

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/flexfuncs.ms")

macroScript WallWormWormFlexMCR
category:"wallworm.com"
tooltip:"Prepare Morpher for VTA UI"
buttontext:"WW Morpher UI"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/WormFlex.ms"

		if doesFileExist f then (
			fileIn f
		) else (
			messageBox "Worm Flex Utilities Missing. Reinstall WWMT."

		)
	)

)

macroScript WallWormVTAPrepSelMCR
category:"wallworm.com"
tooltip:"Prepare Selected Meshes for VTA"
buttontext:"WW Keyframe Morphers"
(
	on execute do (
		if (::wallworm_installation_path == undefined) then (
			::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
		)

		local f = ::wallworm_installation_path + "/WallWorm.com/common/flexfuncs.ms"

		if doesFileExist f then (
			fileIn f

			if selection.count > 0 then (
				local converted = wwmt_prepare_morphs selection
				messageBox ((converted as String) + " objects prepared.")
			) else (
				messageBox "No objects selected"
			)
		) else (
			messageBox "Worm Flex Utilities Missing. Reinstall WWMT."
		)
	)
)
