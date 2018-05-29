function rotateRandom obj x:false y:false z:true = (
	if x then (
		in coordsys local rotate obj (AngleAxis (random (-360) 360) [1, 0, 0])
	)

	if y then (
		in coordsys local rotate obj (AngleAxis (random (-360) 360) [0, 1, 0])
	)

	if z then (
		in coordsys local rotate obj (AngleAxis (random (-360) 360) [0, 0, 1])
	)

)

function rotateObjsRandom objs x:false y:false z:true = (
	for obj in objs do (
		rotateRandom obj x:x y:y z:z
	)
)