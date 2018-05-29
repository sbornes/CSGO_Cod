
if ::wallworm_installation_path == undefined then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

if ::wallworm_EULA != true then (
	fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
	messageBox "Please Agree to the Wall Worm EULA to access these tools."
	fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
) else (
	fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
	fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_struct_mat.ms")
	wwProceedTexCompile = wallworm_canCompileTextures model:true
	if wwProceedTexCompile == true then (
		ww_scene_lods.populateMyMaterials()
		if ww_scene_lods.materials.count > 0 then (
			str = StringStream ""
			format "wwTextureExporter = newRolloutFloater \"Wall Worm Model Tools Texture Exporter 3.2\" 800 800 10 10\n" to:str
			eventHandlersStrings = StringStream""

			format "rollout textureFields \"Wall Worm Model Tools Texture Exporter\" width:790 height:790 (\n\n" to:str

			num = 1
			matNum = 1
			sendToVtex = StringStream ""
			onOpenStr = StringStream ""

			local bitmapsAlreadyListed = #()

			for m in ww_scene_lods.materials do (
				if m.mat1 == undefined then (
					m.mat1 = m.mat
				)

				if ::wwmt_oldModelVTFPath == true then (
					wwmt_vtfMmatPath = ww_scene_lods.materialPath
				) else (
					wwmt_vtfMmatPath = ""
				)

				m.matName = wallworm_getMaterialName m.mat1 forModel:true
				targetmatname = (::wwmt_gameInfoDir + "\\materials\\" + ww_scene_lods.materialPath + "\\" + m.matName + ".vmt")

				if doesFileExist (targetmatname) == true then (
					ch = "false"
				) else (
					ch = "true"
				)

				m.getMaps()

				format "group \"%/%.vmt\" (\n" ww_scene_lods.materialPath m.matName to:str
				format "checkbox chk_VMT% \"VMT Material: (%) %/%.vmt\" align:#left checked:% toolTip:\"Write the VMT file as well as export the texture.\"\n\n" matNum m.valveShader ww_scene_lods.materialPath m.matName ch to:str

				local texmaparray = m.texturemaparray
				for index = 1 to texmaparray.count do (
					local thisMapData = texmaparray[index]

					local thisMap = thisMapData.thisTextureMap
					local thisMapLabel = thisMapData.VMTPropName
					if thisMapLabel != undefined AND thisMapLabel != "" AND ((::WallwormProActive == true) OR classOf thisMap == BitmapTexture) then (
						format "\n wwmt_tga_%.bitmap = (renderMap ww_scene_lods.materials[%].texturemaparray[%].thisTextureMap  size:[15,15])\n" num matNum index to:onOpenStr
						--local thisFileName = thisMap.fileName
						local thisFileName = wallworm_texture_path thisMap forcePath:wwmt_vtfMmatPath matRoot:false forceLegacy:false addGameDir:false fs:true
						local enableFuncs = (findItem bitmapsAlreadyListed thisFileName == 0)

						local notice = ""

						if NOT enableFuncs then (
							append notice "# See Above !"
						)

						append bitmapsAlreadyListed thisFileName

						if wallworm_mat_name_limit_check (getFilenameFile thisFileName) == false then (
							enableFuncs == false
							notice = "# NAME TOO LONG--More than 22 characters!"
						)
						if classOf thisMap == BitmapTexture then (
							status = m.checkDimensions(thisMap.filename)
							if (status[1] == false OR status[2] == false) then (
								enableFuncs == false
								append notice "# Invalid Dimensions!"
							)
						)
						format "bitmap wwmt_tga_% \"\"  width:15  align:#left \n\n" num to:str

						--wallworm_texture_path  tex forcePath:wwmt_vtfMmatPath matRoot:true forceLegacy:false addGameDir:true fs:true
						--vtfname = (wallworm_getVTFPathFromBitmap thisMap forcePath:wwmt_vtfMmatPath) 

						targetmatname = (::wwmt_gameInfoDir + "\\materials\\" + thisFileName)
						local en = "true"
						local en2 = "true"

						if ::wwmt_oldModelVTFPath == true then (
							vtfP = ww_scene_lods.materialPath
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

						local defaultCompression = ww_scene_lods.compression
						if defaultCompression == "" then (
							defaultCompression = "dxt1"
						)

						format "checkbox chk% \"$%:%\" checked:% toolTip:\"Click to export this VTF.\" across:4 offset:[20,-22]  align:#left enabled:%\n" num thisMapLabel notice ch en2 to:str
						format "button btn% \"^\" enabled:% align:#left toolTip:\"Set to the model's material path.\"  offset:[20,-22]\n" num en to:str
						format "editText edt% \"\" enabled:% text:\"%\" toolTip:\"Set the output Path of this VTF.\"  align:#left  offset:[20,-22]\n" num en vtfP to:str
						format "label lblX% \"/%.vtf\" align:#left \n  offset:[20,-22] " num (getFileNameFile thisFileName) to:str
						local theMapStr = "ww_scene_lods.materials[" + matNum as String + "].texturemaparray[" + (index as String) + "].thisTextureMap"

						format "\ton btn% pressed do (\n\nchk%.checked = NOT (::wallwormUpdateTexFromName %  ww_scene_lods.materialPath materailcollection:ww_scene_lods.materials)\n edt%.text = ww_scene_lods.materialPath )\n" num num theMapStr num to:eventHandlersStrings
						--	format ("on edt"+num as string+" changed text do (\nww_scene_lods.materials["+matNum as string+"].mat1.diffuseMap.name =  text\nchk_VMT"+matNum as string+".checked = true\nvtfname = (wallworm_getVTFPathFromBitmap ww_scene_lods.materials["+matNum as string+"].mat1.diffuseMap forcePath:ww_scene_lods.materialPath)\nedt"+num as string+".text = (ww_scene_lods.materials["+matNum as string+"].mat1.diffuseMap.name)\ntargetmatname = ( (\""+::wwmt_gameInfoDir+"\\materials" + "\\\""+"\""+")+vtfname+\""+".vtf"+"\")\nif doesFileExist (targetmatname) == true then (\nchk"+num as string+".checked = false\n) else (\nchk"+num as string+".checked = true\n)\n )\n")

						--format "on btn% pressed do (\n%.name =  ww_scene_lods.materialPath\nchk_VMT%.checked = true\nvtfname = (wallworm_getVTFPathFromBitmap % forcePath:ww_scene_lods.materialPath)\nedt%.text = (%.name)\ntargetmatname = ( (\"%\\materials\\\"\")+vtfname+\".vtf\")\nif doesFileExist (targetmatname) == true then (\nchk%.checked = false\n) else (\nchk%.checked = true\n)\n )\n" num theMapStr matNum theMapStr num theMapStr (::wwmt_gameInfoDir) num num to:eventHandlersStrings
						format "\ton edt% entered text do (\n\nchk%.checked = NOT (::wallwormUpdateTexFromName %  edt%.text materailcollection:ww_scene_lods.materials)\n )\n" num num theMapStr num num to:eventHandlersStrings
						format "\tif chk%.checked do (\n" num to:sendToVtex
						/*format "\t\twallworm_copy_bitmap_to_sdk ww_scene_lods.materials[%].texturemaparray[%].thisTextureMap forcePath:\"%\" compression:\"%\" norm:%\n" matNum index wwmt_vtfMmatPath ww_scene_lods.compression normString  to:sendToVtex
						format "\t\twallworm_write_vtf_bat ww_scene_lods.materials[%].texturemaparray[%].thisTextureMap  dir:\"%\" VMTWritten:true runBat:true exportVTF:true shaderUsed:ww_scene_lods.materials[%].valveShader\n" matNum index wwmt_vtfMmatPath matNum  to:sendToVtex
						*/
						format "\t\twallworm_make_vtf ww_scene_lods.materials[%].texturemaparray[%].thisTextureMap  shaderUsed:ww_scene_lods.materials[%].valveShader norm:false  defaultCompression:% \n" matNum index matNum defaultCompression to:sendToVtex

						--append sendToVtex("ww_scene_lods.materials["+matNum as string+"].compileTexture ww_scene_lods.materials["+matNum as string+"].ambient \"ambient\" \n")
						format "\t)\n\n" to:sendToVtex

						num += 1

					)

				)

				format ")\n" to:str

				format "\tif chk_VMT%.checked do (\n" matNum to:sendToVtex
				format "\t\tww_scene_lods.materials[%].compileTexture ww_scene_lods.materials[%].mat1.diffuseMap \"diff\" writeVMT:true exportVTF:false\n" matNum matNum to:sendToVtex
				format "\t)\n\n" to:sendToVtex

				matNum += 1

				--append str ")"

			)

			format "button btn_exportTGAs \"Export Selected Textures\" width:400 height:48\n\n" to:str
			format "HyperLink exportTex \"Basic Texture Docs\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/topic/18/textures.html\"\n\n" to:str
			format "HyperLink exportTexUsing \"Exporting Textures\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/document/70/export_textures.html\"\n\n" to:str
			format "HyperLink exportSkins \"Exporting Multiple Skins\"  width:132 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/document/71/export_multiple_texture_skins.html\"\n\n" to:str
			format "HyperLink materialTips \"Material Reference Charts and Hints\"  width:200 height:16 color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255) address:\"http://dev.wallworm.com/topic/18/textures.html#materialChart\"\n\n" to:str
			format "label hintLabel \"Remember that the exporter will only list/export map slots that have a Bitmap Map with a TGA bitmap as the image.\"   width:700 height:28\n\n" to:str
			format (eventHandlersStrings as String) to:str
			--format eventHandlersStrings

			format "on btn_exportTGAs pressed do (\n" to:str

			format "if ww_scene_lods.canCompile \"tex\" then (\n\n" to:str

			format (sendToVtex as String) to:str
			--if wwmtCompileMessage == true OR wwmtCompileMessage == "true" do (
			format "\n\n messagebox \"Materials Exported.\" \n" to:str
			--)

			format ") else(\n\n messagebox \"You must set the Bin Directory and give your model a Material Path for this function to work.\"  \n\n)\n" to:str

			format ")\n\n" to:str

			format "on textureFields open do (\n%\n)" (onOpenStr as String) to:str

			format ")\n\n" to:str

			format "addRollout textureFields wwTextureExporter\n" to:str

			--clearListener()
			--print (str as String)

			execute (str as String)

		) else (
			messageBox "You can only export TGA and PSD Bitmaps. Since there are none in your model or LODs, there is nothing to export."
		)

	) else (
		macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
		msg = "There are problems:\n\n"
		for er in wwProceedTexCompile do (
			append msg ("* " + er + "\n")
		)
		messageBox msg
	)
)
