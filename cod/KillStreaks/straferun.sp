public void doStrafeRun(int client)
{
	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/straferun_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/straferun_friendly.mp3", _, SNDCHAN_STATIC );

	add_message_in_queue(client, KSR_STRAFE_RUN, MESSAGE_POINTS[KSR_STRAFE_RUN])

	hasStrafeRun[client] = false;

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

	Handle data;
	data = CreateDataPack();
	CreateDataTimer(2.0, StrafeRunCallBack, data)   	
	WritePackFloat(data, vecPos2[0])
	WritePackFloat(data, vecPos2[1])
	WritePackFloat(data, vecPos2[2])
	WritePackFloat(data, ang[0])
	WritePackFloat(data, ang[1])
	WritePackFloat(data, ang[2])
	WritePackCell(data, client);

	float dir[3];
	GetAngleVectors(ang, NULL_VECTOR, dir, NULL_VECTOR);
        
	ScaleVector(dir, 300.0);
	AddVectors(vecPos2, dir, vecPos2);

//GetAngleVectors(const Float:angle[3], Float:fwd[3], Float:right[3], Float:up[3])

	//vecPos2[0] += 300.0

	Handle data2;
	data2 = CreateDataPack();
	CreateDataTimer(3.0, StrafeRunCallBack, data2)   	
	WritePackFloat(data2, vecPos2[0])
	WritePackFloat(data2, vecPos2[1])
	WritePackFloat(data2, vecPos2[2])
	WritePackFloat(data2, ang[0])
	WritePackFloat(data2, ang[1])
	WritePackFloat(data2, ang[2])
	WritePackCell(data2, client);

	GetAngleVectors(ang, NULL_VECTOR, dir, NULL_VECTOR);
        
	ScaleVector(dir, -600.0);
	AddVectors(vecPos2, dir, vecPos2);

	//vecPos2[0] -= 600.0

	Handle data3;
	data3 = CreateDataPack();
	CreateDataTimer(3.0, StrafeRunCallBack, data3)   	
	WritePackFloat(data3, vecPos2[0])
	WritePackFloat(data3, vecPos2[1])
	WritePackFloat(data3, vecPos2[2])
	WritePackFloat(data3, ang[0])
	WritePackFloat(data3, ang[1])
	WritePackFloat(data3, ang[2])
	WritePackCell(data3, client);

	GetAngleVectors(ang, NULL_VECTOR, dir, NULL_VECTOR);
        
	ScaleVector(dir, 900.0);
	AddVectors(vecPos2, dir, vecPos2);

	//vecPos2[0] += 900.0

	Handle data4;
	data = CreateDataPack();
	CreateDataTimer(4.0, StrafeRunCallBack, data4)   	
	WritePackFloat(data4, vecPos2[0])
	WritePackFloat(data4, vecPos2[1])
	WritePackFloat(data4, vecPos2[2])
	WritePackFloat(data4, ang[0])
	WritePackFloat(data4, ang[1])
	WritePackFloat(data4, ang[2])
	WritePackCell(data4, client);

	GetAngleVectors(ang, NULL_VECTOR, dir, NULL_VECTOR);
        
	ScaleVector(dir, -1200.0);
	AddVectors(vecPos2, dir, vecPos2);

	//vecPos2[0] -= 1200.0

	Handle data5;
	data5 = CreateDataPack();
	CreateDataTimer(4.0, StrafeRunCallBack, data5)   	
	WritePackFloat(data5, vecPos2[0])
	WritePackFloat(data5, vecPos2[1])
	WritePackFloat(data5, vecPos2[2])
	WritePackFloat(data5, ang[0])
	WritePackFloat(data5, ang[1])
	WritePackFloat(data5, ang[2])
	WritePackCell(data5, client);

}

