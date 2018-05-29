macroScript WallWormAnvilInitiateMCR
category:"wallworm.com"
tooltip:"Load Anvil Functions"
buttontext:"Load Anvil Functions"
(
	on execute do (
		macros.run "wallworm.com" "WallWormInitialize"
		if ::wallworm_installation_path != undefined AND doesFileExist ::wallworm_installation_path then (
			
			if (maxVersion())[1] >= 12000 then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WalkableXView.ms")
			)
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.ms")
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.ms")
			fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/displacements.ms")
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
			true
		) else (
			false
		)
	)
)

macroScript WallWormSimpleDisplacementMCR
category:"wallworm.com"
tooltip:"Wall Worm Anvil Level Editor Tools"
buttontext:"Anvil"
(
	function closeAnvil = (
		try(destroyDialog ::wallworm_anvil)catch()
	)
	on isChecked do (
		if ::wallworm_anvil == undefined then (
			false
		) else (
			true
		)
	)
	on closeDialogs do (
		closeAnvil()
	)
	on execute do (
		if ::wallworm_anvil == undefined then (
			if ::wallworm_installation_path == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			local f = ::wallworm_installation_path +"/WallWorm.com/WallWormSimpleDisplacement/anvil.ms"
			if doesFileExist f then (
				fileIn  f
			) else (
				messagebox "Wall Worm Anvil is missing. Reinstall Wall Worm."
			)
		) else (
			closeAnvil()
		)
	)
)

macroscript WallWormCorVexUtilities
category:"wallworm.com"
tooltip:"CorVex Utility Floater"
buttonText:"CorVex Utility Floater"
(
	on execute do (
		global CorVex
		if CorVex == undefined then (
			try (
				crvstring = "crvinitiatetempvar = CorVex()"
				execute crvstring
				delete ::crvinitiatetempvar
				free crvinitiatetempvar
			) catch ()
		)
		if CorVex == undefined then (
			if (querybox "CorVex is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about CorVex?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/66/corvex.html" ""
			)
		) else (
			local crv = createInstance CorVex
			if crv.openCorVexUtilities != undefined then (
				crv.openCorVexUtilities()
			) else (
				messagebox "Your version of CorVex is now out-of-date. Please download the latest version of CorVex."
			)
			crv = undefined
			free crv
		)
	)
)

macroScript WallWormRemoveDisplacementsStartupMCR
category:"wallworm.com"
tooltip:"Remove Displacement Startup Script"
buttontext:"Remove Displacement Startup Script"
(
	on execute do (
		callbacks.removeScripts  id:#wwdt_displacement_topo_handler
		callbacks.removeScripts id:#wwdt_displacement_clone_handler
	)
)

macroScript WallWormBreakNonPlanarMCR
category:"wallworm.com"
tooltip:"Break Non Planar Faces"
buttontext:"Break Non Planar Faces"
(
	on execute  do with undo label:"Break Non Planar Faces" on (
		if selection.count > 0 then (
			objs = for obj in selection WHERE superclassof obj == GeometryClass collect obj
			if objs.count > 0 then (
				addmodifier objs (turn_to_poly requirePlanar:on planarThresh:0.1)
				convertToPoly objs
			)
		)
	)
)

macroScript WallWormDisplacementsCheckMCR
category:"wallworm.com"
tooltip:"Check to remove displacements callback"
buttontext:"Check to remove displacements callback"
(
	on execute do (
		local dispslist = for disp in objects where isProperty disp "ww_displacement" == true OR isProperty disp "wallworm_edit_mesh" == true OR (getUserProp disp "ww_wwdt_displacement_brush" != undefined AND getUserProp disp "ww_wwdt_displacement_brush" != "undefined" ) collect disp 
		if dispslist==undefined OR dispslist.count == 0 then (
			macros.run "wallworm.com" "WallWormRemoveDisplacementsStartupMCR"
			false
		) else (
			true
		)
	)
)

macroScript WallWormDisplacementsQuadrifyMCR
category:"wallworm.com"
tooltip:"Quadrify Displacements"
buttontext:"Quadrify Displacements"
(
	on execute do (
		local dispslist = for disp in objects where isProperty disp "ww_displacement" == true OR isProperty disp "wallworm_edit_mesh" == true collect disp 
		false
		if dispslist.count >0  then (
			oldSel = selection as array
			for disp in dispslist do (
				disp.qaudrifyMe()
			)
			if oldSel.count > 0 then (
				select oldSel
			) else (
				max select none
			)
			true
		)
	)
)

macroScript WallWormDisplacementsTriangulateMCR
category:"wallworm.com"
tooltip:"Triangulate Displacements"
buttontext:"Triangulate Displacements"
(
	on execute do (
		suspendEditing()
		with redraw off (
			local dispslist = for disp in objects where isProperty disp "ww_displacement" == true OR isProperty disp "wallworm_edit_mesh" == true collect disp 
			for disp in dispslist do (
					disp.traingulateMe()
			)
		)
		resumeEditing()
	)
)

