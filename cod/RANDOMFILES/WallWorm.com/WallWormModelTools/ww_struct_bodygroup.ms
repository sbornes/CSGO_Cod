struct ww_wwmt_bodygroup (
	bgname, --NAME OF bodygroup (from bghelper node name)
	bghelper, --DUMMY OBJECT THAT STORES INFO
	bgmodels = #(), --WWMT HELPERS

	function updateCA newDef:undefined forceUpdate:false = (
		global wallworm_bodygroup_CA
		if isValidNode bghelper AND NOT isProperty bghelper #wallworm_bodygroup_CA then (
			custAttributes.add bghelper wallworm_bodygroup_CA
		) else (
			if forceUpdate == true OR bghelper.wallworm_bodygroup_CA.version < 5 then (
				if newDef == undefined then (
					global wallworm_bodygroup_CA
					newDef = (custAttributes.getDefSource wallworm_bodygroup_CA)
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

							)

						)
					)
				)

			)
		)
	),
	function sendValueTobghelper = (
		updateCA()

	),

	function setName n = (
		bgname = n

	),
	function appendModel c refNode:undefined = (
		local isSource = getUserProp c #wwmt_source_helper
		if isSource != undefined AND isValidNode c then (
			local tempWWMT = ww_LOD_wrapper()
			tempWWMT.init()
			if (tempWWMT.setTargetModel c tempWWMT) then (
				append bgmodels c
			)
		)
	),

	function setHelper h refNode:undefined = (
		if classOf h == Dummy then (
			bghelper = h
			bgname = bghelper.name
			for c in bghelper.children do (
				appendModel c refNode:refNode

			)

			global wallworm_bodygroup_CA
			if NOT isProperty h #bodygroup then (
				if wallworm_bodygroup_CA == undefined then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/bodygroups.ms")
				)
				custAttributes.add h wallworm_bodygroup_CA

				local theWWMTBodygroups = getUserProp h #wwmt_bodygroups

				if theWWMTBodygroups != undefined then (
					for word in (filterString (theWWMTBodygroups as String) ",") do (
						n = getNodeByName word

						if isValidNode n AND findItem bghelper.wwmts n == 0 then (
							append bghelper.wwmts n

						)

					)

				)

			)

			bgmodels = bghelper.wwmts as Array

		)

	),

	function addItemToBodygroup wwmt refNode:undefined = (
		bghelper.addWWMT n
		bgmodels = bghelper.wwmts as Array
	),

	function removeItemFromBodygroup wwmt = (
		bghelper.removeWWMT wwmt
		bgmodels = bghelper.wwmts as Array
	)

)