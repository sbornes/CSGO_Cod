macroscript WallWormInitialize
category:"wallworm.com"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms"
		if doesFileExist f then (
			fileIn f
			true
		) else (
			false
		)
	)
)

macroScript WallWormModelToolsMCR
category:"wallworm.com"
tooltip:"Wall Worm Model Tools"
buttontext:"Wall Worm Model Tools"
(
	function closeWWMT = (
		try(closeRolloutFloater ::wwToolsFloater)catch()
	)
	on isChecked do (
		if ::wwToolsFloater == undefined OR ::wwToolsFloater.open == false then (
			false
		) else (
			true
		)
	)
	on closeDialogs do (
		closeWWMT()
	)
	on execute do (
		if ::wwToolsFloater == undefined OR ::wwToolsFloater.open == false then (
			if ::wallworm_installation_path == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			local f = ::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wallworm_model_tools.ms"
			if doesFileExist f then (
				fileIn f
			) else (
				messageBox "Wall Worm Model Tools is not installed properly. Please reinstall WWMT."
			)
		) else (
			closeWWMT()
		)
	)
)
macroscript WallWormWalkThrough
category:"wallworm.com"
tooltip:"Walk Through Mode"
buttontext:"Walk Through Mode"
(
	on execute do (
		macros.run "Views" "WalkThroughToggle"
		local canrun = ::wallworm_installation_path != undefined
		if ::wallworm_installation_path == undefined then (
			canrun = macros.run "wallworm.com" "WallWormInitialize"
		)
		if canrun == true then (
			::wwmt_walkThroughOpsstepSize = (::wallworm_getINISettingWithDefault "Settings" "walkThroughOpsstepSize" 768) as Integer -- 1,15,18,22
			walkThroughOps.stepSize = ::wwmt_walkThroughOpsstepSize
		)
	)
)

macroscript WallWormHullHelperDetach
category:"wallworm.com"
tooltip:"Detach Faces and Hide"
buttontext:"Detach Faces and Hide"
(
	on execute do (
		if classOf $ == Editable_Poly then (
			$.EditablePoly.detachToElement #Face keepOriginal:off
			$.EditablePoly.Hide #Face
		)
	)
)

macroScript WallWormModelToolsConfigMCR
category:"wallworm.com"
tooltip:"Wall Worm Settings"
buttontext:"Wall Worm Settings"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wwmtconfigutility.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Model Tools is not installed properly. Please reinstall WWMT."
		)
	)
)

macroScript WallWormCheckForUpdateMCR
category:"wallworm.com"
tooltip:"Check for Updates"
buttontext:"Check for Updates"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/checkForUpdate.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The updater script is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormCheckForProblemsMCR
category:"wallworm.com"
tooltip:"Check for Problems"
buttontext:"Check for Problems"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/ProblemChecker.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Problem Checker script is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormLaunchDisplayFloater
category:"wallworm.com"
tooltip:"Display Floater"
buttontext:"Display Floater"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/LaunchDisplayFloater.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The display floater script is missing. Please reinstall WWMT."
		)
	)
)


macroScript WallWormModelToolsExportSMDMCR
category:"wallworm.com"
tooltip:"Export DMX/SMD/VTA File"
buttontext:"Export DMX/SMD/VTA File"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/ExportSMD.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Wall Worm SMD Export UI is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormModelToolsSelectAllWWMTMCR
category:"wallworm.com"
tooltip:"Select All WWMT"
buttontext:"Select All WWMT"
(
	on execute do (
		local theSel
		if selection.count > 0 then (
			theSel = selection as Array
		) else (
			theSel = objects as Array
		)

		wwmtcollection = for obj in theSel WHERE isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper != undefined collect obj
		if wwmtcollection.count > 0 then (
			select wwmtcollection
		)
	)
)

