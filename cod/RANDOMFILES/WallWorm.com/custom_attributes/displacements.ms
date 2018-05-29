global wallworm_displacement_brush_node_CA = attributes "Wallworm Displacement Brush Node" version:15 (
	local wallworm = true
	local ww_displacement_brush = true
	local disp = undefined
	local thisNode = undefined

	parameters main rollout:params (
		dispName type:#string
		power type:#integer default:2 animatable:false
		isUpdating type:#boolean default:false
		sourceNode type:#node
		sourceFace type:#integer default:0
		transformStore type:#matrix3 default:(matrix3 1)
	)
	function getNode = (
		if NOT isValidNode thisNode then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	on clone orig do thisNode = undefined
	on update do (
		case of (
			(version < 10) : (
				getNode()
				if isValidNode thisNode then (
					transformStore = thisNode.transform
				)
			)
		)
	)

	function alignToBrushFace = (
		
		if sourceFace != undefined AND isValidNode sourceNode   then (
			getNode()
			local shouldDelete = classof sourceNode != Editable_Poly
			local useNode = sourceNode
			local offsetTM = undefined
			if shouldDelete then (
				useNode = snapshot useNode
				--resetXForm useNode
				convertToPoly useNode
			)
			if useNode.numfaces >= sourceFace then (
					if  (vv = polyop.getFaceVerts useNode sourceFace).count == 4 then
					(
						local gv = polyop.getVert
						in coordsys world (
							v1 = gv useNode vv[1] node:useNode
							v2 = gv useNode vv[2] node:useNode
							v3 = gv useNode vv[3] node:useNode
							v4 = gv useNode vv[4] node:useNode
						)
						local xaxis = normalize (v2 - v1)
						local temp = v1 - v4
						local zaxis = normalize (cross temp xaxis)
						local yaxis = normalize (cross zaxis xaxis)
						local trans = (v2 + v1 + v4 + v3) * 0.25		
						local tm = (Matrix3 xaxis yaxis zaxis trans)
						thisNode.transform = tm
					)
			)
			if shouldDelete then (
				delete useNode
			)
		)
	)
	
	function setDisp d = (
		if isValidNode d then (
			disp = d
			getNode()
			setUserProp thisNode #ww_wwdt_displacement_target disp.name
		)
	)

	function getDisp = (
		if NOT isValidNode disp then (
			thisNode = getNode()
			dispName = getUserProp thisNode #ww_wwdt_displacement_target
			if dispName != undefined AND dispName != "" then (
				disp = getNodeByName dispName
			)
		)
		disp
	)

	function getOtherBrushesUsingSourceNode = (
		if isValidNode sourceNode then (
			for obj in objects WHERE isProperty obj #ww_displacement_brush AND isProperty obj #sourceNode AND obj.sourceNode == sourceNode collect obj
		)
	)

	function getDisplacementsOfSourceNode = (
		local brs = getOtherBrushesUsingSourceNode()
		if brs != undefined then (
			local res = for br in brs collect br.getDisp()
			res = for obj in res WHERE isValidNode obj collect obj
			res
		)
	)

	function showBrush = (
		getNode()
		getDisp()
		hide disp
		unhide thisNode
		if thisNode.isHidden then (
			thisNode.isHidden = false
		)
	)

	function deleteMe = (
		disableRefMsgs()
		thisNode = getNode()
		getDisp()
		local doDelete = true
		if isValidNode disp then (
			if (disp.canDelete()) == true then (
				delete disp
			) else (
				doDelete = false
			)
		)
		if doDelete == true then (
			delete thisNode
		)
		enableRefMsgs()
	)

	rollout params "Options" (
		Label dispLabel ""

		Button alignToBrush "Move Displacement Here" tooltip:"Moves this displacement to match the position and rotation of the underlying brush face (this current object)."
		Button gotoDisp "Get Displacement" tooltip:"Select the displacement this displacement brush face controls."
		Button unlockMe "Allow Movement" toolTip:"Press here if the displacement brush cannot move."
		Button btnOtherBrushes "Get Shared Brush" tooltip:"Select all displacements derived from the same brush."
		on btnOtherBrushes pressed do (
			if isValidNode SourceNode then (
				local res = getOtherBrushesUsingSourceNode()
				if res != undefined then select res
			) else (
				messagebox "This displacement has no source geometry."
			)
		)
		on unlockMe pressed do (
			setTransformLockFlags $ #{7, 8, 9}
		)
		on alignToBrush pressed do (
			if disp != undefined then (
				disp.position = $.position
				disp.rotation = $.rotation

			) else (
				messageBox "It appears the displacement is missing! You will need to recreate this displacement :("
			)

		)

		on gotoDisp pressed do (
			if disp != undefined then (
				unhide disp
				select disp
				if disp.isHidden then (
					disp.isHidden = false
				)
			)

		)
		Button btnAlignFace "Align To Brush Face"
		on btnAlignFace pressed do (
			alignToBrushFace()
		)
		Button btnSelectBrushNode "Select Brush" tooltip:"Select the source geometry from which this displacement was derived."
		on btnSelectBrushNode pressed do (
			if isValidNode SourceNode then (
				select SourceNode
				if SourceNode.isHidden then (
					unhide SourceNode
				)
			) else (
				messagebox "This displacement has no source geometry."
			)
		)

		on params open do (
			if $ != undefined AND isProperty $ "ww_displacement_brush" then (
				showBrush()

				if isValidNode disp then (
					dispLabel.text = ("For: " + disp.name)

				) else (
					--delete $
				)
			)

		)
	)
)

global wallworm_displacement_CA = attributes "Wallworm Displacement" version:17 (
	local wallworm = true
	local ww_displacement = true

	parameters main rollout:params (
		power type:#integer default:2 animatable:false
		sg type:#integer ui:sg_ui default:0 animatable:false
		dispflags type:#integer default:0 animatable:false
		lightmapScale type:#integer ui:lightmapscale_spinner default:16 animatable:false
		NoPhys type:#boolean ui:noPhys_checkbox default:false animatable:false
		NoHull type:#boolean ui:noHull_checkbox default:false animatable:false
		NoRay type:#boolean ui:noRay_checkbox default:false animatable:false
		brushNode type:#node animatable:false
		isUpdating type:#boolean default:false
		dispinfo type:#string default:""

	)

	function getNode = (
		refs.dependentnodes (custAttributes.getOwner this) firstonly:on
	)

	function canDelete = (
		local can = true
		thisNode = getNode()
		disps = for obj in objects WHERE isProperty obj #wallworm_edit_mesh AND findItem obj.displist thisNode > 0 collect obj
		if disps.count > 0 then (
			can = false
		)
		can
	)

	function deleteMe = (
		if (canDelete()) = true then (
			disableRefMsgs()

			if isValidNode brushNode then (
				delete brushNode

			)
			thisNode = getNode()
			delete thisNode

			enableRefMsgs()

		)
	)

	function stopIgnoreEventPropagation = (
		thisNode = getNode()
		setUserProp thisNode #wallworm_ignore_event_propagation "false"

		if isValidNode brushNode then (
			setUserProp brushNode #wallworm_ignore_event_propagation "false"
		)
	)

	function setAlphaChannel = (
		theDispChunk = getNode()
		polyop.setMapSupport theDispChunk (-2) true
		nverts = theDispChunk.numverts
		polyop.setNumMapVerts theDispChunk (-2) nverts keep:true

		polyop.defaultMapFaces theDispChunk (-2)

		--meshop.setVertAlpha (theDispChunk.mesh) (-2) (#{1..nverts} as array) 1.0

	)

	function bakeDispInfo = (
		local TheVMF = wallwormVMF()
		if TheVMF != undefined then (
			TheVMF.getSkyboxHelper (objects as Array)
			TheVMF.ww_wwdt_makeVMFDisplacement brushNode (getNode()) returnDispInfo:true bakeDispinfo:true
			TheVMF = undefined
		)

	)

	function qaudrifyMe = (
		with redraw off (
			if PolyToolsModeling != undefined AND PolyToolsModeling.Quadrify != undefined then (
				select (getNode())
				PolyToolsModeling.Quadrify false false
			) else (
				messageBox "This function is only available in versions of Max that have the Graphite Modeling Tools and the Quadrify method."
			)
		)

	)

	function bakeMappingToBrush = (
		if isValidNode brushNode then (
			obj = getNode()
			mp = ChannelInfo.CopyChannel obj 3 1
			ChannelInfo.PasteChannel brushNode 3 1

			true
		) else (
			false
		)

	)

	function resetMappingFromBrush = (
		if isValidNode brushNode then (
			mp = ChannelInfo.CopyChannel brushNode 3 1
			obj = getNode()
			ChannelInfo.PasteChannel obj 3 1
			true
		) else (
			false
		)
	)

	function traingulateMe = (
		suspendEditing()
		with redraw off (
			obj = getNode()
			convertToMesh obj
			local meshopautoEdge = meshop.autoEdge
			notDone = true
			while notDOne do (
				local edges = obj.Edges
				meshopautoEdge obj edges 0 type:#SetClear
				if edges.count == (obj.Edges).count then (
					notDone = false
				)
			)
			convertToPoly obj
		)
		resumeEditing()
	)

	rollout params "Displacement Settings" (
		Group "Settings" (
			CheckBox noPhys_checkbox "No Phys" toolTip:"Disables any Physics Objects from Colliding with the displacement."
			CheckBox noHull_checkbox "No Hull Collision" toolTip:"Disables any Player or NPC from Colliding with the displacement."
			CheckBox noRay_checkbox "No Ray Collision" toolTip:"Disables raycasts from Colliding with the displacement. Gunfire and bullets will not collide with the displacement surface."
			Spinner lightmapscale_spinner "Lightmap Scale" range:[1, 256, 16] type:#integer step:1 tooltip:"The lightmaps scale of the displacement. The lower the number, the higher the detail of baked shadows but the larger your BSP file will be."
			Spinner sg_ui "Smoothing Group" range:[0, 32, 0] tooltip:"The smoothing group of this displacement." type:#integer step:1
		)

		CheckButton ckb_texMode "Paint Alpha" toolTip:"Click to edit texture blending on displacements with Alpha Blending using the Vertex Paint tool."
		Button wwDisplayWalkable "Display Walkable" tooltip:"Hilight faces that are too steep to walk on."

		Button wwExportBlend "Export Material" tooltip:"Export a VMT and VTFs from the Blend material applied to this displacement."

		Button copyAlphaToColor "Copy Vertex Alpha to Color" tooltip:"Copy the vertex alpha channel to the vertex color channel."

		Button wwMoveMode "Move Mode" toolTip:"Click here to move the displacement. This is helpful once the displacement has been modified from its original state."
		Button btnGetOtherDisps "Get Affiliated Displacements"

		on btnGetOtherDisps pressed do (
			local res = brushNode.getDisplacementsOfSourceNode()
			if res != undefined then select res
		)

		Button alignToBrush "Align to Brush Face" tooltip:"Moves this displacement to match the position and rotation of the underlying brush face for this displacement."
		Button unlockMe "Allow Movement" toolTip:"Press here if the displacement cannot move. You should mostly use the Move Mode, however."

		Button bakeMe "Bake Info" toolTip:"Press here to update and bake the displacement information (dispinfo). This will make exporting the scene work more quickly."
		Button clearBake "Clear Bake" toolTip:"Press here to remove the baked displacement information for this displacement."
		Button btnQuadrifyMe "Quadrify Me" tooltip:"Quadrify this displacement to make me easier to sculpt."
		Button btnTriangulateMe "Triangulate Me" tooltip:"Triangulate me to display correct walkable surfaces."

		Group "UV" (
			Button btnStoreInBrush "Store Mapping in Brush"
			Button btnresetFromBrush "Restore from Brush"
		)

		Group "Update From Source" (
			CheckBox chkUV "Get UV" checked:true  tooltip:"Get UVW from original brush side."
			CheckBox chkMat "Get Mat" checked:true  tooltip:"Get the material from the Source Node Material."
			CheckBox chkUpdateBrush "Brush Side Topology" checked:true  checked:true tooltip:"Reset Brush Node to the original side shape."
			CheckBox chkUpdateDisp "Reset" checked:true tooltip:"Update the displacement node to the original side shape."
			Button btnGetSourceInfo "Update From Source" tooltip:"If this displacement was generated from the face of an object, re-acquire the original UVs and/or material."
		)

		on btnGetSourceInfo pressed do (
			obj = getNode()
			if isValidNode brushNode.sourceNode then (
				if chkUV.checked OR chkMat.checked OR chkUpdateBrush.checked OR chkUpdateDisp.checked then (
					if ::wallworm_update_displacement_from_source == undefined then (
						try (macros.run "wallworm.com" "WallWormAnvilInitiateMCR") catch (
							messagebox "This function requires Wall Worm to be installed."
						)
					)
					if ::wallworm_update_displacement_from_source != undefined then (
						local res = ::wallworm_update_displacement_from_source obj getUV:chkUV.checked getMat:chkMat.checked brushTopo:chkUpdateBrush.checked dispTopo:chkUpdateDisp.checked
						if res == 0 then (
							messageBox "This displacement was not created from an object or that object has been deleted. "
						)						
					)
				) else (
					messageBox "You must check at least one option."
				)
			) else (
				messageBox "This displacement does not have a sourcenode in the scene."
			)
		)

		on btnresetFromBrush pressed do (
			resetMappingFromBrush()
		)

		on btnStoreInBrush pressed do (
			bakeMappingToBrush()
		)

		on btnQuadrifyMe pressed do (
			if $.modifiers.count == 0 OR queryBox "This Will Collapse the Modifier Stack. Continue?" then (
				qaudrifyMe()
			)
		)

		on btnTriangulateMe pressed do (
			if $.modifiers.count == 0 OR queryBox "This Will Collapse the Modifier Stack. Continue?" then (
				traingulateMe()
			)
		)

		on bakeMe pressed do (
			bakeDispInfo()

		)

		on clearBake pressed do (
			dispinfo = ""
		)

		on unlockMe pressed do (
			setTransformLockFlags $ #{7, 8, 9}
		)

		on alignToBrush pressed do (
			if isValidNode brushNode then (
				$.position = brushNode.position
				$.rotation = brushNode.rotation

			) else (
				messageBox "It appears the underlying brush is missing! You will need to recreate this displacement :("
			)

		)

		on copyAlphaToColor pressed do (
			ChannelInfo.CopyChannel $ 3 (-2)
			ChannelInfo.PasteChannel $ 3 0

		)

		on wwExportBlend pressed do (
			macros.run "wallworm.com" "WallWormAnvilCompileVTFMCR"
		)

		on params open do (
			if isValidNode brushNode then (
				hide brushNode
			)

			if bit.and dispflags 2 == 2 then (
				noPhys_checkbox.checked = true
			)
			if bit.and dispflags 4 == 4 then (
				noHull_checkbox.checked = true
			)
			if bit.and dispflags 8 == 8 then (
				noRay_checkbox.checked = true
			)

		)

		on wwMoveMode pressed do (
			if isValidNode brushNode then (
				if brushNode.Wallworm_Displacement_Brush_Node.version < 5 then (
					wallworm_update_displacement_cas brushNode
				)
				thisNode = getNode()
				if brushNode.disp != thisNode then (
					brushNode.setDisp thisNode
				)

				brushNode.showBrush()

				select brushNode
				setTransformLockFlags brushNode #{7, 8, 9}

				max modify mode
				modPanel.setCurrentObject brushNode.baseObject

			)
		)

		function updateFlagsFromChecks = (
			dispflags = 0

			if noHull_checkbox.checked == true then (
				dispflags += 4

			)
			if noRay_checkbox.checked == true then (
				dispflags += 8

			)

		)

		on noPhys_checkbox changed st do (
			updateFlagsFromChecks()
			dispinfo = ""
		)
		on noHull_checkbox changed st do (
			updateFlagsFromChecks()
			dispinfo = ""
		)
		on noRay_checkbox changed st do (
			updateFlagsFromChecks()
			dispinfo = ""
		)

		on wwDisplayWalkable pressed do (
			if (maxVersion())[1] >= 12000 then (
				try (
					macros.run "wallworm.com" "WW_Face_Walkable"
				) catch (
					messageBox "This function only works if you have Wall Worm installed."
				)
			) else (
				messageBox "This feature only works in 3ds Max 2010+."
			)
		)

		on ckb_texMode changed state do
		(
			if state == true then (
				if ::ww_wwdt_paint == undefined then (
					::ww_wwdt_paint = VertexPaint name:"WW Vertex Paint Modifier" mapChannel:-2
				)
				addModifier $ ::ww_wwdt_paint
				local v = VertexPaintTool()
				v.brushOpacity = 50
				v.curPaintMode = 1
				v.brushSize = 128
				v.brushOpacity = 100
				v.mapDisplayChannel = 0
			) else (
				if queryBox "Collapse to Poly?" then (
					oldSurviveState = custAttribCollapseManager.surviveState
					custAttribCollapseManager.surviveState = true
					convertToPoly $
					custAttribCollapseManager.surviveState = oldSurviveState
				)
			)
		)
	)
)

global wallworm_displacement_edit_disp_CA = attributes "Wallworm Displacement Sculpt Mesh" version:28 (
	local wallworm = true
	local dispMapArray = #()
	local wallworm_edit_mesh = true
	local params
	local thisNode
	function allowed_displacement obj = (isProperty obj #ww_displacement OR isProperty obj #ww_displacement_brush)

	parameters main rollout:params (
		displist type:#nodeTab tabSizeVariable:true
		vertCount type:#integer
		mapints type:#intTab tabSizeVariable:true
		isUpdating type:#boolean default:false
		lastcommittime type:#float default:0
		collapseDisplacements type:#boolean default:true ui:chk_collapseDisplacements
	)
	function getNode = (
		if NOT isValidNode thisNode then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
	)

	on clone orig do thisNode = undefined

	function qaudrifyMe = (
		with redraw off (
			if PolyToolsModeling != undefined AND PolyToolsModeling.Quadrify != undefined then (
				getNode()
				select thisNode
				PolyToolsModeling.Quadrify false false
			) else (
				messageBox "This function is only available in versions of Max that have the Graphite Modeling Tools and the Quadrify method."
			)
		)
	)
	function clearDispMapArray = (
		/*Would you like to free some memory?*/
		dispMapArray = #()
		--setProperty this "dispMapArray" (#())
	)

	function traingulateMe = (
		suspendEditing()
		with redraw off (
			getNode()
			convertToMesh thisNode
			local meshopautoEdge = meshop.autoEdge
			notDone = true
			while notDOne do (
				local edges = thisNode.Edges
				meshopautoEdge thisNode edges 0 type:#SetClear
				if edges.count == (thisNode.Edges).count then (
					notDone = false
				)
			)
			convertToPoly thisNode
		)
		resumeEditing()
	)

	function setArrayMap ar = (
		dispMapArray = ar

		getNode()

		deleteAppData thisNode 1

		local tmpMap = deepCopy dispMapArray
		for a in tmpMap do (
			a[1] = undefined
		)

		with printAllElements on setAppData thisNode 1 (tmpMap as String)
		tmpMap = undefined

	)

	function getArrayMap = (
		return dispMapArray
	)

	function bakeMapArrayString = (
		setArrayMap dispMapArray

		mapints = #()
		getNode()
		--dispMapArray = getProperty this "dispMapArray"
		for entry in dispMapArray do (
			for i in entry[2] do (
				append mapints i

			)

			append mapints 0

			for i in entry[3][1] do (
				append mapints i

			)

			append mapints 0

			for i in entry[3][2] do (
				append mapints i

			)

			append mapints 0

		)
		setproperty thisNode "mapints" mapints

		mapints
	)

	function parsemap = (
		dispMapArray = #()
		getNode()
		local sdata = getAppData thisNode 1
		if sdata != undefined then (
			local ss = StringStream sdata
			local v = readValue ss
			if v != undefined AND v != "" then (
				if v.count == displist.count then (
					dispMapArray = v
					for i = 1 to displist.count do (
						dispMapArray[i][1] = displist[i]
					)
				)
			)
		)
		if dispMapArray.count == 0 then (
			currentCount = 1
			dil = getProperty this "displist"
			mapints = getProperty this "mapints"
			for obj in dil WHERE isValidNode obj do (
				verts = #()
				verts1 = #()
				verts2 = #()
				--verts = mapints[currentCount]
				hasFound0 = false
				while currentCount <= mapints.count AND hasFound0 == false do (
					if mapints[currentCount] == 0 then (
						currentCount += 1
						hasFound0 = true
					) else (
						append verts mapints[currentCount]
						currentCount += 1
					)
				)
				hasFound0 = false
				while currentCount <= mapints.count AND hasFound0 == false do (
					if mapints[currentCount] == 0 then (
						currentCount += 1
						hasFound0 = true
					) else (
						append verts1 mapints[currentCount]
						currentCount += 1
					)
				)
				hasFound0 = false
				while currentCount <= mapints.count AND hasFound0 == false do (
					if mapints[currentCount] == 0 then (
						currentCount += 1
						hasFound0 = true
					) else (
						append verts2 mapints[currentCount]
						currentCount += 1
					)
				)
				theList = #(obj, verts, #(verts1, verts2))
				append dispMapArray theList
			)
			setArrayMap dispMapArray
		)
	)

	function hideAllParts = (
		for d in displist WHERE isValidNode d AND d.isHidden == false do (
			hide d
			setTransformLockFlags d #all
			if isValidNode d.brushNode then (
				setTransformLockFlags d.brushNode #all
				hide d.brushNode
			)
		)
	)

	function bakeAllDispinfo = (
		for d in displist WHERE isValidNode d do (
			d.bakeDispInfo()

		)
	)

	function SendMatToMats = (
		thisDispMesh = refs.dependentNodes (custAttributes.getOwner this) firstOnly: true --baseObjectOnly: <bool> 
		if thisDispMesh.mat != undefined then (
			if classOf thisDispMesh.mat == Standard OR classOf thisDispMesh.mat == Blend OR (classOf thisDispMesh.mat == DirectX_9_Shader AND thisDispMesh.mat.renderMaterial != undefined AND (classOf thisDispMesh.mat.renderMaterial == Blend OR classOf thisDispMesh.mat.renderMaterial == Standard)) then (
				for d in displist WHERE isValidNode d do (
					d.mat = thisDispMesh.mat
				)
				true
			) else (
				false
			)
		) else (
			false
		)
	)

	function addAlphaToAllDisps = (
		disableRefMsgs()
		with redraw off
		with undo off (
			for d in displist WHERE isValidNode d do (
				d.setAlphaChannel()
			)
		)
		enableRefMsgs()
	)

	function updateLastUpdateTime = (
		if lastcommittime > 0 then (
			params.labelLastCommit.text = (((lastcommittime) as String) + " seconds")
		)
	)

	function commit = (
		/*	if theHold.Holding() == false then (
			theHold.Begin()
		)*/
		showEndResult = true
		local started = timestamp()
		max create mode
		getNode()
		disableRefMsgs()
		with redraw off
		with undo off (

			if dispMapArray == undefined OR dispMapArray.count == 0 then (
				parsemap()
			)
			local pv_setVert = polyop.setVert
			local pvSetVertColor = polyop.setVertColor
			local pv_getVert = polyop.getVert

			local DoVAlpha = ((maxVersion())[1] >= 12000)
			if DoVAlpha then (
				local SetSelection = thisNode.SetSelection
				local getVertexColor = thisNode.getVertexColor

			)
			
			if dispMapArray != undefined AND dispMapArray.count > 0 then (
				--AND ((wwdt[1].power == 2 AND wwdt[1].numverts==25)) ... consider adding this block and other powers for displacements that might have invalid number of verts
				for wwdt in dispMapArray WHERE (isvalidNode wwdt[1] == true) do (
					local theDispChunk = wwdt[1]
					if collapseDisplacements OR (classof theDispChunk != editable_poly AND classof theDispChunk != PolyMeshObject) then (
						convertToPoly theDispChunk
					)
					local dispNumVerts = theDispChunk.numverts
					local vertmap = wwdt[3][2]
					for i = 1 to vertmap.count while i <= dispNumVerts do (
						local sculptvert = wwdt[3][1][i]
						local controlMeshVert = pv_getVert thisNode sculptvert --node:$
						pv_setVert theDispChunk vertmap[i] controlMeshVert --node:$
						if DoVAlpha then (
							SetSelection #Vertex #{(sculptvert)}
							local theVertColor = getVertexColor #Alpha
							pvSetVertColor theDispChunk (-2) vertmap[i] theVertColor
						)
					)
				)
			)
		)

		enableRefMsgs()

		local ended = timestamp()
		lastcommittime = ((ended - started) / 1000.0)
		minutes = lastcommittime / 60
		--leftover = mod seconds 60 

		format "Commited in % seconds (% minutes)\n" lastcommittime minutes

		--theHold.Accept "Commit Displacement Changes"
	)

	rollout params "Wall Worm Functions" (
		Group "Sculpt and Paint" (
			CheckButton ckb_texMode "Paint Alpha" tooltip:"Paint the alpha to control blend texture changes."
			Button wwDisplayWalkable "Display Walkable" tooltip:"Hilight faces that are too steep to walk on."
			Button btnQuadrifyMe "Quadrify Me" tooltip:"Quadrify this displacement to make me easier to sculpt."
			Button btnTriangulateMe "Triangulate Me" tooltip:"Triangulate me to display correct walkable surfaces."
			PickButton addDisplacement "Add Displacement" toolTip:"Add a displacement from the scene to this sculpt mesh." filter:allowed_displacement message:"Pick a Wall Worm displacement to add to the sculpt mesh.\n"

		)

		Group "Commit" (
			CheckBox chk_collapseDisplacements "Collapse Displacements" tooltip:"When on, the displacements and displacement brushes will be collapsed to editable poly every time you commit."
			Button wwCommitChanges "Commit Changes" tooltip:"Commit the changes for the mesh."
			Label labelLastCL "Last Commit: " across:2
			Label labelLastCommit ""

			Button wwRevert "Revert to Pieces" tooltip:"Reverts the mesh to the respective parts."
		)

		Group "Miscellaneous" (
			Button bakeMe "Bake Info" toolTip:"Press here to update and bake the displacement information (dispinfo). This will make exporting the scene work more quickly."
			Button clearBake "Clear Bake" toolTip:"Press here to remove the baked displacement information for this displacement."
			Button btn_sendMatToMats "Send Material to Pieces" tooltip:"This will send the current material of the displacement to all underlying displacement pieces."
			Button addAlphas "Fix Alphas" tooltip:"Run this function if your displacements are not getting full alpha values (for example, the displacements seem to always get solid alphas)."

		)

		on addAlphas pressed do (
			addAlphaToAllDisps()
		)

		on btnQuadrifyMe pressed do (
			if $.modifiers.count == 0 OR queryBox "This Will Collapse the Modifier Stack. Continue?" then (
				qaudrifyMe()
			)
		)

		on btnTriangulateMe pressed do (
			if $.modifiers.count == 0 OR queryBox "This Will Collapse the Modifier Stack. Continue?" then (
				traingulateMe()
			)
		)

		on btn_sendMatToMats pressed do (
			if SendMatToMats() == false then (
				messageBox "The function could not succeed. It only works if this sculpt mesh has a Standard or Blend material, or a DirectX_Shader with a Standard or Blend Render Material."

			)

		)

		on clearBake pressed do (
			for disp in displist WHERE isValidNode disp do (
				disp.dispinfo = ""
			)

		)


		on bakeMe pressed do (
			bakeAllDispinfo()
		)

		on addDisplacement picked p do (
			--disableRefMsgs()
			local orig

			if isProperty p #ww_displacement then (
				orig = p
			) else (
				dispName = getUserProp p #ww_wwdt_displacement_target
				if dispName != undefined AND dispName != "" then (
					orig = getNodeByName dispName
				)
			)

			local getNumVerts = polyop.getNumVerts

			if isValidNode orig AND findItem displist orig == 0 then (
				max create mode
				commit()

				isUpdating = true
				if classof orig.baseobject != Editable_Poly then (
					convertToPoly orig
				)
				append displist orig
				dispMapArray = #()
				/*Reset the vertmapping in existing displacements*/

				for d in displist WHERE isValidNode d do (
					local theOrigVerts = getNumVerts d
					local theverts = #{1..theOrigVerts} as Array
					append dispMapArray #(d, theverts, #(#(), #()))
				)

				obj = copy orig
				setUserProp obj #wallworm_ignore_event_propagation "true"

				if obj.brushNode != undefined AND isDeleted obj.brushNode == false then (
					setUserProp obj.brushNode #ww_wwdt_displacement_target ""
					setUserProp obj.brushNode #wallworm_is_updating "false"
					setUserProp obj.brushNode #wallworm_ignore_event_propagation "false"
					delete obj.brushNode
				)

				polyop.attach $ obj

				local vs = getNumVerts $

				$.weldThreshold = 1
				polyop.weldVertsByThreshold $ #{1..vs}

				vertCount = getNumVerts $
				--setProperty this "vertCount" vs
				local controlVerts = #()

				--	local checkFromSource = #{1..vertCount} as array -- create an array to store all the vertices in the control mesh
				local pv_getVert = polyop.getVert

				in coordsys world (
					with redraw off

					for i = 1 to vertCount do (
						local pt = (pv_getVert $ i)

						append controlVerts #(pt, (length pt), i)

					)

					function compareFN v1 v2 =

					(
						local d = (v1[2]) - (v2[2])

						case of

						(
							(d < 0.): -1

							(d > 0.): 1

							default: 0

						)

					)

					qsort controlVerts compareFN

					for maps in dispMapArray do (
						for ov in maps[2] do (
							--maps is an array structured like this:  #(originalMeshObject,arrayOfVerticesInMesh,#(#(),#()))
							dispvert = pv_getVert maps[1] ov --get vertice from original mesh
							local toOrigin = length dispvert

							local minIndex = 1
							local maxIndex = vertCount
							local midIndex = (floor ((minIndex + maxIndex) / 2)) as Integer

							local searchValue = toOrigin - 1.0

							do (
								midValue = controlVerts[midIndex][2]

								if midValue < searchValue then (
									minIndex = midIndex
								) else (
									maxIndex = midIndex
								)

								midIndex = (floor ((minIndex + maxIndex) / 2)) as Integer

								--format "###########\nMin\t%\nMid\t%\nMax\t%\n" minIndex midIndex maxIndex

							) while (minIndex != midIndex)

							local nf = true

							for i = minIndex to vertCount while nf do (
								theVert = controlVerts[i][1] --get vertice from the control mesh
								--if ((abs (dispvert.x - theVert.x ) < 1) AND (abs (dispvert.y - theVert.y) < 1) AND (abs (dispvert.z - theVert.z) < 1)) then (
								if (distance dispvert theVert) < 1 then (
									append maps[3][1] controlVerts[i][3] --record the control mesh vertice
									append maps[3][2] ov --record the original vertice
									--checkFrom[i] = false
									--deleteItem checkFrom (findItem checkFrom i) --delete item from the checkFrom array to reduce overhead in next iteration
									nf = false
								)
							)

						)

					)

				)

				setTransformLockFlags orig #all
				hide orig
				if isProperty orig #brushNode AND isValidNode orig.brushNode then (
					setTransformLockFlags orig.brushNode #all
					orig.brushNode.xray = on
					hide orig.brushNode
				)
				isUpdating = false
				--setProperty this "isUpdating" false

				--setProperty this "dispMapArray" dispMapArray

				bakeMapArrayString()
				--ww_wwdt_setDispHandlers()	

				--setUserProp $ "wallworm_ignore_event_propagation" "false"

				max modify mode
			) else (
				messageBox "This displacement is already part of this sculpt mesh."
			)

			--enableRefMsgs()
		)

		on params open do (
			/*
			if mapints.count == 0 then (
				bakeMapArrayString()
			)

			if dispMapArray == undefined OR dispMapArray.count == 0 then (
				parsemap()

			)*/
			hideAllParts()
			updateLastUpdateTime()
		)

		on wwDisplayWalkable pressed do (
			if (maxVersion())[1] >= 12000 then (
				try (
					macros.run "wallworm.com" "WW_Face_Walkable"
				) catch (
					messageBox "This function only works if you have Wall Worm installed."
				)
			) else (
				messageBox "This feature only works in 3ds Max 2010+."
			)
		)

		on ckb_texMode changed state do
		(
			if $ != undefined then (
				if state == true then (
					addModifier $ (VertexPaint name:"WW Blend Paint" mapChannel:-2)

					local v = VertexPaintTool()
					v.brushOpacity = 50
					v.curPaintMode = 1
					v.brushSize = 128
					v.brushOpacity = 100
					v.mapDisplayChannel = 0
				) else (
					if queryBox "Collapse to Poly?" then (
						oldSurviveState = custAttribCollapseManager.surviveState
						custAttribCollapseManager.surviveState = true
						convertToPoly $
						custAttribCollapseManager.surviveState = oldSurviveState
					)
				)
			)
		)

		on wwCommitChanges pressed do (
			commit()
			updateLastUpdateTime()
			max modify mode
		)

		on wwRevert pressed do with redraw off (
			if queryBox "Do you want to commit changes first? If not, any changes made since the last commit will be lost." == true then (
				commit()
			)
			if displist != undefined AND displist.count > 0 then (
				unhide ((for disp in displist WHERE isValidNode disp collect disp) as Array)
				for disp in displist WHERE isValidNode disp do (
					setTransformLockFlags disp #{7, 8, 9}
					if isValidNode disp.brushNode then (
						setTransformLockFlags disp.brushNode #{7, 8, 9}
					)

					if isProperty disp #stopIgnoreEventPropagation then (
						disp.stopIgnoreEventPropagation()
					)
				)
			)
			global ww_wwdt_setDispHandlers

			if ww_wwdt_setDispHandlers == undefined then (
				if (::wallworm_installation_path == undefined) then (
					::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
				)

				if ::wallworm_installation_path != undefined AND (doesFileExist ::wallworm_installation_path) then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
				) else (
					if doesFileExist ("$scripts\\WallWorm.com\\WallWormSimpleDisplacement\\wwdt_event_funcs.ms") then (
						fileIn "$scripts\\WallWorm.com\\WallWormSimpleDisplacement\\wwdt_event_funcs.ms"
					) else (
						if doesFileExist ("$userscripts\\WallWorm.com\\WallWormSimpleDisplacement\\wwdt_event_funcs.ms") then (
							fileIn "$userscripts\\WallWorm.com\\WallWormSimpleDisplacement\\wwdt_event_funcs.ms"
						)
					)

				)

			)
			if ww_wwdt_setDispHandlers != undefined then (
				ww_wwdt_setDispHandlers()
			)
			delete $

		)

	)

)
