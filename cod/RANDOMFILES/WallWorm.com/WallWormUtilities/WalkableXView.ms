(
	global WWDTFaceWalkableChecker

	struct WWDTFaceWalkableCheckerStruct

	(
		WWDTFaceWalkableThresholdMax = 30,
		WWDTFaceWalkableDialog = undefined,
		function geomCheck theTime theNode theResults =
		(
			local m = theNode.Mesh
			for f = 1 to m.numfaces do
			(
				in coordsys world gfn = getFaceNormal m f
				if gfn.z <= cos(45) then (
					append theResults f
				)
			)
			3
		),

		function supportedCheck theNode =
		(
			superClassOf theNode == GeometryClass
		)

	)--end struct

	WWDTFaceWalkableChecker = WWDTFaceWalkableCheckerStruct()

	try (
		XViewChecker.unRegisterChecker "WW Face Walkable"

		XViewChecker.registerChecker WWDTFaceWalkableChecker.geomCheck WWDTFaceWalkableChecker.supportedCheck #Faces "WW Face Walkable" undefined undefined undefined
	) catch (
		--messagebox "Your version of Max may not Support xView. This function works in Max 2010+."
	)

)--end script
