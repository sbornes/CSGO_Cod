if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/matfuncs1.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")

function wallworm_give_selected_material_ww mat = (
	case (classOf mat) of (
		Standard:(
			::wallworm_give_mat_ww mat
		)
		Blend:(
			::wallworm_give_mat_ww mat
		)
		default:(
			if (::WallWormProSMD != undefined) AND superClassOf mat == TextureMap then (
				::wallworm_update_texture_ca mat
			)
		)
	)
)

function wallworm_give_selected_materials_ww = (
	local mtlArr = #()
	v = sme.activeView
	if v > 0 then (
		view = sme.GetView v
		numNodes = view.GetNumNodes()
		if numNodes > 0 then (
			for n = 1 to numNodes do (
				nd = view.GetNode n
				if (nd != undefined AND (isProperty nd #selected AND (nd.selected == undefined OR nd.selected == true))) then (
					ref = trackViewNodes[#sme][v][n].reference

					case (classOf ref) of (
						Standard:(
							append mtlArr ref
						)
						Blend:(
							append mtlArr ref
						)
						default:(
							if (::WallWormProSMD != undefined) AND superClassOf ref == TextureMap then (
								append mtlArr ref
							) else (
								format "% > % > % \n" n nd ref
							)
						)
					)
				)
			)
		)
	)
	if (mtlArr.count) != 0 then
	(
		for mat in mtlArr do (
			::wallworm_give_selected_material_ww mat
		)
		mtlArr
	) else (
		false
	)

)

mat = undefined
if ::sme != undefined then (
	if wallworm_give_selected_materials_ww() == false then (
		mat = sme.GetMtlInParamEditor()
		if mat != undefined then (
			::wallworm_give_selected_material_ww mat
		)
	)
)
if mat == undefined then (
	mat = medit.GetCurMtl()

	if mat != undefined then (
		::wallworm_give_selected_material_ww mat
	)
)
