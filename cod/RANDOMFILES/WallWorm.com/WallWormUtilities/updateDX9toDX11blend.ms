/*
This script will convert displacement materials that use the DX9 format to DX11.

Run this script when opening a level where the displacements were created in older
versions of 3ds Max and Wall Worm.

This script should only be used with 3ds Max 2014+.

Written by Shawn Olson
http://www.shawnolson.net

For use in Wall Worm
http://dev.wallworm.com
*/
if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

disps = for disp in objects WHERE (getUserProp disp #ww_wwdt_displacement_brush != undefined) collect disp

for disp in disps do (
	/*Must only find DX9 mats that have a blend material because the DX11 readers cannot access the maps in the DX9 shader files... so get from the Blend materials. Assumes the blend mats have materials with diffuse bitmaps... consider changing.*/
	if disp.mat != undefined AND classOf disp.mat == DirectX_9_Shader AND disp.mat.renderMaterial != undefined then (
		if getFileNameFile disp.mat.effectfile == "blend_dxsas" then (
			local renderMat = disp.mat.rendermaterial
			local m1
			local m2
			case (classOf renderMat) of (
				Blend: (
					m1 = renderMat.map1.diffusemap.Bitmap
					m2 = renderMat.map2.diffusemap.Bitmap
				)
				Standard:(
					if renderMat.diffuseMap != undefined AND classOf renderMat.diffuseMap == BitmapTexture then (
						m1 = renderMat.diffuseMap.Bitmap
					)
				)
				default:(
				)
			)

			disp.mat.effectFilename = ::wallworm_installation_path + "/WallWorm.com/WallWormSimpleDisplacement/maps/fx/blend_dxsas11_nitrous.fx"
			disp.mat.reloadeffect()

			if m1 != undefined then (
				disp.mat.TextureTop = m1
			)
			if m2 != undefined then (
				disp.mat.TextureBottom = m2
			)
			disp.mat.reloadeffect()

		) else (
			--print "wrong name"
		)

	)

)