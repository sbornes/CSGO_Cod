function wallworm_gcd a b = (
    if (a < 0) then  a = -a
    if (b < 0) then b = -b
    if (b > a) then (
		local temp = a
		a = b
		b = temp
	)
	local out = undefined
    while (out == undefined) do (
        if (b == 0) then (
			out = a
		) else (
			a = mod a b
			if (a == 0) then ( 
				out = b 
			) else (
				b = mod b a	
			)
		)
    )
	out
)

fn GW_displayVertsOffGrid =
(
  unregisterRedrawViewsCallback GW_displaySelectedVertsOffGrid
  gw.setTransform (matrix3 1)
  local gv = meshop.getVert
  for theNode in objects where not theNode.isHiddenInVpt do
	case (superClassOf theNode) of (
		GeometryClass:(
			local m = theNode.Mesh
			for vi = 1 to m.numverts do
			(
				in coordsys world v = gv m vi node:theNode
				if (mod v.x 1.0 != 0.0) OR (mod v.y 1.0 != 0.0) OR (mod v.z 1.0 != 0.0) then (
					gw.text v (vi as string + ": "+v as string) color:yellow
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
						gw.text v (k1 as string + ": "+v as string) color:yellow
					)
				)
			)
		)
		default:()
	)
  gw.enlargeUpdateRect #whole  
)