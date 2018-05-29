macroScript WallWormMaterialGeneratorMCR
category:"wallworm.com"
tooltip:"Convert a collection of VMT and TGA files to 3ds Max material libraries."
buttontext:"Material Library Generator"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/common/wwmt_material_library_generator.ms"

		if doesFileExist f then (
			fileIn f

		) else (
			messageBox "The WWMT Material Library Generator is missing. Reinstall WWMT."
		)
	)

)