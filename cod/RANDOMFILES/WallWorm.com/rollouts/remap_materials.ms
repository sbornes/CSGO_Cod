rollout wallwormRemapMaterials "Material Utilities" width:408
(
	Group "Scene Materials" (
		ComboBox cmbMaterialNames "Material Names" width:380
		CheckBox chkOnlySelectedObjs "Only List Materials from Selected Objects" checked:true across:2 align:#left tooltip:"When selected, only objects in the current selection are used."
		Button btnUpdateList "Update Material Name List" align:#right tooltip:"Click to update the list of materials. Useful if new materials have been added or the selected objects have changes."
	)

	Group "Node Actions" (
		CheckBox chkUsePattern "Pattern Search" checked:true tooltip:"When on, use pattern matching (and allows wildcard characters like *)." across:2
		CheckBox chkCaseInsensitive "Case Insensitive" checked:true tooltip:"Ignore Case for name checking."
		Button btnSelect "Select Scene Objects" across:3 tooltip:"Select objects that have a material with the name listed above. Only selects objects that are visible."
		Button btnHide "Hide Scene Objects" tooltip:"Hides objects that have a material with the name listed above. Only hides objects that are visible."
		Button btnShow "Show Scene Objects" tooltip:"Shows objects that have a material with the name listed above. Only shows objects that are currently hidden."
	)

	function updateNameList = (
		local materialListIn
		if chkOnlySelectedObjs.checked then (
			materialListIn = for obj in selection WHERE obj.mat != undefined collect obj.mat
		) else (
			materialListIn = for mat in sceneMaterials collect mat
		)

		local materialListOut = #()
		wallworm_get_all_materials &materialListIn &materialListOut
		cmbMaterialNames.items = sort (makeUniqueArray (for obj in materialListOut collect obj.name))

		global wallworm_last_matname
		if wallworm_last_matname != undefined then (
			local index = findItem cmbMaterialNames.items wallworm_last_matname
			if index != 0 then (
				cmbMaterialNames.selection = index
			) else (
				local items = cmbMaterialNames.items
				append items wallworm_last_matname
				cmbMaterialNames.items = items
				cmbMaterialNames.selection = cmbMaterialNames.items.count
			)

		)

	)

	on chkOnlySelectedObjs changed stat do (
		updateNameList()
	)

	function updateLastSel = (
		global wallworm_last_matname
		wallworm_last_matname = cmbMaterialNames.text

	)

	on wallwormRemapMaterials open do (
		if wallworm_material_redirect == undefined then (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)

			fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
		)

		updateNameList()

	)
	on btnUpdateList pressed do (
		updateNameList()
	)

	on cmbMaterialNames selected sel do (
		updateLastSel()
		global wallworm_last_matname = cmbMaterialNames.text
	)

	on btnSelect pressed do (
		global wallworm_last_matname = cmbMaterialNames.text
		objs = wallworm_get_objects_using_material_name cmbMaterialNames.text usePattern:chkUsePattern.checked hideem:false ignoreCase:chkCaseInsensitive.checked
		if objs.count > 0 then (
			select objs
		) else (
			messageBox "No visible objects found with this material."
		)
	)

	on btnHide pressed do (
		global wallworm_last_matname = cmbMaterialNames.text
		objs = wallworm_get_objects_using_material_name cmbMaterialNames.text usePattern:chkUsePattern.checked hideem:false ignoreCase:chkCaseInsensitive.checked
		if objs.count > 0 then (
			hide objs
			forcecompleteredraw()
		) else (
			messageBox "No visible objects found with this material."
		)
	)

	on btnShow pressed do (
		global wallworm_last_matname = cmbMaterialNames.text
		objs = wallworm_get_objects_using_material_name cmbMaterialNames.text usePattern:chkUsePattern.checked hideem:false shown:false ignoreCase:chkCaseInsensitive.checked
		if objs.count > 0 then (
			unhide objs
			forcecompleteredraw()
		) else (
			messageBox "No hidden objects found with this material."
		)
	)

	Group "Change Material Names" (
		CheckBox chkSelected "Limited to Selected Object Materials" checked:true toolTip:"When checked, limits remapping to materials in current object selection."
		CheckBox chkRemapTextures "Rename Textures" toolTip:"When checked, remaps the texture names as well as material." across:3 checked:true
		CheckBox chkBitmaps "Only if Bitmaps" toolTip:"When checked, textures are only updated if they are bitmap textures." checked:true
		CheckBox chkPrepend "Prepend" toolTip:"When checked, the new path is prepended to the current names."

		Label lbl2 "Match Pattern" across:3 align:#left
		Button btnPatternFrom "^" align:#left tooltip:"Set the Match Pattern from currently selected Material Name." offset:[-20, 0]
		EditText edtMatch "" align:#left align:#left offset:[-120, 0] width: 240

		Label lbl3 "Skip Pattern" across:3 align:#left
		Button btnSkipFrom "^" align:#left tooltip:"Set the Skip Pattern from currently selected Material Name." offset:[-20, 0]
		EditText edtSkip "" align:#left offset:[-120, 0] width: 240

		Label lbl1 "New Path" across:3 align:#left
		Button btnPathFrom "^" align:#left tooltip:"Set the New Path from currently selected Material Name." offset:[-20, 0]
		EditText edtNewPath "" align:#left offset:[-120, 0] width: 240

		Button btn1 "Change Material Names (for VMT Output Paths)" width:377 toolTip:"Rename the materials and possibly their bitmaps."
		Button btnHL1 "Change Material Names to Match the Diffuse Texture (for Goldsrc Compat)"
	)

	on chkRemapTextures changed stat do (
		chkBitmaps.enabled = chkRemapTextures.checked
	)

	on btnPatternFrom pressed do (
		if cmbMaterialNames.text != "" then (
			if edtMatch.text != "" then (
				edtMatch.text += ","
			)
			edtMatch.text += cmbMaterialNames.text
		)
	)

	on btnPatternFrom rightClick do (
		edtMatch.text = ""
	)

	on btnSkipFrom pressed do (
		if cmbMaterialNames.text != "" then (
			if edtSkip.text != "" then (
				edtSkip.text += ","
			)
			edtSkip.text += cmbMaterialNames.text
		)
	)

	on btnSkipFrom rightClick do (
		edtSkip.text = ""
	)

	on btnPathFrom pressed do (
		if cmbMaterialNames.text != "" then (
			edtNewPath.text = wallworm_remove_last_slash (wallworm_safe_path (getFileNamePath (cmbMaterialNames.text)))
		)
	)

	on btnPathFrom rightClick do (
		edtNewPath.text = ""
	)

	on btn1 pressed do
	(
		local mats
		if chkSelected.checked == true then (
			mats = for obj in selection WHERE obj.mat != undefined collect obj.mat
		) else (
			mats = for mat in sceneMaterials collect mat
		)

		local materialListOut = #()
		wallworm_get_all_materials &mats &materialListOut
		undo "Remap Material Names" on (
			wallworm_material_redirect materialListOut edtNewPath.text prepend:chkPrepend.checked maps:chkRemapTextures.checked texNameToPath:true texPathOnlyForBitmaps:false skipPattern:edtSkip.text matchP:edtMatch.text useOnlyBitmaps:chkBitmaps.checked
		)

		updateNameList()
	)
	on btnHL1 pressed do (
		local mats
		if chkSelected.checked == true then (
			mats = for obj in selection WHERE obj.mat != undefined collect obj.mat
		) else (
			mats = for mat in sceneMaterials collect mat
		)

		local materialListOut = #()
		wallworm_get_all_materials &mats &materialListOut
		undo "Remap Material Names" on (
			for m in materialListOut do (
				local d = m.diffusemap
				if d != undefined then (
					local texpath = wallworm_texture_path d skipExtension:true
					if texpath != undefined AND texpath != "" then (
						m.name = texpath
					)
				)
			)

		)

		updateNameList()
	)

)
