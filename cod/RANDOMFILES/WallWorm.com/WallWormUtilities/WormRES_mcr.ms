macroScript WallWormWormResMCR
category:"wallworm.com"
tooltip:"Create Res File"
buttontext:"RES File"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WormRES.ms"

		if doesFileExist f then (
			fileIn f

		) else (
			messageBox "Worm Res Utilities Missing. Reinstall WWMT."

		)
	)

)