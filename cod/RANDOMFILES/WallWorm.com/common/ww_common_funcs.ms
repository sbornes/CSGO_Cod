/*

Common Functions in Wall Worm Tools
http://www.wallworm.com 

Copyright (c) 2011-2015 by Shawn Olson
http://www.shawnolson.net

Most functions by Shawn Olson and Orvid King

If a function is from elsewhere or derived from another source, it is usually listed in a comment above the function.

Thanks to Denis Trofimov, Kostadin Kotev and others for a lot of random help.

*/

if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

/*Force a value to be boolean*/
function wallworm_makeBoolean v def:false = (
	local out
	case of (
		(v == true):out = v
		(v == false):out = v
		(v == "true"):out = true
		(v == "false"):out = false
		(v == on):out = true
		(v == off):out == false
		(v == 1):out = true
		(v == 0):out == false
		default:(
			if def != true AND def != false then (
				def = false
			)
			out = def
		)
	)
	out
)

/*
Function from discussion at http://forums.cgsociety.org/showthread.php?f=98&t=1131972
*/
function wallworm_klunk_ToggleMaxRedraw arg disablerefs:false resumeEdit:false =
(
	if arg == 1 then
	(
		cui.CommandPanelOpen = true
		enableSceneRedraw()
		enableRefMsgs()
		if resumeEdit then (
			resumeEditing()
		)
	)
	else
	(
		disableSceneRedraw()
		if disablerefs then (
			disableRefMsgs()
		)
	)
	WM_SETREDRAW = 0xB
	hwnd = (windows.getChildHWND #max "Command Panel")

	-- is the command panel floating ?	

	if hwnd == undefined then -- this doesn't really work because when floating I think max/windows turns redraw back on somewhere 
	hwnd = (windows.getChildHWND (windows.getDesktopHWND()) "Command Panel")
	-- works with disableRefMsgs() though ! :)

	-- if something didn't go wrong !

	if hwnd != undefined then
	windows.sendmessage (hwnd[1]) WM_SETREDRAW arg 0
)

/*Function return a randomized copy of an array*/
function wallworm_randomize_array ar = (
	startArrayCount = ar.count
	ar2 = #()

	while ar2.count != startArrayCount do (
		index = random 1 ar.count

		append ar2 ar[index]

		deleteItem ar index

	)
	ar2
)

function wallworm_fix_tiny_float f limit:0.0001 = (
	::wallworm_performanceCounter_start #common #wallworm_fix_tiny_float
	if ((Abs f) - limit < 0) then (
		f = 0
	)
	::wallworm_performanceCounter_stop #common #wallworm_fix_tiny_float
	f
)

function wwmt_smd_exporters_installed = (
	local smdExporters = 0
	local wunderboySMDExporterInstalled = false
	local cannonfodderSMDExporterInstalled = false
	for c in exporterPlugin.classes while smdExporters < 3 do (
		if c == SMDExporter then (
			smdExporters += 1
		)
		if c == SmdExport then (
			smdExporters += 2
		)
	)
	smdExporters
)

/*Function will set the value of vals array to val based on the index of prop in props. 
Useful for datasets stored in two arrays where one array is a named index for the values stored in another array.
This function is helpful because there are no named indexes in MXS arrays and you don't always want to create a struct.

props and vals should be arrays.
*/
function wallworm_set_kvarrays &props &vals prop val checkMatch:true = (
	if checkMatch == true AND props.count != vals.count then (
		/*Stop the function if the props and vals array aren't the same length... as this probably means bad data.*/
		false
	) else (
		local currentPos = findItem props prop
		if currentPos != 0 then (
			vals[currentPos] = val
		) else (
			append props prop
			append vals val

		)
		true
	)
)

function wallworm_get_modifierByClass obj modclass = (
	local m
	local mods = obj.modifiers
	local mCount = mods.count
	if mCount > 0 then (
		for i = 1 to mCount while m == undefined do (
			if classOf mods[i] == modclass then (
				m = mods[i]
			)
		)
	)
	m
)

struct xpecSkinOpsDef (
	--http://tech-artists.org/forum/showthread.php?t=692
	function getBoneNames skinMod = (
		local cnt = skinOps.getNumberBones skinMod

		for i = 1 to cnt collect ::wallworm_skinops_getBoneNameByListID skinMod i 1
	),
	function getBoneId skinMod boneName = (
		findItem (getBoneNames skinMod) boneName
	),
	function getVertexWeightBoneIdByName skinMod vert boneName = (
		skinOps.getVertexWeightBoneId skinMod vert (getBoneId skinMod boneName)
	)
)

function wallworm_getBonesFromSkin theSkin =
(
	--local boneArray = for o in objects WHERE (refs.dependencyLoopTest theSkin o) collect o
	local boneArray = for n in (refs.dependson theSkin) WHERE isValidNode n collect n
)

function getBoneFromSkin theSkin boneID boneArray:undefined sysInt:1 =
(
	--http://forums.cgsociety.org/archive/index.php/t-779310.html
	if boneArray == undefined then (
		local boneArray = for o in objects WHERE (refs.dependencyLoopTest theSkin o) collect o
	)
	local boneName = (skinOps.GetBoneName theSkin boneID sysInt)
	local notFound = true
	local i = 0
	while notFound AND i < boneArray.count do
	(
		i += 1
		if boneArray[i].name == boneName then notFound = false
	)
	if notFound then undefined else boneArray[i]
)

global xpecSkinOps = xpecSkinOpsDef()

function wallworm_slash_start str = (
	local badstart = #("r", "t", "n")
	if findItem badstart str[1] != 0 then (
		str = "\\" + str
	)
	str
)

function wallworm_escape_string str = (
	str = substituteString str "\r" "\\r"
	str = substituteString str "\n" "\\n"
	str = substituteString str "\t" "\\t"
	str = substituteString str "\x" "\\x"
	str = substituteString str "/r" "\/r"
	str = substituteString str "/n" "\/n"
	str = substituteString str "/t" "\/t"
	str = substituteString str "/x" "\/x"
	str
)

function wallworm_FsToBs s = (
	if s != undefined then (
		s = copy s
		local r = s.count
		for i = 1 to r do (
			if s[i] == "/" then (
				s[i] = "\\"
			)
		)
	)
	s
)

function wallworm_bsToFs s = (
	if s == undefined then (
		s = ""
	) else (
		s = copy s
		local r = s.count
		for i = 1 to r do (
			if s[i] == "\\" then (
				s[i] = "/"
			)
		)
	)
	s
)

function wallworm_clean_decimals n = (
	if n < 0.0001 AND n > -0.0001 then (
		n = 0
	)
	n
)

