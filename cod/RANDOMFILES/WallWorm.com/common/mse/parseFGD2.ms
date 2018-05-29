/*
Functions to parse an FGD and create custom attribute definitions for each.
*/

if (::wallworm_installation_path == undefined) then (
	::wallworm_installation_path = pathConfig.removePathLeaf (pathConfig.removePathLeaf (pathConfig.removePathLeaf (getFilenamePath (getThisScriptFilename()))))
)

fileIn (::wallworm_installation_path + "/WallWorm.com/WallWormModelTools/ww_structs.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/settings_struct.ms")
fileIn (::wallworm_installation_path + "/WallWorm.com/common/mse/fgd2.mse")

max create mode

with undo off (
	local fgdHelper = undefined
	if ::WallwormProActive then (
		fgdHelper = try (DotNetClass "WallWorm.Helpers.FGDHelper") catch (undefined)
	)
	global wallworm_parsed_fgd_str
	global wallworm_reparse_fgd
	global wallworm_game_settings

	if wallworm_game_settings == undefined OR classOf wallworm_game_settings != wallworm_fgd_def OR wallworm_reparse_fgd != undefined then (
		wallworm_game_settings = wallworm_fgd_def()
	)

	if wallworm_game_settings.ents.count == 0 OR wallworm_reparse_fgd != undefined then (
		wallworm_game_settings.ents = #()
		wallworm_game_settings.brushEntities = #()
		wallworm_game_settings.pointEntities = #()

		/*This function loops a try/catch block because of an odd unknown system exception that happens randomly at the first few times it runs.*/
		function wallworm_exec_fgd_parse = (
			local ents = #()
			local count = 0
			global wallworm_parsed_fgd_str
			--ents = wallworm_parse_fgd ::wwmt_def_fgd

			while (ents.count == 0) AND count <= 20 do (
				try (
					ents = wallworm_parse_fgd ::wwmt_def_fgd
				) catch (
					ents = #()
					count += 1

					format "\nParse attempt % because of : %\n" count (getCurrentException())

				)
			)

			ents
		)

		if ::wwmt_def_fgd != undefined AND ::wwmt_def_fgd != "" AND doesFileExist ::wwmt_def_fgd == true then (
			wallworm_game_settings.fgdname = getFilenameFile ::wwmt_def_fgd
			wallworm_game_settings.fgdfile = ::wwmt_def_fgd

			if wallworm_reparse_fgd == undefined then (
				wallworm_game_settings.fill_from_parsed()
			)

			if wallworm_game_settings.ents.count == 0 OR wallworm_reparse_fgd != undefined then (
				print "Parsing the entities..."

				if fgdHelper == undefined OR ::WallwormProActive == false OR ::WWLegacyFGD == true then (
					wallworm_game_settings.ents = wallworm_exec_fgd_parse()

					--wallworm_game_settings.ents = wallworm_parse_fgd ::wwmt_def_fgd

					--if wallworm_game_settings.failedEnts.count > 0 then (
					wallworm_game_settings.refresh_unfilled_ents()
					--print "ents with bad data"
					--)

					wallworm_game_settings.getAllPointEntities()
					wallworm_game_settings.getAllBrushEntities()
				)

				wallworm_game_settings.write_ents()

				-- The helper parses and writes out directly, so we need to load it back in to use it.
				if fgdHelper != undefined AND ::WWLegacyFGD != true AND ::WallwormProActive == true then (
					wallworm_game_settings.fill_from_parsed()
				)
			)
			wallworm_game_settings.alphabetize_ents()

			if wallworm_reparse_fgd != undefined then (
				wallworm_update_all_entities()
			)

			wallworm_reparse_fgd = undefined
		)
	)
)
