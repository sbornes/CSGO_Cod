::ww_wwmt_version = 2.727
::wallworm_entity_version = 59
::wallwormWWMTCAversion = 46

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

::wallworm_globalIni = (::wallworm_installation_path + "/WallWorm.com/config/wwmt-defaults.ini")
::wallworm_userIni = ((symbolicPaths.getPathValue "$userScripts") + "/WallWorm.com/config/wwmt.ini")

if (::wallworm_userIni == undefined OR doesFileExist ::wallworm_userIni == false) then (
	::wwmtinifolder = ((symbolicPaths.getPathValue "$userScripts") + "/WallWorm.com/config")
	if (makeDir ::wwmtinifolder all:true == false) then (
		print "Config Directory doesn't exist"
		messageBox "There is no config directory for the WW Model Tools... and MAXScript does not have permission to write to the appropriate directory."
	)
	::wallworm_userIni = ((symbolicPaths.getPathValue "$userScripts") + "/WallWorm.com/config/wwmt.ini")
)

::wallworm_getINISettingWithDefault = function wallworm_getINISetting heading val defaultValue = (
	local ret = getINISetting ::wallworm_userIni heading val
	if ret == "" OR ret == "undefined" then (
		ret = defaultValue
		setINISetting ::wallworm_userIni heading val (ret as String)
	)
	ret
)

::wallworm_getINISetting = function wallworm_getINISetting heading val = (
	local ret = getINISetting ::wallworm_userIni heading val
	if ret == "" then (
		ret = getINISetting ::wallworm_globalIni heading val
		setINISetting ::wallworm_userIni heading val ret
	)
	ret
)

::wallworm_EULA = (::wallworm_getINISettingWithDefault "Agreement" "EULA" false) as BooleanClass
if ::wallworm_EULA != true then (
	fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
)
::WallWormdefaultSMDExporter = 3
if ::wallworm_EULA then (
	if ::wallworm_has_loaded_assemblies == undefined OR ::wallworm_has_loaded_assemblies == false then (
		function wallworm_loadAssembliesInDirectory dir = (
			for plug in getFiles (dir + "/*.dll") do (
				try (
					local asm = dotnet.loadAssembly plug
					for type in (asm.GetTypes()) WHERE type.Name == "AssemblyStartup" do (
						(type.GetMethod "Initialize").Invoke null #()
					)
					-- TODO: Log an error if an assembly fails to load correctly.
				) catch (print (getCurrentException()))
			)
		)
		-- This doesn't scan recursively to allow plugins to conditionally load libraries if needed.
		wallworm_loadAssembliesInDirectory (::wallworm_installation_path + "/WallWorm.com/assemblies")

		::wallworm_has_loaded_assemblies = true
	)
	if ::WallWormProHelpers == undefined then (
		::WallWormProHelpers = (try (DotNetClass "WallWorm.Helpers.ProHelper") catch (undefined))
		if ::WallWormProHelpers != undefined then (
			::WallwormProActive = ::WallWormProHelpers.IsLicensed()
			if ::WallwormProActive == true then (
				::WallWormVTFCmdPath = ::wallworm_getINISettingWithDefault "Directories" "VTFCmdPath" ""
				::WallWormVTFVersion = ::wallworm_getINISettingWithDefault "Materials" "vtfversion" "7.4"
			)
		) else (
			::WallwormProActive = false
		)
	) else if ::WallwormProActive == undefined then (
		::WallwormProActive = false
	)

	if ::WallWormProSMD == undefined then (
		::WallWormProSMD = (try (DotNetObject "WallWorm.Helpers.SMDHelper") catch (undefined))
		if ::WallWormProSMD == undefined OR ::WallwormProActive != true then (::WallWormdefaultSMDExporter = 3) else (::WallWormdefaultSMDExporter = 4)
	)
) else (
	::WallwormProActive = false
)

if ::wallwormUpdateNotice == undefined then (
	::wallwormUpdateNotice = false
)
if ::wallwormUpdateCheck == undefined then (
	::wallwormUpdateCheck = false
)

