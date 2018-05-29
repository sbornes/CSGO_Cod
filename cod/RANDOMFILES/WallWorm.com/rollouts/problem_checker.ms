rollout wallwormProblemChecker "Check For Problems" width:260 (
	local theObjs = #()
	local ignoreEntityCount = #("func_detail", "prop_static", "info_overlay", "prop_detail", "prop_detail_sprite", "env_cubemap", "func_ladder", "func_viscluster", "info_lighting", "info_no_dynamic_shadow", "info_null", "func_instance", "func_instance_parms", "func_instance_origin")
	function countAgainstEntities classname = (
		((findItem ignoreEntityCount className) == 0)
	)

	Group "General Problems" (
		CheckBox chkVersions "Check for 3ds Max Version" align:#left toolTip:"See if there are any known problems with your version of Max."
		CheckBox chkWWMTVersion "Check for Wall Worm updates" align:#left toolTip:"Check to see if you have the latest version of Wall Worm."
		CheckBox chkSMDMaterial "Check Wall Worm Settings" align:#left toolTip:"Check for problems with your global WW settings." checked:true
		CheckBox chkEntVersions "Out-Of-Date Entities" align:#left tooltip:"Check if there are any entities in the scene that are out-of-date or the FGD needs re-parsed?" checked:true
	)

	Group "Level and VMF checks" (
		CheckBox chkInvalidObjects "Concave Geometry" align:#left toolTip:"Selects objects that are not valid brushes because they are concave (not convex)."
		CheckBox chkEntsOutOfBounds "Entities Out of Bounds" align:#left tooltip:"Check for entities that are outside the bounds of the compilable space."
		CheckBox chkEntityLimiti "Entity Count" across:2 tooltip:"Check the number of entities in the scene. Those prop_static, prop_detail, func_detail and other internal entities will be skipped."
		Spinner spEntLimit "Limit" type:#integer range:[4096, 65536, 4096] tooltip:"Set the entity limit appropriate for your mod. This is the total entity limit, and does not distinquish networked/non-networked entities."
		CheckBox chkOverlayLimiti "Overlay Count" across:2 tooltip:"Check the number of overlays in the scene. This counts overlays created with Worm Face."
		Spinner spOverlayLimit "Limit" type:#integer range:[0, 65536, 512] tooltip:"Set the overlay limit appropriate for your mod. This is the total overlay limit."
		CheckBox chkDisplacementLimit "Displacement Count" across:2 tooltip:"Check the number of displacements in the scene."
		Spinner spDisplacementLimit "Limit" type:#integer range:[0, 65536, 2048] tooltip:"Set the displacement limit appropriate for your mod. This is the total displacement limit."
		CheckBox chkBrushLimit "Brush Count" across:2 tooltip:"Check the number of brushes in the scene."
		Spinner spBrushLimit "Limit" type:#integer range:[0, 65536, 8192] tooltip:"Set the brush limit appropriate for your mod."
		CheckBox chkSideLimit "Side Count" across:2 tooltip:"Check the number of Sides in the scene."
		Spinner spSideLimit "Limit" type:#integer range:[0, 1048576, 65536] tooltip:"Set the side limit appropriate for your mod."
		CheckBox chkBrushOutOfBounds "Brushes Out of Bounds" align:#left tooltip:"Check for brushes that have verts outside the bounds of the compilable space."
		CheckBox chkNonPlanarFaces "Brush Geometry with Non-Planar Polys" align:#left toolTip:"Find objects that have polygons that are non-planar. Non planar faces may be convex, but will not always export as intended."
		CheckBox chkLimitToTaggedBrush "Only Check Tagged Geometry" align:#left checked:true toolTip:"When checked, only include objects that have been tagged as world geometry with Anvil."

	)

	Group "Models and Proxies" (
		CheckBox chkModelsNotYesExported "Models in Scene that aren't Exported yet" align:#left toolTip:"Check for WWMT helpers in the scene that have no MDL file compiled into the game directory."
		CheckBox chkExportedMaterials "Models with missing VMTs." align:#left toolTip:"Check to see if there are any WWMT models that are missing some VMTs." enabled:false
	)

	Group "Options" (
		CheckBox chkXREF "Include XREF Scenes" align:#left tooltip:"When on, looks for objects in XREF scenes (but they cannot be selected). Slows the check down." 
		CheckBox chkUseCurrentSelection "Limit to Current Selection" align:#left toolTip:"Only search for problems within the current selection. Deactivates XRef."
		CheckBox chkSelectResults "Select Problem Objects" align:#left toolTip:"If errors are found, set the current selection to those problem objects."
		CheckBox chkIgnoreHidden "Ignore Hidden Objects" align:#left toolTip:"Do not check hidden objects for problems."
	)
	
	on chkUseCurrentSelection changed stat do (
		chkXREF.checked  = NOT stat
	)
	on chkXREF changed stat do (
		chkUseCurrentSelection.checked  = NOT stat
	)
	Button btnDoIt "Check For Problems Now" align:#center
	Button btnGetLastRes "Select Last Results" align:#center

	Group "Update Scene Definitions and Helpers" (
		Button btnUpdateWWMT "WWMT" across:4 align:#left tooltip:"Update the WWMT Helpers to the latest WWMT definitions."
		Button btnUpdateProx "Proxies" align:#left tooltip:"Update the WWMT Proxy definitions in the scene." offset:[-8, 0]
		Button btnUPdateEntities "Entities" align:#left tooltip:"Update all scene entities to the latest versions based on the Entity Cache." offset:[-16, 0]
		Button btnUpdateDisplacements "Displacements" align:#left tooltip:"Update the dispalcements in the scene to use the latest custom attribute definition." offset:[-28, 0]
	)
	Group "App Actions" (
		Button btnGetMaxUpdates "Download Latest 3ds Max Updates" align:#left toolTip:"Open the Web Page of the latest updates for Max."
		Button btnUpdateWallWorm "Update Wall Worm" align:#left toolTip:"Download and Install the latest version of Wall Worm."
		Button btnBreakFacesSelected "Break Non Planar Polygons on Selection" align:#left toolTip:"This function will convert all selected objects to an editable poly... and then break any polygons that have faces not in the same plane."
		Button cvxSceneChecker "Launch Convexity Scene Checker" align:#left toolTip:"Opens the Convexity Scene Checker if you have Convexity installed. Get Convexity at Maple3D.com."
		Button launchPurge "Purge Utility Files"
	)
	
	on launchPurge pressed do (
		fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/purgefiles.ms")
		try (destroyDialog ::wallwormCleanup) catch ()
		createDialog ::wallwormCleanup
	)
	on btnUpdateWWMT pressed do (
		wallworm_update_all_wwmt_cas()
	)
	on btnUpdateProx pressed do (
		wallworm_update_all_proxy_cas()
	)
	on btnUPdateEntities pressed do (
		if ::wallworm_update_all_entities == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
		)
		::wallworm_update_all_entities()
	)
	on btnUpdateDisplacements btn pressed do (
		if ::wallworm_update_displacements == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
		)
		::wallworm_update_displacements()
	)
	on btnUpdateWallWorm pressed do (
		global wallworm_donot_download

		if ::wallworm_winrar != undefined AND doesFileExist (::wallworm_winrar + "\\WinRar.exe") then (
			if wallworm_donot_download == undefined OR wallworm_donot_download == false then (
				if isDirectoryWriteable != undefined AND NOT isDirectoryWriteable (::wallworm_installation_path) then (
					messageBox "Cannot Update Wall Worm because the installation path is not writable. You'll have to install manually."
					shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""

				) else (
					messageBox (wallworm_download_updates())
				)
			) else (
				shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""
				print "Set to not auto-download. Fetching file from URL."
			)
		) else (
			messageBox ("Wall Worm did not Update because WinRar is not installed OR because the global settings prevent it.")

			shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""

		)
	)

	function selectLastResults = (
		if theObjs.count > 0 then (
			clearSelection()
			select theObjs

		)
	)

	on wallwormProblemChecker open do (
		if selection.count == 0 then (
			chkSelectResults.checked = true
		)

	)

	on btnGetLastRes pressed do (
		selectLastResults()
	)

	on cvxSceneChecker pressed do (
		try (
			macros.run "Maple3D-Convexity" "SceneChecker"

		) catch (
			messageBox "Convexity not found. For details, see www.maple3d.com ."
		)

	)

	on btnGetMaxUpdates pressed do (
		macros.run "Help" "Help_Web_Updates"
	)

	on btnBreakFacesSelected pressed do (
		macros.run "wallworm.com" "WallWormBreakNonPlanarMCR"
	)

	function useThisNode node = (
		if chkUseCurrentSelection.checked == true AND node.isSelected == false then (
			false
		) else (
			if chkIgnoreHidden.checked == true AND node.isHidden == true then (
				 false
			) else (
				true
			)
		)
	)

	function useThisBrushNode node = (
		if useThisNode node == false then (
			false
		) else (
			if chkLimitToTaggedBrush.checked == true   then (
				case (classof node) of (
					CorVex:(
						node.isWorldGeometry
					)
					ShellVex:(
						node.isWorldGeometry
					)
					PropLine:(
						node.isWorldGeometry
					)
					Arch:(
						node.isWorldGeometry
					)
					default:(
						if(getUserProp node #wwdt_brush_geometry_export != true) then (
							false
						) else (
							true
						)
					)
				)
				
			) else (
				true
			)
		)
	)

	on btnDoIt pressed do (
		theObjs = #()
		local nonConvex = #()
		local nonPlanar = #()
		local unExportedModels = #()
		local versionProblems = #()
		local settingsErrors = #()
		local outofboundproblems = #()
		local wwold = false

		if chkWWMTVersion.checked == true then (
			wwold = wallworm_need_update()
		)
		local objCollection
		if chkUseCurrentSelection.checked == true then (
			objCollection = selection as Array
		) else (
			
			if chkXREF.checked then (
				objCollection = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:(chkIgnoreHidden.checked) includeScene:true
			) else (
				objCollection = objects as Array
			)
			
			
		)

		if chkUseCurrentSelection.checked == true AND selection.count == 0 then (
			messageBox "Oops! You checked the option to limit results to the current selection but no objects are selected."
			return false

		) else (
			if chkModelsNotYesExported.checked == true then (
				local wwmt = for obj in objCollection WHERE useThisNode obj == true AND getUserProp obj #wwmt_source_helper == true collect obj

				for mdl in wwmt do (
					local wwmt_modelPath = getUserProp mdl #wwmt_modelPath
					local wwmt_modelname = getUserProp mdl #wwmt_modelname
					if wwmt_modelPath != undefined AND wwmt_modelPath != "" AND wwmt_modelname != undefined AND wwmt_modelname != "" then (
						theMdlPath = ::wwmt_gameInfoDir + "\\models\\" + wwmt_modelPath + "\\" + wwmt_modelname + ".mdl"

						if doesFileExist theMdlPath == false then (
							append unExportedModels mdl

						)

					)
				)

				join theObjs unExportedModels

			)
			local brushNodesToCheck = for obj in objCollection WHERE useThisBrushNode obj == true  collect obj
			local sideCount = 0
			if chkSideLimit.checked then (
				local tmp = 0
				for obj in brushNodesToCheck do (
					tmp += (getPolygonCount obj)[1]
				)
				if tmp > spSideLimit.value then (
					sideCount = tmp
					join theObjs brushNodesToCheck
				)
			)

			local brushCount = 0
			if chkBrushLimit.checked == true then (
				if ::wallwormGetElements == undefined then (
					filein (::wallworm_installation_path)+"/WallWorm.com/common/mse/wallwormHullFuncs.ms"
				)
				local tmp = 0
				for obj in brushNodesToCheck do (
					tmp += (wallwormGetElements obj).count
				)
				if tmp > spBrushLimit.value then (
					brushCount = tmp
					join theObjs brushNodesToCheck
				)

			)
			if chkInvalidObjects.checked == true OR chkNonPlanarFaces.checked == true OR chkEntsOutOfBounds.checked == true OR chkBrushOutOfBounds.checked == true then (
				--collect objects exporting as world geometry

				function isNodeInExportablePos position =
				(
					local minX = ::wallworm_mapsize.x
					local maxY = ::wallworm_mapsize.y

					local minCorner = [minX, minX, minX]
					local maxCorner = [maxY, maxY, maxY]

					minCorner.x < position.x AND maxCorner.x > position.x \
					AND
					minCorner.y < position.y AND maxCorner.y > position.y \
					AND
					minCorner.z < position.z AND maxCorner.z > position.z
				)

				if chkEntsOutOfBounds.checked then (
					if ::wallworm_mapsize == undefined then (
						::wallworm_mapsize = [-16384, 16384]
					)

					local ents = for obj in objCollection WHERE (isProperty obj #entName OR getUserProp obj #wwmt_proxie_source != undefined) collect obj
					join ents (lights as Array)

					in coordsys world (
						outofboundproblems = for obj in ents WHERE NOT isNodeInExportablePos obj.pivot collect obj
					)
					if outofboundproblems.count > 0 then (
						join theObjs outofboundproblems

					)
				)

				function isNodeInExportable node =
				(
					local minX = ::wallworm_mapsize.x
					local maxY = ::wallworm_mapsize.y

					local minCorner = [minX, minX, minX]
					local maxCorner = [maxY, maxY, maxY]

					minCorner.x < node.min.x AND maxCorner.x > node.max.x \
					AND
					minCorner.y < node.min.y AND maxCorner.y > node.max.y \
					AND
					minCorner.z < node.min.z AND maxCorner.z > node.max.z
				)

				if chkBrushOutOfBounds.checked then (
					if ::wallworm_mapsize == undefined then (
						::wallworm_mapsize = [-16384, 16384]
					)

					local ents = for obj in objCollection WHERE superClassOf obj == GeometryClass AND (((isProperty obj #entityType AND obj.entityType == "SolidClass") OR (classOf obj == Corvex AND obj.isWorldGeometry == true) OR (obj.layer.name == "Convexity Walls" OR obj.layer.name == "Convexity Floors") OR (getUserProp obj #wwdt_brush_geometry_export != undefined AND getUserProp obj #wwdt_brush_geometry_export == true))) collect obj

					in coordsys world (
						outofboundproblems2 = for obj in ents WHERE NOT isNodeInExportable obj collect obj
					)
					if outofboundproblems2.count > 0 then (
						join theObjs outofboundproblems2

						join outofboundproblems outofboundproblems2

					)

				)

				

				
				if chkInvalidObjects.checked == true then (
					
					nonConvex = for obj in brushNodesToCheck WHERE wallworm_isConvex obj == false collect obj
					if nonConvex.count > 0 then (
						join theObjs nonConvex
					)

				)

				if chkNonPlanarFaces.checked == true then (
					nonPlanar = for obj in brushNodesToCheck WHERE  superClassOf obj == GeometryClass AND wallworm_hasNonPlanarPolygon obj == true AND isGroupHead obj == false collect obj
					if nonPlanar.count > 0 then (
						join theObjs nonPlanar
					)

				)

			)

		)

		if chkVersions.checked then (
			maxExeVersionArr = wallworm_getMaxVersion()
			local version = maxExeVersionArr[1] as Integer
			local patchversion = maxExeVersionArr[2] as Integer
			--2016
			if version == 18 AND patchversion < 2 then (
				append versionProblems ("Service Pack 2 is now available. Please download the latest service pack for 3ds Max 2016.")
			)
			--2015
			if version == 17 AND patchversion < 3 then (
				append versionProblems ("Service Pack 3 is now available. Please download the latest service pack for 3ds Max 2015.")
			)
			--2014
			if version == 16 AND patchversion < 3 then (
				append versionProblems ("Wall Worm does not work properly on 3ds Max 2014 unless you have Product Update / Service Pack 2 or later installed. Service Pack 5 is now available. Please download the latest service pack for 3ds Max 2014.")
			) else (
				if version == 16 AND patchversion < 5 then (
					append versionProblems ("Service Pack 5 is now available. Please download the latest service pack for 3ds Max 2014.")
				)
			)
			--2013
			if version == 15 AND patchversion < 2 then (
				append versionProblems ("Wall Worm does not work properly on 3ds Max 2013 unless you have Product Update / Service Pack 2 or later installed. Please download the latest service pack for 3ds Max 2013.")
			) else (
				if version == 15 AND patchversion < 6 then (
					append versionProblems ("Service Pack 6 is now available. Please download the latest service pack for 3ds Max 2013.")
				)
			)
			--2012
			if version == 14 AND patchversion < 2 then (
				append versionProblems ("Wall Worm does not work properly on 3ds Max 2012 unless you have Product Update / Service Pack 2 or later installed. Please download the latest service pack for 3ds Max 2012.")
			)

			--Lower THAN 2011
			if version < 13 then (
				append versionProblems ("The Show Walkable function in Wall Worm Anvil only works in 3ds Max 2011+.")
			)

			--Max 9
			if version == 9 AND appendIfUnique == undefined then (
				append versionProblems ("Wall Worm is not officially supported on 3ds Max 9 but users have reported it works if you have the AVguard extension installed. Please download the latest patch for your Max and get AVGuard from ScriptSpot.com.")
			)

			--Lower than Max 9
			if version < 9 then (
				append versionProblems ("Wall Worm cannot work on versions of Max older than 3ds Max 9.")
			)

			if version < 17 AND maxOps.productVersion == #productVersionEdu then (
				append versionProblems ("You are not using the latest version of 3ds Max. Since you have an educational version of Max and can freely get the latest version, you should consider updating to 3ds Max 2015+ since Wall Worm is generally tested on the latest versions more thoroughly.")
			)

		)
		entityProblems = #()

		if chkEntVersions.checked == true then (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
			global wallworm_game_settings
			if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
			) else (
				macros.run "wallworm.com" "wallwormParseFGD2"
			)

			if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
				test = wallworm_game_settings.get_entity_by_name wallworm_game_settings.ents[1].name
				local bb = box()
				custAttributes.add bb test.ca
				if bb.version < ::wallworm_entity_version then (
					append entityProblems ("The FGD is out-dated... you need to re-parse it in the global settings.")
				)
				delete bb
			) else (
				append entityProblems ("The FGD has not been parsed. You may need to re-parse it in the global settings or set a FGD. Until this is done, you cannot use the Wall Worm entity tools.")
			)

			oldEntities = for obj in objects WHERE isProperty obj #entityType AND isProperty obj #wallworm AND obj.version < ::wallworm_entity_version collect obj
			if oldEntities.count > 0 then (
				append entityProblems ("There are entities in the scene with out-dated entity custom attributes. Wall Worm has updated the entity definitions since these entities were created. You should update them by opening the MAXScript listener and pasting this code: wallworm_update_all_entities() and hitting ENTER..")
			)

		)

		if chkSMDMaterial.checked == true then (
			if ::wwmtExporter >= 3 then (
				if ::wwmt_legacy_names == true then (
					append settingsErrors "You are using the Wall Worm SMD Exporter... but you have Legacy Material Names turned on. You *should not* use legacy settings in your global settings"
				)
				if ::wwmt_oldModelVTFPath == true then (
					append settingsErrors "You are using the Wall Worm SMD Exporter... but you have Legacy VTF paths turned on. You *should* turn that off in your global settings."
				)
			) else (
				if ::wwmt_legacy_names == false then (
					append settingsErrors "Your current SMD Exporter does not support the naming convention used in your Material Export settings. You *should* switch to the Wall Worm SMD Exporter *or* turn on Legacy Material Names in your global settings."
				)
				if ::wwmt_oldModelVTFPath == false then (
					append settingsErrors "Your current SMD Exporter does not support the naming convention used in your Material Export settings. You *should switch* to the Wall Worm SMD Exporter *or turn on* Legacy Material Names in your global settings."
				)
			)

			if ::wwmt_makeHullsNonRenderable == true AND ::wwmt_exportNonRenderableMeshAsBone == true then (
				append settingsErrors "You have both Export Non Renderable Mesh as Bone checked as well as the option Processed Hulls become Non Renderable. You should not use these settings together because it can lead to hulls that do not export any geometry."
			)

			if (units.DisplayType == #Generic) == false then (
				append settingsErrors ("For using 3ds Max for Source, you should set the Display Units to Generic. You currently are using " + (units.DisplayType as String) + " units. Click Customize > Units Setup to change this setting.")
			)

			if (units.SystemType == #inches) == false OR units.SystemScale != 1.0 then (
				append settingsErrors ("For using 3ds Max for Source, you should set the System Units to Inches where 1 unit equals one inch. You currently are using a setting where 1 unit equals " + (units.SystemScale as String) + " " + (units.SystemType as String) + ". Click Customize > Units Setup > System Unit Setup to change this setting.")
			)

			if ::wallworm_engine != 1 AND wallworm_binSet "tex" == false then (
				append settingsErrors "The Bin Directory you've set for Wall Worm does not include vtex.exe. Without VTEX, you cannot export textures. Find the correct path for VTEX. Note that sometimes Steam deletes VTEX after a steam update. If this is the case, you may only need to restart Steam and/or re-open Hammer for your mod."
			)

			if wallworm_binSet "model" == false then (
				append settingsErrors "The Bin Directory you've set for Wall Worm does not include studiomdl.exe. Without STUDIOMDL, you cannot export and compile models. Find the correct path for STUDIOMDL. Note that sometimes Steam deletes STUDIOMDL after a steam update. If this is the case, you may only need to restart Steam and/or re-open Hammer for your mod."
			)

		)

		--!TODO Disp Checks
		--A single level is limited to a total of 2032 power 3 displacements. 
		--What about power 2 & 4?
		
		local dispCount = 0
		
		if chkDisplacementLimit.checked  == true then (
			spDisplacementLimit.value
			local disps = for disp in objCollection WHERE isProperty disp #brushNode collect disp
			if disps.count > spDisplacementLimit.value then (
				dispCount = disps.count
				join theObjs disps
			)
		)


		local entCount = 0

		if chkEntityLimiti.checked == true then (
			ents = for obj in objCollection WHERE isProperty obj #EntityType AND isProperty obj #wallworm AND countAgainstEntities obj.entname collect obj
			if (ents.count > spEntLimit.value) then (
				join theObjs ents
				entCount = ents.count
			)
		)

		local overlayCount = 0
		if chkOverlayLimiti.checked == true then (
			local overlays = (for obj in objCollection WHERE isProperty obj #entName AND obj.entName == "info_overlay" collect obj)
			if overlays.count > spOverlayLimit.value then (
				join theObjs overlays
				overlayCount = overlays.count
			)
		)

			

		if theObjs.count > 0 OR versionProblems.count > 0 OR unExportedModels.count > 0 OR settingsErrors.count > 0 OR entityProblems.count > 0 OR wwold == true OR outofboundproblems.count > 0 OR brushCount > 0 OR sideCount > 0 OR dispCount > 0 OR entCount > 0 OR overlayCount > 0 then (
			if chkSelectResults.checked == true then (
				selectLastResults()
			)

			clearListener()
			messageBox "There were errors. Check the MAXScript listener (press F11)."

			if nonConvex.count > 0 then (
				format "\n\n######################\n\nThe following items MAY not be convex.\n\n"
				for obj in nonConvex do (
					format "%\n" obj

				)

			)

			if (overlayCount > 0) then (
				format "\n\n######################\n\nThere are % info_overlay entities in the scene. The limit you are checking against is %\n\n" overlayCount spOverlayLimit.value
			)

			if (entCount > 0) then (
				format "\n\n######################\n\nThere are % entities that will export into the engine. The limit you are checking against is %\n\n" entCount spEntLimit.value
			)
			
			if (dispCount > 0) then (
				format "\n\n######################\n\nThere are % Displacements that will export into the engine. The limit you are checking against is %\n\n" dispCount spDisplacementLimit.value
			)
			if (brushCount > 0) then (
				format "\n\n######################\n\nThere are % Brushes that will export into the engine. The limit you are checking against is %\n\n" brushCount spBrushLimit.value
			)
			if (sideCount > 0) then (
				format "\n\n######################\n\nThere are % Sides that will export into the engine. The limit you are checking against is %\n\n" sideCount spSideLimit.value
			)
			
			if outofboundproblems.count > 0 then (
				format "\n\n######################\n\nThe following items are either out of bounds (entity positions) or have vertices that go out of bounds (brushes).\n\n"
				for obj in outofboundproblems do (
					format "%\n" obj

				)
			)

			if nonPlanar.count > 0 then (
				format "\n\n######################\n\nThe following items have non-planar polygons.\n\n"
				for obj in nonPlanar do (
					format "%\n" obj

				)

			)

			if unExportedModels.count > 0 then (
				format "\n\n######################\n\nThe following models have not been compiled into game yet.\n\n"
				for obj in unExportedModels do (
					if classOf obj == Text then (
						format "% @ %\n" obj.text obj.pos
					)
					format "%\n" obj
				)

			)

			if settingsErrors.count > 0 then (
				format "\n\n######################\n\nThe following warnings were produced for your global  Wall Worm Settings.\n\n"
				for er in settingsErrors do (
					format "* %\n\n" er

				)

			)

			if entityProblems.count > 0 then (
				format "\n\n######################\n\nThe following warnings were produced for your Entities and FGD.\n\n"
				for er in entityProblems do (
					format "* %\n\n" er

				)

			)

			if versionProblems.count > 0 then (
				format "\n\n######################\n\nThe following warnings were produced for your version of 3ds Max.\n\n"
				for er in versionProblems do (
					format "* %\n\n" er

				)

			)

			if wwold == true then (
				format "\n\n######################\n\n***\tWall Worm is out-of-date! You should download the latest version at http://dev.wallworm.com .\n\n"
			)

		) else (
			messageBox "No problems detected."

		)
	)

)