function wallworm_string_remove_duplicate inputstring lookfor = (
	local lookForTwo = lookfor + lookfor
	local lookForTwoLength = lookForTwo.count
	local curIdx = findString inputstring lookForTwo
	while curIdx != undefined do (
		inputstring = replace inputstring curIdx lookForTwoLength lookfor
		curIdx = findString inputstring lookForTwo
	)
	free lookForTwo
	inputstring
)

function wallworm_safe_bitmappath inp = (
	inp = copy inp
	local r = inp.count
	for i = 1 to r do (
		local c = inp[i]
		if (c == "%" OR c == "#") then (
			inp[i] = "_"
		)
	)
	inp
)

function wallworm_safe_path p escape:false = (
	p = wallworm_bsToFs p
	p = wallworm_string_remove_duplicate p "/"
	p = wallworm_safe_bitmappath p
	p = trimLeft p
	p = trimRight p
	if escape then (
		p = wallworm_escape_string p
	)
	p
)

function wallworm_safe_local p escape:false= (
	p = wallworm_FsToBs p
	p = wallworm_string_remove_duplicate p "\\\\"
	p = wallworm_safe_bitmappath p
	p = trimLeft p
	p = trimRight p
	if escape then (
		p = wallworm_escape_string p
	)
	p
)

function wallworm_makeStringSafe inp = (
	inp = copy inp
	local r = inp.count
	for i = 1 to r do (
		local c = inp[i]
		if (c == "." OR c == " " OR c == "/" OR c == "\\" OR c == "%" OR c == "#") then (
			inp[i] = "_"
		)
	)
	inp
)

function wallworm_get_hierarchy_root nd = (
	if (isValidNode nd.parent) then (
		wallworm_get_hierarchy_root nd.parent
	) else (
		nd
	)
)

function wallworm_getAllChildren nd &collection = (
	if collection == undefined then (
		collection = #()
	)
	local ch = nd.children
	if ch.count > 0 then (
		join collection (for obj in ch WHERE findItem collection obj == 0 collect obj)

		for obj in ch do (
			wallworm_getAllChildren obj &collection
		)
	)
)

function wwmt_findGroupHead obj = (
	if isGroupHead obj then (
		obj
	) else if isGroupMember obj then (
		wwmt_findGroupHead obj.parent
	) else (
		undefined
	)
)

function wallworm_getAllChildrenInGroup grp &res = (
	local ch = grp.children
	if ch.count > 0 then (
		join res (for obj in ch WHERE isGroupHead obj == false collect obj)

		for obj in ch WHERE isGroupHead obj == true do (
			wallworm_getAllChildrenInGroup obj &res
		)
	)
)

function wallworm_binSet type = (
	if ::WallWormBinSetTest == undefined then (
		::WallWormBinSetTest = false
	)
	if ::WallWormBinSetTest == false then (
		if type == "tex" then (
			if ::WallwormProActive == true AND ::WallWormVTFCmdPath != undefined AND doesFileExist ::WallWormVTFCmdPath then (
				::WallWormBinSetTest = true
			) else (
				if ::wwmt_binDir != undefined then (
					studiopath = ::wwmt_binDir + "\\" + "vtex.exe"
					if doesFileExist studiopath then (
						::WallWormBinSetTest = true
					) else (
						::WallWormBinSetTest = (::wallworm_engine == 1 OR doesFileExist (::wwmt_binDir + "\\" + "wallworm_hl.txt"))
					)
				)	
			)
		) else if type == "model" do (
			if ::wwmt_binDir != undefined then (
				studiopath = ::wwmt_binDir + "\\" + "studiomdl.exe"
				if doesFileExist studiopath then (
					::WallWormBinSetTest = true
				)
			)
		)
	)
	::WallWormBinSetTest
)

function wallworm_remove_last_slash matName forModel:false char:"/" = (
	if matName == undefined OR matName == "" then (
		""
	) else if (substring matName matName.count 1) == char then (
		substring matName 1 (matName.count - 1)
	) else (
		matName
	)
)

function wallworm_remove_first_slash matName forModel:false char:"/" = (
	if matName == undefined OR matName == "" then (
		""
	) else if (substring matName 1 1) == char then (
		substring matName 2 matName.count
	) else (
		matName
	)
)

function wwmt_count_hulls hullobjs concave = (
	local count = 0
	hullobjs = makeUniqueArray hullobjs
	hullobjs = for c in hullobjs WHERE isValidNode c collect c
	if concave == true then (
		if ::wallwormGetElements == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormHullFuncs.mse")
		)
		for obj in hullobjs do (
			count += (::wallwormGetElements obj).count
		)
	) else (
		count = hullobjs.count
	)
	count
)

function wwmt_get_rotation r = (
	if r <= 360 AND r >= -360 then (
		r
	) else (
		mod r 360
	)
)

function wwmt_group_warning obj = (
	if isGroupMember obj then (
		false
	) else (
		true
	)
)

function wwmt_bitarray_value ba = (
	local v = 0
	for bv in ba do (
		v += bv
	)
	v
)

function wwmt_bitarray_int ba = (
	local out = 0
	local v = 1
	for bv = 1 to ba.count do (
		if (findItem ba bv) != 0 then (
			out += v
		)

		v *= 2
	)
	out
)

function wallworm_getXrefs &collection &ref = (
	local gfc = xrefs.getXRefFileCount
	local xrefsgetXRefFile = xrefs.getXRefFile
	if ref != undefined then (
		for index = 1 to gfc root:ref do(
			local xref = xrefsgetXRefFile index root:ref
			if xref.disabled == false then (
				if findItem collection (xref) == 0 then (
					append collection xref
				)
				wallworm_getXrefs collection xref
			)
		)
	) else (
		for index = 1 to gfc() do(
			local xref = xrefsgetXRefFile index
			if xref.disabled == false then (
				append collection xref
				wallworm_getXrefs collection xref
			)
		)
	)
)

/*
this function is necessary when deriving userprop values from some objects derived from XRef scenes.
*/
function ww_getUserProp obj property xref:undefined = (
	local out = undefined
	if isValidNode obj AND classOf obj != MAXRootNode then (
		if xref == undefined then (
			out = getUserProp obj property
		) else (
			property = property as String
			local childIndex = 1
			for childIndex = 1 to xref.count while out == undefined do (
				if obj == xref[childIndex] then (
					out = getUserProp xref[childIndex] property
				)
			)
		)
	)
	out
)

/*
This function is not safe because there is no guarantee that there is only one node with the given name.
*/
function ww_getNodeByName name xref:undefined = (
	local out = undefined
	if xref == undefined then (
		out = getNodeByName name
	) else (
		local childIndex = 1
		for childIndex = 1 to xref.count while out == undefined do (
			if xref[childIndex].name == name then (
				out = xref[childIndex]
			)
		)
	)
	out
)

