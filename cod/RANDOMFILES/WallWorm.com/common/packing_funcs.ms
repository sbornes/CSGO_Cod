/*
Common functions for packing assets. Used by Res File maker and VMF Exporter.

Copyright (c) 2012-2015 by Shawn Olson
http://www.shawnolson.net

All Rights Reserved.

http://dev.wallworm.com

*/

if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

function wallworm_get_soundscape_assets soundscapefile = (
	/*This function returns an array of sound files that are in the soundscape file.*/
	local thewaves = #()

	if doesFileExist soundscapefile then (
		wavPattern = "\\s+\\\"wave\\\"\\s+\\\"([\w_/.\-!@#<>^\*?$)}]+)"
		dotNetFile = DotNetClass "System.IO.File"
		rx = DotNetClass "System.Text.RegularExpressions.RegEx"

		local soundscapeContents = dotNetFile.ReadAllText soundscapefile

		m = rx.match soundscapeContents wavPattern

		while m.Success do (
			for i = 1 to (m.Groups.count - 1) collect (
				append thewaves (wallworm_safe_path("sound/" + ((m.groups.item[1].value))))
			)
			m = m.nextMatch()
		)

	) else (/*No soundscape found*/)

	thewaves

)

function wallworm_get_assets_from_GLB inp = (
	/*This function returns an array of assets that are listed in the contents of a Convexity Entity (like ambient_generic, prop_static, etc)*/
	local theassets = #()
	assetPattern = ",([\w_/.\-!@#<>^\*?$)}]+)"
	rx = DotNetClass "System.Text.RegularExpressions.RegEx"
	m = rx.match inp assetPattern
	--allowedTypes = #(".wav",".mp3",".mdl",".mp4")
	while m.Success do (
		for i = 1 to (m.Groups.count - 1) collect (
			local theType = toLower (getFileNameType m.groups.item[1].value)
			if theType != undefined AND theType != "" then (
				local theRoot = undefined
				case theType of (
					".wav" : theRoot = "sound/"
					".mp3" : theRoot = "sound/"
					".mdl" : theRoot = "models/"
					".vmt" : theRoot = "materials/"
					".vtf" : theRoot = "materials/"
					default : ()
				)
				if theRoot != undefined then (
					append theassets (wallworm_safe_path (theRoot + m.groups.item[1].value))
				)
			)
		)
		m = m.nextMatch()
	)
	theassets
)

function wallworm_res_to_array resfile = (
	/*This function returns an array of assets from a res file.*/
	local theassets = #()

	if doesFileExist resfile then (
		wavPattern = "\s+\"([\w_/.\-!@#<>^\*?$)}]+)\" \"file\""
		dotNetFile = DotNetClass "System.IO.File"
		rx = DotNetClass "System.Text.RegularExpressions.RegEx"

		local resContents = dotNetFile.ReadAllText resfile

		m = rx.match resContents wavPattern

		while m.Success do (
			for i = 1 to (m.Groups.count - 1) collect (
				append theassets (wallworm_safe_path(((m.groups.item[1].value))))
			)
			m = m.nextMatch()
		)

		theassets = makeUniqueArray theassets
	) else (/*No res file found*/)

	theassets
)

