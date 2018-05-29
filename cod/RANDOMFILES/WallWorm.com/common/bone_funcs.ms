global wallworm_bone_CA = attributes "wallworm_bone_CA" version:3 (
	local wallworm = true
	local wwmt_jointprops = true
	local vmf_export = false
	local thisNode
	local paramrollout, setUI, setContents
	function getNode = (
		if NOT isValidNode thisNode then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	parameters params rollout:paramrollout (
		useBoneProps type:#boolean default:false ui:chk_useBoneProps
		root type:#boolean default:false ui:chk_root
		alwayscollapse type:#boolean default:false ui:chk_alwayscollapse
		bonemerge type:#boolean default:false ui:chk_bonemerge
		definebone type:#boolean default:false ui:chk_definebone
		useJointProps type:#boolean default:false ui:chk_useJointProps
		rootbone type:#boolean default:false ui:chk_rootbone
		jointconstrain type:#boolean default:true ui:chk_jointconstrain
		jointskip type:#boolean default:false ui:chk_jointskip
		jointmassbias type:#float default:1.0 ui:sp_jointmassbias
		jointsurfaceprop type:#string default:"default" ui:edt_jointsurfaceprop
		jointinertia type:#float default:1 ui:sp_jointinertia
		jointcollide type:#node ui:pck_jointcollide
		jointmerge type:#node ui:pck_jointmerge
		jointcontents type:#stringtab tabSizeVariable:true
		useJiggleProps type:#boolean default:false ui:chk_useJiggleProps
		jigglebone type:#boolean default:false ui:chk_jigglebone
		jigglebone_is_rigid type:#boolean default:false ui:chk_jigglebone_is_rigid
		jigglebone_is_flexible type:#boolean default:false ui:chk_jigglebone_is_flexible
		jigglebone_has_base_spring type:#boolean default:false ui:chk_jigglebone_has_base_spring
		--is_flexible
		jigglebone_yaw_stiffness type:#float default:100 ui:sp_jigglebone_yaw_stiffness
		jigglebone_yaw_damping type:#float default:5 ui:sp_jigglebone_yaw_damping
		jigglebone_pitch_stiffness type:#float default:100 ui:sp_jigglebone_pitch_stiffness
		jigglebone_pitch_damping type:#float default:5 ui:sp_jigglebone_pitch_damping
		jigglebone_along_stiffness type:#float default:100 ui:sp_jigglebone_along_stiffness
		jigglebone_along_damping type:#float default:5 ui:sp_jigglebone_along_damping
		jigglebone_allow_length_flex type:#boolean default:false ui:chk_jigglebone_allow_length_flex
		jigglebone_tip_mass type:#float default:1 ui:sp_jigglebone_tip_mass
		jigglebone_length type:#float default:64 ui:sp_jigglebone_length
		jigglebone_angle_constraint type:#float default:-90 ui:sp_jigglebone_angle_constraint
		use_jigglebone_yaw_constraint type:#boolean default:false ui:chk_use_jigglebone_yaw_constraint
		jigglebone_yaw_constraint_min type:#float default:-90 ui:sp_jigglebone_yaw_constraint_min --yaw_constraint min
		jigglebone_yaw_constraint_max type:#float default:90 ui:sp_jigglebone_yaw_constraint_max -- yaw_constraint max
		jigglebone_yaw_friction type:#float default:1 ui:sp_jigglebone_yaw_friction
		jigglebone_pitch_constraint type:#float default:0 ui:sp_jigglebone_pitch_constraint
		jigglebone_pitch_constraint_max type:#float default:0 ui:sp_jigglebone_pitch_constraint_max
		jigglebone_pitch_friction type:#float default:1 ui:sp_jigglebone_pitch_friction
		--is_rigid
		jigglebone_is_rigid_tip_mass type:#float default:1 ui:sp_jigglebone_is_rigid_tip_mass
		jigglebone_is_rigid_length type:#float default:64 ui:sp_jigglebone_is_rigid_length
		jigglebone_is_rigid_angle_constraint type:#float default:-90 ui:sp_jigglebone_is_rigid_angle_constraint
		use_jigglebone_is_rigid_yaw_constraint type:#boolean default:false ui:chk_use_jigglebone_is_rigid_yaw_constraint
		jigglebone_is_rigid_yaw_constraint_min type:#float default:-90 ui:sp_jigglebone_is_rigid_yaw_constraint_min --yaw_constraint min
		jigglebone_is_rigid_yaw_constraint_max type:#float default:90 ui:sp_jigglebone_is_rigid_yaw_constraint_max -- yaw_constraint max
		jigglebone_is_rigid_yaw_friction type:#float default:1 ui:sp_jigglebone_is_rigid_yaw_friction
		jigglebone_is_rigid_pitch_constraint type:#float default:0 ui:sp_jigglebone_is_rigid_pitch_constraint
		jigglebone_is_rigid_pitch_constraint_max type:#float default:0 ui:sp_jigglebone_is_rigid_pitch_constraint_max
		jigglebone_is_rigid_pitch_friction type:#float default:1 ui:sp_jigglebone_is_rigid_pitch_friction
		--next for has_base_spring
		jigglebone_stiffness type:#float default:100 ui:sp_jigglebone_stiffness
		jigglebone_damping type:#float default:5 ui:sp_jigglebone_damping
		jigglebone_left_constraint type:#float default:0 ui:sp_jigglebone_left_constraint
		jigglebone_left_constraint_max type:#float default:0 ui:sp_jigglebone_left_constraint_max
		jigglebone_left_friction type:#float default:1 ui:sp_jigglebone_left_friction
		jigglebone_up_constraint type:#float default:0 ui:sp_jigglebone_up_constraint
		jigglebone_up_constraint_max type:#float default:0 ui:sp_jigglebone_up_constraint_max
		jigglebone_up_friction type:#float default:1 ui:sp_jigglebone_up_friction
		jigglebone_forward_constraint type:#float default:0 ui:sp_jigglebone_forward_constraint
		jigglebone_forward_constraint_max type:#float default:0 ui:sp_jigglebone_forward_constraint_max
		jigglebone_forward_friction type:#float default:1 ui:sp_jigglebone_forward_friction
		--is_flexible
		use_jigglebone_yaw_stiffness type:#boolean default:false ui:chk_jigglebone_yaw_stiffness
		use_jigglebone_yaw_damping type:#boolean default:false ui:chk_jigglebone_yaw_damping
		use_jigglebone_pitch_stiffness type:#boolean default:false ui:chk_jigglebone_pitch_stiffness
		use_jigglebone_pitch_damping type:#boolean default:false ui:chk_jigglebone_pitch_damping
		use_jigglebone_along_stiffness type:#boolean default:false ui:chk_jigglebone_along_stiffness
		use_jigglebone_along_damping type:#boolean default:false ui:chk_jigglebone_along_damping
		use_jigglebone_tip_mass type:#boolean default:false ui:chk_jigglebone_tip_mass
		use_jigglebone_length type:#boolean default:false ui:chk_jigglebone_length
		use_jigglebone_angle_constraint type:#boolean default:false ui:chk_jigglebone_angle_constraint
		use_jigglebone_yaw_friction type:#boolean default:false ui:chk_jigglebone_yaw_friction
		use_jigglebone_pitch_constraint type:#boolean default:false ui:chk_jigglebone_pitch_constraint
		use_jigglebone_pitch_friction type:#boolean default:false ui:chk_jigglebone_pitch_friction
		--next group for is_rigid or is_flexible
		use_jigglebone_is_rigid_tip_mass type:#boolean default:false ui:chk_jigglebone_is_rigid_tip_mass
		use_jigglebone_is_rigid_length type:#boolean default:false ui:chk_jigglebone_is_rigid_length
		use_jigglebone_is_rigid_angle_constraint type:#boolean default:false ui:chk_jigglebone_is_rigid_angle_constraint
		use_jigglebone_is_rigid_yaw_friction type:#boolean default:false ui:chk_jigglebone_is_rigid_yaw_friction
		use_jigglebone_is_rigid_pitch_constraint type:#boolean default:false ui:chk_jigglebone_is_rigid_pitch_constraint
		use_jigglebone_is_rigid_pitch_friction type:#boolean default:false ui:chk_jigglebone_is_rigid_pitch_friction
		--next for has_base_spring
		use_jigglebone_stiffness type:#boolean default:false ui:chk_jigglebone_stiffness
		use_jigglebone_damping type:#boolean default:false ui:chk_jigglebone_damping
		use_jigglebone_left_constraint type:#boolean default:false ui:chk_jigglebone_left_constraint
		use_jigglebone_left_friction type:#boolean default:false ui:chk_jigglebone_left_friction
		use_jigglebone_up_constraint type:#boolean default:false ui:chk_jigglebone_up_constraint
		use_jigglebone_up_friction type:#boolean default:false ui:chk_jigglebone_up_friction
		use_jigglebone_forward_constraint type:#boolean default:false ui:chk_jigglebone_forward_constraint
		use_jigglebone_forward_friction type:#boolean default:false ui:chk_jigglebone_forward_friction
		on useBoneProps set val do setUI()
		on useJointProps set val do setUI()
		on jointconstrain set val do setUI()
		on useJiggleProps set val do setUI()
		on jigglebone set val do setUI()
		on jigglebone_is_rigid set val do (
			if jigglebone_is_rigid == true then (
				jigglebone_is_flexible = false
			)
			setUI()
		)
		on jigglebone_is_flexible set val do (
			if jigglebone_is_flexible == true then (
				jigglebone_is_rigid = false
			)
			setUI()
		)
		on jigglebone_has_base_spring set val do setUI()
	)
	parameters makehumanparams rollout:makehumanrollout (
		referenceNames type:#stringTab tabSizeVariable:true
		weightRefNames type:#stringTab tabSizeVariable:true
	)
	local makeHumanBones = sort (#("breast.L", "breast.R", "clavicle.L", "clavicle.R", "eye.L", "eye.R", "finger1-1.L", "finger1-1.R", "finger1-2.L", "finger1-2.R", "finger1-3.L", "finger1-3.R", "finger2-1.L", "finger2-1.R", "finger2-2.L", "finger2-2.R", "finger2-3.L", "finger2-3.R", "finger3-1.L", "finger3-1.R", "finger3-2.L", "finger3-2.R", "finger3-3.L", "finger3-3.R", "finger4-1.L", "finger4-1.R", "finger4-2.L", "finger4-2.R", "finger4-3.L", "finger4-3.R", "finger5-1.L", "finger5-1.R", "finger5-2.L", "finger5-2.R", "finger5-3.L", "finger5-3.R", "foot.L", "foot.R", "head", "jaw", "levator02.L", "levator02.R", "levator03.L", "levator03.R", "levator04.L", "levator04.R", "levator05.L", "levator05.R", "levator06.L", "levator06.R", "lowerarm01.L", "lowerarm01.R", "lowerarm02.L", "lowerarm02.R", "lowerleg01.L", "lowerleg01.R", "lowerleg02.L", "lowerleg02.R", "metacarpal1.L", "metacarpal1.R", "metacarpal2.L", "metacarpal2.R", "metacarpal3.L", "metacarpal3.R", "metacarpal4.L", "metacarpal4.R", "neck01", "neck02", "neck03", "oculi01.L", "oculi01.R", "oculi02.L", "oculi02.R", "orbicularis03.L", "orbicularis03.R", "orbicularis04.L", "orbicularis04.R", "oris01", "oris02", "oris03.L", "oris03.R", "oris04.L", "oris04.R", "oris05", "oris06", "oris06.L", "oris06.R", "oris07.L", "oris07.R", "pelvis.L", "pelvis.R", "risorius02.L", "risorius02.R", "risorius03.L", "risorius03.R", "root", "shoulder01.L", "shoulder01.R", "shoulder02.L", "shoulder02.R", "special01", "special03", "special04", "special05.L", "special05.R", "special06.L", "special06.R", "spine01", "spine02", "spine03", "spine04", "spine05", "temporalis01.L", "temporalis01.R", "temporalis02.L", "temporalis02.R", "toe1-1.L", "toe1-1.R", "toe1-2.L", "toe1-2.R", "toe2-1.L", "toe2-1.R", "toe2-2.L", "toe2-2.R", "toe2-3.L", "toe2-3.R", "toe3-1.L", "toe3-1.R", "toe3-2.L", "toe3-2.R", "toe3-3.L", "toe3-3.R", "toe4-1.L", "toe4-1.R", "toe4-2.L", "toe4-2.R", "toe4-3.L", "toe4-3.R", "toe5-1.L", "toe5-1.R", "toe5-2.L", "toe5-2.R", "toe5-3.L", "toe5-3.R", "tongue00", "tongue01", "tongue02", "tongue03", "tongue04", "tongue05.L", "tongue05.R", "tongue06.L", "tongue06.R", "tongue07.L", "tongue07.R", "upperarm02.L", "upperarm02.R", "upperleg01.L", "upperleg01.R", "upperleg02.L", "upperleg02.R", "wrist.L", "wrist.R"))

	function addNameToNameList n = (
		if n != "" AND findItem referenceNames n == 0 then (
			append referenceNames n
		)
	)
	function deleteNameToNameList n = (
		while findItem referenceNames n != 0 do (
			deleteItem referenceNames (findItem referenceNames n)
		)
	)
	function addNameToWeightList n = (
		if n != "" AND findItem weightRefNames n == 0 then (
			append weightRefNames n
		)
	)

	function deleteNameWeightList n = (
		while findItem weightRefNames n != 0 do (
			deleteItem weightRefNames (findItem weightRefNames n)
		)
	)

	function setUI = (
		paramrollout.chk_bonemerge.enabled = paramrollout.chk_root.enabled = paramrollout.chk_alwayscollapse.enabled = \
		paramrollout.edt_jointsurfaceprop.enabled = paramrollout.lbl_jointsurfaceprop.enabled = \
		paramrollout.lb_jointsurfaceprop.enabled = paramrollout.chk_definebone.enabled = useBoneProps
		paramrollout.sp_jointmassbias.enabled = \
		paramrollout.sp_jointinertia.enabled = \
		paramrollout.pck_jointcollide.enabled = \
		paramrollout.lbl_jointcollide.enabled = \
		paramrollout.lbl_jointmerge.enabled = \
		paramrollout.pck_jointmerge.enabled = \
		paramrollout.chk_jointconstrain.enabled = \
		paramrollout.chk_rootbone.enabled = \
		paramrollout.btn_clearcollide.enabled = \
		paramrollout.btn_jointmerge.enabled = \
		paramrollout.chk_jointskip.enabled = useJointProps
		paramrollout.chk_rootbone.enabled = (useJointProps AND NOT jointconstrain)
		paramrollout.chk_jigglebone.enabled = useJiggleProps
		paramrollout.chk_jigglebone_is_flexible.enabled = \
		paramrollout.chk_jigglebone_is_rigid.enabled = \
		paramrollout.chk_jigglebone_has_base_spring.enabled = useJiggleProps AND jigglebone
		--is_flexible
		paramrollout.chk_jigglebone_yaw_stiffness.enabled = \
		paramrollout.sp_jigglebone_yaw_stiffness.enabled = \
		paramrollout.chk_jigglebone_yaw_damping.enabled = \
		paramrollout.sp_jigglebone_yaw_damping.enabled = \
		paramrollout.chk_jigglebone_pitch_stiffness.enabled = \
		paramrollout.sp_jigglebone_pitch_stiffness.enabled = \
		paramrollout.chk_jigglebone_pitch_damping.enabled = \
		paramrollout.sp_jigglebone_pitch_damping.enabled = \
		paramrollout.chk_jigglebone_along_stiffness.enabled = \
		paramrollout.sp_jigglebone_along_stiffness.enabled = \
		paramrollout.chk_jigglebone_along_damping.enabled = \
		paramrollout.sp_jigglebone_along_damping.enabled = \
		paramrollout.chk_jigglebone_allow_length_flex.enabled = (useJiggleProps AND jigglebone AND jigglebone_is_flexible)
		--next group for is_rigid or is_flexible
		paramrollout.chk_jigglebone_tip_mass.enabled = \
		paramrollout.sp_jigglebone_tip_mass.enabled = \
		paramrollout.chk_jigglebone_length.enabled = \
		paramrollout.sp_jigglebone_length.enabled = \
		paramrollout.chk_jigglebone_angle_constraint.enabled = \
		paramrollout.sp_jigglebone_angle_constraint.enabled = \
		paramrollout.chk_jigglebone_yaw_friction.enabled = \
		paramrollout.sp_jigglebone_yaw_friction.enabled = \
		paramrollout.chk_jigglebone_pitch_constraint.enabled = \
		paramrollout.sp_jigglebone_pitch_constraint.enabled = \
		paramrollout.sp_jigglebone_pitch_constraint_max.enabled = \
		paramrollout.chk_jigglebone_pitch_friction.enabled = \
		paramrollout.sp_jigglebone_pitch_friction.enabled = \
		paramrollout.chk_use_jigglebone_yaw_constraint.enabled = \
		paramrollout.sp_jigglebone_yaw_constraint_min.enabled = \
		paramrollout.lbl_to.enabled = \
		paramrollout.sp_jigglebone_yaw_constraint_max.enabled = (useJiggleProps AND jigglebone AND jigglebone_is_flexible) -- yaw_constraint max
		--next group for is_rigid or is_flexible
		paramrollout.chk_jigglebone_is_rigid_tip_mass.enabled = \
		paramrollout.sp_jigglebone_is_rigid_tip_mass.enabled = \
		paramrollout.chk_jigglebone_is_rigid_length.enabled = \
		paramrollout.sp_jigglebone_is_rigid_length.enabled = \
		paramrollout.chk_jigglebone_is_rigid_angle_constraint.enabled = \
		paramrollout.sp_jigglebone_is_rigid_angle_constraint.enabled = \
		paramrollout.chk_jigglebone_is_rigid_yaw_friction.enabled = \
		paramrollout.sp_jigglebone_is_rigid_yaw_friction.enabled = \
		paramrollout.chk_jigglebone_is_rigid_pitch_constraint.enabled = \
		paramrollout.sp_jigglebone_is_rigid_pitch_constraint.enabled = \
		paramrollout.sp_jigglebone_is_rigid_pitch_constraint_max.enabled = \
		paramrollout.chk_jigglebone_is_rigid_pitch_friction.enabled = \
		paramrollout.sp_jigglebone_is_rigid_pitch_friction.enabled = \
		paramrollout.chk_use_jigglebone_is_rigid_yaw_constraint.enabled = \
		paramrollout.sp_jigglebone_is_rigid_yaw_constraint_min.enabled = \
		paramrollout.lbl_to.enabled = \
		paramrollout.sp_jigglebone_is_rigid_yaw_constraint_max.enabled = (useJiggleProps AND jigglebone AND jigglebone_is_rigid) -- yaw_constraint max
		--next for has_base_spring
		paramrollout.chk_jigglebone_stiffness.enabled = \
		paramrollout.sp_jigglebone_stiffness.enabled = \
		paramrollout.chk_jigglebone_damping.enabled = \
		paramrollout.sp_jigglebone_damping.enabled = \
		paramrollout.chk_jigglebone_left_constraint.enabled = \
		paramrollout.sp_jigglebone_left_constraint.enabled = \
		paramrollout.sp_jigglebone_left_constraint_max.enabled = \
		paramrollout.chk_jigglebone_left_friction.enabled = \
		paramrollout.sp_jigglebone_left_friction.enabled = \
		paramrollout.chk_jigglebone_up_constraint.enabled = \
		paramrollout.sp_jigglebone_up_constraint.enabled = \
		paramrollout.sp_jigglebone_up_constraint_max.enabled = \
		paramrollout.chk_jigglebone_up_friction.enabled = \
		paramrollout.sp_jigglebone_up_friction.enabled = \
		paramrollout.chk_jigglebone_forward_constraint.enabled = \
		paramrollout.sp_jigglebone_forward_constraint.enabled = \
		paramrollout.sp_jigglebone_forward_constraint_max.enabled = \
		paramrollout.chk_jigglebone_forward_friction.enabled = \
		paramrollout.sp_jigglebone_forward_friction.enabled = (useJiggleProps AND jigglebone AND jigglebone_has_base_spring)
	)
	function setContents = (
		paramrollout.cmb_jointcontents.items = sort (for c in jointcontents WHERE c != undefined AND c != "" collect c)
	)
	function addJointcontents c = (
		if findItem jointcontents c == 0 then (
			append jointcontents c
			setContents()
			paramrollout.cmb_jointcontents.selection = findItem paramrollout.cmb_jointcontents.items c
		)
	)
	function delJointcontents c = (
		local index = findItem jointcontents c
		if index != 0 then (
			deleteItem jointcontents index
			setContents()
			paramrollout.cmb_jointcontents.selection = 0
		)
	)
	function getSurfaceProps = (
		getNode()
		local out = #(jointsurfaceprop)
		if ::wallworm_get_hierarchy_root != undefined then (
			local root = ::wallworm_get_hierarchy_root thisNode

			if isValidNode root then (
				local collection
				::wallworm_getAllChildren root &collection
				collection = for bn in collection WHERE isValidNode bn AND (isProperty bn #wwmt_bone_ca) OR (getUserProp bn #wwmt_surfaceprop_bone != undefined) collect bn

				for bn in collection WHERE NOT isProperty bn #wallworm_bone_CA do (
					::wallworm_bone_CA bn
				)

				out = for bn in collection collect hb.jointsurfaceprop
			)

		)

		append out "default"
		out = makeUniqueArray out
		sort out
		out
	)
	function getJiggleFromIK = (
		getNode()
		ba = ik.getAxisSpringOn thisNode #rotational
		if ba != undefined then (
			if (findItem ba 1 > 0 OR findItem ba 2 > 0 OR findItem ba 3 > 0) then (
				useJiggleProps = true
				jigglebone = true
				jigglebone_is_flexible = true
				min = ik.getAxisMin thisNode #rotational
				bmax = ik.getAxisMax thisNode #rotational
				tensions = ik.getAxisSpringTension thisNode #rotational
				dampings = ik.getAxisDamping thisNode #rotational
				for bIndex = 1 to 3 do (
					local axis
					case bIndex of (
						1:(axis = "yaw")
						2:(axis = "pitch")
						3:(axis = "along")
					)
					if findItem ba bIndex > 0 then (
						local propName
						if tensions[bIndex] != undefined then (
							propName = "jigglebone_" + axis + "_stiffness"
							setProperty thisNOde propName (tensions[bIndex] * 20)
							propName = "use_" + propName
							setProperty thisNOde propName true
						)
						if dampings[bIndex] != undefined then (
							propName = "jigglebone_" + axis + "_damping"
							setProperty thisNOde propName (dampings[bIndex] * 10)
							propName = "use_" + propName
							setProperty thisNOde propName true
						)
						if bIndex < 3 AND min[bIndex] != undefined AND bmax[bIndex] != undefined then (
							propName = "jigglebone_" + axis + "_constraint"

							local propName1 = "use_" + propName
							setProperty thisNOde propName1 true
							if bIndex == 1 then (
								propName += "_min"
							)
							setProperty thisNOde propName min[bIndex]
							propName = "jigglebone_" + axis + "_constraint_max"
							setProperty thisNOde propName bmax[bIndex]
						)
					)
				)
			)
		)
	)
	rollout paramrollout "QC Bone Properties" (
		Group "General Bone Properties" (
			CheckBox chk_useBoneProps "Use General Bone Properties"
			CheckBox chk_definebone "Add $definebone to QC"
			CheckBox chk_bonemerge "$bonemerge" enabled:useBoneProps
			CheckBox chk_alwayscollapse "$alwayscollapse"
			CheckBox chk_root "SMD Root" tooltip:"Sets this bone as the root. Generally, you should set this via WWMT instead of in this setting." enabled:useBoneProps
			Label lbl_jointsurfaceprop "$jointsurfaceprop" enabled:useBoneProps
			EditText edt_jointsurfaceprop "" enabled:useBoneProps
			ListBox lb_jointsurfaceprop "" enabled:useBoneProps
		)
		Group "Collision Model Joints" (
			CheckBox chk_useJointProps "Use Collision Model Properties"
			CheckBox chk_jointconstrain "$jointconstrain" enabled:useJointProps tooltip:"This bone will output a $jointconstrain entry if it has a parent node. The $jointconstrain values are dependent on the Max IK values."
			CheckBox chk_rootbone "$rootbone" enabled:(useJointProps AND NOT jointconstrain)
			CheckBox chk_jointskip "$jointskip" default:false enabled:useJointProps
			Spinner sp_jointmassbias "Mass Bias" type:#float range:[-256, 256, 1] align:#right enabled:useJointProps
			Spinner sp_jointinertia "Joint Inertia" type:#float range:[-256, 256, 1] align:#right enabled:useJointProps
			Label lbl_jointcollide "$jointcollide" enabled:useJointProps align:#left
			PickButton pck_jointcollide "Pick $jointcollide" enabled:useJointProps across:2 align:#left
			Button btn_clearcollide "-" enabled:useJointProps align:#right
			Label lbl_jointmerge "$jointmerge" enabled:useJointProps align:#left
			PickButton pck_jointmerge "Pick Node to Merge" enabled:useJointProps across:2 align:#left
			Button btn_jointmerge "-" enabled:useJointProps align:#right
			Label lbl_jointcontents "Joint Contents" align:#left across:3
			Button addContent "+" align:#right
			Button delSel "-" align:#right
			ComboBox cmb_jointcontents ""
			Button btnGrate "G" tooltip:"Grate - Solid to everything except bullets or line of site." across:5
			Button btnMonster "M" tooltip:"Monster - Marks as NPC."
			Button btnNotSolid "N" tooltip:"Not Solid to anything."
			Button btnSolid "S" tooltip:"Solid - Default Value if nothing is set."
			Button btnLadder "L" tooltip:"Ladder"
			on btnGrate pressed do (
				addJointcontents "grate"
			)
			on btnMonster pressed do (
				addJointcontents "monster"
			)
			on btnNotSolid pressed do (
				addJointcontents "notsolid"
			)
			on btnSolid pressed do (
				addJointcontents "solid"
			)
			on btnLadder pressed do (
				addJointcontents "ladder"
			)

			on addContent pressed do (
				if cmb_jointcontents.text != "" then (
					addJointcontents cmb_jointcontents.text
				)
			)

			on delSel pressed do (
				if cmb_jointcontents.selection != 0 then (
					delJointcontents cmb_jointcontents.text
				)
			)

			on pck_jointcollide picked obj do (
				if isValidNode obj then (
					jointcollide = obj
				)
			)
			on btn_clearcollide pressed do (
				jointcollide = undefined
			)

			on pck_jointmerge picked obj do (
				if isValidNode obj then (
					jointmerge = obj
				)
			)
			on btn_jointmerge pressed do (
				jointmerge = undefined
			)
		)

		CheckBox chk_useJiggleProps "Use Jiggle Properties"
		CheckBox chk_jigglebone "Is Jigglebone"

		--is_flexible
		Group "Flexible Properties" (
			CheckBox chk_jigglebone_is_flexible "Is Flexible"
			CheckBox chk_jigglebone_yaw_stiffness "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_yaw_stiffness "Yaw Stiffness" align:#right range:[1.0, 1000.0, 100] step:1.0 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_yaw_damping "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_yaw_damping "Yaw Damping" type:#float default:5 align:#right range:[0.0, 10.0, 5.0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_pitch_stiffness "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_pitch_stiffness "Pitch Stiffness" type:#float align:#right range:[1.0, 1000.0, 100] step:1.0 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_pitch_damping "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_pitch_damping "Pitch Damping" type:#float align:#right range:[0.0, 10.0, 5.0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_along_stiffness "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_along_stiffness "Along Stiffness" type:#float align:#right range:[1.0, 1000.0, 100] step:1.0 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_along_damping "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_along_damping "Along Damping" type:#float align:#right range:[0.0, 10.0, 5.0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:160
			CheckBox chk_jigglebone_allow_length_flex "Allow Length Flex" enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible)

			--next group for is_rigid or is_flexible
			CheckBox chk_jigglebone_tip_mass "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_tip_mass "Tip Mass" type:#float range:[0.0, 10.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#right width:160
			CheckBox chk_jigglebone_length "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_length "Length" type:#float range:[-1024.0, 1024.0, 64.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#right width:160

			CheckBox chk_jigglebone_angle_constraint "" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10 across:2
			Spinner sp_jigglebone_angle_constraint "Angle Constraint" type:#float range:[-90.0, 90.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#right width:160

			CheckBox chk_jigglebone_yaw_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_yaw_friction "Yaw Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#right width:160

			CheckBox chk_jigglebone_pitch_constraint "Pitch Constraint" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible)
			Spinner sp_jigglebone_pitch_constraint "" type:#float range:[-1024.0, 1024.0, 0.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#left across:3 width:60
			Label lbl_sp_jigglebone_pitch_constraint "to"
			Spinner sp_jigglebone_pitch_constraint_max "" type:#float range:[-1024.0, 1024.0, 0.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#left width:60 offset:[-20, 0]

			CheckBox chk_jigglebone_pitch_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:10
			Spinner sp_jigglebone_pitch_friction "Pitch Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) align:#right width:160

			CheckBox chk_use_jigglebone_yaw_constraint "Use Yaw Constraint" enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible)
			Spinner sp_jigglebone_yaw_constraint_min type:#float across:3 align:#left range:[-90, 90, 0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:60 --yaw_constraint min
			Label lbl_to "to"
			Spinner sp_jigglebone_yaw_constraint_max type:#float align:#left range:[-90, 90, 0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_flexible) width:60 offset:[-20, 0]-- yaw_constraint max

			Button setFromIK "Get IK Data" tooltip:"Convert some of the IK properties from the bone's IK. Sets values to those used in the legacy WWMT QC exporter."

			on setFromIK pressed do (
				getJiggleFromIK()
			)
			--next group for is_rigid or is_flexible
		)
		Group "Rigid Properties" (
			CheckBox chk_jigglebone_is_rigid "Is Rigid"
			CheckBox chk_jigglebone_is_rigid_tip_mass "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:10
			Spinner sp_jigglebone_is_rigid_tip_mass "Tip Mass" type:#float range:[0.0, 10.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#right width:160
			CheckBox chk_jigglebone_is_rigid_length "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:10
			Spinner sp_jigglebone_is_rigid_length "Length" type:#float range:[-1024.0, 1024.0, 64.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#right width:160

			CheckBox chk_jigglebone_is_rigid_angle_constraint "" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:10 across:2
			Spinner sp_jigglebone_is_rigid_angle_constraint "Angle Constraint" type:#float range:[-90.0, 90.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#right across:3 width:160

			CheckBox chk_jigglebone_is_rigid_yaw_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:10
			Spinner sp_jigglebone_is_rigid_yaw_friction "Yaw Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#right width:160

			CheckBox chk_jigglebone_is_rigid_pitch_constraint "Pitch Constraint" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid)
			Spinner sp_jigglebone_is_rigid_pitch_constraint "" type:#float range:[-1024.0, 1024.0, 0.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#left across:3 width:60
			Label lbl_sp_jigglebone_is_rigid_pitch_constraint "to"
			Spinner sp_jigglebone_is_rigid_pitch_constraint_max "" type:#float range:[-1024.0, 1024.0, 0.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#left width:60 offset:[-20, 0]

			CheckBox chk_jigglebone_is_rigid_pitch_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:10
			Spinner sp_jigglebone_is_rigid_pitch_friction "Pitch Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) align:#right width:160

			CheckBox chk_use_jigglebone_is_rigid_yaw_constraint "Use Yaw Constraint" enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid)
			Spinner sp_jigglebone_is_rigid_yaw_constraint_min type:#float across:3 align:#left range:[-90, 90, 0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:60 --yaw_constraint min
			Label lbl_to_is_rigid "to"
			Spinner sp_jigglebone_is_rigid_yaw_constraint_max type:#float align:#left range:[-90, 90, 0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_is_rigid) width:60 offset:[-20, 0]-- yaw_constraint max

		)

		Group "Base Spring Properties" (
			CheckBox chk_jigglebone_has_base_spring "Has Base Spring"

			CheckBox chk_jigglebone_stiffness "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) width:10
			Spinner sp_jigglebone_stiffness "Stiffness" type:#float range:[0.0, 10.0, 1.0] align:#right range:[1.0, 1000.0, 100] step:1.0 enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#right width:160
			CheckBox chk_jigglebone_damping "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) width:10
			Spinner sp_jigglebone_damping "Damping" type:#float range:[0.0, 10.0, 5.0] align:#right range:[0.0, 10.0, 5.0] step:0.1 enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#right width:160

			CheckBox chk_jigglebone_left_constraint "Left Constraint" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring)
			Spinner sp_jigglebone_left_constraint "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left across:3 width:60
			Label lbl_sp_jigglebone_left_constraint "to"
			Spinner sp_jigglebone_left_constraint_max "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left width:60 offset:[-20, 0]

			CheckBox chk_jigglebone_left_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) width:10
			Spinner sp_jigglebone_left_friction "Left Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#right width:160
			CheckBox chk_jigglebone_up_constraint "Up Constraint" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring)
			Spinner sp_jigglebone_up_constraint "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left across:3 width:60
			Label lbl_sp_jigglebone_up_constraint "to"
			Spinner sp_jigglebone_up_constraint_max "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left width:60 offset:[-20, 0]

			CheckBox chk_jigglebone_up_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) width:10
			Spinner sp_jigglebone_up_friction "Up Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#right width:160
			CheckBox chk_jigglebone_forward_constraint "Forward Constraint" align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring)

			Spinner sp_jigglebone_forward_constraint "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left across:3 width:60
			Label lbl_sp_jigglebone_forward_constraint "to"
			Spinner sp_jigglebone_forward_constraint_max "" type:#float range:[-1024.0, 1024.0, 0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#left width:60 offset:[-20, 0]
			CheckBox chk_jigglebone_forward_friction "" across:2 align:#left enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) width:10
			Spinner sp_jigglebone_forward_friction "Forward Friction" type:#float range:[0.0, 20.0, 1.0] enabled:(useJiggleProps AND jigglebone AND jigglebone_has_base_spring) align:#right
		)

		on paramrollout open do (
			setUI()
		)
	)
	rollout makehumanrollout "Make Human Connection" (
		DropDownList cmbnameOrig ""
		ComboBox cmbNames "Reference Names"
		Button btnAddName "Add" align:#left across:2
		Button btnDeleteSel "Remove Selected" align:#left offset:[-20, 0]
		DropDownList cmbnameWeightOrig ""
		ComboBox cmbweightRefNames "Weight Reference Names"
		Button btnAddWeightName "Add" align:#left across:2
		Button btnDeleteSelWeight "Remove Selected" align:#left offset:[-20, 0]

		on btnAddName pressed do (
			addNameToNameList cmbNames.text
			cmbNames.items = (referenceNames as Array)
		)
		on btnDeleteSel pressed do (
			deleteNameToNameList cmbNames.text
			cmbNames.items = (cmbNames as Array)
		)
		on cmbnameOrig selected sel do (
			addNameToNameList cmbnameOrig.selected
			cmbNames.items = (referenceNames as Array)
		)

		on btnAddWeightName pressed do (
			addNameToWeightList cmbweightRefNames.text
			cmbweightRefNames.items = (weightRefNames as Array)
		)
		on btnDeleteSelWeight pressed do (
			deleteNameWeightList cmbweightRefNames.text
			cmbweightRefNames.items = (weightRefNames as Array)
		)
		on cmbnameWeightOrig selected sel do (
			addNameToWeightList cmbnameWeightOrig.selected
			cmbweightRefNames.items = (weightRefNames as Array)
		)

		on makehumanrollout open do (
			cmbnameOrig.items = makeHumanBones
			cmbnameWeightOrig.items = makeHumanBones
		)

	)

	function outputMyBoneProps = (
		if useBoneProps then (
			local out = StringStream ""
			getNode()
			local nam = thisNode.name
			if bonemerge then (
				format "$bonemerge \"%\"\n" nam to:out
			)
			if alwayscollapse then (
				format "$alwayscollapse \"%\"\n" nam to:out
			)
			if jointsurfaceprop != "" then (
				format "\t$jointsurfaceprop \"%\" %\n" nam jointsurfaceprop to:out
			)
			out as String
		) else (
			undefined
		)

	)

	function outputMyCollisionForQC = (
		if useJointProps then (
			local out = StringStream ""
			getNode()
			local nam = thisNode.name

			if jointskip then (
				format "\t$jointskip \"%\"\n" nam to:out
			)

			format "\t$jointmassbias \"%\" %\n" nam jointmassbias to:out
			format "\t$jointinertia \"%\" %\n" nam jointinertia to:out

			if isValidNode jointcollide then (
				format "\t$jointcollide \"%\" \"%\"\n" nam jointcollide.name to:out
			)

			if isValidNode jointmerge then (
				format "\t$jointmerge \"%\" \"%\"\n" nam jointmerge.name to:out
			)

			if jointcontents.count > 0 then (
				local jcstream = StringStream "$contents"

				for c in jointcontents do (
					format " \"%\"" to:jcstream
				)
				format "\t%\n" (jcstream as String) to:out
			)
			out as String
		) else (
			undefined
		)
	)

	function outputMyJiggle = (
		if useJiggleProps then (
			local out = StringStream ""

			if jigglebone then (
				getNode()
				format "\t$jigglebone \"%\" {\n" thisNode.name to:out

				if jigglebone_has_base_spring then (
					format "\t\thas_base_spring {\n" to:out
					if use_jigglebone_stiffness then (
						format "\t\t\tstiffness %\n" jigglebone_stiffness to:out
					)
					if use_jigglebone_damping then (
						format "\t\t\tdamping %\n" jigglebone_damping to:out
					)
					if use_jigglebone_left_constraint then (
						format "\t\t\tleft_constraint % %\n" jigglebone_left_constraint jigglebone_left_constraint to:out
					)
					if use_jigglebone_left_friction then (
						format "\t\t\tleft_friction %\n" jigglebone_left_friction to:out
					)
					if use_jigglebone_up_constraint then (
						format "\t\t\tup_constraint % %\n" jigglebone_up_constraint jigglebone_up_constraint_max to:out
					)
					if use_jigglebone_up_friction then (
						format "\t\t\tup_friction %\n" jigglebone_up_friction to:out
					)
					if use_jigglebone_forward_constraint then (
						format "\t\t\tforward_constraint % %\n" jigglebone_forward_constraint jigglebone_forward_constraint_max to:out
					)
					if use_jigglebone_forward_friction then (
						format "\t\t\tforward_friction %\n" jigglebone_forward_friction to:out
					)
					format "\t\t}\n" to:out

				)

				if jigglebone_is_flexible then (
					format "\t\tis_flexible {\n" to:out
					if use_jigglebone_yaw_stiffness then (
						format "\t\t\tyaw_stiffness %\n" jigglebone_yaw_stiffness to:out
					)

					if use_jigglebone_yaw_damping then (
						format "\t\t\tyaw_damping %\n" jigglebone_yaw_damping to:out
					)
					if use_jigglebone_pitch_stiffness then (
						format "\t\t\tpitch_stiffness %\n" jigglebone_pitch_stiffness to:out
					)
					if use_jigglebone_pitch_damping then (
						format "\t\t\tpitch_damping %\n" jigglebone_pitch_damping to:out
					)
					if use_jigglebone_along_stiffness then (
						format "\t\t\talong_stiffness %\n" jigglebone_along_stiffness to:out
					)
					if use_jigglebone_along_damping then (
						format "\t\t\talong_damping %\n" jigglebone_along_damping to:out
					)
					if jigglebone_allow_length_flex then (
						format "\t\t\tallow_length_flex\n" to:out
					)

					if use_jigglebone_tip_mass then (
						format "\t\t\ttip_mass %\n" jigglebone_tip_mass to:out
					)
					if use_jigglebone_length then (
						format "\t\t\tlength %\n" jigglebone_length to:out
					)

					if use_jigglebone_angle_constraint then (
						format "\t\t\tangle_constraint %\n" jigglebone_angle_constraint to:out
					)

					if use_jigglebone_yaw_constraint then (
						format "\t\t\tyaw_constraint % %\n" jigglebone_yaw_constraint_min jigglebone_yaw_constraint_max to:out
					)

					if use_jigglebone_yaw_friction then (
						format "\t\t\tyaw_friction %\n" jigglebone_yaw_friction to:out
					)
					if use_jigglebone_pitch_constraint then (
						format "\t\t\tpitch_constraint % %\n" jigglebone_pitch_constraint jigglebone_pitch_constraint to:out
					)
					if use_jigglebone_pitch_friction then (
						format "\t\t\tpitch_friction %\n" jigglebone_pitch_friction to:out
					)

					format "\t\t}\n" to:out

				)

				if jigglebone_is_rigid then (
					format "\t\tis_rigid {\n" to:out

					if use_jigglebone_tip_mass then (
						format "\t\t\ttip_mass %\n" jigglebone_tip_mass to:out
					)
					if use_jigglebone_length then (
						format "\t\t\tlength %\n" jigglebone_length to:out
					)
					if use_jigglebone_angle_constraint then (
						format "\t\t\tangle_constraint %\n" jigglebone_angle_constraint to:out
					)
					if use_jigglebone_yaw_constraint then (
						format "\t\t\tyaw_constraint % %\n" jigglebone_yaw_constraint_min jigglebone_yaw_constraint_max to:out
					)

					if use_jigglebone_yaw_friction then (
						format "\t\t\tyaw_friction %\n" jigglebone_yaw_friction to:out
					)
					if use_jigglebone_pitch_constraint then (
						format "\t\t\tpitch_constraint % %\n" jigglebone_pitch_constraint jigglebone_pitch_constraint to:out
					)
					if use_jigglebone_pitch_friction then (
						format "\t\t\tpitch_friction %\n" jigglebone_pitch_friction to:out
					)
					format "\t\t}\n" to:out
				)

				format "\t}\n" to:out
			)

			out as String
		) else (undefined)
	)
	on clone orig do thisNode = undefined
)
function wallworm_add_bone_ca bn jointsurfaceprop:"" jointmassbias:1 jointskip:false = (
	if NOT isProperty bn #wallworm_bone_CA then (
		custAttributes.add bn ::wallworm_bone_CA
		local oldBoneInfo = ::wwmt_getBoneInfo bn
		if jointmassbias == undefined then (
			jointmassbias = oldBoneInfo[1]
			if jointmassbias != undefined then (
				jointmassbias = jointmassbias as Integer
			)
		)
		if jointsurfaceprop == undefined OR jointsurfaceprop == "" then (
			jointsurfaceprop = oldBoneInfo[2]
		)

		if jointskip != undefined then (
			jointskip = oldBoneInfo[3]
		)

	)

	if jointmassbias == undefined then (
		jointmassbias = 0
	)

	if jointsurfaceprop == undefined then (
		jointsurfaceprop = ""
	)

	bn.jointmassbias = jointmassbias as Float
	bn.jointsurfaceprop = jointsurfaceprop
	bn.jointskip = ::wallworm_makeBoolean jointskip def:false

)

