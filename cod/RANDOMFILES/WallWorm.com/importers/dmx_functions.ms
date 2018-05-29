function wallworm_convertDMXToText original inencoding:"binary" outfile:undefined outencoding:"keyvalues2" outformat:"dmx" run:true = (
	if ::WallWormDMconverter == undefined then (
		::WallWormDMconverter = (::wwmt_BinDir + "/dmxconvert.exe")
		if NOT doesFileExist ::WallWormDMconverter then (
			::WallWormDMconverter = undefined
		)
	)
	if ::WallWormDMconverter != undefined then (
		if doesFileExist original then (
			local outpath = (getFileNamePath original)
			local originalName = (getFilenameFile original)
			if outfile == undefined then (
				outfile = outpath + originalName + "Converted.dmx"
			)
			local command = StringStream ""
			format "cd \"%\"\r\n" ::wwmt_BinDir to:command
			format "dmxconvert.exe -i \"%\" -ie % -o \"%\" -oe % -of %\r\n" original inencoding outfile outencoding outformat to:command
			if run then (
				btfilename = outpath + originalName + ".bat"
				local btfile
				if doesFileExist btfilename then (
					btfile = openFile btfilename mode:"w+"
				) else (
					btfile = createFile btfilename
				)
				format (command as String) to:btfile
				close btfile

				shellLaunch outpath ""
			)
			command as String
		)
	) else (
		false
	)

)

function wallworm_launchDMXConverter = (
	try (destroydialog ::wallwormDMXConverter) catch ()
	::wallwormDMXConverter = rollout wallwormDMXConverter "DMX Converter" (
		local inEncoding = #("keyvalues", "keyvalues2", "keyvalues2_flat", "binary", "actbusy", "commentary", "vmt", "vmf", "mks", "tex_source1")
		DropDownList drpINEncoding "Original Encoding" items:inEncoding selection:4
		DropDownList drpOutType "Output Type" items:#("dmx", "movieobjects", "sfm", "sfm_settings", "sfm_session", "sfm_trackgroup", "pcf", "gui", "schema", "preset", "facial_animation", "model", "ved", "mks", "mp_preprocess", "mp_root", "mp_model", "mp_anim", \
			"mp_physics", "mp_hitbox", "mp_materialgroup", "mp_keyvalues", "mp_eyes", "mp_bonemask", "tex", "world", "worldnode") selection:1
		DropDownList drpOutEncoding "Output Encoding" items:inEncoding selection:2
		Button btnGetFile "Convert Single File"

		on btnGetFile pressed do (
			original = getOpenFileName historyCategory:"Wall Worm DMX Convert"
			if original != undefined then (
				res = wallworm_convertDMXToText original inencoding:drpINEncoding.selected outfile:undefined outencoding:drpOutEncoding.selected outformat:drpOutType.selected run:true
			)

		)

	)
	createDialog ::wallwormDMXConverter
)

wallworm_launchDMXConverter()