function ww_isProperty obj property xref:undefined = (
	local out = false
	if obj != undefined then (
		if xref == undefined then (
			out = isProperty obj property
		) else (
			property = property as String
			local childIndex = 1
			for childIndex = 1 to xref.count do (
				if obj == xref[childIndex] then (
					out = isProperty xref[childIndex] property
				)

			)

		)
	)
	out
)

/*
This function will return every object that is a child of the root (an XRef Scene).
*/
function wallworm_collect_children root &collection skipNonVMFObjects:false removeHidden:false = (
	if collection == undefined then (
		collection = #()
	)

	local theChildren = for obj in root WHERE classOf obj != MAXRootNode collect obj

	join collection theChildren

	for obj in theChildren WHERE obj.children.count > 0 do (
		wallworm_collect_children obj.children &collection skipNonVMFObjects:skipNonVMFObjects removeHidden:removeHidden
	)

)

/*
This function will return every object in the scene and all XRef Scenes.
*/
function wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true useSceneCache:false = (
	objs = #()
	::wallworm_performanceCounter_start #collection #'wallworm_get_all_objects'
	if (NOT useSceneCache) OR ::wallwormXREFsObjectCache == undefined OR ::wallwormXREFsObjectCache.count == 0 then (
		::wallworm_performanceCounter_start #collection #'wallworm_get_all_collect_from_xref'
		refCollection = #()
		wallworm_getXrefs refCollection undefined
		local alreadyIncluded = #()
		for ref in refCollection do (
			::wallworm_performanceCounter_start #collection #'wallworm_get_all_collect_from_xref-file'
			if findItem alreadyIncluded ref.filename == 0 then (
				wallworm_collect_children ref.tree.children objs skipNonVMFObjects:skipNonVMFObjects removeHidden:removeHidden
				append alreadyIncluded ref.filename
			)
			::wallworm_performanceCounter_stop #collection #'wallworm_get_all_collect_from_xref-file'
		)		
		::wallwormXREFsObjectCache = deepcopy objs
		::wallworm_performanceCounter_stop #collection #'wallworm_get_all_collect_from_xref'
	) else (
		if ::wallwormXREFsObjectCache != undefined AND ::wallwormXREFsObjectCache.count > 0 then (
			objs = deepcopy ::wallwormXREFsObjectCache
		)
	)

	
	
	if includeScene then (
		local theChildren = objects as Array
		if theChildren.count > 0 then (
			join objs theChildren
		)
	)

	if removeHidden then (
		::wallworm_performanceCounter_start #collection #'wallworm_get_all_collect_find_hidden'
		local sculptMeshesToCheck = for obj in objs WHERE isProperty obj #wallworm_edit_mesh AND obj.isHidden == false collect obj

		/*find sculpt meshes that are not hidden and exlude all */
		local dispsPsuedoHidden = #()
		if sculptMeshesToCheck.count > 0 then (
			for sm in sculptMeshesToCheck do (
				join dispsPsuedoHidden sm.displist
			)
		)
		
		dispsPsuedoHidden = makeUniqueArray dispsPsuedoHidden
		objs = for obj in objs WHERE (obj.isHidden == false OR findItem dispsPsuedoHidden obj != 0) collect obj
		::wallworm_performanceCounter_stop #collection #'wallworm_get_all_collect_find_hidden'
	)

	if skipNonVMFObjects then (
		::wallworm_performanceCounter_start #collection #'wallworm_get_all_collect_find_hidden-nonvmf'
		local tmp = #()
		for obj in objs do (
			case of (
				(isProperty obj #ww_displacement_brush):()
				(isProperty obj #wallworm_edit_mesh):()
				(isProperty obj #vmf_exclude AND obj.vmf_exclude == true):()
				(isProperty obj #vmf_export AND obj.vmf_export == false):()
				default:(
					append tmp obj
				)
			)
		) 
		objs = tmp
		::wallworm_performanceCounter_stop #collection #'wallworm_get_all_collect_find_hidden-nonvmf'
	)
	::wallworm_performanceCounter_stop #collection #'wallworm_get_all_objects'
	objs
)

/*
This function tags an objects as a prop. Ideally the FGD has been parsed and no legacy Convexity-formatted data is needed, but it does fall back to Convexity data format.
*/
function wallworm_setPropDefaults obj type:"prop_static" mdl:undefined = (
	global wallworm_get_entity_by_name
	if wallworm_get_entity_by_name == undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
	)
	test = wallworm_get_entity_by_name type
	if test == undefined OR test.ca == undefined then (
		local GLBPntData = ""
		local GLBPntValu = ""
		case type of (
			"prop_static":(
				GLBPntData = "prop_static,angles,mindxlevel,maxdxlevel,model,skin,solid,disableshadows,screenspacefade,fademindist,fademaxdist,fadescale,lightingorigin,disablevertexlighting,disableselfshadowing,ignorenormals"
				GLBPntValu = ",0 0 0,0,0," + mdl + ",0,6,0,0,-1,0,1,;,0,0,0"
			)
			"prop_physics":(
				GLBPntData = "prop_physics,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,minhealthdmg,shadowcastdist,physdamagescale,Damagetype,nodamageforces,inertiaScale,massScale,overridescript,damagetoenablemotion,forcetoenablemotion,puntsound,renderfx,rendermode,renderamt,rendercolor,disablereceiveshadows"
				GLBPntValu = ",;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,0.1,0,0,1.0,0,;,0,0,;,0,0,255,255 255 255,0"
			)
			"prop_dynamic":(
				GLBPntData = "prop_dynamic,parentname,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,renderfx,rendermode,renderamt,rendercolor,disablereceiveshadows,solid,DefaultAnim,RandomAnimation,MinAnimTime,MaxAnimTime,SetBodyGroup,lightingorigin,StartDisabled"
				GLBPntValu = ",;,;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,255,255 255 255,0,6,;,0,5,10,0,;,0"
			)
			"prop_detail":(
				GLBPntData = "prop_detail,model"
				GLBPntValu = "," + mdl
			)
			"prop_physics_multiplayer":(
				GLBPntData = "prop_physics_multiplayer,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,minhealthdmg,shadowcastdist,physdamagescale,Damagetype,nodamageforces,inertiaScale,massScale,overridescript,damagetoenablemotion,forcetoenablemotion,puntsound,renderfx,rendermode,renderamt,rendercolor,disablereceiveshadows,physicsmode"
				GLBPntValu = ",;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,0.1,0,0,1.0,0,;,0,0,;,0,0,255,255 255 255,0,0"
			)
			"prop_physics_override":(
				GLBPntData = "prop_physics_override,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,minhealthdmg,shadowcastdist,physdamagescale,Damagetype,nodamageforces,inertiaScale,massScale,overridescript,damagetoenablemotion,forcetoenablemotion,puntsound,health"
				GLBPntValu = ",;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,0.1,0,0,1.0,0,;,0,0,;,0"

			)
			"prop_dynamic_ornament":(
				GLBPntData = "prop_dynamic_ornament,parentname,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,renderfx,rendermode,renderamt,rendercolor,disablereceiveshadows,DefaultAnim,RandomAnimation,MinAnimTime,MaxAnimTime,SetBodyGroup,lightingorigin,solid,InitialOwner"
				GLBPntValu = ",;,;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,255,255 255 255,0,;,0,5,10,0,;,0,;"

			)
			"prop_dynamic_override":(
				GLBPntData = "prop_dynamic_override,parentname,globalname,angles,model,skin,targetname,damagefilter,disableshadows,ExplodeDamage,ExplodeRadius,PerformanceMode,pressuredelay,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,renderfx,rendermode,renderamt,rendercolor,disablereceiveshadows,solid,DefaultAnim,RandomAnimation,MinAnimTime,MaxAnimTime,SetBodyGroup,lightingorigin,health"
				GLBPntValu = ",;,;,0 0 0," + mdl + ",0,;,;,0,0,0,0,0,0,0,-1,0,1,0,0,255,255 255 255,0,6,;,0,5,10,0,;,0"
			)
			"prop_door_rotating":(
				GLBPntData = "prop_door_rotating,targetname,parentname,angles,globalname,model,skin,disableshadows,slavename,hardware,ajarangles,spawnpos,axis,distance,speed,soundopenoverride,soundcloseoverride,soundmoveoverride,returndelay,dmg,health,soundlockedoverride,soundunlockedoverride,forceclosed,opendir"
				GLBPntValu = ",;,;,0 0 0,;," + mdl + ",0,0,;,1,0 0 0,0,;,90,100,;,;,;,-1,0,0,;,;,0,0"

			)
			"prop_ragdoll":(
				GLBPntData = "prop_ragdoll,angles,targetname,model,skin,disableshadows,mindxlevel,maxdxlevel,fademindist,fademaxdist,fadescale,StartDisabled,angleOverride"
				GLBPntValu = ",0 0 0,;," + mdl + ",0,0,0,0,-1,0,1,0,;"
			)
			default:(
				GLBPntData = "prop_static,angles,mindxlevel,maxdxlevel,model,skin,solid,disableshadows,screenspacefade,fademindist,fademaxdist,fadescale,lightingorigin,disablevertexlighting,disableselfshadowing,ignorenormals"
				GLBPntValu = ",0 0 0,0,0," + mdl + ",0,6,0,0,-1,0,1,;,0,0,0"
			)
		)
		setUserProp obj #GLBPntData GLBPntData
		setUserProp obj #GLBPntValu GLBPntValu
	) else (
		wallworm_remove_entity obj
		custAttributes.add obj test.ca
		if isProperty obj #model AND mdl != undefined AND mdl != "" AND mdl != ";" then (
			obj.model = mdl
		)
	)

)

function wallworm_set_props_type type sel:undefined reselect:false = (
	if sel == undefined then (
		sel = selection
		reselect = true
	)

	if sel.count == 0 then (
		messageBox "This function only works when you have selected a set of WWMT helpers and/or proxies."
	) else (
		oldsel = sel as Array
		local wwmts = 0
		local failed = #()
		clearSelection()
		local res = #()
		for obj in oldsel WHERE isDeleted obj == false do (
			isWWMTSource = getUserProp obj #wwmt_source_helper
			if isWWMTSource != undefined AND isWWMTSource == true then (
				local tempWWMT = ww_LOD_wrapper()

				tempWWMT.init()
				tempWWMT.setTargetModel obj tempWWMT
				--messagebox ddl_propType.selected
				local message = tempWWMT.canBePropType type:type
				if message.count > 0 then (
					for m in message do (
						append res m
					)
					--append res message
				) else (
					(tempWWMT.setCoreCVXEntityValue type:type)
				)
				tempWWMT = undefined
			) else (
				local mdl = undefined
				local modelSource = getUserProp obj #wwmt_proxie_source
				if modelSource != undefined then (
					message = #()
					local theModel = getNodeByName modelSource
					if theModel != undefined then (
						local tempWWMT = ww_LOD_wrapper()
						tempWWMT.init()
						tempWWMT.setTargetModel theModel tempWWMT
						local message = tempWWMT.canBePropType type:type
						mdl = tempWWMT.modelPath + "/" + tempWWMT.modelName + ".mdl"
						tempWWMT = undefined
					)
					if message.count > 0 then (
						for m in message do (
							append res ("[ " + obj.name + " ] - " + m)
						)
					) else (
						wallworm_setPropDefaults obj type:type mdl:mdl
					)
				)
			)
		)
		if res.count > 0 then (
			message = "The action was completed but there were some problems:\n\n"
			for m in res do (
				append message ("*" + m + "\n")
			)
			messageBox message
		)
		if reselect == true then (
			select oldsel
		)
	)
)

function wallworm_create_path_entity ent type:"path_track" targetname:";" targ:";" = (
	global wallworm_get_entity_by_name
	if wallworm_get_entity_by_name == undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
	)

	test = wallworm_get_entity_by_name type

	if test == undefined OR test.ca == undefined then (
		if targ == "" then (
			targ = ";"
		)
		if targetname == "" then (
			targetname = ";"
		)

		case type of (
			"path_corner":(
				GLBPntData = "path_corner,targetname,angles,target,wait,speed,yaw_speed"
				GLBPntValu = "," + targetname + ",0 0 0," + targ + ",0,0,0"
				ent.wireColor = (Color 247 181 82)
			)
			"move_rope":(
				GLBPntData = "move_rope,targetname,parentname,NextKey,MoveSpeed,mindxlevel,maxdxlevel,Slack,Type,Subdiv,Barbed,Width,TextureScale,Collide,Dangling,Breakable,RopeMaterial,NoWind,PositionInterpolator"
				GLBPntValu = "," + targetname + ",;," + targ + ",64,0,0,25,0,2,0,2,1,0,0,0,cable/cable.vmt,0,2"
			)
			"keyframe_rope":(
				GLBPntData = "keyframe_rope,targetname,parentname,NextKey,MoveSpeed,mindxlevel,maxdxlevel,Slack,Type,Subdiv,Barbed,Width,TextureScale,Collide,Dangling,Breakable,RopeMaterial,NoWind"
				GLBPntValu = "," + targetname + ",;," + targ + ",64,0,0,25,0,2,0,2,1,0,0,0,cable/cable.vmt,0"
			)

			"path_corner_crash":(
				GLBPntData = "path_corner_crash,targetname,target"
				GLBPntValu = "," + targetname + "," + targ
				ent.wireColor = (Color 255 0 0)
			)
			"path_track":(
				GLBPntData = "path_track,targetname,parentname,angles,target,altpath,speed,radius,orientationtype"
				GLBPntValu = "," + targetname + ",;,0 0 0," + targ + ",;,0,0,1"
				ent.wireColor = (Color 255 192 0)
			)
		)
		GLBFlags = "0"

		setUserProp ent #GLBPntData GLBPntData
		setUserProp ent #GLBPntValu GLBPntValu
		setUserProp ent #GLBFlags GLBFlags
	) else (
		custAttributes.add ent test.ca

		if isProperty ent #targetname AND targetname != "" AND targetname != ";" then (
			ent.targetname = targetname
		)

		if isProperty ent #wwmt_target AND targ != "" AND targ != ";" then (
			ent.wwmt_target = (targ as String)
		)

		if isProperty ent #NextKey AND targ != "" AND targ != ";" then (
			ent.NextKey = (targ as String)
		)

	)

)

