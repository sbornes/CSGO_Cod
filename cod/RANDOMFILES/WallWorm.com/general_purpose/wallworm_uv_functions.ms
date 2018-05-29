/*
Wall Worm UV Randomizer

*/

function wallwormAddUVRandomizer objs:selection collapseToPoly:false U_Offset:true V_Offset:true W_Offset:false UStep:0 VStep:0 WStep:0 useUstep:false useVstep:false useWstep:false = (
	objs = for obj in objs WHERE superClassOf obj == GeometryClass collect obj
	if objs.count > 0 then (
		for obj in objs do (
			local xf = UVW_Xform()
			local step
			if U_Offset then (
				if useUstep AND UStep != 0 then (
					step = 1.0 / UStep
					xf.U_Offset = step * (random 0 (UStep as Integer))
					print xf.U_Offset
				) else (
					xf.U_Offset = random 0.0 1.0
				)
			)
			if V_Offset then (
				if useVstep AND VStep != 0 then (
					step = 1.0 / VStep
					xf.V_Offset = step * (random 0 (VStep as Integer))
				) else (
					xf.V_Offset = random 0.0 1.0
				)
			)
			if W_Offset then (
				if useWstep AND WStep != 0 then (
					step = 1.0 / WStep
					xf.W_Offset = step * (random 0 (WStep as Integer))
				) else (
					xf.W_Offset = random 0.0 1.0
				)
			)
			addModifier obj (xf)
		)

		if collapseToPoly == true then (
			ConvertToPoly objs
		)
	)
)

function wallworm_uv_weld = (
	if isProperty $ #modifiers AND validModifier $ Unwrap_UVW then (
		max modify mode
		local uvmod = $.modifiers[Unwrap_UVW]
		if uvmod == undefined then (
			uvmod = Unwrap_UVW()
			modPanel.addModToSelection uvmod
		)
		nodeUnwrap = uvmod.unwrap
		nodeUnwrap.edit()
		subObjectLevel = 1
		max select all
		nodeUnwrap.setWeldThreshold 0.01
		nodeUnwrap.weldSelected()
	)
)