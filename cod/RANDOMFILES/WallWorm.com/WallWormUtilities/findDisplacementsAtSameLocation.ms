clearListener()
uniquePos = #()

duplicateGeom = #()

for obj in objects WHERE (getUserProp obj #ww_wwdt_displacement_target) != undefined do (
	if findItem uniquePos obj.pos == 0 then (
		appendIfUnique uniquePos obj.pos

	) else (
		append duplicateGeom obj
	)

)

if duplicateGeom.count > 0 then (
	messageBox ((duplicateGeom.count as String) + " Duplicate Displacement Positions found")

)

select duplicateGeom