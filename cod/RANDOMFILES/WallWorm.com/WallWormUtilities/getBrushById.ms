/*
Wall Worm Brush ID
Copyright (c) 2013 by Shawn Olson

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
try(destroyDialog wallwormBrushID)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/brush_id.ms")

createDialog wallwormBrushID