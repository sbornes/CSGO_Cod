if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/material.ms")

/*
Function returns true if MultiMaterials m1 and m2 have the same number of sub-materials and those submaterials are the same. 
Set byName to true to compare by name instead of actual material.
*/
function wallworm_compareMultiMaterialsMats m1 m2:undefined byName:false nameList:undefined = (
	local same = true
	local compareCount = 0
	if m2 != undefined then (
		compareCount = m2.numsubs
		compareList = m2.materialList
	) else if nameList != undefined then (
		compareCount = nameList.count
		compareList = nameList
	)
	if m1.numsubs == compareCount then (
		local ml = m1.materialList
		for i = 1 to m1.numsubs WHERE ml[i] != undefined AND compareList[i] != undefined while same == true do (
			if byName == true then (
				if nameList == undefined then (
					if toLower ml[i].name != toLower m2.materialList[i].name then (
						same = false
					)
				) else (
					if toLower ml[i].name != toLower nameList[i] then (
						same = false
					)
				)
			) else (
				if ml[i] != m2.materialList[i] then (
					same = false
				)
			)
		)
	) else (
		same = false
	)
	same
)

function wallworm_reuse_diifuse_transform mat = (
	local d = mat.diffusemap
	if d != undefined then (
		if isProperty d #coords then (
			local c = d.coords
			for m in mat.maps do (
				if m != undefined AND m != d AND isProperty m #coords then (
					m.coords = c
				)
			)
		)
	)
)

/*
Function returns true if all of the material names in nameList are found in the Material m1. 
*/
function wallworm_doesMatHaveMatNames m1 nameList = (
	local same = true
	local subnames = for m in m1.materialList collect m.name
	for i = 1 to nameList.count WHERE nameList[i] != undefined while same == true do (
		/*print nameList
		print subnames*/
		if findItem subnames nameList[i] == 0 then (
			same = false
		)
	)
	same
)

/*This function will give the same material to all objects in the same with matching Multi-Materials*/
function wallworm_InstanceSameMultiMat mat byName:false = (
	global wallworm_compareMultiMaterialsMats
	(for o in objects WHERE o.mat != undefined AND o.mat != mat AND classOf o.mat == MultiMaterial AND o.mat.numsubs == mat.numsubs AND (wallworm_compareMultiMaterialsMats mat m2:o.mat byName:byName) == true collect o).mat = mat
)

/*This function will return an array of objects that have a MultiMaterial if it finds any objects with a submaterial list that matches the names in submatnames*/
function wallworm_FindMultiMatBySubNames submatnames = (
	global wallworm_compareMultiMaterialsMats
	(for o in objects WHERE o.mat != undefined AND classOf o.mat == MultiMaterial AND o.mat.numsubs == submatnames.count AND (wallworm_compareMultiMaterialsMats o.mat byName:true nameList:submatnames) == true collect o)
)

/*This function will return an array of objects that have a MultiMaterial if it finds any with a submaterial list that contains matches for all of the names in submatnames, regardless of order.*/
function wallworm_FindMultiMatBySubNames2 submatnames = (
	global wallworm_doesMatHaveMatNames
	(for o in objects WHERE o.mat != undefined AND classOf o.mat == MultiMaterial AND o.mat.numsubs >= submatnames.count AND (wallworm_doesMatHaveMatNames o.mat submatnames) == true collect o)
)

function wallworm_get_ww_displibrary = (
	::wallwormMaterialDisplacementLibrary
	if ::wallwormMaterialDisplacementLibrary == undefined OR classOf ::wallwormMaterialDisplacementLibrary != MaterialLibrary then (
		if doesFileExist "$matlibs/WallWormDisplacementMaterials.mat" == false then (
			::wallwormMaterialDisplacementLibrary = MaterialLibrary()
			if ::ww_wwdt_defaultMat != undefined AND superClassOf ::ww_wwdt_defaultMat == Material then (
				append ::wallwormMaterialDisplacementLibrary ::ww_wwdt_defaultMat
				saveTempMaterialLibrary ::wallwormMaterialDisplacementLibrary "$matlibs/WallWormDisplacementMaterials.mat"
			)
		) else (
			::wallwormMaterialDisplacementLibrary = loadTempMaterialLibrary "$matlibs/WallWormDisplacementMaterials.mat"
		)
	)
	::wallwormMaterialDisplacementLibrary
)

function wallworm_update_ww_displibrary mat = (
	if superClassOf mat == material then (
		wallwormMaterialDisplacementLibrary = wallworm_get_ww_displibrary()
		index = findItem wallwormMaterialDisplacementLibrary mat
		for i = wallwormMaterialDisplacementLibrary.count to 1 by -1 do (
			if wallwormMaterialDisplacementLibrary[i].name == mat.name then (
				deleteItem wallwormMaterialDisplacementLibrary i
			)
		)
		appendIfUnique wallwormMaterialDisplacementLibrary mat
		saveTempMaterialLibrary wallwormMaterialDisplacementLibrary "$matlibs/WallWormDisplacementMaterials.mat"
	)
)

function wallworm_canCompileTextures model:false = (
	local errors = #()

	if (::wallworm_engine != 1) then (
	
		if (::WallWormProSMD == undefined) then (
			if ((::wwmt_binDir == undefined OR ::wwmt_binDir == "" OR doesFileExist (::wwmt_binDir) == false)) then (
				append errors "The Bin Directory in the Settings floater must be set to a directory where VTEX.exe is located. Copy VTEX there or install Wall Worm Pro."
			)
			if  ::wwmt_binDir != undefined then (
				studiopath = ::wwmt_binDir + "\\" + "vtex.exe"
				if doesFileExist (studiopath) == false then (
					append errors "The Bin Directory does not point to a path where vtex.exe is located. Copy VTEX there or install Wall Worm Pro."
				)
			)	
		)

		if (::wwmt_gameInfoDir == undefined OR ::wwmt_gameInfoDir == "" OR doesFileExist (::wwmt_gameInfoDir) == false) then (
			append errors "The texture exporter requires you to set the Game Info Directory. Set this in the Global Wall Worm Settings."
		)
		if model == true AND (::wwmtExporter < 3) AND (::wwmt_legacy_names == false) then (
			append errors "When you are using the Wunderboy or Cannonfodder SMD Exporters with WW, you must turn on Legacy Tex Names in the settings or your models will not export properly. Please turn that on or switch to the Wall Worm SMD Exporter."
		)
	)

	if (::wwmt_exportMats == undefined OR ::wwmt_exportMats == "") then (
		append errors "The material export root has not been set."
	) else (
		if doesFileExist (::wwmt_exportMats) == false then (
			if (makeDir ::wwmt_exportMats all:true) == false then (
				append errors "The material export root does not exist and Wall Worm could not create it."
			)
		)
	)

	if errors.count > 0 then (
		errors
	) else (
		true
	)
)

/*
This function will remove the absolute path at the beginning of the file if it matches some of the common global material paths
*/
function wallworm_sanitize_texture_path texpath fs:true materialPathPrune:false = (
	if texpath != undefined then (
		texpath = ::wallworm_fsToBs texpath
		local mpadd = ""
		local checkpaths = #(::wwmt_gameInfoDir, ::wwmt_raw_mats, ::wwmt_exportMats)
		if ::wwmt_wwmt_gameInfoDirs != undefined AND ::wwmt_wwmt_gameInfoDirs.count > 0 then (
			join checkpaths ::wwmt_wwmt_gameInfoDirs
		)
		checkpaths = makeUniqueArray checkpaths
		if materialPathPrune == true then (
			mpadd = "\\materials\\"
		)
		local hasMatched = false
		for p in checkpaths while hasMatched == false do (
			if p != undefined AND p != "" then (
				local thisCheck = p + mpadd
				if thisCheck != undefined AND matchPattern texpath pattern:("*" + thisCheck + "*") then (
					texpath = substituteString texpath thisCheck ""
					hasMatched = true
				)
			)
		)

		if fs == true then (
			texpath = wallworm_BsToFs texpath

			if substring texpath 1 1 == "/" then (
				replace texpath 1 1 ""
			)
		) else (
			if substring texpath 1 1 == "\\" then (
				replace texpath 1 1 ""
			)
		)
	)
	texpath
)

function wallworm_isValidBitmap ext vtfCheck:false = (
	if (::WallwormProActive == true) then (
		true
	) else (
		if ::wallwormAllowedBitmaps == undefined then (
			::wallwormAllowedBitmaps = #(".tga", ".ifl")
			if ::wwmt_allow_psd == true then (
				append ::wallwormAllowedBitmaps ".psd"
			)
			if (vtfCheck == true AND VTFImporter != undefined) then (
				append ::wallwormAllowedBitmaps ".vtf"
			)
		)
		if (findItem ::wallwormAllowedBitmaps (toLower ext)) > 0 then (
			true
		) else (
			false
		)
	)
)

function wallworm_parseIFL f = (
	local out = #()
	if f != undefined then (
		local ext = toLower ((getFilenameType f))
		if (wallworm_isValidBitmap ext) then (
			if (ext != ".ifl") then (
				out = #(f)
			) else (
				thePath = getFileNamePath f
				local theFile = openFile f mode:"r"
				if theFile != undefined AND doesFileExist f then (
					theCurrentObject = undefined
					while (NOT eof theFile) do (
						local theLine = readLine theFile
						append out (thePath + "\\" + theLine)
					)
				)
				close theFile
			)
		)
	)
	out
)

function wallworm_outputTexName p = (
	local f = ""
	if p != undefined then (
		f = getFileNameFile p
		if getFileNameType p == ".ifl" then (
			f = f + "0"
		)
	)
	f
)

function wallworm_mat_name_limit_check filename = (
	/*return true
	Checks to see if the file name is not too long for a material
	if (filename as string).count > 22 then (
		false
	) else (
		true
	)*/
	true
)

/*Update the definitions for materials.*/
function wallworm_update_materials_ca mat addca:true = (
	local out = false
	if mat != undefined then (
		local c = custAttributes.count mat -- [Basematect:<bool>]
		if c > 0 then (
			for i = c to 1 by -1 while out == false do (
				def = custAttributes.getDef mat i
				if def.name == "Wallworm Material" then (
					custAttributes.redefine def (custAttributes.getDefSource ::wallworm_material_CA)
					out = true
				)
			)
		)
		if out == false AND addca == true then (
			custAttributes.add mat ::wallworm_material_CA
		)
	)
	out
)

/*Update the definitions for materials.*/
function wallworm_update_materialsDX_ca mat addca:true = (
	local out = false
	if mat != undefined then (
		local c = custAttributes.count mat -- [Basematect:<bool>]
		if c > 0 then (
			for i = c to 1 by -1 while out == false do (
				def = custAttributes.getDef mat i
				if def.name == "Wallworm Material DX" then (
					custAttributes.redefine def (custAttributes.getDefSource ::wallworm_materialDX_CA)
					out = true
				)
			)
		)
		if out == false AND addca == true then (
			custAttributes.add mat ::wallworm_materialDX_CA
		)
	)
	out
)

