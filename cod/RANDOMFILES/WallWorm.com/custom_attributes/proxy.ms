::wallworm_proxyskin_holderCA = attributes "WWMTProxy" version:20 (
	local wallworm = true
	local wallwormProxy = true
	local wwmt
	local thisNode, getNode, getWWMT, updateWWMTSkin, updateSkinNum, updateWwmtSkinMaterial, proxParam,hull,getWWMT,getActualMaterail
	function getNode = (
		if NOT isValidNode thisNode then (
			thisNode = refs.dependentnodes (custAttributes.getOwner this) firstonly:on
		)
		thisNode
	)
	parameters params rollout:proxParam (
		wwmtTarget type:#node animatable:false subAnim:false
		wwmtSkinMaterial type:#material
		wwmtSkinNum type:#integer ui:skinspin default:0
		sequenceNames type:#stringTab TabSizevariable:true
		bgNames type:#stringTab TabSizevariable:true
		proxybodygroup type:#string default:""
		proxynimation type:#string default:"idle"
		exclude_vmf type:#boolean default:false ui:chk_exclude_vmf
		on wwmtSkinNum set val do (
			getNode()
			if isValidNode thisNode then (
				if wwmtSkinMaterial == undefined then (
					local updateSkinNum
					if isProperty thisNode #EntityType AND thisNode.entityType == "PointClass" then (
						updateSkinNum = false
					) else (
						updateSkinNum = true
					)
					updateWwmtSkinMaterial doUpdateSkinNum:updateSkinNum
				)
				if wwmtSkinMaterial != undefined then (
					local theMat = getActualMaterail wwmtSkinMaterial
					if theMat[val + 1] != undefined then (
						thisNode.mat = theMat[val + 1]
					)
				)
				if isProperty thisNode #EntityType AND thisNode.entityType == "PointClass" then (
					local custAttribName = ("WW_Entity_" + thisNode.entName)
					if isProperty thisNode custAttribName then (
						local ent = getProperty thisNode custAttribName
						if isProperty ent #Skin then (
							ent.Skin = val
						)
					)
				)
			)
		)
		on wwmtSkinMaterial set val do (
			updateWwmtSkinMaterial doUpdateSkinNum:true
		)
		on proxybodygroup set val do (
			getNode()
			if isValidNode thisNode then (
				if isProperty thisNode #EntityType AND thisNode.entityType == "PointClass" then (
					local custAttribName = ("WW_Entity_" + thisNode.entName)
					if isProperty thisNode custAttribName then (
						local ent = getProperty thisNode custAttribName
						if isProperty ent #body then (
							ent.body = findItem bgNames val
						)
					)
				)
			)
		)
		on proxynimation set val do (
			getNode()
			if isValidNode thisNode then (
				if isProperty thisNode #EntityType AND thisNode.entityType == "PointClass" then (
					local custAttribName = ("WW_Entity_" + thisNode.entName)
					if isProperty thisNode custAttribName then (
						local ent = getProperty thisNode custAttribName
						if isProperty ent #DefaultAnim then (
							ent.DefaultAnim = val
						)
					)
				)
			)
		)
	)
	
	function getWWMT refresh:false = (
		getNode()
		if wwmt == undefined OR refresh == true then (
			if NOT isValidNode wwmtTarget AND isValidNode thisNode then (
				--Look for a userPropValue
				local targetName = getUserProp thisNode #wwmt_proxie_source
				if targetName != undefined then (
					wwmtTarget = getNodeByName targetName
				)
			)
			if isValidNode wwmtTarget then (
				wwmtTarget.getWWMT()
				wwmt = wwmtTarget.wwmt
			)
		)
		wwmt
	)
	
	/*
	Set the wwmt property in cases where the WWMT object is in an XRef Scene
	*/
	function setWWMT ww = (
		if ww != undefined AND classof ww == ww_lod then (
			wwmt = ww
		)
	)

	function getBodygroupNames = (
		local bgs
		if wwmt == undefined AND getWWMT != undefined then (getWWMT())
		if wwmt == undefined OR classOf wwmt != ::ww_LOD_wrapper then (
			bgs = #()
		) else (
			wwmt.populateBodyGroups()
			bgs = for b in wwmt.bodygroups collect b.bgName
		)
		bgs
	)

	function getSequenceNames = (
		local seqs
		if wwmt == undefined AND getWWMT != undefined then (getWWMT())
		if wwmt == undefined OR classOf wwmt != ::ww_LOD_wrapper then (
			seqs = #("idle")
		) else (
			seqs = for s in wwmt.sequences collect s.sequence
		)
		if findItem seqs "idle"== 0 then (
			append seqs "idle" 
		)
		sort seqs
		seqs
	)
	function getOtherProxies = (
		local newProxies = #()
		getWWMT()
		if  wwmt != undefined then (
			newProxies = wwmt.getProxies()
		)
		newProxies
	)
	function getActualMaterail mat = (
		if classOf mat == XRefMaterial then (
			mat = mat.GetSourceMaterial true
		)
		mat
	)
	function makeHullHere = (
		getWWMT()
		if wwmt != undefined AND wwmt.hulls.count > 0 then (
			local hullobjs = for obj in wwmt.hulls collect copy obj
			if ::wallworm_merge_hulls == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			if ::wallworm_merge_hulls != undefined then (
				local temphull = ::wallworm_merge_hulls thehulls:hullobjs
				if isValidNode temphull then (
					hull = temphull
					hull.pivot = wwmt.targets[1].pivot
					hull.transform = thisNode.transform
					hull.parent = thisNode
					hull.name = uniquename (wwmt.modelName+"ProxyHull")
				)
			)
		)
		hull		
	)
	function getHull make:true = (
		if NOT isValidNode hull then (
			getNode()
			local c = thisNode.children.count
			local hull
			if c > 0 then (
				for i = 1 to c WHILE NOT isValidNode hull do (
					if matchPattern thisNode.children[i].name pattern:"*ProxyHull*" then (
						hull = thisNode.children[i]
					)
				)
			)
		)
		if NOT isValidNode hull then (
			makeHullHere()
		)
		hull
	)
	
	function updateBodyList = (
		bgNames = getBodygroupNames()
		proxParam.cmbBody.items = bgNames as Array
		proxParam.cmbBody.selection = findItem bgNames proxybodygroup
	)
	function updateAnimationList = (
		sequenceNames = getSequenceNames()
		proxParam.cmbAnimation.items = (sequenceNames as Array)
		proxParam.cmbAnimation.selection = findItem sequenceNames proxynimation
	)

	function updateSkinNum = (
		getNode()
		local proxyMat = getActualMaterail thisNode.mat
		if proxyMat == undefined then (
			if wwmtSkinMaterial != undefined then (
				if wwmtSkinMaterial[wwmtSkinNum + 1] != undefined then (
					thisNode.mat = wwmtSkinMaterial[wwmtSkinNum + 1]
				) else (
					thisNode.mat = wwmtSkinMaterial[1]
					wwmtSkinNum = 0
				)
			)
		) else (
			local noskinmatch = true
			if wwmtSkinMaterial != undefined then (
				for mi = 1 to wwmtSkinMaterial.numsubs while noskinmatch do (
					if wwmtSkinMaterial[mi] != undefined AND (wwmtSkinMaterial[mi] == proxyMat OR  wwmtSkinMaterial[mi].name == proxyMat.name) then (
						wwmtSkinNum = (mi - 1)
						noskinmatch = false
					)
				)
				if noskinmatch == true then (
					try (
						local nextSub = wwmtSkinMaterial.numsubs + 1
						wwmtSkinMaterial[nextSub] = proxyMat
						wwmtSkinNum = nextSub - 1
					) catch ()
				)				
			)

		)
	)

	function updateWwmtSkinMaterial doUpdateSkinNum:true = (
		getWWMT()
		if isValidNode wwmtTarget then (
			theMat = getActualMaterail wwmtTarget.mat
			if classOf theMat == MultiMaterial then (
				wwmtSkinMaterial = theMat
				if doUpdateSkinNum then (
					updateSkinNum()
				)
			)
		)
	)

	function updateWWMTSkin doUpdateSkinNum:true = (
		getWWMT()
		wwmt.gatherMySkins updateSkinNums:true
		updateWwmtSkinMaterial doUpdateSkinNum:doUpdateSkinNum
	)

	rollout proxParam "Proxy Functions" (
		Group "Prop Controls" (
			Spinner skinspin "Skin" default:0 range:[0, 100, 0] type:#integer
			ComboBox cmbBody "Body Group" items:(bgNames as Array)
			Button btnUpdateComboboxlist "Update Bodygroup List"
			ComboBox cmbAnimation "Animation" items:(sequenceNames as Array)
			Button btnpdateAnimationList "Update Animation List"
		)
		Button updateWWMTSkins "Update WWMT Skins" tooltip:"Update the Skin Material for the WWMT controlling this Proxy."
		Button getSkinMatFromWWMT "Get Skin from WWMT" tooltip:"Update the skins available for this proxy from the WWMT skin material."
		Button selectWWMTHelper "Select WWMT" tooltip:"Select the WWMT for this Proxy."
		Button refreshMeshFromWWMT "Update Mesh" tooltip:"Update the mesh for this proxy based on the WWMT model's mesh."
		DropDownList lbsetProp "Tie To Prop Entitiy" items:#("", "prop_detail", "prop_door_rotating", "prop_dynamic", "prop_dynamic_glow", "prop_dynamic_ornament", "prop_dynamic_override", "prop_hallucination", "prop_physics", "prop_physics_multiplayer", "prop_physics_override", "prop_ragdoll", "prop_static", "prop_vehicle", "prop_vehicle_driveable")
		CheckBox chk_exclude_vmf "Exclude From VMF" tooltip:"Do not export in VMF. Useful when this proxy is a helper for other systems like a Forest or PropLine."
		Button btnSelectAll "Select Sibling Proxies" tooltip:"Select all the Proxies in the scene that are derived from the same WWMT model."
		Button btnGetHull "Get Hull Mesh" tooltip:"Create a copy of the model's hull at this location."
		on btnGetHull pressed do (
			getHull()
			if isValidNode hull then (
				unhide hull
			)
		)
		on btnSelectAll pressed do (
			local proxies = getOtherProxies()
			if proxies.count > 0 then (
				select proxies
			)
		)
		on cmbBody selected val do (
			proxybodygroup = cmbBody.selected
		)
		on cmbAnimation selected val do (
			proxynimation = cmbAnimation.selected
		)
		on cmbBody rightClick do (
			proxybodygroup = ""
		)
		on cmbAnimation rightClick do (
			proxynimation = "idle"
		)
		on updateWWMTSkins pressed do (
			updateWwmtSkinMaterial doUpdateSkinNum:true
		)
		on btnUpdateComboboxlist pressed do (
			updateBodyList()
		)
		on btnpdateAnimationList pressed do (
			updateAnimationList()
		)
		on proxParam open do (
			getNode()
			updateSkinNum()
			updateAnimationList()
			updateBodyList()

			if isProperty thisNode #entName then (
				lbsetProp.selection = findItem lbsetProp.items thisNode.entName
			)
			cmbAnimation.selection = findItem sequenceNames proxynimation
			cmbBody.selection = findItem bgNames proxybodygroup
		)
		on lbsetProp selected sel do (
			local entName = lbsetProp.selected
			if entName != "" then (
				if ::wallworm_game_settings == undefined then (
					macros.run "wallworm.com" "wallwormParseFGD2"
				)
				if ::wallworm_game_settings != undefined then (
					local test = ::wallworm_game_settings.get_entity_by_name entName
					if test != undefined AND test.ca != undefined then (
						getNode()
						wallworm_update_entity thisNode test deleteNonEnt:false
						max create mode
						max modify mode
					)
				) else (
					messageBox "The entity definitions are unavailable. Please check your global settings and verify that the FGD path is correct."
				)
			)
		)
		on getSkinMatFromWWMT pressed do (
			updateWwmtSkinMaterial doUpdateSkinNum:true
		)
		on selectWWMTHelper pressed do (
			if isValidNode wwmtTarget then (
				select wwmtTarget
			) else (
				messageBox "There is a problem. The WWMT helper is not assigned."
			)
		)
		on refreshMeshFromWWMT pressed do (
			getNode()
			getWWMT()
			wwmt.updateObjectAsProxy thisNode
		)
	)

	on clone orig do (
		thisNode = undefined
		hull = undefined
	)
)