macroScript wallwormUpdateBlendsFromDX
category:"wallworm.com"
tooltip:"Update Blend Materials"
buttontext:"Update Blend Materials"
(
	on execute do (
		if ::wallworm_update_blends == undefined then (

			macros.run "wallworm.com" "WallWormInitialize"

		)
		if ::wallworm_update_blends != undefined then (
			local objs
			if selection.count > 0 then (
				objs = selection as array
			) else (
				objs = geometry as array
			)
			wallworm_update_blends objs:objs fixNames:true
		)
	)
)
macroScript wallwormParseFGD2
category:"wallworm.com"
tooltip:"Parse FGD File"
buttontext:"Parse FGD File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/common/mse/parseFGD2.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW FGD Parser 2 is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript wallwormPointEntities
category:"wallworm.com"
tooltip:"Point Entities"
buttontext:"Point Entities"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/rollouts/pointEntities.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Point Entities is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript wallwormBrushEntities
category:"wallworm.com"
tooltip:"Brush Entities"
buttontext:"Brush Entities"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/rollouts/brushEntities.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Point Entities is Missing. Reinstall Wall Worm."
		)
	)
)	
	
macroScript WallWormLoadLeakFileMCR
category:"wallworm.com"
tooltip:"Load Leak File"
buttontext:"Load Leak File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/LoadLineFile.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Line File Loader is Missing. Reinstall Wall Worm."
		)
	)
	
)

macroScript WallWormLoadBSPCompileLogMCR
category:"wallworm.com"
tooltip:"Load BSP Compile Log"
buttontext:"Load BSP Compile Log"
(
	on execute do (
		local thePath = maxFilePath 
		local theFName = getFileNameFile maxFileName
		--see if the root node has a VMF filename associated
		if isProperty rootNode "wallworm_vmf" AND rootNode.wallworm_vmf.filename != undefined AND doesFileExist rootNode.wallworm_vmf.filename then (
			 thePath = getFileNamePath rootNode.wallworm_vmf.filename
			 theFName = getFileNameFile rootNode.wallworm_vmf.filename
		)
		local lastLog = thePath+theFName+".log"
		
		if NOT doesFileExist (lastLog) then (
			if ::wwdt_mapsrc == undefined then (
				macros.run "wallworm.com" "WallWormAnvilInitiateMCR"
			)
			if ::wwdt_mapsrc != undefined AND doesFileExist ::wwdt_mapsrc then (
				lastLog = getOpenFileName filename:(::wwdt_mapsrc+"\\") caption:"Choose Log File" types:"LOG File (*.log)|*.log"  historyCategory:"Wall Worm VMF"
			) else (
				lastLog = getOpenFileName caption:"Choose Log File" types:"LOG File (*.log)|*.log"  historyCategory:"Wall Worm VMF"
			)
		) else (
			lastLog = getOpenFileName filename:(lastLog) caption:"Choose Log File" types:"LOG File (*.log)|*.log"  historyCategory:"Wall Worm VMF"
		)
		if lastLog != undefined then (
			if ::wallworm_text_editor == undefined then (
				::wallworm_text_editor = ""
			)
			local folderOpen ="ShellLaunch \""+::wallworm_text_editor+"\" @\""+lastLog+"\""
			execute folderOpen
		) 
	)
)

macroScript WallWormLoadPRTFileMCR
category:"wallworm.com"
tooltip:"Load PRT File"
buttontext:"Load PRT File"
(
	on execute do (
		if ::wallworm_prt == undefined then (
			if ::wallworm_installation_path == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			local f = ::wallworm_installation_path +"/WallWorm.com/WallWormSimpleDisplacement/prt.ms"
			if doesFileExist f then (
				fileIn  f
			) else (
				messagebox "WW Line File Loader is Missing. Reinstall Wall Worm."
			)			
		)
		if ::wallworm_prt != undefined then (
			local prt = ::wallworm_prt()
			if (prt.parse_visibility()) then (
				prt.construct_leaves()
				prt.creatPortalSpines()
			)
		)
	)
)

