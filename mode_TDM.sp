#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <cod>
#include <mapchooser>
#include <emitsoundany>
#include <smlib>

#include "cod/Titles.sp"

#define IsValidClient(%1)  ( 1 <= %1 <= MaxClients && IsClientInGame(%1) )
#define IsValidClientAlive(%1)  ( 1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) )

#pragma newdecls required

Handle tdmRespawnTimer[MAXPLAYERS+1] = null;

ConVar tdmEnable;
ConVar tdmPointsToWin;
ConVar tdmRespawnDelay;
ConVar tdmSpawnDistanceSafety;
ConVar tdmRandomSpawn;
ConVar tdmPointsPerKill;

float tdmNextRespawnTime[MAXPLAYERS+1];
int winningTeam;
int tdmPoints[4];
int playTime[MAXPLAYERS+1];
int OriginOffset;

int MapTime;

float spawnOrigin[MAXPLAYERS+1][3];
float spawnAngle[MAXPLAYERS+1][3];

bool tdmStatus;

char KVPath[1028];
int PosNumber = 0;

int g_iBeamSprite = 0;
int g_iHaloSprite = 0;

bool InEdit[MAXPLAYERS+1];

public void OnPluginStart()
{
	OriginOffset = FindSendPropInfo("CBaseEntity", "m_vecOrigin");

	tdmEnable 				= CreateConVar("sm_cod_tdm", "1", "Enable/Disable TDM", _, true, 0.0, true, 1.0);
	tdmPointsToWin 			= CreateConVar("sm_cod_tdm_points", "75", "How many points needed to win", _, true, 1.0, _, _);
	tdmPointsPerKill		= CreateConVar("sm_cod_tdm_points_kill", "1", "Points Per Kill", _, true, 1.0, _, _);
	tdmRespawnDelay 		= CreateConVar("sm_cod_tdm_respawn_delay", "3.0", "Respawn Delay Time", _, true, 0.1, _, _);
	tdmSpawnDistanceSafety 	= CreateConVar("sm_cod_tdm_respawn_distance", "1000.0", "Make sure no players around", _, true, 0.0, _, _);
	tdmRandomSpawn 			= CreateConVar("sm_cod_tdm_respawn_random", "1", "Use random spawn points? !sm_codspawn to make spawn points", _, true, 0.0, true, 1.0);

	RegAdminCmd("sm_codspawn", CallBack_CreateSpawn, ADMFLAG_KICK, "Creates Spawn");

	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("round_start", Event_OnRoundStart);
} 

public void OnMapStart()
{
    PosNumber = 0;
    char CurrentMap[256];
    char sMap[256];
    GetCurrentMap(CurrentMap, sizeof(CurrentMap))
    RemoveMapPath(CurrentMap, sMap, sizeof(sMap));
    BuildPath(Path_SM, KVPath, sizeof(KVPath), "configs/cod/spawnpoints/%s.txt", sMap);
    LoadSpawnPoints(0, false);

    AddFileToDownloadsTable("sound/cod/tdm/marine_leading.mp3");
    AddFileToDownloadsTable("sound/cod/tdm/marine_loosing.mp3");
    AddFileToDownloadsTable("sound/cod/tdm/roundlose.mp3");
    AddFileToDownloadsTable("sound/cod/tdm/roundwin.mp3");

    PrecacheSoundAny("cod/tdm/marine_leading.mp3", true);
    PrecacheSoundAny("cod/tdm/marine_loosing.mp3", true);
    PrecacheSoundAny("cod/tdm/roundlose.mp3", true);
    PrecacheSoundAny("cod/tdm/roundwin.mp3", true);

    SetConVarInt(FindConVar("mp_maxrounds"), (tdmPointsToWin.IntValue)*2)
    SetConVarInt(FindConVar("mp_ignore_round_win_conditions"), 1) 

    CreateTimer(1.0, playTimeCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT); 

    tdmStatus = true;

    int iEnt = -1;
    while((iEnt = FindEntityByClassname(iEnt, "func_bomb_target")) != -1) //Find bombsites
    {
    	AcceptEntityInput(iEnt,"kill"); //Destroy the entity
    }

    while((iEnt = FindEntityByClassname(iEnt, "func_hostage_rescue")) != -1) //Find rescue points
    {
    	AcceptEntityInput(iEnt,"kill"); //Destroy the entity
    }

    g_iBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
    g_iHaloSprite = PrecacheModel("sprites/halo.vmt", true);
}

