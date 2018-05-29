
function guessRefName obj = (
	local theName = obj.name
	local referenceNames = #()
	local weightRefNames = #()
	local hasFoundName = false

	local hbones = case theName of (
		"ValveBiped.Bip01_Head1" : #(
			"head", "jaw",
			"oris01", "oris02",
			"oris03.L", "oris04.L",
			"oris03.R", "oris04.R",
			"oris05", "oris06",
			"oris06.L", "oris07.L",
			"oris06.R", "oris07.R",

			"tongue00", "tongue01", "tongue02", "tongue03", "tongue04",
			"tongue05.L", "tongue06.L", "tongue07.L",
			"tongue05.R", "tongue06.R", "tongue07.R",

			"levator02.L", "levator03.L", "levator04.L", "levator05.L", "levator06.L",
			"levator02.R", "levator03.R", "levator04.R", "levator05.R", "levator06.R",

			"special01", "special03", "special04",
			"special05.L", "special06.L",
			"special05.R", "special06.R",

			"eye.L", "eye.R",

			"orbicularis03.L", "orbicularis04.L",
			"orbicularis03.R", "orbicularis04.R",

			"temporalis01.L", "temporalis02.L",
			"temporalis01.R", "temporalis02.R",

			"oculi01.L", "oculi02.L",
			"oculi01.R", "oculi02.R",

			"risorius02.L", "risorius03.L",
			"risorius02.R", "risorius03.R"
		)
		"ValveBiped.Bip01" : #("root")
		"ValveBiped.Bip01_Neck1" : #("neck01", "neck02", "neck03")
		"ValveBiped.Bip01_Pelvis" : #("pelvis.R", "pelvis.L")
		"ValveBiped.Bip01_Spine" : #("spine04", "spine05")
		"ValveBiped.Bip01_Spine1" : #("spine03")
		"ValveBiped.Bip01_Spine2" : #("spine02")

		-- BEGIN LEFT
		"ValveBiped.Bip01_L_Clavicle" : #("clavicle.L")
		"ValveBiped.Bip01_L_Trapezius" : #("shoulder01.L")
		"ValveBiped.Bip01_L_UpperArm" : #("shoulder02.L")
		"ValveBiped.Bip01_L_UpperArm" : #("upperarm02.L")
		"ValveBiped.Bip01_L_Pectoral" : #("breast.L")
		"ValveBiped.Bip01_L_Elbow" : #("lowerarm01.L")
		"ValveBiped.Bip01_L_Forearm" : #("lowerarm02.L")
		"ValveBiped.Bip01_L_Hand" : #("wrist.L", "metacarpal1.L", "metacarpal2.L", "metacarpal3.L", "metacarpal4.L")
		"ValveBiped.Bip01_L_Thigh" : #("upperleg01.L")
		"ValveBiped.Bip01_L_Quadricep" : #("upperleg02.L")
		"ValveBiped.Bip01_L_Calf" : #("lowerleg01.L")
		"ValveBiped.Bip01_L_Shin" : #("lowerleg02.L")
		"ValveBiped.Bip01_L_Foot" : #("foot.L")
		"ValveBiped.Bip01_L_Toe0" : #("toe1-1.L", "toe1-2.L", "toe2-1.L", "toe2-2.L", "toe2-3.L", "toe3-1.L", "toe3-2.L", "toe3-3.L", "toe4-1.L", "toe4-2.L", "toe4-3.L", "toe5-1.L", "toe5-2.L", "toe5-3.L")
		--END LEFT

		--START RIGHT
		"ValveBiped.Bip01_R_Clavicle" : #("clavicle.R")
		"ValveBiped.Bip01_R_Trapezius" : #("shoulder01.R")
		"ValveBiped.Bip01_R_UpperArm" : #("shoulder02.R")
		"ValveBiped.Bip01_R_UpperArm" : #("upperarm02.R")
		"ValveBiped.Bip01_R_Pectoral" : #("breast.R")
		"ValveBiped.Bip01_R_Elbow" : #("lowerarm01.R")
		"ValveBiped.Bip01_R_Forearm" : #("lowerarm02.R")
		"ValveBiped.Bip01_R_Hand" : #("wrist.R", "metacarpal1.R", "metacarpal2.R", "metacarpal3.R", "metacarpal4.R")
		"ValveBiped.Bip01_R_Thigh" : #("upperleg01.R")
		"ValveBiped.Bip01_R_Quadricep" : #("upperleg02.R")
		"ValveBiped.Bip01_R_Calf" : #("lowerleg01.R")
		"ValveBiped.Bip01_R_Shin" : #("lowerleg02.R")
		"ValveBiped.Bip01_R_Foot" : #("foot.R")
		"ValveBiped.Bip01_R_Toe0" : #("toe1-1.R", "toe1-2.R", "toe2-1.R", "toe2-2.R", "toe2-3.R", "toe3-1.R", "toe3-2.R", "toe3-3.R", "toe4-1.R", "toe4-2.R", "toe4-3.R", "toe5-1.R", "toe5-2.R", "toe5-3.R")
		--END RIGHT

		default: "~~UNKNOWN~~"
	)

	if hbones != "~~UNKNOWN" then (
		for n in hbones do (
			append referenceNames n
			append weightRefNames n
		)
		hasFoundName = true
	) else (
		local VdigitNames = #()
		local MdigitNames = #()

		for x = 0 to 4 do (
			local vName1 = "ValveBiped.Bip01_L_Finger" + (x as String)
			append VdigitNames vName1
			append MdigitNames ("finger" + ((x + 1) as String) + "-1.L")
			local vName2 = "ValveBiped.Bip01_R_Finger" + (x as String)
			append VdigitNames vName2
			append MdigitNames ("finger" + ((x + 1) as String) + "-1.R")
			for d = 1 to 2 do (
				append VdigitNames (vName1 + (d as String))
				append MdigitNames ("finger" + ((x + 1) as String) + "-" + ((d + 1) as String) + ".L")
				append VdigitNames (vName2 + (d as String))
				append MdigitNames ("finger" + ((x + 1) as String) + "-" + ((d + 1) as String) + ".R")
			)
		)

		local index = findItem VdigitNames theName
		if index != 0 then (
			n = MdigitNames[index]
			append referenceNames n
			append weightRefNames n
		)
	)

	if false AND NOT hasFoundName then (
		local pats = #("_", " ")
		for pat in pats while hasFoundName == false do (
			local parseName = filterString (toLower theName) pat
			local isLeft = false
			local isRight = false
			if matchPattern theName pattern:"*left*" OR findItem parseName "l" > 0 OR findItem parseName "left" > 0 then (
				isLeft = true
			) else if matchPattern theName pattern:"*right*" OR findItem parseName "r" > 0 OR findItem parseName "right" > 0 then (
				isRight = true
			)
		)
	)

	(#(referenceNames, weightRefNames))
)

