/*
           _____ _____   _____ _______ _____  _____ _  ________ 
     /\   |_   _|  __ \ / ____|__   __|  __ \|_   _| |/ /  ____|
    /  \    | | | |__) | (___    | |  | |__) | | | | ' /| |__   
   / /\ \   | | |  _  / \___ \   | |  |  _  /  | | |  < |  __|  
  / ____ \ _| |_| | \ \ ____) |  | |  | | \ \ _| |_| . \| |____ 
 /_/    \_\_____|_|  \_\_____/   |_|  |_|  \_\_____|_|\_\______|
                                                                
*/

public void doAirstrike(int client)
{
	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/air_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/air_friend.mp3", _, SNDCHAN_STATIC );

	add_message_in_queue(client, KSR_PRECISION_AIRSTRIKE, MESSAGE_POINTS[KSR_PRECISION_AIRSTRIKE])

	hasAirstrike[client] = false;

	float pos[3], ang[3];
	GetClientEyePosition(client, pos);
	GetClientEyeAngles(client, ang);

	Handle data;
	data = CreateDataPack();
	CreateDataTimer(2.0, AirStrikeCallBack, data)   	
	WritePackFloat(data, pos[0])
	WritePackFloat(data, pos[1])
	WritePackFloat(data, pos[2])
	WritePackFloat(data, ang[0])
	WritePackFloat(data, ang[1])
	WritePackFloat(data, ang[2])
	WritePackCell(data, client);	
}

public Action AirStrikeCallBack(Handle timer, any data) 
{
	float pos[3], ang[3];
	ResetPack(data);
	pos[0] = ReadPackFloat(data);
	pos[1] = ReadPackFloat(data);
	pos[2] = ReadPackFloat(data);
	ang[0] = ReadPackFloat(data);
	ang[1] = ReadPackFloat(data);
	ang[2] = ReadPackFloat(data);
	int client = ReadPackCell(data);
	//CloseHandle(data);

	if(!IsValidClient(client))	
		return;

	float EndOrigin[3];

	int iEntity = CreateEntityByName("hegrenade_projectile"); 

	TE_SetupBeamFollow(iEntity, PrecacheModel("materials/sprites/smoke.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1.0, 5.0, 5.0, 1, {255, 255, 255, 255})
	TE_SendToAll()

	Handle TraceRay = TR_TraceRayFilterEx(pos, ang, MASK_ALL, RayType_Infinite, TraceRayTryToHit, client);
	TR_GetEndPosition(EndOrigin, TraceRay);

	//TE_SetupBeamPoints(pos, EndOrigin, PrecacheModel("materials/sprites/laserbeam.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1, 1, 5.0, 1.0, 1.0, 5, 2.0, {255, 0, 0, 255}, 2)
	//TE_SendToAll()

	float vecAng[3] = {-90.0, 0.0, 0.0}, vecPos[3]; 

	Handle trace = TR_TraceRayFilterEx(EndOrigin, vecAng, MASK_ALL, RayType_Infinite, TraceRayTryToHit);
	TR_GetEndPosition(vecPos, trace); 

	//TE_SetupBeamPoints(EndOrigin, vecPos, PrecacheModel("materials/sprites/laserbeam.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1, 1, 5.0, 1.0, 1.0, 5, 2.0, {255, 0, 0, 255}, 2)
	//TE_SendToAll()

	if(vecPos[2] < 670.0 || (vecPos[2] - 100.0 < 670.0))
		vecPos[2] = EndOrigin[2] + 500;
	else
		vecPos[2] -= 100.0;

	float vecAng2[3] = {0.0, 0.0, 0.0}, vecPos2[3]; 

	ang[0] = 0.0;

	//PrintToChat(client, "ang is %.2f %2.f %2.f", ang[0], ang[1], ang[2])

	vecAng2[0] = 0.0;
	//vecAng2[2] = 0.0;

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

	//vecPos2[0] += 300.0;
	//EndOrigin[2] = 670.0;

	AirstrikeLocation[iEntity] = vecPos;
	AirstrikeLocation[iEntity][2] = vecPos2[2];

	//TE_SetupBeamPoints(vecPos, vecPos2, PrecacheModel("materials/sprites/laserbeam.vmt"), PrecacheModel("materials/sprites/halo.vmt"), 1, 1, 5.0, 1.0, 1.0, 5, 2.0, {255, 0, 0, 255}, 2)
	//TE_SendToAll()

	DispatchKeyValue(iEntity, "classname", "precision_airstrike");
	DispatchKeyValue(iEntity, "targetname", "prop");
	//DispatchKeyValue(iEntity, "model", "models/f18/f18.mdl");
	DispatchKeyValue(iEntity, "solid", "0");
	if ( DispatchSpawn(iEntity) ) 
	{

		Entity_SetGlobalName(iEntity, "airsupport");
		
		SetEntityMoveType(iEntity, MOVETYPE_NOCLIP);

		TeleportEntity(iEntity, vecPos2, ang, NULL_VECTOR);

		float endpos[3], dir[3];
		GetAngleVectors(ang, dir, NULL_VECTOR, NULL_VECTOR);
        
		ScaleVector(dir, 50.0);
		AddVectors(vecPos2, dir, endpos);

		TeleportEntity(iEntity, endpos, ang, NULL_VECTOR);

		SetEntityModel(iEntity, "models/f18/f18.mdl")

		//SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		//SetEntProp(iEntity, Prop_Data, "m_iHealth", 200);

		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  0);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 0);
		AcceptEntityInput(iEntity, "EnableMotion");

		ActivateEntity(iEntity)
		//SetEntityMoveType(iEntity, MOVETYPE_FLYGRAVITY);
		char buffer[25];
		Format(buffer, sizeof(buffer), "!self,Kill,,%0.1f,-1", 10.0);
		DispatchKeyValue(iEntity, "OnUser1", buffer);
		AcceptEntityInput(iEntity, "FireUser1");

		EntityOwner[iEntity] = client ;
		//ActivateEntity(iEntity)

		switch(GetRandomInt(0, 1))
		{
			case 0: { EmitAmbientSoundAny("cod/ks/jet_fly1.mp3", endpos, iEntity, 125 ); }
			case 1: { EmitAmbientSoundAny("cod/ks/jet_fly2.mp3", endpos, iEntity, 125 ); }
		}
    }
}