function wallworm_spline_to_path spline type:"path_track" placement:1 useLookat:false = (
	local pathEnts = #()
	--spline = copy spline
	--	if superClassOf s == Shape  then (

	local isSpline = (classOf spline == Line OR classOf spline == SplineShape)

	if isSpline then (
		sps = numSplines spline
	) else (
		sps = 1

	)

	if placement == 1 AND isSpline then (
		for s = 1 to sps do

		(
			local closedSpline = false

			if ((isSpline AND isClosed spline s) OR (NOT isSpline AND ((pathInterp spline s 0.0) == (pathInterp spline s 1.0)))) then (
				closedSpline = true
			)

			local looped = closedSpline

			if isSpline then (
				nk = numKnots spline s
			) else (
				nk = numKnots spline

			)

			for k = 1 to nk do

			(
				knt = getKnotPoint spline s k
				local ent = Box name:(uniqueName type) pos:knt length:16 width:16 height:16
				append pathEnts #(ent, looped)

			)--end k loop

		)--end s loop

	) else (
		local out
		case method of (
			default:(
				out = Line pos:spline.pos
				out.steps = 0

			)
		)

		for s = 1 to sps do (
			if isSpline then (
				nk = numKnots spline s
			) else (
				nk = numKnots spline

			)

			local closedSpline = false

			if ((isSpline AND isClosed spline s) OR (NOT isSpline AND ((pathInterp spline s 0.0) == (pathInterp spline s 1.0)))) then (
				closedSpline = true
			)

			local looped = closedSpline

			--Point pos:(pathInterp spline s 0.0)

			local ent = Box name:(uniqueName type) pos:(pathInterp spline s 0.0) length:16 width:16 height:16
			append pathEnts #(ent, looped)

			if NOT isProperty spline #steps then (
				case (classOf spline) of (
					Helix:steps = 41
					Helix_Pro:steps = spline.sides
					default:steps = 0
				)

			) else (
				if (NOT isSpline AND (pathInterp spline s 0.0) == (pathInterp spline s 1.0)) OR (isSpline AND isClosed spline s) then (
					local steps = (spline.steps + 1) * nk
				) else (
					local steps = ((spline.steps + 1) * (nk - 1))
				)
			)

			local percent = 1.0 / steps

			local newPercent = percent
			for i = 1 to (steps as Integer) do (
				if newPercent > 1.0 then (
					newPercent = 1.0
				)
				--append ptsArray (newPercent)

				--Point pos:(pathInterp spline s newPercent)
				if closedSpline == false OR i < steps then (
					local ent = Box name:(uniqueName type) pos:(pathInterp spline s newPercent) length:16 width:16 height:16
					append pathEnts #(ent, looped)
				)

				newPercent += percent
			)

		)

	)

	--)

	if pathEnts.count > 0 then (
		local i = 1
		for ent in pathEnts do (
			local nextTarget = ""
			if (i < pathEnts.count) then (
				nextTarget = pathEnts[i + 1][1].name

				if useLookat AND isValidNode pathEnts[i + 1][1] AND pathEnts[i + 1][1] != ent[1] AND (refs.dependencyLoopTest pathEnts[i + 1][1] ent[1] == false) then (
					local lookatN = LookAt_Constraint()
					lookatN.appendTarget (pathEnts[i + 1][1]) 100.0

					ent[1].rotation.controller = lookatN
				)
			) else (
				if pathEnts[i][2] == true then (
					nextTarget = pathEnts[1][1].name
					/*local lookatN = LookAt_Constraint()
					lookatN.appendTarget (pathEnts[1][1]) 100.0
					ent[1].rotation.controller = lookatN*/
				)

			)

			if type != "rope" then (
				wallworm_create_path_entity ent[1] type:type targetname:ent[1].name targ:nextTarget
			) else (
				if i == 1 then (
					wallworm_create_path_entity ent[1] type:"move_rope" targetname:ent[1].name targ:nextTarget
				) else (
					wallworm_create_path_entity ent[1] type:"keyframe_rope" targetname:ent[1].name targ:nextTarget
				)

			)

			i = i + 1
		)

	)
	pathEnts
)

