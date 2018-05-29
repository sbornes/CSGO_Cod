

try(destroyDialog wwmtSpecToAlpha)catch(
	--there was not any open
)

wwmt_matsforAlphaSpec = #()
wwmt_specSelectedMat = undefined
wwmt_material_targets = #("Bump", "Displacement", "Self-Illumination", "Diffuse")
wwmt_specTargetState = 1
if ::wwmt_alpha_inverstatus != true AND ::wwmt_alpha_inverstatus != false then (
	::wwmt_alpha_inverstatus = false
)

::wwmt_alphacompfn = function wwmt_alphacompfn c1 p1 c2 p2 =
(
	local res = c2 -- keep bitmap colors
	if ::wwmt_alpha_inverstatus == true then (
		res.alpha = 255.0 - c1.value
	) else (
		res.alpha = c1.value -- use specular value as bump alpha
	)
	res
)

function wwmt_hasBumpmap mat = (
	local found = false

	if mat.bumpMap == undefined AND mat.displacementMap == undefined then (
		 false
	) else (
		if (mat.displacementMap != undefined AND (classOf mat.displacementMap == Bitmaptexture OR (classOf mat.displacementMap == Normal_Bump AND classOf mat.displacementMap.normal_map == Bitmaptexture))) then (
			 true
		) else (
			if (mat.bumpMap != undefined AND (classOf mat.bumpMap == Bitmaptexture OR (classOf mat.bumpMap == Normal_Bump AND classOf mat.bumpMap.normal_map == Bitmaptexture))) then (
				true
			) else (
				false
			)
		)		
	)
)

function addStandardMaterialToArray &matarray &mat = (
	if mat != undefined then (
		inList = false
		for m in matarray while inList == false do (
			--for m in materials do (
			try (
				if m.mat == mat do (inList = true)
			) catch()
		)

		if (inList == false) then (
			if (classOf mat == Standardmaterial) then (
				if mat.specularLevelMap != undefined AND classOf mat.specularLevelMap == Bitmaptexture AND (wwmt_hasBumpmap(mat) == true) then (
					--print (classOf mat.specularLevelMap)
					appendIfUnique matarray mat
				)
			) else (
				if (classOf mat == MultiMaterial) then (
					for m in mat.materialList do (
						addStandardMaterialToArray matarray m
					)
				) else (
					if (classOf mat == Shell_Material) then (
						addStandardMaterialToArray matarray mat.bakedMaterial
					)
				)
			)
		)
	)
)

function copyAlphaFromTo fromTex toTex doPaste:false = (
	case of (
		(classOf fromTex != Bitmaptexture) : (
			messageBox "The Specular texture was invalid."
			false
		)
		(classOf toTex != Bitmaptexture) : (
			messageBox "The target texture was invalid."
			false
		)
		/*
		Probably not necessary with composite method
		(fromTex.Bitmap.height != toTex.Bitmap.height) : (
			messageBox "The specular map and the target map do not have the same height. The must be the same dimensions."
			false
		)
		(fromTex.Bitmap.width != toTex.Bitmap.width) : (
			messageBox "The specular map and the target map do not have the same width. The must be the same dimensions."
			false
		)*/
		default:(
			--local newMap =  bitmap toTex.Bitmap.width toTex.Bitmap.height color:(color 128 128 255 0) gamma:1.0
			/*if  doPaste then (
				newMap = bitmap toTex.Bitmap.width toTex.Bitmap.height color:(color 128 128 255 0) gamma:1.0
				pastebitmap toTex.Bitmap newMap [0, 0] [0, 0]   type:#paste 
			) else (
				newMap = copy toTex.Bitmap
			)
			*/
			--pastebitmap fromTex.Bitmap newMap [0, 0] [0, 0] type:#function function:::wwmt_alphacompfn
			local gma --= gammainfo
			local metadata --davemetadata
			local newFileName = selectSaveBitMap caption:"Save New Bitmap"  gamma:&gma metadata:&metadata
			if newFileName != undefined then (
				if (getFilenameType newFileName) != ".tga" then (
					messageBox "You must save the image as a TGA file!"
					false
				) else (
					local comp = compositeTextureMap ()
					comp.mapList = #(toTex)
					comp.mask = #(fromTex)
					local newMap
					if gma != #auto then (
						newMap =  bitmap toTex.Bitmap.width toTex.Bitmap.height color:(color 128 128 255 0) gamma:gma
					) else (
						newMap =  bitmap toTex.Bitmap.width toTex.Bitmap.height color:(color 128 128 255 0)
					)
					--local newmap = renderMap comp size:([toTex.Bitmap.width,toTex.Bitmap.height]) filename:newFileName  filter:true display:true
					/*::test = comp
					newMap.filename = newFileName*/
					--save newMap
					
					fromTex.output.invert = ::wwmt_alpha_inverstatus
					fromTex.alphaSource = 1
					
					renderMap comp size:([toTex.Bitmap.width,toTex.Bitmap.height]) into:newmap   filter:true display:false
					newmap.filename=newFileName
					save newmap gamma:gma metadata:metadata
					/*newTex.Bitmap = newmap
					theMat.bumpMap = newTex
					close newmap*/
					
					#(newmap,comp,newFileName, gma, metadata)
				)
			) else (
				false
			)
		)
	)
)

