function wallworm_get_matrix_from_pts A B = (
	local coordSysTM = inverse (getViewTM())
	local XUnorm = B - A
	local X = normalize (XUnorm)
	local viewportDir = -coordSysTM.row3
	local Z = normalize (cross viewportDir X)
	local Y = normalize (cross X Z)
	Matrix3 X Y Z (-[dot coordSysTM.row2 A, dot coordSysTM.row1 A, 0])
)

function wallworm_pick_x_axis = (
	local sn
	local IsPerspView = viewport.IsPerspView
	if IsPerspView() then (
		sn = #3D
	) else (
		sn = #2D
	)
	A = pickPoint prompt:"\nPick Point A." snap:sn
	if A != undefined then (
		B = pickPoint prompt:"\nPick Point B." snap:sn rubberBand:A

		if B != undefined then (
			wallworm_get_matrix_from_pts A B
		) else (
			false
		)
	) else (
		false
	)

)

function wallworm_align_slice_plane = (
	max modify mode

	sl = modPanel.getCurrentObject()

	if sl == undefined OR (classOf sl != SliceModifier AND (selection.count > 0 AND validModifier selection SliceModifier)) then (
		sl = SliceModifier()
		addModifier selection sl
		modPanel.setCurrentObject sl
	)

	if classOf sl == SliceModifier then (
		local start = sl.sliceplane.transform
		matrix = wallworm_pick_x_axis()
		if matrix != false then (
			--objTrans =  selection[1].transform
			--matrix.row4 = objTrans.translationPart
			--matrix.row4 = matrix.row4 - start.row4
			sl.slice_plane.transform = matrix

		)
	)

)

clearListener()

b = Box lengthsegs:1 widthsegs:1 heightsegs:1 width:256 length:256 height:256 mapcoords:on isSelected:true

wallworm_align_slice_plane()
