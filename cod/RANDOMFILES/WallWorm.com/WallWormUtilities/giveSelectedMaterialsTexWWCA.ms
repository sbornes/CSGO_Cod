(
	if (::wallworm_installation_path == undefined) then (
		::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
	)

	fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
	fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
	--fileIn (::wallworm_installation_path+"/WallWorm.com/custom_attributes/material.ms")

	cmnt = ""
	if selection.count > 0 then (
		theSel = selection as Array
		cmnt = "the selected"
	) else (
		theSel = objects as Array
		cmnt = "all"
	)

	::wallworm_assign_wwmats_to_objs theSel addTex:true

	format "The materials for % objects were given Wall Worm Material Attributes or had the Material Attribute updated. Textures were also given the texture attributes if WW Pro is installed.\n" cmnt

)