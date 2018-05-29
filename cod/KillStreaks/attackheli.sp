/*

        _______ _______       _____ _  __  _    _ ______ _      _____ 
     /\|__   __|__   __|/\   / ____| |/ / | |  | |  ____| |    |_   _|
    /  \  | |     | |  /  \ | |    | ' /  | |__| | |__  | |      | |  
   / /\ \ | |     | | / /\ \| |    |  <   |  __  |  __| | |      | |  
  / ____ \| |     | |/ ____ \ |____| . \  | |  | | |____| |____ _| |_ 
 /_/    \_\_|     |_/_/    \_\_____|_|\_\ |_|  |_|______|______|_____|
                                                                      
*/

public void doAttackHeli(int client)
{
	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/heli_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/heli_friendly.mp3", _, SNDCHAN_STATIC );

	add_message_in_queue(client, KSR_ATTACK_HELICOPTER, MESSAGE_POINTS[KSR_ATTACK_HELICOPTER])

	hasAttackHeli[client] = false;

	CreateTimer(2.0, AttackHeliCallBack, client)   	
}

public Action AttackHeliCallBack(Handle timer, any client) 
{
	int iEntity = CreateEntityByName("prop_dynamic_override"); 

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

	DispatchKeyValue(iEntity, "classname", "attack_helicopter");
	DispatchKeyValue(iEntity, "targetname", "prop");
	DispatchKeyValue(iEntity, "model", "models/props_vehicles/helicopter_rescue.mdl");
	DispatchKeyValue(iEntity, "solid", "6");
	if ( DispatchSpawn(iEntity) ) 
	{
		if (SDKHookEx(iEntity, SDKHook_SetTransmit, OnSetTransmitEntity))
			SetupGlow(iEntity, 255, 0, 0, 255, 1000.0);
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

		HookSingleEntityOutput( iEntity, "OnBreak", HeliDestroy, true );

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
		float fAngle[3];
		SetPlayerAim(iEntity, HeliTarget[iEntity])
		GetEntPropVector(iEntity, Prop_Send, "m_angRotation", fAngle);
		fAngle[0] = 0.0;
		fAngle[2] = 0.0;
		TeleportEntity(iEntity, NULL_VECTOR, fAngle, NULL_VECTOR);

		SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);

		EmitSoundToAll("vehicles/loud_helicopter_lp_01.wav", iEntity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecPos2, NULL_VECTOR, true, 0.0)
		
		//AirstrikeOwner[iEntity] = client ;

		/*switch(GetRandomInt(0, 1))
		{
			case 0: { EmitAmbientSoundAny("cod/ks/jet_fly1.mp3", endpos, iEntity, 125 ); }
			case 1: { EmitAmbientSoundAny("cod/ks/jet_fly2.mp3", endpos, iEntity, 125 ); }
		}*/
    }
}

public void HeliDestroy (char[] output, int caller, int activator, float delay)
{ 
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);

	// create explosion
	CreateExplosionDelayed( pos, caller );

	StopSound(caller, SNDCHAN_AUTO, "vehicles/loud_helicopter_lp_01.wav");
}

int getClosestEnemy(int client, int currenttarget)
{
	int target = -1;
	float distance = 99999.0;
	for(int i = 1; i <= MaxClients; i++)
		if(IsValidClientAlive(i) && GetClientTeam(i) != GetClientTeam(client) && currenttarget != i && !hasPerk(i, "Blind Eye"))
			if(Entity_GetDistance(client, i) < distance)
				target = i;

	if(target == -1)
		for(int i = 1; i <= MaxClients; i++)
			if(IsValidClientAlive(i) && GetClientTeam(i) != GetClientTeam(client) && currenttarget != i)
				if(Entity_GetDistance(client, i) < distance)
					target = i;		
	
	if(target == -1)
		for(int i = 1; i <= MaxClients; i++)
			if(IsValidClientAlive(i) && GetClientTeam(i) == GetClientTeam(client) && currenttarget != i)
				if(Entity_GetDistance(client, i) < distance)
					target = i;	

	return target;
}

public void AttackHeli_OnGameFrame()
{
	int helicopter = -1;
	while((helicopter = FindEntityByClassname(helicopter, "attack_helicopter")) != INVALID_ENT_REFERENCE)
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

			if(!IsValidClientAlive(HeliTarget[helicopter]) || ( Entity_GetDistance(helicopter, EntityOwner[helicopter]) > 4000.0 && Entity_GetDistance(helicopter, HeliTarget[helicopter]) > 2000.0)) 
			{
				//if(Entity_GetDistance(helicopter, HeliTarget[helicopter]) >  4000.0)
				//{
					float fAngle[3];
					
					HeliTarget[helicopter] = getClosestEnemy(EntityOwner[helicopter], HeliTarget[helicopter]);
					while(HeliTarget[helicopter] == -1)
						HeliTarget[helicopter] = getClosestEnemy(EntityOwner[helicopter], HeliTarget[helicopter]);
					SetPlayerAim(helicopter, HeliTarget[helicopter])
					GetEntPropVector(helicopter, Prop_Send, "m_angRotation", fAngle);
					fAngle[0] = 0.0;
					fAngle[2] = 0.0;
					TeleportEntity(helicopter, NULL_VECTOR, fAngle, NULL_VECTOR);
				//}
			}
			//else
			//{
			//	HeliTarget[helicopter] = getClosestEnemy(HeliOwner[helicopter]);
			//}

			//PrintToConsole(AirstrikeOwner[aircraft], "Aircraft is moving");
		}
	}	
}

public Action Heli_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetClientTeam(attacker) != GetClientTeam(EntityOwner[victim]))
	{
		entityDamage[victim] += damage;
		if(entityDamage[victim] >= /*1000.0*/Entity_GetHealth(victim))
		{
			AcceptEntityInput(victim, "break", attacker, attacker);
			PrintToChatAll(" \x04***\x01 %N destroyed an Attack Helicopter! \x04***\x01", attacker)
		}
		else
		{
			PrintHintText(attacker, "        Attack Helicopter\n        HP: <font color='#ff0000'>%0.f</font>", /*1000.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else
	{
		PrintHintText(attacker, "\n      Attack Helicopter is <font color='#00ff00'>FRIENDLY</font>");
	}
}