rollout anvil_displacements_settings "Displacement Flags" width:391 height:48
(
	CheckBox chkNoPhys "No Phys" pos:[7, 15] width:65 height:15 toolTip:"Disables any physics objects colliding with the displacement."
	CheckBox chkNoHull "No Hull Collision" pos:[82, 14] width:101 height:19 toolTip:"Disables any player or NPC collisions with the displacement."
	CheckBox chkNoRay "No Ray Collision" pos:[185, 14] width:101 height:17 toolTip:"Disables raycasts colliding with the displacement. Gunfire and bullets will not collide with the displacement surface."
	Button btnSetDisplacementFlags "Set Flags" pos:[318, 13] width:68 height:17 toolTip:"Set the Displacement Flags on the selected displacements."
	Button btn30 "Get" pos:[289, 13] width:26 height:17 toolTip:"Prefill the settings from those already stored in the selected displacement."

	Group "Update Displacements From Source Brushes" (
		CheckBox chkUV "UV" checked:true across:5 tooltip:"Get UVW from original brush side."
		CheckBox chkMat "Mat" checked:true tooltip:"Get the material from the Source Node Material." offset:[-20,0]
		CheckBox chkUpdateBrush "Side Topology" checked:true tooltip:"Reset Brush Node to the original side shape." offset:[-40,0]
		CheckBox chkUpdateDisp "Reset" checked:true tooltip:"Update the displacement node to the original side shape." offset:[-10,0]
		Button btnGetSourceInfo "Update From Source" tooltip:"Update any selected displacements that were generated from the face of an object, re-acquire the original UVs and/or material."  offset:[-10,0]
	)
	on btnGetSourceInfo pressed do (
		if chkUV.checked OR chkMat.checked OR chkUpdateBrush.checked OR chkUpdateDisp.checked then (		
			if ::wallworm_update_displacement_from_source == undefined then (
				try (macros.run "wallworm.com" "WallWormAnvilInitiateMCR") catch (
					messagebox "This function requires Wall Worm to be installed."
				)
			)
			if ::wallworm_update_displacement_from_source != undefined then (
				for obj in selection as array WHERE isProperty obj #ww_displacement == true AND  isValidNode obj.brushNode do (
					if isValidNode obj.brushNode.sourceNode then (
						local res = ::wallworm_update_displacement_from_source obj getUV:chkUV.checked getMat:chkMat.checked brushTopo:chkUpdateBrush.checked dispTopo:chkUpdateDisp.checked
						if res == 0 then (
							--messageBox "This displacement was not created from an object or that object has been deleted. "
						)				
					)
				) 			
			)
		) else (
			messageBox "You must check at least one option."
		)			
	)
	
	function setFlagsFromSelection = (
		local flags = 0
		if selection.count == 1 then (
			if isProperty $ #dispflags AND isProperty $ #wallworm then (
				flags = $.dispflags
			) else (
				local brush = ww_wwdt_getBrushFromDisp $
				if brush != undefined then (
					local flags = ww_wwdt_getDispFlags brush
				)
			)
			if flags != undefined AND flags != 0 then (
				if bit.and flags 2 == 2 then (
					chkNoPhys.checked = true
				) else (
					chkNoPhys.checked = false
				)
				if bit.and flags 4 == 4 then (
					chkNoHull.checked = true
				) else (
					chkNoHull.checked = false
				)
				if bit.and flags 8 == 8 then (
					chkNoRay.checked = true
				) else (
					chkNoRay.checked = false
				)
			)
		)
	)
	on anvil_displacements_settings open do
	(
		setFlagsFromSelection()
	)
	on btnSetDisplacementFlags pressed do
	(
		if selection.count > 0 then (
			for obj in selection WHERE isProperty obj #ww_displacement AND isProperty obj #dispflags AND isProperty obj #wallworm do (
				ww_wwdt_setDispFlags obj noPhys:chkNoPhys.checked noHull:chkNoHull.checked noRay:chkNoRay.checked
			)
			for obj in selection WHERE isProperty obj #wallworm_edit_mesh AND isProperty obj #wallworm do (
				for d in obj.displist do (
					ww_wwdt_setDispFlags d noPhys:chkNoPhys.checked noHull:chkNoHull.checked noRay:chkNoRay.checked
				)
			)
			local brushes = ww_wwdt_getBrushesFromDisplacements selection
			if brushes.count > 0 then (
				ww_wwdt_setDispFlagsArray brushes noPhys:chkNoPhys.checked noHull:chkNoHull.checked noRay:chkNoRay.checked
			)
		) else (
			messageBox "You must select displacements to set this property."
		)
	)
	on btn30 pressed do
	(
		if selection.count == 1 AND (getUserProp $ "ww_wwdt_displacement_brush" != undefined) then (
			setFlagsFromSelection()
		) else (
			messageBox "This function only works when you have a single Displacement selected."
		)
	)
)