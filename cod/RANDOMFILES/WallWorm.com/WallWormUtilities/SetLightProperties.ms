/*
Wall Worm Light Properties
Copyright (c) 2012 by Shawn Olson

*/

try(destroyDialog wallwormlights)catch(
	--there was not any open
)

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/lights.ms")

createDialog wallwormlights