scriptPath = symbolicPaths.getPathValue "$userScripts"
::wallworm_userIni = scriptPath + "\WallWorm.com\config\wwmt.ini"

if (doesFileExist ::wallworm_userIni == false) then (
	::wwmtinifolder = scriptPath + "\WallWorm.com\config"
	if (makeDir ::wwmtinifolder all:true == false) then (
		print "Config Directory doesn't exist"
		messageBox "There is no config directory for the WW Model Tools... and MAXScript does not have permission to write to the appropriate directory."
	)

)

::wwmt_exportMats = getINISetting ::wallworm_userIni "Directories" "exportMats"

::wwmt_binDir = getINISetting ::wallworm_userIni "Directories" "binDir"

::wwmt_gameInfoDir = getINISetting ::wallworm_userIni "Directories" "gameInfoDir"