::wallworm_debug = (::wallworm_getINISettingWithDefault "Settings" "wallworm_debug" false) as BooleanClass
::wallworm_enablePerformanceCounters = (::wallworm_getINISettingWithDefault "Settings" "wallworm_enablePerformanceCounters" false) as BooleanClass
::WWuseLegacyVMTImport = (::wallworm_getINISettingWithDefault "Settings" "WWuseLegacyVMTImport" false) as BooleanClass
::wallwormMXSVMF = (::wallworm_getINISettingWithDefault "Settings" "wallwormMXSVMF" false) as BooleanClass
::WWLegacyFGD = (::wallworm_getINISettingWithDefault "Settings" "WWLegacyFGD" false) as BooleanClass -- Whether to use legacy WW Entities or WW Pro when installed
if ::WallWormProSMD == undefined then (
	::wwmt_default_dmx = false
) else (
	tmp = (::wallworm_getINISettingWithDefault "Settings" "wwmt_default_dmx" false)
	if tmp != undefined AND tmp != "undefined" then (
		::wwmt_default_dmx = tmp as BooleanClass
	)
)

::wwmt_dmx_version = (::wallworm_getINISettingWithDefault "Settings" "wwmt_dmx_version" 18) as Integer -- 1,15,18,22
::wallworm_engine = (::wallworm_getINISettingWithDefault "Settings" "engine" 2) as Integer
::wallworm_spacing = (::wallworm_getINISettingWithDefault "Settings" "spacing" 64) as Integer
::wallworm_displacement_events = (::wallworm_getINISettingWithDefault "Displacements" "wallworm_displacement_events" true) as BooleanClass
::wallworm_text_editor = (::wallworm_getINISettingWithDefault "Applications" "text_editor" "notepad.exe")
::wallworm_use_WW_VBSP = ::wallworm_getINISetting "Exporters" "ww_vbsp"
::wwmt_CompileMessage = (::wallworm_getINISettingWithDefault "Settings" "wwmtCompileMessage" false) as BooleanClass
::wwmtAutoCompile = (::wallworm_getINISettingWithDefault "Settings" "wwmtAutoCompile" true) as BooleanClass
::wwmtAutoOpenFolder = (::wallworm_getINISettingWithDefault "Settings" "wwmtAutoOpenFolder" false) as BooleanClass
::wwmt_FOV = (::wallworm_getINISettingWithDefault "Settings" "FOV" 75) as Integer
::wwmt_LODOptimize = (::wallworm_getINISettingWithDefault "Settings" "wwmt_LODOptimize" 1) as Integer
::wwmt_allow_psd = (::wallworm_getINISettingWithDefault "Materials" "wwmt_allow_psd" false) as BooleanClass
::wwmt_autoMaterialNewModel = (::wallworm_getINISettingWithDefault "Materials" "wwmt_autoMaterialNewModel" true) as BooleanClass
::wwmt_createLayers = (::wallworm_getINISettingWithDefault "Settings" "createLayers" false) as BooleanClass
::wwmt_def_fgd = ::wallworm_getINISettingWithDefault "Directories" "wwmt_def_fgd" ""
::wwmt_def_material_path = (::wallworm_getINISettingWithDefault "Directories" "def_material_path" "myproject")
::wwmt_def_model_path = (::wallworm_getINISettingWithDefault "Directories" "def_model_path" "myproject")
::wwmt_default_staticprop = (::wallworm_getINISettingWithDefault "Settings" "wwmt_default_staticprop" false) as BooleanClass
::wwmt_exportNonRenderableMeshAsBone = (::wallworm_getINISettingWithDefault "Settings" "wwmt_exportNonRenderableMeshAsBone" false) as BooleanClass
::wwmt_forceOpaqueFromModel = (::wallworm_getINISettingWithDefault "Materials" "wwmt_forceOpaqueFromModel" false) as BooleanClass
::wwmt_horizontalRes = (::wallworm_getINISettingWithDefault "Settings" "horizontalRes" 1920) as Integer
::wwmt_hull_limit_handling = (::wallworm_getINISettingWithDefault "Settings" "wwmt_hull_limit_handling" 2) as Integer
::wwmt_legacy_names = (::wallworm_getINISettingWithDefault "Materials" "wwmt_legacy_names" false) as BooleanClass
::wwmt_makeHullsNonRenderable = (::wallworm_getINISettingWithDefault "Settings" "wwmt_makeHullsNonRenderable" false) as BooleanClass
::wwmt_mappingChannel = (::wallworm_getINISettingWithDefault "Settings" "wwmt_mappingChannel" 1) as Integer
::wwmt_oldModelVTFPath = (::wallworm_getINISettingWithDefault "Materials" "wwmt_oldModelVTFPath" false) as BooleanClass
::wwmt_overWriteQC = (::wallworm_getINISettingWithDefault "Settings" "overWriteQC" true) as BooleanClass
::wwmt_raw_mats = ::wallworm_getINISetting "Directories" "wwmt_raw_mats"
::wwmt_refLOD = (::wallworm_getINISettingWithDefault "Settings" "wwmt_refLOD" false) as BooleanClass
::wwmt_rotateRefsystem = (::wallworm_getINISettingWithDefault "Settings" "wwmt_rotateRefsystem" false) as BooleanClass
::wwmt_translucentOnlyIfOpacityMap = (::wallworm_getINISettingWithDefault "Materials" "wwmt_translucentOnlyIfOpacityMap" true) as BooleanClass
::wwmt_use_local_origin = (::wallworm_getINISettingWithDefault "Settings" "wwmt_use_local_origin" true) as BooleanClass
::wwmt_verticalRes = (::wallworm_getINISettingWithDefault "Settings" "verticalRes" 1080) as Integer
--this setting is whether the vmf exportor should use the esc character to separate outputs, which is used in later versions of Hammer --can be overwritten per level
::wwmt_vmf_output_separator_esc = ::wallworm_getINISetting "Settings" "wwmt_vmf_output_separator_esc"

