/*
Wall Worm Model Tools Custom Attribute
Copyright (c) 2014-2015 by Shawn Olson
http://www.shawnolson.net

A Wall Worm Project
http://www.wallworm.com

This CA requires that Wall Worm is installed in order to be used correctly.
attribID:#(0xcee389b, 0x2fe761bd) 
*/

global wallworm_model_tools_CA
wallworm_model_tools_CA = attributes "Wallworm Model Tools"
version:46
(
	local wallworm = true --used by many WW scene utilities
	local wwmt_ca = true --lets external functions know this is a WWMT helper
	local wwmt --used to store the ww_LOD_wrapper object. Gets set with the getWWMT() method.
	local thisNode --stores pointer to the node this CA is applied to.
	local updateWWMTFromThis,updateMyName
	function getNode = (
		if thisNode == undefined then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	on clone orig do (
		thisNode = undefined --this is important or the cloned object might have the CA affecting the olde object
		wwmt = undefined --see above
	)
	function getWWMT refresh:false updateCA:false = (
		if wwmt == undefined OR classOf wwmt != ::ww_LOD_wrapper OR thisNode == undefined OR refresh == true then (
			getNode()
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
			)
			if ::ww_LOD_wrapper == undefined AND doesFileExist (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms") then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
			)
			if ::ww_LOD_wrapper != undefined then (
				if isValidNode thisNode then (
					wwmt = ::ww_LOD_wrapper()
					wwmt.init()
					wwmt.target = thisNode
					wwmt.setTargetModel thisNode wwmt --updateCA:updateCA
				)
			)
		)
		if wwmt != undefined AND isProperty wwmt #isset then (
			wwmt.isset = false
		)
		wwmt
	)
	function setWWMT ww = (
		if classOf ww == ::ww_LOD_wrapper then (
			wwmt = ww
		)
	)
	function updateWWMTGUIFromWWMT openWWMT:false sendToGlobal:false = (
		getWWMT refresh:true
		if wwmt != undefined then (
			if (::ww_scene_lods != undefined AND (::ww_scene_lods == wwmt)) OR sendToGlobal == true then (
				if sendToGlobal == true then (
					::wallworm_reset_wwmt = true
					::ww_scene_lods = wwmt
				)
				if (::wwToolsFloater == undefined) AND openWWMT == true then (
					macros.run "wallworm.com" "WallWormModelToolsMCR"
				)
				if ::wwToolsFloater != undefined AND sendToGlobal then (
					::wallworm_setWWMUI()
				)
			)
			true
		) else (
			false
		)
	)

	local mainrollout, hullrollout, propdatarollout, sanitize, attachrollout
	parameters main rollout:mainrollout (
		targets type:#nodeTab tabSizeVariable:true --ui:listNodes --meshes in the $body
		models type:#nodeTab tabSizeVariable:true --list of WWMT Nodes to exports as $models
		includes type:#nodeTab tabSizeVariable:true --list of WWMT Nodes to $includemodel
		--proxies type:#nodeTab  tabSizeVariable:true
		bonelist type:#nodeTab tabSizeVariable:true
		hullbonelist type:#nodeTab tabSizeVariable:true
		sequences type:#stringTab tabSizeVariable:true
		alwayscollapse type:#boolean default:false ui:chk_alwayscollapse
		collapsebones type:#boolean default:false ui:chk_collapsebones
		lods type:#nodeTab tabSizeVariable:true
		attachments type:#nodeTab tabSizeVariable:true
		--bodygroups type:#nodeTab  tabSizeVariable:true
		modelName type:#string default:"modelname" ui:edt_ModelName
		locked type:#boolean default:false ui:chk_lockQC
		modelPath type:#string default:"" ui:edt1_modelPath
		materialPath type:#string default:"" ui:edt2_materialFolder
		surfaceprop type:#string default:"" ui:ddl_surfaceprop
		staticprop type:#boolean default:false ui:chk_staticprop
		upaxis type:#integer default:3 ui:drp_upaxis
		opaque type:#boolean default:false ui:chk_opaque
		mostlyopaque type:#boolean default:unsupplied ui:chk_mostlyopaque
		mscale type:#float default:1.0 ui:spn_scale
		useLocalOrigin type:#boolean default:true ui:chk_localOrigin
		internalOrigin type:#boolean default:true ui:chkInternalOrigin
		rotateRefsystem type:#boolean default:true ui:chkRotateOrigin
		lockInitialOrigin type:#boolean default:false ui:chk_lock_origin
		altOrigin type:#boolean default:false ui:chk_altOrigin
		shaderType type:#string ui:ddl_shader default:"VertexLitGeneric"
		mapChannel type:#integer default:0 ui:spn_mapChannel
		compression type:#string default:"DXT5" ui:ddl_compression
		normalMethod type:#integer default:3 ui:ddlNormals
		dmx type:#boolean default:false ui:chkDMX
		attachmentsInDMX type:#boolean default:false
		on modelname set val do (
			updateMyName()
			if isValidNode thisNode then (
				setUserProp thisNode #wwmt_modelname modelName
			)
		)
		on mapChannel set val do (
			if wwmt != undefined then (
				wwmt.mapChannel = mapChannel
			)
		)
	)
	parameters otherParams rollout:otherParamsRollout (
		ambientboost type:#boolean default:false ui:chk_ambientboost
		constantdirectionallight type:#float ui:spn_constantdirectionallight
		illumorigin type:#node ui:illumpickbuton
		morphasvta type:#boolean default:true ui:chk_morphasvta
		cam type:#node
		camMode type:#boolean default:false
		eyeballs type:#nodeTab tabSizeVariable:true
		eyeposition type:#node
	)

	parameters hullparams rollout:hullrollout (
		hulls type:#nodeTab tabSizeVariable:true
		massorigin type:#node ui:pckMassOrigin
		autoHull type:#boolean default:false ui:chk_autoHull
		usePhysOverrides type:#boolean default:false ui:chk_usePhysOverrides
		mass type:#float default:unsupplied ui:spn_mass
		automass type:#boolean default:false ui:chk_automass
		concave type:#boolean default:unsupplied ui:chk_concave
		contents type:#string default:"solid" --ui:ddl_contents
		inertia type:#float default:unsupplied ui:spn_inertia
		damping type:#float default:unsupplied ui:spn_Damping
		rotDamping type:#float default:unsupplied ui:spn_rotDamping
		jointConstraints type:#boolean default:unsupplied ui:chk_jointrestrain
		phdrag type:#float default:unsupplied ui:spn_phdrag
		animatedfriction type:#string default:"" ui:edt_animatedfriction
		noselfcollisions type:#boolean default:false ui:chk_noselfcollisions

		on usePhysOverrides set val do (
			hullrollout.spn_mass.enabled = usePhysOverrides
			hullrollout.spn_inertia.enabled = usePhysOverrides
			hullrollout.spn_Damping.enabled = usePhysOverrides
			hullrollout.spn_rotDamping.enabled = usePhysOverrides
			hullrollout.spn_phdrag.enabled = usePhysOverrides
		)

		on autoHull set val do (
			hullrollout.listHulls.enabled = (NOT autoHull)
		)

		on automass set val do (
			hullrollout.spn_mass.enabled = (NOT automass)
		)
		on concave set val do (
			if wwmt != undefined then (
				wwmt.concave = concave
			)
		)
	)

	parameters propdataparams rollout:propdatarollout (
		gibs type:#nodeTab tabSizeVariable:true
		base type:#string default:"" ui:ddl_base
		health type:#integer ui:spn_health default:unsupplied
		allowstatic type:#boolean ui:chk_allowstatic default:unsupplied
		physicsmode type:#integer default:1 ui:ddl_physicsmode
		multiplayer_break type:#string default:"client" --ui:ddl_multiplayer_break
		breakable_model type:#string default:"" --ui:ddl_breakable_model
		blockLOS type:#boolean ui:chk_blockLOS
		AIWalkable type:#boolean ui:chk_AIWalkable
		dmg_bullets type:#float ui:spn_dmg_bullets default:0.0
		dmg_club type:#float ui:spn_dmg_club default:0.0
		dmg_explosive type:#float ui:spn_dmg_explosive default:0.0
		ignite type:#boolean ui:chk_ignite default:unsupplied
		explosive_resist type:#boolean ui:chk_explosive_resist default:unsupplied
		flammable type:#boolean ui:chk_flammable default:unsupplied
		explosive_damage type:#float ui:spn_explosive_damage default:unsupplied
		breakable_count type:#integer ui:spn_breakable_count default:unsupplied
		breakable_skin type:#integer ui:spn_breakable_skin default:0
		explosive_radius type:#integer ui:spn_explosive_radius default:unsupplied
		fadetime type:#integer default:15 ui:spn_fadetime
		motiondisabled type:#boolean ui:chk_motiondisabled default:false
		overridePhys type:#boolean ui:chkOverridePhys default:true
		on overridePhys set val do (
			propdatarollout.spn_health.enabled = overridePhys
			propdatarollout.chk_allowstatic.enabled = overridePhys
			propdatarollout.ddl_physicsmode.enabled = overridePhys
			propdatarollout.chk_blockLOS.enabled = overridePhys
			propdatarollout.chk_AIWalkable.enabled = overridePhys
			propdatarollout.spn_dmg_bullets.enabled = overridePhys
			propdatarollout.spn_dmg_club.enabled = overridePhys
			propdatarollout.spn_dmg_explosive.enabled = overridePhys
			propdatarollout.chk_ignite.enabled = overridePhys
			propdatarollout.chk_explosive_resist.enabled = overridePhys
			propdatarollout.chk_flammable.enabled = overridePhys
			propdatarollout.spn_explosive_damage.enabled = overridePhys
			propdatarollout.spn_explosive_radius.enabled = overridePhys
		)

		on breakable_model set val do (
			propdatarollout.btn_compileGibsVTFs.enabled = (breakable_model == "CustomGibs")
			propdatarollout.btn_compileGibs.enabled = (breakable_model == "CustomGibs")
			propdatarollout.cmb_gibslist.enabled = (breakable_model == "CustomGibs")
			propdatarollout.btn_removeGibs.enabled = (breakable_model == "CustomGibs")
			propdatarollout.btn_custGibs.enabled = (breakable_model == "CustomGibs")
		)
	)

	function sendoverridestogibs = (
		for gib in gibs do (
			gib.base = base
			gib.health = health
			gib.allowstatic = allowstatic
			gib.physicsmode = physicsmode
			gib.multiplayer_break = multiplayer_break
			gib.breakable_model = breakable_model
			gib.blockLOS = blockLOS
			gib.AIWalkable = AIWalkable
			gib.dmg_bullets = dmg_bullets
			gib.dmg_club = dmg_club
			gib.dmg_explosive = dmg_explosive
			gib.ignite = ignite
			gib.explosive_resist = explosive_resist
			gib.flammable = flammable
			gib.explosive_damage = explosive_damage
			gib.breakable_count = breakable_count
			gib.breakable_skin = breakable_skin
			gib.explosive_radius = explosive_radius
			gib.fadetime = fadetime
			gib.motiondisabled = motiondisabled
			if isProperty gib #overridePhys then (
				gib.overridePhys = overridePhys
			)
		)
	)

	parameters vmfparams rollout:vmfparamsrollout (
		exclude_vmf type:#boolean ui:chk_exclude_vmf default:false
		skybox type:#boolean ui:chk_skybox default:false
		on exclude_vmf set val do (
			updateMyName()
			if thisNode != undefined then (
				setUserProp thisNode #wallworm_exclude_vmf exclude_vmf
			)
		)
		on skybox set val do (
			updateMyName()
			if thisNode != undefined then (
				setUserProp thisNode #wwdt_skybox_export skybox
			)
		)
	)

	function updateMyName = (
		getNode()
		if thisNode != undefined AND classOf thisNode.baseobject == Text then (

			local sk = ""
			local ex = ""
			local tname = stringstream ""
			if skybox == true then (
				sk = "-S"
			)
			if exclude_vmf == true then (
				ex = "-X"
			)
			format "WWMT%%: %" sk ex modelname to:tname
			tname = tname as string
			if tname != thisNode.baseobject.text then (
				thisNode.baseobject.text = tname as string
			)
		)
	)
	
	function addAttachment obj:undefined = (
		if isValidNode obj then (
			ind = findItem attachments obj
			if ind == 0 then (
				global wallworm_attachment_CA
				local goAhead = false

				if NOT isProperty obj #wallworm_attachment_CA then (
					if wallworm_attachment_CA != undefined then (
						custAttributes.add obj wallworm_attachment_CA
						goAhead = true
					) else (
						goAhead = false
					)
				) else (
					goAhead = true
				)
				if goAhead then (
					append attachments obj
				)
				goAhead
			) else (
				false
			)
		) else (false)
	)

	function removeAttachment obj = (
		ind = findItem attachments obj
		if ind > 0 then (
			deleteItem attachments ind
		)
	)

	function sanitizeAttachments = (
		attachments = for obj in attachments WHERE isValidNode obj collect obj
		wwmt.attachments = for obj in attachments WHERE isValidNode obj collect (obj.setAtt())
	)

	function sanitizeModels = (
		models = for obj in models WHERE isValidNode obj AND isProperty obj #wwmt_ca collect obj
	)
	function sanitizeIncludes = (
		includes = for obj in includes WHERE isValidNode obj AND isProperty obj #wwmt_ca collect obj
	)
	function refreshAttachmentList = (
		sanitizeAttachments()
	)

	function refreshBoneList = (
		bonelist = for obj in bonelist WHERE isValidNode obj collect obj
	)

	function sanitizeEyeballs = (
		eyeballs = for obj in eyeballs WHERE isValidNode obj collect obj
	)

	function getAttachmentStructs = (
		for obj in attachments collect (obj.setAtt())
	)

	function updateWWMTFromThis = (
		getWWMT()
		if wwmt != undefined then (
			/*nodeTabs*/
			wwmt.targets = targets as Array
			--wwmt.proxies = proxies as array
			wwmt.hulls = hulls as Array
			wwmt.gibs = gibs as Array

			wwmt.bonesarray = bonelist as Array
			wwmt.attachments = for obj in attachments WHERE isProperty obj #setAtt collect (obj.setAtt())

			wwmt.lods = #()

			if lods.count > 0 then (
				for l in lods WHERE isValidNode l do (
					local ld = l.get_lod refresh:true
					if ld != undefined then (
						append wwmt.lods ld
					)
				)
			)

			/*Nodes*/
			wwmt.massorigin = massorigin
			wwmt.illumorigin = illumorigin
			wwmt.cam = cam

			/*Other Params*/

			wwmt.autoHull = autoHull
			wwmt.mass = mass
			wwmt.automass = automass
			wwmt.concave = concave
			wwmt.contents = contents
			wwmt.inertia = inertia
			wwmt.damping = damping
			wwmt.rotDamping = rotDamping
			wwmt.jointConstraints = jointConstraints
			wwmt.phdrag = phdrag
			wwmt.animatedfriction = animatedfriction
			wwmt.noselfcollisions = noselfcollisions

			wwmt.normalMethod = normalMethod
			wwmt.compression = compression
			wwmt.mapChannel = mapChannel
			wwmt.shaderType = shaderType
			wwmt.morphasvta = morphasvta
			wwmt.camMode = camMode

			wwmt.altOrigin = altOrigin
			wwmt.lockInitialOrigin = lockInitialOrigin
			wwmt.rotateRefsystem = rotateRefsystem
			wwmt.internalOrigin = internalOrigin

			wwmt.modelName = modelName
			wwmt.locked = locked
			wwmt.modelPath = modelPath
			wwmt.materialPath = materialPath
			wwmt.concave = concave
			wwmt.contents = contents
			wwmt.surfaceprop = surfaceprop
			wwmt.staticprop = staticprop
			wwmt.opaque = opaque
			wwmt.mostlyopaque = mostlyopaque
			wwmt.mscale = mscale
			wwmt.useLocalOrigin = useLocalOrigin
			wwmt.ambientboost = ambientboost
			wwmt.constantdirectionallight = constantdirectionallight
			wwmt.dmg_bullets = dmg_bullets
			wwmt.AIWalkable = AIWalkable
			wwmt.blockLOS = blockLOS
			wwmt.physicsmode = physicsmode
			wwmt.allowstatic = allowstatic
			wwmt.health = health
			wwmt.base = base
			wwmt.dmg_club = dmg_club
			wwmt.dmg_explosive = dmg_explosive
			wwmt.ignite = ignite
			wwmt.explosive_resist = explosive_resist
			wwmt.flammable = flammable
			wwmt.explosive_damage = explosive_damage
			wwmt.breakable_model = breakable_model
			wwmt.breakable_count = breakable_count
			wwmt.breakable_skin = breakable_skin
			wwmt.multiplayer_break = multiplayer_break
			wwmt.explosive_radius = explosive_radius
			wwmt.fadetime = fadetime
			wwmt.motiondisabled = motiondisabled
			wwmt.alwayscollapse = alwayscollapse
			wwmt.collapsebones = collapsebones
			wwmt.upaxis = upaxis
			if ::WallWormProSMD != undefined then (
				wwmt.dmx = dmx
			) else (
				wwmt.dmx = false
			)

		)

	)

	function sanitize = (
		tc = targets.count
		if tc > 0 then (
			targets = for t in targets WHERE isValidNode t collect t
		)

		tc = hulls.count
		if tc > 0 then (
			hulls = for t in hulls WHERE isValidNode t collect t
		)
		tc = gibs.count
		if tc > 0 then (
			gibs = for t in gibs WHERE isValidNode t collect t
		)

		tc = attachments.count
		if tc > 0 then (
			attachments = for t in attachments WHERE isValidNode t collect t
		)

		tc = bonelist.count
		if tc > 0 then (
			bonelist = for t in bonelist WHERE isValidNode t collect t
		)

		tc = lods.count
		if tc > 0 then (
			lods = for t in lods WHERE isValidNode t collect t
		)

		getWWMT()

		if wwmt != undefined then (
			wwmt.targets = targets as Array
			wwmt.hulls = hulls as Array
			wwmt.gibs = gibs as Array
		)

	)

	function updateNames = (
		mainrollout.listNodes.items = for obj in targets WHERE obj != undefined AND isValidNode obj collect obj.name
	)
	function updateHullListNames = (
		hullrollout.listHulls.items = for obj in hulls WHERE obj != undefined AND isValidNode obj collect obj.name
	)

	function updateSurfacePropselection = (
		if mainrollout != undefined then (
			if findItem mainrollout.ddl_surfaceprop.items surfaceprop == 0 then (
				templ = mainrollout.ddl_surfaceprop.items
				append templ surfaceprop
				sort templ
				mainrollout.ddl_surfaceprop.items = templ
			)
			mainrollout.ddl_surfaceprop.selection = findItem mainrollout.ddl_surfaceprop.items surfaceprop
		)
	)

	function updateModelPathselection = (
		if findItem mainrollout.edt1_modelPath.items modelPath == 0 then (
			templ = mainrollout.edt1_modelPath.items
			append templ modelPath
			sort templ
			mainrollout.edt1_modelPath.items = templ
		)
		mainrollout.edt1_modelPath.selection = findItem mainrollout.edt1_modelPath.items modelPath
	)

	function updateMaterialPathselection = (
		if findItem mainrollout.edt2_materialFolder.items materialPath == 0 then (
			templ = mainrollout.edt2_materialFolder.items
			append templ materialPath
			sort templ
			mainrollout.edt2_materialFolder.items = templ
		)
		mainrollout.edt2_materialFolder.selection = findItem mainrollout.edt2_materialFolder.items materialPath
	)

	function allowed_wwmt_obj obj = (((superClassOf obj == GeometryClass OR (superClassOf obj == Shape AND isProperty obj #render_useViewportSettings AND obj.render_useViewportSettings == true)) AND (NOT (isProperty obj #ww_displacement_brush)) AND (NOT (isProperty obj #ww_displacement)) AND (NOT (isProperty obj #wallworm_edit_mesh)) AND (getUserProp obj #wwdt_brush_geometry_export == undefined OR getUserProp obj #wwdt_brush_geometry_export == false) AND (NOT isProperty obj #isWorldGeometry OR (obj.isWorldGeometry == false))) AND findItem targets obj == 0 AND findItem (#("Convexity Walls", "Convexity Floors", "Convexity Library Shapes")) obj.layer.name == 0)

	rollout mainrollout "WWMT Functions" (
		PickButton addModel "+" across:4 toolTip:"Add Meshes to the WWMT Helper." filter:allowed_wwmt_obj
		Button btn_removeSelFromTargets "-" toolTip:"Remove selected objects from the model." offset:[-10, 0]
		Button btnShowModel "Show" toolTip:"Unhide the model if it is hidden." offset:[-10, 0]
		Button btnHideModel "Hide" toolTip:"Hide the model."
		ListBox listNodes "Meshes" height:3
		ComboBox ddl_surfaceprop "Surface Property" items:#(surfaceprop) height:3

		Button btn15 "Dir" toolTip:"Open the folder where the final MDL files get compiled." across:4
		Button btn48 "QC" toolTip:"Open the QC file in Notepad." offset:[-3, 0]
		Button btnCust "QCI" toolTip:"Open the custom QCI file in Notepad." offset:[-3, 0]
		Button btn_open_model_folder "Mdlsrc" toolTip:"Click here to open the model folder."
		Label lbl1 "Model Folder Path" align:#left toolTip:"Enter a path that is relative to the Mod's Model folder."
		ComboBox edt1_modelPath "" toolTip:"Enter the folder path relative to the SDK model folder without starting or ending slashes." items:#(modelPath) height:3

		Button btn31 "VMT Dir" toolTip:"Open the folder where the final VMTs for this model export to." across:2
		Button btn_open_mat_folder "Raw" toolTip:"Click here to open the material folder."
		Label lbl2 "Material Folder Path" align:#left toolTip:"Enter a path that is relative to the Mod's Material folder."
		ComboBox edt2_materialFolder "" toolTip:"Enter the folder path relative to the SDK material folder without starting or ending slashes." items:#(materialPath) height:3

		CheckBox chk_staticprop "$staticprop" toolTip:"Check here is this is a static prop with no animations." across:2
		DropDownList drp_upaxis "" items:#("X","Y","Z") tooltip:"This should almost always be set to Z. For linked FBX files generated in Maya, choose Y." width:30 offset:[20,0]
		CheckBox chk_alwayscollapse "$alwayscollapse Mesh Nodes" tooltip:"Always collapse the mesh nodes. This will reduce overhead if you are using a skinned model."
		CheckBox chk_collapsebones "$collapsebones" tooltip:"Collapses any node that isn't skinned to any vertex or part of an IK chain."

		CheckBox chk_opaque "$opaque" toolTip:"Check this to tell the compiler this is an opaque model. Also forces VMTs for this model to exclude any translucency if your WWMT Settings force this."
		CheckBox chk_mostlyopaque "$mostlyopaque"

		Label lbl3 "Sky Scales" across:3
		Button btn_setSkyScale "1/16" toolTip:"Set to Skybox Scale ( 1/16 )"
		Button btn_setSkyScale2 "1/32" toolTip:"Set to L4D Skybox Scale ( 1/32 )"
		Spinner spn_scale "Model Scale" range:[0.01, 100, 1] scale:0.1
		PickButton btn_illum "Illumination" toolTip:"Click Here to select the Illumination Origin"

		CheckBox chk_localOrigin "Use Local Origin" offset:[0, 20] toolTip:"Click here if you want the origin of the model's world set to the model's origin. This might be necessary if you are creating models inside of scenes instead of their own files."
		CheckBox chk_lock_origin "Lock Origin State" toolTip:"Check this option if the root node is animated in its own space."
		CheckBox chkInternalOrigin "Calculate Origin in SMD" toolTip:"When on, the Origin is calculated in the SMD. When off, calculated in the QC. Some mods do not compile the QC $origin anymore. Also, this option only works with the WW SMD Exporter."
		CheckBox chkRotateOrigin "Rotate Origin" across:2 toolTip:"Rotate the Z-Axis of the model so that it exports in same system as the Max world (and brush geometry). You may want to turn this off with some animated models."
		CheckBox chk_altOrigin "Flip" toolTip:"Click here if the model should be flipped (mirrored)." offset:[20, 0]
		Hyperlink custAltHelp "Origin Offset" address:"http://dev.wallworm.com/document/56/model__basic_qc_rollout.html#uselocalorigin" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		GroupBox grp_Origin "$origin" height:120 width:146 offset:[-6, -120]

		Spinner spn_mapChannel "Map Channel" range:[-1, 99, 1] type:#integer scale:1 toolTip:"Enter the UVW Mapping Channel to use at export or 0 for fast auto detect from diffuse bitmap or -1 for slower but possibly more accurate auto-detect. Only available if using the WWMT SMD Exporter. Otherwise, only channel one is used."
		DropDownList ddlNormals "Normals" items:#("Face Render Normals", "Explicit Normals", "Auto") toolTip:"Choose the method for determining vertex normals. Defaults to Face Render Normals. But you can also choose other options."
		Label mdlenamelabel "Model Name" align:#left toolTip:"Enter the name for this model (only use letters, numbers and underscore. Avoid spaces, periods or any special characters)."
		EditText edt_modelName ""
		Button exportWWMT "Export QC & Model" tooltip:"Run the Exporter"
		CheckBox chk_lockQC "Lock QC" across:2 align:#left toolTip:"Click here if you do not want to overwrite the QC for this model after it has been generated. When locked, the export process will only overwrite SMDs when you export."
		CheckBox chkDMX "Use DMX" align:#left tooltip:"Click here to export this model as DMX instead of using SMDs and VTAs. Only available if WW Pro is installed." enabled:(::WallWormProSMD != undefined)

		Group "Materials" (
			DropDownList ddl_shader "" items:#("VertexLitGeneric", "UnlitGeneric") selection:(findItem ddl_shader.items shaderType)
			DropDownList ddl_compression "Compression" items:#("", "DXT5", "nocompress") selection:(findItem ddl_compression.items compression)
			Button btn_tex "Export VMT and VTF" toolTip:"Click here to compile the textures in your model to VMTs and VTFs."
		)

		Button btn_upenwwmt "Send to WWMT UI"

		on btn_upenwwmt pressed do (
			updateWWMTGUIFromWWMT openWWMT:true sendToGlobal:true
		)

		on chkDMX changed stat do (
			if ::WallWormProSMD != undefined then (
				wwmt.dmx = stat
			) else (
				wwmt.dmx = false
			)
		)

		on listNodes rightClick sel do (
			select (targets[listNodes.selection])
		)
		on listNodes selected sel do (
			nds = #(targets[listNodes.selection])
			flashNodes nds
			forceCompleteredraw()
		)

		on btnShowModel pressed do (
			unhide (targets as Array)
		)
		on btnHideModel pressed do (
			hide (targets as Array)
		)

		on btn15 pressed do
		(
			local m = ""
			if modelPath != "" then (
				m = wwmt.FsToBs modelPath
			) else (
				m = wwmt.FsToBs ::wwmt_def_model_path
			)

			local wwDir = ::wwmt_gameInfoDir + "\\models\\" + m

			local canOpen = doesFileExist wwDir
			if NOT canOpen then (
				canOpen = makeDir wwDir all:true
			)
			if canOpen then (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
				execute folderOpen
			)
		)
		on btn31 pressed do
		(
			local m = ""

			if materialPath != "" then (
				m = wwmt.FsToBs materialPath
			) else (
				m = wwmt.FsToBs ::wwmt_def_material_path
			)

			wwDir = ::wwmt_gameInfoDir + "\\materials\\" + m

			local canOpen = doesFileExist wwDir
			if NOT canOpen then (
				canOpen = makeDir wwDir all:true
			)
			if canOpen then (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
				execute folderOpen
			)
		)
		on btn48 pressed do
		(
			if ::wallworm_text_editor == undefined then (
				::wallworm_text_editor = "notepad.exe"
			)
			local m = ""
			if modelPath != "" then (
				m = wwmt.FsToBs modelPath
			) else(
				m = wwmt.FsToBs ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)

			local wwDir = ::wwmt_export + "\\" + m + "\\" + modelName + ".qc"
			if doesFileExist wwDir == true then (
				folderOpen = "ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + wwDir + "\""
				execute folderOpen
			) else (
				messageBox "Oops... the QC doesn't exist yet. Export the model first."
			)
		)

		on btnCust pressed do
		(
			if ::wallworm_text_editor == undefined then (
				::wallworm_text_editor = "notepad.exe"
			)
			local m = ""
			if modelPath != "" then (
				m = wwmt.FsToBs modelPath
			) else(
				m = wwmt.FsToBs ::wwmt_def_model_path
			)
			if m == undefined then (
				m = ""
			)
			local wwDir = ::wwmt_export + "\\" + m + "\\" + modelName + "_wwmt_custom.qci"
			if doesFileExist wwDir == false then (
				wwmt.createCustomQCI()
			)
			if doesFileExist wwDir == true then (
				folderOpen = "ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + wwDir + "\""
				execute folderOpen
			) else (
				messageBox "Oops... the QCI doesn't exist yet and WWMT can only create/edit it once the model name has been set."
			)
		)

		on btn_open_model_folder pressed do (
			local m = ""
			if modelPath != "" then (
				m = wwmt.FsToBs modelPath
			) else(
				m = wwmt.FsToBs ::wwmt_def_model_path
			)

			local wwDir = ::wwmt_export + "\\" + m
			local canOpen = doesFileExist wwDir
			if NOT canOpen then (
				canOpen = makeDir wwDir all:true
			)
			if canOpen then (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
				execute folderOpen
			)
		)

		on btn_open_mat_folder pressed do (
			local m = ""
			if materialPath != "" then (
				m = wwmt.FsToBs materialPath
			) else (
				m = wwmt.FsToBs ::wwmt_def_material_path
			)
			local wwDir = ::wwmt_exportMats + "\\" + m
			local canOpen = doesFileExist wwDir
			if NOT canOpen then (
				canOpen = makeDir wwDir all:true
			)
			if canOpen then (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
				execute folderOpen
			)
		)

		on btn_tex pressed do (
			ers = wwmt.checkForProblems()
			if ers.count == 0 then (
				global ww_scene_lods
				if ww_scene_lods != wwmt then (
					global wwToolsFloater
					if wwToolsFloater != undefined then (
						try(closeRolloutFloater wwToolsFloater)catch()
					)
					ww_scene_lods = wwmt
				)
				if (::wallworm_installation_path == undefined) then (
					::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
				)
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/textureExport.ms")
			) else (
				message = "There were problems you need to address:\n\n"
				for em in ers do (
					append message ("\t* " + em + "\n")
				)
				messageBox message
			)
		)

		on ddl_compression selected sel do (
			compression = ddl_compression.selected
			if wwmt == undefined then getWWMT()
			wwmt.compression = compression
		)
		on ddl_shader selected sel do (
			shaderType = ddl_shader.selected
			if wwmt == undefined then getWWMT()
			wwmt.shaderType = shaderType
		)

		on btn_setSkyScale pressed do
		(
			spn_scale.value = 0.0625
			if wwmt == undefined then getWWMT()
			wwmt.setScale(spn_scale.value)
		)
		on btn_setSkyScale2 pressed do
		(
			spn_scale.value = 0.03125
			if wwmt == undefined then getWWMT()
			wwmt.setScale(spn_scale.value)
		)
		on mainrollout open do (
			getNode()

			if ::wallwormWWMTCAversion == undefined then (
				if (::wallworm_installation_path == undefined) then (
					::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
				)
				if ::ww_LOD_wrapper == undefined AND doesFileExist (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms") then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
				)
			)

			if ::wallwormWWMTCAversion == undefined OR thisNode.WallWorm_Model_Tools.version < ::wallwormWWMTCAversion then (
				/*
				if ::wallworm_update_wwmt_cas != undefined then (
					wallworm_update_wwmt_cas thisNode desel:true
				)
				*/
				messageBox "This WWMT object is out-of-date. Please update WWMT Helpers in the pop-up that appears."
				max select none
				macros.run "wallworm.com" "WallWormCheckForProblemsMCR"

			) else (
				sanitize()
				getWWMT updateCA:false
				updateNames()
				if mainrollout != undefined then (
					if ::wwmt_surfaceprop_list != undefined AND surfaceprop != undefined then (
						if findItem ::wwmt_surfaceprop_list surfaceprop == 0 then (
							append ::wwmt_surfaceprop_list surfaceprop
							sort ::wwmt_surfaceprop_list
						)
						ddl_surfaceprop.items = ::wwmt_surfaceprop_list
					)
					updateSurfacePropselection()
					if ::wwmt_current_model_Paths != undefined AND modelPath != undefined then (
						if findItem ::wwmt_current_model_Paths modelPath == 0 then (
							append ::wwmt_current_model_Paths modelPath
							sort ::wwmt_current_model_Paths

						)
						edt1_modelPath.items = ::wwmt_current_model_Paths
					)

					updateModelPathselection()
					if ::wwmt_current_material_Paths != undefined AND materialPath != undefined then (
						if findItem ::wwmt_current_material_Paths materialPath == 0 then (
							append ::wwmt_current_material_Paths materialPath
							sort ::wwmt_current_material_Paths

						)
						edt2_materialFolder.items = ::wwmt_current_material_Paths
					)
					updateMaterialPathselection()
				)

			)
		)

		on addModel picked obj do (
			wwmt.addObjToObjects obj
			updateNames()
		)

		on btn_removeSelFromTargets pressed do
		(
			if listNodes.selection > 0 then (
				wwmt.removeItemsFromTargets targets[listNodes.selection]
				updateNames()
			)
		)

		on exportWWMT pressed do (
			getWWMT()
			if wwmt != undefined then (
				sanitize()
				updateWWMTFromThis()
				wwmt.outputModelQC()
			) else (
				messageBox "The model could not export. Perhaps WWMT is not installed."
			)
		)

		on ddl_surfaceprop selected sel do (
			surfaceprop = ddl_surfaceprop.selected
			if wwmt == undefined then getWWMT()
			wwmt.surfaceprop = surfaceprop
		)
		on ddl_surfaceprop entered tex do (
			surfaceprop = tex
			if wwmt == undefined then getWWMT()
			wwmt.surfaceprop = surfaceprop
			updateSurfacePropselection()
		)

		on edt2_materialFolder selected sel do (
			materialPath = edt2_materialFolder.selected
			if wwmt == undefined then getWWMT()
			wwmt.materialPath = materialPath
		)
		on edt2_materialFolder entered tex do (
			materialPath = tex
			if wwmt == undefined then getWWMT()
			wwmt.materialPath = materialPath
			updateMaterialPathselection()
		)

		on edt1_modelPath selected sel do (
			modelPath = edt1_modelPath.selected
			if wwmt == undefined then getWWMT()
			wwmt.modelPath = modelPath
		)
		on edt1_modelPath entered tex do (
			modelPath = tex
			wwmt.modelPath = modelPath
			if wwmt == undefined then getWWMT()
			updateMaterialPathselection()
		)

	)

	rollout hullrollout "Collision Model" (
		Group "Hull Options" (
			CheckBox chk_autoHull "Auto Hull" toolTip:"Use the root model SMD for generating a Collision Hull. Should not be used with animated models." align:#right
			ListBox listHulls "Hulls" items:(for obj in hulls WHERE obj != undefined AND isValidNode obj collect obj.name) enabled:(NOT autoHull) offset:[0, -20]
			PickButton addPhys "+" toolTip:"Pick a collision model you have already made for this model." across:3 align:#left width: 20
			Button btn_deleteHulls "-" toolTip:"Remove Selected Items from the Collision Hull List of this model." align:#left width: 20 offset:[-20, 0]
			Button createPhys "Quick Hull" offset:[-40, 0] align:#left toolTip:"Create a Collision Model from the model. This will automatically make a convex mesh for each element of the picked object. If there is only one element, the collision model may not be very realistic."
			Spinner spn_max_verts "Max Verts Hulls" type:#integer scale:1 toolTip:"Maximum vertices per hull in generated hull." default:44 range:[4, 4096, 44]
			Label grp1 "Hull Count" across:3
			Label lbl_hullcount "?"
			Button btn_update_count "^" toolTip:"Press to update the Hull Count."
		)

		on listHulls rightClick sel do (
			select (hulls[listHulls.selection])
		)
		on listHulls selected sel do (
			nds = #(hulls[listHulls.selection])
			flashNodes nds
			forceCompleteredraw()
		)

		on btn_deleteHulls pressed do
		(
			if listHulls.selection != 0 then (
				deleteItem hulls listHulls.selection
				if wwmt == undefined then getWWMT()
				wwmt.hulls = hulls as Array
				updateHullListNames()
			)
		)
		on addPhys picked obj do
		(
			if wwmt == undefined then getWWMT()
			if (wwmt.addPhysModel obj) then (
				--wwmt.setHullNameChangeHandler()

			) else (
				messageBox "The action failed. Do not use Grouped geometry."
			)
			updateHullListNames()
		)
		on createPhys pressed do
		(
			if wwmt == undefined then getWWMT()
			if (wwmt.createHull maxVerts:spn_max_verts.value) == true then (
				autoHull = false
				if wwmt.hulls.count > 1 OR wwmt.concave == true then (
					concave = true
				)

				updateHullListNames()

				getNode()
				select thisNode

			) else (
				messageBox "There was a problem:\n\n The Wall Worm Hull Helper only works if you have either:\n\n *The nVidia PhysX Plugin or MassFX (Integrated into 3ds Max 2013+)\n*Convexity 1.17+.\n\nIf you meet one of these requirements, please submit a bug report.\n\n*Unfortunately, some versions of PhysX/MassFX have broken the hull function."
			)
		)

		on btn_update_count pressed do
		(
			if NOT autoHull then (
				try (
					local hullcount = 0
					if hulls.count > 0 then (
						if concave == true then (
							hullcount = wwmt_count_hulls wwmt.hulls concave
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

		CheckBox chk_concave "$concave"

		Group "Physical Properties" (
			PickButton pckMassOrigin "Mass Origin"
			CheckBox chk_usePhysOverrides "Use Overrides"
			Spinner spn_mass "Mass" toolTip:"Set a value for the mass of this object. This value will not be used if $automass is checked." width:100 across:2 enabled:(NOT automass) range:[0, 99999999, 0] enabled:usePhysOverrides
			CheckBox chk_automass "Auto" toolTip:"Calculate mass of object based on volume and the type of material defined by Surface Property. This will override values entered into the mass field." align:#right

			DropDownList ddl_contents "Contents" items:#("solid", "notsolid", "monster", "ladder", "grate") selection:(findItem ddl_contents.items contents)
			Spinner spn_rotDamping "Rot Damping" enabled:usePhysOverrides
			Spinner spn_inertia "Inertia" range:[0, 1024, 1] toolTip:"Inertial Scale" enabled:usePhysOverrides
			Spinner spn_Damping "Damping" range:[0, 1024, 1] toolTip:"Damping Scale" enabled:usePhysOverrides
			Spinner spn_phdrag "Drag" range:[0, 1024, 1] toolTip:"Drag Scale" enabled:usePhysOverrides
		)

		Group "Advanced" (
			CheckBox chk_jointrestrain "$jointconstrain" toolTip:"Add $jointconstrain limits to the joints of this model based off of the bone IK info"
			CheckBox chk_noselfcollisions "No Self Collisions" toolTip:"Do not allow collision hulls in same model collide with each other."
			Label anfrlabel "Animated Friction" tooltip:"<float|FrictionTimeIn> <float|FrictionTimeOut> <float|FrictionTimeHold> <float|MinAnimatedFriction> <float|MaxAnimatedFriction> Used to animate the amount of friction on joints over time.  "
			EditText edt_animatedfriction ""
		)
		Group "Functions" (
			Button btn_SelectHulls "Select Collision Hulls" toolTip:"Select in viewport all meshes belonging to the collision hull."
			Button btnHideCM "Hide CM" toolTip:"Hide all meshes belonging to the collision hull." across:2
			Button btnShowCM "Show CM" toolTip:"Unhide all meshes belonging to the collision hull."
			Button btn_processCM "Process CM" toolTip:"Click here to give each element in the Hull a unique smoothing group."
			Button btn_hull_helper "WW Hull Helper" toolTip:"Open the Hull Helper Utility Floater; provides tools for quickly and efficiently making complex hulls from your meshes."

		)

		on ddl_contents selected sel do (
			contents = ddl_contents.selected
		)

		on hullrollout open do (
			updateHullListNames()
		)

		on btnHideCM pressed do (
			hide (hulls as Array)
		)

		on btnShowCM pressed do (
			unhide (hulls as Array)
		)

		on btn_SelectHulls pressed do (
			select (hulls as Array)
		)

		on btn_hull_helper pressed do (
			macros.run "wallworm.com" "WallWormHullHelperMCR"
		)

	)

	rollout propdatarollout "Prop Data & Gibs" (
		Hyperlink hyperlinkgibs "Prop Data Help" align:#right address:"http://dev.wallworm.com/topic/28/prop_data_and_custom_gibs.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		ComboBox ddl_base "Base" offset:[0, -20] items:#("", "Cardboard.Small", "Cardboard.Medium", "Cardboard.Large", "Cardboard.break", "Cardboard.Indestructable", "Cardboard.breakclient", "Cloth.Small", "Cloth.Medium", "Cloth.Large", "Cloth.Object", "Flesh.Tiny", "Flesh.Small", "Glass.Small", "Glass.Window", "Glass.picture", "Glass.CSWindow", "Glass.CSWindow2", "Glass.WindowStrong", "Item.Small", "Item.Medium", "Item.Large", "Door.Standard", "Metal.Small", "Metal.Medium", "Metal.Large", "Metal.break", "Metal.break2", "Metal.MediumClient", "Wooden.Tiny", "Wooden.Small", "Wooden.chair", "Wooden.MediumNobreak", "Wooden.Large", "Wooden.Huge", "Wooden.sticks", "Wooden.Barrel", "Wooden.Small2", "Wooden.Barrel2", "Metal.Large", "Plastic.Small", "Plastic.Medium", "Plastic.Large", "Plastic.break", "PlasticSmall.break", "Plastic.Small2", "Pottery.Small", "Pottery.Medium", "Pottery.Large", "Pottery.Huge", "Pottery.break", "Pottery.Plant", "Pottery.break2", "Pottery.PlantBreak", "Stone.Small", "Stone.Medium", "Stone.Large", "Stone.Huge", "Stone.Gigantic", "Wooden.Tiny", "Wooden.Small", "Wooden.Medium", "Wooden.Large", "Wooden.ExtraLarge", "Wooden.Huge")
		CheckBox chkOverridePhys "Use Overrides" default:false
		Spinner spn_health "Health" range:[0, 10000, 0] type:#integer scale:1 enabled:overridePhys
		CheckBox chk_allowstatic "Allow Static"
		DropDownList ddl_physicsmode "Physics Mode" items:#("Auto", "Solid, pushes the player away.", "Non-solid, but gets pushed away by the player.", "Non-solid, clientside simulated only.") enabled:overridePhys
		CheckBox chk_blockLOS "Block Line of Sight"
		CheckBox chk_AIWalkable "AI Walkable"
		Group "Damage Modifiers" (
			Spinner spn_dmg_bullets "dmg.bullet" range:[0, 10000, 1] enabled:overridePhys
			Spinner spn_dmg_club "dmg.club" range:[0, 100, 1] enabled:overridePhys
			Spinner spn_dmg_explosive "dmg.explosive" range:[0, 10000, 1] enabled:overridePhys
		)
		Group "Flammable Prop" (
			CheckBox chk_ignite "Ignite" enabled:overridePhys
			CheckBox chk_explosive_resist "Explosive Resist" enabled:overridePhys
			CheckBox chk_flammable "Flammable" enabled:overridePhys
		)
		Group "Exploding Prop" (
			Spinner spn_explosive_damage "Exp. Dmg" range:[0, 10000, 0] enabled:overridePhys
			Spinner spn_explosive_radius "Exp. Radius" range:[0, 10000, 0] enabled:overridePhys
		)
		DropDownList ddl_multiplayer_break "Multiplayer Break" items:#("client", "server", "both") enabled:overridePhys --selection:(ddl_multiplayer_break.items[(findItem ddl_multiplayer_break.items multiplayer_break)])
		CheckBox chk_motiondisabled "motiondisabled" tooltip:"To spawn non-moving gibs (in some mods)."
		Group "Gibs Settings" (
			DropDownList ddl_breakable_model "Gibs Model Class" items:#("", "WoodChunks", "GlassChunks", "ConcreteChunks", "MetalChunks", "CustomGibs") --selection:(findItem ddl_breakable_model.items breakable_model)
			Spinner spn_breakable_count "Count" type:#integer scale:1
			Spinner spn_breakable_skin "Skin #" type:#integer scale:1
			Spinner spn_fadetime "Fade Time" range:[0, 10000, 0] type:#integer scale:1
			PickButton btn_custGibs "+" toolTip:"Click here to selected a mesh as Gibs models for this model." enabled:(breakable_model == "CustomGibs") across:2 align:#left
			Button btn_removeGibs "Remove Selected" toolTip:"Click to remove all selected items from the gibs list for this model." enabled:(breakable_model == "CustomGibs") offset:[-20, 0]
			ComboBox cmb_gibslist "Custom Gibs List" enabled:(breakable_model == "CustomGibs") items:(for obj in gibs collect obj.name)
			Button btn_compileGibs "Compile Gibs" toolTip:"Click here to compile all gibs models." enabled:(breakable_model == "CustomGibs")
			Button btn_compileGibsVTFs "Compile Gibs VTFs" toolTip:"Click here to compile all textures belonging to gibs." enabled:(breakable_model == "CustomGibs")
			Button btnSendSettingsToGibs "Send Phys Overrides to Gibs" tooltip:"Send the settings above to the gibs models."
		)

		on btnSendSettingsToGibs pressed do (
			sendoverridestogibs()
		)

		on btn_compileGibs pressed do (
			if gibs.count > 0 then (
				wwmt.gibs = gibs as Array
				wwmt.exportGibs()
				select (getNode())
			) else (
				messageBox "There are no CustomGibs models assigned."
			)
		)

		on btn_custGibs picked obj do (
			wwmt.addGibs (#(obj))
			cmb_gibslist.items = (for obj in gibs collect obj.name)
		)

		on btn_removeGibs pressed do (
			deleteItem gibs cmb_gibslist.selection
			wwmt.gibs = gibs as Array
			cmb_gibslist.items = (for obj in gibs collect obj.name)
		)

		on ddl_breakable_model selected sel do (
			breakable_model = ddl_breakable_model.selected

			cmb_gibslist.enabled = (breakable_model == "CustomGibs")

		)

		on ddl_multiplayer_break selected sel do (
			multiplayer_break = ddl_multiplayer_break.selected
		)

		on ddl_physicsmode selected sel do (
			physicsmode = sel
		)

		on ddl_base selected arg do (
			base = ddl_base.selected
		)

		function addToBase = (
			if findItem ddl_base.items base == 0 then (
				oldItems = ddl_base.items
				append oldItems base
				ddl_base.items = oldItems
			)
			ddl_base.selection = findItem ddl_base.items base
		)
		on ddl_base entered tex do (
			base = tex
			addToBase()
		)

		on propdatarollout open do (
			if multiplayer_break != undefined then (
				ddl_multiplayer_break.selection = findItem ddl_multiplayer_break.items multiplayer_break
			)
			if breakable_model != undefined then (
				ddl_breakable_model.selection = findItem ddl_breakable_model.items breakable_model
			)
			if base != undefined then (
				addToBase()
			)

		)

	)

	function getEyePosition = (
		if NOT isValidNode eyeposition then (
			eyeposition = Point axistripod:off size:10 wireColor:white box:on cross:on name:(uniqueName (modelName + "EyePosition")) pos:[0, 0, 73]
			eyeposition.parent = targets[1]
		)
		eyeposition
	)

	function createEyeball mat:undefined = (
		local eye = Sphere radius:2 wireColor:white mapcoords:on recenter:off slice:off hemisphere:0.0 segs:16 smooth:on realWorldMapSize:off
		--look for head bones

		for obj in bonelist while eye.parent == undefined do (
			if obj.name == "head" OR obj.name == "ValveBiped.Bip01_Head" then (
				eye.parent = obj
			)
		)
		for obj in targets while eye.parent == undefined do (
			if obj.name == "head" OR obj.name == "ValveBiped.Bip01_Head" then (
				eye.parent = obj
			)
		)
		for obj in targets while eye.parent == undefined do (
			if (wallworm_get_modifierByClass obj Morpher) != undefined OR (wallworm_get_modifierByClass obj Morph_O_Matic) != undefined then (
				if isValidNode obj.parent then (
					eye.parent = obj.parent
				) else (
					eye.parent = obj
				)
			)
		)

		for ey in eyeballs while eye.parent == undefined do (
			if isValidNode ey.parent then (
				eye.parent = ey.parent
			)
		)

		append eyeballs eye

		if eye.parent == undefined then (
			getEyePosition()
			eye.parent = eyeposition

		)

		local xpos
		if (mod eyeballs.count 2) == 0 then (
			eye.name = (uniqueName "EyeballLeft")
			xpos = 4
		) else (
			xpos = -4
			eye.name = (uniqueName "EyeballRight")
		)

		if mat == undefined then (
			for ey in eyeballs while eye.mat == undefined do (
				if ey.mat != undefined then (
					eye.mat = ey.mat
				)
			)
		)
		if eye.mat == undefined then (
			local map = Gradient_Ramp name:"DummyEyeTexture"
			map.Gradient_Type = 8
			map.gradient_ramp.flag__1.color = [0, 0, 0]

			map.gradient_ramp.flag__2.color = [255, 255, 255]

			map.gradient_ramp.flag__3.color = [255, 255, 255]
			map.gradient_ramp.flag__3.position = 9.0

			eye.mat = Standard name:"EyeMaterial" diffuseColor:white diffuseMap:map showInViewport:true
		)

		in coordsys world eye.pos = eye.parent.transform.translationPart + [xpos, -24, 0]
		eye
	)

	rollout otherParamsRollout "Lighting and Other" (
		CheckBox chk_ambientboost "Ambient Boost"
		Spinner spn_constantdirectionallight "$constantdirectionallight" width:150 align:#right
		PickButton illumpickbuton "Illumination Origin"
		CheckButton chk_morphasvta "Morph as VTA"
		Group "Eyes Position" (
			Button sel_eyeposition "Get Eye Position"
			ListBox eyelist "Eyes" height:4
			Button bntAddeyement "New" across:4
			PickButton pckAddeye "Pick"
			Button btnSeleye "Sel"
			Button btnRemoveEye "Remove"
		)

		on sel_eyeposition pressed do (
			getEyePosition()
			select eyeposition
		)

		function refresheyeList1 = (
			sanitizeEyeballs()
			eyelist.items = for obj in eyeballs WHERE isValidNode obj collect obj.name

		)

		on bntAddeyement pressed do (
			createEyeball()
			refresheyeList1()
		)

		on eyelist selected sel do (
			local eye = eyeballs[eyelist.selection]
			if isValidNode eye then (
				flashnodes (#(eye))
				forcecompleteredraw()
			)
		)

		on btnSeleye pressed do (
			local eye = eyeballs[eyelist.selection]
			if isValidNode eye then (
				select eye
			)
		)

		on btnRemoveEye pressed do (
			if eyelist.selection > 0 then (
				deleteItem eyeballs eyelist.selection
				refresheyeList1()
			)
		)

		on pckAddeye picked obj do (
			if isValidNode obj then (
				if findItem eyeballs obj == 0 then (
					append eyeballs obj
					refresheyeList1()
				)
			)
		)

		on otherParamsRollout open do (
			refresheyeList1()
		)
	)

	rollout proxrollout "Proxy Functions" (
		Button addProx "Create Proxy"
		Button updateProxies "Update Proxy Meshes"
		Button selectAllProxies "Select All Proxies"
		Button collectSkins "Collect Skins from Proxies"
		Button moreProxTools "More Proxy Tools"

		on updateProxies pressed do (
			if wwmt != undefined then (
				wwmt.update_proxies_in_scene()
			) else (
				messageBox "The WWMT struct is missing. Perhaps Wall Worm is not installed correctly."
			)
		)
		on addProx pressed do (
			if wwmt != undefined then (
				append wwmt.proxies (wwmt.createProxy())
			) else (
				messageBox "The WWMT struct is missing. Perhaps Wall Worm is not installed correctly."
			)
		)

		on selectAllProxies pressed do (
			if wwmt != undefined then (
				local p = wwmt.getProxies()

				select (p as Array)

			) else (
				messageBox "The WWMT struct is missing. Perhaps Wall Worm is not installed correctly."
			)
		)
		on collectSkins pressed do (
			if wwmt != undefined then (
				wwmt.gatherMySkins updateSkinNums:true
			) else (
				messageBox "The WWMT struct is missing. Perhaps Wall Worm is not installed correctly."
			)
		)

		on moreProxTools pressed do (
			macros.run "wallworm.com" "WallWormModelToolsProxyToolsMCR"
		)

	)

	rollout vmfparamsrollout "VMF Settings" (
		CheckBox chk_exclude_vmf "Exclude from VMF"
		CheckBox chk_skybox "Export in Skybox"
	)

	rollout attachrollout "Models, Attachments & Bones" (
		ListBox attachlist "Attachments" height:4
		Button bntAddAttachment "New" across:4
		PickButton pckAddAttach "Pick"
		Button btnSelAttach "Sel"
		Button btnRemoveAtt "Remove"

		ListBox boneslistbox "Bones" height:4
		PickButton pckAddBone "Pick" across:3
		Button btnSelBone "Sel"
		Button btnRemovebone "Remove"

		function refreshAttachmentList1 = (
			sanitizeAttachments()
			attachlist.items = for obj in attachments WHERE isValidNode obj collect obj.name

		)

		on bntAddAttachment pressed do (
			local att = wwmt.createNewAttachment absolute:true rigid:true label:"attachment" asBone:false
			refreshAttachmentList1()
		)

		on bntAddAttachment rightclick do (
			local att = wwmt.createNewAttachment absolute:true rigid:true label:"attachment" asBone:true
			refreshAttachmentList1()
		)

		on attachlist selected sel do (
			local attnode = attachments[attachlist.selection]
			if isValidNode attnode then (
				flashnodes (#(attnode))
				forcecompleteredraw()
			)
		)

		on btnSelAttach pressed do (
			local attnode = attachments[attachlist.selection]
			if isValidNode attnode then (
				select attnode
			)
		)

		on btnRemoveAtt pressed do (
			if attachlist.selection > 0 then (
				deleteItem attachments attachlist.selection
				refreshAttachmentList1()
			)
		)

		on pckAddAttach picked obj do (
			if isValidNode obj then (
				addAttachment obj:obj
				refreshAttachmentList1()
			)
		)

		on btnSelBone pressed do (
			local bn = bonelist[boneslistbox.selection]
			if isValidNode bn then (
				select bn
			)
		)
		on boneslistbox selected sel do (
			local bn = bonelist[boneslistbox.selection]
			if isValidNode bn then (
				flashnodes (#(bn))
				forcecompleteredraw()
			)
		)

		function refreshBoneList1 = (
			bonelist = for obj in bonelist WHERE isValidNode obj collect obj
			boneslistbox.items = for obj in bonelist collect obj.name
		)

		on pckAddBone picked obj do (
			if isValidNode obj then (
				wwmt.addToBones (#(obj))
				refreshBoneList1()
			)
		)

		on btnRemovebone pressed do (
			if boneslistbox.selection > 0 then (
				wwmt.removeFromBones (#(bonelist[boneslistbox.selection]))
				refreshBoneList1()
			)
		)

		ListBox modelslistbox "WWMTs as $model" height:4
		PickButton pckAddmodel "Pick" across:3
		Button btnSelmodel "Sel"
		Button btnRemovemodel "Remove"

		function exportModelsSMD = (
			local allboneNodes = wwmt.getAllBonesArray()
			for m in models do (
				ww = m.getWWMT refresh:true
				if useLocalOrigin == true then (
					ww.referenceNode = targets[1]
				)
				ww.exportSMDS resetBnArray:true runCompile:false expBody:true expSeq:false expHull:false expLOD:false expVTA:false allboneNodes:allboneNodes
			)
		)

		Button btnSMDAll "Write SMD" across:2
		Button btnSMDSelected "Write SMD Sel"

		on btnSMDAll pressed do (
			exportModelsSMD()
		)

		on btnSMDSelected pressed do (
			if modelslistbox.selection > 0 then (
				m = models[modelslistbox.selection]
				if isValidNode m then (
					ww = m.getWWMT refresh:true
					if useLocalOrigin == true then (
						ww.referenceNode = targets[1]
					)
					ww.exportSMDS resetBnArray:false runCompile:false expBody:true expSeq:false expHull:false expLOD:false expVTA:false allboneNodes:(wwmt.getAllBonesArray())
				)
			)
		)

		on btnSelmodel pressed do (
			local bn = models[modelslistbox.selection]
			if isValidNode bn then (
				select bn
			)
		)
		on modelslistbox selected sel do (
			local bn = models[modelslistbox.selection]
			if isValidNode bn then (
				flashnodes (#(bn))
				forcecompleteredraw()
			)
		)

		function sendBonesToMdls = (
			if NOT staticprop then (
				allboneNodes = wwmt.sortArrayByHeirarchy (wwmt.getAllbonesArray())
				for b in allboneNodes do (
					for i in includes do (
						if findItem i.targets b == 0 AND findItem i.bonelist b == 0 then (
							append i.bonelist b
						)
					)
					for i in models do (
						if findItem i.targets b == 0 AND findItem i.bonelist b == 0 then (
							append i.bonelist b
						)
					)
				)
			)
		)

		function refreshmodelList1 = (
			sanitizeModels()
			modelslistbox.items = for obj in models WHERE isValidNode obj collect obj.name
		)

		on pckAddmodel picked obj do (
			if isValidNode obj then (
				if staticprop AND (queryBox "This is only valid if the current WWMT is NOT a $staticprop. Do you want to remove the $staticprop?") then (
					staticprop = false
				)
				if NOT staticprop then (
					if findItem models obj > 0 then (
						messageBox "The WWMT you picked is already a model."
					) else (
						if isProperty obj #wwmt_ca then (
							append models obj
							refreshmodelList1()
						) else (
							local tempWWMT = ww_LOD_wrapper()
							tempWWMT.init()
							tempWWMT.setTargetModel obj tempWWMT
							tempWWMT.setMaterialPath(materialPath)
							tempWWMT.setModelPath(modelPath)

							append models tempWWMT.target
							refreshmodelList1()
						)
						sendBonesToMdls()
					)
				)
			)
		)
		on btnRemovemodel pressed do (
			if modelslistbox.selection > 0 then (
				deleteItem models modelslistbox.selection
				refreshmodelList1()
			)
		)
		ListBox includeslistbox "$include WWMT" height:4
		PickButton pckAddinclude "Pick" across:3
		Button btnSelinclude "Sel"
		Button btnRemoveinclude "Remove"

		function compileincludes = (
			local allboneNodes = wwmt.getAllBonesArray()
			for m in includes do (
				ww = m.getWWMT refresh:true
				if useLocalOrigin == true then (
					ww.referenceNode = targets[1]
				)
				ww.outputModelQC resetExportList:true writeSMDs:true runCompile:true forceBoneReset:true allboneNodes:allboneNodes
			)
		)
		Button btnCompileAll "Compile All" across:2
		Button btnCompileSelected "Compile Sel"

		on btnCompileAll pressed do (
			compileincludes()
		)
		on btnCompileSelected pressed do (
			if includeslistbox.selection > 0 then (
				m = includes[includeslistbox.selection]
				if isValidNode m then (
					ww = m.getWWMT refresh:true
					if useLocalOrigin == true then (
						ww.referenceNode = targets[1]
					)
					ww.outputModelQC resetExportList:true writeSMDs:true runCompile:true forceBoneReset:true allboneNodes:(wwmt.getAllBonesArray())
				)
			)
		)

		on btnSelinclude pressed do (
			local bn = includes[includeslistbox.selection]
			if isValidNode bn then (
				select bn
			)
		)
		on includeslistbox selected sel do (
			local bn = includes[includeslistbox.selection]
			if isValidNode bn then (
				flashnodes (#(bn))
				forcecompleteredraw()
			)
		)
		function refreshincludeList1 = (
			sanitizeincludes()
			includeslistbox.items = for obj in includes WHERE isValidNode obj collect obj.name
		)

		on pckAddinclude picked obj do (
			if isValidNode obj then (
				if staticprop AND (queryBox "This is only valid if the current WWMT is NOT a $staticprop. Do you want to remove the $staticprop?") then (
					staticprop = false
				)
				if NOT staticprop then (
					if findItem includes obj > 0 then (
						messageBox "The WWMT you picked is already a include."
					) else (
						if isProperty obj #wwmt_ca then (
							append includes obj
							refreshincludeList1()
						) else (
							local tempWWMT = ww_LOD_wrapper()
							tempWWMT.init()
							tempWWMT.setTargetinclude obj tempWWMT
							tempWWMT.setMaterialPath(materialPath)
							tempWWMT.setincludePath(includePath)
							append includes tempWWMT.target
							refreshincludeList1()
						)
						sendBonesToMdls()
					)
				)
			)
		)
		on btnRemoveinclude pressed do (
			if includeslistbox.selection > 0 then (
				deleteItem includes includeslistbox.selection
				refreshincludeList1()
			)
		)
		on attachrollout open do (
			if wwmt != undefined then (
				refreshAttachmentList1()
				refreshBoneList1()
				refreshmodelList1()
				refreshincludeList1()
			)
		)
	)
	function unsetWWMT = (
		free mainrollout
		free hullrollout
		free propdatarollout
		free attachrollout
		free otherParamsRollout
		free proxrollout
		free vmfparamsrollout
		free wwmt
	)
	on update do (
		getWWMT()
		if wwmt != undefined then (
			local oldSelection
			local reselect = (isValidNode thisNode AND thisNode.isSelected)

			if reselect then (
				oldSelection = selection as Array
				max create mode
				max select none
			)

			if version < 12 AND lods.count == 0 then (
				wwmt.getLegacyLODS()
				if wwmt.lods.count > 0 then (
					for l in wwmt.lods do (
						l.wrapper = wwmt
						l.setCustomAttributes()
					)
					lods = for l in wwmt.lods collect l.helperTape
				)
			)

			if (version < 17) then (
				if isValidNode thisNode then (
					collapsebonesTmp = getUserProp thisNode #wwmt_collapsebones
				) else (
					collapsebonesTmp = false
				)

				if collapsebonesTmp == undefined OR collapsebonesTmp == "" OR collapsebonesTmp == false OR collapsebonesTmp == "false" then (
					collapsebones = false
				) else (
					collapsebones = true
				)
				wwmt.collapsebones = collapsebones

			)

			if version < 18 then (
				wwmt.setLegacyAttachments()
			)

			if reselect then (
				select oldSelection
			)

		)

	)

)