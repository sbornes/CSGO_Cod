/*
Wall Worm Proxy Tools
Copyright (c) 2015 by Shawn Olson

*/

if (::wallworm_installation_path == undefined) then (
	macros.run "wallworm.com" "WallWormInitialize"
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")
try(destroyDialog wallworm_proxy_tools)catch(
	--there was not any open
)

fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/proxy_tools.ms")

createDialog wallworm_proxy_tools