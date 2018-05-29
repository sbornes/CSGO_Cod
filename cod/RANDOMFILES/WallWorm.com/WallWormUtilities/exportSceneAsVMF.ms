/*
Wall Worm VMF Exporter Window
Copyright (c) 2012-2014 by Shawn Olson

www.wallworm.com

*/
--(

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/vmf.ms")

try (destroyDialog WallWormVMFExport) catch ()

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/packing_funcs.ms")
scriptPath = symbolicPaths.getPathValue "$userScripts"
userIni = scriptPath + "/WallWorm.com/config/wwmt.ini"
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/anvil_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/parseFGD.mse")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/packing_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/wallwormVMF.mse")

wallworm_update_all_wwmt_cas()

vmfPresets = #()
wallworm_vmfPresets = #()
if wallworm_file_vmf_presets == undefined then (
	wallworm_file_vmf_presets = wallwormVMF()
)

if wallworm_file_vmf_presets.filename != undefined then (
	wallworm_file_vmf_presets.sanitize_filename()
)

function updateVMFPresetList = (
	local theLabels = #()
	global wallworm_vmfPresets
	for vmf in wallworm_vmfPresets do (
		append theLabels vmf.name
	)

	return theLabels
)

function wallworm_addVMFRootNode = (
	if NOT isProperty rootNode #Wallworm_VMF then (
		/*Legacy data not stored in CA.*/
		wallwormVMFSettingsIndex = fileProperties.findProperty #custom "wallwormVMFSettings"
		if wallwormVMFSettingsIndex != 0 then (
			wallwormVMFSettings1 = fileProperties.getPropertyValue #custom wallwormVMFSettingsIndex
			wallwormVMFSettings = "global wallworm_file_vmf_presets = (" + wallwormVMFSettings1 + ")"
			execute wallwormVMFSettings
			--print wallworm_file_vmf_presets

			wallworm_file_vmf_presets.wallworm_get_worldspawns()
			wallworm_file_vmf_presets.setFromWorldspawn()
			wallworm_file_vmf_presets.sanitize_filename()

			custAttributes.add rootNode wallworm_vmf_settings_CA
			rootNode.setVMFFromthis wallworm_file_vmf_presets
		) else (
			custAttributes.add rootNode wallworm_vmf_settings_CA
			rootNode.setVMFFromthis wallworm_file_vmf_presets
			wallworm_file_vmf_presets = wallwormVMF()
			rootNode.setVMFFromthis &wallworm_file_vmf_presets
		)

		true
	) else (
		if rootNode.Wallworm_VMF.version < 7 then (
			global wallworm_vmf_settings_CA
			local newDef = custAttributes.getDefSource wallworm_vmf_settings_CA

			--disableRefMsgs()
			with undo off
			with redraw off (
				local c = custAttributes.count rootNode -- [BaseObject:<bool>]
				local out = false

				if c > 0 then (
					for i = c to 1 by -1 do (
						local def = custAttributes.getDef rootNode i

						if def.name == "Wallworm_VMF" then (
							custAttributes.redefine def newDef

						)
					)
				)
			)
		)

		false
	)
)

