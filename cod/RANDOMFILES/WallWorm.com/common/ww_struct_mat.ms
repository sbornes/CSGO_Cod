/*
Material Struct for Wall Worm Mod Tools
Copyright (c) 2010-2015
All Rights Reserved

http://www.wallworm.com

Written by Shawn Olson
http://www.shawnolson.net

Unfortunately, this struct was started early in my MAXScripting days... and it is very inneficient in many ways.

But like they say, if it ain't broke, don't fix it. I'll likely start from scratch at some point, though.

*/

struct wwmatTexToSource (
	VMTPropName,
	thisTextureMap,
	filename = "",
	ssbumpsuffix = ""
)

struct ww_vmt(
	mat,
	mat1,
	mat2,
	diff,
	diff2,
	diffColor,
	useDiffColor = true,
	bump,
	bump2,
	normal,
	normal2,
	detailF,
	detailF2,
	spec,
	spec2,
	ambient,
	illum,
	illum2,
	refract,
	materialPath,
	materialPath2,
	specLevelMap,
	specLevelMap2,
	reflectionMap,
	reflectionMap2,
	blendmodulate,
	decal = false,
	rotationAngle = undefined,
	lightwarptexture,
	lightwarptexture2,
	parallaxmap,
	parallaxmap2,
	parallaxmapscale,
	ba,
	basetexture,
	normalmap,
	bumpmap,
	envmapmask,
	AmbientOcclusion,
	detail,
	selfillumtexture,
	selfillummask,
	phongexponenttexture,
	refracttinttexture,
	blendmodulatetexture,
	basetexture2,
	normalmap2,
	bumpmap2,
	envmapmask2,
	detail2,
	selfillumtexture2,
	selfillummask2,
	otherMaps = #(),
	valveShader = "VertexLitGeneric",
	matName = "",
	matName2 = "",
	forModel = true,
	getNameFromPath = false,
	forceOpaque = false,
	allowedDimension = #(4, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096),
	compression = "dxt5",
	surfaceproperty = "",
	detailtype = "",
	frames = #(),
	texturemaparray = #(),
	defaultCompression = undefined,
	function getTexName p = (
		--materialNamePath = filterString m "\\"
		--materialNameBats = filterString (materialNamePath[materialNamePath.count]) "." 
		--return materialNameBats[1]
		local f = ""
		if p != undefined then (
			f = getFileNameFile p
		)
		f
	),
	function outputTexName p = (
		wallworm_outputTexName p
	),
	function GetVectorsAngle v1 v2 =
	(
		theAngle = acos(dot (normalize v1) (normalize v2))
	),
	function getBlendToolTexName = (
		toolName = mat.name + "_tool"
		toolName
	),

	/*		
	function getRotationProxie bm type:"basetexturetransform" = (
		"LinearRamp"
		{
		"rate" 45
		"initialValue" 0.0
		"resultVar" "$angle"
		}

		"TextureTransform"
		{
		"translateVar" "$translate"
		"rotateVar" "$angle"
		"centerVar" "$center"
		"resultVar" "$basetexturetransform"
		}

	),	
	*/
	function getMaterialPathForMat matin = (
		matin.name = substituteString ((trimLeft (trimRight matin.name))) "\t" ""
		local workingName = matin.name

		local workingPath = workingName
		local hasPath = false
		local materialNamePath = filterString workingName "\\"

		if (materialNamePath.count > 0) then (
			workingName = substring workingName 1 (workingName.count - materialNamePath[materialNamePath.count].count)
			workingPath = substring workingPath 1 (workingPath.count - workingName.count)
			hasPath = true
		)
		materialNamePath = filterString workingName "/"
		if (materialNamePath.count > 0) then (
			workingName = substring workingName 1 (workingName.count - materialNamePath[materialNamePath.count].count)
			workingPath = substring workingPath 1 (workingPath.count - workingName.count)
			hasPath = true
		)

		if hasPath == true then (
			workingPath
		) else (
			""
		)
	),

	function addToTexMapArray newtexturemap = (
		if newtexturemap != undefined AND newtexturemap.vmtPropName != undefined then (
			existing = for m in texturemaparray WHERE m != undefined AND toLower m.vmtPropName == toLower newtexturemap.vmtPropName collect m
			if existing.count == 0 then (
				append texturemaparray newtexturemap
			)
		)
	),
	function getMaps = (
		texturemaparray = #()
		if classOf mat == Blend then (
			local tempMap = #()
			local vs1, vs2
			if isProperty mat.map1 #valveShader then (
				vs1 = mat.map1.valveShader
			) else (
				vs1 = "LightmappedGeneric"
			)
			if isProperty mat.map2 #valveShader then (
				vs2 = mat.map2.valveShader
			) else (
				vs2 = "LightmappedGeneric"
			)

			wallworm_appendBitmaps mat.map1 tempMap vs1 coords:coords
			wallworm_appendBitmaps mat.map2 tempMap vs2 coords:coords

			mat1 = mat.map2
			mat2 = mat.map1
			tempMap[2].getMaps()
			tempMap[2].getMaps()

			join othermaps tempMap[2].otherMaps
			join othermaps tempMap[1].otherMaps

			if tempMap[2].diff != undefined then (
				diff = tempMap[2].diff
				basetexture = tempMap[2].basetexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"basetexture" thisTextureMap:basetexture)
			)
			if tempMap[1].diff != undefined then (
				diff = tempMap[1].diff
				basetexture2 = tempMap[1].basetexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"basetexture2" thisTextureMap:basetexture2)
			)
			if tempMap[2].normal != undefined then (
				normal = tempMap[2].normal
				normalmap = tempMap[2].normalmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"normalmap" thisTextureMap:normalmap)
			)
			if tempMap[1].normal != undefined then (
				normal2 = tempMap[1].normal
				normalmap2 = tempMap[1].normalmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"normalmap2" thisTextureMap:normalmap2)
			)
			if tempMap[2].bump != undefined then (
				bump = tempMap[2].bump
				bumpmap = tempMap[2].bumpmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"bumpmap" thisTextureMap:bumpmap)
			)
			if tempMap[1].bump != undefined then (
				bump2 = tempMap[1].bump
				bumpmap2 = tempMap[1].bumpmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"bumpmap" thisTextureMap:bumpmap2)
			)
			if tempMap[2].detailF != undefined then (
				detailF = tempMap[2].detailF
				detail = tempMap[2].detail
				addToTexMapArray (wwmatTexToSource VMTPropName:"detail" thisTextureMap:detail)
			)
			if tempMap[1].detailF != undefined then (
				detailF2 = tempMap[1].detailF
				detail2 = tempMap[1].detail
				addToTexMapArray (wwmatTexToSource VMTPropName:"detail2" thisTextureMap:detail2)
			)
			/*	if tempMap[2].spec != undefined then (
				spec = tempMap[2].spec
				phongexponenttexture = tempMap[2].phongexponenttexture

			) 
			if tempMap[1].spec != undefined then (
				spec2 = tempMap[1].spec
				phongexponenttexture2 = tempMap[1].phongexponenttexture
			)*/
			if tempMap[2].illum != undefined then (
				illum = tempMap[2].illum
				selfillumtexture = tempMap[2].selfillumtexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"selfillumtexture" thisTextureMap:selfillumtexture)
			)
			if tempMap[1].illum != undefined then (
				illum2 = tempMap[1].illum
				selfillumtexture2 = tempMap[1].selfillumtexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"selfillumtexture2" thisTextureMap:selfillumtexture2)
			)
			if tempMap[2].specLevelMap != undefined then (
				specLevelMap = tempMap[2].specLevelMap
				envmapmask = tempMap[2].envmapmask
				addToTexMapArray (wwmatTexToSource VMTPropName:"envmapmask" thisTextureMap:envmapmask)
			)
			if tempMap[1].specLevelMap != undefined then (
				specLevelMap2 = tempMap[1].specLevelMap
				envmapmask2 = tempMap[1].envmapmask
				addToTexMapArray (wwmatTexToSource VMTPropName:"envmapmask2" thisTextureMap:envmapmask2)
			)

			if isProperty tempMap[1] #lightwarptexture == true then (
				lightwarptexture2 = tempMap[1].lightwarptexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"lightwarptexture2" thisTextureMap:lightwarptexture2)
			)

			if isProperty tempMap[2] #lightwarptexture == true then (
				lightwarptexture = tempMap[2].lightwarptexture
				addToTexMapArray (wwmatTexToSource VMTPropName:"lightwarptexture" thisTextureMap:lightwarptexture)
			)

			if isProperty tempMap[1] #parallaxmap == true then (
				parallaxmap2 = tempMap[1].parallaxmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"parallaxmap2" thisTextureMap:parallaxmap2)
			)

			if isProperty tempMap[2] #parallaxmap == true then (
				parallaxmap = tempMap[2].parallaxmap
				addToTexMapArray (wwmatTexToSource VMTPropName:"parallaxmap" thisTextureMap:parallaxmap)
			)

			if isProperty tempMap[1] #reflectionMap == true then (
				reflectionMap2 = tempMap[1].reflectionMap
				addToTexMapArray (wwmatTexToSource VMTPropName:"envmap2" thisTextureMap:envmap2)
			)

			if isProperty tempMap[2] #reflectionMap == true then (
				reflectionMap = tempMap[2].reflectionMap
				addToTexMapArray (wwmatTexToSource VMTPropName:"envmap" thisTextureMap:envmap)
			)

			valveShader = "WorldVertexTransition"
			matName = wallworm_getMaterialName mat
			materialPath = getMaterialPathForMat mat
			--materialPath2 =  getMaterialPathForMat mat.map1
			if mat.mask != undefined AND classOf mat.mask == BitmapTexture then (
				blendmodulate = mat.mask
				addToTexMapArray (wwmatTexToSource VMTPropName:"blendmodulatetexture" thisTextureMap:blendmodulate)
			)
		) else (
			local texturesToExport = #()
			local subtexcount = getNumSubTexmaps mat
			if subtexcount > 0 then (
				for index = 1 to subtexcount do (
					append texturesToExport (getSubTexmap mat index)
				)
			)
			if isProperty mat #texturelist then (
				for tex in mat.texturelist do (
					append texturesToExport tex
				)

			)
			--texturesToExport = makeUniqueArray texturesToExport

			if texturesToExport.count > 0 then (
				for ThisTex in texturesToExport do (
					if ThisTex != undefined then (
						local useTex = false
						case (classOf ThisTex) of (
							Normal_Bump:(
								local ThisTex2 = ThisTex.normal_map
								local ThisTex3 = ThisTex.bump_map
								if isProperty ThisTex2 #vmtproperties then (
									for param in ThisTex2.vmtproperties do (
										if param != undefined AND param != "" AND isProperty this param then (
											setProperty this param ThisTex2
										) else (
											append otherMaps ThisTex2
										)
										addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex2)
									)
								) else if isProperty ThisTex2 #vmtproperty then (
									local param = ThisTex2.vmtproperty
									if param != undefined AND param != "" AND isProperty this param then (
										setProperty this param ThisTex2
									) else (
										append otherMaps ThisTex2
									)
									addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex2)
								)

								if isProperty ThisTex3 #vmtproperties then (
									for param in ThisTex3.vmtproperties do (
										if param != undefined AND param != "" AND isProperty this param then (
											setProperty this param ThisTex3
										) else (
											append otherMaps ThisTex3
										)
										addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex3)
									)
								) else if isProperty ThisTex3 #vmtproperty then (
									local param = ThisTex3.vmtproperty
									if param != undefined AND param != "" AND isProperty this param then (
										setProperty this param ThisTex3
									) else (
										append otherMaps ThisTex3
									)
									addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex3)
								)

							)
							default:(
								if isProperty ThisTex #vmtproperties then (
									for param in ThisTex.vmtproperties do (
										if param != undefined AND param != "" AND isProperty this param then (
											setProperty this param ThisTex
										) else (
											append otherMaps ThisTex
										)
										addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex)
									)
								) else if isProperty ThisTex #vmtproperty then (
									local param = ThisTex.vmtproperty
									if param != undefined AND param != "" AND isProperty this param then (
										setProperty this param ThisTex
									) else (
										append otherMaps ThisTex
									)
									addToTexMapArray (wwmatTexToSource VMTPropName:param thisTextureMap:ThisTex filename:ThisTex.filename)
								)
							)
						)
					)
				)
			)

			if basetexture == undefined then (
				basetexture = mat.diffuseMap
			)
			if basetexture != undefined AND ((::WallwormProActive == true) OR (classOf basetexture == BitmapTexture AND basetexture.filename != undefined AND wallworm_isValidBitmap (getFilenameType basetexture.filename) == true)) then (
				diff = wallworm_texture_path basetexture matRoot:true addGameDir:true fs:true
				addToTexMapArray (wwmatTexToSource VMTPropName:"basetexture" thisTextureMap:basetexture)
			)

			if phongexponenttexture == undefined then (
				phongexponenttexture = mat.specularMap

			)
			--add specular level as phong exponent texture							
			if phongexponenttexture != undefined AND mat.shaderByName == "Phong" AND ((::WallwormProActive == true) OR (classOf phongexponenttexture == BitmapTexture AND phongexponenttexture.filename != undefined AND wallworm_isValidBitmap (getFilenameType phongexponenttexture.filename) == true)) then (
				spec = wallworm_texture_path phongexponenttexture matRoot:true addGameDir:true fs:true
				addToTexMapArray (wwmatTexToSource VMTPropName:"phongexponenttexture" thisTextureMap:phongexponenttexture)
			)

			if envmapmask == undefined then (
				envmapmask = mat.specularLevelMap
			)

			if envmapmask != undefined AND ((::WallwormProActive == true) OR (classOf envmapmask == BitmapTexture AND envmapmask.filename != undefined AND wallworm_isValidBitmap (getFilenameType envmapmask.filename) == true)) then (
				specLevelMap = wallworm_texture_path envmapmask matRoot:true addGameDir:true fs:true
				addToTexMapArray (wwmatTexToSource VMTPropName:"envmapmask" thisTextureMap:envmapmask)
			)

			if envmap == undefined then (
				envmap = mat.reflectionMap
			)

			if envmap != undefined then (
				if classOf mat.reflectionMap == Reflect_Refract then (
					reflectionMap = envmap
				) else (
					if envmap != undefined AND ((::WallwormProActive == true) OR (classOf envmap == BitmapTexture AND envmap.filename != undefined AND wallworm_isValidBitmap (getFilenameType envmap.filename) == true)) then (
						reflectionMap = envmap
						addToTexMapArray (wwmatTexToSource VMTPropName:"envmap" thisTextureMap:envmap)
					)
				)
			)

			if isProperty mat #lightwarptexture AND mat.lightwarptexture != undefined then (
				lightwarptexture = mat.lightwarptexture
				if lightwarptexture != undefined AND ((::WallwormProActive == true) OR (classOf lightwarptexture == BitmapTexture AND lightwarptexture.filename != undefined AND wallworm_isValidBitmap (getFilenameType lightwarptexture.filename) == true)) then (
					addToTexMapArray (wwmatTexToSource VMTPropName:"lightwarptexture" thisTextureMap:lightwarptexture)
				) else (
					lightwarptexture = undefined
				)
			)

			if isProperty mat #parallaxmap AND mat.parallaxmap != undefined then (
				parallaxmap = mat.parallaxmap
				if parallaxmap != undefined AND ((::WallwormProActive == true) OR (classOf parallaxmap == BitmapTexture AND parallaxmap.filename != undefined AND wallworm_isValidBitmap (getFilenameType parallaxmap.filename) == true)) then (
					addToTexMapArray (wwmatTexToSource VMTPropName:"parallaxmap" thisTextureMap:parallaxmap)
				) else (
					parallaxmap = undefined
				)
			)

			if AmbientOcclusion == undefined then (
				AmbientOcclusion = mat.ambientMap

			)

			if AmbientOcclusion != undefined AND ((::WallwormProActive == true) OR (classOf AmbientOcclusion == BitmapTexture AND AmbientOcclusion.filename != undefined AND wallworm_isValidBitmap (getFilenameType AmbientOcclusion.filename) == true)) then (
				ambient = wallworm_texture_path AmbientOcclusion matRoot:true addGameDir:true fs:true
				addToTexMapArray (wwmatTexToSource VMTPropName:"AmbientOcclusion" thisTextureMap:AmbientOcclusion)
			)

			if selfillumtexture == undefined then (
				selfillumtexture = mat.selfIllumMap

			)

			if selfillumtexture != undefined then (
				if selfillumtexture != undefined AND ((::WallwormProActive == true) OR (classOf selfillumtexture == BitmapTexture AND selfillumtexture.filename != undefined AND wallworm_isValidBitmap (getFilenameType selfillumtexture.filename) == true)) then (
					illum = wallworm_texture_path selfillumtexture matRoot:true addGameDir:true fs:true
					addToTexMapArray (wwmatTexToSource VMTPropName:"selfillumtexture" thisTextureMap:selfillumtexture)
				)
			)

			if refracttinttexture == undefined then (
				refracttinttexture = mat.refractionMap
			)
			if refracttinttexture != undefined then (
				if refracttinttexture != undefined AND ((::WallwormProActive == true) OR (classOf refracttinttexture == BitmapTexture AND refracttinttexture.filename != undefined AND wallworm_isValidBitmap (getFilenameType refracttinttexture.filename) == true)) then (
					refract = wallworm_texture_path refracttinttexture matRoot:true addGameDir:true fs:true
					addToTexMapArray (wwmatTexToSource VMTPropName:"refracttinttexture" thisTextureMap:refracttinttexture)
				) else (
					refracttinttexture = undefined
				)
			)
			if normalmap == undefined then (
				if mat.displacementMap != undefined then (
					normalmap = mat.displacementMap
				)
			)
			if normalmap != undefined then (
				if classOf normalmap == Normal_Bump then (
					if normalmap.bump_map != undefined then (
						detail = normalmap.bump_map
						if detail != undefined AND ((::WallwormProActive == true) OR (classOf detail == BitmapTexture AND detail.filename != undefined AND wallworm_isValidBitmap (getFilenameType detail.filename) == true)) then (
							--detailF = wallworm_texture_path detail matRoot:true addGameDir:true fs:true
							--addToTexMapArray (wwmatTexToSource VMTPropName:"detail" thisTextureMap:detail)
						) else (
							detail = undefined
						)
					)
					normalmap = normalmap.normal_map
				)
				if normalmap != undefined AND ((::WallwormProActive == true) OR (classOf normalmap == BitmapTexture AND normalmap.filename != undefined AND wallworm_isValidBitmap (getFilenameType normalmap.filename) == true)) then (
					normal = wallworm_texture_path normalmap matRoot:true addGameDir:true fs:true
					addToTexMapArray (wwmatTexToSource VMTPropName:"normalmap" thisTextureMap:normalmap)
				) else (
					normal = undefined
				)
			)

			if bumpMap == undefined AND normalmap == undefined then (
				bumpMap = mat.bumpMap
			)
			if bumpMap != undefined then (
				if classOf bumpMap == Normal_Bump then (
					if detail == undefined AND bumpMap.bump_map != undefined AND classOf bumpMap.bump_map == Bitmaptexture then (
						detail = bumpMap.bump_map
						if detail != undefined AND ((::WallwormProActive == true) OR (classOf detail == BitmapTexture AND detail.filename != undefined AND wallworm_isValidBitmap (getFilenameType detail.filename) == true)) then (
							--detailF = wallworm_texture_path detail matRoot:true addGameDir:true fs:true
							--addToTexMapArray (wwmatTexToSource VMTPropName:"detail" thisTextureMap:detail)
						) else (
							detail = undefined
						)
					)
					bumpMap = bumpMap.normal_map
				)
				if bumpMap != undefined AND ((::WallwormProActive == true) OR (classOf bumpMap == BitmapTexture AND bumpMap.filename != undefined AND wallworm_isValidBitmap (getFilenameType bumpMap.filename) == true)) then (
					bump = wallworm_texture_path bumpMap matRoot:true addGameDir:true fs:true
					addToTexMapArray (wwmatTexToSource VMTPropName:"bumpmap" thisTextureMap:bumpMap)
				) else (
					bump = undefined
				)
			)
			if detail != undefined AND ((::WallwormProActive == true) OR (classOf detail == BitmapTexture AND detail.filename != undefined AND wallworm_isValidBitmap (getFilenameType detail.filename) == true)) then (
				detailF = wallworm_texture_path detail matRoot:true addGameDir:true fs:true
				addToTexMapArray (wwmatTexToSource VMTPropName:"detail" thisTextureMap:detail)
			)
		)

	),
	function setTransforms = (
		--no longer used but called in some material CAs... so leave here for now.
		--and go ahead and collect the maps
		getMaps()
	),
	function getScrollProxie bm type:"basetexturetransform" = (
		local out = StringStream ""
		if classOf bm == Normal_Bump then (
			if type == "bumptransform" then (
				bm = bm.normal_map
			) else (
				if type == "detailtransform" then (
					bm = bm.bump_map
				)
			)
		)
		if hasProperty bm #coordinates AND bm.numSubs != undefined AND bm.numSubs > 0 then (
			local co = undefined
			local scrollAngle = undefined
			for i = 1 to bm.numSubs while co == undefined do (
				if ((getSubAnimName bm i asString:true) == "Coordinates") then (
					co = getSubAnim bm i
				)

			)
			if co != undefined then (
				local timeStart = 0f
				local timeEnd = 0f

				if hasProperty co #U_Offset AND hasProperty co #V_Offset AND (co.U_Offset.keys != undefined OR co.V_Offset.keys != undefined) then (
					if co.U_Offset.keys != undefined AND co.U_Offset.keys.count > 1 then (
						timeStart = co.U_Offset.keys[1].time
						timeEnd = co.U_Offset.keys[2].time
					)
					if co.V_Offset.keys != undefined AND co.V_Offset.keys.count > 1 then (
						if co.V_Offset.keys[1].time.frame < timeStart.frame then (
							timeStart = co.V_Offset.keys[1].time
						)
						if co.V_Offset.keys[2].time.frame > timeEnd.frame then (
							timeEnd = co.V_Offset.keys[2].time
						)
					)
					if timeStart != timeEnd then (
						local Start = at time (timeStart.frame) ([bm.coordinates.U_Offset, bm.coordinates.V_Offset, 0])
						local End = at time (timeEnd.frame) ([bm.coordinates.U_Offset, bm.coordinates.V_Offset, 0])

						local rate = (distance Start End) / ((timeEnd.frame - timeStart.frame) / framerate)--/ frameRate
						scrollAngle = ((GetVectorsAngle Start End) - 180) * -1
						format "\n\tTextureScroll\n\t{\n\t\ttexturescrollvar $%\n\t\ttexturescrollrate %\n\t\ttexturescrollangle %\n\t}\n" type (formattedPrint (rate)) (formattedPrint scrollAngle) to:out
					)
				) else if hasProperty co #offset AND co.offset.keys != undefined then (
					if co.offset.keys != undefined AND co.offset.keys.count > 1 then (
						timeStart = co.offset.keys[1].time
						timeEnd = co.offset.keys[2].time
					)

					if timeStart != timeEnd then (
						local Start = at time timeStart.frame bm.coordinates.offset
						local End = at time timeEnd.frame bm.coordinates.offset

						local rate = (distance Start End) / ((timeEnd.frame - timeStart.frame) / framerate)--/ frameRate
						scrollAngle = ((GetVectorsAngle Start End) - 180) * -1
						format "\n\tTextureScroll\n\t{\n\t\ttexturescrollvar $%\n\t\ttexturescrollrate %\n\t\ttexturescrollangle %\n\t}\n" type (formattedPrint (rate)) (formattedPrint scrollAngle) to:out
					)
				)

				if hasProperty co #W_Angle AND co.W_Angle.keys != undefined AND co.W_Angle.keys.count > 1 then (
					timeStart = 0f
					timeEnd = 0f

					timeStart = co.W_Angle.keys[1].time
					timeEnd = co.W_Angle.keys[2].time

					if timeStart != undefined AND timeEnd != undefined AND timeStart != timeEnd then (
						local Start = at time (timeStart.frame) ((bm.coordinates.W_Angle))
						local End = at time (timeEnd.frame) ((bm.coordinates.W_Angle))

						local rate = (End - Start) / ((timeEnd.frame - timeStart.frame) / framerate)--/ frameRate

						if rotationAngle == undefined then (
							rotationAngle = Start * -1
							format "\n\t\"LinearRamp\"\n\n\t\t{\n\n\t\t\t\"rate\" \"%\"\n\n\t\t\t\"initialValue\" \"%\"\n\n\t\t\t\"resultVar\" \"$angle\"\n\n\t\t}\n" (formattedPrint (rate * -1)) (formattedPrint (Start * -1)) to:out
						)
						format "\n\t\"TextureTransform\"\n\n\t\t{\n\n\t\t\t\"rotateVar\" \"$angle\"\n\n\n\t\t\t\"resultVar\" \"$%\"\n\n\t\t}\n" type to:out

					) else if hasProperty co #angle AND co.Angle.keys != undefined AND co.Angle.keys.count > 1 then (
						timeStart = 0f
						timeEnd = 0f

						timeStart = co.Angle.keys[1].time
						timeEnd = co.Angle.keys[2].time

						if timeStart != undefined AND timeEnd != undefined AND timeStart != timeEnd then (
							local Start = at time (timeStart.frame) ((bm.coordinates.Angle))
							local End = at time (timeEnd.frame) ((bm.coordinates.Angle))
							local rate = (End - Start) / ((timeEnd.frame - timeStart.frame) / framerate)--/ frameRate
							/*
							if scrollAngle == undefined then (
								scrollAngle = ((GetVectorsAngle Start End) - 180) * -1
							)*/
							if rotationAngle == undefined then (
								rotationAngle = Start * -1
								format "\n\t\"LinearRamp\"\n\n\t\t{\n\n\t\t\t\"rate\" \"%\"\n\n\t\t\t\"initialValue\" \"%\"\n\n\t\t\t\"resultVar\" \"$angle\"\n\n\t\t}\n" (formattedPrint (rate * -1)) (formattedPrint (Start * -1)) to:out
							)
							format "\n\t\"TextureTransform\"\n\n\t\t{\n\n\t\t\t\"rotateVar\" \"$angle\"\n\n\n\t\t\t\"resultVar\" \"$%\"\n\n\t\t}\n" type to:out

						)
					)
				)

			)

		)
		out as String
	),

	function isValidBitmap ext = (
		t = wallworm_isValidBitmap ext
		t
	),
	function parseIFL f = (
		wallworm_parseIFL f
	),
	function useSSBump m = (
		local out = false
		if isProperty m #ssbump then (
			out = m.ssbump
		) else (
			if valveShader != "LightmappedGeneric" then (
				out = false
			) else (
				if m.displacementMap != undefined then (
					if classOf m.displacementMap == Normal_Bump then (
						mapToUse = m.displacementMap.normal_map
						if m.displacementMap.normal_map != undefined AND classOf m.displacementMap.normal_map == Bitmaptexture AND m.displacementMap.normal_map.Bitmap.hasAlpha == true then (
							out = true
						)
					)
				) else (
					if m.bumpMap != undefined then (
						if classOf m.bumpMap == Normal_Bump then (
							if m.bumpMap.normal_map != undefined AND classOf m.bumpMap.normal_map == Bitmaptexture AND m.bumpMap.normal_map.Bitmap.hasAlpha == true then (
								out = true
							)
						)
					)
				)
			)
		)
		out
	),
	function checkDimensions bm = (
		local status
		if (::WallWormProSMD != undefined) then (
			status = #(true, true)
		) else (
			--checks whether the dimensions of the texture are valid for vtex.exe
			status = #(true, true)
			try(
				local bmf = openBitMap bm
				if findItem allowedDimension bmf.height == 0 then (
					status[1] = false
				)
				if findItem allowedDimension bmf.width == 0 then (
					status[2] = false
				)
			) catch (
				status = #(false, false)
			)
		)
		status
	),

	function setShader s = (
		case s of (
			"VertexLitGeneric":valveShader = "VertexLitGeneric"
			"UnlitGeneric":valveShader = "UnlitGeneric"
			"LightmappedGeneric":valveShader = "LightmappedGeneric"
			"model":valveShader = "VertexLitGeneric"
			"model2":valveShader = "UnlitGeneric"
			"brush":valveShader = "LightmappedGeneric"
			"blend":valveShader = "WorldVertexTransition"
			"Refract":valveShader = "Refract"
			default:
			--wallworm_appendBitmaps &mat &materials valveShader
			if (classOf mat == Blend) then (
				valveShader = "WorldVertexTransition"
			) else (
				valveShader = "VertexLitGeneric"
			)
		)

	),

	function checkForAnimatedRotation m = (
		false
	),

	function transformCheck mat m = (
		local out = false
		if isProperty mat #exportTexTransforms AND isProperty mat #wallworm AND mat.forModel == false then (
			if mat.exportTexTransforms == true then (
				out = true
			) else (
				out = false
			)
		) else (
			if forModel == false AND decal == false then (
				out = false
			)
		)

		if out == false AND (forModel == true OR decal == true) then (
			/*Only check for these in models/decals since these are controlled in the VMF for world textures.*/
			local coords
			case of (
				(hasProperty m #coords) : (coords = m.coords)
				(hasProperty m #coordinates) : (coords = m.coordinates)
				default:()
			)
			if coords == undefined then (
				out = false
			) else (
				if hasProperty coords #U_Tiling then (
					if coords.U_Tiling != 1.0 then (
						out = true
					) else if coords.V_Tiling != 1.0 then (
						out = true
					) else if coords.U_Offset != 0.0 then (
						out = true
					) else if coords.V_Offset != 0.0 then (
						out = true
					) else if coords.W_Angle != 0.0 then (
						out = true
					)
				) else if hasProperty coords #tiling then (
					if coords.tiling != [1.0, 1.0, 1.0] then (
						out = true
					)
				)
			)
		) else (
			if isProperty mat #exportTexTransforms AND isProperty mat #wallworm then (
				out = mat.exportTexTransforms
			) else (
				local co = undefined
				for i = 1 to m.numSubs while co == undefined do (
					if ((getSubAnimName m i asString:true) == "Coordinates") then (
						co = getSubAnim m i
					)
				)
				if co != undefined then (
					out = true
				)
			)
		)
		out
	),

	/*
	Pass the texture map's uv coordinates
	*/
	function outputTransform coords = (
		local out = StringStream ""
		at time 0 (
			/*The center value does not seem to be correct. It should be offset when there is a Rotation, but by how much?*/
			local cent = [0, 0]
			if forModel then (
				cent.x = (coords.U_Tiling / 2)
				cent.y = (coords.V_Tiling / 2)
			)
			format "center % % scale % % rotate % translate % %" cent.x cent.y coords.U_Tiling coords.V_Tiling (coords.W_Angle * -1) ((mod coords.U_Offset 1) * coords.U_Tiling) ((mod coords.V_Offset 1) * coords.V_Tiling) to:out
		)
		out as String
	),

	function setMaterialPath mp = (
		if (valveShader == "VertexLitGeneric" OR forModel == true) then (
			if mp == "" then (
				if isProperty mat #wallworm AND mat.cdmaterials != "" then (
					mp = mat.cdmaterials
				) else (
					mp = getFileNamePath mat.name
				)
			)
			materialPath = mp
		) else(
			materialPath = getMaterialPathForMat mat
		)
		materialPath
	),
	function outputTextureLines texdata &texturemapstream &proxystream parmPrefix:"\n" quotes:"" forcePath:"" doTransforms:false = (
		local tex = texdata.thisTextureMap
		if tex != undefined AND (classOf tex == BitmapTexture OR ((::WallWormProSMD != undefined) AND isProperty tex #wallworm_texture_CA AND isProperty tex #getTGAPath)) then (
			local bmfilename

			if isProperty tex #wallworm_texture_CA AND isProperty tex #getTGAPath then (
				bmfilename = tex.getTGAPath()
			) else (
				bmfilename = tex.filename
			)
			if bmfilename != undefined AND bmfilename != "" then (
				local texstream = StringStream ""
				local prop = texdata.VMTPropName
				format "%%$%% \"%%\"" parmPrefix quotes prop quotes (wallworm_texture_path tex forcePath:forcePath skipExtension:true) texdata.ssbumpsuffix to:texturemapstream
				if doTransforms AND hasProperty tex #coords then (
					format "%$%transform \"%\"" parmPrefix prop (outputTransform tex.coords) to:texturemapstream
				)

				if tex != undefined then (
					scrollp = getScrollProxie tex type:(prop + "transform")
					if scrollp != "" then (
						format scrollp to:proxystream
					)
				)
				if bmfilename != undefined AND toLower (getFilenameType bmfilename) == ".ifl" AND (writeVMT == true OR (::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "")) then (
					local playbackrate = 1.0
					if hasProperty tex #playBackRate then (
						playbackrate = tex.playBackRate
					)
					format "% %AnimatedTexture%\n{\n%animatedTextureVar% %$%%\n%animatedTextureFrameNumVar% %$frame%\n%animatedTextureFrameRate% %%%\n}\n" parmPrefix quotes quotes quotes quotes quotes prop quotes quotes quotes quotes quotes quotes quotes quotes (formattedPrint (playbackrate * frameRate)) quotes to:proxystream
				)
			)
		)
	),
	function compileTexture tex type frame:undefined runBat:true shoutNotice:true writeVMT:false exportVTF:true = (
		--print writeVMT
		--print valveShader
		local m

		useDiffColor = false

		if mat1 == undefined then (
			mat1 = mat
		)

		case of (
			(isProperty tex #wallworm_texture_CA AND isProperty tex #getTGAPath):(
				m = tex.getTGAPath()
				texlist = tex.getFrames()
			)
			(classOf tex == BitmapTexture): (
				m = tex.filename
				texlist = wallworm_parseIFL tex.filename
			)
			default:()
		)

		local useWWMat = false
		if isProperty mat #wallworm then (
			if forModel == true then (
				if (findItem #("VertexLitGeneric", "Refract", "UnlitGeneric") mat.valveShader) != 0 then (
					valveShader = mat.valveShader
				)
			) else (
				if mat.valveShader != "VertexLitGeneric" then (
					valveShader = mat.valveShader
				)
			)
			if mat.valveShader == "LightMappedGeneric" OR mat.valveShader == "WorldVertexTransition" then (
				forModel = false
			)
			useWWMat = true
		)

		local batchstring = ""
		errors = #()
		if (materialPath == undefined) then (
			setMaterialPath ""
		)
		if (::wallworm_engine != 1) then (
			if (::WallWormProSMD == undefined) then (
				if (::wwmt_binDir == undefined) then (
					append errors "The Bin Directory in the Settings floater must be set to a directory where VTEX.exe is located. Copy VTEX there or install Wall Worm Pro."
				)
				studiopath = ::wwmt_binDir + "\\" + "vtex.exe"
				if doesFileExist (studiopath) == false then (
					append errors "The Bin Directory does not point to a path where vtex.exe is located. Copy VTEX there or install Wall Worm Pro."
				)
			)
			if materialPath == undefined AND (valveShader == "VertexLitGeneric" OR forModel == true) AND (materialPath == undefined OR materialPath == "") then (
				append errors "The Material Path for your model must be set."
			)
			if ((makeDir (::wwmt_gameInfoDir + "\materials\\" + materialPath) all:true) == false) then (
				append errors ("The directory [" + ::wwmt_gameInfoDir + "\materials\\" + materialPath + "]  does not exist and MAXScript could not create it.")
			)

		)
		if ((makeDir (::wwmt_exportMats + "\\" + materialPath) all:true) == false) then (
			append errors ("The material export directory [" + ::wwmt_exportMats + "\\" + materialPath + "] does not exist and MAXScript could not create it.")
		)

		if m != undefined AND (toLower ((getFilenameType m)) == ".ifl") then (
			diffName = ((getTexName m) + "0")
		) else (
			if texlist != undefined then (
				diffName = getTexName texlist[1]
			) else (
				diffname = wallworm_getMaterialName mat1 forModel:forModel
				useDiffColor = true
			)
		)
		if diffName == undefined then (
			append errors ("No name found.")
		) else (
			--possibly make a global setting for controlling this value
			if (wallworm_mat_name_limit_check diffName) == false then (
				append errors ("Your texture named " + diffName + " is invalid because the filename is too long. Limit the texture names to 22 characters or less.")
			)
		)
		if errors.count == 0 then (
			local mpstring = ""
			if matName != undefined AND matName != "" then (
				materialName = matName
			) else (
				materialName = diffName
			)
			if (materialPath != undefined AND materialPath != "") then (
				mpstring = materialPath + "\\"
			)
			if writeVMT == true OR (::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "") then (
				local parmPrefix = "\n	"
				local quotes = ""
			) else (
				local parmPrefix = " -vmtparam"
				local quotes = "\""
			)

			if diffName == "" then (
				useDiffColor = true
				writeVMT = true
			)

			if useDiffColor == true OR writeVMT == true OR (::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "") then (
				if materialName == undefined then (
					materialName = wallworm_getMaterialName mat forModel:getNameFromPath
				)
				if diffName == "" then (
					diffName = materialName
				)

				if forModel == true then (
					if ::wwmt_legacy_names == true then (
						if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
							vmfName = ::wwmt_gameInfoDir + "\\materials\\" + mpstring + diffName + ".vmt"
						) else (
							vmfName = ::wwmt_exportMats + "\\" + mpstring + diffName + ".vmt"
						)
					) else (
						vmfName = ::wwmt_gameInfoDir + "\\materials\\" + mpstring + materialName + ".vmt"
					)
				) else (
					materialPath = getMaterialPathForMat mat
					if useDiffColor == false AND classOf mat != Blend then (
						if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
							vmfName = ::wwmt_gameInfoDir + "\\materials\\" + materialName + ".vmt"
						) else (
							vmfName = ::wwmt_exportMats + "\\" + materialName + ".vmt"
						)
					) else (
						if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
							vmfName = ::wwmt_gameInfoDir + "\\materials\\" + materialName + ".vmt"
						) else (
							vmfName = ::wwmt_exportMats + "\\" + materialName + ".vmt"
						)
					)
				)
				parmPrefix = "\n	"
				quotes = ""
				--print ("Diffuse Color Mat sent to: "+batchName)

			)

			local extra = StringStream ""

			if (valveShader != "VertexLitGeneric" AND forModel == true) AND materialPath != undefined AND useWWMat == false then (
				format "% %$model% \"1\"" parmPrefix quotes quotes to:extra
			) else(
				if useWWMat == true then (
					format "\n%" (mat.outputme forceModel:forModel forceDecal:decal) to:extra
				)
			)

			if forModel == true AND chkwwmt_oldModelVTFPath == true then (
				forcePath = mpstring
			) else (
				forcePath = ""
			)

			if type == "diff" then (
				--this is diffuse 
				if decal == true AND useWWMat == false then (
					format "% %$decal% \"1\"" parmPrefix quotes quotes to:extra
				)

				if useWWMat == false then (
					if surfaceproperty != undefined AND surfaceproperty != "" then (
						format "% %$surfaceprop% \"%\"" parmPrefix quotes quotes surfaceproperty to:extra
					)
				)
				local texmaparray = #()
				local proxystream = StringStream ""
				if writeVMT == true AND useDiffColor == false then (
					if (toLower ValveShader == "subrect") then (
						append texmaparray (wwmatTexToSource VMTPropName:"material" thisTextureMap:basetexture)
						local matdiffusemap = mat.diffusemap
						if classOf matdiffusemap == BitmapTexture then (
							local displayMatdiffuseMapBM = matdiffusemap.Bitmap
							if displayMatdiffuseMapBM != undefined then (
								local bmWidth = displayMatdiffuseMapBM.width as Float
								local bmHeight = displayMatdiffuseMapBM.height as Float
								format "% %$Pos% \"% %\"" parmPrefix quotes quotes ((bmWidth * matdiffusemap.clipu) as Integer) ((bmHeight * matdiffusemap.clipv) as Integer) to:extra
								format "% %$Size% \"% %\"" parmPrefix quotes quotes ((bmWidth * matdiffusemap.clipw) as Integer) ((bmHeight * matdiffusemap.cliph) as Integer) to:extra
							)
						)
					) else (
						append texmaparray (wwmatTexToSource VMTPropName:"basetexture" thisTextureMap:basetexture)
					)
				)
				local hasAddedENVmap = false
				if (reflectionMap != undefined OR mat1.reflectionMapEnable == true ) then (
					--add check for texture
					hasAddedENVmap = true
					if reflectionMap != undefined AND classOf reflectionMap == Reflect_Refract AND reflectionMap.outputname != undefined then (
						thecubemapfile = getFileNameFile reflectionMap.outputname
						thecubemapfile = substitutestring thecubemapfile "_UP" ""
						format "% %$envmap% \"%/%\"" parmPrefix quotes quotes (wallworm_remove_last_slash (wallworm_safe_path (reflectionMap.name))) thecubemapfile to:extra
					) else (
						format "% %$envmap% \"env_cubemap\"" parmPrefix quotes quotes to:extra
					)

					if (isProperty mat1 #useEnvSettings AND mat1.useEnvSettings == true) OR (isProperty mat1 #envmaptint AND NOT isProperty mat1 #useEnvSettings) then (
						if isProperty mat1 #envmaptint AND mat1.envmaptint != undefined then (
							format "% %$envmaptint% \"[% % %]\"" parmPrefix quotes quotes (formattedPrint (mat1.envmaptint.r / 255) format:"1.2g") (formattedPrint (mat1.envmaptint.g / 255) format:"1.2g") (formattedPrint (mat1.envmaptint.b / 255) format:"1.2g") to:extra
						)
						if isProperty mat1 #envmapcontrast AND mat1.envmapcontrast != undefined then (
							format "% %$envmapcontrast% \"%\"" parmPrefix quotes quotes mat1.envmapcontrast to:extra
						)
						if isProperty mat1 #envmapsaturation AND mat1.envmapsaturation != undefined then (
							format "% %$envmapsaturation% \"%\"" parmPrefix quotes quotes mat1.envmapsaturation to:extra
						)
					)
				)

				if isProperty mat1 #breakablesurface AND mat1.breakablesurface == true then (
					format "% %BreakableSurface%\n{\n\n}" parmPrefix quotes quotes to:proxystream
				)

				if isProperty mat1 #crackmaterial AND mat1.crackmaterial != undefined then (
					format "% %$crackmaterial% \"%\"" parmPrefix quotes quotes mat1.crackmaterial.name
				)

				local bumpName
				case valveShader of (
					"VertexLitGeneric":(bumpName = "bumpmap")
					"Refract":(bumpName = "normalmap")
					default:(
						bumpName = "bumpmap"
					)
				)

				lookForSSBump = useSSBump mat1
				if lookForSSBump AND forModel == false then (
					ssbumpsuffix = "_ssbump"
				) else (
					ssbumpsuffix = ""
				)

				if normal != undefined then (
					append texmaparray (wwmatTexToSource VMTPropName:bumpName thisTextureMap:normalmap ssbumpsuffix:ssbumpsuffix)
				) else if bump != undefined do (
					append texmaparray (wwmatTexToSource VMTPropName:bumpName thisTextureMap:bumpmap ssbumpsuffix:ssbumpsuffix)
				)

				if useWWMat == false AND lookForSSBump == true then (
					format "% %$ssbump% \"1\"" parmPrefix quotes quotes to:extra
				)

				if (specLevelMap != undefined AND valveShader != "Refract") then (
					if hasAddedENVmap == false then (
						format "% %$envmap% \"env_cubemap\"" parmPrefix quotes quotes to:extra
					)
					local tempBitmap = openBitmap specLevelMap
					local specHasAlpha = true -- (tempBitmap != undefined AND tempBitmap.hasAlpha)
					if (valveShader == "VertexLitGeneric" OR forModel == true) then (
						--http://developer.valvesoftware.com/wiki/$envmapmask
						--A specular map only works on models if there is NO bump/normal map OR the spec comes from diffuse or bump alpha
						if (normal == undefined AND bump == undefined) then (
							if diff == specLevelMap AND specHasAlpha then (
								format "% %$basealphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
							) else if specLevelMap == illum AND specHasAlpha then (
								format "% %$selfillum_envmapmask_alpha% \"1\"" parmPrefix quotes quotes to:extra
							) else (
								append texmaparray (wwmatTexToSource VMTPropName:"envmapmask" thisTextureMap:envmapmask ssbumpsuffix:"")
							)
						) else (
							local proceed = false
							local checkIllum = false
							local checkNormal = false
							local checkBump = false
							if bump != undefined AND bump == specLevelMap then (
								proceed = true
								checkBump = true
							)
							if normal != undefined AND normal == specLevelMap then (
								proceed = true
								checkNormal = true
							)
							if illum != undefined AND illum == specLevelMap then (
								proceed = true
								checkIllum = true
							)
							if (diff == specLevelMap OR proceed == true) AND specHasAlpha then (
								if (checkBump == true OR checkNormal == true) then (
									if (checkBump == true) then (
										format "% %$normalmapalphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
									) else(
										if (checkNormal == true) then (
											format "% %$normalmapalphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
										)
									)
								) else if (checkIllum == true) then (
									format "% %$selfillum_envmapmask_alpha% \"1\"" parmPrefix quotes quotes to:extra
								) else (
									if diff == specLevelMap then (
										format "% %$basealphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
									)
								)
							) else (
								append texmaparray (wwmatTexToSource VMTPropName:"envmapmask" thisTextureMap:envmapmask ssbumpsuffix:"")
							)
						)
					) else (
						if specHasAlpha then (
							if diff == specLevelMap then (
								format "% %$basealphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
							) else if (bump == specLevelMap OR normal == specLevelMap) then (
								format "% %$normalmapalphaenvmapmask% \"1\"" parmPrefix quotes quotes to:extra
							) else if (bump == illum) then (
								format "% %$selfillum_envmapmask_alpha% \"1\"" parmPrefix quotes quotes to:extra
							)
						) else (
							append texmaparray (wwmatTexToSource VMTPropName:"envmapmask" thisTextureMap:envmapmask ssbumpsuffix:"")
						)
					)
					if tempBitmap != undefined then (
						close tempBitmap
					)
				)

				if ambient != undefined AND forModel == true then (
					append texmaparray (wwmatTexToSource VMTPropName:"AmbientOcclusion" thisTextureMap:AmbientOcclusion ssbumpsuffix:"")
					format "% %$AmbientOcclusion% \"1\"" parmPrefix quotes quotes to:extra
				)
				if detailF != undefined then (
					--detailMap = wallworm_detailMapTex mat1 
					append texmaparray (wwmatTexToSource VMTPropName:"detail" thisTextureMap:detail ssbumpsuffix:"")
					if isProperty mat1 #usedetailscale AND mat1.usedetailscale == true then (
						format "% %$detailscale% \"%\"" parmPrefix quotes quotes mat1.detailscale to:extra
					)
					if isProperty mat1 #useadvanceddetail AND mat1.useadvanceddetail == true then (
						if isProperty mat1 #detailtint AND mat1.detailtint != undefined then (
							format "% %$detailtint% \"[% % %]\"" parmPrefix quotes quotes (formattedPrint (mat1.detailtint.r / 255) format:"1.2g") (formattedPrint (mat1.detailtint.g / 255) format:"1.2g") (formattedPrint (mat1.detailtint.b / 255) format:"1.2g") to:extra
						)
						if isProperty mat1 #detailblendmode AND mat1.detailblendmode != undefined then (
							format "% %$detailblendmode% \"%\"" parmPrefix quotes quotes mat1.detailblendmode to:extra
						)
						if isProperty mat1 #detailblendfactor AND mat1.detailblendfactor != undefined then (
							format "% %$detailblendfactor% \"%\"" parmPrefix quotes quotes mat1.detailblendfactor to:extra
						)
					)
				)

				if illum != undefined then (
					append texmaparray (wwmatTexToSource VMTPropName:"selfillumtexture" thisTextureMap:selfillumtexture ssbumpsuffix:"")
					append texmaparray (wwmatTexToSource VMTPropName:"selfillummask" thisTextureMap:selfillumtexture ssbumpsuffix:"")
					format "% %$selfillum% \"1\"" parmPrefix quotes quotes to:extra
				)

				if phongexponenttexture != undefined AND valveShader == "VertexLitGeneric" then (
					--Phong

					format "% %$phong% \"1\"" parmPrefix quotes quotes to:extra
					if useWWMat == false then (
						format "% %$phongboost%  \"%\" % %$phongfresnelranges% \"[0 0.5 1]\"" parmPrefix quotes quotes (mat1.specularMapAmount / 100.0) parmPrefix quotes quotes to:extra
					)
					if spec != undefined then (
						case of (
							(diff == spec): (
								format "% %$basemapalphaphongmask% \"1\"" parmPrefix quotes quotes to:extra
							)
							default:()
						)
						append texmaparray (wwmatTexToSource VMTPropName:"phongexponenttexture" thisTextureMap:phongexponenttexture ssbumpsuffix:"")
					) else (
						if useWWMat == true then (
							local phongexponent = mat1.phongexponent
						) else (
							local phongexponent = 5
						)
						format "% %$phongexponent% \"%\"" parmPrefix quotes quotes phongexponent to:extra
					)
				)

				--check if 2-sided
				if refracttinttexture != undefined OR mat1.refractionMapEnable == true then (
					local refractAmount = mat1.refractionMapAmount / 100

					if refracttinttexture != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:"refracttinttexture" thisTextureMap:refracttinttexture ssbumpsuffix:"")
						if classOf refracttinttexture == BitmapTexture then (
							format "% %$bluramount% \"%\"" parmPrefix quotes quotes (refracttinttexture.coords.blur) to:extra
						) else (
							if classOf refracttinttexture == Color_Correction then (
								format "% %$refracttint% \"{% % %}\" % %$bluramount% \"1\"" parmPrefix quotes quotes (refracttinttexture.color[1]) (refracttinttexture.color[2]) (refracttinttexture.color[3]) parmPrefix quotes quotes to:extra
							)
						)
					)
					format "% %$refractamount% \"%\"" parmPrefix quotes quotes refractAmount to:extra
				)

				if isProperty mat1 #reflectivity AND isProperty mat1 #useReflectivity AND mat1.useReflectivity == true then (
					format "% %$reflectivity% \"[% % %]\"" parmPrefix quotes quotes (formattedPrint (mat.reflectivity.r / 255) format:"2.2g") (formattedPrint (mat.reflectivity.g / 255) format:"2.2g") (formattedPrint (mat.reflectivity.b / 255) format:"2.2g") to:extra

				) else (
					if reflectionMap != undefined OR mat1.reflectionMapEnable == true then (
						local useReflectMap = false
						if ::Color_Correction != undefined then (
							if reflectionMap != undefined AND classOf reflectionMap == Color_Correction then (
								useReflectMap = true
								format "% %$reflectivity% \"{% % %}\"" parmPrefix quotes quotes mat1.reflectionMap.color[1] mat1.reflectionMap.color[2] mat1.reflectionMap.color[3] to:extra
							)
						) else (
							--probably failed because older version of Max... Color_Correction added in Max 2009
							useReflectMap = false
							local reflect = mat1.reflectionMapAmount / 100
							format "% %$reflectivity% \"[% % %]\"" parmPrefix quotes quotes reflect reflect reflect to:extra
						)
					)
				)
				local nocull = false
				if (mat1.twoSided != undefined AND mat1.twoSided == on) then (
					nocull = true
					format "% %$nocull% \"1\"" parmPrefix quotes quotes to:extra
				)

				if forceOpaque == false then (
					if ((mat1.opacity != undefined AND mat1.opacity != 100)) then (
						alphavalue = mat1.opacity / 100
						format "% %$alpha% \"%\"" parmPrefix quotes quotes alphavalue to:extra
						if mat1.opacityType == 2 then (
							format "% %$additive% \"1\"" parmPrefix quotes quotes to:extra
						)

					)
					local addTrans = false
					local checkForAlpha = false
					if (::wwmt_translucentOnlyIfOpacityMap == true) then (
						local opMap = mat1.opacityMap
						if opMap != undefined AND classOf opMap == BitmapTexture AND (opMap.filename == diff OR (isProperty opMap #vtfpath AND (getFileNameFile opMap.vtfpath == getFileNameFile diff)))then (
							addTrans = true
						)
					) else (
						if basetexture != undefined AND classOf basetexture == BitmapTexture AND basetexture.alphasource == 0 then (
							addTrans = true
						)
					)

					if addTrans == true then (
						if (nocull == true AND (valveShader == "VertexLitGeneric" OR forModel == true)) OR illum != undefined then (
							if useWWMat == false then (
								format "% %$alphatest% \"1\"" parmPrefix quotes quotes to:extra
							) else (
								if mat1.alphatest == false then (
									format "% %$translucent% \"1\"" parmPrefix quotes quotes to:extra
								)
							)
						) else (
							if useWWMat == false OR (useWWMat == true AND mat1.alphatest == false)  then (
								format "% %$translucent% \"1\"" parmPrefix quotes quotes to:extra
							)
						)
					)
				)

				if lightwarptexture != undefined then (
					append texmaparray (wwmatTexToSource VMTPropName:"lightwarptexture" thisTextureMap:lightwarptexture ssbumpsuffix:"")
				)

				if parallaxmap != undefined then (
					append texmaparray (wwmatTexToSource VMTPropName:"parallaxmap" thisTextureMap:parallaxmap ssbumpsuffix:"")
					format "% %$parallaxmapscale% \"%\"" parmPrefix quotes quotes mat1.parallaxmapscale to:extra

				)

				if valveShader == "WorldVertexTransition" AND mat2 != undefined AND writeVMT == true then (
					tooltexture = getBlendToolTexName()
					if tooltexture != undefined AND tooltexture != "" then (
						format "% %\%tooltexture% \"%\"" parmPrefix quotes quotes tooltexture to:extra
					)
					if useWWMat == false then (
						if detailtype != undefined AND detailtype != "" then (
							format "% %\%detailtype% \"%\"" parmPrefix quotes quotes detailtype to:extra
						)
						if surfaceproperty2 != undefined AND surfaceproperty2 != "" then (
							format "% %$surfaceprop2% \"%\"" parmPrefix quotes quotes surfaceproperty2 to:extra
						)
					)

					if (materialPath2 != undefined AND materialPath2 != "") then (
						mpstring = materialPath2 + "\\"
					)

					if blendmodulate != undefined AND classOf blendmodulate == BitmapTexture then (
						append texmaparray (wwmatTexToSource VMTPropName:"blendmodulatetexture" thisTextureMap:blendmodulate ssbumpsuffix:"")
					)

					if lightwarptexture2 != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:"lightwarptexture2" thisTextureMap:lightwarptexture2 ssbumpsuffix:"")
					)

					--mpstring = wallworm_bsToFs mpstring

					if basetexture2 != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:"basetexture2" thisTextureMap:basetexture2 ssbumpsuffix:"")

					) else (
						--add diffcolor 2
					)

					if (envmapmask != undefined OR (classOf mat2 == Standard AND mat2.reflectionMapEnable != undefined AND mat2.reflectionMapEnable == true)) then (
						--add check for texture
						format "% %$envmap2% \"env_cubemap\"" parmPrefix quotes quotes to:extra
					)

					if refract2 != undefined then (
						bumpName = "normalmap2"
					) else (
						bumpName = "bumpmap2"
					)

					lookForSSBump = useSSBump mat2

					if lookForSSBump AND forModel == false then (
						ssbumpsuffix = "_ssbump"
					) else (
						ssbumpsuffix = ""
					)

					if normal2 != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:bumpName thisTextureMap:normalmap2 ssbumpsuffix:ssbumpsuffix)
					) else (
						if bump2 != undefined then (
							append texmaparray (wwmatTexToSource VMTPropName:bumpName thisTextureMap:bumpmap2 ssbumpsuffix:ssbumpsuffix)
						)

					)

					if useWWMat == false AND useSSBump mat2 == true then (
						format "% %$ssbump2% \"1\"" parmPrefix quotes quotes to:extra
					)

					if (specLevelMap2 != undefined AND valveShader != "Refract") then (
						if diff2 == specLevelMap2 then (
							format "% %$basealphaenvmapmask2% \"1\"" parmPrefix quotes quotes to:extra
						) else if (bump2 == specLevelMap2 OR normal2 == specLevelMap2) then (
							format "% %$normalmapalphaenvmapmask2% \"1\"" parmPrefix quotes quotes to:extra
						) else if (bump2 == illum2) then (
							format "% %$selfillum_envmapmask_alpha2% \"1\"" parmPrefix quotes quotes to:extra
						) else (
							append texmaparray (wwmatTexToSource VMTPropName:"envmapmask2" thisTextureMap:envmapmask2 ssbumpsuffix:"")
						)
					)

					if detailF2 != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:"detail2" thisTextureMap:detail2 ssbumpsuffix:"")
					)

					if illum2 != undefined then (
						append texmaparray (wwmatTexToSource VMTPropName:"selfillumtexture2" thisTextureMap:selfillumtexture2 ssbumpsuffix:"")
						append texmaparray (wwmatTexToSource VMTPropName:"selfillummask2" thisTextureMap:selfillumtexture2 ssbumpsuffix:"")
						format "% %$selfillum2% \"1\"\n" parmPrefix quotes quotes to:extra
					)

					if reflectionMap2 != undefined OR mat2.reflectionMapEnable == true then (
						local useReflectMap = false
						if reflectionMap2 != undefined AND ::Color_Correction != undefined AND classOf reflectionMap2 == Color_Correction then (
							useReflectMap = true
							format "% %$reflectivity2% \"{% % %}\"" parmPrefix quotes quotes reflectionMap2.color[1] reflectionMap2.color[2] reflectionMap2.color[3] to:extra
						) else (
							--probably failed because older version of Max... Color_Correction added in Max 2009
							useReflectMap = false
							local reflect = mat2.reflectionMapAmount / 100
							format "% %$reflectivity2% \"{% % %}\"" parmPrefix quotes quotes reflect reflect reflect to:extra
						)
					)

					local nocull = false
					if (mat2.twoSided != undefined AND mat2.twoSided == on) then (
						nocull = true
						format "% %$nocull2% \"1\"\n" parmPrefix quotes quotes to:extra

					)
					if ((mat2.opacity != undefined AND mat2.opacity != 100)) then (
						local alphavalue = mat2.opacity / 100
						format "% %$alpha2% \"%\"\n" parmPrefix quotes quotes alphavalue to:extra
						if mat2.opacityType == 2 then (
							format "% %$additive2% \"1\"\n" parmPrefix quotes quotes to:extra
						)
					)

					local addTrans = false
					local checkForAlpha = false
					if (::wwmt_translucentOnlyIfOpacityMap == true) then (
						local opMap = mat2.opacityMap
						if opMap != undefined AND classOf opMap == BitmapTexture AND (opMap.filename == diff OR (isProperty opMap #vtfpath AND (getFileNameFile opMap.vtfpath == getFileNameFile diff)))then (
							addTrans = true
						)
					) else (
						if basetexture != undefined AND classOf basetexture == BitmapTexture AND basetexture.alphasource == 0 then (
							addTrans = true
						)
					)

					if addTrans == true then (
						format "% %$translucent% \"1\"\n" parmPrefix quotes quotes to:extra
					)

					/*END MAT 2*/

				)
			) else (
				if type == "normal" then (
					format "% %$normal% \"1\"\n" parmPrefix quotes quotes to:extra
				) else if type == "bump" then (
					format "% %$normal% \"1\"\n" parmPrefix quotes quotes to:extra
				)
			)
			local shaderUsed = valveShader
			if type != "diff" AND valveShader == "WorldVertexTransition" then (
				shaderUsed = "LightmappedGeneric"
			)
			if valveShader != "WorldVertexTransition" AND type == "diff" AND mat1.refractionMapEnable == true then (
				shaderUsed = "Refract"
			)
			local VMTWritten = false
			if writeVMT == true OR (::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "") then (
				if exportVTF == false OR forModel == true then (
					if useDiffColor == true OR (isProperty mat1 #useColor AND mat1.useColor == true) then (
						local c = (mat1.diffuse as Color)
						local color2 = ""
						if forModel == true AND valveShader == "VertexLitGeneric" then (
							color2 = "2"
							format "% %$color%% \"{% % %}\"" parmPrefix quotes color2 quotes c.r c.g c.b to:extra
						) else (
							if forModel == true then (
								format "% %$color%% \"{% % %}\"" parmPrefix quotes color2 quotes c.r c.g c.b to:extra

							) else (
								format "% %$color%% \"[% % %]\"" parmPrefix quotes color2 quotes (c.r / 256) (c.g / 256) (c.b / 256) to:extra
							)
						)

						if (isProperty mat1 #blendTintByBaseAlpha AND mat1.blendTintByBaseAlpha == true) then (
							format "% %$blendTintByBaseAlpha% \"1\"\n" parmPrefix quotes quotes to:extra
						)

						if (isProperty mat1 #blendTintColorOverBase AND mat1.blendTintColorOverBase > 0.0) then (
							format "% %$blendTintColorOverBase% \"%\"\n" parmPrefix quotes quotes mat1.blendTintColorOverBase to:extra
						)
					)
					if doesFileExist (getFileNamePath vmfName) == false then (
						makeDir (getFileNamePath vmfName) all:true
					)

					if doesFileExist vmfName == true then (
						local newVMF = openFile vmfName mode:"w"
					) else (
						local newVMF = createFile(vmfName)
					)
					local texturemapstream = StringStream ""
					for mp in otherMaps do (
						if isProperty mp #vmtproperties then (
							for prop in mp.vmtproperties WHERE prop != undefined AND prop != "" do (
								append texmaparray (wwmatTexToSource VMTPropName:prop thisTextureMap:mp)
							)
						) else (
							append texmaparray (wwmatTexToSource VMTPropName:mp.vmtproperty thisTextureMap:mp)
						)
					)
					local hasoutputprops = #()
					for data in texmaparray do (
						if data.VMTPropName != undefined then (
							local propname = toLower data.VMTPropName
							if propname != "" then (
								if findItem hasoutputprops propname == 0 then (
									local doTransforms = transformCheck mat1 data.thisTextureMap
									outputTextureLines data &texturemapstream &proxystream parmPrefix:parmPrefix quotes:quotes forcePath:forcePath doTransforms:doTransforms
									append hasoutputprops propname
								)
							)
						)
					)
					if rotationAngle != undefined AND rotationAngle != 0.0 then (
						format ("% %$angle% \"%\"") parmPrefix quotes quotes (formattedPrint rotationAngle) to:texturemapstream
					)

					local proxystream2 = StringStream ""
					if (proxystream as String) != "" then (
						format "\nProxies\n{" to:proxystream2
						format (proxystream as String) to:proxystream2
						format "\n}\n" to:proxystream2
					)

					format "\"%\"\n{\n%\n%\n%\n}" shaderUsed (texturemapstream as String) (proxystream2 as String) (extra as String) to:newVMF
					close newVMF
				)
				VMTWritten = true
			)

			local gameInfoParam = ""
			if useDiffColor == false AND exportVTF == true then (
				wallworm_copy_bitmap_to_sdk tex forcePath:mpstring texlist:texlist compression:compression type:type
				out = wallworm_write_vtf_bat tex diffName:diffName dir:mpstring VMTWritten:VMTWritten runBat:runBat exportVTF:exportVTF extra:extra shaderUsed:shaderUsed
			)

		)

		if errors.count > 0 then (
			out = "There were errors. Please read the following notes:\n\n##########################\n\n"
			for er in errors do (
				append out ("* " + er + "\n\n")
			)
			format out
			if shoutNotice == true then (
				messageBox out
			)
		)
		out

	),
	function compileMaterial = (
		compileTexture diff "diff"
		if bump != undefined then (
			compileTexture bump "bump"
		)
		if detail != undefined then (
			compileTexture detail "detail"
		)

		if diff2 != undefined then (
			compileTexture diff2 "diff2"
		)
		if normal != undefined then (
			compileTexture normal "normal"
		)

		if ambient != undefined then (
			compileTexture ambient "ambient"
		)
		if specLevelMap != undefined then (
			compileTexture specLevelMap "specLevelMap"
		)

		if illum != undefined then (
			compileTexture illum "illum"
		)

		if spec != undefined then (
			compileTexture spec "spec"
		)
		if refract != undefined then (
			compileTexture refract "refract"
		)

		if lightwarptexture != undefined then (
			compileTexture lightwarptexture "lightwarptexture"
		)

		if parallaxmap != undefined then (
			compileTexture parallaxmap "parallaxmap"
		)
	),
	function getVMToutDir = (
		local prepname = wallworm_remove_last_slash matName
		local toolpath = pathConfig.removePathLeaf prepname
		(wallworm_bsToFs (::wwmt_exportMats + "/" + toolpath + "/"))
	)
)