function wallworm_give_mat_ww mat addTex:false tex2:false = (
	case (classOf mat) of (
		Standard: (
			wallworm_update_materials_ca mat addca:true

			if addTex then (
				::wallwormAddTextureCAtoMaterial mat tex2:false
			)
			if isProperty mat #crackmaterial AND mat.crackmaterial != undefined then (
				wallworm_update_materials_ca mat.crackmaterial addca:true
			)
		)
		MultiMaterial:(
			for m in mat.materialList WHERE m != undefined do (
				wallworm_give_mat_ww m addTex:addTex tex2:tex2
			)
		)
		Blend:(
			wallworm_update_materials_ca mat addca:true

			if mat.map1 != undefined then (
				wallworm_give_mat_ww mat.map1 tex2:true addTex:addTex
			)
			if mat.map2 != undefined then (
				wallworm_give_mat_ww mat.map2 tex2:false addTex:addTex
			)
		)
		Shell_Material:(
			if mat.bakedMaterial != undefined then (
				wallworm_give_mat_ww mat.bakedMaterial addTex:addTex tex2:tex2
			)
		)
		Directx_9_shader: (
			wallworm_update_materialsDX_ca mat addca:true
			if mat.renderMaterial != undefined then (
				wallworm_give_mat_ww mat.renderMaterial addTex:addTex tex2:tex2
			)
		)
		default:(
			--do nothing
		)
	)
)

function wallworm_assign_wwmats_to_objs objs addTex:false = (
	for obj in objs WHERE obj.mat != undefined do (
		wallworm_give_mat_ww obj.mat addTex:addTex
	)
)

function wallworm_update_materials_cas addTex:false = (
	for mat in sceneMaterials do (
		wallworm_give_mat_ww mat addTex:addTex
	)
)

/*Update the definitions for materials.*/
function wallworm_update_texture_ca tex addca:true = (
	local out = false
	if tex != undefined then (
		local c = custAttributes.count tex -- [Basematect:<bool>]
		if c > 0 then (
			for i = c to 1 by -1 while out == false do (
				def = custAttributes.getDef tex i
				if def.name == "wallworm_texture_CA" then (
					custAttributes.redefine def (custAttributes.getDefSource ::wallworm_texture_CA)
					out = true
				)
			)
		)
		if out == false AND addca == true AND ::WallwormProActive == true then (
			custAttributes.add tex ::wallworm_texture_CA
			tex.setDefaultsFromBitmap()
		)
	)
	out
)

function wallworm_getBitmapFromTex tex = (
	undefined
	case (classOf tex) of (
		String:(
			undefined
		)
		BitmapTexture:(
			if doesFileExist tex.filename AND tex.bitmap != undefined    then (
				tex.bitmap
			)
		)
		MultiOutputChannelTexmapToTexmap:(
			wallworm_getBitmapFromTex tex.sourceMap
		)
		Output:(
			wallworm_getBitmapFromTex tex.map1
		)
		Color_Correction:(
			wallworm_getBitmapFromTex tex.Map
		)
		Normal_Bump:(
			wallworm_getBitmapFromTex tex.normal
		)
		DreamScape__TerraintextureMap:(
			wallworm_getBitmapFromTex tex.ColorMap
		)
		Ky_Color_Variator:(
			wallworm_getBitmapFromTex tex.TextureMap
		)
		default: (
			undefined
		)
	)
)


