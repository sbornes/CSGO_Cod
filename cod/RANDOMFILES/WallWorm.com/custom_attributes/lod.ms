global wallworm_lod_CA
wallworm_lod_CA = attributes "Wallworm LOD"
version:6
(
	local wallworm = true --used by many WW scene utilities
	local wwmt_lod = true --lets external functions know this is a WWMT helper
	local wwmt --used to store the ww_LOD_wrapper object. Gets set with the getWWMT() method.
	local thisNode --stores pointer to the node this CA is applied to.
	local thislod --store the ww_lod struct
	local exportAsWorldGeometry = false
	local vmf_exclude = true
	local resolutionModifier

	function getGlobalWWVars = (
		if ::wwmt_horizontalRes == undefined OR ::wwmt_horizontalRes == "" then (
			::wwmt_horizontalRes = 1920
		)

		if ::wwmt_FOV == undefined OR ::wwmt_FOV == "" then (
			::wwmt_FOV = 75
		)
	)

	function getNode = (
		if thisNode == undefined then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	on clone orig do thisNode = undefined

	local updateHelperRadius, setRadiusFromMetric, getHelperGizmo

	parameters params rollout:main (
		items type:#nodeTab tabSizeVariable:true --all the meshes in this lod
		metric type:#float ui:sp_metric animatable:false
		vertexPercent type:#float ui:sp_vertPercent default:100 animatable:false
		helperGizmo type:#node
		level type:#integer default:1
		multiresname type:#string
		nofacial type:#boolean default:false ui:chkNoFacial
		isShadowLod type:#boolean default:false ui:chkIsShadowLOD
		on metric set val do (
			if isValidNode helperGizmo then (
				setRadiusFromMetric metric
			)
		)

	)

	function getHelperGizmo = (
		if NOT isValidNode helperGizmo then (
			getNode()
			gizmoName = "ww_lod_sphere_" + thisNode.name + "_" + level as String
			if level != undefined then (
				r = 64 * level
			) else (
				r = 64
			)
			helperGizmo = Sphere name:(gizmoName) radius:r pos:items[1].pos segs:16 renderable:off smooth:off showFrozenInGray:off
			helperGizmo.position.controller = items[1].position.controller
			updateHelperRadius()
			freeze helperGizmo
		)
		helperGizmo
	)

	function sanitize = (
		items = (for obj in items WHERE isValidNode obj collect obj) as Array
		getHelperGizmo()
	)

	function findFirstMod = (
		for l in items while mr == undefined do (
			if l.modifiers[#ProOptimizer] != undefined then (
				resolutionModifier = l.modifiers[#ProOptimizer]
			) else (
				mres = for m in l.modifiers WHERE classOf m == MultiRes collect m

				if mres.count != 0 then (
					resolutionModifier = mres[1]
				)
			)
		)
	)

	function wireHelperPos wrapper:undefined = (
		if thislod != undefined AND thislod.wrapper != undefined AND thislod.wrapper.targets.count > 0 then (
			helperGizmo.position.controller = thislod.wrapper.targets[1].position.controller
		) else (
			if wrapper != undefined AND wrapper.targets != undefined AND wrapper.targets.count > 0 then (
				helperGizmo.position.controller = wrapper.targets[1].position.controller
			) else (
				if items.count > 0 then (
					helperGizmo.position.controller = items[1].position.controller
				)
			)

		)

	)

	function getMetric = (
		getGlobalWWVars()
		getHelperGizmo()
		metric = (floor (helperGizmo.radius * 100 * (2 * (tan(::wwmt_FOV / 2)))) / ::wwmt_horizontalRes)
	)

	function updateHelperRadius resetMetric:true = (
		getNode()
		helperGizmo.radius = distance helperGizmo thisNode
		if resetMetric then (
			getMetric()
		)
	)

	function setRadiusChanger = (
		getNode()
		when transform thisNode changes id:#wallwormlodchangehandler handleAt:#redrawViews obj do (obj.updateHelperRadius())

	)

	function setRadiusFromMetric metric = (
		if metric == undefined then(
			getMetric()
		)

		if metric != undefined AND metric != 0 then (
			getNode()
			if isValidNode thisNode then (
				getGlobalWWVars()

				vect = (normalize (thisNode.transform.position - helperGizmo.transform.position))
				in coordsys world thisNode.position = helperGizmo.transform.position + (vect * ((1.0 / 200.0) * (metric as Float) * ::wwmt_horizontalRes * (1 / tan(::wwmt_FOV / 2))))
			)

		)
	)

	function toggleRadiusVisibility = (
		getHelperGizmo()
		if isValidNode helperGizmo then (
			if helperGizmo.isHiddenInVpt == true then (
				helperGizmo.isHidden = false
			) else (
				helperGizmo.isHidden = true
			)

			forcecompleteredraw()
			true
		) else (
			false
		)
	)

	function get_lod refresh:false = (
		if thislod == undefined OR refresh == true then (
			global ww_lod
			if ww_lod == undefined then (
				if (::wallworm_installation_path == undefined) then (
					::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
				)

				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_struct_lod.ms")
			)
			getNode()
			thislod = ww_lod()
			thislod.helperTape = thisNode
			thislod.helperGizmo = helperGizmo
			thislod.level = level
			thislod.items = (items as Array)
			thislod.metric = metric
		)
		thislod
	)

	function createMaterial = (
		if helperGizmo != undefined then (
			gizmoColorName = "ww_helper_color_LOD_" + level as String
			mat = Standardmaterial name: gizmoColorName
			local v = 255 - ((level * 10))
			--dist = (255/toValue)
			--v = 255 - (level * dist)
			wireColor = (Color v v 0)
			pointColor = (Color 0 v v)
			--item.wirecolor =  wireColor
			mat.Diffuse = wireColor
			mat.ambient = wireColor
			mat.wire = on
			theShell = Shell_Material name:("wwmt_LOD_material_store_" + level as String) bakedMaterial:undefined
			theShell.originalMaterial = mat
			helperGizmo.material = theShell
		)
	)

	function makeMatShell = (
		if helperGizmo.mat == undefined OR classOf helperGizmo.mat != Shell_Material then (
			createMaterial()
		)
	)

	function testMaterial m = (
		if classOf m == Shell_Material AND m.bakedMaterial != undefined then (
			if classOf m.bakedMaterial == Standard OR classOf m.bakedMaterial == MultiMaterial then (
				true
			) else (
				false
			)
		) else (
			false
		)
	)
	function testForExport m = (
		if classOf m == Standard OR classOf m == MultiMaterial OR classOf m == Shell_Material then (
			if classOf m == Shell_Material AND m.bakedMaterial != undefined AND classOf m.bakedMaterial == Standard then (
				true

			) else if (classOf m == Shell_Material AND classOf m.bakedMaterial == MultiMaterial) then (
				local found = false
				for ma in m.bakedMaterial.materialList while found == false do (
					found = testForExport ma
				)
				found
			) else (
				true
			)
		) else (
			false
		)
	)

	function setLODMaterial m = (
		makeMatShell()
		if classOf m == Standard OR classOf m == MultiMaterial OR classOf m == Shell_Material then (
			helperGizmo.mat.bakedMaterial = m
			true
		) else (
			false
		)
	)

	rollout main "LOD Parameters" (
		Group "WWMT Helpers" (
			Spinner sp_vertPercent "Vertex Percent" tooltip:"Vertex Percent for the multiRes/ProOptimizer modifiers associated with this LOD."
			Button btn_ToggleRadiusVis "Toggle Radius Visibility"
			Button hidItems "Hide Mesh(es)"
			Button showItems "Show Mesh(es)"
		)
		Group "QC Options" (
			Spinner sp_metric "LOD Threshold" range:[0.01, 1024, 1] tooltip:"The actual threshhold for the LOD as written in the QC file."
			CheckBox chkNoFacial "No Facial"
			CheckBox chkIsShadowLOD "Use as $shadowlod"
		)

		on main open do (
			sanitize()
			setRadiusChanger()
		)

		on btn_ToggleRadiusVis pressed do (
			toggleRadiusVisibility()
		)

		on sp_vertPercent changed val do (
			findFirstMod()
			if resolutionModifier != undefined then (
				resolutionModifier.vertexPercent = vertexPercent
			)
		)
		on hidItems pressed do (
			sanitize()
			if (items as Array).count > 0 then (
				hide (items as Array)
				forcecompleteredraw()
			)
		)

		on showItems pressed do (
			sanitize()
			if (items as Array).count > 0 then (
				unhide (items as Array)
				forcecompleteredraw()
			)
		)
	)
)

function wallworm_update_lods_cas obj newDef:newDef = (
	if newDef == undefined then (
		global wallworm_lod_CA
		newDef = (custAttributes.getDefSource wallworm_lod_CA)
	)
	--disableRefMsgs()
	with undo off
	with redraw off (
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		local out = false

		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i

				if matchPattern def.name pattern:"*Wallworm LOD" then (
					custAttributes.redefine def newDef

				)

			)
		)
	)
	--enableRefMsgs()
	out
)

function wallworm_update_all_lods_cas = (
	global wallworm_lod_CA
	local newDef = custAttributes.getDefSource wallworm_lod_CA
	for obj in objects WHERE isProperty obj #wwmt_lod AND isProperty obj #wallworm do (
		wallworm_update_lods_cas obj newDef:newDef
	)
)