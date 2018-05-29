/*
Wall Worm Model Tools 
Copyright (c) 2010-2015 by Shawn Olson
http://www.shawnolson.net

A Wall Worm Project
http://www.wallworm.com
*/
--(

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
	--::wallworm_installation_path	= (symbolicPaths.getPathValue "$scripts")
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
wwintro = StringStream ""
format "Loading...\nWall Worm Model Tools\n" to:wwintro
format "Version %\n\n" ::ww_wwmt_version to:wwintro
format "www.wallworm.com\n\n" to:wwintro
format "Copyright (c) 2010-2015 by Shawn Olson\n" to:wwintro
format "http://www.shawnolson.net \n\n" to:wwintro
format "Forums now up at http://www.wallworm.net\n" to:wwintro
format (wwintro as String)

if wwmt_activateLODMenus == undefined then (
	wwmt_activateLODMenus = function wwmt_activateLODMenus ar = ()
)

if ::wallworm_reset_wwmt == true AND ::ww_scene_lods != undefined then (
) else (
	::ww_scene_lods = ww_LOD_wrapper()
	::ww_scene_lods.init()
	try(closeRolloutFloater ::wwToolsFloater)catch()
)

/*See if the UI position was set before*/
thePos = getINISetting ::wallworm_userIni "Layout" "wwmt_ui_pos"
if thePos != undefined AND thePos != "" then (
	execute ("wwmtUILocation =  " + thePos)
)
global wwmtUILocation
if wwmtUILocation == undefined OR classOf wwmtUILocation != Point2 then (
	wwmtUILocation = [20, 20]
)

::wwToolsFloater = newRolloutFloater "Wall Worm Model Tools" 260 1040 wwmtUILocation.x wwmtUILocation.y
global wwmt_lodhelperIcons = #(::wallworm_installation_path + "/Wallworm.com/assets/lod_helper_icon_buttons.png", undefined, 2, 1, 1, 2, 2, false)
global wwmt_lodViewIcons = #(::wallworm_installation_path + "/Wallworm.com/assets/lod_view_icon_buttons.png", undefined, 2, 1, 1, 2, 2, false)
global wwmt_lodHideIcons = #(::wallworm_installation_path + "/Wallworm.com/assets/lod_hide_icon_buttons.png", undefined, 2, 1, 1, 2, 2, false)

global lodstring

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/lodsui.ms")

execute lodstring
lodstring = undefined

function disableUI = (
	local roll = ::wwToolsFloater.rollouts
	local R1 = roll[1]
	local R2 = roll[2]
	local R3 = roll[3]
	local R4 = roll[4]
	local R5 = roll[5]
	local R6 = roll[6]
	local R7 = roll[7]
	local R8 = roll[8]
	local R9 = roll[9]
	R1.addModel.caption = "Pick Model"
	R1.ddlNormals.enabled = false
	R2.addPhys.enabled = false
	R4.pickLOD1.enabled = false
	R1.edt1_modelPath.enabled = false
	R1.edt2_materialFolder.enabled = false
	R1.ddl1.enabled = false
	R1.btn_appendModels.enabled = false
	R1.btn_addSelection.enabled = false
	R1.btn_removeSelFromTargets.enabled = false
	R1.chk_staticprop.enabled = false
	R1.chk_alwayscollapse.enabled = false
	R1.chk_collapsebones.enabled = false
	R1.chk_opaque.enabled = false
	R1.btn_tex.enabled = false
	R1.ddl_shader.enabled = false
	R1.ddl_compression.enabled = false
	R1.chk_mostlyopaque.enabled = false
	R1.edt2_materialFolder.enabled = false
	R1.edt1_modelPath.enabled = false
	R1.runExport.enabled = false
	R1.runQC.enabled = false
	R1.runSMD.enabled = false
	R1.chkDMX.enabled = false
	R1.btn_SelectModel.enabled = false
	R1.btn_illum.enabled = false
	R1.chk_altOrigin.enabled = false
	R1.chk_localOrigin.enabled = false
	R1.chkRotateOrigin.enabled = false
	R1.edt_modelName.enabled = false
	R1.edt_modelName.text = "MyModel"
	R1.spn_scale.enabled = false
	R1.btn_setSkyScale.enabled = false
	R1.btn_setSkyScale2.enabled = false
	R1.chkInternalOrigin.enabled = false
	R2.ddl_contents.enabled = false
	R2.spn_inertia.enabled = false
	R2.spn_damping.enabled = false
	R2.spn_phdrag.enabled = false
	R2.chk_jointrestrain.enabled = false
	R2.chk_noselfcollisions.enabled = false
	R2.edt_animatedfriction.enabled = false
	R2.spn_rotDamping.enabled = false
	R2.btn_deleteHulls.enabled = false
	R2.btn_mass.enabled = false
	R2.chk_automass.enabled = false
	R2.btn_update_count.enabled = false
	R2.spn_mass.enabled = false
	R2.chk_concave.enabled = false
	R2.btn_addCM.enabled = false
	R2.btn_appendCM.enabled = false
	R2.chk_autoHull.enabled = false
	R2.chk_autoHull.chk_usePhysOverrides.enabled = false
	R3.lodSpinner.enabled = false
	R3.generateLODbtn.enabled = false
	R3.chk_shadow.enabled = false
	R5.chk_idleSequence.enabled = false
	R5.cbx_sequences.enabled = false
	R5.btn_addSeq.enabled = false
	R5.btn_delSeq.enabled = false
	R5.cbx_sequences.items = ww_scene_lods.sequencelist
	R5.spn_expStart.enabled = false
	R5.spn_expEnd.enabled = false
	R5.chk_expReverse.enabled = false
	R5.chk_loop.enabled = false
	R7.chk_expHL1Format.enabled = false
	R7.btn_illum.enabled = false
	R7.spn_constantdirectionallight.enabled = false
	R7.chk_ambientboost.enabled = false
	R6.cbx_attachmentList.enabled = false
	R6.ddl_attachmentBone.enabled = false
	R6.chk_attachmentAbsolute.enabled = false
	R6.chk_attachmentRigid.enabled = false
	R6.btn_createAttachment.enabled = false
	R6.btn_deleteAttachment.enabled = false
	R6.btn_attachUpdateBoneList.enabled = false
	R6.btn_selectPoint.enabled = false
	R8.btnSkins.enabled = false
	R8.ckb_expMorphsAsVTA.enabled = false
	R8.btn_expVTAs.enabled = false
	R8.btnCollectSkins.enabled = false
	R8.btnCreateProxy.enabled = false
	R9.chk_overridePhys.enabled = false
	R9.chk_allowstatic.enabled = false
	R9.chk_blockLOS.enabled = false
	R9.chk_AIWalkable.enabled = false
	R9.chk_ignite.enabled = false
	R9.chk_explosive_resist.enabled = false
	R9.chk_flammable.enabled = false
	R9.btn_custGibs.enabled = false
	R9.spn_health.enabled = false
	R9.spn_breakable_skin.enabled = false
	R9.spn_dmg_bullets.enabled = false
	R9.spn_dmg_club.enabled = false
	R9.spn_dmg_explosive.enabled = false
	R9.spn_breakable_count.enabled = false
	R9.spn_explosive_damage.enabled = false
	R9.spn_explosive_radius.enabled = false
	R9.chk_motiondisabled.enabled = false
	R9.spn_fadetime.enabled = false
	R9.ddl_physicsmode.enabled = false
	R9.ddl_base.enabled = false
	R9.ddl_breakable_model.enabled = false
	R9.ddl_multiplayer_break.enabled = false
	R9.btn_custGibs.enabled = false
	R9.btn_compileGibsVTFs.enabled = false
	R9.btn_removeGibs.enabled = false
	R9.btn_compileGibs.enabled = false
)

function wallworm_setWWMUI = (
	local roll = ::wwToolsFloater.rollouts
	local R1 = roll[1]
	local R2 = roll[2]
	local R3 = roll[3]
	local R4 = roll[4]
	local R5 = roll[5]
	local R6 = roll[6]
	local R7 = roll[7]
	local R8 = roll[8]
	local R9 = roll[9]
	R2.addPhys.enabled = true
	R4.pickLOD1.enabled = true
	R1.edt1_modelPath.enabled = true
	R1.edt2_materialFolder.enabled = true
	R1.ddl1.enabled = true
	R1.chkDMX.enabled = (::WallwormProActive == true)
	if ::ww_scene_lods.dmx != undefined then (
		R1.chkDMX.checked = (::ww_scene_lods.dmx)
	)
	R1.btnShowModel.enabled = true
	R1.btnHideModel.enabled = true
	R1.chk_staticprop.enabled = true
	R1.chk_alwayscollapse.enabled = true
	R1.chk_collapsebones.enabled = true
	R1.chk_opaque.enabled = true
	R1.chk_lockQC.enabled = true
	R1.ddl_shader.enabled = true
	R1.ddl_compression.enabled = true
	R1.btn_tex.enabled = true
	R1.chk_mostlyopaque.enabled = true
	R1.edt2_materialFolder.enabled = true
	R1.edt1_modelPath.enabled = true
	R1.runExport.enabled = true
	R1.runQC.enabled = true
	R1.runSMD.enabled = true
	R1.btn_SelectModel.enabled = true
	R1.btn_illum.enabled = true
	R1.chk_altOrigin.enabled = true
	R1.chk_localOrigin.enabled = true
	R1.chkInternalOrigin.enabled = true
	R1.chkRotateOrigin.enabled = true
	R1.chk_lock_origin.enabled = true
	R1.edt_modelName.enabled = true
	R1.edt_modelName.text = ww_scene_lods.modelName
	R1.spn_scale.enabled = true
	R1.btn_setSkyScale.enabled = true
	R1.btn_setSkyScale2.enabled = true
	R1.spn_mapChannel.enabled = true
	R1.ddlNormals.enabled = true
	R2.ddl_contents.enabled = true
	R2.chk_noselfcollisions.enabled = true
	R2.edt_animatedfriction.enabled = true
	R2.createPhys.enabled = true
	R2.chk_autoHull.enabled = true
	R2.chk_usePhysOverrides.enabled = true
	if isProperty ::ww_scene_lods.target #usePhysOverrides then (
		R2.spn_rotDamping.enabled = R2.spn_mass.enabled = R2.spn_inertia.enabled = R2.spn_damping.enabled = R2.spn_phdrag.enabled = ::ww_scene_lods.target.usePhysOverrides
		R2.chk_usePhysOverrides.checked = ::ww_scene_lods.target.usePhysOverrides
	) else (
		R2.spn_rotDamping.enabled = R2.spn_mass.enabled = R2.spn_inertia.enabled = R2.spn_damping.enabled = R2.spn_phdrag.enabled = true
	)
	R2.chk_jointrestrain.enabled = true
	R2.btn_deleteHulls.enabled = true
	R2.btn_mass.enabled = true
	R2.chk_automass.enabled = true

	R2.chk_concave.enabled = true
	R2.btn_addCM.enabled = true
	R2.btn_appendCM.enabled = true
	R2.chk_autoHull.enabled = true
	R2.btn_update_count.enabled = true
	R3.lodSpinner.enabled = true
	R3.generateLODbtn.enabled = true
	R3.chk_shadow.enabled = true
	R5.chk_idleSequence.enabled = true
	R5.cbx_sequences.enabled = true
	R5.btn_addSeq.enabled = true
	R5.btn_delSeq.enabled = true
	R5.cbx_sequences.items = ww_scene_lods.sequencelist
	R5.cbxSeqWeightlist.items = ww_scene_lods.weightlistnames
	R5.cbxWeightLists.items = ww_scene_lods.weightlistnames
	R5.spn_expStart.enabled = true
	R5.spn_expEnd.enabled = true
	R5.chk_expReverse.enabled = true
	R5.chk_loop.enabled = true
	R7.chk_expHL1Format.enabled = true
	R7.btn_illum.enabled = true
	R7.spn_constantdirectionallight.enabled = true
	R7.chk_ambientboost.enabled = true
	R6.cbx_attachmentList.enabled = true
	R6.ddl_attachmentBone.enabled = true
	R6.chk_attachmentAbsolute.enabled = true
	R6.chk_attachmentRigid.enabled = true
	R6.btn_createAttachment.enabled = true
	R6.btn_deleteAttachment.enabled = true
	R6.btn_attachUpdateBoneList.enabled = true
	R6.btn_selectPoint.enabled = true
	R1.addModel.caption = ww_scene_lods.modelName
	if ww_scene_lods.particlesystems.count > 0 then (
		local theSystems = #()
		for sys in ww_scene_lods.particlesystems do (
			append theSystems sys.systemname
		)
		R6.cbxParticles.items = theSystems
	)
	R6.ddlSeqList.items = ww_scene_lods.sequencelist
	R6.setParticleButtons()
	R8.ckb_expMorphsAsVTA.enabled = true
	R8.btn_expVTAs.enabled = true
	R8.btnCollectSkins.enabled = true
	R8.btnCreateProxy.enabled = true
	R8.btnSkins.enabled = true
	if ww_scene_lods.morphasvta != undefined then (
		R8.ckb_expMorphsAsVTA.checked = ww_scene_lods.morphasvta
	) else (
		R8.ckb_expMorphsAsVTA.checked = true
	)
	R9.ddl_base.enabled = true
	R9.chk_overridePhys.enabled = true
	if isProperty ::ww_scene_lods.target #usePhysOverrides then (
		R9.spn_health.enabled = \
		R9.chk_allowstatic.enabled = \
		R9.ddl_physicsmode.enabled = \
		R9.chk_blockLOS.enabled = \
		R9.chk_AIWalkable.enabled = \
		R9.spn_dmg_bullets.enabled = \
		R9.spn_dmg_club.enabled = \
		R9.spn_dmg_explosive.enabled = \
		R9.chk_ignite.enabled = \
		R9.chk_explosive_resist.enabled = \
		R9.chk_flammable.enabled = \
		R9.spn_explosive_damage.enabled = ::ww_scene_lods.target.overridePhys
		R9.chk_overridePhys.checked = ::ww_scene_lods.target.overridePhys
	) else (
		R9.spn_health.enabled = \
		R9.chk_allowstatic.enabled = \
		R9.ddl_physicsmode.enabled = \
		R9.chk_blockLOS.enabled = \
		R9.chk_AIWalkable.enabled = \
		R9.spn_dmg_bullets.enabled = \
		R9.spn_dmg_club.enabled = \
		R9.spn_dmg_explosive.enabled = \
		R9.chk_ignite.enabled = \
		R9.chk_explosive_resist.enabled = \
		R9.chk_flammable.enabled = \
		R9.spn_explosive_damage.enabled = true
	)

	if ww_scene_lods.allowstatic != undefined then (
		R9.chk_allowstatic.checked = ww_scene_lods.allowstatic
	) else (
		R9.chk_allowstatic.checked = false
	)
	if ww_scene_lods.blockLOS != undefined then (
		R9.chk_blockLOS.checked = ww_scene_lods.blockLOS
	) else (
		R9.chk_blockLOS.checked = false
	)

	if ww_scene_lods.AIWalkable != undefined then (
		R9.chk_AIWalkable.checked = ww_scene_lods.AIWalkable
	) else (
		R9.chk_AIWalkable.checked = false
	)
	if ww_scene_lods.ignite != undefined then (
		R9.chk_ignite.checked = ww_scene_lods.ignite
	) else (
		R9.chk_ignite.checked = false
	)
	if ww_scene_lods.explosive_resist != undefined then (
		R9.chk_explosive_resist.checked = ww_scene_lods.explosive_resist
	) else (
		R9.chk_explosive_resist.checked = false
	)
	if ww_scene_lods.flammable != undefined then (
		R9.chk_flammable.checked = ww_scene_lods.flammable
	) else (
		R9.chk_flammable.checked = false
	)

	R9.btn_custGibs.enabled = true
	R9.btn_compileGibsVTFs.enabled = true
	R9.btn_removeGibs.enabled = true
	R9.btn_compileGibs.enabled = true

	if ww_scene_lods.physicsmode != undefined then (
		try (
			R9.ddl_physicsmode.selection = ww_scene_lods.physicsmode
		)catch()
	)
	if ww_scene_lods.base != undefined then (
		try(
			if findItem R9.ddl_base.items ww_scene_lods.base == 0 then (
				oldBaseItems = R9.ddl_base.items
				appendIfUnique oldBaseItems ww_scene_lods.base
				R9.ddl_base.items = oldBaseItems
			)
			R9.ddl_base.selection = findItem R9.ddl_base.items ww_scene_lods.base

		)catch(
			R9.ddl_base.selection = 1
		)
	)
	R9.ddl_breakable_model.enabled = true
	if ww_scene_lods.breakable_model != undefined then (
		try(
			R9.ddl_breakable_model.selection = findItem R9.ddl_breakable_model.items ww_scene_lods.breakable_model
		)catch(
			R9.ddl_breakable_model.selection = 1
		)
	)
	R9.ddl_multiplayer_break.enabled = true
	if ww_scene_lods.multiplayer_break != undefined then (
		try(
			R9.ddl_multiplayer_break.selection = findItem R9.ddl_multiplayer_break.items ww_scene_lods.multiplayer_break
		)catch(
			R9.ddl_multiplayer_break.selection = 1
		)
	)

	R9.btn_custGibs.enabled = true
	R9.spn_health.enabled = true
	R9.spn_breakable_skin.enabled = true
	R9.spn_dmg_bullets.enabled = true
	R9.spn_dmg_club.enabled = true
	R9.spn_dmg_explosive.enabled = true
	R9.spn_breakable_count.enabled = true
	R9.spn_explosive_damage.enabled = true
	R9.spn_explosive_radius.enabled = true
	R9.spn_fadetime.enabled = true
	R9.chk_motiondisabled.enabled = true

	if ww_scene_lods.fadetime != undefined AND ww_scene_lods.fadetime != "undefined" then (
		try(
			R9.spn_fadetime.value = ww_scene_lods.fadetime
		)catch(
			R9.spn_fadetime.value = R9.spn_fadetime.range[3]
		)
	)

	if ww_scene_lods.motiondisabled != undefined AND (ww_scene_lods.motiondisabled == "true" OR ww_scene_lods.motiondisabled == true) then (
		R9.chk_motiondisabled.checked = true
	) else (
		R9.chk_motiondisabled.checked = false
	)

	if ww_scene_lods.health != undefined AND ww_scene_lods.health != "undefined" then (
		R9.spn_health.value = (ww_scene_lods.health as Integer)
	) else(
		R9.spn_health.value = R9.spn_health.range[3]
	)
	if ww_scene_lods.breakable_skin != undefined AND ww_scene_lods.breakable_skin != "undefined" then (
		R9.spn_breakable_skin.value = (ww_scene_lods.breakable_skin as Integer)
	) else(
		R9.spn_breakable_skin.value = R9.spn_breakable_skin.range[3]
	)
	if ww_scene_lods.dmg_bullets != undefined AND ww_scene_lods.dmg_bullets != "undefined" then (
		R9.spn_dmg_bullets.value = ww_scene_lods.dmg_bullets
	) else (
		R9.spn_dmg_bullets.value = R9.spn_dmg_bullets.range[3]
	)
	if ww_scene_lods.dmg_club != undefined AND ww_scene_lods.dmg_club != "undefined" then (
		R9.spn_dmg_club.value = ww_scene_lods.dmg_club
	) else (
		R9.spn_dmg_club.value = R9.spn_dmg_club.range[3]
	)
	if ww_scene_lods.dmg_explosive != undefined AND ww_scene_lods.dmg_explosive != "undefined" then (
		R9.spn_dmg_explosive.value = ww_scene_lods.dmg_explosive
	) else(
		R9.spn_dmg_explosive.value = R9.spn_dmg_explosive.range[3]
	)
	if ww_scene_lods.breakable_count != undefined AND ww_scene_lods.breakable_count != "undefined" then (
		R9.spn_breakable_count.value = ww_scene_lods.breakable_count
	) else (
		R9.spn_breakable_count.value = R9.spn_breakable_count.range[3]
	)
	if ww_scene_lods.explosive_damage != undefined AND ww_scene_lods.explosive_damage != "undefined" then (
		R9.spn_explosive_damage.value = ww_scene_lods.explosive_damage
	) else (
		R9.spn_explosive_damage.value = R9.spn_explosive_damage.range[3]
	)
	if ww_scene_lods.explosive_radius != undefined AND ww_scene_lods.explosive_radius != "undefined" then (
		R9.spn_explosive_radius.value = ww_scene_lods.explosive_radius
	) else (
		R9.spn_explosive_radius.value = R9.spn_explosive_radius.range[3]
	)

	R6.cbx_attachmentList.items = R6.ddl_attachToAttachment.items = ww_scene_lods.getAttachmentList()
	R6.ddl_attachmentBone.items = ww_scene_lods.boneNameList()

	if ww_scene_lods.modelPath != undefined then (
		local ind = findItem R1.edt1_modelPath.items ww_scene_lods.modelPath
		if ind == 0 then (
			local temp = R1.edt1_modelPath.items
			append temp ww_scene_lods.modelPath
			sort temp
			R1.edt1_modelPath.items = temp
			ind = findItem R1.edt1_modelPath.items ww_scene_lods.modelPath
		)
		R1.edt1_modelPath.selection = ind
	)

	if ww_scene_lods.materialPath != undefined then (
		local ind = findItem R1.edt2_materialFolder.items ww_scene_lods.materialPath
		if ind == 0 then (
			local temp = R1.edt2_materialFolder.items
			append temp ww_scene_lods.materialPath
			sort temp
			R1.edt2_materialFolder.items = temp
			ind = findItem R1.edt2_materialFolder.items ww_scene_lods.materialPath
		)
		R1.edt2_materialFolder.selection = ind
	)
	if ww_scene_lods.surfaceprop != undefined then (
		R1.ddl1.selection = findItem R1.ddl1.items ww_scene_lods.surfaceprop
	) else (
		R1.ddl1.selection = 1
	)

	if ww_scene_lods.shaderType != undefined then (
		R1.ddl_shader.selection = findItem R1.ddl_shader.items ww_scene_lods.shaderType
	) else (
		R1.ddl_shader.selection = 1
	)
	if ww_scene_lods.compression != undefined then (
		R1.ddl_compression.selection = findItem R1.ddl_compression.items ww_scene_lods.compression
	) else (
		R1.ddl_compression.selection = 5
	)

	if ww_scene_lods.staticprop != undefined then (
		R1.chk_staticprop.checked = ww_scene_lods.staticprop
	) else (
		R1.chk_staticprop.checked = false
	)

	if ww_scene_lods.alwayscollapse != undefined then (
		R1.chk_alwayscollapse.checked = ww_scene_lods.alwayscollapse
	) else (
		R1.chk_alwayscollapse.checked = false
	)

	if ww_scene_lods.collapsebones != undefined then (
		R1.chk_collapsebones.checked = ww_scene_lods.collapsebones
	) else (
		R1.collapsebones.checked = false
	)

	if ww_scene_lods.locked != undefined then (
		R1.chk_lockQC.checked = ww_scene_lods.locked
	) else(
		R1.chk_lockQC.checked = false
	)

	if ww_scene_lods.noselfcollisions != undefined then (
		R2.chk_noselfcollisions.checked = ww_scene_lods.noselfcollisions
	) else(
		R2.chk_noselfcollisions.checked = false
	)

	if ww_scene_lods.animatedfriction != undefined then (
		R2.edt_animatedfriction.text = ww_scene_lods.animatedfriction
	) else(
		R2.edt_animatedfriction.text = ""
	)
	if ww_scene_lods.opaque != undefined then (
		R1.chk_opaque.checked = ww_scene_lods.opaque
	) else(
		R1.chk_opaque.checked = false
	)

	if ww_scene_lods.normalMethod != undefined then (
		R1.ddlNormals.selection = ww_scene_lods.normalMethod
	) else(
		R1.ddlNormals.selection = 3
	)

	if ww_scene_lods.shadowlod != undefined then (
		R3.chk_shadow.checked = ww_scene_lods.shadowlod
	) else (
		R3.chk_shadow.checked = false
	)
	if ww_scene_lods.mostlyopaque != undefined then (
		R1.chk_mostlyopaque.checked = ww_scene_lods.mostlyopaque
	) else (
		R1.chk_mostlyopaque.checked = false
	)

	if ww_scene_lods.concave != undefined then (
		R2.chk_concave.checked = ww_scene_lods.concave
	) else (
		R2.chk_concave.checked = false
	)

	if ww_scene_lods.jointConstraints != undefined then (
		R2.chk_jointrestrain.checked = ww_scene_lods.jointConstraints
	) else (
		R2.chk_jointrestrain.checked = false
	)

	if ww_scene_lods.mass != undefined then (
		R2.spn_mass.value = ww_scene_lods.mass
	) else (
		R2.spn_mass.value = R2.spn_mass.range[3]
	)

	if ww_scene_lods.inertia != undefined then (
		R2.spn_inertia.value = ww_scene_lods.inertia
	) else (
		R2.spn_inertia.value = R2.spn_inertia.range[3]
	)

	if ww_scene_lods.phdrag != undefined then (
		R2.spn_phdrag.value = ww_scene_lods.phdrag
	) else(
		R2.spn_phdrag.value = R2.spn_phdrag.range[3]
	)

	if ww_scene_lods.damping != undefined then (
		R2.spn_damping.value = ww_scene_lods.damping
	) else (
		R2.spn_damping.value = R2.spn_damping.range[3]
	)

	if ww_scene_lods.rotDamping != undefined then (
		R2.spn_rotDamping.value = ww_scene_lods.rotDamping
	) else(
		R2.spn_rotDamping.value = R2.spn_rotDamping.range[3]
	)

	if ww_scene_lods.autoHull != undefined then (
		R2.chk_autoHull.checked = ww_scene_lods.autoHull
	) else(
		R2.chk_autoHull.checked = false
	)

	if ww_scene_lods.contents != undefined then (
		R2.ddl_contents.selection = findItem R2.ddl_contents.items ww_scene_lods.contents
	) else (
		R2.ddl_contents.selection = 1
	)

	if ww_scene_lods.mscale != undefined then (
		R1.spn_scale.value = ww_scene_lods.mscale
	) else (
		R1.spn_scale.value = R1.spn_scale.range[3]
	)

	if ww_scene_lods.mapChannel != undefined then (
		R1.spn_mapChannel.value = ww_scene_lods.mapChannel
	) else (
		R1.spn_mapChannel.value = ::wwmt_mappingChannel as Integer
	)

	if ww_scene_lods.lockInitialOrigin != undefined AND ww_scene_lods.lockInitialOrigin == true then (
		R1.chk_lock_origin.state = true
	) else (
		R1.chk_lock_origin.state = false
	)

	if ww_scene_lods.automass != undefined then (
		R2.chk_automass.checked = ww_scene_lods.automass
	) else (
		R2.chk_automass.checked = false
	)

	if ww_scene_lods.lods.count > 0 then (
		R3.lodSpinner.value = ww_scene_lods.lods.count
	) else (
		R3.lodSpinner.value = R3.lodSpinner.range[3]
	)

	if ww_scene_lods.hulls.count > 0 AND isValidNode ww_scene_lods.hulls[1] then(
		R2.addPhys.caption = ww_scene_lods.hulls[1].name
	) else (
		R2.addPhys.caption = "Pick Hull"
	)

	if ww_scene_lods.useLocalOrigin != undefined then (
		R1.chk_localOrigin.checked = ww_scene_lods.useLocalOrigin
	) else (
		R1.chk_localOrigin.checked = false
	)

	if ww_scene_lods.internalOrigin != undefined then (
		R1.chkInternalOrigin.checked = ww_scene_lods.internalOrigin
	) else (
		R1.chkInternalOrigin.checked = false
	)

	if ww_scene_lods.rotateRefsystem != undefined then (
		R1.chkRotateOrigin.checked = ww_scene_lods.rotateRefsystem
	) else (
		R1.chkRotateOrigin.checked = false
	)

	if ww_scene_lods.altOrigin != undefined then (
		R1.chk_altOrigin.checked = ww_scene_lods.altOrigin
	) else (
		R1.chk_altOrigin.checked = false
	)

	if ww_scene_lods.idleSequence != undefined then (
		R5.chk_idleSequence.checked = ww_scene_lods.idleSequence
	) else (
		R5.chk_idleSequence.checked = true
	)
	if ww_scene_lods.expHL1Format != undefined then (
		if (ww_scene_lods.expHL1Format == 1 OR ww_scene_lods.expHL1Format == true) then (
			R7.chk_expHL1Format.checked = true
		) else (
			R7.chk_expHL1Format.checked = false
		)
	) else(
		R7.chk_expHL1Format.checked = false
	)

	if ww_scene_lods.ambientboost != undefined then (
		if (ww_scene_lods.ambientboost == 1 OR ww_scene_lods.ambientboost == true) then (
			R7.chk_ambientboost.checked = true
		) else (
			R7.chk_ambientboost.checked = false
		)
	) else(
		R7.chk_ambientboost.checked = false
	)

	if ww_scene_lods.constantdirectionallight != undefined then (
		R7.spn_constantdirectionallight.value = ww_scene_lods.constantdirectionallight
	) else(
		R7.spn_constantdirectionallight.value = R7.spn_constantdirectionallight.range[3]
	)
	wwmt_activateLODMenus ww_scene_lods.lods
	if ww_scene_lods.target != undefined then (
		R1.btn_appendModels.enabled = true
		R1.btn_addSelection.enabled = true
		if ww_scene_lods.targets.count > 1 then (
			R1.btn_removeSelFromTargets.enabled = true
		)
		ww_scene_lods.setTargetCust()
	)
	::wallworm_reset_wwmt = undefined
)
function wwmt_CallbackLODCamMove obj = (
	wwmtviewindex = 0
	if isValidNode obj then (
		disableSceneRedraw()
		for l in ww_scene_lods.lods do (
			if ((distance l.helperTape.position ww_scene_lods.targets[1].pos) < (distance obj.pos ww_scene_lods.targets[1].pos)) then (
				if l.level > wwmtviewindex then (
					wwmtviewindex = l.level
				)
			)
		)
		if wwmtviewindex == 0 then (
			unhide ww_scene_lods.targets
		) else (
			hide ww_scene_lods.targets
		)
		for l in ww_scene_lods.lods do (
			if(l.level == wwmtviewindex) then (
				unhide l.items
			) else (
				hide l.items
			)
		)
		enableSceneRedraw()
	)
)
function wwmt_allowedTarget obj = (
	if ((superClassOf obj) == GeometryClass OR (superClassOf obj) == Shape)then (
		true
	) else (
		false
	)
)
function wwmt_activateLODMenus ar = (
	if ww_scene_lods.lods != undefined then (
		local ind = 1
		local thisLimit = ::wwmt_lodLimit
		if ::ww_scene_lods.lods.count > thisLimit then (
			thisLimit = ::ww_scene_lods.lods.count
		)
		while ind <= thisLimit do (
			nextx = ind + 1
			selStr = StringStream ""
			if ar.count >= ind then (
				if nextx <= thisLimit then (
					format "::wwToolsFloater.rollouts[4].pickLOD%.enabled = true\n" nextx to:selStr
				)
				format "::wwToolsFloater.rollouts[4].pickLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].addSelLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].appendLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].btnPickLOD%Helper.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].btnViewLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetric%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetricGet%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetric%.value = (ww_scene_lods.lods[%].getMetric() as float) \n" ind ind to:selStr
				format "::wwToolsFloater.rollouts[4].pickLOD%.caption = \"LOD %\" \n" ind ind to:selStr
				format "::wwToolsFloater.rollouts[4].btnMatLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].delSelLOD%.enabled = true\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].delLOD%.enabled = true\n" ind to:selStr
				if ww_scene_lods.lods != undefined then (
					--add wrapper if missing
					try(
						lodVal = ww_scene_lods.lods[ind].getMyRes() as String
					) catch (
						lodVal = wwmt_vertexPercentages[ind]
					)
				) else (
					lodVal = wwmt_vertexPercentages[ind]
				)
				format "::wwToolsFloater.rollouts[4].spnLOD%.value = %\n" ind lodVal to:selStr
			) else (
				default = wwmt_vertexPercentages[ind]
				if nextx <= thisLimit then (
					format "::wwToolsFloater.rollouts[4].pickLOD%.enabled = false\n" nextx to:selStr
				)
				format "::wwToolsFloater.rollouts[4].delLOD%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].btnPickLOD%Helper.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].btnViewLOD%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLOD%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetric%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetricGet%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLODMetricGet%.enabled = false\n" ind to:selStr
				format "::wwToolsFloater.rollouts[4].pickLOD%.caption = \"Pick LOD %\"\n" ind ind to:selStr
				format "::wwToolsFloater.rollouts[4].spnLOD%.value = %\n" ind default to:selStr
			)
			try (
				execute (selStr as String) as String
			) catch ()
			ind += 1
		)
	)

)

