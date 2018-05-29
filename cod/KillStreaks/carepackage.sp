/*

   _____          _____  ______   _____        _____ _  __          _____ ______ 
  / ____|   /\   |  __ \|  ____| |  __ \ /\   / ____| |/ /    /\   / ____|  ____|
 | |       /  \  | |__) | |__    | |__) /  \ | |    | ' /    /  \ | |  __| |__   
 | |      / /\ \ |  _  /|  __|   |  ___/ /\ \| |    |  <    / /\ \| | |_ |  __|  
 | |____ / ____ \| | \ \| |____  | |  / ____ \ |____| . \  / ____ \ |__| | |____ 
  \_____/_/    \_\_|  \_\______| |_| /_/    \_\_____|_|\_\/_/    \_\_____|______|
                                                                                 
*/

void doCarePackage(int client)
{
	hasCarePackage[client] = false;

	add_message_in_queue(client, KSR_CARE_PACKAGE, MESSAGE_POINTS[KSR_CARE_PACKAGE])

	float fOrigin[3];
	GetEntityOrigin(client, fOrigin);   
	SpawnCrate( client, fOrigin, true, false );

	//PrintToChatAll(" %N has called in a care package at his location!", client);

	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/cp_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/cp_friendly.mp3", _, SNDCHAN_STATIC );
}

void doCarePackageFake(int client)
{
    hasAirDropTrap[client] = false;

    add_message_in_queue(client, KSR_AIRDROPTRAP, MESSAGE_POINTS[KSR_AIRDROPTRAP])

    float fOrigin[3];
    GetEntityOrigin(client, fOrigin);   
    SpawnCrate( client, fOrigin, true, true );

    //PrintToChatAll(" %N has called in a care package at his location!", client);

    for(int i = 1; i < MaxClients; i++)
        if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
            EmitSoundToClientAny(i, "cod/ks/cp_enemy.mp3", _, SNDCHAN_STATIC );
        else if( IsValidClient(i) )
            EmitSoundToClientAny(i, "cod/ks/cp_friendly.mp3", _, SNDCHAN_STATIC );
}

int SpawnCrate(int owner, float fOrigin[3] = { 0.0, 0.0, 0.0 }, bool Falling, bool fake)
{
    int iEntity = CreateEntityByName("prop_physics_override"); 
    //int iEntity = CreateEntityByName("prop_dynamic_override"); 
    if(!fake)
        DispatchKeyValue(iEntity, "classname", "cod_carepackage");
    else
        DispatchKeyValue(iEntity, "classname", "cod_carepackagefake");
    DispatchKeyValue(iEntity, "targetname", "prop");
    //Entity_SetClassName(iEntity, "cod_carepackage");
    DispatchKeyValue(iEntity, "model", "models/items/ammocrate_smg1.mdl");
    DispatchKeyValue(iEntity, "solid", "6");
    DispatchKeyValue(iEntity, "spawnflags", "256"); // set "usable" flag
    if ( DispatchSpawn(iEntity) ) 
    {
        if(fake)
        {
            int glow = CreatePlayerModelProp(iEntity, "models/items/ammocrate_smg1.mdl")
            EntityOwner[glow] = owner;
            if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
                SetupGlow(glow, 255, 0, 0, 255, 1000.0);
        }

        //if (SDKHookEx(iEntity, SDKHook_SetTransmit, OnSetTransmitEntity))
        //    SetupGlow(iEntity, 255, 0, 0, 255, 1000.0);
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
        SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_NO, 1);
       // SetEntProp(iEntity, Prop_Data, "m_iHealth", 50);
        HookSingleEntityOutput( iEntity, "OnPlayerUse", CPUsed, false );
        SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
        SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
        AcceptEntityInput(iEntity, "EnableMotion");
        EntityOwner[iEntity] = owner;
        return iEntity;
    }   
    //https://forums.alliedmods.net/showthread.php?t=279540 PARTICLE EFFECT
    return -1;
}

public void CPUsed(char[] output, int caller, int activator, float delay)
{ 
    // register last mine touched

    last_cp_used = caller;
//  PrintToChatAll( "debug1, %s, %d, %d, %d", output, caller, last_playeruse_id, last_playeruse_target );
     
}

