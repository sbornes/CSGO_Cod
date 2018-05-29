/*
Wall Worm VTA Helper Function
http://www.wallworm.com

Make a keyframe for every slot in a Morph or Morph-O-Matic modifier

Copyright (c) 2011 by Shawn Olson http://www.shawnolson.net

Function will find a Morph modifier (or Di-O-Matic's Morph-O-Matic modifier)
and apply a keyframe for each channel at 100 weight.

Steps to quicken the creation of VTA flex files for Source.
*/

try(destroyDialog wwmt_WormFlex)catch(
)

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/common/flexfuncs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/custom_attributes/flexcontroller.ms")

rollout wwmt_WormFlex "Worm Flex Tools" width:206 height:104
(
	Button btn1 "Flex Prep Selected" toolTip:"Prepare a mesh with a Morpher or Morph-O-Matic modifier for exporting as a VTA."

	Button btnApplyMorphCA "Add Morph Attributes" tooltip:"Set domination rules, wrinkle, etc for DMX flex targets."

	Hyperlink cust2 "Understanding VTA/Flex Export" address:"http://wallworm.com/projects/utilities/docs/using/making_facial_animations.html" color:(Color 0 0 255) hovercolor:(Color 255 0 0) visitedcolor:(Color 0 0 255)
	on btn1 pressed do
	(
		macros.run "wallworm.com" "WallWormVTAPrepSelMCR"
	)

	on btnApplyMorphCA pressed do (
		wallworm_add_flex_ca()
	)
)

createDialog wwmt_WormFlex