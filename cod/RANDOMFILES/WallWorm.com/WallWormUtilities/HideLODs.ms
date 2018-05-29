

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

allObject = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true

for wwmt in allObject WHERE isProperty wwmt #wwmt_ca do (
	local tempWWMT = ww_LOD_wrapper()
	tempWWMT.init()
	tempWWMT.setTargetModel wwmt tempWWMT
	tempWWMT.showOnlyModel()

)

wwlodcollection = for obj in allObject WHERE isProperty obj #wwmt_lod AND isProperty obj #helperGizmo AND isValidNode obj.helperGizmo collect obj.helperGizmo
if wwlodcollection.count > 0 then (
	hide wwlodcollection
)

forceCompleteRedraw()