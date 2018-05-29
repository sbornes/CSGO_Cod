/*
Wall Worm Display Floater Launcher
Copyright (c) 2015 by Shawn Olson
*/

if (::wallworm_installation_path == undefined) then (
	macros.run "wallworm.com" "WallWormInitialize"
)

try(destroyDialog wallwormDisplayFloater)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/display.ms")
createDialog wallwormDisplayFloater