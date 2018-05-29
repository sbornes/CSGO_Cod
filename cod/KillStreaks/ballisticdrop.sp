void doBallisticVest(int client)
{
	hasBallisticVest[client] = false;

	add_message_in_queue(client, KSR_BALLISTIC_VEST, MESSAGE_POINTS[KSR_BALLISTIC_VEST])

	float fOrigin[3];
	GetEntityOrigin(client, fOrigin);   
	SpawnCrateBalistic( client, fOrigin, true );

	//PrintToChatAll(" %N has called in a care package at his location!", client);

	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/cp_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/cp_friendly.mp3", _, SNDCHAN_STATIC );
}

int SpawnCrateBalistic(int owner, float fOrigin[3] = { 0.0, 0.0, 0.0 }, bool Falling)
{
    int iEntity = CreateEntityByName("prop_physics_override"); 

    DispatchKeyValue(iEntity, "classname", "cod_ballisitcdrop");
    DispatchKeyValue(iEntity, "targetname", "prop");
    //Entity_SetClassName(iEntity, "cod_carepackage");
    DispatchKeyValue(iEntity, "model", "models/hostags/hostage_varianta.mdl");
    DispatchKeyValue(iEntity, "solid", "6");
    DispatchKeyValue(iEntity, "spawnflags", "256"); // set "usable" flag
    if ( DispatchSpawn(iEntity) ) 
    {
        char Model[128];
        Entity_GetModel(iEntity, Model, 128)
        int glow = CreatePlayerModelProp(iEntity, Model)
        EntityOwner[glow] = owner;
        if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntityDuffel))
            SetupGlow(glow, 0, 255, 0, 255, 1000000.0);

        //SetEntProp(iEntity, Prop_Send, "m_fEffects", enteffects);  
        if( Falling ) 
        {
            
            float vecAng[3] = {-90.0, 0.0, 0.0}, vecPos[3]; 

            Handle trace = TR_TraceRayFilterEx(fOrigin, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
            TR_GetEndPosition(vecPos, trace); 

            fOrigin[2] = vecPos[2]-100; 
            CloseHandle(trace);
            
            //fOrigin[2] += 700;
        } 
        StartPara(iEntity, true);

        PackageFalling[iEntity] = true;

        //EmitAmbientSoundAny("hungergames/parachute.mp3", fOrigin, iEntity );
        //SpawnHelicopter(fOrigin);
        TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR); 
        SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
        SetEntProp(iEntity, Prop_Data, "m_iHealth", 500);
        HookSingleEntityOutput( iEntity, "OnPlayerUse", BallisticUsed, false );
        SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
        SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
        AcceptEntityInput(iEntity, "EnableMotion");
        EntityOwner[iEntity] = owner;
        SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);
        SDKHook(iEntity, SDKHook_Touch, VestTouch);
        return iEntity;
    }   
    //https://forums.alliedmods.net/showthread.php?t=279540 PARTICLE EFFECT
    return -1;
}

public void BallisticUsed(char[] output, int caller, int activator, float delay)
{ 
    // register last mine touched

    last_ballistic_used = caller;
//  PrintToChatAll( "debug1, %s, %d, %d, %d", output, caller, last_playeruse_id, last_playeruse_target );
     
}

public void openBallistic( Handle event, char[] name, bool dontBroadcast )
{
    
    int client = GetEventInt( event, "userid" );
    int target = GetEventInt( event, "entity" );

   

    if( last_ballistic_used == target ) { // verify this use event matches with the mine-use event
        client = GetClientOfUserId(client);
        if( client == 0 || GetClientTeam(client) != GetClientTeam(EntityOwner[target]) || isJuggernaut[client] || wearingBallisticVest[client]) return; // client has disconnected

        StartOpenBallistic( client, target );
    }
}

void StartOpenBallistic( int client, int target ) {
    if( defuse_userid[client] != 0 ) return; // defusal already in progress

    PrintHintText( client, "Wearing Vest." );

    defuse_time[client] = 0;
    defuse_target[client] = target;
    GetClientAbsOrigin( client, defuse_position[client] );
    GetClientEyeAngles( client, defuse_angles[client] );
    defuse_cancelled[client] = false;
    defuse_userid[client] = GetClientUserId(client);
    CreateTimer( 1.0, BallisticDefuseTimer, GetClientUserId(client), TIMER_REPEAT );

    EmitSoundToClient( client, "weapons/c4/c4_disarm.wav" );//
//  PlayMineSound( defuse_target[client], SOUND_DEFUSE );
    
}

