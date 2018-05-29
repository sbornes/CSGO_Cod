macroScript WallWormRadMCR
category:"wallworm.com"
tooltip:"Rad Worm"
buttontext:"Rad Worm"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/radworm.ms"

		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Rad Worm is missing. Reinstall WWMT."

		)
	)

)
