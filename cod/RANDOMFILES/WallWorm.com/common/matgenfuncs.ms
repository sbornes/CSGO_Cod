
/*
This function takes an array that comes from a line string in a VMT and converts the values to colors or integers
*/
function wallworm_get_color_from_string_arrays lineArray t:"color" = (
	local mult = false
	if t == "color" then (
		if lineArray.count > 1 AND (matchPattern lineArray[2] pattern:"*[*" == true) then (
			mult = true
		) else (
			mult = false
		)
	)

	local colval = ""
	local ct = lineArray.count
	for i = 1 to ct do (
		append colval lineArray[i]

		if i != ct then (
			append colval " "
		)
	)

	--colval  =( lineArray[2]+" " + lineArray[3] +" " + lineArray[4])

	colval = substituteString colval "\"" ""

	colval = substituteString colval "{" ""
	colval = substituteString colval "}" ""

	colval = substituteString colval "]" ""
	colval = substituteString colval "[" ""

	colvals = filterString colval " "
	local v
	if t == "color" then (
		if colvals != undefined AND colvals.count >= 4 then (
			if (mult == true) then (
				v = Color ((colvals[2] as Float) * 255) ((colvals[3] as Float) * 255) ((colvals[4] as Float) * 255)
			) else (
				v = Color (colvals[2] as Float) (colvals[3] as Float) (colvals[4] as Float)
			)

		)
	) else (
		if colvals != undefined AND colvals.count > 0 then (
			case t of (
				"float": (v = colvals[2] as Float)
				"integer": (v = colvals[2] as Float)
				"string": (v = (colvals[2] as String + " " + colvals[3] as String + " " + colvals[4] as String))
				"array":(v = colvals)
			)

		)
	)
	v
)

struct wallworm_texture_transform (
	c = [0, 0], --center
	s = [1, 1], --scale
	r = 0, --rotate
	t = [0, 0], --translate
	function setFromTransform tr = (
		c = tr.Center
		s = tr.Scale
		r = tr.Rotate
		t = tr.Translate
	),
	function setTextureTransforms &coords = (
		/*The center value does not seem to be correct. It should be offset when there is a Rotation, but by how much?*/
		coords.U_Tiling = 1 / s.x
		coords.V_Tiling = 1 / s.y
		coords.U_Offset = t.x / s.x
		coords.V_Offset = t.y / s.y
		coords.W_Angle = r * -1
	),
	function parseString str = (
		if matchPattern str pattern:"*\"*" then (
			--sanitize string
			local start = findString str "\""
			str = replace str 1 start ""
			str = substituteString str "\"" ""
		)

		local vals = filterString str " "
		if vals.count == 11 then (
			c.x = vals[2] as Float
			c.y = vals[3] as Float
			s.x = vals[5] as Float
			s.y = vals[6] as Float
			r = vals[8] as Float
			t.x = vals[10] as Float
			t.y = vals[11] as Float
		)
	)
)

function wallworm_getBitmapFromPaths fname extraPath:undefined extraRootPaths:undefined collecting:true = (
	local patharray = #()
	local res = undefined

	if extraPath != undefined AND extraPath != "" then (
		if doesFileExist extraPath == true then (
			append patharray (extraPath)
		)

		p2 = (::wwmt_gameInfoDir + "\\materials\\" + extraPath)

		if doesFileExist p2 == true then (
			append patharray p2
		)
		p3 = (::wwmt_exportMats + "\\" + extraPath)
		if doesFileExist p3 == true then (
			append patharray p3
		)

		p4 = (::wwmt_raw_mats + "\\" + extraPath)
		if doesFileExist p4 == true then (
			append patharray p4
		)
	)
	append patharray (::wwmt_gameInfoDir + "\\materials\\")
	append patharray (::wwmt_exportMats)
	append patharray (::wwmt_raw_mats)
	append patharray (getFilenamePath ::wwmt_raw_mats + "\\materialsrc\\")
	
	if ::wwmt_wwmt_gameInfoDirs != undefined AND ::wwmt_wwmt_gameInfoDirs.count > 0 then (
		for p in ::wwmt_wwmt_gameInfoDirs WHERE p != undefined AND p != "" do (
			append patharray p
			append patharray (p + "\\materials\\")
			append patharray (getFilenamePath p + "\\materialsrc\\")
		)
	)
	
	if extraRootPaths != undefined AND extraRootPaths.count > 0 then (
		nps = #()
		for p in patharray do (
			for p2 in extraRootPaths do (
				append nps (p + "\\" + p2)

			)

		)

		if nps.count > 0 then (
			for n in nps do (
				append patharray n
			)
		)
	)

	patharray = makeUniqueArray patharray
	patharray = for p in patharray WHERE doesFileExist p collect p

	for p in patharray while res == undefined do (
		theTex = (p + "\\" + fname + ".psd")
		if doesFileExist theTex then (
			res = #(theTex, true)
		)

	)

	for p in patharray while res == undefined do (
		theTex = (p + "\\" + fname + ".tga")
		if doesFileExist theTex then (
			res = #(theTex, true)
		)

	)

	if collecting == true OR (wallworm_isValidBitmap ".vtf" vtfCheck:true) == true then (
		for p in patharray while res == undefined do (
			theTex = (p + "\\" + fname + ".vtf")

			if doesFileExist theTex then (
				if ::WallwormProActive == true OR VTFImporter != undefined then (
					canClose = true
				) else (
					canClose = false
				)

				res = #(theTex, canClose)
			)

		)

	)

	if res == undefined then (
		if extraPath == undefined then (
			extraPath = ""
		)

		res = #((extraPath + "\\" + fname + ".tga"), false)
	)
	res
)

function wallworm_getVMTFromPaths fname extraPath:undefined extraRootPaths:undefined = (
	local theTexPath = undefined
	ftype = getFileNameType fname
	if ftype != undefined AND ftype != "" then (
		fname = substituteString fname ftype ""
	)
	patharray = #()
	if extraPath != undefined then (
		append patharray (extraPath)
		append patharray (::wwmt_exportMats + "\\" + extraPath)
		append patharray (::wwmt_gameInfoDir + "\\materials\\" + extraPath)
		append patharray (::wwmt_raw_mats + "\\" + extraPath)
	)
	append patharray (::wwmt_gameInfoDir + "\\materials\\")
	append patharray (::wwmt_exportMats)
	append patharray (::wwmt_raw_mats)
	
	if ::wwmt_wwmt_gameInfoDirs != undefined AND ::wwmt_wwmt_gameInfoDirs.count > 0 then (
		for p in ::wwmt_wwmt_gameInfoDirs WHERE p != undefined AND p != "" do (
			append patharray p
			append patharray (p + "\\materials\\")
		)
	)

	if extraRootPaths != undefined AND extraRootPaths.count > 0 then (
		nps = #()
		for p in patharray do (
			for p2 in extraRootPaths do (
				append nps (p + "\\" + p2)
			)
		)
		if nps.count > 0 then (
			for n in nps do (
				append patharray n
			)
		)
	)

	--format "###########\nPaths:\t%\nMaterial Name: \t%\n" patharray fname
	patharray = makeUniqueArray patharray

	for p in patharray while theTexPath == undefined do (
		theTex = (p + "\\" + fname + ".vmt")
		if ::wallworm_debug == true then (
			print ("Looking for: " + theTex)
		)

		if doesFileExist theTex then (
			if ::wallworm_debug == true then (
				print ("FOUND VMT " + theTex)
			)
			theTexPath = theTex
		)

	)
	theTexPath
)

