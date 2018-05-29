#define HIDE_RADAR_CSGO 1<<12

public Action HUD(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientInGame(client) && IsClientConnected(client)){
			UpdateHUD_Radar(client);
			UpdateHud_Msg(client);
		}
	}
}

void UpdateHud_Msg(int client)
{
	char szItems1[512];
	if(PlayerStatsInfo[client][Level] != MAX_LEVEL)
		Format(szItems1, sizeof( szItems1 ), "[%s] [Lv: %d] [XP: %d/%d]",  Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level], PlayerStatsInfo[client][XP], XPtoLevel[PlayerStatsInfo[client][Level]] );
	else
		Format(szItems1, sizeof( szItems1 ), "[%s] [Lv: %d]",  Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level] );

	HudText(client, "2", "255 255 255", "0.0", "0.0", "1.5", szItems1, "0.35", "1.0");
}

void UpdateHUD_Radar(int client)
{
	if(GetClientMenu(client) == MenuSource_None)
	{
		if(g_bScramblerFlashed[client])
			SetRadar(client, true);
		SetRadar(client, false);
	}
	else
	{
		SetRadar(client, true);
	}
}

void UpdateHUD_CSGO2(int client)
{
	//start building HUD
	//char centerText[1024]; //HUD buffer		

	if( IsValidClient(client) && !IsVoteInProgress())
	{
		if(GetClientMenu(client) == MenuSource_None)
		{
			char szItems1[512];
			if(PlayerStatsInfo[client][Level] != MAX_LEVEL)
				Format(szItems1, sizeof( szItems1 ), "%s \nLv: %d \nXP: %d/%d\n---------------------------------------\nNeed %d more XP to level.",  Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level], PlayerStatsInfo[client][XP], XPtoLevel[PlayerStatsInfo[client][Level]], XPtoLevel[PlayerStatsInfo[client][Level]] - PlayerStatsInfo[client][XP] );
			else
				Format(szItems1, sizeof( szItems1 ), "%s \nLv: %d",  Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level]);

			Handle panel = CreatePanel();
			SetPanelTitle(panel, szItems1 );

			//DrawPanelItem(panel, szItems4, ITEMDRAW_RAWLINE);
			
			if(!IsPlayerAlive(client))
				SendPanelToClient(panel, client, PanelHandler1, 5);
			else
				SendPanelToClient(panel, client, PanelHandler1, 2);

			CloseHandle(panel);
		}
	}		
}

public int PanelHandler1(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{

		}
	}
}