macroScript WallWormGetBrushByIDMCR
category:"wallworm.com"
tooltip:"Get Brush By ID"
buttontext:"Get Brush By ID"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/getBrushById.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Brush ID script is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormRemapMaterialsMCR
category:"wallworm.com"
tooltip:"Material Utilities"
buttontext:"Material Utilities"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/RemapMaterials.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Remap Materials Script is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormDisplacementPropertiesMCR
category:"wallworm.com"
tooltip:"Edit Displacement Properties"
buttontext:"Edit Displacement Properties"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/DisplacementTools.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Displacement Tool is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormDisplacementSewMCR
category:"wallworm.com"
tooltip:"Sew Displacements"
buttontext:"Sew Displacements"
(
	on execute do with undo label:"Sew Displacements" on (
		local canRun = ::ww_wwdt_sewSelected != undefined
		if NOT canRun then (
			canRun = macros.run "wallworm.com" "WallWormAnvilInitiateMCR"
		)
		if canRun then (
			::ww_wwdt_sewSelected $selection
		) else (
			messagebox "Sew Displacements is missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormSewSelectedVertsMCR
category:"wallworm.com"
tooltip:"Sew Selected Vertices"
buttontext:"Sew Selected Vertices"
(
	on execute do with undo label:"Sew Vertices" on (
		local canRun = ::wallworm_moveVertsToAveragePosition != undefined
		if NOT canRun then (
			canRun = macros.run "wallworm.com" "WallWormAnvilInitiateMCR"
		)
		if canRun then (
			::wallworm_moveVertsToAveragePosition()
		) else (
			messagebox "The Sew Vertices Script is missing. Reinstall Wall Worm."
		)
	)
)


macroScript WallWormDisplacementSculptMCR
category:"wallworm.com"
tooltip:"Create Sculpt Mesh"
buttontext:"Create Sculpt Mesh"
(
	on execute do (
		local canRun = ::ww_wwdt_editMode != undefined
		if NOT canRun then (
			canRun = macros.run "wallworm.com" "WallWormAnvilInitiateMCR"
		)
		if canRun then (
			local doEditMode = true
			if selection.count < 2 then (
				doEditMode = queryBox "Because there are less than 2 objects selected, ALL displacements will be turned into a Sculpt Mesh. This could take a while if there are many displacements in the scene. Do you want to make a sculpt mesh from ALL displacements?"
			)
			if doEditMode then (
				::wallworm_move_displacement_mode false
				::ww_wwdt_editMode()
			)
		) else (
			messagebox "Sculpt functions are missing. Reinstall Wall Worm."
		)
	)
)


macroScript WallWormDisplacementCreateFromSelectionMCR
category:"wallworm.com"
tooltip:"Create Displacements From Selection"
buttontext:"Create Displacements From Selection"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/CreateDisplacementsFromSelection.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "Create Displacements From Selection Script is missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormDisplacementCreateFromPlanesMCR
category:"wallworm.com"
tooltip:"Convert Planes to Displacements"
buttontext:"Convert Planes to Displacements"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/ConvertPlanesToDisplacements.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "Create Displacements From Selection Script is missing. Reinstall Wall Worm."
		)
	)
)


macroScript WallWormDisplacementPainterMCR
category:"wallworm.com"
tooltip:"Create Displacements By Painting"
buttontext:"Create Displacements By Painting"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/PaintDisplacementsOnFaces.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "Create Displacements By Painting Script is missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormImportVBSPMCR
category:"wallworm.com"
tooltip:"Import Detail VBSP File"
buttontext:"Import VBSP File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/ImportDetailVBSP.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW VBSP Import is Missing. Reinstall Wall Worm."
		)
	)
)


macroScript WallWormImportVMFMCR
category:"wallworm.com"
tooltip:"Import VMF File"
buttontext:"Import VMF or Map File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/VMFImporterUI.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW VMF Import is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormImportDXFMCR
category:"wallworm.com"
tooltip:"Import DXF File"
buttontext:"Import DXF File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/import_dxf.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW DXF Import is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormExportOverviewMCR
category:"wallworm.com"
tooltip:"Export Overview Texture"
buttontext:"Export Overview Texture"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/overview_export.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW Overview Exporter is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormRepairDXRenderMatNamesMCR
category:"wallworm.com"
tooltip:"Repair DX Mat Names"
buttontext:"Repair DX Mat Names"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/repair_dx_matnames.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "Repair DX Mat Names Missing. Reinstall Wall Worm.\n\nIf the file is missing from the latest download, the 3ds Max has an update that fixes the problem."
		)
	)
)

macroScript WallWormExportVMFMCR
category:"wallworm.com"
tooltip:"Export Scene as VMF"
buttontext:"Export Scene as VMF"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/exportSceneAsVMF.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "WW VMF Exporter is Missing. Reinstall Wall Worm."
		)
	)
)

macroScript WallWormCordonManagerMCR
category:"wallworm.com"
tooltip:"Cordon Manager"
buttontext:"Cordon Manager"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path +"/WallWorm.com/WallWormUtilities/cordontools.ms"
		if doesFileExist f then (
			fileIn  f
		) else (
			messagebox "The Cordon Manager is missing. Please reinstall Wall Worm."
		)
	)
)

macroScript WallWormDesignateSelectionAsConcave
category:"wallworm.com"
toolTip:"Set as Concave Brush"
buttonText:"Set as Concave Brush"
(
	on execute do (
		if selection.count > 0 then (
			setUserProp selection "explode_on_export" "true"
			macros.run "wallworm.com" "WallWormDesignateSelectionAsBrushes"
		)
	)
)

macroScript WallWormDesignateSelectionAsConvex
category:"wallworm.com"
toolTip:"Set as Convex Brush"
buttonText:"Set as Convex Brush"
(
	on execute do (
		if selection.count > 0 then (
			setUserProp selection "explode_on_export" "false"
		)
	)
)


macroScript WallWormDesignateSelectionAsBrushes
category:"wallworm.com"
toolTip:"Set Selection as Brush Geometry"
buttonText:"Set Selection as Brush Geometry"
(
	on execute do (
		local errors = false
		for obj in selection where isValidNode obj  and (superClassOf obj == GeometryClass or isGroupHead obj ) and (getUserProp obj "ww_wwdt_displacement_brush") == undefined and (getUserProp obj "wwmt_decal") == undefined AND (getUserProp obj "wwmt_LOD_Gizmo" == undefined)  do (
			if classof obj.baseobject == Corvex OR classof obj.baseobject == ShellVex  OR classof obj.baseobject == PropLine OR classof obj.baseobject == Arch  then (
				obj.isWorldGeometry = true
			) else (
				if superClassOf obj == GeometryClass AND  getUserProp obj "wwmt_proxie_source" == undefined then (
					setUserProp obj "wwdt_brush_geometry_export" "true"
					try (
						if nvpx.IsConvex obj ==false then (
							format "% may not be Convex!!\n" obj.name --**may** because there are often false positives
							errors = true
						)
					) catch ()
				)
			)
		)
		(NOT errors)
	)
)

