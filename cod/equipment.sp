 
 /*
   _____ ______ __  __ _______ ________   __
  / ____|  ____|  \/  |__   __|  ____\ \ / /
 | (___ | |__  | \  / |  | |  | |__   \ V / 
  \___ \|  __| | |\/| |  | |  |  __|   > <  
  ____) | |____| |  | |  | |  | |____ / . \ 
 |_____/|______|_|  |_|  |_|  |______/_/ \_\
*/

public void DoGrenade(int iEntity, const char[] classname) 
{
	char checkClassname[32]
	Entity_GetClassName(iEntity, checkClassname, 32);

	if(StrEqual(classname, "hegrenade_projectile") )
    {	
    	CreateTimer( 0.0, OnGrenadeCreated, EntIndexToEntRef(iEntity) );
    	if(!StrEqual(checkClassname, "airstrike_nade") || !StrEqual(checkClassname, "predator_missile"))
    		SDKHook(iEntity, SDKHook_SpawnPost, OnEntitySpawned);
    }
	if(StrEqual(classname, "flashbang_projectile"))
    {	
    	SDKHook(iEntity, SDKHook_SpawnPost, OnEntitySpawnedFlash);
    }
}

public Action OnGrenadeCreated(Handle timer, any ref)
{
	int ent = EntRefToEntIndex( ref );

	if ( ent != INVALID_ENT_REFERENCE )
	{
		SetEntProp(ent, Prop_Data, "m_nNextThinkTick", -1);
	}
}

public void OnEntitySpawned(int iGrenade)
{
	// Needed only for CSS.
	CreateTimer(0.0, InitGrenade, iGrenade, TIMER_FLAG_NO_MAPCHANGE);
}



public void GrenadeTouch(int iGrenade, int iEntity) 
{
	int iClient = GetEntDataEnt2(iGrenade, OFFSET_THROWER);

	if(hasEquipment(iClient, "Semtex"))
	{
		//Stick once
		SDKUnhook(iGrenade, SDKHook_StartTouch, GrenadeTouch);
		
		//Stick if player
		if(iEntity > 0 && iEntity <= MaxClients)
		{
			StickGrenade(iEntity, iGrenade);
		}
		//Stick to object
		else if(GetEntityMoveType(iGrenade) != MOVETYPE_NONE)
		{
			SetEntityMoveType(iGrenade, MOVETYPE_NONE);
		}
	}
	else if(hasEquipment(iClient, "Bouncy Betty"))
	{
		BettyTouch(iGrenade);
		return;
	}
}


public Action InitGrenade(Handle timer, any iGrenade)
{

	char Classname[32];
	GetEntityClassname(iGrenade, Classname, 32)

	if(StrEqual(Classname, "reaper_missile") || StrEqual(Classname, "predator_missile"))
	{
		SDKHook(iGrenade, SDKHook_StartTouch, OnStartTouchExplode);
		return;
	}

	if(!IsValidEntity(iGrenade) || !StrEqual(Classname, "hegrenade_projectile"))
	{
		return;
	}
	


	int iClient = GetEntDataEnt2(iGrenade, OFFSET_THROWER);
	
	if(iClient < 1 || iClient > MaxClients)
	{
		return;
	}

	char Model[128];
	Entity_GetModel(iGrenade, Model, 128)
	int glow = CreatePlayerModelProp(iGrenade, Model)
	EntityOwner[glow] = iClient
	if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
		SetupGlow(glow, 255, 0, 0, 255, 1000.0);

	
	SetEntDataFloat(iGrenade, OFFSET_DAMAGE, 125.0);
	SetEntDataFloat(iGrenade, OFFSET_RADIUS, 350.0);


	if(hasEquipment(iClient, "Bouncy Betty"))
	{
		InitBetty(iGrenade);
		return;
	}


	explodeNade(2.0, iGrenade);
	

	//Set normal grenade properties

	
	if(hasEquipment(iClient, "Semtex")) 
	{
		float fOrigin[3];
		GetEntityOrigin(iGrenade, fOrigin);
		EmitAmbientSoundAny("cod/semtex.mp3", fOrigin, iGrenade );
		CreateGlow(iGrenade);
		//SetEntityRenderFx(iGrenade,RENDERFX_FLICKER_FAST);
		SDKHook(iGrenade, SDKHook_StartTouch, GrenadeTouch);
	}
}

