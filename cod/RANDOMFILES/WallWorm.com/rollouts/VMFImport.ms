rollout wallwormVMFImporter "VMF and MAP  Importer" width:347 height:754
(
	local mustUseSlice = false

	button btnImport "Choose VMF or MAP to Import" pos:[11,159] width:223 height:37 toolTip:"Browse for your VMF or MAP file and import it. For Materials to work, make sure your MatGen Path is set first. If importing a MAP file, you should make sure to Import the WADS first with the Material Library Generator."
	HyperLink lnkWW "Wall Worm" pos:[13,661] width:81 height:15 address:"http://dev.wallworm.com" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	HyperLink lnkShawn "Shawn Olson" pos:[229,661] width:109 height:15 address:"http://www.shawnolson.net" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	label ver "Version " pos:[105,661] width:77 height:13
	HyperLink lnkLove "Donate to the Wall Worm Project" pos:[116,685] width:223 height:15 address:"http://dev.wallworm.com/topic/42/donate.html" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	label lbl7 "Love Wall Worm?" pos:[13,686] width:87 height:14
	button btnModels "Import Props from Scene Entities" pos:[24,321] width:300 height:37 enabled:true toolTip:"Import prop meshes for any entity with a MDL assigned to it. Only works if the model's QC and SMD files can be found in the modelsrc folders."
	HyperLink lnkHelp "Help Using This Tool and Other Tips" pos:[12,12] width:325 height:15 address:"http://dev.wallworm.com/document/124/vmf_importer.html" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	HyperLink lblBriscoe "Sponsored by Robert Briscoe" pos:[11,706] width:151 height:19 address:"http://www.littlelostpoly.co.uk" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	dropdownList ddlDefaultBitmapSize "" pos:[223,44] width:113 height:21 items:#("64", "128", "256", "512", "1024") selection:4
	label lbl3 "Fallback Bitmap Size for Missing Textures" pos:[14,46] width:207 height:17
	button btnSaveLib "Save Imported Material Library" pos:[23,506] width:300 height:36 enabled:false
	spinner spnLimit "Parse Failure Retry Limit" pos:[23,79] width:313 height:16 range:[0,32,0] type:#integer scale:1 toolTip:"Retry parsing the VMF this many times if there are failures. A high value could freeze Max for a significant period of time!"
	GroupBox grp1 "Prop Imports" pos:[11,266] width:322 height:140
	button btnTools "Hide Tool Textures" pos:[23,458] width:120 height:40 toolTip:"Create Selection Sets of objects with tools names and hide most."
	button btnDisDest "Displacements to Mesh" pos:[157,458] width:166 height:22 toolTip:"Convert Wall Worm displacements to standard Editable Poly objects."
	checkbox chkNoSlice "Use Default Brush Generation" pos:[18,113] width:174 height:18 checked:true toolTip:"Wall Worm has two methods for generating brushes. One is a fallback method when the default fails. Choose the fallback only if the default is giving you poor results."
	button btnRebuild "Delete Imported Objects and Rebuild" pos:[23,621] width:190 height:29 toolTip:"You may want to use this option if you want to rebuild the scene based on having added VMTs and other assets used to build UVs and Materials, or if you need to retry with the alternate brush option."
	spinner spnAngle "Rotation Angle" pos:[76,293] width:62 height:16 range:[-180,180,0] type:#integer scale:1 step:90 toolTip:"This is the default offset rotation for your models. This value is probably going to be 90 for SMD/QC exported before Wall Worm. It may be 0 or 180 for other versions."
	button btnRebuildSel "Rebuild Selected" pos:[220,621] width:103 height:30 toolTip:"Rebuild selected object with the current brush generation method. Only works on displacements and brush objects that are not tied to an entity."
	dropdownList ddlRotTarg "Apply Rotation To" pos:[152,276] width:170 height:40 items:#("WWMT Model", "Proxie Props") toolTip:"If re-exporting the VMF, choose the WWMT model option. Some props will be rotated incorrectly in scene if original SMD was not aligned to world. For getting props in scene with correct orientation, choose Proxie Props. Note that the WWMT model may need to be re-exported."
	button btnRotFix "Fix Bad Prop Rotation" pos:[25,363] width:299 height:14 toolTip:"Experimental.... use this to fix bad rotations which might happen if original prop was rotated incorrectly."
	button btnImportDetails "Import Prop Details" pos:[24,413] width:299 height:35 toolTip:"Import prop details for this scene."
	checkbox chkautoCheckGeometry "Validate Geometry" pos:[18,136] width:112 height:19 checked:false toolTip:"This will add some geometry validation to the importer. This will remove the possibility of missing brushes but can increase import times."
	button btnSelectWarningGeo "Select Imported Geometry that Needs Attention" pos:[24,546] width:238 height:29 toolTip:"Sometimes some of the geometry is imported incorrectly. Use this to select objects that may be incorrect."
	button btnRemCoplanar "Remove Coplanar Faces on Selection" pos:[144,588] width:180 height:23 toolTip:"Run this function on objects that have coplanar faces. Only works on Editable Poly objects."
	spinner spn3 "Threshhold" pos:[49,593] width:86 height:16 range:[0.01,15,10] scale:0.01 toolTip:"Set the threshhold for coplanar face angle detection. The importer uses 10."
	checkbox chkSaveCache "Auto Cache" pos:[249,122] width:84 height:17 checked:false toolTip:"Create a MAXScript cache of this import that can be opened again without parsing the scene."
	button btnCache "Open Cache" pos:[247,144] width:80 height:21 toolTip:"Open an import cache file."
	GroupBox grp3 "Caching" pos:[239,105] width:96 height:91
	button btn31 "Save Cache" pos:[247,170] width:80 height:19
	button btn14 "UV Fix" pos:[265,546] width:57 height:29
	button btnDispMats "Displacement Material to Blend" pos:[155,483] width:167 height:13
	button btnMatGen "Material Library Generator" pos:[11,237] width:322 height:17 toolTip:"Click here to launch to Material Library Generator to set the MatGen path or to import WAD files before importing your level."
	--checkbox chkWad "WADS" pos:[177,139] width:56 height:15 tooltip:"When importing a MAP file, use XWAD to import the WAD to materials and textures."
	button btnPropLibrary "Prop Library From VMF File" pos:[11,202] width:147 height:23 toolTip:"Import all the props from a VMF File and save them to the Prop Library. Right-click to re-import props that are already in the Prop Library."
	button fixPropPlacement "Fix Misplaced Props" pos:[25,383] width:298 height:17 toolTip:"Press to fix props that got placed at the world origin after re-opening a scene."

	function enableButtons = (
		global theWallWormVMFImport
		if theWallWormVMFImport.materials.count > 0 then (
			btnSaveLib.enabled = true
		)
	)

	function buildScene started = (
		max create mode
		
		with redraw off undo off (
			theWallWormVMFImport.createBrushes()
			theWallWormVMFImport.createEntities()

			set coordsys world

			wallworm_show_displacements()
			wallworm_hide_displacement_brushes()

			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)

			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/DisplacementsMat2toMat.ms")

			enableButtons()

		)
		theWallWormVMFImport.fixMessedUpXRefLocations()
		local ended = timestamp()
		seconds = ((ended - started) / 1000.0)
		minutes = seconds / 60
		format "% Imported in % seconds (% minutes)\n" (theWallWormVMFImport.filename) seconds minutes

	)

	function cacheimport = (
		if theWallWormVMFImport != undefined AND theWallWormVMFImport.filename != undefined AND theWallWormVMFImport.filename != "" then (
			newfilename = theWallWormVMFImport.filename + (timestamp() as String) + ".wwimportmxs"
			cf = createFile newfilename
			tempDat = copy theWallWormVMFImport

			for b in tempDat.brushes do (
				for p in b.planes do (
					p.mat = undefined
					if p.dispinfo != undefined then (
						p.dispinfo.clearMatrices()
					)
					p.disp = undefined
				)
				b.nd = undefined

			)
			for en in tempDat.entities do (
				for b in en.brushes do (
					for p in b.planes do (
						p.mat = undefined
						if p.dispinfo != undefined then (
							/*Should never happen... but just in case.*/
							p.dispinfo.clearMatrices()
						)
						p.disp = undefined
					)
					b.nd = undefined
				)
			)
			tempDat.dotNetFile = undefined
			tempDat.rx = undefined
			tempDat.nodes = #()
			if isProperty tempData #pvGetVert then (
				tempDat.pvGetVert = undefined
			)
			if isProperty tempData #pvGetMapVert then (
				tempDat.pvGetMapVert = undefined
			)

			if isProperty tempData #pvGetMapFace then (
				tempDat.pvGetMapFace = undefined
			)

			if isProperty tempData #materials then (
				tempDat.materials = undefined
			)
			tempDat.filename = wallworm_bstofs tempDat.filename
			with printAllElements on (
				format (tempDat as String) to:cf
			)
			close cf
		)
	)

	button btnImportInstances "Import Instances" pos:[166,202] width:168 height:23
	on btnImportInstances pressed do (
		local instanceNodes = for obj in objects where isProperty obj #WW_Entity_func_instance AND obj.WW_Entity_func_instance.file != undefined AND obj.WW_Entity_func_instance.file != "" collect obj
		local instanceFiles = for obj in instanceNodes collect obj.file
		instanceFiles = makeUniqueArray instanceFiles
		for f in instanceFiles do (
			--first see if the max file already exists:
			local instancefileMax = "$scenes/"+(getFileNamePath f) + "/" + (getFileNameFile f)+".cmax"
			local MaxFileExists = doesFileExist instancefileMax
			if NOT doesFileExist (getFileNamePath instancefileMax) then (
				makeDir (getFileNamePath instancefileMax) all:true
			)
			if NOT MaxFileExists then (
				local file = ::wwdt_mapsrc + "/" + f
				if doesFileExist file then (
					theInstanceImport = wallworm_vmf_import()
					theInstanceImport.importWad = false --chkWad.checked 
					theInstanceImport.sliceBrushes = chkNoSlice.checked
					theInstanceImport.autoCheckGeometry = chkautoCheckGeometry.checked
					theInstanceImport.filename = file
					theInstanceImport.generateMaterials = true
					theInstanceImport.removeEdgeThreshhold = spn3.value
					theInstanceImport.defaultBitmapSize = ddlDefaultBitmapSize.selected as Integer
					if (theInstanceImport.parseAndImport tryLimit:spnLimit.value) != false then (
						if theInstanceImport.errorCount > 0 then (
							format "NOTICE: Although the level imported, the parse function failed (%) times.\n\n" theInstanceImport.errorCount
							--messagebox "Your scene imported... however there may be problems. Hit F11 for more information."
						)
					)
					saveNodes theInstanceImport.nodes instancefileMax quiet:true
					theInstanceImport.deleteAllNodes()
					MaxFileExists = doesFileExist instancefileMax
				)				
			)
			if MaxFileExists then (
				local theinstances = for obj in instanceNodes WHERE classof obj == Container AND obj.sourceDefinitionFilename == "" AND obj.WW_Entity_func_instance.file == f  collect obj
				for obj in theinstances do (
					obj.sourceDefinitionFilename = instancefileMax
					obj.LoadContainer()
				)
			)
		)
		
		set coordsys world
		wallworm_show_displacements()
		wallworm_hide_displacement_brushes()
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/DisplacementsMat2toMat.ms")
		enableButtons()
	)

	on wallwormVMFImporter open do
	(
		global theWallWormVMFImport
		if theWallWormVMFImport == undefined then (
			theWallWormVMFImport = wallworm_vmf_import()
		)
		ver.text = ver.text + (theWallWormVMFImport.importVersion as String)
	
		if isProperty theWallWormVMFImport #removeEdgeThreshhold then (
			spn3.value = theWallWormVMFImport.removeEdgeThreshhold
		)
	
		if nvpx == undefined then (
			mustUseSlice = true
			chkNoSlice.checked = true
			chkNoSlice.toolTip = "This setting is required on your version of 3ds Max."
			chkNoSlice.enabled = false
			theWallWormVMFImport.sliceBrushes = true
	
		)
	
		enableButtons()
	)
	on btnImport pressed do
	(
		if ::wwmt_raw_mats == undefined OR ::wwmt_raw_mats == "" OR doesFileExist ::wwmt_raw_mats == false then (
			messageBox "The VMF Importer needs you to set the root material folder for your Material Library Generator. Please set it Material Root in the following dialog then run the VMF importer again."
	
			macros.run "wallworm.com" "WallWormMaterialGeneratorMCR"
	
		) else (
			if objects.count == 0 OR (queryBox "There are objects already in the scene.\nAre you sure you want to import objects?" title:"Confirm Scene Import") == true then (
				--	fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF|MAP (*.map)|*.MAP|All files (*.*)|*.*|" historyCategory:"Wall Worm VMF" caption:"VMF/MAP File Importer" 
				fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF|Map File (*.map)|*.MAP|All files (*.*)|*.*|" historyCategory:"Wall Worm VMF" caption:"VMF File Importer"
	
				if fsource != undefined then (
					clearListener()
	
					local started = timestamp()
	
					max create mode
					with redraw off (
						::wallworm_performanceCounter_reset()
		
						global theWallWormVMFImport
						theWallWormVMFImport = wallworm_vmf_import()
						theWallWormVMFImport.importWad = false --chkWad.checked 
						theWallWormVMFImport.sliceBrushes = chkNoSlice.checked
						theWallWormVMFImport.autoCheckGeometry = chkautoCheckGeometry.checked
						theWallWormVMFImport.filename = fsource
						theWallWormVMFImport.generateMaterials = true
						theWallWormVMFImport.removeEdgeThreshhold = spn3.value
						theWallWormVMFImport.defaultBitmapSize = ddlDefaultBitmapSize.selected as Integer
						if (theWallWormVMFImport.parseAndImport tryLimit:spnLimit.value) != false then (
							if theWallWormVMFImport.errorCount > 0 then (
								format "NOTICE: Although the level imported, the parse function failed (%) times.\n\n" theWallWormVMFImport.errorCount
							) else (
							local ended = timestamp()
							seconds = ((ended - started) / 1000.0)
							minutes = seconds / 60
							format "% Imported in % seconds (% minutes)\n" (theWallWormVMFImport.filename) seconds minutes
							)
						) else (
							messageBox "The import failed. Press F11 for possible hints."
	
							format "There is a common problem with parsing VMF files that causes an *unknown system exception*. This error seems to be related to line endings and file ending line endings.\n\n"
							local vmfMemStream = memStreamMgr.openFile fsource
							vmfMemStream.seek 0 #seek_set
	
							if NOT wallworm_checkForEndlines vmfMemStream then (
								format "Open the file with a text editor and add a line break at the end of the file and save the file. Then Re-Import.\n\n"
							) else (
								format "If you get this failure, try running the import again and/or setting the retry limit higher. Repeated attempts will likely succeed eventually.\n\n"
							)
							memStreamMgr.close vmfMemStream
	
						)
	
						redrawViews()
	
						if chkSaveCache.checked == true then (
							local doCache = false
							if pathIsNetworkPath fsource then (
								doCache = queryBox "Write the cache? This is often very slow on a network."
							) else (
								doCache = true
							)
							if doCache then (
								cacheimport()
							)
						)
						::wallworm_performanceCounter_showData()
					)
	
				) else (
					messageBox "Ooops... no map was imported."
	
				)
	
			)
			resumeEditing()
		)
	)
	on btnModels pressed do
	(
		local skipFiles = #(".vmt",".spr")
		local mdlObjs = for obj in objects WHERE isProperty obj #model AND isProperty obj #entityType AND obj.entityType == "PointClass" AND obj.model != undefined AND obj.model != "" AND (findItem skipFiles (getFileNameType obj.model) == 0 ) collect obj
		if mdlObjs.count > 0 then (
			--mdlObjs = makeUniqueArray mdlObjs
			--wallworm_get_modelmap()

			if ddlRotTarg.selection == 1 then (
				mdls = true
				props = false
			) else (
				mdls = false
				props = true
			)
			wallworm_import_mdls ang:spnAngle.value mdls:mdls props:props sel:mdlObjs --mdlmap:wallworm_complete_model_list
			local importnames = #("Imported Models", "Imported Collision Hulls", "Imported LODs", "Imported Bodygroups", "Imported Hitboxes", "Imported Attachments", "Imported Bones")
			local LayerManagergetLayerFromName = LayerManager.getLayerFromName
			for l in importnames do (
				local layer = (LayerManagergetLayerFromName l)
				if layer != undefined then (
					layer.isHidden = true
				)
			)
		) else (
			messageBox "No Entities found with model properties."
		)
	)
	on btnSaveLib pressed do
	(
		fileName = getSaveFileName caption:"Save Material Library" filename:((getFileNameFile theWallWormVMFImport.filename) + ".mat") types: "Material Library (*.mat)|*.MAT" historyCategory:"Wall Worm Materials"
		if fileName != undefined then (
			saveTempMaterialLibrary theWallWormVMFImport.materials fileName
	
		)
	)
	on btnTools pressed do
	(
		local disSet = #()
		local NoDrawSet = #()
		local SkySet = #()
		local ToolSet = #()
		local HintSet = #()
		local clipSet = #()
		local invisibleSet = #()
	
		for obj in objects WHERE superClassOf obj == GeometryClass do (
			if isProperty obj #wallworm_displacement then (
				append disSet obj
			) else (
				if obj.mat != undefined then (
					local mat = obj.mat
					local matname = toLower mat.name
					if matchPattern matname pattern:"*tools*" == true then (
						append ToolSet obj
						case matname of (
							"tools/toolsnodraw" : (
								append NoDrawSet obj
							)
							"tools/toolsskybox" : (
								append SkySet obj
							)
							"tools/toolshint" : (
								append HintSet obj
							)
							"tools/toolsskip" : (
								append HintSet obj
							)
							"multi_toolsskip_toolshint" : (
								append HintSet obj
							)
							"multi_toolshint_toolsskip" : (
								append HintSet obj
							)
							"tools/toolsclip" : (
								append clipSet obj
							)
							"tools/toolsplayerclip" : (
								append clipSet obj
							)
							"tools/toolsinvisible":(
								append invisibleSet obj
							)
	
						)
					)
				)
			)
		)
	
		selectionSets["Displacements"] = disSet
		selectionSets["NoDraw"] = NoDrawSet
		selectionSets["SKY"] = SkySet
		selectionSets["Tools"] = ToolSet
		selectionSets["Clip"] = clipSet
		selectionSets["Invisible"] = invisibleSet
		selectionSets["Hint"] = HintSet
	
		hide SkySet
		hide NoDrawSet
		hide HintSet
		hide invisibleSet
		hide clipSet
	
	)
	on btnDisDest pressed do
	(
		wallworm_displacement_to_poly()
	)
	on btnRebuild pressed do
	(
		if theWallWormVMFImport.nodes.count > 0 then (
			if (queryBox "Are you sure? All imported objects will get deleted! The action cannot be undone.") == true then (
				theWallWormVMFImport.deleteAllNodes()
				local started = timestamp()
				buildScene(started)
			)
		) else (
			messageBox "There were no nodes in the scene to rebuild."
		)
	)
	on btnRebuildSel pressed do
	(
		if selection.count > 0 then (
			wallworm_rebuild_selected_objects sel:(selection as Array) sliceBrushes:(chkNoSlice.checked)
		) else (
			messageBox "You must select an object in the scene to rebuild."
		)
	)
	on btnRotFix pressed do
	(
		if selection.count > 0 then (
			in coordsys local (
				for obj in selection WHERE isProperty obj #model AND isProperty obj #wallworm do (
					rotate obj (AngleAxis -90 [0, 0, 1])
					rotate obj (AngleAxis 90 [0, 1, 0])
				)
			)
		) else (
			messageBox "No objects selected. Select props in the scene with a bad rotation."
		)
	)
	on btnImportDetails pressed do
	(
		macros.run "wallworm.com" "WallWormImportVBSPMCR"
	)
	on btnSelectWarningGeo pressed do
	(
		global theWallWormVMFImport
		sel = theWallWormVMFImport.getQuestionableBrushes()
		if sel.count > 0 then (
			select sel
		)
	)
	on btnRemCoplanar pressed do
	(
		global theWallWormVMFImport
		for obj in selection WHERE classOf obj.baseObject == Editable_Poly do (
			theWallWormVMFImport.remCopEdges obj threshhold:spn3.value
		)
	)
	on spn3 changed val do
	(
		if theWallWormVMFImport != undefined AND isProperty theWallWormVMFImport #removeEdgeThreshhold then (
			theWallWormVMFImport.removeEdgeThreshhold = spn3.value
		)
	)
	on btnCache pressed do
	(
		fileName = getOpenFileName caption:"Open Import Cache File" types: "Wall Worm Import Cache (*.wwimportmxs)|*.wwimportmxs|All files (*.*)|*.*|" historyCategory:"Wall Worm VMF" caption:"VMF File Importer"
		if fileName != undefined then (
			f = openFile fileName
			global theWallWormVMFImport
			theWallWormVMFImport = execute f
	
			theWallWormVMFImport.materials = MaterialLibrary()
			theWallWormVMFImport.dotNetFile = DotNetClass "System.IO.File"
			theWallWormVMFImport.rx = DotNetClass "System.Text.RegularExpressions.RegEx"
	
			theWallWormVMFImport.nodes = #()
	
			theWallWormVMFImport.pvGetVert = polyop.getVert
			theWallWormVMFImport.pvGetMapVert = polyop.getMapVert
			theWallWormVMFImport.pvGetMapFace = polyop.getMapFace
	
			buildScene((timestamp()))
	
		)
	
	)
	on btn31 pressed do
	(
		cacheimport()
	)
	on btn14 pressed do
	(
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)
	
		fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/importuvfix.ms")
		global wallworm_brush_plane_fix
		try(
			destroyDialog wallworm_brush_plane_fix
		) catch ()
		createDialog wallworm_brush_plane_fix
	)
	on btnDispMats pressed do
	(
		for obj in objects WHERE obj.mat != undefined AND classOf obj.mat == DirectX_9_Shader do (
			obj.mat = obj.mat.renderMaterial
		)
	)
	on btnDispMats rightClick do
	(
		for obj in objects WHERE obj.mat != undefined AND classOf obj.mat == DirectX_9_Shader do (
			obj.mat = obj.mat.renderMaterial.map1
		)
	)
	on btnMatGen pressed do
	(
		macros.run "wallworm.com" "WallWormMaterialGeneratorMCR"
	)
	on btnPropLibrary pressed do
	(
		if objects.count == 0 OR (queryBox "There are objects in the scene. Do you really want to do this?" title:"Importing Props Query") == true then (
			fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF" historyCategory:"Wall Worm VMF" caption:"Import Prop Library From VMF File"
			if fsource != undefined then (
				wallworm_getMDLsFromVMF fsource deleteAll:false remake:false
			)
		)
	)
	on btnPropLibrary rightClick do
	(
		if objects.count == 0 OR (queryBox "There are objects in the scene. Do you really want to do this?" title:"Importing Props Query") == true then (
			fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF" historyCategory:"Wall Worm VMF" caption:"Import Prop Library From VMF File"
			if fsource != undefined then (
				wallworm_getMDLsFromVMF fsource deleteAll:false remake:true
			)
		)
	)
	on fixPropPlacement pressed do
	(
			theWallWormVMFImport.fixMessedUpXRefLocations()
		)
)