macroScript WallWormModelToolsSaveWWMTToLibrary
category:"wallworm.com"
tooltip:"Save All WWMT to Prop Library"
buttontext:"Save All WWMT to Prop Library"
(
	on execute do (
		local theSel
		if selection.count > 0 then (
			theSel = selection as Array
		) else (
			theSel = objects as Array
		)
		wwmtcollection = for obj in theSel WHERE isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper != undefined collect obj
		if wwmtcollection.count > 0 then (
			for wwmt in wwmtcollection do (
				wwmt.getWWMT()
				wwmt.wwmt.saveProxy()
			)
		)
	)
)
macroScript WallWormModelToolsExtrudeHelpersMCR
category:"wallworm.com"
tooltip:"Make WWMT Helpers 3D"
buttontext:"Make WWMT Helpers 3D"
(
	on execute do (
		wwmtcollection = for obj in objects WHERE isProperty obj #wwmt_ca OR getUserProp obj #wwmt_source_helper != undefined collect obj
		if wwmtcollection.count > 0 then (
			wwmts = for wwmt in wwmtcollection WHERE classOf wwmt == Text AND wwmt.modifiers[#Extrude] == undefined collect wwmt
			addModifier wwmts (Extrude amount:4)
		)
	)
)

macroScript WallWormModelToolsQuickCompileMCR
category:"wallworm.com"
tooltip:"Export WWMT to Source Models"
buttontext:"Export WWMT to Source Models"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/exportSelectedWWMT.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The WWMT Quick Compiler is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormModelToolsQuickCompileVTFMCR
category:"wallworm.com"
tooltip:"Export Selected Model Textures"
buttontext:"Export Selected Model Textures"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/exportSelectedWWMTVTF.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The WWMT Quick Texture Compiler is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormAnvilCompileVTFMCR
category:"wallworm.com"
tooltip:"Export Brush Textures"
buttontext:"Export Brush Textures"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/common/exportBrushTex.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The WWMT Quick Texture Compiler is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormModelToolsWWMaterialsCAMCR
category:"wallworm.com"
tooltip:"Give Obj Mats WW Materials"
buttontext:"Give Obj Mats WW Materials"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/giveSelectedMaterialsWWCA.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Wall Worm material assignment script is missing..."
		)
	)
)

macroScript WallWormModelToolsWWMaterialsTEXCAMCR
category:"wallworm.com"
tooltip:"Give Obj Mats+Tex WW Materials"
buttontext:"Give Obj Mats+Tex WW Materials"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/giveSelectedMaterialsTexWWCA.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Wall Worm material assignment script is missing..."
		)
	)
)

macroScript WallWormModelToolsWWMaterialsSlateCAMCR
category:"wallworm.com"
tooltip:"Add WW to Selected Mats in Editor"
buttontext:"Add WW to Selected Mats in Editor"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/giveSelectedSlateMaterialsWWCA.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Wall Worm material assignment script is missing..."
		)
	)
)

macroScript WallWormWADExportMCR
category:"wallworm.com"
tooltip:"Export Textures to WAD"
buttontext:"Export Textures to WAD"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/makeWADFile.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The WWMT Quick Texture Compiler is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormEntityOutputsMCR
category:"wallworm.com"
tooltip:"Manage Source Entity Outputs"
buttontext:"Entity Manager"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/common/mse/entityOutputs.mse"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The WWMT Entity Outputs is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormModelToolsCreateProxyiesMCR
category:"wallworm.com"
tooltip:"Create Proxies from Selected WWMT"
buttontext:"Create WWMT Proxies"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/makeProxiesFromSelection.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Proxy Function is missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormModelToolsProxyToolsMCR
category:"wallworm.com"
tooltip:"WWMT Proxy Tools"
buttontext:"WWMT Proxy Tools"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/ProxyTools.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Proxy Tools are missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormLightToolsMCR
category:"wallworm.com"
tooltip:"Light Properties"
buttontext:"Light Properties"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/SetLightProperties.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Light Properties Tools are missing. Please reinstall WWMT."
		)
	)
)

macroScript WallWormUnfreezeUIMCR
category:"wallworm.com"
tooltip:"Unfreeze UI"
buttontext:"Unfreeze UI"
(
	on execute do (
		if ::wallworm_klunk_ToggleMaxRedraw == undefined then (
			if ::wallworm_installation_path == undefined then (
				macros.run "wallworm.com" "WallWormInitialize"
			)
			local f = ::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms"
			if doesFileExist f then (
				fileIn f
			) else (
				messageBox "WWMT files are missing. Please reinstall WWMT."
			)
		)
		if ::wallworm_klunk_ToggleMaxRedraw != undefined then (
			::wallworm_klunk_ToggleMaxRedraw 1 resumeEdit:true
		)
	)
)

macroScript WallWormWebDocsMCR
category:"wallworm.com"
tooltip:"Wall Worm Documentation"
buttontext:"Wall Worm Documentation"
(
	on execute do (
		shellLaunch "http://dev.wallworm.com" ""
	)
)

