/*
   _____ _      ______ _____ _____ _    _ _______    ____  ______   _    _          _   _ _____  
  / ____| |    |  ____|_   _/ ____| |  | |__   __|  / __ \|  ____| | |  | |   /\   | \ | |  __ \ 
 | (___ | |    | |__    | || |  __| |__| |  | |    | |  | | |__    | |__| |  /  \  |  \| | |  | |
  \___ \| |    |  __|   | || | |_ |  __  |  | |    | |  | |  __|   |  __  | / /\ \ | . ` | |  | |
  ____) | |____| |____ _| || |__| | |  | |  | |    | |__| | |      | |  | |/ ____ \| |\  | |__| |
 |_____/|______|______|_____\_____|_|  |_|  |_|     \____/|_|      |_|  |_/_/    \_\_| \_|_____/ 
                                                                                                                                                                                                  
*/

/*
Taken From
https://github.com/peace-maker/smrpg/blob/master/scripting/upgrades/smrpg_upgrade_fastreload.css.sp
*/

public Action SleightOfHand_OnPlayerRunCmd( int client, int &buttons )
{
	static bool s_ClientIsReloading[MAXPLAYERS+1];

	char sWeapon[64];
	int iWeapon = Client_GetActiveWeaponName(client, sWeapon, sizeof(sWeapon));
	if(iWeapon != INVALID_ENT_REFERENCE)
	{

		bool bIsReloading = Weapon_IsReloading(iWeapon);
		// Shotguns don't use m_bInReload but have their own m_reloadState
		if(!bIsReloading && (StrEqual(sWeapon, "weapon_nova") || StrEqual(sWeapon, "weapon_xm1014") || StrEqual(sWeapon, "weapon_sawedoff") || StrEqual(sWeapon, "weapon_mag7")) && GetEntProp(iWeapon, Prop_Send, "m_reloadState") > 0)
			bIsReloading = true;

		if(bIsReloading && !s_ClientIsReloading[client] && hasPerk(client, "Sleight of Hand"))
		{
			IncreaseReloadSpeed(client);
		}

		s_ClientIsReloading[client] = bIsReloading;
	}
}

public void DoShotgunsReload(int iEntity, const char[] classname) 
{
	if(StrEqual(classname, "weapon_nova") || StrEqual(classname, "weapon_xm1014") || StrEqual(classname, "weapon_sawedoff") || StrEqual(classname, "weapon_mag7") )
		SDKHook(iEntity, SDKHook_ReloadPost, Hook_OnReloadPost);
}