public void openCP( Handle event, char[] name, bool dontBroadcast )
{
    
    int client = GetEventInt( event, "userid" );
    int target = GetEventInt( event, "entity" );

   

    if( last_cp_used == target ) { // verify this use event matches with the mine-use event
        client = GetClientOfUserId(client);
        if( client == 0 ) return; // client has disconnected

        char classname[32];
        Entity_GetClassName(target, classname, 32) 

        if(StrEqual(classname, "cod_carepackagefake"))
            if(GetClientTeam(client) == GetClientTeam(EntityOwner[target]))
                PrintToChat(client, " This is an Air Drop trap!");
            else    
                StartOpenPackage( client, target );
        else
            StartOpenPackage( client, target );
    }
}

void StartOpenPackage( int client, int target ) {
    if( defuse_userid[client] != 0 ) return; // defusal already in progress

    PrintHintText( client, "Opening." );

    defuse_time[client] = 0;
    defuse_target[client] = target;
    GetClientAbsOrigin( client, defuse_position[client] );
    GetClientEyeAngles( client, defuse_angles[client] );
    defuse_cancelled[client] = false;
    defuse_userid[client] = GetClientUserId(client);
    CreateTimer( 1.0, DefuseTimer, GetClientUserId(client), TIMER_REPEAT );

    EmitSoundToClient( client, "weapons/c4/c4_disarm.wav" );//
//  PlayMineSound( defuse_target[client], SOUND_DEFUSE );
    
}

//----------------------------------------------------------------------------------------------------------------------
public Action DefuseTimer( Handle timer, any client ) 
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
        PrintHintText( client, "Opening Interrupted." );
        defuse_userid[client] = 0;
        return Plugin_Stop;
    }


    defuse_time[client]++;
    if( defuse_time[client] < 3 ) {
        char message[16] = "Opening.";
        
        for( int i = 0; i < defuse_time[client]; i++ )
            StrCat( message, 16, "." );

        PrintHintText( client, message );
    } else {
        if(StrEqual(classname, "cod_carepackage"))
            doKillStreaks(client, true)
        else if(StrEqual(classname, "cod_carepackagefake"))
        {
            float pos[3];
            GetEntPropVector(defuse_target[client], Prop_Send, "m_vecOrigin", pos);

            // create explosion
            CreateExplosionDelayed( pos, EntityOwner[defuse_target[client]] );
            //SDKHooks_TakeDamage(client, codPackageOwner[defuse_target[client]], codPackageOwner[defuse_target[client]], 1000.0)
        }

        // defuse mine and give to player
        UnhookSingleEntityOutput( defuse_target[client], "OnBreak", MineBreak );
        AcceptEntityInput( defuse_target[client], "Break" );
        defuse_userid[client] = 0;

        

        return Plugin_Stop;
    }

    return Plugin_Handled;
}

//----------------------------------------------------------------------------------------------------------------------
public Action CarePackageOpen_OnPlayerRunCmd( int client, int &buttons )
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


void CarePackage_OnGameFrame()
{
    //decl String:szClass[65]; 
    int i = -1;
    while((i = FindEntityByClassname(i, "cod_carepackage")) != INVALID_ENT_REFERENCE )
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
    int p = -1;
    while((p = FindEntityByClassname(p, "cod_carepackagefake")) != INVALID_ENT_REFERENCE )
    {
        if(IsValidEntity(p) && PackageFalling[p]) 
        { 
            float vecOrigin[3], vecPos[3], vecAng[3] = {90.0, 0.0, 0.0}; 
            GetEntityOrigin(p, vecOrigin)
            //GetClientAbsOrigin(i, vecOrigin); 
            Handle trace = TR_TraceRayFilterEx(vecOrigin, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit, p);
            TR_GetEndPosition(vecPos, trace); 
            if( /*GetVectorDistance(vecOrigin, vecPos)*/ vecOrigin[2] - vecPos[2] > 100.0 ) 
            { 
                StartPara(p,false);
                TeleportParachute(p);
            }
            else
            {
                EndPara(p);
                PackageFalling[p] = false;
            } 
            
            CloseHandle(trace);

        }   
    }
}