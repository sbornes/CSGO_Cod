/*
Hull Helper for Wall Worm Mod Tools
Copyright (c) 2011-2015
All Rights Reserved

http://www.wallworm.com

Written by Shawn Olson
http://www.shawnolson.net

The advanced hull function requires Convexity 1.17+.
Convexity is available at http://www.maple3d.com

*/
try(destroyDialog wwmt_hull_helper)catch(
	--there was not any open
)

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

rollout wwmt_hull_helper "Wall Worm Hull Helper" width:288 
(
	local  hullsettings = "$userscripts\\WallWorm.com\\config\\hullhelper.ini"
	button btn1 "Grow" pos:[11,62] width:60 height:25 toolTip:"Grow Subobject Selection."
	button btn2 "Shrink" pos:[75,62] width:60 height:25 toolTip:"Shrink Subobject Selection."
	button btn3 "Detach" pos:[11,119] width:65 height:30 toolTip:"Detach selected faces as an Element SubObject and hide the selection."
	button btn10 "Unhide All" pos:[81,119] width:65 height:30 toolTip:"Unhide any hidden faces in the selected object."
	label lbl1 "Wall Worm Hull Helper" pos:[168,6] width:113 height:18
	button btn5 "Prepare From Selection" pos:[11,7] width:138 height:30 toolTip:"Copy and Hide the selected Meshes, convert the copies into a single Editable Poly and go to Polygon Sub Object Mode."
	HyperLink wwlink "Wall Worm" pos:[9,199] width:87 height:15 address:"http://www.wallworm.com"
	button btn24 "Loop" pos:[11,90] width:60 height:25
	button btn25 "Ring" pos:[75,90] width:60 height:25
	button btn9 "Create Hulls From Selection" pos:[139,85] width:142 height:29 toolTip:"Create Convex Hull for each Element of each Object in the current selection."
	spinner spn_max_verts "Max Verts Per Hull" pos:[195,63] width:84 height:16 range:[4,4096,44] type:#integer scale:1 toolTip:"Choose the maximum number of vertices any hull piece can have when being generated."
	button btn_process "Process Selected Hulls" pos:[153,119] width:128 height:31 toolTip:"Click here to make the selected objects ready to export as a \$concave hull by adding the appropriate smoothing groups and material names."
	button btnPivot "Pivots to Selection Center" pos:[12,42] width:137 height:15 toolTip:"Align the pivot of each item in the selection to selection center. Necessary if you are having a problem with the hulls being offset."
	button btn12 "Quick Hulls" pos:[170,25] width:110 height:29 toolTip:"Assign Quick Hulls to the selected WWMT helpers."
	button btn13 "Merge Selected Hulls" pos:[155,156] width:127 height:20 toolTip:"Merge selected hulls into a single object."
	button btnCarver "Launch Carver" pos:[9,182] width:87 height:13 toolTip:"Launch Carver, which has some useful explode/combine functions for some scenarios. Requires Carver."
	button btnSkinEach "Skin on Each Object Selected" pos:[114,187] width:167 height:29 toolTip:"Add a separate skin modifier to each object in the selection."
	group "V-HACD"  (
		spinner spnResolution "Resolution"  range:[10000,6.4e+007,10000] type:#integer scale:1  tooltip:"Maximum number of voxels generated during the voxelization stage"
		spinner spnMaxDepth "Max Depth"  range:[1,32,20] type:#integer scale:1 tooltip:"Maximum number of clipping stages. During each split stage, all the model parts (with a concavity higher than the user defined threshold) are clipped according the *best* clipping plane."
		spinner spnMaxConcavity "Max Concavity"  range:[0,1,0.0025] scale:0.0001 tooltip:"Maximum concavity"
		spinner spnPlaneDownsampling "Plane Downsampling"  range:[1,16,4] type:#integer scale:1 tooltip:"Controls the granularity of the search for the *best* clipping plane"
		spinner spnconvexhullDownsampling "ConvexHhull Downsampling"  range:[1,16,4] type:#integer scale:1 tooltip:"Controls the precision of the convex-hull generation process during the clipping plane selection stage."
		spinner spnAlpha "Alpha"  range:[0,1,0.05] scale:0.01 tooltip:"Controls the bias toward clipping along symmetry planes."
		spinner spnBeta "Beta"  range:[0,1,0.05] scale:0.01 tooltip:"Controls the bias toward clipping along revolution axes."
		spinner spnGamma "Gamma"  range:[0,1,0.00125] scale:1e-005 tooltip:"Maximum allowed concavity during the merge stage."
		checkbox chkPCA "Normalize Mesh"  tooltip:"Rnable/disable normalizing the mesh before applying the convex decomposition."
		radioButtons rdoMode "Mode"  labels:#("Voxel","Tetrahedron")
		spinner spnMaxCHVertices "Max CHVertices"  range:[4,1024,44] type:#integer tooltip:"Controls the maximum number of triangles per convex-hull."
		spinner spnminVolumePerCH "Min Volume Per CH"  range:[0,0.01,0.0001] scale:0.0001 tooltip:"Controls the adaptive sampling of the generated convex-hulls."
		button btnRunV "Execute"  toolTip:"Run the V-HACD"	width:120 across:2
		Button btnSaveAsPreset "Save as Defaults"
	)

	function loadPresets = (
		local resolution = getINISetting hullsettings "VHACD" "resolution"
		local MaxDepth = getINISetting hullsettings "VHACD" "MaxDepth"
		local MaxConcavity = getINISetting hullsettings "VHACD" "MaxConcavity"
		local PlaneDownsampling = getINISetting hullsettings "VHACD" "PlaneDownsampling"
		local convexhullDownsampling = getINISetting hullsettings "VHACD" "convexhullDownsampling"
		local Alpha = getINISetting hullsettings "VHACD" "Alpha"
		local Beta = getINISetting hullsettings "VHACD" "Beta"
		local Gamma = getINISetting hullsettings "VHACD" "Gamma"
		local PCA = getINISetting hullsettings "VHACD" "PCA"
		local mode = getINISetting hullsettings "VHACD" "mode"
		local MaxCHVertices = getINISetting hullsettings "VHACD" "MaxCHVertices"
		local minVolumePerCH = getINISetting hullsettings "VHACD" "minVolumePerCH"

		if resolution != "" AND resolution as integer != undefined then  spnResolution.value = resolution as integer
		if MaxDepth != "" AND MaxDepth as integer != undefined then  spnMaxDepth.value = MaxDepth as integer
		if MaxConcavity != "" AND MaxConcavity as float != undefined then  spnMaxConcavity.value = MaxConcavity as float
		if PlaneDownsampling != "" AND  PlaneDownsampling as integer != undefined then  spnPlaneDownsampling.value = PlaneDownsampling as integer
		if convexhullDownsampling != "" AND convexhullDownsampling as integer != undefined then spnconvexhullDownsampling.value = convexhullDownsampling as integer
		if Alpha != "" AND Alpha as float != undefined then spnAlpha.value = Alpha as float 
		if Beta != "" AND Beta as float != undefined then  spnBeta.value = Beta as float
		if Gamma != "" AND Gamma as float != undefined then  spnGamma.value = Gamma as float
		if PCA != ""  AND  PCA as BooleanClass != undefined then  chkPCA.checked = PCA as BooleanClass
		if mode != "" AND mode as integer != undefined AND mode as integer > 0 then rdoMode.state = mode as integer
		if MaxCHVertices != "" AND MaxCHVertices as integer != undefined then spnMaxCHVertices.value = MaxCHVertices as integer
		if minVolumePerCH != "" AND minVolumePerCH as float != undefined then spnminVolumePerCH.value = minVolumePerCH as float

	)
	on wwmt_hull_helper open do (
		loadPresets()
	)
	
	on btnSaveAsPreset pressed do (
		SetINISetting hullsettings "VHACD" "resolution" (spnResolution.value as string)
		SetINISetting hullsettings "VHACD" "MaxDepth" (spnMaxDepth.value as string)
		SetINISetting hullsettings "VHACD" "MaxConcavity" (spnMaxConcavity.value as string)
		SetINISetting hullsettings "VHACD" "PlaneDownsampling" (spnPlaneDownsampling.value as string)
		SetINISetting hullsettings "VHACD" "convexhullDownsampling" (spnconvexhullDownsampling.value as string)
		setINISetting hullsettings "VHACD" "Alpha" ( spnAlpha.value as string)
		setINISetting hullsettings "VHACD" "Beta" (spnBeta.value as string)
		setINISetting hullsettings "VHACD" "Gamma" (spnGamma.value as string)
		setINISetting hullsettings "VHACD" "PCA" (chkPCA.checked as string)
		setINISetting hullsettings "VHACD" "mode" (rdoMode.state as string)
		setINISetting hullsettings "VHACD" "MaxCHVertices" (spnMaxCHVertices.value as string)
		setINISetting hullsettings "VHACD" "minVolumePerCH" (spnminVolumePerCH.value as string)

	)
	
	on btn1 pressed do
	(
		if classOf $ == Editable_Poly then (
			$.EditablePoly.GrowSelection ()
		)
	)
	on btn2 pressed do
	(
		if classOf $ == Editable_Poly then (
			$.EditablePoly.ShrinkSelection ()
		)
	)
	on btn3 pressed do
	(
		macros.run "wallworm.com" "WallWormHullHelperDetach"
	)
	on btn10 pressed do
	(
		if classOf $ == Editable_Poly then (
			$.EditablePoly.unhideAll #Face
		)
	)
	on btn5 pressed do
	(
		if selection != undefined AND selection.count > 0 then (
			newObj = undefined
			for obj in selection do (
				if superClassOf obj == GeometryClass then (
					temp = copy obj
	
					convertToPoly temp
	
					if newObj == undefined then (
						newObj = temp
					) else (
						newObj.attach temp newObj
					)
					setUserPropBuffer newObj "wwmt_temphull = true"
				) else (
					print "not right class"
				)
			)
	
			if newObj != undefined then (
				newObj.name = uniqueName (selection[1].name + "_Hull_Master")
	
				hide selection
				select newObj
				setCommandPanelTaskMode #modify
				subObjectLevel = 4
	
			)
		) else(
			messageBox "No valid objects selected."
		)
	
	)
	on btn24 pressed do
	(
		macros.run "PolyTools" "Loop"
	
	)
	on btn25 pressed do
	(
		macros.run "PolyTools" "Ring"
	
	)
	on btn9 pressed do
	(
		if selection.count > 0 then (
			if subObjectLevel != 0 then (
				subObjectLevel = 0
			)
			try (
				local startmeshes = (selection as Array)
				NewHulls = wallwormCreateMeshFromMeshes startmeshes vertlimit:spn_max_verts.value doOffsetransforms:true resestX1:false
				hide startmeshes
				select NewHulls
				wwmt_hullsmoothinggroups NewHulls 1
				redrawViews()
			)catch (
				messageBox "There was a problem. The Wall Worm Hull Helper only works if you have either the nVidia PhysX Plugin or MassFX (Integrated into 3ds Max 2012+)."
			)
		) else (
			messageBox "This function only works if you have one or more objects selected."
		)
	)
	on btn_process pressed do
	(
		if selection.count > 0 then (
			if subObjectLevel != 0 then (
				subObjectLevel = 0
			)
	
			wwmt_hullsmoothinggroups selection 1
			redrawViews()
		) else (
			messageBox "This function works on a selection of objects."
		)
	
	)
	on btnPivot pressed do
	(
		for obj in selection do (
			obj.pivot = selection.center
	
		)
	
	)
	on btn12 pressed do
	(
		if selection.count == 0 then (
			messageBox "This function only works when you have selected a set of WWMT helpers."
	
		) else (
			oldsel = selection as Array
			local wwmts = 0
			local failed = #()
			clearSelection()
			for obj in oldsel do (
				isWWMTSource = getUserProp obj #wwmt_source_helper
				if isValidNode obj  AND  isWWMTSource == true then (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel obj tempWWMT
					try (
						if (tempWWMT.createHull maxVerts:spn_max_verts.value) == true then (
							wwmts += 1
						) else (
							append failed ("Failed to Create Hull: " + tempWWMT.modelName)
						)
	
					) catch (
						append failed ("Failed to Create Hull: " + tempWWMT.modelName)
					)
	
				)
				tempWWMT = undefined
			)
	
			select oldsel
			local failedmessage = ""
			if failed.count > 0 then (
				failedmessage = "\n\n(" + (failed.count as String) + ") Model(s) failed to create hulls. Press F11 to see the list."
				for i in failed do (
					print i
				)
			)
			if wwmts == 0 then (
				messageBox ("No no models were hulled. Either no WWMT helpers were selected or there were errors." + failedmessage)
			) else (
				messageBox ((wwmts as String) + " models were hulled." + failedmessage)
			)
		)
	
	)
	on btn13 pressed do
	(
		if selection.count > 0 then (
			wallworm_merge_hulls()
	
		)
	)
	on btnSkinEach pressed do
	(
		objs = for obj in selection WHERE validModifier obj Skin == true AND (wallworm_get_modifierByClass obj Skin) == undefined collect obj
	
		if objs.count > 0 then (
			for obj in objs do (
				addModifier obj (Skin())
			)
		)
	
	)
	on btnCarver pressed do
	(
			macros.run "wallworm.com" "WallWormCarver"
	)
	on btnRunV pressed do
	(
		local sCount = selection.count
		if sCount > 0 then (
			local pca = 0
			if chkPCA.checked then pca = 1
			local startObjName = selection[1]
			::WallWormHullOps.vhadObjs (selection as array) resolution:spnResolution.value maxDepth:spnMaxDepth.value maxConcavity:spnMaxConcavity.value planeDownsampling:spnPlaneDownsampling.value convexhullDownsampling:spnconvexhullDownsampling.value alpha:spnAlpha.value beta:spnBeta.value gamma:spnGamma.value pca:pca mode:(rdoMode.state - 1) maxCHVertices:spnMaxCHVertices.value minVolumePerCH:spnminVolumePerCH.value
			local hulls = for obj in (selection as array) WHERE superclassof obj == GeometryClass collect obj
			local helps = for obj in (selection as array) WHERE superclassof obj != GeometryClass collect obj
			if helps.count > 0 then (
				delete helps
			)
			wwmt_hullsmoothinggroups hulls 1
			if sCount == 1 then (
				local h = wallworm_merge_hulls thehulls:hulls
				if isValidNode h then (
					h.name = startObjName.name+ "_hull"
					h.pivot = startObjName.pivot
					resetXForm h
					convertToPoly h
				)
			)
			redrawViews()
			
		) else (
			messagebox "No objects selected."
		)
	)
)

createDialog wwmt_hull_helper