macroScript WallWormWebChangelogMCR
category:"wallworm.com"
tooltip:"Wall Worm Changelog"
buttontext:"Wall Worm Changelog"
(
	on execute do (
		if ::wallworm_getMaxVersion == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
		)
		local maxInfo = ::wallworm_getMaxVersion()
		shellLaunch ("http://dev.wallworm.com/topic/33/wwmt_changelog.html?previous=" + (::wwmt_installedversion as String) + "&installed=" + (::ww_wwmt_version as String) + "&maxversion=" + (maxInfo[1] as String) + "&maxupdateversion=" + (maxInfo[2] as String)) ""
	)
)

macroScript WallWormWebForumMCR
category:"wallworm.com"
tooltip:"Wall Worm Forums"
buttontext:"Wall Worm Forums"
(
	on execute do (
		shellLaunch "http://www.wallworm.net" ""
	)
)

macroScript WallWormFacebookMCR
category:"wallworm.com"
tooltip:"Wall Worm Facebook Group"
buttontext:"Wall Worm Facebook Group"
(
	on execute do (
		shellLaunch "https://www.facebook.com/groups/wallworm" ""
	)
)

macroScript WallWormWebDonateMCR
category:"wallworm.com"
tooltip:"Donate to Wall Worm"
buttontext:"Donate to Wall Worm"
(
	on execute do (
		shellLaunch "http://dev.wallworm.com/topic/42/donate.html" ""
	)
)

macroScript WallWormHammeredMCR
category:"wallworm.com"
tooltip:"Hammered to the Max"
buttontext:"Hammered to the Max"
(
	on execute do (
		--tracking code in links does not track individual users. the same code is used across all users to track the general user clicks from Max to the guide.
		shellLaunch "https://wallworm.com/store/index.php?route=product/product&product_id=62&tracking=5602cbfec1fc0" ""
	)
)

macroScript WallWormDesignTeamMCR
category:"wallworm.com"
tooltip:"Anatomy of a Design Team"
buttontext:"Anatomy of a Design Team"
(
	on execute do (
		--tracking code in links does not track individual users. the same code is used across all users to track the general user clicks from Max to the guide.
		shellLaunch "https://wallworm.com/store/index.php?route=product/product&product_id=61&tracking=5602cbfec1fc0" ""
	)
)


macroScript WallWormWebProductsMCR
category:"wallworm.com"
tooltip:"Commercial Plugins by Wall Worm"
buttontext:"Commercial Plugins by Wall Worm"
(
	on execute do (
		--tracking code in links does not track individual users. the same code is used across all users to track the general user clicks from Max to the store.
		shellLaunch "http://wallworm.com/store/?tracking=5602cbfec1fc0" ""
	)
)

macroScript WallWormWebProductsProMCR
category:"wallworm.com"
tooltip:"Wall Worm Pro"
buttontext:"Wall Worm Pro"
(
	on execute do (
		if ::wallworm_has_loaded_assemblies != true AND ::wallworm_installation_path != undefined then (
			fileIn (::wallworm_installation_path + "\\WallWorm.com\\common\\config.ms")
		)
		if ::WallWormProHelpers != undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/WWProLicensing.mse")
		) else (
			--tracking code in links does not track individual users. the same code is used across all users to track the general user clicks from Max to the product page.
			shellLaunch "http://dev.wallworm.com/topic/69/wall_worm_pro.html?tracking=5602cbfec1fc0" ""
		)
	)
)

macroScript WallWormWebYoutubeMCR
category:"wallworm.com"
tooltip:"Wall Worm Youtube Channel"
buttontext:"Wall Worm Youtube Channel"
(
	on execute do (
		shellLaunch "http://www.youtube.com/user/webonizer" ""
	)
)

macroScript WallWormWebGooglePlusMCR
category:"wallworm.com"
tooltip:"Wall Worm Google+ Community"
buttontext:"Wall Worm Google+ Community"
(
	on execute do (
		shellLaunch "https://plus.google.com/u/0/communities/100151559196798399920" ""
	)
)