function wwmt_getBoneInfo obj = (
	local wwmt_jointmassbias = getUserProp obj #wwmt_jointmassbias
	local wwmt_surfaceprop_bone = getUserProp obj #wwmt_surfaceprop_bone
	--local wwmt_animatedfriction = getUserProp obj #wwmt_animatedfriction
	local wwmt_jointskip = getUserProp obj #wwmt_jointskip
	#(wwmt_jointmassbias, wwmt_surfaceprop_bone, wwmt_jointskip)
)

function wwmt_setJointSkip obj vals:false = (
	wallworm_add_bone_ca obj jointskip:vals
	vals
)

function wwmt_setBoneMassBias obj amount:1.0 = (
	wallworm_add_bone_ca obj jointmassbias:amount
	amount
)

function wwmt_setBoneSurfaceprop obj prop:"" = (
	wallworm_add_bone_ca obj jointsurfaceprop:prop
	prop
)

function wallworm getHboxSets obj = (
	getNode()
	local out = #(hboxset)
	if ::wallworm_get_hierarchy_root != undefined then (
		local root = wallworm_get_hierarchy_root thisNode
		if isValidNode root then (
			local collection
			wallworm_getAllChildren root &collection

			collection = for hb in collection WHERE isValidNode hb AND (isProperty hb #wwmt_hitbox) OR (getUserProp hb #wwmt_hitbox == true) collect hb

			for hb in collection WHERE NOT isProperty hb #wwmt_hitbox do (
				::wallworm_add_hitbox_ca hb
			)

			out = for hb in collection collect hb.hboxset
		)
	)
	append out "default"
	out = makeUniqueArray out
	sort out
	out
)

