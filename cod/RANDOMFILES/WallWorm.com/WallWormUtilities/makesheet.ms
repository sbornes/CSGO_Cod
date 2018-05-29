--Class to convert bitmaps into animated spritesheets for Source Engine Particle Systems
if ::makesheetRollout == undefined then (
	::makesheetRollout = rollout makesheetRollout "Export Animated Particle Textures" width:300 (
		local wallworm_makesheet = struct wallworm_makesheet (
			folder="particle\wallworm",
			pakmode = false,
			ATSOpsGetResolvedPaths = ATSOps.GetResolvedPaths,
			function makesheet_sequence filelist sequenceNum:0 loop:true rgb:true a:true rate:1.0 = (
				local str = stringstream ""
				if filelist.count >0 then (
					local suffix = ""
					case of (
						(rgb==true AND a ==false):(
							suffix = "-rgb"
						)
						(rgb==false AND a ==true):(
							suffix = "-a"
						)
						default:(
						)
					)
					format "sequence% %\r\n" suffix sequenceNum to:str
					if loop then (
						format "LOOP\r\n" to:str
					)
					for f in filelist do (
						format "frame % %\r\n" f rate to:str
					)
				)
				str as string
			),
			function makesheet_from_bitmaps bitmaps  = (
				local str = stringstream ""
				local seqNum = 1
				for tex in bitmaps WHERE classof tex == BitmapTexture do (
					local fileList = #()
					if toLower (getFilenameType tex.filename) == ".ifl" then (
						if ::wallworm_parseIFL == undefined then (
							macros.run "wallworm.com" "WallWormInitialize"
						)
						fileList =:: wallworm_parseIFL tex.filename
					) else (
						fileList = #(tex.filename)
					)	
					
					--sanitize list to only TGA files
					fileList = for bm in fileList WHERE (toLower (getFileNameType bm) == ".tga") collect bm
					
					if fileList.count > 0 then (
						
						local loop = (tex.endCondition == 0)
						local a
						local rgb
						if pakmode then (
							a == (tex.alphaSource != 2)
							rgb = (tex.rgbOutput == 0 )
						) else (
							a = rgb = false
						)
						local ResolvedFileList = #()
						ATSOpsGetResolvedPaths &FileList &ResolvedFileList
						local seq = makesheet_sequence ResolvedFileList sequenceNum:seqNum loop:loop rgb:rgb a:a rate:tex.playbackrate
						format seq to:str
						seqNum += 1				
					)
				)
				str as string
			),
			function makesheet texturelist  = (
				local str = stringstream ""
				format "//MakeSheet File created by Wall Worm\r\n//Documentation at http://dev.wallworm.com/document/187/exporting_animated_particle_textures.html\r\n"  to:str
				if pakmode == true then (
					format "packmode rgb+a\r\n" to:str
				)
				format (makesheet_from_bitmaps texturelist ) to:str
				str as string
			),
			function save_makesheet texturelist sheetfile:undefined  openText:false = (
				if sheetfile == undefined then (
					sheetfile = getSaveFileName types:"MakeSheet (*.mks)|*.mks" historyCategory:"Wall Worm Makesheet"
				)
				if sheetfile != undefined then (
					local str = makesheet texturelist 
					if str != undefined AND str != "" then (
						(DotNetClass "System.IO.File").WriteAllText sheetfile str
						if openText then (
							try (
								execute ("ShellLaunch \"" + ::wallworm_text_editor + "\" @\"" + sheetfile + "\"")
							) catch(
								execute folderOpen ("ShellLaunch \"explorer.exe\" @\"" + (getFilenamePath sheetfile) + "\"")
							)				
						)
						sheetfile
					) else (
						false
					)
				) else (
					false
				)
			),
			function getBitmapTextures_selected objs = (
				local texturelist = for obj in objs WHERE classof obj.mat == Standard AND classof obj.mat.diffusemap == BitmapTexture collect obj.mat.diffusemap
				texturelist = makeUniqueArray texturelist
				texturelist
			),
			function exportSelectedBitmapsToSheet sheetfile:undefined  openText:false texturelist:undefined = (
				if texturelist == undefined then (
					texturelist = getBitmapTextures_selected (selection as array)
				)
				if texturelist.count > 0 then (
					local res = save_makesheet texturelist sheetfile:sheetfile  openText:openText
					if res != false then (
						local fname = getFileNameFile res
						local fpath = getFileNamePath res
						local sheetstring = stringstream ""
						local sl = "\\"
						local batchFIlePath  = stringstream ""
						format "%%%\\" ::wwmt_exportMats sl folder to:batchFIlePath
						batchFIlePath = batchFIlePath as string
						if NOT doesFileExist batchFIlePath then (
							makeDir batchFIlePath all:true
						)
						local batchFileName = batchFIlePath + fname + ".bat"
						format "cd \"%\"\r\nmksheet \"%\" \"%%%.sht\" \"%%%.tga\" \r\n" ::wwmt_binDir res batchFIlePath sl fname  batchFIlePath sl fname to:sheetstring
						format "vtex -game \"%\" -outdir \"%\materials%%\" -shader UnlitGeneric -vmtparam $translucent 1  \"%%%.sht\"\r\n" ::wwmt_gameInfoDir  ::wwmt_gameInfoDir sl folder batchFIlePath sl fname to:sheetstring
						format "@pause\r\n"  to:sheetstring
						print (sheetstring as string)
						print batchFileName
						(DotNetClass "System.IO.File").WriteAllText batchFileName (sheetstring as string)
						
						shellLaunch batchFileName ""
						true
					) else (
						false
					)
				) else (
					false
				)
			)
		)
		local mySheet = (wallworm_makesheet())
		group "Export Options" (
			EditText edtPath "Path" text:mySheet.folder
			CheckBox chkPakMode "packmode rgb+a" tooltip:"When on, separate Color and Alpha based on Bitmap Alpha settings." checked:mySheet.pakmode
		)
		group "Other Options" (
			CheckBox chkOpen "Open .MKS File At Export"
		)
		Button btnMakeSheet "Make Sheet and Compile" tooltip:"Click to export now." width:280 height:30
		on btnMakeSheet pressed do (
			local texturelist = mySheet.getBitmapTextures_selected (selection as array)
			if texturelist.count > 0 then (
				mySheet.folder=  edtPath.text --"particle\wallworm"
				mySheet.pakmode = chkPakMode.checked
				local res = mySheet.exportSelectedBitmapsToSheet openText:chkOpen.checked texturelist:texturelist
				if res == false then (
					--user probable cancelled file save
				)
			) else (
				messagebox "No valid objects were selected. Select objects with TGA/IFL bitmaps in the diffuse map of their materials."
			)
		)
		Label blbVersion "Make Sheet Version 1.0" across:2
		HyperLink hyperHelp "Documentation" address:"http://dev.wallworm.com/document/187/exporting_animated_particle_textures.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
		HyperLink hyperLink "Developed by Wall Worm" align:#center address:"http://www.wallworm.com" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	)
)
try (destroyDialog ::makesheetRollout) catch ()
createDialog ::makesheetRollout