macroScript WallWormRemoveSelectionFromBrushes
category:"wallworm.com"
toolTip:"Remove Selection from Brush Geometry"
buttonText:"Remove Selection from Brush Geometry"
(
	on execute do (
		for obj in selection where isDeleted obj == false do (
			if classof obj.baseobject == Corvex OR classof obj.baseobject == ShellVex  OR classof obj.baseobject == PropLine OR classof obj.baseobject == Arch then (
				obj.isWorldGeometry = false
			) else (
				setUserProp obj "wwdt_brush_geometry_export" "false"
			)
		)
	)
)

macroScript WallWormVMFExcludeWWMT
category:"wallworm.com"
toolTip:"Exclude Export of Model in VMF"
buttonText:"Exclude Export of Model"
(
	on execute do (
		for obj in selection where isDeleted obj == false and  (isProperty obj #exclude_vmf OR getUserProp obj #wwmt_source_helper != undefined) do (
			if isProperty obj #exclude_vmf then (
				 obj.exclude_vmf = true
			) else (
				 setUserProp obj #wallworm_exclude_vmf "true"
			)
		)
	)
)

macroScript WallWormVMFIncludeWWMT
category:"wallworm.com"
toolTip:"Include Export of Model in VMF"
buttonText:"Include Export of Model"
(
	on execute do (
		for obj in selection where isDeleted obj == false and  (isProperty obj #exclude_vmf OR getUserProp obj #wwmt_source_helper != undefined) do (
			 if isProperty obj #exclude_vmf then (
				 obj.exclude_vmf = false
			) else (
				 setUserProp obj #wallworm_exclude_vmf "false"
			)
		)
	)
)

macroScript WallWormDesignateSelectionAsSky
category:"wallworm.com"
toolTip:"Set Selection as Skybox Item"
buttonText:"Set Selection as Skybox Item"
(
	on execute do (
		for obj in selection  do (
			case of (
				(hasProperty obj #inSky):(
				  obj.inSky = true
				)
				(isProperty obj #skybox):(
					 obj.skybox = true
				)
				default: (
					 setUserProp obj #wwdt_skybox_export "true"
				)
			)
		)
	)
)

macroScript WallWormRemoveSelectionFromSky
category:"wallworm.com"
toolTip:"Remove Selection from Skybox Items."
buttonText:"Remove Selection from Skybox Items"
(
	on execute do (
		for obj in selection  do (
			case of (
				(hasProperty obj #inSky):(
				  obj.inSky = false
				)
				(isProperty obj #skybox):(
					 obj.skybox = false
				)
				default: (
					 setUserProp obj #wwdt_skybox_export "false"
				)
			)
		)
	)
)