macroScript WallWormBoneToolsMCR
category:"wallworm.com"
tooltip:"Bone Tools"
buttontext:"Bone Tools"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/BoneTools.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Bone Tools are missing. Re-Install WWMT."
		)
	)
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSkyWriter/wwsw_mcr.mcr")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/wormface_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/radworm_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/wwmatgen_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/soundscaper_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/wwdt_mcr.mcr")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/HullHelper_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/AlphaSpec_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WormFlex_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/clearWWMT_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WormRES_mcr.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/general_purpose/wallworm_quick_parent.ms")

fileIn (::wallworm_installation_path + "/WallWorm.com/general_purpose/nudge_macros.mcr")
try(
	if (maxVersion())[1] >= 12000 then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WalkableXView.ms")
		fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WalkableXView_mcr.ms")
	)
) catch()

macroscript WallWormMaterialMerger
category:"wallworm.com"
tooltip:"Material Merger"
buttontext:"Material Merger"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/general_purpose/wallworm_material_merge.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Material Merger not present... not installed."
		)
	)
)

macroscript WallWormSprites
category:"wallworm.com"
tooltip:"Sprite Tools"
buttontext:"Sprite Tools"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/general_purpose/wallworm_sprites.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Sprites not present... not installed."
		)
	)
)

macroscript WallWormSpritesDrop
category:"wallworm.com"
tooltip:"Place Sprite"
buttontext:"Place Sprite"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/general_purpose/wallworm_sprites.ms"
		if doesFileExist f then (
			global wallwormSpriteTex
			if wallwormSpriteTex == undefined then (
				macros.run "wallworm.com" "WallWormSprites"
			) else (
				wallwormSpriteTex.placeSpriteAtPoint()
			)
		) else (
			messageBox "Wall Worm Sprites not present... not installed."
		)
	)
)

macroscript WallWormScaleFix
category:"wallworm.com"
tooltip:"Scale Fix"
buttontext:"Scale Fix"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/general_purpose/scale_fix.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Scale Fix not present... not installed."
		)
	)
)

macroScript WallWormBodyGroupsMCR
category:"wallworm.com"
tooltip:"Body Groups"
buttontext:"Body Groups"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/bodygroups.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Model Tools is not installed properly. Please reinstall WWMT."
		)
	)
)

macroscript WallWormSMDImporter
category:"wallworm.com"
tooltip:"SMD and QC Importer"
buttontext:"SMD and QC Importer"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/SMDImporterUI.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "SMD Importer not present... not installed."
		)
	)
)

macroscript WallWormVMTImporter
category:"wallworm.com"
tooltip:"VMT Importer"
buttontext:"VMT Importer"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/ImportVMTFile.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "VMT Importer not present... not installed."
		)
	)
)

macroscript WallWormHideLODS
category:"wallworm.com"
toolTip:"Hide LODs"
buttontext:"Hide LODs"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/HideLODs.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Oops... Hide LODs script not found... not installed."
		)
	)
)

macroScript WallWormMaterialUtilitiesMCR
category:"wallworm.com"
tooltip:"Material Utilities"
buttontext:"Material Utilities"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/SelectMaterialUtilities.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Model Tools is not installed properly. Please reinstall WWMT."
		)
	)
)

macroScript WallWormMKSHEETMCR
category:"wallworm.com"
tooltip:"Export IFL to MakeSheet"
buttontext:"Export IFL to MakeSheet"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/makesheet.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The Wall Worm Makesheet UI is missing. Please reinstall Wall Worm."
		)
	)
)

macroscript WallWormPasteProperties
category:"wallworm.com"
tooltip:"Paste Properties"
buttonText:"Paste Properties"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/general_purpose/paste_properties.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Wall Worm Model Tools is not installed properly. Please reinstall WWMT."
		)
	)
)

macroscript WallWormNormalTools
category:"wallworm.com"
tooltip:"Wall Worm Normal Tools"
buttonText:"Wall Worm Normal Tools"
(
	on execute do (
		global wallworm_normal_tools

		if wallworm_normal_tools == undefined then (
			if (queryBox "Normal Tools is a commercial Addon Script for Wall Worm that is not installed. Would you like to learn more about Normal Tools?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/68/normal_tools.html" ""
			)
		) else (
			local wwNormal = wallworm_normal_tools()
			wwNormal.displayRollout()
			wwNormal.helperRollout.wwNormalStruct = wwNormal
			wwNormal.displayRollout()
		)

	)
)

macroScript WallWormRandomizeUVWMCR
category:"wallworm.com"
tooltip:"Randomize UVW"
buttontext:"Randomize UVW"
(
	on execute do (
		if ::wallworm_installation_path == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/randomizeUVS.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "The updater script is missing. Please reinstall WWMT."
		)
	)
)