function wallworm_getMaterial m matId:undefined forModel:false collectingMat:false forVMF:false returnArray:false = (
	--try (
	local outmat = undefined
	if m != undefined then (
		if matId == undefined then (
			matId = 1
		)
		case (classOf m) of (
			Standard : (
				outmat = m
			)
			MultiMaterial : (
				if matId > m.numsubs then (
					matId = (mod matId m.numsubs) as Integer
					if matId == 0 then (
						matID = m.numsubs
					)
				)
				if matId == 0 OR m.materialList[matId] == undefined then (
					matId = 1
				)

				if matId != undefined AND m.materialList[matId] != undefined then (
					outmat = wallworm_getMaterial m.materialList[matId] matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
				) else (
					if m.materialList[1] != undefined then (
						outmat = wallworm_getMaterial m.materialList[1] matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
					)
				)
			)
			DirectX_9_Shader : (
				if collectingMat == true then (
					outmat = m
				) else (
					if m.renderMaterial != undefined AND (findString m.name "/") == undefined AND (findString m.renderMaterial.name "/") != undefined then (
						outmat = wallworm_getMaterial m.renderMaterial matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
					)
				)
			)
			Shell_Material : (
				if m.bakedMaterial != undefined then (
					outmat = wallworm_getMaterial m.bakedMaterial matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
				)
			)
			Blend : (
				if collectingMat == true then (
					outmat = m
				) else if forVMF then (
					if m.map2 != undefined then (
						outmat = wallworm_getMaterial m.map2 matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
					) else if m.map1 != undefined then (
						outmat = wallworm_getMaterial m.map2 matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
					)
				)
			)
			XRefMaterial :(
				outmat = wallworm_getMaterial (m.GetSourceMaterial true) matId:matId forModel:forModel collectingMat:collectingMat forVMF:forVMF
			)
			default: (
			)
		)
	)
	outmat
)

function wallworm_getMaterialName m matId:undefined forModel:false = (
	local materialName = "unknown"
	if m != undefined then (
		if matId == undefined then (
			matId = 1
		)
		case (classOf m) of (
			Standard : (
				local diffMap = m.diffuseMap
				if forModel == false OR ::wallworm_engine == 1 then (
					if classOf diffMap == BitmapTexture then (
						local fName = diffMap.filename
						if fName != undefined AND fName != "" then (
							if ::wallworm_engine == 1 OR (::wwmt_legacy_names == true) then (
								materialName = getFilenameFile fName
							) else (
								if fName != undefined AND fName != "" AND (substring m.name m.name.count 1) == "/" then (
									materialName = m.name + (getFilenameFile fName)
								) else (
									materialName = ::wallworm_remove_last_slash m.name
								)
							)
						) else (
							materialName = ::wallworm_remove_last_slash m.name
						)
					) else (
						materialName = ::wallworm_remove_last_slash m.name
					)
				) else if (::wwmt_legacy_names == true) AND classOf diffMap == BitmapTexture AND diffMap.filename != undefined AND diffMap.filename != "" then (
					materialName = getFilenameFile diffMap.filename
				) else (
					materialName = ::wallworm_makeStringSafe (pathConfig.stripPathToLeaf (::wallworm_remove_last_slash m.name))
				)
			)
			MultiMaterial : (
				if matId > m.numsubs then (
					matId = (mod matId m.numsubs) as Integer
					if matId == 0 then (
						matID = m.numsubs
					)
				)
				if matId == 0 OR m.materialList[matId] == undefined then (
					matId = 1
				)
				if m.materialList[matId] != undefined then (
					materialName = ::wallworm_getMaterialName m.materialList[matId] matId:matId forModel:forModel
				) else if m.materialList[1] != undefined then (
					materialName = ::wallworm_getMaterialName m.materialList[1] matId:matId forModel:forModel
				) else (
					materialName = ::wallworm_remove_last_slash m.name
				)
			)
			DirectX_9_Shader : (
				if m.renderMaterial != undefined AND (findString m.name "/") == undefined AND (findString m.renderMaterial.name "/") != undefined then (
					materialName = ::wallworm_getMaterialName m.renderMaterial matId:matId forModel:forModel
				) else (
					materialName = ::wallworm_remove_last_slash m.name
				)
			)
			Shell_Material : (
				if m.bakedMaterial != undefined then (
					materialName = ::wallworm_getMaterialName m.bakedMaterial matId:matId forModel:forModel
				) else (
					materialName = ::wallworm_remove_last_slash m.name
				)
			)
			XRefMaterial : (
				local r = m.GetSourceMaterial true
				if r != undefined then (
					materialName = ::wallworm_getMaterialName r matId:matId forModel:forModel
				) else (
					materialName = ::wallworm_remove_last_slash m.name
				)
			)

			String : (
				materialName = m
			)

			default: (
				if superClassOf m == Material then (
					materialName = ::wallworm_remove_last_slash m.name
				) else (
					materialName = ""
				)
			)
		)
	)
	materialName
)

function wallworm_getMapForCoords tex = (
	case (classOf tex) of (
		MultiOutputChannelTexmapToTexmap:(
			tex = wallworm_getMapForCoords tex.sourceMap
		)
		Output:(
			tex = wallworm_getMapForCoords tex.map1
		)
		Color_Correction:(
			tex = wallworm_getMapForCoords tex.Map
		)
		Normal_Bump:(
			tex = wallworm_getMapForCoords tex.normal
		)
		DreamScape__TerraintextureMap:(
			tex = wallworm_getMapForCoords tex.ColorMap
		)
		Ky_Color_Variator:(
			tex = wallworm_getMapForCoords tex.TextureMap
		)
	)
	tex
)

function wallworm_getMapChannel m matId:undefined forModel:false = (
	local mapChannel = undefined
	if matId == undefined then (
		matId = 1
	)
	case (classOf m) of (
		Standard: (
			local tex = wallworm_getMapForCoords m.diffusemap
			if tex != undefined then (
				local coords
				case of (
					(hasProperty tex #coords) : (coords = tex.coords)
					(hasProperty tex #coordinates) : (coords = tex.coordinates)
					default:()
				)
				if hasProperty coords #mapChannel then (
					mapChannel = coords.mapChannel
				)
			)

		)
		MultiMaterial: (
			if matId > m.numsubs then (
				matId = (mod matId m.numsubs) as Integer
			)
			if matId == 0 OR m.materialList[matId] == undefined then (
				matId = 1
			)
			if matId != undefined AND m.materialList[matId] != undefined then (
				mapChannel = wallworm_getMapChannel m.materialList[matId] matId:matId forModel:forModel
			) else (
				if m.materialList[1] != undefined then (
					mapChannel = wallworm_getMapChannel m.materialList[1] matId:matId forModel:forModel
				)
			)
		)

		DirectX_9_Shader : (
			if m.renderMaterial != undefined AND (findString m.name "/") == undefined AND (findString m.renderMaterial.name "/") != undefined then (
				mapChannel = wallworm_getMapChannel m.renderMaterial matId:matId forModel:forModel
			)
		)
		XRefMaterial :(
			local r = m.GetSourceMaterial true
			if r != undefined then (
				mapChannel = wallworm_getMapChannel r matId:matId forModel:forModel
			)
		)
		Shell_Material : (
			if m.bakedMaterial != undefined then (
				mapChannel = wallworm_getMapChannel m.bakedMaterial matId:matId forModel:forModel
			)
		)
		default: (
			mapChannel = undefined
		)
	)
	mapChannel
)

function wallworm_getMaterialName2 m &mname &matId &mchannel forModel:false = (
	if m != undefined then (
		if matId == undefined then (
			matId = 1
		)
		case (classOf m) of (
			Standard : (
				local diffMap = m.diffuseMap

				if diffMap != undefined AND classOf diffMap == BitmapTexture AND diffMap.filename != undefined AND diffMap.filename != "" then (
					mchannel = diffMap.coordinates.mapChannel
				)

				if forModel == false OR ::wallworm_engine == 1 then (
					if classOf diffMap == BitmapTexture then (
						local fName = diffMap.filename
						if fName != undefined AND fName != "" then (
							if ::wallworm_engine == 1 OR (::wwmt_legacy_names == true) then (
								mname = getFilenameFile fName
							) else (
								if fName != undefined AND fName != "" AND (substring m.name m.name.count 1) == "/" then (
									mname = m.name + (getFilenameFile fName)
								) else (
									mname = ::wallworm_remove_last_slash m.name
								)
							)
						) else (
							mname = ::wallworm_remove_last_slash m.name
						)
					) else (
						mname = ::wallworm_remove_last_slash m.name
					)
				) else if (::wwmt_legacy_names == true) AND classOf diffMap == BitmapTexture AND diffMap.filename != undefined AND diffMap.filename != "" then (
					mname = getFilenameFile diffMap.filename
				) else (
					mname = ::wallworm_makeStringSafe (pathConfig.stripPathToLeaf (::wallworm_remove_last_slash m.name))
				)
			)
			MultiMaterial : (
				if matId > m.numsubs then (
					matId = (mod matId m.numsubs) as Integer
					if matId == 0 then (
						matID = m.numsubs
					)
				)
				if matId == 0 OR m.materialList[matId] == undefined then (
					matId = 1
				)
				if m.materialList[matId] != undefined then (
					::wallworm_getMaterialName2 m.materialList[matId] &mname &matId &mchannel forModel:forModel
				) else if m.materialList[1] != undefined then (
					::wallworm_getMaterialName2 m.materialList[1] &mname &matId &mchannel forModel:forModel
				) else (
					mname = ::wallworm_remove_last_slash m.name
				)
			)
			DirectX_9_Shader : (
				if m.renderMaterial != undefined AND (findString m.name "/") == undefined AND (findString m.renderMaterial.name "/") != undefined then (
					::wallworm_getMaterialName2 m.renderMaterial &mname &matId &mchannel forModel:forModel
				) else (
					mname = ::wallworm_remove_last_slash m.name
				)
			)
			Shell_Material : (
				if m.bakedMaterial != undefined then (
					::wallworm_getMaterialName2 m.bakedMaterial &mname &matId &mchannel forModel:forModel
				) else (
					mname = ::wallworm_remove_last_slash m.name
				)
			)
			XRefMaterial : (
				local r = m.GetSourceMaterial true
				if r != undefined then (
					::wallworm_getMaterialName2 r &mname &matId &mchannel forModel:forModel
				) else (
					mname = ::wallworm_remove_last_slash m.name
				)
			)

			String : (
				mname = m
			)

			default: (
				if superClassOf m == Material then (
					mname = ::wallworm_remove_last_slash m.name
				) else (
					mname = ""
				)
			)
		)
	)

)

function wallworm_getVTFPathFromBitmap tex forcePath:"" = (
	local out = ""
	if classOf tex == Normal_Bump then (
		tex = tex.normal_map
	)
	if classOf tex == BitmapTexture then (
		if forcePath == "" then (
			if tex.name == "" then (
				tex.name = "UntitledTexture"
			)
			local texnameuse = tex.name

			local fnameuse = getFilenameFile tex.filename

			if matchPattern texnameuse pattern:("*" + fnameuse + ".vtf") then (
				/*Added to allow the bitmap node to include the bitmap name for easier reference in scene.*/
				texnameuse = substituteString texnameuse (fnameuse + ".vtf") ""
			) else if matchPattern texnameuse pattern:("*" + fnameuse + ".tga") then (
				/*Added to allow the bitmap node to include the bitmap name for easier reference in scene.*/
				texnameuse = substituteString texnameuse (fnameuse + ".tga") ""
			) else if matchPattern texnameuse pattern:("*" + fnameuse + ".psd") then (
				/*Added to allow the bitmap node to include the bitmap name for easier reference in scene.*/
				texnameuse = substituteString texnameuse (fnameuse + ".psd") ""
			) else if matchPattern texnameuse pattern:("*" + fnameuse + ".bmp") then (
				/*Added to allow the bitmap node to include the bitmap name for easier reference in scene.*/
				texnameuse = substituteString texnameuse (fnameuse + ".bmp") ""
			)
			dir = wallworm_remove_last_slash texnameuse
		) else (
			dir = wallworm_remove_last_slash (wallworm_sanitize_texture_path forcePath fs:false)
		)
		out = (wallworm_safe_path (dir + "\\" + (wallworm_sanitize_texture_path (wallworm_outputTexName tex.filename) fs:false)))

	) else (
		if classOf tex == String then (
			out = (wallworm_safe_path(forcePath + "\\" + (wallworm_outputTexName tex)))
		)
	)
	out
)

function wallworm_canTextureExportToVTF tex = (
	if isProperty tex #wallworm_texture_CA AND vtfpath != "" then (
		true
	) else (
		if tex != undefined AND classOf tex == BitmapTexture AND tex.filename != undefined then (
			if (wallworm_isValidBitmap (getFilenameType tex.filename) == true) then (
				true
			)
		)
	)
)

function wallworm_texture_path tex forcePath:undefined matRoot:false forceLegacy:false addGameDir:false fs:true startSlash:false skipExtension:false sanitize:true = (
	local texturepath = StringStream ""
	local tpath = undefined

	if sanitize == true then (
		tpath = wallworm_sanitize_texture_path tpath fs:fs
	)
	if ::WallwormProActive == true AND forceLegacy != true AND isProperty tex #wallworm_texture_CA AND tex.vtfpath != "" then (
		if forcePath != undefined AND forcePath != "" then (
			tpath = forcePath
		) else (
			tpath = tex.vtfpath
		)
		if tpath != undefined AND tpath != "" then (
			if addGameDir == true AND matRoot == true AND ::wwmt_gameInfoDir != undefined then (
				format ::wwmt_gameInfoDir to:texturepath
				if substring ::wwmt_gameInfoDir ::wwmt_gameInfoDir.count 1 != "\\" then (
					format "/" to:texturepath
				)
			)
			--this allows rendering and saving a procedural texture
			if matRoot == true then (
				format "materials/" to:texturepath
			)

			if startSlash AND substring tpath 1 1 != "/" then (
				format "/" to:texturepath
			)

			format tpath to:texturepath

			if getFileNameType (texturepath as String) == "" then (
				--look for a bitmap

				if substring tpath tpath.count 1 != "/" then (
					format "/" to:texturepath
				)

				if classOf tex == BitmapTexture AND tex.filename != undefined then (
					local fname = getFileNameFile tex.filename
					if fname != "" then (
						format "%" fname to:texturepath
					)
				)
				if NOT skipExtension then (
					if (::wallworm_engine != 1) then (
						format ".vtf" to:texturepath
					) else (
						format ".bmp" to:texturepath
					)
				)
			)
		)
	)
	if (texturepath as String) == "" then (
		if forcePath != undefined AND forcePath != "" then (
			tpath = forcePath
		)
		if tex != undefined AND classOf tex == BitmapTexture AND tex.filename != undefined then (
			if addGameDir == true AND matRoot == true AND ::wwmt_gameInfoDir != undefined then (
				format ::wwmt_gameInfoDir to:texturepath
				if substring ::wwmt_gameInfoDir ::wwmt_gameInfoDir.count 1 != "\\" then (
					format "/" to:texturepath
				)
			)
			if matRoot == true then (
				format "materials/" to:texturepath
			)
			if (wallworm_isValidBitmap (getFilenameType tex.filename) == true) then (
				if forcePath != undefined AND forcePath != "" then (
					tpath = forcePath
				) else (
					tpath = tex.name
				)

				if getFileNameType tex.name == "" then (
					format "%" (wallworm_getVTFPathFromBitmap tex forcePath:tpath) to:texturepath
				) else (
					format "%" (wallworm_getVTFPathFromBitmap tex forcePath:(getFilenamePath tpath)) to:texturepath
				)

			)
			if NOT skipExtension then (
				if (::wallworm_engine != 1) then (
					format ".vtf" to:texturepath
				) else (
					format ".bmp" to:texturepath
				)
			)
		) else if ::WallwormProActive == true AND isProperty tex #wallworm_texture_CA then (
			if addGameDir == true AND matRoot == true AND ::wwmt_gameInfoDir != undefined then (
				format ::wwmt_gameInfoDir to:texturepath
				if substring ::wwmt_gameInfoDir ::wwmt_gameInfoDir.count 1 != "\\" then (
					format "/" to:texturepath
				)
			)
			if matRoot == true then (
				format "materials/" to:texturepath
			)

			local ndname = (wallworm_safe_local tex.name)
			format "%" ndname to:texturepath

			if getFilenameFile ndname == "" then (
				format "%" (wallworm_makeStringSafe ndname) to:texturepath
			)

			if NOT skipExtension then (
				if (::wallworm_engine != 1) then (
					format ".vtf" to:texturepath
				) else (
					format ".bmp" to:texturepath
				)
			)
		)
	)
	texturepath = texturepath as String

	if skipExtension then (
		texturepath = (getFilenamePath texturepath) + (getFilenameFile texturepath)
	)

	if fs == true then (
		texturepath = wallworm_bsToFs texturepath
		texturepath = substituteString texturepath "//" "/"
	) else (
		texturepath = wallworm_fsToBs texturepath
		texturepath = substituteString texturepath "\\\\" "\\"
	)
	texturepath
)

