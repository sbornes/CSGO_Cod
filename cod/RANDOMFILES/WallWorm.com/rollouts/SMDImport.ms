rollout wallWormSMDImporter "SMD and QC Importer" width:240
(
	Group "General Options" (
		CheckBox chkAnimatedModel "Animated Model (Hierarchy or Sequence)" align:#left tooltip:"Click here to deactivate functions bad for animated models."
		CheckBox chkSingelMesh "Single Mesh (Recommended + Faster)" align:#left tooltip:"Output model as single mesh. Imports faster and easier to manage." checked:true

		CheckBox chkDeepMatSearch "Extended Material Search" align:#left tooltip:"Search more paths for missing VMTs. Slower." checked:true
	)

	Group "SMD/VTA Only Options" (
		CheckBox chkYUp "Y Up" align:#left tooltip:"Rotate the model 90 degrees in the X axis because the model was made in an application where Y is up. Still Experimental."
		CheckBox chkRotate "Rotated Model" align:#left toolTip:"Check this option if the SMD is a staticprop exported by Wall Worm and you want it to be rotated by 90."
		CheckBox chkStatic "Remove Bones (Becomes Staticprop)" align:#left toolTip:"Remove all the bones from this model." checked:true
		CheckBox chkUniqueNames "Force Unique Bone Names" align:#left tooltip:"Force the node names to be unique in the scene. This is important for scenes with a lot of objects... but may be indesirable if the names of the bones are important."
		CheckBox chkRemoveUnweightedBones "Remove Unweighted Bones from Skin" align:#left tooltip:"Remove any bone from the skin if it has no vertices weighted to it. Takes longer."
		CheckBox chkZeroRotations "Nullify Root Rotation" align:#left tooltip:"Nullify the root rotation in the SMD. Best if limited to staticprop models." checked:true
		CheckBox chkXForm "Xform Mesh Node" align:#left tooltip:"Add Xform to generated mesh node." checked:true
		CheckBox chkWeldVerts "Weld Vertices" align:#left toolTip:"Weld the verticed of the mesh. You will lose the Normals/Smoothing. Generally not desirable." checked:false
		CheckBox chkQuadrifyAll "Quadrify" align:#left toolTip:"Quadrify the incoming mesh. Works best when using the Weld Verts and Convert To Poly. If PolyTools is unavailable, applies a Quadrify Modifier with a quad size of 10 (which you can adjust after the import)." checked:true
		CheckBox chkCreateWWMT "Create a WWMT Helper" align:#left toolTip:"Check this option if you want to create a WWMT helper assigned to this imported SMD." checked:true
		EditText edtMaterialp "$cdmaterials" --.text 
	)

	Group "VTA Only Options" (
		CheckBox chkVTASelectedMesh "Apply VTA Morph to Current Selection"
	)

	Group "QC Only Options" (
		CheckBox chkScaleMesh "$scale to Mesh" align:#left toolTip:"When unchecked, the $scale in a QC is translated to the WWMT helper. If this option is checked, the meshes themselves are scaled then the XForm reset."
		CheckBox chkskipLODS "Skip LODS"
		Label lblExtraSMDPaths "Extra Sequences Folder"
		EditText edtExtraSMDPath "" enabled:true
		CheckBox chkSave "Save to Prop Library" checked:true tooltip:"Save this model to the Project's Import directory for later re-use."
		CheckBox chkNoVMF "WWMT: No VMF Export" tooltip:"This option should be used if you are going to use Proxies of this model (most likely)." checked:true
		CheckBox chkautoQuadrifyStaticprop "Auto Quadrify StaticProp" checked:true tooltip:"Force Static Prop models to get quadrified."
	)

	Group "Single File" (
		Button btnImportSMD "Import QC or SMD" toolTip:"Import a SMD File or all SMD files from the QC."
	)

	Group "Batch Import" (
		EditText edtFolders "Folders" text:"*"
		EditText edtFiles "Files" text:"*"
		CheckBox chkRecurse "Recursive Search" tooltip:"Run a recursive search which will look in sub-folders." across:2
		CheckBox chkSkipRoot "Skip Root" tooltip:"Skip any QC files in the root folder."
		CheckBox chkDelete "Delete After Import" tooltip:"Check here if you are saving props to the library and don't need them in the scene."
		Button batchImportFromPath "Import Multiple Files" tooltip:"Import models that match the filter requirements. This can be a long time if there are many models."
	)

	Button btnPropLibrary "Import Prop Library From VMF File" toolTip:"Import all the props from a VMF File and save them to the Prop Library. Right-click to re-import props that are already in the Prop Library."

	Group "About" (
		Label lblVersion "Version 1.8"
		Hyperlink helplink "SMD/QC Importer Help" address:"http://dev.wallworm.com/document/121/smd_and_qc_importer.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	)

	function setchkSkipRootEnable = (
		chkSkipRoot.enabled = chkRecurse.checked
	)

	function storeDefaults = (
		local config = "$userScripts/WallWorm.com/config/wwmt.ini"
		setINISetting config "SMDImporter" "weldVerts" (chkWeldVerts.checked as String)
		setINISetting config "SMDImporter" "QuadrifyAll" (chkQuadrifyAll.checked as String)
		setINISetting config "SMDImporter" "ZeroRotations" (chkZeroRotations.checked as String)
		setINISetting config "SMDImporter" "XForm" (chkXForm.checked as String)
		setINISetting config "SMDImporter" "Static" (chkStatic.checked as String)
		setINISetting config "SMDImporter" "UniqueNames" (chkUniqueNames.checked as String)
		setINISetting config "SMDImporter" "DeepMatSearch" (chkDeepMatSearch.checked as String)
		setINISetting config "SMDImporter" "Rotate" (chkRotate.checked as String)
		setINISetting config "SMDImporter" "RemoveUnweightedBones" (chkRemoveUnweightedBones.checked as String)
		setINISetting config "SMDImporter" "ScaleMesh" (chkScaleMesh.checked as String)
		setINISetting config "SMDImporter" "skipLODS" (chkskipLODS.checked as String)
		setINISetting config "SMDImporter" "YUpVal" (chkYUp.checked as String)
		setINISetting config "SMDImporter" "SaveToPropLibrary" (chkSave.checked as String)
		setINISetting config "SMDImporter" "SingleMesh" (chkSingelMesh.checked as String)
		setINISetting config "SMDImporter" "Recurse" (chkRecurse.checked as String)
		setINISetting config "SMDImporter" "SkipRoot" (chkSkipRoot.checked as String)
		setINISetting config "SMDImporter" "Delete" (chkDelete.checked as String)
		setINISetting config "SMDImporter" "autoQuadrifyStaticpropchecked" (chkautoQuadrifyStaticprop.checked as String)
	)
	function getDefaults = (
		local config = "$userScripts/WallWorm.com/config/wwmt.ini"
		chkYUpVal = execute (getINISetting config "SMDImporter" "YUpVal")
		chkWeldVertsVal = execute (getINISetting config "SMDImporter" "weldVerts")
		chkQuadrifyAllVal = execute (getINISetting config "SMDImporter" "QuadrifyAll")
		chkZeroRotationsVal = execute (getINISetting config "SMDImporter" "ZeroRotations")
		chkXFormVal = execute (getINISetting config "SMDImporter" "XForm")
		chkStaticVal = execute (getINISetting config "SMDImporter" "Static")
		chkUniqueNamesVal = execute (getINISetting config "SMDImporter" "UniqueNames")
		chkDeepMatSearchVal = execute (getINISetting config "SMDImporter" "DeepMatSearch")
		chkRotateVal = execute (getINISetting config "SMDImporter" "Rotate")
		chkRemoveUnweightedBonesVal = execute (getINISetting config "SMDImporter" "RemoveUnweightedBones")

		chkScaleMeshVal = execute (getINISetting config "SMDImporter" "ScaleMesh")
		chkskipLODSVal = execute (getINISetting config "SMDImporter" "skipLODS")

		chkSave.checked = (::wallworm_getINISettingWithDefault "SMDImporter" "SaveToPropLibrary" false) as BooleanClass
		chkSingleMeshVal = execute (getINISetting config "SMDImporter" "SingleMesh")
		chkautoQuadrifyStaticpropcheckedVal = (::wallworm_getINISettingWithDefault "SMDImporter" "autoQuadrifyStaticpropchecked" true) as BooleanClass
		if chkautoQuadrifyStaticpropcheckedVal == true OR chkautoQuadrifyStaticpropcheckedVal == false then (
			chkautoQuadrifyStaticprop.checked = chkautoQuadrifyStaticpropcheckedVal
		)
		if chkSingleMeshVal != "" AND chkSingleMeshVal != OK then (
			chkSingelMesh.checked = chkSingleMeshVal
		)

		if chkRotateVal != "" AND chkRotateVal != OK then (
			chkRotate.checked = chkRotateVal
		)
		if chkRemoveUnweightedBonesVal != "" AND chkRemoveUnweightedBonesVal != OK then (
			chkRemoveUnweightedBones.checked = chkRemoveUnweightedBonesVal
		)

		if chkYUpVal != "" AND chkYUpVal != OK then (
			chkYUp.checked = chkYUpVal
		)

		if chkWeldVertsVal != "" AND chkWeldVertsVal != OK then (
			chkWeldVerts.checked = chkWeldVertsVal
		)
		if chkQuadrifyAllVal != "" AND chkQuadrifyAllVal != OK then (
			chkQuadrifyAll.checked = chkQuadrifyAllVal
		)
		if chkZeroRotationsVal != "" AND chkZeroRotationsVal != OK then (
			chkZeroRotations.checked = chkZeroRotationsVal
		)
		if chkXFormVal != "" AND chkXFormVal != OK then (
			chkXForm.checked = chkXFormVal
		)
		if chkStaticVal != "" AND chkStaticVal != OK then (
			chkStatic.checked = chkStaticVal
		)
		if chkUniqueNamesVal != "" AND chkUniqueNamesVal != OK then (
			chkUniqueNames.checked = chkUniqueNamesVal
		)
		if chkDeepMatSearchVal != "" AND chkDeepMatSearchVal != OK then (
			chkDeepMatSearch.checked = chkDeepMatSearchVal
		)

		if chkScaleMeshVal != "" AND chkScaleMeshVal != OK then (
			chkScaleMesh.checked = chkScaleMeshVal
		)
		if chkskipLODSVal != "" AND chkskipLODSVal != OK then (
			chkskipLODS.checked = chkskipLODSVal
		)

		
		

		chkRecurse.checked = (::wallworm_getINISettingWithDefault "SMDImporter" "Recurse" false) as BooleanClass
		chkSkipRoot.checked = (::wallworm_getINISettingWithDefault "SMDImporter" "SkipRoot" false) as BooleanClass
		chkDelete.checked = (::wallworm_getINISettingWithDefault "SMDImporter" "Delete" false) as BooleanClass

		setchkSkipRootEnable()

	)

	on chkRecurse changed stat do (
		storeDefaults()
		setchkSkipRootEnable()
	)
	on chkSkipRoot changed stat do (storeDefaults())
	on chkDelete changed stat do (storeDefaults())
	on chkAnimatedModel changed stat do (storeDefaults())
	on chkRotate changed stat do (storeDefaults())
	on chkRemoveUnweightedBones changed stat do (storeDefaults())
	on chkWeldVerts changed stat do (storeDefaults())

	on chkQuadrifyAll changed stat do (storeDefaults())
	on chkZeroRotations changed stat do (storeDefaults())
	on chkXForm changed stat do (storeDefaults())
	on chkStatic changed stat do (storeDefaults())
	on chkUniqueNames changed stat do (storeDefaults())
	on chkDeepMatSearch changed stat do (storeDefaults())

	on chkskipLODS changed stat do (storeDefaults())
	on chkScaleMesh changed stat do (storeDefaults())
	on chkYUp changed stat do (storeDefaults())

	on chkSingelMesh changed stat do (storeDefaults())

	function changeANimState stat = (
		if stat == true then (
			chkWeldVerts.checked = false
			chkWeldVerts.enabled = false
			/*chkConvertToPoly.checked = false
			chkConvertToPoly.enabled = false*/
			chkQuadrifyAll.checked = false
			chkQuadrifyAll.enabled = false
			chkZeroRotations.checked = false
			chkZeroRotations.enabled = false
			chkXForm.checked = false
			chkXForm.enabled = false
			chkStatic.checked = false
			chkStatic.enabled = false
			chkUniqueNames.checked = false
			chkUniqueNames.enabled = false

		) else (
			chkWeldVerts.enabled = true
			--chkConvertToPoly.enabled = true
			chkQuadrifyAll.enabled = true
			chkZeroRotations.enabled = true
			chkXForm.enabled = true
			chkStatic.enabled = true
			chkUniqueNames.enabled = true
		)

	)

	on chkAnimatedModel changed stat do (
		changeANimState stat
		storeDefaults()
	)

	on wallWormSMDImporter open do (
		getDefaults()

		--changeANimState chkAnimatedModel.checked

	)

	function processMesh msh makeWWMT:false forceWeld:false = (
		if msh != undefined then (
			if forceWeld OR chkWeldVerts.checked == true then (
				if classOf msh == Editable_Poly then (
					msh.weldThreshold = 0.1
					polyop.weldVertsByThreshold msh #{1..msh.numverts}
				)
			)
			if chkQuadrifyAll.checked == true AND PolyToolsModeling != undefined then (
				select msh
				PolyToolsModeling.Quadrify false false
			)

			if chkQuadrifyAll.checked == true AND PolyToolsModeling == undefined then (
				local qm = Quadify_Mesh()
				qm.quadsize = 10
				addModifier msh qm
			)
		)
	)

	function runQCImporton fsource = (
		if ::wallworm_EULA != true then (
			messageBox "The Wall Worm EULA has not been agreed to."
			fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
			undefined
		) else (
			local wwmt = wallworm_parse_qc fsource removeUnweightedBonesFromSkin:chkRemoveUnweightedBones.checked autoQuadrifyStaticprop:chkautoQuadrifyStaticprop.checked condenseMesh:chkSingelMesh.checked YUp:chkYUp.checked skipLODS:chkskipLODS.checked deepSearchMaterials:chkDeepMatSearch.checked scaleMesh:chkScaleMesh.checked extraSequences:edtExtraSMDPath.text
			if wwmt != undefined then (
				if chkSave.checked then (
					wwmt.saveProxy quiet:true all:true
				)
				if isValidNode wwmt.target AND chkNoVMF.checked then (
					wwmt.target.exclude_vmf = true
				)
			)
			wwmt
		)
	)

	on batchImportFromPath pressed do (
		if ::wallworm_EULA != true then (
			messageBox "The Wall Worm EULA has not been agreed to."
			fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
			false
		) else (
			if chkSave.checked == false AND chkDelete.checked == true then (
				messageBox "When using the Delete After Import function, you need to turn on the Save to Prop Library option."
			) else (
				local runImp = true
				if chkDelete.checked == true AND objects.count > 0 then (
					runImp = queryBox "When using the delete setting, all objects are deleted after each model imported. Since there are already objects in the scene, you must confirm this action.\n\nIf you want to keep these objects, press No and save your scene or remove the Delete setting."
				)
				if runImp then (
					p = getSavePath caption:"Choose Model Root with QCs and SMDs" historyCategory:"Wall Worm SMD Importer" initialDir:(::wwmt_export)
					local mdlqclist

					if ::wallwormFileOps == undefined then (
						if (::wallworm_installation_path == undefined) then (
							::wallworm_installation_path = (symbolicPaths.getPathValue "$scripts")
						)
						fileIn (::wallworm_installation_path + "/WallWorm.com/common/filesystem_funcs.ms")
					)
					if p != undefined then (
						wwmt_getFilesRecursive = ::wallwormFileOps.getFilesRecursive
						mdlqclist = wwmt_getFilesRecursive p edtFolders.text edtFiles.text recurse:chkRecurse.checked extension:".qc"
						undo off (
							if mdlqclist.count > 0 then (
								for fsource in mdlqclist do (
									if chkSkipRoot.checked == false OR NOT pathConfig.pathsResolveEquivalent p (getFilenamePath fsource) then (
										local wwmt = runQCImporton fsource
										if chkDelete.checked then (
											delete objects
											--wwmt.deleteWWMT deleteLODMeshes:true deleteHulls:true deleteTargets:true
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)

	on btnImportSMD pressed do with undo label:"Import Model" on (
		if ::wallworm_EULA != true then (
			messageBox "The Wall Worm EULA has not been agreed to."
			fileIn (::wallworm_installation_path + "/WallWorm.com/install.ms")
			false
		) else (
			local fsource = GetOpenFileName historyCategory:"Wall Worm SMD Exporter" caption:"SMD File Importer" types: "QC File (*.qc)|*.QC|Studio Model Data (*.smd)|*.SMD|VTAFile (*.vta)|*.VTA|All files (*.*)|*.*|"

			if (fsource != undefined) AND ((doesFileExist fsource) == true) then (
				local fileType = toLower (getFileNameType fsource)
				if fileType != ".qc" then (
					if chkAnimatedModel.checked then (timeOffset = sliderTime) else (timeOffset = 0)

					local vtanode = undefined
					local doImport = true
					if fileType == ".vta" AND chkVTASelectedMesh.checked then (
						if selection.count == 1 AND superClassOf selection[1] == GeometryClass then (
							vtanode = selection[1]
						) else (
							messageBox "When importing a VTA to an existing mesh, you can only select one mesh at a time."
						)
					)
					if doImport then (
						if timeOffset == undefined then (
							timeOffset = 0
						)
						res = (wallworm_import_smd fsource vtanode:vtanode removeUnweightedBonesFromSkin:chkRemoveUnweightedBones.checked materialp:edtMaterialp.text condenseMesh:chkSingelMesh.checked rotateModel:chkRotate.checked YUp:chkYUp.checked deepSearchMaterials:chkDeepMatSearch.checked zeroRotations:chkZeroRotations.checked staticprop:chkStatic.checked autoQuadrifyStaticprop:chkautoQuadrifyStaticprop.checked xf:chkXForm.checked uniqueNames:chkUniqueNames.checked timeOffset:timeOffset isSequence:(chkAnimatedModel.checked) addToTimeline:(chkAnimatedModel.checked))
						mshes = res[1]
						if mshes.count > 0 then (
							if chkCreateWWMT.checked == true then (
								tempWWMT = ww_LOD_wrapper()
								tempWWMT.init()
								tempWWMT.setTargetModel mshes[1] tempWWMT

								for msh in mshes do (
									processMesh msh
									if msh != mshes[1] then (
										tempWWMT.addObjToObjects msh
									)
								)
							)
						) else (
							print "Sequence Imported but not added to wwmt due to an unknown problem."
						)
						wallworm_smd_import_time = undefined
					)
				) else (
					runQCImporton fsource
				)
			)
		)
	)
	on btnPropLibrary pressed do
	(
		if objects.count == 0 OR (queryBox "There are objects in the scene. Do you really want to do this?" title:"Importing Props Query") == true then (
			fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF" historyCategory:"Wall Worm VMF" caption:"Import Prop Library From VMF File"
			if fsource != undefined then (
				if ::wallworm_getMDLsFromVMF == undefined then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/importModelsForProps.ms")
				)
				::wallworm_getMDLsFromVMF fsource deleteAll:false remake:false
			)
		)
	)
	on btnPropLibrary rightClick do
	(
		if objects.count == 0 OR (queryBox "There are objects in the scene. Do you really want to do this?" title:"Importing Props Query") == true then (
			fsource = GetOpenFileName types: "Valve Map File (*.vmf)|*.VMF" historyCategory:"Wall Worm VMF" caption:"Import Prop Library From VMF File"
			if fsource != undefined then (
				if ::wallworm_getMDLsFromVMF == undefined then (
					fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormUtilities/importModelsForProps.ms")
				)
				::wallworm_getMDLsFromVMF fsource deleteAll:false remake:true
			)
		)
	)
)
