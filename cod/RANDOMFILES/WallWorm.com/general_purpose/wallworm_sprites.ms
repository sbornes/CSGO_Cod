/*
Wall Worm Sprite Tool

Copyright (C) 2013-2015 by Shawn Olson
All Rights Reserved
http://www.shawnolson.net

Included in Wall Worm
http://dev.wallworm.com

This script will let you do multiple things:

* Convert sprite cards into Animated Sprite Textures
* Convert Image File Lists (IFLs) into sprite cards
* Convert Animated Textures into IFLs
* Create Sprite Billboards that all use the same look at target

Version History:

1.0

* Initial Release

1.1  Released on 11-20-2013

* Added support for alpha channel in Make Sprite Sheet function.

1.2  Released on 11-29-2013

* Added support for Wall Worm Detail Prop objects.

1.3 Released 07-16-2015

* Added checkbox to force cell width.

* Added support to use texture image with if checkbox is not checked.

* Added button "Selection To Sprite Card" to convert selected objects' materials into a sprite card.

Full documentation at http://www.shawnolson.net/a/1823/sprite_tools.html

*/

global wallwormSpriteTex

try (destroyDialog wallwormSpriteTex) catch ()

global wallworm_sprites_lookat_controller -- for old plane objected
global wallworm_sprites_lookat_target
global wallworm_current_sprite_material
global wallworm_current_sprite_map
global wallworm_last_ifl
global wallworm_last_spritesheet

