if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

global wallwormBodyGroups

try (destroyDialog wallwormBodyGroups) catch ()
fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/bodygroups.ms")

createDialog wallwormBodyGroups