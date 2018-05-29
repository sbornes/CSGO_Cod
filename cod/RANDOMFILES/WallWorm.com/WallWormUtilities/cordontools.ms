/*
Wall Worm Cordon Tools
Copyright (c) 2012-2014 by Shawn Olson

*/

try(destroyDialog wallworm_cordon)catch(
	--there was not any open
)

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/cordon.ms")

createDialog wallworm_cordon