public Action StrafeRunCallBack(Handle timer, any data) 
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


	int iEntity = CreateEntityByName("prop_dynamic_override"); 
	DispatchKeyValue(iEntity, "classname", "straferun_helicopter");
	DispatchKeyValue(iEntity, "targetname", "prop");
	DispatchKeyValue(iEntity, "model", "models/props_vehicles/helicopter_rescue.mdl");
	DispatchKeyValue(iEntity, "solid", "6");
	if ( DispatchSpawn(iEntity) ) 
	{
		Entity_SetGlobalName(iEntity, "airsupport");
		
		SetEntityMoveType(iEntity, MOVETYPE_NOCLIP);

		TeleportEntity(iEntity, pos, ang, NULL_VECTOR);

		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntProp(iEntity, Prop_Data, "m_iHealth", 3000);

		HookSingleEntityOutput( iEntity, "OnBreak", HeliDestroy, true );

		SetVariantString("3ready");//3ready
		AcceptEntityInput(iEntity, "SetAnimation");
		SetEntPropFloat(iEntity, Prop_Send, "m_flPlaybackRate" , 1.0); 

		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  0);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 0);
		AcceptEntityInput(iEntity, "EnableMotion");

		ActivateEntity(iEntity)

		char buffer[25];
		//Format(buffer, sizeof(buffer), "!self,Kill,,%0.1f,-1", 60.0);
		Format(buffer, sizeof(buffer), "!self,Break,,%0.1f,-1", 30.0);
		DispatchKeyValue(iEntity, "OnUser1", buffer);
		AcceptEntityInput(iEntity, "FireUser1");

		entityDamage[iEntity] = 0.0;
		HeliNextFire[iEntity] = 0.0;
		EntityOwner[iEntity] = client;

		SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);

		//EmitSoundToAllAny("vehicles/loud_helicopter_lp_01.wav", entity = SOUND_FROM_PLAYER, channel = SNDCHAN_AUTO, level = SNDLEVEL_NORMAL, flags = SND_NOFLAGS, Float:volume = SNDVOL_NORMAL, pitch = SNDPITCH_NORMAL, speakerentity = -1, const Float:origin[3] = NULL_VECTOR, const Float:dir[3] = NULL_VECTOR, bool:updatePos = true, Float:soundtime = 0.0)
		EmitSoundToAll("vehicles/loud_helicopter_lp_01.wav", iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos, NULL_VECTOR, true, 0.0)
		
    }
}

public void StrafeRun_OnGameFrame()
{
	int helicopter = -1;
	while((helicopter = FindEntityByClassname(helicopter, "straferun_helicopter")) != INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(helicopter))
		{
			if(!IsValidClient(EntityOwner[helicopter]))
				AcceptEntityInput(helicopter, "break", 0, 0);
			

			float velocity[3], angle[3];
			GetEntPropVector(helicopter, Prop_Data, "m_angRotation", angle);
			GetAngleVectors(angle, velocity, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(velocity, 2000.0);

            /*float velocity[3] = { 0.0, 250.0, 0.0 };
            ScaleVector(velocity, 10.0)*/	

			TeleportEntity(helicopter, NULL_VECTOR, NULL_VECTOR, velocity)
			//PrintToChatAll("found aircraft, applying velo")
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsValidEntity(helicopter) && IsValidClientAlive(client) && GetClientTeam(client) != GetClientTeam(EntityOwner[helicopter]))
				{
					if(FindTargetInViewCone(helicopter, client, 4000.0, 180.0, true) && IsVisibleTo(helicopter, client) && !hasPerk(client, "Blind Eye"))
					{
						float bulletDestination[3];
						GetEntityOrigin(client, bulletDestination);
						bulletDestination[2] += 45.0;

						float bulletOrigin[3];
						GetEntityOrigin(helicopter, bulletOrigin);

						float dir[3];
						GetAngleVectors(angle, dir, NULL_VECTOR, NULL_VECTOR);
				        
						ScaleVector(dir, 50.0);
						AddVectors(bulletOrigin, dir, bulletOrigin);


						if(GetGameTime() >= HeliNextFire[helicopter])
						{
							CreateBulletTrace(bulletOrigin, bulletDestination, 3000.0, 2.0, 2.0, "200 200 0");
							EmitAmbientSound( ")weapons/negev/negev-1.wav", bulletOrigin, _, SNDLEVEL_GUNFIRE  );

							HeliNextFire[helicopter] = GetGameTime() + 0.25;
						}

						//if( GetGameTime() >= NextHeliSoundLoop[helicopter])
						//{

						//	EmitAmbientSoundAny("cod/loud_helicopter_lp_01.mp3", bulletOrigin, helicopter, 125 );
						//	NextHeliSoundLoop[helicopter] = GetGameTime() + 3.0;
						//}
						SDKHooks_TakeDamage(client, helicopter, EntityOwner[helicopter], 2.5, _, -1, _, _);
						damage_count[client]++;
						//PrintToChatAll("FIRE")
						break;
					}
				}
			}
		}
	}	
}

public Action Straferun_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetClientTeam(attacker) != GetClientTeam(EntityOwner[victim]))
	{
		entityDamage[victim] += damage;
		if(entityDamage[victim] >= /*250.0*/Entity_GetHealth(victim))
		{
			AcceptEntityInput(victim, "break", attacker, attacker);
			PrintToChatAll(" \x04***\x01 %N destroyed an Strafe run Helicopter! \x04***\x01", attacker)
		}
		else
		{
			PrintHintText(attacker, "        Strafe run Helicopter\n        HP: <font color='#ff0000'>%0.f</font>", /*250.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else
	{
		PrintHintText(attacker, "\n      Strafe run Helicopter is <font color='#00ff00'>FRIENDLY</font>");
	}
}