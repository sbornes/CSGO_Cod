function ww_wwdt_setDispHandlers = ()

if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

function ww_wwdt_setchangehandlers disp br = (
	::wallworm_performanceCounter_start #displacement #ww_wwdt_setchangehandlers
	try (
		when disp deleted id:#wallworm_deleteDisp obj do (
			local eventProp = getUserProp obj #wallworm_ignore_event_propagation

			if (theHold.Redoing() == false OR theHold.Redoing() == 0) AND isDeleted obj == false AND (eventProp == undefined OR eventProp == false OR eventProp == "false") then (
				local canDelete = true

				if isProperty obj #canDelete then (
					canDelete = obj.canDelete()
				)

				if (canDelete == true) then (
					local theBrsh

					if isProperty obj #brushNode AND obj.brushNode != undefined AND isDeleted obj.brushNode == false then (
						theBrsh = obj.brushNode
					) else (
						local br = getUserProp obj #ww_wwdt_displacement_brush
						if br != undefined then (
							theBrsh = getNodeByName br
						)
					)

					if isValidNode theBrsh then (
						try (
							setUserProp theBrsh #wallworm_ignore_event_propagation "true"
							delete theBrsh
						) catch (
							print (getCurrentException())
						)
					)
				) else (
					/*
					!TODO Update this to handle the newer sculpt mesh... probably need to swap all instances of obj in sculpt displists and their dispmaparray.		
					*/

					obj2 = copy obj
					setUserPropBuffer obj2 (getUserPropBuffer obj)
					obj2.name = obj.name
					ww_wwdt_setDispHandlers()
					/*max undo*/
					completeRedraw()
					messageBox "Displacement objects cannot be deleted when there is a Displacement Sculpt Mesh in the Scene using this displacement."
				)
			) else (
				--print "holding"
			)
		)

		when br deleted id:#wallworm_deleteDispBrush obj do (
			global wallworm_ignore_all_events
			if (theHold.Redoing() == false OR theHold.Redoing() == 0) AND isValidNode obj AND (getUserProp obj #wallworm_ignore_event_propagation == undefined OR getUserProp obj #wallworm_ignore_event_propagation == false) then (
				local dm = undefined

				/*!TODO... change this to newer displacement logic.*/

				if (dm == undefined) then (
					local disp = getUserProp obj #ww_wwdt_displacement_target
					if disp != undefined then (
						local dispB = getNodeByName disp
						if isValidNode dispB then (
							try (
								setUserProp dispB #wallworm_ignore_event_propagation "true"
								delete dispB
							) catch ()
						)
					)
				) else (
					obj2 = copy obj
					obj2.name = obj.name
					setUserPropBuffer obj2 (getUserPropBuffer obj)
					ww_wwdt_setDispHandlers()
					/*
					max undo*/
					completeRedraw()
					messageBox "Displacement objects cannot be deleted when there is a Displacement Sculpt Mesh in the Scene."
				)
			)
		)

		when name disp changes id:#wallworm_nameDisplacementMesh handleAt:#redrawViews obj do (
			try (
				global wallworm_ignore_all_events
				if (theHold.Redoing() == false OR theHold.Redoing() == 0) AND isDeleted obj == false then (
					local br = getNodeByName (getUserProp obj #ww_wwdt_displacement_brush)
					setUserProp br #ww_wwdt_displacement_target obj.name
				)
			) catch ()
		)

		if ::wallworm_displacement_events == true OR ::wallworm_displacement_events == undefined then (
			when topology disp changes id:#wallworm_topoDisplacementMesh handleAt:#redrawViews obj do (
				global wallworm_ignore_all_events
				if (theHold.Redoing() == false OR theHold.Redoing() == 0) AND isDeleted obj == false AND (NOT isProperty obj #useSoftSel OR obj.useSoftSel == undefined OR obj.useSoftSel == false) AND (getUserProp obj #wallworm_ignore_event_propagation == undefined OR getUserProp obj #wallworm_ignore_event_propagation == false) then (
					local br
					local p

					if isProperty obj #brushNode then (
						p = obj.power
					) else (
						br = getUserProp obj #ww_wwdt_displacement_brush
						if br != undefined then (
							local theBrsh = getNodeByName br
							if theBrsh != undefined then (
								local p = getUserProp theBrsh #ww_wwdt_power
							)
						)
					)

					if p != undefined then (
						local vc = 25
						if p != undefined then (
							case p of (
								2: (vc = 25)
								3: (vc = 81)
								4: (vc = 289)
							)

							if (getPolygonCount obj)[2] != vc then (
								max undo

								completeRedraw()
								messageBox "The action was cancelled. You cannot change the vertex count of this mesh."
							)
						)
					)
				)
			)

			when topology br changes id:#wallworm_topoDisplacementBrushMesh handleAt:#redrawViews obj do (
				global wallworm_ignore_all_events
				if (theHold.Redoing() == false OR theHold.Redoing() == 0) AND isDeleted obj == false AND (NOT isProperty obj #useSoftSel OR obj.useSoftSel == undefined OR obj.useSoftSel == false) AND (getUserProp obj #wallworm_ignore_event_propagation == undefined OR getUserProp obj #wallworm_ignore_event_propagation == false) then (
					local p = getUserProp obj #ww_wwdt_power

					local vc = 25
					if p != undefined then (
						case p of (
							2: (vc = 25)
							3: (vc = 81)
							4: (vc = 289)
						)

						if (getPolygonCount obj)[2] != vc then (
							max undo
							completeRedraw()
							messageBox "The action was cancelled. You cannot change the vertex count of this mesh."
						)
					)
				)
			)
		) else (
			deleteAllChangeHandlers id:#wallworm_topoDisplacementMesh
			deleteAllChangeHandlers id:#wallworm_topoDisplacementBrushMesh
		)
	) catch (
	)
	::wallworm_performanceCounter_stop #displacement #ww_wwdt_setchangehandlers
)

