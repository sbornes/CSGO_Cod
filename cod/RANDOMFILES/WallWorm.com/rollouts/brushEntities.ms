global wallworm_game_settings

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/entity_copy_paste.ms")

if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
) else (
	macros.run "wallworm.com" "wallwormParseFGD2"
)

if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
	try (destroyDialog brushEntititesUI) catch ()

	rollout brushEntititesUI "Brush Entities" width:400 height:490
	(
		SubRollout brushents "Entity List" height:353
		SubRollout copyrollout "Copy and Paste Functions" height:131
	)

	rollout brushentsRollout "Brush Entities" width:361 height:323
	(
		ComboBox entslist "Available Entities" pos:[12, 6] width:184 height:16
		Button btnPlaceEntity "Tie To Entity" pos:[206, 27] width:138 height:54 toolTip:"Set selected objects as solid entity. Also updates current entities to selected entity class. Make sure object is Convex!"
		Button btnMoveToWorld "Move to World" pos:[208, 90] width:137 height:57

		Button btnSelectEntTypes "Select All of Type in Scene" pos:[20, 268] width:315 height:29
		--subRollout attribs "Entity Attributes" pos:[10,324] width:330 height:168
		GroupBox grp3 "Selection Tools" pos:[9, 244] width:338 height:70

		on brushentsRollout open do
		(
			global wallworm_game_settings
			brushents = wallworm_game_settings.getAllBrushEntities()
			entslist.items = sort (for ent in brushents WHERE ent != undefined collect ent.name)

			last = getINISetting ::wallworm_userIni "Menus" "anvil_last_brush_entity"
			entslist.selection = findItem entslist.items last

		)
		on entslist selected sel do
		(
			if entslist.selected != undefined AND entslist.selected != "" then (
				setINISetting ::wallworm_userIni "Menus" "anvil_last_brush_entity" (entslist.selected as String)
			)
		)
		on btnPlaceEntity pressed do
		(
			max create mode

			local test = undefined
			theSelection = selection as Array

			theSelection = for obj in theSelection WHERE NOT isProperty obj #ww_displacement_brush AND NOT isProperty obj #ww_displacement AND NOT isProperty obj #wallworm_edit_mesh collect obj
			local existing = undefined
			local uniqueproblem = false

			local uniquelist = #("worldspawn")
			local checkUnique = findItem uniquelist entslist.selected != 0

			if theSelection.count > 0 then (
				if checkUnique AND theSelection.count > 1 then (
					uniqueproblem = true
				)

				local test = wallworm_game_settings.get_entity_by_name entslist.selected
				if test != undefined AND test.ca != undefined then (
					if entslist.selected == "worldspawn" then (
						res = queryBox "The worldspawn entity is a special entity that should not be assigned to nodes in the scene. Instead, open the Entity Manager and click the World button in the manager UI. Do you want to launch the Entity Manager?"

						if res then (
							global wallworm_map_properties_show = true
							macros.run "wallworm.com" "WallWormEntityOutputsMCR"
						)

					) else (
						toprocess = wallworm_update_entities theSelection test
						if toprocess.count > 0 then (
							if checkUnique then (
								existing = (for obj in objects WHERE isProperty obj #entityType AND isProperty obj #entname AND obj.entname == entslist AND isProperty obj #wallworm collect obj)
								if existing.count > 0 then (
									uniqueproblem = true
								)
							)
							if uniqueproblem == false then (
								custAttributes.add toprocess test.ca

								if isProperty toprocess[1] "targetName" == true then (
									for obj in toprocess do (
										obj.targetName = obj.name

										--							obj.targetName = (entslist.selected + "_"+(obj.inode.handle as string))
									)
								)
							) else (
								messageBox "Sorry... you cannot add this entity as there is already one in the scene, and this type only allows one."
							)

						)

						if selection.count == 1 then (
							max modify mode
						)
					)
				) else (
					messageBox "Oops... there was a problem. The specified entity was not found in the entity definitions cache. You may need to reparse your FGD in the WW settings."
				)
			) else (
				messageBox "Oops... select some objects first. Make sure they are convex objects since this will export as a brush entity!"
			)

			if uniqueproblem == true then (
				messageBox "Oops... you are only allowed to have a single version of this entity in the scene."
				if existing != undefined AND existing.count > 0 then (
					select existing
				)
			)
		)
		on btnMoveToWorld pressed do
		(
			if selection.count > 0 then (
				wallworm_remove_entities selection
			)
		)
		on btnSelectEntTypes pressed do
		(
			local entname = entslist.selected
			if entname != undefined AND entname != "" then (
				local ents = for obj in objects WHERE isProperty obj #entname AND obj.entname == entname collect obj
				if ents.count > 0 then (
					select ents
				)
			)
		)
	)

	createDialog brushEntititesUI

	addSubRollout brushEntititesUI.brushents brushentsRollout rolledUp:false
	addSubRollout brushEntititesUI.copyrollout wallworm_entity_copy_rollout rolledUp:false

) else (
	messageBox "There is no FGD file. Please set one in the settings!"
	macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
)