function wallworm_autoconfig = (
	::wwmt_sdk_folder = (DotNetClass "System.Environment").GetEnvironmentVariable("sourcesdk")

	::wwmt_valvemod_arraystr = (DotNetClass "System.Environment").GetEnvironmentVariable("VProject")

	if ::wwmt_valvemod_arraystr != undefined AND ::wwmt_valvemod_arraystr != "" then (
		::wwmt_gameInfoDir = ::wwmt_valvemod_arraystr
		setINISetting ::wallworm_userIni "Directories" "gameInfoDir" ::wwmt_gameInfoDir

		wwmt_valvemod_array = filterString ::wwmt_valvemod_arraystr "\\"
		if wwmt_valvemod_array.count > 0 then (
			append ::wwmt_sdk_folder ("_content\\" + wwmt_valvemod_array[wwmt_valvemod_array.count])
		)

	)

	setINISetting ::wallworm_userIni "Directories" "wwmt_sdk_folder" ::wwmt_sdk_folder

	::wwmt_export = (::wwmt_sdk_folder + "\\modelsrc")
	setINISetting ::wallworm_userIni "Directories" "export" ::wwmt_export

	::wwmt_exportMats = (::wwmt_sdk_folder + "\\materialsrc")
	setINISetting ::wallworm_userIni "Directories" "exportMats" ::wwmt_exportMats

	::wwmt_binDir = ((DotNetClass "System.Environment").GetEnvironmentVariable("sourcesdk") + "\\bin\\orangebox\\bin")
	setINISetting ::wallworm_userIni "Directories" "binDir" ::wwmt_binDir

	::wwdt_mapsrc = (::wwmt_sdk_folder + "\\mapsrc")
	setINISetting ::wallworm_userIni "Directories" "exportMaps" ::wwdt_mapsrc

)