rollout wallwormSpriteTex "Wall Worm Sprite Tool 1.3" width:275 height:545
(
	local placeSpriteAtPoint

	mapButton ChooseMap "Choose Map" pos:[141,89] width:99 height:43
	spinner spnRows "Rows" pos:[38,91] width:97 height:16 range:[1,1024,2] type:#integer scale:1 toolTip:"Set the number of rows that are in the sprite card."
	spinner spnColumns "Columns" pos:[38,116] width:97 height:16 range:[1,1024,2] type:#integer scale:1 toolTip:"Set the number of columns that are in the sprite card."
	button btnCreateSprite "Create Sprite" pos:[13,253] width:117 height:39 toolTip:"Create a Sprite Plane in the scene."
	materialButton btnGetMat "Get Existing Sprite Materials" pos:[14,11] width:177 height:43 toolTip:"Select a pre-existing material to apply to new sprites."
	button animateMap "Animate Sprite Map" pos:[28,142] width:212 height:25 toolTip:"Generate an animated sprite map based off of a sprite card bitmap."
	GroupBox grpImport "Import/Export Sprite Card" pos:[13,66] width:244 height:181
	checkbox chkForceDimension "Force Cell Dimension" pos:[28,171] width:117 height:16 toolTip:"Force the cells to be the dimension below. When off, some functions create images based on the size of the bitmaps."
	spinner spnCell "Cell Dimension" pos:[66,190] width:70 height:16 range:[16,1024,128] type:#integer scale:1 toolTip:"The dimension used for cells in a sprite sheet or for images in an IFL. Also sets the dimension of new sprites."
	button btnGenerateCard "Make Sprite Sheet" pos:[147,188] width:93 height:19 toolTip:"Save the current animated sprite as a sprite card bitmap."
	button btnSelectSprites "Select Sprites in Scene" pos:[13,355] width:245 height:39 toolTip:"If no objects selected, selects all sprites in the scene; if there is a current selection, filters that selection to just sprites."
	button btnGetLookAt "Get Sprite Look At Target" pos:[13,401] width:245 height:39 toolTip:"Select the Look At target. If none exist, creates it first then selects it."
	button resetSpriteTarget "Reset All Sprites to Use Look At" pos:[13,446] width:245 height:39 toolTip:"This will set all sprites in the scene to use the Sprite Look At Target. Useful if you inadvertantly deleted the look at helper."
	button btnMakeIFL "Make IFL From Sprite" pos:[30,216] width:121 height:25 toolTip:"Generate an Image File List for the current Sprite Map. Each image will have a height/width equal to the Cell Dimension spinner."
	button btnAssignIFL "Assign IFL" pos:[156,216] width:83 height:25 toolTip:"Make a new Material with the last generated IFL and set it as the current Sprite Material for new sprites."
	bitmap bmpCurrent "Bitmap" pos:[197,12] width:58 height:43
	HyperLink hyperLinkShawn "Shawn Olson" pos:[14,494] width:102 height:16 address:"http://www.shawnolson.net" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	HyperLink hyperlinkWW "Wall Worm" pos:[179,494] width:79 height:16 address:"http://dev.wallworm.com" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	button btnDropSprite "Place Sprites" pos:[136,253] width:121 height:39 toolTip:"Start the tool to let you drop sprites at clicked points."
	HyperLink hyperLinkDetailer "Get Enhanced Functionality with Detailer" pos:[14,520] width:246 height:16 address:"http://dev.wallworm.com/topic/64/detailer.html" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	HyperLink hyperLinkShawn2 "Help" pos:[122,494] width:44 height:16 address:"http://www.shawnolson.net/a/1823/sprite_tools.html" color:(color 0 0 255) hovercolor:(color 255 0 0) visitedcolor:(color 0 0 255)
	button btnSelToIFL "Selection To Sprite Card" pos:[95,315] width:155 height:30 toolTip:"Render a Sprite Cart from all the selected objects' Materials. The objects then get the new material and UVW Xform to offset the IVs to keep the original texture appearance."
	spinner spnChannel "" pos:[29,328] width:55 height:16 range:[1,100,1] type:#integer scale:1
	label lbl1 "Channel" pos:[29,312] width:47 height:14
	groupBox grp2 "Scene" pos:[11,295] width:246 height:56

	function setBmpPreview = (
		if wallworm_current_sprite_map != undefined then (
			bmpCurrent.Bitmap = renderMap wallworm_current_sprite_map size:[58, 43]
		)
	)

	function getSprites useSelection:false selectResults:false = (
		local sprites = #()
		local theSel
		if selection.count > 0 AND useSelection == true then (
			theSel = selection as Array
		) else (
			theSel = objects as Array
		)

		local sprites = for sprite in theSel WHERE getUserProp sprite #wallworm_sprites != undefined collect sprite
		if sprites.count > 0 AND selectResults == true then (
			clearSelection()
			select sprites
		)

		sprites
	)
	function getLookAtControllerObj = (
		global wallworm_sprites_lookat_target
		wallworm_sprites_lookat_target = getNodeByName "wallworm_sprites_lookat_target"
		if wallworm_sprites_lookat_target == undefined then (
			wallworm_sprites_lookat_target = Point pos:[0, 0, 0] isSelected:on size:32 centermarker:on axistripod:off Box:on constantscreensize:on

			wallworm_sprites_lookat_target.name = "wallworm_sprites_lookat_target"
		)
		wallworm_sprites_lookat_target
	)
	function getLookAtController = (
		global wallworm_sprites_lookat_controller
		if wallworm_sprites_lookat_controller == undefined then (
			wallworm_sprites_lookat_controller = LookAt_Constraint()
			wallworm_sprites_lookat_controller.target_axis = 2
		)
		wallworm_sprites_lookat_controller.target_axis = 2
		wallworm_sprites_lookat_controller.upnode_axis = 2
		wallworm_sprites_lookat_controller.lookat_vector_length = 0
		wallworm_sprites_lookat_controller
	)

	function setSpriteLookAtController obj = (
		global wallworm_sprites_lookat_target
		wallworm_sprites_lookat_target = getLookAtControllerObj()

		global wallworm_sprites_lookat_controller
		wallworm_sprites_lookat_controller = getLookAtController()

		wallworm_sprites_lookat_controller.appendTarget wallworm_sprites_lookat_target 100
		obj.rotation.controller = wallworm_sprites_lookat_controller
	)

	function getSpriteMap = (
		global wallworm_current_sprite_map
		if wallworm_current_sprite_map == undefined then (
			wallworm_current_sprite_map = Checker()
			wallworm_current_sprite_map.name = uniqueName "Sprite Map"
		)
		wallworm_current_sprite_map
	)
	function getSpriteMaterial resetMat:false = (
		global wallworm_current_sprite_material
		if wallworm_current_sprite_material == undefined OR resetMat == true then (
			wallworm_current_sprite_material = Standard()
			wallworm_current_sprite_material.name = uniqueName "Sprite Material"
			wallworm_current_sprite_material.showInViewport = true
			getSpriteMap()
			global wallworm_current_sprite_map

			wallworm_current_sprite_material.diffuseMap = wallworm_current_sprite_map
			wallworm_current_sprite_material.opacityMap = wallworm_current_sprite_map

		)
		wallworm_current_sprite_material
	)

	function getDimensionsTex = (
		local width = height = spnCell.value
		try (
			if classOf wallworm_current_sprite_map == BitmapTexture AND wallworm_current_sprite_map.Bitmap != undefined AND chkForceDimension.checked == false then (
				width = wallworm_current_sprite_map.Bitmap.width
				height = wallworm_current_sprite_map.Bitmap.height
			)
		) catch()
		[width,height]
	)
	
	function placeSprite pos:undefined = (
		local sprite
		if WallWormDetailProp != undefined then (
			sprite = WallWormDetailProp()
			sprite.width = spnCell.value
			sprite.height = spnCell.value
			sprite.spritedetailorientation = 2
		) else (
			sprite = Plane lengthsegs:1 widthsegs:1 length:spnCell.value width:spnCell.value name:(uniqueName "sprite") mapCoords:true transform:(Matrix3 [1, 0, 0] [0, 0, 1] [0, -1, 0] [0, 0, 0])

			global wallworm_sprites_lookat_target
			wallworm_sprites_lookat_target = getLookAtControllerObj()

			global wallworm_sprites_lookat_controller
			wallworm_sprites_lookat_controller = getLookAtController ()
			setUserProp sprite #wallworm_sprites "true"

			setSpriteLookAtController sprite
		)

		if pos != undefined then (
			sprite.pos = pos
		)

		getSpriteMaterial()
		sprite.mat = wallworm_current_sprite_material

	)

	function placeSpriteAtPoint = (
		pt = pickPoint()
		if classOf pt == Point3 then (
			placeSprite pos:pt
		)
	)

	function renderSpriteCard filename:undefined skipAlpha:false = (
		if filename == undefined then (
			filename = getSaveFileName caption:"Save the Image" historyCategory:"Wall Worm Sprites" types:"Targa (*.tga)|*.tga|DDS (*.dds)|*.dds|PNG (*.png)|*.png|BMP (*.bmp)|*.bmp|JPEG (*.jpg)|*.jpg"
		)
		if filename != undefined then (
			startSliderTime = sliderTime
			
			local dim = getDimensionsTex()
			local width = dim.x
			height = dim.y

			local w = width * spnColumns.value
			local h = height * spnRows.value

			local f = (spnColumns.value * spnRows.value) - 1

			--color:black gamma:1.0

			local theNewMap = Bitmap w h --gamma:1.0 --hdr:true gamma:wallworm_current_sprite_map.bitmap.gamma

			posX = 0
			posY = 0
			

			
			for fr = 0 to f do (
				sliderTime = fr
				local piece, msk
				at time fr (
					piece = renderMap wallworm_current_sprite_map size:[width, height] filter:true
				)
				local cpmap = bitmap width height 
				copy ::wallworm_current_sprite_map.Bitmap cpmap
				
				
				for r = 0 to (height - 1) do (
					
					local pixColor = getPixels piece [0, r] width
					local pixAlpha = getPixels cpmap [0, r] width
					for i = 1 to pixColor.count do (
						if  pixAlpha[i] != undefined then (
							pixColor[i].alpha = pixAlpha[i].alpha
						)
					)

					setPixels theNewMap [posX, (posY + (r))] pixColor

				)

				posX += width

				if posX >= w then (
					posX = 0
					posY += height
				)

			)
			theNewMap.filename = filename
			save theNewMap
			display theNewMap

			global wallworm_last_spritesheet
			wallworm_last_spritesheet = theNewMap

			sliderTime = startSliderTime
			true
		) else (
			false
		)
	)

	function createSpriteCardFromObjects sel:selection = (
		::wallworm_current_sprite_map = undefined
		::wallworm_current_sprite_material  = undefined
		local sel = sel as Array
		sel = for obj in sel WHERE classOf obj.mat == Standard AND  obj.mat.diffuseMap != undefined collect obj
		struct matmap (
			mat,
			objs = #()
		)

		local objsArray = #()
		local firstTex = undefined
		for obj in sel do (
			local hasFound = false
			for m in objsArray while NOT hasFound do (
				if m.mat == obj.mat then (
					append m.objs obj
					hasFound = true
				)
			)
			if NOT hasFound then (
				local m = matmap()
				m.mat = obj.mat
				append m.objs obj
				append objsArray m
				if firstTex == undefined AND classof m.mat.diffusemap == bitmapTexture then (
					::wallworm_current_sprite_map = m.mat.diffusemap
				)
				
			)
		)
		if firstTex == undefined then (
			::wallworm_current_sprite_map = objsArray[1].mat.diffusemap
		)

		local dim = getDimensionsTex()
		local width = dim.x
		local height = dim.y
		
		local iflPath = pathConfig.convertPathToAbsolute ("$images/wallworm/sprites/ifl/")
		--create IFL file
		local canMake = objsArray.count > 0 AND doesFileExist iflPath
		if NOT canMake then (
			canMake = makeDir iflPath all:true
		)

		if canMake then (
			local iflName = iflPath + (timestamp() as String) + ".ifl"
			local iflFile = createFile iflName mode:"w+"
			if iflFile != undefined then (
				for m in objsArray do (
					local dmap = m.mat.diffusemap
					if classof dmap != BitmapTexture then (
						--render it out and save
						if ::wallworm_safe_bitmappath == undefined then (
							macros.run "wallworm.com" "WallWormInitialize"
						)
						
						local thisFileName = iflpath + (::wallworm_safe_bitmappath dmap.name)+".tga"
						local theNewMap = renderMap  dmap size:[width, height] filter:true
						theNewMap.filename = thisFileName
						save theNewMap
						close theNewMap
						format "%\r\n" thisFileName to:iflFile
					) else (
						format "%\r\n" m.mat.diffusemap.filename to:iflFile
					)
				)
				close iflFile
				local bm = openBitmap iflName
				::wallworm_current_sprite_map = BitmapTexture filename:iflName
				::wallworm_current_sprite_material = Standard()
				::wallworm_current_sprite_material.name = uniqueName "Sprite Material"
				::wallworm_current_sprite_material.showInViewport = true
				getSpriteMap()
				::wallworm_current_sprite_material.diffuseMap = ::wallworm_current_sprite_map
				::wallworm_current_sprite_material.opacityMap = ::wallworm_current_sprite_map

				if (renderSpriteCard filename:undefined skipAlpha:false) then (
					local cols = spnColumns.value
					local rows = spnRows.value

					local utile = 1.0 / cols
					local vtile = 1.0 / rows

					thisRow = 1
					thisCol = 1

					local newMaterial = Standard name:(uniqueName "CardSheet")
					newMaterial.showInViewport = true
					newMaterial.diffuseMap = newMaterial.opacityMap = bitmapTexture filename:(::wallworm_last_spritesheet.filename)
					newMaterial.diffuseMap.monoOutput = 1
					newMaterial.diffuseMap.coords.blur = 0.01
					newMaterial.diffuseMap.coords.mapChannel = spnChannel.value
					for m in objsArray do (
						local thisUOffset = utile * (thisCol - 1)
						local thisVOffset = vtile * (thisRow - 1) + 0.5
						local shellmat =  shell_material name:(uniqueName "CardSheet Shell")
						local thisMod = UVW_XForm()
						thisMod.name = "UV:"+(spnChannel.value as string)+":"+shellmat.name
						thisMod.u_tile = utile
						thisMod.v_tile = vtile
						thisMod.u_offset = thisUOffset
						thisMod.v_offset = thisVOffset
						thisMod.Map_Channel = spnChannel.value
						addModifier m.objs thisMod
						
						shellmat.bakedMaterial = newMaterial
						shellmat.originalMaterial = m.mat
						shellmat.viewportMtlIndex = 1
						m.objs.mat = shellmat
						thisCol += 1
						if thisCol > cols then (
							thisCol = 1
							thisRow += 1
						)
					)
				)
			)
			true
		) else (
			false
		)
	)


	on wallwormSpriteTex open do
	(
		global wallworm_current_sprite_material
		if wallworm_current_sprite_material == undefined then (
			local sprites = getSprites()
			if sprites.count > 0 then (
				for sprite in sprites while wallworm_current_sprite_material == undefined do (
					if sprite.mat != undefined then (
						wallworm_current_sprite_material = sprite.mat
					)
	
				)
	
			)
		)
	
		if wallworm_current_sprite_material == undefined then (
			wallworm_current_sprite_material = getSpriteMaterial()
		)
	
		if wallworm_current_sprite_material != undefined AND wallworm_current_sprite_map == undefined AND wallworm_current_sprite_material.diffusemap != undefined then (
			wallworm_current_sprite_map = wallworm_current_sprite_material.diffusemap
		)
	
		setBmpPreview()
	)
	on ChooseMap picked texmap do
	(
		global wallworm_current_sprite_map
		wallworm_current_sprite_map = texmap
	
		getSpriteMaterial resetMat:true
		setBmpPreview()
	)
	on btnCreateSprite pressed do
	(
		placeSprite()
	)
	on btnGetMat picked mtl do
	(
		wallworm_current_sprite_material = mtl
		global wallworm_current_sprite_map
		if wallworm_current_sprite_material.diffusemap != undefined then (
			wallworm_current_sprite_map = wallworm_current_sprite_material.diffusemap
		)
		setBmpPreview()
	)
	on animateMap pressed do
	(
		/*
		Creates an animated bitmaptexture where each cell of the sprite sheet becomes a frame in the bitmap animation.
		*/
		if wallworm_current_sprite_map != undefined then (
			local intangent, outtangent
			maxops.getDefaultTangentType &intangent &outtangent
	
			maxOps.setDefaultTangentType #step #step writeInCfgFile:false
	
			local u = 1.0 / (spnRows.value as Float)
			local v = 1.0 / (spnColumns.value as Float)
			local row = 1.0
			local column = 1.0
	
			local startCPos = ((spnColumns.value as Float) * 0.5) - 0.5
	
			local startC = startCPos
	
			local StartR = ((spnRows.value as Float) * 0.5) + 0.5
			global wallworm_current_sprite_map
			wallworm_current_sprite_map.coords.U_Tiling = 1.0 / (spnRows.value as Float)
			wallworm_current_sprite_map.coords.V_Tiling = 1.0 / (spnColumns.value as Float)
	
			local z = (spnRows.value * spnColumns.value)
			for ff = 1 to z do (
				local uoffset = (1.5 * column) + 0.5
				local voffset = (row) + 0.5
	
				f = ff - 1
				with animate on (
					at time f wallworm_current_sprite_map.coords.U_Offset = startC
					at time f wallworm_current_sprite_map.coords.V_Offset = StartR
				)
				column += 1
	
				startC -= 1.0
	
				if column > spnColumns.value then (
					column = 1
					row += 1
					StartR += 1.0
					startC = startCPos
				)
	
			)
	
			maxOps.setDefaultTangentType intangent outtangent writeInCfgFile:false
		) else (
			messageBox "You must first set a map for the sprite. Click the Choose Map button."
		)
	
	)
	on btnGenerateCard pressed do
	(
		if wallworm_current_sprite_map != undefined then (
			local filename = getSaveFileName caption:"Save the Image" historyCategory:"Wall Worm Sprites" types:"Targa (*.tga)|*.tga|DDS (*.dds)|*.dds|PNG (*.png)|*.png|BMP (*.bmp)|*.bmp|JPEG (*.jpg)|*.jpg"
			if NOT renderSpriteCard filename:filename then (
				--message?
			)
		) else (
			messageBox "Sorry... there is currently no sprite map assigned. Please choose a map with the Choose Map button."
		)
	
	)
	on btnSelectSprites pressed do
	(
		getSprites useSelection:true selectResults:true
	
	)
	on btnGetLookAt pressed do
	(
		select (getLookAtControllerObj())
	
	)
	on resetSpriteTarget pressed do
	(
		local sprites = for sprite in objects WHERE getUserProp sprite #wallworm_sprites != undefined collect sprite
		if sprites.count > 0 then (
			for sprite in sprites do (
				setSpriteLookAtController sprite
			)
		)
	)
	on btnMakeIFL pressed do
	(
		if wallworm_current_sprite_map != undefined then (
			local filename = getSaveFileName caption:"Save the Image" historyCategory:"Wall Worm Sprites" types:"Targa (*.tga)|*.tga|DDS (*.dds)|*.dds|PNG (*.png)|*.png|BMP (*.bmp)|*.bmp|JPEG (*.jpg)|*.jpg"
	
			if filename != undefined then (
				local w = spnCell.value
				local h = spnCell.value
				local f = (spnColumns.value * spnRows.value) - 1
				local rootname = getFileNameFile filename
				local newfpath = getFileNamePath filename
				local newftype = getFileNameType filename
	
				local iflname = newfpath + rootname + ".ifl"
				if doesFileExist iflname then (
					theIFL = openFile iflname mode:"w+"
				) else (
					theIFL = createFile iflname
				)
	
				for fr = 0 to f do (
					newffile = rootname + "0" + (fr as String) + newftype
					format (newffile + "\r\n") to:theIFL
					newf = newfpath + newffile
					local theNewMap = Bitmap w h numframes:f filename:newf
	
					at time fr renderMap wallworm_current_sprite_map into:theNewMap size:[w, h]
	
					save theNewMap
				)
				close theIFL
				global wallworm_last_ifl
				wallworm_last_ifl = iflname
	
			)
	
		) else (
			messageBox "Sorry... there is currently no sprite map assigned. Please choose a map with the Choose Map button."
		)
	
	)
	on btnAssignIFL pressed do
	(
		global wallworm_current_sprite_material
		global wallworm_current_sprite_map
		global wallworm_last_ifl
	
		if wallworm_last_ifl != undefined AND doesFileExist wallworm_last_ifl then (
			getSpriteMaterial resetMat:true
			wallworm_current_sprite_map = BitmapTexture filename:wallworm_last_ifl name:(uniqueName "Wall Worm Sprite IFL")
			wallworm_current_sprite_material.diffuseMap = wallworm_current_sprite_map
			wallworm_current_sprite_material.opacityMap = wallworm_current_sprite_map
	
		)
	
	)
	on btnDropSprite pressed do
	(
		placeSpriteAtPoint()
	)
	on btnSelToIFL pressed do
	(
		if (createSpriteCardFromObjects()) == false then (
			messagebox "No sprite card made. Hit F11 for more info."
		)
	)
)

createDialog wallwormSpriteTex