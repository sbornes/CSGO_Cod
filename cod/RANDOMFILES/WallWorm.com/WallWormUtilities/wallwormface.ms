/*
Worm Face

Source Game Engine Texture Application in 3ds

Copyright (c) 2011-2015 by Shawn Olson

Thanks to denisT for providing me with the code for collecting a face from the mouse selection in the viewport.
Not only was the code needed here... but it was very educational for me as I had not encountered several
of the methods used in the functions.

www.wallworm.com
*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")

if ::wallworm_game_settings != undefined AND ::wallworm_game_settings.ents != undefined AND ::wallworm_game_settings.ents.count > 0 then (
	--parse the FGD to get entities
) else (
	macros.run "wallworm.com" "wallwormParseFGD2"
)

global WormFace
global wallwormraymesh
global wallwormDecalMode = 1
(
	function wallworm_wormface_setPreview = (
		if ::wwmt_wormface_material != undefined then (
			local usemat = ::wwmt_wormface_material
			if classOf ::wwmt_wormface_material == DirectX_9_Shader then (
				if ::wwmt_wormface_material.renderMaterial != undefined then (
					usemat = ::wwmt_wormface_material.renderMaterial
				)
			)
			if classOf usemat == standard then (
				if usemat.diffuseMap != undefined AND classOf usemat.diffuseMap == BitmapTexture AND usemat.diffuseMap.Bitmap.filename != undefined then (
					--WormFace.mat_thumbnail.filename = usemat.diffuseMap.bitmap.filename
					tempBitmap = Bitmap ::WormFace.mat_thumbnail.width ::WormFace.mat_thumbnail.height
					copy usemat.diffuseMap.Bitmap tempBitmap
					::WormFace.mat_thumbnail.Bitmap = tempBitmap
				)
			)
		)
	)
	function wwmt_wormface_getMeshFaceData aMesh =
	(
		-- converted from http://forums.cgsociety.org/archive/index.php/t-714405.html by an Enrico
		oMesh = copy aMesh
		convertTo oMesh Editable_Mesh
		local baMeshFaces = #{1..(meshOp.getNumFaces oMesh)}
		local aaiFaceGroups = #()
		local i = baMeshFaces.numberSet
		while (i > 0) do
		(
			baMeshFacesInGroup = meshOp.getPolysUsingFace oMesh (baMeshFaces as Array)[1] ignoreVisEdges:false threshhold:120
			append aaiFaceGroups (baMeshFacesInGroup as Array)
			baMeshFaces -= baMeshFacesInGroup
			i = baMeshFaces.numberSet
		)
		local aaiQuadsIndex = #()
		local afQuadsArea = #()
		local ap3QuadsNormal = #()
		local p3TempNormal = [0, 0, 0]
		for aiGroup in aaiFaceGroups do(
			if (aiGroup.count == 2) then (
				append aaiQuadsIndex aiGroup
				append afQuadsArea (meshOp.getFaceArea oMesh aiGroup)
				for iFace in aiGroup do(
					p3TempNormal += getFaceNormal oMesh iFace
				)
				append ap3QuadsNormal (normalize(p3TempNormal))
				p3TempNormal = [0, 0, 0]
			)
		)
		delete oMesh
		#(aaiFaceGroups, aaiQuadsIndex, afQuadsArea, ap3QuadsNormal)
	)

	function wallworm_setDecalNodeFace newDecal node faceid = (
		local dispOverride = false
		if isProperty node #Wallworm_Displacement then (
			local br = node.brushNode
			if isValidNode br AND isProperty br #sourceNode AND isValidNode br.sourceNode AND br.sourceFace > 0 then (
				newDecal.sidesNodes = #(br.sourceNode)
				newDecal.sidesFaces = #(0, br.sourceFace)
				dispOverride = true
			)
		)
		if NOT dispOverride then (
			newDecal.sidesNodes = #(node)
			newDecal.sidesFaces = #(0, faceid)
		)
	)

	function wwmt_set_decal r node faceid = (
		if r != undefined then (
			dwidth = 128
			dlength = 128
			if ::wwmt_wormface_material != undefined then (
				if ::wwmt_wormface_material.diffuseMap != undefined AND classOf ::wwmt_wormface_material.diffuseMap == BitmapTexture AND ::wwmt_wormface_material.diffuseMap.Bitmap != undefined then (
					dwidth = ::wwmt_wormface_material.diffuseMap.Bitmap.width
					dlength = ::wwmt_wormface_material.diffuseMap.Bitmap.height
				)
			)
			local newDecal = Plane pos:r.pos length:dlength width:dwidth lengthsegs:1 widthsegs:1
			newDecal.mat = ::wwmt_wormface_material
			newDecal.dir = r.dir
			newDecal.castShadows = off

			in coordsys local newDecal.pivot = newDecal.pivot + [0, 0, -1]
			in coordsys local newDecal.pos.z += 1
			setUserProp newDecal #wwmt_decal "true"

			--setUserProp newDecal #wwmt_decal_angle_flip "true"
			case wallwormDecalMode of (
				2 : (
					newDecal.name = uniqueName "WW Decal "

					test = ::wallworm_game_settings.get_entity_by_name "infodecal"
					if test != undefined AND test.ca != undefined then (
						custAttributes.add newDecal test.ca
					) else (
						setUserProp newDecal #GLBPntData "infodecal,targetname,LowPriority"
						setUserProp newDecal #GLBPntValu (",;,0")
						setTransformLockFlags newDecal #{7, 8, 9}
					)
				)

				3 :
				(
					newDecal.name = uniqueName "WW Overlay "
					test = ::wallworm_game_settings.get_entity_by_name "info_overlay"
					if test != undefined AND test.ca != undefined then (
						custAttributes.add newDecal test.ca
						newDecal.endv = -1
						if isProperty newDecal #sidesNodes then (
							wallworm_setDecalNodeFace newDecal node faceid
							--Conform 
							/*	c = conformSpaceWarp()
							c.standoff_distance = 8
							bindSpaceWarp node c
							c.transform.controller  = newDecal.transform.controller*/
						)

						if newDecal.version < 26 then (
							messageBox "Unfortunately, Overlays don't work in this version of your FGD cache! Go to your WW Settings and reparse the Entity Cache."
						)

					) else (
						setUserProp newDecal #GLBPntData "info_overlay,targetname,material,sides,RenderOrder,StartU,EndU,StartV,EndV,BasisOrigin,BasisU,BasisV,BasisNormal,uv0,uv1,uv2,uv3,fademindist,fademaxdist"
						setUserProp newDecal #GLBPntValu (",;,;,;,0,0.0,1.0,0.0,1.0,;,;,;,;,;,;,;,;,-1,0")
						setUserProp newDecal #GLBFlags "0"
					)
				)
				4: (
					newDecal.name = uniqueName "WW Overlay Transition "
					test = ::wallworm_game_settings.get_entity_by_name "info_overlay_transition"
					if test != undefined AND test.ca != undefined then (
						custAttributes.add newDecal test.ca
						if isProperty newDecal #sidesNodes then (
							wallworm_setDecalNodeFace newDecal node faceid
							/*
							newDecal.sides2Nodes = #(node)
							newDecal.sides2Faces = #(0,faceid)*/
						)
					) else (
						setUserProp newDecal #GLBPntData "info_overlay_transition,material,sides,sides2,LengthTexcoordStart,LengthTexcoordEnd,WidthTexcoordStart,WidthTexcoordEnd,Width1,Width2,DebugDraw"
						setUserProp newDecal #GLBPntValu (",;,;,;,0.0,1.0,0.0,1.0,25.0,25.0,0")
						setUserProp newDecal #GLBFlags "0"
					)
				)
				5: (
					newDecal.name = uniqueName "WW Projected Decal "
					test = ::wallworm_game_settings.get_entity_by_name "info_projecteddecal"
					if test != undefined AND test.ca != undefined then (
						custAttributes.add newDecal test.ca
					) else (
						setUserProp newDecal #GLBPntData "info_projecteddecal,angles,targetname,Distance"
						setUserProp newDecal #GLBPntValu (",0 0 0,;,64")
						setUserProp newDecal #GLBFlags "0"
					)
				)
			)

			if wallwormDecalMode > 2 then (
				local newMat
				if ::wwmt_wormface_material != undefined then (
					newMat = ::wwmt_wormface_material
				)
				if ::WormFace != undefined AND isValidNode WormFace.lastNode then (
					lastoverlay = WormFace.lastNode
					newDecal.length = lastoverlay.length
					newDecal.width = lastoverlay.width
					::wallworm_set_overlay_uvs_from_mat newDecal
					if newMat == undefined then (
						newMat = lastoverlay.mat
					)
					if newMat != undefined AND ::WormFace.ckbInstanced.checked == false then (
						if classOf newMat == Standard then (
							local dmap1 = newMat.diffusemap
							local dmap
							if dmap1 != undefined then (
								dmap = copy dmap1
								dmap.name = dmap1.name
							)
							local nmap = copy newMat
							nmap.diffusemap = dmap
							if newMat.diffusemap == newMat.opacityMap then (
								nmap.opacityMap = dmap
							)
							nmap.name = uniqueName newMat.name
							newDecal.mat = nmap
						)
					)
				)
				if newMat != undefined then (
					newDecal.wwmt_material = newMat.name
					if getFileNameType newDecal.wwmt_material == "" then (
						newDecal.wwmt_material = newDecal.wwmt_material + ".vmt"
					)
				)
				::WormFace.lastNode = newDecal
			)

		)
	)

	function wwmt_set_mat obj obj_face = (
		if ::wwmt_wormface_material == undefined then (
			messageBox "You must choose a material first. Hold Alt+Click to pick a material from a face. Or click the Get Material from Library Button."
			false
		) else (
			if wallwormDecalMode == true then (
				--::wwmt_set_decal (getFaceNormal obj obj_face) obj obj_face
			) else (
				if (getUserProp obj #ww_wwdt_displacement_brush) != undefined then (
					obj.mat = ::wwmt_wormface_material
				) else (
					local convertToP = false
					local allowedType = false
					-- OR  classOf obj == editable_mesh
					if classOf obj == Editable_Poly OR classOf obj == Editable_Mesh then (
						allowedType = true
					) else(
						if WormFace.ckb_convert.checked == true then (
							convertTo obj Editable_Mesh
							allowedType = true
							convertToP = true
						) else (
							--This is an option needing exploration
							--theMod = Edit_Poly()
							--addModifier obj theMod
							--allowedType = true	
						)
					)
					if allowedType then (
						local currentMat
						if obj.mat != undefined then (
							currentMat = obj.mat
						) else (
							currentMat = ::wwmt_wormface_material
							obj.mat = currentMat
						)

						if classOf currentMat != MultiMaterial then (
							with redraw off (
								if classOf obj == Editable_Poly then (
									polyop.setFaceMatID obj #{1..(polyop.getNumFaces (obj))} 1
								) else if classOf obj == Editable_Mesh then (
									for start = 1 to obj.numfaces do (
										setFaceMatID obj start 1
									)
								) else (
									--polyop.setFaceMatID obj #{1..(polyop.getNumFaces (obj))} 1
									--messagebox "At the moment, this function only works on Editable Poly and Editable Mesh."
								)
								obj.mat = MultiMaterial numsubs:1
								obj.mat[1] = currentMat
							)
						)
						local notfound = true
						local matId = undefined
						--iterate through each submaterial of the multi-material
						for i = 1 to obj.mat.numsubs while notfound do (
							--set the materialID to the material that matches the currently selected material if found
							if obj.mat[i] != undefined AND (obj.mat[i] == ::wwmt_wormface_material OR obj.mat[i].name == ::wwmt_wormface_material.name) then (
								matId = i
								notfound = false
							)
						)
						--Add a new material to the multimaterial if the selected material hasn't been found
						if notfound == true then (
							local newSubNumber = obj.mat.numsubs + 1
							obj.mat.numsubs = newSubNumber
							obj.mat[newSubNumber] = ::wwmt_wormface_material
							matId = newSubNumber
						)

						if matId != undefined then (
							if classOf obj == Editable_Poly then (
								polyop.setFaceMatID obj obj_face matId
							) else if classOf obj == Editable_Mesh then (
								local flist = meshop.getPolysUsingFace obj #{obj_face} ignoreVisEdges:false
								for f in (flist as Array) do (
									setFaceMatID obj f matId
								)
								update obj.Mesh
							) else (
								--polyop.setFaceMatID obj #{1..(polyop.getNumFaces (obj))} 1
							)
						)
						if convertToP then (
							convertToPoly obj
						)
					) else (
						messageBox "This tool currently only works with Editable Poly and Editable Mesh Objects."
					)
				)
			)
		)
	)

	function wwmt_get_mat obj obj_face = (
		if obj.mat != undefined then (
			if classOf obj.mat == MultiMaterial AND (getUserProp obj #ww_wwdt_displacement_brush) == undefined then (
				--get material
				--local temp = copy obj
				local id = getFaceMatID obj.Mesh obj_face
				if obj.mat[id] != undefined then (
					::wwmt_wormface_material = obj.mat[id]
				) else (
					::wwmt_wormface_material = obj.mat[1]
					--messagebox "The selected face has no material."
				)
			) else (
				::wwmt_wormface_material = obj.mat
			)
			wallworm_wormface_setPreview()
		) else (
			messageBox "This object has no material."
		)
	)

	function sortByDistance n1 n2 pos:[0, 0, 0] = (
		--provide by denisT
		local d1 = distance n1[2].pos pos
		local d2 = distance n2[2].pos pos
		if d1 > d2 then 1 else if d1 < d2 then -1 else 0
	)

	function pickingFace msg ir obj faceNum shift ctrl alt = (
		--base provide by denisT
		local node, face, faceid
		case msg of (
			#mousePoint:
			(
				local wray = mapScreenToWorldRay mouse.pos
				local inodes1 = intersectRayScene wray
				inodes = for obj in inodes1 WHERE NOT obj[1].ishiddenInVpt AND NOT isGroupHead obj[1] collect obj
				if inodes.count > 0 then (
					qsort inodes sortByDistance pos:wray.pos
					node = inodes[1][1]
					wallwormraymesh.free()
					wallwormraymesh.Initialize 10

					--see if this is a sculpt mesh
					if isProperty node #Wallworm_Displacement_Sculpt_Mesh then (
						local limitedArray = for obj in inodes1 WHERE (findItem node.dispList obj[1]) > 0 collect obj[1]
						case limitedArray.count of (
							0:(
								--do nothing
							)
							1:(
								node = limitedArray[1]
							)
							default:(
								qsort limitedArray sortByDistance pos:wray.pos
								node = limitedArray[1]
							)
						)
					)

					wallwormraymesh.addNode node
					wallwormraymesh.buildGrid()
					local hits = wallwormraymesh.intersectRay wray.pos wray.dir off
					faces = for i = 1 to hits collect wallwormraymesh.getHitFace i
					if (i = wallwormraymesh.getClosestHit()) != 0 do face = faces[i]
					meshData = wwmt_wormface_getMeshFaceData node
					/*
					format "Quads indexes -> %\n" meshData[2]
					*/
					notface = true
					if NOT alt AND classOf node == Editable_Poly then (
						for f = 1 to meshData[1].count while notface do (
							if (findItem meshData[1][f] face) != 0 then (
								faceid = f
								--notface = false
							)
						)
					) else (
						faceid = face
					)
					if alt == true then (
						--get face material
						wwmt_get_mat node faceid
					) else (
						global wallwormDecalMode
						if wallwormDecalMode > 1 then (
							wwmt_set_decal (intersectRay node wray) node faceid
						) else (
							--place material
							wwmt_set_mat node faceid
						)
					)
				)
				--format "node:% trimesh% face:%\n" node face faceid

			)
		)
		if msg == #mouseAbort then #abort else #continue
	)

	try(destroyDialog WormFace)catch(
		--there was not any open
	)

	rollout WormFace "Worm Face" width:398 height:178
	(
		local lastNode
		Bitmap wormfaceicon "Worm Face" pos:[0, 0] width:128 height:128 fileName:"C:/Program Files/Autodesk/3ds Max 2015/scripts/WallWorm.com/assets/worm_face.png"
		MaterialButton btn_get_mat "Get Material from Library" pos:[136, 6] width:153 height:30 toolTip:"Set the material by browsing your material libraries."
		Bitmap mat_thumbnail "Preview" pos:[294, 6] width:30 height:30
		Button btn14 "Start" pos:[257, 101] width:132 height:62 toolTip:"Start picking objects. Once started: Click to dump materials. Alt-Click to pick materials. Right-Click to end."
		CheckButton ckb_convert "Convert To Poly" pos:[257, 44] width:132 height:22 toolTip:"This tool can only dump materials onto Editable Poly faces. When you turn this button on, the tool will convert picked items into Editable Poly objects."
		Hyperlink link_help "Help and Info" pos:[140, 145] width:79 height:17 address:"http://dev.wallworm.com/topic/36/worm_face.html" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
		Hyperlink linkWW "WallWorm.com" pos:[6, 144] width:96 height:17 address:"http://www.wallworm.com" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
		RadioButtons rdoTextureDrop "Mode" pos:[139, 40] width:108 height:94 labels:#("Texture Drop", "Decal", "Overlay", "Overlay Transition", "Projected Decal") default:1 columns:1
		CheckButton ckbInstanced "Instanced Material" pos:[256, 71] width:133 height:21 enabled:true checked:true
		on btn_get_mat picked mtl do
		(
			if mtl != undefined then (
				::wwmt_wormface_material = mtl

				usemat = mtl

				if classOf mtl == DxMaterial then (
					if mtl.renderMaterial != undefined then (
						usemat = mtl.renderMaterial
					)
				)

				if classOf usemat == standard then (
					wallworm_wormface_setPreview()
				)
			)
		)
		on btn14 pressed do
		(
			wallwormraymesh = RayMeshGridIntersect()
			with undo off mouseTrack trackCallback:pickingFace
			wallwormraymesh.free()
		)
		on rdoTextureDrop changed stat do
		(
			::wallwormDecalMode = stat

			if stat == 1 then (
				ckb_convert.enabled = true
			) else(
				ckb_convert.enabled = false
			)

		)
	)
	createDialog WormFace
	wallworm_wormface_setPreview()
)