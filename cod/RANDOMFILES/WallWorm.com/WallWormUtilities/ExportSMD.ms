/*
Wall Worm SMD Exporter
Copyright (c) 2012-2013 by Shawn Olson

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

try(destroyDialog wallwormSMDExport)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/smdexport.ms")

createDialog wallwormSMDExport