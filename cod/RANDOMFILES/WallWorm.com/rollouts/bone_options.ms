rollout wwmt_bone_options "Bone Options" width:237 height:657
(
	local startSurf = undefined
	local startBias = undefined
	local animatedfriction = undefined
	local startjointskip = undefined
	local currentBone = undefined

	local wwmt_jointmassbias = undefined
	local wwmt_surfaceprop_bone = undefined
	local wwmt_animatedfriction = undefined
	local wwmt_jointskip = undefined

	local hitboxHelper = undefined
	local hboxsets = #("default")
	function wallworm_remove_zero_bones sk = (
		local numBones = skinOps.GetNumberBones sk

		local numVerts = skinOps.GetNumberVertices sk

		local getBID = skinOps.GetVertexWeightBoneID

		for b = 1 to numBones do (
			local hasWeight = false
			for i = 1 to numVerts while hasWeight == false do (
				if getBID sk i b > 0 then (
					hasWeight = true
				)
			)
			if NOT hasWeight then (
				skinOps.removebone sk b
			)

		)

	)
	ComboBox cbxBoneSurfaceProp "Bone Surface Properties" pos:[17, 60] width:203 height:7
	Spinner spn_mass_bias "Mass Bias" pos:[25, 196] width:114 height:16 range:[0, 100, 1] type:#float
	Button btnGetBoneInfo "Get From Selected Bone" pos:[17, 37] width:203 height:17 toolTip:"Get the surface property and mass bias of the selected bone."
	Button btnSetBoneInfo "Set All Values on Selection" pos:[15, 252] width:139 height:32 toolTip:"Set both the surfaceproperty and the mass bias in all selected bones to the values above."
	Button btnSetBias "Set" pos:[143, 197] width:37 height:16 toolTip:"Set the Mass Bias of the selected bones to that value of the Mass Bias Spinner."
	Button btnUnsetBias "Unset" pos:[183, 197] width:36 height:16 toolTip:"Remove mass bias from selected nodes."
	Button btnSetSurf "Set" pos:[147, 61] width:31 height:13 toolTip:"Set the surfaceprop for the selected bones."
	Button btnUnsetSurf "Unset" pos:[185, 61] width:34 height:13 toolTip:"Unset the surfaceprop for the selected bones."
	Hyperlink bonehelp "Help" pos:[200, 635] width:36 height:15 address:"http://dev.wallworm.com/document/120/hitboxes_and_bone_properties.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	/*label lbl1 "$animatedfriction" pos:[16,228] width:91 height:19
	edittext edt_animatedfriction "" pos:[11,246] width:134 height:22
	button btn_animatedfriction "Set" pos:[148,246] width:33 height:21
	button btn_unset_animatedfriction "Unset" pos:[183,246] width:35 height:21*/
	CheckBox chk_jointskip "$jointskip" pos:[15, 226] width:69 height:18
	Button btnSetSkip "Set" pos:[90, 226] width:39 height:15
	Button btn_jointskip_off "Unset" pos:[138, 226] width:38 height:15

	function setInitialValues forceReset:false = (
		if startSurf == undefined OR forceReset == true then (
			startSurf = wwmt_surfaceprop_bone
		)
		if startBias == undefined OR forceReset == true then (
			startBias = wwmt_jointmassbias
		)
		/*	if animatedfriction == undefined OR forceReset==true then (
			animatedfriction = wwmt_animatedfriction
		)	*/
		if startjointskip == undefined OR forceReset == true then (
			startjointskip = wwmt_jointskip
		)

	)

	function setUiFromBoneInfo = (
		if selection.count == 1 then (
			local binfo = wwmt_getBoneInfo selection[1]
			wwmt_surfaceprop_bone = binfo[2]
			wwmt_jointmassbias = binfo[1]
			--wwmt_animatedfriction = binfo[3]
			wwmt_jointskip = binfo[3]
			if currentBone != selection[1] then (
				currentBone = selection[1]
				setInitialValues()
			)
		)

		if wwmt_surfaceprop_bone != undefined then (
			if findItem cbxBoneSurfaceProp.items wwmt_surfaceprop_bone == 0 then (
				local newlist = cbxBoneSurfaceProp.items
				append newlist wwmt_surfaceprop_bone
				try (
					cbxBoneSurfaceProp.items = newlist
				) catch (
					cbxBoneSurfaceProp.items = ::wwmt_surfaceprop_list
				)
			)

			try (
				cbxBoneSurfaceProp.selection = findItem cbxBoneSurfaceProp.items (wwmt_surfaceprop_bone as String)
			) catch ()

		)

		if wwmt_jointmassbias != undefined then (
			spn_mass_bias.value = (wwmt_jointmassbias as Float)

		)

		/*
		if wwmt_animatedfriction != undefined then (
			edt_animatedfriction.text = wwmt_animatedfriction
		)
		*/

		if wwmt_jointskip != undefined AND (wwmt_jointskip == true) then (
			chk_jointskip.checked = true
		) else (
			chk_jointskip.checked = false
		)

	)

	function reconstructBones root parent =
	(
		/* function from johnLauf
		at http://forums.cgsociety.org/archive/index.php/t-795590.html
		*/
		if (classOf root) == BoneGeometry then
		(
			b = BoneSys.createBone root.transform.row4 (root.pos + root.transform.row1 * root.length) [0, 0, 1]
			b.parent = parent
		)
		else
		(
			b = point()
			b.transform = root.transform
			b.parent = parent
		)
		b.wirecolor = yellow
		for c in root.children do (reconstructBones c b)
	)

	Button btnGetHitbox "Get Hitboxes" pos:[24, 316] width:72 height:33 toolTip:"Select all existing hitboxes for the selected bone."
	Button btnCreateHB "Create Hitboxes" pos:[107, 316] width:103 height:33 toolTip:"Create a hitbox for all the selected object."
	ComboBox cbxHboxSet "Hboxset" pos:[25, 358] width:134 height:4 items:#("default")
	Button btnUpdateHboxList "Update" pos:[165, 378] width:47 height:22 toolTip:"Update the HBoxset list from the bone's hitboxes."
	Button btnSetHboxset "Set" pos:[165, 407] width:47 height:24 toolTip:"Set the selected Hitboxes to the HBoxset to the left."

	GroupBox grp1 "Hitbox Functions" pos:[11, 292] width:213 height:185
	Spinner spnHitboxGroup "Hitbox Group" pos:[56, 448] width:77 height:16 range:[0, 100, 0] type:#integer scale:1
	Button btnSetHBGroup "Set" pos:[142, 448] width:31 height:17 toolTip:"Set the Hitbox Group for the selected Hitboxes."
	Button btnUnsetHBGroup "Unset" pos:[179, 448] width:36 height:18 toolTip:"Remove the collision group for selected hitboxes (will return to 0)."
	Button btnMakeBones "Make Node Bones" pos:[12, 549] width:212 height:31

	Button btnAssign "Assign" pos:[18, 499] width:61 height:32 toolTip:"Set the selected object as a Bone for this system. It will export as a Node in the SMD but will not export geometry."
	Button btnRemove "Remove" pos:[84, 499] width:59 height:32 toolTip:"Remove this object from the Bone-Only list."
	Button btnOrigin "Root" pos:[148, 499] width:75 height:34 toolTip:"Make the selected bone the ROOT/$origin node of the current WWMT object."

	Button btnSkinEach "Skin on Each Object Selected" pos:[11, 588] width:214 height:36 toolTip:"Add a separate skin modifier to each object in the selection."

	Button btn_hierarchy "Hierarchy" pos:[158, 253] width:62 height:32
	Button btnAddBoneCA "Add Bone Attributes to Selection" pos:[16, 4] width:205 height:27 toolTip:"Add bone property Custom Attributes to the selected nodes. This allows you to control Jigglebone properties and more."

	on btnAddBoneCA pressed do (
		for obj in selection do (
			wallworm_add_bone_ca obj
		)
	)
	/*on btn_animatedfriction pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setAnimatedfriction obj vals:edt_animatedfriction.text
			)
			pushPrompt "Bone $animatedfriction set for selection."
		) else (
			messagebox "No objects are selected! Select some bones first."
		)
	)
	on btn_unset_animatedfriction pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				setUserProp obj #wwmt_animatedfriction ""
			)
			pushPrompt "Bone $animatedfriction removed for selection."
		) else (
			messagebox "No objects are selected! Select some bones first."
		)
	)*/

	on wwmt_bone_options open do
	(
		if ::wallworm_makeBoolean == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
		)

		cbxBoneSurfaceProp.items = ::wwmt_surfaceprop_list

		if selection.count == 1 then (
			setUiFromBoneInfo()
			hbs = wwmt_get_hitboxes()
			hboxset = wwmt_get_hitboxsets hboxsets objs:hbs
			cbxHboxSet.items = hboxsets
		)

	)
	on btnGetBoneInfo pressed do
	(
		if selection.count == 1 then (
			setUiFromBoneInfo()
		) else (
			messageBox "You must select one individual bone to set the value."
		)

	)
	on btnSetBoneInfo pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setBoneMassBias obj amount:spn_mass_bias.value
				wwmt_setBoneSurfaceprop obj prop:cbxBoneSurfaceProp.selected
				wwmt_setJointSkip obj vals:chk_jointskip.checked
				--wwmt_setAnimatedfriction obj vals:edt_animatedfriction.text
			)
			pushPrompt "Bone Surfaceprop and Mass Bias set for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)

	)
	on btnSetBias pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setBoneMassBias obj amount:spn_mass_bias.value
			)
			pushPrompt "Bone Mass Bias set for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)
	)
	on btnUnsetBias pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setBoneMassBias obj amount:1.0
			)
			pushPrompt "Bone Mass Bias reset to 1.0 for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)
	)
	on btnSetSurf pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setBoneSurfaceprop obj prop:cbxBoneSurfaceProp.selected
			)
			pushPrompt "Bone Surfaceprop set for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)

	)
	on btnUnsetSurf pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setBoneSurfaceprop obj prop:""
			)
			pushPrompt "Bone Surfaceprop cleared for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)

	)
	on btnSetSkip pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setJointSkip obj vals:chk_jointskip.checked
			)
			pushPrompt "Joint Skip set for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)
	)
	on btn_jointskip_off pressed do
	(
		if selection.count > 0 then (
			for obj in selection do (
				wwmt_setJointSkip obj vals:false
			)
			pushPrompt "Joint Skip set for selection."
		) else (
			messageBox "No objects are selected! Select some bones first."
		)
	)
	on btnGetHitbox pressed do
	(
		if selection.count > 0 then (
			hbs = wwmt_get_hitboxes()
			hboxset = wwmt_get_hitboxsets hboxset objs:hbs

			cbxHboxSet.items = hboxsets
			if hbs != undefined AND hbs.count > 0 then (
				select hbs
				unhide hbs
			)
		) else (
			messageBox "This function only works when you have objects selected. "
		)

	)
	on btnCreateHB pressed do
	(
		if selection.count > 0 then (
			local hbs = #()

			for obj in selection do (
				local newhb = wwmt_createBoneHitbox obj
				if newhb != undefined then (
					appendIfUnique hbs newhb
				)
			)

			clearSelection()

			if hbs.count > 0 then (
				select hbs
			)

		) else (
			messageBox "This function only works when you have objects selected. "
		)

	)
	on btnUpdateHboxList pressed do
	(
		oldsel = selection
		hbs = wwmt_get_hitboxes()

		wwmt_get_hitboxsets hboxsets objs:hbs
		cbxHboxSet.items = hboxsets
		if oldsel.count > 0 then (
			select oldsel
		)
	)
	on btnSetHboxset pressed do
	(
		if selection.count > 0 then (
			if cbxHboxSet.text != undefined AND cbxHboxSet.text != "" then (
				if findItem cbxHboxSet.items cbxHboxSet.text == 0 then (
					startItem = cbxHboxSet.text
					newitems = cbxHboxSet.items
					appendIfUnique newitems cbxHboxSet.text
					sort newitems
					cbxHboxSet.items = newitems

					cbxHboxSet.selection = (findItem cbxHboxSet.items startItem)

				)

				wwmt_setHboxSets selection val:cbxHboxSet.selected

			) else (
				messageBox "There is no hboxset selected."
			)

		)

	)
	on btnSetHBGroup pressed do
	(
		if selection.count > 0 then (
			for hb in selection WHERE (isProperty hb #wwmt_hitbox OR getUserProp hb #wwmt_hitbox == true) do (
				wwmt_setHitboxGroup hb grp:spnHitboxGroup.value
			)
		) else (
			messageBox "This function requires you to select hitboxes"
		)
	)
	on btnUnsetHBGroup pressed do
	(
		if selection.count > 0 then (
			for hb in selection WHERE (isProperty hb #wwmt_hitbox OR getUserProp hb #wwmt_hitbox == true) do (
				wwmt_setHitboxGroup hb grp:0
			)
		) else (
			messageBox "This function requires you to select hitboxes"
		)
	)
	on btnMakeBones pressed do
	(
		/*
		objArray = selection as array
		bnArray = #()

		for obj in objArray do (
			--local bn = snapshot obj

			local bn = BoneSys.createBone obj.pos <point3>endPos <point3>zAxis

			bn.name = (uniqueName (obj.name + "Bone"))
			bn.renderable = off
			bn.mat = undefined
			bn.boneEnable=true
			bn.transform = obj.transform

			append bnArray bn

		)

		for i=1 to objArray.count do (
			obj = objArray[i]
			if obj.parent != undefined then (
				theParentIndex = findItem objArray obj.parent
				if theParentIndex != 0 then (
					bnArray[i].parent = bnArray[theParentIndex]

				)

			)

		)

		for i=1 to objArray.count do (
			local ls = bnArray[i].controller = Link_Constraint()
			ls.addTarget  objArray[i] 1

		)

		*/

		for obj in selection WHERE obj.parent == undefined do (
			reconstructBones obj undefined

		)

	)
	on btnAssign pressed do
	(
		global ww_scene_lods
		if ww_scene_lods != undefined AND classOf ww_scene_lods == ww_LOD_wrapper AND ww_scene_lods.target != undefined then (
			if selection.count > 0 then (
				ww_scene_lods.addToBones selection
			) else (
				messageBox "You need to select bones or nodes first."
			)

		) else (
			messageBox "You need to assign a model in the WWMT UI before this function can work."
		)

	)
	on btnRemove pressed do
	(
		global ww_scene_lods
		if ww_scene_lods != undefined AND classOf ww_scene_lods == ww_LOD_wrapper AND ww_scene_lods.target != undefined then (
			if selection.count > 0 then (
				ww_scene_lods.removeFromBones selection
			) else (
				messageBox "You need to select bones or nodes first."
			)

		) else (
			messageBox "You need to assign a model in the WWMT UI before this function can work."
		)

	)
	on btnOrigin pressed do
	(
		global ww_scene_lods
		if ww_scene_lods != undefined AND classOf ww_scene_lods == ww_LOD_wrapper AND ww_scene_lods.target != undefined then (
			if selection.count == 1 then (
				if (ww_scene_lods.setRootNode $) then (
					--ww_scene_lods.addToBones selection

					--print ww_scene_lods.target.targets 
				) else (
					messageBox "The action failed."
				)

			) else (
				messageBox "You need to select bones or nodes first."
			)

		) else (
			messageBox "You need to assign a model in the WWMT UI before this function can work."
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
	on btn_hierarchy pressed do
	(
		setCommandPanelTaskMode mode:#hierarchy
		cui.commandPanelOpen = true

	)
)