public Action playTimeCount(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++)
		if(IsValidClient(i))
			playTime[i]++;

	MapTime++;

	if(tdmStatus && MapTime == GetConVarInt(FindConVar("mp_roundtime")) * 60)
	{
		DoWinGame();
	}
}

public void OnClientDisconnect(int client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
	{
		playTime[client] = 0;
		//SaveData(client)
	}
}


public void Event_OnPlayerDeath(Handle event, char[] name, bool dontBroadcast) 
{
	if(!tdmEnable) return;
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	 
	if(GetClientTeam(attacker) != CS_TEAM_SPECTATOR)
		CheckTDM(attacker, victim);
	
}

public void Event_OnRoundStart(Handle event, char[] name, bool dontBroadcast) 
{
	if(!tdmEnable) return;

	MapTime = 0;

	for(int i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			if(tdmRespawnTimer[i] != null)
			{
				KillTimer(tdmRespawnTimer[i]);
				tdmRespawnTimer[i] = null;
			}
			tdmNextRespawnTime[i] = 0.0;
		}
		if(IsValidClient(i))
			playTime[i] = 0;
	}
	for(int i = 0; i < 4; i++)
		tdmPoints[i] = 0;

	CS_SetTeamScore(CS_TEAM_CT, 0);
	SetTeamScore(CS_TEAM_CT, 0);

	CS_SetTeamScore(CS_TEAM_T, 0);
	SetTeamScore(CS_TEAM_T, 0);

	winningTeam = CS_TEAM_NONE;

	tdmStatus = true;

	int iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "hostage_entity")) != -1) //Find the hostages themselves and destroy them
	{
		AcceptEntityInput(iEnt, "kill");
	}
}

public void Event_OnPlayerSpawn(Handle event, char[] name, bool dontBroadcast) 
{
	if(!tdmEnable) return;

	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(GetConVarInt(tdmRandomSpawn) && FileExists(KVPath))
		NewSpawnLoc(client);


	if(!tdmStatus)
	{
		Client_RemoveAllWeapons(client, _, true)
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 0.0);
	}
}

void NewSpawnLoc(int client, bool ignore = false)
{
	float nearbyPlayers[3];
	
	bool isNearby;

	if(GetRandomSpawn(client))
	{
		if(!ignore)
		{
			for(int i = 1; i < MaxClients; i++)
			{
				if(IsValidClientAlive(i))
				{
					GetEntityOrigin(i, nearbyPlayers);
					if( GetVectorDistance(nearbyPlayers, spawnOrigin[client]) <= GetConVarFloat(tdmSpawnDistanceSafety) && GetClientTeam(i) != GetClientTeam(client) ) 
					{
						isNearby = true;
						break;
					}
					else if( GetVectorDistance(nearbyPlayers, spawnOrigin[client]) <= 10.0 && GetClientTeam(i) == GetClientTeam(client) ) 
					{
						isNearby = true;
						break;
					}
				}
			}
		}
		if(!isNearby)
		{
			TeleportEntity(client, spawnOrigin[client], spawnAngle[client], NULL_VECTOR);
		}
		else
		{
			NewSpawnLoc(client, true);
		}
	}
}