public void PrecisionAirstrike_OnGameFrame()
{
	int aircraft = -1;
	while((aircraft = FindEntityByClassname(aircraft, "precision_airstrike")) != INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(aircraft))
		{
			if(!IsValidClient(EntityOwner[aircraft]))
				RemoveEdict(aircraft)

			static int tick = 0;
			tick++;
			float velocity[3], angle[3];
			GetEntPropVector(aircraft, Prop_Data, "m_angRotation", angle);
			GetAngleVectors(angle, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, 2000.0);

            /*float velocity[3] = { 0.0, 250.0, 0.0 };
            ScaleVector(velocity, 10.0)*/	

			TeleportEntity(aircraft, NULL_VECTOR, NULL_VECTOR, velocity)
			//PrintToChatAll("found aircraft, applying velo")

			if(Entity_GetDistanceOrigin(aircraft, AirstrikeLocation[aircraft]) < 300.0 && tick > 4)
			{
				tick = 0;
				AirstrikeDropBomb(aircraft);
				//PrintToChat(AirstrikeOwner[aircraft], "aircraft reached destination")
			}

			//PrintToConsole(AirstrikeOwner[aircraft], "Aircraft is moving");
		}
	}	
}


void AirstrikeDropBomb(int aircraft)
{
	int iGrenade = CreateEntityByName("hegrenade_projectile");

	//Entity_SetClassName(iGrenade, "airstrike_nade")
	DispatchKeyValue(iGrenade, "classname", "airstrike_nade");
	DispatchKeyValue(iGrenade, "model", "models/weapons/W_missile_closed.mdl");
	SetEntDataFloat(iGrenade, OFFSET_DAMAGE, 300.0);
	SetEntDataFloat(iGrenade, OFFSET_RADIUS, 500.0); 
	SetEntPropEnt(iGrenade, Prop_Send, "m_hOwnerEntity", EntityOwner[aircraft]);
	SetEntPropEnt(iGrenade, Prop_Send, "m_hThrower", EntityOwner[aircraft]);
	SetEntProp(iGrenade, Prop_Send, "m_iTeamNum", GetClientTeam(EntityOwner[aircraft]));
	DispatchSpawn(iGrenade);

	//Entity_SetGlobalName(iGrenade, "airstrike_nade");

	SetEntProp(iGrenade, Prop_Data, "m_nNextThinkTick", -1);

	float Loc[3];
	GetEntityOrigin(aircraft, Loc);
	Loc[2] -= 10.0;
	TeleportEntity(iGrenade, Loc, NULL_VECTOR, NULL_VECTOR)

	char input[64];
	Format(input, sizeof(input), "!self,InitializeSpawnFromWorld,,1.0,-1");
	DispatchKeyValue(iGrenade, "OnUser1", input);
	AcceptEntityInput(iGrenade, "FireUser1", iGrenade);	

	SDKHook(iGrenade, SDKHook_StartTouch, AirstrikeGrenadeTouch);

}

public void AirstrikeGrenadeTouch(int iGrenade, int iEntity) 
{
	//int iClient = GetEntDataEnt2(iGrenade, OFFSET_THROWER);

	SDKUnhook(iGrenade, SDKHook_StartTouch, GrenadeTouch);

	Entity_SetClassName(iGrenade, "hegrenade_projectile")	

	SetEntProp( iGrenade, Prop_Data, "m_nNextThinkTick", 1); 
	SetEntProp( iGrenade, Prop_Data, "m_takedamage", 2 );
	SetEntProp( iGrenade, Prop_Data, "m_iHealth", 1 );

	SDKHooks_TakeDamage(iGrenade, 0, 0, 1.0);
}