function wallworm_getNodeSystem obj t:0 loc:false rot:false = (
	local refSystem = Matrix3 1

	if obj != undefined AND loc == true then (
		refSystem = at time t ((Matrix3 [1, 0, 0] [0, 1, 0] [0, 0, 1] refNode.transform.position))

	)

	if rot == true then (
		refSystem = rotateZMatrix 90 * refSystem

	)

	refSystem
)

function wallworm_is_a_bone obj = (
	if obj != undefined AND (classOf obj == BoneGeometry OR classOf obj == Bone OR classOf obj == CATParent OR classOf obj == CATBone OR classOf obj == HubObject OR classOf obj == Biped_Object) then (
		true
	) else (
		false
	)
)

function wallworm_hasNonPlanarPolygon node =
(
	local hasNonPlanarPolygon = false
	if superClassOf node == GeometryClass then (
		for e in node.Mesh.faces as BitArray while hasNonPlanarPolygon == false do (
			ff = (meshop.getPolysUsingFace node.Mesh e ignoreVisEdges:true) as Array
			if ff.count >= 2 AND (getFaceNormal node.Mesh ff[1] != getFaceNormal node.Mesh ff[2]) then (
				hasNonPlanarPolygon = true
			)
		)

	)
	hasNonPlanarPolygon
)

function wallworm_isConvex obj = (
	local out = undefined
	if nvpx != undefined AND isProperty nvpx #IsConvex then (
		out = nvpx.isConvex obj

	) else (
		if reactor != undefined AND isProperty reactor #GetIsConvex then (
			out = reactor.GetIsConvex obj 0
		)
	)
	out
)

function wallworm_remove_ca_by_name obj name = (
	local c = custAttributes.count obj -- [BaseObject:<bool>]
	local out = false

	if c > 0 then (
		for i = c to 1 by -1 do (
			ca = custAttributes.get obj i

			if ca.name == name then (
				custAttributes.delete obj i
				out = true
			)

		)
	)
	out
)

function wallworm_get_ca_index_by_name obj name = (
	local c = custAttributes.count obj -- [BaseObject:<bool>]
	local out = undefined

	if c > 0 then (
		for i = c to 1 by -1 while out == undefined do (
			ca = custAttributes.get obj i

			if ca.name == name then (
				out = i
			)

		)
	)
	out
)

/*
This function will copy a custom attribute from one object to another based on the indexed custom attribute (caIndex) in fromObj
*/
function wallworm_copy_ca caIndex fromObj toObj = (
	local ca = custAttributes.get fromObj caIndex
	local objdef = custAttributes.getDef fromObj caIndex
	if objdef != undefined then (
		custAttributes.add toObj objdef
		local defs = custAttributes.getPBlockDefs objdef
		for pbi = 1 to defs.count do (
			local paramb = defs[pbi]
			for pbin2 = 5 to paramb.count do (
				local param = (paramb[pbin2][1] as String)
				oldVal = getProperty fromObj param
				if oldVal != undefined then (
					setProperty toObj param oldVal
				)
			)
		)
	)
)

/*
function wallworm_readBlock &memstr p1:"[" p2:"]" = (
	local outputstring = ""
	local limit = memstr.size()
	local startPos = memstr.pos()
	if startPos < limit then (
		outputstring = memstr.readblock p1 p2
		if outputstring == undefined then (
			local rl = memstr.readLine
			outputstring = ""
			local outstream = stringstream ""
			local endPos = memstr.pos()
			memstr.seek startPos #seek_set
			if endPos > limit then (
				endPos = limit
			)
			while memstr.pos() < endPos AND memstr.eos() == false  do (
				local inf = rl()
				format "%\r\n" inf to:outstream
			)
			outputstring = outstream as string
		) else (
			outputstring = replace_LF_with_CRLF outputstring
		)		
	)

	outputstring
)
*/

function wallworm_checkForEndlines vmfMemStream fixFile:false = (
	local pos = vmfMemStream.pos()
	vmfMemStream.seek -2 #seek_end
	ln = (vmfMemStream.readChar() + vmfMemStream.readChar())
	local isOK
	if ln == "\r\n" then (
		isOK = true
	) else (
		isOK = false
	)
	vmfMemStream.seek pos #seek_set
	isOK
)

function wallworm_readBlock &memstr p1:"[" p2:"]" = (
	local memstrreadToken = memstr.readToken
	local memstrreadLine = memstr.readLine
	while NOT memstr.eos() AND memstr.peekToken() != p1 do (
		memstrreadLine()
	)
	local outstream = StringStream ""
	if NOT memstr.eos() then (
		local count1 = 0
		local count2 = 0
		local keepLooking = true
		while keepLooking AND NOT memstr.eos() do (
			local inf = trimLeft (trimRight (memstrreadLine()))
			case inf of (
				p1:(count1 += 1)
				p2:(count1 -= 1)
			)
			format "%\r\n" inf to:outstream
			if count1 == 0 then (
				keepLooking = false
			)
		)
	)
	(outstream as String)
)

function wallworm_readBlock2 &ms p1:"[" p2:"]" =
(
	::wallworm_readBlock &ms p1:p1 p2:p1
)

