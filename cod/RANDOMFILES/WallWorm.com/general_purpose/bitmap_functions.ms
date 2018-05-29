function wallworm_make_icon_from_vector_map vm dimensions:#(16) makeInactive:true pages:16 = (
	for d in dimensions do (
		local pageWidth = d
		local pageHeight = d
		if pageHeight == 16 then (
			pageHeight = 15
		)
		tmpBitmap = Bitmap (pageWidth * pages) pageHeight color:white hdr:true gamma:1.2
		cp = copy vm
		for p = 1 to pages do (
			case (classOf cp) of (
				Vector_Map:(cp.pdf_page = p)
				BitmapTexture:(cp.starttime = (p - 1) * -1)
			)

			local tmp = Bitmap pageWidth pageHeight
			local thisPosition = ((p * pageWidth) - pageWidth)
			renderMap cp into:tmp size:[pageWidth, pageHeight] filter:true
			for r = 0 to pageHeight do (
				px = getPixels tmp [0, r] pageWidth
				setPixels tmpBitmap [thisPosition, r] px
			)
		)
		display tmpBitmap
	)
)

function wallworm_load_icon_rollout = (
	if ::wallworm_icon_rollout == undefined then (
		::wallworm_icon_rollout = rollout wallworm_icon_rollout "Save Vector Map to Icons" (
			MapButton mpVectorMap "Vector Map" tooltip:"Select a Vector Map"
			EditText edtIconName "Icon Name" text:"myicons"
			Group "Sizes" (
				CheckBox chk16 "16" align:#left across:2 checked:true
				CheckBox chk64 "64" align:#left
				CheckBox chk24 "24" align:#left across:2 checked:true
				CheckBox chk96 "96" align:#left
				CheckBox chk32 "32" align:#left across:2 checked:true
				CheckBox chk128 "128" align:#left
				CheckBox chk48 "48" align:#left across:2
				CheckBox chk256 "256" align:#left
			)
			CheckBox chkDisabled "Include Desaturated (Disabled) images"
			Button btnSave "Render and Save"
			on btnSave pressed do (
				if classOf mpVectorMap.map != Vector_map then (
					messageBox "This function only works with Vector Maps."
				) else (
					if edtIconName.text == "" then (
						messageBox "You need to assign a name for the icons."
					) else (
						local outArray = #()
						if chk256.checked then (
							append outArray 256
						)
						if chk128.checked then (
							append outArray 128
						)
						if chk96.checked then (
							append outArray 96
						)
						if chk64.checked then (
							append outArray 64
						)
						if chk48.checked then (
							append outArray 48
						)
						if chk32.checked then (
							append outArray 32
						)
						if chk24.checked then (
							append outArray 24
						)
						if chk16.checked then (
							append outArray 16
						)

						if outArray.count == 0 then (
							messageBox "You need to check at least one image size."
						) else (
							wallworm_make_icon_from_vector_map mpVectorMap.map dimensions:outArray makeInactive:chkDisabled.checked
						)
					)
				)
			)
		)
	)
	try (destroyDialog ::wallworm_icon_rollout) catch ()
	createDialog ::wallworm_icon_rollout

)