function wallworm_get_sourcematpaths inp = (
	wallworm_safe_path inp
	if matchPattern inp pattern:"*.vtf" == false AND matchPattern inp pattern:"*.tga" == false then (
		inp += ".vtf"
	)
	inp
)

function wallworm_getValueVMTVal ln = (
	ln = substituteString ln "\"" ""
	ln = substituteString ln "\"" ""
	ln = substituteString ln "\\\\" "\\"
	ln = substituteString ln "\\" "/"
	ln
)

::wallworm_VMTHelper = try (
	DotNetClass "WallWorm.Helpers.VMTHelper"
	fileIn (::wallworm_installation_path + "/WallWorm.com/common/vmt_funcs.ms")
) catch (undefined)
function wallworm_generateMaterialFromVMT vmt addMat:undefined matType:"brush" brushColor:(Color 0 0 0) modelColor:(Color 0 0 0) dispColor:(Color 0 0 0) dispColor2:(Color 0 0 0) decalColor:(Color 0 0 0) extraPath:undefined overWriteName:undefined rootPath:undefined extraRootPaths:undefined forceMaxScript:false = (
	undo off (
		local oldSIlentMode = setSilentMode true
		if forceMaxScript == false AND ::WallwormProActive == true AND ::wallworm_VMTHelper != undefined AND ::WWuseLegacyVMTImport != true then (
			displayMat = ::wallworm_vmt_loadMaterial vmt matType:matType brushColor:brushColor modelColor:modelColor dispColor:dispColor dispColor2:dispColor2 decalColor:decalColor extraPath:extraPath overWriteName:overWriteName rootPath:rootPath extraRootPaths:extraRootPaths
			if displayMat != undefined then (
				displayMat.name = wallworm_sanitize_texture_path displayMat.name fs:true materialPathPrune:true
				if isProperty displayMat #decal AND displayMat.decal == true AND displayMat.opacityMap == undefined AND displayMat.diffusemap != undefined then (
					displayMatdiffuseMap = displayMat.diffuseMap
					displayMatdiffuseMap.monoOutput = 1
					displayMatdiffuseMap.alphasource = 0
					displayMat.opacityMap = displayMatdiffuseMap
				)
			)
			displayMat
		) else (
			local displayMat = undefined
			local diffuseName = ""
			local SubRectPos = undefined
			local SubRectSize = undefined
			local bumpName = ""
			local opacityName = ""
			local useMat = true

			local lineNum = 0
			local isTranslucent = false
			local selfIllum = false
			local selfIllumName = ""
			local color1
			local color2
			local nocull = false
			local displayMatdiffuseMap = undefined
			local makeNewMats = true --will be false if this was an included vmt
			local theVMT = openFile vmt mode:"r"

			if theVMT != undefined then (
				local normalmapalphaenvmapmask, normalmapalphaenvmapmask2 = false
				if addMat == undefined then (
					local addMat = Standard diffusemap:(BitmapTexture()) showInViewport:true
					wallworm_give_mat_ww addMat
				) else (
					makeNewMats = false
				)

				if overWriteName == undefined then (
					if rootPath == undefined then (
						if ::wwmt_raw_mats != undefined AND ::wwmt_raw_mats != "" AND findString vmt ::wwmt_raw_mats != 0 then (
							rootPath = ::wwmt_raw_mats
						)
					)

					if makeNewMats == true then (
						if rootPath != undefined then (
							addMat.name = substituteString vmt rootPath ""
							addMat.name = substituteString addMat.name ".vmt" ""

						) else (
							addMat.name = getFileNamePath vmt
						)
					)
				) else (
					if makeNewMats == true then (
						addMat.name = overWriteName

					)
				)
				if makeNewMats == true then (
					addMat.name = wallworm_safe_path addMat.name
					addMat.name = wallworm_remove_first_slash addMat.name
					addMat.name = wallworm_remove_last_slash addMat.name
				)
				addMat.name = wallworm_sanitize_texture_path addMat.name fs:true materialPathPrune:true

				local blendV = VertexColor()
				--local mp1 = Standard diffusemap:(BitmapTexture()) showInViewport:true
				local mp2 = Standard diffusemap:(BitmapTexture()) showInViewport:true
				local addMatB = Blend map1:addMat map2:mp2 mask:blendV showInViewport:true

				wallworm_give_mat_ww addMatB
				--wallworm_give_mat_ww mp1
				wallworm_give_mat_ww mp2

				local transforms1, transforms2

				--mask:VertexColor 
				while (useMat == true AND NOT eof theVMT) do (
					lineNum += 1

					--try (
					--fLines[lineNum] = filePos theVMT
					local theLine = readLine theVMT

					theLine = trimLeft theLine
					theLine = trimRight theLine
					theLine = substituteString theLine "\t" " "
					theLine = substituteString theLine "  " " "

					-- !TODO this whole block needs to lose all the continue commands. 
					--lines to ignore until support for these features are added (to speed gneeration up)	
					case of (
						((theLine == "" OR theLine == undefined OR ((substring theLine 1 2) == "//"))):(
							--skip
						)

						((matchPattern theLine pattern:"*LightmappedGeneric*") == true) : (
							matType = "brush"
							addMat.valveShader = "LightmappedGeneric"
						)
						((matchPattern theLine pattern:"*UnlitGeneric*") == true) : (
							matType = "brush"
							addMat.valveShader = "UnlitGeneric"
						)

						((matchPattern theLine pattern:"*DecalModulate*") == true) : (
							matType = "decal"
							addMat.valveShader = "DecalModulate"
						)

						((matchPattern theLine pattern:"*Subrect*") == true) : (
							matType = "decal"
							addMat.valveShader = "Subrect"
						)

						((matchPattern theLine pattern:"*VertexLitGeneric*") == true) :(
							matType = "model"
							addMat.forModel = true
							addMat.valveShader = "VertexLitGeneric"
						)

						((matchPattern theLine pattern:"*WorldVertexTransition*") == true): (
							matType = "blend"
							addMatB.valveShader = "WorldVertexTransition"
							addMat.valveShader = "LightMappedGeneric"
							addMatB.map2.valveShader = "LightMappedGeneric"
							addMatB.name = addMat.name
						)
						(matchPattern theLine pattern:"*%*" AND NOT matchPattern theLine pattern:"*%detailtype*"):(
							case of (
								((matchPattern theLine pattern:"*%compilehint*") == true): (
									addMat.compilehint = true
								)
								((matchPattern theLine pattern:"*%compileladder*") == true) : (
									addMat.compileladder = true
								)
								((matchPattern theLine pattern:"*%compileNoLight*") == true) : (
									addMat.compileNoLight = true
								)
								((matchPattern theLine pattern:"*%compilenpcclip*") == true) : (
									addMat.compilenpcclip = true
								)
								((matchPattern theLine pattern:"*%compileorigin*") == true) : (
									addMat.compileorigin = true
								)
								((matchPattern theLine pattern:"*%compileclip*") == true) : (
									addMat.compileclip = true
								)
								((matchPattern theLine pattern:"*%compilenodraw*") == true) : (
									addMat.compilenodraw = true
								)
								((matchPattern theLine pattern:"*%compilenonsolid*") == true) : (
									addMat.compilenonsolid = true
								)
								((matchPattern theLine pattern:"*%compilepassbullets*") == true) : (
									addMat.compilepassbullets = true
								)
								((matchPattern theLine pattern:"*%compile2Dsky*") == true) : (
									addMat.compile2Dsky = true
								)
								((matchPattern theLine pattern:"*%compileDetail*") == true) : (
									addMat.compileDetail = true
								)
								((matchPattern theLine pattern:"*%compilefog*") == true) : (
									addMat.compilefog = true
								)
								((matchPattern theLine pattern:"*%compilewater*") == true) : (
									addMat.compilewater = true
								)
								((matchPattern theLine pattern:"*%compiletrigger*") == true) : (
									addMat.compiletrigger = true
								)
								((matchPattern theLine pattern:"*%compileplayercontrolclip*") == true) : (
									addMat.compileplayercontrolclip = true
								)
								((matchPattern theLine pattern:"*%compileskip*") == true) : (
									addMat.compileskip = true
								)
								((matchPattern theLine pattern:"*%compilesky*") == true) : (
									addMat.compilesky = true
								)
								((matchPattern theLine pattern:"*%compileSlime*") == true) : (
									addMat.compileSlime = true
								)
								((matchPattern theLine pattern:"*%compileTeam*") == true) : (
									addMat.compileTeam = true
								)
							)
						)

						((matchPattern theLine pattern:"*$normalmapalphaenvmapmask2 *") == true) : (
							normalmapalphaenvmapmask2 = true
						)
						((matchPattern theLine pattern:"*$normalmapalphaenvmapmask *") == true) : (
							normalmapalphaenvmapmask = true
						)
						
						((matchPattern theLine pattern:"*$halflambert *") == true) : (
							addMat.halflambert = true
							matType = "model"
							addMat.forModel = true

						)

						((matchPattern theLine pattern:"*$FlashlightNoLambert*") == true) : (
							addMat.FlashlightNoLambert = true
							matType = "model"
							addMat.forModel = true

						)

						((matchPattern theLine pattern:"*$ignorez*") == true) : (
							addMat.ignorez = true

						)
						((matchPattern theLine pattern:"*$nofog*") == true) : (
							addMat.nofog = true

						)
						((matchPattern theLine pattern:"*$alphatest*") == true) : (
							addMat.alphatest = true

						)

						((matchPattern theLine pattern:"*$vertexcolor*") == true) : (
							if matType != "decal" then (
								matType = "model"
								addMat.forModel = true
							)
							addMat.ww_vertexcolor = true

						)
						((matchPattern theLine pattern:"*$vertexfog*") == true) : (
							--matType = "model"
							--addMat.forModel = true
							addMat.vertexfog = true

						)
						((matchPattern theLine pattern:"*$rimlight*") == true) : (
							addMat.rimlight = true
							matType = "model"
							addMat.forModel = true

						)

						((matchPattern theLine pattern:"*$rimmask*") == true) : (
							addMat.rimmask = true
							matType = "model"
							addMat.forModel = true

						)

						((matchPattern theLine pattern:"*$nocull*") == true) : (
							nocull = true
							addMat.twoSided = on

						)

						((matchPattern theLine pattern:"*$additive*") == true) : (
							addMat.opacityType = 2

						)

						((matchPattern theLine pattern:"*$writeZ*") == true) : (
							addMat.writeZ = true

						)

						((matchPattern theLine pattern:"*$ssbump2*") == true) : (
							addMatB.ssbump2 = true
							addMatB.map2.ssbump = true
						)

						((matchPattern theLine pattern:"*$ssbump*") == true) : (
							addMat.ssbump2 = true
							addMatB.ssbump = true
						)

						default:(
							--((matchPattern theLine pattern:"*$parallaxmap*") == true):()
							--((matchPattern theLine pattern:"*srgb?$basetexture*") == true):()
							--((matchPattern theLine pattern:"*$distancealpha*") == true):()		

							local lineArray = filterString theLine " "

							if lineArray.count >= 1 then (
								param = lineArray[1]
							) else (
								param = theLine
							)

							param = substituteString param "\"" ""

							if lineArray.count > 1 then (
								val = lineArray[2]

								val = substituteString val "\"" ""

								if matchPattern val pattern:"*//*" == true then (
									pos = findString val "//"
									if pos > 1 then (
										val = substring val 1 (pos - 1)
									) else (
										val = undefined
									)
								)
							) else (
								val = undefined
							)

							if val != undefined then (
								if ((matchPattern val pattern:"*$*") == false) then (
									if ((matchPattern param pattern:"*$model*") == true AND ((matchPattern param pattern:"*$modelmaterial*") == false) AND val != undefined AND ((matchPattern val pattern:"*true*") OR (matchPattern val pattern:"*1*"))) then (
										matType = "model"
										addMat.forModel = true
									)

									case of (
										/*
										skip all transforms for now ... add support later
										*/
										((matchPattern theLine pattern:"*basetexturetransform*") == true) : (
											--write function for transform
											local tr = wallworm_texture_transform()
											tr.parseString theLine
											if (matchPattern theLine pattern:"*basetexturetransform2*") == true then (
												transforms2 = tr
											) else (
												transforms1 = tr
											)
										)
										((matchPattern theLine pattern:"*include*") == true) : (
											vmtval = val

											if findString vmtval "materials/" == 1 then (
												vmtval = replace vmtval 1 10 ""

											)

											vmtval = ::wwmt_raw_mats + "/" + vmtval

											wallworm_generateMaterialFromVMT vmtval addMat:addMat matType:matType brushColor:brushColor modelColor:modelColor dispColor:dispColor dispColor2:dispColor2 extraPath:extraPath overWriteName:overWriteName rootPath:rootPath extraRootPaths:extraRootPaths

										)

										((matchPattern theLine pattern:"*$envmapsaturation*") == true) : (
											addMat.useEnvSettings = true
											if addMat.envmapsaturation != undefined AND val != undefined then (
												if lineArray.count < 3 then (
													if val as Float != undefined then (
														addMat.envmapsaturation = val as Float
													)
												) else (
													c = wallworm_get_color_from_string_arrays lineArray t:"float"
													if c != undefined then (
														addMat.envmapsaturation = c
													)
													--addMat.envmapsaturation = val as float
												)
											)

										)

										((matchPattern theLine pattern:"*$envmapcontrast*") == true) : (
											addMat.useEnvSettings = true
											if val as Float != undefined then (
												addMat.envmapcontrast = val as Float
											)
										)

										((matchPattern theLine pattern:"*$envmaptint*") == true) : (
											addMat.useEnvSettings = true
											c = wallworm_get_color_from_string_arrays lineArray t:"color"
											if c != undefined then (
												addMat.envmaptint = c
											)
										)

										((matchPattern theLine pattern:"*$rimexponent*") == true) : (
											addMat.rimlight = true
											if val != undefined AND val as Float != undefined then (
												addMat.rimexponent = val as Float
											)
											matType = "model"
											addMat.forModel = true
										)

										((matchPattern theLine pattern:"*$rimboost*") == true) : (
											addMat.rimlight = true
											if val != undefined AND val as Float != undefined then (
												addMat.rimboost = val as Float
											)
											matType = "model"
											addMat.forModel = true
										)

										((matchPattern theLine pattern:"*$maxfogdensityscalar*") == true) : (
											addMat.use_maxfogdensityscalar = true
											if val as Float != undefined then (
												maxfogdensityscalar = val as Float
											)
											matType = "model"
											addMat.forModel = true
										)

										((matchPattern theLine pattern:"*$disablecsmlookup*") == true) : (
											addMat.disablecsmlookup = true
											matType = "model"
											addMat.forModel = true
										)

										((matchPattern theLine pattern:"*$treeSway*") == true) : (
											matType = "model"
											addMat.forModel = true
											addMat.treeSway = true

											if val != undefined then (
												case of (
													((matchPattern theLine pattern:"*$treeSwayHeight*") == true) : (
														addMat.treeSwayHeight = val as Float

													)

													((matchPattern theLine pattern:"*$treeSwayStartHeight*") == true) : (
														addMat.treeSwayStartHeight = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayRadius*") == true) : (
														addMat.treeSwayRadius = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayStartRadius*") == true) : (
														addMat.treeSwayStartRadius = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwaySpeed*") == true) : (
														addMat.treeSwaySpeed = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayStrength*") == true) : (
														addMat.treeSwayStrength = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayScrumbleSpeed*") == true) : (
														addMat.treeSwayScrumbleSpeed = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayScrumbleStrength*") == true) : (
														addMat.treeSwayScrumbleStrength = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayScrumbleFrequency*") == true) : (
														addMat.treeSwayScrumbleFrequency = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayFalloffExp*") == true) : (
														addMat.treeSwayFalloffExp = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwayScrumbleFalloffExp*") == true) : (
														addMat.treeSwayScrumbleFalloffExp = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwaySpeedHighWindMultiplier*") == true) : (
														addMat.treeSwaySpeedHighWindMultiplier = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwaySpeedLerpStart*") == true) : (
														addMat.treeSwaySpeedLerpStart = val as Float

													)
													((matchPattern theLine pattern:"*$treeSwaySpeedLerpEnd*") == true) : (
														addMat.treeSwaySpeedLerpEnd = val as Float
													)
												)
											)
										)

										((matchPattern theLine pattern:"*$lightjitter*") == true) : (
											matType = "model"
											addMat.forModel = true

											addMat.detailsprite = true
											addMat.useJitter = true

											case of (
												((matchPattern theLine pattern:"*$lightjitteramount*") == true) : (
													addMat.lightjitteramount = val as Float

												)

												((matchPattern theLine pattern:"*$lightjittersin1angle*") == true) : (
													addMat.lightjittersin1angle = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin1speed*") == true) : (
													addMat.lightjittersin1speed = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin1dispersion*") == true) : (
													addMat.lightjittersin1dispersion = val as Float

												)

												((matchPattern theLine pattern:"*$lightjittersin2angle*") == true) : (
													addMat.lightjittersin2angle = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin2speed*") == true) : (
													addMat.lightjittersin2speed = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin2dispersion*") == true) : (
													addMat.lightjittersin2dispersion = val as Float

												)

												((matchPattern theLine pattern:"*$lightjittersin3angle*") == true) : (
													addMat.lightjittersin3angle = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin3speed*") == true) : (
													addMat.lightjittersin3speed = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittersin3dispersion*") == true) : (
													addMat.lightjittersin3dispersion = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittergustmultiplier*") == true) : (
													addMat.lightjittergustmultiplier = val as Float

												)
												((matchPattern theLine pattern:"*$lightjittergustspeed*") == true) : (
													addMat.lightjittergustspeed = val as Float

												)

												((matchPattern theLine pattern:"*$lightjittercolour*") == true) : (
													c = wallworm_get_color_from_string_arrays lineArray t:"color"
													if c != undefined then (
														addMat.lightjittercolour = c
													)
												)
											)
										)
										((matchPattern theLine pattern:"*$phong*") == true) : (
											addMat.shaderByName = "Phong"
											matType = "model"
											addMat.forModel = true

											case of (
												((matchPattern theLine pattern:"*$phongboost*") == true AND val as Float != undefined) : (
													addMat.phongboost = val as Float
												)
												((matchPattern theLine pattern:"*$phongfresnelranges*") == true) : (
													if lineArray.count > 3 then (
														--addMat.phongfresnelranges = (lineArray[2] + " " +  lineArray[3]+ " " +  lineArray[4])
														local frx, fry, frz
														frx = substituteString ((substituteString lineArray[2] "[" "")) "\"" "" as Float
														if frx != undefined then (
															addMat.phongfresnelranges.x = frx
															fry = lineArray[3] as Float
															if fry != undefined then (
																addMat.phongfresnelranges.y = fry
																frz = substituteString ((substituteString lineArray[4] "]" "")) "\"" "" as Float
																if frz != undefined then (
																	addMat.phongfresnelranges.z = frz
																)
															)
														)
													) else (
														/*
														addMat.phongfresnelranges = val as string
														addMat.phongfresnelranges = substituteString (addMat.phongfresnelranges) "[" ""
														addMat.phongfresnelranges = substituteString (addMat.phongfresnelranges) "]" ""
														addMat.phongfresnelranges = substituteString (addMat.phongfresnelranges) "\"" ""		*/
													)

												)
												((matchPattern param pattern:"*$phongexponenttexture*") == true) : (
													phongexponenttextureName = wallworm_getValueVMTVal val
													addMat.specularMap = BitmapTexture()
													addMat.specularMap.name = (wallworm_get_sourcematpaths phongexponenttextureName)
													local theTex = wallworm_getBitmapFromPaths phongexponenttextureName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
													tex1 = theTex[1]
													canClose = theTex[2]
													addMat.specularMap.filename = tex1
													if canClose == true then (
														close addMat.specularMap.Bitmap
													)
												)
												default: (
													if ((matchPattern theLine pattern:"*$phongexponent*") == true AND (matchPattern theLine pattern:"*$phongexponenttexture*") == false AND val as Float != undefined) then (
														addMat.phongexponent = val as Float
													)
												)
											)
										)

										((matchPattern theLine pattern:"*$reflectivity*") == true) : (
											addMat.useReflectivity = true

											c = wallworm_get_color_from_string_arrays lineArray t:"color"
											if c != undefined then (
												addMat.reflectivity = c
											)
										)

										((matchPattern theLine pattern:"*$detailscale*") == true) : (
											addMat.usedetailscale = true
											if (val as Float) != undefined then (
												addMat.detailscale = val as Float
											)

										)

										((matchPattern theLine pattern:"*$detailblendfactor*") == true) : (
											addMat.useadvanceddetail = true
											if (val as Float) != undefined then (
												addMat.detailblendfactor = val as Float
											)

										)

										((matchPattern theLine pattern:"*$detailblendmode*") == true) : (
											addMat.useadvanceddetail = true
											if (val as Float) != undefined then (
												addMat.detailblendmode = val as Float
											)

										)

										((matchPattern theLine pattern:"*$detailtint*") == true) : (
											addMat.useadvanceddetail = true

											c = wallworm_get_color_from_string_arrays lineArray
											if c != undefined then (
												--print c
												addMat.detailtint = c
											)
										)

										((matchPattern theLine pattern:"*$seamless_scale*") == true) : (
											addMatB.use_seamless_scale = true
											if (val as Integer) != undefined then (
												addMatB.seamless_scale = val as Integer
											)

										)

										((matchPattern theLine pattern:"*%keywords*") == true) : (
											local kwvars = filterString val ","
											addMat.keywords = kwvars

										)

										((matchPattern theLine pattern:"*$decal*") == true) : (
											addMatB.decal = true
											addMat.decal = true
											matType = "decal"
											case of (
												((matchPattern theLine pattern:"*$decalscale*") == true) : (
													if (val as Float) != undefined then (
														addMat.decalscale = val as Float
														addMatB.decalscale = val as Float
													)

												)

												((matchPattern theLine pattern:"*$decalfadeduration*") == true) : (
													if (val as Float) != undefined then (
														addMat.decalfadeduration = val as Float
														addMatB.decalfadeduration = val as Float
													)

												)
												((matchPattern theLine pattern:"*$decalfadetime*") == true) : (
													if (val as Float) != undefined then (
														addMat.decalfadetime = val as Float
														addMatB.decalfadetime = val as Float
													)

												)
												default:()
											)
										)

										((matchPattern theLine pattern:"*$modelmaterial*") == true) : (
											addMat.modelmaterial = val
											addMatB.modelmaterial = val
										)

										((matchPattern theLine pattern:"*$material*") == true AND addMat.valveShader == "Subrect"): (
											diffuseName = wallworm_getValueVMTVal val
											local theTex = wallworm_getBitmapFromPaths diffuseName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
											tex1 = theTex[1]
											canClose = theTex[2]
											if addMat != undefined then (
												addMat.diffusemap.filename = tex1
												addMat.diffusemap.name = wallworm_get_sourcematpaths diffuseName
												displayMatdiffuseMap = addMat.diffusemap
											)
										)

										((matchPattern theLine pattern:"*$Pos*") == true AND addMat.valveShader == "Subrect"): (
											SubRectPos = [((substituteString lineArray[2] "\"" "") as Float), ((substituteString lineArray[3] "\"" "") as Float)]
										)
										((matchPattern theLine pattern:"*$Size*") == true AND addMat.valveShader == "Subrect"): (
											SubRectSize = [((substituteString lineArray[2] "\"" "") as Float), ((substituteString lineArray[3] "\"" "") as Float)]
										)
										((matchPattern theLine pattern:"*$fogscale*") == true) : (
											if (val as Float) != undefined then (
												addMat.fogscale = val as Float
												addMatB.fogscale = val as Float
											)

										)

										((matchPattern theLine pattern:"*$rimexponent*") == true) : (
											addMat.rimexponent = val as Float
											addMatB.rimexponent = val as Float

										)
										((matchPattern theLine pattern:"*$rimboost*") == true) : (
											addMat.rimboost = val as Float
											addMatB.rimboost = val as Float
										)

										((matchPattern param pattern:"*$color2*") == true AND lineArray.count >= 4) : (
											c = wallworm_get_color_from_string_arrays lineArray t:"color"
											if c != undefined then (
												color2 = c
											)
										)

										((matchPattern param pattern:"*$color*") == true AND lineArray.count >= 4) : (
											c = wallworm_get_color_from_string_arrays lineArray t:"color"
											if c != undefined then (
												color1 = c
											)
										)
										((matchPattern param pattern:"*$baseTexture2*") == true AND val != "") : (
											addMatB.map2.name = val
											dName = wallworm_getValueVMTVal val

											local theTex = wallworm_getBitmapFromPaths dName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
											tex2 = theTex[1]
											canClose = theTex[2]

											addMatB.map2.diffusemap.filename = tex2

											addMatB.map2.diffusemap.name = wallworm_get_sourcematpaths dName

											if canClose == true then (
												close addMatB.map2.diffusemap.Bitmap
											)

										)

										(((matchPattern param pattern:"*$baseTexture*") == true) AND val != "") : (
											if matType == "blend" then (
												addMat.name = val
											)
											diffuseName = wallworm_getValueVMTVal val
											local theTex = wallworm_getBitmapFromPaths diffuseName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
											tex1 = theTex[1]
											canClose = theTex[2]
											if addMat != undefined then (
												if ::wwmt_legacy_names == true AND matType == "model" then (
													addMat.name = diffuseName
												)
												addMat.diffusemap.filename = tex1
												addMat.diffusemap.name = wallworm_get_sourcematpaths diffuseName
												if canClose == true then (
													close addMat.diffusemap.Bitmap
												)
											)
										)

										((matchPattern param pattern:"*$blendmodulatetexture*") == true) : (
											if  val != "" then (
												dName = wallworm_getValueVMTVal val
												local theTex = wallworm_getBitmapFromPaths dName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex2 = theTex[1]
												canClose = theTex[2]
												addMatB.mask = BitmapTexture()
												addMatB.mask.name = wallworm_get_sourcematpaths dName
												addMatB.mask.filename = tex2
												if canClose == true then (
													close addMatB.mask.Bitmap
												)												
											)

										)

										((matchPattern param pattern:"*$AmbientOcclTexture*") == true): (
											if  val != "" then (
												ambientocclusionName = wallworm_getValueVMTVal val
												addMat.ambientMap = BitmapTexture()
												addMat.ambientMap.name = (wallworm_get_sourcematpaths ambientocclusionName)
												local theTex = wallworm_getBitmapFromPaths ambientocclusionName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]
												addMat.ambientMap.filename = tex1
												if canClose == true then (
													close addMat.ambientMap.Bitmap
												)												
											)

										)
										((matchPattern param pattern:"*$bumpmap2*") == true ):(
											if  val != "" then (
												bumpName = wallworm_getValueVMTVal val
												addMatB.map2.bumpmap = BitmapTexture()
												addMatB.map2.bumpmap.name = (wallworm_get_sourcematpaths bumpName)

												local theTex = wallworm_getBitmapFromPaths bumpName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												
												tex1 = theTex[1]
												canClose = theTex[2]

												addMatB.map2.bumpmap.filename = tex1
												if canClose == true then (
													close addMatB.map2.bumpmap.Bitmap
												)												
											)

										)
										((matchPattern param pattern:"*$bumpmap*") == true): (
											if  val != "" then (
												bumpName = wallworm_getValueVMTVal val
												--print diffuseName

												addMat.bumpmap = BitmapTexture()
												addMat.bumpmap.name = (wallworm_get_sourcematpaths bumpName)

												local theTex = wallworm_getBitmapFromPaths bumpName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]

												addMat.bumpmap.filename = tex1
												if canClose == true then (
													close addMat.bumpmap.Bitmap
												)												
											)
										)
										((matchPattern param pattern:"*$lightwarptexture2*") == true): (
											if  val != "" then (
												bumpName = wallworm_getValueVMTVal val

												addMatB.map2.lightwarptexture = BitmapTexture()
												addMatB.map2.lightwarptexture.name = (wallworm_get_sourcematpaths bumpName)

												local theTex = wallworm_getBitmapFromPaths bumpName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]

												addMatB.map2.lightwarptexture.filename = tex1
												if canClose == true then (
													close addMatB.map2.lightwarptexture.Bitmap
												)												
											)
										)
										((matchPattern param pattern:"*$lightwarptexture*") == true) : (
											if  val != "" then (
												bumpName = wallworm_getValueVMTVal val
												addMat.lightwarptexture = BitmapTexture()
												addMat.lightwarptexture.name = (wallworm_get_sourcematpaths bumpName)
												local theTex = wallworm_getBitmapFromPaths bumpName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]
												addMat.lightwarptexture.filename = tex1
												if canClose == true then (
													close addMat.lightwarptexture.Bitmap
												)												
											)
										)

										((matchPattern param pattern:"*$selfillumtexture2*") == true): (
											if  val != "" then (
												selfIllumName = wallworm_getValueVMTVal val
												addMatB.map2.selfIllumMap = BitmapTexture()
												addMatB.map2.selfIllumMap.name = (wallworm_get_sourcematpaths selfIllumName)
												local theTex = wallworm_getBitmapFromPaths selfIllumName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]
												addMatB.map2.selfIllumMap.filename = tex1
												if canClose == true then (
													close addMatB.map2.selfIllumMap.Bitmap
												)												
											)
										)

										((matchPattern param pattern:"*$selfillumtexture*") == true AND addMat != undefined): (
											if  val != "" then (
												selfIllumName = wallworm_getValueVMTVal val
												--print diffuseName
												addMat.selfIllumMap = BitmapTexture()
												addMat.selfIllumMap.name = (wallworm_get_sourcematpaths selfIllumName)
												local theTex = wallworm_getBitmapFromPaths selfIllumName extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]
												addMat.selfIllumMap.filename = tex1
												if canClose == true then (
													close addMat.selfIllumMap.Bitmap
												)												
											)
										)

										((matchPattern param pattern:"*$envmapmask2*") == true): (
											if  val != "" then (
												envmapmask = wallworm_getValueVMTVal val
												addMatB.map2.specularLevelMap = BitmapTexture()
												addMatB.map2.specularLevelMap.name = (wallworm_get_sourcematpaths envmapmask)
												local theTex = wallworm_getBitmapFromPaths envmapmask extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]

												addMatB.map2.specularLevelMap.filename = tex1
												if canClose == true then (
													close addMatB.map2.specularLevelMap.Bitmap
												)												
											)
										)
										((matchPattern param pattern:"*$envmapmask*") == true): (
											if  val != "" then (
												envmapmask = wallworm_getValueVMTVal val
												addMat.specularLevelMap = BitmapTexture()
												addMat.specularLevelMap.name = (wallworm_get_sourcematpaths envmapmask)
												local theTex = wallworm_getBitmapFromPaths envmapmask extraPath:extraPath extraRootPaths:extraRootPaths collecting:false
												tex1 = theTex[1]
												canClose = theTex[2]

												addMat.specularLevelMap.filename = tex1
												if canClose == true then (
													close addMat.specularLevelMap.Bitmap
												)												
											)
										)

										default:(
											if (matchPattern theLine pattern:"*$translucent*") == true then (
												addMat.opacityMap = addMat.diffusemap
												isTranslucent = true
												addMat.diffusemap.monoOutput = 1
												addMat.diffusemap.alphasource = 0
											)

											if (matchPattern theLine pattern:"*$selfillum*") == true then (
												selfIllum = true
											)
											case param of (
												"$surfaceprop":(
													if addMat != undefined then (
														addMat.surfaceproperty = val
													)
													if addMatB != undefined then (
														addMatB.surfaceproperty = val
													)

												)
												"$alpha":(
													if val != undefined then (
														op = (val as Integer)
														if op != undefined then (
															addMat.opacity = (op) * 100
														)
													)
												)

												"%detailtype":(
													addMat.detail = val
													addMatB.detail = val

												)

												"$surfaceprop2":(
													addMatB.map2.surfaceproperty = val
													addMatB.surfaceproperty2 = val

												)
												"$alpha2":(
													if val != undefined then (
														op = (val as Integer)
														if op != undefined then (
															addMatB.map2.opacity = (op) * 100
														)
													)

												)
												default:()
											)
										)
									)
								)
							)
						)
					)
				)
				if theVMT != undefined then (
					close theVMT
				)

				--addMatB.map1 = addMat

				if useMat == true then (
					if (addMat.forModel == true) then (
						--get the cdmaterials from the file path starting from materials/
						addMat.cdmaterials = wallworm_bstofs (getFileNamePath addMat.name)

					)

					if addMat.detailsprite == true OR addMat.alphatest == true then (
						addMat.opacityMap = addMat.diffuseMap
						addMat.opacityMap.monoOutput = 1

					)

					if addMatB != undefined then (
						displayMatnameB = addMatB.name
					)

					if addMat != undefined then (
						--displayMatname = ((count as string)+" "+addMat.name)
						displayMatname = addMat.name
						addMat.name = addMat.name -- + " render"

					)

					if transforms1 != undefined then (
						local d = addMat.diffusemap
						if d != undefined then (
							local coords = d.coords
							transforms1.setTextureTransforms coords
							wallworm_reuse_diifuse_transform addMat
						)
					)

					if transforms2 != undefined AND addMatB.map2 != undefined then (
						local d = addMatB.map2.diffusemap
						if d != undefined then (
							local coords = d.coords
							transforms2.setTextureTransforms coords
							wallworm_reuse_diifuse_transform addMatB.map2
						)
					)


					if normalmapalphaenvmapmask == true AND addMat.bumpmap != undefined then (
						local cp =copy addMat.bumpmap
						cp.name = addMat.bumpmap.name
						cp.monoOutput = cp.rgbOutput = 1
						addMat.specularLevelMap = cp
					)

					if matType == "blend" then (
						
						if normalmapalphaenvmapmask2 == true AND addMatB.map2.bumpmap != undefined then (
							local cp =copy addMatB.map2.bumpmap
							cp.name = addMatB.map2.bumpmap.name
							cp.monoOutput = cp.rgbOutput = 1
							addMatB.map2.specularLevelMap = cp
						)
						/*
						!!TODO swap the order of map1 & 2
						*/
						if color1 != undefined then (
							addMatB.map1.diffuse = color1
							addMatB.map1.ambient = color1

						) else (
							--addMatB.map1.diffuse = dispColor
						)

						if color2 != undefined then (
							addMatB.map2.diffuse = color2
							addMatB.map2.ambient = color2
						) else (
							addMatB.map2.diffuse = dispColor2
						)

						/*oldm1 = addMatB.map1
						oldm2 = addMatB.map2
						addMatB.map1 = oldm1*/

						addMatB.map1 = addMatB.map2 
						addMatB.map2 = addMat
						--addMatB.map1 = addMat
						displayMat = wallworm_blend_to_DXBlend mat:addMatB --rev:false

						--addMatB.name = displayMatnameB
						displayMat.name = displayMatnameB
						wallwormAddTextureCAtoMaterial addMatB
					) else (
						if color1 != undefined then (
							if matType != "model" then (
								addMat.diffuse = color1
								addMat.ambient = color1
							)
						) else (
							case matType of (
								"model":(
									addMat.diffuse = modelColor
									addMat.ambient = modelColor
								)
								"brush":(
									addMat.diffuse = brushColor
									addMat.ambient = brushColor
								)
								"decal":(
									addMat.diffuse = decalColor
									addMat.ambient = decalColor
								)
								"blend":(
									addMat.diffuse = dispColor
									addMat.ambient = dispColor
								)
								default:()
							)

						)

						if color2 != undefined then (
							if matType == "model" then (
								addMat.diffuse = color2
								addMat.ambient = color2

							)
						) else (
							case matType of (
								"model":(
									addMat.diffuse = modelColor
									addMat.ambient = modelColor
								)
								"brush":(
									addMat.diffuse = brushColor
									addMat.ambient = brushColor
								)
								"decal":(
									addMat.diffuse = decalColor
									addMat.ambient = decalColor
								)
								"blend":(
									addMat.diffuse = dispColor
									addMat.ambient = dispColor
								)
								default:()
							)
						)
						displayMat = addMat

						if SubRectPos != undefined AND SubRectSize != undefined AND classOf displayMatdiffuseMap == BitmapTexture AND doesFileExist displayMatdiffuseMap.filename then (
							local displayMatdiffuseMapBM = displayMatdiffuseMap.Bitmap
							if displayMatdiffuseMapBM != undefined then (
								local bmWidth = displayMatdiffuseMapBM.width as Float
								local bmHeight = displayMatdiffuseMapBM.height as Float
								displayMatdiffuseMap.apply = true
								displayMatdiffuseMap.cropPlace = 0
								displayMatdiffuseMap.clipu = (SubRectPos.x as Float) / bmWidth
								displayMatdiffuseMap.clipv = (SubRectPos.y as Float) / bmHeight
								displayMatdiffuseMap.clipw = (SubRectSize.x as Float) / bmWidth
								displayMatdiffuseMap.cliph = (SubRectSize.y as Float) / bmHeight
							)
						)
						displayMat.name = displayMatname
						wallwormAddTextureCAtoMaterial displayMat
					)
				)
				if isProperty displayMat #decal AND (displayMat.decal == true OR isTranslucent == true) AND displayMat.opacityMap == undefined AND displayMat.diffusemap != undefined then (
					displayMatdiffuseMap = displayMat.diffuseMap
					displayMatdiffuseMap.monoOutput = 1
					displayMatdiffuseMap.alphasource = 0
					displayMat.opacityMap = displayMatdiffuseMap
				)
				displayMat
			)
		)
		setSilentMode oldSIlentMode
		displayMat
	)

)

