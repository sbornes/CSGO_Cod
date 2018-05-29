/*
  _____  ______          _____  ______ _____  
 |  __ \|  ____|   /\   |  __ \|  ____|  __ \ 
 | |__) | |__     /  \  | |__) | |__  | |__) |
 |  _  /|  __|   / /\ \ |  ___/|  __| |  _  / 
 | | \ \| |____ / ____ \| |    | |____| | \ \ 
 |_|  \_\______/_/    \_\_|    |______|_|  \_\                                              
*/                                              

int reaperEnt[MAXPLAYERS+1];
void doReaper(int client)
{
	if(!(GetGameTime() > lastHit[client]))
	{
		PrintToChat(client, "You can not use Reaper at this moment.")
		return;
	}

	Client_SetActiveWeapon(client, Client_GetWeaponBySlot(client, CS_SLOT_KNIFE))

	add_message_in_queue(client, KSR_REAPER, MESSAGE_POINTS[KSR_REAPER])

	int iEntity = CreateEntityByName("prop_dynamic_override"); 

	ReaperAmmo[client] = KS_ReaperAmmo.IntValue;
	HeliEntity[client] = iEntity;

	float ang[3];
	GetClientEyeAngles(client, ang);

	float clientPos[3], vecAng[3] = {-90.0, 0.0, 0.0}, vecPos[3]; 
	GetEntityOrigin(client, clientPos);

	Handle trace = TR_TraceRayFilterEx(clientPos, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
	TR_GetEndPosition(vecPos, trace); 

	if(vecPos[2] < 670.0 || (vecPos[2] - 100.0 < 670.0))
		vecPos[2] = clientPos[2] + 500;
	else
		vecPos[2] -= 100.0;

	float vecAng2[3] = {0.0, 0.0, 0.0}, vecPos2[3]; 

	ang[0] = 0.0;

	vecAng2[0] = 0.0;


	if(ang[1] >= 0.0)
		vecAng2[1] = ang[1] - 180.0;
	else
		vecAng2[1] = ang[1] + 180.0;


	//PrintToChat(client, "ang is %.2f %2.f %2.f", vecAng2[0], vecAng2[1], vecAng2[2])

	Handle trace2 = TR_TraceRayFilterEx(vecPos, vecAng2, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
	TR_GetEndPosition(vecPos2, trace2); 

	if(vecPos2[2] < 670.0 || (vecPos2[2] - 100.0 < 670.0))
		vecPos2[2] = vecPos[2];
	else
		vecPos2[2] -= 100.0;

	DispatchKeyValue(iEntity, "classname", "reaper");
	DispatchKeyValue(iEntity, "targetname", "prop");
	DispatchKeyValue(iEntity, "model", "models/props_vehicles/helicopter_rescue.mdl");
	DispatchKeyValue(iEntity, "solid", "6");

	char Buffer[64];
	Format(Buffer, sizeof(Buffer), "heli%d", iEntity);
	DispatchKeyValue(iEntity, "targetname", Buffer);

	if ( DispatchSpawn(iEntity) ) 
	{
		if (SDKHookEx(iEntity, SDKHook_SetTransmit, OnSetTransmitEntity))
			SetupGlow(iEntity, 255, 0, 0, 255, 1000.0);

		showGlow[client] = true;
		Entity_SetGlobalName(iEntity, "airsupport");

		SetEntityMoveType(iEntity, MOVETYPE_NOCLIP);

		TeleportEntity(iEntity, vecPos2, ang, NULL_VECTOR);

		/*float endpos[3], dir[3];
		GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
        
		ScaleVector(dir, 50.0);
		AddVectors(vecPos2, dir, endpos);

		TeleportEntity(iEntity, endpos, ang, NULL_VECTOR);*/

		//SetEntityModel(iEntity, "models/props_vehicles/helicopter_rescue.mdl")
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntProp(iEntity, Prop_Data, "m_iHealth", 3000);

		HookSingleEntityOutput( iEntity, "OnBreak", REAPERHeliDestroy, true );

		SetVariantString("3ready");//3ready
		AcceptEntityInput(iEntity, "SetAnimation");
		SetEntPropFloat(iEntity, Prop_Send, "m_flPlaybackRate" , 1.0); 

		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  0);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 0);
		AcceptEntityInput(iEntity, "EnableMotion");

		ActivateEntity(iEntity)
		//SetEntityMoveType(iEntity, MOVETYPE_FLYGRAVITY);
		char buffer[25];
		//Format(buffer, sizeof(buffer), "!self,Kill,,%0.1f,-1", 60.0);
		Format(buffer, sizeof(buffer), "!self,Break,,%0.1f,-1", 60.0);
		DispatchKeyValue(iEntity, "OnUser1", buffer);
		AcceptEntityInput(iEntity, "FireUser1");

		/*SetEntityRenderMode(iEntity, RENDER_GLOW)
		if(GetClientTeam(client) == CS_TEAM_CT)
			SetEntityRenderColor(iEntity, 0, 0, 150, 255)
		else
			SetEntityRenderColor(iEntity, 150, 0, 0, 255)*/

		entityDamage[iEntity] = 0.0;
		HeliNextFire[iEntity] = 0.0;
		EntityOwner[iEntity] = client;
		HeliTarget[iEntity] = getClosestEnemy(client, 0);
		while(HeliTarget[iEntity] == -1)
			HeliTarget[iEntity] = getClosestEnemy(EntityOwner[iEntity], HeliTarget[iEntity]);
		float fAngle[3];
		SetPlayerAim(iEntity, HeliTarget[iEntity])
		GetEntPropVector(iEntity, Prop_Send, "m_angRotation", fAngle);
		fAngle[0] = 0.0;
		fAngle[2] = 0.0;
		TeleportEntity(iEntity, NULL_VECTOR, fAngle, NULL_VECTOR);

		SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);

		EmitSoundToAll("vehicles/loud_helicopter_lp_01.wav", iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecPos2, NULL_VECTOR, true, 0.0)
	
	    //int iEntityCamera = CreateEntityByName("point_viewcontrol"); 

		//DispatchKeyValue(iEntityCamera, "classname", "test");
		//DispatchKeyValue(iEntityCamera, "targetname", "prop");
		//DispatchKeyValue(iEntityCamera, "model", "models/gibs/hgibs.mdl");
		//float endpos[3], dir[3];
		//GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
        
		//ScaleVector(dir, 50.0);
		//AddVectors(vecPos2, dir, endpos);
		
		//DispatchKeyValue(iEntityCamera, "solid", "6");
    	//if ( DispatchSpawn(iEntityCamera) ) 
        	//TeleportEntity(client, endpos, NULL_VECTOR, NULL_VECTOR);

		GetEntityOrigin(client, HeliOwnerLocation[client])
		//SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);  
		reaperEnt[client] = iEntity;
		InReaper[client] = true;
		hasReaper[client] = false;
		showGlow[client] = true;

		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 0);  
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // god on
	   	//SetClientViewEntity(client, iEntityCamera)

		//AirstrikeOwner[iEntity] = client ;

		/*switch(GetRandomInt(0, 1))
		{
			case 0: { EmitAmbientSoundAny("cod/ks/jet_fly1.mp3", endpos, iEntity, 125 ); }
			case 1: { EmitAmbientSoundAny("cod/ks/jet_fly2.mp3", endpos, iEntity, 125 ); }
		}*/
    }

	return;
}

