/*
This script will check to see if the currently installed version of Wall Worm is up-to-date.

If the instlalled version is older, it will alert the user WW is out-of-date and launch a browser window to the WW changelog.

The query string of the 

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/version_funcs.ms")

case (wallworm_need_update()) of (
	false:(
		if ::wallwormIsStartingUp != true then (
			messageBox "Wall Worm is Up-To-Date"
		) else (
			format "Wall Worm is Up-To-Date\n"
		)
	)
	true:(
		case (yesNoCancelBox "There is a newer version of Wall Worm available. Click Yes to Download, No to open the the Changelog, or Cancel to do Nothing.") of (
			#yes:(
				global wallworm_donot_download

				if ::wallworm_winrar != undefined AND doesFileExist (::wallworm_winrar + "\\WinRar.exe") then (
					if wallworm_donot_download == undefined OR wallworm_donot_download == false then (
						if isDirectoryWriteable != undefined AND NOT isDirectoryWriteable (::wallworm_installation_path) then (
							messageBox "Cannot Update Wall Worm because the installation path is not writable. You'll have to install manually."
							shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""
						) else (
							messageBox (wallworm_download_updates())
						)
					) else (
						shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""
					)
				) else (
					shellLaunch "http://www.wallworm.com/projects/utilities/wallworm_model_tools.zip" ""
				)
			)

			#no:(
				macros.run "wallworm.com" "WallWormWebChangelogMCR"
			)
			#cancel:(
				--do nothing
			)
		)
	)
	default: (
		messageBox "No version number was returned from the Wall Worm website. Try again later."
	)
)
::wallwormIsStartingUp = undefined
free ::wallwormIsStartingUp