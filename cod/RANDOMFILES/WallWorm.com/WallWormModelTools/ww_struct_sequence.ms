struct wwmt_weightlist (
	name,
	bns = #(),
	weights = #(),
	function getWeightByBoneName boneName = (
		bnIndex = findItem bns boneName
		if bnIndex != 0 AND (weights.count >= bnIndex) then (
			return (weights[bnIndex])
		)
	),
	function setWeightByBoneName boneName val = (
		bnIndex = findItem bns boneName

		if bnIndex == 0 then (
			append bns boneName
			bnIndex = bns.count
		)

		if (weights.count >= bnIndex) then (
			weights[bnIndex] = val
		) else (
			--assuming to add the next item in array
			append weights val
		)
	),
	function writeWeightListToObject obj = (
		if isValidNode obj then (
			propName = "wwmt_weightlist_" + name + "_bones"

			boneList = ""
			for b in bns do (
				append boneList (b + ",")

			)
			setUserProp obj propName boneList

			propName = "wwmt_weightlist_" + name + "_weights"
			weightList = ""
			for w in weights do (
				append weightList (w as String + ",")
			)
			setUserProp obj propName weightList

		)

	),

	function getWeightListFromObj obj = (
		if isValidNode obj then (
			propName = "wwmt_weightlist_" + name + "_bones"
			bnlist = getUserProp obj propName
			if bnlist != undefined AND bnlist != "" then (
				bnlistA = filterString bnlist ","
				if bnlistA.count > 0 then (
					bns = for b in bnlistA WHERE b != undefined AND (trimLeft(trimRight(b)) != "") collect b
				)

			)

			propName = "wwmt_weightlist_" + name + "_weights"

			weightlist = getUserProp obj propName
			if weightlist != undefined AND weightlist != "" then (
				weightlistA = filterString weightlist ","
				if weightlistA.count > 0 then (
					weights = for w in weightlistA WHERE w != undefined AND (trimLeft(trimRight(w)) != "") collect (w as Float)
				)

			)

		)

	)

)

struct wwmt_sequence(
	sequence = "idle",
	start = 0,
	end = 100,
	fps = (frameRate as Float),
	type = "Reference",
	expReverse = 0,
	loop = 1,
	events = #(),
	activity = "",
	activityWeight = -1.0,
	nd = "",
	autoplay = false,
	snap = false,
	realtime = false,
	hidden = false,
	addlayer = "",
	fadeIn = 0.2,
	fadeOut = 0.2,
	weightlist = "",
	animations = "",
	asAnimation = false,
	makeSMD = true,
	function setSequence targ = (
	),

	function sanitize = (
		if activityWeight == undefined OR activityWeight == "" then (
			activityWeight = -1.0
		) else (
			activityWeight = activityWeight as Float
		)
		if nd == undefined then (
			nd = ""
		)

		if autoplay == undefined then (
			autoplay = false
		) else (
			if autoplay == "true" OR autoplay == true then (
				autoplay = true
			) else (
				autoplay = false
			)
		)

		if snap == undefined then (
			snap = false
		) else (
			if snap == "true" OR snap == true then (
				snap = true
			) else (
				snap = false
			)
		)

		if realtime == undefined then (
			realtime = false
		) else (
			if realtime == "true" OR realtime == true then (
				realtime = true
			) else (
				realtime = false
			)
		)

		if hidden == undefined then (
			hidden = false
		) else (
			if hidden == "true" OR hidden == true then (
				hidden = true
			) else (
				hidden = false
			)
		)

		if asAnimation == undefined then (
			asAnimation = false
		) else (
			if asAnimation == "true" OR asAnimation == true then (
				asAnimation = true
			) else (
				asAnimation = false
			)
		)

		if makeSMD == undefined then (
			makeSMD = true
		) else (
			if makeSMD == "true" OR makeSMD == true then (
				makeSMD = true
			) else (
				makeSMD = false
			)
		)

		if addlayer == undefined OR addlayer == "undefined" then (
			addlayer = ""
		)

		if animations == undefined OR animations == "undefined" then (
			animations = ""
		)

		if fadeIn == undefined OR fadeIn == "" then (
			fadeIn = 0.2
		) else (
			fadeIn = fadeIn as Float
		)

		if fadeOut == undefined OR fadeOut == "" then (
			fadeOut = 0.2
		) else (
			fadeOut = fadeOut as Float
		)

		if weightlist == undefined OR weightlist == "undefined" then (
			weightlist = ""
		)
		if animations == undefined OR animations == "undefined" then (
			animations = ""
		)

		if activity == undefined then (
			activity = ""
		)

	),

	function getSequenceFromCust targ = (
		if isValidNode targ then (
			propName = "wwmt_sequence_" + sequence + "_reverse"
			expReverse = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_end"
			end = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_start"
			start = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_type"
			type = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_fps"
			fps = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_loop"
			loop = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_activity"
			activity = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_activityWeight"
			activityWeight = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_nd"
			nd = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_snap"
			snap = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_realtime"
			realtime = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_hidden"
			hidden = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_addlayer"
			addlayer = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_fadeIn"
			fadeIn = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_fadeOut"
			fadeOut = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_weightlist"
			weightlist = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_animations"
			animations = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_asAnimation"
			asAnimation = getUserProp targ propName

			propName = "wwmt_sequence_" + sequence + "_makeSMD"
			makeSMD = getUserProp targ propName

			sanitize()
		)
	)

)