function wallworm_getLibraryFromMatName matname debug:false = (
	local lib = undefined
	matname = wallworm_remove_last_slash matname
	if ::wallworm_debug == true then (
		debug = true
	)
	if debug == true then (
		print ("Looking for this material: " + matname)
	)
	libpath = filterString matname "/" splitEmptyTokens:false
	if debug == true then (
		print ("Material broken into this: " + libpath as String)
	)
	if libpath.count > 1 then (
		local matlib = ((trimLeft (trimRight libpath[1])) + ".mat")
		if debug == true then (
			print matlib
		)
		if doesFileExist matlib == true then (
			lib = loadMaterialLibrary matlib
		)
	)

	lib
)

function wallworm_VMFIMPORT_getExistingMaterial matName mats:materials openLib:false = (
	local theMat = undefined
	--look in the existing mats array probably generated by script
	if mats != undefined then (
		for m in mats while theMat == undefined do (
			if m.name == matName then (
				theMat = m
			)
		)
	)

	--look in the existing scene mats
	if theMat == undefined AND sceneMaterials.count > 0 then (
		m = sceneMaterials[matName]
		if m != undefined then (
			theMat = m

		)
	)
	--look in the current material library
	if theMat == undefined AND currentMaterialLibrary.count > 0 then (
		m = currentMaterialLibrary[matName]
		if m != undefined then (
			theMat = m
		)
	)
	--optionally, open a material library that matches the root path of the material name. Assumes a library is named from root directories
	if theMat == undefined AND openLib == true then (
		lib = wallworm_getLibraryFromMatName matName

		if lib != undefined AND lib != false then (
			if currentMaterialLibrary.count > 0 then (
				m = currentMaterialLibrary[matName]
				if m != undefined then (
					theMat = m

				)
			)

		)
	)

	theMat
)

