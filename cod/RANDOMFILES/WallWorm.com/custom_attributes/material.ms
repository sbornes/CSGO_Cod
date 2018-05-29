global wallworm_materialDX_CA = attributes "Wallworm Material DX" version:4 (
	local thisNode
	function getNode refresh:false = (
		if thisNode == undefined OR refresh == true then (
			thisNode = custAttributes.getOwner this
		)
		thisNode
	)
	function isValidMat = (
		getNode()
		-1
		if classOf thisNode == DirectX_9_Shader AND thisNode.effectFilename != undefined then (
			case (toLower (getFilenameFile thisNode.effectFilename)) of (
				"worldvertextransition":(
					4
				)
				"standardfx11":(
					1
				)
				"blend_dxsas11_nitrous":(
					2
				)
				"blend_dxsas":(
					3
				)
				default:(
					0
				)
			)
		)
	)
	function updateMyName = (
		if (isValidMat()) > 0 then (
			if thisNode.renderMaterial != undefined then (
				local canGetName = ::wallworm_getMaterialName != undefined
				if NOT canGetName then (
					canGetName = macros.run "wallworm.com" "WallWormInitialize"
				)
				if canGetName then (
					thisNode.name = wallworm_getMaterialName thisNode.renderMaterial
				)
			)
		)
	)

	function swapTex = (
		getNode()
		false
		local dxtype = isValidMat()
		if dxtype > 0 then (
			local bm1, bm2, ub1,ub2,ue1,ue2
			case (dxtype) of (
				1:(
					bm1 = thisNode.g_topTexture
					bm2 = thisNode.g_bottomTexture
					thisNode.g_topTexture = bm2
					thisNode.g_bottomTexture = bm1
					true
				)
				2:(
					bm1 = thisNode.TextureTop
					bm2 = thisNode.TextureBottom
					thisNode.TextureTop = bm2
					thisNode.TextureBottom = bm1
					true
				)
				3:(
					bm1 = thisNode.geteffectbitmap 1
					bm2 = thisNode.geteffectbitmap 2
					thisNode.seteffectbitmap 1 bm2
					thisNode.seteffectbitmap 2 bm1
					true
				)
				4:(
					bm1 = thisNode.basetexture
					bm2 = thisNode.basetexture2
				
					thisNode.basetexture = bm2
					thisNode.basetexture2 = bm1
				
					bm1 = thisNode.bumpmap
					bm2 = thisNode.bumpmap2
				
					if bm2 != undefined then (
						thisNode.bumpmap = bm2
					)
					if bm1 != undefined then (
						thisNode.bumpmap2 = bm1
					)
					
					ub1 = thisNode.usebump
					ub2 = thisNode.usebump2
					thisNode.usebump = ub2
					thisNode.usebump2 = ub1
				
					bm1 = thisNode.envmapmask
					bm2 = thisNode.envmapmask2
					if bm2 != undefined then (
						thisNode.envmapmask = bm2
					)
					if bm1 != undefined then (
						thisNode.envmapmask2 = bm1
					)
					ue1 = thisNode.envmapuseAlpha
					ue2 = thisNode.envmapuseAlpha2
					thisNode.usebump = ue2
					thisNode.usebump2 = ue1
				
					true
				)
				default:(
					false
				)
			)
		)
	)

	function getRenderMaterial = (
		getNode()
		false
		local rMat
		local dxtype = isValidMat()
		if dxtype > 0 then (
			local rMat = thisNode.renderMaterial
			if classOf rMat != Blend then (
				rMat = undefined
			)
		)
		rMat
	)

	function updateRenderMatFromThis rev:false fixNames:false = (
		local response = 0 --if this is always 0, then there is not a blend material in the render material slot
		local rMat = getRenderMaterial()
		if rMat != undefined then (
			if fixNames then (
				updateMyName()
			)
			local dxtype = isValidMat()
			if dxtype > 0 then (
				local bm1, bm2
				case (dxtype) of (
					1:(
						bm1 = thisNode.g_topTexture
						bm2 = thisNode.g_bottomTexture
					)
					2:(
						bm1 = thisNode.TextureTop
						bm2 = thisNode.TextureBottom

					)
					3:(
						bm1 = thisNode.geteffectbitmap 1
						bm2 = thisNode.geteffectbitmap 2

					)
					4:(
						bm1 = thisNode.basetexture
						bm2 = thisNode.basetexture2

					)
					default:(
					)
				)
				--see if the materials in rMat match textures in diffuse
				local rMat1 = rMat.map1
				local rMat2 = rMat.map2
				if classOf rMat1 == Standard AND classOf rMat2 == Standard then (
					local mp1 = rMat1.diffuseMap
					local mp2 = rMat2.diffuseMap
					if classOf mp1 == BitmapTexture AND classOf mp2 == BitmapTexture AND classOf bm1 == Bitmap AND classOf bm2 == Bitmap then (
						if rev == true then (
							if (pathConfig.pathsResolveEquivalent mp1.filename bm1.filename) AND (pathConfig.pathsResolveEquivalent mp2.filename bm2.filename) then (
								rMat.map1 = rMat2
								rMat.map2 = rMat1
								response = 5 --materials were swapped
							) else (
								response = 4 --not necessary
							)
						) else (
							if (pathConfig.pathsResolveEquivalent mp1.filename bm2.filename) AND (pathConfig.pathsResolveEquivalent mp2.filename bm1.filename) then (
								rMat.map1 = rMat2
								rMat.map2 = rMat1
								response = 5 --materials were swapped
							) else (
								response = 4 --not necessary
							)
						)

					) else (
						response = 3 --one or both of the diffuse textures was not a bitmap
					)
				) else (
					response = 2 -- one or both of the blend materials was not a standard material
				)
			) else (
				response = 1 --this isn't a valid dx shader
			)
		)
		response
	)
	function updateThisFromRenderMat rev:false = (
		local response = 0 --if this is always 0, then there is not a blend material in the render material slot
		local rMat = getRenderMaterial()
		if rMat != undefined then (
			local dxtype = isValidMat()
			if dxtype > 0 then (
				local bm1, bm2

				--see if the materials in rMat match textures in diffuse
				local rMat1 = rMat.map1
				local rMat2 = rMat.map2
				if classOf rMat1 == Standard AND classOf rMat2 == Standard then (
					local mp1 = rMat1.diffuseMap
					local mp2 = rMat2.diffuseMap
					if classOf mp1 == BitmapTexture AND classOf mp2 == BitmapTexture then (
						bm1 = mp1.Bitmap
						bm2 = mp2.Bitmap
						case (dxtype) of (
							1:(
								thisNode.g_AlphaVertex = on
								thisNode.g_TopDiffuseEnable = on
								thisNode.g_BottomDiffuseEnable = on
								thisNode.g_SpecularEnable = on
								thisNode.n = 0
								if rev == true then (
									thisNode.g_topTexture = bm1
									thisNode.g_bottomTexture = bm2
								) else (
									thisNode.g_topTexture = bm2
									thisNode.g_bottomTexture = bm1
								)
							)
							2:(
								if rev == false then (
									thisNode.TextureTop = bm1
									thisNode.TextureBottom = bm2
								) else (
									thisNode.TextureTop = bm2
									thisNode.TextureBottom = bm1
								)
							)
							3:(
								if rev == false then (
									thisNode.seteffectbitmap 1 bm1
									thisNode.seteffectbitmap 2 bm2
								) else (
									thisNode.seteffectbitmap 1 bm2
									thisNode.seteffectbitmap 2 bm1
								)
							)
							4:(
								if rev == false then (
									thisNode.basetexture = bm1
									thisNode.basetexture2 = bm2
								) else (
									thisNode.basetexture = bm2
									thisNode.basetexture2 = bm1
								)
								
								local mp1 = rMat1.normalMap
								local mp2 = rMat2.normalMap
								if classOf mp1 == BitmapTexture AND classOf mp2 == BitmapTexture then (
									bm1 = mp1.Bitmap
									bm2 = mp2.Bitmap
								)
								if rev == false then (
									thisNode.bumpmap = bm1
									thisNode.bumpmap2 = bm2
								) else (
									thisNode.bumpmap = bm2
									thisNode.bumpmap2 = bm1
								)
								
								local mp1 = rMat1.specularLevelMap
								local mp2 = rMat2.specularLevelMap
								if classOf mp1 == BitmapTexture  then (
									bm1 = mp1.Bitmap
								) else (
									bm1 = undefined
								)

								if classOf mp2 == BitmapTexture then (
									bm2 = mp2.Bitmap
								) else (
									bm2 = undefined
								)
								
								if rev == false then (
									thisNode.envmapmask = bm1
									thisNode.envmapmask2 = bm2
								) else (
									thisNode.envmapmask = bm2
									thisNode.envmapmask2 = bm1
								)
							)
							default:(
							)
						)
					) else (
						response = 3 --one or both of the diffuse textures was not a bitmap
					)
				) else (
					response = 2 -- one or both of the blend materials was not a standard material
				)
			) else (
				response = 1 --this isn't a valid dx shader
			)
		)
		response

	)

	function getNodesUsingThis = (
		getNode()
		if thisNode != undefined then (
			(for obj in objects WHERE obj.mat == thisNode collect obj) --!TODO: this doesn't account for multimaterials
		) else (#())
	)

	rollout wwdxrollout "Wall Worm Functions" (
		Button btnSwapDisplay "Swap Display Textures"
		on btnSwapDisplay pressed do (
			swapTex()
		)

		Button btnUpdateRenderTex "Updated Render Material"

		on btnUpdateRenderTex pressed do (
			updateRenderMatFromThis rev:false
		)

		on btnUpdateRenderTex rightCLick do (
			updateRenderMatFromThis rev:true
		)

		Button btnUpdateFromRender "Update From Render Material" tooltip:"Click to update the render material order. Right click to use the reverse method."
		on btnUpdateFromRender pressed do (
			updateThisFromRenderMat rev:false
		)

		on btnUpdateFromRender rightClick do (
			updateThisFromRenderMat rev:true
		)

		Button btnUpdateName "Update Name from Render Material" tooltip:"Force this material name to match the render material name. The VMF Exporter uses the DX material name."
		on btnUpdateName pressed do (
			updateMyName()
		)

		Group "Scene" (
			Button btnSelectInScene "Select Objects Using"
			on btnSelectInScene pressed do (
				local nds = getNodesUsingThis()
				if nds.count > 0 then (
					select nds
				) else (
					messageBox "No usage in scene."
				)
			)

		)
	)

)

global wallworm_material_CA = attributes "Wallworm Material" version:30 (
	local wallworm = true
	local surfaceproplist = #("", "Metal_Box", "Plastic_Box", "Wood_Box", "Wood_Crate", "Wood_Furniture", "Wood_Panel", "Wood_Plank", "Wood_Solid", "Wood_lowdensity", "alienflesh", "antlion", "antlionsand", "armorflesh", "asphalt", "baserock", "bloodyflesh", "boulder", "brakingrubbertire", "brick", "canister", "cardboard", "carpet", "ceiling_tile", "chain", "chainlink", "combine_glass", "combine_metal", "computer", "concrete", "concrete_block", "crowbar", "default", "default_silent", "dirt", "flesh", "floating_metal_barrel", "floatingstandable", "foliage", "glass", "glassbottle", "grass", "gravel", "grenade", "gunship", "ice", "item", "jeeptire", "ladder", "metal", "metal_barrel", "metal_bouncy", "metal_seafloorcar", "metalgrate", "metalpanel", "metalvehicle", "metalvent", "mud", "no_decal", "paintcan", "paper", "papercup", "plaster", "plastic", "plastic_barrel", "plastic_barrel_buoyant", "player", "player_control_clip", "popcan", "pottery", "quicksand", "rock", "roller", "rubber", "rubbertire", "sand", "slidingrubbertire", "slidingrubbertire_front", "slidingrubbertire_rear", "slime", "slipperymetal", "slipperyslime", "snow", "solidmetal", "strider", "tile", "wade", "water", "watermelon", "weapon", "wood", "zombieflesh")
	local detaillist = #("", "swamp_land_002", "grass01", "grass02", "coastline_grass01", "coastline_grass02", "coastline_redgrass01", "coastline_redgrass02", "coastline_redgrass03", "citygrass01", "redgrass", "redgrass_light", "short_redgrass", "PerfTest1", "canal_reeds", "rocks_redgrass", "lostcoast_grass", "lostcoast_grass2")
	local displacementRollout, compileRollout, params, modelsRollout, miscRollout, decalRollout, matsrollout

	parameters main rollout:params (
		forModel type:#boolean default:false ui:chk_forModel animatable:false
		valveShader type:#string default:"LightmappedGeneric" animatable:false -- VertexLitGeneric , UnlitGeneric, WorldVertexTransition
		surfaceproperty type:#string default:"" animatable:false
		ssbump type:#boolean default:false ui:chk_ssbump animatable:false
		ignorez type:#boolean default:false ui:chk_ignorez animatable:false
		vertexfog type:#boolean default:false ui:chk_vertexfog animatable:false
		ww_vertexcolor type:#boolean default:false ui:chk_ww_vertexcolor animatable:false
		vertexalpha type:#boolean default:false ui:chk_vertexalpha animatable:false
		receiveflashlight type:#boolean ui:chk_receiveflashlight animatable:false default:false
		singlepassflashlight type:#boolean ui:chk_singlepassflashlight animatable:false default:false
		nofog type:#boolean default:false ui:chk_nofog animatable:false
		alphatest type:#boolean default:false ui:chk_alphatest animatable:false
		allowalphatocoverage type:#boolean default:false ui:chk_allowalphatocoverage animatable:false
		AlphaTestReference type:#float ui:spn_AlphaTestReference default:0.5 animatable:false
		useColor type:#boolean ui:ch_useColor default:false animatable:false
		blendTintByBaseAlpha type:#boolean ui:ck_blendTintByBaseAlpha default:false animatable:false
		blendTintColorOverBase type:#float ui:sp_blendTintColorOverBase default:0.0 animatable:false

	)

	parameters decalMain rollout:decalRollout (
		decal type:#boolean default:false ui:chk_decal animatable:false
		writeZ type:#boolean default:false ui:chk_writeZ animatable:false
		decalscale type:#float default:1.0 ui:spn_decalscale animatable:false
		modelmaterial type:#string default:"" ui:edt_modelmaterial animatable:false
		decalfadeduration type:#float default:1.0 ui:spn_decalfadeduration animatable:false
		decalfadetime type:#float default: 1.0 ui:spn_decalfadetime animatable:false
		fogscale type:#float default: 1.0 ui:spn_fogscale animatable:false
	)

	parameters modelsMain rollout:modelsRollout (
		cdmaterials type:#string default:"" ui:edt_cdmaterials animatable:false

		halflambert type:#boolean default:false ui:chk_halflambert animatable:false --VertexLitGeneric. 
		FlashlightNoLambert type:#boolean default:false ui:chk_FlashlightNoLambert animatable:false
		rimlight type:#boolean ui:chk_rimlight default:false animatable:false -- only with phong
		rimexponent type:#integer ui:spn_rimexponent default:2 animatable:false
		rimboost type:#integer ui:spn_rimboost default:1 animatable:false
		rimmask type:#boolean ui:chk_rimmask default:false animatable:false
		phongboost type:#float default:1.0 ui:spn_phongboost animatable:false
		basemapalphaphongmask type:#boolean default:false ui:chk_basemapalphaphongmask
		basemapluminancephongmask type:#boolean default:false  ui:chk_basemapluminancephongmask
		phongfresnelranges type:#point3 default:(Point3 0 0.5 1) animatable:false --ui:edt_phongfresnelranges
		phongexponent type:#integer default:5 ui:spn_phongexponent animatable:false
		disablecsmlookup type:#boolean ui:chk_disablecsmlookup default:false animatable:false
		use_maxfogdensityscalar type:#boolean default:false ui:chk_use_maxfogdensityscalar animatable:false
		maxfogdensityscalar type:#float default:0.0 ui:spn_maxfogdensityscalar animatable:false
		treeSway type:#boolean default:false ui:chk_treeSway animatable:false
		treeSwayHeight type:#float ui:spn_treeSwayHeight default: 200.0 animatable:false
		treeSwayStartHeight type:#float default:.5 ui:spn_treeSwayStartHeight animatable:false
		treeSwayRadius type:#float default:200.0 ui:spn_treeSwayRadius animatable:false
		treeSwayStartRadius type:#float default:0.0 ui:spn_treeSwayStartRadius animatable:false
		treeSwaySpeed type:#float default:.2 ui:spn_treeSwaySpeed animatable:false
		treeSwayStrength type:#float default:1.0 ui:spn_treeSwayStrength animatable:false
		treeSwayScrumbleSpeed type:#float default:.2 ui:spn_treeSwayScrumbleSpeed animatable:false
		treeSwayScrumbleStrength type:#float default:1.0 ui:spn_treeSwayScrumbleStrength animatable:false
		treeSwayScrumbleFrequency type:#float default:2.0 ui:spn_treeSwayScrumbleFrequency animatable:false
		treeSwayFalloffExp type:#float default:32.0 ui:spn_treeSwayFalloffExp animatable:false
		treeSwayScrumbleFalloffExp type:#float default:32.0 ui:spn_treeSwayScrumbleFalloffExp animatable:false
		treeSwaySpeedHighWindMultiplier type:#float default:1.0 ui:spn_treeSwaySpeedHighWindMultiplier animatable:false
		treeSwaySpeedLerpStart type:#float default:200.0 ui:spn_treeSwaySpeedLerpStart animatable:false
		treeSwaySpeedLerpEnd type:#float default:600.0 ui:spn_treeSwaySpeedLerpEnd animatable:false
		detailsprite type:#boolean default:false ui:chk_detailsprite animatable:false
		useJitter type:#boolean default:false ui:chk_useJitter animatable:false
		lightjittercolour type:#color ui:cp_lightjittercolour animatable:false default:(Color 255 229.5 127.5)
		lightjitteramount type:#float ui:spn_lightjitteramount animatable:false default:0.3
		lightjittersin1angle type:#float ui:spn_lightjittersin1angle animatable:false default:180.0
		lightjittersin1speed type:#float ui:spn_lightjittersin1speed animatable:false default:150
		lightjittersin1dispersion type:#float ui:spn_lightjittersin1dispersion animatable:false default:0.02
		lightjittersin2angle type:#float ui:spn_lightjittersin2angle animatable:false default:180.0
		lightjittersin2speed type:#float ui:spn_lightjittersin2speed animatable:false default:150
		lightjittersin2dispersion type:#float ui:spn_lightjittersin2dispersion animatable:false default:0.02
		lightjittersin3angle type:#float ui:spn_lightjittersin3angle animatable:false default:180.8
		lightjittersin3speed type:#float ui:spn_lightjittersin3speed animatable:false default:140.0
		lightjittersin3dispersion type:#float ui:spn_lightjittersin3dispersion animatable:false default:0.03
		lightjittergustmultiplier type:#float ui:spn_lightjittergustmultiplier animatable:false default:7.0
		lightjittergustspeed type:#float ui:spn_lightjittergustspeed animatable:false default:10.0
	)

	parameters displacementMain rollout:displacementRollout (
		use_seamless_scale type:#boolean default:false ui:chk_use_seamless_scale animatable:false
		seamless_scale type:#float default:0.005 ui:spn_seamless_scale animatable:false
		detail type:#string default:"" animatable:false
		surfaceproperty2 type:#string default:"" animatable:false
		ssbump2 type:#boolean default:false ui:chk_ssbump2 animatable:false
	)

	parameters compileMain rollout:compileRollout (
		compile2DSky type:#boolean ui:chk_compile2DSky animatable:false
		compileBlockLOS type:#boolean ui:chk_compileBlockLOS animatable:false
		compileClip type:#boolean ui:chk_compileClip animatable:false
		compileDetail type:#boolean ui:chk_compileDetail animatable:false
		compileFog type:#boolean ui:chk_compileFog animatable:false
		compileHint type:#boolean ui:chk_compileHint animatable:false
		compileInvisible type:#boolean ui:chk_compileInvisible animatable:false
		compileKeepLight type:#boolean ui:chk_compileKeepLight animatable:false
		compileLadder type:#boolean ui:chk_compileLadder animatable:false
		compileNoChop type:#boolean ui:chk_compileNoChop animatable:false
		compileNoDraw type:#boolean ui:chk_compileNoDraw animatable:false
		compileNoLight type:#boolean ui:chk_compileNoLight animatable:false
		compileNonSolid type:#boolean ui:chk_compileNonSolid animatable:false
		compileNoPortal type:#boolean ui:chk_compileNoPortal animatable:false
		compileNPCClip type:#boolean ui:chk_compileNPCClip animatable:false
		compileOrigin type:#boolean ui:chk_compileOrigin animatable:false
		compilePassBullets type:#boolean ui:chk_compilePassBullets animatable:false
		compilePlayerControlClip type:#boolean ui:chk_compilePlayerControlClip animatable:false
		compileSkip type:#boolean ui:chk_compileSkip animatable:false
		compileSky type:#boolean ui:chk_compileSky animatable:false
		compileSlime type:#boolean ui:chk_compileSlime animatable:false
		compileTeam type:#boolean ui:chk_compileTeam animatable:false
		compileTrigger type:#boolean ui:chk_compileTrigger animatable:false
		compileWater type:#boolean ui:chk_compileWater animatable:false
	)

	function getMyVMTName = (
		vmtname = (custAttributes.getOwner this).name
	)

	function getMyVMTFileName = (
		if ::wwmt_gameInfoDir != undefined then (
			if forModel == true AND cdmaterials != "" then (
				materialPath = cdmaterials + "/" + getFileNameFile (getMyVMTName())
			) else (
				materialPath = getMyVMTName()
			)
			::wwmt_gameInfoDir + "/materials/" + materialPath + ".vmt"
		) else (
			undefined
		)
	)

	function setPointThreeFromString arg = (
		local p3 = Point3 0.0 0.0 0.0
		arg = substituteString arg "\"" ""
		arg = substituteString arg "  " " "

		if matchPattern arg pattern:"*,*" then (
			local frsvars = filterString arg "," splitEmptyTokens:false
		) else (
			local frsvars = filterString arg " " splitEmptyTokens:false
		)

		case frsvars.count of (
			1:(
				p3.x = (trimRight frsvars[1]) as Float
			)
			2:(
				p3.x = (trimRight frsvars[1]) as Float
				p3.y = (trimRight frsvars[2]) as Float
			)
			3:(
				p3.x = (trimRight frsvars[1]) as Float
				p3.y = (trimRight frsvars[2]) as Float
				p3.z = (trimRight frsvars[3]) as Float
			)
			default:(
			)
		)
		p3
	)

	function getRolloutByName theRollout theSubRolloutName = (
		local rollname
		for subr in theRollout while rollname == undefined do (
			if subr.name == theSubRolloutName then (
				rollname = subr
			)
		)
		rollname
	)

	function checkDecal dontclose:true = (
		decalRollout.spn_decalscale.enabled = decal
		decalRollout.spn_decalfadeduration.enabled = decal
		decalRollout.spn_decalfadetime.enabled = decal
		decalRollout.spn_fogscale.enabled = decal
		decalRollout.edt_modelmaterial.enabled = decal
		decalRollout.chk_writeZ.enabled = decal

		if dontclose == false then (
			decalRollout.open = decal
		)
	)

	function update_surface2_list val = (
		if findItem displacementRollout.cmb_surfaceproperty2.items val == 0 then (
			theItems = displacementRollout.cmb_surfaceproperty2.items
			append theItems val
			sort theItems
			displacementRollout.cmb_surfaceproperty2.items = theItems
		)
		displacementRollout.cmb_surfaceproperty2.selection = findItem displacementRollout.cmb_surfaceproperty2.items val
		surfaceproperty2 = val
	)

	function update_detail_list_from_scene = (
		scenedetailtypes = makeUniqueArray (for obj in objects WHERE classOf obj == WallWormDetailType collect obj.name)
		if scenedetailtypes.count > 0 then (
			theItems = displacementRollout.cmb_detail.items

			for sd in scenedetailtypes WHERE findItem theItems sd == 0 do (
				append theItems sd
			)

			sort theItems
			displacementRollout.cmb_detail.items = theItems

			displacementRollout.cmb_detail.selection = findItem displacementRollout.cmb_detail.items detail
		)
	)

	function update_detail_list val = (
		if findItem displacementRollout.cmb_detail.items val == 0 then (
			theItems = displacementRollout.cmb_detail.items
			append theItems val
			sort theItems
			displacementRollout.cmb_detail.items = theItems
		)
		displacementRollout.cmb_detail.selection = findItem displacementRollout.cmb_detail.items val
		detail = val
	)

	function displacementCheck = (
		if (classOf (custAttributes.getOwner this)) == Blend then (
			valveShader = "WorldVertexTransition"
			params.drp_valveShader.items = #("WorldVertexTransition")

			forModel = false
			params.chk_forModel.enabled = false
			decal = false
			checkDecal()
		)

		if valveShader == "WorldVertexTransition" then (
			params.drp_valveShader.items = #("WorldVertexTransition")
			params.drp_valveShader.selection = 1

			displacementRollout.cmb_detail.enabled = true
			displacementRollout.chk_use_seamless_scale.enabled = true
			displacementRollout.spn_seamless_scale.enabled = true
			displacementRollout.cmb_surfaceproperty2.enabled = true
			displacementRollout.open = true
		) else (
			displacementRollout.cmb_detail.enabled = false
			displacementRollout.chk_use_seamless_scale.enabled = false
			displacementRollout.spn_seamless_scale.enabled = false
			displacementRollout.cmb_surfaceproperty2.enabled = false
			displacementRollout.open = false
		)
	)

	function VertexLitCheck = (
		if valveShader == "VertexLitGeneric" then (
			modelsRollout.chk_halflambert.enabled = true
		) else (
			modelsRollout.chk_halflambert.enabled = false
		)
	)

	function checkTreesway = (
		local treeSwayEnable
		if treeSway == true AND modelsRollout.chk_treeSway.enabled == true then (
			treeSwayEnable = true
		) else (
			treeSwayEnable = false
		)
		modelsRollout.spn_treeSwayHeight.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayStartHeight.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayRadius.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayStartRadius.enabled = treeSwayEnable
		modelsRollout.spn_treeSwaySpeed.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayStrength.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayScrumbleSpeed.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayScrumbleStrength.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayScrumbleFrequency.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayFalloffExp.enabled = treeSwayEnable
		modelsRollout.spn_treeSwayScrumbleFalloffExp.enabled = treeSwayEnable
		modelsRollout.spn_treeSwaySpeedHighWindMultiplier.enabled = treeSwayEnable
		modelsRollout.spn_treeSwaySpeedLerpStart.enabled = treeSwayEnable
		modelsRollout.spn_treeSwaySpeedLerpEnd.enabled = treeSwayEnable
	)

	function modelCheck = (
		modelsRollout.chk_disablecsmlookup.enabled = forModel
		modelsRollout.edt_cdmaterials.enabled = forModel
		modelsRollout.chk_treeSway.enabled = forModel
		modelsRollout.chk_FlashlightNoLambert.enabled = forModel
		modelsRollout.chk_halflambert.enabled = forModel
		modelsRollout.spn_phongboost.enabled = forModel
		modelsRollout.spn_phongexponent.enabled = forModel
		--modelsRollout.edt_phongfresnelranges.enabled = forModel
		modelsRollout.spn_phongfresnelrangesX.enabled = forModel
		modelsRollout.spn_phongfresnelrangesY.enabled = forModel
		modelsRollout.spn_phongfresnelrangesZ.enabled = forModel

		modelsRollout.chk_rimlight.enabled = forModel

		if rimlight == true AND forModel == true then (
			modelsRollout.spn_rimexponent.enabled = rimlight
			modelsRollout.spn_rimboost.enabled = rimlight
			modelsRollout.chk_rimmask.enabled = rimlight
		) else (
			modelsRollout.spn_rimexponent.enabled = false
			modelsRollout.spn_rimboost.enabled = false
			modelsRollout.chk_rimmask.enabled = false
		)

		modelsRollout.chk_disablecsmlookup.enabled = forModel
		modelsRollout.chk_use_maxfogdensityscalar.enabled = forModel

		if use_maxfogdensityscalar == true AND forModel == true then (
			modelsRollout.spn_maxfogdensityscalar.enabled = true
		) else (
			modelsRollout.spn_maxfogdensityscalar.enabled = false
		)

		miscRollout.spn_radAmount.enabled = NOT forModel

		if forModel == true then (
			params.drp_valveShader.items = #("VertexLitGeneric", "UnlitGeneric", "Refract")
			params.drp_valveShader.selection = findItem params.drp_valveShader.items valveShader

			if cdmaterials == "" AND detailsprite == false then (
				cdmaterials = getFileNamePath ((custAttributes.getOwner this).name)

				if ::wallworm_safe_path == undefined then (
					if (::wallworm_installation_path == undefined) then (
						::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
						local wwp = (::wallworm_installation_path + "\\WallWorm.com\\WallWormModelTools\\ww_struct.ms")
						if doesFileExist wwp then (
							fileIn wwp
						)
					)
				)
				if ::wallworm_safe_path != undefined AND cdmaterials != "" then (
					cdmaterials = ::wallworm_safe_path cdmaterials
					cdmaterials = ::wallworm_remove_first_slash cdmaterials
					cdmaterials = ::wallworm_remove_last_slash cdmaterials
				)
				modelsRollout.edt_cdmaterials.text = cdmaterials
			)
		) else (
			if (classOf (custAttributes.getOwner this)) == Blend then (
				valveShader = "WorldVertexTransition"
				params.drp_valveShader.items = #("WorldVertexTransition")
			) else (
				params.drp_valveShader.items = #("LightmappedGeneric", "UnlitGeneric", "Water", "Sky", "Refract", "DecalModulate", "Subrect")
				params.drp_valveShader.selection = findItem params.drp_valveShader.items valveShader
			)
		)
		checkTreesway()

		if forModel == false then (
			modelsRollout.open = forModel
		)
	)

	rollout params "Wall Worm Source Material Settings" (
		CheckBox chk_forModel "For Model"

		DropDownList drp_valveShader "Source Shader" items:#("LightmappedGeneric", "UnlitGeneric", "WorldVertexTransition", "Water", "Sky", "Refract", "DecalModulate", "Subrect")
		ComboBox cmb_surfaceproperty "Surface Property" items:surfaceproplist

		CheckBox ch_useColor "Use Diffuse Color even with Bitmap" tooltip:"Add the diffuse color into the VMT even when there is a bitmap."

		CheckBox ck_blendTintByBaseAlpha "$blendTintByBaseAlpha" toolTip:"Enables the use of an alpha mask to define areas to tint. Uses the mask of the Base Texture."
		Spinner sp_blendTintColorOverBase "$blendTintColorOverBase" type:#float scale:0.01 range:[0.0, 1.0, 0.0] toolTip:"Sets the amount to replace with solid color. A value of '0' will be full tint while a value of '1.00' will replace the albedo in the mask area with the color defined with $color2. Default value is '0'."

		CheckBox chk_ssbump "Self Shadowing Bump Map ($ssbump)"
		CheckBox chk_ignorez "Ignore Z"

		CheckBox chk_vertexfog "Vertex Fog" enabled:true
		CheckBox chk_vertexalpha "Vertex Alpha"
		CheckBox chk_ww_vertexcolor "Vertex Color"

		CheckBox chk_receiveflashlight "Receive Flashlight" tooltip:"Allow the player's flashlight to illuminate the material. " enabled:true
		CheckBox chk_singlepassflashlight "Single Pass Flashlight" enabled:true
		CheckBox chk_nofog "No Fog"

		Group "Alpha Settings" (
			Label alphalabel "Use Opacity for Alpha and 2-Sided for Nocull"
			CheckBox chk_alphatest "Alpha Test"
			Spinner spn_AlphaTestReference "Alpha Test Reference" range:[0.0, 1.0, 0.5]
			CheckBox chk_allowalphatocoverage "$allowalphatocoverage" tooltip:"Enable antialiasing of alpha-tested textures."
		)

		function setUIElements = (
			modelsRollout.spn_maxfogdensityscalar.enabled = use_maxfogdensityscalar
			displacementRollout.spn_seamless_scale.enabled = use_seamless_scale
		)

		function displacementOpts = (
		)

		function update_surface_list val = (
			if findItem cmb_surfaceproperty.items val == 0 then (
				theItems = cmb_surfaceproperty.items
				append theItems val
				sort theItems
				cmb_surfaceproperty.items = theItems
			)
			cmb_surfaceproperty.selection = findItem cmb_surfaceproperty.items val
			surfaceproperty = val
		)

		function update_shader_list val = (
			if (classOf (custAttributes.getOwner this)) == Blend then (
				val = "WorldVertexTransition"
				valveShader = "WorldVertexTransition"
				drp_valveShader.items = #("WorldVertexTransition")
				drp_valveShader.selection = 1
			) else (
				if findItem drp_valveShader.items val == 0 then (
					theItems = drp_valveShader.items
					append theItems val
					sort theItems
					drp_valveShader.items = theItems
				)
				drp_valveShader.selection = findItem drp_valveShader.items val
				valveShader = val
			)
			chk_ssbump.enabled = true
			if valveShader == "LightmappedGeneric" OR valveShader == "WorldVertexTransition" then (
				displacementRollout.chk_ssbump2.enabled = true
				decalRollout.chk_writeZ.enabled = false
				displacementRollout.chk_ssbump2.enabled = true
			) else (

				displacementRollout.chk_ssbump2.enabled = false
				if valveShader == "DecalModulate" then (
					decal = true
					decalRollout.chk_decal.checked = true
					checkDecal()
					decalRollout.chk_writeZ.enabled = true
				) else (
					decalRollout.chk_writeZ.enabled = false
					if toLower valveShader == "subrect" then (
						decal = true
						decalRollout.chk_decal.checked = true
						checkDecal()
					)
				)
			)
			VertexLitCheck()
		)

		on cmb_surfaceproperty entered val do (
			update_surface_list val
		)

		on cmb_surfaceproperty selected sel do (
			update_surface_list cmb_surfaceproperty.selected
		)

		on chk_forModel changed stat do (
			modelCheck()
			if findItem drp_valveShader.items valveShader == 0 then (
				if forModel then (
					valveShader = "VertexLitGeneric"
				) else (
					valveShader = "LightmappedGeneric"
				)
				drp_valveShader.selection = findItem drp_valveShader.items valveShader
			)
		)

		on params open do (
			cmb_surfaceproperty.items = surfaceproplist
			update_surface_list surfaceproperty
			update_shader_list valveShader
			displacementCheck()
			if valveShader == "WorldVertexTransition" OR valveShader == "LightmappedGeneric" OR valveShader == "Sky" then (
				forModel = false
			)

			modelCheck()
			checkDecal()
			VertexLitCheck()
		)

		on drp_valveShader selected sel do (
			valveShader = drp_valveShader.selected
			displacementCheck()
			checkTreesway()
		)

		on chk_use_seamless_scale changed stat do (
			setUIElements()
		)

		on drp_valveShader selected sel do (
			update_shader_list drp_valveShader.selected
			VertexLitCheck()
		)
	)

	rollout modelsRollout "Model Shader Settings" (
		EditText edt_cdmaterials "$cdmaterials" toolTip:"Enter the Output Path for this material if it is a model material." enabled:forModel
		CheckBox chk_FlashlightNoLambert "Flashlight No Lambert" enabled:forModel
		CheckBox chk_halflambert "Half Lambert" enabled:forModel
		Group "Phong" (
			Label phongNote "Only works if Standard Shader Type set to Phong"
			CheckBox chk_basemapalphaphongmask "$basemapalphaphongmask" tooltip:"Use the alpha channel of the $basetexture as Phong mask."
			CheckBox chk_basemapluminancephongmask "$basemapluminancephongmask" tooltip:"Use the luminance of the $basetexture as Phong mask."
			Spinner spn_phongboost "Phong Boost" type:#float range:[0.0, 32.0, 1.0] enabled:forModel
			Spinner spn_phongexponent "Phong Exponent" type:#integer step:1 range:[0, 32, 5] enabled:forModel

			--editText edt_phongfresnelranges "Phong Fresnel Ranges"  enabled:forModel

			Label lbl_phongranges "Phong Fresnel Ranges"
			Spinner spn_phongfresnelrangesX "" across:3 enabled:forModel type:#float
			Spinner spn_phongfresnelrangesY "" enabled:forModel type:#float
			Spinner spn_phongfresnelrangesZ "" enabled:forModel type:#float

			CheckBox chk_rimlight "Rim Light" enabled:forModel

			Spinner spn_rimexponent "Rim Light Exponent" default:2 enabled:rimlight animatable:false type:#integer step:1
			Spinner spn_rimboost "Rim Light Boost" default:1 enabled:rimlight animatable:false type:#integer step:1
			CheckBox chk_rimmask "Rim Light Mask" default:false enabled:rimlight animatable:false
		)

		CheckBox chk_disablecsmlookup "Disable CSM Lookup" enabled:forModel
		Group "Tree Sway" (
			CheckBox chk_treeSway "Tree Sway" enabled:forModel
			Spinner spn_treeSwayHeight "Tree Sway Height" range:[0, 1024, 200] enabled:treeSway
			Spinner spn_treeSwayStartHeight "Tree Sway Start Height" range:[0.0, 32.0, 0.5] enabled:treeSway
			Spinner spn_treeSwayRadius "Tree Sway Radius" range:[0, 1024, 100] enabled:treeSway
			Spinner spn_treeSwayStartRadius "Tree Sway Start Radius" range:[0.0, 32.0, 0.5] enabled:treeSway
			Spinner spn_treeSwaySpeed "Tree Sway Speed" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayStrength "Tree Sway Strength" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayScrumbleSpeed "Tree Sway Scrumble Speed" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayScrumbleStrength "Tree Sway Scrumble Strength" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayScrumbleFrequency "Tree Sway Scrumble Frequency" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayFalloffExp "Tree Sway Falloff Exponent" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwayScrumbleFalloffExp "Tree Sway Scrumble Falloff Exponent" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwaySpeedHighWindMultiplier "Tree Sway High Wind Multiplier" range:[0.0, 1000, 1.1] enabled:treeSway
			Spinner spn_treeSwaySpeedLerpStart "Tree Sway Speed Lerp Start" range:[0.0, 1000, 0.5] enabled:treeSway
			Spinner spn_treeSwaySpeedLerpEnd "Tree Sway Speed Lerp End" range:[0.0, 1000, 0.5] enabled:treeSway
		)

		CheckBox chk_use_maxfogdensityscalar "Use Max Fog Density" toolTip:"Check here to use the Max Fog Density." enabled:forModel
		Spinner spn_maxfogdensityscalar "Max Fog Density" range:[0.0, 1.0, 0.0] enabled:use_maxfogdensityscalar -- enabled:use_maxfogdensityscalar 

		function updatePhongRangeText spinners:false = (
			--edt_phongfresnelranges.text = (phongfresnelranges.x as string) + " " +(phongfresnelranges.y as string) + " " +(phongfresnelranges.z as string) 
			if spinners == true then (
				spn_phongfresnelrangesX.value = phongfresnelranges.x
				spn_phongfresnelrangesY.value = phongfresnelranges.y
				spn_phongfresnelrangesZ.value = phongfresnelranges.z
			)
		)
		/*
		on edt_phongfresnelranges entered arg do (
			try (--must try in case user enters invalid format
				local p3 = setPointThreeFromString arg
				phongfresnelranges = p3
				spn_phongfresnelrangesX.value = phongfresnelranges.x
				spn_phongfresnelrangesY.value = phongfresnelranges.y
				spn_phongfresnelrangesZ.value = phongfresnelranges.z
			) catch (
				messagebox "The values of the phongfresnelranges must be a list of floats separated by spaces or commas."
			)
		)*/

		on spn_phongfresnelrangesX entered do (
			phongfresnelranges.x = spn_phongfresnelrangesX.value

		)
		on spn_phongfresnelrangesY entered do (
			phongfresnelranges.y = spn_phongfresnelrangesY.value

		)
		on spn_phongfresnelrangesZ entered do (
			phongfresnelranges.z = spn_phongfresnelrangesZ.value

		)

		on chk_treeSway changed stat do (
			checkTreesway()
		)

		on chk_rimlight changed stat do (
			spn_rimexponent.enabled = stat
			spn_rimboost.enabled = stat
			chk_rimmask.enabled = stat
		)

		on chk_use_maxfogdensityscalar changed stat do (
			spn_maxfogdensityscalar.enabled = stat
		)

		on modelsRollout open do (
			modelCheck()
			updatePhongRangeText spinners:true
		)

		CheckBox chk_detailsprite "Detail Sprite" tooltip:"Set the Detailsprite setting for this material."

		Group "Jitter Settings" (
			CheckBox chk_useJitter "Use Jitter" tooltip:"Enable and use the Jitter Settings" -- enabled:detailsprite

			ColorPicker cp_lightjittercolour "Light Jitter Color" enabled:useJitter
			Spinner spn_lightjitteramount "Light Jitter Amount" enabled:useJitter

			Spinner spn_lightjittersin1angle "Light Jitter Angle 1" enabled:useJitter
			Spinner spn_lightjittersin1speed "Light Jitter Speed 1" enabled:useJitter
			Spinner spn_lightjittersin1dispersion "Light Jitter Dispersion 1" enabled:useJitter

			Spinner spn_lightjittersin2angle "Light Jitter Angle 2" enabled:useJitter
			Spinner spn_lightjittersin2speed "Light Jitter Speed 2" enabled:useJitter
			Spinner spn_lightjittersin2dispersion "Light Jitter Dispersion 2" enabled:useJitter

			Spinner spn_lightjittersin3angle "Light Jitter Angle 3" enabled:useJitter
			Spinner spn_lightjittersin3speed "Light Jitter Speed 3" enabled:useJitter
			Spinner spn_lightjittersin3dispersion "Light Jitter Dispersion 3" enabled:useJitter

			Spinner spn_lightjittergustmultiplier "Light Jitter Gust Multiplier" enabled:useJitter
			Spinner spn_lightjittergustspeed "Light Jitter Gust Speed" enabled:useJitter
		)

		function setJitterFields = (
			spn_lightjitteramount.enabled = useJitter
			spn_lightjittersin1angle.enabled = useJitter
			spn_lightjittersin1speed.enabled = useJitter
			spn_lightjittersin1dispersion.enabled = useJitter

			spn_lightjittersin2angle.enabled = useJitter
			spn_lightjittersin2speed.enabled = useJitter
			spn_lightjittersin2dispersion.enabled = useJitter

			spn_lightjittersin3angle.enabled = useJitter
			spn_lightjittersin3speed.enabled = useJitter
			spn_lightjittersin3dispersion.enabled = useJitter

			spn_lightjittergustmultiplier.enabled = useJitter
			spn_lightjittergustspeed.enabled = useJitter
			cp_lightjittercolour.enabled = useJitter
		)

		on chk_detailsprite changed stat do (
			chk_useJitter.enabled = true
			setJitterFields()
		)

		on chk_useJitter changed stat do (
			setJitterFields()
		)
	)

	rollout displacementRollout "WorldVertexShader (Blend) Settings" (
		ComboBox cmb_detail "Detail Type" items:detaillist
		Button btn_update_details "Update List from Scene Details" tooltip:"Update the list from the detail types in the scene. Requires the Detailer Plugin."
		Label dispnote "NOTE: surfaceprop2 refer to Material 1 in Blend"

		ComboBox cmb_surfaceproperty2 "Surface Property2" items:surfaceproplist
		CheckBox chk_use_seamless_scale "Use Seamless Scale" toolTip:"Check here to use the Seamless Scale"
		Spinner spn_seamless_scale "Seamless Scale" rang:[0.0001, 16.000, 0.001] --enabled:use_seamless_scale
		CheckBox chk_ssbump2 "Self Shadowing Bump Map ($ssbump2)"

		on btn_update_details pressed do (
			update_detail_list_from_scene()
		)

		on cmb_detail selected sel do (
			update_detail_list cmb_detail.selected
		)

		on cmb_detail entered tex do (
			update_detail_list tex
		)

		on cmb_surfaceproperty2 entered val do (
			update_surface2_list val
		)

		on cmb_surfaceproperty2 selected sel do (
			update_surface2_list cmb_surfaceproperty2.selected
		)

		on displacementRollout open do (
			if forModel == false then (
				update_detail_list detail
				update_surface2_list surfaceproperty2
				cmb_detail.items = detaillist

				update_detail_list detail
			)

			displacementCheck()
		)
	)

	rollout decalRollout "Decal Settings" (
		CheckBox chk_decal "Decal"

		Spinner spn_decalscale "Decal Scale" enabled:decal range:[0.0, 128.0, 1.0]
		Spinner spn_decalfadeduration "Decal Fade Duration" enabled:decal range:[0.0, 1024.0, 1.0]
		Spinner spn_decalfadetime "Decal Fade Time" enabled:decal range:[0.0, 1024.0, 1.0]
		Spinner spn_fogscale "Decal Fog Scale" enabled:decal range:[0.0, 1024.0, 1.0]
		EditText edt_modelmaterial "Model Material Name" enabled:decal
		CheckBox chk_writeZ "Write Z" enabled:decal toolTip:"Only available if the Source Shader is set to DecalModulate."

		on chk_decal changed stat do (
			checkDecal()
		)

		on decalRollout open do (
			checkDecal dontclose:false
		)
	)

	parameters envmapvars rollout:envmaprollout (
		useReflectivity type:#boolean ui:ch_useRefelctivity animatable:false default:false
		reflectivity type:#color ui:cp_reflectivity animatable:false default:(Color 255 255 255)

		useEnvSettings type:#boolean ui:ch_useEnvSettings animatable:false default:false
		envmaptint type:#color ui:cp_envmaptint animatable:false default:(Color 255 255 255)
		envmapcontrast type:#float ui:sp_envmapcontrast default:0.0 animatable:false
		envmapsaturation type:#float ui:sp_envmapsaturation default:1.0 animatable:false
	)

	rollout envmaprollout "Reflections and Env" (
		Label envlabel "Use Specular Level for envmapmask. Use Reflection for envmap."

		CheckBox ch_useRefelctivity "Use Reflectivity Setting"
		ColorPicker cp_reflectivity "$reflectivity" enabled:useReflectivity tooltip:"$reflectivity overrides a VTF file's embedded reflectivity value. It tells VRAD how much light should be bounced off the material, without affecting how much it receives. "
		Group "Env Settings" (
			CheckBox ch_useEnvSettings "Use Env Settings:"
			ColorPicker cp_envmaptint "$envmaptint" enabled:useEnvSettings tooltip:"Controls the intensity of the reflection's red, green and blue color channels. Any positive number can be used. Default is \"[1 1 1]\", which means 100% intensity.\n\nThis command is often used to dim the brightness of a specular reflection without the overhead of an $envmapmask."
			Spinner sp_envmapcontrast "$envmapcontrast" enabled:useEnvSettings type:#float scale:0.0001 range:[0.0, 1.0, 0.0] tooltip:"Controls the contrast of the reflection. 0 is natural contrast, while 1 is the full squaring of the color (i.e. color*color).\n\nUse higher contrasts to diminish relatively darker areas and increase hot spots.\n\nWill not work when Phong is enabled"
			Spinner sp_envmapsaturation "$envmapsaturation" enabled:useEnvSettings type:#float range:[0.0, 1.0, 0.0] scale:0.0001 tooltip:"Controls the colour saturation of the reflection. 0 is greyscale, while 1 is natural saturation.\n\nWill not work when Phong is enabled"
		)

		on envmaprollout open do (
			cp_reflectivity.enabled = useReflectivity

			cp_envmaptint.enabled = useEnvSettings
			sp_envmapcontrast.enabled = useEnvSettings
			sp_envmapsaturation.enabled = useEnvSettings
		)

		on ch_useRefelctivity changed stat do (
			cp_reflectivity.enabled = useReflectivity
		)

		on ch_useEnvSettings changed stat do (
			cp_envmaptint.enabled = useEnvSettings
			sp_envmapcontrast.enabled = useEnvSettings
			sp_envmapsaturation.enabled = useEnvSettings
		)
	)

	parameters matsandmaps rollout:matsrollout (
		lightwarptexture type:#texturemap ui:mp_lightwarptexture animatable:false
		crackmaterial type:#material ui:mt_crackmaterial animatable:false

		parallaxmap type:#texturemap ui:mp_parallaxmaptexture animatable:false
		parallaxmapscale type:#float default:0.05 ui:sp_parallaxmapscale animatable:false

		breakablesurface type:#boolean ui:chk_BreakableSurface animatable:false default:false
		detailscale type:#float default:4.0 animatable:false ui:sp_detailscale
		detailblendfactor type:#float default:0.5 animatable:false ui:sp_detailblendfactor
		detailblendmode type:#integer default:0 animatable:false --ui:sp_detailblendmode
		detailtint type:#color ui:cp_detailtint animatable:false default:(Color 127 127 127)

		useadvanceddetail type:#boolean ui:ch_useAdvancedDetail animatable:false default:false
		usedetailscale type:#boolean ui:ch_usedetailscale animatable:false default:false
		texturelist type:#texturemapTab tabSizeVariable:true
	)
	function fillTextureList = (
		matsrollout.texturelistbox.items = for t in texturelist collect t.name
	)
	function removeFromTextureListByTexture tex = (
		local index = (findItem texturelist tex)
		while index != 0 do (
			deleteItem texturelist index
			index = (findItem texturelist tex)
		)
		texturelist = for tex in texturelist WHERE tex != undefined collect tex
		fillTextureList()
	)
	function addToTextureList tex = (
		if superClassOf tex == TextureMap then (
			if findItem texturelist tex == 0 then (
				append texturelist tex
			)
			fillTextureList()
		)
	)
	rollout matsrollout "Extra Maps and Materials"
	(
		Group "Texture Maps" (
			Label lightwarplabel "$lightwarptexture"
			MapButton mp_lightwarptexture "Select lightwarptexture Bitmap"

			Label parallaxmaplable "$parallaxmap"
			MapButton mp_parallaxmaptexture "Select parallaxmap Bitmap"
			Spinner sp_parallaxmapscale "Parallax Map Scale" range:[0.0, 1.0, 0.05] tooltip:"Parallaxmap scale. Brick is good at 0.05."

			ListBox texturelistbox "Extra Textures"
			Button removeSelectedTexture "Remove Selected" across:2 align:#left tooltip:"Remove the texture selected above."
			MapButton addTextureListButton "Add Texture" tooltip:"Add to the arbitrary texture list."

		)

		Group "Detail Texture" (
			Label detaillabelinfo "Set Detail Map in Extra Bump property of a Normal Bump in Bump"

			CheckBox ch_usedetailscale "Use Detail Scale instead of Detail Texture Transform"
			Spinner sp_detailscale "$detailscale" enabled:usedetailscale type:#float scale:0.01 range:[0.01, 1024.0, 4.0] tooltip:"Fits the detail texture onto the material the given number of times (default = 4). Generally used instead of $detailtexturetransform with a value of around 7 or 8 for a 128px detail texture."
			CheckBox ch_useAdvancedDetail "Use Advanced Detail Settings"
			Spinner sp_detailblendfactor "$detailblendfactor" enabled:useadvanceddetail type:#float scale:0.01 range:[0.0, 1.0, 0.0] tooltip:"Effectively an $alpha value for the detail texture."
			DropDownList dp_detailblendmode "$detailblendmode" enabled:useadvanceddetail tooltip:"How to combine the detail material with the albedo. " items:#("0 = normal (darken)", "1 = additive (lighten)", "2 = alpha blend detail over base ", "3 = crossfade ", "4 = overlays over alpha map")
			ColorPicker cp_detailtint "$detailtint" enabled:useadvanceddetail
		)

		Group "Materials" (
			Label crackmatlabel "$crackmaterial"
			MaterialButton mt_crackmaterial "Crack Material" tooltip:"The crack material for this material. You may have to use Slate to add this property."
			CheckBox chk_BreakableSurface "Breakable Surface" tooltip:"Add Proxy block for breakable surface. May need to further edit VMT."
		)

		function setDetailMode = (
			--BINARY
			detailblendmode = dp_detailblendmode.selection - 1
		)

		function setDetailModeUI = (
			dp_detailblendmode.selection = detailblendmode + 1
		)

		on matsrollout open do (
			setDetailModeUI()
			fillTextureList()
		)

		on addTextureListButton picked tex do (
			addToTextureList tex
		)
		on removeSelectedTexture pressed do (
			sel = texturelistbox.selection
			if sel != undefined AND texturelist[sel] != undefined then (
				removeFromTextureListByTexture texturelist[sel]
			)
		)

		on dp_detailblendmode selected sel do (
			setDetailMode()
		)

		on ch_usedetailscale changed stat do (
			sp_detailscale.enabled = usedetailscale
		)

		on ch_useAdvancedDetail changed stat do (
			sp_detailblendfactor.enabled = useadvanceddetail
			dp_detailblendmode.enabled = useadvanceddetail
			cp_detailtint.enabled = useadvanceddetail
		)
	)

	rollout compileRollout "Source Compile Parameters" (
		CheckBox chk_compile2DSky "Compile 2D Sky"
		CheckBox chk_compileBlockLOS "Compile Block LOS"
		CheckBox chk_compileClip "Compile Clip"
		CheckBox chk_compileDetail "Compile Detail"
		CheckBox chk_compileFog "Compile Fog"
		CheckBox chk_compileHint "Compile Hint"
		CheckBox chk_compileInvisible "Compile Invisible"
		CheckBox chk_compileKeepLight "Compile Keep Light"
		CheckBox chk_compileLadder "Compile Ladder"
		CheckBox chk_compileNoChop "Compile No Chop"
		CheckBox chk_compileNoDraw "Compile No Draw"
		CheckBox chk_compileNoLight "Compile No Light"
		CheckBox chk_compileNonSolid "Compile Non Solid"
		CheckBox chk_compileNoPortal "Compile No Portal"
		CheckBox chk_compileNPCClip "Compile NPC Clip"
		CheckBox chk_compileOrigin "Compile Origin"
		CheckBox chk_compilePassBullets "Compile Pass Bullets"
		CheckBox chk_compilePlayerControlClip "Compile Player Control Clip"
		CheckBox chk_compileSkip "Compile Skip"
		CheckBox chk_compileSky "Compile Sky"
		CheckBox chk_compileSlime "Compile Slime"
		CheckBox chk_compileTeam "Compile Team"
		CheckBox chk_compileTrigger "Compile Trigger"
		CheckBox chk_compileWater "Compile Water"
	)

	parameters miscMain rollout:miscRollout(
		keywords type:#stringTab tabSizeVariable:true animatable:false
		RadAmount type:#integer default:1000 ui:spn_radAmount animatable:false
		exportTexTransforms type:#boolean default:false ui:chk_texTransforms animatable:false
	)

	rollout miscRollout "Miscellaneous" (
		Spinner spn_radAmount "Radiosity Amount" type:#integer step:1 range:[1, 64000, 1000] toolTip:"Brightness for this Material when giving radiosity light in a lights.rad file."

		ComboBox cmb_keywords "Keywords" items:(keywords as Array)
		Button btn_delete_keyword "Delete Selected Keyword"

		CheckBox chk_texTransforms "Write Tex Transforms Into VMT" toolTip:"Write the texture transforms into the VMT. Only applicable to Brush Materials since this is always done for materials used on models."
		Button exportMat "Write Material File (VMT)"

		Button exportMe "Export Textures to VTF"

		Button openMe "View VMT"

		Hyperlink wwlink "Powered By Wall Worm" address:"http://dev.wallworm.com" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		Hyperlink valvelink "Valve Shader Wiki" address:"https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters?from=3ds+max+and+wallworm" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)

		on exportMat pressed do (
			m = (custAttributes.getOwner this)

			local exportMatlist = #()

			local getNameFromPath = false
			local materialPath = getFileNamePath m.name
			if forModel == true AND cdmaterials != "" then (
				getNameFromPath = false
				materialPath = cdmaterials
			)

			if ::wallworm_appendBitmaps == undefined then (
				if (::wallworm_installation_path == undefined) then (
					::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
				)

				fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
			)

			::wallworm_appendBitmaps m exportMatlist valveShader coords:exportTexTransforms decal:decal getNameFromPath:getNameFromPath forModel:forModel materialPath:materialPath

			if classOf m == Blend then (
				exportMatlist[1].matName = ::wallworm_getMaterialName m
				exportMatlist[1].materialPath = ""
			) else (
				if exportMatlist[1].mat1 == undefined then (
					exportMatlist[1].mat1 = exportMatlist[1].mat
				)
				exportMatlist[1].matName = ::wallworm_getMaterialName exportMatlist[1].mat1 forModel:forModel
			)

			if (m.forModel != true OR m.cdmaterials == "") AND classOf m != Blend then (
				materialPath = exportMatlist[1].getMaterialPathForMat m
			)

			if classOf m == Blend then (
				exportMatlist[1].compileTexture m.map1.diffuseMap "diff" writeVMT:true exportVTF:false shoutNotice:true
			) else (
				exportMatlist[1].compileTexture m.diffuseMap "diff" writeVMT:true exportVTF:false shoutNotice:true
			)
		)

		on exportMe pressed do (
			::wallworm_exportMatlist = #((custAttributes.getOwner this))
			try (
				macros.run "wallworm.com" "WallWormAnvilCompileVTFMCR"
			) catch (
				messageBox "Oops... this function only works if Wall Worm is installed. Go to http://dev.wallworm.com"
			)
		)

		on openMe pressed do (
			local f = getMyVMTFileName()
			if f != undefined then (
				--print f

				if doesFileExist f == true then (
					if ::wallworm_text_editor == undefined OR ::wallworm_text_editor == "" then (
						::wallworm_text_editor = "notepad.exe"
					)
					folderOpen = "ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + f + "\""
					execute folderOpen
				) else (
					messageBox "This file doesn't exist. Perhaps it is in a VPK or has not been exported yet."
				)
			)
		)

		on cmb_keywords entered tex do (
			if findItem keywords tex == 0 then (
				append keywords tex
				sort (keywords as Array)
				cmb_keywords.items = keywords as Array
			)
		)

		on btn_delete_keyword pressed do (
			if cmb_keywords.selection > 0 then (
				local kw = (keywords as Array)
				local ind = findItem kw cmb_keywords.selected
				if ind != 0 then (
					deleteItem kw ind
					cmb_keywords.items = kw as Array
					keywords = kw
				)
			)
		)
	)

	function outputme forceModel:false forceDecal:false = (
		local forModelCheck = forModel

		if forModel == false AND forceModel == true AND valveShader != "WorldVertexTransition" AND valveShader != "LightMappedGeneric" AND valveShader != "Sky" then (
			forModelCheck = forceModel
		)

		local forDecalCheck = decal

		if decal == false AND forceDecal == true then (
			forDecalCheck = forceDecal
		)

		local outStr = StringStream ""

		if forModelCheck == true then (
			if valveShader != "VertexLitGeneric" then (
				format "\t\"$model\" 1\n" to:outStr
			)

			if detailsprite == true then (
				format "\t\"$detailsprite\" 1\n" to:outStr
			)

			if treeSway == true then (
				format "\n\t\"$treeSway\" 1\n" to:outStr
				format "\t\"$treeSwayHeight\" \"%\"\n" treeSwayHeight to:outStr
				format "\t\"$treeSwayStartHeight\" \"%\"\n" treeSwayStartHeight to:outStr
				format "\t\"$treeSwayRadius\" \"%\"\n" treeSwayRadius to:outStr
				format "\t\"$treeSwayStartRadius\" \"%\"\n" treeSwayStartRadius to:outStr
				format "\t\"$treeSwaySpeed\" \"%\"\n" treeSwaySpeed to:outStr
				format "\t\"$treeSwayStrength\" \"%\"\n" treeSwayStrength to:outStr
				format "\t\"$treeSwayScrumbleSpeed\" \"%\"\n" treeSwayScrumbleSpeed to:outStr
				format "\t\"$treeSwayScrumbleStrength\" \"%\"\n" treeSwayScrumbleStrength to:outStr
				format "\t\"$treeSwayScrumbleFrequency\" \"%\"\n" treeSwayScrumbleFrequency to:outStr
				format "\t\"$treeSwayFalloffExp\" \"%\"\n" treeSwayFalloffExp to:outStr
				format "\t\"$treeSwayScrumbleFalloffExp\" \"%\"\n" treeSwayScrumbleFalloffExp to:outStr
				format "\t\"$treeSwaySpeedHighWindMultiplier\" \"%\"\n" treeSwaySpeedHighWindMultiplier to:outStr
				format "\t\"$treeSwaySpeedLerpStart\" \"%\"\n" treeSwaySpeedLerpStart to:outStr
				format "\t\"$treeSwaySpeedLerpEnd\" \"%\"\n\n" treeSwaySpeedLerpEnd to:outStr
			)

			if disablecsmlookup == true then (
				format "\t\"$DISABLECSMLOOKUP\" 1\n" to:outStr
			)

			if valveShader == "VertexLitGeneric" AND halflambert == true then (
				format "\t\"$halflambert\" 1\n" to:outStr
			)

			if (classOf (custAttributes.getOwner this) == Standard) AND (custAttributes.getOwner this).shaderByName == "Phong" then (
				format "\t\"$phong\" 1\n" to:outStr
				format "\t\"$phongboost\" \"%\"\n" phongboost to:outStr
				format "\t\"$phongexponent\" \"%\"\n" phongexponent to:outStr

				format ("\t\"$phongfresnelranges\" \"[% % %]\"\n") phongfresnelranges.x phongfresnelranges.y phongfresnelranges.z to:outStr
				if basemapalphaphongmask == true then (
					format "\t\"$basemapalphaphongmask\" 1\n" to:outStr
				)
				if basemapluminancephongmask == true then (
					format "\t\"$basemapluminancephongmask\" 1\n" to:outStr
				)
				if rimlight == true then (
					format "\t\"$rimlight\" 1\n" to:outStr

					format "\t\"$rimexponent\" \"%\"\n" rimexponent to:outStr
					format "\t\"$rimboost\" \"%\"\n" rimboost to:outStr
					if rimmask == true then (
						format "\t\"$rimmask\" 1\n" to:outStr
					)
				)
			)

			if use_maxfogdensityscalar == true then (
				format ("\t\"$maxfogdensityscalar\" \"%\"\n") maxfogdensityscalar to:outStr
			)

			if FlashlightNoLambert == true then (
				format "\t\"$FlashlightNoLambert\" 1\n" to:outStr
			)

		)

		if surfaceproperty != "" then (
			format "\t\"$surfaceprop\" \"%\"\n" surfaceproperty to:outStr
		)

		if compile2DSky then (
			format "\t\"\%compile2dsky\" 1\n" to:outStr
		)
		if compileBlockLOS then (
			format "\t\"\%compileblocklos\" 1\n" to:outStr
		)
		if compileClip then (
			format "\t\"\%compileclip\" 1\n" to:outStr
		)
		if compileDetail then (
			format "\t\"\%compiledetail\" 1\n" to:outStr
		)
		if compileFog then (
			format "\t\"\%compilefog\" 1\n" to:outStr
		)
		if compileHint then (
			format "\t\"\%compilehint\" 1\n" to:outStr
		)
		if compileInvisible then (
			format "\t\"\%compileinvisible\" 1\n" to:outStr
		)
		if compileKeepLight then (
			format "\t\"\%compilekeeplight\" 1\n" to:outStr
		)
		if compileLadder then (
			format "\t\"\%compileladder\" 1\n" to:outStr
		)
		if compileNoChop then (
			format "\t\"\%compilenochop\" 1\n" to:outStr
		)
		if compileNoDraw then (
			format "\t\"\%compilenodraw\" 1\n" to:outStr
		)
		if compileNoLight then (
			format "\t\"\%compilenolight\" 1\n" to:outStr
		)
		if compileNonSolid then (
			format "\t\"\%compilenonsolid\" 1\n" to:outStr
		)
		if compileNoPortal then (
			format "\t\"\%compilenoportal\" 1\n" to:outStr
		)
		if compileNPCClip then (
			format "\t\"\%compilenpcclip\" 1\n" to:outStr
		)
		if compileOrigin then (
			format "\t\"\%compileorigin\" 1\n" to:outStr
		)
		if compilePassBullets then (
			format "\t\"\%compilepassbullets\" 1\n" to:outStr
		)
		if compilePlayerControlClip then (
			format "\t\"\%compileplayercontrolclip\" 1\n" to:outStr
		)
		if compileSkip then (
			format "\t\"\%compileskip\" 1\n" to:outStr
		)
		if compileSky then (
			format "\t\"\%compilesky\" 1\n" to:outStr
		)
		if compileSlime then (
			format "\t\"\%compileslime\" 1\n" to:outStr
		)
		if compileTeam then (
			format "\t\"\%compileteam\" 1\n" to:outStr
		)
		if compileTrigger then (
			format "\t\"\%compiletrigger\" 1\n" to:outStr
		)
		if compileWater then (
			format "\t\"\%compilewater\" 1\n" to:outStr
		)

		if keywords.count > 0 then (
			format "\t\"\%keywords\" \"" to:outStr
			hasComma = false
			for k in keywords do (
				if hasComma == true then (
					format "," to:outStr
				) else (
					hasComma = true
				)

				format k to:outStr
			)

			format "\"\n" to:outStr
		)

		if valveShader == "DecalModulate" AND writeZ == true then (
			format "\t\"$writeZ\" 1\n" to:outStr
		)

		if ssbump == true then (
			format "\t\"$ssbump\" 1\n" to:outStr
		)

		if ignorez == true then (
			format "\t\"$ignorez\" 1\n" to:outStr
		)

		if nofog == true then (
			format "\t\"$nofog\" 1\n" to:outStr
		)

		if vertexfog == true then (
			format "\t\"$vertexfog\" 1\n" to:outStr
		)

		if vertexalpha == true then (
			format "\t\"$vertexalpha\" 1\n" to:outStr
		)
		if ww_vertexcolor == true then (
			format "\t\"$vertexcolor\" 1\n" to:outStr
		)

		if receiveflashlight == true then (
			format "\t\"$receiveflashlight\" 1\n" to:outStr
		)
		if singlepassflashlight == true then (
			format "\t\"$singlepassflashlight\" 1\n" to:outStr
		)

		if forDecalCheck == true then (
			format "\t\"$decal\" 1\n" to:outStr

			format "\t\"$decalscale\" \"%\"\n" decalscale to:outStr
			format "\t\"$decalfadeduration\" \"%\"\n" decalfadeduration to:outStr
			format "\t\"$decalfadetime\" \"%\"\n" decalfadetime to:outStr
			if modelmaterial != "" then (
				format "\t\"$modelmaterial\" \"%\"\n" modelmaterial to:outStr
			)

		)

		if alphatest == true then (
			format "\t\"$alphatest\" 1\n" to:outStr
			format "\t\"$AlphaTestReference\" \"%\"\n" AlphaTestReference to:outStr
			if allowalphatocoverage == true then (
				format "\t\"$allowalphatocoverage\" 1\n" to:outStr
			)
		)

		if useJitter == true then (
			format "\t\"$lightjitteramount\" \"%\"\n" lightjitteramount to:outStr
			format "\t\"$lightjittercolour\" \"[% % %]\"\n" (lightjittercolour.r / 255.0) (lightjittercolour.g / 255.0) (lightjittercolour.b / 255.0) to:outStr

			format "\t\"$lightjittersin1angle\" \"%\"\n" lightjittersin1angle to:outStr
			format "\t\"$lightjittersin1speed\" \"%\"\n" lightjittersin1speed to:outStr
			format "\t\"$lightjittersin1dispersion\" \"%\"\n" lightjittersin1dispersion to:outStr
			format "\t\"$lightjittersin2angle\" \"%\"\n" lightjittersin2angle to:outStr
			format "\t\"$lightjittersin2speed\" \"%\"\n" lightjittersin2speed to:outStr
			format "\t\"$lightjittersin2dispersion\" \"%\"\n" lightjittersin2dispersion to:outStr
			format "\t\"$lightjittersin3angle\" \"%\"\n" lightjittersin3angle to:outStr
			format "\t\"$lightjittersin3speed\" \"%\"\n" lightjittersin3speed to:outStr
			format "\t\"$lightjittersin3dispersion\" \"%\"\n" lightjittersin3dispersion to:outStr
			format "\t\"$lightjittergustmultiplier\" \"%\"\n" lightjittergustmultiplier to:outStr
			format "\t\"$lightjittergustspeed\" \"%\"\n" lightjittergustspeed to:outStr
		)

		if valveShader == "WorldVertexTransition" AND forModelCheck == false then (
			if use_seamless_scale == true then (
				format "\t\"$seamless_scale\" \"%\"\n" seamless_scale to:outStr
			)

			if detail != "" then (
				format "\t\"\%detailtype\" \"%\"\n" detail to:outStr
			)

			if surfaceproperty2 != "" then (
				format "\t\"$surfaceprop2\" \"%\"\n" surfaceproperty2 to:outStr
			)

			if ssbump2 == true then (
				format ("\t\"$ssbump2\" 1\n") to:outStr
			)
		)

		(outStr as String)
	)

	/*
	on update do (
		if version < 17 then (
			if phongfresnelranges != "" then (
				--print "Houston, we have a problem."
				--phongfresnelranges = setPointThreeFromString arg
			)
		)

	)*/

)

