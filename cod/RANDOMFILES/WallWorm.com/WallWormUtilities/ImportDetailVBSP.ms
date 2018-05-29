

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_event_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/displacements.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/importModelsForProps.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/VMFImport2.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/vmf.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/sprite_struct.ms")
(
	global wallworm_VBSP

	--REMOVE AT RELEASE
	--wallworm_VBSP = undefined

	if wallworm_VBSP == undefined then (
		clearListener()

		--REMOVE AT RELEASE
		--delete (for obj in objects where getUserProp obj #wallworm_imported_detail != undefined collect obj)

		wallworm_VBSP = wallworm_detail_vbsp()

		global wallworm_file_vmf_presets

		if NOT isProperty rootNode #Wallworm_VMF then (
			custAttributes.add rootNode wallworm_vmf_settings_CA

			wallwormVMFSettingsIndex = fileProperties.findProperty #custom "wallwormVMFSettings"
			if wallwormVMFSettingsIndex != 0 then (
				wallwormVMFSettings1 = fileProperties.getPropertyValue #custom wallwormVMFSettingsIndex
				wallwormVMFSettings = "global wallworm_file_vmf_presets = (" + wallwormVMFSettings1 + ")"

				execute wallwormVMFSettings
				--print wallworm_file_vmf_presets

				if wallworm_file_vmf_presets != undefined AND classOf wallworm_file_vmf_presets == wallwormVMF then (
					rootNode.getSettingsFromVMFStruct wallworm_file_vmf_presets
				)
			)

		) else (
			if wallworm_file_vmf_presets == undefined OR classOf wallworm_file_vmf_presets != wallwormVMF then (
				wallworm_file_vmf_presets = wallwormVMF()
			)

			rootNode.setVMFFromthis &wallworm_file_vmf_presets
		)

		if wallworm_file_vmf_presets != undefined AND classOf wallworm_file_vmf_presets == wallwormVMF then (
			wallworm_VBSP.filename = ::wwmt_gameInfoDir + "\\" + wallworm_file_vmf_presets.DetailVBSP
			wallworm_VBSP.vmt = ::wwmt_gameInfoDir + "\\materials\\" + wallworm_file_vmf_presets.DetailSprites

			if getfilenametype wallworm_VBSP.vmt == "" then (
				wallworm_VBSP.vmt = (wallworm_VBSP.vmt + ".vmt")
			)

		)

		if wallworm_VBSP.filename == undefined OR wallworm_VBSP.filename == "" then (
			wallworm_VBSP.filename = ::wwmt_gameInfoDir + "\\detail.vbsp"
		)

		if wallworm_VBSP.vmt == undefined OR wallworm_VBSP.vmt == "" then (
			lookArray = #((::wwmt_gameInfoDir + "\\materials"), ::wwmt_exportMats, ::wwmt_raw_mats)
			for i = 1 to lookArray.count while wallworm_VBSP.vmt == "" do (
				vmtsearch = lookArray[i] + "\\detail\\detailsprites.vmt"
				if doesFileExist vmtsearch then (
					wallworm_VBSP.vmt = vmtsearch
				)
			)
		)

		if wallworm_VBSP.vmt != "" then (
			--wallworm_VBSP.import()
		)
		--wallworm_VBSP.spriteMats.materialList.count
	)

	wallworm_VBSP.show()
)