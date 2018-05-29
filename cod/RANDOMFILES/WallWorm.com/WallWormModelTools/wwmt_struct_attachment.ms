struct wwmt_attachment (
	attachment,
	pb,
	absolute = false,
	rigid = false,
	atPoint,
	function updateCA forceUpdate:false = (
		global wallworm_attachment_CA
		if isValidNode atPoint then (
			if NOT isProperty atPoint #wallworm_attachment_CA then (
				custAttributes.add atPoint wallworm_attachment_CA
			) else (
				if forceUpdate == true OR atPoint.wallworm_attachment_CA.version < 3 then (
					oldSel = selection as Array
					max select none

					global wallworm_attachment_CA
					local newDef = (custAttributes.getDefSource wallworm_attachment_CA)

					--disableRefMsgs()
					with undo off
					with redraw off (
						local c = custAttributes.count atPoint -- [BaseObject:<bool>]
						local out = false

						if c > 0 then (
							for i = c to 1 by -1 do (
								def = custAttributes.getDef atPoint i

								if def.name == "wallworm_attachment_CA" then (
									custAttributes.redefine def newDef

								)

							)
						)
					)
					if oldSel.count > 0 then (
						select oldSel
					)
				)
			)
		)

	),
	function sendValueToAtPoint = (
		updateCA()
		if isValidNode atPoint then (
			--Because the values might be empty strings or undefined
			if rigid == true OR rigid == false then (
				atPoint.rigid = rigid
			)
			if absolute == true OR absolute == false then (
				atPoint.absolute = absolute
			)
			atPoint.name = attachment
		)

	),
	function setAsWWMTAttachment = (
		if isValidNode atPoint then (
			sendValueToAtPoint()
			setUserProp atPoint #wwmt_is_attachment true
			setUserProp atPoint #wwmt_attachment_name attachment
		)
	),

	function setAttachment = (
		updateCA()
		sendValueToAtPoint()

	),
	/*Used for legacy attachments*/
	function getAttachmentFromCust targ = (
		local propName = "wwmt_attachment_" + attachment + "_absolute"
		local a = getUserProp targ propName
		if a == 1 OR a == "1" then (
			absolute = true
		) else (
			absolute = false
		)

		propName = "wwmt_attachment_" + attachment + "_pb"
		tempPb = getUserProp targ propName
		if tempPb != undefined AND tempPb != 0 then (
			local b = getNodeByName (tempPb as String)
			if isValidNode b then (
				-- AND classOf b ==Bone
				pb = tempPb
			)
		)

		propName = "wwmt_attachment_" + attachment + "_rigid"
		local r = getUserProp targ propName

		if r == 1 OR r == "1" then (
			rigid = true
		) else (
			rigid = false
		)

		--propName = "wwmt_attachment_"+attachment+"_rot"
		--rot =  getUserProp targ propName  	

		propName = "wwmt_attachment_" + attachment + "_atPoint"
		local tempPt = getUserProp targ propName
		if tempPt != undefined then (
			tp = getNodeByName tempPt
			if isValidNode tp then (
				atPoint = tp
				setAsWWMTAttachment()
			)
		)
	),
	function updateValues = (
		if isValidNode atPoint AND isProperty atPoint #wallworm_attachment_CA then (
			attachment = atPoint.name
			pb = atPoint.parent
			absolute = atPoint.absolute
			rigid = atPoint.absolute
		)

	)

)

