/*

   _____ ______ _   _ _______ _______     __   _____ _    _ _   _ 
  / ____|  ____| \ | |__   __|  __ \ \   / /  / ____| |  | | \ | |
 | (___ | |__  |  \| |  | |  | |__) \ \_/ /  | |  __| |  | |  \| |
  \___ \|  __| | . ` |  | |  |  _  / \   /   | | |_ | |  | | . ` |
  ____) | |____| |\  |  | |  | | \ \  | |    | |__| | |__| | |\  |
 |_____/|______|_| \_|  |_|  |_|  \_\ |_|     \_____|\____/|_| \_|
                                                                  
*/

// Sentry
//int SentryGunOwner[2048];

void SentryGun_OnGameFrame()
{
    int i = -1;
    while((i = FindEntityByClassname(i, "cod_sentry")) != INVALID_ENT_REFERENCE)
    {
        if(IsValidEntity(i)) 
        { 
        	if(!IsValidClient(EntityOwner[i]))
        		RemoveEdict(i);

        	for(int client = 1; client <= MaxClients; client++)
        	{
        		if(IsValidEntity(i) && IsValidClientAlive(client) && GetClientTeam(client) != GetClientTeam(EntityOwner[i]))
        		{
					if(FindTargetInViewCone(i, client, 1500.0, 90.0, false)/*IsVisibleTo(i, client)*/ && !hasPerk(client, "Blind Eye"))
					{
						SetVariantString("idle");//3ready
						AcceptEntityInput(i, "SetAnimation");

						SetPlayerAim(i, client);
						float fAngle[3];
						GetEntPropVector(i, Prop_Send, "m_angRotation", fAngle);
						fAngle[0] = 0.0;
						fAngle[2] = 0.0;
						TeleportEntity(i, NULL_VECTOR, fAngle, NULL_VECTOR);
						float bulletDestination[3];
						GetEntityOrigin(client, bulletDestination);
						bulletDestination[2] += 45.0;

						float bulletOrigin[3];
						GetEntityOrigin(i, bulletOrigin);
						bulletOrigin[2] += 45.0

						if(GetGameTime() >= SentryGunNextFire[i])
						{
							CreateBulletTrace(bulletOrigin, bulletDestination, 3000.0, 2.0, 2.0, "200 200 0");
							EmitAmbientSoundAny("cod/sentry_shoot.mp3", bulletOrigin, i, 50 );
							SentryGunNextFire[i] = GetGameTime() + 0.25;
						}
						
						SDKHooks_TakeDamage(client, i, EntityOwner[i], 2.0, _, -1, _, _);
						damage_count[client]++;
						break;
					}
        		}
        	}
		}   
	}
}

void doSentryGun(int client)
{
	if(GetEntityFlags(client) & FL_ONGROUND)
		CreateSentry(client);
	else
	{
		PrintToChat(client, "You must be on the ground to use Sentry Gun.")
		return
	}

	add_message_in_queue(client, KSR_SENTRY_GUN, MESSAGE_POINTS[KSR_SENTRY_GUN])

	hasSentryGun[client] = false;
	
	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/sentry_enemy.mp3", _, SNDCHAN_STATIC );
}

int CreateSentry(int client)
{
	float fOrigin[3], fAngle[3];
	GetEntityOrigin(client, fOrigin);
	GetClientEyeAngles(client, fAngle)
	fAngle[0] = 0.0;
	fAngle[2] = 0.0;

	int iEntity = CreateEntityByName("prop_dynamic_override"); 

	DispatchKeyValue(iEntity, "classname", "cod_sentry");
	DispatchKeyValue(iEntity, "targetname", "prop");
	Entity_SetClassName(iEntity, "cod_sentry");
	DispatchKeyValue(iEntity, "model", "models/cod/sentryv4/cod_sentryv4.mdl");
	//SetEntPropFloat(iEntity, Prop_Send,"m_flModelScale", 20.0);
	DispatchKeyValue(iEntity, "solid", "0");
	if ( DispatchSpawn(iEntity) ) 
	{
		Entity_SetGlobalName(iEntity, "airsupport");
		
		int glow = CreatePlayerModelProp(iEntity, "models/cod/sentryv4/cod_sentryv4.mdl")
		EntityOwner[glow] = client;
		if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
			SetupGlow(glow, 255, 0, 0, 255, 1000.0);

		//if (SDKHookEx(iEntity, SDKHook_SetTransmit, OnSetTransmitEntity))
		//	SetupGlow(iEntity, 255, 0, 0, 255, 1000.0);

		TeleportEntity(iEntity, fOrigin, fAngle, NULL_VECTOR); 
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);  
		SetEntProp(iEntity, Prop_Data, "m_iHealth", 1000);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
		//SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_PROJECTILE);
		//https://forums.alliedmods.net/showthread.php?t=80598 
		//COLLISION_GROUP_PROJECTILE
		SetEntityMoveType(iEntity, MOVETYPE_NONE);
		Entity_SetOwner(iEntity, client);

		EmitSoundToClientAny(client, "cod/ks/sentry_achieve1.mp3", _, SNDCHAN_STATIC );
		//AcceptEntityInput(iEntity, "EnableMotion");
		EntityOwner[iEntity] = client;
		Entity_SetOwner(iEntity, client)
		char _tmp[128];
		FormatEx(_tmp, sizeof(_tmp), "OnUser1 !self:kill::%f:-1", 90.0);
		SetVariantString(_tmp);
		AcceptEntityInput(iEntity, "AddOutput");
		AcceptEntityInput(iEntity, "FireUser1");

		SetVariantString("spin");//3ready
		AcceptEntityInput(iEntity, "SetAnimation");

		SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);

		CreateTimer(4.266, PlayAnimation, iEntity, TIMER_REPEAT)

		//if(!TeleportSkill(client, 50.0, _, iEntity))
		//{
		//	RemoveEdict(iEntity);
		//	hasSentryGun[client] = true;
		//}

		return iEntity;
	} 
	return -1;	
}

public Action PlayAnimation( Handle timer, any sentry)
{
	if(!IsValidEntity(sentry))	
		return Plugin_Stop;

	SetVariantString("spin");//3ready
	AcceptEntityInput(sentry, "SetAnimation");	

	return Plugin_Continue;
}

public Action Sentry_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
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
			PrintHintText(attacker, "        Sentry Gun\n        HP: <font color='#ff0000'>%0.f</font>", /*500.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else
	{
		PrintHintText(attacker, "\n      Sentry Gun is <font color='#00ff00'>FRIENDLY</font>");
	}
}