global wallworm_hitbox_CA = attributes "wallworm_hitbox_CA" version:2 (
	local wallworm = true
	local wwmt_hitbox = true
	local vmf_export = false
	local vmf_exclude = true
	local thisNode
	local hboxsets = #()

	function getNode = (
		if NOT isValidNode thisNode then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)

	parameters params rollout:paramrollout (
		hitbox_group type:#integer default:0 ui:sp_hitbox_group
		hboxset type:#string default:"default" ui:edt_hboxset

	)

	function getHboxSets = (
		getNode()
		local out = #(hboxset)
		if ::wallworm_get_hierarchy_root != undefined then (
			local root = ::wallworm_get_hierarchy_root thisNode

			if isValidNode root then (
				local collection

				::wallworm_getAllChildren root &collection

				collection = for hb in collection WHERE isValidNode hb AND (isProperty hb #wwmt_hitbox) OR (getUserProp hb #wwmt_hitbox == true) collect hb

				for hb in collection WHERE NOT isProperty hb #wwmt_hitbox do (
					::wallworm_add_hitbox_ca hb
				)

				out = for hb in collection collect hb.hboxset
			)

		)

		append out "default"
		out = makeUniqueArray out
		sort out
		out
	)

	function alignToP = (
		getNode()
		if isValidNode thisNode.parent then (
			AlignToParent thisNode
		)
	)

	rollout paramrollout "WWMT Hitbox" (
		Spinner sp_hitbox_group "Group #" type:#integer range:[0, 256, 0] step:1 tooltip:"Set a Hitbox Group ID. Default is 0."
		EditText edt_hboxset "$hboxset"
		ListBox lb_listothers "HBoxSets In Model" items:#("default")
		Button btnAlignTP "Align To Parent"

		on btnAlignTP pressed do (
			alignToP()
		)
		on paramrollout open do (
			lb_listothers.items = getHboxSets()
			lb_listothers.selection = findItem lb_listothers.items hboxset

		)

		on lb_listothers selected sel do (
			if lb_listothers.selected != hboxset then (
				hboxset = lb_listothers.selected
			)
		)
	)

	on clone orig do thisNode = undefined
)