::wwmt_walkThroughOpsstepSize = (::wallworm_getINISettingWithDefault "Settings" "walkThroughOpsstepSize" 768) as Integer -- 1,15,18,22
walkThroughOps.stepSize = ::wwmt_walkThroughOpsstepSize

::wwmt_installedversion = getINISetting ::wallworm_userIni "Version" "wwmt_installedversion"
if ::wwmt_installedversion == undefined OR ::wwmt_installedversion == "" OR (::wwmt_installedversion as Number) < ::ww_wwmt_version then (
	fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/addWWtoMaxMenu.ms")
	setINISetting ::wallworm_userIni "Version" "wwmt_installedversion" (::ww_wwmt_version as String)

	if ::wwmt_installedversion == undefined OR ::wwmt_installedversion == "" OR (::wwmt_installedversion as Number) < 2.4 then (
		local wwmts = for obj in objects WHERE isProperty obj #wwmt_ca collect obj
		if wwmts.count > 0 then (
			messageBox "Because there are WWMT Helpers in the current scene, you should restart Max."
		)
	)

	if ::wallwormUpdateNotice == false AND ::wallworm_getMaxVersion != undefined then (
		fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
		--shellLaunch ("http://dev.wallworm.com/topic/33/wwmt_changelog.html?previous="+(::wwmt_installedversion as string)) ""
		local maxInfo = ::wallworm_getMaxVersion()
		shellLaunch ("http://dev.wallworm.com/topic/33/wwmt_changelog.html?previous=" + (::wwmt_installedversion as String) + "&installed=" + (::ww_wwmt_version as String) + "&maxversion=" + (maxInfo[1] as String) + "&maxupdateversion=" + (maxInfo[2] as String)) ""
		::wallwormUpdateNotice = true
	)
)

::wwmt_gameInfoDir = getINISetting ::wallworm_userIni "Directories" "gameInfoDir"
::wwmt_sdk_folder = getINISetting ::wallworm_userIni "Directories" "wwmt_sdk_folder"
if ::wwmt_sdk_folder == "" then (
	::wwmt_sdk_folder = (DotNetClass "System.Environment").GetEnvironmentVariable("sourcesdk")

	::wwmt_valvemod_arraystr = (DotNetClass "System.Environment").GetEnvironmentVariable("VProject")

	if ::wwmt_valvemod_arraystr != undefined AND ::wwmt_valvemod_arraystr != "" then (
		if ::wwmt_gameInfoDir == undefined OR ::wwmt_gameInfoDir == "" then (
			::wwmt_gameInfoDir = ::wwmt_valvemod_arraystr
			setINISetting ::wallworm_userIni "Directories" "gameInfoDir" ::wwmt_gameInfoDir
		)

		if ::wwmt_sdk_folder != undefined then (
			::wwmt_valvemod_array = filterString ::wwmt_valvemod_arraystr "\\"
			if ::wwmt_valvemod_array.count > 0 then (
				append ::wwmt_sdk_folder ("_content\\" + wwmt_valvemod_array[wwmt_valvemod_array.count])
			)
		)
	)

	if ::wwmt_sdk_folder != undefined then (
		setINISetting ::wallworm_userIni "Directories" "wwmt_sdk_folder" ::wwmt_sdk_folder
	)
)