void CheckTDM(int attacker, int victim)
{
	int team = GetClientTeam(attacker);
	int tempWinningTeam = leadingTeam();

	int winPoints = GetConVarInt(tdmPointsToWin);
	tdmPoints[team] += GetConVarInt(tdmPointsPerKill);

	CS_SetTeamScore(team, tdmPoints[team]);
	SetTeamScore(team, tdmPoints[team])
	
	SetEntProp(attacker, Prop_Data, "m_iFrags",  GetClientFrags(attacker));

	GameRules_SetProp("m_totalRoundsPlayed", tdmPoints[CS_TEAM_CT] + tdmPoints[CS_TEAM_T]);

	if(tempWinningTeam != winningTeam && tempWinningTeam != 0)
	{
		winningTeam = tempWinningTeam;
		for(int i = 1; i < MaxClients; i++)
			if(IsValidClient(i))
				if(GetClientTeam(i) == winningTeam)
					EmitSoundToClientAny(i, "cod/tdm/marine_leading.mp3", _, SNDCHAN_STATIC );
				else
					EmitSoundToClientAny(i, "cod/tdm/marine_loosing.mp3", _, SNDCHAN_STATIC );			
	}

	//if(tdmPoints[team] == winPoints*3/4)
	//{
	//	InitiateMapChooserVote(MapChange_RoundEnd)
	//}


	if(tdmPoints[team] == winPoints && tdmStatus)
	{
		DoWinGame();
		//Client_ShowScoreboard(client);
	}
	else
	{
		if(GetClientTeam(victim) != CS_TEAM_SPECTATOR) 
		{
			if(tdmRespawnTimer[victim] != null)
			{
				KillTimer(tdmRespawnTimer[victim]);
				tdmRespawnTimer[victim] = null;
			}
			char Name[32];
			GetClientName(attacker, Name, 32)

			tdmNextRespawnTime[victim] = GetGameTime() + GetConVarFloat(tdmRespawnDelay);
			DataPack pack;
			tdmRespawnTimer[victim] = CreateDataTimer(0.1, RespawnTimerHud, pack, TIMER_REPEAT);
			pack.WriteCell(victim);
			WritePackString(pack, Titles[COD_GetLevel(attacker)])
			WritePackString(pack, Name)
			pack.WriteCell(COD_GetLevel(attacker))
		}
	}
}

public void DoWinGame()
{
	int team = leadingTeam();

	if(team == CS_TEAM_CT)
		CS_TerminateRound(99.0, CSRoundEnd_CTWin);
	else
		CS_TerminateRound(99.0, CSRoundEnd_TerroristWin);

	for(int i = 1; i < MaxClients; i++)
	{
		if(IsValidClientAlive(i)) {
			Client_RemoveAllWeapons(i, _, true)
			SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 0.0);
		}
		if(IsValidClient(i) && !IsFakeClient(i)) 
		{
			bool bonus = false
			if(GetClientTeam(i) == team) {
				bonus = true;
				EmitSoundToClientAny(i, "cod/tdm/roundwin.mp3", _, SNDCHAN_STATIC );
			}
			else {
				EmitSoundToClientAny(i, "cod/tdm/roundlose.mp3", _, SNDCHAN_STATIC );
			}
			ScreenFade(i, FFADE_IN|FFADE_MODULATE, { 211, 211, 211, 255 }, 1, 1);
			if(COD_GetLevel(i) != 80) 
			{
				int frags = GetClientFrags(i) * 100;
				int level = COD_GetLevel(i) * 50;
				int timeplayXP = playTime[i];
				float total = float(frags+level+timeplayXP);
				if(bonus)
					total *= 1.1;
			
				PrintToServer("MATCH BONUS DEBUG: %N's bonus || Kills: %d || level: %d || timePlayXP %d: || Total: %d", i, frags, level, timeplayXP, RoundFloat(total))	
				COD_GiveXP(i, RoundFloat(total))
				PrintHintText(i, "           MATCH BONUS \n 	     +<font color='#ffff00'>%d</font>XP", RoundFloat(total));
				PrintToChat(i, " \x04[ COD ]\x01 MATCH BONUS: %dXP", RoundFloat(total));
			}
		}
		tdmStatus = false;
	}
	CreateTimer(5.0, ChangeMapTimer);
}

public Action ChangeMapTimer(Handle timer)
{
	InitiateMapChooserVote(MapChange_Instant);
}

