rollout wallwormBrushID "Go To Brush" width:401 height:246
(
	EditText edtBrushID "" pos:[90, 4] width:114 height:17
	Label lbl4 "Go To Brush ID" pos:[6, 7] width:84 height:18
	Button btnGO "Go" pos:[276, 3] width:119 height:26 toolTip:"Go To and Select a Brush by it's ID after the scene has been exported to VMF."

	GroupBox grp1 "Portals and Vis Leaves" pos:[4, 74] width:393 height:130

	Spinner spLeafA "Leaf A" pos:[74, 93] width:126 height:16 range:[0, 16000, 0] type:#integer across:2
	Button btnLeafA "Select this Leaf" pos:[249, 93] width:89 height:21

	Spinner spLeafB "Leaf B" pos:[74, 119] width:126 height:16 range:[0, 16000, 0] type:#integer across:2
	Button btnLeafB "Select this Leaf" pos:[249, 119] width:89 height:21

	Button getFromBoth "Get Portals Using Both A and B" pos:[118, 145] width:164 height:21
	Button loadPortalFile "Load Portal File" pos:[156, 171] width:89 height:21

	Button leakLoad "Load Leak File" pos:[143, 212] width:109 height:21 toolTip:"Load a Leak File"
	CheckBox chkLegacy "Legacy" pos:[212, 5] width:60 height:15 toolTip:"Search the older data (UserProp) rather than the newer AppData."
	Button btnInvalid "Select Invalid Brushes" pos:[8, 39] width:387 height:26

	on btnInvalid pressed do (
		::WallWormHullOps
		if ::WallWormHullOps == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallWormHullFuncs.ms")
		)
		local objs
		oldSel = selection as Array
		if selection.count > 0 then (
			objs = selection as Array
		) else (
			objs = objects as Array
		)

		objs = for obj in objs WHERE (getUserProp obj #wwdt_brush_geometry_export == true OR (classOf obj == CorVex AND obj.isWorldGeometry == true)) AND ((::WallWormHullOps.selectElementsOutOfRange obj).numberset > 0) collect obj
		select objs

	)

	on btnGO pressed do
	(
		local brshs = #()
		local ars = #(edtBrushID.text)
		if matchPattern edtBrushID.text pattern:"*,*" then (
			ars = filterString edtBrushID.text ","
			if ars.count > 0 then (
				for n in ars do (
					join brshs (wallworm_get_exported_brush_by_id (n as Integer) legacy:chkLegacy.checked)
				)
			)
		) else (
			brshs = wallworm_get_exported_brush_by_id (edtBrushID.text as Integer) legacy:chkLegacy.checked
		)

		if brshs.count > 0 then (
			ars = for v in ars WHERE v != "" AND v != undefined collect v as Integer
			for b in brshs WHERE getAppData b 211 != undefined do (
				local brushIDs = execute (getAppData b 211)
				if brushIDs != "" AND brushIDs.count > 1 then (
					local faceSel = #{}
					local elements = wallwormGetElements b

					--local brushIDstring  = getUserProp b #wallworm_exported_brush_ids
					--	local brushIDs = filterString brushIDstring ","
					brushes_in_node = #()
					local elementsSelected = 0
					for i = ars.count to 1 by -1 do (
						local foundID = findItem brushIDs ars[i]
						if foundID > 0 then (
							append brushes_in_node ars[i]
							--print ("Element "+foundID as string)
							join faceSel elements[foundID]
							deleteItem ars i
							elementsSelected += 1
						)
					)
					if elementsSelected > 0 then (
						select b
						local theMod = Mesh_Select()
						addModifier b theMod
						max modify mode
						setFaceSelection b theMod (faceSel as Array) --name:"Selected Brushes"
						subObjectLevel = 5
						local n = "Brushes:"
						for brushID in brushes_in_node do (
							n += (" " + brushID as String)
						)
						theMod.name = n
					)
				)
			)

			select brshs
			max tool zoomextents
		) else (
			messageBox "No matching brushes were found."
		)
	)
	on btnLeafA pressed do
	(
		local lA = for obj in objects WHERE isProperty obj #wallworm_portal AND (obj.leafA == spLeafA.value OR obj.leafB == spLeafA.value) collect obj
		if lA.count > 0 then (
			select lA
			max zoomext sel

		)
	)
	on btnLeafB pressed do
	(
		local lA = for obj in objects WHERE isProperty obj #wallworm_portal AND (obj.leafA == spLeafB.value OR obj.leafB == spLeafB.value) collect obj
		if lA.count > 0 then (
			select lA
			max zoomext sel

		)
	)
	on getFromBoth pressed do
	(
		local lA = for obj in objects WHERE isProperty obj #wallworm_portal AND (obj.leafA == spLeafA.value OR obj.leafB == spLeafA.value) AND (obj.leafA == spLeafB.value OR obj.leafB == spLeafB.value) collect obj
		if lA.count > 0 then (
			select lA
			max zoomext sel

		)
	)
	on loadPortalFile pressed do
	(
		macros.run "wallworm.com" "WallWormLoadPRTFileMCR"
	)
	on leakLoad pressed do
	(
		macros.run "wallworm.com" "WallWormLoadLeakFileMCR"
	)
)

