
/*
   ____  _    _ _____ _____ _  __  _____  _____       __          __
  / __ \| |  | |_   _/ ____| |/ / |  __ \|  __ \     /\ \        / /
 | |  | | |  | | | || |    | ' /  | |  | | |__) |   /  \ \  /\  / / 
 | |  | | |  | | | || |    |  <   | |  | |  _  /   / /\ \ \/  \/ /  
 | |__| | |__| |_| || |____| . \  | |__| | | \ \  / ____ \  /\  /   
  \___\_\\____/|_____\_____|_|\_\ |_____/|_|  \_\/_/    \_\/  \/    
*/                                                                    
                                                                    

public Action DoQuickDraw(int client, int weapon) 
{
    if (weapon && hasPerk(client, "Quickdraw")) 
    {
        Handle data;
        data = CreateDataPack();
        WritePackCell(data, client);
        WritePackCell(data, weapon);

        CreateTimer(0.1, Timer_FastSwitch, data);

        return Plugin_Continue;
    }
    return Plugin_Continue;
}

public Action Timer_FastSwitch(Handle timer, any data) 
{
    ResetPack(data);
    int client = ReadPackCell(data);
    int weapon = ReadPackCell(data);
    CloseHandle(data);

    if (client && IsClientInGame(client) && IsPlayerAlive(client) && weapon && IsValidEdict(weapon)) 
    {
        UTIL_FastSwitch(client, weapon, false);
    }
}

/*
   ______      ________ _____  _  _______ _      _      
  / __ \ \    / /  ____|  __ \| |/ /_   _| |    | |     
 | |  | \ \  / /| |__  | |__) | ' /  | | | |    | |     
 | |  | |\ \/ / |  __| |  _  /|  <   | | | |    | |     
 | |__| | \  /  | |____| | \ \| . \ _| |_| |____| |____ 
  \____/   \/   |______|_|  \_\_|\_\_____|______|______|
                                                        
*/                                                        