macroscript WallWormTilerFromSelection
category:"wallworm.com"
tooltip:"Create ProPal Around Selections"
buttonText:"Create ProPal Around Selections"
(
	on execute do (
		if ::ProPal == undefined then (
			if (queryBox "ProPal is a commercial Addon Plugin for Wall Worm that is not installed. Would you like to learn more about ProPal?") == true then (
				shellLaunch "http://dev.wallworm.com/topic/75/propal.html" ""
			)
		) else (
			if Selection.count == 0 then (
				messageBox "No objects selected... Select objects first."
			) else (
				local t = ProPal()
				t.pos = selection.center
				t.pos.z = selection.min.z
				t.height = selection.max.z - selection.min.z
				local pr = t.addProjection()
				local adobn = pr.addObjectNode
				for obj in selection WHERE superClassOf obj == GeometryClass do (
					adobn obj
				)
				pr.autowrapCage()
				t.wrapProjectionNodes outside:true
				t.updateBakeInfo()
				select t
			)
		)
	)
)
macroscript WallWormSelectionToWWMT
category:"wallworm.com"
tooltip:"Create WWMT From Selection"
buttonText:"Create WWMT From Selection"
(
	on execute do (
		if ::ww_LOD_wrapper == undefined OR ::wallworm_remove_proxy == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		
		local objs = selection as array
		if objs.count > 0 then (
			if objs.count > 1 then (
				local make1 = true
				case (yesnocancelbox "Since there are multiple objects, should each be a separate WWMT? Click No to add all objects to a single WWMT Helper.") of (
					#yes:(
						for obj in objs do (
							local tmpAr = #(obj)
							try (
								if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
									InstanceMgr.MakeObjectsUnique &tmpAr #individual
								)
							) catch ()
							::wallworm_remove_proxy obj
							local tempWWMT = ww_LOD_wrapper()
							tempWWMT.init()
							tempWWMT.setTargetModel obj tempWWMT
						)
					)
					#no:(
						
						local tempWWMT = ww_LOD_wrapper()
						tempWWMT.init()
						local tmpAr = #(objs[1])
						try (
							if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
								InstanceMgr.MakeObjectsUnique &tmpAr #individual
							)
						) catch ()
						wallworm_remove_proxy objs[1]
						tempWWMT.setTargetModel objs[1] tempWWMT
						for i = 2 to objs.count do (
							local tmpAr = #(objs[i])
							try (
								if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
									InstanceMgr.MakeObjectsUnique &tmpAr #individual
								)
							) catch ()
							::wallworm_remove_proxy objs[i]
							tempWWMT.addObjToObjects objs[i]
						)
					
					)
					#cancel:()
				)
				/*
					undo "Merge on Snapshot" on
					(
						crvStruct.collapseObjectsToPoly (selection as Array) useSnapshot:true
					)	
				*/
					
			) else (
				try (
					if (InstanceMgr.CanMakeObjectsUnique obs) then (
						InstanceMgr.MakeObjectsUnique &obs #individual
					)	
				) catch ()
				local tempWWMT = ww_LOD_wrapper()
				tempWWMT.init()
				wallworm_remove_proxy $
				tempWWMT.setTargetModel $ tempWWMT

			)			
		) else (
			messagebox "No objects selected."
		)

	)
)

