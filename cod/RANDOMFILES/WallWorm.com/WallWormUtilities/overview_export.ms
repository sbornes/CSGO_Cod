/*
Wall Worm
Overview Creation Script

http://dev.wallworm.com

Copyright (c) 2012-2015 by Shawn Olson
http://www.shawnolson.net

All Rights Reserved

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

try (
	destroydialog WallWormOverviewExporter
) catch ()

(
	wallworm_StartingLayout = viewport.getLayout()
	wallworm_StartingView = viewport.getType()
	wallworm_StartingRenderLevel = viewport.GetRenderLevel()
	wallworm_StartingrenderWidth = renderWidth
	wallworm_StartingrenderHeight = renderHeight
	wallworm_oldComment1 = Targa.getComment1()
	wallworm_oldComment2 = Targa.getComment2()
	wallworm_oldComment3 = Targa.getComment3()
	wallworm_oldAlphaSplit = Targa.getAlphaSplit()
	wallworm_oldAlphaPre = Targa.getPreMultAlpha()

	try (
		wallwormNitrous = NitrousGraphicsManager.GetActiveViewportSetting()
		wallworm_oldNitrousSetting = wallwormNitrous.VisualStyleMode
	) catch ()

	rollout WallWormOverviewExporter "Wall Worm Overview Exporter v1.1" width:314 height:312
	(
		local bm1, bm2

		Button btnRender "Render" pos:[9, 228] width:132 height:43 toolTip:"Render the overview. You should have the Safe Frame turned on!"
		DropDownList ddlDimension "Overview Bitmap Size" pos:[16, 58] width:112 height:40 items:#("512", "1024", "2048") selection:2
		Button btnSF "Safe Frame Toggle" pos:[10, 193] width:131 height:29 toolTip:"Display the Safe Frame Toggle for aligning your overview."
		EditText edtMapName "Map Name" pos:[12, 9] width:286 height:20
		Button btn13 "Compile" pos:[146, 193] width:149 height:43 toolTip:"Compile the VTFs from the rendered TGA files."
		Hyperlink overlink "Help, Tips and Tricks" pos:[13, 281] width:101 height:15 address:"http://dev.wallworm.com/topic/59/overview_exporter.html" color:(Color 0 0 255) visitedcolor:(Color 0 0 255) hovercolor:(Color 255 0 0)
		DropDownList ddlRadarSize "Radar Bitmap Size" pos:[164, 96] width:121 height:40 enabled:false items:#("128", "256", "512", "1024", "2048") selection:2
		CheckBox chkRadar "Make Alternate Radar" pos:[164, 75] width:128 height:15
		CheckBox clamp "Clamp S/T" pos:[17, 114] width:76 height:16 checked:true
		CheckBox chkTranslucent "$translucent" pos:[17, 136] width:89 height:16 checked:true
		GroupBox grp1 "Radar Image" pos:[152, 44] width:145 height:140
		Button btnViewRadar "View Radar TGA" pos:[164, 145] width:123 height:26
		Button btnViewOverview "View Overview TGA" pos:[18, 155] width:108 height:23 toolTip:"Open the TGA that matches the Map Name above."
		Button btnOpenOverviewFolder "Open Overview Folder" pos:[148, 242] width:148 height:27 toolTip:"Open the folder where the overview text files go, as well as DDS files for CSGO."

		GroupBox grp6 "Default Overview" pos:[9, 41] width:131 height:144

		function setRenderDimensions = (
			renderWidth = (ddlDimension.selected as Number)

			if ::wallworm_engine == 1 then (
				renderHeight = case ddlDimension.selected of (
					1:(384)
					2:(768)
					3:(1536)
					default:(768)
				)
			) else (
				renderHeight = (ddlDimension.selected as Number)
			)
		)

		on WallWormOverviewExporter open do
		(
			viewport.setLayout #layout_1
			viewport.setType #view_top
			viewport.SetRenderLevel #smoothhighlights
			setRenderDimensions()

			try (
				wallwormNitrous.VisualStyleMode #Realistic
			) catch (
				--failed because not nitrous
			)
			/*

			local wallwormMapNameIndex = fileProperties.findProperty #custom "wallwormMapName"

			if wallwormMapNameIndex != 0 then (
				edtMapName.text =fileProperties.getPropertyValue #custom wallwormMapNameIndex
			) else (
				edtMapName.text = getFilenameFile maxFileName
			)
			*/
			edtMapName.text = wallworm_get_vmf_name()

			Targa.setComment1 "overview"
			Targa.setComment2 "hdr"
			Targa.setComment3 "wallworm.com overview creator"
			Targa.setAlphaSplit false
			Targa.setPreMultAlpha true
			if ::wallworm_engine == 1 then (
				Targa.setColorDepth 8
			) else (
				Targa.setColorDepth 32
			)

			local expRadar = getINISetting ::wallworm_userIni "Exporters" "wwmt_overview_export_radar"
			if expRadar != undefined AND expRadar == "true" then (
				ddlRadarSize.enabled = true

				chkRadar.checked = true
			)

			local overDim = getINISetting ::wallworm_userIni "Exporters" "wwmt_overview_dimension"
			if overDim != undefined then (
				ddlDimension.selection = findItem ddlDimension.items overDim

			)

			local radarDim = getINISetting ::wallworm_userIni "Exporters" "wwmt_radar_dimension"
			if radarDim != undefined then (
				ddlRadarSize.selection = findItem ddlRadarSize.items radarDim
			)

		)
		on WallWormOverviewExporter close do
		(
			viewport.setLayout wallworm_StartingLayout
			viewport.setType wallworm_StartingView

			viewport.SetRenderLevel wallworm_StartingRenderLevel

			renderWidth = wallworm_StartingrenderWidth
			renderHeight = wallworm_StartingrenderHeight

			Targa.setComment1 wallworm_oldComment1
			Targa.setComment2 wallworm_oldComment2
			Targa.setComment3 wallworm_oldComment3
			Targa.setAlphaSplit wallworm_oldAlphaSplit
			Targa.setPreMultAlpha wallworm_oldAlphaPre
			try (
				wallwormNitrous.VisualStyleMode wallworm_oldNitrousSetting
			) catch (
				--failed because not nitrous
			)
		)
		on btnRender pressed do
		(
			local initialdisplaySafeFrames = displaySafeFrames

			--local mapsize = (cbxMapDimension.text as number)
			if edtMapName.text != "" then (
				local dimension = (ddlDimension.selected as Number)
				local radarDimension = (ddlRadarSize.selected as Number)

				local colorDepth = 32
				if ::wallworm_engine == 1 then (
					colorDepth = 8
				)

				local vpTransform = viewport.getTM()
				/*
				Returns a Matrix like: (matrix3 [1,0,0] [0,1,0] [0,0,1] [-560.076,1419.73,0])
				*/
				local outScale = (getScreenScaleFactor [0, 0, 0]) / dimension
				local areadimension = (dimension * outScale)
				local tempPlane = Plane pos:[(vpTransform[4].x * -1), (vpTransform[4].y * -1), 0] lengthsegs:1 widthsegs:1 width:areadimension length:areadimension
				outX = tempPlane.min.x
				outY = tempPlane.max.y
				delete tempPlane
				local outpath
				local overviewpath
				if ::wallworm_engine == 1 then (
					outpath = ::wwmt_gameInfoDir
					overviewpath = ::wwmt_gameInfoDir + "\\overviews\\" + edtMapName.text + ".txt"
					local tgafile = outpath + "\\overviews\\" + edtMapName.text + ".bmp"
				) else (
					outpath = ::wwmt_exportMats
					overviewpath = ::wwmt_gameInfoDir + "\\resource\\overviews\\" + edtMapName.text + ".txt"
					local tgafile = outpath + "\\overviews\\" + edtMapName.text + ".tga"
				)

				local tgafile2 = outpath + "\\overviews\\" + edtMapName.text + "_radar.tga"
				local preffile = outpath + "\\overviews\\" + edtMapName.text + ".txt"
				local preffile2 = outpath + "\\overviews\\" + edtMapName.text + "_radar.txt"
				local bat = outpath + "\\overviews\\" + edtMapName.text + ".bat"

				if doesFileExist (getFileNamePath (preffile)) == false then (
					makeDir (getFileNamePath (preffile)) all:true
				)

				local overviewpath2 = ::wwmt_gameInfoDir + "\\resource\\overviews\\" + edtMapName.text + "_radar.txt"

				if doesFileExist (getFileNamePath (overviewpath)) == false then (
					makeDir (getFileNamePath (overviewpath)) all:true
				)

				local tga = Bitmap renderWidth renderHeight HDR:true PixelAspect:1 colorDepth:colorDepth filename:tgafile
				displaySafeFrames = false
				if ::wallworm_engine == 1 then (
					bmp.setType #paletted
					render outputwidth:renderWidth outputheight:renderHeight quiet:true vfb:on outputHDRbitmap:false to:tga
				) else (
					render outputwidth:dimension outputheight:dimension quiet:true vfb:on outputHDRbitmap:true to:tga
				)

				save tga

				displaySafeFrames = initialdisplaySafeFrames

				if ::wallworm_engine != 1 then (
					if chkRadar.checked == true then (
						local tga2 = Bitmap radarDimension radarDimension HDR:true PixelAspect:1 colorDepth:colorDepth filename:tgafile2
						copy tga tga2
						save tga2
						close tga2
					)
					clampline = ""
					if clamp.checked == true then (
						clampline = "\"clamps\" \"1\"\n\"clampt\" \"1\"\n"
					)
					if doesFileExist preffile == true then (
						local paramfile = openFile preffile mode:"w"
					) else (
						local paramfile = createFile(preffile)
					)
					format (clampline + "\"nocompress\" \"1\"\n\"nomip\" \"1\"") to:paramfile
					close paramfile
					if chkRadar.checked == true then (
						if doesFileExist preffile2 == true then (
							local paramfile = openFile preffile2 mode:"w"
						) else (
							local paramfile = createFile(preffile2)
						)
						format (clampline + "\"nocompress\" \"1\"\n\"nomip\" \"1\"") to:paramfile
						close paramfile
					)
				)

				close tga
				if doesFileExist overviewpath == true then (
					local overview = openFile overviewpath mode:"w"
				) else (
					local overview = createFile(overviewpath)
				)
				format ("//\tOverview Created by Wall Worm\r\n//\thttp://dev.wallworm.com\r\n") to:overview

				if ::wallworm_engine != 1 then (
					format (edtMapName.text + "\n{\n") to:overview
					format ("material	overviews/" + edtMapName.text + " \n") to:overview
					format ("pos_x		" + (formattedPrint outX) + " \n") to:overview
					format ("pos_y		" + (formattedPrint outY) + " \n") to:overview
					format ("scale		" + (formattedPrint outScale) + " \n") to:overview
					format ("rotate		0 \n") to:overview
					format ("zoom		1 \n") to:overview
					format ("}") to:overview
				) else (
					local height = (areadimension * renderWidth) / (2 * areadimension * tan(viewport.getFOV() / 2))

					--local height =  vpTransform.translationPart.z as integer
					format ("\r\nglobal {\r\n") to:overview
					format ("ORIGIN	% % % \r\n") (outX as Integer) (outY as Integer) height to:overview
					format ("ROTATED		0\r\n") to:overview
					format ("ZOOM		%\r\n") outScale to:overview
					format ("}") to:overview

					format "\nlayer {\r\n" to:overview
					format ("IMAGE	overviews/%.bmp \r\n") edtMapName.text to:overview
					format ("HEIGHT		 %\r\n") height to:overview
					format ("}\r\n") to:overview

				)
				close overview
				if ::wallworm_engine != 1 then (
					if chkRadar.checked == true then (
						if doesFileExist overviewpath2 == true then (
							local overview = openFile overviewpath2 mode:"w"
						) else (
							local overview = createFile(overviewpath2)
						)
						format (edtMapName.text + "\n{\n") to:overview
						format ("material	overviews/" + edtMapName.text + "_radar \n") to:overview
						format ("pos_x		" + (outX as String) + " \n") to:overview
						format ("pos_y		" + (outY as String) + " \n") to:overview
						format ("scale		" + (outScale as String) + " \n") to:overview
						format ("rotate		0 \n") to:overview
						format ("zoom		1 \n") to:overview
						format ("}") to:overview
						close overview
					)

					if doesFileExist bat == true then (
						local newBatch = openFile bat mode:"w"
					) else (
						local newBatch = createFile(bat)
					)

					if chkRadar.checked == true then (
						--print "yes"
						tgafile = tgafile + ("\" \"" + tgafile2 + "")

					) else (
						--print "no"
					)

					local transline = ""
					if chkTranslucent.checked == true then (
						transline = " -vmtparam $translucent 1"
					)

					format "@echo on\n" to:newBatch
					local bt = "cd \"" + ::wwmt_binDir + ">\"\n"
					format bt to:newBatch
					bt = "vtex.exe  -game \"" + ::wwmt_gameInfoDir + "\" -mkdir -shader UnlitGeneric" + transline + " -vmtparam $vertexalpha 1 -vmtparam $no_fullbright 1 -vmtparam  $ignorez 1 \"" + tgafile + "\"\n"
					format bt to:newBatch
					close newBatch
				)

				display tga

			) else (
				messageBox "You must enter a map name."
			)
		)
		on ddlDimension selected sel do
		(
			setRenderDimensions()
			setINISetting ::wallworm_userIni "Exporters" "wwmt_overview_dimension" (ddlDimension.selected as String)

		)
		on btnSF pressed do
		(
			max safeframe toggle
		)
		on edtMapName entered text do
		(
			local wallwormMapNameIndex = fileProperties.findProperty #custom "wallwormMapName"

			if wallwormMapNameIndex != 0 then (
				fileProperties.deleteProperty #custom "wallwormMapName"
			)

			fileProperties.addProperty #custom "wallwormMapName" text

		)
		on btn13 pressed do
		(
			bat = ::wwmt_exportMats + "\\overviews\\" + edtMapName.text + ".bat"
			if doesFileExist bat == true then (
				shellLaunch bat ""

			) else (
				messageBox "The batch file to compile hasn't been made. Run the Render function."
			)
		)
		on ddlRadarSize selected sel do
		(
			/*
			renderWidth  = (ddlDimension.selected as number)
			renderHeight  = (ddlDimension.selected as number)
			*/
			setINISetting ::wallworm_userIni "Exporters" "wwmt_radar_dimension" (ddlRadarSize.selected as String)

		)
		on chkRadar changed state do
		(
			ddlRadarSize.enabled = state

			setINISetting ::wallworm_userIni "Exporters" "wwmt_overview_export_radar" (state as String)

		)
		on btnViewRadar pressed do
		(
			local tgafile = ::wwmt_exportMats + "\\overviews\\" + edtMapName.text + "_radar.tga"
			if doesFileExist tgafile == true then (
				local tga = openbitmap tgafile
				display tga

			) else (
				messageBox "Ooops... the tga file for this level hasn't been rendered yet or you don't have the correct level name above."
			)

		)
		on btnViewOverview pressed do
		(
			if ::wallworm_engine == 1 then (
				local tgafile = ::wwmt_gameInfoDir + "\\overviews\\" + edtMapName.text + ".tga"
			) else (
				local tgafile = ::wwmt_exportMats + "\\overviews\\" + edtMapName.text + ".tga"
			)

			if doesFileExist tgafile == true then (
				local tga = openbitmap tgafile
				display tga

			) else (
				messageBox "Ooops... the tga file for this level hasn't been rendered yet or you don't have the correct level name above."
			)

		)
		on btnOpenOverviewFolder pressed do
		(
			if ::wallworm_engine == 1 then (
				local ovp = ::wwmt_gameInfoDir + "\\overviews\\"
			) else (
				local ovp = ::wwmt_gameInfoDir + "\\resource\\overviews\\"
			)

			ShellLaunch "explorer.exe" ovp

		)
	)
	createDialog WallWormOverviewExporter
)