rollout wwmtSpecToAlpha "Wall Worm Alpha Spec" width:416 height:281
(
	local wwmt_matsforAlphaSpec = #()
	listbox lbxMaterials "Materials With Specular Level Bitmaps" pos:[10,25] width:391 height:9 selection:0 toolTip:"A list of materials that have Specular Level and a Bump/Displacement map."
	button btnRefreshMaterials "Update Material List" pos:[279,8] width:124 height:33 toolTip:"Click here to generate a list of materials from the current scene selection that are candidates for merging the Specular Level into the Alpha of another bitmap."
	radiobuttons rdoCopyTo "Copy Specular Level to Alpha Of:" pos:[10,173] width:96 height:78 labels:#("Bump", "Displacement", "Self-Illumination", "Diffuse") columns:1
	checkbutton ckbInvert "Invert Alpha" pos:[184,173] width:218 height:29 toolTip:"Reverse the Alpha values." checked:false
	button btnSendSpecToAlpha "Do It" pos:[185,206] width:217 height:44 enabled:false
	HyperLink alphaspcelink "Important Documentation - READ BEFORE USE!" pos:[169,255] width:232 height:15 address:"http://dev.wallworm.com/topic/34/alpha_spec.html" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	function updateMaterialList = (
		if selection.count > 0 then (
			wwmt_matsforAlphaSpec = #()
			for obj in selection do (
				if obj.mat != undefined then (
					addStandardMaterialToArray wwmt_matsforAlphaSpec obj.mat
				)
			)
			if wwmt_matsforAlphaSpec.count > 0 then (
				theItems = #()
				for m in wwmt_matsforAlphaSpec do (
					append theItems m.name
				)
				lbxMaterials.items = theItems
				btnSendSpecToAlpha.enabled = true
				if wwmt_matsforAlphaSpec.count == 1 then (
					lbxMaterials.selection = 1
					wwmt_specSelectedMat = wwmt_matsforAlphaSpec[1]
				) else (
					lbxMaterials.selection = 0
				)
				
			) else (
				btnSendSpecToAlpha.enabled = false
			)
		)
	)
	
	on wwmtSpecToAlpha open do
	(
			updateMaterialList()
		)
	on lbxMaterials selected sel do
	(
		if sel != undefined AND sel > 0 then (
			theMat = wwmt_matsforAlphaSpec[sel]
			wwmt_specSelectedMat = theMat
			local newItems = #()
	
			if theMat.diffuseMap != undefined AND classOf theMat.diffuseMap == Bitmaptexture then (
				append newItems "Diffuse"
			)
			if theMat.selfIllumMap != undefined AND classOf theMat.selfIllumMap == Bitmaptexture then (
				append newItems "Self-Illumination"
			)
			if (theMat.displacementMap != undefined AND (classOf theMat.displacementMap == Bitmaptexture OR (classOf theMat.displacementMap == Normal_Bump AND classOf theMat.displacementMap.normal_map == Bitmaptexture))) then (
				append newItems "Displacement"
			)
			if (theMat.bumpMap != undefined AND (classOf theMat.bumpMap == Bitmaptexture OR (classOf theMat.bumpMap == Normal_Bump AND classOf theMat.bumpMap.normal_map == Bitmaptexture))) then (
				append newItems "Bump"
			)
	
			if newItems.count > 0 then (
				btnSendSpecToAlpha.enabled = true
			) else (
				btnSendSpecToAlpha.enabled = false
			)
		)
	)
	on btnRefreshMaterials pressed do
	(
		if selection.count > 0 then (
			updateMaterialList()
			if wwmt_matsforAlphaSpec.count == 0 then  (
				messageBox "No valid materials were found in the selection."
			)
	
		) else (
			messageBox "You must select some objects."
		)
	
	)
	on rdoCopyTo changed stat do
	(
		wwmt_specTargetState = stat
		
		if stat == 4 then (
			::wwmt_alpha_inverstatus = ckbInvert.state = true
		) else (
			::wwmt_alpha_inverstatus = ckbInvert.state = false
		)
	)
	on ckbInvert changed state do
	(
		wwmt_alpha_inverstatus = state
	)
	on btnSendSpecToAlpha pressed do
	(
		if wwmt_specSelectedMat == undefined then (
			messageBox "Select a material from the list first."
			return false
		)
	
		local setNormalFlag = false
		local theMat = wwmt_specSelectedMat
	
		local selected = wwmt_material_targets[wwmt_specTargetState]
		local copied = false
		local newTex = undefined
		local res
		case of (
			(selected == "Diffuse" AND theMat.diffuseMap != undefined AND classOf theMat.diffuseMap == Bitmaptexture ) : (
				res = copyAlphaFromTo theMat.specularLevelMap theMat.diffuseMap
				if res != false then (
					local comp = res[2]
					comp.name = "SpecularInDiffuse"
					local toTex = comp.mapList[1]
					theMat.diffuseMap = comp
					local newmap = res[1]
					newTex = copy toTex
					newTex.Bitmap = newmap
					theMat.diffuseMap = newTex
					close newmap
				)
			)
			(selected == "Self-Illumination" AND theMat.selfIllumMap != undefined AND classOf theMat.selfIllumMap == Bitmaptexture  ) :  (
				res = copyAlphaFromTo theMat.specularLevelMap theMat.selfIllumMap
				if res != false then (
					local comp = res[2]
					comp.name = "SpecularInIllum"
					local toTex = comp.mapList[1]
					theMat.selfIllumMap = comp
					local newmap = res[1]
					newTex = copy toTex
					newTex.Bitmap = newmap
					theMat.selfIllumMap = newTex
					close newmap
				)
			)
			(selected == "Displacement" AND (theMat.displacementMap != undefined AND (classOf theMat.displacementMap == Bitmaptexture OR (classOf theMat.displacementMap == Normal_Bump AND classOf theMat.displacementMap.normal_map == Bitmaptexture)))  ) :  (
				if classOf theMat.displacementMap == Bitmaptexture then (
					res = copyAlphaFromTo theMat.specularLevelMap theMat.displacementMap doPaste:true
					if res != false then (
						local comp = res[2]
						comp.name = "SpecularInBump"
						local toTex = comp.mapList[1]
						theMat.displacementMap = comp
						local newmap = res[1]
						setNormalFlag = true
						newTex = copy toTex
						newTex.Bitmap = newmap
						theMat.displacementMap = newTex
						close newmap
					)
				) else (
					res = copyAlphaFromTo theMat.specularLevelMap theMat.displacementMap.normal_map  doPaste:true
					if res != false then (
						local comp = res[2]
						comp.name = "SpecularInBump"
						local toTex = comp.mapList[1]
						theMat.displacementMap.normal_map = comp
						local newmap = res[1]
						setNormalFlag = true
						newTex = copy toTex
						newTex.Bitmap = newmap
						theMat.displacementMap.normal_map = newTex
						close newmap
					)
				)
			)
			( selected == "Bump" AND (theMat.bumpMap != undefined AND (classOf theMat.bumpMap == Bitmaptexture OR (classOf theMat.bumpMap == Normal_Bump AND classOf theMat.bumpMap.normal_map == Bitmaptexture)))  ) :  (
				if classOf theMat.bumpMap == Bitmaptexture then (
					res = copyAlphaFromTo theMat.specularLevelMap theMat.bumpMap  doPaste:true theMat:theMat mapName:#bumpMap
					if res != false then (
						local comp = res[2]
						comp.name = "SpecularInBump"
						local toTex = comp.mapList[1]
						theMat.bumpMap = comp
						local newmap = res[1]
						setNormalFlag = true
						newTex = copy toTex
						newTex.Bitmap = newmap
						theMat.bumpMap = newTex
						close newmap
					)
				) else (
					res = copyAlphaFromTo theMat.specularLevelMap theMat.bumpMap.normal_map  doPaste:true
					if res != false then (
						local comp = res[2]
						comp.name = "SpecularInBump"
						local toTex = comp.mapList[1]
						theMat.bumpMap.normal_map = comp
						local newmap = res[1]
						setNormalFlag = true
						newTex = copy toTex
						newTex.Bitmap = newmap
						theMat.bumpMap.normal_map = newTex
						close newmap
					)
				)
			)
			default:()
		)
		
		if newTex != undefined then (
			if ::WallwormProActive == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			if ::WallwormProActive == true then (
				::wallworm_update_texture_ca newTex addca:true
				newTex.wallworm_texture_CA.compression = "DXT5"
				if setNormalFlag then (
					newTex.setTextureFlag newTex.wwTextureFlags_Normal
				)
			)
			
			local specVersion = copy newTex
			specVersion.name = newTex.name
			specVersion.monoOutput = 1
			specVersion.rgbOutput = 1
			--specVersion.output.invert = ::wwmt_alpha_inverstatus
			theMat.specularLevelMap = specVersion
			/*
			wallworm_update_texture_ca specVersion addca:true
			specVersion.wallworm_texture_CA.compression = "DXT5"
			*/
			
			format "The specular color was copied to the % alpha channel.\n" selected
		) else (
			messageBox ("The specular color was NOT copied to the " + selected + " alpha channel.")
		)
	
	)
)

createDialog wwmtSpecToAlpha
