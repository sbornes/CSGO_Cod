macroScript WallWormSkyWriterMCR
category:"wallworm.com"
tooltip:"Sky Writer"
buttontext:"Sky Writer"
(
	on execute do (
		
		global wallworm_installation_path
		if (wallworm_installation_path == undefined) then (
			wallworm_installation_path	= (symbolicPaths.getPathValue "$scripts")
		)
		
		f = wallworm_installation_path + "/WallWorm.com/WallWormSkyWriter/sky_writer.ms"
		if doesFileExist f then (

			fileIn  f
		) else (
			messagebox "Sky Writer is missing. Reinstall WWMT."
			
		)
	)

)