rollout wallworm_entity_copy_rollout "Copy Entity Properties" width:358 height:101
(
	Button btnCopy "Copy Entity" pos:[217, 20] width:123 height:21 toolTip:"Set the currently selected entity as the copy-from entity for the Paste function."
	Button btnPaste "Paste Entity" pos:[217, 44] width:123 height:37 toolTip:"Paste the current properties."
	GroupBox grpCopy "Copy/Paste Properties" pos:[7, 7] width:339 height:86
	CheckBox chkProperties "Properties" pos:[16, 29] width:82 height:15 toolTip:"When pasting an entity onto others, paste all of the properties."
	CheckBox chkOutputs "Outputs" pos:[16, 48] width:64 height:15 toolTip:"When pasting an entity onto others, paste all of the outputs. When Append to Current is set, the outputs are appended to the target's current output list (if any). Otherwise, the existing outputs are over-written."
	CheckBox chkSpawnflags "Spawn Flags" pos:[16, 67] width:84 height:15 toolTip:"Paste the spawnflags (over-writing any existing values)."
	CheckBox chkAppendOutputs "Append to Current" pos:[92, 48] width:114 height:16 toolTip:"When on, the outputs are appended to the target's current output list (if any). Otherwise, the existing outputs are over-written."

	on wallworm_entity_copy_rollout open do
	(
		entity_paste_props = getINISetting ::wallworm_userIni "Menus" "entity_paste_props"
		entity_paste_outputs = getINISetting ::wallworm_userIni "Menus" "entity_paste_outputs"
		entity_paste_spawnflags = getINISetting ::wallworm_userIni "Menus" "entity_paste_spawnflags"
		entity_paste_outputs_append = getINISetting ::wallworm_userIni "Menus" "entity_paste_outputs_append"
		if entity_paste_props == "" OR entity_paste_props == "true" then (
			chkProperties.checked = true
		)
		if entity_paste_outputs == "true" then (
			chkOutputs.checked = true
		)
		if entity_paste_spawnflags == "true" then (
			chkSpawnflags.checked = true
		)

		if entity_paste_outputs_append == "" OR entity_paste_outputs_append == "true" then (
			chkAppendOutputs.checked = true
		)
	)
	on btnCopy pressed do
	(
		global wallworm_copy_entity

		if selection.count == 1 AND isProperty selection[1] "entName" then (
			wallworm_copy_entity = selection[1]
		) else (
			messageBox "This function only works when you have a single entity object selected."
		)

	)
	on btnPaste pressed do
	(
		global wallworm_copy_entity
		if isValidNode wallworm_copy_entity AND isProperty wallworm_copy_entity #entName then (
			if selection.count > 0 then (
				global wallworm_addEntProps
				theSelection = selection as Array
				wallworm_addEntProps theSelection wallworm_copy_entity.entName

				if chkProperties.checked then (
					if isProperty wallworm_copy_entity #exportProps AND wallworm_copy_entity.exportProps != undefined then (
						for p in wallworm_copy_entity.exportProps do (
							v = getProperty wallworm_copy_entity p
							if v != undefined then (
								objs = for obj in theSelection WHERE isProperty obj p collect obj
								if objs.count > 0 then (
									for obj in objs do (
										setProperty obj p v
									)
								)
							)
						)

					)
				)

				if chkOutputs.checked then (
					if isProperty wallworm_copy_entity #outputs AND wallworm_copy_entity.outputs != undefined then (
						objs = for obj in theSelection WHERE isProperty obj #outputs collect obj
						local copiedouts = wallworm_copy_entity.outputs as Array

						if chkAppendOutputs.checked then (
							if objs.count > 0 then (
								for obj in objs do (
									ar1 = obj.outputs as Array
									join ar1 copiedouts
									obj.outputs = ar1
								)
							)
						) else (
							objs.outputs = copiedouts
						)
					)
				)

				if chkSpawnflags.checked then (
					if isProperty wallworm_copy_entity #spawnflags AND wallworm_copy_entity.spawnflags != undefined then (
						objs = for obj in theSelection WHERE isProperty obj #spawnflags collect obj
						objs.spawnflags = wallworm_copy_entity.spawnflags
					)
				)
			) else (
				messageBox "This function only works when you have a single entity object selected."
			)

		) else (
			messageBox "You must first copy an entity properties from the scene."
		)
	)
	on chkProperties changed stat do
	(
		setINISetting ::wallworm_userIni "Menus" "entity_paste_props" (stat as String)
	)
	on chkOutputs changed stat do
	(
		setINISetting ::wallworm_userIni "Menus" "entity_paste_outputs" (stat as String)
	)
	on chkSpawnflags changed stat do
	(
		setINISetting ::wallworm_userIni "Menus" "entity_paste_spawnflags" (stat as String)
	)
	on chkAppendOutputs changed stat do
	(
		setINISetting ::wallworm_userIni "Menus" "entity_paste_outputs_append" (stat as String)
	)
)
