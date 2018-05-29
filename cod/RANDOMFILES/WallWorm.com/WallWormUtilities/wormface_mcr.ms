macroScript WallWormFaceMCR
category:"wallworm.com"
tooltip:"Worm Face"
buttontext:"Worm Face"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/wallwormface.ms"

		if doesFileExist f then (
			fileIn f
		) else(
			messageBox "Worm Face is missing. Reinstall WWMT."
		)
	)

)
