/*
Source Game Engine Material Library Generator
Copyright (c) 2011-2015 by Shawn Olson
www.wallworm.com
*/
global wwmt_material_library_version = 1.7
global wwmt_current_material_root
global wallwormMatGen
global wallwormMaxVersions

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/filesystem_funcs.ms")

try (
	destroyDialog wallwormMatGen
) catch (
	--there was not any open
)

function wallworm_can_read_VTF = (
	--read data from VMT file f
	if ::wallwormMaxVersions == undefined then (
		::wallwormMaxVersions = wallworm_getMaxVersion()
	)
	local version = ::wallwormMaxVersions[1] as Integer
	if ::WallwormProActive == true OR version < 15 then (
		true
	) else (
		false
	)
)

function wallworm_texname_out n = (
	wallworm_remove_last_slash (wallworm_safe_path (getFileNamePath n))
)

function wwmt_ceate_material_library p project br bl mdl folderFilter fileFilter recurse usedecl:true = (
	if ::wallworm_debug then (
		local stopwatch = DotNetObject "System.Diagnostics.Stopwatch"
		stopwatch.Start()
	)
	--find all VMT files
	--find all folders and recursively run this func

	local oneLibrary = true
	if wallwormMatGen.chk_seperateLibraries.checked == true then(
		oneLibrary = false
		local BrushMaterials = MaterialLibrary()
		local ModelMaterials = MaterialLibrary()
		local BlendMaterials = MaterialLibrary()
		local DecalMaterials = MaterialLibrary()
	) else (
		local AllMaterials = MaterialLibrary()
	)
	local wwmt_getFilesRecursive = ::wallwormFileOps.getFilesRecursive
	::vmts = wwmt_getFilesRecursive p folderFilter fileFilter recurse:recurse

	local total = ::vmts.count
	local count = 0

	for vmt in ::vmts do (
		mat = ::wallworm_generateMaterialFromVMT vmt brushColor:wallwormMatGen.cp_brush.color modelColor:wallwormMatGen.cp_model.color dispColor:wallwormMatGen.cp_blend.color dispColor2:wallwormMatGen.cp_brush.color decalColor:wallwormMatGen.cp_decal.color rootPath:::wwmt_raw_mats
		local useMat = true

		if (
			(mat == undefined) OR
			(bl == false AND (classOf mat == DirectX_9_Shader OR mat.valveShader == "WorldVertexTransition")) OR
			(mdl == false AND isProperty mat #forModel AND mat.forModel == true) OR
			(br == false AND usedecl == false AND isProperty mat #valveShader AND mat.valveShader == "LightmappedGeneric") OR
			(br == false AND mdl == false AND usedecl == false AND classOf mat != DirectX_9_Shader) OR
			(usedecl == false AND ((isProperty mat #valveShader AND mat.valveShader == "DecalModulate") OR (isProperty mat #decal AND mat.decal == true)))
		) then (
			useMat = false
		)

		if useMat == true then (
			if oneLibrary == true then (
				append AllMaterials mat
			) else if classOf mat == DirectX_9_Shader OR mat.valveShader == "WorldVertexTransition" then (
				append BlendMaterials mat
			) else if mat.forModel == true then (
				append ModelMaterials mat
			) else if mat.decal == true OR mat.valveShader == "DecalModulate" then (
				append DecalMaterials mat
			) else (
				append BrushMaterials mat
			)

			count += 1
			wallwormMatGen.pb1.value = (100. * count) / total
		)
	)

	local matContinue = false
	if oneLibrary == true then (
		if AllMaterials.count > 0 then (
			matContinue = true
		)
	) else if BrushMaterials.count > 0 OR ModelMaterials.count > 0 OR BlendMaterials.count > 0 OR DecalMaterials.count > 0 then (
		matContinue = true
	)

	if matContinue == false then (
		if ::wallworm_debug then (
			stopwatch.Stop()
			messageBox ("Took " + ((DotNetClass "System.Convert").ToString stopwatch.ElapsedMilliseconds) + " ms")
		)
		messageBox "No VMTs found in the specified directories... no Material Library generated."
	) else (
		message = "Library Created:\n\n"

		if oneLibrary == true then (
			saveTempMaterialLibrary AllMaterials ("$matlibs/" + project + ".mat")
			message += ("All Materials created in \"" + project + ".mat\" in the Project Material Libraries folder.\n\n")
		) else (
			if br == true AND BrushMaterials.count > 0 then (
				saveTempMaterialLibrary BrushMaterials ("$matlibs/" + project + "_brushes.mat")
				message += ("Brush Materials created in \"" + project + "_brushes.mat\" in the Project Material Libraries folder.\n\n")
			)
			if bl == true AND BlendMaterials.count > 0 then (
				saveTempMaterialLibrary BlendMaterials ("$matlibs/" + project + "_blend.mat")
				message += ("Blend Materials created in \"" + project + "_blend.mat\" in the Project Material Libraries folder.\n\n")
			)
			if mdl == true AND ModelMaterials.count > 0 then (
				saveTempMaterialLibrary ModelMaterials ("$matlibs/" + project + "_models.mat")
				message += ("Model Materials created in \"" + project + "_models.mat\" in the Project Material Libraries folder.\n\n")
			)

			if usedecl == true AND DecalMaterials.count > 0 then (
				saveTempMaterialLibrary DecalMaterials ("$matlibs/" + project + "_decals.mat")
				message += ("Model Materials created in \"" + project + "_models.mat\" in the Project Material Libraries folder.\n\n")
			)

		)

		if ::wallworm_debug then (
			stopwatch.Stop()
			messageBox ("Took " + ((DotNetClass "System.Convert").ToString stopwatch.ElapsedMilliseconds) + " ms")
		)
		messageBox message
	)

	gc lite:false
)

rollout wallwormMatGen "Material Generator" width:208
(
	Group "Types of Libraries" (
		CheckBox chk_brushLibrary "Brush Library" toolTip:"Collect brush materials (LightmappedGeneric)." across:2
		ColorPicker cp_brush "" color:(Color 155 155 155) title:"Default Brush Color" toolTip:"Choose a default diffuse color for brush materials."
		CheckBox chk_blendLibrary "Blend Library" toolTip:"Collect Blend Materials (WorldVertexTransition)." across:2
		ColorPicker cp_blend "" color:(Color 0 155 0) title:"Default Blend Color" toolTip:"Choose a default diffuse color for blend materials."
		CheckBox chk_modelLibrary "Model Library" toolTip:"Collect Model Materials (With $model 1 or VertexLitGeneric)." across:2
		ColorPicker cp_model "" color:(Color 155 155 0) title:"Default Model Color" toolTip:"Choose a default diffuse color for model materials."
		CheckBox chk_decalLibrary "Decal Library" toolTip:"Collect Decal Materials ($decal 1 or DecalModulate)." across:2
		ColorPicker cp_decal "" color:(Color 255 0 0) title:"Default Decal Color" toolTip:"Choose a default diffuse color for decal materials when the Texture cannot be found."
	)
	Group "Library Settings" (
		CheckBox chk_seperateLibraries "Separate Libraries by Type"
		Label lbl1 "Export Project Name" align:#left
		EditText edt_libraryName "" toolTip:"Enter a name for this library project. This will be the prefix for each library created." align:#left
		Label lbl3 "Folder Filter" align:#left
		EditText edtFolders "" text:"*" toolTip:"Enter a string to limit folders to those that match the given pattern. The asterisk (*) is a wildcard." align:#left
		Label lbl5 "File Filters" align:#left
		EditText edtFileFilters "" text:"*" toolTip:"Enter a string to limit files to those that match the given pattern. The asterisk (*) is a wildcard." align:#left
	)

	Button btn_createLibraries "Material Root" width:173 height:35 toolTip:"Click here to create the material libraries. This can take several minutes if there are a lot of folders and/or VMTs."
	ProgressBar pb1 "ProgressBar" width:170 height:23

	CheckBox chk_recurse "Recursive" width:72 height:14
	Button btnGenerate "Create" width:172 height:23

	Group "WADS" (
		CheckBox chkSkipExisting "Skip WADS with Existing Folders" width:150 height:16 checked:true
		Button btnWadsFromMap "Import WADs from MAP" width:147 height:26 toolTip:"Import the WADS used in a MAP file."
		Button btnWadsFromFolder "Import WADS in Folder" width:146 height:22 toolTip:"Import the WADS in a folder. If the File Filter is used above, then files will be limited to match that filter (don't use the .wad in the filter, just the file names). Only one filter is used, so no commas."
		Hyperlink wadlink "WAD Import Help" width:146 height:15 address:"http://dev.wallworm.com/document/164/importing_wad_files.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	)

	Label lblMLV "Material Library Generator V " width:170 height:22
	Label lbl2 "Copyright (c) 2015 by Shawn Olson" width:172 height:19
	Hyperlink wwlink "Wall Worm" width:86 height:15 address:"http://www.wallworm.com" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255) across:2
	Hyperlink mathelplink "Material Library Help" width:100 height:15 address:"http://dev.wallworm.com/topic/35/material_library_generator.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)

	on btn_createLibraries pressed do
	(
		newPath = getSavePath caption:"Find Material Root" initialDir:::wwmt_raw_mats

		if newPath != undefined then (
			if newPath != ::wwmt_raw_mats then (
				::wwmt_raw_mats = newPath
				setINISetting ::wallworm_userIni "Directories" "wwmt_raw_mats" ::wwmt_raw_mats
			)

			::wwmt_current_material_root = newPath
		)
	)
	on btnGenerate pressed do
	(
		errors = #()

		if edt_libraryName.text == "" then (
			append errors "You must give this export a project name."
		)

		if chk_brushLibrary.checked == false AND chk_blendLibrary.checked == false AND chk_modelLibrary.checked == false AND chk_decalLibrary.checked == false then (
			append errors "You must choose the types of material libraries to create."
		)

		if edtFolders.text == "" then (
			append errors "The folder filter cannot be empty. If you want to search all folders in the material root, type an asterisk (*). Otherwise, wrap a folder name in asterisks."
		)

		if edtFileFilters.text == "" then (
			append errors "The file filter cannot be empty. If you want to search all VMT files, type an asterisk (*). Otherwise, wrap a file name in asterisks to use only that VMTs that have this filter in the file name."
		)

		if ::wwmt_raw_mats == undefined OR doesFileExist ::wwmt_raw_mats == false then (
			append errors "Please choose a root material folder from which to start the scan."
		)

		if errors.count != 0 then (
			message = "There are problems:\n\n"

			for err in errors do (
				append message ("* " + err + "\n\n")
			)
			messageBox message
			false
		) else (
			::wwmt_ceate_material_library ::wwmt_raw_mats edt_libraryName.text chk_brushLibrary.checked chk_blendLibrary.checked chk_modelLibrary.checked edtFolders.text edtFileFilters.text chk_recurse.checked usedecl:chk_decalLibrary.checked
		)
	)
	on btnWadsFromMap pressed do
	(
		local filename = getOpenFileName historyCategory:"Wall Worm VMF" types:"MAP FILE (.MAP)|*.map"

		if filename != undefined then (
			res = wallworm_getwadsfrommap filename skipExisting:chkSkipExisting.checked runWadImport:true
			if res != undefined AND res.count > 0 AND res[1] != undefined AND res[1].count > 0 then (
				print res

			) else (
				messageBox "No Wads found. Make sure the wads are in a place WW can find them (one of these places): In the Game Info Dir or in the same folder as the MAP."
			)
		)

	)
	on btnWadsFromFolder pressed do
	(
		local wadDir
		if doesFileExist ::wwmt_gameInfoDir then (
			wadDir = getSavePath caption:"Get Folder with WADS" initialDir:::wwmt_gameInfoDir
		) else (
			wadDir = getSavePath caption:"Get Folder with WADS"
		)
		if wadDir != undefined then (
			local filt = "*"

			if edtFileFilters.text != "" then (
				filt = edtFileFilters.text
			)
			local theWads = getFiles (wadDir + "\\" + filt + ".wad")
			if theWads.count > 0 then (
				res = wallworm_ importWads theWads skipExisting:chkSkipExisting.checked runWadImport:true quiet:true
			)

		)

	)
)

createDialog wallwormMatGen

wallwormMatGen.lblMLV.text += (::wwmt_material_library_version as String)
