rollout wallwormDisplayFloater "Wall Worm Display Floater" width:200 (
	Group "Tagged Geometry" (
		CheckBox chkWorldGeometry "World Geometry"
		CheckBox chkFuncDetail "Func Detail"
		CheckBox chkSky "Sky"
	)
	Group "WW Geo Plugins" (
		CheckBox chkCorvex "CorVex"
		CheckBox chkShellvex "ShellVex"
		CheckBox chkArch "Arch"
		CheckBox chkPropline "PropLine"
	)
	Group "Anvil" (
		CheckBox chkDisplacements "Displacements"
		CheckBox chkDisplacementsB "Displacement Brushes"
		CheckBox chkSculptMeshes "Sculpt Meshes"
	)
	Group "Entities" (
		CheckBox chkPointEntities "Point Entities"
		CheckBox chkBrushEntities "Brush Entities"
		CheckBox chkWWMT "WWMT Helpers"
		CheckBox chkWWMTProxies "WWMT Proxies"
	)
	Group "Misc" (
		Checkbox chkAny "Any WW Node"
	)
	Button btnAll "All" across:3
	Button btnNone "None"
	Button btnInvert "Invert"
	
	on btnAll pressed do (
		chkAny.checked =chkCorvex.checked = chkWWMT.checked = chkWWMTProxies.checked =chkShellVex.checked = chkArch.checked =chkPropline.checked =chkWorldGeometry.checked =chkFuncDetail.checked =chkSky.checked =chkDisplacements.checked =chkDisplacementsB.checked =chkSculptMeshes.checked =chkPointEntities.checked =chkBrushEntities.checked  = true
	)
	on btnNone pressed do (
		chkAny.checked =chkCorvex.checked = chkWWMT.checked = chkWWMTProxies.checked = chkShellVex.checked = chkArch.checked =chkPropline.checked =chkWorldGeometry.checked =chkFuncDetail.checked =chkSky.checked =chkDisplacements.checked =chkDisplacementsB.checked =chkSculptMeshes.checked =chkPointEntities.checked =chkBrushEntities.checked  = false
	)
	on btnInvert pressed do (
		chkAny.checked = NOT chkAny.checked
		chkCorvex.checked = NOT chkCorvex.checked
		chkShellVex.checked = NOT  chkShellVex.checked
		chkArch.checked = NOT chkArch.checked
		chkPropline.checked = NOT chkPropline.checked
		chkWorldGeometry.checked = NOT chkWorldGeometry.checked
		chkFuncDetail.checked = NOT chkFuncDetail.checked
		chkSky.checked = NOT chkSky.checked
		chkDisplacements.checked = NOT chkDisplacements.checked
		chkDisplacementsB.checked = NOT chkDisplacementsB.checked
		chkSculptMeshes.checked = NOT chkSculptMeshes.checked
		chkPointEntities.checked = NOT chkPointEntities.checked
		chkBrushEntities.checked  = NOT  chkBrushEntities.checked
		chkWWMT.checked  = NOT  chkWWMT.checked
		chkWWMTProxies.checked  = NOT  chkWWMTProxies.checked
	)
	
	Group "Action" (
		Button btnShow "Show" across:3
		Button btnHide "Hide"
		Button btnSelect "Select"
		CheckBox chkSel "Hide/Select in Current Selection"
	)
	function processAllObjects objs:objects = (
		local res = #()
		for obj in objs do (
			local isMatch = false
			case of (
				(chkAny.checked == true AND isProperty obj #wallworm):(isMatch = true)
				(chkCorvex.checked == true AND classof obj == Corvex):(isMatch = true)
				(chkShellVex.checked == true AND classof obj == ShellVex):(isMatch = true)
				(chkArch.checked == true AND classof obj == Arch):(isMatch = true)
				(chkPropline.checked == true AND classof obj == Propline):(isMatch = true)
				(chkWorldGeometry.checked == true AND ((isProperty obj #isWorldGeometry AND obj.isWorldGeometry==true) OR (getUserProp obj #wwdt_brush_geometry_export == true))):(isMatch = true)
				(chkFuncDetail.checked == true AND ((isProperty obj #funcDetail AND obj.funcDetail==true) OR (getUserProp obj #wwdt_func_detail == true))):(isMatch = true)
				(chkSky.checked == true AND ((isProperty obj #inSky AND obj.inSky==true) OR (getUserProp obj #wwdt_skybox_export == true))):(isMatch = true) 
				(chkDisplacements.checked == true AND (isProperty obj #ww_displacement AND obj.ww_displacement==true)):(isMatch = true)
				(chkDisplacementsB.checked == true AND (isProperty obj #ww_displacement_brush AND obj.ww_displacement_brush==true)):(isMatch = true)
				(chkSculptMeshes.checked == true AND (isProperty obj #wallworm_edit_mesh AND obj.wallworm_edit_mesh==true)):(isMatch = true)
				(chkPointEntities.checked == true AND (isProperty obj #entityType AND obj.entityType=="PointClass")):(isMatch = true)
				(chkBrushEntities.checked == true AND (isProperty obj #entityType AND obj.entityType=="SolidClass" OR ((isProperty obj #funcDetail AND obj.funcDetail==true) OR (getUserProp obj #wwdt_func_detail == true)))):(isMatch = true)
				(chkWWMT.checked == true AND isProperty obj #wwmt_ca):(isMatch = true)
				(chkWWMTProxies.checked == true AND isProperty obj #wallwormProxy):(isMatch = true)
			)
			if isMatch then (
				append res obj
			)
		)
		res
	)
	on btnShow pressed do (
		local res = processAllObjects()
		if res.count >0 then (
			res.isHidden = false
		)
		forcecompleteredraw()
	)
	on btnHide pressed do (
		local objs
		if chkSel.checked == true then (
			objs = selection as array
		) else (
			objs = objects as array
		)
		local res = processAllObjects objs:objs
		if res.count >0 then (
			res.isHidden = true
		)
		forcecompleteredraw()
	)
	on btnSelect pressed do (
		local objs
		if chkSel.checked == true then (
			objs = selection as array
		) else (
			objs = objects as array
		)
		local res = processAllObjects objs:objs
		if res.count >0 then (
			select res
		)
	)
)