function wallworm_getTexturesFromMaterial mat &inarray forcePath:undefined matRoot:true addGameDir:false fs:true = (
	case (classOf mat) of (
		Standard:(
			texCount = getNumSubTexmaps mat
			for i = 1 to texCount do (
				local tex = getSubTexmap mat i
				case (classOf tex) of (
					UndefinedClass:()
					Normal_Bump:(
						if tex.normal_map != undefined then (
							local texName = (wallworm_texture_path tex.normal_map forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs)
							if texName != "" then (
								append inarray texName
							)
						)
						if tex.bump_map != undefined then (
							local texName = (wallworm_texture_path tex.bump_map forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs)
							if texName != "" then (
								append inarray texName
							)
						)
					)
					default:(
						if tex != undefined then (
							local texName = (wallworm_texture_path tex forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs)
							if texName != "" then (
								append inarray texName
							)
						)
					)
				)
			)
			if isProperty mat #'Wallworm Material' then (
				local texArray = #(#lightwarptexture, #parallaxmap)
				for texparam in texArray do (
					if isProperty mat texparam then (
						tex = getProperty mat texparam
						local texName = (wallworm_texture_path tex forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs)
						if texName != "" then (
							append inarray texName
						)
					)
				)
			)
		)
		MultiMaterial: (
			for m in mat.materialList WHERE m != undefined do (
				wallworm_getTexturesFromMaterial m &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
		)
		Blend : (
			if mat.map1 != undefined then (
				wallworm_getTexturesFromMaterial mat.map1 &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
			if mat.map2 != undefined then (
				wallworm_getTexturesFromMaterial mat.map2 &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
			local msk = mat.mask
			if msk != undefined then (
				local texName = (wallworm_texture_path msk forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs)
				if texName != "" then (
					append inarray texName
				)
			)

		)
		DirectX_9_Shader : (
			if mat.renderMaterial != undefined then (
				wallworm_getTexturesFromMaterial mat.renderMaterial &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
		)
		XRefMaterial :(
			local r = mat.GetSourceMaterial true
			if r != undefined then (
				wallworm_getTexturesFromMaterial r &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
		)
		Shell_Material : (
			if mat.bakedMaterial != undefined then (
				wallworm_getTexturesFromMaterial mat.bakedMaterial &inarray forcePath:forcePath matRoot:matRoot addGameDir:addGameDir fs:fs
			)
		)
		default: (
		)
	)
)

function wallworm_appendBitmaps &mat &materials valveShader coords:false decal:false getNameFromPath:true forModel:false materialPath:undefined forceOpaque:false = (
	if mat != undefined AND materials != undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_struct_mat.ms")
		global ww_vmt
		inList = false
		for m in materials while inList == false do (
			if m.mat != undefined AND m.mat == mat then (inList = true)
		)

		if(inList == false) then (
			if (classOf mat == Standardmaterial) then (
				vmt = ww_vmt()
				vmt.mat = mat
				vmt.decal = decal
				if valveShader != undefined AND valveShader != "" then (
					vmt.valveShader = valveShader
				)

				vmt.getNameFromPath = getNameFromPath
				vmt.forModel = forModel
				vmt.setMaterialPath materialPath
				vmt.forceOpaque = forceOpaque
				vmt.getMaps()

				appendIfUnique materials vmt
				if isProperty mat #crackmaterial AND mat.crackmaterial != undefined then (
					wallworm_appendBitmaps mat.crackmaterial materials valveShader coords:coords decal:decal getNameFromPath:getNameFromPath forModel:forModel materialPath:materialPath
				)
			) else (
				if (classOf mat == MultiMaterial) then (
					for m in mat.materialList do (
						if isProperty m #valveShader then (
							vs = m.valveShader
						) else (
							vs = valveShader
						)
						wallworm_appendBitmaps &m &materials vs coords:coords decal:decal getNameFromPath:getNameFromPath forModel:forModel materialPath:materialPath
					)
				) else (
					if (classOf mat == Blend) then (
						--try (

						--print "this is a blend"
						tempMap = #()

						if isProperty mat.map1 #valveShader then (
							vs1 = mat.map1.valveShader
						) else (
							vs1 = valveShader
						)
						if isProperty mat.map2 #valveShader then (
							vs2 = mat.map2.valveShader
						) else (
							vs2 = valveShader
						)

						--wallworm_appendBitmaps mat.map1 tempMap vs1 coords:coords
						--wallworm_appendBitmaps mat.map2 tempMap vs2 coords:coords

						vmt3 = ww_vmt()
						vmt3.mat = mat
						vmt3.getMaps()

						appendIfUnique materials vmt3

						--appendIfUnique materials tempMap[1]
						--appendIfUnique materials tempMap[2]

					)

					if (classOf mat == Shell_Material) then (
						wallworm_appendBitmaps mat.bakedMaterial &materials valveShader getNameFromPath:getNameFromPath coords:coords forModel:forModel materialPath:materialPath

					)
					if (classOf mat == DirectX_9_Shader) then (
						wallworm_appendBitmaps mat.renderMaterial &materials valveShader getNameFromPath:getNameFromPath coords:coords forModel:forModel materialPath:materialPath

					)

					if (classOf mat == XRefMaterial) then (
						wallworm_appendBitmaps (mat.getSourceMaterial true) &materials valveShader getNameFromPath:getNameFromPath coords:coords forModel:forModel materialPath:materialPath

					)
				)
			)
		)
	)
)
/*	
function wallworm_remove_filename_from_path p = (
	local fnameuse = filenameFromPath tex.filename

	if matchpattern texnameuse pattern:("*"+fnameuse) then (
		texnameuse = substituteString texnameuse fnameuse ""
	)
)
*/

function wallworm_detailMapTex mat = (
	local out = undefined

	if mat.displacementMap != undefined AND classOf mat.displacementMap == Normal_Bump AND mat.displacementMap.bump_map != undefined AND (classOf mat.displacementMap.bump_map == BitmapTexture OR (::WallWormProSMD != undefined AND isProperty mat.displacementMap.bump_map #wallworm_texture_CA)) then (
		--print mat.displacementMap
		out = mat.displacementMap.bump_map
	) else (
		if mat.bumpMap != undefined then (
			if classOf mat.bumpMap == Normal_Bump AND mat.bumpMap.bump_map != undefined AND (classOf mat.bumpMap.bump_map == BitmapTexture OR (::WallWormProSMD != undefined AND isProperty mat.bumpMap.bump_map #wallworm_texture_CA)) then (
				out = mat.bumpMap.bump_map
			)
		)
	)
	out
)

function wallworm_bumpMapTex mat = (
	local out
	if mat.displacementMap != undefined then (
		if classOf mat.displacementMap == BitmapTexture then (
			out = mat.displacementMap
		) else if classOf mat.displacementMap == Normal_Bump AND mat.displacementMap.normal_map != undefined AND (classOf mat.displacementMap.normal_map == BitmapTexture OR (::WallWormProSMD != undefined AND isProperty mat.displacementMap.normal_map #wallworm_texture_CA)) then (
			out = mat.displacementMap.normal_map
		)
	) else (
		if mat.bumpMap != undefined then (
			if classOf mat.bumpMap == BitmapTexture then (
				out = mat.bumpMap
			) else (
				if classOf mat.bumpMap == Normal_Bump AND mat.bumpMap.normal_map != undefined AND (classOf mat.bumpMap.normal_map == BitmapTexture OR (::WallWormProSMD != undefined AND isProperty mat.bumpMap.normal_map #wallworm_texture_CA)) then (
					out = mat.bumpMap.normal_map
				)
			)
		)
	)
	out
)

function wallworm_use_file_source actualtexfilename = (
	local actualType = (tolower (getFilenameType actualtexfilename)) 
	local permittedBMPs = #(".tga",".bmp",".dds",".jpg",".png",".jpeg",".gif")
	(findItem permittedBMPs actualType != 0)
)

/*This function is not needed in PRO.*/
function wallworm_write_vtf_bat tex diffName:"" dir:"" VMTWritten:false runBat:true exportVTF:true extra:"" shaderUsed:"LightmappedGeneric" texlist:#() mat:undefined = (
	local bt = ""
	if ::wallworm_engine != 1 then (
		local ssbump = false

		if mat != undefined AND isProperty mat #wallworm then (
			ssbump = mat.ssbump
		)

		if classOf tex == Reflect_Refract then (
			if tex.source == 1 AND tex.outputname != undefined then (
				for cb in tex.bitmapname WHERE cb != "" do (
					if doesFileExist cb == true then (
						tptex = BitmapTexture()
						tptex.name = tex.name
						tptex.filename = cb
						append bt (wallworm_write_vtf_bat tptex diffName:diffName dir:dir VMTWritten:VMTWritten runBat:runBat exportVTF:exportVTF extra:extra shaderUsed:"UnlitGeneric" texlist:texlist)
					)
				)
			)
		) else (
			local batchstring = ""
			if classOf tex == Normal_Bump then (
				tex = tex.normal_map
			)

			local texlist = #()
			local texfilename
			local sourceFileType
			local useMap = false
			
			local canUseWallWormVTFCmdPath = false
			case of (
				(::WallwormProActive == true AND isProperty tex #wallworm_texture_CA AND isProperty tex #getTGAPath):(
					local forceTGA = true
					local tgaPfname =   tex.getTGAPath()
					texfilename = tex.getActualFileName()
					if classOf tex == BitmapTexture	then (
						local actualFilename = tex.filename	
						if actualFilename != undefined then (
							local actualType = (tolower (getFilenameType actualFilename))
							local permittedBMPs = #(".tga",".bmp",".dds",".jpg",".png",".jpeg",".gif")
								
							
							if (findItem permittedBMPs actualType != 0) then (
								forceTGA = false
							)
						)
					)
					if NOT forceTGA then (
						if  (getFileNameFile texfilename != getFileNameFile tgaPfname) then (
							forceTGA = true
						)	
					)
					if forceTGA then (
						texfilename = tgaPfname
					)
					texlist = tex.getFrames()
					useMap = true
					dir = undefined
					canUseWallWormVTFCmdPath = true
				)
				(classOf tex == BitmapTexture): (
					texfilename = tex.filename
					if texlist.count == 0 AND tex.filename != undefined then (
						texlist = wallworm_parseIFL tex.filename
					)
					useMap = true
				)
				default:()
			)

			--local texname = wallworm_getVTFPathFromBitmap tex forcePath:dir
			local texname = wallworm_texture_path tex skipExtension:true forcePath:dir
			--!TODO add texlist (animated) to the WallWormVTFCmdPath string
			if canUseWallWormVTFCmdPath == true AND ::WallWormVTFCmdPath != undefined AND texlist.count == 1 then (
				if NOT isProperty tex #getCompileString OR tex.wallworm_texture_CA.version < 20 then (
					wallworm_update_texture_ca tex
				)

				batchName = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + "_wwpro.bat") escape:true
				if batchName != undefined AND doesFileExist (getFileNamePath batchName) == false then (
					makeDir (getFileNamePath batchName) all:true
				)

				if doesFileExist batchName == true then (
					local newBatch = openFile batchName mode:"w"
				) else (
					local newBatch = createFile(batchName)
				)

				--format "@echo on\n" to:newBatch
				local VTFCmd = StringStream ""
				local rsizeString = stringstream ""
				local isVTF = false
				if classOf tex == BitmapTexture then (
					local differentDimension = false
					try (
						local bm = tex.bitmap
						if bm != undefined AND (bm.width != tex.vtfWidth OR bm.height != tex.vtfHeight) then (
							format " -resize -rwidth % -rheight %" tex.vtfWidth  tex.vtfheight to:rsizeString
							if tex.wallworm_texture_CA.version >= 20 then (
								format " -rmethod \"%\"" tex.resizemethods[tex.rmethod] to:rsizeString
								format " -rfilter \"%\"" tex.mipmapFilters[tex.rfilter] to:rsizeString
								format " -rsharpen \"%\"" tex.sharpenfilters[tex.rsharpen] to:rsizeString								
							)
							differentDimension = true
						)	
					) catch (
						format "%\n" ((getCurrentException()) as string)
					)
					if NOT differentDimension then (
						--see if this is already a VTF
						if ( (toLower (getFileNameType tex.filename)) == ".vtf") then (
							isVTF = true
						)
					)
				)
				local proceed = true
				local fstr = stringstream ""
				format "%/materials/%.vtf" ::wwmt_gameInfoDir  texname to:fstr
				local vtffile = fstr as string
				if isVTF == true then (
					if  ( pathConfig.pathsResolveEquivalent vtffile tex.filename) then (
						proceed = false
						--don't try to overwrite itself
					)
				)
				if proceed == true then (
					local outpuat = (getFileNamePath vtffile)
					if doesFileExist outpuat == false then (
						makeDir outpuat all:true
					)

					format "\"%\" -file \"%\" -output \"%\materials%%\" %%" ::WallWormVTFCmdPath (mapPaths.getFullFilePath texfilename) ::wwmt_gameInfoDir "\\" (::wallworm_remove_last_slash (getFileNamePath texname) char:"\\") (tex.getCompileString() as String) (rsizeString as string) to:VTFCmd
					format (::wallworm_fsToBs (VTFCmd as String)) to:newBatch
					--format "@pause\n" to:newBatch
					close newBatch
					shellLaunch batchName ""					
				)
			) else (
				/*local outdir = stringstream ""
				format "-outdir \"%materials\\%\"" wwmt_gameInfoDir (getFileNamePath texname) to:outdir
				outdir = outdir as string*/
				if useMap == true then (
					local tga1 = texfilename

					if (getFilenameType tga1) == ".ifl" then (
						tga = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + (getFilenameType texlist[1]))
						if ssbump then (
							ssbumpname = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + "_ssbump" + (getFilenameType texlist[1]))
						)
					) else (
						tga = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + (getFilenameType texfilename))
						if ssbump then (
							ssbumpname = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + "_ssbump" + (getFilenameType texfilename))
						)
					)
				) else (
					tga = tex
				)

				batchName = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + ".bat")
				if batchName != undefined AND doesFileExist (getFileNamePath batchName) == false then (
					makeDir (getFileNamePath batchName) all:true
				)

				if doesFileExist batchName == true then (
					local newBatch = openFile batchName mode:"w"
				) else (
					local newBatch = createFile(batchName)
				)

				format "@echo on\n" to:newBatch

				local gameInfoParam = ""

				if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
					gameInfoParam = " -game \"" + ::wwmt_gameInfoDir + "\""
				)	
				local ds = "\\"
				if ssbump then (
					/*See if normal2ssbump.exe resides in BIN*/
					if doesFileExist (::wwmt_binDir + "\\normal2ssbump.exe") then (
						
						format  "\"%\\normal2ssbump.exe\"  \"%\"\r\n" ::wwmt_binDir tga to:newBatch
						if runBat == false then (
							append gameInfoParam " -nopause"
						)
						format "\"%\vtex.exe\"% -mkdir -outdir \"%%materials\%%\"  \"%\"\r\n" ::wwmt_binDir gameInfoParam wwmt_gameInfoDir ds ds (wallworm_remove_last_slash (getFileNamePath texname) char:"\\")  ssbumpname to:newBatch
					) else (
						format  "%\\normal2ssbump.exe not found... skipping SSBump conversion.\n" ::wwmt_binDir
					)
				)
				if runBat == false then (
					append gameInfoParam " -nopause"
				)
				

				
				format "\"%\vtex.exe\"% -mkdir -outdir \"%%materials%%\" \"%\"\r\n" ::wwmt_binDir gameInfoParam ::wwmt_gameInfoDir ds ds (wallworm_remove_last_slash (getFileNamePath texname) char:"\\")  tga to:newBatch
				if batchstring != "" then (
					format batchstring to:newBatch
				)
				format "@pause\n" to:newBatch
				close newBatch
				if runBat == true AND exportVTF == true then (
					shellLaunch batchName ""
				)
			)
		)
	)
	bt
)

