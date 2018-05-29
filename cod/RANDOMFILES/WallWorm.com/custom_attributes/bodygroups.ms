global wallworm_bodygroup_CA = attributes "wallworm_bodygroup_CA" version:7 (
	local wallworm = true
	local bodygroup = true
	local vmf_exclude = true
	local thisNode, paramrollout, updateItemsList, sendBonesToBodygroup

	function getNode = (
		if thisNode == undefined then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	on clone orig do thisNode = undefined

	parameters params rollout:paramrollout (
		wwmts type:#nodeTab tabSizeVariable:true

		on wwmts set val do (
			updateItemsList()
		)
	)

	function sanitize = (
		wwmts = for obj in wwmts WHERE isValidNode obj collect obj
		local tmpArray = #()
		for wwmt in wwmts do (
			local tempWWMT = ww_LOD_wrapper()
			tempWWMT.init()
			tempWWMT.setTargetModel obj tempWWMT
			if (findItem tmpArray tempWWMT.target == 0) then (
				append tmpArray tempWWMT.target
			)
		)
		wwmts = for obj in wwmts WHERE isValidNode obj AND isProperty obj #wwmt_ca AND obj.wwmt_ca == true collect obj
	)
	function addWWMT obj = (
		if isValidNode obj AND findItem wwmts obj == 0 then (
			local tempWWMT = ww_LOD_wrapper()
			tempWWMT.init()
			tempWWMT.setTargetModel obj tempWWMT
			if (findItem wwmts tempWWMT.target == 0) then (
				append wwmts tempWWMT.target
			)
		)
	)

	function removeWWMT obj = (
		local index = findItem wwmts obj
		if index != 0 then (
			deleteItem wwmts index
			sanitize()
		)
	)

	function updateItemsList = (
		if isValidNode (getNode()) then (
			sanitize()
			paramrollout.cmboItems.items = for obj in wwmts collect obj.name
		)

	)

	function hilightItems = (
		if wwmts.count > 0 OR thisNode.children.count > 0 then (
			nodeList = #()
			join nodeList (wwmts as Array)
			join nodeList (for obj in thisNode.children collect obj)
			flashNodes nodeList
			forceCompleteredraw()
		)
	)

	function filterFunction obj = (isProperty obj #wwmt_ca)

	function sendBonesToWWMT wwmt recurse:false = (
		getNode()
		if isValidNode thisNode AND isValidNode thisNode.parent then (
			local p = thisNode.parent
			if isProperty p #bonelist AND isProperty wwmt #bonelist then (
				local bns = #()
				join bns p.bonelist
				join bns wwmt.bonelist
				for t in p.targets do (
					if findItem wwmt.targets t == 0 then (
						append bns t
					)
				)

				bns = makeUniqueArray bns
				wwmt.bonelist = bns

				if recurse == true then (
					local morebgs = for obj in wwmt.children WHERE isProperty obj #bodygroup collect obj
					for obj in morebgs do (
						obj.sendBonesToBodygroup wwmt recurse:true
					)
				)
				true
			) else (
				false
			)
		) else (
			false
		)
	)

	function sendBonesToBodygroup recurse:false = (
		getNode()
		if isValidNode thisNode AND isValidNode thisNode.parent then (
			if wwmts.count > 0 then (
				for wwmt in wwmts do (
					sendBonesToWWMT wwmt recurse:recurse
				)
				true
			) else (
				false
			)

		) else (
			false
		)
	)

	rollout paramrollout "Bodygroup" (
		ListBox cmboItems "WWMT Helpers"
		PickButton addItem "Add WWMT" filter:filterFunction
		Button removeSelected "Remove Selected"
		Button btnHilight "Flash All"

		Group "Utilities" (
			Button btnSendBonesToSel "Send Parent Bones To Selected"
			Button btnSendBonesToAll "Send Parent Bones to All"
		)

		on btnSendBonesToAll pressed do (
			sendBonesToBodygroup()
		)

		on btnSendBonesToSel pressed do (
			if cmboItems.selection > 0 then (
				if (NOT (sendBonesToWWMT wwmts[cmboItems.selection] recurse:false)) then (
					messageBox "The bones were not updated, possibly because the WWMT Helpers are corrupt."
				)
			)
		)

		on btnSendBonesToSel pressed do (
			if cmboItems.selection > 0 then (
				sendBonesToWWMT wwmts[cmboItems.selection] recurse:false
			)
		)

		on btnSendBonesToSel rightClick do (
			if cmboItems.selection > 0 then (
				sendBonesToWWMT wwmts[cmboItems.selection] recurse:true
			)
		)

		on btnSendBonesToSel rightClick do (
			if cmboItems.selection > 0 then (
				sendBonesToWWMT wwmts[cmboItems.selection] recurse:true
			)
		)

		on btnHilight pressed do (
			hilightItems()
		)

		on paramrollout open do (
			sanitize()
		)
		on addItem picked obj do (
			if findItem wwmts obj == 0 then (
				addWWMT obj
				updateItemsList()
			)
		)
		on removeSelected pressed do (
			if cmboItems.selection > 0 then (
				deleteItem wwmts cmboItems.selection
				updateItemsList()
			)
		)

	)

)