public Action DoReaperSwitch(int client, int weapon) 
{
	if(InReaper[client])
	{
		Client_SetActiveWeapon(client, Client_GetWeaponBySlot(client, CS_SLOT_KNIFE))
	}
}

public void OnReaperFire(Handle event, char[] name,bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(InReaper[client] )
	{
		if(ReaperAmmo[client] == 0)
		{
			if(IsValidEntity(HeliEntity[client]))
				AcceptEntityInput(HeliEntity[client], "break", 0, 0);
			else
			{
				TeleportEntity(EntityOwner[client], HeliOwnerLocation[EntityOwner[client]], NULL_VECTOR, NULL_VECTOR);
				InReaper[EntityOwner[client]] = false;
				Client_SetActiveWeapon(EntityOwner[client], Client_GetWeaponBySlot(EntityOwner[client], CS_SLOT_PRIMARY))
				SetEntityRenderMode(EntityOwner[client], RENDER_TRANSCOLOR);
				SetEntityRenderColor(EntityOwner[client], 255, 255, 255, 255); 
				SetEntProp(EntityOwner[client], Prop_Data, "m_takedamage", 2, 1); // god off
				showGlow[EntityOwner[client]] = false;
			}
			return;
		}

		ReaperAmmo[client] --;

		PrintHintText(client, " Reaper Missile Ammo: %d", ReaperAmmo[client]);

		int iEntity = CreateEntityByName("hegrenade_projectile"); 

		DispatchKeyValue(iEntity, "classname", "reaper_missile");
		DispatchKeyValue(iEntity, "targetname", "prop");
		DispatchKeyValue(iEntity, "model", "models/weapons/W_missile_closed.mdl");
		DispatchKeyValue(iEntity, "solid", "6");

		if ( DispatchSpawn(iEntity) ) 
		{
			SetEntityModel(iEntity, "models/weapons/W_missile_closed.mdl")
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", reaperEnt[client]);
			SetEntPropEnt(iEntity, Prop_Send, "m_hThrower", client);

			SetEntPropEnt(iEntity, Prop_Send, "m_hEffectEntity", client);

			float origin[3];
			GetEntityOrigin(InReaper[client], origin)
			origin[2] = origin[2] - 50.0;
			TeleportEntity(iEntity, origin, NULL_VECTOR, NULL_VECTOR);

			SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
			SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
			AcceptEntityInput(iEntity, "EnableMotion");


			SetEntityMoveType(iEntity, MOVETYPE_FLY);

			TE_SetupBeamFollow(iEntity, PrecacheModel("materials/sprites/smoke.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1.0, 5.0, 5.0, 1, {255, 255, 255, 255})
			TE_SendToAll()
			//Entity_SetOwner(Psybeam_projectile, client)
			//Client_SetViewOffset(client, view_as<float>{90.0, 0.0, 0.0} )
			//missileOwner[iEntity] = client;
			//SDKHook(iEntity, SDKHook_StartTouch, OnStartTouchExplode);
		}
	}
}

public void REAPERHeliDestroy (char[] output, int caller, int activator, float delay)
{
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);

	// create explosion
	CreateExplosionDelayed( pos, caller );

	StopSound(caller, SNDCHAN_AUTO, "vehicles/loud_helicopter_lp_01.wav");

	//SDKUnhook(EntityOwner[caller], SDKHook_SetTransmit, Hook_SetTransmit);
	TeleportEntity(EntityOwner[caller], HeliOwnerLocation[EntityOwner[caller]], NULL_VECTOR, NULL_VECTOR);
	InReaper[EntityOwner[caller]] = false;
	Client_SetActiveWeapon(EntityOwner[caller], Client_GetWeaponBySlot(EntityOwner[caller], CS_SLOT_PRIMARY))
	SetEntityRenderMode(EntityOwner[caller], RENDER_TRANSCOLOR);
	SetEntityRenderColor(EntityOwner[caller], 255, 255, 255, 255); 
	SetEntProp(EntityOwner[caller], Prop_Data, "m_takedamage", 2, 1); // god off
	showGlow[EntityOwner[caller]] = false;
}

public void Reaper_OnGameFrame()
{
	int helicopterreaper = -1;
	while((helicopterreaper = FindEntityByClassname(helicopterreaper, "reaper")) != INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(helicopterreaper))
		{
			if(!IsValidClient(EntityOwner[helicopterreaper]))
				RemoveEdict(helicopterreaper)

			float velocity[3], angle[3];
			GetEntPropVector(helicopterreaper, Prop_Data, "m_angRotation", angle);
			velocity[0] = 0.0;
			velocity[2] = 0.0;
			GetAngleVectors(angle, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, 500.0);

			float HeliPos[3];
			GetEntPropVector(helicopterreaper, Prop_Send, "m_vecOrigin", HeliPos);

            /*float velocity[3] = { 0.0, 250.0, 0.0 };
            ScaleVector(velocity, 10.0)*/	

			TeleportEntity(helicopterreaper, NULL_VECTOR, NULL_VECTOR, velocity)

			if(!IsValidClientAlive(HeliTarget[helicopterreaper]) || ( Entity_GetDistance(helicopterreaper, EntityOwner[helicopterreaper]) > 4000.0 && Entity_GetDistance(helicopterreaper, HeliTarget[helicopterreaper]) > 2000.0)) 
			{
				/*HeliTarget[helicopterreaper] = getClosestEnemy(HeliOwner[helicopterreaper], HeliTarget[helicopterreaper]);

				float TargetVec[3];
				float TargetPos[3];

				GetEntityOrigin(HeliTarget[helicopterreaper], TargetPos)

				float CurrentVec[3];
				GetEntPropVector(helicopterreaper, Prop_Send, "m_vecVelocity", CurrentVec);
				float FinalVec[3];

				MakeVectorFromPoints(HeliPos, TargetPos, TargetVec);

				NormalizeVector(TargetVec, TargetVec);
				NormalizeVector(CurrentVec, CurrentVec);
				ScaleVector(TargetVec, 500.0 / 1000.0);
				AddVectors(TargetVec, CurrentVec, FinalVec);
				
				
				NormalizeVector(FinalVec, FinalVec);
				ScaleVector(FinalVec, 500.0);
				float FinalAng[3];
				GetVectorAngles(FinalVec, FinalAng);

				TeleportEntity(helicopterreaper, NULL_VECTOR, FinalAng, FinalVec);*/

					float fAngle[3];
					
					HeliTarget[helicopterreaper] = getClosestEnemy(EntityOwner[helicopterreaper], HeliTarget[helicopterreaper]);
					while(HeliTarget[helicopterreaper] == -1)
						HeliTarget[helicopterreaper] = getClosestEnemy(EntityOwner[helicopterreaper], HeliTarget[helicopterreaper]);
					SetPlayerAim(helicopterreaper, HeliTarget[helicopterreaper])
					GetEntPropVector(helicopterreaper, Prop_Send, "m_angRotation", fAngle);
					fAngle[0] = 0.0;
					fAngle[2] = 0.0;
					TeleportEntity(helicopterreaper, NULL_VECTOR, fAngle, NULL_VECTOR);
				//}
			}

			/*float TargetVec[3];
			float clientAngle[3], HeliOrigin[3];
			GetEntityOrigin(helicopterreaper, HeliOrigin)
			float pOrigin[3];
			GetEntityOrigin(HeliOwner[helicopterreaper], pOrigin);

			float OwnerAng[3];
			GetClientEyeAngles(HeliOwner[helicopterreaper], OwnerAng);
			float OwnerPos[3];
			GetClientEyePosition(HeliOwner[helicopterreaper], OwnerPos);
			TR_TraceRayFilter(OwnerPos, OwnerAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit, HeliOwner[helicopterreaper]);
			//TR_TraceRay(OwnerPos, OwnerAng, MASK_ALL, RayType_Infinite)
			float TargetPos[3];
			TR_GetEndPosition(TargetPos);
			MakeVectorFromPoints(pOrigin, TargetPos, TargetVec);

			float FinalVec[3];
			FinalVec = TargetVec;
			
			NormalizeVector(FinalVec, FinalVec);
			ScaleVector(FinalVec, 2.0);
			float FinalAng[3];
			GetVectorAngles(FinalVec, FinalAng);*/
			float HeliOrigin[3];
			GetEntityOrigin(helicopterreaper, HeliOrigin)
			HeliOrigin[2] -= 150.0;
			TeleportEntity(EntityOwner[helicopterreaper], HeliOrigin, NULL_VECTOR, NULL_VECTOR)
			ScreenFade(EntityOwner[helicopterreaper], FFADE_IN|FFADE_PURGE|FFADE_MODULATE, { 125, 125, 125, 255 }, 1, 1);
			//else
			//{
			//	HeliTarget[helicopter] = getClosestEnemy(HeliOwner[helicopter]);
			//}

			//PrintToConsole(AirstrikeOwner[aircraft], "Aircraft is moving");
		}
	}

}