void IncreaseReloadSpeed(int client)
{
	char sWeapon[64];
	int iWeapon = Client_GetActiveWeaponName(client, sWeapon, sizeof(sWeapon));
	
	//PrintToChatAll("%N is reloading his weapon %d %s.", client, iWeapon, sWeapon);
	
	if(iWeapon == INVALID_ENT_REFERENCE)
		return;
	
	// No shotgun?
	bool bIsShotgun;
	if(StrEqual(sWeapon, "weapon_m3") || StrEqual(sWeapon, "weapon_xm1014"))
	{
		int iReloadState = GetEntProp(iWeapon, Prop_Send, "m_reloadState");
		// The shotgun isn't really reloading. (full or no ammo left)
		if(iReloadState == 0)
			return;
		
		bIsShotgun = true;
	}
	
	float fNextAttack = GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack");
	float fGameTime = GetGameTime();
	
	//PrintToChatAll("gametime %f, weapon nextattack %f, player nextattack %f, weapon idletime %f", fGameTime, fNextAttack, GetEntPropFloat(client, Prop_Send, "m_flNextAttack"), GetEntPropFloat(iWeapon, Prop_Send, "m_flTimeWeaponIdle"));
	
	float fReloadIncrease = 1.0 / 2.0;
	
	// Change the playback rate of the weapon to see it reload faster visually
	SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 1.0 / fReloadIncrease);
	
	int iViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(iViewModel != INVALID_ENT_REFERENCE)
		SetEntPropFloat(iViewModel, Prop_Send, "m_flPlaybackRate", 1.0 / fReloadIncrease);
	
	float fNextAttackNew = (fNextAttack - fGameTime) * fReloadIncrease;
	
	if(bIsShotgun)
	{
		Handle hData;
		CreateDataTimer(0.01, Timer_CheckShotgunEnd, hData, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		WritePackCell(hData, EntIndexToEntRef(iWeapon));
		WritePackCell(hData, GetClientUserId(client));
	}
	else
	{
		// Reset the playback rate after the gun reloaded.
		Handle hData;
		CreateDataTimer(fNextAttackNew, Timer_ResetPlaybackRate, hData, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(hData, EntIndexToEntRef(iWeapon));
		WritePackCell(hData, GetClientUserId(client));
	}
	
	// Tell the gun it can fire ammo faster again after reload
	// This acutally decreases the reload time
	fNextAttackNew += fGameTime;
	SetEntPropFloat(iWeapon, Prop_Send, "m_flTimeWeaponIdle", fNextAttackNew);
	SetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack", fNextAttackNew);
	SetEntPropFloat(client, Prop_Send, "m_flNextAttack", fNextAttackNew);
	
	//PrintToChatAll("new nextattack %f, client nextattack %f, weapon idletime %f", fNextAttackNew, GetEntPropFloat(client, Prop_Send, "m_flNextAttack"), GetEntPropFloat(iWeapon, Prop_Send, "m_flTimeWeaponIdle"));
}

public Action Timer_ResetPlaybackRate(Handle timer, any data)
{
	ResetPack(data);
	
	int iWeapon = EntRefToEntIndex(ReadPackCell(data));
	int client = GetClientOfUserId(ReadPackCell(data));
	
	if(iWeapon != INVALID_ENT_REFERENCE)	
		SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 1.0);
	
	if(client > 0)
		ResetClientViewModel(client);
	
	//PrintToChatAll("Reset playback rate of %d and client %d", iWeapon, client);
	
	return Plugin_Stop;
}

public Action Timer_CheckShotgunEnd(Handle timer, any data)
{
	ResetPack(data);
	
	int iWeapon = EntRefToEntIndex(ReadPackCell(data));
	int client = GetClientOfUserId(ReadPackCell(data));
	
	// Weapon is gone?!
	if(iWeapon == INVALID_ENT_REFERENCE)
	{
		if(client > 0)
			ResetClientViewModel(client);
		return Plugin_Stop;
	}
	
	int iOwner = Weapon_GetOwner(iWeapon);
	// Weapon dropped?
	if(iOwner <= 0)
	{
		// Reset the old client
		if(client > 0)
			ResetClientViewModel(client);
		
		// Reset weapon.
		SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 1.0);
		
		return Plugin_Stop;
	}

	int iReloadState = GetEntProp(iWeapon, Prop_Send, "m_reloadState");
	
	// Still reloading
	if(iReloadState > 0)
		return Plugin_Continue;
	
	// Done reloading.
	SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 1.0);
	
	
	if(client > 0)
		ResetClientViewModel(client);
	
	//PrintToChatAll("%N reloaded shotgun %d", client, iWeapon);
	
	return Plugin_Stop;
}

// Increase shotgun reload
public void Hook_OnReloadPost(int weapon, bool bSuccessful)
{
	int client = Weapon_GetOwner(weapon);
	if(client <= 0)
		return;
	
	if(GetEntProp(weapon, Prop_Send, "m_reloadState") != 2)
		return;
	
	if(!hasPerk(client, "Sleight of Hand"))
		return;

	// Fasten reload!
	float fReloadIncrease = 1.0 / 2.0;
	
	float fIdleTime = GetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle");
	float fGameTime = GetGameTime();
	float fIdleTimeNew = (fIdleTime - fGameTime) * fReloadIncrease + fGameTime;
	// This is the next time Reload is called for shotguns
	SetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle", fIdleTimeNew);
	
	//PrintToChatAll("%d reloadpost, success %d, reloadstate %d, gametime %f, wep nextattack %f, orig idle: %f, idle %f, clip1 %d, nextthink %d", weapon, bSuccessful, GetEntProp(weapon, Prop_Send, "m_reloadState"), GetGameTime(), GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack"), fIdleTime, GetEntPropFloat(weapon, Prop_Send, "m_flTimeWeaponIdle"), Weapon_GetPrimaryClip(weapon), GetEntProp(weapon, Prop_Send, "m_nNextThinkTick"));
}

