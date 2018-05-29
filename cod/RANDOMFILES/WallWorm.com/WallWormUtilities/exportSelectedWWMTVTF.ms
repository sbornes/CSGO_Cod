
global wallworm_tex_already_exported = #()

function wallworm_should_export_tex tex = (
	global wallworm_tex_already_exported
	if (findItem wallworm_tex_already_exported tex) > 0 then (
		--print (tex + " already found. Not exporting.")
		return false
	) else (
		append wallworm_tex_already_exported tex
		--print (tex + " exporting.")
		return true
	)

)

(
	Format "Starting Wall Worm Model VTF exporter.\n"

	if (::wallworm_installation_path == undefined) then (
		::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
	)
	fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
	
	wwProceedTexCompile = wallworm_canCompileTextures()
	if wwProceedTexCompile == true then (
		forcePrompt = false
		runExport = true
		if selection.count > 0 then (
			oldsel = selection as Array
			reSelect = true
		) else (
			forcePrompt = true
			oldsel = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true
			reSelect = false
		)
		if forcePrompt then (runExport = queryBox "Since you did not select specific WWMT Helpers, all Model's will export textures... which can take a long time.\n\nAre you sure?")
		if runExport then (
			local exportedMaterials = #()
			local exportedTextures = #()
			
			for obj in oldsel WHERE (getUserProp obj #wwmt_source_helper) != undefined do (
				isWWMTSource = isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper

				if isValidNode obj AND isWWMTSource == true then (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel obj tempWWMT
					tempWWMT.populateMyMaterials()
					for m in tempWWMT.materials do (
						
						if findItem exportedMaterials m.mat == 0 then (
							m.forModel = true
							if m.mat1 == undefined then (
								m.mat1 = m.mat
							)
							if ::wwmt_oldModelVTFPath == true then (
								wwmt_vtfMmatPath = tempWWMT.materialPath
							) else (
								wwmt_vtfMmatPath = ""
							)
							m.matName = wallworm_getMaterialName m.mat1 forModel:true
							m.getMaps()
							
							if ::skipWWMTVTFExport != true then (
								local defaultCompression = tempWWMT.compression
								if defaultCompression == "" then (
									defaultCompression = "dxt1"
								)
								local texmaparray = m.texturemaparray
								for index = 1 to texmaparray.count do (
									local thisMapData = texmaparray[index]
									local thisMap = thisMapData.thisTextureMap
									if findItem exportedTextures thisMap == 0 then (
										local thisMapLabel = thisMapData.VMTPropName
										normString = false
										case (toLower thisMapLabel) of (
											"bumpmap" : (normString = true)
											"normalmap" : (normString = true)
											default: (normString = false)
										)
										wallworm_make_vtf thisMap  shaderUsed:m.valveShader norm:normString  defaultCompression:defaultCompression
										append exportedTextures thisMap									
									)
								)								
							)
							m.compileTexture m.mat.diffuseMap "diff" shoutNotice:false writeVMT:true exportVTF:false							
							append exportedMaterials m.mat
						)
					)
				)
			)
			format "% Materials Exporter to VMT\n"  exportedMaterials.count
			format "% Textures Exporter to VTF\n"  exportedTextures.count
		)
		
	) else (
		msg = "There are problems:\n\n"
		for er in wwProceedTexCompile do (
			append msg ("* " + er + "\n")
		)
		messageBox msg
	)
	::skipWWMTVTFExport = undefined
	format "Model VMT/VTF Exporter. Hit F11 for more details.\n"
)