public void SetupOverkill(int client)
{
    Client_RemoveWeapon(client, PlayerClassInfo[client][PrimaryWeapon], true, false)
    GivePlayerItem(client, PlayerClassInfo[client][SecondaryWeapon])
    OverKillClip[client] = Weapon_GetPrimaryClip(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
    OverKillAmmo[client] = GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")
    Client_RemoveWeapon(client, PlayerClassInfo[client][SecondaryWeapon], true, false)
    int primWep = GivePlayerItem(client, PlayerClassInfo[client][PrimaryWeapon])
    primClip[client] = Weapon_GetPrimaryClip(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
    primAmmo[client] = GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")
    Client_SetWeaponPlayerAmmoEx(client, primWep, primAmmo[client])

    int weapon = GivePlayerItem(client, "weapon_glock");
    //Entity_SetClassName(weapon, PlayerClassInfo[client][SecondaryWeapon]);
    Entity_SetGlobalName(weapon, PlayerClassInfo[client][SecondaryWeapon])
    Entity_SetGlobalName(primWep, PlayerClassInfo[client][PrimaryWeapon])

    Client_SetWeaponPlayerAmmoEx(client, weapon, OverKillAmmo[client])
    //int value = CSGO_GetItemDefinitionIndexByName(PlayerClassInfo[client][SecondaryWeapon]);
    //SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", value);
    WepSwitches[client] = false;
    //SDKHook(client, SDKHook_WeaponSwitch, DoOverKill);   
}

public Action DoOverKill(int client, int weapon)
{
    if(hasPerk(client, "Overkill"))
    {
        //SDKUnhook(client, SDKHook_WeaponSwitch, DoOverKill);

        char Classname[32];
        Entity_GetGlobalName(weapon, Classname, 32)
    

        if(StrEqual(Classname, PlayerClassInfo[client][SecondaryWeapon]))
        {
            if(IsValidEntity(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)) && Weapon_IsReloading(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)))
            {
                SetEntPropFloat(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_flTimeWeaponIdle", GetGameTime());
                SetEntPropFloat(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_flNextPrimaryAttack", GetGameTime());
                SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime());                
            }

            if(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY) == -1)
            {
                PrintToChat(client, " \x02Guns Bugged...  you will be respawned.")
                RespawnTime[client] = GetGameTime() + 5.0
                int Team[MAXPLAYERS+1];
                Team[client] = GetClientTeam(client)
                ChangeClientTeam(client, CS_TEAM_SPECTATOR)
                CS_SwitchTeam(client, Team[client])
                //CreateTimer(0.1, DoRespawn, client, TIMER_REPEAT);    
                CS_RespawnPlayer(client)            
            }

            primClip[client] = Weapon_GetPrimaryClip(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
            primAmmo[client] = GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")
            //Client_GetWeaponPlayerAmmoEx(client, Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), primAmmo[client])
            Client_RemoveWeapon(client, PlayerClassInfo[client][PrimaryWeapon], true, true)
            Client_RemoveWeapon(client, "weapon_glock", true, true)

            //Client_RemoveAllWeapons(client, "weapon_knife", true);
            //int weaponOverKill = Client_GiveWeaponAndAmmo(client, PlayerClassInfo[client][SecondaryWeapon], false, 0, 0, OverKillClip[client], 0)
            int weaponOverKill = GivePlayerItem(client, PlayerClassInfo[client][SecondaryWeapon])
            Weapon_SetPrimaryClip(weaponOverKill, OverKillClip[client])
            SetEntProp(weaponOverKill, Prop_Send, "m_iPrimaryReserveAmmoCount", OverKillAmmo[client]);
            //Weapon_SetPrimaryAmmoCount(weaponOverKill, OverKillAmmo[client]);
            //Client_SetWeaponPlayerAmmoEx(client, weaponOverKill, OverKillAmmo[client])

            //int value = CSGO_GetItemDefinitionIndexByName(PlayerClassInfo[client][SecondaryWeapon]);
            //SetEntProp(weaponOverKill, Prop_Send, "m_iItemDefinitionIndex", value);

            int normalWep = GivePlayerItem(client, "weapon_glock");
            //Entity_SetClassName(normalWep, PlayerClassInfo[client][PrimaryWeapon]);
            Entity_SetGlobalName(normalWep, PlayerClassInfo[client][PrimaryWeapon])
            //value = CSGO_GetItemDefinitionIndexByName(PlayerClassInfo[client][PrimaryWeapon]);
            //SetEntProp(normalWep, Prop_Send, "m_iItemDefinitionIndex", value);

            //PrintToChat(client, "2. Triggered OverKill Wep");

            Client_SetLastActiveWeapon(client, normalWep)

            if(!InReaper[client])
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
            else
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", Client_GetWeaponBySlot(client, CS_SLOT_KNIFE))

            SetEntProp(GetEntPropEnt(client, Prop_Send, "m_hViewModel"), Prop_Send, "m_nModelIndex", Entity_GetModelIndex(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)))

            WepSwitches[client] = true;
            //PrintToChat(client, "WepSwtich Called");
        }
        else if(StrEqual(Classname, PlayerClassInfo[client][PrimaryWeapon]) && WepSwitches[client])
        {
            if(IsValidEntity(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)) && Weapon_IsReloading(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)))
            {
                SetEntPropFloat(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_flTimeWeaponIdle", GetGameTime());
                SetEntPropFloat(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_flNextPrimaryAttack", GetGameTime());
                SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GetGameTime());                
            }

            if(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY) == -1)
            {
                PrintToChat(client, " \x02Guns Bugged... you will be respawned.")
                RespawnTime[client] = GetGameTime() + 5.0
                int Team[MAXPLAYERS+1];
                Team[client] = GetClientTeam(client)
                ChangeClientTeam(client, CS_TEAM_SPECTATOR)
                CS_SwitchTeam(client, Team[client])
                //CreateTimer(0.1, DoRespawn, client, TIMER_REPEAT);  
                CS_RespawnPlayer(client)

            }


            OverKillClip[client] = Weapon_GetPrimaryClip(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
            OverKillAmmo[client] = GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")
            //Client_GetWeaponPlayerAmmoEx(client, Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), OverKillAmmo[client])
            Client_RemoveWeapon(client, PlayerClassInfo[client][SecondaryWeapon], true, true)
            Client_RemoveWeapon(client, "weapon_glock", true, true)
            //Client_RemoveAllWeapons(client, "weapon_knife", true);
            //int normalWep = Client_GiveWeaponAndAmmo(client, PlayerClassInfo[client][PrimaryWeapon], false, 0, 0, primClip[client], 0);
            int normalWep = GivePlayerItem(client, PlayerClassInfo[client][PrimaryWeapon])
            Weapon_SetPrimaryClip(normalWep, primClip[client])
            SetEntProp(normalWep, Prop_Send, "m_iPrimaryReserveAmmoCount", primAmmo[client]);
    
            //Weapon_SetPrimaryAmmoCount(normalWep, primAmmo[client]);
            //Client_SetWeaponPlayerAmmoEx(client, normalWep, primAmmo[client])

            //int value = CSGO_GetItemDefinitionIndexByName(PlayerClassInfo[client][PrimaryWeapon]);
            //SetEntProp(normalWep, Prop_Send, "m_iItemDefinitionIndex", value);
 
            int weaponOverKill = GivePlayerItem(client, "weapon_glock");
            //Entity_SetClassName(weaponOverKill, PlayerClassInfo[client][SecondaryWeapon]);
            Entity_SetGlobalName(weaponOverKill, PlayerClassInfo[client][SecondaryWeapon])
            //value = CSGO_GetItemDefinitionIndexByName(PlayerClassInfo[client][SecondaryWeapon]);
            //SetEntProp(weaponOverKill, Prop_Send, "m_iItemDefinitionIndex", value);

            //PrintToChat(client, "2. Triggered Main Wep");

            Client_SetLastActiveWeapon(client, weaponOverKill)

            if(!InReaper[client])
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY))
            else
                SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", Client_GetWeaponBySlot(client, CS_SLOT_KNIFE))

            SetEntProp(GetEntPropEnt(client, Prop_Send, "m_hViewModel"), Prop_Send, "m_nModelIndex", Entity_GetModelIndex(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY)))

        }

        //SDKHook(client, SDKHook_WeaponSwitch, DoOverKill)
    }
}