function wallworm_get_exportedFilename tex forcePath:"" = (
	local tga = ""
	if ::WallwormProActive == true AND NOT isProperty tex #getTGAPath then (
		::wallworm_update_texture_ca tex addca:true
	)
	if ::WallwormProActive == true AND isProperty tex #getTGAPath then (
		tga = tex.getTGAPath()
	) else (
		if isProperty tex #filename then (
			local texname = wallworm_getVTFPathFromBitmap tex forcePath:forcePath
			if (getFilenameType tex.filename) == ".ifl" then (
				local texlist = wallworm_parseIFL tex.filename
				tga = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + (toLower ((getFilenameType texlist[1]))))
			) else (
				tga = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + (toLower ((getFilenameType tex.filename))))
			)			
		)
	)
	tga
)

/*This function is not needed in PRO.*/
function wallworm_copy_bitmap_to_sdk tex forcePath:"" texlist:#() compression:undefined norm:false sky:false clampS:false clampT:false = (
	if classOf tex == Reflect_Refract then (
		if tex.source == 1 AND tex.outputname != undefined then (
			for cb in tex.bitmapname WHERE cb != "" do (
				if doesFileExist cb then (
					tptex = BitmapTexture()
					tptex.name = tex.name
					tptex.filename = cb
					wallworm_copy_bitmap_to_sdk tptex forcePath:forcePath texlist:texlist compression:compression norm:norm sky:sky
				)
			)
		)
	) else (
		if classOf tex == Normal_Bump then (
			tex = tex.normal_map
		)
		local skipRender = false
		if ::WallwormProActive == true AND (NOT isProperty tex #getTGAPath OR tex.wallworm_texture_CA.version < 17) then (
			::wallworm_update_texture_ca tex addca:true
		)
		local tga = ""
		local newParams
		--local texname = wallworm_getVTFPathFromBitmap tex forcePath:forcePath
		local texname = wallworm_texture_path tex skipExtension:true --forcePath:forcePath
		local texlist = #()
		local texfilename
		local canRender = false
		local actualtexfilename 
		case of (
			(isProperty tex #wallworm_texture_CA AND isProperty tex #getActualFileName):(
				texfilename = tex.getTGAPath()
				--local allowedfiles = #(".tga",".psd")
				--if ::WallwormProActive == true AND doesFileExist texfilename AND (findItem allowedfiles (getFileNameType texfilename) > 0) then skipRender = true
				texlist = tex.getFrames()
			
				actualtexfilename = tex.getActualFileName()
				if wallworm_use_file_source actualtexfilename AND doesFileExist actualtexfilename then (
					skipRender = true
				)
				canRender = true
				clampS = (bit.and tex.textureFlags tex.wwTextureFlags_ClampS) != 0
				clampT = (bit.and tex.textureFlags tex.wwTextureFlags_ClampT) != 0

				case (tex.compression) of (
					"DXT1":(
						compression = ""
					)
					"DXT5":(
						compression = "dxt5"
					)
					"NONE":(
						compression = "nocompress"
					)
					default:(
						compression = "dxt5"
					)
				)
				norm = (bit.and tex.textureFlags tex.wwTextureFlags_Normal) != 0
			)
			(classOf tex == BitmapTexture): (
				texfilename = tex.filename
				actualtexfilename = texfilename
				texlist = wallworm_parseIFL tex.filename
			)
			default:()
		)

		tga = wallworm_get_exportedFilename tex forcePath:""

		--format "Source: %\nDestination: %\n" texlist[1] tga
		local pth = stringstream ""
		format "%/%.txt"  ::wwmt_exportMats texname to:pth
		local tn = wallworm_safe_path (::wallworm_BStoFS(pth as string)) escape:true
		if doesFileExist (getFileNamePath tn) == false then (
			makeDir (getFileNamePath tn) all:true
		)

		if doesFileExist tn == true then (
			local newParams = openFile tn mode:"w"
		) else (
			local newParams = createFile tn
		)
		if norm == true then (
			--No compression because a normal map
			format ("normal 1\n") to:newParams
		)

		if compression != undefined AND compression != "" then (
			/*
			if tolower compression == "dxt5" AND (tex.alphasource == 2 OR (tex.bitmap != undefined AND tex.bitmap.hasAlpha == false)) then (
				--do not add alpha
			)*/
			--Use designated compression
			format "% 1\n" (toLower compression) to:newParams
		)

		if clampS == true then (
			format "clamps 1\n" to:newParams
		)
		if clampT == true then (
			format "clampt 1\n" to:newParams
		)

		if texlist.count > 1 then (
			--This is an image file list
			format ("startframe 0\nendframe " + ((texlist.count - 1) as String) + "\n") to:newParams
		)
		close newParams

		if (texfilename != undefined AND (pathConfig.pathsResolveEquivalent texfilename tga) == false) AND doesFileExist tga then (
			--print ("Deleting "+tga)
			deleteFile tga
		)

		local proceedWithCopy = true
		if skipRender == false then (
			if  canRender == true then (
				proceedWithCopy = NOT (tex.renderMeToTGA())
			)
		) else (
			proceedWithCopy = false
		)
		local mapPathsgetFullFilePath = mapPaths.getFullFilePath
		if proceedWithCopy == true then (
			if actualtexfilename == undefined OR actualtexfilename == "" then (
				actualtexfilename =  (mapPathsgetFullFilePath texlist[1])
			)
			if getFilenamePath actualtexfilename != getFilenamePath tga OR (getFileNameFile actualtexfilename == getFileNameFile tga) then (
				copyFile actualtexfilename tga
			)
		)
		if (toLower ((getFilenameType actualtexfilename)) == ".ifl") then (
			theTexBit = BitmapTexture()
			theTexBit.name = tex.name
			for t in texlist do (
				theTexBit.filename = t
				texname = wallworm_getVTFPathFromBitmap theTexBit forcePath:forcePath
				tga2 = wallworm_safe_path (::wwmt_exportMats + "\\" + texname + (toLower ((getFilenameType t))))
				--print  tga2
				if doesFileExist t AND (getFilenamePath t != getFilenamePath tga2) then (
					if doesFileExist tga2 then (
						deleteFile tga2
					)
					copyFile (mapPathsgetFullFilePath t) tga2
				)
			)
		)
	)
)