function wallworm_collect_assets_from_scene wwmt:true wwmtMaterials:true cvxModels:true sky:true soundscape:true worldMaterials:true mapname:undefined isRes:false vmfsettings:undefined resAndPak:false vbsp:true = (
	local collection = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true

	local objectCollection = #()
	local wwmtsCollection = #()
	--local wwmtsCollection = for wwmt in collection WHERE (isProperty wwmt #wwmt_ca OR getUserProp wwmt #wwmt_source_helper != undefined) collect wwmt
	--join wwmtsCollection (for wwmt in objectCollection where (isProperty wwmt #wwmt_ca OR getUserProp wwmt #wwmt_source_helper != undefined)   collect wwmt)
	/*messagebox (objectCollection as string)
	if wwmtsCollection.count > 0 then (
		objectCollection = for obj in objectCollection WHERE findItem wwmtsCollection obj == 0 collect obj
	)*/
	local details = #()
/*	local details = for obj in objectCollection WHERE classOf obj.baseObject == WallWormDetailProp collect obj
	if details.count > 0 then (
		objectCollection = for obj in objectCollection WHERE findItem details obj == 0 collect obj
	)*/

	local proxyCollection = #()
/*	proxyCollection = for proxie in objectCollection WHERE ((isProperty proxie #wallwormProxy) OR (getUserProp proxie #wwmt_proxie_source != undefined)) collect proxie
	if proxyCollection.count > 0 then (
		objectCollection = for obj in objectCollection WHERE findItem proxyCollection obj == 0 collect obj
	)*/

	for obj in collection do (
		case of (
			(isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper != undefined):(append wwmtsCollection obj)
			((isProperty obj #wallwormProxy) OR (getUserProp obj #wwmt_proxie_source != undefined)):(append proxyCollection obj)
			(classOf obj.baseObject == WallWormDetailProp):(append details obj)
			(superclassof obj == GeometryClass):( append objectCollection obj )
			default:(
				--skip
			)
		)
		
	)
	
	
	
	/*

	This function returns an array of all the Assets (MDL, VMT, VTF, TXT, DDS, RES, BSP, SWF) 
	that Wall Worm knows how to collect from the Scene and associated files. 

	Since many files are dependant on the map's name, it is important for the user to pass the correct map name.

	*/

	local wwmt_res_list = #()
	--local wwmt_used_materials = #()

	macros.run "wallworm.com" "WallWormRepairDXRenderMatNamesMCR"

	local vbspmats = #()

	if isRes == true then (
		append wwmt_res_list ("maps/" + mapname + ".bsp")
		append wwmt_res_list ("maps/" + mapname + ".res")
	)

	local gameDir = ::wwmt_gameInfoDir

	/*if ::wwmt_gameInfoDir == undefined OR ::wwmt_gameInfoDir == "" then (
		gameDir = (dotnetclass "System.Environment").GetEnvironmentVariable("VProject")
	)

	if mapname != undefined then (
		print mapname
	)
	*/

	if mapname != undefined AND ::wwmt_gameInfoDir != undefined AND gameDir != "" then (
		if isRes == true then (
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".txt") then (
				append wwmt_res_list ("maps/" + mapname + ".txt")
			)

			if doesFileExist (gameDir + "\\maps\\" + mapname + ".jpg") then (
				append wwmt_res_list ("maps/" + mapname + ".jpg")
			)
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".png") then (
				append wwmt_res_list ("maps/" + mapname + ".png")
			)
			if doesFileExist (gameDir + "\\maps\\" + mapname + "README.txt") then (
				append wwmt_res_list ("maps/" + mapname + "README.txt")
			)
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".html") then (
				append wwmt_res_list ("maps/" + mapname + ".html")
			)
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".css") then (
				append wwmt_res_list ("maps/" + mapname + ".css")
			)
			if ::wallworm_engine == 1 then (
				/*It appears Overview DDS files will only load if inside the RES File*/
				if doesFileExist (gameDir + "\\overviews\\" + mapname + ".bmp") then (
					append wwmt_res_list ("overviews/" + mapname + ".bmp")
				)
				if doesFileExist (gameDir + "\\overviews\\" + mapname + ".tga") then (
					append wwmt_res_list ("overviews/" + mapname + ".tga")
				)
				if doesFileExist (gameDir + "\\overviews\\" + mapname + ".txt") then (
					append wwmt_res_list ("overviews/" + mapname + ".txt")
				)
				if doesFileExist (gameDir + "\\" + mapname + ".wad") then (
					append wwmt_res_list (mapname + ".wad")
				)

			) else (
				/*It appears Overview DDS files will only load if inside the RES File*/
				if doesFileExist (gameDir + "\\resource\\overviews\\" + mapname + ".dds") then (
					append wwmt_res_list ("resource/overviews/" + mapname + ".dds")
				)
				if doesFileExist (gameDir + "\\resource\\overviews\\" + mapname + "_radar.dds") then (
					append wwmt_res_list ("resource/overviews/" + mapname + "_radar.dds")
				)
				if doesFileExist (gameDir + "\\resource\\overviews\\" + mapname + "_radar_spectate.dds") then (
					append wwmt_res_list ("resource/overviews/" + mapname + "_radar_spectate.dds")
				)
			)

			/*In all of my tests... PAKing a KV file messes up on the server.*/
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".kv") then (
				append wwmt_res_list ("maps/" + mapname + ".kv")
			)

			/*Don't PAK the NAV file since a server may want to customize this for their own needs.*/
			if doesFileExist (gameDir + "\\maps\\" + mapname + ".nav") then (
				append wwmt_res_list ("maps/" + mapname + ".nav")
			)

			if doesFileExist (gameDir + "\\materials\\vgui\\backgrounds\\maps\\" + mapname + ".vmt") then (
				append wwmt_res_list ("materials/vgui/backgrounds/maps/" + mapname + ".vmt")
			)
			if doesFileExist (gameDir + "\\materials\\vgui\\backgrounds\\maps\\" + mapname + ".vtf") then (
				append wwmt_res_list ("materials/vgui/backgrounds/maps/" + mapname + ".vtf")
			)

			if doesFileExist (gameDir + "\\materials\\vgui\\mp_sp_screens\\" + mapname + ".vmt") then (
				append wwmt_res_list ("materials/vgui/mp_sp_screens/" + mapname + ".vmt")
			)
			if doesFileExist (gameDir + "\\materials\\vgui\\mp_sp_screens\\" + mapname + ".vtf") then (
				append wwmt_res_list ("materials/vgui//mp_sp_screens/" + mapname + ".vtf")
			)

			if doesFileExist (gameDir + "\\materials\\vgui\\gfx\\vgui\\summary_maps\\summary_" + mapname + ".vmt") then (
				append wwmt_res_list ("materials/vgui/gfx/vgui/summary_maps/summary_" + mapname + ".vmt")
			)

			if doesFileExist (gameDir + "\\materials\\vgui\\gfx\\vgui\\summary_maps\\summary_" + mapname + ".vtf") then (
				append wwmt_res_list ("materials/vgui/gfx/vgui/summary_maps/summary_" + mapname + ".vtf")
			)

		)

		if doesFileExist (gameDir + "\\maps\\cfg\\" + mapname + ".cfg") then (
			append wwmt_res_list ("maps/cfg/" + mapname + ".cfg")
		)

		if doesFileExist (gameDir + "\\maps\\soundcache\\" + mapname + ".cache") then (
			append wwmt_res_list ("maps/soundcache/" + mapname + ".cache")
		)

		if doesFileExist (gameDir + "\\maps\\soundcache\\" + mapname + ".manifest") then (
			append wwmt_res_list ("maps/soundcache/" + mapname + ".manifest")
		)

		if doesFileExist (gameDir + "\\maps\\" + mapname + "_commentary.txt") then (
			append wwmt_res_list ("maps/" + mapname + "_commentary.txt")
		)

		if doesFileExist (gameDir + "\\maps\\" + mapname + ".ent") then (
			append wwmt_res_list ("maps/" + mapname + ".ent")
		)

		if doesFileExist (gameDir + "\\maps\\" + mapname + "_manifest.txt") then (
			append wwmt_res_list ("maps/" + mapname + "_manifest.txt")
		)

		if doesFileExist (gameDir + "\\particles\\" + mapname + "_manifest.txt") then (
			append wwmt_res_list ("particles/" + mapname + "_manifest.txt")
		)

		if doesFileExist (gameDir + "\\maps\\" + mapname + "particles.txt") then (
			append wwmt_res_list ("maps/" + mapname + "particles.txt")
		)

		if doesFileExist (gameDir + "\\maps\\" + mapname + "_exclude.lst") then (
			append wwmt_res_list ("maps/" + mapname + "_exclude.lst")
		)

		if doesFileExist (gameDir + "\\scripts\\soundscapes_" + mapname + ".txt") then (
			append wwmt_res_list ("scripts/soundscapes_" + mapname + ".txt")
		)

		if doesFileExist (gameDir + "\\materials\\overviews\\" + mapname + ".vmt") then (
			append wwmt_res_list ("materials/overviews/" + mapname + ".vmt")
		)

		if doesFileExist (gameDir + "\\materials\\overviews\\" + mapname + ".vtf") then (
			append wwmt_res_list ("materials/overviews/" + mapname + ".vtf")
		)

		if doesFileExist (gameDir + "\\materials\\overviews\\" + mapname + "_radar.vmt") then (
			append wwmt_res_list ("materials/overviews/" + mapname + "_radar.vmt")
		)

		if doesFileExist (gameDir + "\\materials\\overviews\\" + mapname + "_radar.vtf") then (
			append wwmt_res_list ("materials/overviews/" + mapname + "_radar.vtf")
		)

		if doesFileExist (gameDir + "\\materials\\mapDesc\\" + mapname + ".jpg") then (
			append wwmt_res_list ("materials/mapDesc/" + mapname + ".jpg")
		)

		if doesFileExist (gameDir + "\\materials\\vgui\\maps\\menu_thumb_" + mapname + ".vmt") then (
			append wwmt_res_list ("materials/vgui/maps/menu_thumb_" + mapname + ".vmt")
		)

		if doesFileExist (gameDir + "\\materials\\vgui\\maps\\menu_thumb_" + mapname + ".vtf") then (
			append wwmt_res_list ("materials/vgui/maps/menu_thumb_" + mapname + ".vtf")
		)

		if doesFileExist (gameDir + "\\resource\\overviews\\" + mapname + ".txt") then (
			append wwmt_res_list ("resource/overviews/" + mapname + ".txt")
		)

		if doesFileExist (gameDir + "\\resource\\flash\\loading-" + mapname + ".swf") then (
			append wwmt_res_list ("resource/flash/loading-" + mapname + ".swf")
		)

	)

	--get all wwmt models
	if wwmt == true OR wwmtMaterials == true then (
		local wwmts = 0
		local failed = #()
		clearSelection()
		for obj in wwmtsCollection do (
			local tempWWMT = ww_LOD_wrapper()
			tempWWMT.init()
			tempWWMT.setTargetModel obj tempWWMT

			if wwmt == true then (
				append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + (toLower tempWWMT.modelName) + ".mdl")
				append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + (toLower tempWWMT.modelName) + ".vvd")
				append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + tempWWMT.modelName + ".sw.vtx")
				append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + tempWWMT.modelName + ".dx80.vtx")
				append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + tempWWMT.modelName + ".dx90.vtx")

				if tempWWMT.hulls.count > 0 OR tempWWMT.autoHull == true then (
					append wwmt_res_list ("models/" + (tempWWMT.modelPath) + "/" + tempWWMT.modelName + ".phy")
				)
			)

			if ::wallworm_engine != 1 AND wwmtMaterials == true then (
				tempWWMT.populateMyMaterials()
				--where (findItem wwmt_used_materials m == 0)
				for m in tempWWMT.materials do (
					if m.mat1 == undefined then (
						m.mat1 = m.mat
					)
					--appendIfUnique wwmt_used_materials m
					if ::wwmt_oldModelVTFPath == true then (
						wwmt_vtfMmatPath = tempWWMT.materialPath
					) else (
						wwmt_vtfMmatPath = ""
					)
					append wwmt_res_list ("materials/" + tempWWMT.materialPath + "/" + (wallworm_getMaterialName m.mat1 forModel:true) + ".vmt")

					wallworm_getTexturesFromMaterial m.mat &wwmt_res_list forcePath:wwmt_vtfMmatPath matRoot:true addGameDir:false fs:true

					if m.detail != undefined then (
						--appendIfUnique wwmt_res_list (("materials/"+(tempWWMT.materialPath)+"/") + (getFileNameFile m.illum)+".vmt") 
						detailMap = wallworm_detailMapTex m.mat1
						if classOf detailMap == BitmapTexture then (
							append wwmt_res_list ("materials/" + ((wallworm_getVTFPathFromBitmap detailMap forcePath:wwmt_vtfMmatPath)) + ".vtf")
						)
					)
					if m.reflectionMap != undefined then (
						if classOf m.reflectionMap == Reflect_Refract AND m.reflectionMap.outputname != undefined AND m.reflectionMap.outputname != "" then (
							local n = getFileNameFile m.reflectionMap.outputname

							n = (substituteString n "_UP" "")

							append wwmt_res_list ("materials/" + (wallworm_remove_last_slash (wallworm_safe_path (m.reflectionMap.name))) + "/" + n + ".vtf")

						) else (
							if classOf m.reflectionMap == BitmapTexture then (
								append wwmt_res_list ("materials/" + ((wallworm_getVTFPathFromBitmap m.reflectionMap forcePath:wwmt_vtfMmatPath)) + ".vtf")
							)
						)

					)

				)

			)

		)

	)

	if vbsp == true then (
		for d in details WHERE d.model != undefined AND d.model != "" do (
			append wwmt_res_list (d.model)

			if d.mat != undefined then (
				append vbspmats d.mat
			)

		)

		local detMats = for d in details WHERE (d.model == undefined OR d.model == "") AND d.mat != undefined collect d.mat

		detMats = makeUniqueArray detMats

		if detMats.count > 0 then (
			for m in detMats do (
				append vbspmats m
			)

		)

		if isProperty rootNode #DetailSprites then (
			if rootNode.DetailSprites != "" then (
				local detMatFile = rootNode.DetailSprites
				if getFileNameType detMatFile == "" then (
					detMatFile += ".vmt"
				)

				append wwmt_res_list ("materials/" + detMatFile)
			)
		) else (
			if vmfsettings == undefined then (
				global wallworm_file_vmf_presets
				if wallworm_file_vmf_presets != undefined then (
					vmfsettings = wallworm_file_vmf_presets
				)
			)

			if vmfsettings != undefined AND vmfsettings.DetailSprites != undefined AND vmfsettings.DetailSprites != "" then (
				local detMatFile = vmfsettings.DetailSprites
				if getFileNameType detMatFile == "" then (
					detMatFile += ".vmt"
				)

				append wwmt_res_list ("materials/" + detMatFile)

			)
		)

	)

	if sky == true then (
		gotsky = false

		for s in collection while gotsky == false WHERE (isDeleted s == false) do (
			if vmfsettings != undefined AND vmfsettings.skyName != undefined AND vmfsettings.skyName != "" then (
				skyn = vmfsettings.skyName

			) else (
				skyn = getUserProp s #wwsw_skyname
			)

			if skyn != undefined AND skyn != "" then (
				--appendIfUnique wwmt_used_materials s.mat

				if ::wallworm_engine != 1 then (
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrft.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrft.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "ft.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "ft.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrbk.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrbk.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "bk.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "bk.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrlf.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrlf.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "lf.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "lf.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrrt.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrrt.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "rt.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "rt.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrdn.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrdn.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "dn.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "dn.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrup.hdr.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "_hdrup.vmt")
					append wwmt_res_list ("materials/skybox/" + skyn + "up.vtf")
					append wwmt_res_list ("materials/skybox/" + skyn + "up.vmt")
				) else (
					append wwmt_res_list ("gfx/env/" + skyn + "ft.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "bk.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "lf.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "rt.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "dn.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "up.bmp")
					append wwmt_res_list ("gfx/env/" + skyn + "ft.tga")
					append wwmt_res_list ("gfx/env/" + skyn + "bk.tga")
					append wwmt_res_list ("gfx/env/" + skyn + "lf.tga")
					append wwmt_res_list ("gfx/env/" + skyn + "rt.tga")
					append wwmt_res_list ("gfx/env/" + skyn + "dn.tga")
					append wwmt_res_list ("gfx/env/" + skyn + "up.tga")
				)

				gotsky = true

			)

		)

	)

	ww_brushmaterials = #()

	if ::wallworm_engine != 1 AND vbsp == true AND WallWormDetailProp != undefined AND vbspmats != undefined AND vbspmats.count > 0 then (
		for m in vbspmats do (
			if isProperty m #valveShader AND m.valveShader != undefined AND m.valveShader != "" then (
				vshader = m.valveShader
			) else (
				vshader = "UnlitGeneric"
			)
			wallworm_appendBitmaps m ww_brushmaterials vshaderr coords:true
		)
	)

	if ::wallworm_engine != 1 AND worldMaterials == true then (
		--(findItem wwmt_used_materials i.mat) ==0 AND 

		local brshes = for obj in objectCollection WHERE (((getUserProp obj #wwdt_brush_geometry_export == true) OR (getUserProp obj #ww_wwdt_displacement_brush) != undefined) OR (hasProperty obj #isWorldGeometry AND obj.isWorldGeometry == on)) collect obj
		for i in brshes do (
			if i.mat != undefined then (
				if classOf i.mat == Blend then (
					shaderType = "WorldVertexTransition"

				) else (
					shaderType = "UnLitGeneric"
				)

				wallworm_appendBitmaps i.mat &ww_brushmaterials shaderType coords:true
			)

		)
	)

	if ww_brushmaterials.count > 0 then (
		--where (findItem wwmt_used_materials m.mat == 0)
		for m in ww_brushmaterials do (
			if m.mat1 == undefined then (
				m.mat1 = m.mat
			)

			--appendIfUnique wwmt_used_materials m.mat

			--m.matName=m.mat.name
			m.forModel = false
			--m.valveShader="LightmappedGeneric"

			--
			if (m.materialPath != undefined AND m.materialPath != "") then (
				--m.setMaterialPath m.matName

			)

			if (m.materialPath != undefined AND m.materialPath != "") then (
				mpstring = m.materialPath + "/"
			) else (
				mpstring = m.mat.name + "/"

			)

			if ::wwmt_oldModelVTFPath == true then (
				materialPath = m.getMaterialPathForMat m.mat1.mat

				if materialPath == "" then (
					wwmt_vtfMmatPath = m.matName
				) else (
					wwmt_vtfMmatPath = materialPath
				)

			) else (
				wwmt_vtfMmatPath = ""

			)

			append wwmt_res_list (wallworm_safe_path("materials/" + ((wallworm_getMaterialName m.mat) + ".vmt")))

			wallworm_getTexturesFromMaterial m.mat &wwmt_res_list forcePath:wwmt_vtfMmatPath matRoot:true addGameDir:false fs:true

			if m.detail != undefined then (
				detailMap = wallworm_detailMapTex m.mat1
				if classOf detailMap == BitmapTexture then (
					append wwmt_res_list (wallworm_safe_path("materials/" + (wallworm_getVTFPathFromBitmap detailMap forcePath:wwmt_vtfMmatPath) + ".vtf"))
				)
			)

			if m.reflectionMap != undefined then (
				if classOf m.reflectionMap == Reflect_Refract AND m.reflectionMap.outputname != undefined AND m.reflectionMap.outputname != "" then (
					local n = getFileNameFile m.reflectionMap.outputname

					n = (substituteString n "_UP" "")

					append wwmt_res_list ("materials/" + (wallworm_remove_last_slash (wallworm_safe_path (m.reflectionMap.name))) + "/" + n + ".vtf")

				) else (
					if classOf m.reflectionMap == BitmapTexture then (
						append wwmt_res_list ("materials/" + ((wallworm_getVTFPathFromBitmap m.reflectionMap forcePath:wwmt_vtfMmatPath)) + ".vtf")
					)
				)

			)

			if m.mat2 != undefined then (
				wallworm_getTexturesFromMaterial m.mat2 &wwmt_res_list forcePath:wwmt_vtfMmatPath matRoot:true addGameDir:false fs:true

				if m.detail2 != undefined then (
					detailMap = wallworm_detailMapTex m.mat2
					if classOf detailMap == BitmapTexture then (
						append wwmt_res_list (wallworm_safe_path("materials/" + (wallworm_getVTFPathFromBitmap detailMap forcePath:wwmt_vtfMmatPath) + ".vtf"))
					)
				)

			)
		)
	)

	if soundscape == true AND mapname != undefined then (
		soundscapefile = ::wwmt_gameInfoDir + "\\maps\\" + mapname + "_level_sounds.txt"

		sounds = wallworm_get_soundscape_assets (::wwmt_gameInfoDir + "\\scripts\\soundscapes_" + mapname + ".txt")
		if sounds.count > 0 then (
			join wwmt_res_list sounds
		)

		sounds = wallworm_get_soundscape_assets (::wwmt_gameInfoDir + "\\maps\\" + mapname + "_level_sounds.txt")
		if sounds.count > 0 then (
			join wwmt_res_list sounds
		)

	)

	if cvxModels == true then (
		for ent in collection WHERE isProperty ent #exportProps AND isProperty ent #wallworm do (
			for property in ent.exportProps do (
				val = (getProperty ent property)
				local theType = toLower (getFileNameType (val as String))
				if theType == undefined OR theType == "" do continue
				case theType of (
					".wav" : theRoot = "sound/"
					".mp3" : theRoot = "sound/"
					".mdl" : theRoot = "models/"
					".vmt" : theRoot = "materials/"
					default : continue
				)
				append wwmt_res_list (wallworm_safe_path (theRoot + val))
			)

		)

		for ent in collection WHERE (getUserProp ent #GLBPntValu != undefined) AND (getUserProp ent #wwmt_source_helper == undefined) do (
			assets = wallworm_get_assets_from_GLB (getUserProp ent #GLBPntValu)
			if assets.count > 0 then (
				join wwmt_res_list assets
			)

		)

	)

	wwmt_res_list = makeUniqueArray wwmt_res_list

	wwmt_res_list
)