public void ReaperMissile_OnGameFrame()
{
	int missilereaper = -1;
	while((missilereaper = FindEntityByClassname(missilereaper, "reaper_missile")) != INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(missilereaper))
		{
			float TargetVec[3];
			float NadePos[3];
			GetEntPropVector(missilereaper, Prop_Send, "m_vecOrigin", NadePos);

			int NadeOwner = GetEntPropEnt(missilereaper, Prop_Send, "m_hThrower");
			if(IsValidClientAlive(NadeOwner))
			{
				float OwnerAng[3];
				GetClientEyeAngles(NadeOwner, OwnerAng);
				float OwnerPos[3];
				GetClientEyePosition(NadeOwner, OwnerPos);
				TR_TraceRayFilter(OwnerPos, OwnerAng, MASK_SOLID, RayType_Infinite, DontHitOwnerOrNade, missilereaper);
				float TargetPos[3];
				TR_GetEndPosition(TargetPos);
				MakeVectorFromPoints(NadePos, TargetPos, TargetVec);	


				NormalizeVector(TargetVec, TargetVec);
				ScaleVector(TargetVec, 1500.0);
				float FinalAng[3];
				GetVectorAngles(TargetVec, FinalAng);
				TeleportEntity(missilereaper, NULL_VECTOR, FinalAng, TargetVec);
			}
		}
	}	
}

public bool DontHitOwnerOrNade(int entity, int contentsMask, any data)
{
	int NadeOwner = GetEntPropEnt(data, Prop_Send, "m_hThrower");
	int heli = GetEntPropEnt(data, Prop_Send, "m_hOwnerEntity")
	return ((entity != data) && (entity != NadeOwner) && (entity != heli));
}


public Action Reaper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetClientTeam(attacker) != GetClientTeam(EntityOwner[victim]))
	{
		entityDamage[victim] += damage;
		if(entityDamage[victim] >= /*250.0*/Entity_GetHealth(victim))
		{
			AcceptEntityInput(victim, "break", attacker, attacker);
			PrintToChatAll(" \x04***\x01 %N destroyed a Strafe run Helicopter! \x04***\x01", attacker)
		}
		else
		{
			PrintHintText(attacker, "        Reaper Helicopter\n        HP: <font color='#ff0000'>%0.f</font>", /*250.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else if( attacker != EntityOwner[victim] )
	{
		PrintHintText(attacker, "\n      Reaper Helicopter is <font color='#00ff00'>FRIENDLY</font>");
	}
}