/*
@param bmtex BitMapTexture -- should be a bitmaptexture
@param shaderUsed String Used to set the shader if letting VTEX.EXE write the VMT. Probably not used anymore but can't remove without testing various aspects of WW that have ties to ancient places.
@param norm Boolean Whether this bitmap is a NormalMap. Tells VTEX to treat it like a Normal
@param forcePath String Path to place this bitmap in if needs to override.
*/
function wallworm_make_vtf bmtex shaderUsed:"VertexLitGeneric" norm:false forcePath:"" defaultCompression:"dxt5" sky:false = (
	if (::WallwormProActive == true) then (
		--Let WW Pro create the VTF immediately when code is done

		if isProperty bmtex #wallworm_texture_CA then (
		) else (
			custAttributes.add bmtex ::wallworm_texture_CA

			--bmtex.setTextureFlag bmtex.wwTextureFlags_Normal

			case (defaultCompression) of (
				"":(
					bmtex.compression = "DXT1"
				)
				"dxt5":(
					bmtex.compression = "DXT5"
				)
				"nocompress":(
					bmtex.compression = "NONE"
				)
				default:(
					bmtex.compression = "DXT5"
				)
			)
			if sky then (
				bmtex.setTextureFlag bmtex.wwTextureFlags_ClampS
				bmtex.setTextureFlag bmtex.wwTextureFlags_ClampT
			)

			/*
			--SEE IF THIS IS AN IFL... if so then set the frames and animation set

			*/

			bmtex.setDefaultsFromBitmap()

		)

		actualFileName = bmtex.getFileName() --(wallworm_texture_path bmtex matRoot:true addGameDir:true fs:true) --where WW PRO should write the VTF
		--NOTE: the fs:false has Back Slashes... but windows is fine with the forward slash... and using forward won't accidentally cause string parsers to think a path like \this\nice\path as TABhisNEWLINEice\path
		--!TODO --write the PRO CODE TO WRITE VTF FILE based on the WW TEX CA
		-- 		local vtf = (DotNetClass "WallWorm.VTF.VTFFile").createFile()
		-- 		vtf.Height = bmtex.vtfHeight
		-- 		vtf.Width = bmtex.vtfWidth
		-- 		vtf.Flags = bmtex.textureFlags
		-- 		vtf.ImageFormat = bmtex.compression
		-- 		local bx = Box name:"Temp box" material:bmtex pos:[0, 0, 0] renderable:off heigh:16 width:16 length:16
		-- 		convertTo bx Editable_Poly

		-- 		(DotNetClass "WallWorm.Helpers.VTFHelper").WriteVTF (bx.inode.handle) vtf actualFileName

		/*Begin Temporary*/
		--format "PRO WILL SAVE TO %\n" actualFileName

		case (bmtex.compression) of (
			"DXT1":(
				compressionVal = ""
			)
			"DXT5":(
				compressionVal = "dxt5"
			)
			"NONE":(
				compressionVal = "nocompress"
			)
			default:(
				compressionVal = "dxt5"
			)
		)

		if (forcePath == undefined OR forcePath == "") AND bmtex.vtfpath != "" then (
			forcePath = getFileNamePath (wallworm_texture_path bmtex) -- getFileNamePath bmtex.vtfpath
		)

		normVal = (bit.and bmtex.textureFlags bmtex.wwTextureFlags_Normal) != 0
		wallworm_copy_bitmap_to_sdk bmtex forcePath:forcePath compression:compressionVal norm:norm --WON'T NEED THIS ONE because  we can write VTF directly to GAME FOLDERS
		wallworm_write_vtf_bat bmtex dir:forcePath VMTWritten:true runBat:true exportVTF:true shaderUsed:shaderUsed -- WON'T NEED THIS ONE because  WWPRO writes VTF and no need to make batch files/execute.
		/*End Temporary*/
	) else (
		wallworm_copy_bitmap_to_sdk bmtex forcePath:forcePath compression:defaultCompression norm:norm
		wallworm_write_vtf_bat bmtex dir:forcePath VMTWritten:true runBat:true exportVTF:true shaderUsed:shaderUsed
	)
)

function wallwormAddTextureCAtoMaterial mat tex2:false = (
	if ::WallwormProActive == true then (
		case (classOf mat) of (
			Standard:(
				local baseTexture = mat.diffuseMap
				if baseTexture != undefined then (
					wallworm_update_texture_ca baseTexture
					if tex2 then (
						appendifunique baseTexture.vmtproperties "basetexture2"
					) else (
						appendifunique baseTexture.vmtproperties "basetexture"
					)
				)

				local phongexponenttexture = mat.specularMap
				if phongexponenttexture != undefined then (
					wallworm_update_texture_ca phongexponenttexture
					if tex2 then (
						appendifunique phongexponenttexture.vmtproperties "phongexponenttexture2"
					) else (
						appendifunique phongexponenttexture.vmtproperties "phongexponenttexture"
					)
				)

				local ambientocclusion = mat.AmbientMap
				if ambientocclusion != undefined then (
					mat.shaderByName = "phong"
					wallworm_update_texture_ca ambientocclusion
					appendifunique ambientocclusion.vmtproperties "ambientocclusion"
				)

				local detailMap = undefined

				local bumpAsNormal = true
				local normalmap = mat.DisplacementMap
				if normalmap != undefined then (
					wallworm_update_texture_ca normalmap
					normalmap.setTextureFlag normalmap.wwTextureFlags_Normal
					if classOf normalmap == Normal_Bump then (
						if normalmap.bump_map != undefined then (
							detailMap = normalmap.bump_map
						)
						normalmap = normalmap.normal_map
					)

				)

				if normalmap != undefined then (
					wallworm_update_texture_ca normalmap
					normalmap.setTextureFlag normalmap.wwTextureFlags_Normal
					if tex2 then (
						appendifunique normalmap.vmtproperties "normalmap2"
					) else (
						appendifunique normalmap.vmtproperties "normalmap"
					)
					bumpAsNormal = false
				)

				if detailMap != undefined then (
					wallworm_update_texture_ca detailMap
					if tex2 then (
						appendifunique detailMap.vmtproperties "detail2"
					) else (
						appendifunique detailMap.vmtproperties "detail"
					)
				)

				detailMap = undefined

				local bumpmap = mat.BumpMap
				
				if bumpmap != undefined then (
					if classOf bumpmap == Normal_Bump then (
						wallworm_update_texture_ca bumpmap
						bumpmap.setTextureFlag bumpmap.wwTextureFlags_Normal
						if bumpmap.bump_map != undefined then (
							detailMap = bumpmap.bump_map
						)
						bumpmap = bumpmap.normal_map
					)
				)

				if bumpmap != undefined then (
					wallworm_update_texture_ca bumpmap
					if bumpAsNormal then (
						bumpmap.setTextureFlag bumpmap.wwTextureFlags_Normal
						if tex2 then (
							appendifunique bumpmap.vmtproperties "normalmap2"
						) else (
							appendifunique bumpmap.vmtproperties "normalmap"
						)
					) else (
						if tex2 then (
							appendifunique bumpmap.vmtproperties "bumpmap2"
						) else (
							appendifunique bumpmap.vmtproperties "bumpmap"
						)
					)
					bumpAsNormal = false
				)

				if detailMap != undefined then (
					wallworm_update_texture_ca detailMap
					if tex2 then (
						appendifunique detailMap.vmtproperties "detail2"
					) else (
						appendifunique detailMap.vmtproperties "detail"
					)
				)

				local Selfillumtexture = mat.selfIllumMap
				if Selfillumtexture != undefined then (
					wallworm_update_texture_ca Selfillumtexture
					if tex2 then (
						appendifunique Selfillumtexture.vmtproperties "selfillumtexture2"
					) else (
						appendifunique Selfillumtexture.vmtproperties "selfillumtexture"
					)
				)

				local envmapmask = mat.SpecularLevelMap
				if envmapmask != undefined then (
					wallworm_update_texture_ca envmapmask
					if tex2 then (
						appendifunique envmapmask.vmtproperties "envmapmask2"
					) else (
						appendifunique envmapmask.vmtproperties "envmapmask"
					)
				)

				if isProperty mat #wallworm then (
					local lightwarptexture = mat.lightwarptexture
					if lightwarptexture != undefined then (
						wallworm_update_texture_ca lightwarptexture
						if tex2 then (
							appendifunique lightwarptexture.vmtproperties "lightwarptexture2"
						) else (
							appendifunique lightwarptexture.vmtproperties "lightwarptexture"
						)
					)

					local parallaxmap = mat.parallaxmap
					if parallaxmap != undefined then (
						wallworm_update_texture_ca parallaxmap
						if tex2 then (
							appendifunique parallaxmap.vmtproperties "parallaxmap2"
						) else (
							appendifunique parallaxmap.vmtproperties "parallaxmap"
						)
					)

				)

			)
			Blend:(
				--with blend textures, map1 is the second set of params (basetexture2, normalmap2, etc)
				wallwormAddTextureCAtoMaterial mat.map1 tex2:true
				wallwormAddTextureCAtoMaterial mat.map2 tex2:false
				local blendmod = mat.mask
				if blendmod != undefined AND classof blendmod != Vertex_Color then (
					wallworm_update_texture_ca blendmod
					appendifunique blendmod.vmtproperties "blendmodulatetexture"
				)
			)

			MultiMaterial:(
				for m in mat.marerialList WHERE m != undefined do (
					wallwormAddTextureCAtoMaterial m
				)
			)

			Shell_Material:(
				wallwormAddTextureCAtoMaterial mat.bakedMaterial
			)

			default:(
			)

		)
	)

)

function wallworm_TextureUntextured objarray:undefined theMat:undefined = (
	if theMat == undefined then (
		if ::sme != undefined AND isProperty ::sme "GetMtlInParamEditor" then (
			--get the material that is open in slate
			theMat = sme.GetMtlInParamEditor()
			if theMat == undefined OR superClassOf theMat != Material then (
				--either there is nothing selected or it isn't a Material (like a texture or float, etc)
				theMat = medit.GetCurMtl()
			)
		) else (
			--for older versions of Max that don't have Slate
			theMat = medit.GetCurMtl()
		)
	)

	if theMat != undefined AND superClassOf theMat == Material then (
		if objarray == undefined then (
			if selection.count > 0 then (
				objarray = selection as Array
			) else (
				objarray = objects as Array
			)
		)
		if objarray.count > 0 then (
			for obj in objarray WHERE obj.mat == undefined do (
				obj.mat = theMat
			)
		)
	)
)

function wallworm_update_dxdisplay dxversion:11 = (
	for mat in sceneMaterials WHERE classOf mat == DirectX_9_Shader AND getFileNameFile mat.effectfile == "blend_dxsas11_nitrous" do (
		wallworm_update_materialsDX_ca mat
		if viewport.GetRenderLevel() != #smoothhighlights then (
			if dxversion != 11 then (
				mat.technique = 3
			) else (
				mat.technique = 1
			)
		) else (
			if dxversion != 11 then (
				mat.technique = 2
			) else (
				mat.technique = 0
			)
		)
	)
)

function wallworm_valid_dxfiles filename = (
	local allwedtypes = #(".tga",".bmp",".dds",".jpg",".png",".psd",".hdr")
	getFileNameType filename != ".vtf"
)