function wallworm_update_proxies proxyselection = (
	newProxies = #()
	max create mode
	with redraw off
	if proxyselection != undefined AND (proxyselection as Array).count > 0 then (
		local wwmts = #()

		wwmtselection = for ww in proxyselection WHERE isProperty ww #wwmt_ca OR getUserProp ww #wwmt_source_helper != undefined collect ww

		for ww in wwmtselection do (
			local tempWWMT = ww_LOD_wrapper()
			tempWWMT.init()
			tempWWMT.setTargetModel ww tempWWMT
			newAr = tempWWMT.update_proxies_in_scene()
			if newAr.count > 0 then (
				join newProxies newAr
			)
		)

		/*Reduce selection to WWMT proxies*/
		proxyselection = for prox in proxyselection WHERE getUserProp prox #wwmt_proxie_source != undefined collect prox

		/*get array of WWMT names in list*/

		wwmtselectionnames = for ww in wwmtselection collect ww.name

		local wwmtnames = for prox in proxyselection collect (getUserProp prox #wwmt_proxie_source)
		wwmtnames = makeUniqueArray wwmtnames

		for i = wwmtnames.count to 1 by -1 do (
			if findItem wwmtselectionnames wwmtnames[i] != 0 then (
				deleteItem wwmtnames i
			)
		)

		for i = wwmtnames.count to 1 by -1 do (
			local tname = wwmtnames[i]
			wwmttarget = getNodeByName tname
			if wwmttarget != undefined AND NOT isDeleted wwmttarget AND getUserProp wwmttarget #wwmt_source_helper != undefined then (
				local tempWWMT = ww_LOD_wrapper()
				tempWWMT.init()
				tempWWMT.setTargetModel wwmttarget tempWWMT
				newAr = tempWWMT.update_proxies_in_scene()
				if newAr.count > 0 then (
					join newProxies newAr
				)
			)

		)
	)
	newProxies
)

/*Update the custom attribute definitions for a WWMT object.*/
function wallworm_update_wwmt_cas obj newDef:newDef desel:true = (
	local currenSelection
	if desel == true then (
		currenSelection = selection as Array
		max select none
		max create mode
	)
	if newDef == undefined then (
		global wallworm_model_tools_CA
		newDef = (custAttributes.getDefSource wallworm_model_tools_CA)
	)
	--disableRefMsgs()
	with undo off
	with redraw off (
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		local out = false

		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i
				if matchPattern def.name pattern:"*Wallworm Model Tools" then (
					custAttributes.redefine def newDef
					out = true
				)
			)
		)
	)
	if desel == true AND currenSelection.count > 0 then (
		select currenSelection
	)
	out
)

function wallworm_update_all_wwmt_cas = (
	global wallworm_model_tools_CA
	if wallworm_model_tools_CA == undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/wwmt.ms")
		fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/proxy.ms")
	)
	local newDef = custAttributes.getDefSource wallworm_model_tools_CA
	local currenSelection = selection as Array
	max select none
	max create mode
	for obj in objects WHERE isProperty obj #Wallworm_Model_Tools AND obj.Wallworm_Model_Tools.version < ::wallwormWWMTCAversion do (
		wallworm_update_wwmt_cas obj newDef:newDef desel:false
	)
	if currenSelection.count > 1 then (
		select currenSelection
	)
)

/*Update the custom attribute definitions for a Proxy object.*/
function wallworm_update_proxy_cas obj newDef:newDef desel:true = (
	local currenSelection
	if desel == true then (
		currenSelection = selection as Array
		max select none
		max create mode
	)
	if newDef == undefined then (
		newDef = (custAttributes.getDefSource ::wallworm_proxyskin_holderCA)
	)
	--disableRefMsgs()
	with undo off
	with redraw off (
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		local out = false

		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i
				if matchPattern def.name pattern:"*WWMTProxy" then (
					custAttributes.redefine def newDef
					out = true
				)
			)
		)
	)
	if desel == true AND currenSelection.count > 0 then (
		select currenSelection
	)
	out
)

function wallworm_update_all_proxy_cas = (
	if ::wallworm_proxyskin_holderCA == undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/wwmt.ms")
		fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/proxy.ms")
	)
	local newDef = custAttributes.getDefSource ::wallworm_proxyskin_holderCA
	local currenSelection = selection as Array
	max select none
	max create mode
	for obj in objects WHERE isProperty obj #WWMTProxy AND obj.WWMTProxy.version < 20 do (
		wallworm_update_proxy_cas obj newDef:newDef desel:false
	)
	if currenSelection.count > 1 then (
		select currenSelection
	)
)
function wallworm_remove_proxy obj = (
	if isProperty obj #WWMTProxy then (
		local nds = #(obj)
		InstanceMgr.MakeObjectsUnique nds #individual
		local c = custAttributes.count obj -- [BaseObject:<bool>]
		if c > 0 then (
			for i = c to 1 by -1 do (
				def = custAttributes.getDef obj i
				if matchPattern def.name pattern:"*WWMTProxy" then (
					custAttributes.delete obj i
				)
			)
		)
	)
	if getUserProp obj #wwmt_proxie_source != undefined then setUserProp obj #wwmt_proxie_source  undefined
)


global wallworm_single_entities = #("sky_camera", "light_environment", "env_fog_controller", "shadow_control")
function wallworm_should_test_existing_entity_exists entName = (findItem wallworm_single_entities entName != 0)

function wallworm_testExistingEntity entName = (
	local existing = undefined
	local uniqueproblem = false
	if (wallworm_should_test_existing_entity_exists entName) then (
		existing = (for obj in objects WHERE isProperty obj #entityType AND isProperty obj #entname AND obj.entname == entslist AND isProperty obj #wallworm.selected collect obj)
		if existing.count > 0 then (
			uniqueproblem = true
		)
	)
	uniqueproblem
)

function wallworm_addEntProps theSelection entName = (
	max create mode
	theSelection = for obj in theSelection WHERE NOT isProperty obj #ww_displacement_brush AND NOT isProperty obj #ww_displacement AND NOT isProperty obj #wallworm_edit_mesh collect obj
	if theSelection.count > 0 then (
		if (wallworm_should_test_existing_entity_exists entName) == true AND (theSelection.count > 1 OR wallworm_testExistingEntity() == true) then (
			messageBox "This entity should only be added once to the scene. You cannot apply it to multiple objects."
		) else (
			test = wallworm_game_settings.get_entity_by_name entName
			if test != undefined AND test.ca != undefined then (
				toprocess = wallworm_update_entities theSelection test
				if toprocess.count > 0 then (
					custAttributes.add toprocess test.ca
				)
				for obj in (theSelection as Array) do (
					if isProperty obj #model then (
						local wwmtname = getUserProp obj #wwmt_proxie_source
						if wwmtname != undefined then (
							wwmtnode = getNodeByName wwmtname
							if isProperty wwmtnode #modelName then (
								obj.model = (wallworm_remove_last_slash (wwmtnode.modelPath)) + "/" + wwmtnode.modelName + ".mdl"
							)
						)
					)
					legacyDats = getUserProp obj #GLBPntData
					legacyValus = getUserProp obj #GLBPntValu
					legacyFlags = getUserProp obj #GLBFlags
					if legacyDats != undefined AND legacyDats != "" AND legacyValus != undefined AND legacyValus != "" then (
						props = filterString legacyDats "," splitEmptyTokens:true
						vals = filterString legacyValus "," splitEmptyTokens:true
						if props.count == vals.count then (
							for i = 2 to props.count do (
								if vals[i] != undefined AND vals[i] != "" AND vals[i] != ";" then (
									if isProperty obj props[i] == true then (
										try (
											setProperty obj props[i] (vals[i] as (classOf (getProperty obj props[i])))
										) catch ()
									)
								)
							)
						)
					)
					if legacyFlags != undefined AND legacyFlags != "" AND isProperty obj #spawnflags AND ((legacyFlags as Integer) != undefined) then (
						setProperty obj #spawnflags (legacyFlags as Integer)
					)

					if legacyDats != undefined then (
						setUserProp obj #GLBPntData ""
					)

					if legacyValus != undefined then (
						setUserProp obj #GLBPntValu ""
					)
					if legacyFlags != undefined then (
						setUserProp obj #GLBFlags ""
					)
					if isProperty obj #entcolor AND obj.entcolor != undefined AND classOf obj.entcolor == Color then (
						obj.wireColor = obj.entcolor
					)
					if isProperty obj #iconsprite AND obj.iconsprite != undefined then (
						lookFor = substituteString obj.iconsprite ".vmt" ""
						themat = wallworm_VMFIMPORT_getMaterial lookFor color:obj.wireColor openLib:true
						obj.mat = themat
						if isProperty obj #mapcoords then (
							obj.mapcoords = on
						)
					)
					if superClassOf obj == Light then (
						if classOf obj == Directionallight then (
							obj.overshoot = true
						)
						if isProperty obj #color AND isProperty obj #_light then (
							obj._light = obj.color
						)
					)
				)
			) else (
				messageBox "Oops... this entity was not found in the Entity Cache. You may need to reparse the FGD in the WW Settings."
			)
		)

		if selection.count == 1 then (
			max modify mode
		)
	) else (
		messageBox "Oops... you need to select some objects to us this function."
	)
)