function wallworm_VMFIMPORT_createMaterial matName openLib:false Color:undefined matType:"brush" extraPath:undefined extraRootPaths:undefined = (
	local vmt = wallworm_getVMTFromPaths matName extraPath:extraPath extraRootPaths:extraRootPaths
	local newMat
	if vmt != undefined then (
		newMat = (wallworm_generateMaterialFromVMT vmt matType:matType overWriteName:matName extraPath:extraPath extraRootPaths:extraRootPaths)
	) else (
		newMat = Standard()
		newMat.name = matName
		if Color != undefined then (
			newMat.diffuse = Color
		)
	)
	newMat
)

function wallworm_VMFIMPORT_getMaterial matName mats:materials Color:undefined openLib:false matType:undefined extraPath:undefined extraRootPaths:undefined = (
	local mat = wallworm_VMFIMPORT_getExistingMaterial matName mats:materials openLib:openLib matType:matType extraPath:extraPath extraRootPaths:extraRootPaths

	if mat == undefined AND extraRootPaths != undefined AND extraRootPaths.count > 0 then (
		for p in extraRootPaths while mat == undefined do (
			if p != undefined then (
				local pn = (p + "/" + matName)
				mat = wallworm_VMFIMPORT_getExistingMaterial pn mats:materials openLib:openLib matType:matType
			)
		)
	)

	if mat == undefined then (
		mat = wallworm_VMFIMPORT_createMaterial matName Color:Color matType:matType extraPath:extraPath extraRootPaths:extraRootPaths

	)
	mat

)

