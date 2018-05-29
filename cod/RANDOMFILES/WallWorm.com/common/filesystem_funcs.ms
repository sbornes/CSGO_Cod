struct wallwormFileOpsStruct (
	version = 1,
	FileSystemHelper = (try (DotNetClass "WallWorm.Helpers.FilesystemHelper") catch (undefined)),
	function checkValidFile filename = (
		local numproviders = ATSOps.NumProviders()
		local fileExists = false
		for i = 1 to numproviders while fileExists == false do (
			local myStatus = ATSOps.GetFileStatus 1 filename
			fileExists = (findItem myStatus #UNKNOWN == false)
		)
	),
	/*
	File System funcs for Wall Worm -- Gets all sub folders of Root and if folderFilter is set, filter to only folders that match the folderFilter patterns (comma-separated list)
	*/
	function getAllFoldersRecursive root folderFilter:"*" sanitize:false = (
		local dir_array = #()
		if root != undefined then (
			local dirs = GetDirectories (root + "*")
			for dir in dirs do (
				append dir_array dir
				join dir_array (getAllFoldersRecursive dir)
			)
		)
		if sanitize == true then (
			dir_array = makeUniqueArray dir_array
		)
		if folderFilter != undefined AND folderFilter != "*" AND folderFilter != "" then (
			local tmpAr = #()
			local rc = root.count + 1
			local filters = filterString folderFilter ","
			--first strip root because we want to exclude it from pattern matching
			for d in dir_array do (
				str = (substring d rc d.count)

				local filterAdd = false
				for f in filters while filterAdd == false do (
					if findstring f "*" == undefined then (
						f = "*" + f + "*"
					)
					if matchPattern str pattern:f then (
						append tmpAr d
						filterAdd = true
					)
				)
			)
			dir_array = tmpAr

		)
		dir_array
	),

	/*
	File System funcs for Wall Worm
	*/
	function wallworm_getFoldersRecursive root folderFilter recurse:false = (
		local dir_array = #()
		if root != undefined AND folderFilter != undefined then (
			local dirs = filterString folderFilter ","

			for dir in dirs do (
				join dir_array (GetDirectories (root + "/" + dir))
				if recurse == true then (
					for d in dir_array do (
						local dirpath = d + "/*"
						local newDirs = GetDirectories (dirpath)
						join dir_array newDirs
						join dir_array (getFoldersRecursive dirpath "*" recurse:true)
					)
				)
			)
		)
		dir_array
	),
	function getFilesRecursive root folderFilter fileFilter recurse:false extension:".vmt" = (
		if FileSystemHelper != undefined AND ::WallwormProActive == true AND ::wallwormUSEMXS_Filesearch != true then (
			(FileSystemHelper.GetFilesRecursive root folderFilter fileFilter recurse extension) as Array
		) else (
			local my_files = #()
			if root != undefined then (
				local dir_array = #()
				if recurse then (
					dir_array = getAllFoldersRecursive root folderFilter:folderFilter sanitize:true
				) else (
					dir_array = #((root + "\\"))
				)
				local files = filterString fileFilter ","
				for file in files do (
					for f in dir_array do (
						join my_files (getFiles (f + file + extension))
					)
				)
				my_files = makeUniqueArray my_files
			)
			my_files
		)
	)
)
::wallwormFileOps = ::wallwormFileOpsStruct()
/*
function speedTest = (
	fe = ::wallwormFileOps .checkValidFile
	local fakefile = "C:\\myVault\\myScene.max"
	local tstart = timestamp()
	for i = 1 to 10000 do (
		fe fakefile
	)
	format "ATSOP took % miliseconds\n" ((timestamp()) - tstart)
	local tstart = timestamp()
	for i = 1 to 10000 do (
		doesFileExist fakefile
	)
	format "doesFileExist took % miliseconds\n" ((timestamp()) - tstart)
)*/