rollout wallwormSMDExport "Wall Worm DMX/SMD/VTA Export" width:568 height:489
(
	local originNode
	local smdFileName
	local nodeList = #()
	local boneList = #()
	local smd = wallwormSMD()
	local defaultEngine = (if(smd.usePro) then 2 else 1)
	RadioButtons rdoType "Type" pos:[11, 26] width:73 height:62 labels:#("Reference", "Sequence", "Flex") columns:1 toolTip:"SMD/VTA or DMX settings."
	CheckBox chkDMX "DMX" pos:[115, 27] width:40 height:13 checked:(::wwmt_default_dmx == true) tooltip:"Export to the DMX format if WW Pro is installed."
	DropDownList ddldmx_version "" items:#("1", "15", "18") pos:[160, 24] width:40 tooltip:"Which DMX Version? Not all versions may work or be fully supported."
	Spinner spnStart "Start" pos:[42, 297] width:72 height:16 range:[0, 999999, 0] type:#integer scale:1 toolTip:"Set the beggining frame for a sequence or VTA. For reference, set the reference frame."
	Spinner spnEnd "End" pos:[138, 298] width:72 height:16 range:[0, 999999, 100] type:#integer scale:1 toolTip:"Set the end frame for sequence and VTA exports."
	CheckBox chkMeshAsBone "Export Non-Renderable Mesh as Bone" pos:[13, 253] width:205 height:18 toolTip:"Force the exporter to skip the geometry of objects that are non-renderable--and only use the pivot point as a bone. Useful when there are objects that should only export as a bone."
	Spinner spnUVW "UVW Channel (0 == Auto)" pos:[138, 396] width:77 height:16 range:[-1, 100, 1] type:#integer scale:1 toolTip:"Select the UVW channel used in this model. 0 and -1 are auto-detect values. Default comes form global WW settings."
	Button btnExport "Export" pos:[348, 414] width:201 height:50
	Hyperlink WormLink "Wall Worm" pos:[12, 458] width:96 height:15 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com"
	Hyperlink DonateLink "Donate" pos:[112, 458] width:96 height:15 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/42/donate.html"
	CheckBox chkStatic "Static Prop" pos:[115, 43] width:94 height:16 checked:false toolTip:"Tell the exporter that this object has no moving parts."
	CheckBox chkFirst "Local Origin as World Origin" pos:[18, 118] width:203 height:15 toolTip:"When set, the exporter uses the pivot point of the origin node (or first object in the selection if no node designated) as the working reference point for creating node and vertex positions."
	PickButton btnOriginNode "Pick Origin Node" pos:[18, 180] width:200 height:25
	Button btnclear "Clear Origin" pos:[18, 209] width:68 height:18 toolTip:"Clear the Origin Node."
	Button btnGetOrigin "Get Origin" pos:[88, 209] width:59 height:18 toolTip:"Click here to select the origin node in the scene."
	Button btnHilightOrigin "Hilight Origin" pos:[152, 209] width:66 height:18
	GroupBox grp1 "Origin Offset" pos:[8, 98] width:218 height:144
	CheckBox chkRefCurrentTime "Reference Mesh from Current Time" pos:[13, 355] width:205 height:17 toolTip:"When checked, reference models are generated from the state of the model at the current frame in the timeline. Otherwise at the start-frame designated in the range."
	RadioButtons rdoSMDExportSelections "Export" pos:[243, 7] width:268 height:30 labels:#("Auto", "Scene", "Selection", "Manual") columns:4
	GroupBox grp13 "Range" pos:[10, 278] width:215 height:69
	Label lblVersion "Source Model Exporter" pos:[9, 6] width:138 height:18
	CheckBox chkLockOrigin "Lock Origin State" pos:[18, 157] width:107 height:18 toolTip:"Check this option if the root node is animated in its own space. Only useful for Sequence SMDs where the root node is animated in World Space. This option may be removed in the future."
	DropDownList ddlNormals "Normals" pos:[115, 59] width:109 height:40 items:#("Face Render Normals", "Explicit Normals", "Auto") selection:3 toolTip:"With Auto, looks for an Edit Normals modifier on node to determine method. If model has modified normals but no Edit Normals modifier, choose Explicit Normals."
	CheckBox chkRotate "Rotate World" pos:[18, 137] width:88 height:17 toolTip:"Rotate the output by 90 degrees. Useful for making props use [0 0 0] alignment in Hammer's prop settings straight from the SMD. Best with staticprop!"
	DropDownList drp_upaxis "Up Axis" pos:[176, 414] items:#("X","Y","Z") tooltip:"This should almost always be set to Z. For linked FBX files generated in Maya, choose Y." width:40 selection:3
	CheckBox chkFlip "Flip" pos:[170, 154] width:46 height:19 toolTip:"Flip the SMD by 180 degrees. If Rotate is also used, the model is rotated 270 degrees. This option may be removed in the future."
	CheckBox chkVis "Only Visible Objects" pos:[30, 416] width:125 height:14 toolTip:"Only include those objects that are visible in the scene when this option is checked."
	MultiListBox cbxNodeList "Mesh and Bone Nodes" pos:[244, 44] width:248 height:7
	MultiListBox cbxBoneList "Bone Nodes (Exclude Mesh)" pos:[242, 205] width:248 height:10
	Button btnAddMeshSelection "Add Scene Selection" pos:[243, 166] width:110 height:23 toolTip:"Add items in the scene selection to the mesh export list."
	Button btnRemoveMeshSelection "Remove Scene Selection" pos:[364, 166] width:125 height:23 toolTip:"Remove any item from the scene selection that is in the mesh export list."
	Button btnMeshAll "All" pos:[500, 60] width:55 height:19 toolTip:"Select all meshes in the mesh list."
	Button btnMeshInvert "Invert" pos:[500, 82] width:55 height:19 toolTip:"Invert the current mesh list selection."
	Button btnMeshNone "None" pos:[500, 104] width:55 height:19 toolTip:"Set the current mesh selection to none."
	Button btnMeshRemove "Remove" pos:[500, 126] width:55 height:19 toolTip:"Remove the selected item(s) from the export list."
	Button btnToBones "To Bones" pos:[500, 146] width:55 height:19 toolTip:"Send selected meshes to the bone-only list."
	Button btnToOrigin "To Origin" pos:[500, 168] width:55 height:19 toolTip:"Set selected mesh as the origin node in the exported SMD."
	Button btnAddBoneSelection "Add Scene Selection" pos:[243, 378] width:110 height:23 toolTip:"Add items in the scene selection to the bone export list."
	Button btnRemoveBoneSelection "Remove Scene Selection" pos:[364, 378] width:125 height:23 toolTip:"Remove any item from the scene selection that is in the bone export list."
	Button btnBoneRemove "Remove" pos:[500, 286] width:55 height:19 toolTip:"Remove selected bone from the export list."
	Button btnToMeshes "To Mesh" pos:[500, 308] width:55 height:19 toolTip:"Move the selected bones to the mesh and bone list."
	Button btnToOrigin2 "To Origin" pos:[500, 330] width:55 height:19 toolTip:"Set selected bone as the origin node in the exported SMD."
	Button btnBoneAll "All" pos:[500, 220] width:55 height:19 toolTip:"Select all bones in list box."
	Button btnBoneInvert "Invert" pos:[500, 242] width:55 height:19 toolTip:"Invert Bone Selection in list box."
	Button btnBoneNone "None" pos:[500, 264] width:55 height:19 toolTip:"Select no bones in list box."
	RadioButtons rdoExporter "Export Engine" pos:[237, 417] width:94 height:46 labels:#("Wall Worm", "Wall Worm Pro") default:2 columns:1 toolTip:"Choose your prefered export Engine."
	Button btnStart "Timeline" pos:[23, 322] width:79 height:13
	Button btnEnd "Timeline" pos:[122, 322] width:91 height:13
	GroupBox grp23 "Miscellaneous Options" pos:[14, 379] width:212 height:76
	CheckBox chkGold "Goldsrc Format SMD" pos:[30, 434] width:134 height:13 checked:(::wallworm_engine == 1) tooltip:"Export in a format compatible with the Goldsrc SMD format."

	on drp_upaxis selected sel do (
		if sel == 1 then (
			messagebox "At this time, only Y and Z are supported."
			drp_upaxis.selection = 3
		)
		
	)
	
	function updateOriginStates = (
		btnOriginNode.enabled = btnclear.enabled = btnGetOrigin.enabled = btnHilightOrigin.enabled = chkLockOrigin.enabled = chkFlip.enabled = chkFirst.checked
	)

	function returnCurrentOriginNode = (
		undefined
		if isValidNode originNode then (
			originNode
		) else (
			if nodeList.count > 0 then (
				nodeList[1]
			) else (
				if selection.count > 0 then (
					selection[1]
				) else (
					if objects.count > 0 then (
						objects[1]
					)
				)
			)
		)
	)

	/*
	This function returns a list of objects for exporting based on the export settings. If the user chooses manual exporting, returns undefined.
	*/
	function returnNodeList = (
		local choose = undefined
		case rdoSMDExportSelections.state of (
			1:(if selection.count > 0 then (choose = selection) else (choose = objects))
			2:(choose = objects)
			3:(choose = selection)
			default:(
			)
		)
		if choose != undefined then (
			if chkVis.checked then (
				choose = for obj in choose WHERE obj.isHidden == false AND (getUserProp obj #wwmt_hitbox == undefined AND getUserProp obj #wwmt_is_attachment == undefined AND getUserProp obj #wwmt_source_helper == undefined AND getUserProp obj #wwmt_LOD_Gizmo == undefined AND getUserProp obj #wwmt_LOD_target == undefined AND (NOT isProperty obj #bodygroup AND NOT isProperty obj #wwmt_lod)) collect obj

			) else (
				choose = for obj in choose WHERE (getUserProp obj #wwmt_hitbox == undefined AND getUserProp obj #wwmt_is_attachment == undefined AND getUserProp obj #wwmt_source_helper == undefined AND getUserProp obj #wwmt_LOD_Gizmo == undefined AND getUserProp obj #wwmt_LOD_target == undefined AND (NOT isProperty obj #bodygroup AND NOT isProperty obj #wwmt_lod)) collect obj
			)

		)

		choose
	)

	function updateBoneList = (
		boneList = makeUniqueArray boneList
		boneList = for obj in boneList WHERE isValidNode obj collect obj
		cbxBoneList.items = for obj in boneList collect obj.name
	)
	function updateNodeList = (
		nodeList = makeUniqueArray nodeList
		nodeList = for obj in nodeList WHERE isValidNode obj AND findItem boneList obj == 0 collect obj
		cbxNodeList.items = for obj in nodeList collect obj.name
	)

	function fillLists = (
		local nodes = returnNodeList()
		if nodes != undefined then (
			if chkMeshAsBone.checked == true then (
				boneList = for obj in nodes WHERE (wallworm_is_a_bone obj == true) OR ((canConvertTo obj Mesh) == false) OR (obj.renderable == off) collect obj
			) else (
				boneList = for obj in nodes WHERE (wallworm_is_a_bone obj == true) OR ((canConvertTo obj Mesh) == false) collect obj
			)
			if rdoSMDExportSelections.state <= 2 then (
				local skinnedOBJS = for obj in nodes WHERE (wallworm_get_modifierByClass obj Skin) != undefined collect obj
				if skinnedOBJS.count > 0 then (
					global wallworm_getBonesFromSkin
					for obj in skinnedOBJS do (
						join boneList ((wallworm_getBonesFromSkin (wallworm_get_modifierByClass obj Skin)) as Array)
					)

				)
			)

			updateBoneList()

			nodeList = nodes
			updateNodeList()

			--cbxNodeList.items  = 
		)
	)

	function removeBone obj = (
		local ind = findItem boneList obj
		if ind > 0 then (
			deleteItem boneList ind
		)
	)
	function removeMesh obj = (
		local ind = findItem nodeList obj
		if ind > 0 then (
			deleteItem nodeList ind
		)

	)

	/*	on spnStart changed val do
	(
		if spnStart.value >= spnEnd.value then (
			spnEnd.value = spnStart.value + 1
		)

	)
	on spnEnd changed val do
	(
		if spnEnd.value <= spnStart.value then (
			spnStart.value = spnEnd.value - 1
		)

	)*/

	function sendMeshesToBoneslist = (
		local ndSel = cbxNodeList.selection
		if ndSel != 0 then (
			local indCount = nodeList.count
			local objToSendToBones = for i = 1 to indCount WHERE ndSel[i] == true collect nodeList[i]
			indCount = undefined
			for obj in objToSendToBones do (
				removeMesh obj
			)
			join boneList objToSendToBones
			updateBoneList()
			updateNodeList()
		)
	)

	function sendBonesToMesheslist = (
		local ndSel = cbxBoneList.selection
		if ndSel != 0 then (
			local indCount = boneList.count
			local objToSendToBones = for i = 1 to indCount WHERE ndSel[i] == true collect boneList[i]
			indCount = undefined
			for obj in objToSendToBones do (
				removeBone obj
			)
			join nodeList objToSendToBones
			updateBoneList()
			updateNodeList()
		)

	)

	on wallwormSMDExport open do
	(
		lblVersion.text = ("Model Exporter Version " + smd.exporterVersion as String)

		spnUVW.value = ::wwmt_mappingChannel

		fillLists()
		rdoExporter.state = (if(smd.usePro AND ::wwmtExporter != 3) then 2 else 1)

		--start selection listener
		updateOriginStates()

		if ::wwmt_dmx_version == undefined then (
			::wwmt_dmx_version = 18
		)
		ddldmx_version.selection = findItem ddldmx_version.items (::wwmt_dmx_version as String)

		callbacks.addScript #selectionSetChanged "wallwormSMDExport.fillLists()" id:#wallwormSMDExportSelectionChange

	)
	on wallwormSMDExport close do
	(
		callbacks.removeScripts #selectionSetChanged id:#wallwormSMDExportSelectionChange
	)
	on chkMeshAsBone changed stat do
	(
		fillLists()
	)
	on btnExport pressed do
	(
		smd.smdNodes = #()
		smd.type = case rdoType.state of (
			1:("Reference")
			2:("Sequence")
			3:("VTA")
			default:("Reference")
		)

		if (chkGold.checked) then (
			smd.hl1 = true
		) else (
			smd.hl1 = false
		)
		smd.upaxis = drp_upaxis.selection
		/*
		Consider allowing the Start spinner to set the reference time.
		At the moment, Reference always uses frame 0.
		To update, need to re-write logic in SMD Export class.
		*/

		if chkRefCurrentTime.checked == true then (
			smd.referenceFrame = ((currentTime as Integer) / TicksPerFrame)
		) else (
			smd.referenceFrame = spnStart.value
		)

		if smd.type != "Reference" then (
			smd.range = #()
			for r = spnStart.value to spnEnd.value do (
				append smd.range r
			)
		) else (
			if chkRefCurrentTime.checked == true then (
				smd.range = #((currentTime as Integer) / TicksPerFrame)
			) else (
				smd.range = #(spnStart.value)
			)
		)
		local filetype
		local exportCaption
		local initialFtype = ".smd"
		if chkDMX.checked then (
			filetype = "DMX(*.dmx)|*.dmx"
			exportCaption = "Export DMX"
			smd.outtype = "dmx"
			initialFtype = ".dmx"
			smd.dmxFormat = (ddldmx_version.selected as Integer)
		) else (
			filetype = "SMD(*.smd)|*.smd"
			exportCaption = "Export SMD"
			if smd.type == "VTA" then (
				filetype = "VTA(*.vta)|*.vta"
				exportCaption = "Export VTA"
				initialFtype = ".vta"
			)
		)

		smd.uvwchannel = spnUVW.value
		local desel = false

		if ::wallworm_debug != true AND ::wallworm_debug != false then (
			::wallworm_debug = false
		)

		smd.debug = ::wallworm_debug
		smd.usePro = (::WallwormProActive == true AND ((rdoExporter.state == 2) OR chkDMX.checked == true))
		smd.nonRenderableAsBone = chkMeshAsBone.checked
		smd.staticprop = chkStatic.checked
		smd.origin = chkFirst.checked
		smd.internalOrigin = chkFirst.checked
		smd.rotateRefsystem = chkRotate.checked
		if smd.origin == true then (
			smd.flip = chkFlip.checked
			smd.lockInitialOrigin = chkLockOrigin.checked
		) else (
			smd.flip = false
			smd.lockInitialOrigin = false
		)
		smd.normalMethod = ddlNormals.selection
		if selection.count > 0 then (
		) else (
			desel = true
		)

		local nodes = #()
		join nodes nodeList
		join nodes boneList

		--returnNodeList()
		if nodes != undefined AND nodes.count > 0 then (
			if chkFirst.checked == true then (
				if isValidNode originNode then (
					smd.refNode = originNode
				) else (
					smd.refNode = nodes[1]
				)
			)
			smd.justBones = boneList
			if chkDMX.checked then (
				if smd.type == "VTA" then (
					smd.range = #(0)
					smd.getRefOrientation t:0
					smd.makeNodeList nodeList
					smd.getFlexStates()
				) else (
					smd.getRefOrientation t:0
					smd.makeNodeList nodeList
				)

			) else (
				smd.makeNodeList nodeList
			)

			try (
				if smdFileName == undefined then (
					fname = ::wwmt_def_model_path + "\\" + (getFilenameFile maxFileName) + initialFtype
				) else (
					fname = smdFileName
				)
				local filename = getSaveFileName filename:fname caption:exportCaption types:filetype historyCategory:"Wall Worm SMD Exporter"
			) catch (
				local filename = getSaveFileName caption:exportCaption types:filetype historyCategory:"Wall Worm SMD Exporter"

			)

			if filename != undefined then (
				smdFileName = filename
				smd.exportSMD filename shout:true

				if smd.errors.count == 0 then (
					messageBox "File saved."
				)
			) else (
				messageBox "The export was cancelled."
			)
			if desel == true then (
				max select none
			)

		) else (
			messageBox "There were no objects to export."
		)
	)
	on chkFirst changed stat do
	(
		updateOriginStates()
	)
	on btnOriginNode picked obj do
	(
		originNode = obj

	)
	on btnclear pressed do
	(
		originNode = undefined

	)
	on btnGetOrigin pressed do
	(
		orig = returnCurrentOriginNode()
		if isValidNode orig then (
			select orig
		)

	)
	on btnHilightOrigin pressed do
	(
		orig = returnCurrentOriginNode()
		if isValidNode orig then (
			flashNodes (#(orig))
			forceCompleteredraw()
		)
	)
	on rdoSMDExportSelections changed state do
	(
		fillLists()
	)
	on rdoSMDExportSelections rightClick do
	(
		fillLists()
	)
	on chkVis changed stat do
	(
		fillLists()
	)
	on cbxNodeList selected sel do
	(
		if cbxNodeList.selection != 0 AND cbxNodeList.selection[sel] then (
			local nd = nodeList[sel]
			if isValidNode nd then (
				flashNodes (#(nd))
				forceCompleteRedraw()
			)

		)

	)
	on cbxNodeList doubleClicked sel do
	(
		if cbxNodeList.selection != 0 AND cbxNodeList.selection[sel] then (
			local nds = for i = 1 to nodeList.count WHERE cbxNodeList.selection[i] == true collect nodeList[i]

			if nds.count > 0 then (
				select nds
			)
		)
	)
	on cbxNodeList rightClick do
	(
		sendMeshesToBoneslist()
	)
	on btnAddMeshSelection pressed do
	(
		if selection.count > 0 then (
			rdoSMDExportSelections.state = 4
			join nodeList (selection as Array)
			updateNodeList()
		) else (
			messageBox "No objects selected. Select objects in scene first."
		)
	)
	on btnRemoveMeshSelection pressed do
	(
		if selection.count > 0 then (
			rdoSMDExportSelections.state = 4
			for obj in selection do (
				removeMesh obj
			)
			updateNodeList()
		) else (
			messageBox "No objects selected. Select objects in scene first."
		)
	)
	on btnMeshAll pressed do
	(
		local amount = cbxNodeList.items.count
		if amount > 0 then (
			cbxNodeList.selection = #{1..amount}
		)
	)
	on btnMeshInvert pressed do
	(
		cbxNodeList.selection = -(cbxNodeList.selection)
	)
	on btnMeshNone pressed do
	(
		cbxNodeList.selection = #{}
	)
	on btnMeshRemove pressed do
	(
		if cbxNodeList.selection.numberset > 0 then (
			rdoSMDExportSelections.state = 4
			local indexes = cbxNodeList.selection as Array
			local rmnodes = for ind in indexes collect nodeList[ind]
			for obj in rmnodes do (
				removeMesh obj
			)
			updateNodeList()
		)
	)
	on btnToBones pressed do
	(
		rdoSMDExportSelections.state = 4
		sendMeshesToBoneslist()
	)
	on btnToOrigin pressed do
	(
		if chkFirst.checked then (
			if cbxNodeList.selection.numberset == 1 then (
				local indexes = cbxNodeList.selection as Array
				originNode = nodeList[indexes[1]]

			) else (
				messageBox "You can only send one node as the Origin Node."
			)

		) else (
			messageBox "This function only works when the Use Local Origin setting is on."
		)

	)
	on btnAddBoneSelection pressed do
	(
		if selection.count > 0 then (
			rdoSMDExportSelections.state = 4
			join boneList (selection as Array)
			updateBoneList()
		) else (
			messageBox "No objects selected. Select objects in scene first."
		)
	)
	on btnRemoveBoneSelection pressed do
	(
		if selection.count > 0 then (
			rdoSMDExportSelections.state = 4
			for obj in selection do (
				removeBone obj
			)
			updateNodeList()
		) else (
			messageBox "No objects selected. Select objects in scene first."
		)
	)
	on btnBoneRemove pressed do
	(
		if cbxBoneList.selection.numberset > 0 then (
			rdoSMDExportSelections.state = 4
			local indexes = cbxBoneList.selection as Array
			local rmnodes = for ind in indexes collect boneList[ind]
			for obj in rmnodes do (
				removeBone obj
			)
			updateBoneList()
		)

	)
	on btnToMeshes pressed do
	(
		rdoSMDExportSelections.state = 4
		sendBonesToMesheslist()
	)
	on btnToOrigin2 pressed do
	(
		if chkFirst.checked then (
			if cbxBoneList.selection.numberset == 1 then (
				local indexes = cbxBoneList.selection as Array
				originNode = boneList[indexes[1]]

			) else (
				messageBox "You can only send one bone as the Origin Node."
			)

		) else (
			messageBox "This function only works when the Use Local Origin setting is on."
		)

	)
	on btnBoneAll pressed do
	(
		local amount = cbxBoneList.items.count
		if amount > 0 then (
			cbxBoneList.selection = #{1..amount}
		)
	)
	on btnBoneInvert pressed do
	(
		cbxBoneList.selection = -(cbxBoneList.selection)
	)
	on btnBoneNone pressed do
	(
		cbxBoneList.selection = #{}
	)

	function checkForProFeatures = (
		if smd.smdHelper == undefined AND (rdoExporter.state == 2 OR chkDMX.checked == true) then (
			if (queryBox "This feature only works when Wall Worm Pro is installed. Do you want to learn more about Wall Worm Pro?") == true then (
				global wallworm_getMaxVersion
				if wallworm_getMaxVersion == undefined then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
				)

				local maxInfo = wallworm_getMaxVersion()
				shellLaunch ("http://dev.wallworm.com/topic/69/wall_worm_pro.html?" + (::wwmt_installedversion as String) + "&installed=" + (::ww_wwmt_version as String) + "&maxversion=" + (maxInfo[1] as String) + "&maxupdateversion=" + (maxInfo[2] as String)) ""
			)
			rdoExporter.state = 1
			chkDMX.checked = false
			false
		) else (
			true
		)
	)

	on chkDMX changed stat do (
		checkForProFeatures()
	)

	on rdoExporter changed stat do
	(
		if (checkForProFeatures()) == true then (
			if state == 2 then (
				smd.usePro = true
			) else (
				smd.usePro = false
			)
		)
	)
	on btnStart pressed do
	(
		spnStart.value = (currentTime as Integer) / TicksPerFrame
	)
	on btnStart rightClick do
	(
		spnStart.value = (animationRange.start as Integer) / TicksPerFrame
	)
	on btnEnd pressed do
	(
		spnEnd.value = (currentTime as Integer) / TicksPerFrame
	)
	on btnEnd rightClick do
	(
		spnEnd.value = (animationRange.end as Integer) / TicksPerFrame
	)
)
