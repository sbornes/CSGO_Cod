

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/importers/Mario_Kart_SMD_Importer.ms")
global wallWormSMDImporter

try(destroyDialog wallWormSMDImporter)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/SMDImport.ms")

createDialog wallWormSMDImporter