::wwmt_wwmt_gameInfoDirs = #()
::wwmt_gameInfoDirstmp = getINISetting ::wallworm_userIni "Directories" "gameInfoDirs" -- for extrapaths
if wwmt_gameInfoDirstmp != "" then (
	for word in (filterString wwmt_gameInfoDirstmp ";") do (
		append ::wwmt_wwmt_gameInfoDirs word
	)
)


if ::wwmt_sdk_folder == undefined then (
	::wwmt_sdk_folder = ""
)

::wwmt_export = getINISetting ::wallworm_userIni "Directories" "export"
if ::wwmt_export == "" then (
	if ::wwmt_sdk_folder == undefined OR ::wwmt_sdk_folder == "" then (
		::wwmt_export = getINISetting ::wallworm_globalIni "Directories" "export"
	) else (
		::wwmt_export = (::wwmt_sdk_folder + "\\modelsrc")
	)

	setINISetting ::wallworm_userIni "Directories" "export" (::wwmt_sdk_folder + "\\modelsrc")
)

::wwmt_exportMats = getINISetting ::wallworm_userIni "Directories" "exportMats"
if ::wwmt_exportMats == "" then (
	if ::wwmt_sdk_folder == undefined OR ::wwmt_sdk_folder == "" then (
		::wwmt_exportMats = getINISetting ::wallworm_globalIni "Directories" "exportMats"
	) else (
		::wwmt_exportMats = (::wwmt_sdk_folder + "\\materialsrc")
	)

	setINISetting ::wallworm_userIni "Directories" "exportMats" (::wwmt_sdk_folder + "\\materialsrc")
)

::wwdt_mapsrc = getINISetting ::wallworm_userIni "Directories" "exportMaps"
if (::wwdt_mapsrc == undefined OR ::wwdt_mapsrc == "") AND ::wwmt_sdk_folder != undefined AND ::wwmt_sdk_folder != "" then (
	::wwdt_mapsrc = (::wwmt_sdk_folder + "\\mapsrc")
	setINISetting ::wallworm_userIni "Directories" "exportMaps" ::wwdt_mapsrc
)

::wwmt_binDir = getINISetting ::wallworm_userIni "Directories" "binDir"
if ::wwmt_binDir == "" then (
	local wwmt_tmpBin = (DotNetClass "System.Environment").GetEnvironmentVariable("sourcesdk")
	if wwmt_tmpBin != undefined then (
		::wwmt_binDir = (wwmt_tmpBin + "\\bin\\orangebox\\bin")
		setINISetting ::wallworm_userIni "Directories" "binDir" ::wwmt_binDir
		tmpBin = undefined
	) else (
		setINISetting ::wallworm_userIni "Directories" "binDir" ""
	)
)

::wwmt_lodLimit = (::wallworm_getINISetting "Settings" "lodLimit") as Integer
if ::wwmt_lodLimit < 1 then (
	::wwmt_lodLimit = 1
)

::wwmtExporter = (::wallworm_getINISettingWithDefault "Settings" "wwmtExporter" ::WallWormdefaultSMDExporter) as Integer
if ::wwmtExporter == undefined OR ::wwmtExporter < 1 OR ::wwmtExporter > 4 then (
	if ::WallWormProSMD == undefined then (
		::wwmtExporter = 3
		setINISetting ::wallworm_userIni "Settings" "wwmtExporter" "3"
	) else (
		::wwmtExporter = 4
		setINISetting ::wallworm_userIni "Settings" "wwmtExporter" "4"
	)
)

::wwmt_current_model_Paths = #()
currentModelPathtList = ::wallworm_getINISettingWithDefault "Directories" "wwmt_saved_model_path_list" "myproject"
if currentModelPathtList != "" then (
	for word in (filterString currentModelPathtList ",") do (
		append ::wwmt_current_model_Paths word
	)
)

