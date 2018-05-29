macroScript WallWormHullHelperMCR
category:"wallworm.com"
tooltip:"Hull Helper"
buttontext:"Hull Helper"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/HullHelper.ms"

		if doesFileExist f then (
			fileIn f

		) else (
			messageBox "Hull Helper is missing. Re-Install WWMT."

		)

	)
)