macroscript WallWormProxiesToWWMT
category:"wallworm.com"
tooltip:"Create WWMT From Selected Proxies"
buttonText:"Create WWMT From Selected Proxies"
(
	on execute do (
		if ::ww_LOD_wrapper == undefined OR ::wallworm_remove_proxy == undefined then (
			macros.run "wallworm.com" "WallWormInitialize"
		)
		local objs = for obj in  (selection as array) where isProperty obj #WWMTProxy collect obj
		if objs.count == 0 then (
			messagebox "No objects selected."
		) else (

			if objs.count > 1 then (
				
				local hullOBJS = #()
				local tempWWMT = ww_LOD_wrapper()
				tempWWMT.init()
				local obj1 = objs[1]
				
				if obj1.WWMTProxy.version >=15 then (
					local thisHull = obj1.getHull()
					if isValidNode thisHull then append hullOBJS thisHull
				)
				
				local tmpAr = #(obj1)
				try (
					if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
						InstanceMgr.MakeObjectsUnique &tmpAr #individual
					)
				) catch()
				::wallworm_remove_proxy obj1
				tempWWMT.setTargetModel obj1 tempWWMT
				for i = 2 to selection.count do (
					local thisObj = objs[i]
					local tmpAr = #(thisObj)
					try (
						if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
							InstanceMgr.MakeObjectsUnique &tmpAr #individual
						)
					) catch ()
					if thisObj.WWMTProxy.version >=15 then (
						local thisHull = thisObj.getHull()
						if isValidNode thisHull then append hullOBJS thisHull
					)
					::wallworm_remove_proxy thisObj
					tempWWMT.addObjToObjects thisObj
				)
				if hullOBJS.count > 0 then (
					for obj in hullOBJS do (
						tempWWMT.addPhysModel obj
					)
				)
				tempWWMT.processPhys()
				theRealHullCount = wwmt_count_hulls (hullOBJS) true
				if theRealHullCount > 1 then (
					tempWWMT.setConcave true
				)
				tempWWMT.setLocalOrigin true
					
			) else (
				if selection.count == 0 then (
					messagebox "No objects selected."
				) else (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					local thisHull
					if isProperty $ #WWMTProxy AND $.WWMTProxy.version >=15 then (
						thisHull = $.getHull()
					)
					local tmpAr = #($)
					try (
						if (InstanceMgr.CanMakeObjectsUnique tmpAr) then (
							InstanceMgr.MakeObjectsUnique &tmpAr #individual
						)
					) catch ()
					wallworm_remove_proxy $
					tempWWMT.setTargetModel $ tempWWMT
					
					if isValidNode thisHull then (
						tempWWMT.addPhysModel thisHull
						tempWWMT.processPhys()
						theRealHullCount = wwmt_count_hulls (#(thisHull)) true
						if theRealHullCount > 1 then (
							tempWWMT.setConcave true
						)					
					)

					tempWWMT.setLocalOrigin true
				)
			)			
		)	

	)
)

macroscript WallWormSelectionToWWMTAndHull
category:"wallworm.com"
tooltip:"Create WWMT + Hull From Selection"
buttonText:"Create WWMT + Hull From Selection"
(
	on execute do (
		if selection.count == 2 then (
			local hull, msh
			local ob1 = selection[1]
			local n1= ob1.name
			local ob2 = selection[2]
			local n2= ob2.name
			case of (
				(matchpattern n1 pattern:"*_collision"  OR matchpattern  n1 pattern:"*_hull"  OR matchpattern  n1 pattern:"*_phys"  OR matchpattern  n1 pattern:"*_physics") :(
					hull = ob1
					msh = ob2
				)
				(matchpattern  n2 pattern:"*_collision"  OR matchpattern  n2 pattern:"*_hull"  OR matchpattern  n2 pattern:"*_phys"  OR matchpattern  n2 pattern:"*_physics") :(
					hull = ob2
					msh = ob1
				)
				default:(
				)
			)
			
			if isValidNode msh AND isValidNode hull then (
				
				local nmethod = 3
				
				if classof msh == fbxMaxWrapper then (
					--addmodifier msh (XForm())
					nmethod = 2
				)
				if classof hull == fbxMaxWrapper then (
					--addmodifier hull (XForm())
					nmethod = 2
				)
				if ::ww_LOD_wrapper == undefined OR ::wallworm_remove_proxy == undefined then (
					macros.run "wallworm.com" "WallWormInitialize"
				)
				if ::ww_LOD_wrapper != undefined then (
					local tempWWMT = ww_LOD_wrapper()
					tempWWMT.init()
					tempWWMT.setTargetModel msh tempWWMT
					tempWWMT.addPhysModel hull
					tempWWMT.processPhys()
					theRealHullCount = ::wwmt_count_hulls (#(hull)) true
					if theRealHullCount > 1 then (
						tempWWMT.setConcave true
					)
					tempWWMT.setNormalMethod nmethod
					if msh.pos == [0,0,0] then (
						tempWWMT.setLocalOrigin false
						tempWWMT.setRotateRefsystem false
					) else (
						tempWWMT.setLocalOrigin true
					)					
				) else (
					messagebox "Wall Worm isn't properly installed."
				)
			) else (
				messagebox "This function requires one object to have a recognized hull name"
			)
			
		) else messagebox "This function only works when two objects are selected."
	)
)