function wallworm_blend_to_DXBlend mat:undefined rev:false useStandard:false forcelegacy:false = (
	local mat2

	defaultBitmaps = #()
	local bm1 = openBitMap (::wallworm_installation_path + "/WallWorm.com/materials/wwmt/share/rock1_d.tga")
	local bm2 = openBitMap (::wallworm_installation_path + "/WallWorm.com/materials/wwmt/share/sand1_d.tga")
	if mat != undefined AND classOf mat == Blend then (
		mat2 = mat
		if mat2.map1 != undefined AND mat2.map1.diffusemap != undefined AND classOf mat2.map1.diffusemap == bitmaptexture AND doesFileExist mat2.map1.diffusemap.filename == true AND ((::WallwormProActive == true) OR (VTFImporter != undefined OR getFileNameType mat2.map1.diffusemap.filename != ".vtf")) then (
			bm1 = mat2.map1.diffusemap.Bitmap
		)
		if mat2.map2 != undefined AND mat2.map2.diffusemap != undefined AND classOf mat2.map2.diffusemap == bitmaptexture AND doesFileExist mat2.map2.diffusemap.filename == true AND ((::WallwormProActive == true) OR (VTFImporter != undefined OR getFileNameType mat2.map2.diffusemap.filename != ".vtf")) then (
			bm2 = mat2.map2.diffusemap.Bitmap
		)
	) else (
		local tex1 = bitmaptexture bitmap:bm1 filename:bm1.filename name:"wwmt/share/rock1_d.vtf"
		local tex2 = bitmaptexture bitmap:bm2 filename:bm2.filename name:"wwmt/share/sand1_d.vtf"

		if mat == undefined OR classOf mat != Standard then (
			
			
			local bmn1 = openBitMap (::wallworm_installation_path + "/WallWorm.com/materials/wwmt/share/rocks1_spec_normal.tga")
			local bmn2 = openBitMap (::wallworm_installation_path + "/WallWorm.com/materials/wwmt/share/sand1_spec_normal.tga")
			
			local ntex1 =  bitmaptexture bitmap:(bmn1)  name:"wwmt/share/rocks1_spec_normal.vtf"
			local ntex2 =  bitmaptexture  bitmap:(bmn2) name:"wwmt/share/sand1_spec_normal.vtf"
			
			local stex1 =  bitmaptexture bitmap:(bmn1)  name:"wwmt/share/rocks1_spec_normal.vtf"
			local stex2 =  bitmaptexture bitmap:(bmn2)  name:"wwmt/share/sand1_spec_normal.vtf"
			
			stex1.monoOutput = stex2.monoOutput = stex1.rgbOutput = stex2.rgbOutput =1

			local bmbl = openBitMap (::wallworm_installation_path + "/WallWorm.com/materials/wwmt/share/sandstone_blendmodulate.tga")
			local blmod = bitmaptexture bitmap:(bmbl)  name:"wwmt/share/sandstone_blendmodulate.vtf"
			
			mat2 = Blend map2:(Standard diffusemap:(tex1) bumpmap:ntex1 specularlevelmap:stex1 showInViewport:true name:"wwmt/share/rock1") map1:(Standard diffusemap:(tex2)  bumpmap:ntex2  specularlevelmap:stex2 showInViewport:true name:"wwmt/share/sand1") mask:blmod showInViewport:true name:"wwmt/share/blendrocksand1"
		) else (
			if classOf mat == Standard AND mat.diffusemap != undefined AND classOf mat.diffusemap == BitmapTexture then (
				mat2 = Blend map1:mat map2:(Standard diffusemap:(tex2) showInViewport:true name:"wwmt/share/sand1") showInViewport:true name:("wwmt/myblends/blend"+(getfilenamefile mat.name)+"sand")
			)
		)
	)

	local dxmat
	local maxv = (MaxVersion())[1]
	if maxv >= 16000 AND (NitrousGraphicsManager.IsEnabled() == true) then (
		local fx11 = (GetDir #maxroot) + "maps/fx/StandardFX11.fx"
		if useStandard AND doesFileExist (fx11) then (
			dxmat = DirectX_9_Shader effectFilename:fx11 name:mat2.name
			if hasProperty dxmat #g_topTexture then (
				dxmat.g_AlphaVertex = on
				dxmat.g_TopDiffuseEnable = on
				dxmat.g_BottomDiffuseEnable = on
				dxmat.g_SpecularEnable = on
				dxmat.n = 0
				if rev == true then (
					dxmat.g_topTexture = bm1
					dxmat.g_bottomTexture = bm2
				) else (
					dxmat.g_topTexture = bm2
					dxmat.g_bottomTexture = bm1
				)
			)
		) else (
			local effectFile = (::wallworm_installation_path + "/WallWorm.com/assets/shader/WorldVertexTransition.fx")
			if forcelegacy == false AND maxv >= 17000 AND doesFileExist effectFile then (
				dxmat = DirectX_9_Shader effectFilename:effectFile name:mat2.name
				--dxmat.useshaderfx = true
				if hasProperty dxmat #basetexture then (
					dxmat.Light0Type = 4
					if classof mat2.mask == BitmapTexture then (
						dxmat.blendmodulatetexture = mat2.mask.bitmap
					)
					
					local bmn1 = undefined
					local bmn2 = undefined
					if mat2.map1 != undefined then (
						bmn1 = wallworm_getBitmapFromTex mat2.map1.bumpmap
					)
					if mat2.map2 != undefined then (
						bmn2 = wallworm_getBitmapFromTex mat2.map2.bumpmap
					)
					local bms1 = undefined
					local bms2 = undefined
					if mat2.map1 != undefined then (
						bms1 = wallworm_getBitmapFromTex mat2.map1.specularLevelMap
					)
					if mat2.map2 != undefined then (
						bms2 = wallworm_getBitmapFromTex mat2.map2.specularLevelMap
					)
					--format "%\n bm1  %\n bm2 %\n bmn1 %\n bmn2 %\n bms1 %\n bms2 % \n" rev (getFileNameFile bm1.filename)  (getFileNameFile bm2.filename)  (getFileNameFile bmn1.filename) (getFileNameFile bmn2.filename) (getFileNameFile bms1.filename) (getFileNameFile bms2.filename)
					if rev == true then (
						
						dxmat.basetexture =  bm1
						dxmat.basetexture2 =  bm2
						
						if bmn1 != undefined then (
							dxmat.bumpmap =  bmn1
						) 
						if bmn2 != undefined then (
							dxmat.bumpmap2 =  bmn2
						) 
						if bmn1 != undefined then (
							dxmat.usebump = true
						) else (
							dxmat.usebump = false
						)
						if bmn2 != undefined then (
							dxmat.usebump2 = true
						) else (
							dxmat.usebump2 = false
						)
						
						if bms1 != undefined then (
							dxmat.envmapmask =  bms1
						) 
						if bms2 != undefined then (
							dxmat.envmapmask2 =  bms2
						) 
						if bms1 != undefined then (
							dxmat.useenvmapmask = true
						) else (
							dxmat.useenvmapmask = false
						)
						if bms2 != undefined then (
							dxmat.useenvmapmask2 = true
						) else (
							dxmat.useenvmapmask2 = false
						)

					) else (
						
						dxmat.basetexture =  bm2
						dxmat.basetexture2 =  bm1

						if bmn2 != undefined then (
							dxmat.bumpmap =  bmn2
						) 
						if bmn1 != undefined then (
							dxmat.bumpmap2 =  bmn1
						) 
						
						if bmn2 != undefined then (
							dxmat.usebump = true
						) else (
							dxmat.usebump = false
						)
						if bmn1 != undefined then (
							dxmat.usebump2 = true
						) else (
							dxmat.usebump2 = false
						)
						
						if bms2 != undefined then (
							dxmat.envmapmask =  bms2
						) 
						if bms1 != undefined then (
							dxmat.envmapmask2 =  bms1
						) 
						if bms2 != undefined then (
							dxmat.useenvmapmask = true
						) else (
							dxmat.useenvmapmask = false
						)
						if bms1 != undefined then (
							dxmat.useenvmapmask2 = true
						) else (
							dxmat.useenvmapmask2 = false
						)

					)
					if (dxmat.usebump2 == dxmat.useenvmapmask2) AND dxmat.useenvmapmask2 == true AND dxmat.bumpmap2 != undefined AND dxmat.envmapmask2 != undefined AND  dxmat.bumpmap2.filename == dxmat.envmapmask2.filename then (
						dxmat.envmapusealpha2 = true
					) else (
						dxmat.envmapusealpha2 = false
					)
					if ((dxmat.usebump == dxmat.useenvmapmask)  AND dxmat.useenvmapmask == true)  AND dxmat.bumpmap != undefined AND dxmat.envmapmask != undefined AND dxmat.bumpmap.filename == dxmat.envmapmask.filename then (
						dxmat.envmapusealpha = true
					) else (
						dxmat.envmapusealpha = false
					)
				)
			) else (
				if doesFileExist (fx11) then (
					dxmat = DirectX_9_Shader effectFilename:fx11 name:mat2.name
					if hasProperty dxmat #g_topTexture then (
						dxmat.g_AlphaVertex = on
						dxmat.g_TopDiffuseEnable = on
						dxmat.g_BottomDiffuseEnable = on
						dxmat.g_SpecularEnable = on
						dxmat.n = 0
						if rev == true then (
							dxmat.g_topTexture = bm1
							dxmat.g_bottomTexture = bm2
						) else (
							dxmat.g_topTexture = bm2
							dxmat.g_bottomTexture = bm1
						)
					)
				) else (
					effectFile = (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/maps/fx/blend_dxsas11_nitrous.fx")
					dxmat = DirectX_9_Shader effectFilename:effectFile name:mat2.name
					if hasProperty dxmat #TextureTop then (
						if rev == true then (
							dxmat.TextureTop = bm1
							dxmat.TextureBottom = bm2
						) else (
							dxmat.TextureTop = bm2
							dxmat.TextureBottom = bm1
						)
					)					
				)
			)
		)
	) else (
		dxmat = DirectX_9_Shader effectFilename:((GetDir #maxroot) + "maps/fx/blend_dxsas.fx") name:mat2.name
		if hasProperty dxmat #seteffectbitmap then (
			if rev == false then (
				dxmat.seteffectbitmap 1 bm1
				dxmat.seteffectbitmap 2 bm2
			) else (
				dxmat.seteffectbitmap 1 bm2
				dxmat.seteffectbitmap 2 bm1
			)
		)
	)

	/*Swap the materials. Probably from an imported VMT*/
	/*if rev == true then (
		om1 = mat2.map1
		om2 = mat2.map2
		mat2.map1 = om2
		mat2.map2 = om1
	)*/
	dxmat.renderMaterial = mat2

	wallworm_update_materials_ca mat2.map1 addca:true
	wallworm_update_materials_ca mat2.map2 addca:true
	wallworm_update_materials_ca dxmat.renderMaterial addca:true
	wallworm_update_materialsDX_ca dxmat addca:true

	dxmat
)

function wallworm_convert_blends_to_dx objs rev:false = (
	local objMats = for obj in objs WHERE obj.mat != undefined AND classOf obj.mat == Blend collect obj.mat
	objMats = makeUniqueArray objMats
	local newMats = #()
	for i = 1 to objMats.count do (
		local newMat = (wallworm_blend_to_DXBlend mat:objMats[i] )
		append newMats newMat
		for obj in objs WHERE obj.mat == objMats[i] do (
			obj.mat = newMat
		)
	)
)
--updates all the blends to a format where their exported VMT will match the display of the DX shader.
function wallworm_update_blends objs:geometry fixNames:false = (
	--now find all objects with DX material and update their CA... then run the function to set Blend from DX
	local objMats = for obj in objs WHERE obj.mat != undefined AND classOf obj.mat == DirectX_9_Shader collect obj.mat
	objMats = makeUniqueArray objMats
	for mat in objMats do (
		wallworm_update_materialsDX_ca mat addca:true
		mat.updateRenderMatFromThis rev:false fixNames:fixNames
	)
)

/*

Function to copy the Vertex Alpha to Vertex

*/
function wallworm_copy_alpha_to_vert obj = (
	ChannelInfo.CopyChannel obj 3 (-2)
	ChannelInfo.PasteChannel obj 3 0
)

