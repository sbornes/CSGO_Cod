/*

  _____  _____  ______ _____       _______ ____  _____    __  __ _____  _____ _____ _____ _      ______ 
 |  __ \|  __ \|  ____|  __ \   /\|__   __/ __ \|  __ \  |  \/  |_   _|/ ____/ ____|_   _| |    |  ____|
 | |__) | |__) | |__  | |  | | /  \  | | | |  | | |__) | | \  / | | | | (___| (___   | | | |    | |__   
 |  ___/|  _  /|  __| | |  | |/ /\ \ | | | |  | |  _  /  | |\/| | | |  \___ \\___ \  | | | |    |  __|  
 | |    | | \ \| |____| |__| / ____ \| | | |__| | | \ \  | |  | |_| |_ ____) |___) |_| |_| |____| |____ 
 |_|    |_|  \_\______|_____/_/    \_\_|  \____/|_|  \_\ |_|  |_|_____|_____/_____/|_____|______|______|
                                                                                                        
*/
int predEnt[MAXPLAYERS+1];
void doPredMissile(int client)
{
	add_message_in_queue(client, KSR_PREDATOR_MISSILE, MESSAGE_POINTS[KSR_PREDATOR_MISSILE])

	//hasPredatorMissile[client] = false;

	int missile = CreatePredatorMissile(client);

	if(IsValidEntity(missile))
	{
		hasPredatorMissile[client] = false;

		
		showGlow[client] = true;
		
		for(int i = 1; i < MaxClients; i++) {
			if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client)) {
				EmitSoundToClientAny(i, "cod/ks/predator_enemy.mp3", _, SNDCHAN_STATIC );
			}
			else if( IsValidClient(i) )
				EmitSoundToClientAny(i, "cod/ks/predator_friend.mp3", _, SNDCHAN_STATIC );
		}

	}
}



