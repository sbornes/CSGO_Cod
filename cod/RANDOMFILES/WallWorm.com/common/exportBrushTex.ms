/*
Export Brush Texture Dialog

This script creates a UI for exporting textures.

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_struct_mat.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/blendrender.ms")

if ::wallworm_EULA != true then (
	messageBox "Please Agree to the Wall Worm EULA to access these tools."
	fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
) else (
	wwProceedTexCompile = wallworm_canCompileTextures()
	if wwProceedTexCompile == true then (
		global ww_brushmaterials = #()
		global wallwormbrushtex = #()
		global wallworm_exportMatlist
		thematerials = #()
		if ::wallworm_exportMatlist != undefined AND ::wallworm_exportMatlist.count > 0 then (
			join thematerials wallworm_exportMatlist
		)

		macros.run "wallworm.com" "WallWormRepairDXRenderMatNamesMCR"

		global wallworm_detailarray = #("", "swamp_land_002", "grass01", "grass02", "coastline_grass01", "coastline_grass02", "coastline_redgrass01", "coastline_redgrass02", "coastline_redgrass03", "citygrass01", "redgrass", "redgrass_light", "short_redgrass", "PerfTest1", "canal_reeds", "rocks_redgrass", "lostcoast_grass", "lostcoast_grass2")

		if thematerials.count == 0 then (
			if selection.count > 0 then (
				wallwormbrushtex = selection
			) else (
				--wallwormbrushtex = objects
				for o in objects WHERE ((getUserProp o #wwdt_brush_geometry_export) != undefined OR (getUserProp o #ww_wwdt_displacement_brush) != undefined OR (getUserProp o #wwmt_decal) != undefined OR classOf o.baseObject == WallWormDetailType) do (
					append wallwormbrushtex o
				)
			)
			newMats = for i in wallwormbrushtex WHERE i.mat != undefined collect i.mat
			join thematerials newMats

		)
		thematerials = makeUniqueArray thematerials
		for m in thematerials do (
			if classOf m == Blend then (
				shaderType = "WorldVertexTransition"
			) else(
				shaderType = "LightmappedGeneric"
			)
			--print (i.mat)
			/*
			if (getUserProp i #wwmt_decal)!=undefined then (
				decal = true
			) else (
				decal = false
			)
			*/
			local getNameFromPath = true
			local forModel = false
			local materialPath = undefined

			if isProperty m #wallworm then (
				shaderType = m.valveShader
				decal = m.decal

				if m.forModel == true AND m.cdmaterials != "" then (
					getNameFromPath = false

					forModel = true
					materialPath = m.cdmaterials
				)
			)

			wallworm_appendBitmaps m ww_brushmaterials shaderType coords:true decal:decal getNameFromPath:getNameFromPath forModel:forModel materialPath:materialPath

		)
		wallwormbrushtex = undefined

		str = StringStream ""
		format "wwTextureExporter = newRolloutFloater \"Wall Worm Texture Exporter 3.2\" 800 800 10 10\n" to:str
		eventHandlersStrings = StringStream""

		format "rollout textureFields \"Wall Worm Texture Exporter\" width:790 height:790 (\n\n" to:str

		num = 1
		matNum = 1
		sendToVtex = StringStream ""
		onOpenStr = StringStream ""
		if ww_brushmaterials.count > 0 then (
			local bitmapsAlreadyListed = #()

			format "group \"Defaults\" (\n" to:str
			format "dropdownList ddl_compression \"Compression\" across:4  items:#(\"\", \"DXT5\", \"nocompress\") selection:5 \n" to:str
			format "dropdownList ddl_shader \"Non Blend Shader\"  items:#(\"LightmappedGeneric\", \"UnlitGeneric\") \n" to:str
			format "combobox ddl_surfaceproperty \"Surface Property\"  height:3 items:(::wwmt_surfaceprop_list) \n " to:str
			format "combobox ddl_detailtype \"Detail Type\"  height:3 items:(::wallworm_detailarray) \n" to:str
			format ") \n" to:str

			for m in ww_brushmaterials do (
				if m.mat1 == undefined then (
					m.mat1 = m.mat
				)
				m.getMaps()
				if classOf m.mat == Blend then (
					m.matName = wallworm_getMaterialName m.mat
				) else (
					m.matName = wallworm_getMaterialName m.mat1
				)

				if isProperty m #wallworm AND m.forModel == true AND m.cdmaterials != "" then (
					materialPath = m.cdmaterials
					m.forModel = true
				) else (
					m.forModel = false
					materialPath = m.getMaterialPathForMat m.mat
				)

				if materialPath == "" then (
					temp_wwmt_vtfMmatPath = m.matName
				) else (
					temp_wwmt_vtfMmatPath = materialPath
				)
				local wwmt_vtfMmatPath = ""
				if ::wwmt_oldModelVTFPath == true then (
					wwmt_vtfMmatPath = temp_wwmt_vtfMmatPath
				)
				m.matName = wallworm_getMaterialName m.mat forModel:m.formodel
				if m.formodel then (
					targetmatname = (::wwmt_gameInfoDir + "\\materials\\" + wwmt_vtfMmatPath + "\\" + m.matName + ".vmt")
				) else (
					targetmatname = (::wwmt_gameInfoDir + "\\materials\\" + m.matName + ".vmt")
				)

				if doesFileExist (targetmatname) == true then (
					ch = "false"
				) else (
					ch = "true"
				)

				if m.defaultCompression == undefined then (
					m.defaultCompression = ""
				)

				format "group \"%.vmt\" (\n" m.matName to:str
				format "checkbox chk_VMT% \"VMT Material: (%) %.vmt\" align:#left  checked:% toolTip:\"Write the VMT file as well as export the texture.\" \n " matNum m.valveShader m.matName ch to:str

				if m.valveShader == "WorldVertexTransition" then (
					local prepname = wallworm_remove_last_slash (wallworm_bsToFs m.matName)
					local toolpath = pathConfig.removePathLeaf prepname
					--append toolpath "_tool"
					--m.matName+".vmt"	

					--writepath = wallworm_bsToFs("$maps/"+toolpath+"/"+(pathConfig.stripPathToLeaf prepname)+"_tool.tga")
					local tp = (pathConfig.stripPathToLeaf prepname)
					--local writepath = (wallworm_bsToFs ::wwmt_exportMats) + "/" + toolpath + "/" + (tp) + "_tool.tga"
					local wp = stringstream ""
					format "%/%/%_tool.tga"  ::wwmt_exportMats  toolpath  tp to:wp
					
					local writepath = wallworm_safe_path (::wallworm_BStoFS (wp as string)) --escape:true
					if doesFileExist (getFileNamePath writepath) == false then (
						makeDir (getFileNamePath writepath) all:true
					)
					--print writepath
					tex = BitmapTexture()
					tex.name = toolpath
					tex.filename = writepath

					format "bitmap wwmt_tga_% \"\" align:#left width:15 height:15 \n" num to:str
					format "checkbox chk% \"Tool Texture VTF: %/%_tool.vtf\"  checked:%  height:15 align:#left offset:[20,-20] toolTip:\"Click to export this VTF.\"\n" num (wallworm_bsToFs toolpath) (getFileNameFile m.matName) ch to:str

					format "\nlocal bmt =  wallworm_render_blend_mat ww_brushmaterials[%].mat size:[15,15]\nif bmt != undefined then (wwmt_tga_%.bitmap =bmt\n)\n" matNum num to:onOpenStr
					format "if chk%.checked  do (\n" num to:sendToVtex

					if m.mat2 != undefined AND m.basetexture2 != undefined AND classOf m.basetexture2 == BitmapTexture AND m.basetexture2.Bitmap != undefined AND m.basetexture2.Bitmap.width != undefined then (
						bmWIdth = m.basetexture2.Bitmap.width
						bmHeight = m.basetexture2.Bitmap.height
					) else (
						if m.basetexture != undefined AND classOf m.basetexture == BitmapTexture AND m.basetexture.Bitmap != undefined AND m.basetexture.Bitmap.width != undefined then (
							bmWIdth = m.basetexture.Bitmap.width
							bmHeight = m.basetexture.Bitmap.height
						) else (
							bmWIdth = 512
							bmHeight = 512

						)
					)
					
					format "local bm = wallworm_render_blend_mat ww_brushmaterials[%].mat size:[%,%] filename:\"%\" overWrite:true\n" matNum bmWIdth bmHeight writepath to:sendToVtex
					format "save bm \n" to:sendToVtex
					format "local bmt = BitmapTexture()" to:sendToVtex
					format "bmt.name = \"%\" \n" tex.name to:sendToVtex
					format "bmt.bitmap = bm\n" to:sendToVtex
					/*format "wallworm_copy_bitmap_to_sdk   bmt compression:ddl_compression.selected norm:false forcePath:\"%\"\n" toolpath  to:sendToVtex

					format "wallworm_write_vtf_bat bmt dir:\"%\" VMTWritten:true runBat:true exportVTF:true shaderUsed:ww_brushmaterials[%].valveShader\n" toolpath matNum to:sendToVtex*/
					format "\t\twallworm_make_vtf bmt  shaderUsed:ww_brushmaterials[%].valveShader norm:false forcePath:\"%\" defaultCompression:ddl_compression.selected \n" matNum toolpath to:sendToVtex

					--append sendToVtex("ww_brushmaterials["+matNum as string+"].compileTexture ww_brushmaterials["+matNum as string+"].diff \"diff\" writeVMT:false exportVTF:true\n")
					format ")\n\n" to:sendToVtex
					num += 1
				)

				local texmaparray = m.texturemaparray
				for index = 1 to texmaparray.count do (
					local thisMapData = texmaparray[index]
					local thisMap = thisMapData.thisTextureMap
					local thisMapLabel = thisMapData.VMTPropName
					local hasWWTex = (::WallwormProActive == true AND isProperty thisMap #vtfpath AND thisMap.vtfpath != "")
					if thisMapLabel != undefined AND thisMapLabel != "" AND (hasWWTex OR classOf thisMap == BitmapTexture) then (
						format "\n wwmt_tga_%.bitmap = (renderMap ww_brushmaterials[%].texturemaparray[%].thisTextureMap  size:[15,15])\n" num matNum index to:onOpenStr

						local thisFileName = wallworm_texture_path thisMap forcePath:wwmt_vtfMmatPath matRoot:false forceLegacy:false addGameDir:false fs:true
						local enableFuncs = (findItem bitmapsAlreadyListed thisFileName == 0)
						local notice = ""
						if NOT enableFuncs then (
							append notice " # See Above!"
						)
						append bitmapsAlreadyListed thisFileName
						if wallworm_mat_name_limit_check (getFilenameFile thisFileName) == false then (
							enableFuncs == false
							notice = " # NAME TOO LONG--More than 22 characters!"
						)
						if classOf thisMap == BitmapTexture then (
							status = m.checkDimensions(thisMap.filename)
							if (status[1] == false OR status[2] == false) then (
								enableFuncs == false
								append notice " # Invalid Dimensions!"
							)
						)
						format "bitmap wwmt_tga_% \"\"  width:15  align:#left \n\n" num to:str
						--wallworm_texture_path  tex forcePath:wwmt_vtfMmatPath matRoot:true forceLegacy:false addGameDir:true fs:true
						--vtfname = (wallworm_getVTFPathFromBitmap thisMap forcePath:wwmt_vtfMmatPath) 
						targetmatname = (::wwmt_gameInfoDir + "\\materials\\" + thisFileName)
						local en = "true"
						local en2 = "true"
						if ::wwmt_oldModelVTFPath == true then (
							vtfP = wwmt_vtfMmatPath
							en = "false"
						) else (
							vtfP = getFileNamePath thisFileName
						)

						vtfP = wallworm_bsToFs vtfP
						normString = "false"
						case (toLower thisMapLabel) of (
							"bumpmap" : (normString = "true")
							"normalmap" : (normString = "true")
							default: (normString = "false")
						)
						if NOT enableFuncs then (
							en2 = "false"
							en = "false"
							ch = "false"
						) else (
							if doesFileExist (targetmatname) == true then (
								ch = "false"
							) else (
								ch = "true"
							)
						)
						format "checkbox chk% \"$%:%\" checked:% toolTip:\"Click to export this VTF.\" across:4 offset:[20,-22]  align:#left enabled:%\n" num thisMapLabel notice ch en2 to:str
						format "button btn% \"^\" enabled:% align:#left toolTip:\"Set to the model's material path.\"  offset:[20,-22]\n" num en to:str
						format "editText edt% \"\" enabled:% text:\"%\" toolTip:\"Set the output Path of this VTF.\"  align:#left  offset:[20,-22]\n" num en vtfP to:str
						format "label lblX% \"/%.vtf\" align:#left \n  offset:[20,-22] " num (getFileNameFile thisFileName) to:str
						local theMapStr = "ww_brushmaterials[" + matNum as String + "].texturemaparray[" + (index as String) + "].thisTextureMap"
						format "\ton btn% pressed do (\n\nchk%.checked = NOT (local pth = getFileNamePath ww_brushmaterials[%].mat1.name\n ::wallwormUpdateTexFromName %  pth materailcollection:ww_brushmaterials)\n edt%.text = wallworm_safe_path pth )\n" num num matNum theMapStr num to:eventHandlersStrings
						format "\ton edt% entered text do (\n\nchk%.checked = NOT (::wallwormUpdateTexFromName %  edt%.text materailcollection:ww_brushmaterials)\n )\n" num num theMapStr num num to:eventHandlersStrings
						format "\tif chk%.checked do (\n" num to:sendToVtex
						format "\t\twallworm_make_vtf ww_brushmaterials[%].texturemaparray[%].thisTextureMap  shaderUsed:ww_brushmaterials[%].valveShader norm:% defaultCompression:ddl_compression.selected \n" matNum index matNum normString to:sendToVtex
						format "\t)\n\n" to:sendToVtex
						num += 1
					)
				)

				format ")\n" to:str

				format "\tif chk_VMT%.checked do (\n" matNum to:sendToVtex
				format "\t\tww_brushmaterials[%].compileTexture ww_brushmaterials[%].mat1.diffuseMap \"diff\" writeVMT:true exportVTF:false\n" matNum matNum to:sendToVtex
				format "\t)\n\n" to:sendToVtex

				matNum += 1

			)
		)

		format "button btn_exportTGAs \"Export Selected Textures\" width:400 height:48\n\n" to:str

		format "HyperLink exportTex \"Basic Texture Docs\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/topic/18/textures.html\"\n\n" to:str

		format "HyperLink exportTexUsing \"Exporting Textures\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/document/70/export_textures.html\"\n\n" to:str

		format "HyperLink exportSkins \"Exporting Multiple Skins\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/document/71/export_multiple_texture_skins.html\"\n\n" to:str

		format "HyperLink materialTips \"Material Reference Charts and Hints\"  width:200 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/topic/18/textures.html#materialChart\"\n\n" to:str

		format "label hintLabel \"Remember that the exporter will only list/export map slots that have a Bitmap Map with a TGA/PSD or IFL bitmap as the image.\"   width:700 height:28\n\n" to:str

		format (eventHandlersStrings as String) to:str
		--format eventHandlersStrings

		format "on btn_exportTGAs pressed do (\n" to:str

		format "if wallworm_canCompileTextures model:false then (\n\n" to:str

		format (sendToVtex as String) to:str
		--if wwmtCompileMessage == true OR wwmtCompileMessage == "true" do (
		format "\n\n print \"Materials Exported.\" \n" to:str
		--)

		format ") else(\n\n messagebox \"You must set the Bin Directory and give your model a Material Path for this function to work.\"  \n\n)\n" to:str

		format ")\n\n" to:str

		format "on textureFields open do (\n%\n)" (onOpenStr as String) to:str

		format ")\n\n" to:str

		format "addRollout textureFields wwTextureExporter\n" to:str

		/*clearListener()
		print (str as string)*/

		::tmp = str

		execute (str as String)

	) else (
		msg = "There are problems:\n\n"
		for er in wwProceedTexCompile do (
			append msg ("* " + er + "\n")
		)
		messageBox msg
	)

	wallworm_exportMatlist = undefined
)