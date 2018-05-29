/*
Wall Worm UV Randomizer

*/

try (destroyDialog wallwormUVRandomizer) catch ()

rollout wallwormUVRandomizer "Randomize UVS" width:300 (
	Group "UVW" (
		CheckBox chkU "U" tooltip:"Randmoly Offset U coordinates" align:#left checked:true across:3
		CheckBox chkUseUStep "Step" align:#left
		Spinner spUstep "Divisions" type:#integer align:#left
		CheckBox chkV "V" tooltip:"Randmoly Offset V coordinates" align:#left checked:true across:3
		CheckBox chkUseVStep "Step" align:#left
		Spinner spVstep "Divisions" type:#integer align:#left
		CheckBox chkW "W" tooltip:"Randmoly Offset W coordinates" align:#left checked:false across:3
		CheckBox chkUseWStep "Step" align:#left
		Spinner spWstep "Divisions" type:#integer align:#left
	)

	function setUI = (
		spUstep.enabled = chkUseUStep.checked AND chkU.checked
		chkUseUStep.enabled = chkU.checked
		spVstep.enabled = chkUseVStep.checked AND chkV.checked
		chkUseVStep.enabled = chkV.checked
		spWstep.enabled = chkUseWStep.checked AND chkW.checked
		chkUseWStep.enabled = chkW.checked
	)

	on chkU changed stat do setUI()
	on chkV changed stat do setUI()
	on chkW changed stat do setUI()
	on chkUseUStep changed stat do setUI()
	on chkUseVStep changed stat do setUI()
	on chkUseWStep changed stat do setUI()
	on wallwormUVRandomizer open do setUI()

	CheckBox chkCollapse "Collapse to Editable Poly" tooltip:"If not on, each object will keep the UVWXform modifier."
	Button btnRandomize "Randomize on Selected Objects"

	on wallwormUVRandomizer open do (
		if ::wallwormAddUVRandomizer == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/general_purpose/wallworm_uv_functions.ms")
		)
	)

	on btnRandomize pressed do (
		if selection.count > 0 then (
			if chkU.checked OR chkV.checked OR chkW.checked then (
				::wallwormAddUVRandomizer collapseToPoly:chkCollapse.checked U_Offset:chkU.checked V_Offset:chkV.checked W_Offset:chkW.checked UStep:spUstep.value VStep:spVstep.value WStep:spWstep.value useUstep:chkUseUStep.checked useVstep:chkUseVStep.checked useWstep:chkUseWStep.checked
			) else (
				messageBox "You must use at least one of the UVW options above."
			)
		) else (
			messageBox "No objects are selected. Please select some objects"
		)
	)

)

createDialog wallwormUVRandomizer