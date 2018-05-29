struct WallWormConfig (
	_wwmt_def_fgd,
	_wwmt_raw_mats,
	_wwdt_mapsrc,
	_wwmt_current_material_Paths,
	_wwmt_current_model_Paths,
	_wwmt_mappingChannel,
	_wwmt_FOV,
	_wwmt_verticalRes,
	_wwmt_horizontalRes,
	_wwmt_LODOptimize,
	_wwmt_hull_limit_handling,
	_wwmtExporter,
	_wwmt_hull_tool = 1,
	_wwmt_lodLimit,
	_wwmt_createLayers,
	_wwmtAutoOpenFolder,
	_wwmt_autoMaterialNewModel,
	_wwmt_overWriteQC,
	_wwmt_makeHullsNonRenderable,
	_wwmt_refLOD,
	_wwmt_default_staticprop,
	_wwmt_use_local_origin,
	_wwmt_exportNonRenderableMeshAsBone,
	_wwmt_forceOpaqueFromModel,
	_wwmt_translucentOnlyIfOpacityMap,
	_wwmtCompileMessage,
	_wwmtAutoCompile,
	_wwmt_gameInfoDir,
	_wwmt_binDir,
	_wwmt_def_material_path,
	_wwmt_def_model_path,
	_wwmt_exportMats,
	_wwmt_export,
	_wwmt_allow_psd,
	_wwmt_mat_textransform_vmts,
	_wwmt_oldModelVTFPath,
	_wwmt_legacy_names,
	_wwmt_rotateRefsystem,
	_wallworm_text_editor = "notepad",
	_wallworm_winrar,
	_wallworm_displacement_events = true,
	_wwmt_copyTarget = false, -- needs to be here for legacy purposes. old instances of the data have this property stored and there is a MAXScript error if the property is missing when loading old settings files.
	_wwmt_default_dmx = false,
	_wwmt_dmx_version = 18,
	_startupConfig = false,
	_checkForUpdates = false,
	_wallworm_engine = 2,
	_WWuseLegacyVMTImport = false,
	_wallwormMXSVMF = false,
	_WWLegacyFGD = false,
	_WallWormVTFVersion = "7.4",
	_walkThroughOpsstepSize = 768,
	function replace_improper_vals str = (
		str = substituteString str "\t" "\\t"
		str = substituteString str "\n" "\\n"
		str = substituteString str "\r" "\\r"
		str = substituteString str "\x" "\\x"
		str
	),

	function makeBoolean v def:true = (
		local out
		case v of (
			true:out = true
			false:out = false
			"true":out = true
			"false":out = false
			1 : out = true
			0 : out = false
			on : out = true
			off : out = false
			"1" : out = true
			"0" : out = false
			default:(
				out = def
			)
		)
		out
	),

	function sanitize_vars = (
		
		_wwmt_raw_mats =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_raw_mats)) char:"/")
		_wwdt_mapsrc =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwdt_mapsrc)) char:"/")
		_wwmt_gameInfoDir =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_gameInfoDir)) char:"/")
		_wwmt_binDir =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_binDir)) char:"/")
		_wwmt_def_material_path =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_def_material_path)) char:"/")
		_wwmt_def_model_path =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_def_model_path)) char:"/")
		_wallworm_winrar =  (wallworm_remove_last_slash (wallworm_BStoFS (_wallworm_winrar)) char:"/")
		_wwmt_def_fgd =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_def_fgd)) char:"/")
		_wwmt_exportMats =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_exportMats)) char:"/")
		_wwmt_export =  (wallworm_remove_last_slash (wallworm_BStoFS (_wwmt_export)) char:"/")

		for i = 1 to _wwmt_current_material_Paths.count do (
			_wwmt_current_material_Paths[i] = (wallworm_remove_last_slash (wallworm_BsToFS (_wwmt_current_material_Paths[i])) char:"/")
		)
		for i = 1 to _wwmt_current_model_Paths.count do (
			_wwmt_current_model_Paths[i] = (wallworm_remove_last_slash (wallworm_BsToFS (_wwmt_current_model_Paths[i])) char:"/")
		)

		_wwmt_createLayers = makeBoolean _wwmt_createLayers def:false
		_wwmtAutoOpenFolder = makeBoolean _wwmtAutoOpenFolder def:false
		_wwmt_autoMaterialNewModel = makeBoolean _wwmt_autoMaterialNewModel def:true
		_wwmt_overWriteQC = makeBoolean _wwmt_overWriteQC def:true
		_wwmt_makeHullsNonRenderable = makeBoolean _wwmt_makeHullsNonRenderable def:false
		_wwmt_refLOD = makeBoolean _wwmt_refLOD def:false
		_wwmt_default_staticprop = makeBoolean _wwmt_default_staticprop def:false
		_wwmt_use_local_origin = makeBoolean _wwmt_use_local_origin def:true
		_wwmt_exportNonRenderableMeshAsBone = makeBoolean _wwmt_exportNonRenderableMeshAsBone def:false
		_wwmt_forceOpaqueFromModel = makeBoolean _wwmt_forceOpaqueFromModel def:false
		_wwmt_translucentOnlyIfOpacityMap = makeBoolean _wwmt_translucentOnlyIfOpacityMap def:true
		_wwmtCompileMessage = makeBoolean _wwmtCompileMessage def:false
		_wwmtAutoCompile = makeBoolean _wwmtAutoCompile def:true
		_wwmt_allow_psd = makeBoolean _wwmt_allow_psd def:false
		_wallworm_displacement_events = makeBoolean _wallworm_displacement_events def:true

		_wwmt_oldModelVTFPath = makeBoolean _wwmt_oldModelVTFPath def:false
		_wwmt_legacy_names = makeBoolean _wwmt_legacy_names def:false
		_wwmt_rotateRefsystem = makeBoolean _wwmt_rotateRefsystem def:true
		_wwmt_default_dmx = makeBoolean _wwmt_default_dmx def:false
		_startupConfig = makeBoolean _startupConfig def:false
		_checkForUpdates = makeBoolean _checkForUpdates def:false
		_WWLegacyFGD = makeBoolean _WWLegacyFGD def:false

		if _wwmt_dmx_version == undefined then (
			_wwmt_dmx_version = 18
		)

		if _wallworm_engine == undefined then (
			_wallworm_engine = 2
		) else (
			_wallworm_engine = _wallworm_engine as Integer
		)
		_WWuseLegacyVMTImport = makeBoolean _WWuseLegacyVMTImport def:false
		_wallwormMXSVMF = makeBoolean _wallwormMXSVMF def:false

		if findItem (#("7.0", "7.1", "7.2", "7.3", "7.4", "7.5")) _WallWormVTFVersion == 0 then (
			_WallWormVTFVersion = "7.4"
		)
		if _walkThroughOpsstepSize == undefined then (
			_walkThroughOpsstepSize = 768
		) else (
			_walkThroughOpsstepSize = _walkThroughOpsstepSize as integer
		)

	),

	function setGlobalsFromPreset = (
		sanitize_vars()
		::wallworm_userIni
		::wwmt_def_fgd = _wwmt_def_fgd
		::wwmt_raw_mats = _wwmt_raw_mats
		::wwdt_mapsrc = _wwdt_mapsrc
		/*::wwmt_current_material_Paths = _wwmt_current_material_Paths
		::wwmt_current_model_Paths = _wwmt_current_model_Paths*/
		::wwmt_mappingChannel = _wwmt_mappingChannel as Integer
		::wwmt_FOV = _wwmt_FOV as Integer
		::wwmt_verticalRes = _wwmt_verticalRes as Integer
		::wwmt_horizontalRes = _wwmt_horizontalRes as Integer
		::wwmt_LODOptimize = _wwmt_LODOptimize as Integer
		::wwmt_hull_limit_handling = _wwmt_hull_limit_handling as Integer
		::wwmtExporter = _wwmtExporter as Integer
		::wwmt_lodLimit = _wwmt_lodLimit as Integer
		::wwmt_createLayers = _wwmt_createLayers as BooleanClass
		::wwmtAutoOpenFolder = _wwmtAutoOpenFolder as BooleanClass
		::wwmt_autoMaterialNewModel = _wwmt_autoMaterialNewModel as BooleanClass
		::wwmt_mappingChannel = _wwmt_mappingChannel as Integer
		::wwmt_overWriteQC = _wwmt_overWriteQC as BooleanClass
		::wwmt_makeHullsNonRenderable = _wwmt_makeHullsNonRenderable as BooleanClass
		::wwmt_refLOD = _wwmt_refLOD as BooleanClass
		::wwmt_default_staticprop = _wwmt_default_staticprop as BooleanClass
		::wwmt_use_local_origin = _wwmt_use_local_origin as BooleanClass
		::wwmt_exportNonRenderableMeshAsBone = _wwmt_exportNonRenderableMeshAsBone as BooleanClass
		::wwmt_forceOpaqueFromModel = _wwmt_forceOpaqueFromModel as BooleanClass
		::wwmt_translucentOnlyIfOpacityMap = _wwmt_translucentOnlyIfOpacityMap as BooleanClass
		::wwmt_CompileMessage = _wwmtCompileMessage as BooleanClass
		::wwmtAutoCompile = _wwmtAutoCompile as BooleanClass
		::wwmt_gameInfoDir = _wwmt_gameInfoDir
		::wwmt_binDir = _wwmt_binDir
		::wwmt_def_material_path = _wwmt_def_material_path
		::wwmt_def_model_path = _wwmt_def_model_path
		::wwmt_exportMats = _wwmt_exportMats
		::wwmt_export = _wwmt_export
		::wwmt_allow_psd = _wwmt_allow_psd as BooleanClass
		::wallworm_text_editor = _wallworm_text_editor
		::wallworm_winrar = _wallworm_winrar
		::wallworm_displacement_events = _wallworm_displacement_events as BooleanClass
		::wwmt_walkThroughOpsstepSize = _walkThroughOpsstepSize as Integer
		::wwmt_default_dmx = _wwmt_default_dmx as BooleanClass
		::wwmt_dmx_version = _wwmt_dmx_version as Integer

		if ::wallworm_text_editor == undefined then (
			::wallworm_text_editor = "notepad.exe"
		)

		if ::wallworm_winrar == undefined then (
			::wallworm_winrar = "C:\Program Files\WinRAR"
		)

		::WWuseLegacyVMTImport = _WWuseLegacyVMTImport as BooleanClass
		::wallwormMXSVMF = _wallwormMXSVMF as BooleanClass
		::WWLegacyFGD = _WWLegacyFGD as BooleanClass
		::wallworm_engine = _wallworm_engine as Integer
		::WallWormVTFVersion = _WallWormVTFVersion
		/*	
		global wwmt_mat_textransform_vmts = _wwmt_mat_textransform_vmts
		if wwmt_mat_textransform_vmts == undefined then (
			wwmt_mat_textransform_vmts = "true"
		)
		*/
		::wwmt_oldModelVTFPath = _wwmt_oldModelVTFPath
		::wwmt_legacy_names = _wwmt_legacy_names
		::wwmt_rotateRefsystem = _wwmt_rotateRefsystem
		
		
		::wwmt_raw_mats =  wallworm_FStoBS (::wwmt_raw_mats)
		::wwdt_mapsrc =  wallworm_FStoBS (::wwdt_mapsrc)
		::wwmt_gameInfoDir =  wallworm_FStoBS (::wwmt_gameInfoDir)
		::wwmt_binDir =  wallworm_FStoBS (::wwmt_binDir)
		::wwmt_def_material_path =  wallworm_FStoBS (::wwmt_def_material_path)
		::wwmt_def_model_path =  wallworm_FStoBS (::wwmt_def_model_path)
		::wallworm_winrar =  wallworm_FStoBS (::wallworm_winrar)
		::wwmt_def_fgd =  wallworm_FStoBS (::wwmt_def_fgd)
		::wwmt_exportMats =  wallworm_FStoBS (::wwmt_exportMats)
		::wwmt_export =  wallworm_FStoBS (::wwmt_export)

		
		

		setINISetting ::wallworm_userIni "Settings" "engine" (::wallworm_engine as String)
		setINISetting ::wallworm_userIni "Directories" "export" ::wwmt_export
		setINISetting ::wallworm_userIni "Directories" "exportMats" ::wwmt_exportMats
		setINISetting ::wallworm_userIni "Settings" "createLayers" (::wwmt_createLayers as String)
		setINISetting ::wallworm_userIni "Directories" "binDir" ::wwmt_binDir
		setINISetting ::wallworm_userIni "Settings" "lodLimit" (::wwmt_lodLimit as String)
		setINISetting ::wallworm_userIni "Settings" "wwmtAutoCompile" (::wwmtAutoCompile as String)
		setINISetting ::wallworm_userIni "Settings" "wwmtAutoOpenFolder" (::wwmtAutoOpenFolder as String)
		setINISetting ::wallworm_userIni "Settings" "FOV" (::wwmt_FOV as String)
		setINISetting ::wallworm_userIni "Settings" "horizontalRes" (::wwmt_horizontalRes as String)
		setINISetting ::wallworm_userIni "Settings" "verticalRes" (::wwmt_verticalRes as String)
		setINISetting ::wallworm_userIni "Settings" "wwmtExporter" (::wwmtExporter as String)
		setINISetting ::wallworm_userIni "Directories" "def_material_path" ::wwmt_def_material_path
		setINISetting ::wallworm_userIni "Directories" "def_model_path" ::wwmt_def_model_path
		setINISetting ::wallworm_userIni "Directories" "gameInfoDir" ::wwmt_gameInfoDir
		setINISetting ::wallworm_userIni "Settings" "wwmt_exportNonRenderableMeshAsBone" (::wwmt_exportNonRenderableMeshAsBone as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_makeHullsNonRenderable" (::wwmt_makeHullsNonRenderable as String)
		setINISetting ::wallworm_userIni "Settings" "overWriteQC" (::wwmt_overWriteQC as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_mappingChannel" (::wwmt_mappingChannel as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_translucentOnlyIfOpacityMap" (::wwmt_translucentOnlyIfOpacityMap as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_forceOpaqueFromModel" (::wwmt_forceOpaqueFromModel as String)
		--setINISetting ::wallworm_userIni "Materials" "wwmt_mat_textransform_vmts" wwmt_mat_textransform_vmts
		setINISetting ::wallworm_userIni "Materials" "wwmt_allow_psd" (::wwmt_allow_psd as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_oldModelVTFPath" (::wwmt_oldModelVTFPath as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_legacy_names" (::wwmt_legacy_names as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_hull_limit_handling" (::wwmt_hull_limit_handling as String)
		setINISetting ::wallworm_userIni "Materials" "vtfversion" ::WallWormVTFVersion
		setINISetting ::wallworm_userIni "Directories" "exportMaps" ::wwdt_mapsrc
		setINISetting ::wallworm_userIni "Settings" "wwmtCompileMessage" (_wwmtCompileMessage as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_autoMaterialNewModel" (::wwmt_autoMaterialNewModel as String)
		setINISetting ::wallworm_userIni "Materials" "wwmt_allow_psd" (::wwmt_allow_psd as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_refLOD" (::wwmt_refLOD as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_use_local_origin" (::wwmt_use_local_origin as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_LODOptimize" (::wwmt_LODOptimize as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_default_staticprop" (::wwmt_default_staticprop as String)
		setINISetting ::wallworm_userIni "Directories" "wwmt_def_fgd" ::wwmt_def_fgd
		setINISetting ::wallworm_userIni "Settings" "wwmt_rotateRefsystem" (::wwmt_rotateRefsystem as String)
		setINISetting ::wallworm_userIni "Applications" "text_editor" ::wallworm_text_editor
		setINISetting ::wallworm_userIni "Applications" "winrar" ::wallworm_winrar
		setINISetting ::wallworm_userIni "Directories" "wwmt_raw_mats" ::wwmt_raw_mats
		setINISetting ::wallworm_userIni "Displacements" "wallworm_displacement_events" (::wallworm_displacement_events as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_default_dmx" (::wwmt_default_dmx as String)
		setINISetting ::wallworm_userIni "Settings" "wwmt_dmx_version" (::wwmt_dmx_version as String)
		setINISetting ::wallworm_userIni "StartUp" "config" (_startupConfig as String)
		setINISetting ::wallworm_userIni "StartUp" "checkForUpdates" (_checkForUpdates as String)
		setINISetting ::wallworm_userIni "Settings" "WWuseLegacyVMTImport" (_WWuseLegacyVMTImport as String)
		setINISetting ::wallworm_userIni "Settings" "wallwormMXSVMF" (_wallwormMXSVMF as String)
		setINISetting ::wallworm_userIni "Settings" "WWLegacyFGD" (_WWLegacyFGD as String)
		setINISetting ::wallworm_userIni "Settings" "walkThroughOpsstepSize" (_walkThroughOpsstepSize as String)
	),

	function setPresetFromGlobals = (
		_wwmt_walkThroughOpsstepSize = ::wwmt_walkThroughOpsstepSize
		_wwmt_def_fgd = ::wwmt_def_fgd
		_wwmt_raw_mats = ::wwmt_raw_mats
		_wwdt_mapsrc = ::wwdt_mapsrc
		_wwmt_current_material_Paths = ::wwmt_current_material_Paths
		_wwmt_current_model_Paths = ::wwmt_current_model_Paths
		_wwmt_mappingChannel = ::wwmt_mappingChannel
		_wwmt_FOV = ::wwmt_FOV
		_wwmt_verticalRes = ::wwmt_verticalRes
		_wwmt_horizontalRes = ::wwmt_horizontalRes
		_wwmt_LODOptimize = ::wwmt_LODOptimize
		_wwmt_hull_limit_handling = ::wwmt_hull_limit_handling
		_wwmtExporter = ::wwmtExporter
		_wwmt_lodLimit = ::wwmt_lodLimit
		_wwmt_createLayers = ::wwmt_createLayers
		_wwmtAutoOpenFolder = ::wwmtAutoOpenFolder
		_wwmt_autoMaterialNewModel = ::wwmt_autoMaterialNewModel
		_wwmt_mappingChannel = ::wwmt_mappingChannel
		_wwmt_overWriteQC = ::wwmt_overWriteQC
		_wwmt_makeHullsNonRenderable = ::wwmt_makeHullsNonRenderable
		_wwmt_refLOD = ::wwmt_refLOD
		_wwmt_default_staticprop = ::wwmt_default_staticprop
		_wwmt_use_local_origin = ::wwmt_use_local_origin
		_wwmt_exportNonRenderableMeshAsBone = ::wwmt_exportNonRenderableMeshAsBone
		_wwmt_forceOpaqueFromModel = ::wwmt_forceOpaqueFromModel
		_wwmt_translucentOnlyIfOpacityMap = ::wwmt_translucentOnlyIfOpacityMap
		_wwmtCompileMessage = ::wwmt_CompileMessage
		_wwmtAutoCompile = ::wwmtAutoCompile
		_wwmt_gameInfoDir = ::wwmt_gameInfoDir
		_wwmt_binDir = ::wwmt_binDir
		_wwmt_def_material_path = ::wwmt_def_material_path
		_wwmt_def_model_path = ::wwmt_def_model_path
		_wwmt_exportMats = ::wwmt_exportMats
		_wwmt_export = ::wwmt_export
		_wwmt_allow_psd = ::wwmt_allow_psd
		_wwmt_mat_textransform_vmts = true
		_wwmt_oldModelVTFPath = ::wwmt_oldModelVTFPath
		_wwmt_legacy_names = ::wwmt_legacy_names
		_wwmt_rotateRefsystem = ::wwmt_rotateRefsystem
		_wallworm_winrar = ::wallworm_winrar
		_wallworm_text_editor = ::wallworm_text_editor
		_wallworm_displacement_events = ::wallworm_displacement_events
		_wwmt_default_dmx = ::wwmt_default_dmx
		_startupConfig = (::wallworm_getINISettingWithDefault "StartUp" "config" false) as BooleanClass
		_checkForUpdates = (::wallworm_getINISettingWithDefault "StartUp" "checkForUpdates" false) as BooleanClass
		_wallworm_engine = ::wallworm_engine
		_WWuseLegacyVMTImport = ::WWuseLegacyVMTImport
		_wallwormMXSVMF = ::wallwormMXSVMF
		_WWLegacyFGD = ::WWLegacyFGD
		_wwmt_dmx_version = ::wwmt_dmx_version
		_WallWormVTFVersion = ::WallWormVTFVersion
		sanitize_vars()
	),
	function setStartupScript preloadconfig:false checkforupdates:false = (
		/*If the installation is not in the 3ds Max Scripts folder, add an entry into the startup scripts to set the wallworm installation path to this install.*/
		local wwinstallationloader = "$userscripts/startup/wallworm_installation_path.ms"
		if doesFileExist wwinstallationloader then (
			wwstartupfile = openFile wwinstallationloader mode:"w+"
		) else (
			wwstartupfile = createFile wwinstallationloader
		)
		--this to avoid needing to escape values like \t \n, etc
		::wallworm_installation_path = substituteString ::wallworm_installation_path "\\" "/"

		format "::wallworm_installation_path = \"%\"\n" ::wallworm_installation_path to:wwstartupfile
		if preloadconfig AND (maxversion())[1] > 14000 then (
			format "wwconfigpath = (::wallworm_installation_path+\"/WallWorm.com/common/config.ms\")\n" to:wwstartupfile
			format "if doesFileExist wwconfigpath then (\n\tfileIn wwconfigpath\n)\n" to:wwstartupfile
			if checkforupdates then (
				format "::wallwormIsStartingUp = true\n" to:wwstartupfile
				format "wwcheckupatepath = (::wallworm_installation_path+\"/WallWorm.com/WallWormUtilities/checkForUpdate.ms\")\n" to:wwstartupfile
				format "if doesFileExist wwcheckupatepath then (\n\tfileIn wwcheckupatepath\n)\n" to:wwstartupfile
				format "::wallwormIsStartingUp = undefined\n" to:wwstartupfile
				format "free ::wallwormIsStartingUp\n" to:wwstartupfile
			)
		)
		close wwstartupfile
	),
	function saveStartup = (
		setINISetting ::wallworm_userIni "StartUp" "checkForUpdates" (_checkForUpdates as String)
		setINISetting ::wallworm_userIni "StartUp" "config" (_startupConfig as String)
		setStartupScript preloadconfig:_startupConfig checkforupdates:_checkForUpdates
	),
	function getStartupRollout = (
		if ::wallwormStartupOptionsRollout == undefined OR classOf ::wallwormStartupOptionsRollout != RolloutClass then (
			::wallwormStartupOptionsRollout = rollout wallwormStartupOptionsRollout "Wall Worm Startup Uptions" width:280 (
				local settingObj
				function setMySettings settingsObj = (
					settingObj = settingsObj
				)
				Group "Max Startup" (
					CheckBox chkLoadConfigAtStartUp "Load WW Config (recommended with WW Pro)" tooltip:"This will load the WW global settings and pre-load WW Pro's Assemblies to be ready when WW Loads (avoiding lag opening tools)." align:#left
					CheckBox chkCheckForUpdatesAtStartUp "Check For Updates" tooltip:"Check for updates to Wall Worm when Max starts." align:#left
				)
				Button btnSaveStartupSettings "Save Startup Options" width:260
				function prefillsettings = (
					if settingObj != undefined then (
						chkLoadConfigAtStartUp.checked = settingObj._startupConfig
						chkCheckForUpdatesAtStartUp.checked = settingObj._checkForUpdates
					)
				)
				on btnSaveStartupSettings pressed do (
					if settingObj != undefined then (
						settingObj._startupConfig = chkLoadConfigAtStartUp.checked
						settingObj._checkForUpdates = chkCheckForUpdatesAtStartUp.checked
						settingObj.saveStartup()
					)
				)
			)
		)
		::wallwormStartupOptionsRollout
	),
	function loadStartupRollout = (
		try (destroyDialog ::wallwormStartupOptionsRollout) catch ()
		getStartupRollout()
		createDialog ::wallwormStartupOptionsRollout
		::wallwormStartupOptionsRollout.setMySettings this
		::wallwormStartupOptionsRollout.prefillsettings()
	)
)
struct WallWormPresetStore (
	name = "New Preset",
	preset

)

function wallworm_parse_gameinfo filename = (
	local games = #()
	if ((doesFileExist filename) == false) then (
		false
	) else (
		local ms = memStreamMgr.openFile filename

		while ms.eos() == false do (
			ms.skipSpace()
			try (
				theline = ms.readLine()
			) catch (
				continue
			)
			theline = trimLeft theline
			if ((matchPattern theLine pattern:"\"games\"") == true) then (
				local gamesStr = wallworm_readBlock2 ms p1:"{" p2:"}"
				gameStream = memStreamMgr.openString gamesStr
				while gameStream.eos() == false do (
					gameStream.skipSpace()
					try (
						theline2 = gameStream.readLine()
					) catch (
						continue
					)
					if gameStream.peekToken() == "{" then (
						local preset = WallWormPresetStore()
						preset.preset = WallWormConfig()
						preset.preset.setPresetFromGlobals()
						preset.name = trimLeft (trimRight (substituteString theline2 "\"" ""))
						preset.preset._wwmt_binDir = wallworm_remove_last_slash (getFileNamePath filename) char:"\\"
						local modStr = gameStream.readBlock "{" "}"
						modStream = memStreamMgr.openString modStr
						while modStream.eos() != true do (
							local modline = modStream.readLine()
							modline = substituteString modline "\"" ""
							while matchPattern modline pattern:"*\t\t*" == true do (
								modline = substituteString modline "\t\t" "\t"
							)
							while matchPattern modline pattern:"*  *" == true do (
								modline = substituteString modline "  " " "
							)

							local vars = filterString modline "\t"

							if vars.count == 2 then (
								local val = wallworm_remove_last_slash (wallworm_FsToBs (vars[2])) char:"\\"
								--format "Prop: % : %\n" vars[1] val 

								case vars[1] of (
									"GameDir":preset.preset._wwmt_gameInfoDir = val
									"MapDir":(
										preset.preset._wwdt_mapsrc = val
										preset.preset._wwmt_exportMats = ((getFileNamePath val) + "materialsrc")
										preset.preset._wwmt_export = ((getFileNamePath val) + "modelsrc")
									)
									"GameData0": (preset.preset._wwmt_def_fgd = val
										--print "added fgd"
									)
								)

							)

							/*			 = ::wwmt_def_fgd

							*/

						)
						memStreamMgr.close modStream
						preset.preset.sanitize_vars()
						append games preset
					)
				)
				memStreamMgr.close gameStream
			)
		)
		memStreamMgr.close ms
		games
	)
)