wwvmfdummy = wallwormVMF()
global wallwormVMFExportVersion = wwvmfdummy.exporterVersion
rollout WallWormVMFExport "Wall Worm VMF Exporter | Version " width:402 height:805
(
	Bitmap anvillogo "anvil" pos:[179, 8] width:217 height:107 fileName:(::wallworm_installation_path + "/WallWorm.com/assets/anvil_logo.tif")
	CheckBox chk_displacements "Displacements" pos:[24, 148] width:81 height:15 checked:true toolTip:"Export displacements created with Anvil." 
	CheckBox chk_invertAlpha "Default Alpha"  pos:[112, 140] width:60 height:30 checked:true toolTip:"Invert the alphas on the displacements." 
	CheckBox chk_wwBrush "World Brushes" pos:[24, 167] width:100 height:15 checked:true toolTip:"Export geometry as world brushes that you've assigned as Brushes in Anvil. Also exports geometry in any layer called `Convexity Walls` and `Convexity Floors`."
	CheckBox chk_cvxWalls "Brush Entities" pos:[24, 188] width:140 height:15 checked:true toolTip:"Export Brush and Associated Entity information for any geometry that has been tied to a brush entity."
	CheckBox chk_cvxEntities "Point Entities" pos:[24, 230] width:140 height:15 checked:true toolTip:"Export all Point Entities."
	CheckBox chk_lights "Lights" pos:[24, 249] width:134 height:15 checked:true toolTip:"Export all scene lights as corresponding light entity."
	CheckBox chk_models "WWMT Models" pos:[24, 209] width:106 height:15 checked:true toolTip:"Export all WWMT helpers in the scene along with their associated Proxy models."
	GroupBox grp1 "Export" pos:[10, 128] width:164 height:162
	CheckBox chk_visFast "Fast" pos:[261, 222] width:49 height:15
	CheckBox chk_vradBoth "Both" pos:[273, 302] width:49 height:15 checked:true toolTip:"This option only adds -both flag. Calculates both HDR and LDR."
	CheckBox chk_vradFinal "Final" pos:[338, 302] width:46 height:15 toolTip:"Spend extra time firing light_environment rays. When on, equivalent to -extrasky 16. When not used, then equivalent to -extrasky 1."
	GroupBox grp2 "Vis Options" pos:[179, 204] width:217 height:69
	GroupBox grp3 "Rad Options" pos:[180, 278] width:216 height:104
	CheckBox chk_compile "Compile Map on Export" pos:[11, 641] width:145 height:19 checked:false
	CheckBox chk_launch "Launch Game after Compile" pos:[12, 661] width:150 height:17 checked:false
	EditText edt_visOpts "Options" pos:[190, 247] width:200 height:18
	EditText edt_radOpts "Options" pos:[190, 356] width:200 height:18
	EditText edt_bspOpts "Options" pos:[190, 173] width:200 height:18
	GroupBox grp10 "BSP Options" pos:[179, 121] width:217 height:79 enabled:true
	Spinner spn_lightMultiplier "light multiplier" pos:[93, 344] width:77 height:16 range:[1, 1000, 200] type:#float scale:1 toolTip:"Enter a multiplier converting Max light multipliers into Source light brightness. This value is multiplied against the lights' individual multipliers. This value is for the light and light_spot entities."
	Spinner spn_lightEnvMultiplier "env mult" pos:[341, 459] width:49 height:16 range:[1, 1000, 20] type:#integer scale:1 toolTip:"Enter a multiplier for the light_environment entities. This multiplier is multiplied against the light's multiplier for the final Source multiplier. So if the light has a multiplier of 1 and this numer is 20, the Source brightness will be 20."
	GroupBox grp17 "Lights" pos:[11, 292] width:164 height:152
	DropDownList ddlVisOpts "" pos:[313, 219] width:77 height:21 items:#("", " -radius_override # ", " -nosort ", " -tmpin ", " -tmpout ", " -low ", " -threads #", " -v ", " -verbose ", " -novconfig ", " -mpi ", " -mpi_pw <string> ", " -vproject <string> ", " -game <string> ")
	ComboBox cbxPresets "Presets" pos:[9, 7] width:125 height:7 selection:0
	Button btnSavePreset "Save" pos:[137, 49] width:37 height:21
	DropDownList ddlBSPOpts "" pos:[262, 140] width:130 height:21 items:#("", " -verbose ", " -onlyents ", " -onlyprops ", " -glview ", " -nodetail ", " -nowater ", " -low ", " -vproject <directory> ", " -game <directory> ", " -novconfig ", " -threads #", " -verboseentities ", " -noweld ", " -nocsg ", " -noshare ", " -notjunc ", " -noopt ", " -noprune ", " -nomerge ", " -nomergewater ", " -nosubdiv ", " -micro <#> ", " -fulldetail ", " -leaktest ", " -bumpall ", " -snapaxial ", " -block # # ", " -blocks # # # # ", " -blocksize 1024", " -dumpstaticprops ", " -dumpcollide ", " -luxelscale # ", " -lightifmissing ", " -localphysx ", " -keepstalezip ", " -replacematerials ", " -FullMinidumps ")
	DropDownList ddlRadOpts "" pos:[188, 324] width:203 height:21 items:#("", " -ldr ", " -hdr ", " -both ", " -fast ", " -final ", " -extrasky <int> ", " -lights <filename>.rad ", " -bounce <int> ", " -smooth <int> ", " -luxeldensity <normal> ", " -softsun <float> ", " -StaticPropLighting ", " -StaticPropPolys ", " -TextureShadows ", " -low ", " -threads <int> ", " -mpi ", " -mpi_pw <string> ", " -noextra ", " -chop <int> ", " -maxchop <int> ", " -LargeDispSampleRadius ", " -compressconstant <int> ", " -rederrors ", " -vproject <directory> ", " -game <directory> ", " -v ", " -verbose ", " -novconfig ", " -dump ", " -dumpnormals ", " -debugextra ", " -dlightmap ", " -stoponexit ", " -nodetaillight ", " -centersamples ", " -loghash ", " -onlydetail ", " -maxdispsamplesize # ", " -FullMinidump ", " -OnlyStaticProps ", " -StaticPropNormals ", " -noskyboxrecurse ", " -nossprops ")
	Button btnDeletePreset "Delete" pos:[137, 73] width:37 height:20 toolTip:"Click here to delete the selected preset."
	Button btn28 "New" pos:[137, 27] width:37 height:19
	CheckBox chkHidden "Hidden Objects" pos:[24, 269] width:143 height:16 checked:true toolTip:"Export objects that are hidden."
	Spinner spnLightmapScale "Default Lightmap Scale" pos:[106, 313] width:63 height:16 range:[1, 1024, 16] type:#integer scale:1 toolTip:"Set the default lightmap scale for all brush and displacement faces that have not been otherwise set individually."
	Button btn5 "Run Compile Batch" pos:[182, 732] width:214 height:19 toolTip:"Compile the map. This function only works if you have previously exported the map. Does not change existing VMF."
	Button btnOpenMaps "Open Maps" pos:[12, 726] width:62 height:26 toolTip:"Open the folder where your VMF exports to along with Wall Worm batch files."
	CheckBox chkEmbedWWMT "WWMT Models" pos:[20, 474] width:92 height:14 toolTip:"PAK the MDL files for WWMT models and proxies in this scene."
	CheckBox chkEmbeddWWMTTex "WWMT Textures" pos:[20, 493] width:103 height:14 toolTip:"Embed all VMT and VTF files associated with your WWMT models and proxies."
	CheckBox chkEmbedSky "Sky Textures" pos:[20, 530] width:88 height:15 toolTip:"Embed your Sky textures. Only works with Skywriter."
	CheckBox chkEmbedCVXProps "Entity Assets" pos:[20, 566] width:90 height:15 toolTip:"Collect MDL, VMT, WAV and MP3 from Entities."
	CheckBox chkEmbedWorldTex "World Textures" pos:[20, 512] width:100 height:16 toolTip:"Embed VMT and VTF files from the world geometry. The materials must be named properly for this function to work. This option not yet fully tested."
	CheckBox chkEmbedVBSP "Detail Texture" pos:[20, 584] width:88 height:15 toolTip:"Embed your detail texture. Note that this will read materials from Wall Worm Detail Props."
	GroupBox grp6 "PAK Assets Into BSP" pos:[12, 454] width:163 height:176
	ColorPicker cpAmbient "Ambient" pos:[191, 414] width:60 height:16 Color:(Color 255 255 255) title:"Choose Ambient color (controls the Global Tint in Max)." toolTip:"Choose the ambient color for your map. Only works if you have a light that exports as light_environment. Will change the Max global Tint inside the Max Environment settings."
	ColorPicker cpHDRBrightness "HDR Color" pos:[24, 392] width:145 height:19 enabled:false Color:(Color 255 255 255) title:"Choose Brightness (HDR Color)" toolTip:"Set the default global HDR color for lights. Only works if Use LDR Color is unchecked."
	ColorPicker cpAmbientHDR "Ambient HDR" pos:[194, 437] width:86 height:16 enabled:false Color:(Color 255 255 255) title:"Choose Ambient color" toolTip:"Choose the HDR Ambient color. Only works if there is a light_environment light in the scene and Use LDR Ambient is unchecked."
	CheckBox chkUseBrightness "Use LDR Color" pos:[26, 419] width:121 height:16 checked:true toolTip:"Set the global option for lights to use their LDR color as the HDR color if the light hasn't had a value set specifically."
	CheckBox chkUseLDRAmbient "Use LDR Ambient" pos:[288, 437] width:105 height:16 checked:true toolTip:"Reuse the global Ambient color for the light_environment HDR ambient color."
	Spinner spnHDRScale "HDR Scale" pos:[85, 369] width:85 height:16 range:[1, 100, 1] type:#float scale:0.01 toolTip:"Set the default HDR scale for all lights that do not have this value set individually."
	Spinner spnSunSpreadAngle "Sun Spread" pos:[348, 413] width:40 height:16 range:[0, 180, 0] type:#integer scale:1 toolTip:"Set the Sun Spread angle. Only works if there is a light that exports as light_environment in the scene."

	GroupBox grpLightEnv "Environment" pos:[181, 394] width:215 height:164
	Button btn19 "Update Pak List" pos:[21, 602] width:139 height:18 toolTip:"Recreate the pak list for zipping assets into the scene. May be necessary if you have added new models/materials, etc since the last time the scene was exported."
	Spinner spnAmbientScale "Amb HDRScale" pos:[244, 459] width:56 height:16 range:[0, 1000, 1] toolTip:"Set the Ambient HDR Scale."
	Spinner spnAmbientScaleLDR "" pos:[257, 413] width:36 height:16 range:[0, 1000, 2] toolTip:"Set the Ambient Scale Multiplier for the light_environment. This value will be multiplied by the light's multiplier to create the value for the ambient light level (brightness of indirect environment lighting)."
	ComboBox cbxSkyName "Sky Name" pos:[191, 478] width:198 height:3 toolTip:"Enter the name of the sky for this map. The list will automatically include any sky writer files in the map."
	Spinner spnMaxPropScreenWidth "Start" pos:[241, 609] width:67 height:16 range:[-1, 32000, -1] type:#integer scale:1 toolTip:"Number of pixels wide at which all props in the level start to fade (<0 = use fademaxdist). This number is ignored if the prop has a specific fade distance specified."
	Spinner spnMinPropScreenWidth "End" pos:[328, 608] width:66 height:16 range:[-1, 32000, 0] type:#integer scale:1 toolTip:"Minimum number of pixels wide at which the prop is visible (0 = don't fade out). This number is ignored if the prop has a specific fade distance specified."

	Button btnLeak "Leak" pos:[78, 726] width:44 height:26 toolTip:"Load the Leak File to help find leaks. This file only exists if you have tried to compile and the compiler created a LIN file."
	CheckBox chkEmbedWAVs "Soundscape Contents" pos:[20, 548] width:145 height:15 toolTip:"Collect sounds listed in soundscapes."
	EditText edtDetailSprites "detail/detailsprites" pos:[184, 562] width:210 height:19
	EditText edtDetailVBSP "detail.vbsp" pos:[184, 585] width:210 height:20
	Label lbl1 "Fade" pos:[185, 609] width:31 height:13
	CheckBox chkBreakNonPlanarFaces "Break Non Planar Polygons" pos:[185, 632] width:210 height:16 toolTip:"Tell the exporter to break non-planar polygons into pieces. Useful for solving problems where convex geometry in Max sometimes misses geometry... but might take longer to export."
	CheckBox chkPrecise "Precise Coords" pos:[185, 650] width:96 height:16 checked:true toolTip:"When on, uses long digits for brush vertex coordinates. For Hammer-like truncated values, turn off (but may lead to non-convex geometry and/or changes in exported geometry)."
	CheckBox chkWeld "Weld Verts" pos:[286, 652] width:79 height:13 enabled:true checked:false toolTip:"Check to Weld the vertices of world geometry."
	Spinner spbrushSideMax "Brush Max Sides" pos:[226, 667] width:140 height:16 range:[128, 2048, 128] type:#integer tooltip:"Skip brushes with more sides than this value."
	Button btn_export "Export Scene as Game Level" pos:[182, 686] width:213 height:44 toolTip:"Run the export. You'll be prompted to name and save the file. This may take several minutes (or longer depending on scene complexity and computer speed) and may appear to have frozen Max."

	CheckBox chkCompileLogWindow "Output Compile Window" pos:[12, 683] width:150 height:17 toolTip:"When on, the compile log is displayed in console. When off, the compiler will not display a lot of info. At the end of compile, the compile log will open in your text editor."
	CheckBox chkrunVBSP "Run VBSP" pos:[192, 142] width:69 height:20 checked:true
	CheckBox chkrunVVIS "Run VVIS" pos:[190, 222] width:65 height:18 checked:true
	CheckBox chkrunVRAD "Run VRAD" pos:[192, 302] width:71 height:16 checked:true
	Button btnlog "LOG" pos:[128, 726] width:47 height:26 toolTip:"Open the last compile log."

	Hyperlink linkWW "WallWorm.com" pos:[17, 764] width:96 height:17 address:"http://www.wallworm.com" Color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
	Hyperlink donate "Donate & Support Wall Worm" pos:[127, 764] width:143 height:20 Color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/42/donate.html"
	Hyperlink help "Help" pos:[327, 764] width:43 height:20 Color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) address:"http://dev.wallworm.com/topic/47/vmf_exporter.html"

	function useHDRBrightness state = (
		global wallworm_file_vmf_presets
		if state == true then (
			cpHDRBrightness.enabled = true
			chkUseBrightness.checked = false
		) else (
			cpHDRBrightness.enabled = false
			chkUseBrightness.checked = true

		)
		wallworm_file_vmf_presets.UseBrightness = NOT state
		if isProperty rootNode #UseBrightness then (
			rootNode.UseBrightness = NOT state
		)
	)

	function useHDRAmbient state = (
		global wallworm_file_vmf_presets
		if state == true then (
			cpAmbientHDR.enabled = true
			chkUseLDRAmbient.checked = false
		) else (
			cpAmbientHDR.enabled = false
			chkUseLDRAmbient.checked = true
		)

		wallworm_file_vmf_presets.UseLDRAmbient = NOT state
		if isProperty rootNode #UseLDRAmbient then (
			rootNode.UseLDRAmbient = NOT state
		)
	)

	function writePreferences = (
		for vmf in wallworm_vmfPresets do (
			vmf.vmf.pv = undefined
			vmf.vmf.gv = undefined
			vmf.vmf.pgetFaceNormal = undefined
			vmf.vmf.polyopgetFaceMatId = undefined
			vmf.vmf.polyopgetFaceVerts = undefined
			vmf.vmf.polyopgetFaceSmoothGroup = undefined
			vmf.vmf.getMapVert = undefined
			vmf.vmf.getMapSupport = undefined
			vmf.vmf.getMapFace = undefined
			vmf.vmf.polyopgetFaceArea = undefined
			vmf.vmf.wallworm_vmfExport_invalidValues = undefined
			vmf.vmf.skyTransform = undefined
			vmf.vmf.vmfHelper = undefined
			if isProperty vmf.vmf #meshopgetPolysUsingFace then (
				vmf.vmf.meshopgetPolysUsingFace = undefined
			)
			if isProperty vmf.vmf #validTextureFilenames then (
				vmf.vmf.validTextureFilenames = undefined
				vmf.vmf.invalidTextureFilenames = undefined
				vmf.vmf.checkValidFile = undefined
			)
		)

		with printAllElements on (
			local str = "global wallworm_vmfPresets = " + (wallworm_vmfPresets as String)
		)
		local prefFile
		if doesFileExist "$userScripts\\WallWorm.com\\config\\vmfPresets.ms" == false then (
			prefFile = createFile "$userScripts\\WallWorm.com\\config\\vmfPresets.ms"
			close prefFile
		)

		try (
			prefFile = openFile "$userScripts\\WallWorm.com\\config\\vmfPresets.ms" mode:"w+"
			format str to:prefFile
			close prefFile
		) catch (
			print (getCurrentException())
		)
	)

	function getVMFFromUI = (
		/*This function fills a VMF struct from the UI's current settings*/
		global wallworm_file_vmf_presets
		if wallworm_file_vmf_presets == undefined then (
			wallworm_file_vmf_presets = wallwormVMF()
		)
		wallworm_file_vmf_presets.outputModels = chk_models.state
		wallworm_file_vmf_presets.outputDisplacements = chk_displacements.state
		wallworm_file_vmf_presets.outputBrushes = chk_wwBrush.state
		wallworm_file_vmf_presets.outputPointEntities = chk_cvxEntities.state
		wallworm_file_vmf_presets.outputBrushEntities = chk_cvxWalls.state
		wallworm_file_vmf_presets.outputLights = chk_lights.state
		wallworm_file_vmf_presets.vradBoth = chk_vradBoth.state
		wallworm_file_vmf_presets.vradFinal = chk_vradFinal.state
		wallworm_file_vmf_presets.includeHidden = chkHidden.state
		wallworm_file_vmf_presets.vvisFast = chk_visFast.state
		wallworm_file_vmf_presets.launchGame = chk_launch.state
		wallworm_file_vmf_presets.visOpts = edt_visOpts.text
		wallworm_file_vmf_presets.radOpts = edt_radOpts.text
		wallworm_file_vmf_presets.bspOpts = edt_bspOpts.text
		wallworm_file_vmf_presets.lightMultiplier = spn_lightMultiplier.value
		wallworm_file_vmf_presets.lightEnvMultiplier = spn_lightEnvMultiplier.value
		wallworm_file_vmf_presets.lightmapScale = spnLightmapScale.value

		wallworm_file_vmf_presets.launchGame = chk_launch.state
		wallworm_file_vmf_presets.compileMap = chk_compile.state

		wallworm_file_vmf_presets.MaxPropScreenWidth = spnMaxPropScreenWidth.value
		wallworm_file_vmf_presets.MinPropScreenWidth = spnMinPropScreenWidth.value

		wallworm_file_vmf_presets.EmbedWWMT = chkEmbedWWMT.state
		wallworm_file_vmf_presets.EmbeddWWMTTex = chkEmbeddWWMTTex.state
		wallworm_file_vmf_presets.EmbedSky = chkEmbedSky.state
		wallworm_file_vmf_presets.EmbedCVXProps = chkEmbedCVXProps.state
		wallworm_file_vmf_presets.EmbedWorldTex = chkEmbedWorldTex.state

		if wallworm_file_vmf_presets.EmbedVBSP != undefined then (
			wallworm_file_vmf_presets.EmbedVBSP = chkEmbedVBSP.state
		)

		if wallworm_file_vmf_presets.weldWorldGeometry != undefined then (
			wallworm_file_vmf_presets.weldWorldGeometry = chkWeld.state
		)

		if wallworm_file_vmf_presets.brushSideMax != undefined then (
			wallworm_file_vmf_presets.brushSideMax = spbrushSideMax.value
		)
		if wallworm_file_vmf_presets.invertAlpha != undefined then (
			wallworm_file_vmf_presets.invertAlpha = chk_invertAlpha.state
		)

		wallworm_file_vmf_presets.compileLogWindow = chkCompileLogWindow.state

		wallworm_file_vmf_presets.EmbedWAVs = chkEmbedWAVs.state

		wallworm_file_vmf_presets.HDRBrightness = cpHDRBrightness.Color
		wallworm_file_vmf_presets.AmbientHDR = cpAmbientHDR.Color
		wallworm_file_vmf_presets.UseBrightness = chkUseBrightness.state
		wallworm_file_vmf_presets.UseLDRAmbient = chkUseLDRAmbient.state
		wallworm_file_vmf_presets.HDRScale = spnHDRScale.value
		wallworm_file_vmf_presets.SunSpreadAngle = spnSunSpreadAngle.value
		wallworm_file_vmf_presets.BreakNonPlanarFaces = chkBreakNonPlanarFaces.state

		wallworm_file_vmf_presets.precise = chkPrecise.state

		wallworm_file_vmf_presets.AmbientHDRScale = spnAmbientScale.value

		wallworm_file_vmf_presets.AmbientScale = spnAmbientScaleLDR.value

		wallworm_file_vmf_presets.AmbientLDR = cpAmbient.Color

		wallworm_file_vmf_presets.skyName = cbxSkyName.text

		wallworm_file_vmf_presets.DetailSprites = edtDetailSprites.text
		wallworm_file_vmf_presets.DetailVBSP = edtDetailVBSP.text

		wallworm_file_vmf_presets.runVBSP = chkrunVBSP.state
		wallworm_file_vmf_presets.runVVIS = chkrunVVIS.state
		wallworm_file_vmf_presets.runVRAD = chkrunVRAD.state

		global wallwormVMFExportVersion
		wallworm_file_vmf_presets.exporterVersion = wallwormVMFExportVersion

		return wallworm_file_vmf_presets
	)

	function setFromPreset vmf = (
		/*This function fills the UI with properties saved in a preset (or in the file settings)*/
		vmf.sanitize_filename()
		try (
			chk_models.state = vmf.outputModels
			chk_displacements.state = vmf.outputDisplacements
			chk_wwBrush.state = vmf.outputBrushes
			chk_cvxEntities.state = vmf.outputPointEntities
			chk_cvxWalls.state = vmf.outputBrushEntities
			chk_lights.state = vmf.outputLights
			chk_vradBoth.state = vmf.vradBoth
			chk_vradFinal.state = vmf.vradFinal
			chk_visFast.state = vmf.vvisFast
			chk_launch.state = vmf.launchGame
			edt_visOpts.text = vmf.visOpts
			edt_radOpts.text = vmf.radOpts
			edt_bspOpts.text = vmf.bspOpts
			spn_lightMultiplier.value = vmf.lightMultiplier
			spn_lightEnvMultiplier.value = vmf.lightEnvMultiplier
			spnLightmapScale.value = vmf.lightmapScale

			chk_launch.state = vmf.launchGame
			chk_compile.state = vmf.compileMap

			if vmf.precise != undefined then (
				chkPrecise.state = vmf.precise
			)

			if vmf.compileLogWindow != undefined then (
				chkCompileLogWindow.state = vmf.compileLogWindow
			)

			if vmf.weldWorldGeometry != undefined then (
				chkWeld.state = vmf.weldWorldGeometry
			)

			if vmf.brushSideMax != undefined then (
				spbrushSideMax.value = vmf.brushSideMax
			)
			if vmf.invertAlpha != undefined then (
				chk_invertAlpha.state = vmf.invertAlpha
			)

			chkEmbedWWMT.state = vmf.EmbedWWMT
			chkEmbeddWWMTTex.state = vmf.EmbeddWWMTTex
			chkEmbedSky.state = vmf.EmbedSky
			chkEmbedCVXProps.state = vmf.EmbedCVXProps
			chkEmbedWorldTex.state = vmf.EmbedWorldTex

			if vmf.EmbedVBSP != undefined then (
				chkEmbedVBSP.state = vmf.EmbedVBSP
			)

			if vmf.EmbedWAVs != undefined then (
				chkEmbedWAVs.state = vmf.EmbedWAVs
			)

			if vmf.BreakNonPlanarFaces != undefined then (
				chkBreakNonPlanarFaces.state = vmf.BreakNonPlanarFaces
			)
			if wallworm_file_vmf_presets.AmbientLDR != undefined then (
				cpAmbient.Color = vmf.AmbientLDR
			)
			if wallworm_file_vmf_presets.AmbientScale != undefined then (
				spnAmbientScaleLDR.value = vmf.AmbientScale
			)
			if wallworm_file_vmf_presets.HDRBrightness != undefined then (
				cpHDRBrightness.Color = vmf.HDRBrightness
			)
			if wallworm_file_vmf_presets.AmbientHDR != undefined then (
				cpAmbientHDR.Color = vmf.AmbientHDR
			)
			if wallworm_file_vmf_presets.UseBrightness != undefined then (
				chkUseBrightness.state = vmf.UseBrightness
			)
			if wallworm_file_vmf_presets.UseLDRAmbient != undefined then (
				chkUseLDRAmbient.state = vmf.UseLDRAmbient
			)
			if wallworm_file_vmf_presets.HDRScale != undefined then (
				spnHDRScale.value = vmf.HDRScale
			)
			if wallworm_file_vmf_presets.SunSpreadAngle != undefined then (
				spnSunSpreadAngle.value = vmf.SunSpreadAngle
			)
			if wallworm_file_vmf_presets.AmbientHDRScale != undefined then (
				spnAmbientScale.value = vmf.AmbientHDRScale
			)
			if vmf.includeHidden != undefined then (
				chkHidden.state = vmf.includeHidden
			)

			if (wallworm_file_vmf_presets.MaxPropScreenWidth != undefined) then (
				spnMaxPropScreenWidth.value = wallworm_file_vmf_presets.MaxPropScreenWidth
			)

			if wallworm_file_vmf_presets.DetailSprites != undefined AND wallworm_file_vmf_presets.DetailSprites != "" then (
				edtDetailSprites.text = vmf.DetailSprites
			)

			if wallworm_file_vmf_presets.DetailVBSP != undefined AND wallworm_file_vmf_presets.DetailVBSP != "" then (
				edtDetailVBSP.text = vmf.DetailVBSP
			)

			if (wallworm_file_vmf_presets.MinPropScreenWidth != undefined) then (
				spnMinPropScreenWidth.value = wallworm_file_vmf_presets.MinPropScreenWidth
			)

			if wallworm_file_vmf_presets.skyName != undefined then (
				if findItem cbxSkyName.items wallworm_file_vmf_presets.skyName == 0 then (
					tempItems = cbxSkyName.items
					append tempItems wallworm_file_vmf_presets.skyName

					cbxSkyName.items = tempItems
				)

				cbxSkyName.selection = findItem cbxSkyName.items wallworm_file_vmf_presets.skyName
			)

		) catch (
			print (getCurrentException())
		)

		if vmf.UseBrightness == undefined OR vmf.UseBrightness == true then (
			useHDRBrightness false
		) else (
			useHDRBrightness true
		)

		if vmf.UseLDRAmbient == undefined OR vmf.UseLDRAmbient == true then (
			useHDRAmbient false
		) else (
			useHDRAmbient true
		)

		if isProperty vmf #runVBSP AND vmf.runVBSP != undefined then (
			chkrunVBSP.state = vmf.runVBSP

			chkrunVVIS.state = vmf.runVVIS
			chkrunVRAD.state = vmf.runVRAD
		)
	)

	function setFileVMFProperties filename:undefined = (
		/*This function saves the properties of the UI into the file's properties.*/
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets = getVMFFromUI()

		wallworm_file_vmf_presets.wallworm_get_worldspawns()
		wallworm_file_vmf_presets.setWorldspawn()

		/*		

		wallwormVMFSettingsIndex = fileProperties.findProperty #custom "wallwormVMFSettings"

		if wallwormVMFSettingsIndex != 0 then (
			fileProperties.deleteProperty #custom "wallwormVMFSettings"
		)

		if filename != undefined then (
			wallworm_file_vmf_presets.filename = filename
		)

		wallworm_file_vmf_presets.sv = undefined
		wallworm_file_vmf_presets.devmap = undefined
		wallworm_file_vmf_presets.worldspawn = undefined*/

		global wallwormVMFExportVersion
		wallworm_file_vmf_presets.exporterVersion = wallwormVMFExportVersion
		/*VERY IMPORTANT!! Unset the _this property or the object will be saved with a recursion that breaks the object when saved into the file!*/
		--wallworm_file_vmf_presets._this = undefined
		--fileProperties.addProperty #custom "wallwormVMFSettings" (wallworm_file_vmf_presets as string)

		if NOT isProperty rootNode #Wallworm_VMF then (
			custAttributes.add rootNode wallworm_vmf_settings_CA
		)

		rootNode.getSettingsFromVMFStruct wallworm_file_vmf_presets

		if wallworm_file_vmf_presets.filename != undefined then (
			--wallworm_file_vmf_presets._this = wallworm_file_vmf_presets
			wallworm_file_vmf_presets.writeBatchFile()
		)
	)

	function getSkyNames = (
		global wallworm_file_vmf_presets

		local skyList = #()

		if wallworm_file_vmf_presets.skyName != undefined AND wallworm_file_vmf_presets.skyName != "" then (
			append skyList wallworm_file_vmf_presets.skyName
		)
/*
		for s in objects WHERE (isDeleted s == false) AND getUserProp s #wwsw_skyname != undefined do (
			append skyList (getUserProp s #wwsw_skyname)
		)

		refCollection = #()
		wallworm_file_vmf_presets.getXrefs refCollection undefined
		if refCollection.count > 0 then (
			for ref in refCollection do (
				for s in ref.tree.children WHERE (ww_getUserProp s #wwsw_skyname xref:ref.tree.children) != undefined do (
					append skyList (ww_getUserProp s #wwsw_skyname xref:ref.tree.children)
				)
			)
		)
*/
		/*
		if skyList.count == 0 then (
			append skyList "sky_day01_01"

		)

		*/

		--print skyList
		
		skyList = makeUniqueArray skyList
		return skyList
	)

	on WallWormVMFExport open do
	(
		WallWormVMFExport.title = WallWormVMFExport.title + (wwvmfdummy.exporterVersion as String)

		/*
		global	wallworm_vmfPresets

		if (doesFileExist "$userScripts\\WallWorm.com\\config\\vmfPresets.ms") == true then (
			--readValue "$userScripts\\WallWorm.com\\config\\sourcePresets.ms" ignoreStringEscapes:true
			local temp = openFile "$userScripts\\WallWorm.com\\config\\vmfPresets.ms" mode:"r"
			execute temp
			close temp
			fillPresets()
		) else (
			wallwormSettingPresetsStr  = GetINISetting ::wallworm_userIni "Presets" "wallwormSettingPresets"
			if wallwormSettingPresetsStr != undefined AND wallwormSettingPresetsStr != "" then (
				local theStr = "global wallworm_setting_presets = " +  wallwormSettingPresetsStr
				execute theStr
				fillPresets()

			)

		)	
		*/

		if (doesFileExist "$userScripts\\WallWorm.com\\config\\vmfPresets.ms") == true then (
			--readValue "$userScripts\\WallWorm.com\\config\\sourcePresets.ms" ignoreStringEscapes:true

			try (
				local temp = openFile "$userScripts\\WallWorm.com\\config\\vmfPresets.ms" mode:"r"
				execute temp
				close temp
			) catch()
			--fillPresets()
		) else (
			if (::wallworm_installation_path == undefined) then (
				::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
			)

			try (
				local temp = openFile (::wallworm_installation_path + "/WallWorm.com/config/vmfPresets-defaults.ms") mode:"r"
				execute temp
				close temp
			) catch(
				local temp = openFile (::wallworm_installation_path + "/WallWorm.com/config/vmfPresets-defaults.ms") mode:"r"
				execute temp
				close temp
			)
		)

		cbxSkyName.items = getSkyNames()

		global wallworm_file_vmf_presets
		if wallworm_file_vmf_presets.skyName != undefined AND wallworm_file_vmf_presets.skyName != "" then (
			cbxSkyName.selection = findItem cbxSkyName.items wallworm_file_vmf_presets.skyName

		)

		--cpAmbient.color=lightTintColor
	)

	on chk_displacements changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputDisplacements = state
		wallworm_addVMFRootNode()
		rootNode.outputDisplacements = state
	)
	on chk_invertAlpha changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.invertAlpha = state
		wallworm_addVMFRootNode()
		rootNode.invertAlpha = state
	)

	on spbrushSideMax changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.brushSideMax = val
		wallworm_addVMFRootNode()
		rootNode.brushSideMax = val
	)

	on chk_wwBrush changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputBrushes = state
		wallworm_addVMFRootNode()
		rootNode.outputBrushes = state
	)

	on chk_cvxWalls changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputBrushEntities = state
		wallworm_addVMFRootNode()
		rootNode.outputBrushEntities = state
	)

	on chk_cvxEntities changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputPointEntities = state
		wallworm_addVMFRootNode()
		rootNode.outputPointEntities = state
	)

	on chk_lights changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputLights = state
		wallworm_addVMFRootNode()
		rootNode.outputLights = state
	)

	on btn_export pressed do
	with undo off
	(
		--forcecompleteredraw()
		--vmf = getVMFFromUI()
		max create mode
		global wallworm_file_vmf_presets
		--print vmf
		macros.run "wallworm.com" "WallWormRepairDXRenderMatNamesMCR"
		suspendEditing()

		--  (
		--try with redraw off (
		local started = timestamp()
		if wallworm_file_vmf_presets.setFileName() == true then (
			wallworm_addVMFRootNode()

			if wallworm_file_vmf_presets.filename != undefined then (
				rootNode.Wallworm_VMF.filename = wallworm_file_vmf_presets.filename

				if wallworm_file_vmf_presets.outputVMF() == true then (
					local ended = timestamp()
					seconds = ((ended - started) / 1000.0)
					minutes = seconds / 60
					--leftover = mod seconds 60 

					format "% Exported in % seconds (% minutes)\n" (getFileNameFile (wallworm_file_vmf_presets.filename)) seconds minutes

					--setFileVMFProperties filename:wallworm_file_vmf_presets.filename
					local addednoticice = ""
					--addednoticice = "\n\nCurrently, brush geometry UVW is not properly exported."	
					if (maxVersion())[1] < 12000 then (
						addednoticice += "\n\nUnfortunately, at the moment, the vertex painting (material blending) only exports from Max 2010+."

					)

					if wallworm_file_vmf_presets.actualBrushes > 8192 then (
						addednoticice += ("\n\nThis level has too many brushes. It may not compile correctly. The limit is 8192 in Source, and the level exported with " + (wallworm_file_vmf_presets.actualBrushes as String) + " .")
					)

					if wallworm_file_vmf_presets.sideNUm > 65536 then (
						addednoticice += "\n\nThere are too many brush sides. The Source limit for brush sides is 65,536. There are " + wallworm_file_vmf_presets.sideNUm as String + " sides. The level may not compile correctly"
					)

					/*
					if wallworm_file_vmf_presets.actualEntities > 	8192 then (
						addednoticice += ("\n\nThis level has too many brushes. It may not compile correctly. The limit is 8192 in Source, and the level exported with "+(wallworm_file_vmf_presets.actualBrushes as string)+" .")
					)
					*/

					if chk_compile.state == true then (
						wallworm_file_vmf_presets.writeBatchFile()
						wallworm_file_vmf_presets._this = wallworm_file_vmf_presets
						wallworm_file_vmf_presets.writeBSPZIPBatchFile()

						wallworm_file_vmf_presets.runCompile()

						if addednoticice != "" then (
							messageBox ("There may be problems." + addednoticice)
						)

					) else (
						messageBox ("The VMF File was successfully saved." + addednoticice)
					)

				) else (
					messageBox "VMF Not Saved."
				)
			) else (
				messageBox "There was an error with the filename--it was returned as undefined. Please try re-loading the exporter window."
			)

		) else (
			print "VMF Name not set... not exporting."
		)

		resumeEditing()

		--) catch (

		--resumeEditing()

		--messagebox "Oops... there was a problem with the export. Press F11 for more details."

		--print (getCurrentException())
		--message
		--)
		vmf = undefined
	)

	on chk_models changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.outputModels = state
		wallworm_addVMFRootNode()
		rootNode.outputModels = state
	)

	on chk_visFast changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.vvisFast = state
		wallworm_addVMFRootNode()
		rootNode.vvisFast = state
	)

	on chk_vradBoth changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.vradBoth = state
		wallworm_addVMFRootNode()
		rootNode.vradBoth = state
	)

	on chk_vradFinal changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.vradFinal = state
		wallworm_addVMFRootNode()
		rootNode.vradFinal = state
	)

	on chk_compile changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.compileMap = state
		wallworm_addVMFRootNode()
		rootNode.compileMap = state
	)

	on chk_launch changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.launchGame = state
		wallworm_addVMFRootNode()
		rootNode.launchGame = state
	)

	on edt_visOpts entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.visOpts = text
		wallworm_addVMFRootNode()
		rootNode.visOpts = text
	)

	on edt_radOpts entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.radOpts = text
		wallworm_addVMFRootNode()
		rootNode.radOpts = text
	)

	on edt_bspOpts entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.bspOpts = text
		wallworm_addVMFRootNode()
		rootNode.bspOpts = text
	)

	on spn_lightMultiplier changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.lightMultiplier = val
		wallworm_addVMFRootNode()
		rootNode.lightMultiplier = val
	)

	on spn_lightEnvMultiplier changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.lightEnvMultiplier = val
		wallworm_addVMFRootNode()
		rootNode.lightEnvMultiplier = val
	)

	on ddlVisOpts selected sel do
	(
		edt_visOpts.text += ddlVisOpts.selected
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.visOpts = edt_visOpts.text
		wallworm_addVMFRootNode()
		rootNode.visOpts = edt_visOpts.text
	)

	on cbxPresets selected sel do
	(
		if cbxPresets.selection > 0 then (
			global wallworm_vmfPresets
			setFromPreset (wallworm_vmfPresets[cbxPresets.selection].vmf)
		)
		setFileVMFProperties()
	)

	on btnSavePreset pressed do
	(
		global wallworm_vmfPresets
		local preset = wallwormVMFPreset()
		preset.vmf = copy (getVMFFromUI())
		preset.name = cbxPresets.text
		preset.vmf._this = undefined
		preset.vmf.devmap = undefined
		preset.vmf.worldspawn = undefined
		preset.vmf.filename = undefined
		preset.vmf.allObject = #()
		preset.vmf.objectCollection = #()
		preset.vmf.shapeCollection = #()
		preset.vmf.lightCollection = #()
		preset.vmf.cameraCollection = #()
		preset.vmf.helperCollection = #()

		preset.vmf.pv = undefined
		preset.vmf.gv = undefined
		preset.vmf.pgetFaceNormal = undefined
		preset.vmf.polyopgetFaceMatId = undefined
		preset.vmf.polyopgetFaceVerts = undefined
		polyopgetFaceSmoothGroup = undefined
		preset.vmf.getMapVert = undefined
		preset.vmf.getMapSupport = undefined
		preset.vmf.getMapFace = undefined
		preset.vmf.polyopgetFaceArea = undefined
		preset.vmf.vmfHelper = undefined
		preset.vmf.wallworm_vmfExport_invalidValues = undefined
		preset.vmf.layerID_Cache = undefined
		preset.vmf.layerID_Cache_Get = undefined
		preset.vmf.skyTransform = undefined
		preset.vmf.vmfHelper = undefined
		if isProperty preset.vmf #meshopgetPolysUsingFace then (
			preset.vmf.meshopgetPolysUsingFace = undefined
		)
		if isProperty preset.vmf #validTextureFilenames then (
			preset.vmf.validTextureFilenames = undefined
			preset.vmf.invalidTextureFilenames = undefined
			preset.vmf.checkValidFile = undefined
		)
		preset.vmf.actualBrushes = 0
		preset.vmf.actualEntities = 0
		preset.vmf.brushNum = 1
		preset.vmf.sideNum = 0

		if preset.name == undefined OR preset.name == "" then (
			local sfn = maxFileName

			if sfn != undefined AND sfn != "" then (
				preset.name = substring sfn 1 (sfn.count - 4)
			) else (
				preset.name = "New Preset"
			)
		)

		if wallworm_vmfPresets.count == 0 OR cbxPresets.selection == 0 then (
			append wallworm_vmfPresets preset
		) else (
			wallworm_vmfPresets[cbxPresets.selection] = preset
		)

		writePreferences()

		--setINISetting ::wallworm_userIni "Presets" "vmf" (wallworm_vmfPresets as string)
		cbxPresets.items = (updateVMFPresetList() as Array)
	)

	on ddlBSPOpts selected sel do
	(
		edt_bspOpts.text += ddlBSPOpts.selected

		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.bspOpts = edt_bspOpts.text
		wallworm_addVMFRootNode()
		rootNode.bspOpts = edt_bspOpts.text
	)

	on ddlRadOpts selected sel do
	(
		edt_radOpts.text += ddlRadOpts.selected
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.radOpts = edt_radOpts.text
		wallworm_addVMFRootNode()
		rootNode.radOpts = edt_radOpts.text
	)

	on btnDeletePreset pressed do
	(
		if cbxPresets.selection > 0 then (
			global wallworm_vmfPresets
			deleteItem wallworm_vmfPresets cbxPresets.selection
			writePreferences()
			cbxPresets.items = (updateVMFPresetList() as Array)
		)
	)

	on btn28 pressed do
	(
		cbxPresets.selection = 0
	)

	on chkHidden changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.includeHidden = state
		wallworm_addVMFRootNode()
		rootNode.includeHidden = state
	)

	on spnLightmapScale changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.lightmapScale = val
		wallworm_addVMFRootNode()
		rootNode.lightmapScale = val
	)

	on btn5 pressed do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.writeBatchFile()
		wallworm_file_vmf_presets._this = wallworm_file_vmf_presets
		if wallworm_file_vmf_presets.addPackBat() == true then (
			wallworm_file_vmf_presets.writeBSPZIPBatchFile()
		)

		wallworm_file_vmf_presets.runCompile()
	)

	on btnOpenMaps pressed do
	(
		global wallworm_file_vmf_presets
		if wallworm_file_vmf_presets.filename != undefined then (
			folderOpen =
			execute ("ShellLaunch \"explorer.exe\" @\"" + (getFilenamePath wallworm_file_vmf_presets.filename) + "\"")
		) else (
			execute ("ShellLaunch \"explorer.exe\" @\"" + (::wwdt_mapsrc) + "\"")
		)
	)

	on chkEmbedWWMT changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedWWMT = state
		wallworm_addVMFRootNode()
		rootNode.EmbedWWMT = state
	)

	on chkEmbeddWWMTTex changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbeddWWMTTex = state
		wallworm_addVMFRootNode()
		rootNode.EmbeddWWMTTex = state
	)

	on chkEmbedSky changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedSky = state
		wallworm_addVMFRootNode()
		rootNode.EmbedSky = state
	)

	on chkEmbedCVXProps changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedCVXProps = state
		wallworm_addVMFRootNode()
		rootNode.EmbedCVXProps = state
	)

	on chkEmbedWorldTex changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedWorldTex = state
		wallworm_addVMFRootNode()
		rootNode.EmbedWorldTex = state
	)

	on chkEmbedVBSP changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedVBSP = state
		wallworm_addVMFRootNode()
		rootNode.EmbedVBSP = state
	)

	on cpAmbient changed col do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.AmbientLDR = col
		wallworm_addVMFRootNode()
		rootNode.AmbientLDR = col
	)

	on cpHDRBrightness changed col do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.HDRBrightness = col
		wallworm_addVMFRootNode()
		rootNode.HDRBrightness = col
	)

	on cpAmbientHDR changed col do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.AmbientHDR = col
		wallworm_addVMFRootNode()
		rootNode.AmbientHDR = col
	)

	on chkUseBrightness changed state do
	(
		if state == true then (
			useHDRBrightness false
		) else (
			useHDRBrightness true
		)
	)

	on chkUseLDRAmbient changed state do
	(
		if state == true then (
			useHDRAmbient false
		) else (
			useHDRAmbient true
		)
	)

	on spnHDRScale changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.HDRScale = val
		wallworm_addVMFRootNode()
		rootNode.HDRScale = val
	)

	on spnSunSpreadAngle changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.SunSpreadAngle = val
		wallworm_addVMFRootNode()
		rootNode.SunSpreadAngle = val
	)

	on btn19 pressed do
	(
		macros.run "wallworm.com" "WallWormRepairDXRenderMatNamesMCR"
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.writeBatchFile()
		wallworm_file_vmf_presets._this = wallworm_file_vmf_presets
		wallworm_file_vmf_presets.writeBSPZIPBatchFile()
	)

	on spnAmbientScale changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.AmbientHDRScale = val
		wallworm_addVMFRootNode()
		rootNode.AmbientHDRScale = val
	)

	on spnAmbientScaleLDR changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.AmbientScale = val
		wallworm_addVMFRootNode()
		rootNode.AmbientScale = val
	)

	on cbxSkyName selected sel do
	(
		if sel > 0 AND cbxSkyName.selected != undefined then (
			wallworm_file_vmf_presets.skyName = cbxSkyName.selected

			wallworm_addVMFRootNode()
			rootNode.skyName = wallworm_file_vmf_presets.skyName
		)
	)

	on cbxSkyName entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.skyName = text

		if findItem cbxSkyName.items wallworm_file_vmf_presets.skyName == 0 then (
			tempItems = cbxSkyName.items
			append tempItems wallworm_file_vmf_presets.skyName

			cbxSkyName.items = tempItems
		)

		if cbxSkyName.items != undefined then (
			cbxSkyName.selection = findItem cbxSkyName.items wallworm_file_vmf_presets.skyName
		)

		wallworm_addVMFRootNode()
		rootNode.skyName = text
	)

	on spnMaxPropScreenWidth changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.MaxPropScreenWidth = val
		wallworm_addVMFRootNode()
		rootNode.MaxPropScreenWidth = val
	)

	on spnMinPropScreenWidth changed val do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.MinPropScreenWidth = val
		wallworm_addVMFRootNode()
		rootNode.MinPropScreenWidth = val
	)

	on btnLeak pressed do
	(
		macros.run "wallworm.com" "WallWormLoadLeakFileMCR"
	)

	on chkEmbedWAVs changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.EmbedWAVs = state
		wallworm_addVMFRootNode()
		rootNode.EmbedWAVs = state
	)

	on edtDetailSprites entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.DetailSprites = text
		wallworm_addVMFRootNode()
		rootNode.DetailSprites = text
	)

	on edtDetailVBSP entered text do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.DetailVBSP = text
		wallworm_addVMFRootNode()
		rootNode.DetailVBSP = text
	)

	on chkBreakNonPlanarFaces changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.BreakNonPlanarFaces = state
		wallworm_addVMFRootNode()
		rootNode.BreakNonPlanarFaces = state
	)

	on chkPrecise changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.precise = state
		wallworm_addVMFRootNode()
		rootNode.precise = state
	)

	on chkWeld changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.weldWorldGeometry = state
		wallworm_addVMFRootNode()
		rootNode.weldWorldGeometry = state
	)

	on chkCompileLogWindow changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.compileLogWindow = state
		wallworm_addVMFRootNode()
		rootNode.compileLogWindow = state
	)

	on chkrunVBSP changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.runVBSP = state
		wallworm_addVMFRootNode()
		rootNode.runVBSP = state
	)

	on chkrunVVIS changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.runVVIS = state
		wallworm_addVMFRootNode()
		rootNode.runVVIS = state
	)

	on chkrunVRAD changed state do
	(
		global wallworm_file_vmf_presets
		wallworm_file_vmf_presets.runVRAD = state
		wallworm_addVMFRootNode()
		rootNode.runVRAD = state
	)

	on btnlog pressed do
	(
		macros.run "wallworm.com" "WallWormLoadBSPCompileLogMCR"
	)
)

