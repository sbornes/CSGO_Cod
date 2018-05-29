/*
Wall Worm Anvil
Level Design Tools for Source
Copyright (c) 2011-2015 by Shawn Olson http://www.shawnolson.net

WallWorm.com

*/
--(
::ww_wwdt_version = 3.93
if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
if (maxVersion())[1] >= 12000 then (
	fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WalkableXView.ms")
)
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.mse")

fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/displacements.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")

if NOT isProperty rootNode #'WW Entity worldspawn' then (
	if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
	) else (
		macros.run "wallworm.com" "wallwormParseFGD2"
	)
	if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
		local test = wallworm_game_settings.get_entity_by_name "worldspawn"
		if test != undefined AND test.ca != undefined then (
			custAttributes.add rootNode test.ca
			if isProperty rootNode #Wallworm_VMF then (
				local wsp = rootNode.'WW Entity worldspawn'
				wsp.skyname = rootNode.Wallworm_VMF.skyName

				if isProperty wsp #MaxPropScreenWidth then (
					wsp.MaxPropScreenWidth = rootNode.Wallworm_VMF.MaxPropScreenWidth
				)

				if isProperty wsp #MinPropScreenWidth then (
					wsp.MinPropScreenWidth = rootNode.Wallworm_VMF.MinPropScreenWidth
				)
				if isProperty wsp #DetailVBSP then (
					wsp.DetailVBSP = rootNode.Wallworm_VMF.DetailVBSP
				)
				if isProperty wsp #detailmaterial then (
					wsp.detailmaterial = rootNode.Wallworm_VMF.DetailSprites
				)
			)
		)
	)
)

--Destroy the dialog if it is already open 
try(destroyDialog wallworm_anvil)catch()

/*See if the UI position was set before*/
thePos = getINISetting ::wallworm_userIni "Layout" "wwdt_ui_pos"
if thePos != undefined AND thePos != "" then (
	execute ("wwdtUILocation =  " + thePos)
)
global wwdtUILocation
if wwdtUILocation == undefined OR classOf wwdtUILocation != Point2 then (
	wwdtUILocation = [20, 20]
)