/*
add le
*/
function wallworm_add_hitbox_ca hb hbset:"default" grp:0 = (
	if NOT isProperty hb #wallworm_hitbox_CA then (
		custAttributes.add hb ::wallworm_hitbox_CA

		if grp == undefined then (
			grp = (getUserProp hb #wwmt_hitbox_group) --look for a legacy value
			if grp != undefined then (
				grp = grp as Integer
			)
		)

		if hbset == undefined then (
			hbset = getUserProp hb #wwmt_hboxset --legacy
		)

	)

	if grp == undefined then (
		grp = 0
	)

	if hbset == undefined then (
		hbset = "default"
	)

	hb.hitbox_group = grp
	hb.hboxset = hbset

)

function wwmt_setHitboxGroup obj grp:0 = (
	if NOT isProperty obj #wwmt_hitbox then (
		wallworm_add_hitbox_ca obj grp:grp
	) else (
		obj.hitbox_group = grp
		--setUserProp obj #wwmt_hitbox_group (grp as string)
	)
	grp
)

function wwmt_getBoneHitboxes bs:selection = (
	hitboxes = #()
	if bs.count > 0 then (
		for b in bs do (
			if b != undefined then (
				if b.children.count > 0 then (
					for hb in b.children WHERE (isProperty hb #wwmt_hitbox) OR (getUserProp hb #wwmt_hitbox == true) do (
						append hitboxes hb
					)
				)

			)
		)
	)
	hitboxes
)