rollout wwmt_cm "Collision Model & Physics" width:250 height:464
(
	Button btn_addCM "Add CM Sel" pos:[165, 23] width:66 height:14 enabled:false toolTip:"Click to add Currently Selected mesh(es) to to the the Collision Model."
	PickButton btn_appendCM "Append CM" pos:[165, 7] width:66 height:13 enabled:false toolTip:"Click to choose another mesh to add to the Collision Model."
	Button btn_deleteHulls "Del Sel" pos:[181, 41] width:49 height:25 enabled:false toolTip:"Remove Selected Items from the Collision Hull List of this model."
	PickButton addPhys "Pick Collision Model" pos:[15, 7] width:146 height:30 enabled:false toolTip:"Pick a collision model you have already made for this model."
	Button createPhys "Quick Hull" pos:[14, 63] width:146 height:25 enabled:false toolTip:"Create a Collision Model from the model. This will automatically make a convex mesh for each element of the picked object. If there is only one element, the collision model may not be very realistic."
	CheckBox chk_usePhysOverrides "Overrides" pos:[153, 177] enabled:false
	Spinner spn_inertia "Inertia" pos:[153, 220] width:75 height:16 enabled:false range:[0, 1024, 1] toolTip:"Inertial Scale"
	Spinner spn_Damping "Damping" pos:[140, 239] width:87 height:16 enabled:false range:[0, 1024, 1] toolTip:"Damping Scale"
	Spinner spn_phdrag "Drag" pos:[158, 258] width:69 height:16 enabled:false range:[0, 1024, 1] toolTip:"Drag Scale"
	Spinner spn_mass "Mass" pos:[155, 201] width:73 height:16 enabled:false range:[0, 99999999, 0] toolTip:"Set a value for the mass of this object. This value will not be used if $automass is checked."
	CheckBox chk_automass "$automass" pos:[12, 180] width:69 height:17 enabled:false toolTip:"Calculate mass of object based on volume and the type of material defined by Surface Property. This will override values entered into the mass field."
	CheckBox chk_concave "$concave" pos:[12, 201] width:69 height:18 enabled:false
	Button btn_mass "Mass" pos:[176, 139] width:48 height:32 enabled:false images:#((::wallworm_installation_path + "/Wallworm.com/assets/wwmt_mass_icon_buttons.png"), undefined, 2, 1, 1, 2, 1, false) toolTip:"Click Here to select the Mass Center"
	CheckBox chk_jointrestrain "$jointconstrain" pos:[12, 311] width:94 height:16 enabled:false toolTip:"Add $jointconstrain limits to the joints of this model based off of the bone IK info"
	DropDownList ddl_contents "Contents" pos:[12, 131] width:157 height:40 enabled:false items:#("solid", "notsolid", "monster", "ladder", "grate")
	Spinner spn_rotDamping "Rot Damping" pos:[121, 287] width:105 height:16 enabled:false
	Button btn_SelectHulls "Select Collision Hulls" pos:[12, 364] width:103 height:40 toolTip:"Select in viewport all meshes belonging to the collision hull."
	PickButton btn36 "Prepare CM" pos:[13, 411] width:102 height:40 toolTip:"Pick an object that needs to be prepared to be turned into a Collision Mesh. This tool will apply a unique smoothing group to each Element sub-object of the picked object."
	Button btnHideCM "Hide CM" pos:[124, 364] width:50 height:40 toolTip:"Hide all meshes belonging to the collision hull."
	Button btnShowCM "Show CM" pos:[182, 364] width:51 height:40 toolTip:"Unhide all meshes belonging to the collision hull."
	CheckBox chk_autoHull "Auto Hull" pos:[12, 287] width:61 height:20 enabled:false toolTip:"Use the root model SMD for generating a Collision Hull. Should not be used with animated models."
	Button btn_processCM "Process CM" pos:[122, 411] width:111 height:40 toolTip:"Click here to give each element in the Hull a unique smoothing group."
	GroupBox grp1 "Hull Count" pos:[9, 220] width:72 height:39
	Button btn_update_count "^" pos:[48, 235] width:24 height:19 enabled:false toolTip:"Press to update the Hull Count."
	Label lbl_hullcount "?" pos:[16, 234] width:27 height:20
	Spinner spn_max_verts "Max Verts Hulls" pos:[53, 44] width:109 height:16 range:[4, 4096, 44] type:#integer scale:1 toolTip:"Maximum vertices per hull in generated hull."
	Button btn_hull_helper "Launch Hull Helper" pos:[15, 98] width:212 height:25 toolTip:"Open the Hull Helper Utility Floater; provides tools for quickly and efficiently making complex hulls from your meshes."
	CheckBox chk_noselfcollisions "No Self Collisions" pos:[13, 265] width:100 height:20 enabled:false toolTip:"Do not allow collision hulls in same model collide with each other."
	EditText edt_animatedfriction "Animated Friction" pos:[13, 335] width:222 height:18 tooltip:"<float|FrictionTimeIn> <float|FrictionTimeOut> <float|FrictionTimeHold> <float|MinAnimatedFriction> <float|MaxAnimatedFriction> Used to animate the amount of friction on joints over time.  "
	on chk_usePhysOverrides changed stat do (
		if ::ww_scene_lods != undefined AND isValidNode ::ww_scene_lods.target then (
			::ww_scene_lods.target.usePhysOverrides = stat
			spn_mass.enabled = stat
			spn_inertia.enabled = stat
			spn_Damping.enabled = stat
			spn_rotDamping.enabled = stat
			spn_phdrag.enabled = stat
		)
	)
	on edt_animatedfriction entered text do
	(
		ww_scene_lods.setAnimatedfriction(text)
	)
	function turnOffAutoHull = (
		if ww_scene_lods.autoHull == false then (
			chk_autoHull.checked = false
		)
	)
	on btn_addCM pressed do
	(
		if subObjectLevel == undefined OR subObjectLevel == 0 then (
			for obj in selection do (
				ww_scene_lods.appendHull(obj)
			)
			turnOffAutoHull()
		) else (
			messageBox "You can only use this function if the Sub-Object Level in the Modifier Stack is set to 0.\n\n(This means you are currently at Vertex, Edge, Border, Polygon or Element level."
		)
	)
	on btn_appendCM picked obj do
	(
		if (ww_scene_lods.addAHull(obj)) then (
			turnOffAutoHull()
		) else (
			messageBox "There was a problem... do not use Grouped geometry."
		)
	)
	on btn_deleteHulls pressed do
	(
		ww_scene_lods.removeItemsFromHulls selection
	)
	on addPhys picked obj do
	(
		if (ww_scene_lods.addPhysModel obj) then (
			addPhys.caption = ww_scene_lods.phys.name
			turnOffAutoHull()
		) else (
			messageBox "The action failed. Do not use Grouped geometry."
		)
	)
	on createPhys pressed do
	(
		if (ww_scene_lods.createHull maxVerts:spn_max_verts.value) == true then (
			if ww_scene_lods.hulls.count > 1 OR ww_scene_lods.concave == true then (
				chk_concave.checked = true
			)
			turnOffAutoHull()
		) else (
			messageBox "There was a problem:\n\n The Wall Worm Hull Helper only works if you have either:\n\n *The nVidia PhysX Plugin or MassFX (Integrated into 3ds Max 2013+)\n*Convexity 1.17+.\n\nIf you meet one of these requirements, please submit a bug report.\n\n*Unfortunately, some versions of PhysX/MassFX have broken the hull function."
		)
	)
	on spn_inertia changed val do
	(
		ww_scene_lods.setInertia(val)
	)
	on spn_Damping changed val do
	(
		ww_scene_lods.setDamping(val)
	)
	on spn_phdrag changed val do
	(
		ww_scene_lods.setPhdrag(val)
	)
	on spn_mass changed val do
	(
		ww_scene_lods.setMass(val)
		ww_scene_lods.setAutoMass(false)
		chk_automass.checked = false

	)
	on chk_automass changed state do
	(
		ww_scene_lods.setAutomass(state)
	)
	on chk_concave changed state do
	(
		ww_scene_lods.setConcave(state)
	)
	on btn_mass pressed do
	(
		if ww_scene_lods.massorigin == undefined OR isDeleted ww_scene_lods.massorigin then (
			ww_scene_lods.createMassHelper()
		)
		select ww_scene_lods.massorigin
	)
	on chk_jointrestrain changed state do
	(
		ww_scene_lods.setJointConstraints(state)
	)
	on ddl_contents selected sel do
	(
		ww_scene_lods.setContents(ddl_contents.items[sel])
	)
	on spn_rotDamping changed val do
	(
		ww_scene_lods.setRotDamping(val)
	)
	on btn_SelectHulls pressed do
	(
		if ww_scene_lods.hulls.count > 0 then (
			clearSelection()
			ww_scene_lods.hulls = for obj in ww_scene_lods.hulls WHERE isValidNode obj collect obj
			select ww_scene_lods.hulls
			redrawViews()
		)
	)
	on btn36 picked obj do
	(
		convertTo obj Editable_Poly
		wwmt_hullsmoothinggroups (#(obj)) sg
	)
	on btnHideCM pressed do
	(
		ww_scene_lods.hideCM()
		redrawViews()
	)
	on btnShowCM pressed do
	(
		ww_scene_lods.showCM()
		redrawViews()
	)
	on chk_autoHull changed state do
	(
		ww_scene_lods.setAutoHull state
	)
	on btn_processCM pressed do
	(
		if ww_scene_lods.hulls.count > 0 then (
			wwmt_hullsmoothinggroups ww_scene_lods.hulls 1
			redrawViews()
		)
	)
	on btn_update_count pressed do
	(
		if ww_scene_lods.autoHull == undefined OR ww_scene_lods.autoHull == false then (
			try (
				local hullcount = 0
				if ww_scene_lods.hulls.count > 0 then (
					local cc
					if ww_scene_lods.concave == undefined then (
						cc = false
					) else (
						cc = ww_scene_lods.concave
					)
					if cc == true then (
						hullcount = wwmt_count_hulls ww_scene_lods.hulls cc
					) else (
						hullcount = 1
					)
				) else (
					hullcount = 0
				)
				if hullcount != undefined AND hullcount <= 20 then (
					if hullcount == 0 then (
						hullcount = "0"
					)
					lbl_hullcount.caption = ((hullcount as String))
				) else(
					lbl_hullcount.caption = ((hullcount as String) + "!")
				)
			) catch (
				messageBox "There was a problem. Fress F11 for more details."
				print (getCurrentException())
			)
		) else (
			messageBox "This function only works when Auto Hull is not checked; you have to create your own hulls or use the Quick Hull or Adv Hull functions."
		)
	)
	on btn_hull_helper pressed do
	(
		macros.run "wallworm.com" "WallWormHullHelperMCR"
	)
	on chk_noselfcollisions changed state do
	(
		ww_scene_lods.setNoselfcollisions state
	)
)

global wallworm_wwmt_pick_fast
rollout Wall_Worm_Model_Tools "Model & Basic QC" width:250 height:677
(
	PickButton addModel "Pick Model" filter:wallworm_allowed_wwmt_obj pos:[9, 7] width:119 height:37 toolTip:"Pick your model. If your model is composed of multiple meshes, choose the root mesh that will be used to define the origin. For existing WWMT, pick the WWMT Helper Name to pre-fill details of a model you've already made." autoDisplay:false
	CheckButton ckbFastMode "^" pos:[130, 8] width:14 height:35 toolTip:"Click Here to turn off comprehensive object type filters in the pick tool if picking is slow." checked:false
	PickButton btn_appendModels "Append" pos:[147, 8] width:91 height:14 enabled:false toolTip:"Click to choose another mesh to add to the Model."
	Button btn_addSelection "Add Sel" pos:[147, 28] width:44 height:16 enabled:false toolTip:"Click to add Currently Selected mesh(es) to to the Model."
	Button btn_removeSelFromTargets "Del Sel" pos:[195, 28] width:42 height:15 enabled:false toolTip:"Remove selected objects from the model."
	DropDownList ddl1 "Surface Property" pos:[11, 56] width:136 height:40 enabled:false
	Label lbl1 "Model Folder Path" pos:[10, 293] width:90 height:18 toolTip:"Enter a path that is relative to the Mod's Model folder."
	Label lbl2 "Material Folder Path" pos:[12, 372] width:141 height:21 toolTip:"Enter a path that is relative to the Mod's Material folder."
	ComboBox edt1_modelPath "" pos:[6, 310] width:229 height:3 enabled:false toolTip:"Enter the folder path relative to the SDK model folder without starting or ending slashes."
	ComboBox edt2_materialFolder "" pos:[9, 392] width:226 height:3 enabled:false toolTip:"Enter the folder path relative to the SDK material folder without starting or ending slashes."
	GroupBox grp1 "Settings" pos:[8, 99] width:228 height:86
	CheckBox chk_staticprop "$staticprop" pos:[13, 116] width:79 height:14 enabled:false toolTip:"Check here is this is a static prop with no animations."
	CheckBox chk_opaque "$opaque" pos:[13, 163] width:67 height:14 enabled:false toolTip:"Check this to tell the compiler this is an opaque model. Also forces VMTs for this model to exclude any translucency if your WWMT Settings force this."
	CheckBox chk_mostlyopaque "$mostlyopaque" pos:[83, 163] width:94 height:14 enabled:false
	CheckBox chk_alwayscollapse "$alwayscollapse" pos:[13, 133] width:98 height:14 enabled:false toolTip:"Collapse the mesh bones for skinned models."
	CheckBox chk_collapsebones "$collapsebones" pos:[13, 148] width:98 height:14 enabled:false toolTip:"Collapse all bones that have no weighted vertices or don't belong to a hierarchy."
	Spinner spn_scale "Scale" pos:[146, 127] width:84 height:16 enabled:false range:[0.01, 100, 1] scale:0.1
	EditText edt_ModelName "Model Name" pos:[11, 453] width:224 height:27 toolTip:"Enter the name for this model (only use letters, numbers and underscore. Avoid spaces, periods or any special characters)."
	Button btn_SelectModel "Select Model" pos:[152, 68] width:86 height:15 enabled:false toolTip:"Select in viewport all meshes that are part of the base model (not collision hulls or LODs)."
	Button btnSelectWWMTHelper "Select WWMT" pos:[152, 85] width:85 height:12 toolTip:"Select the WWMT Helper for this model in the scene."
	Button btn_illum "Illumination" pos:[182, 147] width:48 height:32 enabled:false images:#((::wallworm_installation_path + "/Wallworm.com/assets/wwmt_illum_icon_buttons.png"), undefined, 2, 1, 1, 2, 1, false) toolTip:"Click Here to select the Illumination Origin"
	Button btn_open_model_folder "Mdlsrc" pos:[195, 292] width:40 height:16 toolTip:"Click here to open the model folder."
	Button btn_open_mat_folder "Raw" pos:[197, 372] width:38 height:16 toolTip:"Click here to open the material folder."
	Button btn_setSkyScale "1/16" pos:[166, 109] width:29 height:17 enabled:false toolTip:"Set to Skybox Scale ( 1/16 )"
	Button btn_setSkyScale2 "1/32" pos:[198, 109] width:32 height:17 enabled:false toolTip:"Set to L4D Skybox Scale ( 1/32 )"
	Label lbl3 "Sky Scales" pos:[114, 108] width:52 height:15
	CheckBox chk_altOrigin "Flip" pos:[15, 225] width:36 height:15 enabled:false toolTip:"Click here if the model should be flipped (mirrored)."
	GroupBox grp_Origin "$origin" pos:[9, 193] width:228 height:91
	CheckBox chk_localOrigin "Use Local Origin as World Origin" pos:[15, 206] width:176 height:17 enabled:false toolTip:"Click here if you want the origin of the model's world set to the model's origin. This might be necessary if you are creating models inside of scenes instead of their own files."
	CheckBox chk_lock_origin "Lock Origin State" pos:[56, 225] width:106 height:15 enabled:false toolTip:"Check this option if the root node is animated in its own space."
	Hyperlink custAltHelp "Origin Offset" pos:[163, 258] width:64 height:18 address:"http://dev.wallworm.com/document/56/model__basic_qc_rollout.html#uselocalorigin" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	Button btnShowModel "Show" pos:[148, 50] width:43 height:14 enabled:false toolTip:"Unhide the model if it is hidden."
	Button btnHideModel "Hide" pos:[195, 50] width:42 height:14 enabled:false toolTip:"Hide the model."
	DropDownList ddlNormals "Normals" pos:[100, 486] width:134 height:40 enabled:false items:#("Face Render Normals", "Explicit Normals", "Auto") toolTip:"Choose the method for determining vertex normals. Defaults to Face Render Normals. But you can also choose other options."
	Button btn15 "Dir" pos:[172, 292] width:22 height:16 toolTip:"Open the folder where the final MDL files get compiled."
	Button btn31 "VMT Dir" pos:[151, 372] width:45 height:16 toolTip:"Open the folder where the final VMTs for this model export to."
	Button btn48 "QC" pos:[111, 292] width:30 height:16 toolTip:"Open the QC file in Notepad."
	Button btnCust "QCI" pos:[142, 292] width:29 height:16 toolTip:"Open the custom QCI file in Notepad."
	CheckBox chkInternalOrigin "Calculate Origin in SMD" pos:[16, 243] width:142 height:15 enabled:false checked:true toolTip:"When on, the Origin is calculated in the SMD. When off, calculated in the QC. Some mods do not compile the QC $origin anymore. Also, this option only works with the WW SMD Exporter."
	CheckBox chkRotateOrigin "Rotate Origin" pos:[16, 261] width:95 height:17 enabled:false checked:true toolTip:"Rotate the Z-Axis of the model so that it exports in same system as the Max world (and brush geometry). You may want to turn this off with some animated models."
	CheckBox chk_lockQC "Lock QC" pos:[12, 509] width:66 height:17 enabled:false checked:false toolTip:"Click here if you do not want to overwrite the QC for this model after it has been generated. When locked, the export process will only overwrite SMDs when you export."
	Label lbl7 "Channel" pos:[11, 486] width:43 height:19
	Spinner spn_mapChannel "" pos:[54, 486] align:#left width:38 height:16 enabled:false range:[-1, 99, 1] type:#integer scale:1 toolTip:"Enter the UVW Mapping Channel to use at export or 0 for fast auto detect from diffuse bitmap or -1 for slower but possibly more accurate auto-detect. Only available if using the WWMT SMD Exporter. Otherwise, only channel one is used."
	CheckBox chkDMX "Export as DMX (WW Pro Only)" tooltip:"Export DMX files rather than SMD and VTA. Requires WW Pro." pos:[12, 530] enabled:false
	Button runExport "Export QC+Model" pos:[137, 548] width:100 height:37 enabled:false toolTip:"Click to run the Model Exporter... which creates SMDs, QCs, VTAs and a batch file in sdk_content folders. Compiles the Model."
	Button runQC "Write QC" pos:[8, 548] width:60 height:37 enabled:false toolTip:"Click to write just the QCs. Does not compile."
	Button runSMD "Write SMDs" pos:[70, 548] width:66 height:37 enabled:false toolTip:"Click to write just the SMDs. Does not compile."
	DropDownList ddl_shader "" pos:[122, 602] width:108 height:21 enabled:false items:#("VertexLitGeneric", "UnlitGeneric")
	DropDownList ddl_compression "Compression" pos:[15, 613] width:99 height:40 enabled:false items:#("", "DXT5", "nocompress") selection:5
	GroupBox grp5 "Materials" pos:[5, 588] width:231 height:74
	Button btn_tex "Export VTFs" pos:[122, 628] width:108 height:26 enabled:false toolTip:"Click here to compile the textures in your model to VMTs and VTFs."
	function setWWMTFromOBJ obj = (
		local isSource
		ww_scene_lods.init()
		if isProperty obj #wwmt AND isProperty obj #getWWMT then (
			isSource = true
			obj.getWWMT()
			if obj.wwmt != undefined then (
				ww_scene_lods = obj.wwmt
			)
		) else (
			isSource = getUserProp obj #wwmt_source_helper
		)
		if obj.material == undefined AND isSource == undefined AND superClassOf obj == GeometryClass AND ::wwmt_autoMaterialNewModel != true then (
			messageBox "You must first apply a material to your model."
			addModel.caption = "Pick Model"
		) else (
			if ((ww_scene_lods.setTargetModel obj ww_scene_lods) == true) then (
				wallworm_setWWMUI()
			) else (
				messageBox "There was an unknown problem. If this error continues, please submit a bug report on the WW forums at wallworm.net ."
			)
		)
	)
	on chkDMX changed stat do (
		if ::WallwormProActive == true then (
			if ::ww_scene_lods != undefined AND isValidNode ::ww_scene_lods.target then (
				::ww_scene_lods.dmx = stat
				::ww_scene_lods.target.dmx = stat
			)
		)
	)

	on Wall_Worm_Model_Tools open do
	(
		if ::wallworm_wwmt_pick_fast == undefined then (
			::wallworm_wwmt_pick_fast = false
		)
		ckbFastMode.checked = ::wallworm_wwmt_pick_fast
		ddl1.items = ::wwmt_surfaceprop_list
		if (::wwmt_current_material_Paths != undefind AND ::wwmt_current_material_Paths.count > 0) then (
			edt2_materialFolder.items = ::wwmt_current_material_Paths
		)
		if (::wwmt_current_model_Paths != undefined AND ::wwmt_current_model_Paths.count > 0) then (
			edt1_modelPath.items = ::wwmt_current_model_Paths
		)
		if ::wwmt_def_model_path != undefined then (
			edt1_modelPath.selection = findItem edt1_modelPath.items ::wwmt_def_model_path
		)
		if ::wwmt_def_material_path != undefined then (
			edt2_materialFolder.selection = findItem edt2_materialFolder.items ::wwmt_def_material_path
		)
	)
	on Wall_Worm_Model_Tools moved pos do
	(
		setINISetting ::wallworm_userIni "Layout" "wwmt_ui_pos" (pos as String)
	)
	on addModel picked obj do
	(
		local wws = for ww in objects WHERE isProperty ww #wwmt_ca AND isProperty ww #wallworm AND findItem ww.targets obj != 0 collect ww

		case wws.count of (
			0: (
				/*
				Fall Back  to looking for old WWMT Source name in userprop data
				*/
				sname = getUserProp obj #wwmt_source
				if sname != undefined then (
					target = getNodeByName sname
					if (target == undefined) then (
						setWWMTFromOBJ obj
					) else (
						setWWMTFromOBJ target
						setUserProp obj #wwmt_source undefined
					)
				) else (
					setWWMTFromOBJ obj
				)
			)
			1: (
				setWWMTFromOBJ wws[1]
			)
			default:(
				messageBox "Because this object is part of multiple WWMT Helpers, the correct one could not be determined. Please choose the WWMT Helper for the model you want to use instead of the mesh. Hit F11 to see a list of WWMT Helpers using this mesh."
				print wws
			)
		)
	)
	on btn_appendModels picked obj do
	(
		if ww_scene_lods.target != undefined then (
			if (ww_scene_lods.addObjToObjects obj) then (
				ww_scene_lods.setTargetCust()
				if ww_scene_lods.targets.count > 1 then (
					btn_removeSelFromTargets.enabled = true
				)
			) else (
				messageBox "The action failed. Some geometry cannot be used (for example, a WWMT Helper)."
			)
		)
	)
	on btn_addSelection pressed do
	(
		if (ww_scene_lods.addObjToObjects $selection) then (
			ww_scene_lods.setTargetCust()
			if ww_scene_lods.targets.count > 1 then (
				btn_removeSelFromTargets.enabled = true
			)
		) else (
			messageBox "The action failed. Some geometry cannot be used (for example, a WWMT Helper)."
		)
	)
	on btn_removeSelFromTargets pressed do
	(
		ww_scene_lods.removeItemsFromTargets selection
	)
	on ddl1 selected sel do
	(
		ww_scene_lods.setSurfaceProperty(ddl1.items[sel])
	)
	on runExport pressed do
	(
		if (ww_scene_lods.target == undefined) then (
			messageBox "You must first pick your model/mesh or a collision model."
		) else (
			if(ww_scene_lods.modelPath == undefined OR ww_scene_lods.materialPath == undefined)then (
				messageBox "You must set Model and Material Paths."
			) else (
				ers = ww_scene_lods.checkForProblems()
				if ers.count == 0 then (
					ww_scene_lods.outputModelQC writeSMDs:true
				) else (
					message = "There were problems you need to address:\n\n"
					for em in ers do (
						append message ("\t* " + em + "\n")
					)
					messageBox message
				)
			)
		)
	)
	on runQC pressed do
	(
		if ww_scene_lods.locked then (messageBox "The QC lock is set. You cannot overwrite the QC because of that.") else (
			if (ww_scene_lods.target == undefined) then (
				messageBox "You must first pick your model/mesh or a collision model."
			) else (
				if(ww_scene_lods.modelPath == undefined OR ww_scene_lods.materialPath == undefined)then (
					messageBox "You must set Model and Material Paths."
					return messageBox
				) else (
					ers = ww_scene_lods.checkForProblems()
					if ers.count == 0 then (
						ww_scene_lods.outputModelQC writeSMDs:false
					) else (
						message = "There were problems you need to address:\n\n"
						for em in ers do (
							append message ("\t* " + em + "\n")
						)
						messageBox message
					)
				)
			)
		)
	)
	on runSMD pressed do
	(
		if (ww_scene_lods.target == undefined) then (
			messageBox "You must first pick your model/mesh or a collision model."
		) else (
			if(ww_scene_lods.modelPath == undefined OR ww_scene_lods.materialPath == undefined)then (
				messageBox "You must set Model and Material Paths."
			) else (
				ers = ww_scene_lods.checkForProblems()
				if ers.count == 0 then (
					if (ww_scene_lods.exportSMDS resetBnArray:true runCompile:false) == false then (
						messageBox "The SMDs were not exported."
					)
				) else (
					message = "There were problems you need to address:\n\n"
					for em in ers do (
						append message ("\t* " + em + "\n")
					)
					messageBox message
				)
			)
		)

	)
	on edt1_modelPath selected sel do
	(
		ww_scene_lods.setModelPath(edt1_modelPath.items[sel])
	)
	on edt1_modelPath entered text do
	(
		ww_scene_lods.setModelPath(text)
	)
	on edt1_modelPath changed text do
	(
		ww_scene_lods.setModelPath(text)
	)
	on edt2_materialFolder selected sel do
	(
		ww_scene_lods.setMaterialPath(edt2_materialFolder.items[sel])
	)
	on edt2_materialFolder entered text do
	(
		ww_scene_lods.setMaterialPath(text)
	)
	on edt2_materialFolder changed text do
	(
		ww_scene_lods.setMaterialPath(text)
	)
	on chk_alwayscollapse changed state do (
		ww_scene_lods.target.alwayscollapse = state
		ww_scene_lods.alwayscollapse = state
	)
	on chk_collapsebones changed state do (
		ww_scene_lods.target.collapsebones = state
		ww_scene_lods.collapsebones = state
	)
	on chk_staticprop changed state do
	(
		ww_scene_lods.setStaticprop(state)
	)
	on chk_opaque changed state do
	(
		ww_scene_lods.setOpaque(state)
	)
	on chk_mostlyopaque changed state do
	(
		ww_scene_lods.setMostlyOpaque(state)
	)
	on spn_scale changed val do
	(
		ww_scene_lods.setScale(val)
	)
	on edt_ModelName entered text do
	(
		ww_scene_lods.setModelName(text)
		if modelName != text then (
			edt_modelName.text = ww_scene_lods.modelName
		)
	)
	on btn_SelectModel pressed do
	(
		local trgs = for obj in ww_scene_lods.targets WHERE isValidNode obj collect obj
		if trgs.count > 0 then (
			select trgs
		) else (
			messageBox "There was a problem; no objects still associated to this WWMT Helper."
		)
	)
	on btnSelectWWMTHelper pressed do
	(
		if ww_scene_lods != undefined AND isValidNode ww_scene_lods.target then (
			select ww_scene_lods.target
		) else (
			messageBox "The WWMT Helper has been deleted from the scene!"
		)
	)
	on btn_illum pressed do
	(
		if ww_scene_lods.illumorigin == undefined OR isDeleted ww_scene_lods.illumorigin then (
			ww_scene_lods.createIlluminationHelper()
		)
		select ww_scene_lods.illumorigin
	)
	on btn_tex pressed do
	(
		if ww_scene_lods.canCompile "tex" then (
			ers = ww_scene_lods.checkForProblems()
			if ers.count == 0 then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/textureExport.ms")
			) else (
				message = "There were problems you need to address:\n\n"
				for em in ers do (
					append message ("\t* " + em + "\n")
				)
				messageBox message
			)
		) else (
			messageBox "To compile textures, the following requirements must be met:\n\n*Set a \"Material Path\" in the Export Options rollout\n*Have valid materials on model\n*\"Bin Dir\" AND \"Material Root Directory\" set in the Global WW Settings\n*Your Mod must have VTEX.EXE in the Bin Folder"
		)
	)
	on btn_open_model_folder pressed do
	(
		local m = ""
		if edt1_modelPath.text != "" then (
			if ww_scene_lods.modelPath != undefined then (
				m = ww_scene_lods.modelPath
			) else(
				m = ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)
		)
		local wwDir = ww_scene_lods.FsToBs (::wwmt_export + "/" + m)

		local canOpen = doesFileExist wwDir
		if NOT canOpen then (
			canOpen = makeDir wwDir all:true
		)
		if canOpen then (
			folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
			print folderOpen
			execute folderOpen
		)
	)
	on btn_open_mat_folder pressed do
	(
		local m = ""
		if edt2_materialFolder.text != "" then (
			if ww_scene_lods.materialPath != undefined then (
				m = ww_scene_lods.materialPath
			) else (
				m = ::wwmt_def_material_path
			)
		)
		local wwDir = ww_scene_lods.FsToBs (::wwmt_exportMats + "\\" + m)
		local canOpen = doesFileExist wwDir
		if NOT canOpen then (
			canOpen = makeDir wwDir all:true
		)
		if canOpen then (
			folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
			execute folderOpen
		)
	)
	on btn_setSkyScale pressed do
	(
		spn_scale.value = 0.0625
		ww_scene_lods.setScale(spn_scale.value)
	)
	on btn_setSkyScale2 pressed do
	(
		spn_scale.value = 0.03125
		ww_scene_lods.setScale(spn_scale.value)
	)
	on chk_altOrigin changed state do
	(
		ww_scene_lods.setAltOrigin(state)
	)
	on chk_localOrigin changed state do
	(
		ww_scene_lods.setLocalOrigin(state)
	)
	on chk_lock_origin changed state do
	(
		ww_scene_lods.setLockOrigin state
	)
	on chk_lockQC changed state do
	(
		ww_scene_lods.setLock(state)
	)
	on ddl_shader selected sel do
	(
		ww_scene_lods.setShaderType ddl_shader.selected
	)
	on spn_mapChannel changed val do
	(
		ww_scene_lods.setUVW(val)
		if ::wwmtExporter < 3 then (
			if ::wwmtExporter == 2 then (
				messageBox "This feature is not available when using the Canonfodder Exporters. If you need this feature, you need to get Wunderboy's SMD Exporter 1.7 or later from www.wunderboy.org."
			) else (
				try (
					if WBSMDExportVersionNum() < 1700 then (
						messageBox "If you need this feature, you need to get Wunderboy's SMD Exporter 1.7 or later from www.wunderboy.org."
					)
				) catch (
					messageBox "If you need this feature, you need to get Wunderboy's SMD Exporter 1.7 or later from www.wunderboy.org."
				)
			)
		)
	)
	on ddl_compression selected sel do
	(
		ww_scene_lods.setCompression ddl_compression.selected
	)
	on btnShowModel pressed do
	(
		unhide (for obj in ww_scene_lods.targets WHERE isValidNode obj collect obj)
	)
	on btnHideModel pressed do
	(
		hide (for obj in ww_scene_lods.targets WHERE isValidNode obj collect obj)
	)
	on ddlNormals selected sel do
	(
		ww_scene_lods.setNormalMethod sel
	)
	on btn15 pressed do
	(
		local m = ""
		if edt1_modelPath.text != "" then (
			if ww_scene_lods.modelPath != undefined then (
				m =  ww_scene_lods.modelPath
			) else(
				m =  ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)
		)
		local wwDir = wallworm_FStoBS (::wwmt_gameInfoDir + "\\models\\" + m)
		local canOpen = doesFileExist wwDir
		if NOT canOpen then (
			canOpen = makeDir (wwDir all:true)
		)
		if canOpen then (
			folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
			execute folderOpen
		) else (
			messageBox "This path doesn't exist and WW doesn't have permission to write it."
		)
	)
	on btn31 pressed do
	(
		local m = ""
		if edt2_materialFolder.text != "" then (
			if ww_scene_lods.materialPath != undefined then (
				m =  ww_scene_lods.materialPath
			) else (
				m =  ::wwmt_def_material_path
			)
		)
		local wwDir = wallworm_FStoBS (::wwmt_gameInfoDir + "\\materials\\" + m)
		local canOpen = doesFileExist wwDir
		if NOT canOpen then (
			canOpen = makeDir wwDir all:true
		)
		if canOpen then (
			folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
			execute folderOpen
		) else (
			messageBox "This path doesn't exist and WW doesn't have permission to write it."
		)
	)
	on btn48 pressed do
	(
		local m = ""
		if edt1_modelPath.text != "" then (
			if ww_scene_lods.modelPath != undefined then (
				m =  ww_scene_lods.modelPath
			) else(
				m =  ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)
		)
		local wwDir = wallworm_FStoBS (::wwmt_export + "\\" + m + "\\" + ww_scene_lods.modelName + ".qc")
		if doesFileExist wwDir == true then (
			folderOpen = "ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + wwDir + "\""
			execute folderOpen
		) else (
			messageBox "Oops... the QC doesn't exist yet. Export the model first."
		)
	)
	on btnCust pressed do
	(
		local m = ""
		if edt1_modelPath.text != "" then (
			if ww_scene_lods.modelPath != undefined then (
				m = ww_scene_lods.FsToBs ww_scene_lods.modelPath
			) else(
				m = ww_scene_lods.FsToBs ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)
		)
		local wwDir = wallworm_FStoBS (::wwmt_export + "\\" + m + "\\" + ww_scene_lods.modelName + "_wwmt_custom.qci")
		if doesFileExist wwDir == false then (
			ww_scene_lods.createCustomQCI()
		)
		if doesFileExist wwDir == true then (
			folderOpen = "ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + wwDir + "\""
			execute folderOpen
		) else (
			messageBox "Oops... the QCI doesn't exist yet and WWMT can only create/edit it once the model name has been set."
		)
	)
	on chkInternalOrigin changed state do
	(
		ww_scene_lods.setinternalOrigin state
	)
	on chkRotateOrigin changed state do
	(
		ww_scene_lods.setRotateRefsystem state
	)
	on ckbFastMode changed stat do
	(
		::wallworm_wwmt_pick_fast = stat
	)
)
rollout wwmt_exportRollout "Lighting & Miscellaneous Options" width:250 height:167
(
	Hyperlink expHelp "Lighting & Misc Help" pos:[8, 2] width:100 height:16 address:"http://dev.wallworm.com/document/62/lighting_rollout.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	Button btn_illum "Illumination" pos:[16, 43] width:48 height:32 enabled:false images:#((::wallworm_installation_path + "/Wallworm.com/assets/wwmt_illum_icon_buttons.png"), undefined, 2, 1, 1, 2, 1, false) toolTip:"Click Here to select the Illumination Origin"
	CheckBox chk_expHL1Format "HL1 Format" pos:[11, 143] width:78 height:16 enabled:false toolTip:"Only select this if you are exporting to the HL1 engine..."
	GroupBox grp4 "Lighting" pos:[8, 20] width:235 height:70
	CheckBox chk_ambientboost "$ambientboost" pos:[72, 40] width:106 height:18 enabled:false
	Spinner spn_constantdirectionallight "" pos:[200, 59] width:38 height:16 enabled:false
	Label lbl5 "$constantdirectionallight" pos:[71, 61] width:128 height:16
	Label lbl6 "All of the options below are optional and/or experimental. They may not work properly. Use at your own risk." pos:[8, 97] width:236 height:42 enabled:true

	on btn_illum pressed do
	(
		if ww_scene_lods.illumorigin == undefined then (
			ww_scene_lods.createIlluminationHelper()
		)
		select ww_scene_lods.illumorigin
	)
	on chk_expHL1Format changed state do
	(
		ww_scene_lods.setExpHL1Format state
	)
	on chk_ambientboost changed state do
	(
		ww_scene_lods.setAmbientboost(state)
	)
	on spn_constantdirectionallight changed val do
	(
		ww_scene_lods.setConstantdirectionallight val
	)
)