--Create a rollout
rollout wallworm_anvil "Wall Worm Anvil - Level Design Tools for Source" width:553 height:336
(
	--Add a dot net tab control
	DotNetControl tabs "system.windows.forms.tabControl" pos:[13, 7] width:400 height:25

	--Add a sub rollout.
	SubRollout subRoll "Sub" pos:[13, 32] width:400 height:263

	Bitmap anvillogo "anvil" pos:[419, 33] width:128 height:75 fileName:(::wallworm_installation_path + "/WallWorm.com/assets/anvil_logo_small.tif")

	Hyperlink wwlink "WallWorm.com" pos:[417, 158] width:84 height:20 address:"http://www.wallworm.com" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
	Label lbl2 "Copyright (c) 2013-2015 by " pos:[419, 206] width:147 height:18
	Hyperlink smolink "Shawn Olson" pos:[419, 225] width:82 height:17 address:"http://www.shawnolson.net" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
	Button btn_vmf "Export VMF" pos:[420, 251] width:128 height:48 toolTip:"Click here to generate a VMF file that you can open in Hammer. Displacements will become displacements. WWMT models will become prop_static, prop_physics or prop_dynamic. WW Sky Writer objects will export as the sky_name."

	Button btn_settings "Settings" pos:[419, 112] width:128 height:17 toolTip:"Open the settings floater for all Wall Worm Tools. You can set the Map Src folder for where your VMFs should get saved."

	Button load_corvex_util "CorVex Utility Floater" pos:[419, 135] width:128 height:17

	on load_corvex_util pressed do (
		macros.run "wallworm.com" "WallWormCorVexUtilities"
	)

	Hyperlink donate "Donate" pos:[419, 181] width:43 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/42/donate.html"
	Hyperlink cust22 "Forums" pos:[505, 158] width:51 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://www.wallworm.net"
	Hyperlink extendAnvil "Get More From Anvil" pos:[420, 304] width:129 height:18 address:"http://wallworm.com/store/" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	Button btnHammered "Get Hammered to the Max" tooltip:"Read the Hammer User Guide for 3ds Max." pos:[420, 344] width:129 height:30

	on btnHammered pressed do (
		macros.run "wallworm.com" "WallWormHammeredMCR"
	)

	Button getPro "Get Wall Worm Pro" pos:[420, 376] width:129 height:30
	on getPro pressed do (
		macros.run "wallworm.com" "WallWormWebProductsProMCR"
	)

	--Function to show all properties, methods and events for any dotNet object
	/*fn showProps obj=
	(
		clearListener()
		format "Properties:\n"
		showProperties obj
		format "\nMethods:\n"
		showMethods obj
		format "\nEvents:\n"
		showEvents obj
	)*/

	--Tab initilization function.
	function initTabs tab labels:#() =
	(
		--Clear any existing tabs incase we do an update of them at some point. 
		tab.tabPages.clear()
		--Set the size mode so that we can control their width. 
		tab.sizeMode = tab.sizeMode.fixed
		--Set the width of every tab.
		tab.itemSize = DotNetObject "System.Drawing.Size" ((tab.width / labels.count) - 2) 25

		--Loop through all the labels that we pass to the function and add a tab by the same name. 
		for x in labels do tab.tabPages.add x
	)

	--Add rollouts to the subRollout based on which tab is currently selected. 
	function addTabRollout index =
	(
		--Remove any existing rollouts first. 
		for x in subRoll.rollouts do removeSubRollout subRoll x
		moreSubs = #()
		sub = case index of
		(
			default:
			(
				fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/displacements.ms")
				global anvil_displacements_settings
				(
					fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/displacement_settings.ms")
					append moreSubs anvil_displacements_settings
				)
				global anvil_displacements
				anvil_displacements
			)
			1:
			(
				rollout anvil_tags "Geometry Tags" width:370 height:293
				(
					Button btn_addBrush "Add" pos:[18, 43] width:50 height:17 toolTip:"Designate all selected objects as brush geometry when exporting to VMF."
					Button btn_removeBrush "Remove" pos:[74, 43] width:71 height:17 toolTip:"Remove selected objects from the list of items that should become brushes (world geometry) in the VMF."
					Button btn31 "Select World Geometry" pos:[152, 43] width:138 height:17 toolTip:"Select all objects in the current selection designated as brush geometry. If selection is empty, selects from entire scene."
					Button btn49 "Add" pos:[19, 208] width:53 height:17 toolTip:"Designate all selected objects as belonging in the 3D Skybox when exporting to VMF."
					Button btn50 "Remove" pos:[79, 208] width:50 height:17 toolTip:"Remove selected objects from the list of items that should be in the 3D Skybox in the VMF."
					Button btn51 "Select Sky Objects" pos:[140, 208] width:99 height:17 toolTip:"Select all objects in the current selection designated as 3D Skybox objects. If selection is empty, selects from entire scene."
					GroupBox grp13 "World Geometry Tags" pos:[8, 8] width:344 height:65
					Button btn71 "Get/Set Sky Cam" pos:[207, 238] width:122 height:25 toolTip:"Select the WW Sky Camera helper. The location of the Sky Camera Helper will export as the origin of your mini map if creating a 3D Skybox."
					Button btn_setSkyScale "1/16" pos:[134, 246] width:29 height:17 toolTip:"Set to Skybox Scale ( 1/16 )"
					Button btn_setSkyScale2 "1/32" pos:[167, 246] width:32 height:17 toolTip:"Set to L4D Skybox Scale ( 1/32 )"
					Spinner spn_scale "Skybox Scale 1/" pos:[71, 246] width:58 height:16 range:[1, 100, 16] type:#integer scale:1 toolTip:"Set the skybox scale for this level."
					Hyperlink link3dSky "Skybox Tool Tips" pos:[238, 180] width:107 height:15 address:"http://dev.wallworm.com/topic/45/3d_skybox.html" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
					Button btn23 "Add" pos:[115, 95] width:93 height:15 toolTip:"Set the selection as a brush and a func_detail."
					Button btn24 "Remove" pos:[213, 95] width:54 height:15 toolTip:"Remove this item form the func_detail list."
					Button btn73 "Add as Sky and Brush" pos:[17, 178] width:199 height:24 toolTip:"Set the selected objects as both brush and sky objects."
					Button btn27 "Group Detail" pos:[20, 95] width:91 height:15 toolTip:"Group the selected objects and tag as func_detail."
					GroupBox grp18 "func_detail Tags" pos:[9, 80] width:343 height:38
					GroupBox grp19 "3D Skybox Tags" pos:[9, 157] width:342 height:118
					Button btn16 "Brush Entities" pos:[10, 125] width:168 height:25
					Button btn17 "Point Entities" pos:[186, 126] width:165 height:25

					CheckButton ckbBrushMode "Brush Mode" pos:[152, 20] width:137 height:18 toolTip:"When enabled, new objects you create are automatically tagged as brush objects."
					Button btnSelDetails "Select Details" pos:[272, 95] width:75 height:16 tooltip:"Select all objects in the scene tagged as func_detail."

					on anvil_tags open do
					(
						ww_wwdt_sky_marker = ww_wwdt_get_sky_marker create:false
						if ww_wwdt_sky_marker != undefined then (
							if isProperty ww_wwdt_sky_marker #wwmt_scale then (
								spn_scale.value = ww_wwdt_sky_marker.wwmt_scale
							)
						)
						global wallwormbrusmodestate
						if wallwormbrusmodestate != undefined AND wallwormbrusmodestate == true then (
							ckbBrushMode.state = true
						) else (
							ckbBrushMode.state = false
						)
					)
					on btn_addBrush pressed do
					(
						macros.run "wallworm.com" "WallWormDesignateSelectionAsBrushes"
					)
					on btn_removeBrush pressed do
					(
						macros.run "wallworm.com" "WallWormRemoveSelectionFromBrushes"
					)
					on btn31 pressed do
					(
						macros.run "wallworm.com" "wallwormSelectAllBrushes"
					)

					on btnSelDetails pressed do (
						macros.run "wallworm.com" "wallwormSelectAllDetails"
					)

					on btn49 pressed do
					(
						macros.run "wallworm.com" "WallWormDesignateSelectionAsSky"

					)
					on btn50 pressed do
					(
						macros.run "wallworm.com" "WallWormRemoveSelectionFromSky"
					)
					on btn51 pressed do
					(
						macros.run "wallworm.com" "WallWormSelectSkyObjects"
					)
					on btn71 pressed do
					(
						ww_wwdt_sky_marker = ww_wwdt_get_sky_marker setScale:spn_scale.value create:true
						--ww_wwdt_setSkyScale setScale:spn_scale.value
						select ww_wwdt_sky_marker
						--max zoomext sel all
					)
					on btn_setSkyScale pressed do
					(
						spn_scale.value = 16
						ww_wwdt_setSkyScale amount:spn_scale.value create:true
					)
					on btn_setSkyScale2 pressed do
					(
						spn_scale.value = 32
						ww_wwdt_setSkyScale amount:spn_scale.value create:true

					)
					on spn_scale changed val do
					(
						ww_wwdt_setSkyScale amount:spn_scale.value create:false

					)
					on btn23 pressed do
					(
						macros.run "wallworm.com" "WallWormDesignateSelectionAsFuncDetail"
					)
					on btn24 pressed do
					(
						macros.run "wallworm.com" "WallWormRemoveSelectionFromFuncDetail"
					)
					on btn73 pressed do
					(
						macros.run "wallworm.com" "WallWormDesignateSelectionAsBrushes"
						macros.run "wallworm.com" "WallWormDesignateSelectionAsSky"

					)
					on btn27 pressed do
					(
						macros.run "wallworm.com" "WallWormDesignateSelectionAsFuncDetailGroup"
					)
					on btn16 pressed do
					(
						macros.run "wallworm.com" "wallwormBrushEntities"

					)
					on btn17 pressed do
					(
						macros.run "wallworm.com" "wallwormPointEntities"
					)
					on ckbBrushMode changed st do
					(
						global wallwormbrusmodestate
						macros.run "wallworm.com" "wallwormbrushmodetoggle"
						ckbBrushMode.state = wallwormbrusmodestate

					)
				)
				(
					fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/lightmap.ms")
					global wallworm_lightmap

					append moreSubs wallworm_lightmap
				)

				anvil_tags
			)
			2:
			(
				global wallworm_proxy_tools
				fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/proxy_tools.ms")
				(
					forAnvil = true
					fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/wwmt_anvil_utilities.ms")
					global wwmt_utilities
					append moreSubs wwmt_utilities
				)
				wallworm_proxy_tools
			)

			3:(
				rollout anvil_world "World" height:300 (
					SubRollout entprops "Map Properties" height:430
					Button getWorlLimits "Show World Limits" align:#left across:2
					Button hideWorldLimits "Hide World Limits"
					SubRollout worldprops "Miscellaneous" height:146

					on getWorlLimits pressed do (
						local l = wallworm_create_map_limits()
						unhide l
					)

					on hideWorldLimits pressed do (
						local l = wallworm_create_map_limits()
						hide l
					)

					on anvil_world open do (
						if isProperty rootNode #'WW Entity worldspawn' then (
							local theName = "WW Entity worldspawn"

							local catCount = custAttributes.count rootNode
							local test = false
							local ca = undefined
							for i = 1 to catCount while test == false do (
								ca = custAttributes.get rootNode i
								if ca.name == theName then (
									test = true
								)

							)
							if test == true AND ca != undefined then (
								addSubRollout anvil_world.entprops ca.params
							)
						)

						local limits = wallworm_create_map_limits()
						local theName = "Wallworm_Mapsize"
						local catCount = custAttributes.count limits
						local test = false
						local ca2 = undefined
						for i = 1 to catCount while test == false do (
							ca2 = custAttributes.get limits i
							if ca2.name == theName then (
								test = true
							)
						)
						if test == true AND ca2 != undefined then (
							addSubRollout anvil_world.worldprops ca2.paramrollout
						)
					)

				)
			)
			4:
			(
				fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/lights.ms")
				fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/wallworm_shape_path.ms")
				rollout wwbrushrollout "Brush Functions" width:361 height: 100 (
					Button brkFaces "Break Non Planar Polygons on Selected Objects" toolTip:"Fix selected objects such that non-planar polygons get broken into planar polygons. Do this for objects that don't export properly."
					Button chkProblems "Check for Problems in Scene"

					on chkProblems pressed do (
						macros.run "wallworm.com" "WallWormCheckForProblemsMCR"
					)
					on brkFaces pressed do (
						macros.run "wallworm.com" "WallWormBreakNonPlanarMCR"
					)
				)

				rollout anvil_materials "Materials" width:361 height:218
				(
					Button btn_generateLibrary "Generate Library" toolTip:"Open the WW Material Library Generator to create 3ds Max material libraries based off of a Source VMT material collection." offset:[-50, 0] across:2
					Button btn_exportVTFS "Export Brush/Displacement Materials into VMTs/VTFs" toolTip:"Export VTFs/VMTs (textures) based on the textures on the geometry in the scene." offset:[-40, 0]
					Group "Blend Materials" (
						Button btnConvBlendToDX "Convert Blend to DX Blend" across:2 tooltip:"Convert the material of any selected object that has a Blend Material to a DX Material where the current Blend Material becomes the DX render material."
						Button btnUpdateBlendsDisps "Update Blends from DX" tooltip:"Click to update all Blend Materials to match the output based on the DX material texture orders."

					)
					Group "3ds Max 2014+ Displacement Display Functions" (
						CheckBox chkConvertDX9 "Convert DX9 Materials to DX11 during update." toolTip:"If your displacements were created before 3ds Max 2014, you can convert their materials to DX11 compatible."
						RadioButtons rdoDXVersion "DirectX Version" labels:#("DX11", "DX10") columns:2 across:2
						Button btnUpdateDX "Update Displacement Materials" toolTip:"Update the display techniques for displacements in 3ds Max 2014+."
					)

					on btnUpdateBlendsDisps pressed do (
						local objs
						if selection.count > 0 then (
							objs = selection as Array
						) else (
							objs = geometry as Array
						)

						::wallworm_update_blends objs:objs
					)
					on btnConvBlendToDX pressed do
					(
						::wallworm_convert_blends_to_dx (selection as Array) --rev:true
					)

					on btn_generateLibrary pressed do
					(
						macros.run "wallworm.com" "WallWormMaterialGeneratorMCR"
					)

					on btn_exportVTFS pressed do
					(
						macros.run "wallworm.com" "WallWormAnvilCompileVTFMCR"
					)

					on btnUpdateDX pressed do
					(
						if chkConvertDX9.checked == true then (
							fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/updateDX9toDX11blend.ms")
						)
						if rdoDXVersion.state != 1 then (
							::wallworm_update_dxdisplay dxversion:10
						) else (
							::wallworm_update_dxdisplay()
						)
					)
				)

				global wallwormlights
				global wallworm_shape_path
				global anvil_materials

				append moreSubs wwbrushrollout
				append moreSubs wallworm_shape_path
				append moreSubs anvil_materials

				wallwormlights
			)

		)
		addSubRollout subRoll sub

		local UIHeight = sub.height + 30
		if moreSubs.count > 0 then (
			for si = 1 to moreSubs.count do (
				local r = moreSubs[si] as RolloutClass
				addSubRollout subRoll r
				UIHeight = UIHeight + r.height + 30
			)
		)
		if UIHeight < 280 then (
			UIHeight = 280
		) else if UIHeight > 800 then (
			UIHeight = 800
		)
		if index == 0 then (
			sub.lbx_length.items = ww_wwdt_dispsizes
			sub.ddl_height.items = ww_wwdt_dispsizes
			sub.ddl_width.items = ww_wwdt_dispsizes
		)

		wallworm_anvil.subRoll.height = UIHeight
		wallworm_anvil.height = wallworm_anvil.subRoll.height + 30
	)

	--When the rollout opens initilize the tab control

	on wallworm_anvil open do
	(
		initTabs tabs labels:#("Displacements", "Tags", "Models", "World", "Miscellaneous")
		addTabRollout 0
	)
	on wallworm_anvil close do
	(
		::wallworm_anvil = undefined
	)
	on wallworm_anvil moved pos do
	(
		setINISetting ::wallworm_userIni "Layout" "wwdt_ui_pos" (pos as String)
	)
	on tabs mouseUp senderArg arg do
	(
		addTabRollout senderArg.SelectedIndex
	)
	on btn_vmf pressed do
	(
		macros.run "wallworm.com" "WallWormExportVMFMCR"
	)
	on btn_settings pressed do
	(
		macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
	)
)
--Create the dialog
createDialog wallworm_anvil pos:[wwdtUILocation.x, wwdtUILocation.y]

wallworm_anvil.title += " - Version " + (ww_wwdt_version as String)

callbacks.removeScripts id:#wwdt_displacement_clone_handler
callbacks.addScript #postNodesCloned "wwdt_copy_displacement (callbacks.notificationParam())" id:#wwdt_displacement_clone_handler

--find all displacements and run their correct event handlers
--deleteAllChangeHandlers  id:#topologyControlMesh
ww_wwdt_setDispHandlers()

callbacks.removeScripts id:#wwdt_displacement_topo_handler
callbacks.addScript #filePostOpenProcess ("testpath = ::wallworm_installation_path\nif testpath == undefined then (\ntestpath = (symbolicPaths.getPathValue \"$scripts\")\n)\n if doesFileExist (testpath+\"/WallWorm.com/WallWormSimpleDisplacement/startup.ms\") then (fileIn (testpath+\"/WallWorm.com/WallWormSimpleDisplacement/startup.ms\") )") id:#wwdt_displacement_topo_handler persistent:true