public void OnStartTouchExplode(int iGrenade, int iEntity) 
{
	float pos[3];
	GetEntPropVector(iGrenade, Prop_Send, "m_vecOrigin", pos);

	// create explosion
	CreateExplosionDelayed( pos, GetEntPropEnt( iGrenade, Prop_Data, "m_hThrower" ) );

	char Classname[32];
	Entity_GetClassName(iGrenade, Classname, 32)

	if(StrEqual(Classname, "predator_missile")) 
	{
		SetEntPropFloat(EntityOwner[iGrenade], Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetClientViewEntity(EntityOwner[iGrenade], EntityOwner[iGrenade]);	
		predAttacked[EntityOwner[iGrenade]] = false;	
		InPredator[EntityOwner[iGrenade]] = false;
		showGlow[EntityOwner[iGrenade]] = false;
	}

	RemoveEdict(iGrenade)
}

void explodeNade(float timer, int iGrenade)
{
	CreateTimer( timer , Timer_Detonate, iGrenade );
}

//Explode the grenade, <3 blodia
public Action Timer_Detonate(Handle timer, any ref)
{
	int ent = EntRefToEntIndex( ref );
	if ( ent != INVALID_ENT_REFERENCE )
	{
		SetEntProp( ent, Prop_Data, "m_nNextThinkTick", 1); 
		SetEntProp( ent, Prop_Data, "m_takedamage", 2 );
		SetEntProp( ent, Prop_Data, "m_iHealth", 1 );

		SDKHooks_TakeDamage(ent, 0, 0, 1.0);
	}
}

void StickGrenade(int iClient, int iGrenade)
{	
	add_message_in_queue(GetEntDataEnt2(iGrenade, OFFSET_THROWER), BM_STUCK, MESSAGE_POINTS[BM_STUCK])
	
	//Remove Collision
	SetEntProp(iGrenade, Prop_Send, "m_CollisionGroup", 2);
	
	//stop movement
	SetEntityMoveType(iGrenade, MOVETYPE_NONE);
	
	// Stick grenade to victim
	SetVariantString("!activator");
	AcceptEntityInput(iGrenade, "SetParent", iClient);
	SetVariantString("idle");
	AcceptEntityInput(iGrenade, "SetAnimation");
	
	//set properties
	SetEntDataFloat(iGrenade, OFFSET_DAMAGE, 180.0);
	SetEntDataFloat(iGrenade, OFFSET_RADIUS, 350.0);
}

/*
  _______ _    _ _____   ______          _______ _   _  _____   _  ___   _ _____ ______ ______ 
 |__   __| |  | |  __ \ / __ \ \        / /_   _| \ | |/ ____| | |/ / \ | |_   _|  ____|  ____|
    | |  | |__| | |__) | |  | \ \  /\  / /  | | |  \| | |  __  | ' /|  \| | | | | |__  | |__   
    | |  |  __  |  _  /| |  | |\ \/  \/ /   | | | . ` | | |_ | |  < | . ` | | | |  __| |  __|  
    | |  | |  | | | \ \| |__| | \  /\  /   _| |_| |\  | |__| | | . \| |\  |_| |_| |    | |____ 
    |_|  |_|  |_|_|  \_\\____/   \/  \/   |_____|_| \_|\_____| |_|\_\_| \_|_____|_|    |______|
                                                                                               
 */
                                                                                              
public void OnKnifeFire(Handle event, char[] name,bool dontBroadcast)
{
	char weapon[20];	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	Client_GetActiveWeaponName(client, weapon, 20)

	if( StrContains(weapon, "knife", false) == -1 )
		return;

	if(InReaper[client] || KnifeAttack[client])
		return;
	
	if(g_iPlayerKniveCount[client] <= 0 || !hasEquipment(client, "Throwing Knife"))
		return;

	g_hTimerDelay[client] = CreateTimer(0.0, CreateKnife, client);

}	

public Action CreateKnife(Handle timer, any client)
{
	g_hTimerDelay[client] = INVALID_HANDLE;
	int slot_knife = GetPlayerWeaponSlot(client, CS_SLOT_KNIFE);
	int knife = CreateEntityByName("smokegrenade_projectile");

	if(knife == -1 || !DispatchSpawn(knife))
	{
		return;
	}

	// owner
	int team = GetClientTeam(client);
	SetEntPropEnt(knife, Prop_Send, "m_hOwnerEntity", client);
	SetEntPropEnt(knife, Prop_Send, "m_hThrower", client);
	SetEntProp(knife, Prop_Send, "m_iTeamNum", team);

	// player knife model
	char model[PLATFORM_MAX_PATH];
	if(slot_knife != -1)
	{
		GetEntPropString(slot_knife, Prop_Data, "m_ModelName", model, sizeof(model));
		if(ReplaceString(model, sizeof(model), "v_knife_", "w_knife_", true) != 1)
		{
			model[0] = '\0';
		}
		else if(ReplaceString(model, sizeof(model), ".mdl", "_dropped.mdl", true) != 1)
		{
			model[0] = '\0';
		}
	}


	if(!FileExists(model, true))
	{
		Format(model, sizeof(model), "%s", team == CS_TEAM_T ? "models/weapons/w_knife_default_t_dropped.mdl":"models/weapons/w_knife_default_ct_dropped.mdl");
	}

	// model and size
	SetEntProp(knife, Prop_Send, "m_nModelIndex", PrecacheModel(model));
	SetEntPropFloat(knife, Prop_Send, "m_flModelScale", 2.0);

	// knive elasticity
	SetEntPropFloat(knife, Prop_Send, "m_flElasticity", 0.2);
	// gravity
	SetEntPropFloat(knife, Prop_Data, "m_flGravity", 1.0);


	// Player origin and angle
	float origin[3], angle[3];
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angle);

	// knive new spawn position and angle is same as player's
	float pos[3];
	GetAngleVectors(angle, pos, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(pos, 50.0);
	AddVectors(pos, origin, pos);

	// knive flying direction and speed/power
	float player_velocity[3], velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", player_velocity);
	GetAngleVectors(angle, velocity, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(velocity, 2250.0);
	AddVectors(velocity, player_velocity, velocity);

	// spin knive
	float spin[] = {4000.0, 0.0, 0.0};
	SetEntPropVector(knife, Prop_Data, "m_vecAngVelocity", spin);

	// Stop grenade detonate and Kill knive after 1 - 30 sec
	SetEntProp(knife, Prop_Data, "m_nNextThinkTick", -1);
	char buffer[25];
	Format(buffer, sizeof(buffer), "!self,Kill,,%0.1f,-1", 5.0);
	DispatchKeyValue(knife, "OnUser1", buffer);
	AcceptEntityInput(knife, "FireUser1");

	// Throw knive!
	TeleportEntity(knife, pos, angle, velocity);
	SDKHookEx(knife, SDKHook_Touch, KnifeHit);

	PushArrayCell(g_hThrownKnives, EntIndexToEntRef(knife));
	g_iPlayerKniveCount[client]--;
}

public Action KnifeHit(int knife, int other)
{
	if(0 < other <= MaxClients) // Hits player index
	{
		int victim = other;

		SetVariantString("csblood");
		AcceptEntityInput(knife, "DispatchEffect");
		AcceptEntityInput(knife, "Kill");

		int attacker = GetEntPropEnt(knife, Prop_Send, "m_hThrower");
		int inflictor = GetPlayerWeaponSlot(attacker, CS_SLOT_KNIFE);

		if(inflictor == -1)
		{
			inflictor = attacker;
		}

		float victimeye[3];
		GetClientEyePosition(victim, victimeye);

		float damagePosition[3];
		float damageForce[3];

		GetEntPropVector(knife, Prop_Data, "m_vecOrigin", damagePosition);
		GetEntPropVector(knife, Prop_Data, "m_vecVelocity", damageForce);

		if(GetVectorLength(damageForce) == 0.0) // knife movement stop
		{
			return;
		}

		// Headshot - shitty way check it, clienteyeposition almost player back...
		float distance = GetVectorDistance(damagePosition, victimeye);
		g_bHeadshot[attacker] = distance <= 20.0;

		// damage values and type
		float damage[2];
		damage[0] = 200.0;
		damage[1] = 500.0;
		int dmgtype = DMG_SLASH|DMG_NEVERGIB;

		if(g_bHeadshot[attacker])
		{
			dmgtype |= DMG_HEADSHOT;
		}

		// create damage
		SDKHooks_TakeDamage(victim, inflictor, attacker,
		g_bHeadshot[attacker] ? damage[1]:damage[0],
		dmgtype, knife, damageForce, damagePosition);

		// blood effect
		int color[] = {255, 0, 0, 255};
		float dir[3];

		TE_SetupBloodSprite(damagePosition, dir, color, 1, PrecacheDecal("sprites/blood.vmt"), PrecacheDecal("sprites/blood.vmt"));
		TE_SendToAll(0.0);

		// ragdoll effect
		int ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");
		if(ragdoll != -1)
		{
			ScaleVector(damageForce, 50.0);
			damageForce[2] = FloatAbs(damageForce[2]); // push up!
			SetEntPropVector(ragdoll, Prop_Send, "m_vecForce", damageForce);
			SetEntPropVector(ragdoll, Prop_Send, "m_vecRagdollVelocity", damageForce);
		}

		got_bullseye[attacker] = true;
	}
	else if(FindValueInArray(g_hThrownKnives, EntIndexToEntRef(other)) != -1) // knives collide
	{
		SDKUnhook(knife, SDKHook_Touch, KnifeHit);
		float pos[3], dir[3];
		GetEntPropVector(knife, Prop_Data, "m_vecOrigin", pos);
		TE_SetupArmorRicochet(pos, dir);
		TE_SendToAll(0.0);

		DispatchKeyValue(knife, "OnUser1", "!self,Kill,,1.0,-1");
		AcceptEntityInput(knife, "FireUser1");
	}
}

public void OnEntityDestroyed(int entity)
{
	if(!IsValidEdict(entity))
	{
		return;
	}

	int index = FindValueInArray(g_hThrownKnives, EntIndexToEntRef(entity));
	if(index != -1) RemoveFromArray(g_hThrownKnives, index);

	//MissileDestroyed(entity)
}

/*

  ____   ____  _    _ _   _  _______     __  ____  ______ _______ _________     __
 |  _ \ / __ \| |  | | \ | |/ ____\ \   / / |  _ \|  ____|__   __|__   __\ \   / /
 | |_) | |  | | |  | |  \| | |     \ \_/ /  | |_) | |__     | |     | |   \ \_/ / 
 |  _ <| |  | | |  | | . ` | |      \   /   |  _ <|  __|    | |     | |    \   /  
 | |_) | |__| | |__| | |\  | |____   | |    | |_) | |____   | |     | |     | |   
 |____/ \____/ \____/|_| \_|\_____|  |_|    |____/|______|  |_|     |_|     |_|   
                                                                                  
*/

public Action BouncyBetty_OnPlayerRunCmd( int client, int &buttons )
{
	if(buttons & IN_ATTACK && hasEquipment(client, "Bouncy Betty"))
	{
		char weaponName[32];
		Client_GetActiveWeaponName(client, weaponName, 32)
		if(StrEqual(weaponName, "weapon_hegrenade"))
		{
			buttons &= ~IN_ATTACK
			buttons = IN_ATTACK2
			//if(buttons & IN_ATTACK && !( GetEntProp( client, Prop_Data, "m_nOldButtons" ) & IN_ATTACK ))
			//	PrintToChat(client, "You must right-click to throw the bouncy betty!")
		}	
	}
}

void InitBetty(int iGrenade)
{
	SetEntDataFloat(iGrenade, OFFSET_DAMAGE, 165.0);
	SetEntDataFloat(iGrenade, OFFSET_RADIUS, 350.0);
	SetEntPropFloat(iGrenade, Prop_Data, "m_flElasticity", 0.0);

	SDKHook(iGrenade, SDKHook_StartTouch, GrenadeTouch);
}

void BettyTouch(int iGrenade)
{
	Handle TraceRayHitAllButFeet;
	float StartOriginFeet[3];
	float AnglesFeet[3];
	AnglesFeet[0] = 90.0;
	//Initialize:
	GetEntityOrigin(iGrenade, StartOriginFeet);
	//Ray:
	//TraceRay = TR_TraceRayEx(StartOrigin, Angles, MASK_SOLID, RayType_Infinite);
	TraceRayHitAllButFeet = TR_TraceRayFilterEx(StartOriginFeet, AnglesFeet, MASK_SOLID, RayType_Infinite, TraceRayTryToHit, iGrenade);
	float EndOriginFeet[3];
	//Collision:
	if(TR_DidHit(TraceRayHitAllButFeet))
	{
		TR_GetEndPosition(EndOriginFeet, TraceRayHitAllButFeet);
	}	

	CloseHandle(TraceRayHitAllButFeet);	

	if(GetVectorDistance(StartOriginFeet, EndOriginFeet) < 10)
	{
		SetEntProp(iGrenade, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntProp(iGrenade, Prop_Data, "m_iHealth", 50);

		SetEntityMoveType(iGrenade, MOVETYPE_NONE);
		Entity_SetClassName(iGrenade, "Bouncy Betty");	
		CreateTimer(0.5, BouncyBettyCheck, iGrenade, TIMER_REPEAT);	
	}
}

public Action BouncyBettyCheck(Handle timer, any iGrenade)
{
	if(!IsValidEntity(iGrenade))
		return Plugin_Stop;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClientAlive(i) && IsValidClient(GetEntDataEnt2(iGrenade, OFFSET_THROWER)) && GetClientTeam(i) != GetClientTeam(GetEntDataEnt2(iGrenade, OFFSET_THROWER)))
		{
			if(Entity_GetDistance(i, iGrenade) <= 350.0)
			{
				float fOrigin[3];
				GetEntityOrigin(iGrenade, fOrigin);
				fOrigin[2] += 5;
				SetEntityMoveType(iGrenade, MOVETYPE_FLYGRAVITY);

				Entity_SetClassName(iGrenade, "hegrenade_projectile");

				float pushUP[3];
				pushUP[2] += 275.0;
				TeleportEntity(iGrenade, fOrigin, NULL_VECTOR, pushUP);

				explodeNade(1.0, iGrenade);
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

/*
   _____ _           __     ____  __  ____  _____  ______ 
  / ____| |        /\\ \   / /  \/  |/ __ \|  __ \|  ____|
 | |    | |       /  \\ \_/ /| \  / | |  | | |__) | |__   
 | |    | |      / /\ \\   / | |\/| | |  | |  _  /|  __|  
 | |____| |____ / ____ \| |  | |  | | |__| | | \ \| |____ 
  \_____|______/_/    \_\_|  |_|  |_|\____/|_|  \_\______|
*/                                                          
                                                          

public Action Claymore_OnPlayerRunCmd( int client, int &buttons )
{
	if(buttons & IN_ATTACK && hasEquipment(client, "Claymore"))
	{
		char weaponName[32];
		Client_GetActiveWeaponName(client, weaponName, 32)
		if(StrEqual(weaponName, "weapon_c4"))
		{
			RemoveEdict(Client_GetWeaponBySlot(client, CS_SLOT_C4));
			Client_ChangeToLastWeapon(client);
			createClaymore(client);
		}
	}
}

int createClaymore(int client)
{
	//int iEntity = CreateEntityByName("prop_physics_override"); 
	int iEntity = CreateEntityByName("prop_dynamic_override"); 

	float fOrigin[3], fAngle[3];
	GetEntityOrigin(client, fOrigin);

	//SetEntPropVector(client, Prop_Send, "m_angRotation", fAngle);
	GetClientEyeAngles(client, fAngle)
	fAngle[0] = 0.0;
	if(fAngle[1] >= 0.0)
		fAngle[1] = fAngle[1] - 180.0;
	else
		fAngle[1] = fAngle[1] + 180.0;
	fAngle[2] = 0.0;
	fOrigin[2] += 5;
	//fOrigin[2] += 75;

	DispatchKeyValue(iEntity, "classname", "claymore");
	DispatchKeyValue(iEntity, "targetname", "prop");
	Entity_SetClassName(iEntity, "claymore");
	DispatchKeyValue(iEntity, "model", "models/bf2/claymore.mdl");
	DispatchKeyValue(iEntity, "solid", "6");
	//SetEntPropFloat(iEntity, Prop_Send,"m_flModelScale", 0.25);
	if ( DispatchSpawn(iEntity) ) 
	{
		int glow = CreatePlayerModelProp(iEntity, "models/bf2/claymore.mdl")
		EntityOwner[glow] = client;
		if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
			SetupGlow(glow, 255, 0, 0, 255, 1000.0);

		Entity_SetOwner(iEntity, client)
		float temp[3];
		GetAngleVectors(fAngle, temp, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(temp, 500.0); 
		EmitAmbientSoundAny("cod/claymore.mp3", fOrigin, iEntity );
		TeleportEntity(iEntity, fOrigin, fAngle, temp); 
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
		SetEntProp(iEntity, Prop_Data, "m_iHealth", 50);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);
		AcceptEntityInput(iEntity, "DisableMotion");
		//Entity_SetOwner(iEntity, client)

		EntityOwner[iEntity] = client;

		CreateTimer(0.5, CheckClaymore, iEntity, TIMER_REPEAT)

		SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakeDamage);

		return iEntity;
	} 
	return -1;	
}

public Action Claymore_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(GetClientTeam(attacker) != GetClientTeam(EntityOwner[victim]))
	{
		entityDamage[victim] += damage;
		if(entityDamage[victim] >= /*500.0*/Entity_GetHealth(victim))
		{
			AcceptEntityInput(victim, "break", attacker, attacker);
			float Origin[3];
			GetEntityOrigin(victim, Origin);
			CreateExplosionDelayed( Origin, EntityOwner[victim] )
			//PrintToChatAll(" \x04***\x01 %N destroyed an Strafe run Helicopter! \x04***\x01", attacker)
		}
		else
		{
			PrintHintText(attacker, "        Claymore\n        HP: <font color='#ff0000'>%0.f</font>", /*500.0*/Entity_GetHealth(victim) - entityDamage[victim])
		}
	}
	else
	{
		PrintHintText(attacker, "\n      Claymore is <font color='#00ff00'>FRIENDLY</font>");
	}
}


public Action CheckClaymore(Handle timer, any claymore)
{
	if(!IsValidEntity(claymore))
		return Plugin_Stop;


	float fOrigin[3], fAngle[3];
	GetEntityOrigin(claymore, fOrigin);
	fOrigin[2] += 1;
	GetEntPropVector(claymore, Prop_Data, "m_angRotation", fAngle);
	//PrintToChatAll("Ang is %.2f %.2f %.2f", fAngle[0], fAngle[1], fAngle[2])

	fAngle[0] = 0.0;
	if(fAngle[1] >= 0.0)
		fAngle[1] = fAngle[1] - 180.0;
	else
		fAngle[1] = fAngle[1] + 180.0;
	fAngle[2] = 0.0;
	
	float rightLine[3], leftLine[3], rightOrigin[3], leftOrigin[3], rightLineEnd[3], LeftLineEnd[3];

	GetAngleVectors(fAngle, NULL_VECTOR, rightOrigin, NULL_VECTOR);
	ScaleVector(rightOrigin, 2.0); 
	AddVectors(fOrigin, rightOrigin, rightOrigin);

	GetAngleVectors(fAngle, NULL_VECTOR, leftOrigin, NULL_VECTOR);
	ScaleVector(leftOrigin, -2.0); 
	AddVectors(fOrigin, leftOrigin, leftOrigin);

	//GetAngleVectors(fAngle, NULL_VECTOR, rightLine, NULL_VECTOR);
	//ScaleVector(rightLine, 10.0); 
	//AddVectors(fOrigin, rightLine, rightLine);
	//GetVectorAngles(rightLine, rightLine)
	GetAngleVectors(fAngle, rightLine, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(rightLine, 7.0); 
	AddVectors(rightOrigin, rightLine, rightLine);

	//GetAngleVectors(fAngle, NULL_VECTOR, leftLine, NULL_VECTOR);
	//ScaleVector(leftLine, -10.0);
	//AddVectors(fOrigin, leftLine, leftLine);
	//GetVectorAngles(leftLine, leftLine)
	GetAngleVectors(fAngle, leftLine, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(leftLine, 7.0); 
	AddVectors(leftOrigin, leftLine, leftLine);

	GetAngleVectors(fAngle, NULL_VECTOR, LeftLineEnd, NULL_VECTOR);
	ScaleVector(LeftLineEnd, 7.0); 
	AddVectors(leftLine, LeftLineEnd, LeftLineEnd);

	GetAngleVectors(fAngle, NULL_VECTOR, rightLineEnd, NULL_VECTOR);
	ScaleVector(rightLineEnd, -7.0); 
	AddVectors(rightLine, rightLineEnd, rightLineEnd);

	TE_SetupBeamPoints(rightOrigin, LeftLineEnd, g_beamsprite, g_halosprite, 1, 1, 0.5, 0.2, 0.1, 1, 1.0, { 255, 0, 0, 50 }, 1)
	TE_SendToAll();
	TE_SetupBeamPoints(leftOrigin, rightLineEnd, g_beamsprite, g_halosprite, 1, 1, 0.5, 0.2, 0.1, 1, 1.0, { 255, 0, 0, 50 }, 1)
	TE_SendToAll();

	for(int i = 1; i<=MaxClients; i++)
	{
		if(IsValidClientAlive(i) && IsValidClient(EntityOwner[claymore]) && GetClientTeam(i) != GetClientTeam(EntityOwner[claymore]))
		{
			if(FindTargetInViewCone(claymore, i, 50.0, 180.0, false) )
			{
				explodeClaymore(claymore);
				break;
			}
		}
	}

	return Plugin_Continue;
}

void explodeClaymore(int claymore)
{
	int iGrenade = CreateEntityByName("hegrenade_projectile");
	SetEntDataFloat(iGrenade, OFFSET_DAMAGE, 165.0);
	SetEntDataFloat(iGrenade, OFFSET_RADIUS, 350.0); 
	SetEntPropEnt(iGrenade, Prop_Send, "m_hOwnerEntity", EntityOwner[claymore]);
	SetEntPropEnt(iGrenade, Prop_Send, "m_hThrower", EntityOwner[claymore]);
	SetEntProp(iGrenade, Prop_Send, "m_iTeamNum", GetClientTeam(EntityOwner[claymore]));
	DispatchSpawn(iGrenade);

	float Loc[3];
	GetEntityOrigin(claymore, Loc);
	TeleportEntity(iGrenade, Loc, NULL_VECTOR, NULL_VECTOR)

	char input[64];
	Format(input, sizeof(input), "!self,InitializeSpawnFromWorld,,0.1,-1");
	DispatchKeyValue(iGrenade, "OnUser1", input);
	AcceptEntityInput(iGrenade, "FireUser1", iGrenade);
	EmitAmbientSoundAny("cod/claymore_t.mp3", Loc, iGrenade );
	explodeNade(0.5, iGrenade);

	/*SetEntProp( iGrenade, Prop_Data, "m_nNextThinkTick", 1); 
	SetEntProp( iGrenade, Prop_Data, "m_takedamage", 2 );
	SetEntProp( iGrenade, Prop_Data, "m_iHealth", 1 );

	SDKHooks_TakeDamage(iGrenade, 0, 0, 1.0);*/

	RemoveEdict(claymore);
}

/*
   _____ _  _   
  / ____| || |  
 | |    | || |_ 
 | |    |__   _|
 | |____   | |  
  \_____|  |_|  
*/                
                

public Action C4_OnPlayerRunCmd( int client, int &buttons )
{
	if((buttons & IN_ATTACK || buttons & IN_ATTACK2 ) && hasEquipment(client, "C4"))
	{
		char weaponName[32];
		Client_GetActiveWeaponName(client, weaponName, 32)
		if(StrEqual(weaponName, "weapon_c4"))
		{
			buttons &= ~IN_ATTACK;
			//buttons &= ~IN_ATTACK2;

			if(buttons & IN_ATTACK2)
				plantC4(client);
			else {
				if(buttons & IN_ATTACK && !( GetEntProp( client, Prop_Data, "m_nOldButtons" ) & IN_ATTACK))
					PrintToChat(client, " You must right-click to set the C4!")
			}
		}
	}	
}

public void plantC4(int client)
{
	float trace_start[3], trace_angle[3], trace_end[3], trace_normal[3];
	GetClientEyePosition( client, trace_start );
	GetClientEyeAngles( client, trace_angle );
	GetAngleVectors( trace_angle, trace_end, NULL_VECTOR, NULL_VECTOR );
	NormalizeVector( trace_end, trace_end ); // end = normal

	// offset start by near point
	for( int i = 0; i < 3; i++ )
		trace_start[i] += trace_end[i] * 1.0;
	
	for( int i = 0; i < 3; i++ )
		trace_end[i] = trace_start[i] + trace_end[i] * 80.0;
	
	TR_TraceRayFilter( trace_start, trace_end, CONTENTS_SOLID|CONTENTS_WINDOW, RayType_EndPoint, TraceFilter_All, 0 );
	
	if( TR_DidHit( INVALID_HANDLE ) ) {

		Client_RemoveWeapon(client, "weapon_c4", true, true)

		TR_GetEndPosition( trace_end, INVALID_HANDLE );
		TR_GetPlaneNormal(INVALID_HANDLE, trace_normal);
		 
		SetupC4( client, trace_end, trace_normal );

	} else {
		PrintCenterText( client, "Invalid C4 position." );
	}
}

public void SetupC4( int client, float position[3], float normal[3] ) 
{
  
	char mine_name[64];
	Format( mine_name, 64, "equipmentc4%d", client );
	
	float angles[3];
	GetVectorAngles( normal, angles );
	
	int ent = CreateEntityByName( "prop_physics_override" );
	//int ent = CreateEntityByName( "prop_dynamic_override" )
	DispatchKeyValue( ent, "model", "models/weapons/w_c4_planted.mdl" );
	DispatchKeyValue( ent, "physdamagescale", "0.0");	// enable this to destroy via physics?
	DispatchKeyValue( ent, "health", "100" ); // use the set entity health function instead ?
	DispatchKeyValue( ent, "targetname", mine_name);
	DispatchKeyValue( ent, "spawnflags", "256"); // set "usable" flag
	DispatchSpawn( ent );

	int glow = CreatePlayerModelProp(ent, "models/weapons/w_c4_planted.mdl")
	EntityOwner[glow] = client;
	if (SDKHookEx(glow, SDKHook_SetTransmit, OnSetTransmitEntity))
		SetupGlow(glow, 255, 0, 0, 255, 1000.0);

	SetEntityMoveType(ent, MOVETYPE_NONE);
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	SetEntPropEnt(ent, Prop_Data, "m_hLastAttacker", client); // use this to identify the owner (see below)
	//SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity",client); //Set the owner of the mine (cant, it stops the owner from destroying it)
	SetEntityRenderColor( ent, 255, 255, 255, 255 );
	SetEntProp( ent, Prop_Send, "m_CollisionGroup", 2); // set non-collidable

	// offset placement slightly so it is on the wall's surface
	for( int i =0 ; i < 3; i++ ) {
		position[i] += normal[i] * 0.5;
	}
	TeleportEntity(ent, position, angles, NULL_VECTOR );//angles, NULL_VECTOR );

	// hook to explosion function
	HookSingleEntityOutput( ent, "OnBreak", MineBreak, true );

 	playersC4[client] = ent;

 	PrintToChat(client, " \x05Press F (+lookatweapon) to detonate the C4 !")
}

public bool TraceFilter_All( int entity, int contentsMask ) {
	return false;
}

public void MineBreak (char[] output, int caller, int activator, float delay)
{ 
	float pos[3];
	GetEntPropVector(caller, Prop_Send, "m_vecOrigin", pos);

	// create explosion
	CreateExplosionDelayed( pos, GetEntPropEnt( caller, Prop_Data, "m_hLastAttacker" ) );

	playersC4[caller] = -1;
}

public void explodeC4(int client)
{
	float pos[3];
	GetEntPropVector(playersC4[client], Prop_Send, "m_vecOrigin", pos);

	// create explosion
	CreateExplosionDelayed( pos, GetEntPropEnt( playersC4[client], Prop_Data, "m_hLastAttacker" ) );

	playersC4[client] = -1;
}


public void CreateExplosionDelayed( float vec[3], int owner ) {

	Handle data;
	CreateDataTimer( 0.1, CreateExplosionDelayedTimer, data );
	
	WritePackCell(data,owner);
	WritePackFloat(data,vec[0]);
	WritePackFloat(data,vec[1]);
	WritePackFloat(data,vec[2]);

}

public Action CreateExplosionDelayedTimer( Handle timer, Handle data ) {

	ResetPack(data);
	int owner = ReadPackCell(data);

	float vec[3];
	vec[0] = ReadPackFloat(data);
	vec[1] = ReadPackFloat(data);
	vec[2] = ReadPackFloat(data);

	CreateExplosion( vec, owner );
	
	return Plugin_Handled;
}

public void CreateExplosion( float vec[3], int owner ) {
	int ent = CreateEntityByName("env_explosion");	
	DispatchKeyValue(ent, "classname", "env_explosion");
	if(IsValidClient(owner))
		SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", owner); //Set the owner of the explosion
	else
		SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", 0);
	int mag = 200;
	int rad = 450;
	SetEntProp(ent, Prop_Data, "m_iMagnitude",mag); 
	if( rad != 0 ) {
		SetEntProp(ent, Prop_Data, "m_iRadiusOverride",rad); 
	}

	DispatchSpawn(ent);
	ActivateEntity(ent);

	char exp_sample[64];

	Format( exp_sample, 64, ")weapons/hegrenade/explode%d.wav", GetRandomInt( 3, 5 ) );

	EmitAmbientSound( exp_sample, vec, _, SNDLEVEL_GUNFIRE  );


	TeleportEntity(ent, vec, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(ent, "explode");
	AcceptEntityInput(ent, "kill");


}