if NOT (wallworm_addVMFRootNode()) then (
	wallworm_file_vmf_presets = wallwormVMF()
	rootNode.setVMFFromthis &wallworm_file_vmf_presets

	if isProperty rootNode #'WW Entity worldspawn' then (
		wallworm_file_vmf_presets.worldspawn = rootNode
		wallworm_file_vmf_presets.setFromWorldspawn()
	)

)

createDialog WallWormVMFExport
wwvmfdummy = undefined
WallWormVMFExport.cbxPresets.items = (updateVMFPresetList() as Array)

if isProperty rootNode #'WW Entity worldspawn' then (
	wallworm_file_vmf_presets.worldspawn = rootNode
	wallworm_file_vmf_presets.setFromWorldspawn()
	wallworm_file_vmf_presets.setWorldspawn()

)

WallWormVMFExport.setFromPreset (wallworm_file_vmf_presets)

WallWormVMFExport.cbxSkyName.items = WallWormVMFExport.getSkyNames()

bspItems = WallWormVMFExport.ddlBSPOpts.items
radItems = WallWormVMFExport.ddlRadOpts.items
visItems = WallWormVMFExport.ddlVisOpts.items

/*ALphabetize the option lists*/
sort bspItems
sort radItems
sort visItems

WallWormVMFExport.ddlBSPOpts.items = bspItems
WallWormVMFExport.ddlRadOpts.items = radItems
WallWormVMFExport.ddlVisOpts.items = visItems

bspItems = undefined
radItems = undefined
visItems = undefined

