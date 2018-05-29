global wallworm_cordon_CA = attributes "Wallworm_Cordon" (
	local wallworm = true
	local vmf_exclude = true
	local wallworm_cordon = true
	local thisNode

	function getNode = (
		refs.dependentnodes (custAttributes.getOwner this) firstonly:on
	)

	on clone orig do thisNode = undefined

	function getThisNode = (
		if thisNode == undefined then (
			thisNode = getNode()
		)
		thisNode
	)

	function activate = (
		getThisNode()
		if isValidNode thisNode then (
			activeCordon = true
			thisNode.wireColor = red
		)
	)

	function deactivate = (
		getThisNode()
		if isValidNode thisNode then (
			activeCordon = false
			thisNode.wireColor = Color 220 220 220
		)
	)

	parameters params rollout:paramrollout (
		activeCordon type:#boolean default:true ui:chk_active

		on activeCordon set val do (
			if val then (
				activate()
			) else (
				deactivate()
			)
		)
	)

	rollout paramrollout "Cordon Parameters" (
		CheckBox chk_active "Active Cordon" tooltip:"Check to make this cordon active."
	)

)

global wallworm_mapsize_CA = attributes "Wallworm_Mapsize" version:9 (
	local wallworm = true
	local vmf_exclude = true
	local wallworm_mapsize2 = true
	local thisNode

	function getNode = (
		refs.dependentnodes (custAttributes.getOwner this) firstonly:on
	)

	function getThisNode = (
		if thisNode == undefined then (
			thisNode = getNode()
		)
		thisNode
	)

	parameters params rollout:paramrollout (
		mapversion type:#integer default:1
		fgd type:#filename
		defaultMaterialName type:#string default:"tools/toolsnodraw" ui:edtDefaultMaterialName
		multipleCordons type:#boolean default:true ui:chkmultipleCordons
		escapeOutputs type:#boolean default:false ui:chkEscape
		legacyEntities type:#boolean default:false ui:chkLegacyEnts
		brushCount type:#integer default:0 ui:sp_brushCount
		entCount type:#integer default:0 ui:sp_entCount
		sideCount type:#integer default:0 ui:sp_sideCount
		dispCount type:#integer default:0 ui:sp_dispCount
	)

	function updateLimits = (
		getThisNode()

		if ::wallworm_mapsize == undefined OR classOf ::wallworm_mapsize != Point2 then (
			::wallworm_mapsize = [-16384, 16384]
		)

		thisNode.transform = Matrix3 1
		thisNode.parent = undefined
		local sz = ::wallworm_mapsize[2] * 2

		thisNode.boxsize = [sz, sz, sz]
		setTransformLockFlags thisNode #all

		if ::wwmt_def_fgd != undefined then (
			fgd = ::wwmt_def_fgd
		)

	)

	rollout paramrollout "Map Parameters" (
		Label lblFile "FGD Used"
		Label lblFile2 ""
		Group "VMF Options" (
			Label lblMatName "Default Material Name"
			EditText edtDefaultMaterialName ""
			CheckBox chkmultipleCordons "Multiple Cordons" tooltip:"Output the VMF with the multiple cordon format."
			CheckBox chkEscape "Escape Outputs" tooltip:"Export with the ESC command separator in the VMF."
			CheckBox chkLegacyEnts "Legacy Entities" tooltip:"Look for legacy entities in the scene. Only use this if you have entities created by Convexity."
		)
		Group "Last Export Statistics" (
			Spinner sp_brushCount "Brushes:" enabled:false type:#integer range:[0,9999999,0]
			Spinner sp_dispCount "Displacements:" enabled:false type:#integer range:[0,9999999,0] 
			Spinner sp_sideCount "Sides:" enabled:false type:#integer range:[0,9999999,0] 
			Spinner sp_entCount "Entities:" enabled:false type:#integer range:[0,9999999,0] 
		)
		
		Button btnCordons "Cordon Manager"
		Button btnReset "Reset Map Limits"
		Button btnMapProperties "Open Map Properties"

		on btnCordons pressed do (
			macros.run "wallworm.com" "WallWormCordonManagerMCR"
		)

		on paramrollout open do (
			getThisNode()
			updateLimits()

			if fgd != undefined AND fgd != "" then (
				lblFile2.text = (filenameFromPath fgd)

			)

		)
		on btnReset pressed do (
			updateLimits()
		)
		on btnMapProperties pressed do (
			global wallworm_map_properties_show = true
			macros.run "wallworm.com" "WallWormEntityOutputsMCR"
		)

	)

)

function wallworm_get_map_limits cvx:false = (
	local res = for obj in helpers WHERE isProperty obj #'Wallworm_Mapsize' collect obj

	if res.count == 0 AND cvx == true then (
		res = for obj in objects WHERE getUserProp obj #CVXBorder == 1 collect obj
	)
	res
)

function wallworm_create_map_limits showLimits:false = (
	local mp = wallworm_get_map_limits()
	local mapsize
	if mp.count == 0 then (
		mapsize = dummy()
		mapsize.name = "Map Limits"
		custAttributes.add mapsize wallworm_mapsize_CA
		mapsize.isHidden = NOT showLimits
	) else (
		mapsize = mp[1]
	)
	mapsize.updateLimits()
	if ::ww_SetObjLayer != undefined then (
		::ww_SetObjLayer mapsize "VMF_Exclude" forceFunc:true
	)
	mapsize
)
