rollout wallwormBodyGroups "Bodygroups v3.0" width:200
(
	local currentBodygroups = #()
	function wwmtfilterfunc obj = isProperty obj #wwmt_ca AND findItem (selection as Array) obj == 0
	--Group 

	Group "Multi-Assignment" (
		Button btnAssignAndLink "Create BG From Selection and Prompt" tooltip:"Make a Bodygroup, assign the currently selected WWMT helpers to it, then prompt to pick the parent WWMT."
		Button btnSetCurrent "Set BG Selection" toolTip:"Set your BodyGroup dummy helpers for adding/removing WWMT helpers to."
		Button btnAssignToBodygroups "Assign Selected WWMT To BG" toolTip:"Set the selected WWMT helpers as belonging to the currently assigned bodygroup dummies."
		Button btnRemoveFromBodygroups "Remove Selected WWMT from BG" toolTip:"Remove the selected WWMT helpers from the currently assigned bodygroup dummies."
	)

	Group "Hilight and Get" (
		Button btnFlashBG "Hilight Current BG Helpers" toolTip:"Flash the current Bodygroups."
		Button btnSelectBG "Select Current BG Helpers" toolTip:"Select the bodygroup dummies currently assigned to the UI."
		Button btnFlashWWMT "Hilight Current BG WWMT" toolTip:"Flash the WWMT helpers that belong to the selected bodygroup dummies."
		Button btnSelectWWMT "Select Current BG WWMT" toolTip:"Select all WWMT helpers that are part of the selected bodygroup dummies."

	)

	Group "Utilities" (
		Button addCatoDummy "Add BG Properties to Dummy" tooltip:"Add Bodygroup properties to an existing Dummy."
		Button btnUpdateCAs "Update BG Definitions"
	)

	Hyperlink lnkDocs "Bodygroup Help" address:"http://dev.wallworm.com/document/72/export_body_groups__bodygroup.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)

	on wallwormBodyGroups open do (
		global wallworm_bodygroup_CA
		if wallworm_bodygroup_CA == undefined then (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)

			fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/bodygroups.ms")
		)
	)

	function updateCA bghelper newDef:undefined forceUpdate:false = (
		false
		if classOf bghelper == Dummy then (
			if isValidNode bghelper AND NOT isProperty bghelper #wallworm_bodygroup_CA then (
				custAttributes.add bghelper ::wallworm_bodygroup_CA
				true
			) else (
				if forceUpdate == true OR bghelper.wallworm_bodygroup_CA.version < 7 then (
					if newDef == undefined then (
						global wallworm_attachment_CA
						newDef = (custAttributes.getDefSource ::wallworm_bodygroup_CA)
					)
					--disableRefMsgs()
					with undo off
					with redraw off (
						local c = custAttributes.count bghelper -- [BaseObject:<bool>]
						local out = false

						if c > 0 then (
							for i = c to 1 by -1 do (
								def = custAttributes.getDef bghelper i
								if def.name == "wallworm_bodygroup_CA" then (
									custAttributes.redefine def newDef
									true
								)
							)
						)
					)
				)
			)
		)
	)

	on btnUpdateCAs pressed do (
		local newDef = (custAttributes.getDefSource ::wallworm_bodygroup_CA)
		for bghelper in helpers WHERE isProperty bghelper #bodygroup do (
			updateCA bghelper newDef:newDef
		)
	)

	on btnSetCurrent pressed do
	(
		currentBodygroups = selection as Array
	)

	on btnAssignToBodygroups pressed do
	(
		if selection.count > 0 then (
			for bg in currentBodygroups WHERE classOf bg == Dummy do (
				theBG = ww_wwmt_bodygroup()
				theBG.setHelper bg
				for wwmt in (selection as Array) WHERE ::wallworm_allowed_wwmt_obj wmmt == true do (
					theBG.bghelper.addWWMT wwmt
				)
			)
		) else (
			messageBox "Oops... you don't have any objects selected."
		)
	)

	on addCatoDummy pressed do
	(
		if selection.count > 0 then (
			local newDef = (custAttributes.getDefSource ::wallworm_bodygroup_CA)
			for bg in selection WHERE classOf bg == Dummy do (
				updateCA bg newDef:newDef
			)
		) else (
			messageBox "Oops... you don't have any objects selected."
		)
	)

	on btnAssignAndLink pressed do (
		local wwmts = for wwmt in (selection as Array) WHERE isProperty wwmt #wwmt_ca AND wwmt.wwmt_ca == true collect wwmt
		if selection.count > 0 then (
			local bg = Dummy pos:selection.center boxsize: [64, 64, 64]

			local theBG = ww_wwmt_bodygroup()
			theBG.setHelper bg
			local useArray = selection as Array
			if wwmts.count != selection.count AND (NOT queryBox "Create WWMT Helpers for non-WWMT Helpers in selection?" title:"What to do about non-WWMT Helpers" beep:true) then (
				useArray = wwmts
			)

			for wwmt in useArray do (
				theBG.bghelper.addWWMT wwmt
			)
			local parentWWMT = pickObject prompt:"Pick the parent WWMT for this bodygroup." message:"Pick the parent WWMT for this bodygroup." prompt:"" filter:wwmtfilterfunc rubberband:bg.pos
			if isValidNode parentWWMT then (
				bg.parent = parentWWMT
				bg.name = uniqueName ("BG" + parentWWMT.modelName)
			) else (
				bg.name = uniqueName "Bodygroup"
			)
		) else (
			messageBox "Oops... you don't have any WWMT objects selected."
		)
	)

	on btnRemoveFromBodygroups pressed do
	(
		if selection.count > 0 then (
			for bg in currentBodygroups WHERE classOf bg == Dummy do (
				theBG = ww_wwmt_bodygroup()
				theBG.setHelper bg
				for wwmt in selection do (
					theBG.bghelper.removeWWMT wwmt
				)

			)
		) else (
			messageBox "Oops... you don't have any objects selected."
		)
	)
	on btnFlashBG pressed do
	(
		if currentBodygroups.count > 0 then (
			flashnodes currentBodygroups
			forceCompleteredraw()
		)
	)
	on btnSelectBG pressed do
	(
		if currentBodygroups.count > 0 then (
			select currentBodygroups
		)
	)
	on btnFlashWWMT pressed do
	(
		if currentBodygroups.count > 0 then (
			local wwmts = #()
			for bg in currentBodygroups WHERE classOf bg == Dummy do (
				bg.hilightItems()
			)
		)
	)
	on btnSelectWWMT pressed do
	(
		if currentBodygroups.count > 0 then (
			local wwmts = #()
			for bg in currentBodygroups WHERE classOf bg == Dummy do (
				theBG = ww_wwmt_bodygroup()
				theBG.setHelper bg
				join wwmts theBG.bgmodels
			)
			makeUniqueArray wwmts
			local toFlash = #()
			for wwmt in wwmts do (
				appendIfUnique toFlash wwmt.target
			)

			if toFlash.count > 0 then (
				select toFlash
			)
		)
	)
)