function wwmt_createBoneHitbox b hbset:"default" grp:0 = (
	if isProperty b #wwmt_hitbox OR getUserProp b #wwmt_hitbox == true then (
		undefined
	) else (
		hitboxHelper = boxGizmo ()
		hitboxHelper.name = uniqueName ("WWMT_hbox_" + b.name)

		wallworm_add_hitbox_ca hitboxHelper hbset:hbset grp:grp

		hitboxHelper.parent = b
		hitboxHelper.transform = b.transform

		in coordsys b (
			hitboxHelper.height = b.max.z
			hitboxHelper.width = b.max.x
			hitboxHelper.length = b.max.y
		)
		hitBoxHelper
	)
)

function wwmt_setHboxSets objs val:"default" = (
	if objs != undefined AND objs.count > 0 then (
		for obj in objs do (
			wallworm_add_hitbox_ca obj hbset:val
		)
		--setUserProp objs #wwmt_hboxset val
	)
)

function wwmt_get_hitboxsets &hboxsets objs:selection = (
	if objs != undefined AND objs.count > 0 then (
		for obj in objs do (
			for hb in obj.children WHERE isProperty hb #hboxset OR getUserProp hb #wwmt_hboxset != undefined do (
				local hbset
				if NOT isProperty hb #hboxset then (
					wallworm_add_hitbox_ca hb --hbset:hbset grp:grp
				)
				hbset = hb.hboxset
				if hbset != undefined AND hbset != "" then (
					appendifunique hboxsets hbset
				)
			)

		)

	)
)