macroScript WallWormSelectSkyObjects
category:"wallworm.com"
toolTip:"Select Skybox Items."
buttonText:"Select Skybox Items"
(
	on execute do (
		if selection.count > 0 then (
			select (for obj in selection WHERE (getUserProp obj #wwdt_skybox_export) == true OR ((hasProperty obj #insky) AND obj.insky == true) collect obj)
		) else (
			select (for obj in objects WHERE (getUserProp obj #wwdt_skybox_export) == true OR ((hasProperty obj #insky) AND obj.insky == true) collect obj)
		)
	)
)




macroScript WallWormDesignateSelectionAsFuncDetail
category:"wallworm.com"
toolTip:"Set Selection as Func Detail"
buttonText:"Set Selection as Func Detail Item"
(
	on execute do (
		macros.run "wallworm.com" "WallWormDesignateSelectionAsBrushes"
		for obj in selection do (
			if hasProperty obj #funcDetail then (
				obj.funcDetail = true
			) else (
				setUserProp obj #wwdt_func_detail "true"
			)
			setUserProp obj #GLBEntData "func_detail"
			setUserProp obj #GLBEntValu ","
		)
	)
)

macroScript WallWormDesignateSelectionAsFuncDetailGroup
category:"wallworm.com"
toolTip:"Set Selection as Grouped Func Detail"
buttonText:"Set Selection as Grouped Func Detail"
(
	on execute do (
		if selection.count > 1 then (
			local selnodes = selection as array
			macros.run "wallworm.com" "WallWormDesignateSelectionAsFuncDetail"
			newgroup = group selnodes name:(uniqueName "WW Func Detail")  select:true
			for obj in newgroup do ( 
				if (isGroupHead obj == true) then (
					setUserProp obj #wwdt_func_detail "true"
					setUserProp obj #GLBEntData "func_detail"
					setUserProp obj #GLBEntValu ","
				) 
			)
			selnodes = undefined
			select newgroup
		)
		macros.run "wallworm.com" "WallWormDesignateSelectionAsFuncDetail"
	)
)

macroScript WallWormRemoveSelectionFromFuncDetail
category:"wallworm.com"
toolTip:"Remove Selection from Func Detail Items."
buttonText:"Remove Selection from Func Detail Items"
(
	on execute do (
		for obj in selection where isDeleted obj == false do (
			if hasProperty obj #funcDetail then (
				obj.funcDetail = false
			) else (
				setUserProp obj #wwdt_func_detail "false"
			)
			setUserProp obj #GLBEntData ""
			setUserProp obj #GLBEntValu ""
		)
	)
)

Macroscript wallwormHideAllBrushes
category:"wallworm.com"
tooltip:"Hide All Displacement Brushes"
buttontext:"Hide All Displacement Brushes"
(
	on execute do (
		brushes = for obj in objects WHERE obj.isHidden == false AND (((isProperty obj #ww_displacement_brush == true OR getUserProp obj #ww_wwdt_displacement_target != undefined)) OR ((classof obj == Corvex OR classof obj == ShellVex) AND obj.isWorldGeometry == true)) collect obj
		hide brushes	
	)
)

Macroscript wallwormSelectAllBrushes
category:"wallworm.com"
tooltip:"Select Brushes"
buttontext:"Select Brushes"
(
	on execute do (
		if selection.count > 0 then (
			select (for obj in selection where  ((getUserProp obj #wwdt_brush_geometry_export) == true) OR ((classof obj == Corvex OR classof obj == ShellVex) AND obj.isWorldGeometry == true) collect obj)
		) else (
			select (for obj in objects where  ((getUserProp obj #wwdt_brush_geometry_export) == true) OR  ((classof obj == Corvex OR classof obj == ShellVex) AND obj.isWorldGeometry == true) collect obj)
		)
	)
)



Macroscript wallwormSelectAllDetails
category:"wallworm.com"
tooltip:"Select Func Details"
buttontext:"Select Func Details"
(
	on execute do (
		if selection.count > 0 then (
			select (for obj in selection where ((hasProperty obj #funcDetail AND obj.funcDetail == true) OR (((getUserProp obj #wwdt_func_detail) == true))) AND  (( (getUserProp obj #wwdt_brush_geometry_export) == true) OR ((classof obj == Corvex OR classof obj == ShellVex) AND obj.isWorldGeometry == true)) collect obj)
		) else (
			select (for obj in objects where ((hasProperty obj #funcDetail AND obj.funcDetail == true) OR (((getUserProp obj #wwdt_func_detail) == true))) AND  ( ( (getUserProp obj #wwdt_brush_geometry_export) == true) OR  ((classof obj == Corvex OR classof obj == ShellVex) AND obj.isWorldGeometry == true)) collect obj)
		)
	)
)


Macroscript wallwormbrushmodetoggle
category:"wallworm.com"
tooltip:"Wall Worm Brush Mode"
buttontext:"Brush Mode"
/*autoUndoEnabled:false*/
(
	::wallworm_brush_mode_create = function wallworm_brush_mode_create = (
		if ::wallwormbrusmodestate != undefined AND ::wallwormbrusmodestate then (
			obj = callbacks.notificationParam()
			if isValidNode obj  and (superClassOf obj == GeometryClass or isGroupHead obj == true  ) and  (getUserProp obj #wwmt_decal) == undefined AND (getUserProp obj #wwmt_proxie_source == undefined) AND getUserProp obj #ww_wwdt_displacement_target==undefined AND isProperty obj #wallworm_edit_mesh == false AND isProperty obj #ww_displacement_target == false AND (isProperty obj #entityType == false  OR obj.entityType != "PointClass")  AND (getUserProp obj #wwmt_LOD_Gizmo == undefined)   then (

				if (classof obj.baseObject == Corvex OR classof obj.baseObject == ShellVex  OR classof obj.baseObject == Arch ) then (
					obj.isWorldGeometry = true
				) else (
					local theClass = classof obj
					if findItem (#(Plane,Torus,Tube,Teapot,L_Ext,Torus_Knot,C_Ext,RingWave,Hose)) theClass == 0  then (
						setUserProp obj #wwdt_brush_geometry_export "true"
					)
				)
				local mat 	
				if obj.mat == undefined then (
					if sme != undefined  then (
							mat = sme.GetMtlInParamEditor() 
					) 
					if mat == undefined then (
							
						mat = medit.GetCurMtl()		
					)
					if mat != undefined AND superClassOf mat == Material then (
						obj.mat = mat	
					)
				)
			)	
		)
	)
	
	::wallworm_brush_mode_create_spline = function wallworm_brush_mode_create_spline = (
		obj = callbacks.notificationParam()
		if isValidNode obj and superClassOf obj == Shape  then (
			addModifier obj (Extrude())
		)
	)

	::wallworm_removeBrushMode = function wallworm_removeBrushMode = (
		callbacks.removeScripts id:#wallwormbrushmode
		::wallwormbrusmodestate = false	
	)
	
	on isChecked return ::wallwormbrusmodestate --check or uncheck the Macro button
	on closeDialogs do (
		::wallworm_removeBrushMode()
	)
	
	on execute do (
		if ::wallwormbrusmodestate == undefined then (
			::wallwormbrusmodestate = false	
		)
		
		if ::wallwormbrusmodestate == false then (
			callbacks.addScript #nodeCreated "::wallworm_brush_mode_create()" id:#wallwormbrushmode persistent:false
			callbacks.addScript #nodeCloned "::wallworm_brush_mode_create()" id:#wallwormbrushmode persistent:false
			--callbacks.addScript #sceneNodeAdded "wallworm_brush_mode_create_spline()" id:#wallwormbrushmode persistent:false
			callbacks.addScript #filePreSave "::wallworm_removeBrushMode()" id:#wallwormbrushmode persistent:false
			::wallwormbrusmodestate = true
		) else (
			::wallworm_removeBrushMode()
		)
	)
)

macroscript WallWormCarver
category:"wallworm.com"
tooltip:"Wall Worm Carver"
buttonText:"Wall Worm Carver"
(
	on execute do (
		if ::wallworm_carver == undefined then (
			if (querybox "Carver is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about Carver?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/67/carver.html" ""
			)
		) else (
			local crv = ::wallworm_carver()
			crv.displayRollout()
			crv.helperRollout.crvStruct = crv
			crv.displayRollout()
		)
	)
)

macroscript WallWormTerrainFromSelection
category:"wallworm.com"
tooltip:"Create Terrain From Selection"
buttonText:"ShellVex: Create Terrain"
(
	on execute do (
		if ::ShellVex == undefined then (
			if (querybox "ShellVex is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about ShellVex?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/76/shellvex.html" ""
			)
		) else (
			if Selection.count == 0 then (
				messagebox "No objects selected... Select objects first."
			) else (
				local t = ShellVex()
				t.direction = 1
				t.method = #local
				t.sourceNodes = for obj in selection WHERE superclassof obj == GeometryClass collect obj
				select t
			)
		)
	)
)

macroscript WallWormCorridorFromSelection
category:"wallworm.com"
tooltip:"Create Corridor From Selection"
buttonText:"ShellVex: Create Corridor"
(
	on execute do (
		if ::ShellVex == undefined then (
			if (querybox "ShellVex is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about ShellVex?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/76/shellvex.html" ""
			)
		) else (
			if Selection.count == 0 then (
				messagebox "No objects selected... Select objects first."
			) else (
				local t = ShellVex()
				t.direction = 2
				t.method = #local
				t.sourceNodes = for obj in selection WHERE superclassof obj == GeometryClass collect obj
				select t
			)
		)
	)
)
macroscript WallWormPropLineNodesFromSelection
category:"wallworm.com"
tooltip:"Create PropLine with Selection"
buttonText:"Create PropLine with Selection"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			
			if Selection.count == 0 then (
				messagebox "No objects selected... Select objects first."
			) else (
				local t = PropLine()
				t.position = selection.center
				if t.distributionMethod as name == #divide then (
					t.spacing = 3
				)
				local sel = (selection as array)
				local splinesToAdd = for obj in sel WHERE superclassof obj.baseobject == Shape collect obj
				for obj in splinesToAdd do (
					if (NOT refs.dependencyLoopTest t obj) then (
						append t.splineBases obj
					)
				)
				local nodesToAdd = for obj in sel WHERE superclassof obj == GeometryClass AND findItem t.splineBases obj == 0  collect obj
				for obj in nodesToAdd do (
					if (NOT refs.dependencyLoopTest t obj) then (
						append t.sourceNodes obj
					)
				)
				select t
			)
		)
	)
)

macroscript WallWormPropLineDeactivateAll
category:"wallworm.com"
tooltip:"Deactivate All PropLine Nodes"
buttonText:"Deactivate All PropLine Nodes"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			for obj in objects where classof obj == PropLine do obj.active = false
			forceCompleteRedraw()
		)
	)
)

macroscript WallWormPropLineActivateAll
category:"wallworm.com"
tooltip:"Activate All PropLine Nodes"
buttonText:"Activate All PropLine Nodes"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			for obj in objects where classof obj == PropLine do obj.active = true
			forceCompleteRedraw()
		)
	)
)

macroscript WallWormPropLineCacheAll
category:"wallworm.com"
tooltip:"Cache All PropLine Nodes"
buttonText:"Cache All PropLine Nodes"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			for obj in objects where classof obj == PropLine do obj.autoupdate = false
			forceCompleteRedraw()
		)
	)
)

macroscript WallWormPropLineCacheClearAll
category:"wallworm.com"
tooltip:"Clear All PropLine Cache"
buttonText:"Clear All PropLine Cache"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			with redraw off (
				for obj in objects where classof obj == PropLine do obj.clearCache()
			)
			forceCompleteRedraw()
		)
	)
)




macroscript WallWormPropLineBakeAll
category:"wallworm.com"
tooltip:"Bake All PropLine"
buttonText:"Bake All PropLine"
(
	on execute do (
		if ::PropLine == undefined then (
			if (querybox "PropLine is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about PropLine?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/78/propline.html" ""
			)
		) else (
			local newNodes = #()
			for obj in objects where classof obj == PropLine do (
				if obj.active AND obj.sourceNodes.count > 0 AND obj.splineBases.count > 0 AND NOT obj.displayAsBoxes then (
					local newNode = obj.bakeMe()
					if isValidNode newNode then (
						append newNodes newNode
					)
				)
			)
			if newNodes.count > 0 then (
				forceCompleteRedraw()
				select newNodes
			)
		)
	)
)

macroscript WallWormSpacingUp
category:"wallworm.com"
tooltip:"Increase Grid Spacing"
buttonText:"Increase Grid Spacing"
(
	on execute do (
		if activeGrid == undefined then (
			local currentSpacing = getGridSpacing()
			if currentSpacing >= 1 then (
				SetGridSpacing ((currentSpacing * 2.0) as Integer)
			) else (
				SetGridSpacing 1
			)
		) else (
			if activeGrid.grid >= 1 then (
				activeGrid.grid = activeGrid.grid * 2.0
			) else (
				activeGrid.grid = 1
			)
		)
		snapMode.active = true
	)
)

macroscript WallWormSpacingDown
category:"wallworm.com"
tooltip:"Decrease Grid Spacing"
buttonText:"Decrease Grid Spacing"
(
	on execute do (
		if activeGrid == undefined then (
			local currentSpacing = getGridSpacing()
			if currentSpacing > 1 then (
				SetGridSpacing ((currentSpacing / 2.0) as Integer)
			)
		) else (
			if activeGrid.grid > 1 then (
				activeGrid.grid = activeGrid.grid / 2.0
			)
		)
		snapMode.active = true
	)
)

macroScript VertsOFFGridxViewMCR
buttonText:"Verts off Grid xView"
category:"wallworm.com"
tooltip:"Verts off Grid xView"
(
	on isChecked return
	xViewChecker.getCheckerName xViewChecker.activeIndex == "Verts Off Grid" AND xViewChecker.on == true
	on execute do (
		if (xViewChecker.getCheckerName xViewChecker.activeIndex == "Verts Off Grid" AND xViewChecker.on == true) then (
			xViewChecker.on = false
		)
		else
		(
			local theIndex = 0
			for i = 1 to xViewChecker.getNumCheckers() do
			if xViewChecker.getCheckerName i == "Verts Off Grid" do theIndex = i
			if theIndex > 0 then (
				xViewChecker.setActiveCheckerID (xViewChecker.getCheckerID theIndex)
				xViewChecker.on = true
			)
		)		
	)
)

/*
	MacroScripts for WW displaying information about vertices.

*/
macroScript WallWormDisplaySelectedVertsOffGrid
buttonText:"Selected Verts Off Grid"
category:"wallworm.com"
tooltip:"Selected Verts Off Grid"
(
	on execute do (
		if ::wallworm_gcd == undefined then (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)
			local f = ::wallworm_installation_path + "/WallWorm.com/common/geometryinfofuncs.ms"
			if doesFileExist f then (
				filein f
			)
		)
		unregisterRedrawViewsCallback ::GW_displaySelectedVertsOffGrid
		if ::wallworm_gcd != undefined then (
			if ::GW_displaySelectedVertsOffGrid  == undefined then (
				::GW_displaySelectedVertsOffGrid = fn GW_displaySelectedVertsOffGrid =
				(
				  gw.setTransform (matrix3 1)
				  local gv = meshop.getVert
				  for theNode in selection where not theNode.isHiddenInVpt do
					case (superClassOf theNode) of (
						GeometryClass:(
							local m = theNode.Mesh
							for vi = 1 to m.numverts do
							(
								in coordsys world v = gv m vi node:theNode
								if (mod v.x 1.0 != 0.0) OR (mod v.y 1.0 != 0.0) OR (mod v.z 1.0 != 0.0) then (
									gw.text v (vi as string + ": "+v as string) color:yellow
								)
							)					
						)
						Shape:(
							
							--skip those with modifiers to avoid maxscript errors
							local k1 = 0 --vertex index in the system
							local isSpline = (classOf theNode == Line OR classOf theNode == SplineShape) --if true then can use actual knots; if not, must use pathinterp()
							local percent -- value for interpolation increments
							local s -- number of subsplines

							
							if isSpline OR theNode.modifiers.count == 0 then (	
								if NOT isSpline then (
									s = 1					
								) else (
									try (
										s = numSplines theNode
									) catch (
										s = 1
										isSpline = false
									)
								)								
								
								for si = 1 to s do (
									local lastPoint --store the last point to measure distance and rise/run
									local kCount --number of knots in this subspline
									if isSpline then (
										kCount = numKnots theNode si
									) else (
										kCount = numKnots theNode
									)
									local closedSpline = false
									if (NOT isSpline AND (pathInterp theNode s 0.0) == (pathInterp theNode s 1.0)) OR (isSpline AND isClosed theNode s) then (
										closedSpline = true
									)
									local firstPoint --store the first point in case the spline is closed
									if NOT isSpline then (
										--determine the percent values and vertex count based on the shape's steps
										if NOT isProperty theNode #steps then (
											case (classOf theNode) of (
												Helix:steps = 41
												Helix_Pro:steps = theNode.sides
												default:steps = 0
											)
										) else (
											if (NOT isSpline AND (pathInterp theNode s 0.0) == (pathInterp theNode s 1.0)) then (
												steps = (theNode.steps + 1) * kCount
											) else (
												steps = ((theNode.steps + 1) * (kCount - 1))
											)
										)
										kCount *= (steps + 1)
										percent = 1.0 / (steps as float)							
									)
									local amount = 0.0
									for k = 1 to kCount WHILE amount < 1.0 do (
										k1 += 1
										local v
										if isSpline then (
											v = in coordsys world (getKnotPoint theNode si k) 
										) else (
											amount = (k * percent) - percent
											if amount > 1.0 then amount = 1.0
											v = in coordsys world (pathInterp theNode s amount)
										)
										if k > 1 then (
											local ror = v - lastPoint
											local gcd = wallworm_gcd (ror.x as integer) (ror.y as integer)
											gw.text ((v + lastPoint) / 2) (((k1 - 1) as string)+"-"+ k1 as string + " ( "+(distance v lastPoint) as string+" ) : "+((ror.x/gcd) as integer) as string+ "/"+((ror.y/gcd) as integer) as string) color:orange
											
										) else (
											firstPoint = v
										)
										if mod v.x 1.0 != 0.0 OR mod v.y 1.0 != 0.0 OR mod v.z 1.0 != 0.0 then (
											gw.text v (k1 as string + ": "+v as string) color:yellow
										)
										local lastPoint = v
									)
									if closedSpline then (
										--if the spline is closed, add the distance and rise/run of last segment
										local ror =  lastPoint - firstPoint
										local gcd = wallworm_gcd (ror.x as integer) (ror.y as integer)
										gw.text ((firstPoint + lastPoint) / 2) ((k1 as string)+"-1 ("+(distance firstPoint lastPoint) as string+") : "+((ror.x/gcd) as integer) as string+ "/"+((ror.y/gcd) as integer) as string) color:orange
									)
								)								
							)
						)
						default:()
					)
				  gw.enlargeUpdateRect #whole  
				)	
				registerRedrawViewsCallback ::GW_displaySelectedVertsOffGrid
			) else (
				::GW_displaySelectedVertsOffGrid = undefined
			)			
		)
	)
)

