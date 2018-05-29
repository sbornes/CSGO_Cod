/*
Script by Shawn Olson
http://www.shawnolson.net
Added into Wall Worm
*/
(
	try(destroyDialog wallworm_copy_properties) catch ()
	rollout wallworm_copy_properties "Copy & Paste Matching Properties" width:250 (
		Label lblSource "Source Node:"
		PickButton pckbtnSource "Pick Source of Properties" width:240 tooltip:"Select the object to serve as the source." autoDisplay:true
		Group "Controller Options" (
			RadioButtons rdpPropController "Paste Type" labels:#("Current Value", "Copied Controller", "Instanced Controllers") align:#left
		)
		Group "Properties" (
			Button btnAll "All" align:#left width:70 across:3
			Button btnInvert "Invert" width:70 align:#left
			Button btnNone "None" width:70 align:#left
			MultiListBox mlbProps "Properties"
		)
		Group "Extra Paste Options" (
			CheckBox chkMaterial "Paste Material" across:2
			CheckBox chkPasteWireColor "Paste Wire Color"
		)
		Group "Misc" (
			CheckBox chkSelectRes "Select Updated Nodes on Completion" tooltip:"If checked, the selection will update to include any objects that had properties updated."
		)
		Button btnDoIt "Paste Matching Properties" width:240 tooltip:"When pressed, will apply all properties of the Source object to selected objects where the property names and property types match."
		Hyperlink lnkWW "A Script by Wall Worm" address:"http://www.wallworm.com" color:blue hovercolor:red across:2
		Hyperlink linkHelp "Help" address:"http://www.shawnolson.net/a/1846/copy_and_paste_object_properties_in_3ds_max.html" color:blue hovercolor:red align:#right

		function flashSource = (
			local obj = pckbtnSource.object
			if isValidNode obj then (
				flashNodes (#(obj))
				forcecompleteredraw()
			)
		)
		on btnAll pressed do (
			if mlbProps.items.count > 0 then (
				mlbProps.selection = #{1..mlbProps.items.count}
			)
		)
		on btnNone pressed do (
			mlbProps.selection = #{}
		)
		on btnInvert pressed do (
			mlbProps.selection = -(mlbProps.selection)
		)
		on pckbtnSource rightClick do (
			flashSource()
		)
		on pckbtnSource picked obj do (
			if isValidNode obj then (
				mlbProps.items = (sort(getPropNames obj))
				flashSource()
			)
		)
		on btnDoIt pressed do undo "Paste Properties" on (
			local obj = pckbtnSource.object
			local updatedObjects = #()
			if isValidNode obj then (
				if selection.count > 0 then (
					if mlbProps.selection.numberset == 0 then (
						messageBox "No properties are selected for pasting."
					) else (
						with redraw off (
							local propNames = sort(getPropNames obj)
							local values = for v in propNames collect getProperty obj v
							local controllers = #()
							if rdpPropController.state != 1 then (
								controllers = for v in propNames collect getPropertyController obj v
							)
							local propCount = propNames.count
							local theMat = obj.mat
							local wireColor = obj.wireColor
							local thesel = for testObj in selection WHERE testObj != obj collect testObj
							for testObject in thesel do (
								if chkMaterial.checked then (
									testObject.mat = theMat
									appendIfUnique updatedObjects testObject
								)
								if chkPasteWireColor.checked then (
									testObject.wireColor = wireColor
									appendIfUnique updatedObjects testObject
								)
								for i = 1 to propCount do (
									if mlbProps.selection [i] == true then (
										local prop = propNames[i]
										local val = values[i]
										if isProperty testObject prop then (
											local currentValue = getProperty testObject prop
											if classOf currentValue == classOf val AND currentValue != val then (
												case rdpPropController.state of (
													1:(
														setProperty testObject prop val
													)
													2:(
														if controllers[i] != undefined then (
															setPropertyController testObject prop (copy controllers[i])
														) else (
															setProperty testObject prop val
														)
													)
													3:(
														if controllers[i] != undefined then (
															setPropertyController testObject prop (controllers[i])
														) else (
															setProperty testObject prop val
														)
													)
												)
												if chkSelectRes.checked then (
													appendIfUnique updatedObjects testObject
												)
											)
										)
									)
								)
							)
						)
						if updatedObjects.count > 0 then (
							select updatedObjects
						)
						forcecompleteredraw()
					)
				) else (
					messageBox "No objects selected. Make a selection of objects to paste properties to."
				)
			) else (
				messageBox "First pick the Source object to copy properties from."
			)
		)
	)
	createDialog wallworm_copy_properties
)