function wwmt_get_hitboxes objs:selection = (
	local hbs = #()
	--hboxsets = #("default")
	if objs.count > 0 then (
		local newhb = wwmt_getBoneHitboxes bs:objs
		if newhb != undefined AND newhb.count > 0 then (
			join hbs newhb
		)
		/*
		if hbs.count > 0 then (
			wwmt_get_hitboxsets hboxsets objs:hbs
		)*/

	)
	hbs
)

/*Following  two functions by Denis Trofimov... discussion at 

http://forums.cgsociety.org/showthread.php?f=98&t=1114788

*/
function wallworm_convertCATSkeleton catRoot showlinks:on namePre:"WW_BoneShadow_" =
(
	bones = #()
	catBones = join #() catRoot
	for node in catBones do
	(
		b = point name:(namePre + node.name) transform:node.transform wirecolor:node.wirecolor
		if (k = findItem catBones node.parent) != 0 do b.parent = bones[k]
		append bones b
	)
	bones.showLinks = bones.showLinksOnly = showlinks
	bones
)

function wallworm_transferCATAnimation catRoot boneRoot range: =
(
	if NOT isKindOf range interval do range = animationrange

	catBones = join #() catRoot
	bones = join #() boneRoot
	with animate on for t = range.start to range.end do at time t
	(
		for k = 1 to catBones.count do bones[k].transform = catBones[k].transform
	)
)

