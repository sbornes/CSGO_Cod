function wallworm_cloneToLowPoly objs vertexCount:200 pushAmount:-0.2 addParent:false projPush:1 = (
	local res = #()
	for obj in objs do (
		local cp = copy obj
		cp.name = (obj.name + "_LP")
		local psh = Push()
		psh.Push_Value = pushAmount
		addModifier cp psh

		local mr = MultiRes ()
		mr.vertexCount = vertexCount
		addModifier cp mr
		mr.reqGenerate = off

		select cp
		max modify mode
		mr.reqGenerate = on

		max create mode

		local proj = Projection()

		addModifier cp proj
		proj.addObjectNode obj
		proj.pushCage projPush

		if addParent then (
			cp.parent = obj
		)
		append res cp
	)
	res
)

wallworm_cloneToLowPoly (selection as Array)