/*

tool textures
Version 1.0
Created by Shawn Olson
www.shawnolson.net

for Wall Worm Mod Tools
www.wallworm.com

*/

SourceToolTextures = #()

append SourceToolTextures #("tools/invismetal", "Invis Metal", (Color 120 80 17))
append SourceToolTextures #("tools/toolsareaportal", "Area Portal", (Color 95 255 250))
append SourceToolTextures #("tools/toolsblack", "BLACK", BLACK)
append SourceToolTextures #("tools/toolsblock_los", "Block LOS", blue)
append SourceToolTextures #("tools/toolsblockbullets", "Block Bullets", orange)
append SourceToolTextures #("tools/toolsblocklight", "Block Light", (Color 127 207 116))
append SourceToolTextures #("tools/toolsclip", "Clip", (Color 212 61 37))
append SourceToolTextures #("tools/toolscontrolclip", "Player Control Clip", (Color 183 33 166))
append SourceToolTextures #("tools/toolsdotted", "Dotted", yellow)
append SourceToolTextures #("tools/toolsfog", "FOG", (Color 200 200 200))
append SourceToolTextures #("tools/toolshint", "Hint", (Color 119 52 135))
append SourceToolTextures #("tools/toolsinvisible", "Invisible", (Color 183 33 166))
append SourceToolTextures #("tools/toolsinvisibleladder", "Ladder", orange)
append SourceToolTextures #("tools/toolsnodraw", "NODRAW", yellow)
append SourceToolTextures #("tools/toolsnodraw_roof", "NODRAW ROOF", YELLOW)
append SourceToolTextures #("tools/toolsnpcclip", "NPC Clip", (Color 119 52 135))
append SourceToolTextures #("tools/toolsoccluder", "Occluder", (Color 29 41 84))
append SourceToolTextures #("tools/toolsorigin", "ORIGIN", green)
append SourceToolTextures #("tools/toolsplayerclip", "Player Clip", (Color 183 33 166))
append SourceToolTextures #("tools/toolsskip", "SKIP", (Color 100 199 251))
append SourceToolTextures #("tools/toolsskybox", "SKYBOX", (Color 176 217 239))
append SourceToolTextures #("tools/toolsskybox2d", "2D SKYBOX", (Color 215 203 249))
append SourceToolTextures #("tools/toolsskyfog", "Sky Fog", (Color 176 217 239))
append SourceToolTextures #("tools/toolstrigger", "Trigger", orange)

theMaterialLibrary = MaterialLibrary()
hintMat = MultiMaterial name:"Hint/Skip Brush" numsubs:2

for t in SourceToolTextures do (
	m = Standard name:t[1] diffuse:t[3] opacity:70

	if t[1] == "tools/toolsskip" then (
		hintMat[1] = m
		hintMat.names[1] = t[2]
	)

	if t[1] == "tools/toolshint" then (
		hintMat[2] = m
		hintMat.names[2] = t[2]
	)

	append theMaterialLibrary m

)

append theMaterialLibrary hintMat

saveTempMaterialLibrary theMaterialLibrary ("$matlibs/wallworm_source_tools.mat")
loadMaterialLibrary "$matlibs/wallworm_source_tools.mat"