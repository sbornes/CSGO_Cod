rollout wallwormCleanup "Wall Worm House Cleaning" (
	CheckBox chkDispMats "Default Displacement Material Library" enabled:(doesFileExist "$matlibs/WallWormDisplacementMaterials.mat")
	CheckBox chkImpMats "VMT Imports Library" enabled:(doesFileExist "$matlibs/WallWormVMTImportMaterials.mat")
	Button btnDoIt "Delete Selected Files"
	on btnDoIt pressed do  (
		local res = stringstream ""
		if chkDispMats.checked == true AND doesFileExist "$matlibs/WallWormDisplacementMaterials.mat"  then (
			deleteFile "$matlibs/WallWormDisplacementMaterials.mat"
			format "* Default Displacement Material Library\n" to:res
		)
		
		if chkImpMats.checked == true AND doesFileExist "$matlibs/WallWormVMTImportMaterials.mat"  then (
			deleteFile "$matlibs/WallWormVMTImportMaterials.mat"
			format "* VMT Imports Library\n" to:res
		)
		messagebox ("The following Files were deleted:\n\n" + (res as string))
	)
)