int CreatePredatorMissile(int client)
{
    int iEntity = CreateEntityByName("hegrenade_projectile"); 

    DispatchKeyValue(iEntity, "classname", "predator_missile");
    DispatchKeyValue(iEntity, "targetname", "prop");
    Entity_SetClassName(iEntity, "predator_missile");
    DispatchKeyValue(iEntity, "model", "models/weapons/W_missile_closed.mdl");
    SetEntDataFloat(iEntity, OFFSET_DAMAGE, 500.0);
    SetEntDataFloat(iEntity, OFFSET_RADIUS, 500.0); 
    DispatchKeyValue(iEntity, "solid", "6");
    SetEntProp(iEntity, Prop_Send, "m_iTeamNum", GetClientTeam(client));
    
    if ( DispatchSpawn(iEntity) ) 
    {
    	TE_SetupBeamFollow(iEntity, PrecacheModel("materials/sprites/smoke.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1.0, 5.0, 5.0, 1, {255, 255, 255, 255})
    	TE_SendToAll()
    	InPredator[client] = true;
    	predAttacked[client] = false;
    	SetEntProp(iEntity, Prop_Data, "m_nNextThinkTick", -1);
    	SetEntityModel(iEntity, "models/weapons/W_missile_closed.mdl")
    	Entity_SetGlobalName(iEntity, "airsupport");

    	SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
    	SetEntPropEnt(iEntity, Prop_Send, "m_hThrower", client);

    	SetEntPropEnt(iEntity, Prop_Send, "m_hEffectEntity", client);
    	float vecOrigin[3], vecPos[3], vecAng[3] = {-90.0, 0.0, 0.0}, fOrigin[3]; 
    	GetEntityOrigin(iEntity, vecOrigin)
    	GetEntityOrigin(client, fOrigin);
    	Handle trace = TR_TraceRayFilterEx(fOrigin, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit, iEntity);
    	TR_GetEndPosition(vecPos, trace); 

    	//fOrigin[2] = vecPos[2] - 100.0;
    	if(vecPos[2] < 670.0 || (vecPos[2] - 100.0 < 670.0))
    		vecPos[2] = fOrigin[2] + 500;
    	else
    		vecPos[2] -= 100.0;

    	//vecPos[2] = vecPos[2] - 150.0;
    	CloseHandle(trace);
    	TeleportEntity(iEntity, vecPos, NULL_VECTOR, NULL_VECTOR); 
    	//Client_SetViewOffset(client, view_as<float>({90.0, 0.0, 0.0}) )
    	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
    	AcceptEntityInput(iEntity, "EnableMotion");
    	//Entity_SetOwner(Psybeam_projectile, client)
    	//Client_SetViewOffset(client, view_as<float>{90.0, 0.0, 0.0} )
    	HookSingleEntityOutput( iEntity, "OnBreak", PredDestroy, true );

    	char buffer[25];
    	Format(buffer, sizeof(buffer), "!self,Kill,,%0.1f,-1", GetConVarFloat(PredTime));
    	DispatchKeyValue(iEntity, "OnUser1", buffer);
    	AcceptEntityInput(iEntity, "FireUser1");

    	playerPredTime[client] = GetGameTime() + GetConVarFloat(PredTime);

    	SetClientViewEntity(client, iEntity);

    	EntityOwner[iEntity] = client;
    	predEnt[client] = iEntity;
    	/*char input[64];
    	Format(input, sizeof(input), "!self,InitializeSpawnFromWorld,,1.0,-1");
    	DispatchKeyValue(iEntity, "OnUser1", input);
    	AcceptEntityInput(iEntity, "FireUser1", iEntity);	*/

    	//SDKHook(iEntity, SDKHook_StartTouch, PredMissileTouch);
    	//SetEntityMoveType(iEntity, MOVETYPE_FLY);

    	return iEntity;
	}  
    return -1;	
}

void PredatorMissile_OnGameFrame()
{
	int i = -1;
	while((i = FindEntityByClassname(i, "predator_missile")) != INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(i)) 
		{ 
			if(!IsValidClientAlive(EntityOwner[i]))
			{
				PrintHintText(EntityOwner[i], "\n      <font color='#ff0000'>Lost Control of Missile</font>")
				OnStartTouchExplode(i, EntityOwner[i])
				return;
        	}
        	//ScreenFade(EntityOwner[i], FFADE_IN|FFADE_PURGE|FFADE_MODULATE, { 200, 200, 200, 255 }, 1, 1);

        	/*float TargetVec[3];

			float pOrigin[3];
			GetEntityOrigin(EntityOwner[i], pOrigin);

			float OwnerAng[3];
			GetClientEyeAngles(EntityOwner[i], OwnerAng);
			float OwnerPos[3];
			GetClientEyePosition(EntityOwner[i], OwnerPos);
			TR_TraceRayFilter(OwnerPos, OwnerAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit, EntityOwner[i]);
			//TR_TraceRay(OwnerPos, OwnerAng, MASK_ALL, RayType_Infinite)
			float TargetPos[3];
			TR_GetEndPosition(TargetPos);
			MakeVectorFromPoints(pOrigin, TargetPos, TargetVec);

			float FinalVec[3];
			FinalVec = TargetVec;
			
			NormalizeVector(FinalVec, FinalVec);
			ScaleVector(FinalVec, 500.0);
			float FinalAng[3];
			GetVectorAngles(FinalVec, FinalAng);
			TeleportEntity(i, NULL_VECTOR, FinalAng, FinalVec);*/
			if(!predAttacked[EntityOwner[i]] && GetGameTime() >= PredSound[i])
			{
				float pOrigin[3];
				GetEntityOrigin(i, pOrigin);
				EmitAmbientSoundAny("cod/ks/pr_fly.mp3", pOrigin, i );
				PredSound[i] = GetGameTime() + 0.50;
			}
			float ang[3];
			float temp[3];
        	//GetEntPropVector(EntityOwner[i], Prop_Data, "m_angRotation", ang);
			GetClientEyeAngles(EntityOwner[i], ang)
			GetAngleVectors(ang, temp, NULL_VECTOR, NULL_VECTOR);
			//if(!predAttacked[EntityOwner[i]])
			//	ScaleVector(temp, 500.0);
			//else
			//	ScaleVector(temp, 2000.0)
			

			if(playerPredTime[EntityOwner[i]] > GetGameTime() )
			{
				if(!predAttacked[EntityOwner[i]]) 
				{
					ScaleVector(temp, 500.0);
					PrintHintText(EntityOwner[i], "      <font color='#00ff00'>SHOOT to speed up Missile</font>\n      Self detonation in <font color='#ff0000'>%.2f</font>s", playerPredTime[EntityOwner[i]] - GetGameTime())
				}
				else
				{
					PrintHintText(EntityOwner[i], "\n      Self detonation in <font color='#ff0000'>%.2f</font>s", playerPredTime[EntityOwner[i]] - GetGameTime())
					ScaleVector(temp, 2000.0);
				}	
			}
			else
			{
				PrintHintText(EntityOwner[i], "\n      <font color='#ff0000'>Self Detonated</font>")
				OnStartTouchExplode(i, EntityOwner[i])
				return;
			}

			TeleportEntity(i, NULL_VECTOR, ang, temp); 
		}
	}
}

public void OnPredMissileFire(Handle event, char[] name,bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(InPredator[client] && !predAttacked[client])
	{
		float pOrigin[3];
		GetEntityOrigin(predEnt[client], pOrigin);
		EmitAmbientSoundAny("cod/ks/pr_start.mp3", pOrigin, client );
		predAttacked[client] = true;
	}
}

public void PredMissileTouch(int iMissile, int iEntity) 
{

	SDKUnhook(iMissile, SDKHook_StartTouch, PredMissileTouch);

	SetEntPropFloat(EntityOwner[iMissile], Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetClientViewEntity(EntityOwner[iMissile], EntityOwner[iMissile]);
	showGlow[EntityOwner[iMissile]] = false;
	Entity_SetClassName(iMissile, "hegrenade_projectile")

	char input[64];
	Format(input, sizeof(input), "!self,InitializeSpawnFromWorld,,1.0,-1");
	DispatchKeyValue(iEntity, "OnUser1", input);
	AcceptEntityInput(iEntity, "FireUser1", iEntity);

	SetEntProp( iMissile, Prop_Data, "m_nNextThinkTick", 1); 
	SetEntProp( iMissile, Prop_Data, "m_takedamage", 2 );
	SetEntProp( iMissile, Prop_Data, "m_iHealth", 1 );

	SDKHooks_TakeDamage(iMissile, 0, 0, 1.0);

	/*char _tmp[128];
	FormatEx(_tmp, sizeof(_tmp), "OnUser1 !self:kill::%f:-1", 0.0);
	SetVariantString(_tmp);
	AcceptEntityInput(iMissile, "AddOutput");
	AcceptEntityInput(iMissile, "FireUser1");

	PrintToChat(PredatorMissileOwner[iMissile], "HAS TOUCHED")*/
}

public void MissileDestroyed(int entity)
{
	char Classname[32]
	Entity_GetClassName(entity, Classname, 32)

	if(StrEqual(Classname, "predator_missile")) 
	{
		SetEntPropFloat(EntityOwner[entity], Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetClientViewEntity(EntityOwner[entity], EntityOwner[entity]);
		showGlow[EntityOwner[entity]] = false;
	}
}

public void PredDestroy (char[] output, int caller, int activator, float delay)
{
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);

	//create explosion
	CreateExplosionDelayed( pos, EntityOwner[caller] );

	SetEntPropFloat(EntityOwner[caller], Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetClientViewEntity(EntityOwner[caller], EntityOwner[caller]);
	showGlow[EntityOwner[caller]] = false;
}