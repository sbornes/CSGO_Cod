macroScript WallWormAlphaSpecMCR
category:"wallworm.com"
tooltip:"Alpha Spec - Merge Specular Level into Alpha of other Bitmaps."
buttontext:"Alpha Spec"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)
		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/AlphaSpec.ms"
		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Alpha Spec is missing. Re-Install WWMT."

		)
	)

)
