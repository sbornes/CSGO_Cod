/*
Wall Worm Bone Tools
Copyright (c) 2012-2013 by Shawn Olson

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/bone_funcs.ms")

try(destroyDialog wwmt_bone_options)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/bone_options.ms")

createDialog wwmt_bone_options