/*
Wall Worm Model Tools Source Model Struct
Copyright (c) 2010-2015 by Shawn Olson
http://www.shawnolson.net

A Wall Worm Project
http://www.wallworm.com

*/

if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/Maple3DLayerFns.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormSMD.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_struct_mat.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormHullFuncs.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_lod.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/bone_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/wwmt.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/proxy.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wwmt_struct_attachment.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/attachments.ms")

if ::wallworm_wwmt_pick_fast == undefined then (
	::wallworm_wwmt_pick_fast = false
)

/*
wallworm_allowed_wwmt_obj() : This function is a filter function to stop WW from picking objects that belong to invalid object types and assigning them as WWMT models.
*/
::wallworm_allowed_wwmt_obj = function wallworm_allowed_wwmt_obj obj = (
	local sc = superClassOf obj
	if ::wallworm_wwmt_pick_fast == true then (
		(sc == GeometryClass OR sc == Shape)
	) else (
		if (sc == GeometryClass) then (
			if isProperty obj #wallworm then (
				if ((NOT (isProperty obj #ww_displacement_brush)) AND (NOT (isProperty obj #ww_displacement)) AND (NOT (isProperty obj #wallworm_edit_mesh))) then (
					true
				) else (
					false
				)
			) else (
				if (classOf obj == CorVex) then (
					(NOT obj.isWorldGeometry)
				) else (
					if ((getUserProp obj #wwdt_brush_geometry_export != true)) then (
						if findItem (#("Convexity Walls", "Convexity Floors", "Convexity Library Shapes")) obj.layer.name == 0 then (
							true
						) else (
							false
						)
					) else (
						false
					)
				)
			)
		) else (
			if sc == Shape AND (isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper == true OR (isProperty obj #render_useViewportSettings AND obj.render_useViewportSettings == true)) then (
				true
			) else (
				false
			)
		)
	)
)

struct wallworm_transform_store (
	originalNode,
	tempNode,
	worldTrans,
	parentTrans,
	function setParentTree = (
		if isValidNode tempNode.parent then (
			parentTrans = tempNode.parent.transform
		)
	)
)

function wwmt_CallbackLODCamMove obj = ()
global wwmt_vertexPercentages = #(75, 56.25, 42.1875, 31.6406, 23.73, 17.7975, 13.348, 10.0111, 7.5083, 5.6312)
--Structs used in the Wall Worm Model Tools MaxScript
::ww_LOD_wrapper = struct ww_LOD_wrapper (
	modelName = "modelname",
	isset = false,
	alwayscollapse = false,
	collapsebones = false,
	target,
	targets = #(),
	hulls = #(),
	bonesarray = #(),
	hullbonesarray = #(),
	autoHull = false,
	modelSetName,
	physSetName,
	lods = #(),
	locked = false,
	layer,
	phys,
	lodgroup,
	modelPath,
	materialPath,
	surfaceprop,
	staticprop,
	ambientboost,
	constantdirectionallight,
	opaque,
	mostlyopaque,
	illumorigin,
	mass,
	automass,
	concave,
	contents,
	inertia,
	damping,
	rotDamping,
	jointConstraints,
	phdrag,
	animatedfriction,
	masscenter,
	massorigin,
	mscale,
	noselfcollisions = false,
	useLocalOrigin,
	refSystem,
	altOrigin = false,
	shadowlod,
	expHL1Format = (::wallworm_engine == 1),
	idleSequence = true,
	sequences = #(),
	sequencelist = #(),
	weightlistnames = #(),
	weightlists = #(),
	particlesystems = #(),
	origin,
	bitmaps = #(),
	materials = #(),
	cam,
	camMode = false,
	attachmentlist = #(),
	attachments = #(),
	base = "",
	health,
	allowstatic,
	physicsmode,
	blockLOS,
	AIWalkable,
	dmg_bullets,
	dmg_club,
	dmg_explosive,
	ignite,
	explosive_resist,
	flammable,
	explosive_damage,
	breakable_model,
	breakable_count,
	breakable_skin,
	multiplayer_break,
	explosive_radius,
	fadetime = 15,
	motiondisabled,
	gibs = #(),
	bodygroups = #(),
	morphasvta = true,
	shaderType = "VertexLitGeneric",
	mapChannel = 1,
	range = #(0),
	compression = "DXT5",
	referenceNode = undefined,
	offsetFaces = false,
	lockInitialOrigin = false,
	normalMethod = 3,
	internalOrigin = true,
	rotateRefsystem = true, -- This should really only be on for staticprop
	alreadyExported = #(), --used to avoid infinite loops
	dmx = (::wwmt_default_dmx as BooleanClass),
	proxies = #(),
	isXref = false,
	upaxis = 3,-- 1:X,2:Y,3:Z Default:3 Use Y for Maya-generated models
	proxyFileDoesExist = false, -- when set to true, no need to check if file exists
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
	),
	function needsUpdatedCA = (
		local bo = target.baseobject
		if NOT isProperty bo #Wallworm_Model_Tools OR bo.Wallworm_Model_Tools.version >= ::wallwormWWMTCAversion then (
			false
		) else (
			true
		)
	),
	function makeSequenceListFromCust getFromOld:false = (
		if ::wwmt_sequence == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_sequence.ms")
		)

		if target.sequences.count > 0 then (
			sequencelist = #()
			sequences = #()
			for seqstr in target.sequences do(
				try (
					seq = execute seqstr
					append sequences seq
					append sequencelist seq.sequence
				) catch (
					/*Oops... bad sequence*/
				)
			)
		) else if sequencelist.count > 0 AND getFromOld then (
			for word in sequencelist do(
				s = wwmt_sequence()
				s.sequence = word
				s.getSequenceFromCust target
				append sequences s
			)
		)
	),
	function setSeqListCust = (
		if isValidNode target then (
			setUserProp target #wwmt_sequencelist undefined
			with printAllElements on (
				target.sequences = #()
				for s in sequences do (
					append target.sequences (s as String)
				)
			)
		)
	),
	function setWWMTAttribFromThis = (
		if isValidNode target then (
			if NOT isProperty target #wwmt_ca then (
				custAttributes.add target ::wallworm_model_tools_CA
			)

			target.targets = makeUniqueArray (targets as Array)
			target.hulls = makeUniqueArray (hulls as Array)
			target.gibs = gibs as Array
			--target.proxies = proxies as array

			if lods.count > 0 then (
				for l in lods do (
					l.wrapper = this
					l.setCustomAttributes()
				)

			)

			if isValidNode massorigin AND isProperty target #massorigin then (
				target.massorigin = massorigin
			)
			if isValidNode illumorigin AND isProperty target #illumorigin then (
				target.illumorigin = illumorigin
			)

			if autoHull != undefined then (
				target.autoHull = autoHull
			)
			if mass != undefined then (
				target.mass = mass
			)
			if automass != undefined then (
				target.automass = automass
			)
			if concave != undefined then (
				target.concave = concave
			)
			if contents != undefined then (
				target.contents = contents
			)
			if inertia != undefined then (
				target.inertia = inertia
			)
			if damping != undefined then (
				target.damping = damping
			)
			if rotDamping != undefined then (
				target.rotDamping = rotDamping
			)
			if jointConstraints != undefined then (
				target.jointConstraints = jointConstraints
			)
			if phdrag != undefined then (
				target.phdrag = phdrag
			)
			if animatedfriction != undefined then (
				target.animatedfriction = animatedfriction
			)
			if noselfcollisions != undefined then (
				target.noselfcollisions = noselfcollisions
			)

			--target.attachments = attachments as array
			--bodygroups = bodygroups as array

			if normalMethod != undefined then (
				target.normalMethod = normalMethod
			)
			if compression != undefined then (
				target.compression = compression
			)
			if mapChannel != undefined then (
				target.mapChannel = mapChannel
			)
			target.shaderType = shaderType
			if morphasvta != undefined then (
				target.morphasvta = morphasvta
			)
			if camMode != indefined then (
				target.camMode = camMode
			)
			if cam != undefined then (
				target.cam = cam
			)
			if altOrigin != undefined then (
				target.altOrigin = altOrigin
			)
			if lockInitialOrigin != undefined then (
				target.lockInitialOrigin = lockInitialOrigin
			)
			if rotateRefsystem != undefined then (
				target.rotateRefsystem = rotateRefsystem
			)
			if internalOrigin != undefined then (
				target.internalOrigin = internalOrigin
			)

			if modelName != undefined then (
				target.modelName = modelName
			)
			if locked != undefined then (
				target.locked = locked
			)
			if modelPath != undefined then (
				target.modelPath = modelPath
			)
			if materialPath != undefined then (
				target.materialPath = materialPath
			)
			if concave != undefined then (
				target.concave = concave
			)
			if contents != undefined then (
				target.contents = contents
			)
			if surfaceprop != undefined AND surfaceprop != "undefined" then (
				target.surfaceprop = surfaceprop
			)
			if staticprop != undefined then (
				target.staticprop = staticprop
			)

			if alwayscollapse != undefined then (
				target.alwayscollapse = alwayscollapse
			)

			if collapsebones != undefined then (
				target.collapsebones = collapsebones
			)

			if opaque != undefined then (
				target.opaque = opaque
			)
			if mostlyopaque != undefined then (
				target.mostlyopaque = mostlyopaque
			)

			if mscale != undefined then (
				target.mscale = mscale
			)
			if useLocalOrigin != undefined then (
				target.useLocalOrigin = useLocalOrigin
			)
			if dmg_bullets != undefined AND dmg_bullets as Float != undefined then (
				target.dmg_bullets = dmg_bullets
			)
			if AIWalkable != undefined AND AIWalkable != "undefined" then (
				target.AIWalkable = AIWalkable
			)
			if blockLOS != undefined AND blockLOS != "undefined" then (
				target.blockLOS = blockLOS
			)

			if physicsmode != undefined then (
				target.physicsmode = physicsmode
			)
			if allowstatic != undefined AND allowstatic != "undefined" then (
				target.allowstatic = allowstatic
			)
			if health != undefined AND health as Float != undefined then (
				target.health = health
			)
			if base != undefined then (
				target.base = base
			)
			if dmg_club != undefined AND dmg_club != "undefined" then (
				target.dmg_club = dmg_club
			)
			if dmg_explosive != undefined AND dmg_explosive != "undefined" then (
				target.dmg_explosive = dmg_explosive
			)
			if ignite != undefined AND ignite != "undefined" then (
				target.ignite = ignite
			)
			if explosive_resist != undefined AND explosive_resist != "undefined" then (
				target.explosive_resist = explosive_resist
			)
			if flammable != undefined AND flammable != "undefined" then (
				target.flammable = flammable
			)
			if explosive_damage != undefined AND explosive_damage as Float != undefined then (
				target.explosive_damage = explosive_damage
			)
			if breakable_model != undefined AND breakable_model != "undefined" then (
				target.breakable_model = breakable_model
			)
			if breakable_count != undefined AND breakable_count as Integer != undefined then (
				target.breakable_count = breakable_count
			)
			if breakable_skin != undefined AND breakable_skin != "undefined" then (
				target.breakable_skin = breakable_skin
			)
			if multiplayer_break != undefined AND multiplayer_break != "undefined" then (
				target.multiplayer_break = multiplayer_break
			)
			if explosive_radius != undefined AND explosive_radius as Float != undefined then (
				target.explosive_radius = explosive_radius
			)
			if fadetime != undefined AND fadetime as Float != undefined then (
				target.fadetime = fadetime
			)
			if motiondisabled != undefined AND motiondisabled != "undefined" then (
				target.motiondisabled = motiondisabled
			)
			if dmx != undefined AND dmx != "undefined" then (
				target.dmx = dmx
			)

			setSeqListCust()
		)

	),

	function getParamsFromWWMTAttrib = (
		if isValidNode target AND isProperty target #targets then (
			--target.getWWMT()
			if isProperty target #setWWMT then (
				target.setWWMT this
			)
			if isProperty target #sanitize then (
				target.sanitize()
			)
			targets = makeuniquearray (target.targets as Array)
			hulls = makeuniquearray (target.hulls as Array)
			gibs = target.gibs as Array
			--proxies = target.proxies as array

			if isProperty target #lods then (
				if target.lods.count > 0 then (
					lods = #()
					for l in target.lods WHERE isValidNode l do (
						ld = l.get_lod refresh:true

						if ld != undefined then (
							append lods ld
						)
					)

				)
			)

			massorigin = target.massorigin
			autoHull = target.autoHull

			mass = target.mass
			automass = target.automass
			concave = target.concave
			contents = target.contents
			inertia = target.inertia
			damping = target.damping
			rotDamping = target.rotDamping
			jointConstraints = target.jointConstraints
			phdrag = target.phdrag
			animatedfriction = target.animatedfriction
			noselfcollisions = target.noselfcollisions
			global wwmt_attachment
			attachments = for obj in target.attachments collect (obj.setAtt())
			--bodygroups = target.bodygroups as array

			normalMethod = target.normalMethod
			compression = target.compression
			mapChannel = target.mapChannel
			shaderType = target.shaderType
			morphasvta = target.morphasvta
			camMode = target.camMode
			cam = target.cam
			altOrigin = target.altOrigin
			lockInitialOrigin = target.lockInitialOrigin
			rotateRefsystem = target.rotateRefsystem
			internalOrigin = target.internalOrigin
			modelName = target.modelName
			locked = target.locked
			modelPath = target.modelPath
			materialPath = target.materialPath
			concave = target.concave
			contents = target.contents
			surfaceprop = target.surfaceprop
			staticprop = target.staticprop
			opaque = target.opaque
			mostlyopaque = target.mostlyopaque
			illumorigin = target.illumorigin
			mscale = target.mscale
			useLocalOrigin = target.useLocalOrigin
			dmg_bullets = target.dmg_bullets
			AIWalkable = target.AIWalkable
			blockLOS = target.blockLOS
			physicsmode = target.physicsmode
			allowstatic = target.allowstatic
			health = target.health
			base = target.base
			dmg_club = target.dmg_club
			dmg_explosive = target.dmg_explosive
			ignite = target.ignite
			explosive_resist = target.explosive_resist
			flammable = target.flammable
			explosive_damage = target.explosive_damage
			breakable_model = target.breakable_model
			breakable_count = target.breakable_count
			breakable_skin = target.breakable_skin
			multiplayer_break = target.multiplayer_break
			explosive_radius = target.explosive_radius
			fadetime = target.fadetime
			motiondisabled = target.motiondisabled
			upaxis = target.upaxis
			if isProperty target #dmx then (
				dmx = target.dmx
			)

			if isProperty target #alwayscollapse then (
				alwayscollapse = target.alwayscollapse
			)
			if isProperty target #collapsebones then (
				collapsebones = target.collapsebones
			)
			makeSequenceListFromCust()
		)

	),

	function init = (
		global wwmtCompileMessage

		lods = #()
		hulls = #()
		bonesarray = #()
		hullbonesarray = #()
		attachmentlist = #()
		attachments = #()
		gibs = #()
		bodygroups = #()
		sequences = #()
		sequencelist = #()
		weightlistnames = #()
		weightlists = #()
		targets = #()
		idleSequence = true
		proxies = #()
		upaxis = 3
		global wwmt_sequence
		if wwmt_sequence == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_sequence.ms")
		)
		global wwmt_weightlist

		useLocalOrigin = ::wwmt_use_local_origin as BooleanClass
		rotateRefsystem = ::wwmt_rotateRefsystem as BooleanClass
		mapChannel = ::wwmt_mappingChannel as Integer

		mscale = 1
		layer = "WW Model Tools Layer"

		--reset everything to defaults	
		modelName = "modelname"
		shaderType = "VertexLitGeneric"
		isset = false
		target = undefined
		autoHull = false
		locked = false
		noselfcollisions = false
		modelSetName = undefined
		physSetName = undefined
		phys = undefined
		lodgroup = undefined
		modelPath = undefined
		materialPath = undefined
		surfaceprop = undefined
		lockInitialOrigin = false
		collapsebones = false
		normalMethod = 3
		animatedfriction = undefined
		staticprop = ::wwmt_default_staticprop as BooleanClass
		dmx = ::wwmt_default_dmx as BooleanClass
		ambientboost = undefined
		constantdirectionallight = undefined
		opaque = undefined
		mostlyopaque = undefined
		illumorigin = undefined
		mass = undefined
		automass = undefined
		concave = undefined
		contents = undefined
		inertia = undefined
		damping = undefined
		rotDamping = undefined
		jointConstraints = undefined
		phdrag = undefined
		masscenter = undefined
		massorigin = undefined
		altOrigin = false
		shadowlod = undefined
		expHL1Format = (::wallworm_engine == 1)
		origin = undefined
		cam = undefined
		camMode = false
		base = ""
		particlesystems = #()
		health = undefined
		allowstatic = undefined
		physicsmode = undefined
		blockLOS = undefined
		AIWalkable = undefined
		dmg_bullets = undefined
		dmg_club = undefined
		dmg_explosive = undefined
		ignite = undefined
		explosive_resist = undefined
		flammable = undefined
		explosive_damage = undefined
		breakable_model = undefined
		breakable_count = undefined
		breakable_skin = undefined
		multiplayer_break = undefined
		explosive_radius = undefined
		motiondisabled = undefined
		fadetime = 15
		morphasvta = true
		internalOrigin = true
		collapsebones = false

	),

	function writeBonesArray = (
		if isValidNode target then (
			s = ""
			iteration = 1

			for so in bonesarray WHERE (isValidNode so == true) do (
				if iteration > 1 then (
					append s ","
				)

				append s so.name
				iteration = iteration + 1
				appendifUnique bonesarray so
				if findItem target.bonelist so == 0 then (
					append target.bonelist so
				)

			)

			--setUserProp target #wwmt_bonelist  s

		)

	),

	function addToBones bonelist = (
		bonelist = bonelist as Array
		if bonelist != undefined AND bonelist.count > 0 then (
			for b in bonelist do (
				if (findItem target.bonelist b) == 0 then (
					append target.bonelist b
				)

			)
			bonesarray = target.bonelist as Array
		)
		bonesarray
	),

	function removeFromBones bonelist = (
		bonelist = bonelist as Array
		if bonelist != undefined AND bonelist.count > 0 then (
			for bin = bonelist.count to 1 do (
				b = bonelist[bin]
				local bi2 = findItem target.bonelist b
				if bi2 != 0 then (
					deleteItem target.bonelist bi2
				)
			)
			bonesarray = target.bonelist as Array
		)
	),

	function checkForRenderableMesh = (
		if ::wwmt_exportNonRenderableMeshAsBone == false then (
			true
		) else (
			local rfound = false
			for ob in targets while rfound == false do (
				if (ob.renderable == on) then (
					rfound = true
				)
			)
			rfound
		)
	),

	function setRefNode n:undefined = (
		/*	if useLocalOrigin == true AND n==undefined then (
			referenceNode = undefined
		) else (
			*/
		if n == undefined then (
			referenceNode = targets[1]
		) else (
			if isValidNode n then (
				referenceNode = n
			) else (
				referenceNode = targets[1]
			)

		)
		--)
		referenceNode
	),

	function getRefNode = (
		--if useLocalOrigin == true then (
		if NOT isValidNode referenceNode then (
			referenceNode = targets[1]
		)else (
			--targets[1]
		)
		/*) else (
		return undefined
	)*/
		referenceNode
	),

	function getRefSystem t:0 = (
		local rotationAmount = 0
		getRefNode()
		if isValidNode referenceNode AND useLocalOrigin == true then (
			--refsystem = matrix3 [1,0,0] [0,1,0] [0,0,1] (at time t  refNode.transform.translation)
			refSystem = at time t referenceNode.transform

		) else (
			refSystem = Matrix3 1

		)

		if rotateRefsystem == true then (
			rotationAmount += 90
		)

		if flip == true then (
			rotationAmount += 180
		)

		if rotationAmount != 0 then (
			refSystem = rotateZMatrix rotationAmount * refSystem
		)
		refSystem
	),

	function getRefOrientation t:0 = (
		/*

		if isValidNode referenceNode AND useLocalOrigin == true then (
			if lockInitialOrigin == true then (
				refSystem = at time 0 ((matrix3 [1,0,0] [0,1,0] [0,0,1] referenceNode.transform.translation))  
			) else (
				refSystem = at time t ((matrix3 [1,0,0] [0,1,0] [0,0,1] referenceNode.transform.translation))  
			)				
		)

		if rotateRefsystem == true then (
			refSystem = rotateZMatrix 90 *  refSystem

		)
		*/
		if isValidNode referenceNode AND useLocalOrigin == true AND lockInitialOrigin == true then (
			t = 0
		)
		local refSystem = getRefSystem t:t
		refSystem
	),

	function checkForUVWData = (
		local missinguvw = #()
		if ::wwmtExporter == 1 then (
			--Only Necessary with Wunderboy's SMD Exporter

			try(
				pluginManager.loadClass SMDExporter
			) catch(
				--Wunderboy SMD Exporter not installed
			)

			local uvchannelcheck = mapChannel
			if WBSMDExportVersionNum() < 1701 then (
				uvchannelcheck = 1
			)

			objsToCheck = #()
			join objsToCheck targets
			join objsToCheck hulls
			--  
			-- The newer Unreleased Wunderboy SMD Exporter makes up missing UVs like Canonfodder and WW 
			--format "Objects to Check: %\n\n" (objsToCheck)
			for obj in objsToCheck do (
				tempObj = copy obj
				--format "Object Name: % ; Object Class: %" tempObj.name (classOf tempObj)
				convertToPoly tempObj
				if (polyop.getMapSupport tempObj uvchannelcheck) == false then (
					append missinguvw obj
				)
				delete tempObj
			)

			objsToCheck = undefined

		)
		missinguvw
	),

	function canBePropType type:"prop_static" = (
		local er = #()
		if (base != undefined AND base != "") AND type != "prop_physics" AND type != "prop_physics_multiplayer" AND type != "prop_ragdoll" then (
			append er (modelName + " could not be set as " + type + " because it has Prop Data.")
		)
		if (base == undefined OR base == "") AND type == "prop_physics" then (
			append er (modelName + " could not be set as " + type + " because it has no Prop Data.")
		)
		if (type == "prop_ragdoll" OR type == "prop_physics") AND (hulls.count == 0) then (
			append er (modelName + " could not be set as a " + type + " because it has no Collision Hull.")
		)
		if ((type == "prop_detail" OR type == "prop_static") AND (staticprop == undefined OR staticprop == false)) then (
			append er (modelName + " could not be set as " + type + " because it does not have the $staticprop setting.")
		)
		er
	),

	function getProxies legacy:true collection:objects = (
		if legacy == true then (
			proxies = for proxy in objects WHERE ((isProperty proxy #wallwormProxy AND proxy.wwmtTarget == target) OR getUserProp proxy #wwmt_proxie_source == target.name) collect proxy
			for proxy in proxies WHERE NOT isProperty proxy #wallwormProxy do (
				custAttributes.add proxy ::wallworm_proxyskin_holderCA --BaseObject:false 
				proxy.wwmtTarget = target
			)
		) else (
			proxies = for proxy in objects WHERE ((isProperty proxy #wallwormProxy AND proxy.wwmtTarget == target)) collect proxy
		)
		--target.proxies = proxies
		proxies
	),

	function setCoreCVXEntityValue type:"prop_static" = (
		wallworm_setPropDefaults target type:type mdl:(modelPath + "/" + modelName + ".mdl")
		getProxies()
		for proxy in proxies do (
			wallworm_setPropDefaults proxy type:type mdl:(modelPath + "/" + modelName + ".mdl")
		)
		""
	),

	function FsToBs s = (
		wallworm_FsToBs s
	),

	function bsToFs s = (
		wallworm_bsToFs s
	),
	function resetHullBonesarray = (
		hullbonesarray = #()
		if isValidNode target then (
			hullbonesarray = target.bonelist as Array
			for t in hulls WHERE isValidNode t do (
				local sm = wallworm_get_modifierByClass t Skin
				if sm != undefined then (
					global wallworm_getBonesFromSkin
					join hullbonesarray ((wallworm_getBonesFromSkin sm) as Array)
				) else(
					--print "no modifiers"
				)
			)
			hullbonesarray = sortArrayByHeirarchy hullbonesarray
			hullbonesarray = makeUniqueArray hullbonesarray
		)

	),
	function resetBonesArray = (
		bonesarray = #()
		if isValidNode target then (
			bonesarray = target.bonelist as Array
			for t in targets WHERE isValidNode t do (
				local sm = wallworm_get_modifierByClass t Skin
				if sm != undefined then (
					global wallworm_getBonesFromSkin
					join bonesarray ((wallworm_getBonesFromSkin sm) as Array)
				) else(
					--print "no modifiers"
				)
			)
		)
		bonesarray = sortArrayByHeirarchy bonesarray
		bonesarray = makeUniqueArray bonesarray
	),
	function getAllbonesArray = (
		resetBonesArray()
		resetHullBonesArray()
		local allbonenodes = #()
		join allbonenodes (targets as Array)
		join allbonenodes (hulls as Array)

		if bonesarray.count > 0 then (
			join allbonenodes (bonesarray as Array)
		)
		if hullbonesarray.count > 0 then (
			join allbonenodes (hullbonesarray as Array)
		)
		for obj in target.models do (
			ww = obj.getWWMT()
			join allbonenodes (ww.getAllbonesArray())
		)
		for obj in target.includes do (
			ww = obj.getWWMT()
			join allbonenodes (ww.getAllbonesArray())
		)
		allbonenodes = makeUniqueArray allbonenodes
	),
	function boneNameList = (
		local out = #("")
		for b in bonesarray WHERE isValidNode b do (
			appendIfUnique out b.name
		)
		out
	),
	function getMorphObjs = (
		for m in targets WHERE isValidNode m AND (m.modifiers[#Morph_O_Matic] != undefined OR m.modifiers[#Morpher] != undefined) collect m
	),

	function areMorphs = (
		local morphs = false
		for m in targets WHERE isValidNode m while morphs == false do (
			if (wallworm_get_modifierByClass m Morpher) != undefined OR (wallworm_get_modifierByClass m Morph_O_Matic) != undefined then (
				morphs = true
			)
		)
		morphs
	),
	
	function getVTAFlexnames obj = (
		nameArray = #()
		local notFound = true
		local i = 1
		local mMod
		local mma = wallworm_get_modifierByClass obj Morph_O_Matic
		local mrph = wallworm_get_modifierByClass obj Morpher
		if mma != undefined then (
			mMod = mma
		) else if (mrph) != undefined then (
			mMod = mrph
		)

		if mMod != undefined then (
			if classOf mMod == Morpher then (
				--do morpher code

				local usedChannels = #()
				for uc = 1 to 100 do (
					if WM3_MC_HasData mMod uc AND WM3_MC_IsActive mMod uc then (
						append usedChannels uc
					)

				)
				local f = 1
				for c in usedChannels do (
					append nameArray #((WM3_MC_GetName mMod c), f)
					f = f + 1
				)

			) else if classOf mMod == Morph_O_Matic then (
				--do morph-o-matic code
				MOM_HoldLicense()
				/*			
				select obj
				max modify mode
				modPanel.setCurrentObject obj.modifiers[i]			
				*/
				local channels = MOM_GetNumChannels mMod

				for c = 1 to (channels) do (
					--print (classOf (obj.modifiers[i][c]))
					--print (c as string + " : "+(MOM_MC_TARG_GetName obj.morphomatic[1] c))
					append nameArray #((mMod[c].name), c)
				)
			)
		)
		if nameArray.count > 0 then (
			for c = 1 to 100 do (
				case (classOf mMod) of (
					Morpher: (
						if (mMod[c] != undefined) AND (at time c mMod[c].value == 100) then (
							append range c
						)
					)
					Morph_O_Matic:(
						if mMod[c] != undefined AND (at time c mMod[c].progressive == 100) then (
							append range c

						)

					)
				)
			)
		)

		nameArray
	),

	function exportVTAs exportNonRenderableMeshAsBone explist:undefined = (
		local vtaSelection = #()
		local vtaObjects = 0
		local notFound = true
		local morphObjs = getMorphObjs()

		local explist = #()
		join explist (targets as Array)
		if bonesarray.count > 0 then (
			join explist (bonesarray as Array)
		)

		if allboneNodes == undefined then (
			allboneNodes = sortArrayByHeirarchy (getAllbonesArray())
		)

		for obj in morphObjs do (
			local mp = FsToBs modelPath
			local wwDir = ::wwmt_export + "\\" + mp
			local outRange
			local fileExt
			if dmx == true AND ::WallwormProActive == true then (
				fileExt = ".dmx"
				outRange = #(0)
			) else (
				fileExt = ".vta"

			)

			local fname = wwDir + "\\" + modelName + "_" + obj.name + "_flex" + fileExt

			if ::wwmtExporter >= 3 then (
				local exportListOnlyBones = for b in allboneNodes WHERE b != obj collect b

				--use WWMT MXS SMD Exporter
				smd = wallwormSMD()
				smd.usePro = (::WallwormProActive == true AND (::wwmtExporter == 4 OR dmx == true))
				smd.uvwchannel = mapChannel
				smd.justBones = exportListOnlyBones --except for the current object, all objects must be a bone
				smd.flexnamelist = getVTAFlexnames obj
				smd.upaxis = upaxis
				if dmx == true AND ::WallwormProActive == true then (
				) else (
					outRange = range
					for i = 1 to smd.flexnamelist.count do (
						if findItem outRange i == 0 then (
							append outRange i
						)
					)
				)

				smd.range = outRange
				smd.nonRenderableAsBone = exportNonRenderableMeshAsBone
				smd.origin = useLocalOrigin
				smd.staticprop = staticprop
				smd.refNode = getRefNode()
				smd.normalMethod = normalMethod
				smd.internalOrigin = internalOrigin
				smd.rotateRefsystem = rotateRefsystem
				smd.collapsemesh = alwaysCollapse
				smd.flip = altOrigin
				--smd.refNode = targets[1]

				if dmx == true AND ::WallwormProActive == true then (
					smd.type = "VTA"
					smd.outtype = "dmx"

					smd.getRefOrientation t:0
					smd.makeNodeList allboneNodes
					smd.getFlexStates()
					--smd.attachments = target.attachments
				) else (
					smd.type = "VTA"
					smd.makeNodeList allboneNodes
				)

				status = smd.exportSMD fname --releaseAll:false
				if status then (
					if dmx == true AND ::WallwormProActive == true then (
					) else (
						fname = wwDir + "\\" + modelName + "_" + obj.name + "_flex.smd"
						smd.type = "Reference"
						status = smd.exportSMD fname
					)

				)

				if status == false then (
					messageBox "The flex file was not properly exported."
				)

				status
			) else (
				if ::wwmtExporter == 2 then (
					try (
						--if is64bitApplication() then (
						--messagebox "Canonfodder's VTA exporter currently doesn't work with 64bit Max. You may have to try the Wunderboy SMD and VTA exporters."
						--) 

						if (ExportVTA == undefined) then (
							messageBox "Canonfodder's VTA exporter needs to be updated in order to export VTAs with WWMT."
						) else (
							ExportVTA fname true
							true
						)
						false
					) catch (
						messageBox "There was a problem with the VTA export."
						false
					)
				) else (
					--write Wunderboy's export
					try (
						exportFile fname #noPrompt selectedOnly:true using:VTAExporter
						true
					) catch (
						messageBox "There was a problem with the VTA export."
						false
					)
				)
			)

		)

	),
	function setUpAxis axis = (
		upaxis = axis
		if isValidNode target then (
			target.upaxis = upaxis
		)
	), 
	function setShaderType mp = (
		shaderType = mp
		if isValidNode target then (
			target.shaderType = mp
			setUserProp target #wwmt_shader mp
		)
	),
	function setCompression mp = (
		compression = mp
		if isValidNode target then (
			target.compression = mp
			setUserProp target #wwmt_compression mp
		)
	),
	function setParticleSystems = (
		if isValidNode target then (
			setUserProp target #wwmt_particlesystems particlesystems
		)
	),

	function removeParticleSystem ind = (
		deleteItem particlesystems ind
		setParticleSystems()
	),

	function addParticleSystem ps = (
		appendIfUnique particlesystems ps
		setParticleSystems()
	),

	function getParticleSystems = (
		local ps = (getUserProp target #wwmt_particlesystems)

		if ps != undefined then (
			--ps = (ps as array)

			global wwmt_temporary_value

			thestr = "wwmt_temporary_value = " + ps
			execute thestr
			if (wwmt_temporary_value as Array).count > 0 then (
				particlesystems = wwmt_temporary_value
			)
			wwmt_temporary_value = undefined
			--print particlesystems
		)

	),

	function deleteWWMT deleteLODMeshes:false deleteHulls:false deleteTargets:false = (
		try(
			if isValidNode target then (
				delete target
			)
			if isValidNode illumorigin then (
				delete illumorigin
			)
			if isValidNode massorigin then (
				delete massorigin
			)

			if lods.count > 0 then (
				for l in lods do (
					if isValidNode l.helperGizmo then (
						delete l.helperGizmo
					)
					if isValidNode l.helperTape then (
						delete l.helperTape
					)
					if deleteLODMeshes then (
						for i in l.items WHERE isValidNode i do (
							delete i
						)
					)
				)
			)
			if deleteHulls then (
				for h in hulls WHERE isValidNode h do (
					delete h
				)
			)

			if deleteTargets then (
				for t in targets WHERE isValidNode t do (
					delete t
				)
			)

			if isValidNode cam then (
				delete cam
			)
		) catch(
			print "There was an error deleting the WWMT info."
		)
	),

	function setAnimatedfriction m = (
		animatedfriction = trimLeft (trimRight m)
		target.animatedfriction = animatedfriction
		setUserProp target #wwmt_animatedfriction animatedfriction
	),

	function lodcount = (
		lods.count
	),

	function setBase m = (
		if m == undefined then (
			m = ""
		)
		base = m
		target.base = m
		setUserProp target #wwmt_base m
	),
	function setPhysicsmode m = (
		physicsmode = m
		target.physicsmode = m
		setUserProp target #wwmt_physicsmode m
	),
	function setMultiplayer_break m = (
		multiplayer_break = m
		target.multiplayer_break = multiplayer_break
		setUserProp target #wwmt_multiplayer_break m
	),
	function setBreakable_model m = (
		breakable_model = m
		target.breakable_model = m
		setUserProp target #wwmt_breakable_model m
	),
	function setBreakable_count m = (
		breakable_count = m
		target.breakable_count = m
		setUserProp target #wwmt_breakable_count m
	),
	function setHealth m = (
		health = m
		if m != undefined then (
			target.health = m
		)
		setUserProp target #wwmt_health m
	),
	function setDmg_bullets m = (
		dmg_bullets = m
		if m != undefined then (
			target.dmg_bullets = m
		)
		setUserProp target #wwmt_dmg_bullets m
	),
	function setDmg_club m = (
		dmg_club = m
		if m != undefined then (
			target.dmg_club = m
		)
		setUserProp target #wwmt_dmg_club m
	),
	function setDmg_explosive m = (
		dmg_explosive = m
		if m != undefined then (
			target.dmg_explosive = m
		)
		setUserProp target #wwmt_dmg_explosive m
	),
	function setExplosive_damage m = (
		explosive_damage = m
		if m != undefined then (
			target.explosive_damage = m
		)
		setUserProp target #wwmt_explosive_damage m
	),
	function setExplosive_radius m = (
		explosive_radius = m
		if m != undefined then (
			target.explosive_radius = m
		)
		setUserProp target #wwmt_explosive_radius m
	),
	function setBreakable_skin m = (
		breakable_skin = m
		if m != undefined then (
			target.breakable_skin = m
		)
		setUserProp target #wwmt_breakable_skin m
	),
	function setFadetime m = (
		fadetime = m
		if m != undefined then (
			target.fadetime = m
		)
		setUserProp target #wwmt_fadetime m
	),

	function setAllowstatic mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			allowstatic = mp
			target.allowstatic = mp
			setUserProp target #wwmt_allowstatic (mp as String)
		)
	),
	function setBlockLOS mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			blockLOS = mp
			target.blockLOS = mp
			setUserProp target #wwmt_blockLOS (mp as String)

		)
	),
	function setMotiondisabled mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			motiondisabled = mp
			target.motiondisabled = mp
			setUserProp target #wwmt_motiondisabled (mp as String)
		)
	),
	function setAIWalkable mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			AIWalkable = mp
			target.AIWalkable = mp
			setUserProp target #wwmt_AIWalkable (mp as String)
		)
	),
	function setCollapsebones mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			collapsebones = mp
			target.collapsebones = mp
		)
	),
	function setIdleSequence mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:true
			idleSequence = mp
			setUserProp target #wwmt_idleSequence (mp as String)
		)
	),
	function setIgnite mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			ignite = mp
			target.ignite = mp
			setUserProp target #wwmt_ignite (mp as String)
		)
	),
	function setExplosive_resist mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			explosive_resist = mp
			target.explosive_resist = mp
			setUserProp target #wwmt_explosive_resist (mp as String)
		)
	),
	function setMorphasvta mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:true
			morphasvta = mp
			target.morphasvta = mp
			setUserProp target #wwmt_morphasvta (mp as String)

		)
	),
	function setLockOrigin mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			lockInitialOrigin = mp
			target.lockInitialOrigin = mp
			setUserProp target #wwmt_lockInitialOrigin (mp as String)
		)
	),

	function setFlammable mp = (
		if isValidNode target then (
			mp = wallworm_makeBoolean mp def:false
			flammable = mp
			target.flammable = mp
			setUserProp target #wwmt_flammable (mp as String)
		)
	),

	function setTargetCust = (
		if isValidNode target then (
			s = ""
			iteration = 1

			for so in targets WHERE isValidNode so do (
				if iteration > 1 then (
					append s ","
				)

				append s so.name
				iteration = iteration + 1

				local ti = findItem target.targets so
				if ti == 0 then (
					append target.targets so
				)

			)

			setUserProp target #wwmt_targetslist s

		)
	),
	function getMainMaterial matname:undefined = (
		local newmat
		if targets.count > 0 AND targets[1].mat != undefined then (
			newmat = targets[1].mat
		) else (
			local newmat = Standard()
			if matname == undefined then (
				matname = ("VMT_" + modelName + "_")
			)
			newmat.name = uniqueName matname
			newmat.Diffuse = Color 203 37 5
			newmat.ambient = Color 203 37 5

			wallworm_give_mat_ww newmat
			newmat.valveShader = shaderType
			newmat.forModel = true
			if materialPath != undefined then (
				newmat.cdmaterials = materialPath
			)
			if surfaceprop != undefined then (
				newmat.surfaceproperty = surfaceprop
			)
			newmat.keywords = #("wallworm", modelName)
		)
		newmat
	),

	function getAllNodesFromGroup &nodes gr = (
		for obj in gr do (
			if isGroupHead obj then (
				getAllNodesFromGroup nodes obj.children
			) else (
				appendIfUnique nodes obj
				if findItem target.targets obj == 0 then (
					append target.targets obj
				)
			)
		)
	),

	function addObjToObjects obj recurse:false = (
		local added = true
		local startingCount = targets.count
		if classOf obj == ObjectSet then (
			for i in obj WHERE isGroupHead i == false do (
				addObjToObjects i
			)
		) else (
			if obj != target then (
				if ::wwmt_autoMaterialNewModel == true AND superClassOf obj == GeometryClass AND obj.mat == undefined AND isGroupHead obj == false then (
					obj.mat = getMainMaterial()
				)
				--appendIfUnique targets obj
				if findItem target.targets obj == 0  then (
					append target.targets obj
				)
				if isGroupMember obj then (
					getAllNodesFromGroup target.targets obj.parent.children
				)
				for i = targets.count to 1 by -1 do (
					local testNode = targets[i]
					if NOT isValidNode testNode OR getUserProp testNode #wwmt_source_helper != undefined OR isProperty testNode #wwmt_ca then (
						deleteItem target.targets i
					)
				)
				targets = target.targets as Array
				setTargetCust()
			)
		)
		if targets.count <= startingCount then (
			false
		) else (
			true
		)
	),

	function setRootNode obj = (
		if isValidNode obj then (
			addObjToObjects obj
			if targets[1] != obj then (
				local tmp = #(obj)
				join tmp targets
				tmp = makeUniqueArray tmp
				target.targets = tmp
				targets = tmp
				setTargetCust()
			)
			true
		) else (
			false
		)
	),
	function setCamChangeHandler = (
		when transform cam changes id:#wwmtLODCamHandler handleAt:#redrawViews obj do (
			if isDeleted obj == false then (wwmt_CallbackLODCamMove obj)
		)
	),

	function setGibsCust = (
		s = ""
		iteration = 1
		for so in gibs do (
			if iteration > 1 then (
				append s ","
			)
			append s so.name
			iteration = iteration + 1
		)
		setUserProp target #wwmt_gibslist s
	),
	function appendGibs obj = (
		if (superClassOf obj == GeometryClass) then (
			appendIfUnique gibs obj
		) else (
			if (superClassOf obj == Shape AND obj != target) then (
				isWWMTSource = getUserProp obj #wwmt_source_helper
				--wwmt_source_helper
				if (isWWMTSource != undefined AND isWWMTSource == true) then (
					appendIfUnique gibs obj
				)
			)
		)
		if breakable_count == undefined OR gibs.count > breakable_count then (
			breakable_count = gibs.count
			setBreakable_count breakable_count
		)
		if findItem target.gibs obj == 0 then (
			append target.gibs obj
		)
	),
	function setChildGibs tempWWMT = (
		tempWWMT.setMaterialPath(materialPath)
		tempWWMT.setModelPath(modelPath)
		tempWWMT.setConcave(false)
		tempWWMT.setAutoHull(true)
		tempWWMT.setStaticprop(true)
		newModelName = "GibsModel_" + tempWWMT.modelName
		tempWWMT.setModelName(newModelName)
		if base == undefined then (
			base = ""
		)
		tempWWMT.setBase(base)
		tempWWMT.setSurfaceProperty(surfaceprop)
		tempWWMT.setDmg_bullets(dmg_bullets)
		tempWWMT.setDmg_club(dmg_club)
		tempWWMT.setDmg_explosive(dmg_explosive)
		tempWWMT.setFadetime(fadetime)
		tempWWMT.setMotiondisabled(motiondisabled)

		tempWWMT.setTargetCust()
		if referenceNode != undefined then (
			tempWWMT.referenceNode = referenceNode
		)
	),
	function addGibs sel = (
		if sel.count > 0 then (
			for obj in sel do (
				if isValidNode obj then (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel obj tempWWMT
					if isValidNode tempWWMT.target then (
						--this will exclude the gib WWMT from exporting in the VMF
						--setUserProp tempWWMT.target #wallworm_exclude_vmf "true"
						tempWWMT.target.exclude_vmf = true
					)
					if (tempWWMT.isset == true) then (
						setChildGibs tempWWMT
					)
					appendGibs tempWWMT.target
				)
			)
		)
		setGibsCust()
	),
	function removeGibs sel = (
		for obj in sel do (
			local gindex = findItem target.gibs obj
			if gindex != 0 then (
				deleteItem target.gibs gindex
			)
		)
		gibs = target.gibs as Array
		setGibsCust()
	),
	function removeItemFromTargets obj = (
		ind = findItem target.targets obj
		if ind > 0 then (
			deleteItem target.targets ind
			targets = target.targets as Array
			setTargetCust()
		)
	),
	function removeItemsFromTargets sel = (
		for obj in sel do (
			removeItemFromTargets(obj)
		)
	),
	function makeWeightListFromCust = (
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_sequence.ms")
		global wwmt_weightlist
		for word in weightlistnames do(
			s = wwmt_weightlist()
			s.name = word
			s.getWeightListFromObj target
			append weightlists s
		)
	),

	function setWeightListCust = (
		if target != undefined then (
			s = ""
			iteration = 1
			for so in weightlists do (
				if iteration > 1 then (
					append s ","
				)

				append s so.name
				iteration = iteration + 1
			)
			setUserProp target #wwmt_weightlists s
		)
	),

	function addToWeightLists so = (
		local add = true
		for s in weightlists while add do (
			if s.name == so.name then (
				add = false
			)
		)
		if add == true then (
			append weightlists so
			setWeightListCust()
		)
	),
	function addToSequences so = (
		local add = true
		for s in sequences while add do (
			if s.sequence == so.sequence then (
				add = false
			)
		)
		if add == true then (
			append sequences so
			setSeqListCust()
		)
	),
	function removeSequence t = (
		local ind = findItem sequencelist t
		if ind > 0 then (
			deleteItem sequencelist ind
		)
		ind = 1
		for s in sequences do (
			if s.sequence == t then (
				s = undefined
				deleteItem sequences ind
			)
			ind = ind + 1
		)
		setSeqListCust()
	),

	function removeWeightlist t = (
		local ind = findItem weightlistnames t
		if ind > 0 then (
			deleteItem weightlistnames ind
		)
		ind = 1
		for s in weightlists do (
			if s.name == t then (
				s = undefined
				deleteItem weightlists ind
			)
			ind = ind + 1
		)
		setWeightListCust()
	),

	function makeAttachmentListFromCust = (
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wwmt_struct_attachment.ms")
		global wwmt_attachment
		for word in attachmentlist do(
			s = wwmt_attachment()
			s.attachment = word
			s.getAttachmentFromCust target
			append attachments s
		)
	),

	function setLegacyAttachments = (
		local templist = getUserProp target #wwmt_attachmentlist
		if templist != undefined AND templist != "" then (
			for word in (filterString templist ",") do(
				append attachmentlist word
			)
			sort attachmentlist
			makeAttachmentListFromCust()
		)
		if attachments.count > 0 then (
			for att in attachments do (
				att.sendValueToAtPoint()
			)
			target.attachments = for att in attachments WHERE isValidNode (att.atPoint) collect att.atPoint
		)
	),
	function getAttachmentList = (
		for att in attachments WHERE isValidNode (att.atPoint) collect att.attachment
	),

	function setAttListCust = (
		if target != undefined then (
			s = ""
			iteration = 1
			for so in attachments do (
				if iteration > 1 then (
					append s ","
				)
				append s so.attachment
				iteration = iteration + 1
			)
			setUserProp target #wwmt_attachmentlist s
		)
	),
	function addToAttachments so = (
		if so != undefined AND isValidNode so.atPoint then (
			local existing = for s in target.attachments WHERE s.name == so.attachment collect s
			if existing.count == 0 then (
				target.addAttachment obj:so.atPoint
				append attachments so
			)
		)
	),
	function addToAttachmentList s = (
		if s != undefined AND isValidNode s.atPoint then (
			target.addAttachment obj:s.atPoint
		)
		target.sanitizeAttachments()
	),
	function removeAttachment t = (
		for s in target.attachments WHERE s.name == t do (
			target.removeAttachment s
		)
		target.sanitizeAttachments()
	),
	function setAttAbsolute t mp = (
		local notf = true
		for s in attachments while notf do (
			if s.attachment == t then (
				s.absolute = mp
				s.setAttachment()
				notf = false
			)
		)
	),
	function setAttRigid t mp = (
		local notf = true
		for s in attachments while notf do (
			if s.attachment == t then (
				s.rigid = mp
				s.setAttachment()
				notf = false
			)
		)
	),
	function setAttBone t bn = (
		local notf = true
		for s in attachments while notf do (
			if s.attachment == t then (
				s.pb = bn
				if t == "" then (
					s.atPoint.parent = targets[1]
					s.setAttachment()
					notf = false
				) else (
					b = getNodeByName s.pb
					if isValidNode b then (
						s.atPoint.parent = b
						--print b.name
					) else (
						s.atPoint.parent = targets[1]
					)
				)
				s.setAttachment()
				notf = false
			)
		)
	),
	function createNewAttachment absolute:false rigid:false label:"attachment" pb:undefined asBone:false = (
		local att = wwmt_attachment()
		att.absolute = absolute
		att.rigid = rigid

		if (isValidNode pb) then (
			bonestartpos = in coordsys world pb.transform.translationPart
		) else (
			bonestartpos = in coordsys world targets[1].transform.translationPart
		)
		if asBone == true then (
			att.atPoint = (BoneSys.createBone bonestartpos (bonestartpos + [4, 0, 0]) [0, 0, 1])
			attachementBone.showLinks = true
			attachementBone.showLinksOnly = true
			bone_size = 2
			attachementBone.width = bone_size
			attachementBone.height = bone_size
			--attachementBone.transform = bone_transform
			attachementBone.boneEnable = true
			attachementBone.name = (uniqueName(Label))
		) else (
			att.atPoint = Point name:(uniqueName(Label)) pos:bonestartpos isSelected:on cross:on box:on size:20 Color:green axistripod:on drawontop:on size:4
		)
		global wallworm_attachment_CA
		custAttributes.add att.atPoint wallworm_attachment_CA

		att.attachment = att.atPoint.name
		att.pb = pb

		if (isValidNode pb) then (
			att.atPoint.parent = pb
		) else (
			att.atPoint.parent = targets[1]
		)

		att.setAttachment()
		att.setAsWWMTAttachment()

		if isValidNode target then (
			append target.attachments att.atPoint
		)
		append attachments att
		att
	),
	function setExpType t mp = (
		local notf = true
		for s in sequences while notf do (
			if s.sequence == t then (
				s.type = mp
				setSeqListCust()
				notf = false
			)
		)
	),
	function setExpStart t mp = (
		local notf = true
		for s in sequences while notf do (
			if s.sequence == t then (
				s.start = mp
				setSeqListCust()
				notf = false
			)
		)
	),
	function setExpEnd t mp = (
		local notf = true
		for s in sequences while notf do (
			if s.sequence == t then (
				s.end = mp
				setSeqListCust()
				notf = false
			)
		)
	),
	function setExpReverse t mp = (
		local notf = true
		for s in sequences while notf do (
			if s.sequence == t then (
				s.expReverse = mp
				setSeqListCust()
				notf = false
			)
		)
	),
	function setLoop t mp = (
		notf = true
		for s in sequences while notf do (
			if s.sequence == t then (
				s.loop = mp
				setSeqListCust()
				notf = false
			)
		)
	),
	function setModelName mn shout:false = (
		if mn != "" then (
			modelName = wallworm_makeStringSafe mn
			--add check for invalid characters
			if isValidNode target then (
				target.modelName = modelName
			)
		) else (
			if shout then (
				messageBox "This model has no name. Please give the model a name."
			)
		)
	),
	function setExpHL1Format mp = (
		expHL1Format = wallworm_makeBoolean mp def:false
		if target != undefined then (
			setUserProp target #wwmt_expHL1Format (expHL1Format as String)
		)
	),
	function setExpSequenceName t mp = (
	),
	function setModelPath mp = (
		modelPath = wallworm_remove_last_slash (wallworm_safe_path mp)
		if target != undefined then (
			target.modelPath = modelPath
			setUserProp target #wwmt_modelPath modelPath
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),
	function setMaterialPath mp = (
		materialPath = wallworm_remove_last_slash (wallworm_safe_path mp)

		if target != undefined then (
			target.materialPath = materialPath
			setUserProp target #wwmt_materialPath materialPath
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),
	function setInertia m = (
		inertia = m as Float
		target.inertia = inertia
		setUserProp target #wwmt_inertia m
	),
	function setRotDamping m = (
		rotDamping = m as Float
		target.rotDamping = rotDamping
		setUserProp target #wwmt_rotDamping m
	),
	function setdamping m = (
		damping = m as Float
		target.damping = damping
		setUserProp target #wwmt_damping m
	),
	function setPhdrag m = (
		if m != undefined then (
			phdrag = m as Float
			target.phdrag = phdrag
			setUserProp target #wwmt_phdrag m
		)
	),
	function setContents m = (
		if m != undefined then (
			contents = m
			target.contents = m
			setUserProp target #wwmt_contents m
		)
	),
	function setMass m = (
		if m != undefined then (
			mass = m as Float
			target.mass = mass
			setUserProp target #wwmt_mass m
		)
	),
	function setScale m = (
		if m == undefined OR m == "" then (
			m = 1.0
		)
		mscale = m as Float
		target.mscale = mscale
		setUserProp target #wwmt_scale m
	),
	function setUVW m = (
		if m == undefined then (
			m = ::wwmt_mappingChannel as Integer
		)
		mapChannel = m
		target.mapChannel = m as Integer
		setUserProp target #wwmt_mapChannel m
	),
	function setConstantdirectionallight m = (
		if m != undefined then (
			constantdirectionallight = m
			target.constantdirectionallight = m
			setUserProp target #wwmt_constantdirectionallight m
		)
	),
	function setAmbientboost mp = (
		ambientboost = mp
		target.ambientboost = mp
		if mp == true then (
			setUserProp target #wwmt_ambientboost "true"
		) else (
			setUserProp target #wwmt_ambientboost "false"
		)
	),
	function setLock mp = (
		if target != undefined then (
			locked = mp
			target.locked = mp
			if mp == true then (
				setUserProp target #wwmt_lock "true"
			) else (
				setUserProp target #wwmt_lock "false"
			)
		)
	),
	function setNoselfcollisions mp = (
		noselfcollisions = mp
		if isValidNode target then (
			target.noselfcollisions = mp
			if mp == true then (
				setUserProp target #wwmt_noselfcollisions "true"
			) else (
				setUserProp target #wwmt_noselfcollisions "false"
			)
		)
	),
	function setAutoHull mp = (
		autoHull = mp
		if isValidNode target then (
			target.autoHull = mp
			if mp == true then (
				setUserProp target #wwmt_autoHull "true"
			) else (
				setUserProp target #wwmt_autoHull "false"
			)
		)
	),
	function setLocalOrigin mp = (
		useLocalOrigin = mp

		if isValidNode target then (
			target.useLocalOrigin = mp
			if mp == true then (
				setUserProp target #wwmt_useLocalOrigin "true"
			) else (
				setUserProp target #wwmt_useLocalOrigin "false"
			)
		)
	),
	function setRotateRefsystem mp = (
		if target != undefined then (
			rotateRefsystem = mp
			if isValidNode target then (
				target.rotateRefsystem = mp
				if mp == true then (
					setUserProp target #wwmt_rotateRefsystem "true"
				) else (
					setUserProp target #wwmt_rotateRefsystem "false"
				)
			)
		)
	),
	function setinternalOrigin mp = (
		if target != undefined then (
			internalOrigin = mp
			target.internalOrigin = mp
			if mp == true then (
				setUserProp target #wwmt_internalOrigin "true"
			) else (
				setUserProp target #wwmt_internalOrigin "false"
			)
		)
	),
	function setJointConstraints mp = (
		if (isValidNode target) AND (mp == true OR mp == false) then (
			jointConstraints = mp
			target.jointConstraints = mp
		)
	),
	function setConcave mp = (
		if isValidNode target then (
			concave = mp
			target.concave = mp
			if mp == true then (
				setUserProp target #wwmt_concave "true"
			) else (
				setUserProp target #wwmt_concave "false"
			)
		)
	),
	function setNormalMethod sp = (
		normalMethod = sp
		if isValidNode target then (
			target.normalMethod = sp
			setUserProp target #wwmt_normalmethod (sp as String)
		) else (
			--messagebox "Please choose a model before changing any export settings."
		)
	),
	function setSurfaceProperty sp = (
		if sp == undefined then (
			sp = ""
		)
		surfaceprop = sp
		target.surfaceprop = sp
		if isValidNode target then (
			setUserProp target #wwmt_surfaceprop sp
		) else (
			messageBox "Please choose a model before changing any export settings."
		)

	),
	function setStaticprop mp = (
		if isValidNode target then (
			staticprop = mp
			target.staticprop = mp
			if mp == true then (
				setUserProp target #wwmt_staticprop "true"
			) else (
				setUserProp target #wwmt_staticprop "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),

	function setShadowlod mp = (
		if isValidNode target then (
			shadowlod = mp
			--target.shadowlod = shadowlod
			if mp == true then (
				setUserProp target #wwmt_shadowlod "true"
			) else (
				setUserProp target #wwmt_shadowlod "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),

	function setOpaque mp = (
		if isValidNode target then (
			opaque = mp
			target.opaque = opaque
			if mp == true then (
				setUserProp target #wwmt_opaque "true"
			) else (
				setUserProp target #wwmt_opaque "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),
	function setAltOrigin mp = (
		if isValidNode target then (
			altOrigin = mp
			target.altOrigin = altOrigin
			if mp == true then (
				setUserProp target #wwmt_altOrigin "true"
			) else (
				setUserProp target #wwmt_altOrigin "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),

	function setAutomass mp = (
		if isValidNode target then (
			automass = mp
			target.automass = automass
			if mp == true then (
				setUserProp target #wwmt_automass "true"
			) else (
				setUserProp target #wwmt_automass "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),

	function setMostlyOpaque mp = (
		if isValidNode target then (
			mostlyopaque = mp
			target.mostlyopaque = mostlyopaque
			if mp == true then (
				setUserProp target #wwmt_mostlyopaque "true"
			) else (
				setUserProp target #wwmt_mostlyopaque "false"
			)
		) else (
			messageBox "Please choose a model before changing any export settings."
		)
	),

	function fetchFromTarget obj = (
	),
	function createSelectionSets = (
		modelSetName = "wwmt_Models_" + target.name
		--selectionSets[modelSetName] = targets
		-- setUserProp target #wwmt_modelSetName  modelSetName
		--physSetName = "wwmt_Phys_"+target.name
		--setUserProp target #wwmt_physSetName  physSetName
	),

	function makeLOD i obj percent rename &wwmt updateui:true = (
		newLod = ww_lod()
		newLod.wrapper = wwmt
		--assign the LOD level to the LOD for use later in functions to find the right LOD
		newLod.level = i
		newLod.newMR makeNew:true
		if obj == target then (
			for sr in targets do (
				if ::wwmt_refLOD == true then (
					newItem = reference sr
				) else (
					newItem = copy sr
				)
				setUserPropBuffer newItem ""
				if ::wwmt_LODOptimize != 3 AND newLod.mr != undefined then (
					addModifier newItem newLod.mr
				)
				if rename == undefined then (
					newItem.name = sr.name + "_LOD" + i as String
				)
				--lock LOD transforms
				setTransformLockFlags newItem #all
				newItem.position.controller = sr.position.controller
				newItem.rotation.controller = sr.rotation.controller
				newItem.scale.controller = sr.scale.controller
				append newLod.items newItem
			)
		) else (
			append newLod.items obj
			newLod.findFirstMod()
		)

		newLod.setGizmo(toValue)
		newLod.res = percent
		newLod.setCustomAttributes()
		ww_SetObjLayer newItem layer
		ww_SetObjLayer newLod.helperGizmo layer
		newLod.helperGizmo.radius = 50 * i
		if(lods.count >= i) then (
			lods[i] = newLod
		) else (
			lods = append lods newLod
		)
		if updateui then (
			select newLod.helperTape
			if ::wwToolsFloater != undefined then (
				local selStr
				try (
					selStr = "wwToolsFloater.rollouts[4].pickLOD" + i as String + ".caption = ww_scene_lods.lods[" + i as String + "].item.name"
					execute selStr as String
				) catch ()
				try (
					selStr = "wwToolsFloater.rollouts[4].btnPickLOD" + i as String + "Helper.enabled = true"
					execute selStr as String
					selStr = "wwToolsFloater.rollouts[4].btnViewLOD" + i as String + ".enabled = true"
					execute selStr as String

					selStr = "wwToolsFloater.rollouts[4].spnLOD" + i as String + ".enabled = true"
					execute selStr as String

					selStr = "wwToolsFloater.rollouts[4].addSelLOD" + i as String + ".enabled = true"
					execute selStr as String

					selStr = "wwToolsFloater.rollouts[4].appendLOD" + i as String + ".enabled = true"
					execute selStr as String
					n = i + 1
					if n < ::wwmt_lodLimit then (
						selStr = "wwToolsFloater.rollouts[4].pickLOD" + n as String + ".enabled = true"
						execute selStr as String
					)
				) catch()
			)
		)
		newLod
	),
	function selectItems = (
		for so in items do (
		)

	),
	function updateLegacyProxies = (
		p = for proxy in objects WHERE (getUserProp proxy #wwmt_proxie_source == target.name) collect proxy
	),
	function getLegacyLODS = (
		/*
		Used to get LOD values from before WW 2.05
		*/
		for lodl = 1 to ::wwmt_lodLimit do (
			local lodstr = "wwmt_LOD" + lodl as String
			local lodname = getUserProp target lodstr
			if (lodname != undefined) then (
				local lodObject = getNodeByName lodname
				if isValidNode lodObject then (
					lods[lodl] = ww_lod()
					lods[lodl].wrapper = wwmt
					lods[lodl].level = lodl
					--lods[lodl].items[1] = lodObject
					templist = getUserProp lodObject #wwmt_lodlist
					if templist != undefined then (
						for word in (filterString templist ",") do(
							n = getNodeByName word
							if (isValidNode n) then (
								append lods[lodl].items n
								--print n.name
							)
						)
					)
					local lodhelperPoint = getUserProp lodObject #wwmt_LOD_Point_Helper
					if lodhelperPoint != undefined then (
						helperObj = getNodeByName lodhelperPoint
						if helperObj != undefined then (
							lods[lodl].helperTape = helperObj
							--print "helper pointer assigned"
						)
					)
					local lodGizmo = getUserProp lodObject #wwmt_LOD_Gizmo
					if lodGizmo != undefined then (
						gizmoObj = getNodeByName lodGizmo
						if gizmoObj != undefined AND classOf gizmoObj == Sphere then (
							lods[lodl].helperGizmo = gizmoObj
							paramWire.disconnect lods[lodl].helperGizmo.baseObject[#Radius]
						)
					)
					modName = target.name + "_LOD_" + lodl as String + "_MultiRes"
					for m in lodObject.modifiers do (
						if (classOf m == MultiRes OR classOf m == ProOptimizer) AND m.name == modName then (
							lods[lodl].mr = m
							lods[lodl].res = lods[lodl].mr.vertexPercent
						)
					)
					if lods[lodl].res == undefined then (
						lods[lodl].res = wwmt_vertexPercentages[lodl]
					)
					if lods[lodl].helperGizmo == undefined OR lods[lodl].helperTape == undefined then (
						lods[lodl].setGizmo lodl
					) else (
						lods[lodl].makeMatShell()
					)
					lods[lodl].setCustomAttributes()
				)
			) else (
				--deleteItem lods lodl
			)
		)
	),

	function setTargetModel obj &wwmt recurse:false skipSequencesIfPresent:true updateCA:true = (
		if ::wallworm_EULA != true then (
			messageBox "The Wall Worm EULA has not been agreed to."
			fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
			false
		) else if isValidNode obj then (
			local startObj = obj

			if classOf obj == XRefObject then (
				local o1 = obj.GetSourceObject true
				if isValidNode o1 then (
					obj = o1 
					isXref = true
				)
			)
			init()
			createWWMT = false
			if isProperty obj #wwmt_ca then (
				/*This is a WWMT 2.0+ object*/
				createWWMT = false
				target = obj
			) else (
				sname = getUserProp obj #wwmt_proxie_source
				if sname != undefined then (
					target = getNodeByName sname
					if ((NOT isValidNode target) OR target == obj) then (
						createWWMT = true
					) else (
						/*This is a WWMT Proxie*/
						createWWMT = false
					)
				) else (
					helperVal = getUserProp obj #wwmt_source_helper
					if helperVal != undefined then (
						/*This is a WWMT 1.0 object*/
						target = obj
						createWWMT = false
					) else (
						createWWMT = true
					)
				)
			)
			if createWWMT == true then (
				isset = true

				/*
				Get globals for default values in new WWMT object
				*/

				target = Text text:"WWMT:" size:50 Color:blue
				custAttributes.add target wallworm_model_tools_CA
				setModelName(obj.name)
				target.name = uniqueName ("wwmt_" + modelName + "_")
				target.parent = obj
				target.pos.x = obj.pos.x
				target.pos.y = (obj.pos.y + 100)
				target.pos.z = obj.pos.z
				setUserProp target #wwmt_source_helper true
				--setUserProp obj #wwmt_source  target.name
				setStaticprop staticprop
				setNormalMethod normalMethod

				rotateRefsystem = ::wwmt_rotateRefsystem as BooleanClass
				setRotateRefsystem rotateRefsystem

				setinternalOrigin internalOrigin
				useLocalOrigin = ::wwmt_use_local_origin as BooleanClass

				setLocalOrigin useLocalOrigin
				setUVW(::wwmt_mappingChannel)

				--make a name for a layer for this object	
				layer = "WWMT Layer " + target.name

				local mPath = getINISetting ::wallworm_userIni "Directories" "def_model_path"
				local maPath = getINISetting ::wallworm_userIni "Directories" "def_material_path"

				if mPath != undefined AND mPath != "" then (
					setModelPath mPath
				)

				if maPath != undefined AND maPath != "" then (
					setMaterialPath maPath
				)
				addObjToObjects obj recurse:true
				ww_SetObjLayer obj layer
				--createIlluminationHelper()

				true
			) else (
				--create the info from the obj
				if NOT isProperty target #wwmt_ca then (
					global wallworm_model_tools_CA
					custAttributes.add target wallworm_model_tools_CA

					/*Get Params from legacy WWMT where the following properties were stored in userprop data. Now stored in a custom attribute.*/

					local exclude = wallworm_makeBoolean (getUserProp target #wallworm_exclude_vmf) def:false
					target.exclude_vmf = exclude

					local sk = wallworm_makeBoolean (getUserProp target #wwdt_skybox_export) def:false
					target.skybox = sk

					physname = getUserProp target #wwmt_phys_copy
					modelName = (getUserProp target #wwmt_modelname) as String
					if modelName == undefined then (
						modelName = "modelname"
					)
					if physname != undefined then (
						physObj = getNodeByName (physname as String)
						if physObj != undefined then (
							phys = physObj
							massobjname = getUserProp target #wwmt_mass_helper
							if massobjname != undefined then (
								massoriginObj = getNodeByName (massobjname as String)
								if massoriginObj != undefined AND classOf massoriginObj == Point then (
									massorigin = massoriginObj
								)
							)

							if massorigin != undefined then (
								masscenter = massorigin.controller.position
							) else (
								masscenter = [0, 0, 0]
							)

						)
					)

					local temphulls = getUserProp target #wwmt_hulllist
					if temphulls != undefined then (
						for word in (filterString (temphulls as String) ",") do(
							n = getNodeByName word
							if isValidNode n then (
								append hulls n
							)
						)
						target.hulls = hulls
					)

					materialPath = (getUserProp target #wwmt_materialPath) as String
					modelPath = (getUserProp target #wwmt_modelPath) as String
					surfaceprop = (getUserProp target #wwmt_surfaceprop) as String

					staticprop = wallworm_makeBoolean (getUserProp target #wwmt_staticprop) def:false
					opaque = wallworm_makeBoolean (getUserProp target #wwmt_opaque) def:false
					mostlyopaque = wallworm_makeBoolean (getUserProp target #wwmt_mostlyopaque) def:false
					mass = getUserProp target #wwmt_mass
					altOrigin = wallworm_makeBoolean (getUserProp target #wwmt_altOrigin) def:false
					automass = wallworm_makeBoolean (getUserProp target #wwmt_automass) def:false
					concave = wallworm_makeBoolean (getUserProp target #wwmt_concave) def:false
					useLocalOrigin = wallworm_makeBoolean (getUserProp target #wwmt_useLocalOrigin) def:true
					internalOrigin = wallworm_makeBoolean (getUserProp target #wwmt_internalOrigin) def:true
					noselfcollisions = wallworm_makeBoolean (getUserProp target #wwmt_noselfcollisions) def:false
					animatedfriction = getUserProp target #wwmt_animatedfriction
					mapChannel = (getUserProp target #wwmt_mapChannel)

					if mapChannel == undefined then (
						mapChannel = ::wwmt_mappingChannel
					)
					mapChannel = mapChannel as Integer
					mscale = getUserProp target #wwmt_scale

					morphasvta = wallworm_makeBoolean (getUserProp target #wwmt_morphasvta) def:true
					ambientboost = getUserProp target #wwmt_ambientboost
					constantdirectionallight = getUserProp target #wwmt_constantdirectionallight

					contents = getUserProp target #wwmt_contents
					inertia = getUserProp target #wwmt_inertia
					damping = getUserProp target #wwmt_damping
					phdrag = getUserProp target #wwmt_phdrag
					rotDamping = getUserProp target #wwmt_rotDamping
					jointConstraints = getUserProp target #wwmt_jointConstraints
					autoHull = getUserProp target #wwmt_autoHull

					locked = wallworm_makeBoolean (getUserProp target #wwmt_lock) def:false

					base = getUserProp target #wwmt_base
					health = getUserProp target #wwmt_health
					allowstatic = getUserProp target #wwmt_allowstatic
					physicsmode = getUserProp target #wwmt_physicsmode
					blockLOS = getUserProp target #wwmt_blockLOS
					AIWalkable = getUserProp target #wwmt_AIWalkable
					dmg_bullets = getUserProp target #wwmt_dmg_bullets
					dmg_club = getUserProp target #wwmt_dmg_club
					dmg_explosive = getUserProp target #wwmt_dmg_explosive
					ignite = getUserProp target #wwmt_ignite
					explosive_resist = getUserProp target #wwmt_explosive_resist
					flammable = getUserProp target #wwmt_flammable
					explosive_damage = getUserProp target #wwmt_explosive_damage
					breakable_model = getUserProp target #wwmt_breakable_model
					breakable_count = getUserProp target #wwmt_breakable_count
					breakable_skin = getUserProp target #wwmt_breakable_skin
					multiplayer_break = getUserProp target #wwmt_multiplayer_break
					explosive_radius = getUserProp target #wwmt_explosive_radius
					fadetime = getUserProp target #wwmt_fadetime
					motiondisabled = getUserProp target #wwmt_motiondisabled
					normalMethod = getUserProp target #wwmt_normalmethod
					if normalMethod == undefined then (
						normalMethod = 1
					)

					shaderType = getUserProp target #wwmt_shader
					if shaderType == undefined then (
						shaderType = "VertexLitGeneric"
					)

					lockInitialOrigin = wallworm_makeBoolean (getUserProp target #wwmt_lockInitialOrigin) def:false
					local rotateRefsystem = wallworm_makeBoolean (getUserProp target #wwmt_rotateRefsystem) def:false

					local tempgibslist = getUserProp target #wwmt_gibslist
					if tempgibslist != undefined then (
						for word in (filterString (tempgibslist as String) ",") do (
							n = getNodeByName word
							if (isValidNode n) then (
								appendGibs n
							)
						)
					)

					illumobjname = getUserProp target #wwmt_illumination_helper
					if illumobjname != undefined then (
						illumoriginObj = getNodeByName illumobjname
						if illumoriginObj != undefined AND classOf illumoriginObj == Point then (
							illumorigin = illumoriginObj
						)

					)

					camobjname = getUserProp target #wwmt_cam
					if camobjname != undefined then (
						camObj = getNodeByName camobjname
						if (camObj != undefined AND (classOf camObj == targetCamera OR classOf camObj == freeCamera)) then (
							cam = camObj
							setCamChangeHandler()
						)
					)

					templist = getUserProp target #wwmt_targetslist
					if templist != undefined then (
						for word in (filterString (templist as String) ",") do(
							n = getNodeByName word
							if isValidNode n then (
								if findItem target.targets n == 0 then (
									append target.targets n
								)
								append targets n
							)
						)
					)

					templist = getUserProp target #wwmt_sequencelist
					if templist != undefined then (
						for word in (filterString templist ",") do(
							append sequencelist word
						)
						sort sequencelist
						makeSequenceListFromCust getFromOld:true
					)

					getLegacyLODS()
					setLegacyAttachments()
					setWWMTAttribFromThis()
					--target.updateWWMTFromThis()

				) else (
					/*
					Get properties from WWMT Custom Attribute added in WWMT 2.0		

					if (needsUpdatedCA()== true ) then (
						free target.mainrollout
						free target.hullrollout
						free target.propdatarollout 
						free target.attachrollout
						free target.otherParamsRollout
						free target.proxrollout
						free target.vmfparamsrollout 
						--free target.wwmt

					)	

					*/
					if (needsUpdatedCA()) == true AND updateCA == true then (
						wallworm_update_wwmt_cas target
					)
					getParamsFromWWMTAttrib()

				)

				if lods.count > 0 then (
					for l in lods do (
						l.wrapper = this
					)
				)

				/*These are all properties that are still stored in the node UserProp. Eventually all will be moved to the WWMT CA.*/
				getParticleSystems()
				idleSequence = wallworm_makeBoolean (getUserProp target #wwmt_idleSequence) def:true
				modelSetName = getUserProp target #wwmt_modelSetName
				physSetName = getUserProp target #wwmt_physSetName
				shadowlod = wallworm_makeBoolean (getUserProp target #wwmt_shadowlod) def:false
				if isProperty target #sequences AND target.sequences.count > 0 then (
					makeSequenceListFromCust()
				)
				templist = getUserProp target #wwmt_weightlists
				if templist != undefined then (
					for word in (filterString templist ",") do (
						append weightlistnames word
						--print word
					)
					sort weightlistnames
					makeWeightListFromCust()
				)

				expHL1Format = wallworm_makeBoolean (getUserProp target #wwmt_expHL1Format) def:false --probably should remove this as only works with Wunderboy's SMD Exporter
				if isProperty target #updateMyName then (
					target.updateMyName()
				)
				true
			)
		) else (
			format "This is not a valid Node: %\n" obj
			false
		)
	),
	function createIlluminationHelper = (
		illuminationName = target.name + "_illuminationorigin"
		setUserProp target #wwmt_illumination_helper illuminationName
		if isValidNode targets[1] then (
			helperpos = targets[1].pos
		) else (
			helperpos = target.pos
		)
		illumorigin = Point name:illuminationName pos:helperpos Box:on centermarker:on cross:off axistripod:off wirecolor:yellow size:64
		illumorigin.parent = targets[1]
		target.illumorigin = illumorigin
		ww_SetObjLayer illumorigin layer
		illumorigin
	),
	function createMassHelper = (
		massName = target.name + "_massorigin"
		setUserProp target #wwmt_mass_helper massName
		oldmassorigin = getNodeByName massName
		if isValidNode oldmassorigin then (
			delete oldmassorigin
		)
		if isValidNode targets[1] then (
			helperpos = targets[1].pos
		) else (
			helperpos = target.pos
		)
		massorigin = Point name:massName pos:helperpos Box:on centermarker:on cross:off axistripod:off wirecolor:blue size:64
		target.massorigin = massorigin
		massorigin.parent = targets[1]
		ww_SetObjLayer massorigin layer
		massorigin
	),
	function makeLodsArray toValue &wwmt = (
		max select none

		if toValue == undefined then (
			toValue = 1
		)
		--get the layer associated with this function
		llayer = ww_CreateLayer layer
		wwmt_vertexPercentages = #(75, 56.25, 42.1875, 31.6406, 23.73, 17.7975, 13.348, 10.0111, 7.5083, 5.6312)
		--loop to make new ww_lod objects; makes as many LODs as are in the spinner value
		for i = 1 to toValue by 1 do (
			makeLOD i target wwmt_vertexPercentages[i] undefined wwmt
		)
	),
	function hideCM = (
		its = for so in hulls WHERE isValidNode so collect so
		if its.count > 0 then (
			hide its
		)
	),
	function showCM = (
		its = for so in hulls WHERE isValidNode so collect so
		if its.count > 0 then (
			unhide its
		)
	),

	function unhideLod i = (
		its = for so in lods[i].items WHERE isValidNode so collect so
		if its.count > 0 then (
			unhide its
		)

	),
	function hideLod i = (
		its = for so in lods[i].items WHERE isValidNode so collect so
		if its.count > 0 then (
			hide its
		)

	),
	function selectSelectionSets i = (
		select lods[i].items

	),

	function setLod level obj &wwmt alertMessage:true = (
		if lods[level] == undefined then (
			newLod = ww_lod()

			newLod.wrapper = wwmt
			newLod.level = level

			newLod.newMR()
			newLod.setGizmo (64 * level)

			lods[level] = newLod

		) else (
			newLod = lods[level]

		)

		if ::wwmt_autoMaterialNewModel == true AND obj.material == undefined then (
			obj.material = getMainMaterial matname:("VMT_" + modelName + "_" + obj.name)

		)

		append newLod.items obj
		newLod.setCustomAttributes()

		l
	),
	function makeLodGroup = (
		message = "This function is disabled in the current version of WWMT."
		messageBox message
	),

	function processPhys = (
		try (
			wwmt_applyWWMTHullMaterial(phys)

			ww_SetObjLayer phys layer
		) catch()
	),
	function appendHull obj = (
		local res = true
		if classOf obj == ObjectSet then (
			for i in obj while res == true do (
				if (isValidNode i == false) then (
					res = false
				)
			)
		) else (
			if (isValidNode obj == false) then (
				res = false
			)
		)
		if res then (
			if findItem target.hulls obj == 0 then (
				if (append target.hulls obj) == true then (
					wwmt_applyWWMTHullMaterial(obj)
					ww_SetObjLayer obj layer
				)
			)
			if target.hulls != undefined AND target.hulls.count > 0 then (
				autoHull = false
				setAutoHull false
			)
			hulls = makeUniqueArray (target.hulls as Array)
		)
		res
	),

	function tieToTargetPosition obj = (
		paramWire.connect targets[1].pos.controller[#X_Position] obj.pos.controller[#X_Position] "X_Position"
		paramWire.connect targets[1].pos.controller[#Y_Position] obj.pos.controller[#Y_Position] "Y_Position"
		paramWire.connect targets[1].pos.controller[#Z_Position] obj.pos.controller[#Z_Position] "Z_Position"
		paramWire.connect2way targets[1].rotation.controller[#X_Rotation] obj.rotation.controller[#X_Rotation] "X_Rotation" "X_Rotation"
		paramWire.connect2way targets[1].rotation.controller[#Y_Rotation] obj.rotation.controller[#Y_Rotation] "Y_Rotation" "Y_Rotation"
		paramWire.connect2way targets[1].rotation.controller[#Z_Rotation] obj.rotation.controller[#Z_Rotation] "Z_Rotation" "Z_Rotation"

	),
	function addPhysModel obj = (
		local res = true
		if isValidNode obj == false then (
			res = false

		) else (
			originalName = obj.name
			if phys != undefined then (
				if (isValidNode phys) then (
					oldName = getUserProp phys #wwmt_original_name
				) else (
					oldName = ""
				)
				if oldName != undefined AND oldName != "" then (
					phys.name = oldName
				) else (
					try (
						oldName = oldPhys.name + "_old"
						phys.name = oldName
					) catch()
				)

			)

			--if copyTarget == "true" OR obj == targets[1] then (
			if (findItem targets obj) != 0 then (
				phys = copy obj
				convertTo phys Editable_Poly

				newPhysName = target.name as String
				newPhysName += "_hull"
				phys.name = newPhysName
			) else (
				phys = obj
			)

			setUserProp obj #wwmt_phys_copy phys.name
			setUserProp target #wwmt_phys_copy phys.name
			setUserProp phys #wwmt_phys_source obj.name
			setUserProp phys #wwmt_target target.name
			setUserProp phys #wwmt_original_name originalName
			processPhys()
			res = appendHull(phys)
		)
		res
	),
	function addAHull obj = (
		if target.hulls.count == 0 then (
			addPhysModel obj
		) else (
			appendHull obj
		)
	),
	function removeItemFromHulls obj = (
		local ind = findItem target.hulls obj
		if ind > 0 then (
			deleteItem target.hulls ind
		)
		hulls = target.hulls as Array
	),
	function removeItemsFromHulls sel = (
		for obj in sel WHERE isValidNode obj do (
			removeItemFromHulls(obj)
		)
	),
	function canCompile type = (
		local can = false
		case type of (
			"tex":(
				if materialPath == undefined OR materialPath == "" then (
					can = false
				) else (
					can = (::wallworm_engine == 1 OR (wallworm_binSet type == true))
				)
			)
			"model":(
				if modelPath == undefined OR modelPath == "" then (
					can = false
				) else (
					can = (wallworm_binSet type == true)
				)
			)
			default:(can = false)
		)
		can
	),
	function populateBodyGroups = (
		bodygroups = #()
		global ww_wwmt_bodygroup
		if ww_wwmt_bodygroup == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_bodygroup.ms")
		)
		if isValidNode target AND target.children.count > 0 then (
			for c in target.children do (
				local hp = ww_wwmt_bodygroup()
				hp.setHelper c --refNode:(getRefNode())
				if hp.bgmodels.count > 0 then (
					append bodygroups hp
				)
			)
		)
	),
	function exportBodyGroups tempRefNode:undefined = (
		-- !TODO ... add code to exclude exporting SMDs that were already exported
		if bodygroups.count > 0 then (
			--if tempRefNode == undefined then (
			tempRefNode = getRefNode()
			--)
			--local tempRefNode = Box pos:referenceNode.pos

			for b in bodygroups do (
				for m in b.bgmodels WHERE isValidNode m AND m != target do (
					if findItem alreadyExported m == 0 then (
						m.getWWMT()
						m.wwmt.alreadyExported = join m.wwmt.alreadyExported alreadyExported

						if findItem alreadyExported m.wwmt.target == 0 then (
							m.wwmt.sequences = join m.wwmt.sequences sequences

							m.wwmt.resetBonesArray()

							m.wwmt.modelPath = modelPath
							--m.wwmt.setRefNode n:(getRefNode())
							--m.wwmt.offsetFaces = true
							m.wwmt.staticprop = false
							m.wwmt.useLocalOrigin = useLocalOrigin
							m.wwmt.internalOrigin = internalOrigin
							m.wwmt.rotateRefsystem = rotateRefsystem

							if isValidNode referenceNode then (
								m.wwmt.referenceNode = tempRefNode
							)
							/*if useLocalOrigin == false then (
							) else (
								m.wwmt.getRefNode()
							)*/
							m.wwmt.outputModelQC resetExportList:false forceBoneReset:false

							alreadyExported = join alreadyExported m.wwmt.alreadyExported
							appendIfUnique alreadyExported m.wwmt.target
						)

					)
				)

			)

			--delete tempRefNode

		)

	),

	function getBodygroupMats = (
		matstring = ""

		if isValidNode target AND target.mat != undefined AND classOf target.mat == MultiMaterial then (
			t = "$texturegroup \"" + modelName + "_skins\"\r\n{\r\n\r\n"
			append matstring t

			for m in target.mat.materialList do (
				if m != undefined then (
					/*
					if classOf m == Standard AND m.diffuseMap != undefined AND classOf m.diffuseMap == BitmapTexture AND m.diffuseMap.filename != undefined then (
						skinName = getFilenameFile m.diffuseMap.filename
						if getFileNameType m.diffuseMap.filename == ".ifl" then (
							append skinName "0"
						)
					) else (
						skinName = m.name
					)
					*/

					if classOf m == MultiMaterial then (
						skinName = ""
						for m2 in m.materialList do (
							if m2 != undefined then (
								skinName += " \"" + (wallworm_getMaterialName m2 forModel:true) + "\""

							)

						)

					) else (
						skinName = " \"" + (wallworm_getMaterialName m forModel:true) + "\""
					)

					t = " { " + skinName + " }\r\n"
					append matstring t

				)
			)
			t = "\r\n}\r\n"
			append matstring t
		)
		matstring
	),

	function getOnlyBonesList meshlist bonelist = (
		local theOnlyBones = #()
		for b in bonelist do (
			if findItem meshlist b == 0 then (
				append theOnlyBones b
			)
		)
		theOnlyBones
	),

	function export_sequence s wwDir:undefined resetBnArray:true explist:undefined = (
		if resetBnArray then (
			resetBonesArray()
		)

		if wwDir == undefined then (
			local mp = FsToBs modelPath

			local wwDir = ::wwmt_export + "\\" + mp
		)

		if ::wwmtExporter >= 3 then (
			if explist == undefined then (
				explist = #()
				join explist (targets as Array)

				if bonesarray.count > 0 then (
					join explist (bonesarray as Array)
				)
			)

		) else (
			clearNodeSelection()
			select targets

			if bonesarray.count > 0 then (
				selectMore (bonesarray as Array)
			)
		)

		fr = s.fps as String

		if dmx == true AND ::WallwormProActive == true then (
			fileExt = ".dmx"
		) else (
			fileExt = ".smd"
		)

		seqname = modelName + "_sequence_" + s.sequence
		--seqname = s.sequence

		local fname = wwDir + "\\" + seqname + fileExt

		if ::wwmtExporter >= 3 then (
			--use WWMT MXS SMD Exporter
			local smd = wallwormSMD()
			smd.usePro = (::WallwormProActive == true AND (::wwmtExporter == 4 OR dmx == true))
			smd.type = "Sequence"
			if dmx == true AND ::WallwormProActive == true then (
				smd.outtype = "dmx"
				smd.sequenceName = seqname
			)
			smd.uvwchannel = mapChannel
			smd.range = #()
			smd.upaxis = upaxis
			if s.end == s.start then (
				append smd.range s.start

			) else (
				local sequenceDir = 1

				if s.end < s.start then (
					sequenceDir = -1
				)
				for r = s.start to s.end by sequenceDir do (
					append smd.range r
				)

			)

			if (::wallworm_engine == 1) then (
				smd.hl1 = true
			) else (
				smd.hl1 = false
			)

			smd.makeNodeList explist
			smd.nonRenderableAsBone = exportNonRenderableMeshAsBone
			--smd.refNode = getRefNode()
			smd.refNode = getRefNode()
			smd.offsetFaces = offsetFaces
			--smd.refNode = targets[1]
			smd.normalMethod = normalMethod
			smd.origin = useLocalOrigin
			smd.staticprop = staticprop
			smd.normalMethod = normalMethod
			smd.internalOrigin = internalOrigin
			smd.rotateRefsystem = rotateRefsystem
			if lockInitialOrigin != undefined AND lockInitialOrigin == true then (
				smd.lockInitialOrigin = lockInitialOrigin
				/*local locksys = smd.refNode.transform
				locksys = rotateZMatrix -90 * locksys
				smd.initialReFSystem = locksys
				locksys = undefined*/
			)
			smd.flip = altOrigin

			smd.exportSMD fname

		) else (
			if ::wwmtExporter == 2 then (
				ExportSMD fname true false false false false (s.start as String) (s.end as String)
			) else (
				if useOldWBS == false then (
					local hl1 = 0
					if ::wallworm_engine == 1 then (hl1 = 1)
					if WBSMDExportVersionNum() < 1700 then (
						status = WBSMDExport fname true 1 hl1 s.start s.end false false false exportNonRenderableMeshAsBone
					) else(
						status = WBSMDExport fname true 1 hl1 (mapChannel as Integer) s.start s.end false false false exportNonRenderableMeshAsBone
					)
				) else (
					try(
						refInt = 1
						setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Type" (refInt as String)
						setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Start" (s.start as String)
						setINISetting "$plugcfg/smdexp.ini" "Batch Config" "End" (s.end as String)
						setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Reverse" (s.expReverse as String)

						if ::wallworm_engine == 1 then (
							setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" "1"
						) else (
							setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" "0"
						)
					) catch(
						noPlugWrite = true
					)
					exportFile fname #noPrompt selectedOnly:true using:SMDExporter
					--print "USED OLD for Sequence"

				)
			)
		)
		fname
	),

	function exportSMDS resetBnArray:true runCompile:true expBody:true expSeq:true expHull:true expLOD:true expVTA:true expModels:true allboneNodes:undefined = (
		local failed = 0

		if allboneNodes == undefined then (
			if staticprop then (
				allboneNodes = #(targets[1])
			) else (
				allboneNodes = sortArrayByHeirarchy (getAllbonesArray())
			)
		)
		local makeSMDs = true
		if ::wwmtExporter < 3 then (
			--WW & WWPro don't need this check
			theClasses = exporterPlugin.classes
			makeSMDs = false
			for c in theClasses while makeSMDs == false do (
				--is Jed's Exporter Selected and Installed
				if ::wwmtExporter == 1 AND c == SMDExporter then (
					makeSMDs = true
				)
				--is Cannonfodder's Exporter Selected and Installed
				if ::wwmtExporter == 2 AND c == SmdExport then (
					makeSMDs = true
				)
			)
		)
		local exportNotice = StringStream ""
		local mp = FsToBs modelPath
		local wwDir = ::wwmt_export + "\\" + mp

		if makeSMDs == true then (
			makeSMDs = doesFileExist wwDir

			if NOT makeSMDs then (
				makeSMDs = makeDir wwDir all:true
			)
		)

		if (makeSMDs == true) then (
			max select none

			shouldUpdateSMDExporter = false
			noPlugWrite = false
			exportNonRenderableMeshAsBone = ::wwmt_exportNonRenderableMeshAsBone
			local useOldWBS = true
			if ::wwmtExporter == 1 then (
				try(
					if WBSMDExportVersionNum() >= 1600 then (
						useOldWBS = false
					)
					if WBSMDExportVersionNum() < 1700 then (
						shouldUpdateSMDExporter = true
					)
				) catch(
					useOldWBS = true
					shouldUpdateSMDExporter = true
				)
			)

			local explist = #()
			local tempRefNode = getRefNode()
			local meshAndBones = #()

			join meshAndBones (targets as Array)
			if bonesarray.count > 0 then (
				join meshAndBones (bonesarray as Array)
			)

			if ::wwmtExporter >= 3 then (
				explist = meshAndBones

			) else (
				clearNodeSelection()
				select meshAndBones

			)

			if dmx == true AND ::WallwormProActive == true then (
				fileExt = ".dmx"
			) else (
				fileExt = ".smd"
			)
			local hl1 = 0
			if (::wallworm_engine == 1) then (hl1 = 1)

			local fname = wwDir + "\\" + modelName + fileExt

			--added because some mods/installs of Steam won't create the dir when compiling
			if (makeDir (::wwmt_gameInfoDir + "\\models\\" + mp) all:true) == true then (
				--print ("created " + (::wwmt_gameInfoDir + "\\models\\"+mp) )
			)

			local mainbonelist = getOnlyBonesList targets allboneNodes

			local morphObjs = getMorphObjs()

			join mainbonelist morphObjs
			/*
			if hulls.count > 0 then (
				join mainbonelist  (getOnlyBonesList targets hulls)
			) 

			if hullbonesarray.count > 0 then (
				join mainbonelist  (getOnlyBonesList targets hullbonesarray)
			) */

			mainbonelist = makeUniqueArray mainbonelist

			if expModels == true then (
				for m in target.models do (
					local mww = m.getWWMT()
					mww.exportSMDS resetBnArray:false runCompile:false expBody:true expSeq:false expHull:false expLOD:false expVTA:true expModels:true allboneNodes:allboneNodes
				)
			)

			if expBody == true then (
				if ::wwmtExporter >= 3 then (
					--use WWMT MXS SMD Exporter

					local smd = wallwormSMD()
					if dmx == true AND ::WallwormProActive == true then (
						smd.outtype = "dmx"
						if isProperty target #attachmentsInDMX AND target.attachmentsInDMX == true then (
							smd.attachments = target.attachments
						)
					)
					smd.usePro = (::WallwormProActive == true AND (::wwmtExporter == 4 OR dmx == true))
					smd.uvwchannel = mapChannel
					/*
					expArray = #()
					join expArray bonesarray
					join expArray targets
					*/
					if (::wallworm_engine == 1) then (
						smd.hl1 = true
					) else (
						smd.hl1 = false
					)
					smd.upaxis = upaxis
					smd.justBones = mainbonelist
					smd.makeNodeList meshAndBones

					smd.nonRenderableAsBone = exportNonRenderableMeshAsBone
					smd.refNode = tempRefNode
					--smd.refNode = tempRefNode
					smd.origin = useLocalOrigin
					smd.staticprop = staticprop
					smd.offsetFaces = offsetFaces
					smd.normalMethod = normalMethod
					smd.internalOrigin = internalOrigin
					smd.rotateRefsystem = rotateRefsystem
					smd.flip = altOrigin

					smd.collapsemesh = alwaysCollapse
					smd.range = #(0)

					smd.exportSMD fname

					/*
					if lockInitialOrigin != undefined AND lockInitialOrigin == true then (
						local locksys = smd.refNode.transform
						locksys = rotateZMatrix -90 * locksys

					)

					*/
					if ::wallworm_debug == true then (
						::wallworm_smd_debug = smd
					)

				) else (
					if ::wwmtExporter == 2 then (
						ExportSMD fname true true false false false "" ""
					) else (
						if useOldWBS == false then (
							if WBSMDExportVersionNum() < 1700 then (
								status = WBSMDExport fname true 0 hl1 0 0 false false false exportNonRenderableMeshAsBone
							) else (
								--print ("Using 1700 with map channel: " + (mapChannel as String))
								status = WBSMDExport fname true 0 hl1 (mapChannel as Integer) 0 0 false false false exportNonRenderableMeshAsBone

							)
							--print "USED NEW for mesh"
							--print status
						) else (
							--print (getCurrentException())
							try(
								setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Type" "0"
								setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Start" "0"
								setINISetting "$plugcfg/smdexp.ini" "Batch Config" "End" "0"
								setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Reverse" "0"
								if (::wallworm_engine == 1) then (
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" "1"
								) else (
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" "0"
								)
							) catch(
								noPlugWrite = true
							)

							exportFile fname #noPrompt selectedOnly:true using:SMDExporter
							--print "USED OLD"

						)
					)
				)

				format "# Target Model Exported to %\n" fname to:exportNotice
			)

			if expVTA == true AND staticprop == false AND areMorphs() == true AND morphasvta == true then (
				exportVTAs (exportNonRenderableMeshAsBone)
			)
			if expLOD then (
				for l in lods do (
					if ::wwmtExporter >= 3 then (
						local explist = #()
						join explist (l.items as Array)

						if bonesarray.count > 0 then (
							join explist (bonesarray as Array)
						)

					) else (
						clearNodeSelection()
						select l.items
						if bonesarray.count > 0 then (
							selectMore (bonesarray as Array)
						)
					)

					fname = wwDir + "\\" + modelName + "_LOD_" + l.level as String + fileExt

					if ::wwmtExporter >= 3 then (
						--use WWMT MXS SMD Exporter
						local smd = wallwormSMD()
						if dmx == true AND ::WallwormProActive == true then (
							smd.outtype = "dmx"
						)
						if (::wallworm_engine == 1) then (
							smd.hl1 = true
						) else (
							smd.hl1 = false
						)
						smd.usePro = (::WallwormProActive == true AND (::wwmtExporter == 4 OR dmx == true))
						smd.uvwchannel = mapChannel
						smd.makeNodeList explist
						smd.nonRenderableAsBone = exportNonRenderableMeshAsBone
						--smd.refNode = getRefNode()
						smd.refNode = tempRefNode
						smd.offsetFaces = offsetFaces
						smd.range = #(0)
						--smd.refNode = targets[1]
						smd.origin = useLocalOrigin
						smd.staticprop = staticprop
						smd.normalMethod = normalMethod
						smd.internalOrigin = internalOrigin
						smd.rotateRefsystem = rotateRefsystem
						smd.flip = altOrigin
						smd.justBones = getOnlyBonesList l.items bonesarray
						smd.collapsemesh = alwaysCollapse
						smd.upaxis = upaxis
						if (smd.exportSMD fname) then (
							format "# LOD Level % Exported to %\n" l.level fname to:exportNotice

						) else (
							format "# LOD Level % Failed to Export\n" l.level to:exportNotice
						)

					) else (
						if ::wwmtExporter == 2 then (
							ExportSMD fname true true false false false "" ""
						) else (
							if useOldWBS == false then (
								if WBSMDExportVersionNum() < 1700 then (
									status = WBSMDExport fname true 0 hl1 0 0 false false false exportNonRenderableMeshAsBone
								) else (
									status = WBSMDExport fname true 0 hl1 (mapChannel as Integer) 0 0 false false false exportNonRenderableMeshAsBone
								)
								--print "USED NEW for LOD"
							) else (
								try(
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Type" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Start" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "End" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Reverse" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" (expHL1Format as String)
								) catch(
									noPlugWrite = true
								)
								exportFile fname #noPrompt selectedOnly:true using:SMDExporter
							)
						)
					)

				)
			)

			if ::wallworm_engine == 1 AND (staticprop == true OR idleSequence == true) then (
				local s = wwmt_sequence()
				s.sequence = "idle"
				s.start = 0
				s.end = 0
				s.makeSMD = true
				local spath = export_sequence s wwDir:wwDir resetBnArray:false explist:meshAndBones
			)

			if staticprop == false AND expSeq == true then (
				for s in sequences WHERE (s.makeSMD == true OR s.asAnimation == true) do (
					local spath = export_sequence s wwDir:wwDir resetBnArray:false explist:meshAndBones
					format "# Sequence % Exported to %\n" s.sequence spath to:exportNotice
				)
			)

			/*Begin Export Hulls*/

			if expHull == true AND hulls.count > 0 AND (autoHull != true) then (
				if ::wwmtExporter >= 3 then (
					local explist = #()
					join explist (targets as Array)
					join explist (hulls as Array)

					if bonesarray.count > 0 then (
						join explist (bonesarray as Array)
					)
					if hullbonesarray.count > 0 then (
						join explist (hullbonesarray as Array)
					)
					explist = makeUniqueArray explist

				) else (
					clearNodeSelection()
					select hulls
					if hullbonesarray.count > 0 then (
						selectMore (bonesarray as Array)
					)
					if hullbonesarray.count > 0 then (
						selectMore (hullbonesarray as Array)
					)
				)

				local fname = wwDir + "\\" + modelName + "_hull" + fileExt

				if ::wwmtExporter >= 3 then (
					--use WWMT MXS SMD Exporter
					local smd = wallwormSMD()
					if dmx == true AND ::WallwormProActive == true then (
						smd.outtype = "dmx"
					)
					smd.usePro = (::WallwormProActive == true AND (::wwmtExporter == 4 OR dmx == true))
					smd.uvwchannel = mapChannel
					if (::wallworm_engine == 1) then (
						smd.hl1 = true
					) else (
						smd.hl1 = false
					)
					smd.collapsemesh = alwaysCollapse
					smd.collapsetoParent = true

					/*
					local limitedTriangles = #()
					limitedTriangles = join limitedTriangles (targets as array)
					limitedTriangles = join limitedTriangles (bonesarray as array)
					smd.limitBones = makeUniqueArray limitedTriangles /**/

					local justBonesH = (getOnlyBonesList hulls hullbonesarray)
					local justBones = join justBonesH (getOnlyBonesList hulls bonesarray)
					local justBonesT = getOnlyBonesList hulls targets
					justBones = makeUniqueArray (join justBones justBonesT)
					smd.justBones = justBones
					smd.makeNodeList explist

					smd.nonRenderableAsBone = exportNonRenderableMeshAsBone
					--smd.refNode = getRefNode()
					smd.refNode = tempRefNode
					smd.offsetFaces = offsetFaces
					--smd.refNode = targets[1]
					smd.origin = useLocalOrigin
					smd.staticprop = staticprop
					smd.normalMethod = normalMethod
					smd.internalOrigin = internalOrigin
					smd.rotateRefsystem = rotateRefsystem
					smd.flip = altOrigin
					smd.range = #(0)
					smd.upaxis = upaxis
					smd.exportSMD fname

					format "\n# Phys Model Exported to %\n" fname to:exportNotice
				) else (
					try (
						if ::wwmtExporter == 2 then (
							ExportSMD fname true true false false false "" ""
						) else (
							if useOldWBS == false then (
								if WBSMDExportVersionNum() < 1700 then (
									status = WBSMDExport fname true 0 hl1 0 0 false false false exportNonRenderableMeshAsBone
								) else (
									status = WBSMDExport fname true 0 hl1 (mapChannel as Integer) 0 0 false false false exportNonRenderableMeshAsBone
								)
								--print status
								--print "USED NEW for Hull"
							) else (
								try(
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Type" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Start" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "End" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "Reverse" "0"
									setINISetting "$plugcfg/smdexp.ini" "Batch Config" "HL1Format" (expHL1Format as String)
								) catch(
									noPlugWrite = true
								)

								exportFile fname #noPrompt selectedOnly:true using:SMDExporter
								--print "OLD for hull"
							)
						)
						format "\n# Phys Model Exported to %\n" fname to:exportNotice
					) catch (
						print (getCurrentException())

						format "\nThe collision model DID NOT EXPORT due to an error!" to:exportNotice
						failed = failed + 1
					)

				)

			)
			/*End Export Hulls*/

			if ::wwmtExporter == 1 AND noPlugWrite == true then (
				if (useOldWBS == true) then (
					--exportNotice+= "\n\nBecause your plugcfg folder is not writable, the batch format function did not work--that is why you had to confirm all the export dialogues."
					format "\n\nBecause your plugcfg folder is not writable, the batch format function did not work--that is why you had to confirm all the export dialogues." to:exportNotice

				) else (
					try(
						deleteFile "$plugcfg/smdexp.ini"
					) catch ()
				)

				if shouldUpdateSMDExporter == true then (
					format "\n\nYou may not be using the latest SMD Exporter. You should update the SMD Exporter to Version 1.7. Please visit www.wunderboy.org." to:exportNotice
				)
			)

			format (exportNotice as String)
			if wwmtCompileMessage == true OR wwmtCompileMessage == "true" then (
				messageBox (exportNotice as String)
			)

			exportBodyGroups tempRefNode:tempRefNode

			if doesFileExist (wwDir + "\\" + modelName + ".bat") == true then (
				local newBatch = openFile (wwDir + "\\" + modelName + ".bat") mode:"w"
			) else (
				local newBatch = createFile(wwDir + "\\" + modelName + ".bat")
			)

			format "@echo on\r\n" to:newBatch

			--local bt = "cd \""+::wwmt_binDir+">\"\r\n" 
			format "REM Compiling using the Wall Worm Batch File...\r\n" to:newBatch
			local gameInfoParam = ""

			if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
				gameInfoParam = " -game \"" + ::wwmt_gameInfoDir + "\""

			)

			if ::wallworm_engine != 1 then (
				if ::wwmt_hull_limit_handling == 3 AND theRealHullCount != undefined AND theRealHullCount > 20 then (
					append gameInfoParam " -fullcollide"
				)

				append gameInfoParam " -nop4"

			)

			bt = "\"" + ::wwmt_binDir + "\studiomdl.exe\"" + gameInfoParam + " \"" + wwDir + "\\" + modelName + ".qc\"\r\n"
			format bt to:newBatch
			format "@pause\r\n" to:newBatch

			try (
				close newBatch
				free newBatch
				flush newBatch
			) catch ()

			-- 2012 initial release maxVersion() = #(14000, 38, 0)

			if ((maxVersion())[1] == 14000) then (
				newBatch = openFile (wwDir + "\\" + modelName + ".bat")
				seek newBatch #eof
				maxlen = filepos newBatch
				seek newBatch 0
				res = readChars newBatch maxlen errorAtEOF:false
				try (
					close newBatch
					free newBatch
					flush newBatch
				) catch ()
				(DotNetClass "System.IO.File").WriteAllText (wwDir + "\\" + modelName + "_2012.bat") res

			)

			if (runCompile == true AND ::wwmtAutoCompile == true AND failed == 0) then (
				if ((maxVersion())[1] == 14000) then (
					compileBatStr = wwDir + "\\" + modelName + "_2012.bat"
				) else (
					compileBatStr = wwDir + "\\" + modelName + ".bat"
				)

				if findItem alreadyExported target == 0 then (
					shellLaunch compileBatStr ""
				)

			)

			--)

			if ::wwmtAutoOpenFolder == "true" then (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + wwDir + "\""
				execute folderOpen
			)

			true
		) else (
			false
		)
	),
	/*
	This function gets all the objects associated with the model
	*/
	function collectAllObjects = (
		local c = for i in targets collect i
		for l in lods do (
			if l.helperGizmo != undefined AND isDeleted l.helperGizmo == false then (
				append c l.helperGizmo
			)
			join c l.items
		)
		append c target
		if target.children != undefined AND target.children.count > 0 then (
			join c target.children
		)
		if hulls.count > 0 then (
			join c hulls
		)
		try(
			if gibs.count > 0 then (
				for g in gibs do (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					if (tempWWMT.setTargetModel g tempWWMT) then (
						if (tempWWMT.isset == true) then (
							setChildGibs tempWWMT
						)
						tempWWMT.populateBodyGroups()
						join c (tempWWMT.collectAllObjects())
					)

				)

			)

		) catch (
			print (getCurrentException())
		)
		populateBodyGroups()
		if bodygroups.count > 0 then (
			for b in bodygroups do (
				for i in b.bgmodels do (
					i.populateMyMaterials()
					join c (i.collectAllObjects())
				)
			)
		)
		c
	),

	function populateMyMaterials = (
		materials = #()
		getNameFromPath = false
		local forceOpaque = false
		if opaque != undefined AND opaque == true AND ::wwmt_forceOpaqueFromModel == true then (
			forceOpaque = true
		)

		for i in targets do (
			wallworm_appendBitmaps i.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
		)

		for eye in target.eyeballs do (
			wallworm_appendBitmaps eye.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
		)

		for l in lods WHERE l != undefined do (
			if (l.testForExport l.helperGizmo.mat) == true then (
				wallworm_appendBitmaps l.helperGizmo.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
			)
		)
		if isValidNode target AND target.mat != undefined AND classOf target.mat == MultiMaterial then (
			wallworm_appendBitmaps target.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
		)
		try(
			if gibs.count > 0 then (
				for g in gibs WHERE isValidNode g do (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel g tempWWMT
					if (tempWWMT.isset == true) then (
						setChildGibs tempWWMT
					)
					tempWWMT.populateMyMaterials()
					local forceOpaque = false
					if tempWWMT.opaque == true AND ::wwmt_forceOpaqueFromModel == true then (
						forceOpaque = true
					)
					for im in tempWWMT.materials do (
						wallworm_appendBitmaps im.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
					)
				)
			)
		) catch (
			print (getCurrentException())
		)
		populateBodyGroups()
		if bodygroups.count > 0 then (
			for b in bodygroups do (
				for i in b.bgmodels do (
					i.getWWMT()
					i.wwmt.populateMyMaterials()
					local forceOpaque = false
					if i.opaque == true AND ::wwmt_forceOpaqueFromModel == true then (
						forceOpaque = true
					)
					for im in i.wwmt.materials do (
						wallworm_appendBitmaps im.mat materials valveShader getNameFromPath:false forModel:true materialPath:materialPath forceOpaque:forceOpaque
					)
				)
			)
		)
	),

	function createCustomQCI = (
		local qcistr = modelName + "_wwmt_custom.qci"
		if modelPath != undefined then (
			local m = FsToBs modelPath
			wwDir = ::wwmt_export + "\\" + m
			qcistr = wwDir + "\\" + modelName + "_wwmt_custom.qci"
			if NOT doesFileExist wwDir then (
				makeDir wwDir all:true
			)
			if doesFileExist wwDir then (
				if doesFileExist (wwDir + "\\" + modelName + "_wwmt_custom.qci") == false then (
					local CustomQCFile = createFile(wwDir + "\\" + modelName + "_wwmt_custom.qci")
					format "//File for injecting custom rules. Safe to edit. Do not delete.\r\n\r\n" to:CustomQCFile
					try (
						close CustomQCFile
						free CustomQCFile
						flush CustomQCFile
					) catch ()
				)
			)
		)
		qcistr
	),

	function outputModelQC resetExportList:true writeSMDs:true runCompile:true forceBoneReset:true allboneNodes:undefined = (
		--resetExportList will clear the alreadyExported array at the end of the method if true
		local out = false --return value
		if dmx == true AND ::WallwormProActive == true then (
			fileExt = ".dmx" -- this should not really happen yet but if someone tampers they might get this. But as of this moment, the results will fail.
		) else (
			fileExt = ".smd"
		)
		local smdInQCfileExt = fileExt

		if (::wallworm_engine == 1) then (
			smdInQCfileExt = ""
		)

		setRefNode()

		with redraw off
		(
			if allboneNodes == undefined then (
				if staticprop then (
					allboneNodes = #(targets[1])
				) else (
					allboneNodes = sortArrayByHeirarchy (getAllbonesArray())
				)
			)

			--currentSel = getCurrentselection()
			local exportNotice = ""
			--try (
			local errors = #()

			for t in targets do (
				if NOT isValidNode t then (
					deleteItem targets (findItem targets t)
				) else (
					if isGroupHead t == false then (
						if t.material == undefined AND superClassOf t == GeometryClass AND classOf t != BoneGeometry then (
							if ::wwmt_autoMaterialNewModel == true AND t.material == undefined then (
								t.material = getMainMaterial()
							) else (
								append errors "The model has meshes with no material. Please add a standard material with a Bitmap in the diffuse slot to each mesh in your model."
							)
						)
					)
				)
			)

			if checkForRenderableMesh() == false then (
				append errors "You have the Export Non-renderable Mesh as Bone option turned on in the WW Settings. All of your meshes are non-renderable... so no mesh data can be exported."
			)

			local missingUVW = checkForUVWData()
			if missingUVW.count > 0 then (
				append errors "One or more of the meshes are missing UVW data. At the moment, the Wunderboy SMD Exporter will fail if you do not have UVW data for every vertex on a mesh. The objects with missing UVW data have been selected for you."
				select missingUVW
			)

			if targets.count == 0 then (
				append errors "The model has no meshes currently assigned. Check that the base objects are Renderable if you have the global setting to export non-renderable meshes as bones."
			)

			for h in hulls do (
				if NOT isValidNode h then (
					deleteItem hulls (findItem hulls h)
				) else(
					if h.material == undefined then (
						wwmt_applyWWMTHullMaterial h
						append errors "The collision model has meshes with no material. Please add a standard material with a Bitmap in the diffuse slot to each mesh in your collision model."
					)
				)
			)

			local m = FsToBs modelPath
			wwDir = ::wwmt_export + "\\" + m

			if (makeDir wwDir all:true) == false then (
				append errors ("The Path you want to export to does not exist. Please make sure to create the following path.:\n\n" + wwDir)
			)
			resetBonesArray()

			if staticprop != undefined AND NOT staticprop then (
				local finalbonearray = #()
				join finalbonearray targets
				join finalbonearray bonesarray
				finalbonearray = makeUniqueArray finalbonearray
				if (finalbonearray.count > 128) then (
					--make this a notice rather than an error because bones can be set to skip, merge, etc.
					print "The bone count exceeded the compile limit of 128 bones. Reduce the number of nodes and bones in this model if you have problems."
					--append errors ("The bone count exceeded the compile limit of 128 bones. Reduce the number of nodes and bones in this model if you have problems.")
				)
				finalbonearray = undefined
				if rotateRefSystem == true then (
					--append errors ("The Rotate Origin setting should not be turned on except for $staticprop models. This model is not set as $staticprop.")
				)

			)

			if errors.count > 0 then (
				message = "There were problems.\n\n"

				for er in errors do (
					message += er + "\n"

				)
				enableSceneRedraw()
				messageBox message
				if missingUVW.count > 0 then (
					missingUVW = undefined
					max tool hlist
				)

				out = false
			) else (
				local theRealHullCount = 0
				local mp = BsToFs modelPath
				local doWriteQC = true
				local QCExists = doesFileExist(wwDir + "\\" + modelName + ".qc")

				if locked == true then (
					if (QCExists == true) then (
						doWriteQC = false
						exportNotice += "** The QC was not written because it already existed and this model has Lock QC turned on. If you want to overwrite the QC, you must rename it, delete it or turn off this model's QC Lock.\n\n"
					)
				) else (
					if doWriteQC == true AND (QCExists == true) then (
						if (::wwmt_overWriteQC == false OR ::wwmt_overWriteQC == "false") then (
							doWriteQC = false
							exportNotice += "** The QC was not written because it already existed. If you want to overwrite the QC, you must rename it, delete it or turn on QC Over-writing in the WWMT Settings.\n\n"
						) else (
							exportNotice += "** The exisitng QC was over-written. If you do not want to overwrite existing QCs, turn off QC Over-writing in the WWMT Settings or lock the QC with the Lock QC option.\n\n"
						)
					)

				)

				if doWriteQC == true then (
					local canWriteQC
					try (
						if QCExists == true then (
							local NewQC = openFile (wwDir + "\\" + modelName + ".qc") mode:"w"
						) else (
							local NewQC = createFile(wwDir + "\\" + modelName + ".qc")
						)
						canWriteQC = true
					) catch (
						messageBox ("The exporter cannot create " + wwDir + "\\" + modelName + ".qc . Please check that the path to that file is writable.")
						canWriteQC = false
						out = false

					)

					if canWriteQC then (
						getRefOrientation()
						if ::wallworm_engine > 1 then (
							format "// QC File generated by the Wall Worm Model Tools Version %\r\n" ::ww_wwmt_version to:NewQC
							
							local mfp = maxFilePath 
							local mfn = maxFileName
							if mfn == "" then (
								mfn = "Unsaved File"
							)
							
							format "// Exported From: %%\r\n" mfp mfn to:NewQC
							format "// Get the latest version and notes at:\r\n" to:NewQC
							format "// http://dev.wallworm.com \r\n\r\n" to:NewQC
						)
						if mscale != undefined then (
							format "$scale %\r\n" mscale to:NewQC
						)
						if upaxis == 2 then (
							format "$upaxis \"Y\"\r\n"  to:NewQC
						)
						
						if (::wallworm_engine == 1) then (
							local fullpath = (::wwmt_gameInfoDir + "/" + mp + "/" + modelName)
							if (NOT doesFileExist (fullpath)) then (
								makeDir fullpath all:true
							)
							format "$modelname	\"%/models/%/%.mdl\"\r\n" ::wwmt_gameInfoDir mp modelName to:NewQC
						) else (
							format "$modelname	\"%/%.mdl\"\r\n" mp modelName to:NewQC
						)

						--and staticprop == true
						if (useLocalOrigin == true) then (
							if (::wwmtExporter >= 3 AND internalOrigin == true) then (
								--don't add the $origin line

							) else (
								if altOrigin == undefined then (
									altOrigin = false
								)

								local calcpost = targets[1].transform.position

								yval = abs calcpost.y
								xval = abs calcpost.x

								if (altOrigin == true) then (
									/*Alt (flip)*/
									zRotationVal = "-180"
									if calcpost.x < 0 then (
										xval = xval * -1
									)

									if calcpost.y < 0 then (
										yval = yval * -1
									)
								) else (
									zRotationVal = "0"

									if calcpost.x > 0 then (
										xval = xval * -1
									)

									if calcpost.y > 0 then (
										yval = yval * -1
									)
								)

								if staticprop == true then (
									calcpost.z *= -1
									if (::wwmtExporter >= 3) then (
										t = "$origin " + (formattedPrint (yval * -1) format:".16g") + " " + (formattedPrint (xval) format:".16g") + " " + (formattedPrint calcpost.z format:".16g") + " " + zRotationVal as String + " \r\n"
									) else (
										t = "$origin " + (formattedPrint xval format:".16g") + " " + (formattedPrint yval format:".16g") + " " + (formattedPrint calcpost.z format:".16g") + " " + zRotationVal as String + " \r\n"
									)

								) else (
									if rotateRefsystem == false then (
										xval = xval * -1
										yval = yval * -1
										t = "$origin " + (formattedPrint (xval) format:".16g") + " " + (formattedPrint (yval) format:".16g") + " " + (formattedPrint calcpost.z format:".16g") + " " + zRotationVal as String + " \r\n"
									) else (
										t = "$origin " + (formattedPrint (yval * -1) format:".16g") + " " + (formattedPrint (xval) format:".16g") + " " + (formattedPrint calcpost.z format:".16g") + " " + zRotationVal as String + " \r\n"
									)
								)
								format t to:NewQC
							)
						)

						populateBodyGroups()
						if bodygroups.count > 0 then (
							if staticprop == true then (
								exportNotice += "** A model with bodygroups cannot have the $staticprop flag. The model was temporarily changed to not have $staticprop for the export.\r\n"
							)
							staticprop = false
						)

						if (::wallworm_engine == 1) then (
							format "$cd \"%%%\"\r\n" ::wwmt_export "\\" modelPath to:NewQC
						)

						if staticprop == true AND (::wallworm_engine != 1) then (
							format "$staticprop\r\n" to:NewQC
						) else (
							if collapsebones == true then (
								format "$collapsebones\r\n" to:NewQC
							)

							local hasPutRoot = false
							for b in allbonenodes do (
								if isProperty b #wallworm_bone_CA then (
									if b.useBoneProps then (
										if NOT hasPutRoot AND b.root == true then (
											format "$root \"%\"\r\n" b.name to:NewQC
											hasPutRoot = true
										)

										if b.definebone == true then (
											local pname = ""
											if isValidNode b.parent then (
												pname = b.parent.name
											)
											local pos = in coordsys parent b.pos
											format "$definebone \"%\" \"%\" % % % 0 0 0 0 0 0 0 0 0\r\n" b.name pname (wallworm_fix_tiny_float pos.x) (wallworm_fix_tiny_float pos.y) (wallworm_fix_tiny_float pos.z) to:NewQC
										)

									)
								)
							)
							local eyePosition = target.eyeposition
							if isValidNode eyePosition then (
								local eyepos
								if useLocalOrigin == true then (
									eyepos = in coordsys refSystem eyePosition.position
								) else (
									eyepos = in coordsys parent eyePosition.position
								)
								if distance eyepos [0, 0, 0] > 1 then (
									format "$eyeposition % % % \r\n" (wallworm_fix_tiny_float eyepos.x) (wallworm_fix_tiny_float eyepos.y) (wallworm_fix_tiny_float eyepos.z) to:NewQC
								)
							)
						)

						if opaque == true then (
							format "$opaque\r\n" to:NewQC
						)
						if ::wallworm_engine != 1 then (
							if mostlyopaque == true then (
								format "$mostlyopaque\r\n" to:NewQC
							)
						)

						if (isValidNode illumorigin) then (
							local illumPos
							if useLocalOrigin == true then (
								illumPos = in coordsys refSystem illumorigin.position
							) else (
								illumPos = in coordsys parent illumorigin.position
							)
							if distance illumPos [0, 0, 0] > 1 then (
								format "$illumposition % % % \r\n" (wallworm_fix_tiny_float illumPos.x) (wallworm_fix_tiny_float illumPos.y) (wallworm_fix_tiny_float illumPos.z) to:NewQC
							)
						)

						if ambientboost != undefined AND (ambientboost == 1 OR ambientboost == true) then (
							format "$ambientboost\r\n" to:NewQC
						)

						if constantdirectionallight != undefined then (
							format "$constantdirectionallight %\r\n" constantdirectionallight to:NewQC
						)

						local morphObjs = getMorphObjs()
						/*
						Flex Models
						*/
						if staticprop != true AND (morphasvta == true AND areMorphs() == true) OR target.models.count > 0 OR target.includes.count > 0 then (
							for obj in morphObjs do (
								local objName = obj.name
								local modobjname = modelName + "_" + objName

								if dmx == true AND ::WallwormProActive == true then (
									format "$model % \"%_flex.dmx\" {\r\n}\r\n" modobjname modobjname to:NewQC
								) else (
									flexQC = (modobjname + "_wwmt_flex.qci")
									if doesFileExist (wwDir + "\\" + flexQC) == true then (
										local flexQCFile = openFile (wwDir + "\\" + flexQC) mode:"w"
									) else (
										local flexQCFile = createFile(wwDir + "\\" + flexQC)
									)
									--append qci (flexQC)		

									format "//File generated by WWMT for flex. DO NOT EDIT/DELETE THIS FILE as it will alwasy get over-written when exported in WWMT.\r\n\r\n//If you need to edit the flex rules, use the \"%_wwmt_flex_custom.qci\" file\r\n\r\n\r\n	defaultflex frame 0\r\n" modelName to:flexQCFile
									local flexnames = getVTAFlexnames obj
									for fns in flexnames do (
										format "	flex \"%\" frame %\r\n" fns[1] fns[2] to:flexQCFile
									)
									try (
										close flexQCFile
										free flexQCFile
										flush flexQCFile
									) catch ()
									--flex "AU42" frame 5		// eyes	half_closed

									local customQCIFNAme = wwDir + "\\" + modobjname + "_wwmt_flex_custom.qci"
									if doesFileExist (customQCIFNAme) == false then (
										local flexCustomQCFile = createFile(customQCIFNAme)
										format "//File for injecting custom flex data. Safe to edit. Do not delete.\r\n\r\n" to:flexCustomQCFile
										try (
											--some versions of Max lock the file or have other errors and cannot properly close/free/flush
											close flexCustomQCFile
											free flexCustomQCFile
											flush flexCustomQCFile
										) catch(
											print "You should close Max and download the latest service pack for 3ds Max as it has problems with closing files."
										)
									)

									flexcontroller = StringStream ""
									format "\tflexcontroller wwmt_flex_controller_% " objName to:flexcontroller
									flexlist = StringStream ""
									fnum = 0
									for fns in flexnames do (
										if fns[1] != undefined then (
											local controllername = wallworm_makeStringSafe fns[1]
											/* append flexcontroller (" \""+controllername+"\"")
											append flexlist ("\%"+controllername+" = "+controllername+"\n")*/
											format "\t\"%\"" controllername to:flexcontroller
											format "\t\%% = %\r\n" controllername controllername to:flexlist
										)
									)
									in coordsys parent (
										for eye in target.eyeballs WHERE isValidNode eye AND classOf eye == Sphere AND eye.parent == obj do (
											local pos = eye.position

											local eyeMat = wallworm_getMaterialName eye.mat matId:1 forModel:true
											local irisMat = wallworm_getMaterial eye.mat matId:2 forModel:true
											local irisMatName = wallworm_getMaterialName eye.mat matId:2 forModel:true
											local irisAngle = 2
											local irisScale = 0.66
											if (classOf irisMat == Standard AND isProperty irisMat #diffuseMap AND isProperty irisMat.diffuseMap #coords) then (
												irisAngle = irisMat.diffuseMap.coords.V_Angle
												irisScale = 1.0 / irisMat.diffuseMap.coords.V_Tiling
											)

											format "\teyeball % % % % % % % % % %\r\n" eye.name objName pos.x pos.y pos.z eyeMat (eye.radius * 2) irisAngle irisMatName irisScale to:flexlist

										)
									)

									format "\r\n\r\n%" (flexlist as String) to:flexcontroller

									format "$model % \"%_flex.smd\" {\r\n\r\n\tflexfile \"%_flex.vta\" {\r\n\t\t$include\t\"%\"\r\n\t\t$include\t\"%_wwmt_flex_custom.qci\"\r\n\t}\r\n%\r\n}\r\n" modobjname modobjname modobjname flexQC modobjname (flexcontroller as String) to:NewQC

								)

							)

							--use complex $model format
							format "$model % \"%%\"\r\n" modelName modelName smdInQCfileExt to:NewQC

							for obj in target.models do (
								local objName = obj.modelName
								format "$model % \"%%\"\r\n" objName objName smdInQCfileExt to:NewQC
							)
							for obj in target.includes do (
								format "$includemodel \"%/%.mdl\"\r\n" obj.modelPath obj.modelName to:NewQC
							)

						) else (
							--use simpler body format
							format "$body % \"%%\"\r\n" modelName modelName smdInQCfileExt to:NewQC
						)

						populateBodyGroups()
						bodygroupNum = 1
						if bodygroups.count > 0 then (
							for b in bodygroups do (
								format "$bodygroup %\r\n{\r\nblank\r\n" b.bgname to:NewQC
								for m in b.bgmodels do (
									format "studio \"%%\"\r\n" m.modelName fileExt to:NewQC
								)
								format "}\r\n" to:NewQC
							)
						)

						local cmtype
						if (hulls.count > 0 OR (autoHull != undefined AND autoHull == true)) then (
							if (staticprop == true) then (
								cmtype = "$collisionmodel"
							) else (
								resetHullBonesArray()

								if ((hullbonesarray.count > 0) OR hulls.count > 1) then (
									cmtype = "$collisionjoints"
								) else (
									cmtype = "$collisionmodel"
								)

							)
							if (autoHull == true) then (
								format "% \"%%\" {\r\n" cmtype modelName fileExt to:NewQC
							) else(
								format "% \"%_hull%\" {\r\n" cmtype modelName fileExt to:NewQC
							)

							if(concave == true) then (
								if cmtype == "$collisionmodel" then (
									format "$concave\r\n" to:NewQC
								)

								theRealHullCount = wwmt_count_hulls hulls true
								if ::wwmt_hull_limit_handling == 2 AND theRealHullCount > 20 then (
									format "$maxconvexpieces %\r\n" theRealHullCount to:NewQC
								)
							)

							if (noselfcollisions != undefined AND noselfcollisions == true) then (
								format "$noselfcollisions\r\n" to:NewQC
							)

							if target.usePhysOverrides == true then (
								if (inertia != undefined) then (
									format "$inertia %\r\n" inertia to:NewQC
								)

								if (damping != undefined) then (
									format "$damping %\r\n" damping to:NewQC
								)

								if (rotDamping != undefined) then (
									format "$rotdamping %\r\n" rotDamping to:NewQC
								)

								if (phdrag != undefined) then (
									format "$drag %\r\n" phdrag to:NewQC
								)
							)

							if ((isValidNode massorigin) AND cmtype == "$collisionmodel") then (
								if useLocalOrigin == true then (
									massPos = in coordsys refSystem massorigin.position
								) else (
									massPos = in coordsys parent massorigin.position
								)
								if distance massPos [0, 0, 0] > 1 then (
									format "$masscenter % % % \r\n" massPos.x massPos.y massPos.z to:NewQC
								)
							)
							if (automass != undefined) then (
								if (automass == true) then (
									format "$automass\r\n" to:NewQC
								)

							) else(
								if (mass != undefined) then (
									automass = false
								) else (
									automass = true
								)
							)

							if (mass != undefined AND (automass == undefined OR automass == false) AND target.usePhysOverrides == true) then (
								format "$mass %\r\n" mass to:NewQC
							)

							if jointConstraints == true AND cmtype == "$collisionjoints" then (
								if (animatedfriction != undefined AND animatedfriction != "") then (
									animatedfriction = trimLeft (trimRight animatedfriction)

									if animatedfriction != "" then (
										format "$animatedfriction %\r\n" animatedfriction to:NewQC
									)
								)

								local hasPutRoot = false
								local useJointConsrains = true

								for b in allbonenodes do (
									if isProperty b #wallworm_bone_CA then (
										if b.useJointProps then (
											if NOT hasPutRoot AND b.rootbone then (
												hasPutRoot = true
												format "$rootbone \"%\"\r\n" b.name to:NewQC
												useJointConsrains = false
											) else (
												useJointConsrains = b.jointconstrain
											)
											local cjt = b.outputMyCollisionForQC()
											if cjt != undefined then (
												format cjt to:NewQC
											)
										)
									) else (
										--This is legacy version
										local wwmt_jointskip = getUserProp b #wwmt_jointskip
										if wwmt_jointskip != undefined then (
											format "$jointskip \"%\"\r\n" b.name to:NewQC
										)
										local bonemass = getUserProp b #wwmt_jointmassbias
										if bonemass != undefined then (
											format "$jointmassbias \"%\" %\r\n" b.name bonemass to:NewQC
										)
									)

									if useJointConsrains AND b.parent != undefined AND (findItem allbonenodes b.parent > 0) then (
										ba = ik.getAxisLimit b #rotational
										boneActive = ik.getAxisActive b #rotational
										boneDamp = ik.getAxisDamping b #rotational

										if ba != undefined OR boneActive != undefined then (
											min = ik.getAxisMin b #rotational
											bmax = ik.getAxisMax b #rotational
											for bindex = 1 to 3 do (
												local jt
												case bindex of (
													1:(jt = "x")
													2:(jt = "y")
													3:(jt = "z")
												)
												local type = "limit"

												if findItem boneActive bindex > 0 then (
													if findItem ba bindex > 0 then (
														if (min[bindex] != 0 AND bmax[bindex] != 0) then (
															type = "limit"
														) else (
															type = "fixed"
														)
													) else (
														type = "free"
													)
												) else (
													type = "fixed"
												)
												format "\t$jointconstrain \"%\" % limit % % %\r\n" b.name jt min[bindex] bmax[bindex] boneDamp[bindex] to:NewQC
											)
										)
									)
								)

								if NOT hasPutRoot AND hullbonesarray[1] != undefined then (
									hasPutRoot = true
									format "$rootbone \"%\"\r\n" hullbonesarray[1].name to:NewQC
								)

							)

							t = "\r\n}\r\n"
							format t to:NewQC

						)

						--jigglebones
						for b in allbonenodes do (
							local useJiggle = true
							if isProperty b #wallworm_bone_CA then (
								if b.useJiggleProps then (
									--useJiggle = false
									local cjt = b.outputMyJiggle()
									if cjt != undefined then (
										format cjt to:NewQC
									)
								)
							)

							/*
							Legacy Code. Probably going to not support this method.
							if useJiggle then (
								ba = ik.getAxisSpringOn b #rotational
								if ba != undefined then (
									if (findItem ba 1 > 0 OR findItem ba 2 > 0 OR findItem ba 3 > 0) then (
										local useJiggle = true
										min = ik.getAxisMin b #rotational
										bmax = ik.getAxisMax b #rotational
										tensions = ik.getAxisSpringTension b #rotational
										dampings = ik.getAxisDamping b #rotational
										t = "$jigglebone \"" + b.name + "\" {\r\n is_flexible {\r\n"
										format t to:NewQC
										for bIndex = 1 to 3 do (
											local axis
											case bIndex of  (
												1:(axis = "yaw")
												2:(axis = "pitch")
												3:(axis = "along")
											)
											if findItem ba bIndex > 0 then (
												if tensions[bIndex]  != undefined then (
													format "%_stiffness %\r\n" axis (tensions[bIndex] * 20) to:NewQC -- Multiple By 20 because no direct relationship in Max : Source
												)
												if dampings[bIndex] != undefined then (
													format "%_damping %\r\n" axis (dampings[bIndex] * 10) to:NewQC  -- Multiple By 10 because no direct relationship in Max : Source
												)
												if bIndex < 3 AND min[bIndex]  != undefined AND bmax[bIndex] != undefined then (
													format "%_constraint % %\r\n" axis min[bIndex] bmax[bIndex]  to:NewQC
												)
											)
										)
										format "\r\n }\r\n}\r\n\r\n" to:NewQC
									)

								)
							)*/

						)

						if (surfaceprop != undefined AND surfaceprop != "undefined" AND surfaceprop != "") then (
							format "$surfaceprop \"%\" \r\n" surfaceprop to:NewQC
						)

						if (contents != undefined AND (::wallworm_engine != 1)) then (
							--This value should not be a single entry because you can choose multiple contents... but for now it will do. !TODO: Add support for multiple like in the bone_CA

							t = "$contents \"" + contents + "\" \r\n"
							format t to:NewQC

						)

						local matP = BsToFs materialPath

						if (::wallworm_engine == 1) then (
							--format "$cdtexture \"%\"\r\n$cliptotextures\r\n"  materialPath to:NewQC
							format "$cdtexture \"%%%\"\r\n$cliptotextures\r\n" ::wwmt_exportMats "\\" materialPath to:NewQC
						) else (
							format "$cdmaterials \"%\"\r\n" materialPath to:NewQC
						)

						t = ""
						format (getBodygroupMats()) to:NewQC
						otherSkins = #(modelName)
						for bdy in bodygroups do (
							for tmpwwmt in bdy.bgmodels do (
								if findItem otherSkins tmpwwmt.modelName == 0 then (
									tmpwwmt.getWWMT()
									format (tmpwwmt.wwmt.getBodygroupMats()) to:NewQC
									append otherSkins tmpwwmt.modelName
								)
							)
						)
						otherSkins = undefined

						if bodygroups.count > 0 OR lods.count > 0 then (
							theLods = #()

							if bodygroups.count > 0 then (
								for b in bodygroups do (
									--t="studio \""+( BsToFs b.modelPath)+"/"+b.modelName+".smd\"\n"

									for m in b.bgmodels do (
										if m.lods != undefined AND m.lods.count > 0 then (
											--for mshs in m.targets do (
											--wallworm_appendBitmaps mshs.mat targMats valveShader coords:false decal:false  getNameFromPath:getNameFromPath
											--)	
											for lodm in m.lods do (
												lodm.getMetric()
												lodm.thislod.getMatFromOtherLOD()
												--lodindex = (floor (lodm.helperGizmo.radius* 100 *( 2 *(tan(::wwmt_FOV/2)  ) ) ) / ::wwmt_horizontalRes)
												if theLods[lodm.metric] == undefined then (
													theLods[lodm.metric] = #()
												)
												append theLods[lodm.metric] lodm
											)
										)

									)
								)
							)
							local ShadowLODID = lods.count
							if lods.count > 0 then (
								for i = 1 to lods.count do (
									l = lods[i]
									l.getMetric()
									l.getMatFromOtherLOD()
									local metricIndex = abs (l.metric as Integer)
									if theLods[metricIndex] == undefined then (
										theLods[metricIndex] = #()
									)
									append theLods[metricIndex] l

									if isProperty l.helperTape #isShadowLod AND l.helperTape.isShadowLod == true then (
										ShadowLODID = i
									)
								)
							)

							if theLods.count > 0 then (
								--collect materials in reference model
								populateMyMaterials()
								for ind = 1 to theLods.count do (
									if theLods[ind] != undefined AND classOf theLods[ind] == Array then (
										local lodMats = #()
										format "\r\n\r\n" to:NewQC
										format "$lod %\r\n" ind to:NewQC
										format "{\r\n" to:NewQC

										previousMats = #()
										for l in theLods[ind] do (
											local thisLevel = l.level
											wallworm_appendBitmaps l.helperGizmo.mat lodMats valveShader coords:false decal:false getNameFromPath:getNameFromPath
											local mainMat = #()
											--check if this model has an lod for this level
											--TODO see if there is a highel level LOD if one not present
											format "\treplacemodel \"%\" \"%_LOD_%%\"\r\n" modelName modelName thisLevel fileExt to:NewQC
											for targMat in materials do (
												local alreadyUsed = #()
												if ::wwmt_legacy_names == true then (
													--set the name from the diffuse bitmap for Older SMD exporters
													local dfile = targMat.getTexName targMat.diff
												) else (
													--set the name from the material for WW SMD Exporter
													local dfile = wallworm_getMaterialName targMat.mat forModel:true
												)
												local lodfile = dfile + "LOD" + (thisLevel as String)
												--format "Looking at % for LODs...\r\n" targMat
												local lodmatopts = #()
												for i = 0 to thisLevel while i <= thisLevel do (
													thatlod = dfile + "LOD" + ((thisLevel - i) as String)
													append lodmatopts thatlod
												)
												for lodMat in lodMats do (
													--enter false for model because the true will force the material name to be the name of the 
													if ::wwmt_legacy_names == true then (
														--check against the diffuse bitmaps
														local theFind = findItem lodmatopts (lodMat.getTexName lodMat.diff)
													) else (
														--check against the material names
														local theFind = findItem lodmatopts ((wallworm_getMaterialName lodMat.mat forModel:true))
													)
													if (findItem alreadyUsed lodfile) == 0 AND theFind > 0 then (
														theLODfile = lodmatopts[theFind]
														append alreadyUsed theLODfile
														append mainMat dfile
														append previousMats theLODfile
														format "\treplacematerial \"%\" \"%\"\r\n" dfile theLODfile to:NewQC
													)
												)
											)
											if isProperty l.helpertape #nofacial AND l.helperTape.nofacial == true then (
												format "\tnofacial\r\n" to:NewQC
											)
										)
										format "}\r\n" to:NewQC
									)
								)
								if shadowlod != undefined then (
									if (lods.count > 0 AND shadowlod == true) then (
										format "$shadowlod \r\n" to:NewQC
										format "{\r\n" to:NewQC
										format "\treplacemodel \"%\" \"%_LOD_%%\"\r\n" modelName modelName lods[ShadowLODID].level fileExt to:NewQC
										format "}\r\n" to:NewQC
									)
								)
							)
						)

						if idleSequence == true then (
							if staticprop == true then (
								if (::wallworm_engine == 1) then (
									format "$sequence idle \"%_sequence_idle\"  loop  fps 30 ACT_IDLE 1\r\n" modelName to:NewQC
								) else (
									format "$sequence idle \"%\" activity ACT_IDLE -1.0 fps 1\r\n" modelName to:NewQC
								)
							) else (
								/*See if the model has a specified idle sequence.*/
								local idleSeq = for s in sequences WHERE s.sequence == "idle" collect s
								if idleSeq.count == 0 then (
									if (::wallworm_engine == 1) then (
										format "$sequence idle \"%\"    loop fps % ACT_IDLE 1\r\n" modelName frameRate to:NewQC
									) else (
										format "$sequence idle \"%\"  activity ACT_IDLE -1.0 loop fps %\r\n" modelName frameRate to:NewQC
									)
								)
							)
						)

						particleData = #()
						particleEvents = #()
						--AND (staticprop==undefined OR staticprop==false)
						if particlesystems.count > 0 then (
							for p in particlesystems do (
								if p.type == "keyvalue" then (
									append particleData p
								) else (
									append particleEvents p
								)

							)

						)

						if staticprop != true then (
							if weightlists.count > 0 then (
								for w in weightlists do (
									local weightlistlines = "$weightlist " + w.name + " "

									local afterBone = ""
									local openBracket = ""
									local closeBracket = "\r\n"

									if w.bns.count > 1 then (
										afterBone = "\r\n"
										openBracket = "{\r\n"
										closeBracket = "}\r\n"
									)

									append weightlistlines openBracket

									for bi = 1 to w.bns.count do (
										append weightlistlines ("\"" + w.bns[bi] + "\" " + w.weights[bi] as String + afterBone)

									)

									append weightlistlines closeBracket

									format weightlistlines to:NewQC

								)

							)

							--For Static Prop... animation sequences make no sense... so skip if staticprop
							fr = frameRate as String

							local alreadyUsedSeq = #()

							function sortSequences seq1 seq2 = (
								case of
								(
									(seq1.asAnimation == true AND seq2.asAnimation == false): -1
									(seq2.asAnimation == true AND seq1.asAnimation == false): 1
									default: 0
								)
							)
							tempSegList = deepCopy sequences
							qsort tempSegList sortSequences

							for s in tempSegList do (
								--print ("Making Sequence: "+s.sequence)

								if s.asAnimation == true then (
									s.makeSMD == true
								)

								afterOp = " "
								if s.makeSMD == true then (
									seqname = "\"" + modelName + "_sequence_" + s.sequence + "\""
								) else (
									seqname = ""
									if s.asAnimation == false then (
										afterOp = "\r\n"
									)
								)
								if findItem alreadyUsedSeq s.sequence == 0 then (
									--fr = s.fps as string

									--seqname = modelName+"_sequence_"+s.sequence

									local seQEvent = StringStream ""
									local seQEvent1 = StringStream ""
									for p in particleEvents do (
										if p.sequence == s.sequence AND p.type != "keyvalue" then (
											local atpoint = ""
											if p.attachTo == "start_at_attachment" OR p.attachTo == "follow_attachment" then (
												atpoint = " " + p.attachmentPoint
											)

											if p.type == "once" then (
												format ("\r\n{ event AE_CL_CREATE_PARTICLE_EFFECT % \"% %%\" }\r\n") p.pframe p.systemname p.attachTo atpoint to:seQEvent
											) else (
												if p.pframe != undefined AND p.pEnd != undefined AND p.pframe < p.pEnd then (
													--TODO add code to check if the range is in the target sequence
													format ("\r\n{ event AE_START_SCRIPTED_EFFECT % \"% %%\" }\r\n") p.pframe p.systemname p.attachTo atpoint to:seQEvent
													format ("\r\n{ event AE_END_SCRIPTED_EFFECT % \"% %%\" }\r\n") p.pEnd p.systemname p.attachTo atpoint to:seQEvent
												)
											)

										)

									)

									local moreSeqOptions = StringStream ""

									if s.asAnimation == true then (
										sLabel = "animation"

										if s.loop == 1 then (
											format "loop %" afterOp to:moreSeqOptions
										)

										if s.weightlist != undefined AND s.weightlist != "" AND s.weightlist != "undefined" then (
											format "weightlist %%" s.weightlist afterOp to:moreSeqOptions
										)

									) else (
										if ::wallworm_engine != 1 then (
											if s.animations != undefined AND s.animations != "" then (
												format "%%" s.animations afterOp to:moreSeqOptions
											)

											format "fps %%" s.fps afterOp to:moreSeqOptions
											if s.loop == 1 then (
												format "loop %" afterOp to:moreSeqOptions
											)

											if s.weightlist != undefined AND s.weightlist != "" AND s.weightlist != "undefined" then (
												format "weightlist %%" s.weightlist afterOp to:moreSeqOptions
											)

											if s.activity != undefined AND s.activity != "" then (
												format "activity % %%" s.activity s.activityWeight afterOp to:moreSeqOptions
											)

											if s.addlayer != undefined AND s.addlayer != "" then (
												format "addlayer %%" s.addlayer afterOp to:moreSeqOptions
											)

											if s.fadeIn != undefined then (
												format "fadein %%" s.fadeIn afterOp to:moreSeqOptions
											)

											if s.fadeOut != undefined then (
												format "fadeout %%" s.fadeOut afterOp to:moreSeqOptions
											)
											if s.nd != undefined AND s.nd != "" then (
												format "node %%" s.nd afterOp to:moreSeqOptions
											)

											if s.autoplay != undefined AND s.autoplay == true then (
												format "autoplay%" afterOp to:moreSeqOptions
											)
											if s.snap != undefined AND s.snap == true then (
												format "snap%" afterOp to:moreSeqOptions
											)
											if s.realtime != undefined AND s.realtime == true then (
												format "realtime%" afterOp to:moreSeqOptions
											)
											if s.hidden != undefined AND s.hidden == true then (
												format "hidden%" afterOp to:moreSeqOptions
											)

											if s.makeSMD == false AND s.asAnimation == false then (
												format (moreSeqOptions as String) to:seQEvent
												moreSeqOptions = StringStream ""
											)

											if (seQEvent as String).count > 0 then (
												format " {\r\n%\r\n}" seQEvent to:seQEvent1
											)
										) else (
											if s.animations != undefined AND s.animations != "" then (
												format "%%" s.animations afterOp to:moreSeqOptions
											)

											format "fps %%" s.fps afterOp to:moreSeqOptions
											if s.loop == 1 then (
												format "loop %" afterOp to:moreSeqOptions
											)

											if s.activity != undefined AND s.activity != "" then (
												format "% " s.activity to:moreSeqOptions
											)

											if s.autoplay != undefined AND s.autoplay == true then (
												format "autoplay%" afterOp to:moreSeqOptions
											)
											if s.snap != undefined AND s.snap == true then (
												format "snap%" afterOp to:moreSeqOptions
											)
											if s.realtime != undefined AND s.realtime == true then (
												format "realtime%" afterOp to:moreSeqOptions
											)
											if s.hidden != undefined AND s.hidden == true then (
												format "hidden%" afterOp to:moreSeqOptions
											)

											if s.makeSMD == false AND s.asAnimation == false then (
												format (moreSeqOptions as String) to:seQEvent
												moreSeqOptions = StringStream ""
											)

										)

										sLabel = "sequence"
									)

									format "$% % % %%\r\n" sLabel s.sequence seqname (moreSeqOptions as String) (seQEvent1 as String) to:NewQC
									appendIfUnique alreadyUsedSeq s.sequence
								)
							)

							tempSegList = undefined

						)

						for ats in attachments WHERE isValidNode ats.atPoint do (
							local pname
							local rst = ab = ri = ""

							local thePt = ats.atPoint
							local pnode = thePt.parent

							if isProperty ats #updateValues then
							(
								ats.updateValues()
							)
							if ats.absolute == true OR ats.absolute == 1 then
							(
								ab = " absolute"
							)

							if ats.rigid == true OR ats.rigid == 1 then
							(
								ri = " rigid"
							)

							if isValidNode pnode AND (findItem targets pnode > 0 OR findItem bonesArray pnode > 0) then
							(
								pname = pnode.name
								local pntransform = at time 0 pnode.transform
								thePosA = ((at time 0 thePt.transform)).translationPart * inverse pntransform
								r2 = (at time 0 ((thePt.transform.rotationPart * (inverse pntransform.rotationPart)))) as EulerAngles
							)
							else
							(
								pname = targets[0].name
								thePosA = (at time 0 thePt.transform.translationPart) - refSystem.translationPart
								r2 = (at time 0 ((thePt.transform * (inverse refSystem)).rotationPart)) as EulerAngles
							)

							if r2 != [0, 0, 0] then
							(
								rst = " rotate " + ((wallworm_fix_tiny_float r2.y) as String) + " " + (wallworm_fix_tiny_float r2.z as String) + " " + ((wallworm_fix_tiny_float r2.x) as String)
							)
							format "$attachment \"%\" \"%\" % % %%%%\r\n" thePt.name pname (wallworm_fix_tiny_float thePosA.x) (wallworm_fix_tiny_float thePosA.y) (wallworm_fix_tiny_float thePosA.z) ab ri rst to:NewQC
						)

						if (base != undefined AND base != "") OR (particleData.count > 0) then (
							gibsText = StringStream ""
							format " $keyvalues {\r\n" to:NewQC

							if particleData.count > 0 then (
								format "\t\"particles\"\r\n	{\r\n" to:NewQC

								for p in particleData do (
									format "\t\"effect\"\r\n	{\r\n" to:NewQC
									format "\t\tname		\"%\"  \r\n" p.systemname to:NewQC
									format "\t\tattachment_type		\"%\"  \r\n" p.attachTo to:NewQC
									if p.attachmentPoint != undefined AND p.attachmentPoint != "" then (
										format "\t\tattachment_point		\"%\"  \r\n" p.attachmentPoint to:NewQC
									)
									format "\r\n\t}\r\n" to:NewQC
								)

								format "\r\n\t}\r\n" to:NewQC

							)

							if base != undefined AND base != "" then (
								format "	\"prop_data\"\r\n	{\r\n" to:NewQC

								format "\t\t\"base\"		\"%\"\r\n" base to:NewQC

								if target.overridePhys == true then (
									if health != undefined AND health != "undefined" then (
										format "\t\t\"health\"		\"%\"\r\n" health to:NewQC
									)
									if allowstatic != undefined AND (allowstatic == "true" OR allowstatic == true) then (
										format "\t\t\"allowstatic\"		\"%\"\r\n" allowstatic to:NewQC
									)

									if blockLOS != undefined AND blockLOS != "undefined" AND (blockLOS == "true" OR blockLOS == true) then (
										format "\t\t\"blockLOS\"		\"%\"\r\n" blockLOS to:NewQC
									)
									if AIWalkable != undefined AND (AIWalkable == "true" OR AIWalkable == true) then (
										format "\t\t\"AIWalkable\"		\"%\"\r\n" AIWalkable to:NewQC
									)

									if physicsmode != undefined then (
										format "\t\t\"physicsmode\"		\"%\"\r\n" ((-1) + (physicsmode)) to:NewQC
									)

									if dmg_bullets != undefined AND dmg_bullets != "undefined" then (
										format "\t\t\"dmg.bullets\"		\"%\"\r\n" dmg_bullets to:NewQC
									)
									if dmg_club != undefined AND dmg_club != "undefined" then (
										format "		\"dmg.club\"		\"%\"\r\n" dmg_club to:NewQC
									)
									if dmg_explosive != undefined AND dmg_explosive != "undefined" then (
										format "		\"dmg.explosive\"		\"%\"\r\n" dmg_explosive to:NewQC
									)

									flammables = ""

									if ignite != undefined AND (ignite == true OR ignite == "true") then (
										append flammables "\t\t\t\"ignite\"\t\"halfhealth\"\r\n"
									)
									if explosive_resist != undefined AND (explosive_resist == true OR explosive_resist == "true") then (
										append flammables "\t\t\t\"explosive_resist\"	\t\"yes\"\r\n"
									)
									if flammable != undefined AND (flammable == true OR flammable == "true") then (
										append flammables "\t\t\t\"flammable\"\t\"yes\"\r\n"
									)

									if flammables != "" then (
										format "\r\n\t\t\"fire_interactions\"\r\n\t\t{\r\n%\r\n\t\t}\r\n" flammables to:NewQC
									)

								)

								if breakable_model != undefined AND breakable_model != "" then (
									if breakable_model != "CustomGibs" then (
										format "		\"breakable_model\"		\"%\"\r\n" breakable_model to:NewQC

									) else (
										if gibs.count > 0 then (
											for obj in gibs do (
												if isValidNode obj then (
													local tempWWMT = ww_LOD_wrapper()
													tempWWMT.init()
													tempWWMT.setTargetModel obj tempWWMT

													if (tempWWMT.isset == true) then (
														setChildGibs tempWWMT
													)

													h = ""
													if tempWWMT.health != undefined AND tempWWMT.health != "undefined" then (
														h = "	 \"health\" \"" + (tempWWMT.health as String) + "\""
													) else(
														h = ""
													)

													if tempWWMT.motiondisabled != undefined AND (tempWWMT.motiondisabled == "true" OR tempWWMT.motiondisabled == true) then (
														h += "	 \"motiondisabled\" \"1\""
													)

													if tempWWMT.fadetime != undefined AND tempWWMT.fadetime != "undefined" then (
														f = (tempWWMT.fadetime as String)
													) else(
														f = "0"
													)
													format "\"break\"\r\n{				\r\n \"model\" \"%/%.mdl\"	\"fadetime\" \"%\"%	\r\n}\r\n" tempWWMT.modelPath tempWWMT.modelName f h to:gibsText

												)

											)
										)
										if target.overridePhys == true then (
											if breakable_count != undefined AND breakable_count != "undefined" then (
												format "		\"breakable_count\"		\"%\"\r\n" breakable_count to:NewQC
											)
											if breakable_skin != undefined AND breakable_skin != "undefined" then (
												format "		\"breakable_skin\"		\"%\"\r\n" breakable_skin to:NewQC
											)
										)
									)
									if target.overridePhys == true then (
										if multiplayer_break != undefined AND multiplayer_break != "undefined" then (
											format "		\"multiplayer_break\"		\"%\"\r\n" multiplayer_break to:NewQC
										)
									)

								)
								if target.overridePhys == true then (
									if explosive_radius != undefined AND explosive_radius != "undefined" then (
										format "		\"explosive_radius\"		\"%\"\r\n" explosive_radius to:NewQC
									)
									if explosive_damage != undefined AND explosive_damage != "undefined" then (
										format "		\"explosive_damage\"		\"%\"\r\n" explosive_damage to:NewQC
									)
								)
								format "\r\n	}\r\n" to:NewQC

							)

							format "\r\n}\r\n" to:NewQC

							gibsText = gibsText as String
							if gibsText.count > 0 then (
								format "\r\n$collisiontext\r\n{\r\n%\r\n}\r\n" gibsText to:NewQC
							)

						)

						if staticprop != true AND (targets.count > 1 OR bonesarray.count > 0 OR hullbonesarray.count > 0) then (
							for obj in allbonenodes do (
								if isProperty obj #useBoneProps AND obj.useBoneProps == true then (
									format ((obj.outputMyBoneProps()) as String) to:NewQC
								) else (
									--legacy bone functions
									local jsurfaceprop = getUserProp obj #wwmt_surfaceprop_bone
									if jsurfaceprop != undefined AND jsurfaceprop != "" then (
										format "\r\n$jointsurfaceprop % %\r\n" obj.name jsurfaceprop to:NewQC
									)
								)
							)

							if alwayscollapse == true then (
								--collapse mesh nodes
								for t in targets WHERE t != targets[1] AND classOf t != Bone AND classOf t != BoneGeometry AND findItem bonesarray t == 0 AND findItem hullbonesarray t == 0 do (
									if (NOT isProperty obj #useBoneProps OR obj.useBoneProps == false) then (
										format "\r\n$alwayscollapse \"%\"\r\n" t.name to:NewQC
									)
								)

							)

							/* Hitboxes */

							local hboxobjs = #()
							join hboxobjs targets
							join hboxobjs bonesarray
							join hboxobjs hullbonesarray
							--join hullbonesarray targets
							hboxobjs = makeUniqueArray hboxobjs
							hbsets = #()
							wwmt_get_hitboxsets &hbsets objs:hboxobjs
							local hboxes = #()
							local hbArrs = #()

							local theHitBoxes = wwmt_getBoneHitboxes bs:hboxobjs

							if theHitBoxes.count > 0 then (
								for hb in theHitBoxes do (
									local wwmt_hboxset
									if isProperty hb #hboxset then (
										wwmt_hboxset = hb.hboxset
									) else (
										wwmt_hboxset = getUserProp hb #wwmt_hboxset
									)

									--= getUserProp hb #wwmt_hboxset
									if wwmt_hboxset == undefined OR wwmt_hboxset == "" then (
										wwmt_hboxset = "default"
									)

									local hbIndex = findItem hboxes wwmt_hboxset
									--print hbIndex
									if hbIndex == 0 then (
										append hboxes (wwmt_hboxset as String)
										append hbArrs (#())

										hbIndex = hboxes.count
									)
									--print hbIndex
									append hbArrs[hbIndex] hb

								)

								for hbi = 1 to hboxes.count do (
									format "\r\n$hboxset \"%\"\r\n" hboxes[hbi] to:NewQC

									for hbo in hbArrs[hbi] do (
										local wwmt_hitbox_group
										if isProperty hbo #hitbox_group then (
											wwmt_hitbox_group = hbo.hitbox_group
										) else (
											wwmt_hitbox_group = getUserProp hbo #wwmt_hitbox_group
										)

										if wwmt_hitbox_group == undefined OR wwmt_hitbox_group == "" then (
											wwmt_hitbox_group = "0"

										)

										local bb = in coordsys local nodeLocalBoundingBox hbo
										local offset = in coordsys parent hbo.position
										bb[1] = bb[1] += offset
										bb[2] = bb[2] += offset
										in coordsys parent (
											local rot = quatToEuler (inverse hbo.rotation) --order:3
										)
										format "$hbox % \"%\" % % % % % % % % %\r\n" wwmt_hitbox_group hbo.parent.name (formattedPrint bb[1].x format:".2f") (formattedPrint bb[1].y format:".2f") (formattedPrint bb[1].z format:".2f") (formattedPrint bb[2].x format:".2f") (formattedPrint bb[2].y format:".2f") (formattedPrint bb[2].z format:".2f") (formattedPrint rot.y format:".2f") (formattedPrint rot.z format:".2f") (formattedPrint rot.x format:".2f") to:NewQC
									)
								)
							)
						)

						format "\r\n$include	\"%_wwmt_custom.qci\"" modelName to:NewQC

						createCustomQCI()
						try(
							close NewQC
							free NewQC
							flush NewQC

						) catch()

						out = true
					)

				)

				print exportNotice

				if writeSMDs then (
					if (exportSMDS resetBnArray:true runCompile:runCompile allboneNodes:allboneNodes) == false then (
						messageBox "The SMDs were not exported because you do not have one of the SMD exporters installed. Please get one from www.wunderboy.org and/or www.chaosincarnate.net ."
						enableSceneRedraw()
					)

				)

			)

			if resetExportList == true then (
				alreadyExported = #()
			)
		)
		out
	),

	function exportGibs = (
		if gibs.count > 0 then (
			for obj in gibs do (
				if isValidNode obj then (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel obj tempWWMT
					if isValidNode referenceNode then (
						tempWWMT.referenceNode = referenceNode
					)
					if (tempWWMT.isset == true) then (
						setChildGibs tempWWMT
					)
					tempWWMT.outputModelQC()
				)
			)
		)
	),
	function showOnlyModel = (
		if lods.count > 0 then (
			for l in lods do (
				hide l.items
				hide l.helperGizmo
			)
		)
		if hulls.count > 0 then (
			hide hulls
		)
		unhide targets
	),
	
	function updateProxySkinNums = (
		local helperMat = target.mat
		if classOf helperMat == XRefMaterial then (
			helperMat = helperMat.GetSourceMaterial true
		)
		if helperMat != undefined AND classOf helperMat == MultiMaterial then (
			getProxies()
			for obj in proxies do (
				obj.updateWwmtSkinMaterial()
				
			)
			
		)
	),
	function gatherMySkins updateSkinNums:false = (
		/*

		XRefmaterial :(
			return wallworm_getMaterial (m.GetSourceMaterial true) matId:matId forModel:forModel collectingMat:collectingMat
		)

		*/
		local helperMat = target.mat
		if classOf helperMat == XRefMaterial then (
			helperMat = helperMat.GetSourceMaterial true
		)

		if helperMat != undefined OR classOf helperMat != MultiMaterial then (
			newmat = MultiMaterial numsubs:1
			newmat.name = ("Skin Material for " + modelName)
			helperMat = newmat
			target.mat = newmat
			if (targets[1].mat != undefined) then (
				helperMat.materialList[1] = targets[1].mat
				helperMat.names[1] = "Skin 0"
			)

		)
		local HelperMaterialCount = helperMat.materialList.count
		local objectsToTest = #()
		join objectsToTest targets
		getProxies()
		join objectsToTest proxies

		local targsArray = #()
		for obj in objectsToTest do (
			objMods = obj.modifiers

			local mma = wallworm_get_modifierByClass obj Morph_O_Matic
			local mrph = wallworm_get_modifierByClass obj Morpher

			case of (
				(mrph != undefined):(
					theMorphMod = mrph
					local usedChannels = #()
					for uc = 1 to 100 do (
						if WM3_MC_HasData theMorphMod uc AND WM3_MC_IsActive theMorphMod uc then (
							append usedChannels uc
						)
					)
					local f = 1
					for c in usedChannels do (
						local morphtargetscount = WM3_NumberOfProgressiveMorphs theMorphMod c
						for mtc = 1 to morphtargetscount do (
							local targ = WM3_GetProgressiveMorphNode theMorphMod c mtc
							append targsArray targ

						)
					)
				)
				(mma != undefined):(
					getStatesFromMorpher = true
					theMorphMod = mma
					MOM_HoldLicense()
					local channels = MOM_GetNumChannels theMorphMod
					local f = 1
					for c = 1 to channels do (
						if theMorphMod[c] != undefined then (
							local thisChannel = theMorphMod[c]
							if thisChannel.Active == true then (
								MOM_MC_GetNumTargets theMorphMod[c]
								local morphtargetscount = MOM_MC_GetNumTargets theMorphMod [c]
								for mtc = 1 to morphtargetscount do (
									if MOM_MC_TARG_IsOriginal theMorphMod[c] mtc == false then (
										local targ = MOM_MC_TARG_GetNode theMorphMod[c] mtc
										append targsArray targ
									)
								)
							)
						)
					)
				)
				default:()
			)
		)
		join objectsToTest targsArray

		objectsToTest = for obj in objectsToTest WHERE isValidNode obj collect obj
		objectsToTest = makeUniqueArray objectsToTest

		local testMaterails = for obj in objectsToTest WHERE obj.mat != undefined collect obj.mat
		testMaterails = makeUniqueArray testMaterails

		for testMat in testMaterails do (
			notFound = true
			if classOf testMat == XRefMaterial then (
				testMat = testMat.GetSourceMaterial true
			)
			for m in helperMat.materialList while notFound do (
				if m == testMat OR m.name == testMat.name then (
					notFound = false
				)
			)
			if notFound then (
				HelperMaterialCount += 1
				helperMat.materialList[HelperMaterialCount] = testMat
				helperMat.names[HelperMaterialCount] = ("Skin " + ((HelperMaterialCount - 1) as String))
			)
		)
		if updateSkinNums then (
			updateProxySkinNums()
		)
	),
	function getLibraryPath = (
		(pathConfig.GetDir #import) + "\\WallWormPropLibrary\\" + (getFileNameFile ::wwmt_def_fgd) + "\\" + modelPath
	),
	function getProxyFileName = (
		(getLibraryPath()) + "\\" + modelName + ".max"
	),
	max2016Up = (maxversion())[1] >= 18000,
	function createProxy updateFromModel:true saveFirst:false offset:[128,128]= (
		local newModel
		if targets == undefined OR NOT isValidNode targets[1] then (
			newModel = undefined
		) else (
			local prfile = getProxyFileName()
			local newModel
			if NOT updateFromModel AND (proxyFileDoesExist == true OR doesFileExist prfile) then (
				proxyFileDoesExist = true
				if max2016Up then (
					local  objXRefMgrmergeTransforms = objXRefMgr.mergeTransforms
					objXRefMgr.mergeTransforms = true
				)
				newModel = xrefs.addNewXRefObject prfile "WallWormProxyReference" modifiers:#merge manipulators:#merge dupMtlNameAction:#autoRename
				newModel.proxyFileName = prfile
				newModel.proxyObjectName = "WallWormProxyHullReference"
				if max2016Up then (
					objXRefMgr.mergeTransforms = objXRefMgrmergeTransforms
					newModel.transform.controller =  prs()
				)
			) else (
				at time 0 (
					local boneClasses = #(Bone, BoneGeometry, CatBone, HubObject, CATParent, Biped_Object)
					local newModel = snapshot targets[1]
					convertTo newModel Editable_Poly

					if (NOT isValidNode targets[1]) OR superClassOf targets[1] != GeometryClass OR findItem boneClasses (classOf targets[1]) > 0 then (
						polyop.deleteVerts newModel #all

					)

					if targets.count > 1 then (
						for index = 2 to targets.count do (
							local thisTarget = targets[index]
							if (isValidNode thisTarget == false)  OR superClassOf thisTarget != GeometryClass OR findItem boneClasses (classOf thisTarget) > 0 then (
								/*Skip this object*/
							) else (
								local cp = snapshot (thisTarget)
								newModel.attach cp newModel
							)
						)
					)
				)
			)
			newModel.name = uniqueName (modelName + " Proxie")
			setUserPropBuffer newModel ""
			setUserProp newModel #wwmt_proxie_source target.name
			newModel.pos.x = newModel.pos.x + offset.x
			newModel.pos.y = newModel.pos.y + offset.y

			setTransformLockFlags newModel #{7, 8, 9} --Because most props cannot be scaled
			/*	if Deformable_gPoly != undefined then (
				convertTo newModel Deformable_gPoly
			)
			*/

			custAttributes.add newModel ::wallworm_proxyskin_holderCA --BaseObject:false 
			newModel.wwmtTarget = target
			newModel.parent = undefined
		)
		newModel
	),
	function addProxyCAtoPoxies = (
		global wallworm_proxyskin_holderCA
		for p in proxies WHERE NOT isProperty p #WWMTProxy do (
			custAttributes.add p wallworm_proxyskin_holderCA
			p.wwmtTarget = target
		)
	),

	function collectWWMTNodes = (
		/*Collect all nodes used in this WWMT . */
		local bonenodes = getAllbonesArray()
		append bonenodes target
		join bonenodes targets
		join bonenodes hulls
		populateBodyGroups()
		for b in bodygroups do (
			append bonenodes b.bghelper
			for ww in b.bgmodels do (
				theWWmt = ww.getWWMT()
				join bonenodes (theWWmt.collectWWMTNodes())
			)
		)
		for l in lods do (
			local lobjs = l.getAllObjects()
			if lobjs.count > 0 then (
				join bonenodes lobjs
			)
		)

		for obj in gibs do (
			theWWmt = obj.getWWMT()
			join bonenodes (theWWmt.collectWWMTNodes())
		)

		join bonenodes (wwmt_getBoneHitboxes bs:bonenodes)
		join bonenodes target.attachments

		if isValidNode target.cam then (
			append bonenodes target.cam
		)
		if isValidNode target.massorigin then (
			append bonenodes target.massorigin
		)
		if isValidNode target.illumorigin then (
			append bonenodes target.illumorigin
		)
		if target.'Wallworm Model Tools'.version >= 22 then (
			if isValidNode target.eyeposition then (
				append bonenodes target.eyeposition
			)
			for b in target.includes do (
				theWWmt = b.getWWMT()
				join bonenodes (theWWmt.collectWWMTNodes())
			)

			for b in target.models do (
				theWWmt = b.getWWMT()
				join bonenodes (theWWmt.collectWWMTNodes())
			)

			join bonenodes target.eyeballs
		)
		join bonenodes target.attachments
		bonenodes = makeUniquearray bonenodes
		bonenodes
	),

	function saveProxy quiet:true all:false = (
		max create mode
		with redraw off
		local result = false
		undo off (
			local fgdName = getFileNameFile ::wwmt_def_fgd
			if fgdName != "" then (
				localProxPath = (pathConfig.GetDir #import) + "\\WallWormPropLibrary\\" + fgdName + "\\" + modelPath
				if doesFileExist localProxPath OR (makeDir localProxPath all:true) then (
					local prox = createProxy updateFromModel:true
					prox.transform = targets[1].transform
					prox.name = "WallWormProxyReference"
					setUserprop prox #wwmt_staticprop (staticprop as String)
					local hullProx
					local hullobjs
					if hulls.count > 0 then (
						hullobjs = for obj in hulls collect copy obj
					) else (
						local targcollection = #()
						getAllNodesFromGroup targcollection targets
						targcollection = for obj in targcollection WHERE findItem target.bonelist obj == 0 collect obj
						hullobjs =  wallwormCreateMeshFromMeshes targcollection vertlimit:44 doOffsetransforms:true resestX1:false
					)
					local nodearray = #(prox)
					local deleteHull = false
					if hullobjs.count > 0 then (
						hullProx = wallworm_merge_hulls thehulls:hullobjs
						if isValidNode hullProx then (
							hullProx.name = "WallWormProxyHullReference"
							hullProx.pivot = prox.pivot		
							append nodearray hullProx
							deleteHull = true
						)
					)

					if all == true then (
						join nodearray (collectWWMTNodes())
					)
					--move all the objects to the Exclude layer
					struct tmp (
						obj,
						layer
					)
					local layerstore = #()
					local excludeLayer = LayerManager.getLayerFromName "VMF_Exclude"
					if excludeLayer == undefined then (
						excludeLayer = LayerManager.newLayerFromName "VMF_Exclude"
					)
					local oldTargetVal = target.exclude_vmf
					target.exclude_vmf = true
					for obj in nodearray do (
						l = tmp()
						l.obj = obj
						l.layer = obj.layer
						append layerstore l
						excludeLayer.addNode obj
					)
					saveNodes nodearray (localProxPath + "\\" + modelName + ".max") quiet:quiet
					target.exclude_vmf = oldTargetVal
					for l in layerstore do (
						l.layer.addNode l.obj
					)
					delete prox
					if deleteHull == true then (
						delete hullProx
					)
					result = true
				)
			)
		)
		result
	),
	function createHull maxVerts:44 = (
		try (
			local targcollection = #()
			getAllNodesFromGroup targcollection targets
			targcollection = for obj in targcollection WHERE findItem target.bonelist obj == 0 collect obj
			if targcollection.count > 0 then (
				local NewHulls = wallwormCreateMeshFromMeshes targcollection vertlimit:maxVerts doOffsetransforms:true resestX1:false
				for obj in NewHulls do (
					obj.name = uniqueName (modelName + "_WWMT_hull")
					if staticprop == false then (
						addAHull(obj)
					)
					--obj.parent = ww_scene_lods.targets[1]
				)
				if staticprop == true then (
					local newhull = wallworm_merge_hulls thehulls:NewHulls
					if newhull != undefined then (
						newhull.name = uniqueName (modelName + "_hull")
						addAHull(newhull)
						newhull.pivot = targets[1].pivot
						resetXForm newHull
						convertToPoly newHull
					)
				)
			)
			wwmt_hullsmoothinggroups hulls 1
			if hulls.count > 1 OR (NewHulls != undefined AND NewHulls.count > 1) then (
				setConcave true
			)
			true
		) catch (
			--messagebox "There was a problem:\n\n The Wall Worm Hull Helper only works if you have either:\n\n *The nVidia PhysX Plugin or MassFX (Integrated into 3ds Max 2012+)\n*Convexity 1.17+.\n\nIf you meet one of these requirements, please submit a bug report."
			false
		)
	),
	function checkForProblems = (
		local ers = #()
		if findString modelPath ":" != undefined then (
			append ers "The Model Path is invalid. It cannot have a colon (:) character. Do not use full paths here."
		)
		if findString materialPath ":" != undefined then (
			append ers "The Material Path is invalid. It cannot have a colon (:) character. Do not use full paths here."
		)
		ers
	),
	function updateObjectAsProxy proxy newProx:undefined useRotation:false = (
		if isValidNode proxy then (
			with undo off (
				local deleteAtEnd = false
				local isXREF = classOf proxy == XRefObject
				if NOT isXREF then (
					local startPivot = proxy.pivot
					if newProx == undefined then (
						local newProx = createProxy updateFromModel:true
						if NOT rotateRefSystem then (
							in coordsys local rotate newProx (AngleAxis -90 [0, 0, 1])
						)
						deleteAtEnd = true
					)
					addedProx = newProx
					newProx.transform = Matrix3 1
					--addedProx.transform = proxy.transform
					addedProx.parent = proxy.parent
					addedProx.scale = [1, 1, 1]
					convertToMesh proxy
					proxy.Mesh = addedProx.Mesh
					update proxy.Mesh
					convertToPoly proxy
				)

				setUserProp proxy #wwmt_proxie_source target.name
				--proxy.transform = newProx.objecttransform

				--updateObjectAsProxy proxy newProx:newProx
				if NOT isProperty proxy #wallwormProxy then (
					custAttributes.add proxy ::wallworm_proxyskin_holderCA --BaseObject:false 
				)
				proxy.wwmtTarget = target

				--if proxy.material == undefined then (
				proxy.updateWwmtSkinMaterial()

				if proxy.wwmtSkinMaterial != undefined AND classOf proxy.wwmtSkinMaterial == MultiMaterial then (
					local skNum = 1
					if isProperty proxy #entityType AND isProperty proxy #Skin then (
						skNum = proxy.Skin + 1
					)
					proxy.material = proxy.wwmtSkinMaterial[skNum]
				) else (
					if NOT isXREF then (
						proxy.material = newProx.mat
					)
				)

				--)

				if deleteAtEnd then (
					delete newProx
				)

				if isProperty proxy #model then (
					proxy.model = ("models/" + modelPath + "/" + modelName + ".mdl")
				)
			)

		)

		proxy
	),

	function update_proxies_in_scene = (
		max create mode
		newProxies = #()
		getProxies()
		local newProx = createProxy updateFromModel:true
		for proxy in proxies do (
			updateObjectAsProxy proxy newProx:newProx
			append newProxies proxy
		)
		delete newProx
		newProxies
	)

)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_bodygroup.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_sequence.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/wwmt_particles.ms")

