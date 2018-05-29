

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
(
	if selection.count == 0 then (
		messageBox "This function only works when you have selected a set of WWMT helpers."

	) else (
		oldsel = selection as Array
		local wwmts = 0
		clearSelection()
		for obj in oldsel WHERE (getUserProp obj #wwmt_source_helper != undefined) do (
			isWWMTSource = getUserProp obj #wwmt_source_helper
			if isDeleted obj == false AND isWWMTSource != undefined AND isWWMTSource == true then (
				local tempWWMT = ww_LOD_wrapper()
				tempWWMT.init()
				tempWWMT.setTargetModel obj tempWWMT

				selectMore (tempWWMT.createProxy())

				wwmts += 1

			)

		)

		if wwmts == 0 then (
			messageBox "No WWMT helpers were selected; no proxies were created."

		) else (
			messageBox ((wwmts as String) + " proxies were created.")

		)

	)
)