function wallworm_copy_alphas_to_verts objs = (
	for obj in objs do (
		wallworm_copy_alpha_to_vert obj
	)

)

/*

matchPolice

1: return true only if match all
2: return true only if match none
3: return true if match found

*/

function wallworm_matchStringArray str pattern matchPolicy:1 = (
	local ma
	if matchPattern pattern pattern:"*,*" == true then (
		strs = filterString pattern ","
		ma = undefined
		for s in strs while ma == undefined do (
			local m = matchPattern str pattern:("*" + s + "*")
			case of (
				(m == true AND matchPolicy == 3) : (
					ma true
				)
				(m == true AND matchPolicy == 2) : (
					ma = false
				)
				(m == false AND matchPolicy == 1) : (
					ma = false
				)
			)
		)

		if ma == undefined then (
			ma = false
		)

	) else (
		ma = matchPattern str pattern:("*" + pattern + "*")
		if matchPolicy == 2 then (
			ma = NOT ma
		)
	)
	ma
)

function wallworm_material_redirect mats newPath &ignore:#() prepend:false maps:true texNameToPath:true texPathOnlyForBitmaps:true skipPattern:undefined matchP:undefined useOnlyBitmaps:false addTexCA:false updateTextureName:true skipMaterialNames:false = (
	for m in mats WHERE findItem ignore m == 0 AND (skipPattern == undefined OR skipPattern == "" OR (skipPattern != undefined AND skipPattern != "" AND wallworm_matchStringArray m.name skipPattern matchPolicy:2 == true)) AND (matchP == undefined OR matchP == "" OR (matchP != undefined AND matchP != "" AND wallworm_matchStringArray m.name matchP matchPolicy:3 == true)) do (
		local updateTheName = true

		if ::WallwormProActive == true then (
			if addTexCA then (
				case (superClassOf m) of (
					TextureMap:(
						wallworm_update_texture_ca m addca:true
					)
					Material:(
						wallwormAddTextureCAtoMaterial m tex2:false
					)
				)
				updateTheName = updateTextureName
			)

			if (isProperty m #wallworm_texture_CA) then (
				local vtfname = "unknown.vtf"
				if hasProperty m #filename AND m.filename != undefined then (
					vtfname = getFileNameFile m.filename
				)
				m.vtfpath = wallworm_safe_path (newPath + "/" + vtfname + ".vtf")
				updateTheName = updateTextureName
			)
		)

		if skipMaterialNames AND superClassOf m == Material then (
			updateTheName = false
		)

		if updateTheName then (
			if classOf m == BitmapTexture AND (m.filename != undefined AND m.filename != "") then (
				m.name = newPath + "/" + (filenameFromPath m.filename)
			) else (
				if prepend == true then (
					newPath += "/" + (getFileNamePath m.name)
				)

				m.name = newPath + "/" + (getFileNameFile m.name)

			)

			m.name = wallworm_safe_path m.name
		)

		append ignore m
		if maps == true then (
			newMats = #()

			if superClassOf m == Material then (
				ms = getNumSubMtls m
				if ms > 0 then (
					for msi = 1 to ms do (
						ma = (getSubMtl m msi)
						if ma != undefined then (
							appendIfUnique newMats ma
						)
					)

				)
			)

			ms = getNumSubTexmaps m
			if ms > 0 then (
				for msi = 1 to ms do (
					mp = (getSubTexmap m msi)
					if mp != undefined AND findItem ignore mp == 0 then (
						if texNameToPath == true AND (texPathOnlyForBitmaps == false OR classOf mp == BitmapTexture) then (
							local updateTheName2 = true
							if ::WallwormProActive == true then (
								if addTexCA AND superClassOf mp == TextureMap then (
									wallwormAddTextureCAtoMaterial mp tex2:false
									updateTheName2 = updateTextureName
								)
								if (isProperty mp #wallworm_texture_CA) then (
									local vtfname = "unknown.vtf"
									if hasProperty mp #filename AND mp.filename != undefined then (
										vtfname = getFileNameFile mp.filename
									)
									mp.vtfpath = newPath + "/" + vtfname + ".vtf"
									updateTheName2 = updateTextureName
								)
							)
							if updateTheName2 then (
								if classOf mp == BitmapTexture AND (mp.filename != undefined AND mp.filename != "") then (
									mp.name = newPath + "/" + (filenameFromPath mp.filename)

								) else (
									if NOT useOnlyBitmaps then (
										mp.name = newPath
									)
								)
							)

						) else (
							appendIfUnique newMats mp
						)
						append ignore mp
					)
				)

			)

			if newMats.count > 0 then (
				wallworm_material_redirect newMats newPath ignore:&ignore prepend:prepend maps:maps matchP:matchP skipPattern:skipPattern texPathOnlyForBitmaps:texPathOnlyForBitmaps texNameToPath:texNameToPath useOnlyBitmaps:useOnlyBitmaps addTexCA:addTexCA updateTextureName:updateTextureName skipMaterialNames:skipMaterialNames
			)

		)

	)

)

function wallworm_has_material_name thisMaterial searchName usePattern:false ignoreCase:true obj:undefined = (
	local found = false
	if usePattern then (
		found = matchPattern thisMaterial.name pattern:("*" + searchName + "*") ignoreCase:ignoreCase
	) else (
		if ignoreCase then (
			found = ((toLower thisMaterial.name) == (toLower searchName))
		) else (
			found = (thisMaterial.name == searchName)
		)

	)

	if NOT found then (
		case (classOf thisMaterial) of (
			UndefinedClass:(
			)
			MultiMaterial: (
				--	local mats = for m in thisMaterial.materialList where m != undefined collect m

				local ml = thisMaterial.materialList
				local mlc = ml.count
				for matId = 1 to mlc while NOT found do (
					m = ml[matId]
					if m != undefined then (
						tempfound = (wallworm_has_material_name m searchName usePattern:usePattern ignoreCase:ignoreCase)
						if tempfound AND isValidNode obj then (
							for f = 1 to obj.Mesh.numfaces while NOT found do (
								local theID = getFaceMatID obj.Mesh f

								if theID > mlc then (
									theID = (mod theID mlc) as Integer
								)
								--format "OBJ % Face % ID % == %\n" obj f theID matID

								if matId == theId then (
									found = true
								)

							)

						) else (
							found = tempFound
						)

					)
				)
			)
			Blend:(
				found = ((wallworm_has_material_name thisMaterial.map1 searchName) OR (wallworm_has_material_name thisMaterial.map2 searchName))
			)
			XRefmaterial:(
				found = (wallworm_has_material_name (thisMaterial.GetSourceMaterial true) searchName)
			)
			default:(
				if usePattern then (
					found = matchPattern thisMaterial.name pattern:("*" + searchName + "*") ignoreCase:ignoreCase
				) else (
					if ignoreCase then (
						found = ((toLower thisMaterial.name) == (toLower searchName))
					) else (
						found = (thisMaterial.name == searchName)
					)

				)
			)

		)
	)

	found
)

function wallworm_get_objects_using_material_name searchName usePattern:false hideem:false shown:true ignoreCase:true = (
	local ObjectsWithMaterial = for obj in geometry WHERE obj.isHidden != shown AND obj.mat != undefined collect obj

	ObjectsWithMaterial = for obj in ObjectsWithMaterial WHERE (wallworm_has_material_name obj.mat searchName usePattern:usePattern ignoreCase:ignoreCase obj:obj) collect obj
	if hideem then (
		hide ObjectsWithMaterial
	)
	ObjectsWithMaterial
)

function wallworm_get_all_materials &materialListIn &materialListOut = (
	if materialListOut == undefined then (
		materialListOut = #()
	)
	if materialListIn == undefined then (
		materialListIn = #()
	)
	for m in materialListIn WHERE m != undefined do (
		local subMats
		local numSubs = getNumSubMtls m
		appendIfUnique materialListOut m
		if numSubs != 0 then (
			subMats = (for i = 1 to numSubs collect (getSubMtl m i))
			wallworm_get_all_materials &subMats &materialListOut
		)

	)
)

::wallwormUpdateTexFromName = function wallwormUpdateTexFromName currentTex newpath materailcollection:(#()) = (
	local currentTexFile
	if isProperty currentTex #filename then (
		currentTexFile = currentTex.filename
	) else (
		currentTexFile = currentTex.name	
	)
	local themats = #()
	--find all the uses of this bitmap
	local totalIndex = 1
	for matindex = 1 to materailcollection.count do (
		local thismatincollection = materailcollection[matindex]
		for texnum = 1 to thismatincollection.texturemaparray.count do (
			local thisTex = thismatincollection.texturemaparray[texnum]
			local texmap = thisTex.thisTextureMap

			if texmap != undefined AND isProperty texmap #filename AND texmap.filename == currentTexFile then (
				append themats texmap
			)
		)
	)
	themats = makeUniqueArray themats
	local ignore = #()
	wallworm_material_redirect themats newpath ignore:&ignore prepend:false maps:true texNameToPath:true texPathOnlyForBitmaps:false useOnlyBitmaps:false addTexCA:true updateTextureName:false skipMaterialNames:true

	local thisFileName = ::wallworm_texture_path currentTex forcePath:newpath matRoot:true forceLegacy:false addGameDir:true fs:true

	doesFileExist thisFileName
)

/*
For those who read this stuff:
Thanks for Andrew Penry (again) for helping me figure these functions out!
http://thepenry.net
*/
function wallworm_set_mat_uvs_from_overlay nd = (
	if isProperty nd #startU AND nd.mat != undefined then (
		local mat = wallworm_getMaterial nd.mat
		if classOf mat == Standard then (
			local displayMatdiffuseMap = mat.diffusemap
			if classOf displayMatdiffuseMap == bitmapTexture then (
				local coords = displayMatdiffuseMap.coords
				coords.U_Tiling = nd.endU - nd.startU
				coords.U_Offset = 0.5 * (1 / coords.U_Tiling - 1) - (nd.startU / coords.U_Tiling)
				local tiling = (nd.endv - nd.startv)
				coords.v_Tiling = tiling * -1
				coords.v_Offset = 0.5 * (1 / tiling - 1) - (nd.startv / tiling)
			)
		)
	)
)
function wallworm_set_overlay_uvs_from_mat nd = (
	if isProperty nd #startU AND nd.mat != undefined then (
		local mat = wallworm_getMaterial nd.mat
		if classOf mat == Standard then (
			local displayMatdiffuseMap = mat.diffusemap
			if classOf displayMatdiffuseMap == bitmapTexture then (
				local coords = displayMatdiffuseMap.coords
				if coords != undefined then (
					nd.startU = 0.5 - coords.U_Tiling * (coords.U_Offset + 0.5)
					nd.endU = coords.U_Tiling + nd.startU
					local tiling = coords.v_Tiling * -1
					nd.startv = 0.5 - tiling * (coords.v_Offset + 0.5)
					nd.endv = tiling + nd.startv
				)
			)
		)
	)
)