macroScript WallWormDisplayInterpolationOffGrid
buttonText:"Interpolation Info"
category:"wallworm.com"
tooltip:"Interpolation Info"
(
	on execute do (
		if ::wallworm_gcd == undefined then (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)
			local f = ::wallworm_installation_path + "/WallWorm.com/common/geometryinfofuncs.ms"
			if doesFileExist f then (
				filein f
			)
		)
		if ::wallworm_gcd != undefined then (
			unregisterRedrawViewsCallback ::GW_displaySelectedInterpolationOffGrid
			if ::GW_displaySelectedInterpolationOffGrid  == undefined then (
				::GW_displaySelectedInterpolationOffGrid = fn GW_displaySelectedInterpolationOffGrid = (
					gw.setTransform (matrix3 1)
					local gv = meshop.getVert
					for spline in selection where not spline.isHiddenInVpt AND (superClassOf spline) == Shape do (
						local k1 = 0
						local isSpline = (classOf spline == Line OR (classOf spline == SplineShape))

						if isSpline OR spline.modifiers.count == 0 then (
							local sps
							if isSpline then (
								try (
									sps = numSplines spline
								) catch (
									sps = 1
									isSpline = false
								)
							) else (
								sps = 1
							)
							for s = 1 to sps do (
								if isSpline then (
									nk = numKnots spline s
								) else (
									nk = numKnots spline
								)
								k1 += 1
								local v1
								in coordsys world v1 = (pathInterp spline s 0.0)
								local lastPoint = v1
								if mod v1.x 1.0 != 0.0 OR mod v1.y 1.0 != 0.0 then (
									gw.text v1 (k1 as string + ": ["+v1.x as string+","+v1.y as string+"]") color:yellow
								)
								if NOT isProperty spline #steps then (
									case (classOf spline) of (
										Helix:steps = 41
										Helix_Pro:steps = spline.sides
										default:steps = 0
									)
								) else (
									if (NOT isSpline AND (pathInterp spline s 0.0) == (pathInterp spline s 1.0)) OR (isSpline AND isClosed spline s) then (
										local steps = (spline.steps + 1) * nk
									) else (
										local steps = ((spline.steps + 1) * (nk - 1))
									)
								)
								local percent = 1.0 / steps
								local newPercent = copy percent
								for i = 1 to (steps as Integer) do (
									if newPercent > 1.0 OR i == steps then (
										newPercent = 1.0
									)
									local v
									k1 += 1
									in coordsys world v = (pathInterp spline s newPercent)
									local ror = v - lastPoint
									local gcd = wallworm_gcd (ror.x as integer) (ror.y as integer)
									gw.text ((v + lastPoint) / 2) (k1 as string + ": "+((ror.x/gcd) as integer) as string+ "/"+((ror.y/gcd) as integer) as string) color:orange
									if mod v.x 1.0 != 0.0 OR mod v.y 1.0 != 0.0  then (
										gw.text v (k1 as string + ": ["+v.x as string+","+v.y as string+"]") color:yellow
									)
									lastPoint = v
									newPercent += percent
								)
							)
						)
					)
					gw.enlargeUpdateRect #whole  
				)
				registerRedrawViewsCallback ::GW_displaySelectedInterpolationOffGrid				
			) else (
				::GW_displaySelectedInterpolationOffGrid = undefined
			)
		)
	)
)