/*Update the custom attribute definitions for a WWMT object.*/
function wallworm_update_hitbox_cas obj newDef:newDef = (
	if newDef == undefined then (
		newDef = (custAttributes.getDefSource ::wallworm_hitbox_CA)
	)
	with undo off
	with redraw off (
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		local out = false
		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i
				if matchPattern def.name pattern:"*wallworm_hitbox_CA" then (
					custAttributes.redefine def newDef
					out = true
				)

			)
		)
	)
	out
)

function wallworm_update_all_hitbox_cas minVersion:100 = (
	local newDef = custAttributes.getDefSource ::wallworm_hitbox_CA
	for obj in objects WHERE isProperty obj #wallworm_hitbox_CA AND obj.wallworm_hitbox_CA.version < minVersion do (
		wallworm_update_hitbox_cas obj newDef:newDef
	)
)

/*Update the custom attribute definitions for a WWMT object.*/
function wallworm_update_bone_cas obj newDef:newDef = (
	if newDef == undefined then (
		newDef = (custAttributes.getDefSource ::wallworm_bone_CA)
	)
	with undo off
	with redraw off (
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		local out = false
		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i
				if matchPattern def.name pattern:"*wallworm_bone_CA" then (
					custAttributes.redefine def newDef
					out = true
				)

			)
		)
	)
	out
)

function wallworm_update_all_bone_cas minVersion:100 = (
	local newDef = custAttributes.getDefSource ::wallworm_bone_CA
	max create mode
	for obj in objects WHERE isProperty obj #wallworm_bone_CA AND obj.wallworm_bone_CA.version < minVersion do (
		wallworm_update_bone_cas obj newDef:newDef
	)
)

function wallworm_set_bone_display length:1 width:1 height:1 bns:selection = (
	for bn in (selection as Array) WHERE classOf bn == BoneGeometry do (
		bn.showLinks = off
		bn.showLinksOnly = off
		bn.width = width
		bn.height = height
		bn.length = length
	)
)