rollout wwmt_attachments "Attachments and Particles" width:239 height:627
(
	local hasResetBonesArray = false
	Hyperlink lnkSequenceHelp "Help" pos:[80, 8] width:22 height:15 address:"http://dev.wallworm.com/document/61/attachments__particle_system_ui.html" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
	ComboBox cbx_attachmentList "Attachements" pos:[8, 8] width:221 height:6 enabled:false
	DropDownList ddl_attachmentBone "Parent Bone" pos:[8, 145] width:223 height:40 enabled:false
	CheckBox chk_attachmentAbsolute "Absolute" pos:[8, 194] width:66 height:16 enabled:false
	CheckBox chk_attachmentRigid "Rigid" pos:[81, 194] width:46 height:16 enabled:false
	Button btn_createAttachment "Create Attachment" pos:[9, 120] width:110 height:22 enabled:false toolTip:"Click here to create a new attachment point. The name of the attachment will be the name entered in the attachments list above."
	Button btn_deleteAttachment "Delete Attachment" pos:[127, 120] width:101 height:22 enabled:false toolTip:"Delete the currently hilighted attachment."
	Button btn_attachUpdateBoneList "Update Bone List" pos:[135, 194] width:94 height:17 enabled:false toolTip:"Update the Parent Bone list for the model."
	Button btn_selectPoint "Select Point" pos:[135, 7] width:85 height:14 enabled:false
	Label lbl1 "Attach Particle System Events" pos:[12, 238] width:214 height:18
	ComboBox cbxParticles "Particle System Name" pos:[11, 265] width:213 height:6
	DropDownList ddlSeqList "Use in Sequence" pos:[11, 515] width:216 height:40
	Spinner spnFrame "At Frame" pos:[22, 569] width:208 height:16 type:#integer scale:1
	Button btnAddParticle "+" pos:[159, 260] width:32 height:19 toolTip:"Add Particle System Event."
	Button btnRemoveParticle "-" pos:[194, 260] width:28 height:19 toolTip:"Remove particle system event."
	DropDownList ddl_attachTo "Attach To:" pos:[12, 415] width:214 height:40 items:#("start_at_origin", "start_at_attachment", "follow_origin", "follow_attachment")
	DropDownList ddl_attachToAttachment "Choose Attachment" pos:[12, 460] width:214 height:40
	RadioButtons rdoParticleType "QC Type" pos:[12, 383] width:211 height:30 labels:#("keyvalue", "once", "scripted") columns:3
	Button btn24 "Get" pos:[130, 259] width:25 height:20 toolTip:"Get a particle system from known effects."
	Spinner spnEnd "End At Frame" pos:[19, 597] width:210 height:16 type:#integer scale:1

	function updateAttachmentList = (
		cbx_attachmentList.items = ddl_attachToAttachment.items = ww_scene_lods.getAttachmentList()
	)

	on wwmt_attachments open do (
		updateAttachmentList()
	)

	function addParticles n = (
		local ps = wwmt_particles()
		ps.systemname = n
		if rdoParticleType.state == 1 then (
			ps.type = "keyvalue"
		) else if rdoParticleType.state == 2 then (
			ps.type = "start"
		) else if rdoParticleType.state == 3 then (
			ps.type = "end"
		) else (
			ps.type = "keyvalue"
		)
		ps.attachTo = ddl_attachTo.selected
		ps.sequence = ddlSeqList.selected
		ps.pframe = spnFrame.value
		ps.pEnd = spnEnd.value
		::ww_scene_lods.addParticleSystem ps
		local tempItems = cbxParticles.items
		append tempItems n
		cbxParticles.items = tempItems
		cbxParticles.selection = 0
	)

	function setParticleNames n = (
		addParticles n
	)
	function setParticleButtons = (
		local states = #("keyvalue", "once", "scripted")
		if rdoParticleType.state == findItem states "keyvalue" then (
			spnFrame.enabled = false
			ddlSeqList.enabled = false
		) else (
			spnFrame.enabled = true
			ddlSeqList.enabled = true
		)
		ddl_attachTo.enabled = true

		if rdoParticleType.state == findItem states "scripted" then (
			spnEnd.enabled = true
		) else (
			spnEnd.enabled = false
		)
		if ddl_attachTo.selected == "start_at_attachment" OR ddl_attachTo.selected == "follow_attachment" then (
			ddl_attachToAttachment.enabled = true
			if cbxParticles.selection > 0 AND (ww_scene_lods.particlesystems[cbxParticles.selection].attachmentPoint == undefined OR ww_scene_lods.particlesystems[cbxParticles.selection].attachmentPoint == "") then (
				if ddl_attachToAttachment.selected != undefined then (
					ww_scene_lods.particlesystems[cbxParticles.selection].attachmentPoint = ddl_attachToAttachment.selected
					ww_scene_lods.setParticleSystems()
				)
			)
		) else (
			ddl_attachToAttachment.enabled = false
		)
	)
	function getSeqList = (
		ddlSeqList.items = ::wwToolsFloater.rollouts[5].cbx_sequences.items
	)
	function setFormFromAttachment att = (
		local atPoint = att.atPoint
		if isValidNode atPoint.parent then (
			ddl_attachmentBone.selection = findItem ddl_attachmentBone.items atPoint.parent.name
		)
		if att.absolute == true then (
			chk_attachmentAbsolute.checked = true
		) else (
			chk_attachmentAbsolute.checked = false
		)
		if att.rigid == true then (
			chk_attachmentRigid.checked = true
		) else (
			chk_attachmentRigid.checked = false
		)
		cbxParticles.enabled = true
		ddlSeqList.enabled = true
		spnFrame.enabled = true
		btnAddParticle.enabled = true
		btnRemoveParticle.enabled = true
		spnEnd.enabled = true
		getSeqList()
	)

	on cbx_attachmentList selected sel do
	(
		--set other values
		notf = true
		for s in ww_scene_lods.attachments while notf do (
			if cbx_attachmentList.items[sel] == s.attachment then (
				setFormFromAttachment s
				notf = false
			)
		)
	)
	on ddl_attachmentBone selected sel do (
		ww_scene_lods.setAttBone cbx_attachmentList.selected ddl_attachmentBone.items[sel]
	)
	on chk_attachmentAbsolute changed state do
	(
		if cbx_attachmentList.selection != 0 then (
			local att = ww_scene_lods.attachments[cbx_attachmentList.selection]
			if ww_scene_lods.attachments[cbx_attachmentList.selection] != undefined then (
				ww_scene_lods.attachments[cbx_attachmentList.selection].absolute = state
				ww_scene_lods.attachments[cbx_attachmentList.selection].setAttachment()
			)
		)
		--ww_scene_lods.setAttAbsolute  cbx_attachmentList.selected state 
	)
	on chk_attachmentRigid changed state do
	(
		if cbx_attachmentList.selection != 0 then (
			local att = ww_scene_lods.attachments[cbx_attachmentList.selection]
			if ww_scene_lods.attachments[cbx_attachmentList.selection] != undefined then (
				ww_scene_lods.attachments[cbx_attachmentList.selection].rigid = state
				ww_scene_lods.attachments[cbx_attachmentList.selection].setAttachment()
			)
		)
	)
	on btn_createAttachment pressed do (
		t = wallworm_makeStringSafe cbx_attachmentList.text
		if (t == "") then (
			message = "You must enter a unique name in the attachement field."
			messageBox message
		) else (
			if ((findItem cbx_attachmentList.items t) == 0) then (
				local att = ww_scene_lods.createNewAttachment absolute:chk_attachmentAbsolute.checked rigid:chk_attachmentRigid.checked label:t pb:undefined asBone:false
				cbx_attachmentList.items = ddl_attachToAttachment.items = ww_scene_lods.getAttachmentList()
				cbx_attachmentList.selection = (findItem cbx_attachmentList.items t)
				setFormFromAttachment att
			) else (
				messageBox ("There is already an attachment with the name \"" + t + "\". Use another Name.")
			)
		)
	)
	on btn_createAttachment rightClick do (
		t = wallworm_makeStringSafe cbx_attachmentList.text
		if (t == "") then (
			message = "You must enter a unique name in the attachement field."
			messageBox message
		) else (
			if ((findItem cbx_attachmentList.items t) == 0) then (
				local att = ww_scene_lods.createNewAttachment absolute:chk_attachmentAbsolute.checked rigid:chk_attachmentRigid.checked label:t pb:undefined asBone:true
				setFormFromAttachment att
				cbx_attachmentList.items = ddl_attachToAttachment.items = ww_scene_lods.getAttachmentList()
				cbx_attachmentList.selection = (findItem cbx_attachmentList.items t)
				setFormFromAttachment att
			) else (
				messageBox ("There is already an attachment with the name \"" + t + "\". Use another Name.")
			)
		)
	)

	on btn_deleteAttachment pressed do
	(
		ww_scene_lods.removeAttachment cbx_attachmentList.selected
		cbx_attachmentList.items = ww_scene_lods.getAttachmentList()
		ddl_attachToAttachment.items = ww_scene_lods.getAttachmentList()
		ww_scene_lods.setAttListCust

	)
	on btn_attachUpdateBoneList pressed do
	(
		ww_scene_lods.resetBonesArray()
		theNames = ww_scene_lods.boneNameList()
		if theNames == undefined then (
			theNames = #()
		)
		for obj in ww_scene_lods.targets do (
			appendIfUnique theNames obj.name
		)
		ddl_attachmentBone.items = theNames

	)
	on btn_selectPoint pressed do
	(
		notf = true

		--include "wwmt_struct_attachment.ms"
		for s in ww_scene_lods.attachments while notf do (
			if s.attachment == cbx_attachmentList.selected then (
				select s.atPoint
				notf = false

			)

		)

	)
	on cbxParticles selected arg do
	(
		rdoParticleType.enabled = true
		local states = #("keyvalue", "once", "scripted")
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].sequence != undefined AND ww_scene_lods.particlesystems[arg].sequence != "" then (
			ddlSeqList.selection = findItem ddlSeqList.items ww_scene_lods.particlesystems[arg].sequence
		)
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].pframe != undefined then (
			spnFrame.value = ww_scene_lods.particlesystems[arg].pframe
		)
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].pEnd != undefined then (
			spnEnd.value = ww_scene_lods.particlesystems[arg].pEnd
		)
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].attachmentPoint != undefined AND ww_scene_lods.particlesystems[arg].attachmentPoint != "" then (
			ddl_attachToAttachment.selection = findItem ddl_attachToAttachment.items ww_scene_lods.particlesystems[arg].attachmentPoint
		)
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].attachTo != undefined AND ww_scene_lods.particlesystems[arg].attachTo != "" then (
			ddl_attachTo.selection = findItem ddl_attachTo.items ww_scene_lods.particlesystems[arg].attachTo
		)
		if ww_scene_lods.particlesystems[arg] != undefined AND ww_scene_lods.particlesystems[arg].type != undefined AND ww_scene_lods.particlesystems[arg].type != "" then (
			rdoParticleType.state = findItem states ww_scene_lods.particlesystems[arg].type
		)
		setParticleButtons()
	)
	on ddlSeqList selected sel do
	(
		if cbxParticles.selection > 0 then (
			ww_scene_lods.particlesystems[cbxParticles.selection].sequence = ddlSeqList.selected
			ww_scene_lods.setParticleSystems()
		)

	)
	on spnFrame changed val do
	(
		if cbxParticles.selection > 0 then (
			if ddlSeqList.selection > 0 then (
				for s in ww_scene_lods.sequences do (
					if s.sequence == ddlSeqList.selected AND val > s.end then (
						val = s.end
						messageBox ("The value you entered was higher than the end of the chosen sequence. The frame was lowered to " + (s.end as String) + ".")
					)
				)
			)
			if val > spnEnd.value then (
				spnEnd.value = val + 1
			)
			if spnFrame.value != val then (
				spnFrame.value = val
			)
			ww_scene_lods.particlesystems[cbxParticles.selection].pframe = val
			ww_scene_lods.setParticleSystems()
		)
	)
	on btnAddParticle pressed do
	(
		if cbxParticles.text != undefined AND cbxParticles.text != "" then (
			addParticles cbxParticles.text
		)
	)
	on btnRemoveParticle pressed do
	(
		if ww_scene_lods.particlesystems.count > 0 then (
			ww_scene_lods.removeParticleSystem cbxParticles.selection
			local tempItems = cbxParticles.items
			deleteItem tempItems cbxParticles.selection
			cbxParticles.items = tempItems
		)
	)
	on ddl_attachTo selected sel do
	(
		if ddl_attachToAttachment.items.count == 0 AND (ddl_attachTo.selected == "start_at_attachment" OR ddl_attachTo.selected == "follow_attachment") then (
			ddl_attachTo.selection = 0
			messageBox "You can only attach particles to Attachments if you have already created attachments."
		)
		if cbxParticles.selection > 0 then (
			ww_scene_lods.particlesystems[cbxParticles.selection].attachTo = ddl_attachTo.selected
			ww_scene_lods.setParticleSystems()
		)
		setParticleButtons()
	)
	on ddl_attachToAttachment selected sel do
	(
		if cbxParticles.selection > 0 then (
			ww_scene_lods.particlesystems[cbxParticles.selection].attachmentPoint = ddl_attachToAttachment.selected
			ww_scene_lods.setParticleSystems()
		)
	)
	on rdoParticleType changed stat do
	(
		if cbxParticles.selection > 0 then (
			if rdoParticleType.state == 1 then (
				ww_scene_lods.particlesystems[cbxParticles.selection].type = "keyvalue"
			) else if rdoParticleType.state == 2 then (
				ww_scene_lods.particlesystems[cbxParticles.selection].type = "once"
			) else if rdoParticleType.state == 3 then (
				ww_scene_lods.particlesystems[cbxParticles.selection].type = "scripted"
			) else (
				ww_scene_lods.particlesystems[cbxParticles.selection].type = "keyvalue"
			)
			ww_scene_lods.particlesystems[cbxParticles.selection].sequence = ddlSeqList.selected
			ww_scene_lods.setParticleSystems()
		)
		setParticleButtons()
	)
	on btn24 pressed do
	(
		try (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/particleDefaults.ms")
		) catch ()
	)
	on spnEnd changed val do
	(
		if cbxParticles.selection > 0 then (
			if ddlSeqList.selection > 0 then (
				for s in ww_scene_lods.sequences do (
					if s.sequence == ddlSeqList.selected AND val > s.end then (
						val = s.end
						messageBox ("The value you entered was higher than the end of the chosen sequence. The max time was lowered to " + (s.end as String) + ".")
					)
				)
			)
			if val < spnFrame.value then (
				spnFrame.value = val - 1
			)
			if spnEnd.value != val then (
				spnEnd.value = val
			)

			ww_scene_lods.particlesystems[cbxParticles.selection].pEnd = val
			ww_scene_lods.setParticleSystems()
		)
	)
)

