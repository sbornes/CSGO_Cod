
/*
  _______       _____ _______ _____ _____          _        _____ _   _  _____ ______ _____ _______ _____ ____  _   _ 
 |__   __|/\   / ____|__   __|_   _/ ____|   /\   | |      |_   _| \ | |/ ____|  ____|  __ \__   __|_   _/ __ \| \ | |
    | |  /  \ | |       | |    | || |       /  \  | |        | | |  \| | (___ | |__  | |__) | | |    | || |  | |  \| |
    | | / /\ \| |       | |    | || |      / /\ \ | |        | | | . ` |\___ \|  __| |  _  /  | |    | || |  | | . ` |
    | |/ ____ \ |____   | |   _| || |____ / ____ \| |____   _| |_| |\  |____) | |____| | \ \  | |   _| || |__| | |\  |
    |_/_/    \_\_____|  |_|  |_____\_____/_/    \_\______| |_____|_| \_|_____/|______|_|  \_\ |_|  |_____\____/|_| \_|
                                                                                                                      
                                                                                                                      
*/

public void OnEntitySpawnedFlash(int iGrenade)
{
	// Needed only for CSS.
	CreateTimer(0.0, InitFlashGrenade, iGrenade, TIMER_FLAG_NO_MAPCHANGE);
}


public void GrenadeTouchTatical(int iGrenade, int iEntity) 
{
	//Stick once
	SDKUnhook(iGrenade, SDKHook_StartTouch, GrenadeTouchTatical);
	

	SetEntityMoveType(iGrenade, MOVETYPE_NONE);
	
	PlayerHasTatical[GetEntDataEnt2(iGrenade, OFFSET_THROWER)] = true;
	PlayerTaticalEnt[GetEntDataEnt2(iGrenade, OFFSET_THROWER)] = iGrenade;
}

public Action InitFlashGrenade(Handle timer, any iGrenade)
{
	if(!IsValidEntity(iGrenade))
	{
		return;
	}
	
	int iClient = GetEntDataEnt2(iGrenade, OFFSET_THROWER);
	
	if(iClient < 1 || iClient > MaxClients)
	{
		return;
	}

	if(hasTactical(iClient, "Tactical Insertion")) 
	{
		RemoveEdict(iGrenade);
		CreateTact(iClient);
		//CreateTimer( 0.0, OnGrenadeCreated, iGrenade );
		//SDKHook(iGrenade, SDKHook_StartTouch, GrenadeTouchTatical);
	}

	char Model[128];
	Entity_GetModel(iGrenade, Model, 128)
	int glow = CreatePlayerModelProp(iGrenade, Model)
	EntityOwner[glow] = iClient;
	if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
		SetupGlow(glow, 255, 0, 0, 255, 1000.0);
}



int CreateTact(int client)
{
	int iEntity = CreateEntityByName("prop_physics_override"); 
	//int iEntity = CreateEntityByName("prop_dynamic_override"); 

	float fOrigin[3], fAngle[3];
	GetEntityOrigin(client, fOrigin);
	SetEntPropVector(client, Prop_Send, "m_angRotation", fAngle);
	fAngle[0] = 90.0;
	fAngle[2] = 0.0;

	//fOrigin[2] += 75;

	DispatchKeyValue(iEntity, "classname", "Tactical Insertion");
	DispatchKeyValue(iEntity, "targetname", "prop");
	DispatchKeyValue(iEntity, "model", "models/weapons/w_eq_sensorgrenade_dropped.mdl");
	DispatchKeyValue(iEntity, "solid", "6");
	//SetEntPropFloat(iEntity, Prop_Send,"m_flModelScale", 0.25);
	if ( DispatchSpawn(iEntity) ) 
	{
		char Model[128];
		Entity_GetModel(iEntity, Model, 128)
		int glow = CreatePlayerModelProp(iEntity, Model)
		EntityOwner[glow] = client;
		if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
			SetupGlow(glow, 255, 0, 0, 255, 1000.0);

        //if (SDKHookEx(iEntity, SDKHook_SetTransmit, OnSetTransmitEntity))
        //    SetupGlow(iEntity, 255, 0, 0, 255, 1000.0);

		TeleportEntity(iEntity, fOrigin, fAngle, NULL_VECTOR); 
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
		AcceptEntityInput(iEntity, "DisableMotion");
		Entity_SetOwner(iEntity, client)

		EntityOwner[iEntity] = client;

		SetEntityMoveType(iEntity, MOVETYPE_NONE);
	
		PlayerHasTatical[client] = true;
		PlayerTaticalEnt[client] = iEntity;

		return iEntity;
	} 
	return -1;	
}

