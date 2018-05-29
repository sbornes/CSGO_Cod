scriptPath = symbolicPaths.getPathValue "$userScripts"
userIni = scriptPath + "\WallWorm.com\config\wwmt.ini"

if (doesFileExist ::wallworm_userIni == false) then (
	::wwmtinifolder = scriptPath + "\WallWorm.com\config"
	if (makeDir ::wwmtinifolder all:true == false) then (
		print "Config Directory doesn't exist"
		messageBox "There is no config directory for Wall Worm Tools... and MAXScript does not have permission to write to the appropriate directory."
	)

)

::wwdt_mapsrc = getINISetting ::wallworm_userIni "Directories" "exportMaps"

if ::wwdt_mapsrc == undefined then (
	::wwdt_mapsrc = ""

)