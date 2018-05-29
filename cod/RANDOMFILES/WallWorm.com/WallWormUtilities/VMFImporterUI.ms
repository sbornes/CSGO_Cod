

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/displacements.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/importModelsForProps.ms")

fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/VMFImport2.mse")

global wallwormVMFImporter

try(destroyDialog wallwormVMFImporter)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/VMFImport.ms")

createDialog wallwormVMFImporter

/*
wallwormVMFImporter.theVMF.brushes[1].planes[1]

wallwormVMFImporter.theVMF.brushes[1].originalBrush

*/