rollout wallworm_MaxToMakeHuman "Max Rig to MakeHuman Rig" width: 300 (
	function sortArrayByHeirarchy objectArray = (
		/*
		This function from http://forums.cgsociety.org/archive/index.php/t-577535.html
		*/
		sortedArray = #()
		childArray = #()
		-- first find roots and put them at left
		for obj in objectArray WHERE isValidNode obj do(
			if (findItem objectArray obj.parent) == 0 then (
				append sortedArray obj
			)
			else append childArray obj
		)
		-- now insert children on immediate right of their parents
		-- repeat scan until child array is empty
		while childArray.count > 0 do (
			i = 1
			while i <= childArray.count do(
				parentIdx = findItem sortedArray childArray[i].parent
				if parentIdx != 0 then(
					insertItem childArray[i] sortedArray (parentIdx + 1)
					deleteItem childArray i
				)
				else(
					i += 1
				)
			)
		)
		sortedArray
	)

	EditText edtName "Name" align:#left
	EditText edtDescription "Description" align:#left
	Label lblTags "Tags (comma separate)" align:#left
	EditText edtTags "" align:#left
	EditText edtCopyright "Copyright" align:#left
	EditText edtLicense "Description" text:"GNU Affero General Public License 3" align:#left
	EditText edtVersion "Version" text:"102" align:#left

	Button exportSelectedObjs "Export" width:200

	on exportSelectedObjs pressed do (
		local filename = getSaveFileName "Choose a File Name"
		if filename != undefined then (
			local objs = sortArrayByHeirarchy (selection as Array)
			local objcount = objs.count

			local boneString = "
		\"%\": {
			\"head\": \"%_head\",
			\"parent\": %,
			\"reference\": %,
			%
			\"roll\": %,
			\"tail\": \"%_tail\"
		}%"

			if objs.count > 0 then (
				local out = StringStream ""
				local joints = StringStream ""
				local comma = ","
				format "{\n\t\"bones\": {" to:out
				local ccount = 13606
				for c = 1 to objcount do (
					local thisComma = ""
					if c != objcount then (
						thisComma = comma
					)
					local obj = objs[c]
					local objName = obj.name
					local parentName = "null"
					if isValidNode obj.parent then (
						parentName = "\"" + obj.parent.name + "\""
					)
					local roll = 0
					local theRot = in coordsys world obj.rotation as EulerAngles
					roll = degToRad (theRot.x)

					local refnamestr = StringStream ""
					local refnamestr2 = StringStream ""

					local referenceName = #()
					local weightRefNames = #()
					if isProperty obj #referenceNames AND obj.referenceNames.count > 0 then (
						referenceName = obj.referenceNames
						weightRefNames = obj.weightRefNames
					) else (
						local guess = guessRefName obj
						referenceName = guess[1]
						weightRefNames = guess[2]
					)

					local refNameCount = referenceName.count
					if refNameCount > 0 then (
						format "[" to:refnamestr

						for i = 1 to refNameCount do (
							local refn =
							local icomma = ""
							if i != refNameCount then (
								icomma = comma
							)
							format "\"%\"%" referenceName[i] icomma to:refnamestr
						)
						format "]" to:refnamestr
					) else (
						format "null" to:refnamestr
					)
					local refNameCount = weightRefNames.count
					if refNameCount > 0 then (
						format "\"weights_reference\": [" to:refnamestr2
						for i = 1 to refNameCount do (
							local refn =
							local icomma = ""
							if i != refNameCount then (
								icomma = comma
							)
							format "\"%\"%" weightRefNames[i] icomma to:refnamestr2
						)
						format "]," to:refnamestr2
					)

					format boneString objName objName parentName (refnamestr as String) (refnamestr2 as String) roll objName thisComma to:out
					format "\t\t\"%_head\": [\n" obj.name to:joints
					for i = 1 to 8 do (
						local icomma = ""
						if i != 8 then (
							icomma = comma
						)
						format "\t\t\t%%\n" ccount icomma to:joints
						ccount += 1
					)
					format "\t\t],\n" to:joints

					format "\t\t\"%_tail\": [\n" obj.name to:joints
					for i = 1 to 8 do (
						local icomma = ""
						if i != 8 then (
							icomma = comma
						)
						format "\t\t\t%%\n" ccount icomma to:joints
						ccount += 1
					)
					format "\t\t]%\n" thisComma to:joints

				)
				format "\n\t},\n" to:out
				format "\t\"joints\": {\n" to:out
				format (joints as String) to:out
				format "\t},\n" to:out

				local tags = StringStream ""
				local tagArray = filterString edtTags.text ","
				join tagArray (#("wallworm"))
				local hasLooped = false
				for t in tagArray do (
					if hasLooped then (
						format comma to:tags
					)
					format "\"%\"" t to:tags
					hasLooped = true
				)
				format "\t\"copyright\": \"%\",\n" edtCopyright.text to:out
				format "\t\"description\": \"%\",\n" edtDescription.text to:out
				format "\t\"license\": \"%\",\n" edtLicense.text to:out
				format "\t\"name\": \"%\",\n" edtName.text to:out
				format "\t\"tags\": [%],\n" (tags as String) to:out
				format "\t\"version\": %\n" edtVersion.text to:out
				format "}\n" to:out
			)

			local theFile
			if doesFileExist filename then (
				theFile = openFile filename mode:"w+"
			) else (
				theFile = createFile filename
			)
			format (out as String) to:theFile
			close theFile

			shellLaunch filename ""

		)

	)

)

createDialog wallworm_MaxToMakeHuman