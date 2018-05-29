
function wallworm_getMaxVersion = (
	local versinfo = DotNetClass "System.Diagnostics.FileVersionInfo"
	local myFI = versinfo.GetVersionInfo (pathConfig.appendPath (pathConfig.GetDir #maxroot) "3dsmax.exe")
	local maxExeVersion = myFI.FileVersion
	maxExeVersionArr = filterString maxExeVersion "."
)

function wallworm_need_update = (
	local out = undefined
	try (
		if (DotNetClass "System.Net.NetworkInformation.NetworkInterface").GetIsNetworkAvailable() then (
			::ww_wwmt_version_new = (DotNetObject "System.Net.WebClient").downloadString "http://wallworm.com/projects/utilities/wwmt_version.txt"
			if ::ww_wwmt_version_new != undefined AND ::ww_wwmt_version_new != "" then (
				setINISetting ::wallworm_userIni "Version" "wwmt_newversion" (::ww_wwmt_version_new as String)
				if (::ww_wwmt_version == undefined OR ::ww_wwmt_version_new as Number > ::ww_wwmt_version) then (
					out = true
				) else (
					out = false
				)
			) else(
				out = undefined
			)
		) else (
			print "No Network Available... Wall Worm could not check for updates."
			out = undefined
		)
	) catch (print "There was an error checking for a newer version of Wall Worm. Perhaps WallWorm.com is doing maintenance or the check is being blocked by a firewall.")
	out
)

function wallworm_download_updates = (
	local m
	global wallworm_donot_download

	if (wallworm_donot_download == undefined OR wallworm_donot_download == false) AND ::wallworm_winrar != undefined AND doesFileExist (::wallworm_winrar + "\\WinRar.exe") then (
		/*isDirectoryWriteable only available in Max 2010+*/
		if isDirectoryWriteable != undefined AND NOT isDirectoryWriteable (::wallworm_installation_path) then (
			m = "Cannot Update Wall Worm because the installation path is not writable."

		) else (
			userpath = (symbolicPaths.getPathValue "$userscripts")

			if NOT doesFileExist (userpath + "/tmp") then (
				makeDir (userpath + "/tmp")
			)

			web = DotNetObject "System.Net.WebClient"
			web.DownloadFile "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" (userpath + "\\tmp\\wallworm_model_tools.zip")

			if doesFileExist (userpath + "\\tmp\\wallworm_model_tools.zip") then (
				outputstr = ""
				append outputstr ("\"" + ::wallworm_winrar + "\\WinRar.exe\"  x -y \"" + userpath + "\\tmp\\wallworm_model_tools.zip\" * \"" + ::wallworm_installation_path + "\"\n")

				local bFilePath = (userpath + "\\tmp\\downloadww.bat")

				append outputstr ("DEL /F \"" + userpath + "\\tmp\\wallworm_model_tools.zip\"\n")
				append outputstr ("DEL /F \"" + bFilePath + "\"\n")

				if doesFileExist bFilePath then (
					bFile = openFile bFilePath mode:"w"
				) else (
					bFile = createFile bFilePath
				)

				format outputstr to:bFile
				close bFile
				bFile = undefined
				gc lite:false
				shellLaunch bFilePath ""

				fileIn (::wallworm_installation_path + "/WallWorm.com/common/config.ms")

				m = ("Wall Worm updated to the latest version. You should Restart 3ds Max.")
			) else (
				m = "Wall Worm was not downloaded."
			)
		)
	) else (
		m = "Wall Worm did not Update because WinRar is not installed OR because the global settings prevent it."
	)

	m
)