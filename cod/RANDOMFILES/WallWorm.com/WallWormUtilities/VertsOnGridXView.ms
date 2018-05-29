(
	global WallWormVertsOnGridXView
	struct WallWormVertsOnGridXViewStruct

	(
		ongrid = false,
		WallWormVertsOnGridXViewDialog = undefined,
		gv = meshop.getVert,
		function geomCheck theTime theNode theResults =
		(
			case (superClassOf theNode) of (
				GeometryClass:(
					local m = theNode.Mesh
					for vi = 1 to m.numverts do
					(
						in coordsys world v = gv m vi node:theNode
						if (mod v.x 1.0 != 0.0) OR (mod v.y 1.0 != 0.0) OR (mod v.z 1.0 != 0.0) then (
							append theResults vi
						)
					)					
				)
				Shape:(
					local k1 = 0
					local s = numSplines theNode
					for si = 1 to s do (
						local kCount = numKnots theNode si
						for k = 1 to kCount do (
							k1 += 1
							local v = in coordsys world (getKnotPoint theNode si k) 
							if mod v.x 1.0 != 0.0 OR mod v.y 1.0 != 0.0 OR mod v.z 1.0 != 0.0 then (
								append theResults k1
							)
						)
					)
				)
			)
			1
		),

		function supportedCheck theNode =
		(
			((superClassOf theNode == GeometryClass) OR classof theNode == Line)
		)

	)--end struct

	WallWormVertsOnGridXView = WallWormVertsOnGridXViewStruct()

	try (
		XViewChecker.unRegisterChecker "Verts Off Grid"
		XViewChecker.registerChecker WallWormVertsOnGridXView.geomCheck WallWormVertsOnGridXView.supportedCheck #Vertices "Verts Off Grid" undefined undefined undefined
	) catch (
		--messagebox "Your version of Max may not Support xView. This function works in Max 2010+."
	)

)--end script