stock void ResetClientViewModel(int client)
{
	int iViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(iViewModel != INVALID_ENT_REFERENCE)
		SetEntPropFloat(iViewModel, Prop_Send, "m_flPlaybackRate", 1.0);
}

/*
   _____  _____     __      ________ _   _  _____ ______ _____  
  / ____|/ ____|   /\ \    / /  ____| \ | |/ ____|  ____|  __ \ 
 | (___ | |       /  \ \  / /| |__  |  \| | |  __| |__  | |__) |
  \___ \| |      / /\ \ \/ / |  __| | . ` | | |_ |  __| |  _  / 
  ____) | |____ / ____ \  /  | |____| |\  | |__| | |____| | \ \ 
 |_____/ \_____/_/    \_\/   |______|_| \_|\_____|______|_|  \_\
*/                                                                
                                                               

int createMagazine(int client)
{
	int iEntity = CreateEntityByName("prop_physics_override"); 

	float fOrigin[3];
	GetEntityOrigin(client, fOrigin);

	DispatchKeyValue(iEntity, "classname", "Scavenger");
	DispatchKeyValue(iEntity, "targetname", "prop");
	Entity_SetClassName(iEntity, "ScavengercreateMagazine");
	DispatchKeyValue(iEntity, "model", "models/cod/magazine/magazine.mdl");
	DispatchKeyValue(iEntity, "solid", "6");

	if ( DispatchSpawn(iEntity) ) 
	{
		TeleportEntity(iEntity, fOrigin, NULL_VECTOR, NULL_VECTOR); 
		SetEntProp(iEntity, Prop_Data, "m_takedamage", DAMAGE_NO, 0);
		SetEntProp(iEntity, Prop_Send, "m_usSolidFlags",  152);
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 8);

		char _tmp[128];
		FormatEx(_tmp, sizeof(_tmp), "OnUser1 !self:kill::%f:-1", 30.0);
		SetVariantString(_tmp);
		AcceptEntityInput(iEntity, "AddOutput");
		AcceptEntityInput(iEntity, "FireUser1");

		SDKHook(iEntity, SDKHook_Touch, ScavengerTouch);

		return iEntity;
	} 
	return -1;	
}


public Action ScavengerTouch(int magazine, int other)
{
	if(0 < other <= MaxClients) // Hits player index
	{
		int client = other;

		if(hasPerk(other, "Scavenger"))
		{
			
			char WeaponName[32];
			Client_GetActiveWeaponName(client, WeaponName, 32);
			if(StrEqual(WeaponName, "weapon_knife"))
				Client_GetLastActiveWeaponName(client, WeaponName, 32);

			int weapon = Client_GetWeapon(client, WeaponName)
			int ammotype = -1;
			if(weapon != -1)
				ammotype = GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");

			if(ammotype != -1)
				GivePlayerAmmo(client, GetRandomInt(15, 25), ammotype, false)

			/*
			PrintToChat(client, "Active wep: %d", weapon)
			int SecondayAmmo = 0;
			//Client_GetWeaponPlayerAmmoEx(client, weapon, SecondayAmmo)
			SecondayAmmo = GetEntProp(client, Prop_Send, "m_iAmmo", _, GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"));

			PrintToChat(client, "Active wep ammo: %d", SecondayAmmo)

			SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
			Client_SetWeaponPlayerAmmoEx(client, weapon, SecondayAmmo + 20)
			PrintToChat(client, "Active wep new ammo: %d", SecondayAmmo + 20)*/
			RemoveEdict(magazine);
		}
		
	}
}
