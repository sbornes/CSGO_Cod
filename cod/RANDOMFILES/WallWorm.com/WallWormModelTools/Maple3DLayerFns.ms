--Functions written by Michael Little from Maple3D.com

-- Some functions i wrote that might be useful to you :)
function ww_SetObjLayer obj Lay forceFunc:false = (-- Lay is name of layer, if layer of that name does not exist then it is created.
	if (forceFunc == true OR ::wwmt_createLayers == true) then (
		local Ly = (LayerManager.getLayerFromName Lay)
		if Ly != undefined then (Ly.addNode obj) else
		(
			Ly = LayerManager.newLayer()
			Ly.setName Lay
			Ly.addNode obj
		)
	)
)

function ww_CreateLayer Lay forceFunc:false = (-- Creates a Layer of the name Lay if it does not already exist.
	if (forceFunc == true OR ::wwmt_createLayers == true) then (
		local Ly = (LayerManager.getLayerFromName Lay)
		if Ly != undefined then (Ly) else
		(
			Ly = LayerManager.newLayer()
			Ly.setName Lay
		)
	)
	Ly
)
