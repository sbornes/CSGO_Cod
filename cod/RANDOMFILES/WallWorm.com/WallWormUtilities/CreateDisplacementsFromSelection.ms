/*

Function for creating a displacement for each face in the selection.

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.mse")

fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/displacements.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")

if selection.count > 0 then (
	theDisp = wallworm_create_displacements_from_array ar:selection
	with undo off (
		if theDisp.count > 0 then (
			clearSelection()

			newcol = for disps in theDisp WHERE disps[1] != undefined collect disps[1]
			if newcol.count > 0 then (
				select newcol
				unhide newcol
			)
		)
	)
) else (
	messageBox "You need to select objects for this function to work."

)