if ::wwmt_def_model_path != undefined AND ::wwmt_def_model_path != "" AND findItem ::wwmt_current_model_Paths ::wwmt_def_model_path == 0 then (
	append ::wwmt_current_model_Paths ::wwmt_def_model_path
)

::wwmt_current_material_Paths = #()
currentMaterialPathList = ::wallworm_getINISettingWithDefault "Directories" "wwmt_saved_material_path_list" "myproject"
if currentMaterialPathList != "" then (
	for word in (filterString currentMaterialPathList ",") do (
		append ::wwmt_current_material_Paths word
	)
)

if ::wwmt_def_material_path != undefined AND ::wwmt_def_material_path != "" AND findItem ::wwmt_current_material_Paths ::wwmt_def_material_path == 0 then (
	append ::wwmt_current_material_Paths ::wwmt_def_material_path
)

::wallworm_winrar = getINISetting ::wallworm_userIni "Applications" "winrar"
if ::wallworm_winrar == "" then (
	if doesFileExist ("c:\\Program Files\\WinRar\\WinRar.exe") then (
		::wallworm_winrar = "c:\\Program Files\\WinRar"
	) else if doesFileExist ("c:\\Program Files\\WinRar\\WinRar.exe") then (
		::wallworm_winrar = "c:\\Program Files (x86)\\WinRar"
	) else (
		pths = filterString ((DotNetClass "System.Environment").GetEnvironmentVariable("path")) ";"
		for p in pths while ::wallworm_winrar == "" do (
			if matchPattern p pattern:"*winrar*" ignoreCase:true then (
				::wallworm_winrar = p
			)
		)
	)
	if ::wallworm_winrar == "" then (
		::wallworm_winrar = "c:\\Program Files\\WinRar"
	)
	setINISetting ::wallworm_userIni "Applications" "winrar" ::wallworm_winrar

)

/*This variable exists because Max 2014 changed the way getBoneName works*/
if ::wallworm_skinops_getBoneNameByListID == undefined then (
	::wallworm_skinops_getBoneNameByListID = skinOps.getBoneName
	if (hasProperty skinOps #getBoneNameByListID) then (
		::wallworm_skinops_getBoneNameByListID = skinOps.getBoneNameByListID
	)
)

if ::wallworm_mapsize == undefined OR classOf ::wallworm_mapsize != Point2 then (
	::wallworm_mapsize = [-16384, 16384]
)

::wwmt_surfaceprop_list = #(
	"",
	"Metal_Box",
	"Plastic_Box",
	"Wood_Box",
	"Wood_Crate",
	"Wood_Furniture",
	"Wood_Panel",
	"Wood_Plank",
	"Wood_Solid",
	"Wood_lowdensity",
	"alienflesh",
	"antlion",
	"antlionsand",
	"armorflesh",
	"asphalt",
	"baserock",
	"bloodyflesh",
	"boulder",
	"brakingrubbertire",
	"brick",
	"canister",
	"cardboard",
	"carpet",
	"ceiling_tile",
	"chain",
	"chainlink",
	"combine_glass",
	"combine_metal",
	"computer",
	"concrete",
	"concrete_block",
	"crowbar",
	"default",
	"default_silent",
	"dirt",
	"flesh",
	"floating_metal_barrel",
	"floatingstandable",
	"foliage",
	"glass",
	"glassbottle",
	"grass",
	"gravel",
	"gravel",
	"grenade",
	"gunship",
	"ice",
	"item",
	"jeeptire",
	"ladder",
	"metal",
	"metal_barrel",
	"metal_bouncy",
	"metal_seafloorcar",
	"metalgrate",
	"metalpanel",
	"metalvehicle",
	"metalvent",
	"mud",
	"no_decal",
	"paintcan",
	"paper",
	"papercup",
	"plaster",
	"plastic",
	"plastic_barrel",
	"plastic_barrel_buoyant",
	"player",
	"player_control_clip",
	"popcan",
	"pottery",
	"quicksand",
	"rock",
	"roller",
	"rubber",
	"rubbertire",
	"sand",
	"slidingrubbertire",
	"slidingrubbertire_front",
	"slidingrubbertire_rear",
	"slime",
	"slipperymetal",
	"slipperyslime",
	"snow",
	"solidmetal",
	"strider",
	"tile",
	"wade",
	"water",
	"watermelon",
	"weapon",
	"wood",
	"zombieflesh"
)
