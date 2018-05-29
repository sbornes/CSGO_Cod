
if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/matgenfuncs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/importers/Mario_Kart_SMD_Importer.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/getQCtoMDLMap.ms")

function wallworm_get_modeldata_by_modelname mdlname = (
	global wallworm_models_array
	local found = undefined
	for ind = 1 to wallworm_models_array.count while found == undefined do (
		if (toLower (wallworm_models_array[ind].orig)) == (toLower mdlname) then (
			found = ind
		)
	)
	found
)

function wallworm_get_modelmap = (
	::wallworm_complete_model_list = #()
	::qcFiles = wwmt_getQCFilesRecursive ::wwmt_export "*" "*"
	for qc in ::qcFiles do (
		m = wallworm_mdlQCmap()
		m.qc = qc
		m.getMyMdl()
		append ::wallworm_complete_model_list m
	)
)

function wallworm_findWWMTbyMDL mdlPath objs:objects = (
	local wwmt
	local hasFoundWWMT = false
	for obj in objs WHERE isProperty obj #wwmt_ca while NOT hasFoundWWMT do (
		local testpath = toLower ("models/" + obj.modelPath + "/" + obj.modelName + ".mdl")
		if (testpath == mdlPath) then (
			wwmt = ww_LOD_wrapper()
			wwmt.init()
			wwmt.setTargetModel obj wwmt
			hasFoundWWMT = true
		)
	)
	wwmt
)

