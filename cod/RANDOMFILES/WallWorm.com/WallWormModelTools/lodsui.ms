components = StringStream ""
picked = StringStream ""
view = StringStream ""

y1 = 7
y2 = 21
y2b = y2 + 13
y3n4 = 50
y5 = 66
y6 = 49
thisLimit = ::wwmt_lodLimit
if thisLimit == undefined OR thisLimit == "" OR thisLimit < 1 then (
	thisLimit = 1
)

if ::ww_scene_lods != undefined AND ww_scene_lods.lods.count > thisLimit then (
	thisLimit = ww_scene_lods.lods.count
)
cycleval = 106
for c = 1 to thisLimit do (
	format "GroupBox grpLOD% \"LOD %\" pos:[3,%] width:240 height:99\n" c c y1 to:components
	format "pickbutton pickLOD% \"Pick LOD % Model\" pos:[9,%] width:100 height:24 enabled:false toolTip:\"Pick a mesh for the root of your LOD.\"\n" c c y2 to:components
	format "pickbutton appendLOD% \"Append LOD % \" pos:[116,%] width:71 height:12 enabled:false toolTip:\"Add all selected meshes to this LOD.\"\n" c c y2 to:components
	format "button addSelLOD% \"+ Sel to LOD % \" pos:[116,%] width:71 height:12 enabled:false toolTip:\"Add selected meshes to this LOD model.\"\n" c c y2b to:components
	format "button delLOD% \"DELETE\" pos:[190,%] width:51 height:12 enabled:false toolTip:\"Delete this LOD entirely. Deletes ALL meshes and helpers for this LOD.\"\n" c y2b to:components
	format "button delSelLOD% \"Rem Sel\" pos:[190,%] width:51 height:12 enabled:false toolTip:\"Remove selected meshes from this LOD.\"\n" c y2 to:components
	format "button btnPickLOD%Helper \"Button\" pos:[9,%] width:48 height:32 toolTip:\"Select Distance Helper.\" enabled:false images:wwmt_lodhelperIcons\n" c y3n4 to:components
	format "button btnViewLOD% \"Button\" pos:[56,%] width:48 height:32 toolTip:\"Show/Hide the LOD and its Radius Gizmo.\" enabled:false images:wwmt_lodHideIcons\n" c y3n4 to:components
	format "spinner spnLOD% \"\" pos:[110,%] width:80 height:16 enabled:false\n" c y5 to:components
	format "label lblLOD% \"Detail Percent\" pos:[111,%] width:80 height:16\n" c y6 to:components
	format "materialButton btnMatLOD% \"Material\" pos:[190,%] width:50 height:36 enabled:false toolTip:\"Browse your materials to select LOD materials to swap out with the main model's materials for this LOD.\"" c y6 to:components
	format "spinner spnLODMetric% \"LOD Threshold\" pos:[12,%] range:[0.01,1024,1] width:100 height:16 enabled:false\n" c (y5 + 18) to:components
	format "button spnLODMetricGet% \"Get Metric\" pos:[115,%] width:80 height:16  toolTip:\"Reset the value after changing the helper in the scene.\" enabled:false\n" c (y5 + 18) to:components

	y1 += cycleval
	y2 += cycleval
	y3n4 += cycleval
	y5 += cycleval
	y6 += cycleval
	y2b += cycleval

	format "on btnViewLOD% pressed do\n" c to:view
	format "(\t\ntry(\n" to:view
	format "\t\tif ww_scene_lods.lods[%].helperGizmo.isNodeHidden  then ( \n" c to:view
	format "\t\tww_scene_lods.unhideLod %\n" c to:view
	format "\t\tww_scene_lods.selectSelectionSets %\n" c to:view
	format "\t\tunhide ww_scene_lods.lods[%].helperGizmo\n" c to:view
	format "\t\twwToolsFloater.rollouts[4].btnViewLOD%.images = wwmt_lodViewIcons\n" c to:view
	format "\t\thide ww_scene_lods.targets\n" to:view
	format "\t) else (\n" to:view
	format "\t\thide ww_scene_lods.lods[%].items\n" c to:view
	format "\t\thide ww_scene_lods.lods[%].helperGizmo\n" c to:view
	format "\t\twwToolsFloater.rollouts[4].btnViewLOD%.images = wwmt_lodHideIcons\n" c to:view
	format "\t\tunhide ww_scene_lods.targets\n" to:view
	format "\t\tunfreeze ww_scene_lods.targets\n" to:view
	format "\t)\n" to:view
	format "\tredrawviews()\n" to:view
	format "\n\t)catch()\n)\n" to:view

	format "on btnMatLOD% picked mat do (\n" c to:picked to:picked
	format "\tif (ww_scene_lods.lods[ %].setLODMaterial mat == false) do (\nmessagebox \"You can only choose a Standard, Shell or Multi/Sub-Object Material.\"\n)\n" c to:picked
	format ")\n" to:picked
	format "on delSelLOD% pressed do (\n" c to:picked
	format "\tif (ww_scene_lods.lods[ %].removeItem selection > 0) then (\n\t\t\tmessagebox \"The selected items were deleted from this LOD.\"\n\t\t\t)\nelse\n(\n\t\t\tmessagebox \"None of the selected items were part of this LOD. None were removed.\"\n\t\t\t)\n" c to:picked
	format "\t)\n" to:picked
	format "on delLOD% pressed do (\n" c to:picked
	format "\tif ww_scene_lods.lods[ %] != undefined then (\n\t\tww_scene_lods.lods[ %].deleteLOD()\n" c c to:picked
	format "\t\tdelLOD%.enabled = false\n" c to:picked
	format "\t\tdelSelLOD%.enabled = false\n" c to:picked
	format "\t\tbtnPickLOD%Helper.enabled = false\n" c to:picked
	format "\t\tbtnViewLOD%.enabled = false\n" c to:picked
	format "\t\tspnLOD%.enabled = false\n" c to:picked
	format "\t\tpickLOD%.caption = \"Pick LOD %\"\n" c c to:picked
	format "\t\tif wwmt_activateLODMenus != undefined then (\nwwmt_activateLODMenus ww_scene_lods.lods\n)\n" to:picked
	format "\t)\n)\n" to:picked

	format "on pickLOD% picked obj do (\n" c to:picked
	format "\tww_scene_lods.setLod % obj ww_scene_lods\n" c to:picked
	format "\tdelLOD%.enabled = true\n" c to:picked
	format "\tappendLOD%.enabled = true\n" c to:picked
	format "\taddSelLOD%.enabled = true\n" c to:picked
	format "\tbtnViewLOD%.enabled = true\n" c to:picked
	format "\tbtnPickLOD%Helper.enabled = true\n" c to:picked
	format "\tspnLOD%.enabled = true\n" c to:picked
	format "\tspnLODMetric%.enabled = true\n" c to:picked
	format "\tspnLODMetricGet%.enabled = true\n" c to:picked
	format "\tbtnMatLOD%.enabled = true\n" c to:picked
	format "\tpickLOD%.caption = \"LOD %\"\n" c c to:picked
	if c < thisLimit then (
		format "\tpickLOD%.enabled = true\n" (c + 1) to:picked
	)
	format ")\n" to:picked

	format "on addSelLOD% pressed do (\n" c to:picked
	format "\ttempsel = (for obj in selection WHERE superclassof obj == GeometryClass collect obj) as array\n" to:picked
	format "\tif tempsel.count > 0 then (" to:picked
	format "\t\tif ww_scene_lods.lods[%] == undefined OR (classof ww_scene_lods.lods[ %] != ww_lod) then (\n\t\tww_scene_lods.setLod % tempsel[1] ww_scene_lods\n\t\tdeleteItem tempsel 1\n\t\ttempsel = for obj in tempsel WHERE isvalidnode obj == true collect obj\n\t)\n" c c c to:picked
	format "\tif tempsel.count > 0 then (\n" to:picked
	format "\t\tfor obj in tempsel do (\n" to:picked
	format "\t\t\tww_scene_lods.lods[ %].appendItem obj\n" c to:picked
	format "\t\t\t)\n" to:picked
	format "\t\t)\n" to:picked
	format "\t)\n" to:picked
	format ")\n" to:picked

	format "on appendLOD% picked obj do (\n" c to:picked
	format "\tww_scene_lods.lods[ %].appendItem obj\n" c to:picked
	format ")\n" to:picked
	format "on spnLOD% changed val do (\n" c to:picked
	format "\tww_scene_lods.lods[%].setMyRes val\n" c to:picked
	format ")\n" to:picked
	format "on spnLODMetric% changed val do (\n" c to:picked
	format "\tww_scene_lods.lods[%].setRadiusFromMetric val\n" c to:picked
	format ")\n" to:picked
	format "on spnLODMetricGet% pressed do (\n" c to:picked
	format "\tspnLODMetric%.value = ww_scene_lods.lods[%].getMetric()\n" c c to:picked
	format ")\n" to:picked
	format "on btnPickLOD%Helper pressed do (\n" c to:picked
	format "\ttry (\n" to:picked
	format "\t\tif ww_scene_lods.lods[%].helperTape.isNodeHidden do (\n" c to:picked
	format "\t\t\tunhide ww_scene_lods.lods[%].helperTape\n" c to:picked
	format "\t\t)\n" to:picked
	format "\t\tselect ww_scene_lods.lods[%].helperTape\n" c to:picked
	format "\t) catch (\n" to:picked
	format "\t)\n" to:picked
	format "\tredrawviews()\n" to:picked
	format ")\n" to:picked
	c = c + 1
)
lodstringa = StringStream ""
format "rollout wwmt_lodslistrollouta \"LOD List\" width:240 height:658\n" to:lodstringa
format "(\n" to:lodstringa
format (components as String) to:lodstringa
format (view as String) to:lodstringa
format (picked as String) to:lodstringa
format ")\n" to:lodstringa

lodstring = lodstringa as String