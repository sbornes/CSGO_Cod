/*

Wall Worm Scene Checker

Functions to help check for problems and to fix some common problems.

*/
global wallwormProblemChecker

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/problem_checker.ms")

try (
	destroyDialog wallwormProblemChecker
) catch ()

createDialog wallwormProblemChecker