
if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)
fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")

function wallworm_importVMTAndApplyToScene = (
	local tempLibPath = "$matlibs/WallWormVMTImportMaterials.mat"
	if ::wallworm_vmt_import_library == undefined OR classOf ::wallworm_vmt_import_library != MaterialLibrary then (
		if doesFileExist tempLibPath == false then (
			::wallworm_vmt_import_library = MaterialLibrary()
			saveTempMaterialLibrary ::wallworm_vmt_import_library tempLibPath
		) else (
			::wallworm_vmt_import_library = loadTempMaterialLibrary tempLibPath
		)
		::wallworm_vmt_import_library = loadTempMaterialLibrary tempLibPath
	)
	if ::wwmt_raw_mats != undefined then (
		vmt = getOpenFileName caption:"Find a Source Material File (VMT)" types:"Valve Material (*.vmt)|*.vmt" historyCategory:"Wall Worm Materials" filename:::wwmt_raw_mats
	) else (
		vmt = getOpenFileName caption:"Find a Source Material File (VMT)" types:"Valve Material (*.vmt)|*.vmt" historyCategory:"Wall Worm Materials"
	)
	if vmt != undefined then (
		local mat = wallworm_generateMaterialFromVMT vmt extraPath:(getFileNamePath vmt)
		if mat != undefined then (
			local res = false
			forceCompleteRedraw()
			if selection.count > 0 then (
				res = queryBox "Do you want to apply this material to the selection?" title:"VMT Import Options"
				if res == true then (
					for obj in selection WHERE isProperty obj #material do (
						obj.material = mat
					)
				) else (
					res = false
				)
			)
			append ::wallworm_vmt_import_library mat
			saveTempMaterialLibrary ::wallworm_vmt_import_library tempLibPath
			if res == false then (
				messageBox ("The Material [ " + mat.name + " ] is now in the WallWormVMTImportMaterials.mat in your materiallibraries folder.")
			)
		) else (
			messageBox "No Material was imported."
		)
	)
)

wallworm_importVMTAndApplyToScene()