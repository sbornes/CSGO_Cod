try (destroyDialog wallworm_shape_path) catch ()

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/wallworm_shape_path.ms")

createDialog wallworm_shape_path