rollout wwmt_sequences "Sequences, Activities and Weights" width:239 height:953
(
	Spinner spn_expStart "Start" pos:[20, 198] width:69 height:16 enabled:false range:[0, 999999, 0] type:#integer
	Spinner spn_expEnd "End" pos:[102, 199] width:74 height:16 enabled:false range:[0, 999999, 0] type:#integer
	--edittext edt_expSequenceName "Sequence Name" pos:[10,222] width:203 height:18 enabled:false
	CheckBox chk_expReverse "Reverse" pos:[13, 343] width:68 height:15 enabled:false
	ComboBox cbx_sequences "Sequences" pos:[4, 27] width:223 height:8 enabled:false selection:0
	Button btn_addSeq "Add Sequence" pos:[4, 163] width:82 height:21 enabled:false toolTip:""
	Button btn_delSeq "Delete Sequence" pos:[93, 163] width:90 height:21 enabled:false
	CheckBox chk_loop "Loop" pos:[13, 361] width:51 height:18 enabled:false
	Hyperlink lnkSequenceHelp "Sequence Help" pos:[155, 5] width:74 height:15 address:"http://dev.wallworm.com/document/60/sequences.html" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
	CheckBox chk_idleSequence "Use Idle Sequence" pos:[4, 4] width:117 height:16 enabled:false toolTip:"Make a default Idle Sequence at Frame 0"
	ComboBox cbxWeightLists "Weight Lists" pos:[21, 611] width:199 height:6
	Button btnAddWeightList "Add List" pos:[21, 737] width:53 height:18
	Button btn4 "Update Name" pos:[80, 737] width:81 height:19
	Button btnDeleteWeightList "Delete" pos:[168, 737] width:53 height:18
	ComboBox cbxWeightlistBones "Bones In List" pos:[24, 771] width:137 height:9
	Spinner spnWeight "Bone Weight in this List" pos:[34, 920] width:185 height:16 range:[0, 1, 1] type:#float scale:0.1
	Button btnAddBone "Add" pos:[169, 814] width:59 height:18
	Button btnDeleteBone "Delete" pos:[169, 837] width:60 height:23
	Button btnFillList "Fill List" pos:[168, 793] width:60 height:13
	ComboBox cbxSeqWeightlist "Sequence Weightlist" pos:[12, 225] width:220 height:6 selection:0
	Spinner spnFPS "FPS" pos:[124, 346] width:104 height:16 range:[1, 300, 30] scale:0.1
	CheckBox chkAutoPlay "Autoplay" pos:[13, 382] width:80 height:16
	Spinner spnActivityWeight "Activity Weight" pos:[91, 563] width:131 height:16 range:[-1, 1, 1]
	CheckBox chkSnap "Snap" pos:[13, 402] width:66 height:16
	CheckBox chkRealtime "Realtime" pos:[114, 366] width:82 height:15
	CheckBox chkAsAnimation "As $animation" pos:[114, 384] width:96 height:14
	EditText edtAnimations "Anims" pos:[13, 443] width:216 height:17
	CheckBox chkHidden "Hidden" pos:[114, 402] width:93 height:15
	CheckBox chkMakeSMD "Make SMD" pos:[13, 424] width:75 height:16
	Spinner spnFadeIn "Fade In" pos:[114, 484] width:114 height:16 range:[0, 1000, 0.2]
	Spinner spnFadeOut "Fade Out" pos:[105, 507] width:123 height:16 range:[0, 1000, 0.2]
	EditText edtNode "Node" pos:[114, 420] width:116 height:17
	EditText edtActivity "Activity" pos:[31, 535] width:192 height:22
	Button btnGetActivity "Get" pos:[21, 562] width:49 height:16 toolTip:"Select a common, default activity."
	EditText edtAddLayer "Add Layer" pos:[12, 464] width:217 height:16
	Button btnNoWeightList "None" pos:[158, 223] width:72 height:18

	Button btnCompileSequence "Compile" pos:[187, 163] width:42 height:21 toolTip:"Compile the selected Sequence SMD."
	Button btnTimeline "Timeline" pos:[185, 199] width:45 height:18 tooltip:"Set the timeline to this range."
	on btnTimeline pressed do (
		if spn_expStart.value < spn_expEnd.value then (
			animationRange = interval spn_expStart.value spn_expEnd.value
			sliderTime = spn_expStart.value
		)
	)

	function setSequenceFromUI = (
		local theSequence
		if ww_scene_lods.sequences != undefined AND ww_scene_lods.sequences.count > 0 AND cbx_sequences.selection > 0 AND ww_scene_lods.sequences[cbx_sequences.selection] != undefined then (
			theSequence = ww_scene_lods.sequences[cbx_sequences.selection]
			ww_scene_lods.sequences[cbx_sequences.selection].weightlist = cbxSeqWeightlist.selected
			ww_scene_lods.sequences[cbx_sequences.selection].autoplay = chkAutoPlay.state
			ww_scene_lods.sequences[cbx_sequences.selection].realtime = chkRealtime.state
			ww_scene_lods.sequences[cbx_sequences.selection].asAnimation = chkAsAnimation.state
			ww_scene_lods.sequences[cbx_sequences.selection].snap = chkSnap.state
			ww_scene_lods.sequences[cbx_sequences.selection].hidden = chkHidden.state
			ww_scene_lods.sequences[cbx_sequences.selection].makeSMD = chkMakeSMD.state
			ww_scene_lods.sequences[cbx_sequences.selection].addLayer = edtAddLayer.text
			ww_scene_lods.sequences[cbx_sequences.selection].fadeOut = spnFadeOut.value
			ww_scene_lods.sequences[cbx_sequences.selection].animations = edtAnimations.text
			ww_scene_lods.sequences[cbx_sequences.selection].nd = edtNode.text
			ww_scene_lods.sequences[cbx_sequences.selection].activityWeight = spnActivityWeight.value
			ww_scene_lods.sequences[cbx_sequences.selection].fps = spnFPS.value
			ww_scene_lods.sequences[cbx_sequences.selection].fadeIn = spnFadeIn.value
			ww_scene_lods.sequences[cbx_sequences.selection].activity = edtActivity.text
			ww_scene_lods.setSeqListCust()
		)
		theSequence
	)

	function updateWeightList tex = (
		if tex != undefined AND tex != "undefined" AND tex != "" AND findItem cbxSeqWeightlist.items tex == 0 then (
			itemList = cbxSeqWeightlist.items
			append itemList tex
			cbxSeqWeightlist.items = itemList
			cbxSeqWeightlist.selection = itemList.count
		) else (
			cbxSeqWeightlist.selection = 0
		)
	)

	function setFormFromSequence seq = (
		spn_expStart.value = seq.start
		spn_expEnd.value = seq.end
		chkSnap.state = seq.snap
		chkHidden.state = seq.hidden
		chkMakeSMD.state = seq.makeSMD
		chkAutoPlay.state = seq.autoplay
		spnActivityWeight.value = seq.activityWeight
		chkRealtime.state = seq.realtime
		chkAsAnimation.state = seq.asAnimation
		edtAnimations.text = seq.animations
		spnFadeIn.value = seq.fadeIn as Float
		spnFadeOut.value = seq.fadeOut as Float
		edtNode.text = seq.nd
		edtActivity.text = seq.activity
		edtAddLayer.text = seq.addLayer
		spnFPS.value = (seq.fps as Float)

		if seq.weightlist != undefined AND seq.weightlist != "" then (
			updateWeightList seq.weightlist
			cbxSeqWeightlist.selection = findItem cbxSeqWeightlist.items seq.weightlist
		) else (
			cbxSeqWeightlist.selection = 0
		)

		if seq.expReverse == 1 then (
			chk_expReverse.checked = true
		) else (
			chk_expReverse.checked = false
		)
		if seq.loop == 1 then (
			chk_loop.checked = true
		) else (
			chk_loop.checked = false
		)
	)

	function addToWeightBoneList boneName = (
		local tempList = cbxWeightlistBones.items
		if cbxWeightLists.selection != 0 then (
			if ::ww_scene_lods.weightlists[cbxWeightLists.selection] != undefined then (
				::ww_scene_lods.weightlists[cbxWeightLists.selection].setWeightByBoneName boneName spnWeight.value
				if findItem tempList boneName == 0 then (
					append tempList boneName
				)
				::ww_scene_lods.weightlists[cbxWeightLists.selection].writeWeightListToObject ::ww_scene_lods.target
				cbxWeightlistBones.selection = 0
				cbxWeightlistBones.items = tempList
			)
		)
	)

	on spn_expStart changed val do
	(
		ww_scene_lods.setExpStart cbx_sequences.selected val
	)
	on spn_expEnd changed val do
	(
		ww_scene_lods.setExpEnd cbx_sequences.selected val
	)
	on chk_expReverse changed state do
	(
		if state == true then (
			ww_scene_lods.setExpReverse cbx_sequences.selected 1

		) else (
			ww_scene_lods.setExpReverse cbx_sequences.selected 0

		)
	)
	on cbx_sequences selected sel do
	(
		--set other values

		notf = true
		for s in ww_scene_lods.sequences while notf do (
			if cbx_sequences.items[sel] == s.sequence then (
				setFormFromSequence s
				if s.start != undefined AND s.start != "" then (
					anR = animationRange

					newstart = undefined
					newend = undefined

					if anR.start > s.start then (
						newstart = s.start
					)

					if anR.end < s.end then (
						newend = s.end
					)
					if newstart == undefined then (
						newstart = animationRange.start
					)
					if newend == undefined then (
						newend = animationRange.end
					)

					animationRange = interval newstart newend

					sliderTime = s.start
				)
				notf = false
			)

		)

	)
	on btn_addSeq pressed do
	(
		t = cbx_sequences.text
		if ((t == "")) then (
			messageBox "You must enter a unique name in the sequence field."
		) else (
			if ((findItem cbx_sequences.items t) == 0) then (
				append ww_scene_lods.sequencelist t
				cbx_sequences.items = ww_scene_lods.sequencelist
				seq = wwmt_sequence()
				seq.sequence = t
				seq.start = spn_expStart.value
				seq.end = spn_expEnd.value
				seq.fps = frameRate
				seq.type = "Sequence"
				if chk_loop.checked == false then (
					seq.loop = 0
				) else (
					seq.loop = 1
				)
				if chk_expReverse.checked == false then (
					seq.expReverse = 0
				) else (
					seq.expReverse = 1
				)
				ww_scene_lods.addToSequences seq
				ww_scene_lods.setSeqListCust()
				ind = findItem cbx_sequences.items t
				cbx_sequences.selection = ind
				setFormFromSequence seq
				setSequenceFromUI()
				::wwToolsFloater.rollouts[6].ddlSeqList.items = cbx_sequences.items
			)
		)
	)
	on btn_delSeq pressed do
	(
		ww_scene_lods.removeSequence cbx_sequences.selected
		cbx_sequences.items = ww_scene_lods.sequencelist
		ww_scene_lods.setSeqListCust
		::wwToolsFloater.rollouts[6].ddlSeqList.items = cbx_sequences.items
	)
	on chk_loop changed state do
	(
		if state == true then (
			ww_scene_lods.setLoop cbx_sequences.selected 1
		) else (
			ww_scene_lods.setLoop cbx_sequences.selected 0
		)
		ww_scene_lods.setSeqListCust()
	)
	on chk_idleSequence changed stat do
	(
		ww_scene_lods.setIdleSequence stat
	)
	on cbxWeightLists selected sel do
	(
		if isProperty ww_scene_lods.weightlists[cbxWeightLists.selection] #bns AND ww_scene_lods.weightlists[cbxWeightLists.selection].bns != undefined then (
			cbxWeightlistBones.items = ww_scene_lods.weightlists[cbxWeightLists.selection].bns
		)
	)
	on btnAddWeightList pressed do
	(
		t = cbxWeightLists.text
		if (t == "") then (
			messageBox "You must enter a unique name in the Leight Lists field."
		) else (
			if ((findItem cbxWeightLists.items t) == 0) then (
				cbxWeightlistBones.items = #()
				cbxWeightlistBones.selection = 0
				append ww_scene_lods.weightlistnames t
				cbxWeightLists.items = ww_scene_lods.weightlistnames
				local wt = wwmt_weightlist()
				wt.name = t
				ww_scene_lods.addToWeightLists wt
				wt.writeWeightListToObject ww_scene_lods.target
				ww_scene_lods.setWeightListCust()
				ind = findItem cbxWeightLists.items t
				cbxWeightLists.selection = ind
			)
		)
	)
	on btnDeleteWeightList pressed do
	(
		if cbxWeightLists.selection != 0 AND ww_scene_lods.weightlists.count > 0 then (
			ww_scene_lods.removeWeightlist cbxWeightLists.selected
			cbxWeightLists.selection = 0
			cbxWeightLists.items = ww_scene_lods.weightlistnames
		)
	)
	on cbxWeightlistBones selected sel do
	(
		if ww_scene_lods.weightlists[cbxWeightLists.selection].weights[cbxWeightlistBones.selection] != undefined then (
			spnWeight.value = ww_scene_lods.weightlists[cbxWeightLists.selection].weights[cbxWeightlistBones.selection] as Float
		)
	)
	on spnWeight changed val do
	(
		if cbxWeightLists.selection != 0 AND cbxWeightlistBones.selection != 0 then (
			ww_scene_lods.weightlists[cbxWeightLists.selection].setWeightByBoneName cbxWeightlistBones.text val
			ww_scene_lods.weightlists[cbxWeightLists.selection].writeWeightListToObject ww_scene_lods.target
		)
	)
	on btnAddBone pressed do
	(
		if cbxWeightlistBones.text != "" then (
			addToWeightBoneList cbxWeightlistBones.text
		)
	)
	on btnDeleteBone pressed do
	(
		if cbxWeightLists.selection != 0 AND cbxWeightlistBones.selection != 0 then (
			sel = cbxWeightlistBones.selection
			deleteItem ww_scene_lods.weightlists[cbxWeightLists.selection].bns sel
			deleteItem ww_scene_lods.weightlists[cbxWeightLists.selection].weights sel
			ww_scene_lods.weightlists[cbxWeightLists.selection].writeWeightListToObject ww_scene_lods.target
			cbxWeightlistBones.items = ww_scene_lods.weightlists[cbxWeightLists.selection].bns
		)
	)
	on btnFillList pressed do
	(
		ww_scene_lods.resetBonesArray()
		if ww_scene_lods.bonesarray.count > 0 then (
			for b in ww_scene_lods.bonesarray do (
				addToWeightBoneList b.name
			)
		)
	)
	on cbxSeqWeightlist selected sel do
	(
		setSequenceFromUI()
	)
	on cbxSeqWeightlist entered tex do
	(
		updateWeightList tex
		setSequenceFromUI()
	)
	on spnFPS changed val do
	(
		setSequenceFromUI()
	)
	on chkAutoPlay changed stat do
	(
		setSequenceFromUI()
	)
	on spnActivityWeight changed val do
	(
		setSequenceFromUI()
	)
	on chkSnap changed stat do
	(
		setSequenceFromUI()
	)
	on chkRealtime changed stat do
	(
		setSequenceFromUI()
	)
	on chkAsAnimation changed stat do
	(
		setSequenceFromUI()
	)
	on edtAnimations entered tex do
	(
		setSequenceFromUI()
	)
	on chkHidden changed stat do
	(
		setSequenceFromUI()
	)
	on chkMakeSMD changed stat do
	(
		setSequenceFromUI()
	)
	on spnFadeIn changed val do
	(
		setSequenceFromUI()
	)
	on spnFadeOut changed val do
	(
		setSequenceFromUI()
	)
	on edtNode entered tex do
	(
		setSequenceFromUI()
	)
	on edtActivity changed tex do
	(
		setSequenceFromUI()
	)
	on btnGetActivity pressed do
	(
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/actionDefaults.ms")
	)
	on edtAddLayer entered tex do
	(
		setSequenceFromUI()
	)
	on btnNoWeightList pressed do
	(
		cbxSeqWeightlist.selection = 0
		setSequenceFromUI()
	)
	on btnCompileSequence pressed do
	(
		if ww_scene_lods.sequences != undefined AND ww_scene_lods.sequences.count > 0 AND cbx_sequences.selection > 0 AND ww_scene_lods.sequences[cbx_sequences.selection] != undefined then (
			ww_scene_lods.export_sequence ww_scene_lods.sequences[cbx_sequences.selection]
		)
	)
)

