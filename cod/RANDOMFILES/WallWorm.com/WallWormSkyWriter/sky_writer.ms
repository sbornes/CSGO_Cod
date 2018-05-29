/*  
Wall Worm Productions
http://www.wallworm.com

Wall Worm Sky Writer
by Shawn Olson
http://www.shawnolson.net

Get the latest version at:
http://dev.wallworm.com/topic/43/sky_writer.html

Special Thanks to Fabian Groß of 48Design.de for writing the PFM Exporter.
http://www.zwischendrin.com

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/ww_common_funcs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/write_pfm.ms")

if ::wwmt_exportMats == undefined OR ::wwmt_exportMats == "" OR ::wwmt_binDir == undefined OR ::wwmt_binDir == "" then (
	messageBox "In order to use Sky Writer, you must make sure to set the Material root for your mod and the Bin Directory.\n\nSet them then restart Sky Writer."
	fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/wwmtconfigutility.ms")

) else (
	global ww_wwsw_version = 1.2
	global ww_wwsw_sky_box
	global ww_wwsw_sky_resolutions = #(128, 256, 512, 1024, 2048, 4096)
	global ww_wwsw_sides = #("rt", "lf", "ft", "bk")
	global ww_wwsw_cubeFaces = #(
		--BEGIN IGNORE FORMAT
		#((Quat -0.707107 0.707107 0 0), "up"),
		#((Quat 0 0 -0.707107 0.707107), "dn"),
		#((Quat 0.5 -0.5 -0.5 0.5), "rt"),
		#((Quat -0.5 -0.5 -0.5 -0.5), "lf"),
		#((Quat 0.707107 0 0 0.707107), "bk"),
		#((Quat 0 0.707107 0.707107 0), "ft")
		--END IGNORE FORMAT
	)

	global ww_wwsw_defaultGamma = 2.2
	function ww_wwsw_getGamma = (
		local g = getUserProp ww_wwsw_sky_box #wwsw_gamma

		if g != undefined AND g != "" then (
			g = ((getUserProp ww_wwsw_sky_box #wwsw_gamma) as Float)

		) else (
			g = ww_wwsw_defaultGamma
		)
		g
	)

	function ww_wwsw_getGammaHDR = (
		local g = getUserProp ww_wwsw_sky_box #wwsw_gamma_hdr

		if g != undefined AND g != "" then (
			g = ((getUserProp ww_wwsw_sky_box #wwsw_gamma_hdr) as Float)

		) else (
			g = 1
		)
		g
	)

	function ww_wwsw_runSkyBatch = (
		if isValidNode ww_wwsw_sky_box then (
			local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname
			batchName = ::wwmt_exportMats + "\\skybox\\" + sn + ".bat"

			studiopath = ::wwmt_binDir + "\\" + "vtex.exe"
			if doesFileExist (studiopath) then (
				if ((maxVersion())[1] == 14000) then (
					shellLaunch (::wwmt_exportMats + "\\skybox\\" + sn + "_2012.bat") ""
				) else (
					shellLaunch batchName ""
				)
			) else (
				messageBox "The batch Compiler cannot run because VTEX.exe isn't in the specified directory."
			)
		) else (
			messageBox "The sky doesn't exist"
		)

	)

	function ww_wwsw_makeCubeCross b s = (
		if isValidNode ww_wwsw_sky_box then (
			local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname
			if sn == undefined then (
				sn = ""
			)

			local hdrfile = ::wwmt_exportMats + "\\skybox\\" + (sn as String) + ".tga"
			--local ldrfile = ::wwmt_exportMats+"\\skybox\\"+(sn as string)+".tga"
			try (
				Targa.setColorDepth 32
				Targa.setAlphaSplit true
				Targa.setPreMultAlpha true

				try (
					local g = (ww_wwsw_getGammaHDR() as Float)
				) catch (
					g = 1
				)
				hdrCross = undefined
				hdrCross = Bitmap (s * 4) (s * 3) filename:hdrfile gamma:g HDR:true Color:(Color 128 128 128 0) PixelAspect:1 colorDepth:32

				freeSceneBitmaps()

				--Top
				pasteBitmap b[1] hdrCross (Box2 0 0 s s) [s * 3, 0]
				--Back
				pasteBitmap b[6] hdrCross (Box2 0 0 s s) [0, s]
				--Left
				pasteBitmap b[4] hdrCross (Box2 0 0 s s) [s, s]
				--Front
				pasteBitmap b[5] hdrCross (Box2 0 0 s s) [s * 2, s]
				--Right
				pasteBitmap b[3] hdrCross (Box2 0 0 s s) [s * 3, s]
				--bottom
				pasteBitmap b[2] hdrCross (Box2 0 0 s s) [s * 3, s * 2]

				wallwormWritePFM hdrCross 2 filename:(::wwmt_exportMats + "\\skybox\\" + (sn as String) + ".hdr.pfm")
				save hdrCross
				freeSceneBitmaps()

			) catch(
				print (getCurrentException() as String)
				messageBox ("There was an error making the cube cross image:\n\n" + (getCurrentException()))

			)

		) else (
			messageBox "Please pick a Sky Writer Helper first or create a new one."

		)

	)

	function ww_wwsw_setSkyName n = (
		if isValidNode ww_wwsw_sky_box then (
			n = wallworm_makeStringSafe(n)
			setUserProp ww_wwsw_sky_box #wwsw_skyname n
			local skyname = ::wwmt_exportMats + "\\skybox\\" + (n as String) + "_hdr.tga"
			ww_wwsw_sky_box.mat.reflectionMap.outputname = skyname

		)
		return n
	)

	function ww_wwsw_giveDiffuseMap &mat = (
		if mat.diffuseMap == undefined then (
			mat.diffuseMap = BitMapTexture filename:(::wallworm_installation_path + "/WallWorm.com/assets/wwsw_helper_diffuse.png")
		)

		if mat.selfillumMap == undefined then (
			mat.selfillumMap = mat.diffuseMap
			mat.useSelfIllumColor = on
		)

		mat.showInViewport = true

	)

	function ww_wwsw_checkExposureSettings = (
		if ((classOf SceneExposureControl.exposureControl == Automatic_Exposure_Control) OR (classOf SceneExposureControl.exposureControl == Linear_Exposure_Control)) then (
			false
		) else (
			true
		)
	)

	function ww_wwsw_checkGamma = (
	)

	function ww_wwsw_setSkyOutputName state = (
		if isValidNode ww_wwsw_sky_box then (
			local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname
			if sn == undefined then (
				sn = ""
			)
			local skyname = ::wwmt_exportMats + "\\skybox\\" + (sn as String) + "_hdr.tga"
			ww_wwsw_sky_box.mat.reflectionMap.outputname = skyname
		)

	)

	function writeSkyVMT texname side ldr:false oldcubepath:true valveShader:"Sky" = (
		if ldr == true OR oldcubepath == false then (
			local hdrext = ""
		) else (
			local hdrext = "_hdr"
		)

		vmtfilename = ::wwmt_gameInfoDir + "/materials/skybox/" + texname + side + hdrext + ".vmt"

		if doesFileExist vmtfilename == true then (
			local vmtfile = openFile (vmtfilename) mode:"w"
		) else (
			local vmtfile = createFile(vmtfilename)
		)
		local extra = ""

		if ldr == true then (
			local extra = "basetexture\t\"skybox/" + texname + side + "\"\n"
			append extra ("hdrbasetexture\t\"skybox/" + texname + "_hdr" + side + "\"\n")

		) else (
			local extra = "basetexture\t\"skybox/" + texname + "_hdr" + side + "\"\n"

		)

		bt = ("\"" + valveShader + "\"\n{\n$nofog 1\n$ignorez 1\n" + extra + "}")
		format bt to:vmtfile

		close vmtfile
	)

	function writeBatchFile = (
		local errors = #()

		if isValidNode ww_wwsw_sky_box then (
			local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname
			batchName = (::wwmt_exportMats) + "\\skybox\\" + sn + ".bat"

			if (makeDir (::wwmt_exportMats + "\\skybox") all:true) == false then (
				append errors ("The Path you want to export to does not exist. Please make sure to create the following path.:\n\n" + ::wwmt_exportMats + "\\skybox")

			)
			try (
				if doesFileExist batchName == true then (
					local newBatch = openFile (batchName) mode:"w"
				) else (
					local newBatch = createFile (batchName)
				)

			) catch(
				append errors ("Sky writer does not have permission to write to this directory:\n\n" + ::wwmt_exportMats + "\\skybox")

			)
			if errors.count == 0 then(
				useSkyShader = getUserProp ww_wwsw_sky_box #wwsw_use_skyshader
				local valveShader = "Sky"
				if useSkyShader == undefined OR useSkyShader == "true" OR useSkyShader == true then (
					valveShader = "Sky"

				) else (
					valveShader = "UnlitGeneric"
				)

				local gameInfoParam = ""
				if ::wwmt_gameInfoDir != undefined AND ::wwmt_gameInfoDir != "" then (
					append gameInfoParam (" -game \"" + ::wwmt_gameInfoDir + "\"")
				)

				local tFormat = getUserProp ww_wwsw_sky_box #wwsw_tformat
				if tFormat == undefined OR tFormat == "" then (
					tFormat = false
				)

				local usetFormat = getUserProp ww_wwsw_sky_box #wwsw_use_tformat
				if usetFormat == undefined OR usetFormat == "" then (
					usetFormat = false
				)

				if tFormat == true AND usetFormat == false then (
					append gameInfoParam "  -oldcubepath"
				)

				--local	usePFM = true

				format "@echo on\n" to:newBatch

				--local bt = "cd \""+::wwmt_binDir+">\"\n" 
				--Format bt to:newBatch

				local fytext = ""
				--if (usePFM != undefined AND usePFM == true) do (

				local pfmscale = getUserProp ww_wwsw_sky_box #wwsw_pfm_brightness
				if pfmscale == undefined OR pfmscale == "" then (
					pfmscale = 1
				)

				fytext = "pfm 1\npfmscale " + (pfmscale as String) + "\n"

				--)  

				local useHalf = getUserProp ww_wwsw_sky_box #wwsw_halfsides
				if useHalf == undefined then (
					useHalf = false
				)

				--local	usePFM = getUserProp ww_wwsw_sky_box #wwsw_pfm
				local mkTiny = getUserProp ww_wwsw_sky_box #wwsw_tinyb
				if mkTiny == undefined then (
					mkTiny = false
				)

				local useSkyFlag = true
				local skyboxLine = "skybox 1\n"
				if useHalf == true OR mkTiny == true then (
					useSkyFlag = false
					skyboxLine = ""
				)

				/*Text to control compiling parameters for images. Written to skytextfile and skytextfileL below.*/
				append fytext ("clamps 1\nclampt 1\n" + skyboxLine + "nocompress 1\nnomip 1\nnolod 1\nnonice 1")
				local fytextL = ("clamps 1\nclampt 1\n" + skyboxLine + "nomip 1\nnolod 1\nnonice 1\nnocompress 1")

				if usetFormat == true then (
					local sideName = sn + "_hdr"
					local sideNameHDR = sn + "_hdr.hdr"
					local sideNameL = sn
					local textName = ::wwmt_exportMats + "\\skybox\\" + sideName + ".txt"
					local textNameL = ::wwmt_exportMats + "\\skybox\\" + sideNameL + ".txt"

					/*Create text files to store compile flags for the sky images.*/

					if doesFileExist textName == true then (
						local skytexfile = openFile (textName) mode:"w"
					) else (
						local skytexfile = createFile(textName)
					)

					if doesFileExist textNameL == true then (
						local skytexfileL = openFile (textNameL) mode:"w"
					) else (
						local skytexfileL = createFile(textNameL)
					)

					format fytext to:skytexfile
					close skytexfile

					format fytextL to:skytexfileL
					close skytexfileL

					fname = ::wwmt_exportMats + "\\skybox\\" + sideName + ".hdr.pfm"
					fnameGO = ::wwmt_exportMats + "\\skybox\\" + sideName + ".hdr.pfm"
					bname = ::wwmt_exportMats + "\\skybox\\" + sideNameL

					bt = "\"" + ::wwmt_binDir + "\vtex.exe\"" + gameInfoParam + " -nopause -mkdir -shader " + valveShader + " -vmtparam $nofog 1 -vmtparam $ignorez 1 \"" + fnameGO + "\"\n"
					format bt to:newBatch

					writeSkyVMT sn "" ldr:false oldcubepath:false valveShader:valveShader

				) else (
					index = 1
					for face in ww_wwsw_cubeFaces do (
						--local baseName = sn+(ww_wwsw_cubeFaces[index][2])
						/*
						local sideName = sn+"_hdr"+(ww_wwsw_cubeFaces[index][2])
						local sideNameHDR = sn+"_hdr"+(ww_wwsw_cubeFaces[index][2])+".hdr"*/

						local sideName = sn + (ww_wwsw_cubeFaces[index][2])
						local sideNameHDR = sn + (ww_wwsw_cubeFaces[index][2]) + ".hdr"

						local sideNameL = sn + (ww_wwsw_cubeFaces[index][2])
						local textName = ::wwmt_exportMats + "\\skybox\\" + sideName + ".hdr.txt"
						local textNameL = ::wwmt_exportMats + "\\skybox\\" + sideNameL + ".txt"

						/*Create text files to store compile flags for the sky images.*/

						if doesFileExist textName == true then (
							local skytexfile = openFile (textName)mode:"w"
						) else (
							local skytexfile = createFile(textName)
						)
						format fytext to:skytexfile
						close skytexfile
						if doesFileExist textNameL == true then (
							local skytexfileL = openFile (textNameL)mode:"w"
						) else (
							local skytexfileL = createFile(textNameL)
						)
						--

						format fytextL to:skytexfileL
						close skytexfileL

						fname = ::wwmt_exportMats + "\\skybox\\" + sideName + ".hdr.pfm"

						bname = ::wwmt_exportMats + "\\skybox\\" + sideNameL + ".tga"

						vmts = ""

						fname2 = ::wwmt_exportMats + "\\skybox\\half_" + sideName + ".hdr.pfm"
						bname2 = ::wwmt_exportMats + "\\skybox\\half_" + sideNameL + ".tga"

						fname3 = ::wwmt_exportMats + "\\skybox\\tiny_" + sideName + ".hdr.pfm"
						bname3 = ::wwmt_exportMats + "\\skybox\\tiny_" + sideNameL + ".tga"

						/*Rename the actual sides to temporary names and use the half-height sides instead of real sides during the compile*/
						if (useHalf != undefined AND useHalf != "false" AND useHalf != false) AND (findItem ww_wwsw_sides face[2]) != 0 then (
							append vmts " -vmtparam $basetexturetransform \"center 0 0 scale 1 2 rotate 0 translate 0 0\""
							format ("rename \"" + fname + "\" \"" + sideName + ".hdr.pfm.temp\"\n") to:newBatch
							format ("rename \"" + bname + "\" \"" + sideNameL + ".tga.temp\"\n") to:newBatch

							format ("rename \"" + fname2 + "\" \"" + sideName + ".hdr.pfm\"\n") to:newBatch
							format ("rename \"" + bname2 + "\" \"" + sideNameL + ".tga\"\n") to:newBatch
						)

						/*Rename the actual bottom to temporary name and use thetiny bottom instead of real bottom during the compile*/
						if index == 2 AND mkTiny == true then (
							format ("rename \"" + fname + "\" \"" + sideName + ".hdr.pfm.temp\"\n") to:newBatch
							format ("rename \"" + bname + "\" \"" + sideNameL + ".tga.temp\"\n") to:newBatch
							format ("rename \"" + fname3 + "\" \"" + sideName + ".hdr.pfm\"\n") to:newBatch
							format ("rename \"" + bname3 + "\" \"" + sideNameL + ".tga\"\n") to:newBatch
						)

						if usetFormat == false then (
							bt = "\"" + ::wwmt_binDir + "\vtex.exe\"" + gameInfoParam + " -nopause -mkdir -shader " + valveShader + " -vmtparam $nofog 1 -vmtparam $ignorez 1 -vmtparam $hdrbasetexture \"skybox/" + sideNameHDR + "\"" + vmts + "  \"" + bname + "\"\n"
							format bt to:newBatch
							bt = "\"" + ::wwmt_binDir + "\vtex.exe\"" + gameInfoParam + " -nopause -mkdir -shader " + valveShader + " -vmtparam $nofog 1 -vmtparam $ignorez 1" + vmts + " \"" + fname + "\"\n"
							format bt to:newBatch
						) else (
							writeSkyVMT sn face[2] ldr:true
							writeSkyVMT sn face[2] ldr:false

						)

						/*Rename the actual sides as the sides instead of half-height sides after the compile is complete.*/
						if (useHalf != undefined AND useHalf != "false" AND useHalf != false) AND (findItem ww_wwsw_sides face[2]) != 0 then (
							format ("rename \"" + fname + "\" \"half_" + sideName + ".hdr.pfm\"\n") to:newBatch
							format ("rename \"" + bname + "\" \"half_" + sideNameL + ".tga\"\n") to:newBatch
							format ("rename \"" + fname + ".temp\" " + sideName + ".hdr.pfm\"\n") to:newBatch
							format ("rename \"" + bname + ".temp\" " + sideNameL + ".tga\"\n") to:newBatch
						)

						/*Rename the actual bottom as the bottom instead of tiny bottom after the compile is complete.*/
						if index == 2 AND mkTiny == true then (
							format ("rename \"" + fname + "\" \"tiny_" + sideName + ".hdr.pfm\"\n") to:newBatch
							format ("rename \"" + bname + "\" \"tiny_" + sideNameL + ".tga\"\n") to:newBatch
							format ("rename \"" + fname + ".temp\" " + sideName + "\".hdr.pfm\n") to:newBatch
							format ("rename \"" + bname + ".temp\" " + sideNameL + ".tga\"\n") to:newBatch
						)
						index += 1

					)

				)

				textName = ::wwmt_exportMats + "\\skybox\\" + sn + "_hdr.txt"

				if doesFileExist textName == true then (
					skytexfile = openFile (textName) mode:"w+"
				) else (
					skytexfile = createFile(textName)

				)

				format fytext to:skytexfile
				close skytexfile
				format "@pause\n" to:newBatch

				close newBatch

				if ((maxVersion())[1] == 14000) then (
					newBatch = openFile ((::wwmt_exportMats) + "\\skybox\\" + sn + ".bat")
					seek newBatch #eof
					maxlen = filepos newBatch
					seek newBatch 0
					res = readChars newBatch maxlen errorAtEOF:false
					close newBatch
					(DotNetClass "System.IO.File").WriteAllText ((::wwmt_exportMats) + "\\skybox\\" + sn + "_2012.bat") res

				)

			)

		)

		return errors
	)

	rollout SkyWriter "Sky Writer" width:326 height:436
	(
		EditText edt_skyName "Sky Name" pos:[7, 6] width:180 height:18 toolTip:"Enter the name of this sky (omitting the `_hdr`)"
		Button btn_createSky "Create New Sky" pos:[7, 66] width:110 height:40 toolTip:"Create a new Sky Writer Helper."
		PickButton btn_pickSky "Pick Existing Sky" pos:[121, 66] width:117 height:40 toolTip:"Pick an existing Sky Writer Helper."
		Button btn3 "Render" pos:[243, 66] width:71 height:40 toolTip:"Click here to render the 6 sky textures from the point of view of the SKy Writer Helper."
		RadioButtons rdo_resolution "Sky Resolution" pos:[8, 32] width:47 height:110 labels:#("128", "256", "512", "1024", "2048", "4096") default:3
		Button btn10 "Compile Sky to VTFs" pos:[134, 142] width:111 height:30 toolTip:"Click here to run the batch file that will compile the sky into Source."
		CheckButton ckb1 "Old Cube Path" pos:[7, 112] width:79 height:25 toolTip:"Turn on Old Cube Path (-oldcubepath) to compile this sky in mods that expect a single 4x3 texture... which is required for some mods like Left For Dead."
		Button btn_open "Open Folder" pos:[249, 143] width:66 height:29 toolTip:"Open the folder where the raw TGA bitmaps, text files and batch files are written to (Generally in your Mod's material > skybox folder)."
		Bitmap bmp1 "Bitmap" pos:[6, 176] width:315 height:180 fileName:(::wallworm_installation_path + "/WallWorm.com/assets/wwsw_logo.png")

		Label lbl1 "Wall Worm Sky Writer (c) 2012-2015 by" pos:[7, 369] width:197 height:16
		Hyperlink hyperLinkShawn "Shawn Olson" pos:[204, 369] width:70 height:16 address:"http://www.shawnolson.net" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		Label lbl_version "Version " pos:[7, 388] width:71 height:16
		Hyperlink hyperLinkWallWorm "WallWorm.com" pos:[83, 389] width:100 height:16 address:"http://www.wallworm.com" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		Hyperlink hyperLinkWallWormForum "Forums" pos:[191, 388] width:40 height:16 address:"http://www.wallworm.net" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		Button btn_configure "Settings" pos:[256, 410] width:61 height:16 toolTip:"Click here to configure output paths."
		CheckButton ckb_halfHeight "Half-Height Sides" pos:[155, 112] width:88 height:24 toolTip:"Check here if you want to use half-height images. This adds a line into the VMT (Material File) that will allow you to have a material that is wide instead of square. You will need to manually crop the bitmaps in another app."
		CheckButton ckb_tinyB "Tiny Bottom" pos:[245, 112] width:69 height:24 toolTip:"Check here if you want to use a reduced-size bitmap for the bottom."
		Spinner spn_gamma "LDR Gamma" pos:[245, 6] width:70 height:16 range:[0.1, 100, 1] scale:0.1 toolTip:"Set the gamma for the LDR bitmaps."
		Spinner spn_hdr_gamma "HDR Gamma" pos:[245, 26] width:70 height:16 range:[0.1, 100, 1] scale:0.1 toolTip:"Set the gamma for the HDR bitmaps."
		Spinner spn_pfmBrightness "" pos:[8, 155] width:72 height:16 range:[0, 100, 1] type:#float
		Label lblPFM "PFM Brightness" pos:[7, 138] width:78 height:15

		Hyperlink cust4 "zwischendrin.com" pos:[110, 410] width:137 height:16 address:"http://www.zwischendrin.com" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		Label lbl4 "Special Thanks to " pos:[10, 410] width:92 height:19
		CheckButton ckb4 "Cube Cross" pos:[88, 112] width:63 height:25 enabled:true toolTip:"Use this to compile with the Cube Cross. Not yet implemented."
		CheckButton ckbShaderSky "Sky" pos:[87, 141] width:41 height:29 toolTip:"Use the Sky Shader when checked. If off, use the Unlitgeneric shader."

		on SkyWriter open do (
			if ::wallworm_engine == 1 then (
				rdo_resolution.state = 2
			) else (
				rdo_resolution.state = 3
			)
		)

		on edt_skyName entered text do
		(
			n = ww_wwsw_setSkyName(text)
			if n != text then (
				edt_skyName.text = n
			)
		)
		on btn_createSky pressed do
		(
			ww_wwsw_sky_box = box length: 32 width:32 height: 32 isSelected:true mapcoords:on
			ww_wwsw_sky_box.name = uniqueName "SkyWriter"
			ww_wwsw_sky_box.pos = [0, 0, 0]

			if edt_skyName.text == "" then (
				edt_skyName.text = uniqueName "Custom_Sky"

			)

			local rsize = ww_wwsw_sky_resolutions[rdo_resolution.state] as Integer

			ww_wwsw_sky_box.mat = Standard name:(uniqueName (ww_wwsw_sky_box.name + "_Material_")) reflectionMap:(reflectRefract source:1 size:rsize)
			ww_wwsw_giveDiffuseMap ww_wwsw_sky_box.mat
			ww_wwsw_setSkyOutputName false
			ww_wwsw_sky_box.renderable = false
			ww_wwsw_setSkyName edt_skyName.text

			setUserProp ww_wwsw_sky_box #wwsw_gamma (spn_gamma.value as String)
			setUserProp ww_wwsw_sky_box #wwsw_gamma_hdr (spn_hdr_gamma.value as String)
			--setUserProp ww_wwsw_sky_box #wwsw_pfm (ckb_pfm.state as string)
			setUserProp ww_wwsw_sky_box #wwsw_tformat (ckb1.state as String)
			setUserProp ww_wwsw_sky_box #wwsw_use_tformat (ckb4.state as String)
			setUserProp ww_wwsw_sky_box #wwsw_pfm_brightness (spn_pfmBrightness.value as String)
			setUserProp ww_wwsw_sky_box #wwsw_use_skyshader (ckbShaderSky.state as String)

		)
		on btn_pickSky picked obj do
		(
			local sn = getUserProp obj #wwsw_skyname
			if classOf obj == Box AND sn != undefined AND sn != "" then (
				ww_wwsw_sky_box = obj
				try(
					edt_skyName.text = sn
				) catch()
				try (
					rdo_resolution.state = (findItem ww_wwsw_sky_resolutions ww_wwsw_sky_box.mat.reflectionMap.size)

				) catch(
					rdo_resolution.state = 2

				)
				try (
					ckb1.state = getUserProp ww_wwsw_sky_box #wwsw_tformat

				) catch (
					setUserProp ww_wwsw_sky_box #wwsw_tformat (ckb1.state as String)
				)

				try (
					ckbShaderSky.state = getUserProp ww_wwsw_sky_box #wwsw_use_skyshader

				) catch (
					setUserProp ww_wwsw_sky_box #wwsw_use_skyshader (ckbShaderSky.state as String)
				)

				try (
					ckb4.state = getUserProp ww_wwsw_sky_box #wwsw_use_tformat

				) catch (
					setUserProp ww_wwsw_sky_box #wwsw_use_tformat (ckb4.state as String)
				)

				try (
					ckb_halfHeight.state = getUserProp ww_wwsw_sky_box #wwsw_halfsides

				) catch ()

				try (
					ckb_tinyB.state = getUserProp ww_wwsw_sky_box #wwsw_tinyb

				) catch ()

				try (
					local g = getUserProp ww_wwsw_sky_box #wwsw_gamma

					if g == undefined OR g == "" then (
						g = ww_wwsw_defaultGamma
						setUserProp ww_wwsw_sky_box #wwsw_gamma (g as String)
					)

					spn_gamma.value = (g as Float)

				)catch()

				try (
					local g = getUserProp ww_wwsw_sky_box #wwsw_gamma_hdr

					if g == undefined OR g == "" then (
						g = ww_wwsw_getGammaHDR()
						setUserProp ww_wwsw_sky_box #wwsw_gamma_hdr (g as String)
					)

					spn_hdr_gamma.value = (g as Float)

				)catch()

				try (
					local g = getUserProp ww_wwsw_sky_box #wwsw_pfm_brightness

					if g == undefined OR g == "" then (
						g = 1
						setUserProp ww_wwsw_sky_box #wwsw_pfm_brightness "1"
					)

					spn_pfmBrightness.value = (g as Float)

				)catch()

				ww_wwsw_giveDiffuseMap ww_wwsw_sky_box.mat

			) else (
				messageBox "You did not pick an existing Sky Writer Helper."
			)

		)
		on btn3 pressed do
		(
			errors = #()

			if isValidNode ww_wwsw_sky_box then (
				errors = writeBatchFile()
				if ww_wwsw_checkExposureSettings() == false then (
					append errors "You have an invalid Exposure Control in the Environment Settings. Do not use Automatic Exposure Control or Linear Exposure Control for Skybox creation."
					if (envEffectsDialog.isOpen() == false) then (
						editAtmosphere()
					)

				)
				local fnameLHL1Path
				if ::wallworm_engine == 1 then (
					fnameLHL1Path = ::wwmt_gameInfoDir + "\\gfx\\env\\"
					if NOT doesFileExist fnameLHL1Path then (
						if NOT makeDir fnameLHL1Path all:true then (
							append errors ("The gfx/env folder does not exist and Sky Writer does not have permission to create it. Please create " + fnameLHL1Path + " and make the folder writable.")
						)
					)

				)

				if errors.count == 0 then (
					local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname

					local oldComment1 = Targa.getComment1()
					local oldComment2 = Targa.getComment2()
					local oldComment3 = Targa.getComment3()
					local oldAlphaSplit = Targa.getAlphaSplit()
					local oldAlphaPre = Targa.getPreMultAlpha()

					Targa.setComment1 "sky"
					Targa.setComment2 "hdr"
					Targa.setComment3 "wallworm.com sky writer"
					Targa.setAlphaSplit false
					Targa.setPreMultAlpha true

					--Cube map renderer

					local ldrGamma = ww_wwsw_getGamma()
					local hdrGamma = ww_wwsw_getGammaHDR()

					local cubeCamera = freeCamera()
					cubeCamera.orthoProjection = off

					cubeCamera.fov = 90

					local raw = #()
					local bitmaps = #()
					local ldrs = #()

					local index = 1
					for face in ww_wwsw_cubeFaces do (
						cubeCamera.pos = ww_wwsw_sky_box.center
						cubeCamera.rotation = face[1]
						cubeCamera.pos = ww_wwsw_sky_box.center
						redrawViews()
						--local sideName = sn+"_hdr"+(face[2])
						local sideName = sn + "_hdr" + (face[2])
						local ldrName = sn + (face[2])

						local fname = ::wwmt_exportMats + "\\skybox\\" + sideName + ".tga"
						local fnameL = ::wwmt_exportMats + "\\skybox\\" + ldrName + ".tga"
						raw[index] = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size HDR:true PixelAspect:1 gamma:hdrGamma colorDepth:32
						bitmaps[index] = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size HDR:true PixelAspect:1 gamma:hdrGamma filename:fname colorDepth:32

						vmts = ""
						Targa.setColorDepth 32

						/*This chunk of code for Vray provided by Fabian Groß*/
						-- vray switch! 
						local vr = renderers.current
						local vray_render = (matchPattern (vr as String) pattern:"V_Ray_*")
						if vray_render == true then
						(
							/* VRay recognized */
							vr.output_force32bit_3dsmax_vfb = true
							vr.output_on = true
							vr.output_splitgbuffer = true
							vr.output_splitRGB = true
							vr.output_splitAlpha = false
							vr.output_splitfilename = fnameL
							rendOutputFilename = (::wwmt_exportMats + "\\skybox\\" + sideName + "_vr_temp.tga") --can be deleted afterwards!
							rendSaveFile = true
						)

						-- render cubemap images
						render camera:cubeCamera outputHDRbitmap:true vfb:(NOT vray_render) to:raw[index]

						wallwormWritePFM raw[index] 2 filename:(::wwmt_exportMats + "\\skybox\\" + (sn + (face[2])) + ".hdr.pfm")
						--this block strips any alpha
						local w = raw[index].width
						for y = 0 to raw[index].height - 1 do (
							local sourceRow = getPixels raw[index] [0, y] w
							local destRow = getPixels bitmaps[index] [0, y] w
							for x = 1 to sourceRow.count do (
								destRow[x].r = sourceRow[x].r
								destRow[x].g = sourceRow[x].g
								destRow[x].b = sourceRow[x].b
								destRow[x].alpha = 0
							)
							setPixels bitmaps[index] [0, y] destRow
						)

						save bitmaps[index]

						ldrs[index] = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size HDR:false PixelAspect:1 gamma:ldrGamma filename:fnameL colorDepth:32
						pasteBitmap bitmaps[index] ldrs[index] (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size)) [0, 0]
						save ldrs[index]

						if ::wallworm_engine == 1 then (
							Targa.setColorDepth 8
							local fnameLHL1 = fnameLHL1Path + ldrName + ".tga"
							local m2 = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size HDR:false PixelAspect:1 gamma:ldrGamma filename:fnameLHL1 colorDepth:8
							pasteBitmap bitmaps[index] m2 (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size)) [0, 0] channels:(#(#shaderColor))
							save m2
						)

						if face[2] != "up" then (
							if face[2] == "dn" then (
								local fnameTinyL = ::wwmt_exportMats + "\\skybox\\tiny_" + ldrName + ".tga"
								local altHdr = Bitmap 4 4 HDR:true PixelAspect:1 gamma:hdrGamma colorDepth:32
								local altLdr = Bitmap 4 4 HDR:false PixelAspect:1 gamma:ldrGamma colorDepth:32 filename:fnameTinyL
								pasteBitmap bitmaps[index] altHdr (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size) [0, 0]
								pasteBitmap ldrs[index] altLdr (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size ww_wwsw_sky_box.mat.reflectionMap.size) [0, 0]
								wallwormWritePFM altHdr 2 filename:(::wwmt_exportMats + "\\skybox\\tiny_" + sn + (face[2]) + ".hdr.pfm")
								--save altHdr
								save altLdr
								--)
							) else (
								--	if  ( useHalf == true )  do (
								--	local fnameHalf = ::wwmt_exportMats+"\\skybox\\half_"+sideName+".tga"
								local fnameHalfL = ::wwmt_exportMats + "\\skybox\\half_" + ldrName + ".tga"
								--make a half-sized copy
								local altHdr = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size / 2) HDR:true PixelAspect:1 gamma:hdrGamma colorDepth:32
								local altLdr = Bitmap ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size / 2) HDR:false PixelAspect:1 gamma:ldrGamma colorDepth:32 filename:fnameHalfL

								pasteBitmap bitmaps[index] altHdr (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size / 2)) [0, 0]
								--save altHdr
								pasteBitmap ldrs[index] altLdr (Box2 0 0 ww_wwsw_sky_box.mat.reflectionMap.size (ww_wwsw_sky_box.mat.reflectionMap.size / 2)) [0, 0]
								wallwormWritePFM altHdr 2 filename:(::wwmt_exportMats + "\\skybox\\half_" + sn + (face[2]) + ".hdr.pfm")
								save altLdr
								--save btHalf
								--) 							
							)
						)

						undisplay raw[index]

						local sl = index

						if index == 3 then (
							sl = 4
						)else(
							if index == 4 then (
								sl = 3
							)

						)
						ww_wwsw_sky_box.mat.reflectionMap.bitmapName[sl] = bitmaps[index].filename
						index += 1
					)
					ww_wwsw_makeCubeCross raw ww_wwsw_sky_box.mat.reflectionMap.size
					raw = undefined
					delete cubeCamera
					Targa.setComment1 oldComment1
					Targa.setComment2 oldComment2
					Targa.setComment3 oldComment3
					Targa.setAlphaSplit oldAlphaSplit
					Targa.setPreMultAlpha oldAlphaPre
					if ::wallworm_engine != 1 then (
						messageBox "The images have been rendered. You can now press the Compile Sky button or click the Open button to see the files."
					)
				) else (
					m = "There are errors:\n\n"
					for ma in errors do (
						append m (ma + "\n\n")
					)
					messageBox m

				)
			) else(
				messageBox "Please create a Sky Writer Helper or select an existing one."
			)

		)
		on rdo_resolution changed stat do
		(
			if isValidNode ww_wwsw_sky_box then (
				ww_wwsw_sky_box.mat.reflectionMap.size = ww_wwsw_sky_resolutions[stat]
			)
		)
		on btn10 pressed do
		(
			if isValidNode ww_wwsw_sky_box then (
				if ::wallworm_engine == 1 then (
					messageBox "Wall Worm is set up for Goldsource. No compiling is necessary as only TGA files are needed."
				) else (
					local proceed = true
					local sn = getUserProp ww_wwsw_sky_box #wwsw_skyname
					for face in ww_wwsw_cubeFaces while proceed == true do (
						local fname = ::wwmt_exportMats + "\\skybox\\" + sn + (face[2]) + ".hdr.pfm"
						local fnamel = ::wwmt_exportMats + "\\skybox\\" + sn + (face[2]) + ".tga"
						if (doesFileExist fname) == false OR (doesFileExist fnamel) == false then (
							proceed = false
						)
					)
					if proceed == true then (
						ww_wwsw_runSkyBatch()
					) else(
						messageBox "The compiler failed to run because you the TGA and PFM files do not exist. You must render the sky first."
					)
				)
			) else (
				messageBox "You cannot compile the sky because you have not created and/or selected a sky."
			)
		)
		on ckb1 changed state do
		(
			if isValidNode ww_wwsw_sky_box then (
				if state == true then (
					local s = "true"
				) else(
					local s = "false"
				)
				setUserProp ww_wwsw_sky_box #wwsw_tformat s
				writeBatchFile()
			)
		)
		on btn_open pressed do
		(
			try (
				folderOpen = "ShellLaunch \"explorer.exe\" @\"" + (::wwmt_exportMats + "\\skybox") + "\""
				execute folderOpen
			) catch (
				messageBox "The Material Export Path hasn't been set. Click the settings button in the Sky Writer UI and set the Material Root folder."
			)
		)
		on btn_configure pressed do
		(
			macros.run "wallworm.com" "WallWormModelToolsConfigMCR"
		)
		on ckb_halfHeight changed state do
		(
			if isValidNode ww_wwsw_sky_box then (
				if state == true then (
					local s = "true"
				) else(
					local s = "false"
				)
				setUserProp ww_wwsw_sky_box #wwsw_halfsides s
				writeBatchFile()
			)

		)
		on ckb_tinyB changed state do
		(
			if isValidNode ww_wwsw_sky_box then (
				if state == true then (
					local s = "true"
				) else(
					local s = "false"
				)
				setUserProp ww_wwsw_sky_box #wwsw_tinyb s

				writeBatchFile()
			)

		)
		on spn_gamma changed val do
		(
			if isValidNode ww_wwsw_sky_box then (
				setUserProp ww_wwsw_sky_box #wwsw_gamma (val as String)
				writeBatchFile()
			)
		)
		on spn_hdr_gamma changed val do
		(
			if isValidNode ww_wwsw_sky_box then (
				setUserProp ww_wwsw_sky_box #wwsw_gamma_hdr (val as String)
				writeBatchFile()
			)
		)
		on spn_pfmBrightness changed val do
		(
			if isValidNode ww_wwsw_sky_box then (
				setUserProp ww_wwsw_sky_box #wwsw_pfm_brightness (val as String)
				writeBatchFile()
			)

		)
		on ckb4 changed state do
		(
			if isValidNode ww_wwsw_sky_box then (
				if state == true then (
					local s = "true"
				) else(
					local s = "false"
				)
				setUserProp ww_wwsw_sky_box #wwsw_use_tformat s

				writeBatchFile()
			)
		)
		on ckbShaderSky changed state do
		(
			if isValidNode ww_wwsw_sky_box then (
				if state == true then (
					local s = "true"
				) else(
					local s = "false"
				)
				setUserProp ww_wwsw_sky_box #wwsw_use_skyshader s

				writeBatchFile()
			)
		)
	)

	createDialog SkyWriter
	--addRollout SkyWriter wwSkyWriterFloater rolledUp:false

	SkyWriter.spn_gamma.range = [0, 10, ww_wwsw_defaultGamma]

	SkyWriter.spn_hdr_gamma.range = [0, 10, 1]

	SkyWriter.lbl_version.caption += (ww_wwsw_version as String)

)