function wallworm_cap_borders nodes = (
	for nd in nodes WHERE classOf nd == Editable_Poly do (
		nd.capHoles #object
	)
)

wallworm_cap_borders selection