rollout wwmt_lodsrollout "Level of Detail Tools" width:250 height:215
(
	Spinner lodSpinner "LODs" pos:[21, 7] width:120 height:16 enabled:false range:[1, 10, 0] type:#integer scale:1 toolTip:"Select the number of LODs that get generated with the LOD options below."
	Button generateLODbtn "Generate LODs" pos:[146, 6] width:93 height:18 enabled:false toolTip:"Click here to make an array of lower-res models based off of the model selected above."
	Button createLODCam "Create LOD Camera" pos:[19, 47] width:105 height:40
	Button selectLODCam "Select LOD Cam" pos:[132, 47] width:105 height:20
	GroupBox grp2 "LOD Camera Utilities" pos:[12, 31] width:231 height:66
	Button btnViewLOD "View to LOD Cam" pos:[132, 73] width:105 height:14
	CheckBox chk_shadow "$shadowlod" pos:[11, 104] width:80 height:17 enabled:false toolTip:"Use the lowest level of LOD to calculate the shadow. Ignored if there as no LOD Model."
	Button btnDeleteAllLods "Delete All Current LODs" pos:[12, 128] width:230 height:27 toolTip:"Delete all the current LODs and their helpers for this model."
	Button btnHideLODs "Show Main Model" pos:[13, 163] width:229 height:36 toolTip:"Hide all LODs and hulls for this model. Displays main mesh."
	on generateLODbtn pressed do
	(
		if ww_scene_lods.target == undefined then (
			messageBox "You must first pick your model/mesh."
		) else (
			if (lodSpinner.value == undefined OR lodSpinner.value == 0) then (
				lodSpinner.value = 1
			)
			::ww_scene_lods.makeLodsArray lodSpinner.value ::ww_scene_lods
			wwmt_activateLODMenus ::ww_scene_lods.lods
			::wwToolsFloater.rollouts[3].open = false
			::wwToolsFloater.rollouts[4].open = true
		)
	)
	on createLODCam pressed do
	(
		if ww_scene_lods.lodcount() == 0 then (
			messageBox "The LOD Came only works if the model has LODs."
		) else (
			if ww_scene_lods.cam == undefined OR isDeleted ww_scene_lods.cam then (
				local camTar = targetObject pos:ww_scene_lods.targets[1].pos
				camTar.parent = ww_scene_lods.targets[1]
				local cam = targetCamera target:camTar
				cam.name = (ww_scene_lods.modelName + "_LOD_Camera")
				cam.fov = ::wwmt_FOV
				cam.position = ww_scene_lods.lods[1].helperTape.position
				cam.parent = ww_scene_lods.targets[1]
				ww_scene_lods.cam = cam
				ww_scene_lods.target.cam = cam
				ww_scene_lods.setCamChangeHandler()
			) else (
				ww_scene_lods.setCamChangeHandler()
			)
			select ww_scene_lods.cam
		)
	)
	on selectLODCam pressed do
	(
		if (ww_scene_lods.cam != undefined AND NOT isDeleted ww_scene_lods.cam) then (
			select ww_scene_lods.cam
		)
	)
	on btnViewLOD pressed do
	(
		if ww_scene_lods.cam != undefined then (
			select ww_scene_lods.cam
			viewport.setType #view_camera
		) else (
			messageBox "No LOD Cam. Create one first."
		)
	)
	on chk_shadow changed state do
	(
		ww_scene_lods.setShadowlod(state)
	)
	on btnDeleteAllLods pressed do
	(
		for l in ww_scene_lods.lods WHERE l != undefined AND classOf l == ww_lod do (
			l.deleteLOD()
		)
		ww_scene_lods.lods = #()
		wwmt_activateLODMenus ww_scene_lods.lods
	)
	on btnHideLODs pressed do
	(
		ww_scene_lods.showOnlyModel()
	)
)