function ww_wwdt_delete_all_handlers = (
	deleteAllChangeHandlers id:#wallworm_brushGeometryScale
	deleteAllChangeHandlers id:#wallworm_displacementGeometryScale
	deleteAllChangeHandlers id:#wallworm_nameDisplacementBrushMesh
	deleteAllChangeHandlers id:#wallworm_nameDisplacementMesh
	deleteAllChangeHandlers id:#wallworm_deleteDisp
	deleteAllChangeHandlers id:#wallworm_deleteDispBrush
	deleteAllChangeHandlers id:#wallworm_topoDisplacementMesh
	deleteAllChangeHandlers id:#wallworm_topoDisplacementBrushMesh
	deleteAllChangeHandlers id:#wallworm_brushGeometryScale
	deleteAllChangeHandlers id:#wallworm_displacementGeometryScale
)

function wallworm_all_displacement_cleanup = (
	max create mode
	ww_wwdt_delete_all_handlers()
	deleteAllChangeHandlers id:#topologyControlMesh
	deleteAllChangeHandlers id:#deleteControlMesh

	callbacks.removeScripts id:#wwdt_displacement_topo_handler
	callbacks.removeScripts id:#wwdt_displacement_clone_handler

	/*
	local dispCollection  =	for obj in objects WHERE isProperty obj #wallworm AND (isProperty obj #wallworm_edit_mesh ) collect obj

	if dispCollection.count > 0 then (
		for disp in dispCollection do (
			disp.clearDispMapArray()
		)
	)*/

)

callbacks.removeScripts id:#wallWormRemoveDisplacementListenersAtFileOpen
callbacks.addScript #filePreOpenProcess "if (callbacks.notificationParam())[1] == 1 then (wallworm_all_displacement_cleanup())" id:#wallWormRemoveDisplacementListenersAtFileOpen

callbacks.removeScripts id:#wallWormRemoveDisplacementListenersAtShutDown
callbacks.addScript #preSystemShutdown "wallworm_all_displacement_cleanup()" id:#wallWormRemoveDisplacementListenersAtShutDown

callbacks.removeScripts id:#wallWormRemoveDisplacementListenersAtNew
callbacks.addScript #systemPreNew "if (callbacks.notificationParam()) == 1 then (wallworm_all_displacement_cleanup())" id:#wallWormRemoveDisplacementListenersAtNew

function wallworm_sculpt_mesh_handlers theController = (
	when topology theController change id:#topologyControlMesh handleAt:#redrawViews obj do (
		--make an event to unhide the displacements if the control mesh is deleted
		global wallworm_ignore_all_events
		if isDeleted obj == false AND (NOT isProperty obj #isUpdating OR obj.isUpdating == false) AND (getPolygonCount obj)[2] != obj.vertCount AND (NOT isProperty obj #useSoftSel OR obj.useSoftSel == undefined OR obj.useSoftSel == false) AND (theHold.Redoing() == false OR theHold.Redoing() == 0) then (
			max undo

			completeRedraw()
			messageBox "The action was cancelled. You cannot change the vertex count of this mesh."
		)
	)

	when theController deleted id:#deleteControlMesh obj do (
		--make an event to unhide the displacements if the control mesh is deleted
		global wallworm_ignore_all_events
		if isProperty obj #displist AND obj.displist != undefined AND obj.displist.count > 0 then (
			for d in obj.displist WHERE isValidNode d do (
				unhide d

				setTransformLockFlags d #{7, 8, 9}
				if isValidNode d.brushNode then (
					setTransformLockFlags d.brushNode #{7, 8, 9}
					d.brushNode.xray = off
				)
			)
		)

	)
)

function deleteAllEmptyBrushNodes = (
	count = 0
	for obj in objects WHERE isProperty obj #ww_displacement_brush AND isProperty obj #getDisp AND (obj.getDisp()) == undefined do (
		try (
			obj.deleteMe()
			count += 1
		) catch ()
	)
	count
)

function ww_wwdt_setDispHandlers deleteFirst:true = (
	if deleteFirst == true then (
		ww_wwdt_delete_all_handlers()
	)

	--deleteAllChangeHandlers id:#wallworm_listen_for_changed_geometry

	for disp in objects WHERE (isProperty disp #ww_displacement OR (getUserProp disp #ww_wwdt_displacement_brush != undefined)) AND isDeleted disp == false do (
		if isProperty disp #brushNode then (
			local br = disp.brushNode
		) else (
			local br = getNodeByName (getUserProp disp #ww_wwdt_displacement_brush)
		)

		if isValidNode br then (
			ww_wwdt_setchangehandlers disp br
		) else (
			--add function to recreate and rebind 
		)
	)
	--deleteAllEmptyBrushNodes()
)

function wallworm_displacement_to_poly deleteBrush:true disps:objects = (
	if disps.count > 0 then (
		ww_wwdt_delete_all_handlers()
		disps = for disp in disps WHERE isProperty disp #ww_displacement collect disp
		for disp in disps do (
			if deleteBrush == true then (
				delete disp.brushNode
			) else (
				wallworm_remove_ca_by_name disp.brushNode "Wallworm Displacement Brush Node"
				setUserProp disp.brushNode #ww_wwdt_displacement undefined
				setUserProp disp.brushNode #ww_wwdt_displacement_target undefined
			)
			setUserProp disp #ww_wwdt_displacement_brush undefined
			wallworm_remove_ca_by_name disp "Wallworm Displacement"
		)
		ww_wwdt_setDispHandlers()
	)
)
