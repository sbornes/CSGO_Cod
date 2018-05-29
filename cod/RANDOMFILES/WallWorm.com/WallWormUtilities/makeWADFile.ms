/*

MAKE WAD FILES -- A DECADE LATE BUT WHAT THE HELL

*/

macros.run "wallworm.com" "WallWormInitialize"

function wallworm_make_wad texturelist wadname appendTo:true command:"miptex" commandParams:"-1 -1 -1 -1" = (
	local mode = "r+"
	local fname = ::wwmt_binDir + "\\" + wadname + ".ls"
	local batName = ::wwmt_binDir + "\\" + wadname + ".bat"
	local lumpyScriptFile
	local readOldList = true
	if doesFileExist fname then (
		if appendTo == false then (
			mode = "w+"
			readOldList = false
		)
		lumpyScriptFile = openFile fname mode:mode
	) else (
		lumpyScriptFile = createFile fname
		readOldList = false
		appendTo = false
		mode = "w+"
	)
	local existingentries = #()
	if readOldList == true then (
		while eof lumpyScriptFile == false do (
			local thisLine = readLine lumpyScriptFile
			if matchPattern thisLine pattern:"*$LOADBMP*" then (
				thisLine = substituteString thisLine "$LOADBMP" ""
				thisLine = substituteString thisLine "\"" ""
				thisLine = trimRight (trimLeft thisLine)
				append existingentries thisLine
			)
		)
		texturelist = for t in texturelist WHERE findItem existingentries t == 0 collect t
	)

	--First Make a QLumpy Script
	local lumpyScriptString = StringStream ""
	if appendTo == false then (
		format "$DEST \"%%%.wad\"\r\n" ::wwmt_gameInfoDir "\\" wadname to:lumpyScriptString
	)
	for mp in texturelist WHERE ((toLower (getFileNameType mp)) == ".bmp") AND doesFileExist mp do (
		format "$LOADBMP \"%\"\r\n" mp to:lumpyScriptString
		format "\"%\"  % % \r\n" (getFilenameFile mp) command commandParams to:lumpyScriptString
	)
	format (lumpyScriptString as String) to:lumpyScriptFile
	close lumpyScriptFile
	free lumpyScriptFile
	local batFile
	if NOT DoesFileExist batName then (
		local launchstring = StringStream ""
		batFile = createFile batName
		local fsbin = wallworm_bsToFs ::wwmt_binDir
		format "\"%\\qlumpy.exe\" \"%%%\"" fsbin fsbin "/" wadname to:launchstring
		format (launchstring as String) to:batFile
		close batFile
		free batFile
	)
	if doesFileExist (::wwmt_binDir + "\\qlumpy.exe") then (
		ShellLaunch batName ""
		true
	) else (
		false
	)
)

function wallworm_getMaterials m &matArray = (
	case (classOf m) of (
		Standard : (
			append matArray m
		)
		MultiMaterial : (
			for mat in m.materialList do (
				wallworm_getMaterials mat &matArray
			)
		)
		DirectX_9_Shader : (
			if m.renderMaterial != undefined then (
				wallworm_getMaterials m.renderMaterial &matArray
			)
		)
		Shell_Material : (
			if m.bakedMaterial != undefined then (
				wallworm_getMaterials m.bakedMaterial &matArray
			)
		)
		Blend : (
			if m.map2 != undefined then (
				wallworm_getMaterials m.map2 &matArray

			)
			if m.map1 != undefined then (
				wallworm_getMaterials m.map1 &matArray
			)
		)
		XRefMaterial :(
			wallworm_getMaterials (m.GetSourceMaterial true) &matArray
		)
		default: (
		)
	)
)

function wallworm_getAllTexturesForWad objs:selection = (
	local texturelist = #()
	local matArray = #()
	for obj in objs WHERE isValidNode obj do (
		wallworm_getMaterials obj.mat &matArray
	)
	matArray = makeUniqueArray matArray
	for mat in matArray WHERE mat.diffuseMap != undefined do (
		local texmap = mat.diffusemap
		if texmap != undefined AND (::wallworm_canTextureExportToVTF texmap) == true then (
			local tex
			if isProperty texmap #getTGAPath then (
				tex = texmap.getTGAPath()
				local addme = true
				if tex != undefined AND NOT doesFileExist tex then (
					addme = texmap.renderMeToTGA()
				)
				if addme then (
					append texturelist tex
				)
			) else (
				tex = texmap.filename
				if tex != undefined AND (toLower (getFileNameType tex)) == ".bmp" AND doesFileExist tex then (
					append texturelist tex
				)

			)

		)

	)
	texturelist = makeUniquearray texturelist
	texturelist
)

try (destroyDialog wallwormWADExport) catch ()
rollout wallwormWADExport "Export Textures to WAD" width:800 (
	RadioButtons rdoSel "Get From" labels:#("Scene", "Selected Objects") default:1 columns:2 align:#left across:4
	Label lblCommand "Command:"
	DropDownList drpType "" items:#("miptex", "qpic")
	EditText edtCommandExtra "Command Parameters" text:"-1 -1 -1 -1"
	ComboBox cmbTexutures "Textures to Export" tooltip:"List of the textures that will get placed into the WAD." height:20
	CheckBox chkAppend "Append to Existing Lumpy Script?" checked:true align:#left
	EditText edtMapName "WAD Name" width:200
	Hyperlink hyperWAD "WAD Exporter Help" address:"http://dev.wallworm.com/document/159/export_textures_to_wad.html" align:#left color:blue hovercolor:red visited:blue
	Hyperlink hyperLumpy "Qlumpy Help" address:"https://developer.valvesoftware.com/wiki/Qlumpy?from=WallWorm" color:blue hovercolor:red visited:blue offset:[120, -20]
	Button btnMakeWad "Export Wad" width:400 height:60 align:#right offset:[0, -60]
	function setUI = (
		local objs
		if rdoSel.state == 1 then (
			objs = objects
		) else (
			objs = selection
		)
		local tex = wallworm_getAllTexturesForWad objs:objs
		cmbTexutures.items = tex
	)
	on wallwormWADExport open do (
		if selection.count == 0 then (
			rdoSel.state = 1
		) else (
			rdoSel.state = 2
		)
		setUI()
		if ::wallworm_get_vmf_name == undefined then (
			fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
		)
		edtMapName.text = ::wallworm_get_vmf_name()
	)
	on rdoSel changed stat do (
		setUI()
	)
	on btnMakeWad pressed do (
		if doesFileExist (::wwmt_binDir + "\\qlumpy.exe") then (
			wallworm_make_wad (cmbTexutures.items as Array) edtMapName.text appendTo:chkAppend.checked command:drpType.selected commandParams:edtCommandExtra.text
		) else (
			messageBox "Qlumpy.exe was not found in the Bin Directory."
		)

	)

)

createDialog wallwormWADExport