/*
   _____ ____  _   _  _____ _    _  _____ _____ _____ ____  _   _    _____ _____  ______ _   _          _____  ______ 
  / ____/ __ \| \ | |/ ____| |  | |/ ____/ ____|_   _/ __ \| \ | |  / ____|  __ \|  ____| \ | |   /\   |  __ \|  ____|
 | |   | |  | |  \| | |    | |  | | (___| (___   | || |  | |  \| | | |  __| |__) | |__  |  \| |  /  \  | |  | | |__   
 | |   | |  | | . ` | |    | |  | |\___ \\___ \  | || |  | | . ` | | | |_ |  _  /|  __| | . ` | / /\ \ | |  | |  __|  
 | |___| |__| | |\  | |____| |__| |____) |___) |_| || |__| | |\  | | |__| | | \ \| |____| |\  |/ ____ \| |__| | |____ 
  \_____\____/|_| \_|\_____|\____/|_____/_____/|_____\____/|_| \_|  \_____|_|  \_\______|_| \_/_/    \_\_____/|______|
                                                                                                                      

*/

public Action Event_PlayerBlind(Handle event, char[] name, bool dontBroadcast)
{
    /* The client that was blinded */
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if(g_bFlashed[client])
    {
		if(GetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha") > 100.0)
			SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 100.0);
		
		flashDuration[client] = GetGameTime() + GetEntPropFloat(client, Prop_Send, "m_flFlashDuration");
		CreateTimer(0.1, doConcussion, client, TIMER_REPEAT)
		g_bFlashed[client] = false;
    }

    if(g_bScramblerFlashed[client])
    {
    	PrintToChat(client, "RADAR DOWN, you were hit by a scrambler.")
    	SetEntPropFloat(client, Prop_Send, "m_flFlashMaxAlpha", 0.0);
    	SetEntPropFloat(client, Prop_Send, "m_flFlashDuration", 0.0);
    	SetRadar(client, true);
    }

    //PrintToChat(client, "BINDLED tRUE")
}

/* Called when a flashbang has detonated (after the players have already been blinded) */
public void Event_FlashbangDetonate(Handle event, char[] name, bool dontBroadcast)
{
    /* The number of flashed players, and the player that threw the flashbang */
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    for (int i = 1; i <= MaxClients; i++)
    {
        /* Not a self flash, other player (i) marked as being flashed, in game, on same team, and alive */
        if (i != client && IsClientInGame(i) && GetClientTeam(i) != GetClientTeam(client) && IsPlayerAlive(i))
        {
        	//PrintToChat(client, " 1 DETONATED")
            if(hasTactical(client, "Concussion Grenade") && !g_bFlashed[i])
            {
				g_bFlashed[i] = true;
            }
            else
            {
            	g_bFlashed[i] = false;
            }
            if(hasTactical(client, "Scrambler") && !g_bScramblerFlashed[i])
            {
				g_bScramblerFlashed[i] = true;
            }
            else
            {
            	g_bScramblerFlashed[i] = false;
            }
        }
    }
}

public Action doConcussion( Handle timer, any client)
{
	if(!IsValidClientAlive(client)) 
		return Plugin_Stop;

	if(flashDuration[client] > GetGameTime())
	{
		float ClientPos[3];
		GetClientEyeAngles(client, ClientPos);

		ClientPos[0] += GetRandomFloat(-2.5, 2.5);
		ClientPos[1] += GetRandomFloat(-2.5, 2.5);

		TeleportEntity(client, NULL_VECTOR, ClientPos, NULL_VECTOR);
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}