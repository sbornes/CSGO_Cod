::wallwormMorphTargetCA = attributes "wallwormMorphTargetCA" version:1 (
	local wallworm = true
	local exclude_vmf = true
	local thisNode
	function getNode = (
		if thisNode == undefined then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	parameters params rollout:mainrollout (
		wrinklescale type:#float default:0.0 ui:spWrinkleScale
		suppresses type:#nodeTab tabSizeVariable:true
		usedInControllers type:#stringTab tabSizeVariable:true
	)
	rollout mainrollout "Flex Controller Info" (
		Spinner spWrinkleScale "Wrinkle Scale" align:#left tooltip:"Not currently implemented. Use a wrinklemap instead."
		ComboBox cbxsuppresses "This Shape Dominates These:" height:10
		PickButton btnPickSuppressed "Pick a Dominated Shape"
		Button btnRemoveSelected "Remove Selected"

		function sanitize = (
			suppresses = for obj in suppresses WHERE isValidNode obj collect obj
		)
		function updateSuppressList = (
			sanitize()
			cbxsuppresses.items = for obj in suppresses collect obj.name
		)
		on btnPickSuppressed picked obj do (
			if isValidNode obj then (
				append suppresses obj
				updateSuppressList()
			)
		)
		on btnRemoveSelected pressed do (
			local index = cbxsuppresses.selection
			if index > 0 then (
				if suppresses.count >= index then (
					deleteItem suppresses index
					updateSuppressList()
				)
			)
		)

		Group "Utilities" (
			Button btnAddWrinkle "Add Wrinkle Map"
		)

		on btnAddWrinkle pressed do (
			getNode()
			if thisNode.modifiers[#VertexPaint] == undefined then (
				addModifier thisNode (VertexPaint name:"wrinkle")
			)
		)

		on mainrollout open do (
			updateSuppressList()
		)
	)
)

function wallworm_add_flex_ca objs:selection = (
	for obj in objs WHERE NOT isProperty obj #wallwormMorphTargetCA do custAttributes.add obj wallwormMorphTargetCA
)
