
global wallwormraymesh

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")

global wallworm_game_settings
if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
) else (
	macros.run "wallworm.com" "wallwormParseFGD2"
)

if wallworm_game_settings != undefined AND wallworm_game_settings.ents != undefined AND wallworm_game_settings.ents.count > 0 then (
	try (destroyDialog pointEntititesUI) catch ()

	rollout pointEntititesUI "Point Entities" width:356 height:454
	(
		local rootParam
		ComboBox entslist "Available Entities" pos:[12, 6] width:184 height:18
		Button btnConvEntity "Selection As Point Entity" pos:[213, 161] width:125 height:48 toolTip:"Assign the selected object(s) as point entities. Usefull for assigning entity properties to Proxies, etc. Also updates current entities to selected entity class."
		Button btnPlaceEntity "Place Entities" pos:[201, 103] width:146 height:32 toolTip:"Start Dropping Entities. Right Click to stop."

		Button btnMoveToWorld "Detach Entity" pos:[214, 216] width:124 height:39 toolTip:"Remove the entity data from selected object."

		GroupBox grp1 "More Functions" pos:[202, 140] width:145 height:125
		CheckBox pointOrigin "Picked Point Origin" pos:[201, 29] width:143 height:15 toolTip:"If on, the picked point is the origin of your entity. If off... the picked point is the bottom of the entity (and the origin is 8 units above)."
		CheckBox chkGPoly "Convert to GPoly" pos:[201, 48] width:146 height:14 checked:true toolTip:"Convert entity to Editable GPoly to reduce clutter in Modify Tab. Only in 3ds Max 2014+."
		Button btnSelectEntTypes "Select All of Type in Scene" pos:[162, 299] width:168 height:29
		--subRollout attribs "Entity Attributes" pos:[10,324] width:330 height:168
		CheckBox chkExcludeWWMT "Exclude WWMT Helpers" pos:[15, 297] width:138 height:15
		CheckBox chkExcludeWWMTProxies "Exclude WWMT Proxies" pos:[15, 317] width:141 height:18
		GroupBox grp3 "Selection Tools" pos:[9, 274] width:338 height:70

		Button btnCopy "Copy Entity" pos:[218, 364] width:123 height:21 toolTip:"Set the currently selected entity as the copy-from entity for the Paste function."
		Button btnPaste "Paste Entity" pos:[218, 388] width:123 height:37 toolTip:"Paste the current properties."
		GroupBox grpCopy "Copy/Paste Properties" pos:[8, 351] width:339 height:86
		CheckBox chkProperties "Properties" pos:[17, 373] width:82 height:15 toolTip:"When pasting an entity onto others, paste all of the properties."
		CheckBox chkOutputs "Outputs" pos:[17, 392] width:64 height:15 toolTip:"When pasting an entity onto others, paste all of the outputs. When Append to Current is set, the outputs are appended to the target's current output list (if any). Otherwise, the existing outputs are over-written."
		CheckBox chkSpawnflags "Spawn Flags" pos:[17, 411] width:84 height:15 toolTip:"Paste the spawnflags (over-writing any existing values)."
		CheckBox chkAppendOutputs "Append to Current" pos:[93, 392] width:114 height:16 toolTip:"When on, the outputs are appended to the target's current output list (if any). Otherwise, the existing outputs are over-written."
		Button btnXRef "World Model XRef" pos:[201, 86] width:145 height:12
		EditText edtWorldModelPath "" pos:[200, 66] width:147 height:14

		on btnXRef pressed do (
			localProxPath = (pathConfig.GetDir #import) + "\\WallWormPropLibrary\\"
			if doesFileExist localProxPath then (
				local fgdName = getFileNameFile ::wwmt_def_fgd
				tmpPath = localProxPath + fgdName + "\\"

				local modFGDPath = tmpPath

				if doesFileExist tmpPath then (
					localProxPath = tmpPath

					if edtWorldModelPath.text != "" then (
						tmpPath = localProxPath + getFileNamePath (edtWorldModelPath.text)
						if doesFileExist tmpPath then (
							localProxPath = tmpPath
						)
					)
					::wallworm_PointEntityProxFile = getOpenFileName filename:localProxPath caption:"Choose Library File" types:"MAX Files (*.MAX)|*.max" historyCategory:"Wall Worm Prop Library"

					if ::wallworm_PointEntityProxFile != undefined then (
						::wallworm_PointEntityProxFilePath = wallworm_BSToFS (substituteString (substituteString ::wallworm_PointEntityProxFile modFGDPath "") ".max" ".mdl")
						edtWorldModelPath.text = ::wallworm_PointEntityProxFilePath
					)
				) else (
					messageBox "This mod has no props in the library yet."
				)
			) else (
				messageBox "There are no files in the Wall Worm Prop Library."
			)

		)

		function shouldCheckForUnique = (findItem (#("sky_camera", "light_environment", "env_fog_controller", "shadow_control")) entslist.selected != 0)

		function testExisting = (
			local existing = undefined
			local uniqueproblem = false
			if (shouldCheckForUnique()) then (
				existing = (for obj in objects WHERE isProperty obj #entityType AND isProperty obj #entname AND obj.entname == entslist AND isProperty obj #wallworm.selected collect obj)
				if existing.count > 0 then (
					uniqueproblem = true
				)
			)
			uniqueproblem
		)

		function bind_light_params ent = (
			ent._light = ent.color
		)

		function pickAnotherPoint = (
			local ent
			local convertToGP = false
			local MDLName = undefined
			max create mode
			p = pickPoint snap:#3D prompt:"\nPlace entities at the picked points.\n"
			if classOf p == Point3 then (
				if pointOrigin.checked == false then (
					p = p + [0, 0, 8]
				)

				--try (

				if testExisting() == false then (
					test = wallworm_game_settings.get_entity_by_name entslist.selected

					if test != undefined AND test.ca != undefined then (
						local ent

						case (entslist.selected) of (
							"light":(
								ent = Omnilight()
							)
							"light_spot":(
								ent = FreeSpot()
							)
							"light_dynamic":(
								ent = FreeSpot()
							)

							"light_spot":(
								ent = FreeSpot()
							)
							"light_environment":(
								ent = Directionallight()
								ent.overshoot = true
							)
							"light_directional":(
								ent = Directionallight()
								ent.overshoot = true
							)
							"func_instance":(
								ent = Container()
							)
							default:(
								if test.studio != undefined AND test.studio != "" then (
									/*See if this MDL exists.*/

									/*First check the library*/
									local mdl = substituteString test.studio "models/" ""

									local fgdName = getFileNameFile ::wwmt_def_fgd

									if fgdName != "" then (
										localProxPath = (pathConfig.GetDir #import) + "\\WallWormPropLibrary\\" + fgdName + "\\"
										local mdl = substituteString mdl ".mdl" ".max"
										local modelFile = localProxPath + mdl
										if doesFileExist modelFile then (
											ent = xrefs.addNewXRefObject modelFile "WallWormProxyReference" modifiers:#merge manipulators:#merge dupMtlNameAction:#autoRename
											setUserPropBuffer ent ""
										) else (
											/*Look for QC*/
											/*
											local modelFile = localProxPath + mdl

											if doesFileExist modelFile then (
												ent = xrefs.addNewXRefObject prfile "WallWormProxyReference"  modifiers:#xref  manipulators:#xref  dupMtlNameAction:#useScene
												setUserPropBuffer ent ""
											)
											*/
										)
									)
								)

								if ent == undefined then (
									/*DO NOT USE BRUSH MODE*/
									local tempwallwormbrusmodestate = wallwormbrusmodestate
									global wallwormbrusmodestate = false

									local loadProxModel = case (entslist.selected) of (
										"prop_static":true
										"prop_dynamic":true
										"prop_physics":true
										"prop_dynamic_override":true
										"prop_ragdoll":true
										"prop_door_rotating":true
										"prop_physics_multiplayer":true
										"prop_vehicle":true
										"prop_vehicle_driveable":true
										default:false
									)

									if (loadProxModel AND ::wallworm_PointEntityProxFile != undefined) then (
										ent = xrefs.addNewXRefObject ::wallworm_PointEntityProxFile "WallWormProxyReference" modifiers:#merge manipulators:#merge dupMtlNameAction:#autoRename
										MDLName = "models/" + edtWorldModelPath.text
									)
									if NOT isValidNode ent then (
										ent = Box height: 16 width:16 length:16 mapcoords:on lengthsegs:1 heightsegs:1 widthsegs:1
										ent.pivot = ent.center
										ent.mapcoords = on
										ResetXform ent
										convertToPoly ent
										convertToGP = true
									)
									wallwormbrusmodestate = tempwallwormbrusmodestate
								)
							)
						)

						ent.pos = p

						ent.name = uniqueName test.name

						--convertToPoly ent
						custAttributes.add ent test.ca

						if isProperty ent #targetName then (
							ent.targetName = ent.name
						)
						if MDLName != undefined AND isProperty ent #model then (
							ent.model = MDLName
							setUserPropBuffer ent ""
						)
						/*
						Maybe add model importing....

						if  isProperty ent #studio  AND ent.studio != undefined then (
							lookFor = substituteString ent.studio ".mdl" ""
							append lookFor ".qc"
							print lookFor
							replacementEnt = (wallworm_import_smd lookFor rotateModel:false) 

							--ent.setUserPropBuffer ent ""

						)

						*/

						if superClassOf ent != Light then (
							if isProperty ent #entcolor AND ent.entcolor != undefined AND classOf ent.entcolor == Color then (
								ent.wireColor = ent.entcolor
							) else (
								ent.wireColor = (Color 192 13 208)
							)

							if isProperty ent #iconsprite AND ent.iconsprite != undefined then (
								lookFor = substituteString ent.iconsprite ".vmt" ""
								themat = wallworm_VMFIMPORT_getMaterial lookFor color:ent.wireColor openLib:true
								ent.mat = themat

							)

							if NOT isProperty ent #model then (
								ent.renderable = off
								if convertToGP AND Deformable_Gpoly != undefined AND canConvertTo ent Deformable_Gpoly AND chkGPoly.checked then (
									convertTo ent Deformable_Gpoly
								)

							)

						) else (
							if isProperty ent #color AND isProperty ent #_light then (
								ent._light = ent.color
							)
						)

						if isProperty ent #_lightHDR_intensity  then (
							ent._lightHDR_intensity = -1
						)
						if isProperty ent #_ambientHDR_intensity  then (
							ent._ambientHDR_intensity = -1
						)
					) else (
						messageBox "Oops... this entity was not found in the Entity Cache. You may need to reparse the FGD in the WW Settings."

					)

					--) catch (
					--messagebox "Oops... there was an error. Click F11 for more info."
					--print (getCurrentException())
					--)
					pickAnotherPoint()

				) else (
					messageBox "Oops... this entity is only allowed to exist once in the scene."

					select ((for obj in objects WHERE isProperty obj #entityType AND isProperty obj #entname AND obj.entname == entslist AND isProperty obj #wallworm.selected collect obj))
				)
			)

			if ent != undefined then (
				select ent

				max modify mode
			)

		)

		/*
		function clearRootParam = (
			if rootParam != undefined then (
				removeSubRollout attribs rootParam
			)

			wallworm_remove_entity rootNode
		)

		on pointEntititesUI close do
		(
			clearRootParam()
		)
		*/

		function addEntProps theSelection entName = (
			max create mode

			theSelection = for obj in theSelection WHERE NOT isProperty obj #ww_displacement_brush AND NOT isProperty obj #ww_displacement AND NOT isProperty obj #wallworm_edit_mesh collect obj

			if theSelection.count > 0 then (
				if (shouldCheckForUnique()) == true AND (theSelection.count > 1 OR testExisting() == true) then (
					messageBox "This entity should only be added once to the scene. You cannot apply it to multiple objects."

				) else (
					test = wallworm_game_settings.get_entity_by_name entName

					if test != undefined AND test.ca != undefined then (
						toprocess = wallworm_update_entities theSelection test

						if toprocess.count > 0 then (
							--wallworm_remove_entities toprocess
							custAttributes.add toprocess test.ca
						)

						for obj in (theSelection as Array) do (
							local wwmtnode
							local isProxy = false
							local wwmtname = getUserProp obj #wwmt_proxie_source
							if wwmtname != undefined then (
								if isProperty obj #wwmtTarget then (
									wwmtnode = obj.wwmtTarget
								) else (
									wwmtnode = getNodeByName wwmtname
								)
							)
							if isValidNode wwmtnode then (
								isProxy = true
								obj.getWWMT()
							)
							if isProperty obj #model then (
								if isValidNode wwmtnode AND isProperty wwmtnode #modelName then (
									obj.model = (wallworm_remove_last_slash (wwmtnode.modelPath)) + "/" + wwmtnode.modelName + ".mdl"
								)
							)

							if isProxy == true AND isProperty obj #proxynimation AND isProperty obj #defaultAnim then (
								obj.defaultAnim = obj.proxynimation
							)

							if isProxy == true AND isProperty obj #proxybodygroup AND isProperty obj #body then (
								obj.wwmt.populateBodyGroups()
								bgs = for b in obj.wwmt.bodygroups collect b.bgName
								obj.body = findItem bgs obj.proxybodygroup
							)

							if superClassOf obj == Light then (
								if isProperty obj #brightness then (
									--$
								)
							)

							legacyDats = getUserProp obj #GLBPntData
							legacyValus = getUserProp obj #GLBPntValu
							legacyFlags = getUserProp obj #GLBFlags

							if legacyDats != undefined AND legacyDats != "" AND legacyValus != undefined AND legacyValus != "" then (
								props = filterString legacyDats "," splitEmptyTokens:true
								vals = filterString legacyValus "," splitEmptyTokens:true

								if props.count == vals.count then (
									for i = 2 to props.count do (
										if vals[i] != undefined AND vals[i] != "" AND vals[i] != ";" then (
											if isProperty obj props[i] == true then (
												try (
													setProperty obj props[i] (vals[i] as (classOf (getProperty obj props[i])))
												) catch ()
											)
										)

									)

								)

							)

							if legacyFlags != undefined AND legacyFlags != "" AND isProperty obj #spawnflags AND ((legacyFlags as Integer) != undefined) then (
								setProperty obj "spawnflags" (legacyFlags as Integer)

							)

							if legacyDats != undefined then (
								setUserProp obj #GLBPntData ""
							)

							if legacyValus != undefined then (
								setUserProp obj #GLBPntValu ""
							)
							if legacyFlags != undefined then (
								setUserProp obj #GLBFlags ""
							)

							if isProperty obj #entcolor AND obj.entcolor != undefined AND classOf obj.entcolor == Color then (
								obj.wireColor = obj.entcolor
							)

							if obj.mat == undefined AND isProperty obj #iconsprite AND obj.iconsprite != undefined then (
								lookFor = substituteString obj.iconsprite ".vmt" ""
								themat = wallworm_VMFIMPORT_getMaterial lookFor color:obj.wireColor openLib:true
								obj.mat = themat
								if isProperty obj #mapcoords then (
									obj.mapcoords = on
								)
							)

							if superClassOf obj == Light then (
								if classOf obj == Directionallight then (
									obj.overshoot = true
								)

								if isProperty obj #color AND isProperty obj #_light then (
									obj._light = obj.color
								)

							) else (
								if NOT isProperty obj #model then (
									obj.renderable = off
									if Deformable_Gpoly != undefined AND obj.modifiers.count == 0 AND canConvertTo obj Deformable_Gpoly AND chkGPoly.checked then (
										convertTo obj Deformable_Gpoly
									)

								) else (
									obj.renderable = on
									if classOf obj == Deformable_Gpoly AND obj.modifiers.count == 0 then (
										convertToMesh obj
										convertToPoly obj
									)

								)
							)

							local legacyDist = getUserProp obj #wwmt_max_distance
							if legacyDist != undefined AND legacyDist != "" AND legacyDist as Float != undefined AND isProperty obj #fademaxdist then (
								obj.fademaxdist = legacyDist as Float
								setUserProp obj #wwmt_max_distance undefined
							)

							local legacyStartDist = getUserProp obj #wwmt_start_fade
							if legacyStartDist != undefined AND legacyStartDist != "" AND legacyStartDist as Float != undefined AND isProperty obj #fademindist then (
								obj.fademaxdist = legacyStartDist as Float
								setUserProp obj #wwmt_start_fade undefined
							)

							
							if isProperty obj #_lightHDR_intensity  then (
								obj._lightHDR_intensity = -1
							)
							
							if isProperty obj #_ambientHDR_intensity  then (
								obj._ambientHDR_intensity = -1
							)

							
						)

					) else (
						messageBox "Oops... this entity was not found in the Entity Cache. You may need to reparse the FGD in the WW Settings."

					)
				)

				if selection.count == 1 then (
					max modify mode
				)

			) else (
				messageBox "Oops... you need to select some objects to us this function."

			)

		)

		on pointEntititesUI open do
		(
			global wallworm_game_settings
			pointents = wallworm_game_settings.getAllPointEntities()
			entslist.items = sort (for ent in pointents WHERE ent != undefined collect ent.name)

			last = getINISetting ::wallworm_userIni "Menus" "anvil_last_point_entity"
			entslist.selection = findItem entslist.items last

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

			if ::wallworm_PointEntityProxFilePath != undefined then (
				edtWorldModelPath.text = ::wallworm_PointEntityProxFilePath
			)

		)
		on entslist selected sel do
		(
			/*change global last ent*/

			/*
			test = wallworm_game_settings.get_entity_by_name  entslist.selected

			if test != undefined AND test.ca != undefined then (
				clearRootParam()

				custAttributes.add rootNode test.ca

				rootParam = rootNode.custattributes[rootNode.custattributes.count].params

				--addRollout rootNode.custattributes[rootNode.custattributes.count].params

				addSubRollout attribs rootParam

			)		

			*/

			/*
			open rollouts with values to send to selected objs
			*/
			if entslist.selected != undefined AND entslist.selected != "" then (
				setINISetting ::wallworm_userIni "Menus" "anvil_last_point_entity" (entslist.selected as String)
			)
		)
		on btnConvEntity pressed do
		(
			theSelection = selection as Array
			addEntProps theSelection entslist.selected

		)
		on btnPlaceEntity pressed do
		(
			pickAnotherPoint()
		)
		on btnMoveToWorld pressed do
		(
			if selection.count > 0 then (
				wallworm_remove_entities selection
			) else (
				messageBox "Oops... no objects were selected."
			)
		)
		on btnSelectEntTypes pressed do
		(
			local entname = entslist.selected
			if entname != undefined AND entname != "" then (
				local ents = for obj in objects WHERE isProperty obj #entname AND obj.entname == entname AND ((NOT chkExcludeWWMT.checked) OR (chkExcludeWWMT.checked AND NOT isProperty obj #wwmt_ca)) AND ((NOT chkExcludeWWMTProxies.checked) OR (chkExcludeWWMTProxies.checked AND getUserProp obj #wwmt_proxie_source == undefined)) collect obj
				if ents.count > 0 then (
					select ents
				)
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
					theSelection = selection as Array
					addEntProps theSelection wallworm_copy_entity.entName

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

	createDialog pointEntititesUI

) else (
	messageBox "There is no FGD file. Please set one in the settings!"
	macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
)