rollout wwtoolsAbout "About and Settings" width:250 height:171
(
	Hyperlink ShawnLink "Shawn Olson" pos:[143, 42] width:96 height:15 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://www.shawnolson.net"
	Label lbl1 "Wall Worm Model Tools Version " pos:[9, 3] width:232 height:19
	Label lbl2 "Copyright (c) 2010-2015" pos:[11, 43] width:131 height:19
	Hyperlink cust2 "Documents and Reference" pos:[9, 22] width:132 height:12 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/2/wall_worm_model_tools.html"
	Bitmap wwmt_logo "" pos:[19, 65] width:200 height:68 fileName:(::wallworm_installation_path + "/Wallworm.com/assets/ww_model_tools.png")
	Hyperlink Credits "Credits" pos:[13, 138] width:46 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/29/credits.html"
	Hyperlink changelog "Changelog" pos:[66, 138] width:65 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/33/wwmt_changelog.html"
	Hyperlink donate "Donate" pos:[197, 138] width:43 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/42/donate.html"
	Button configButton "Settings" pos:[153, 16] width:80 height:20 toolTip:"Set various settings to control the way WWMT works, including setting important Source SDK paths, etc."
	Hyperlink cust22 "Forums" pos:[139, 138] width:51 height:20 color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://www.wallworm.net"
	on configButton pressed do
	(
		macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
	)
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/wwmt_utilities.ms")

rollout wwmt_propData "Prop Data and Custom Gibs" width:250 height:600
(
	ComboBox ddl_base "Base" pos:[11, 6] width:225 height:5 enabled:false items:#("", "Cardboard.Small", "Cardboard.Medium", "Cardboard.Large", "Cardboard.break", "Cardboard.Indestructable", "Cardboard.breakclient", "Cloth.Small", "Cloth.Medium", "Cloth.Large", "Cloth.Object", "Flesh.Tiny", "Flesh.Small", "Glass.Small", "Glass.Window", "Glass.picture", "Glass.CSWindow", "Glass.CSWindow2", "Glass.WindowStrong", "Item.Small", "Item.Medium", "Item.Large", "Door.Standard", "Metal.Small", "Metal.Medium", "Metal.Large", "Metal.break", "Metal.break2", "Metal.MediumClient", "Wooden.Tiny", "Wooden.Small", "Wooden.chair", "Wooden.MediumNobreak", "Wooden.Large", "Wooden.Huge", "Wooden.sticks", "Wooden.Barrel", "Wooden.Small2", "Wooden.Barrel2", "Metal.Large", "Plastic.Small", "Plastic.Medium", "Plastic.Large", "Plastic.break", "PlasticSmall.break", "Plastic.Small2", "Pottery.Small", "Pottery.Medium", "Pottery.Large", "Pottery.Huge", "Pottery.break", "Pottery.Plant", "Pottery.break2", "Pottery.PlantBreak", "Stone.Small", "Stone.Medium", "Stone.Large", "Stone.Huge", "Stone.Gigantic", "Wooden.Tiny", "Wooden.Small", "Wooden.Medium", "Wooden.Large", "Wooden.ExtraLarge", "Wooden.Huge")
	Hyperlink hyperlinkgibs "Prop Data Help" pos:[160, 6] width:73 height:15 address:"http://dev.wallworm.com/topic/28/prop_data_and_custom_gibs.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	Spinner spn_health "Health" pos:[143, 167] width:92 height:16 enabled:false range:[0, 10000, 0] type:#integer scale:1
	CheckBox chk_allowstatic "Allow Static " pos:[12, 169] width:115 height:15 enabled:false
	DropDownList ddl_physicsmode "Physics Mode" pos:[11, 106] width:224 height:40 enabled:false items:#("Auto", "Solid, pushes the player away.", "Non-solid, but gets pushed away by the player.", "Non-solid, clientside simulated only.")
	CheckBox chk_blockLOS "Block Line of Sight" pos:[12, 190] width:118 height:15 enabled:false
	CheckBox chk_AIWalkable "AI Walkable" pos:[132, 186] width:103 height:14 enabled:false
	Spinner spn_dmg_bullets "dmg.bullet" pos:[49, 229] width:135 height:16 enabled:false range:[0, 10000, 1]
	Spinner spn_dmg_club "dmg.club" pos:[49, 255] width:135 height:16 enabled:false range:[0, 100, 1]
	Spinner spn_dmg_explosive "dmg.explosive" pos:[50, 280] width:134 height:16 enabled:false range:[0, 10000, 1]
	CheckBox chk_ignite "Ignite" pos:[11, 342] width:57 height:14 enabled:false
	CheckBox chk_explosive_resist "Explosive Resist" pos:[11, 359] width:98 height:14 enabled:false
	CheckBox chk_flammable "Flammable" pos:[11, 377] width:97 height:13 enabled:false
	GroupBox grp1 "Flammable Prop" pos:[4, 321] width:110 height:79
	Spinner spn_explosive_damage "Exp. Dmg" pos:[147, 344] width:89 height:16 enabled:false range:[0, 10000, 0]
	Spinner spn_explosive_radius "Exp. Radius" pos:[147, 366] width:89 height:16 enabled:false range:[0, 10000, 0]
	GroupBox grp2 "Exploding Prop" pos:[116, 321] width:126 height:79
	DropDownList ddl_breakable_model "Gibs Model Class" pos:[12, 431] width:134 height:40 enabled:false items:#("", "WoodChunks", "GlassChunks", "ConcreteChunks", "MetalChunks", "CustomGibs")
	Spinner spn_breakable_count "Count" pos:[18, 486] width:114 height:16 enabled:false type:#integer scale:1
	Spinner spn_breakable_skin "Skin #" pos:[148, 486] width:85 height:16 enabled:false type:#integer scale:1
	DropDownList ddl_multiplayer_break "Multiplayer Break" pos:[10, 519] width:227 height:40 enabled:false items:#("client", "server", "both")
	Button btn_custGibs "Add Sel Gibs" pos:[158, 422] width:76 height:17 enabled:false toolTip:"Click here to set all selected meshes as Gibs models for this model."
	GroupBox grp3 "Gibs" pos:[5, 410] width:237 height:180
	GroupBox grp4 "Damage Modifiers" pos:[4, 212] width:239 height:99
	Spinner spn_fadetime "Fade Time" pos:[141, 516] width:92 height:16 enabled:false range:[0, 10000, 0] type:#integer scale:1
	Button btn_removeGibs "Rem Sel Gibs" pos:[158, 446] width:75 height:17 enabled:false toolTip:"Click to remove all selected items from the gibs list for this model."
	Button btn_compileGibs "Compile Gibs" pos:[11, 566] width:100 height:15 enabled:false toolTip:"Click here to compile all gibs models."
	Button btn_compileGibsVTFs "Compile Gibs VTFs" pos:[120, 566] width:100 height:15 enabled:false toolTip:"Click here to compile all textures belonging to gibs."
	CheckBox chk_motiondisabled "motiondisabled" pos:[132, 202] width:109 height:19 enabled:false toolTip:"To spawn non-moving gibs (in some mods)."
	CheckBox chk_overridePhys "Override Base Phys Settings" pos:[12, 148] width:222 height:16
	on chk_overridePhys changed stat do (
		spn_health.enabled = \
		chk_allowstatic.enabled = \
		ddl_physicsmode.enabled = \
		chk_blockLOS.enabled = \
		chk_AIWalkable.enabled = \
		spn_dmg_bullets.enabled = \
		spn_dmg_club.enabled = \
		spn_dmg_explosive.enabled = \
		chk_ignite.enabled = \
		chk_explosive_resist.enabled = \
		chk_flammable.enabled = \
		spn_explosive_damage.enabled = stat
		::ww_scene_lods.target.overridePhys = stat
	)
	on ddl_base selected sel do
	(
		ww_scene_lods.setBase(ddl_base.items[sel])
	)
	on ddl_base changed txt do
	(
		ww_scene_lods.setBase(txt)
	)
	on spn_health changed val do
	(
		ww_scene_lods.setHealth val
	)
	on chk_allowstatic changed state do
	(
		ww_scene_lods.setAllowstatic state
	)
	on ddl_physicsmode selected sel do
	(
		ww_scene_lods.setPhysicsmode(ddl_physicsmode.selection)
	)
	on chk_blockLOS changed state do
	(
		ww_scene_lods.setBlockLOS state
	)
	on chk_AIWalkable changed state do
	(
		ww_scene_lods.setAIWalkable state
	)
	on spn_dmg_bullets changed val do
	(
		ww_scene_lods.setDmg_bullets val
	)
	on spn_dmg_club changed val do
	(
		ww_scene_lods.setDmg_club val
	)
	on spn_dmg_explosive changed val do
	(
		ww_scene_lods.setDmg_explosive val
	)
	on chk_ignite changed state do
	(
		ww_scene_lods.setIgnite state
	)
	on chk_explosive_resist changed state do
	(
		ww_scene_lods.setExplosive_resist state
	)
	on chk_flammable changed state do
	(
		ww_scene_lods.setFlammable state
	)
	on spn_explosive_damage changed val do
	(
		ww_scene_lods.setExplosive_damage val
	)
	on spn_explosive_radius changed val do
	(
		ww_scene_lods.setExplosive_radius val
	)
	on ddl_breakable_model selected sel do
	(
		ww_scene_lods.setBreakable_model(ddl_breakable_model.items[sel])
	)
	on spn_breakable_count changed val do
	(
		ww_scene_lods.setBreakable_count val
	)
	on spn_breakable_skin changed val do
	(
		ww_scene_lods.setBreakable_skin val
	)
	on ddl_multiplayer_break selected sel do
	(
		ww_scene_lods.setMultiplayer_break(ddl_multiplayer_break.items[sel])
	)
	on btn_custGibs pressed do
	(
		if (ww_scene_lods.breakable_model == undefined OR ww_scene_lods.breakable_model != "CustomGibs") then (
			messageBox "Custom Gibs is can only be set if Gibs Model Class is set to \"CustomGibs\"."
		) else(
			if selection.count > 0 then (
				ww_scene_lods.addGibs selection
				if ww_scene_lods.breakable_count != undefined AND spn_breakable_count.value != ww_scene_lods.breakable_count then (
					spn_breakable_count.value = ww_scene_lods.breakable_count
				)
			) else (
				messageBox "You must first select the items to add to the gibs list."
			)
		)
	)
	on spn_fadetime changed val do
	(
		ww_scene_lods.setFadetime val
	)
	on btn_removeGibs pressed do
	(
		ww_scene_lods.removeGibs selection
	)
	on btn_compileGibs pressed do
	(
		if ww_scene_lods.gibs.count > 0 then (
			ww_scene_lods.exportGibs()
		) else (
			messageBox "You haven't assigned any gibs to this model."
		)
	)
	on btn_compileGibsVTFs pressed do
	(
		if ww_scene_lods.gibs.count > 0 then (
			if ww_scene_lods.canCompile "tex" then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/textureExport.ms")
			) else (
				messageBox "To compile textures, the following requirements must be met:\n\n*Set a \"Material Path\" in the Export Options rollout\n*Have valid materials (with Bitmaps in the diffuse slots) on model\n*\"Bin Dir\" AND \"Material Root Directory\" set in the Settings floater"
			)
		) else(
			messageBox "You haven't assigned any gibs to this model."
		)
	)
	on chk_motiondisabled changed state do
	(
		ww_scene_lods.setmotiondisabled state
	)
)
--addRollout titleRoll ::wwToolsFloater 
addRollout Wall_Worm_Model_Tools ::wwToolsFloater
addRollout wwmt_cm ::wwToolsFloater rolledUp:true
addRollout wwmt_lodsrollout ::wwToolsFloater rolledUp:true

try (
	addRollout wwmt_lodslistrollouta ::wwToolsFloater rolledUp:true
) catch (
	execute lodstring
	addRollout wwmt_lodslistrollouta ::wwToolsFloater rolledUp:true
)

addRollout wwmt_sequences ::wwToolsFloater rolledUp:true
addRollout wwmt_attachments ::wwToolsFloater rolledUp:true
addRollout wwmt_exportRollout ::wwToolsFloater rolledUp:true
addRollout wwmt_utilities ::wwToolsFloater rolledUp:true
addRollout wwmt_propData ::wwToolsFloater rolledUp:true
addRollout wwtoolsAbout ::wwToolsFloater

::wwToolsFloater.rollouts[10].lbl1.caption += (::ww_wwmt_version as String)
::wwToolsFloater.rollouts[3].lodSpinner.range = [1, ::wwmt_lodLimit, 1]

if wallworm_reset_wwmt == true AND ww_scene_lods != undefined then (
	wallworm_setWWMUI()
)
wallworm_reset_wwmt = undefi