function wallworm_load_wwmt_from_library libraryfile mdlPath excludeLayer:undefined = (
	local wwmt = undefined

	if doesFileExist libraryfile then (
		--local hasLoadedFile = mergeMAXFile libraryfile  #select #noRedraw #mergeDups #renameMtlDups  --quiet:true
		local xfound = undefined
		--see if it's already loaded
		c = xrefs.getXRefFileCount()
		if c > 0 then (
			for test = 1 to c while xfound == undefined do (
				local textx = xrefs.getXRefFile test
				if (pathconfig.pathsResolveEquivalent textx.filename libraryfile) then (
					xfound = textx
				)
			)
		)
		if xfound == undefined then (
			xfound = xrefs.addNewXRefFile libraryfile -- [ #noLoad ] --[root:<XRefScene>]
			xfound.hidden = true --no need to see these bad boys in viewport
		)
		if xfound != undefined then (
			local objs = #()
			wallworm_collect_children xfound.tree.children objs skipNonVMFObjects:false removeHidden:false
			wwmt = wallworm_findWWMTbyMDL mdlPath objs:objs
		) else (
			local objs = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true
			wwmt = wallworm_findWWMTbyMDL mdlPath objs:objs
		)
	)
	wwmt
)

/*

special cases are for models in paths that don't map 1:1 between modelsrc directory and models directory

bits:
1 = Old Format (SMDs were not generated with the WW Rotate function)
2 == Dear Esther

*/
function wallworm_import_mdls special:#{} ang:0 sel:objects fromArray:"ents" mdls:false props:false mdlmap:undefined = (
	if (ang as Integer) == 0 then (
		mdls = false
		props = false
	)
	
	wallworm_get_modelmap()
	
	
	max create mode
	clearlistener()
	with undo off
	with redraw off (
		proxyLayer = LayerManager.getLayerFromName "Imported_Prop_Proxy"
		if proxyLayer == undefined then (
			proxyLayer = LayerManager.newLayerFromName "Imported_Prop_Proxy"
		)
		proxyLayer.current = true
		local skipFiles = #(".vmt",".spr")
		local theProps
		case fromArray of (
			"ents":(theProps = for obj in sel WHERE isValidNode obj AND isProperty obj #model AND isProperty obj #entityType AND isProperty obj #wallworm AND obj.entityType == "PointClass" AND obj.model != undefined AND obj.model != "" AND getUserProp obj #wallworm_already_imported == undefined AND findItem skipFiles (getFileNameType obj.model) == 0 collect obj)
			"details":(theProps = for obj in sel WHERE isValidNode obj AND isProperty obj #ww_detail AND isProperty obj #wallworm AND obj.model != undefined AND obj.model != "" AND getUserProp obj #wallworm_already_imported == undefined AND findItem skipFiles (getFileNameType obj.model) == 0 collect obj)
			default:theProps = for obj in sel WHERE isValidNode obj AND isProperty obj #model AND isProperty obj #entityType AND isProperty obj #wallworm AND obj.entityType == "PointClass" AND obj.model != undefined AND obj.model != "" AND getUserProp obj #wallworm_already_imported == undefined  AND findItem skipFiles (getFileNameType obj.model) == 0 collect obj
		)
		if theProps.count > 0 then (
			struct wallworm_model_import_wrapper (
				modelpath,
				modelname,
				orig,
				qc,
				wwmt,
				libraryfile
			)
			global wallworm_models_array = #() --store the data for the models
			global alreadyProcessed = #() --store array of model names
			local libraryRoot = (pathConfig.GetDir #import) + "/WallWormPropLibrary/" + (getFileNameFile ::wwmt_def_fgd) + "/"
			for obj in theProps do with redraw off (
				if findItem alreadyProcessed (toLower obj.model) == 0 then (
					local theStor = wallworm_findQCByModelName obj.model
					local theModelPath = getFilenamePath (toLower obj.model)
					local theFileName = getFilenameFile (toLower obj.model)
					local theStruct = wallworm_model_import_wrapper()
					theStruct.orig = tolower obj.model
					theStruct.modelname = theFileName
					if substring theModelPath 1 6 == "models" then (
						theModelPath = replace theModelPath 1 7 ""
					)
					if theStor.count > 0 then (
						theStruct.qc = theStor[1].qc
						theStruct.modelpath = theStor[1].mdl
					) else (
						local theQCShouldBe
						for m in ::wallworm_complete_model_list where m.mdl == obj.model while theQCShouldBe == undefined do (
							theQCShouldBe = m.qc
						)
						if theQCShouldBe == undefined then (
							theQCShouldBe = ::wwmt_export + "\\" + theModelPath + "\\" + theFileName + ".qc" -- This is assuming that the MDL was made from a QC in the same relative path and using the same file name
						)
						theStruct.qc = theQCShouldBe
						theStruct.modelpath = theModelPath
					)
					theStruct.libraryfile = (libraryRoot + theModelPath + "/" + theFileName + ".max")
					append wallworm_models_array theStruct
					append alreadyProcessed obj.model
				)
			)
			local allObject = wallworm_get_all_objects skipNonVMFObjects:false removeHidden:false includeScene:true

			local allwwmt = for obj in allObject WHERE isProperty obj #wwmt_ca collect obj
			/*Go through all the QC files and generate WWMT associations*/
			for i = 1 to alreadyProcessed.count do with redraw off (
				dataindex = (wallworm_get_modeldata_by_modelname alreadyProcessed[i])
				modelData = wallworm_models_array[dataindex]

				/*see if there is already a WWMT helper in scene*/
				wwmts = for obj in allObject WHERE isProperty obj #wwmt_ca AND (getUserProp obj #wallworm_import_mdl_name) != undefined AND (toLower (getUserProp obj #wallworm_import_mdl_name)) == (toLower alreadyProcessed[i]) collect obj

				if wwmts.count == 0 then (
					/*An existing WWMT was not found... import it from the QC*/
					--print modelData.qc

					local wwmt
					wwmt = wallworm_findWWMTbyMDL modelData.orig objs:allwwmt
					if wwmt == undefined then (
						wwmt = wallworm_load_wwmt_from_library modelData.libraryfile modelData.orig --excludeLayer:excludeLayer
					)
					if wwmt == undefined AND doesFileExist modelData.qc then (
						slidertime = 0
						wwmt = wallworm_import_qc_from_filename modelData.qc saveToLib:true noVMF:true skipLODS:true deepSearchMaterials:false
						slidertime = 0
					)
					if wwmt == undefined then (
						print ("Missing WWMT: " + alreadyProcessed[i])
					) else (
						setUserProp wwmt.target #wallworm_import_mdl_name (toLower (alreadyProcessed[i]))
					)

				) else (
					/*A WWMT was already found... assign the wwmt to the struct*/

					wwmt = ww_LOD_wrapper()
					wwmt.init()
					wwmt.setTargetModel wwmts[1] wwmt

					--print "resuing a wwmt"
				)
				if wwmt != undefined then (
					wallworm_models_array[dataindex].wwmt = wwmt
				)

			)

			/*
			Go through all the props in the scene and turn them into proxies from the WWMT helpers.
			*/
			for obj in theProps WHERE isValidNode obj do with redraw off (
				--mdl = wallworm_get_modeldata_by_modelname obj.model
				dataindex = (wallworm_get_modeldata_by_modelname obj.model)
				mdl = wallworm_models_array[dataindex]
				if mdl.wwmt != undefined then (
					if mdl.wwmt.targets != undefined AND mdl.wwmt.targets.count > 0 AND isValidNode mdl.wwmt.targets[1] then (
						local obj1
						local proxFile = mdl.wwmt.getProxyFileName()
						if doesFileExist proxFile then (
							local oldLayer = obj.layer
							oldLayer.current = true
							obj1 = xrefs.addNewXRefObject proxFile "WallWormProxyReference" modifiers:#merge manipulators:#merge dupMtlNameAction:#autoRename
							if isValidNode obj1 then (
								obj1.transform = copy obj.transform
								local objname = obj.name
								if custAttributes.count obj > 0 then (
									wallworm_copy_ca 1 obj obj1
								)
								delete obj
								obj1.name = objname
								oldLayer.addNode obj1
								setUserProp obj1 #wwmtImportedTransform (obj1.transform as String)

							)
						)
						if NOT isValidNode obj1 then (
							obj1 = obj
						)
						mdl.wwmt.updateObjectAsProxy obj1
						setUserProp obj1 #wallworm_already_imported "true"
					) else (
						print "No targets for WWMT"
					)
				) else (
					print ("No WWMT found for " + obj.model)
				)

			)

		) else (
			messageBox "There are no entities in the scene with MDLs listed."
		)

	)

)

function wallworm_getMDLsFromVMF vmfilename deleteAll:true remake:false = (
	local mdlsArray = #()
	local theVMF = openFile vmfilename mode:"r"
	if theVMF != undefined then (
		local skipFiles = #(".vmt",".spr")
		while NOT eof theVMF do (
			local theLine = readLine theVMF
			if matchPattern theLine pattern:"*\"model\"*" then (
				theLine = trimLeft theLine
				theLine = trimRight theLine
				theLine = substituteString theLine "\t" " "
				theLine = substituteString theLine "  " " "
				local vals = filterString theLine "\""
				if vals.count == 3 then (
					mdl = toLower vals[3]
					if findItem skipFiles (getFileNameType mdl) == 0 then (
						append mdlsArray mdl
					)
				)
			)
		)
		mdlsArray = makeUniqueArray mdlsArray
		local fgdName = getFileNameFile ::wwmt_def_fgd
		local propLibPath = (pathConfig.GetDir #import) + "\\WallWormPropLibrary\\" + fgdName + "\\"
		for mdl in mdlsArray do (
			local startMdl = mdl
			if substring mdl 1 6 == "models" then (
				mdl = replace mdl 1 7 ""
			)
			local qcfilename = ::wwmt_export + "/" + mdl
			qcfilename = substituteString qcfilename ".mdl" ".qc"
			mdl = substituteString mdl ".mdl" ".max"
			local libraryfilename = propLibPath + mdl
			local wwmt
			local LibraryFileExists = doesFileExist libraryfilename
			if remake == true OR NOT LibraryFileExists then (
				wwmt = wallworm_import_qc_from_filename qcfilename
			)
			if wwmt == undefined AND LibraryFileExists == true AND NOT deleteAll then (
				wwmt = wallworm_load_wwmt_from_library libraryfilename startMdl
			)
		)
		if deleteAll then (
			delete objects
		)
	)
	close theVMF
	--"model" "models/wallworm/props/wwutilitylight1.mdl"

	mdlsArray
)