--LOD Struct
if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
)
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/lod.ms")

struct ww_lod (
	item,
	items = #(),
	level,
	helperGizmo,
	helperTape,
	wireColor,
	wrapper,
	metric,
	mr,
	res,
	hlayer = "wwmt_helpers",
	nofacial = false,
	shadowlod = false,
	function getAllObjects = (
		local out = for i in items WHERE isValidNode i collect i
		if isValidNode helperTape then (
			append out helperTape
		)
		if isValidNode helperGizmo then (
			append out helperGizmo
		)
		out
	),
	function deleteLOD deleteItems:true = (
		if theHold.Holding() == false then (
			theHold.Begin()
		)
		if deleteItems == true AND items.count > 0 then (
			for i in items do (
				if isValidNode i then (
					delete i
				)
			)
		)
		if isValidNode helperTape AND wrapper.target.lods.count > 0 then (
			lc = findItem wrapper.target.lods findItem
			if lc > 0 then (
				deleteItem wrapper.target.lods lc
			)
			delete helperTape
		)
		if isValidNode helperGizmo then (
			delete helperGizmo
		)
		if theHold.Holding() == false then (
			theHold.Begin()
		)
		theHold.Accept "Delete LODs"
	),
	function findFirstMod = (
		for l in items while mr == undefined do (
			if l.modifiers[#ProOptimizer] != undefined then (
				mr = l.modifiers[#ProOptimizer]
			) else (
				mres = for m in l.modifiers WHERE classOf m == MultiRes collect m
				if mres.count != 0 then (
					mr = mres[1]
				)
			)
		)
	),
	function newMR makeNew:true = (
		findFirstMod()
		if mr == undefined AND makeNew == true then (
			if ::wwmt_LODOptimize == 1 then (
				mr = MultiRes()
			) else (
				mr = ProOptimizer()
				mr.KeepUV = on
			)
			mr.name = wrapper.target.name + "_LOD_" + level as String
		)
	),
	function getMetric = (
		metric = (floor (helperGizmo.radius * 100 * (2 * (tan(::wwmt_FOV / 2)))) / ::wwmt_horizontalRes)
	),
	function setRadiusFromMetric metric = (
		if metric != 0 then (
			vect = (normalize (helperTape.transform.position - helperGizmo.transform.position))
			in coordsys world helperTape.position = helperGizmo.transform.position + (vect * ((1.0 / 200.0) * metric * ::wwmt_horizontalRes * (1 / tan(::wwmt_FOV / 2))))
		)
	),
	function wireHelperPos = (
		helperGizmo.position.controller = wrapper.targets[1].position.controller
	),
	function createMaterial = (
		if helperTape != undefined AND isProperty helperTape #createMaterial then (
			helperTape.createMaterial()
		)
	),
	function makeMatShell = (
		if isProperty helperTape #makeMatShell then (
			helperTape.makeMatShell()
		)
	),
	function testMaterial m = (
		helperTape.testMaterial m
	),
	function testForExport m = (
		if isProperty helpertTape #testForExport then (
			helpertTape.testForExport m
		)
	),
	function setLODMaterial m = (
		helperTape.setLODMaterial m
	),
	function getMatFromOtherLOD = (
		findOtherLOD = true
		for i = 1 to (level) while (findOtherLOD AND (level) > i AND wrapper != undefined) do (
			if wrapper.lods[(level - i)].helperGizmo.mat != undefined AND testMaterial wrapper.lods[(level - i)].helperGizmo.mat == true then (
				helperGizmo.mat = wrapper.lods[(level - i)].helperGizmo.mat
				findOtherLOD = false
			)
		)
	),
	function getHelperGizmo = (
		if NOT isValidNode helperGizmo then (
			local gizmoName = "ww_lod_sphere_" + wrapper.target.name + "_" + level as String
			r = 64 * level
			helperGizmo = Sphere name:(gizmoName) radius:r pos:wrapper.targets[1].position segs:16 renderable:off smooth:off showFrozenInGray:off
			helperTape.helperGizmo = helperGizmo
			helperTape.createMaterial()
			helperGizmo.position.controller = wrapper.targets[1].position.controller
			ww_SetObjLayer helperGizmo hlayer
			freeze helperGizmo
		)
		helperGizmo
	),
	function getHelperTape = (
		if NOT isValidNode helperTape then (
			if wrapper != undefined AND isValidNode wrapper.target then (
				helperTapeName = "LOD_" + wrapper.target.name + "_" + level as String
				helperTape = Point name:helperTapeName pos:wrapper.targets[1].position Box:on centermarker:on cross:off axistripod:off wirecolor:green size:64
				custAttributes.add helperTape wallworm_lod_CA
				helperTape.helperGizmo = getHelperGizmo()
				helperTape.setRadiusChanger()
				helperTape.setRadiusChanger()
				ww_SetObjLayer helperTape hlayer
				movePos = true
			)
		) else (
			if NOT isProperty helperTape #wwmt_lod then (
				custAttributes.add helperTape wallworm_lod_CA
				helperTape.setRadiusChanger()
			)
		)
		helperTape
	),
	function setGizmo toValue = (
		/*Creates a sphere gizmo that is then assigned to the helperGizmo property;
		Binds helperGizmo position to the item property

		The radius of the gizmo controls the distance at which this LOD gets activated
		*/
		if wrapper != undefined AND isValidNode wrapper.target then (
			if wrapper.layer != undefined then (
				hlayer = wrapper.layer + "_helpers"
			) else (
				hlayer = "wwmt_helpers"
			)
			local movePos = false
			getHelperTape()
			helperTape.getHelperGizmo()
			if movePos == true then (
				helperTape.setRadiusFromMetric metric
			)
		)
		if isValidNode helperGizmo then (
			wireHelperPos()
			hide helperGizmo
			freeze helperGizmo
		)
	),
	function sanitize = (
		items = for obj in items WHERE isValidNode obj collect obj
	),

	function appendItem obj = (
		gethelperTape()
		if findItem helperTape.items obj == 0 then (
			append helperTape.items obj
			if mr == undefined then (
				newMR()
			)
			if ::wwmt_LODOptimize != 3 then (
				if classOf mr == MultiRes then (
					mres = for m in obj.modifiers WHERE classOf m == MultiRes collect m
					if mres.count == 0 then (
						addModifier obj mr
					)
				) else (
					if obj.modifiers[#ProOptimizer] == undefined then (
						addModifier obj mr
					)
					if obj.modifiers[#ProOptimizer] != undefined then (
						obj.modifiers[#ProOptimizer].Calculate = off
					)
				)
			)
			sanitize()
			for l in items do (
				select l
				if classOf mr == MultiRes then (
					mres = for m in l.modifiers WHERE classOf m == MultiRes collect m
					if mres.count != 0 then (
						mres[1].reqGenerate = off
					)
				) else (
					if l.modifiers[#ProOptimizer] != undefined then (
						l.modifiers[#ProOptimizer].Calculate = off
					)
				)
			)
			if classOf mr != MultiRes then (
				mr.Calculate = off
				mr.keepUV = on
				mr.Calculate = on
			)
			items = helperTape.items as Array
		)
	),
	function removeItem sel = (
		local removed = 0
		if sel.count != undefined AND sel.count > 0 then (
			for obj in sel do (
				local lc = helperTape.items.count
				if lc > 0 then (
					for c = lc to 1 by -1 do (
						if helperTape.items[c] == obj then (
							deleteItem helperTape.items c
							removed += 1
						)
					)
				)
			)
			items = helperTape.items as Array
			sanitize()
		)
		removed
	),

	function deleteItems deleteMeshes:false = (
		if isValidNode helperGizmo then (
			delete helperGizmo
		)
		if isValidNode helperTape then (
			delete helperTape
		)
		if deleteMeshes then (
			for obj in items WHERE isValidNode obj do (
				delete obj
			)
		)
	),
	function setCustomAttributes = (
		if isValidNode helperTape then (
			if NOT isProperty helperTape #wwmt_lod then (
				custAttributes.add helperTape wallworm_lod_CA
			)
			findFirstMod()
			if helperTape.'Wallworm LOD'.version < 2 then (
				wallworm_update_lods_cas helperTape
			)
			if NOT isValidNode helperGizmo then (
				helperTape.getHelperGizmo()
			)
			helperTape.items = (items as Array)
			helperTape.level = level
			helperTape.helperGizmo = helperGizmo
			if vertexPercent != undefined then (
				helperTape.vertexPercent = vertexPercent
			)
			helperTape.getMetric()
			if mr != undefined then (
				helperTape.multiresname = mr.name
			) else (
				helperTape.multiresname = ("LOD MULTIRES " + (level as String))
			)
			if wrapper != undefined AND wrapper.target != undefined then (
				if findItem wrapper.target.lods helperTape == 0 then (
					append wrapper.target.lods helperTape
				)
			)
		)
	),
	function getMyRes makeNew:true = (
		findFirstMod()
		if mr == undefined then (
			newMR makeNew:makeNew
			mr.vertexPercent
		) else (
			if mr != undefined then (
				mr.vertexPercent
			) else (
				if mr == undefined then (
					helperTape.vertexPercent
				) else (
					newMR()
					mr.vertexPercent
				)
			)
		)
	),
	function setMyRes v = (
		findFirstMod()
		if mr == undefined then (
			getMyRes makeNew:true
		)
		if classOf mr == MultiRes then (
			if mr.reqGenerate == off then (
				setCommandPanelTaskMode mode:#modify
				mr.reqGenerate = on
			)
		) else (
			if mr.Calculate != undefined AND mr.Calculate == off then (
				setCommandPanelTaskMode mode:#modify
				mr.Calculate = on
			)
		)
		mr.vertexPercent = v
		res = v
		helperTape.vertexPercent = res
	)
)
