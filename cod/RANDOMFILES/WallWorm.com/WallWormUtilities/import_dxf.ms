/*

Wall Worm DXF importer
http://www.wallworm.com

This script will allow you to pick a DXF file to import as a level.

Copyright (c) 2012 by Shawn Olson
All Rights Reserved

http://www.shawnolson.net

*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename())))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/importers/importer_functions.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/rollouts/dxf_import.ms")

try (destroyDialog wallwormDXFImport) catch ()

createDialog wallwormDXFImport