function wallworm_update_material_from_vmt mat matType:undefined extraPath:undefined extraRootPaths:undefined Color:undefined = (
	if mat != undefined then (
		newmat = wallworm_VMFIMPORT_createMaterial mat.name Color:Color matType:matType extraPath:extraPath extraRootPaths:extraRootPaths
		if newmat != undefined then (
			if classOf mat == DirectX_9_Shader AND mat.renderMaterial != undefined AND classOf newmat == DirectX_9_Shader AND newmat.renderMaterial != undefined then (
				index = wallworm_get_ca_index_by_name newmat.renderMaterial "Wallworm Material"
				if index != undefined then (
					wallworm_copy_ca index newmat.renderMaterial mat.renderMaterial
					--format "copying % to %\n" newmat mat
				)
			) else (
				index = wallworm_get_ca_index_by_name newmat "Wallworm Material"
				--format "Root % to %\n" newmat mat
				wallworm_copy_ca index newmat mat
			)
		) else (
			--print "vmt not loaded"
		)
	)

)

function wallworm_reload_world_materials = (
	max create mode
	with redraw off
	undo off (
		local mats = for m in scenematerials WHERE (isProperty m #wallworm AND m.forModel == false) OR (classOf m == DirectX_9_Shader) collect m
		for m in mats do (
			local matName = m.name
			vmt = wallworm_getVMTFromPaths matName
			if vmt != undefined then (
				newMat = (wallworm_generateMaterialFromVMT vmt overWriteName:(matName))
				if newMat != undefined then (
					local objs = for obj in objects WHERE obj.mat == m collect obj
					for obj in objs do (
						obj.mat = newMat
					)
				)
			)
		)
	)
)

function wallworm_import_wad wadfiles baseDir:::wwmt_raw_mats quiet:false = (
	local out = StringStream ""
	format "cd \"%\"\n" ::wwmt_binDir to:out
	wadfiles = makeUniqueArray wadfiles
	local baseDirOut = getFilenamePath baseDir
	local quietstr = ""
	if quiet then (
		quietstr = " -Quiet"
	)
	for wad in wadfiles do (
		format "xwad.exe  -BaseDir % -WadFile \"%\"%\n" baseDirOut wad quietstr to:out
	)
	out as String
)

function wallworm_ importWads originalWadFiles skipExisting:true runWadImport:true filename:undefined quiet:false = (
	local wadx
	local wadimporturl
	local wadTemp = #()
	for w in originalWadFiles do (
		local wfmatdir = getFilenameFile w
		if skipExisting == false OR NOT doesFileExist (::wwmt_raw_mats + "/" + wfmatdir) then (
			local hasFound = false
			if doesFileExist w then (
				append wadTemp w
			) else (
				local wf = filenameFromPath w
				local paths = #((getFileNamePath filename), ::wwmt_gameInfoDir, ((::wwmt_raw_mats + "/wads")))
				for p in paths while hasFound == false do (
					local thisTest = p + "/" + wf
					if doesFileExist thisTest then (
						append wadTemp thisTest
						hasFound = true
					)
				)
			)
		)
	)
	if wadTemp.count > 0 then (
		wadx = wallworm_import_wad wadTemp quiet:quiet
		if filename == undefined OR NOT isDirectoryWriteable (getFileNamePath filename) then (
			if NOT doesFileExist "$userscripts/WallWorm.com/temp" then (
				MakeDir "$userscripts/WallWorm.com/temp" all:true
			)
			filename = "$userscripts/WallWorm.com/temp/wadimport" + (timestamp() as String) + ".map"
		)
		wadimporturl = (getFileNamePath filename) + "/" + (getFileNameFile filename) + "_wadimport.bat"

		local wadbat
		if doesFileExist wadimporturl then (
			wadbat = openFile wadimporturl mode:"w+"
		) else (
			wadbat = createFile wadimporturl
		)
		format wadx to:wadbat
		close wadbat
		if runWadImport == true then (
			shellLaunch wadimporturl ""
		)

	)
	(#(wadTemp, wadx, wadimporturl))
)

function wallworm_getwadsfrommap map skipExisting:true runWadImport:true = (
	local res
	if doesFileExist map then (
		local foundWad = false
		mapfile = openFile map mode:"rt"
		while NOT eof mapfile AND foundWad == false do (
			local theLine = readLine mapfile
			local trimmedLine = trimLeft (trimRight theLine)
			if foundwad == false AND matchPattern trimmedLine pattern:"*wad*" == true then (
				strs = filterString trimmedLine "\""
				if strs.count > 2 then (
					originalWadFiles = filterString strs[3] ";"
					res = wallworm_ importWads originalWadFiles skipExisting:skipExisting runWadImport:runWadImport filename:map
					foundwad = true
				)
			)
		)
		close mapfile
	)
	res
)