//----------------------------------------------------------------------------------------------------------------------
public Action BallisticDefuseTimer( Handle timer, any client ) 
{
    client = GetClientOfUserId(client)
    int userid = defuse_userid[client];
    int old_client = GetClientOfUserId( userid );

    char classname[32];
    Entity_GetClassName(defuse_target[client], classname, 32)

    if( !IsValidClient(old_client) || old_client != client ) {
        
        return Plugin_Stop; // something went wrong
    }

    if( defuse_cancelled[client] ) {
        defuse_userid[client] = 0;
        return Plugin_Stop;
    }

    if( !IsValidEntity(defuse_target[client]) ) {
        // mine was killed
        defuse_userid[client] = 0;
        return Plugin_Stop;
    }

    bool player_moved=false;
    // VERIFY ANGLES
    float angles[3];
    
    
    GetClientEyeAngles( client, angles );
    for( int i = 0; i < 3; i++ ) {
        if( FloatAbs(angles[i] - defuse_angles[client][i]) > DEFUSE_ANGLE_THRESHOLD ) {
            player_moved=true;
            break;
        }
    }

    if( !player_moved ) {
        float pos[3];
        GetClientAbsOrigin( client, pos );

        for( int i = 0; i < 3; i++ ) {
            pos[i] -= defuse_position[client][i];
            pos[i] *= pos[i];
        }
        
        float dist = pos[0] + pos[1] + pos[2];

        if( dist >= (DEFUSE_POSITION_THRESHOLD*DEFUSE_POSITION_THRESHOLD) ) {
            player_moved = true;
        }
    }

    if( player_moved ) {
        PrintHintText( client, "Wearing Vest Interrupted." );
        defuse_userid[client] = 0;
        return Plugin_Stop;
    }


    defuse_time[client]++;
    if( defuse_time[client] < 3 ) {
        char message[16] = "Wearing Vest.";
        
        for( int i = 0; i < defuse_time[client]; i++ )
            StrCat( message, 16, "." );

        PrintHintText( client, message );
    } else {
    	GivePlayerItem(client, "item_heavyassaultsuit");
        Client_SetArmor(client, 100)
        SetEntityHealth(client, GetClientHealth(client) + 50);
        wearingBallisticVest[client] = true;
        if(EntityOwner[defuse_target[client]] != client)
        	add_message_in_queue(EntityOwner[defuse_target[client]], KSR_BALLISTIC_VEST_SHARE, MESSAGE_POINTS[KSR_BALLISTIC_VEST_SHARE])
 		
        // defuse mine and give to player
        //UnhookSingleEntityOutput( defuse_target[client], "OnBreak", MineBreak );
        //AcceptEntityInput( defuse_target[client], "Break" );
        defuse_userid[client] = 0;

        

        return Plugin_Stop;
    }

    return Plugin_Handled;
}

//----------------------------------------------------------------------------------------------------------------------
public Action BallisticOpen_OnPlayerRunCmd( int client, int &buttons )
{
    if( IsValidClient(client) ) 
    {
        if( (buttons & IN_USE) == 0 ) {
        
            if( defuse_userid[client] && !defuse_cancelled[client] ) { // is defuse in progress?
                defuse_cancelled[client] = true;
                PrintHintText( client, "Opening Cancelled." );
            }
        }
    }
}


void Ballistic_OnGameFrame()
{
    //decl String:szClass[65]; 
    int i = -1;
    while((i = FindEntityByClassname(i, "cod_ballisitcdrop")) != INVALID_ENT_REFERENCE )
    {
        if(IsValidEntity(i) && PackageFalling[i]) 
        { 
			float vecOrigin[3], vecPos[3], vecAng[3] = {90.0, 0.0, 0.0}; 
			GetEntityOrigin(i, vecOrigin)
            //GetClientAbsOrigin(i, vecOrigin); 
			Handle trace = TR_TraceRayFilterEx(vecOrigin, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit, i);
			TR_GetEndPosition(vecPos, trace); 
			if( /*GetVectorDistance(vecOrigin, vecPos)*/ vecOrigin[2] - vecPos[2] > 100.0 ) 
			{ 
				StartPara(i,false);
				TeleportParachute(i);
			}
			else
			{
				EndPara(i);
				PackageFalling[i] = false;
			} 
            
			CloseHandle(trace);

		}   
	}
}

public Action Vest_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetClientTeam(attacker) != GetClientTeam(EntityOwner[victim]))
	{
		entityDamage[victim] += damage;
		if(entityDamage[victim] >= /*500.0*/Entity_GetHealth(victim))
		{
			AcceptEntityInput(victim, "break", attacker, attacker);
			//PrintToChatAll(" \x04***\x01 %N destroyed an Strafe run Helicopter! \x04***\x01", attacker)
		}
		else
		{
			PrintHintText(attacker, "        Ballistic Vest\n        HP: <font color='#ff0000'>%0.f</font>", /*500.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else
	{
		PrintHintText(attacker, "\n      Ballistic Vest is <font color='#00ff00'>FRIENDLY</font>");
	}
}

public void VestTouch(int BallisticVest, int iEntity) 
{
	//int iClient = GetEntDataEnt2(iGrenade, OFFSET_THROWER);
	AcceptEntityInput(BallisticVest, "DisableMotion");
	SDKUnhook(BallisticVest, SDKHook_Touch, GrenadeTouch);
}

