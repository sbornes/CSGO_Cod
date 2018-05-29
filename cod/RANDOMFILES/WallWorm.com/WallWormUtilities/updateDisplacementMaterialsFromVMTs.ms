

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")
(
	mats = for obj in objects WHERE obj.mat != undefined AND ((classOf obj.mat == DirectX_9_Shader) OR (isProperty obj #wallworm AND (isProperty obj #ww_displacement_brush OR isProperty obj #ww_displacement OR isProperty obj #wallworm_edit_mesh))) collect obj.mat

	mats = makeuniquearray mats
	for m in mats do wallworm_update_material_from_vmt m

)