public Action RespawnTimerHud(Handle timer, Handle pack)
{

	int client, level;
	char Title[32];
 	char Name[32];
 	
	ResetPack(pack);
	client = ReadPackCell(pack);
	ReadPackString(pack, Title, 32);
	ReadPackString(pack, Name, 32);
	level = ReadPackCell(pack);

	if(!IsValidClient(client) || GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		tdmRespawnTimer[client] = null;
		return Plugin_Stop;
	}

	if(GetGameTime() >= tdmNextRespawnTime[client])
	{
		if(!IsClientReplay(client))
			CS_RespawnPlayer(client);
		else
			CreateTimer(1.0, CheckReplayRespawn, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		tdmRespawnTimer[client] = null;
		return Plugin_Stop;
	}
	else
		PrintHintText(client, "%s %s (Lv:%d) \nRespawning in <font color='#ff0000'>%.1f</font>s ", Title, Name, level, tdmNextRespawnTime[client] - GetGameTime());

	return Plugin_Continue;
}

public Action CheckReplayRespawn(Handle timer, any client)
{
	client = GetClientOfUserId(client);
	if(!IsValidClient(client) || IsValidClientAlive(client))
		return;

	if(IsClientReplay(client))
		PrintHintText(client, "Waiting for REPLAY to finish.");
	else
		CS_RespawnPlayer(client);
	return;
}

stock int leadingTeam()
{
	if(tdmPoints[CS_TEAM_T] > tdmPoints[CS_TEAM_CT])
		return CS_TEAM_T;
	else if(tdmPoints[CS_TEAM_CT] > tdmPoints[CS_TEAM_T])
		return CS_TEAM_CT;
	return CS_TEAM_NONE;
}

// Custom Spawns
public Action CallBack_CreateSpawn(int client, int args)
{
    Handle menu = CreateMenu(CallBack_CreateSpawn_Handle);

    char szMsg[60];
    char szItems[60], szItems2[60];
    Format(szMsg, sizeof( szMsg ), "Spawns: %d", PosNumber);
    
    SetMenuTitle(menu, szMsg);

    Format(szItems, sizeof( szItems ), "Add Spawn");
    Format(szItems2, sizeof( szItems2 ), "Show Spawns: %s", InEdit[client] ? "ON" : "OFF");

    AddMenuItem(menu, "class_id", szItems);
    AddMenuItem(menu, "class_id", szItems2);

    SetMenuExitButton(menu, true);

    DisplayMenu(menu, client, MENU_TIME_FOREVER)

}
public int CallBack_CreateSpawn_Handle(Handle menu, MenuAction action, int client, int item)
{
    if( action == MenuAction_Select )
    {
    	switch(item)
    	{
    		case 0:
    		{
		        float Origin[3];
		        GetEntityOrigin(client, Origin)
		        float fAngle[3];
		        GetClientEyeAngles(client, fAngle)
		        fAngle[0] = 0.0;
		        fAngle[2] = 0.0;
		        Handle DB = CreateKeyValues("spawnpoints");
		        FileToKeyValues(DB, KVPath);

		        char strNumber[32];
		        IntToString(PosNumber, strNumber, sizeof(strNumber))

		        if( KvJumpToKey(DB, strNumber, true))
		        {
		            KvSetFloat(DB, "x", Origin[0])
		            KvSetFloat(DB, "y", Origin[1])
		            KvSetFloat(DB, "z", Origin[2])

		            KvSetFloat(DB, "a", fAngle[0])
		            KvSetFloat(DB, "b", fAngle[1])
		            KvSetFloat(DB, "c", fAngle[2])
		        }

		        KvRewind(DB);
		        KeyValuesToFile(DB, KVPath);

		        CloseHandle(DB);
		        PosNumber++;

		        PrintToChat(client, "Position #%d saved %.0f %.0f %.0f", PosNumber, Origin[0], Origin[1], Origin[2]);
		    
		        CallBack_CreateSpawn(client, 0);    			
    		}
    		case 1:
    		{
    			CreateTimer(1.0, Spawns_Timer_Display, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE)
    			InEdit[client] = !InEdit[client];
    			CallBack_CreateSpawn(client, 0);
    		}
    	}

    
    } 
    else if (action == MenuAction_End)  
    {
        CloseHandle(menu);
    }
}

public Action Spawns_Timer_Display(Handle timer, any clientId)
{   
	int client = GetClientOfUserId(clientId);
	if(!InEdit[client] || !IsValidClient(client))
		return Plugin_Stop;

	LoadSpawnPoints(client, true);
    
	return Plugin_Continue;
}

void LoadSpawnPoints(int client = 0, bool showSpawn)
{
	if (FileExists(KVPath))
	{   
		Handle DB = CreateKeyValues("spawnpoints");
		FileToKeyValues(DB, KVPath);
		PosNumber = 0;
		char StringNumber[128];
		IntToString(PosNumber, StringNumber, sizeof(StringNumber))
		if(showSpawn)
		{
			while( KvJumpToKey(DB, StringNumber, false) )
			{
				PosNumber++
				IntToString(PosNumber, StringNumber, sizeof(StringNumber))

				float origin[3], angle[3];

				origin[0] = KvGetFloat(DB, "x");
				origin[1] = KvGetFloat(DB, "y");
				origin[2] = KvGetFloat(DB, "z");

				angle[0] = KvGetFloat(DB, "a");
				angle[1] = KvGetFloat(DB, "b");
				angle[2] = KvGetFloat(DB, "c");

				spawns_DisplaySpawnPoint(client, origin, angle, 40.0)
				KvRewind(DB);
			}
		}
		else
		{
			while( KvJumpToKey(DB, StringNumber, false) )
			{
				PosNumber++
				IntToString(PosNumber, StringNumber, sizeof(StringNumber))
				KvRewind(DB);
				
			}
		}
		CloseHandle(DB);
		PrintToServer("%d spawnpoints Loaded", PosNumber)
	}
}

stock void spawns_DisplaySpawnPoint(int clientIndex, float position[3], float angles[3], float size)
{
    float direction[3], up[3];
    
    GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(direction, size/2);
    AddVectors(position, direction, direction);

    GetAngleVectors(angles, NULL_VECTOR, NULL_VECTOR, up);
    ScaleVector(up, size);
    AddVectors(position, up, up);

    TE_Start("BeamRingPoint");
    TE_WriteVector("m_vecCenter", position);
    TE_WriteFloat("m_flStartRadius", 10.0);
    TE_WriteFloat("m_flEndRadius", size);
    TE_WriteNum("m_nModelIndex", g_iBeamSprite);
    TE_WriteNum("m_nHaloIndex", g_iHaloSprite);
    TE_WriteNum("m_nStartFrame", 0);
    TE_WriteNum("m_nFrameRate", 0);
    TE_WriteFloat("m_fLife", 1.0);
    TE_WriteFloat("m_fWidth", 1.0);
    TE_WriteFloat("m_fEndWidth", 1.0);
    TE_WriteFloat("m_fAmplitude", 0.0);
    TE_WriteNum("r", 255);
    TE_WriteNum("g", 255);
    TE_WriteNum("b", 0);
    TE_WriteNum("a", 255);
    TE_WriteNum("m_nSpeed", 50);
    TE_WriteNum("m_nFlags", 0);
    TE_WriteNum("m_nFadeLength", 0);
    TE_SendToClient(clientIndex);
    
    TE_Start("BeamPoints");
    TE_WriteVector("m_vecStartPoint", position);
    TE_WriteVector("m_vecEndPoint", direction);
    TE_WriteNum("m_nModelIndex", g_iBeamSprite);
    TE_WriteNum("m_nHaloIndex", g_iHaloSprite);
    TE_WriteNum("m_nStartFrame", 0);
    TE_WriteNum("m_nFrameRate", 0);
    TE_WriteFloat("m_fLife", 1.0);
    TE_WriteFloat("m_fWidth", 1.0);
    TE_WriteFloat("m_fEndWidth", 1.0);
    TE_WriteFloat("m_fAmplitude", 0.0);
    TE_WriteNum("r", 255);
    TE_WriteNum("g", 255);
    TE_WriteNum("b", 0);
    TE_WriteNum("a", 255);
    TE_WriteNum("m_nSpeed", 50);
    TE_WriteNum("m_nFlags", 0);
    TE_WriteNum("m_nFadeLength", 0);
    TE_SendToClient(clientIndex);

    TE_Start("BeamPoints");
    TE_WriteVector("m_vecStartPoint", position);
    TE_WriteVector("m_vecEndPoint", up);
    TE_WriteNum("m_nModelIndex", g_iBeamSprite);
    TE_WriteNum("m_nHaloIndex", g_iHaloSprite);
    TE_WriteNum("m_nStartFrame", 0);
    TE_WriteNum("m_nFrameRate", 0);
    TE_WriteFloat("m_fLife", 1.0);
    TE_WriteFloat("m_fWidth", 1.0);
    TE_WriteFloat("m_fEndWidth", 1.0);
    TE_WriteFloat("m_fAmplitude", 0.0);
    TE_WriteNum("r", 255);
    TE_WriteNum("g", 255);
    TE_WriteNum("b", 0);
    TE_WriteNum("a", 255);
    TE_WriteNum("m_nSpeed", 50);
    TE_WriteNum("m_nFlags", 0);
    TE_WriteNum("m_nFadeLength", 0);
    TE_SendToClient(clientIndex);
}

stock bool GetRandomSpawn(int client)
{
	if (FileExists(KVPath))
	{   
		int randomlocation = GetRandomInt(1, PosNumber-1);

		Handle DB = CreateKeyValues("spawnpoints");
		FileToKeyValues(DB, KVPath);

		char PosString[32];
		IntToString(randomlocation, PosString, sizeof(PosString))
		if( KvJumpToKey(DB, PosString, false) )
		{ 
			spawnOrigin[client][0] = KvGetFloat(DB, "x");
			spawnOrigin[client][1] = KvGetFloat(DB, "y");
			spawnOrigin[client][2] = KvGetFloat(DB, "z");

			spawnAngle[client][0] = KvGetFloat(DB, "a");
			spawnAngle[client][1] = KvGetFloat(DB, "b");
			spawnAngle[client][2] = KvGetFloat(DB, "c");
			return true;
		}
		CloseHandle(DB);
	}
	else
	{
		LogError("Error: Missing %s", KVPath);
	}
	return false;
}

stock void ScreenFade(int iClient, int iFlags = FFADE_PURGE, int iaColor[4] = {0, 0, 0, 0}, int iDuration = 0, int iHoldTime = 0)
{
    Handle hScreenFade = StartMessageOne("Fade", iClient);
    PbSetInt(hScreenFade, "duration", iDuration * 500);
    PbSetInt(hScreenFade, "hold_time", iHoldTime * 500);
    PbSetInt(hScreenFade, "flags", iFlags);
    PbSetColor(hScreenFade, "clr", iaColor);
    EndMessage();
}

public void GetEntityOrigin(int entity, float output[3])
{
    GetEntDataVector(entity, OriginOffset, output);
}

stock bool RemoveMapPath(const char[] map, char[] destination, int maxlen)
{
	if (strlen(map) < 1)
	{
		ThrowError("Bad map name: %s", map);
	}
	
	// UNIX paths
	int pos = FindCharInString(map, '/', true);
	if (pos == -1)
	{
		// Windows paths
		pos = FindCharInString(map, '\\', true);
		if (pos == -1)
		{
			// Copy the path out unchanged, but return false
			// This was added by request, but also simplifies MapEqual a LOT
			strcopy(destination, maxlen, map);
			return false;
		}
	}

	// pos + 1 is because pos is the last / or \ location and we want to start one char further
	// maxlen is because strcopy will auto-stop if it hits '\0' before maxlen
	strcopy(destination, maxlen, map[pos+1]);
	
	return true;
}