function wallworm_get_vmf_name = (
	if isProperty rootNode #Wallworm_VMF AND rootNode.Wallworm_VMF.filename != undefined AND rootNode.Wallworm_VMF.filename != "" then (
		getFileNameFile rootNode.Wallworm_VMF.filename
	) else (
		local wallwormMapNameIndex = fileProperties.findProperty #custom "wallwormMapName"
		if wallwormMapNameIndex != 0 then (
			/*This file was exported with an older version of the VMF Exporter. Use legacy name.*/
			fileProperties.getPropertyValue #custom wallwormMapNameIndex
		) else (
			local sfn = maxFileName
			if sfn != undefined AND sfn != "" then (
				getFileNameFile sfn
			) else (
				"MyMap"
			)
		)
	)
)

::WallWormEntityOps = struct WallWormEntityOps (

	/*Functions to run on entities if the custom attribute definitions have been updated*/
	function wallworm_entity_ca_postupdate ent oldversion:1 = (
		if isProperty ent #entname AND isProperty ent #wallworm then (
			if oldversion < 58 then (
				if superclassof ent == Light AND isProperty ent #_light AND isProperty ent #_light_intensity AND isProperty ent #multiplier then (
					local ltval = 200.0
					local ltenvval = 20.0
					local useNum = 200.0
					if isProperty rootNode #wallworm_vmf then (
						ltval = rootNode.lightMultiplier
						ltenvval = rootNode.lightEnvMultiplier
					)
					if ent.entName == "light_environment" OR ent.entName == "light_directional" then (
						useNum = ltenvval
					) else (
						useNum = ltval
					)
					ent._light_intensity = thisNode.multiplier * useNum
				)
			)
		)
	),

	function wallworm_update_entity_angles pThis = (
		if isValidNode pThis then (
			local trans = pThis.transform
			local str = stringStream ""	
			if superclassof pThis != light then (
				in coordsys world entEuler = trans.rotationPart as EulerAngles	
				format "% % %" (entEuler.y as float) (entEuler.z as float) (entEuler.x as float) to:str
			) else (
				local r3 = trans.row3
				local dp = (dot (normalize (cross [0, 0, 1] (cross (-1.0 * r3) [0, 0, 1]))) [1, 0, 0])
				local XYAngle = acos dp
				if (dot r3 [0, 1, 0]) > 0 then (
					XYAngle = (360 - XYAngle)
				)
				if isProperty pThis #pitch then (
					local dp = normalize (cross [0, 0, 1] (cross (-1.0 *r3) [0, 0, 1]))
					local pitch = acos (dot (-1.0 * r3) dp)
					if (dot (r3) [0, 0, 1]) > 0 then (
						pitch *= -1
					)
					pThis.pitch	= (pitch as (classof pThis.pitch)) --sometimes it's a string/sometimes an integer
				) 
				format "0 % 0" ( XYAngle as integer) to:str
			)
			pThis.angles = str as string
			true
		) else (
			false
		)
	),
	function wallworm_rotateEntByYZX entNode = (
		if isValidNode entNode then (
			local fstr = filterString entNode.angles " "
			if fstr.count == 3 then (
				fstr[1] = fstr[1] as float
				fstr[2] = fstr[2] as float
				fstr[3] = fstr[3] as float
				
				if fstr[1]  == undefined OR fstr[2] == undefined  OR fstr[3] == undefined then (
					false
				)  else (
					entNode.transform = (Matrix3 [1, 0, 0] [0, 1, 0] [0, 0, 1] entNode.transform.row4) 
					if superClassOf entNode != Light then (
						in coordsys world (
							rotate entNode (AngleAxis (fstr[3] ) [1, 0, 0])
							rotate entNode (AngleAxis (fstr[2] ) [0, 0, 1])
							rotate entNode (AngleAxis (fstr[1] ) [0, -1, 0])
						)
					) else (
						local pitch
						local r = Point3 (fstr[3] ) (fstr[2] ) (fstr[1] )
						if isProperty entNode #pitch then (
							r.x = (entNode.pitch as float) * -1
						)
						r.y = (r.y * -1) + 90
						r.x = r.x - 90
						local rotSystem = Matrix3 [1, 0, 0] [0, 1, 0] [0, 0, 1] entNode.pos
						in coordsys rotSystem (
							rotate entNode ((EulerAngles r.x 0 0) as Quat)
							rotate entNode ((EulerAngles 0 0 r.y) as Quat)
						)
					)
				)
				true	
			)
		) else (
			false
		)
	)
)

function wallworm_create_selected_LODS sel:undefined count:1 = (
	if sel == undefined then (
		sel = selection as array
	)
	for obj in sel WHERE isProperty obj #getWWMT AND obj.lods.count == 0 do (
		local wwmt = obj.getWWMT()
		if wwmt != undefined then (
			wwmt.makeLodsArray count wwmt
		)
	)
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")