global wallworm_texture_CA = attributes "wallworm_texture_CA" version:20 (
	local wallworm = true
	local thisNode
	local textureFlagsRollout, setFlagChecks, params
	function getNode refresh:false = (
		if thisNode == undefined OR refresh == true then (
			thisNode = custAttributes.getOwner this
		)
		thisNode
	)

	function setGlobalCompressionVals = (
		if ::WallWormVTFCompressionListPRO == undefined then (
			/*
			Not currently Available
			"P8", \
			"R32F", \
			"RGB323232F", \
			"RGBA32323232F", \
			"NV_INTZ", \
			"NV_RAWZ", \
			"NV_NULL", \
			"ATI1N", \
			*/

			::WallWormVTFCompressionListPRO = #(
				"RGBA8888",
				"ABGR8888",
				"RGB888",
				"BGR888",
				"RGB565",
				"I8",
				"IA88",
				"A8",
				"RGB888_BLUESCREEN",
				"BGR888_BLUESCREEN",
				"ARGB8888",
				"BGRA8888",
				"DXT1",
				"DXT3",
				"DXT5",
				"BGRX8888",
				"BGR565",
				"BGRX5551",
				"BGRA4444",
				"DXT1_ONEBITALPHA",
				"BGRA5551",
				"UV88",
				"UVWQ8888",
				"RGBA16161616F",
				"RGBA16161616",
				"UVLX8888",
				"NV_DST16",
				"NV_DST24",
				"ATI_DST16",
				"ATI_DST24",
				"ATI2N",
				"NONE"
			)
		)
		if ::WallWormVTFCompressionList == undefined then (
			::WallWormVTFCompressionList = #(
				"DXT1",
				"DXT5",
				"NONE"
			)
		)

	)
	local vtfVersions = #("7.0", "7.1", "7.2", "7.3", "7.4", "7.5")
	local conversionmethods = #("ALPHA","AVERAGERGB","BIASEDRGB","RED","GREEN","BLUE","MAXRGB","COLORSPACE")
	local kernalfilters = #("4X","3X3","5X5","7X7","9X9","DUDV")
	local alpharesults = #("NOCHANGE","HEIGHT","BLACK","WHITE")
	local resizemethods = #("NEAREST","BIGGEST","SMALLEST")
	local sharpenfilters = #("CONTOUR", "CONTRASTLESS", "CONTRASTMORE", "DARKER", "EDGEDETECT", "EDGEDETECTSOFT", "EMBOSS", "FINDEDGES", "LIGHTER", "MEANREMOVAL", "NEGATIVE", "NONE", "SHARPENMEDIUM", "SHARPENSOFT", "SHARPENSTRONG", "SMOOTHEN", "UNSHARP", "WARPSHARP", "XSHARPEN")
	local mipmapFilters = #("BESSEL", "BLACKMAN", "BOX", "CATROM", "CUBIC", "GAUSSIAN", "HAMMING", "HANNING", "KAISER", "MITCHELL", "POINT", "QUADRATIC", "SINC", "TRIANGLE")

	--BEGIN IGNORE FORMAT
	local wwTextureFlags_PointSample		= 0x00000001
	local wwTextureFlags_Trilinear			= 0x00000002
	local wwTextureFlags_ClampS				= 0x00000004
	local wwTextureFlags_ClampT				= 0x00000008
	local wwTextureFlags_Anisotropic		= 0x00000010
	local wwTextureFlags_Hint_DXT5			= 0x00000020
	local wwTextureFlags_SRGB				= 0x00000040
	local wwTextureFlags_Normal				= 0x00000080
	local wwTextureFlags_NoMip				= 0x00000100
	local wwTextureFlags_NoLOD				= 0x00000200
	local wwTextureFlags_MinMip				= 0x00000400
	local wwTextureFlags_Procedural			= 0x00000800
	local wwTextureFlags_OneBitAlpha		= 0x00001000
	local wwTextureFlags_EightBitAlpha		= 0x00002000
	local wwTextureFlags_EnvMap				= 0x00004000
	local wwTextureFlags_RenderTarget		= 0x00008000
	local wwTextureFlags_DepthRenderTarget	= 0x00010000
	local wwTextureFlags_NoDebugOverride	= 0x00020000
	local wwTextureFlags_SingleCopy			= 0x00040000
	local wwTextureFlags_Deprecated_OneOverMipLevelInAlpha			= 0x00080000
	local wwTextureFlags_Deprecated_PreMultColorByOneOverMipLevel	= 0x00100000
	local wwTextureFlags_Deprecated_NormalToDuDv					= 0x00200000
	local wwTextureFlags_Deprecated_AlphaTestMipGeneration			= 0x00400000
	local wwTextureFlags_NoDepthBuffer				= 0x00800000
	local wwTextureFlags_Deprecated_NiceFiltered	= 0x01000000
	local wwTextureFlags_ClampU						= 0x02000000
	local wwTextureFlags_VertexTexture				= 0x04000000
	local wwTextureFlags_SSBump						= 0x08000000
	local wwTextureFlags_Deprecated_Unfilterable_OK	= 0x10000000
	local wwTextureFlags_Border						= 0x20000000
	local wwTextureFlags_Deprecated_SpecVar_Red		= 0x40000000
	local wwTextureFlags_Deprecated_SpecVar_Alpha	= 0x80000000
	--END IGNORE FORMAT

	parameters main rollout:params (
		vtfpath type:#string ui:edt_vtfpath default:""
		vmtproperties type:#stringtab tabSizeVariable:true
		compression type:#string default:"DXT5" ui:edt_compression
		vtfframes type:#intTab tabSizeVariable:true
		animatedVTF type:#boolean default:false ui:chkAnimatedVTF
		frameType type:#integer ui:drp_frameType default:1 -- default:auto  #("Auto","Bitmap Frames","Timeline","Specified")	
		textureFlags type:#integer default:0
		vtfWidth type:#integer default:512 ui:sp_vtfWidth
		vtfHeight type:#integer default:512 ui:sp_vtfHeight
		renderscale type:#float default:1.0 ui:sp_renderScale
		useVTFDimensions type:#boolean default:false ui:chk_useVTFDimensions
		useVTFVersion type:#boolean default:false ui:chk_useVTFVersion
		vtfVersion type:#integer default:5 ui:drpvtfVersion
		useGammaCorrection type:#boolean default:false ui:chk_useGammaCorrection
		gcorrection type:#float default:2.2 ui:sp_gcorrection
		convertToNormal type:#boolean default:false ui:chk_convertToNormal
		useNScale type:#boolean default:false ui:chk_useNScale
		nscale type:#float default:1.0 ui:sp_nscale
		nwrap type:#boolean default:false ui:chk_nwrap
		nkernel type:#integer default:2 ui:drp_nkernel     --  (Normal map generation kernel to use.)
		nheight type:#integer default:2 ui:drp_nheight     --   (Normal map height calculation to use.)
		nalpha  type:#integer default:4 ui:drp_nalpha       --   (Normal map alpha result to set.)

		bumpscale type:#float default:1.0 ui:sp_bumpscale
		nothumbnail type:#boolean default:false ui:chk_nothumbnail
		noreflectivity type:#boolean default:false ui:noreflectivity
		mfilter type:#integer  default:3 ui:drp_mfilter   -- mipmapFilters   
		msharpen type:#integer default:12  ui:drp_msharpen   -- sharpenfilters 

		rmethod type:#integer default:1 ui:drp_rmethod --resizemethods
		rfilter type:#integer  default:14 ui:drp_rfilter   -- mipmapFilters   
		rsharpen type:#integer default:12  ui:drp_rsharpen   -- sharpenfilters 

		on compression set val do (
			setGlobalCompressionVals()
			if findItem ::WallWormVTFCompressionListPRO (toUpper val) == 0 then (
				getNode()
				if thisNode == undefined OR NOT hasProperty thisNode #alphaSource then (
					compression = "DXT5"
				) else if thisNode.alphasource == 2 then (
					compression = "DXT1"
				) else (
					compression = "DXT5"
				)
			)
		)
		on textureFlags set val do (
			if setFlagChecks != undefined then (
				setFlagChecks()
			)
		)
	)

	function setFlagChecks = (
		textureFlagsRollout.chTextureFlags_PointSample.checked = (bit.and textureFlags wwTextureflags_PointSample) != 0
		textureFlagsRollout.chTextureFlags_Trilinear.checked = (bit.and textureFlags wwTextureflags_Trilinear) != 0
		textureFlagsRollout.chTextureFlags_ClampS.checked = (bit.and textureFlags wwTextureflags_ClampS) != 0
		textureFlagsRollout.chTextureFlags_ClampT.checked = (bit.and textureFlags wwTextureflags_ClampT) != 0
		textureFlagsRollout.chTextureFlags_Anisotropic.checked = (bit.and textureFlags wwTextureflags_Anisotropic) != 0
		textureFlagsRollout.chTextureFlags_Hint_DXT5.checked = (bit.and textureFlags wwTextureflags_Hint_DXT5) != 0
		textureFlagsRollout.chTextureFlags_SRGB.checked = (bit.and textureFlags wwTextureflags_SRGB) != 0
		textureFlagsRollout.chTextureFlags_Normal.checked = (bit.and textureFlags wwTextureflags_Normal) != 0
		params.chTextureFlags_Normal.checked = (bit.and textureFlags wwTextureflags_Normal) != 0
		textureFlagsRollout.chTextureFlags_NoMip.checked = (bit.and textureFlags wwTextureflags_NoMip) != 0
		params.chkmipmap.checked  = (bit.and textureFlags wwTextureflags_NoMip) == 0
		textureFlagsRollout.chTextureFlags_NoLOD.checked = (bit.and textureFlags wwTextureflags_NoLOD) != 0
		textureFlagsRollout.chTextureFlags_MinMip.checked = (bit.and textureFlags wwTextureflags_MinMip) != 0
		textureFlagsRollout.chTextureFlags_Procedural.checked = (bit.and textureFlags wwTextureflags_Procedural) != 0
		textureFlagsRollout.chTextureFlags_OneBitAlpha.checked = (bit.and textureFlags wwTextureflags_OneBitAlpha) != 0
		textureFlagsRollout.chTextureFlags_EightBitAlpha.checked = (bit.and textureFlags wwTextureflags_EightBitAlpha) != 0
		textureFlagsRollout.chTextureFlags_EnvMap.checked = (bit.and textureFlags wwTextureflags_EnvMap) != 0
		textureFlagsRollout.chTextureFlags_RenderTarget.checked = (bit.and textureFlags wwTextureflags_RenderTarget) != 0
		textureFlagsRollout.chTextureFlags_DepthRenderTarget.checked = (bit.and textureFlags wwTextureflags_DepthRenderTarget) != 0
		textureFlagsRollout.chTextureFlags_NoDebugOverride.checked = (bit.and textureFlags wwTextureflags_NoDebugOverride) != 0
		textureFlagsRollout.chTextureFlags_SingleCopy.checked = (bit.and textureFlags wwTextureflags_SingleCopy) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_OneOverMipLevelInAlpha.checked = (bit.and textureFlags wwTextureflags_Deprecated_OneOverMipLevelInAlpha) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_PreMultColorByOneOverMipLevel.checked = (bit.and textureFlags wwTextureflags_Deprecated_PreMultColorByOneOverMipLevel) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_NormalToDuDv.checked = (bit.and textureFlags wwTextureflags_Deprecated_NormalToDuDv) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_AlphaTestMipGeneration.checked = (bit.and textureFlags wwTextureflags_Deprecated_AlphaTestMipGeneration) != 0
		textureFlagsRollout.chTextureFlags_NoDepthBuffer.checked = (bit.and textureFlags wwTextureflags_NoDepthBuffer) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_NiceFiltered.checked = (bit.and textureFlags wwTextureflags_Deprecated_NiceFiltered) != 0
		textureFlagsRollout.chTextureFlags_ClampU.checked = (bit.and textureFlags wwTextureflags_ClampU) != 0
		textureFlagsRollout.chTextureFlags_VertexTexture.checked = (bit.and textureFlags wwTextureflags_VertexTexture) != 0
		textureFlagsRollout.chTextureFlags_SSBump.checked = (bit.and textureFlags wwTextureflags_SSBump) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_Unfilterable_OK.checked = (bit.and textureFlags wwTextureflags_Deprecated_Unfilterable_OK) != 0
		textureFlagsRollout.chTextureFlags_Border.checked = (bit.and textureFlags wwTextureflags_Border) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_SpecVar_Red.checked = (bit.and textureFlags wwTextureflags_Deprecated_SpecVar_Red) != 0
		textureFlagsRollout.chTextureFlags_Deprecated_SpecVar_Alpha.checked = (bit.and textureFlags wwTextureflags_Deprecated_SpecVar_Alpha) != 0
		
		
	)

	function getCompileString = (
		local normalString = ""
		local nomimmap = ""
		local flagString = StringStream ""
		if (bit.and textureFlags wwTextureflags_PointSample) != 0 then format " -flag \"POINTSAMPLE\"" to:flagString
		if (bit.and textureFlags wwTextureflags_Trilinear) != 0 then format " -flag \"TRILINEAR\"" to:flagString
		if (bit.and textureFlags wwTextureflags_ClampS) != 0 then format " -flag \"CLAMPS\"" to:flagString
		if (bit.and textureFlags wwTextureflags_ClampT) != 0 then format " -flag \"CLAMPT\"" to:flagString
		if (bit.and textureFlags wwTextureflags_Anisotropic) != 0 then format " -flag \"ANISOTROPIC\"" to:flagString
		if (bit.and textureFlags wwTextureflags_Hint_DXT5) != 0 then format " -flag \"HINT_DXT5\"" to:flagString
		--if (bit.and textureFlags wwTextureflags_SRGB) != 0 then format " -flag \"SRGB\"" to:flagString
		
		if convertToNormal then (
			normalString = StringStream ""
			format " -normal" to:normalString
			format " -nkernel %" kernalfilters[nkernel] to:normalString
			format " -nheight %" conversionmethods[nheight] to:normalString
			format " -nalpha %" alpharesults[nalpha] to:normalString
			
			if useNScale then (
				format " -nscale %" nscale to:normalString
			)
			if nwrap then (
				format " -nwrap" to:normalString
			)
			normalString = normalString as String
		)

		if (bit.and textureFlags wwTextureflags_Normal) != 0 then (
			format " -flag \"NORMAL\"" to:flagString


		)
		if (bit.and textureFlags wwTextureflags_NoMip) != 0 then (
			format " -flag \"NOMIP\"" to:flagString
			nomimmap = " -nomipmaps"
		) else (
			
			nomimmap = stringstream ""
			format " -mfilter \"%\"" mipmapFilters[mfilter] to:nomimmap
			format " -msharpen \"%\"" sharpenfilters[msharpen] to:nomimmap
			nomimmap = nomimmap as string
		)
		if (bit.and textureFlags wwTextureflags_NoLOD) != 0 then format " -flag \"NOLOD\"" to:flagString
		if (bit.and textureFlags wwTextureflags_MinMip) != 0 then format " -flag \"MINMIP\"" to:flagString
		if (bit.and textureFlags wwTextureflags_Procedural) != 0 then format " -flag \"PROCEDURAL\"" to:flagString
		if (bit.and textureFlags wwTextureflags_EnvMap) != 0 then format " -flag \"ENVMAP\"" to:flagString
		if (bit.and textureFlags wwTextureflags_RenderTarget) != 0 then format " -flag \"RENDERTARGET\"" to:flagString
		if (bit.and textureFlags wwTextureflags_DepthRenderTarget) != 0 then format " -flag \"DEPTHRENDERTARGET\"" to:flagString
		if (bit.and textureFlags wwTextureflags_NoDebugOverride) != 0 then format " -flag \"NODEBUGOVERRIDE\"" to:flagString
		if (bit.and textureFlags wwTextureflags_SingleCopy) != 0 then format " -flag \"SINGLECOPY\"" to:flagString
		if (bit.and textureFlags wwTextureflags_Border) != 0 then format " -flag \"BORDER\"" to:flagString
		if (bit.and textureFlags wwTextureflags_NoDepthBuffer) != 0 then format " -flag \"NODEPTHBUFFER\"" to:flagString
		if (bit.and textureFlags wwTextureflags_ClampU) != 0 then format " -flag \"CLAMPU\"" to:flagString
		if (bit.and textureFlags wwTextureflags_VertexTexture) != 0 then format " -flag \"VERTEXTEXTURE\"" to:flagString
		if (bit.and textureFlags wwTextureflags_SSBump) != 0 then format " -flag \"SSBUMP\"" to:flagString

		local vtfv = ::WallWormVTFVersion
		if useVTFVersion == true then (
			vtfv = vtfVersions[vtfVersion]
		)

		local gammaString = ""
		if useGammaCorrection then (
			gammaString = (" -gamma -gcorrection " + (gcorrection as String))
		)

		local noreflectivityStr = ""
		if noreflectivity then (
			noreflectivityStr = " -noreflectivity"
		)

		local nothumbnailStr = ""
		if nothumbnail then (
			nothumbnailStr = " -nothumbnail"
		)

		local out = StringStream ""
		format " -version \"%\" -format \"%\"  -alphaformat \"%\"%%% -bumpscale %%%%" vtfv (toLower compression) (toLower compression) normalString nomimmap gammaString bumpscale nothumbnailStr noreflectivityStr (flagString as String) to:out
		(out as String)
	)

	function setTextureFlag flag val:true = (
		if val == true then (
			textureFlags = bit.or textureFlags flag
		) else (
			textureFlags = bit.and textureFlags (bit.not flag)
		)
	)

	function writeme = (
		getNode()
		if ::wallworm_make_vtf == undefined AND ::wallworm_installation_path != undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
		)
		if ::wallworm_make_vtf != undefined then (
			::wallworm_make_vtf thisNode
		)
	)

	function setDimensionFromBitmap force:false = (
		getNode()
		if force == true OR classOf thisNode == BitmapTexture then (
			local substancenode
			case (classOf thisNode) of (
				MultiOutputChannelTexmapToTexmap:(
					substancenode = thisNode.sourceMap
				)
				output:(
					substancenode = thisNode.map1
				)
				BitmapTexture:(
					local bm
					try(
						bm = thisNode.Bitmap
						if bm != undefined AND isProperty bm #width AND bm.width != undefined then (
							vtfWidth = bm.width
							vtfHeight = bm.height
						)
					) catch ()
				)
				default:()
			)
			if classOf substancenode == Substance then (
				vtfWidth = substancenode.localAbsoluteTextureWidth
				vtfHeight = substancenode.localAbsoluteTextureHeight
			)
		)
	)
	function setDefaultsFromBitmap = (
		getNode()
		setDimensionFromBitmap force:true
		if classOf thisNode == BitmapTexture AND thisNode.filename != undefined then (
			if ::wallworm_parseIFL == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			if ::wallworm_parseIFL != undefined then (
				local texlist = ::wallworm_parseIFL thisNode.filename
				if texlist.count > 1 then (
					animatedVTF = true
					frameType = 2
				)
			)
			compression = "DXT1"
			--setSilentMode sl
		) else (
			compression = "DXT1"
			local substancenode
			case (classOf thisNode) of (
				MultiOutputChannelTexmapToTexmap:(
					substancenode = thisNode.sourceMap
				)
				output:(
					substancenode = thisNode.map1
				)
				default:()
			)
			if classOf substancenode == Substance then (
				vtfWidth = substancenode.localAbsoluteTextureWidth
				vtfHeight = substancenode.localAbsoluteTextureHeight
			)
		)
		vtfpath = ::wallworm_texture_path thisNode
		case of (
			(matchPattern vtfpath pattern:"*.tga.vtf*"):(
				vtfpath = substituteString vtfpath ".tga.vtf" ".vtf"
			)
			(matchPattern vtfpath pattern:"*.psd.vtf*"):(
				vtfpath = substituteString vtfpath ".psd.vtf" ".vtf"
			)
			(matchPattern vtfpath pattern:"*.pfm.vtf*"):(
				vtfpath = substituteString vtfpath ".pfm.vtf" ".vtf"
			)
			(matchPattern vtfpath pattern:"*.bmp.vtf*"):(
				vtfpath = substituteString vtfpath ".bmp.vtf" ".vtf"
			)
			(matchPattern vtfpath pattern:"*.jpg.vtf*"):(
				vtfpath = substituteString vtfpath ".jpg.vtf" ".vtf"
			)
		)
	)

	function getFileName = (
		getNode()
		if ::wallworm_texture_path == undefined AND ::wallworm_installation_path != undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
		)
		if ::wallworm_texture_path != undefined then (
			(::wallworm_texture_path thisNode matRoot:true addGameDir:true fs:true)
		) else (
			undefined
		)
	)

	function updatePropertiesUI = (
		params.lbVmtProperties.items = (vmtproperties as Array)
	)

	function getTGAPath frame:undefined = (
		local thisoutfilename = ""
		getNode()
		if ::wwmt_exportMats != undefined AND vtfpath != "" then (
			local thisoutfilename = ::wwmt_exportMats + "/" + vtfpath
			if ::wallworm_engine == 1 then (
				thisoutfilename = substituteString thisoutfilename ".vtf" ".bmp"
				thisoutfilename = substituteString thisoutfilename ".VTF" ".bmp"
				thisoutfilename = substituteString thisoutfilename ".tga" ".bmp"
				thisoutfilename = substituteString thisoutfilename ".tga" ".bmp"
			) else (
				thisoutfilename = substituteString thisoutfilename ".vtf" ".tga"
				thisoutfilename = substituteString thisoutfilename ".VTF" ".tga"					
			)
		)
		thisoutfilename
	)

	function getActualFileName = (
		getNode()
		if classOf thisNode == BitmapTexture then (
			thisNode.filename
		) else (
			getTGAPath()
		)
	)

	function renderMeToTGA disp:false = (
		getNode()
		local proceed = false
		if ::wwmt_exportMats != undefined AND vtfpath != "" then (
			local thisoutfilename = getTGAPath()
			local outpath = (getFilenamePath thisoutfilename)
			proceed = doesFileExist outpath
			if NOT proceed then (
				proceed = makeDir outpath all:true
			)
			if proceed then (
				if classOf thisNode == BitmapTexture AND pathConfig.pathsResolveEquivalent thisNode.filename thisoutfilename == true then (
					proceed = false --we don't want to overwrite this file with a render of itself
				)
			)
			if proceed then (
				if doesFileExist thisoutfilename then (
					deleteFile thisoutfilename
				)
				local theBM
				if (bit.and textureFlags wwTextureflags_Normal) != 0 then (
					theBM = Bitmap vtfWidth vtfHeight filename:thisoutfilename gamma:1.0
				) else (
					theBM = Bitmap vtfWidth vtfHeight filename:thisoutfilename
				)
				/*
				local coordsobj 
				if hasProperty thisNode #coords then (
					coordsobj = thisNode.coords
					print (coordsobj.coordType as string)
					if (hasProperty coordsobj #coordType  AND coordsobj.coordType  != 2) then (
						renderScale = 1.0 / vtfWidth
					) 		
				) else if hasProperty thisNode #coordinates then (
					coordsobj = thisNode.coordinates
					if (hasProperty coordsobj #mapping AND coordsobj.mapping != 0) then (
						renderScale = 1.0 / vtfWidth						
					) 
				)
				*/
				rendermap thisNode into:theBM display:disp filter:true scale:renderScale
				save theBM
				if NOT disp then (
					close theBM
				)
			)
		)
		proceed
	)

	function hasFrames = (
		getNode()
		local result = false
		if thisNode != undefined AND classOf thisNode == BitmapTexture then (
			if toLower (getFileNameType thisNode.filename) == ".ifl" then (
				result = true
			)
		)
		result
	)

	function getFrames steFrames:false setAnimIfTrue:false = (
		local texlist = #((getTGAPath()))
		if (hasFrames()) == true then (
			texlist = wallworm_parseIFL thisNode.filename
			if setFrames == true then (
				frameType = 2
			)
			if setAnimIfTrue == true then (
				animatedVTF = true
			)
		)
		texlist
	)

	rollout params "Wall Worm Texture Properties" (
		EditText edt_vtfpath "Path"
		Group "VTF Dimensions" (
			Spinner sp_vtfWidth "W" type:#integer align:#left range:[8, 4096, 512] scale:1 across:3 --enabled:(::WallWormProSMD != undefined)
			Spinner sp_vtfHeight "H" type:#integer align:#left range:[8, 4096, 512] scale:1 --enabled:(::WallWormProSMD != undefined)
			Button btnGetDimensions "Get Dimensions"
			
			DropDownList drp_rmethod "Resize Method" align:#left across:3 tooltip:"Method for determining nearest resize value." items:resizemethods
			DropDownList drp_rfilter "Resize Filter" align:#left tooltip:"Resizing Filter." items:mipmapFilters
			DropDownList drp_rsharpen "Resize Sharpening" align:#left tooltip:"Method for determining nearest resize value." items:sharpenfilters
			
			CheckBox chk_useVTFDimensions "Override Bitmap Dimensions in VMF Exporter" tooltip:"When on, these dimensions override the actual bitmap dimensions in the VMF Exporter."
		)
		on btnGetDimensions pressed do (
			setDimensionFromBitmap force:true
		)

		Spinner sp_renderScale "Scale"  across:3 range:[0.001,4096,1] align:#left tooltip:"Use this to fix some procedural textures that render at wrong scale."
		Button btnRenderToTGA "Render to TGA" tooltip:"Render out the TGA if you do not have WW Pro and VTF write support. Right-Click to display bitmap." align:#left offset:[-14,0]
		--Spinner spGamma "Bitmap Render Gamma" type:#float tooltip:"Gamma to use in the output file."
		Button btnExport "Export Texture as VTF" tooltip:"Export this texture now." align:#right
		EditText edt_vmtproperty "Parameter"
		DropDownList drpMapNames "" items:#(
			"",
			"basetexture",
			"normalmap",
			"bumpmap",
			"envmapmask",
			"AmbientOcclusion",
			"detail",
			"selfillumtexture",
			"selfillummask",
			"phongexponenttexture",
			"refracttinttexture",
			"lightwarptexture",
			"parallaxmap",
			"blendmodulatetexture",
			"lightwarptexture2",
			"basetexture2",
			"normalmap2",
			"bumpmap2",
			"envmapmask2",
			"detail2",
			"selfillumtexture2",
			"selfillummask2",
			"compress",
			"stretch",
			"bumpcompress",
			"bumpstretch"
		)
		ListBox lbVmtProperties "Texures To Reuse This Map" items:(vmtproperties as Array) height:4
		Button btnDeleteProp "Delete Selected Texture Parameter"
		EditText edt_compression "Compression"
		DropDownList drp_compression ""
		Group "Animated VTF" (
			CheckBox chkAnimatedVTF "Animated VTF" tooltip:"When on, exports a VTF with animation frames."
			DropDownList drp_frameType "Frames From" items:#("Auto", "Bitmap Frames", "Timeline", "Specified")
			EditText edt_vtfframes "Frames" enabled:(frameType == 4)
		)

		Group "Misc VTF Settings" (
			CheckBox chk_useGammaCorrection "Use Gamma Correction" across:2
			Spinner sp_gcorrection "Gamma Correction" type:#float range:[0.1, 8.0, 2.2] enabled:useGammaCorrection fieldwidth:40
			CheckBox chk_useVTFVersion "Override Version" across:2
			DropDownList drpvtfVersion "VTF Version" items:#("7.0", "7.1", "7.2", "7.3", "7.4", "7.5") enabled:useVTFVersion
			CheckBox chk_nothumbnail "No Thumbnail"
			CheckBox noreflectivity "No Reflectivity"
		)
		Group "Normal Map and Bump" (
			CheckBox chTextureFlags_Normal "Normal Map" tooltip:"For normal maps. Used to prevent compression artifacts caused by DXTn compression which distort the smooth gradients on most normal maps. Leaves texture uncompressed and sets Trilinear flag to force Trilinear filtering. Furthermore, all normals will be kept normalized during mipmap generation. "
			CheckBox chk_convertToNormal "Convert to Normal" tooltip:"Convert this bitmap into a normal map."
			DropDownList drp_nkernel "Normal Kernel" items:kernalfilters across:3
			DropDownList drp_nheight "Height Source" items:conversionmethods
			DropDownList drp_nalpha "Alpha Result Set To" items:alpharesults
			CheckBox chk_useNScale "Use Normal Scale" across:2
			Spinner sp_nscale "Normal Scale" type:#float fieldwidth:40 enabled:useNScale
			CheckBox chk_nwrap "Wrap Normal"
			Spinner sp_bumpscale "Bump Scale" type:#float fieldwidth:40
		)
		Group "Mip Mapping" (
			CheckBox chkmipmap "Mip Maps"
			DropDownList drp_mfilter "Mipmap Filter" items:mipmapFilters
			DropDownList drp_msharpen "Mipmap Sharpen" items:sharpenfilters		
		)
		on chkmipmap changed stat do (
			setTextureFlag wwTextureFlags_NoMip val:(NOT stat)
			textureFlagsRollout.chTextureFlags_NoMip.checked = (NOT stat)
		)
		
		on chk_useNScale changed stat do (
			sp_nscale.enabled = useNScale
		)

		on chTextureFlags_Normal changed stat do (
			setTextureFlag wwTextureFlags_Normal val:stat
			textureFlagsRollout.chTextureFlags_Normal.checked = stat
		)
		on chk_useVTFVersion changed stat do (
			drpvtfVersion.enabled = useVTFVersion
		)
		on chk_useGammaCorrection changed stat do (
			sp_gcorrection.enabled = useGammaCorrection
		)

		on btnRenderToTGA pressed do (
			if NOT (renderMeToTGA()) then (
				messageBox "The TGA was not written."
			)
		)
		on btnRenderToTGA rightClick do (
			if NOT (renderMeToTGA disp:true) then (
				messageBox "The TGA was not written."
			)
		)
		on btnExport pressed do (
			writeme()
		)
		function setCompressionList = (
			local thisItems = drp_compression.items
			if ::ww_wwmt_version == undefined AND ::wallworm_installation_path != undefined then (
				fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
			)
			if (::WallWormProSMD != undefined) then (
				join thisItems ::WallWormVTFCompressionListPRO
			) else (
				join thisItems ::WallWormVTFCompressionList
			)
			if findItem thisItems compression == 0 then (
				append thisItems (toUpper compression)
			)
			thisItems = makeUniqueArray thisItems
			drp_compression.items = sort thisItems
			if compression != undefined then (
				drp_compression.selection = findItem drp_compression.items (toUpper compression)
			)
		)
		on params open do (
			setGlobalCompressionVals()
			setCompressionList()
			if vtfframes != undefined AND vtfframes.count > 0 then (
				local FrameList = StringStream ""
				local hasStarted = false
				local comma = ","
				for i in (vtfframes as Array) do (
					if hasStarted == true then (
						format comma to:FrameList
					)
					format "%" i to:FrameList
					if hasStarted == false then (
						hasStarted = true
					)
				)
				edt_vtfframes.text = (FrameList as String)
			)
			setFlagChecks()

			updatePropertiesUI()

		)
		function addToProperties prop = (
			if findItem vmtproperties prop == 0 then (
				append vmtproperties prop
			)
			updatePropertiesUI()
		)

		function deleteFromProperties prop = (
			local index = findItem vmtproperties prop
			if index != 0 then (
				deleteItem vmtproperties index
				vmtproperties = for p in vmtproperties WHERE p != undefined AND p != "" collect p
				updatePropertiesUI()
			)
		)

		on btnDeleteProp pressed do (
			if lbVmtProperties.selected != undefined then (
				deleteFromProperties lbVmtProperties.selected
			)
		)

		on drpMapNames selected sel do (
			addToProperties drpMapNames.selected
		)
		on edt_vmtproperty entered tex do (
			addToProperties tex
		)

		on drp_frameType selected sel do (
			edt_vtfframes.enabled = (frameType == 4)
		)
		on edt_vtfframes entered tex do (
			if tex != undefined then (
				local fs = filterString (edt_vtfframes.text) ","
				if fs.count > 0 then (
					vtfframes = for i in fs WHERE i != undefined AND i != "" AND ((i as Integer) != undefined) collect (i as Integer)
				)
			)
		)
		function testcompression = (
			local upComp = (toUpper compression)
			local isInPro = (findItem ::WallWormVTFCompressionListPro upComp != 0)
			local out = true
			if (::WallWormProSMD == undefined) then (
				if findItem ::WallWormVTFCompressionList upComp == 0 then (
					if isInPro then (
						if (queryBox "The Compression Value isn't available unless you have Wall Worm Pro. Would you like to learn about WW Pro?") == true then (
							macros.run "wallworm.com" "WallWormWebProductsProMCR"
						)
					) else (
						messageBox "This is not currently an available compression setting."
					)
					out = false
				) else (
					out = true
				)
			) else if NOT isInPro then (
				out = false
				messageBox "This is not currently an available compression setting."
			)
			out
		)
		on edt_compression entered tex do (
			testcompression()
			setCompressionList()
		)

		on drp_compression selected sel do (
			compression = drp_compression.selected
			edt_compression.text = drp_compression.selected
			testcompression()
		)

	)

	rollout textureFlagsRollout "Texture Flags" (
		Label lblFlagsNotice "Flags only export with  " align:#left across:2
		Hyperlink hyperWWPRoFlags "Wall Worm Pro" align:#left address:"http://dev.wallworm.com/topic/69/wall_worm_pro.html" color:blue hoverColor:red visitedColor:blue
		Group "Common Flags" (
			CheckBox chTextureFlags_ClampS "Clamp S" tooltip:"Do not allow the texture to wrap in the S. Useful for sprites, sky, etc."
			CheckBox chTextureFlags_ClampT "Clamp T" tooltip:"Do not allow the texture to wrap in the T. Useful for sprites, sky, etc."
			CheckBox chTextureFlags_Normal "Normal Map" tooltip:"For normal maps. Used to prevent compression artifacts caused by DXTn compression which distort the smooth gradients on most normal maps. Leaves texture uncompressed and sets Trilinear flag to force Trilinear filtering. Furthermore, all normals will be kept normalized during mipmap generation. "
			CheckBox chTextureFlags_NoMip "No Mip" tooltip:"Do not use mip-levels for this texture. Used for materials like skyboxes and menu backgrounds."
			CheckBox chTextureFlags_NoLOD "No LOD" tooltip:"Do not use lower quality versions of this texture in lower DirectX versions. Used for non-world graphics such as HUD art. "
			CheckBox chTextureFlags_MinMip "Min Mip"
		)

		Group "Alpha Channel Flags" (
			CheckBox chTextureFlags_OneBitAlpha "1-Bit Alpha"
			CheckBox chTextureFlags_EightBitAlpha "8-Bit Alpha"
		)

		Group "Texture Flags" (
			CheckBox chTextureFlags_EnvMap "Environment Map"
			CheckBox chTextureFlags_Hint_DXT5 "Hint DXT5" tooltip:"Use DXT5 compression instead of full compression. "
			CheckBox chTextureFlags_PointSample "Point Sample" tooltip:"Do not filter this texture in-game."
			CheckBox chTextureFlags_Trilinear "Trilinear" tooltip:"Force at least Trilinear filtering on the compiled texture. "
			CheckBox chTextureFlags_ClampU "Clamp U" tooltip:"Do not allow the texture to wrap in the U. Useful for sprites, sky, etc."
			CheckBox chTextureFlags_Anisotropic "Anisotropic" tooltip:"Force at least Anisotropic filtering on the compiled texture. "
			CheckBox chTextureFlags_SRGB "SRGB"

			CheckBox chTextureFlags_Procedural "Procedural" tooltip:"Texture is procedural."
			CheckBox chTextureFlags_RenderTarget "Render Target" tooltip:"Texture is a rendertarget."
			CheckBox chTextureFlags_DepthRenderTarget "Depth Render Target"
			CheckBox chTextureFlags_NoDebugOverride "No Debug Override"
			CheckBox chTextureFlags_SingleCopy "Single Copy"
			CheckBox chTextureFlags_NoDepthBuffer "No Depth Buffer"
			CheckBox chTextureFlags_VertexTexture "Vertex Texture"
			CheckBox chTextureFlags_SSBump "Self-Shadowing Bump" tooltip:"Used for self-shadowing bump maps."
			CheckBox chTextureFlags_Border "Border"
		)

		Group "Deprecated Texture Flags" (
			CheckBox chTextureFlags_Deprecated_OneOverMipLevelInAlpha "One Over Mip Level In Alpha"
			CheckBox chTextureFlags_Deprecated_PreMultColorByOneOverMipLevel "Premultiply Color by One Over Mip Level"
			CheckBox chTextureFlags_Deprecated_NormalToDuDv "Deprecated Normal to Du Dv"
			CheckBox chTextureFlags_Deprecated_AlphaTestMipGeneration "Alpha Test Mip Generation"
			CheckBox chTextureFlags_Deprecated_NiceFiltered "Nice Filtered"
			CheckBox chTextureFlags_Deprecated_Unfilterable_OK "Unfilterable OK"
			CheckBox chTextureFlags_Deprecated_SpecVar_Red "Spec Var Red"
			CheckBox chTextureFlags_Deprecated_SpecVar_Alpha "Spec Var Alpha"
		)

		-- Once the list of flags is isolated into a flat list, the regex:
		/**
		on ch$1 changed stat do \(
			setTextureFlag ww$1 val:stat
			\)
		*/
		-- Can be used to generate these on changed functions.
		on chTextureFlags_ClampS changed stat do (setTextureFlag wwTextureFlags_ClampS val:stat)
		on chTextureFlags_ClampT changed stat do (setTextureFlag wwTextureFlags_ClampT val:stat)
		on chTextureFlags_Normal changed stat do (
			setTextureFlag wwTextureFlags_Normal val:stat
			params.chTextureFlags_Normal.checked = stat
		)
		on chTextureFlags_NoMip changed stat do (setTextureFlag wwTextureFlags_NoMip val:stat)
		on chTextureFlags_NoLOD changed stat do (setTextureFlag wwTextureFlags_NoLOD val:stat)
		on chTextureFlags_MinMip changed stat do (setTextureFlag wwTextureFlags_MinMip val:stat)
		on chTextureFlags_OneBitAlpha changed stat do (setTextureFlag wwTextureFlags_OneBitAlpha val:stat)
		on chTextureFlags_EightBitAlpha changed stat do (setTextureFlag wwTextureFlags_EightBitAlpha val:stat)
		on chTextureFlags_EnvMap changed stat do (setTextureFlag wwTextureFlags_EnvMap val:stat)
		on chTextureFlags_Hint_DXT5 changed stat do (setTextureFlag wwTextureFlags_Hint_DXT5 val:stat)
		on chTextureFlags_PointSample changed stat do (setTextureFlag wwTextureFlags_PointSample val:stat)
		on chTextureFlags_Trilinear changed stat do (setTextureFlag wwTextureFlags_Trilinear val:stat)
		on chTextureFlags_ClampU changed stat do (setTextureFlag wwTextureFlags_ClampU val:stat)
		on chTextureFlags_Anisotropic changed stat do (setTextureFlag wwTextureFlags_Anisotropic val:stat)
		on chTextureFlags_SRGB changed stat do (setTextureFlag wwTextureFlags_SRGB val:stat)
		on chTextureFlags_Procedural changed stat do (setTextureFlag wwTextureFlags_Procedural val:stat)
		on chTextureFlags_RenderTarget changed stat do (setTextureFlag wwTextureFlags_RenderTarget val:stat)
		on chTextureFlags_DepthRenderTarget changed stat do (setTextureFlag wwTextureFlags_DepthRenderTarget val:stat)
		on chTextureFlags_NoDebugOverride changed stat do (setTextureFlag wwTextureFlags_NoDebugOverride val:stat)
		on chTextureFlags_SingleCopy changed stat do (setTextureFlag wwTextureFlags_SingleCopy val:stat)
		on chTextureFlags_NoDepthBuffer changed stat do (setTextureFlag wwTextureFlags_NoDepthBuffer val:stat)
		on chTextureFlags_VertexTexture changed stat do (setTextureFlag wwTextureFlags_VertexTexture val:stat)
		on chTextureFlags_SSBump changed stat do (setTextureFlag wwTextureFlags_SSBump val:stat)
		on chTextureFlags_Border changed stat do (setTextureFlag wwTextureFlags_Border val:stat)
		on chTextureFlags_Deprecated_OneOverMipLevelInAlpha changed stat do (setTextureFlag wwTextureFlags_Deprecated_OneOverMipLevelInAlpha val:stat)
		on chTextureFlags_Deprecated_PreMultColorByOneOverMipLevel changed stat do (setTextureFlag wwTextureFlags_Deprecated_PreMultColorByOneOverMipLevel val:stat)
		on chTextureFlags_Deprecated_NormalToDuDv changed stat do (setTextureFlag wwTextureFlags_Deprecated_NormalToDuDv val:stat)
		on chTextureFlags_Deprecated_AlphaTestMipGeneration changed stat do (setTextureFlag wwTextureFlags_Deprecated_AlphaTestMipGeneration val:stat)
		on chTextureFlags_Deprecated_NiceFiltered changed stat do (setTextureFlag wwTextureFlags_Deprecated_NiceFiltered val:stat)
		on chTextureFlags_Deprecated_Unfilterable_OK changed stat do (setTextureFlag wwTextureFlags_Deprecated_Unfilterable_OK val:stat)
		on chTextureFlags_Deprecated_SpecVar_Red changed stat do (setTextureFlag wwTextureFlags_Deprecated_SpecVar_Red val:stat)
		on chTextureFlags_Deprecated_SpecVar_Alpha changed stat do (setTextureFlag wwTextureFlags_Deprecated_SpecVar_Alpha val:stat)

		on textureflagsrollout open do (
			setFlagChecks()
		)

	)

	on clone orig do thisNode = undefined

	on update do (
		case of (
			(version < 4):(
				if vmtproperty != undefined AND vmtproperty != "" then (
					local props
					if matchPattern vmtproperty pattern:"*,*" then (
						props = filterString vmtproperty ","
					) else (
						props = #(vmtproperty)
					)
					for prop in props WHERE prop != undefined AND prop != "" do (
						append vmtproperties prop
					)
				)
			)
		)
	)
)