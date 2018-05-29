public Action ClassMenu(int client)
{
	Handle menu = CreateMenu(ClassMenu_Handle);

	char szMsg[128];
	char szItems[128], szItems2[128], szItems3[128], szItems4[128], szItems5[128], szItems6[128];	
	Format(szMsg, sizeof( szMsg ), "Class Menu");
	SetMenuTitle(menu, szMsg);

	Format(szItems, sizeof( szItems ), "Grenadier" );
	AddMenuItem(menu, "class_id", szItems);
	
	Format(szItems2, sizeof( szItems2 ), "First Recon" );
	AddMenuItem(menu, "class_id", szItems2);

	Format(szItems3, sizeof( szItems3 ), "Overwatch" );
	AddMenuItem(menu, "class_id", szItems3);

	Format(szItems4, sizeof( szItems4 ), "Scout Sniper" );
	AddMenuItem(menu, "class_id", szItems4);

	Format(szItems5, sizeof( szItems5 ), "Riot Control" );
	AddMenuItem(menu, "class_id", szItems5);

	if( PlayerStatsInfo[client][Level] >= GetConVarInt(Class_CustomLevel))
	{
		Format(szItems6, sizeof( szItems6 ), "Custom Class" );
		AddMenuItem(menu, "class_id", szItems6);
	}
	else
	{
		Format(szItems6, sizeof( szItems6 ), "Custom Class (Lv:%d)", GetConVarInt(Class_CustomLevel) );
		AddMenuItem(menu, "class_id", szItems6, ITEMDRAW_DISABLED);
	}

	if(SelectedClass[client])
		SetMenuExitButton(menu, true);
	else
		SetMenuExitButton(menu, false);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}


void SetClass(int client, int standardClassID)
{
	switch(standardClassID)
	{
		case 0:
		{
			strcopy(PlayerClassStandardInfo[client][PrimaryWeapon], 32, "weapon_bizon");
			strcopy(PlayerClassStandardInfo[client][SecondaryWeapon], 32, "weapon_mp7");
			strcopy(PlayerClassStandardInfo[client][Equipment], 32, "Semtex");
			strcopy(PlayerClassStandardInfo[client][Tactical], 32, "Flash Grenade");
			strcopy(PlayerClassStandardInfo[client][PerkOne], 32, "Scavenger");
			strcopy(PlayerClassStandardInfo[client][PerkTwo], 32, "Overkill");
			strcopy(PlayerClassStandardInfo[client][PerkThree], 32, "Steady Aim");
			strcopy(PlayerClassStandardInfo[client][StrikePackage], 128, "Assault(UAV, Care Package, Strafe Run)");
		}

		case 1:
		{
			strcopy(PlayerClassStandardInfo[client][PrimaryWeapon], 32, "weapon_ump45");
			strcopy(PlayerClassStandardInfo[client][SecondaryWeapon], 32, "weapon_p250");
			strcopy(PlayerClassStandardInfo[client][Equipment], 32, "Frag");
			strcopy(PlayerClassStandardInfo[client][Tactical], 32, "Flash Grenade");
			strcopy(PlayerClassStandardInfo[client][PerkOne], 32, "Recon");
			strcopy(PlayerClassStandardInfo[client][PerkTwo], 32, "Quickdraw");
			strcopy(PlayerClassStandardInfo[client][PerkThree], 32, "Dead Silence");
			strcopy(PlayerClassStandardInfo[client][StrikePackage], 128, "Assault(UAV, Care Package, Strafe Run)");
		}

		case 2:
		{
			strcopy(PlayerClassStandardInfo[client][PrimaryWeapon], 32, "weapon_m249");
			strcopy(PlayerClassStandardInfo[client][SecondaryWeapon], 32, "weapon_deagle");
			strcopy(PlayerClassStandardInfo[client][Equipment], 32, "Frag");
			strcopy(PlayerClassStandardInfo[client][Tactical], 32, "Flash Grenade");
			strcopy(PlayerClassStandardInfo[client][PerkOne], 32, "Blind Eye");
			strcopy(PlayerClassStandardInfo[client][PerkTwo], 32, "Blast Shield");
			strcopy(PlayerClassStandardInfo[client][PerkThree], 32, "Sit Rep");
			strcopy(PlayerClassStandardInfo[client][StrikePackage], 128, "Support(UAV, Counter UAV, Sentry Gun)");
		}

		case 3:
		{
			strcopy(PlayerClassStandardInfo[client][PrimaryWeapon], 32, "weapon_ssg08");
			strcopy(PlayerClassStandardInfo[client][SecondaryWeapon], 32, "weapon_p250");
			strcopy(PlayerClassStandardInfo[client][Equipment], 32, "Frag");
			strcopy(PlayerClassStandardInfo[client][Tactical], 32, "Smoke Grenade");
			strcopy(PlayerClassStandardInfo[client][PerkOne], 32, "Extreme Condition");
			strcopy(PlayerClassStandardInfo[client][PerkTwo], 32, "Assassin");
			strcopy(PlayerClassStandardInfo[client][PerkThree], 32, "Marksman");
			strcopy(PlayerClassStandardInfo[client][StrikePackage], 128, "Assault(UAV, Care Package, Strafe Run");
		}

		case 4:
		{
			strcopy(PlayerClassStandardInfo[client][PrimaryWeapon], 32, "weapon_p90");
			strcopy(PlayerClassStandardInfo[client][SecondaryWeapon], 32, "weapon_usp_silencer");
			strcopy(PlayerClassStandardInfo[client][Equipment], 32, "Frag");
			strcopy(PlayerClassStandardInfo[client][Tactical], 32, "Concussion Grenade");
			strcopy(PlayerClassStandardInfo[client][PerkOne], 32, "Sleight of Hand");
			strcopy(PlayerClassStandardInfo[client][PerkTwo], 32, "Hardline");
			strcopy(PlayerClassStandardInfo[client][PerkThree], 32, "Stalker");
			strcopy(PlayerClassStandardInfo[client][StrikePackage], 128, "Support(UAV, Counter-UAV, Sentry Gun)");
		}
	}



	if(!IsFakeClient(client) && SelectedClass[client])
	{
		char sCookieValue[32];
		IntToString(standardClassID, sCookieValue, sizeof(sCookieValue));
		SetClientCookie(client, gLastClass, sCookieValue);
		//PrintToChat(client, "Your class will change next spawn.");
	}
	else if(!IsFakeClient(client) && !SelectedClass[client])
	{
		RespawnTime[client] = GetGameTime() + 5.0;
		SelectedClass[client] = true;
		//CreateTimer(0.1, DoRespawn, GetClientUserId(client), TIMER_REPEAT);
	}

	
	ChangeClassStandard[client] = true;
}


public int ClassMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { GrenadierMenu(client); }
			case 1: { First_ReconMenu(client); }
			case 2: { OverwatchMenu(client); }
			case 3: { Scout_SniperMenu(client); }
			case 4: { Riot_ControlMenu(client); }
			case 5: { CustomClassMenu(client); }
		}
	}
}

public Action GrenadierMenu(int client)
{
	Handle menu = CreateMenu(GrenadierMenu_Handle)

	char szMsg[512];
	char szItems[128];
	Format(szMsg, sizeof( szMsg ), "Class Grenadier: \n \
									Primary: Bizon \n \
									Secondary: MP7 \n \
									Equipment: Semtex \n \
									Tactical: Flash Grenade \n \
									Perk 1: Scavenger \n \
									Perk 2: Overkill \n \
									Perk 3: Steady Aim \n \
									Strike Package: Assault(Care Package, Strafe Run, Assault Drone) ");

	Format(szItems, sizeof( szItems ), "Change Class to Grenadier" );
	AddMenuItem(menu, "class_id", szItems);

	SetMenuTitle(menu, szMsg);

	//SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int GrenadierMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { SetClass(client, 0); }
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 
}

public Action First_ReconMenu(int client)
{
	Handle menu = CreateMenu(First_ReconMenu_Handle)

	char szMsg[512];
	char szItems[128];
	Format(szMsg, sizeof( szMsg ), "Class First Recon: \n\n \
									Primary: UMP-45 \n \
									Secondary: P250 \n \
									Equipment: Frag \n \
									Tactical: Flash Grenade \n \
									Perk 1: Recon \n \
									Perk 2: Quickdraw \n \
									Perk 3: Dead Silence \n \
									Strike Package: Assault(Care Package, Strafe Run, Assault Drone) ");

	Format(szItems, sizeof( szItems ), "Change Class to First Recon" );
	AddMenuItem(menu, "class_id", szItems);

	SetMenuTitle(menu, szMsg);

	//SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int First_ReconMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { SetClass(client, 1); }
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 
}

public Action OverwatchMenu(int client)
{
	Handle menu = CreateMenu(OverwatchMenu_Handle)

	char szMsg[512];
	char szItems[128];
	Format(szMsg, sizeof( szMsg ), "Class Overwatch: \n\n \
									Primary: M249 \n \
									Secondary: Deagle \n \
									Equipment: Frag \n \
									Tactical: Flash Grenade \n \
									Perk 1: Blind Eye \n \
									Perk 2: Blast Shield \n \
									Perk 3: Sit Rep \n \
									Strike Package: Support(Counter UAV, Recon Drone, Sentry Gun) ");

	Format(szItems, sizeof( szItems ), "Change Class to Overwatch" );
	AddMenuItem(menu, "class_id", szItems);

	SetMenuTitle(menu, szMsg);

	//SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int OverwatchMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { SetClass(client, 2); }			
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 

}

public Action Scout_SniperMenu(int client)
{
	Handle menu = CreateMenu(Scout_SniperMenu_Handle)

	char szMsg[512];
	char szItems[128];
	Format(szMsg, sizeof( szMsg ), "Class Scout Sniper: \n\n \
									Primary: Scout \n \
									Secondary: P250 \n \
									Equipment: Frag \n \
									Tactical: Smoke Grenade \n \
									Perk 1: Extreme Condition \n \
									Perk 2: Assassin \n \
									Perk 3: Marksman \n \
									Strike Package: Assault(Care Package, Strafe Run, Assault Drone) ");

	Format(szItems, sizeof( szItems ), "Change Class to Scout Sniper" );
	AddMenuItem(menu, "class_id", szItems);

	SetMenuTitle(menu, szMsg);

	//SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int Scout_SniperMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { SetClass(client, 3); }	
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 
}

public Action Riot_ControlMenu(int client)
{
	Handle menu = CreateMenu(Riot_ControlMenuHandle);

	char szMsg[512];
	char szItems[128];
	Format(szMsg, sizeof( szMsg ), "Class Riot Control: \n\n \
									Primary: P90 \n \
									Secondary: USP-S \n \
									Equipment: Frag \n \
									Tactical: Concussion Grenade \n \
									Perk 1: Sleight of Hand \n \
									Perk 2: Hardline \n \
									Perk 3: Stalker \n \
									Strike Package: Support(Counter-UAV, Recon Drone, Remote Sentry) ");

	Format(szItems, sizeof( szItems ), "Change Class to Riot Control" );
	AddMenuItem(menu, "class_id", szItems);

	SetMenuTitle(menu, szMsg);

	//SetMenuExitButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int Riot_ControlMenuHandle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { SetClass(client, 4); }	
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 
}

public Action CustomClassMenu(int client)
{
	Handle menu = CreateMenu(CustomClassMenuHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "%s (%d)\nCustom Class Menu:", Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level] );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < MAX_CUSTOM_CLASS; i++)
	{
		char szItems[128];
		if(strlen(PlayerCustomClassInfo[client][i][ClassName]) > 1 && Client_HasAdminFlags(client, VIP_FLAG))
			Format(szItems, sizeof( szItems ), "%s %s" , PlayerCustomClassInfo[client][i][ClassName], i > 1 && !Client_HasAdminFlags(client, VIP_FLAG) ? "(VIP)" : "");
		else
			Format(szItems, sizeof( szItems ), "Custom Class %d %s" , i+1, i > 1 && !Client_HasAdminFlags(client, VIP_FLAG) ? "(VIP)" : "");

		char classid[32];
		IntToString(i, classid, 32);

		if(i > 1 && !Client_HasAdminFlags(client, VIP_FLAG))
			AddMenuItem(menu, classid, szItems, ITEMDRAW_DISABLED);
		else
			AddMenuItem(menu, classid, szItems);
	}
	//SetMenuExitBackButton(menu, true);
	SetMenuExitBackButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int CustomClassMenuHandle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		char info[32];
		GetMenuItem(menu, item, info, 32);
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 
}

public Action CustomeClassSelectMenu(int client, char[] customclass)
{
	Handle menu = CreateMenu(CustomeClassSelectMenuHandle);

	int customindex = StringToInt(customclass);

	char szMsg0[128], szMsg1[128], szMsg[1024];
	char szItems[128], szItems2[128];

	Format(szMsg0, sizeof( szMsg0 ), "%s" , PlayerCustomClassInfo[client][customindex][ClassName]); 
	Format(szMsg1, sizeof( szMsg1 ), "Class Custom %d" , customindex + 1); 

	char Wepp[32];
	strcopy(Wepp, sizeof(Wepp), PlayerCustomClassInfo[client][customindex][PrimaryWeapon][0]);
	Wepp[0] = CharToUpper(Wepp[0]);

	char Weps[32];
	strcopy(Weps, sizeof(Weps), PlayerCustomClassInfo[client][customindex][SecondaryWeapon][0]);
	Weps[0] = CharToUpper(Weps[0]);

	ReplaceString(Wepp, 32, "weapon_", "", false);
	ReplaceString(Weps, 32, "weapon_", "", false);

	Format(szMsg, sizeof( szMsg ), "%s: \n\n \
									Primary: %s \n \
									Secondary: %s \n \
									Equipment: %s \n \
									Tactical: %s \n \
									Perk 1: %s \n \
									Perk 2: %s \n \
									Perk 3: %s \n \
									Strike Package: %s ", \
									strlen(PlayerCustomClassInfo[client][customindex][ClassName]) > 1 && Client_HasAdminFlags(client, VIP_FLAG) ? szMsg0 : szMsg1, \
									Wepp, \
									Weps, \
									PlayerCustomClassInfo[client][customindex][Equipment], \
									PlayerCustomClassInfo[client][customindex][Tactical], \
									PlayerCustomClassInfo[client][customindex][PerkOne], \
									PlayerCustomClassInfo[client][customindex][PerkTwo], \
									PlayerCustomClassInfo[client][customindex][PerkThree], \
									PlayerCustomClassInfo[client][customindex][StrikePackage] );


	if(strlen(PlayerCustomClassInfo[client][customindex][ClassName]) > 1)
		Format(szItems, sizeof( szItems ), "Change Class to %s" , PlayerCustomClassInfo[client][customindex][ClassName]);
	else
		Format(szItems, sizeof( szItems ), "Change Class to Custom Class %d" , customindex+1);

	AddMenuItem(menu, customclass, szItems);

	Format(szItems2, sizeof( szItems2 ), "Edit Class" );
	AddMenuItem(menu, customclass, szItems2);

	SetMenuTitle(menu, szMsg);

	SetMenuExitBackButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}


public int CustomeClassSelectMenuHandle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		char info[32];
		GetMenuItem(menu, item, info, 32);
		int customindex = StringToInt(info);
		switch(item)
		{
			case 0: 
			{ 
				ChangeClass[client] = true;
				ChangeID[client] = customindex;
				
				if(!IsFakeClient(client) && SelectedClass[client])
				{
					char sCookieValue[32];
					IntToString(ChangeID[client]+5, sCookieValue, sizeof(sCookieValue));
					SetClientCookie(client, gLastClass, sCookieValue);
					//PrintToChat(client, "Your class will change next spawn.");
				}
				else if(!IsFakeClient(client) && !SelectedClass[client])
				{
					RespawnTime[client] = GetGameTime() + 5.0
					SelectedClass[client] = true;
					//CreateTimer(0.1, DoRespawn, GetClientUserId(client), TIMER_REPEAT);
				}
			}
			case 1: { EditClassMainMenu(client, info); }
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       ClassMenu(client);
    } 

    
}

public Action EditClassMainMenu(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditClassMainMenuHandle);

	char szMsg[128];
	char szItems[128], szItems2[128], szItems3[128], szItems4[128], szItems5[128], szItems6[128], szItems7[128], szItems8[128];
	Format(szMsg, sizeof( szMsg ), "Edit Class:");

	Format(szItems, sizeof( szItems ), "Primary Gun" );
	AddMenuItem(menu, customclass, szItems);

	Format(szItems2, sizeof( szItems2 ), "Secondary Gun" );
	AddMenuItem(menu, customclass, szItems2);

	Format(szItems3, sizeof( szItems3 ), "Equipment" );
	AddMenuItem(menu, customclass, szItems3);

	Format(szItems4, sizeof( szItems4 ), "Tactical" );
	AddMenuItem(menu, customclass, szItems4);

	Format(szItems5, sizeof( szItems5 ), "Perk One" );
	AddMenuItem(menu, customclass, szItems5);

	Format(szItems6, sizeof( szItems6 ), "Perk Two" );
	AddMenuItem(menu, customclass, szItems6);

	Format(szItems7, sizeof( szItems7 ), "Perk Three" );
	AddMenuItem(menu, customclass, szItems7);

	Format(szItems8, sizeof( szItems8 ), "Strike Package" );
	AddMenuItem(menu, customclass, szItems8);

	SetMenuTitle(menu, szMsg);

	SetMenuExitBackButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditClassMainMenuHandle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		char info[32];
		GetMenuItem(menu, item, info, 32);
		switch(item)
		{
			case 0: { EditPrimary(client, info); }
			case 1: { EditSecondary(client, info); }
			case 2: { EditEquipment(client, info); }
			case 3: { EditTactical(client, info); }
			case 4: { EditPerkOne(client, info); }
			case 5: { EditPerkTwo(client, info); }
			case 6: { EditPerkThree(client, info); }
			case 7: { EditStrikePackage(client, info); }
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       CustomClassMenu(client);
    } 

}

public Action EditPrimary(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditPrimaryHandle);

	char szMsg[128];
	char szItems[128], szItems2[128], szItems3[128], szItems4[128];
	Format(szMsg, sizeof( szMsg ), "Primary Gun Selection" );
	SetMenuTitle(menu, szMsg);

	Format(szItems, sizeof( szItems ), "Rifles" );
	AddMenuItem(menu, customclass, szItems);

	Format(szItems2, sizeof( szItems2 ), "Sub-Machine Guns" );
	AddMenuItem(menu, customclass, szItems2);

	Format(szItems3, sizeof( szItems3 ), "Shotguns" );
	AddMenuItem(menu, customclass, szItems3);

	Format(szItems4, sizeof( szItems4 ), "Snipers" );
	AddMenuItem(menu, customclass, szItems4);

	SetMenuExitBackButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditPrimaryHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);

	if( action == MenuAction_Select )
	{
		switch(item)
		{
			case 0: { EditRifles(client, info); }
			case 1: { EditSMGs(client, info); }
			case 2: { EditShotguns(client, info); }
			case 3: { EditSnipers(client, info); }
		}
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditClassMainMenu(client, info);
    } 
}

public Action EditRifles(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditRiflesHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Rifle:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Rifles); i++)
	{
		char Wepp[32];
		strcopy(Wepp, sizeof(Wepp), Rifles[i][0][7]);
		Wepp[0] = CharToUpper(Wepp[0]);

		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Rifles[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Wepp);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Wepp, Rifles[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditRiflesHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);

	if( action == MenuAction_Select )
	{
		if(PerkOverkill[client])
		{
			PerkOverkill[client] = false;
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, Rifles[item][0]);
		}
		else
		{
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PrimaryWeapon], 32, Rifles[item][0]);
		}
		//PrintToChat(client, "You have selected: %s", Rifles[item][0])
		//PlayerCustomClassInfo[client][class][PrimaryGun]
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditPrimary(client, info);
    } 
}

public Action EditSMGs(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditSMGsHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select SMG:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(SMGs); i++)
	{
		char Wepp[32];
		strcopy(Wepp, sizeof(Wepp), SMGs[i][0][7]);
		Wepp[0] = CharToUpper(Wepp[0]);

		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(SMGs[i][1] ))
		{
			Format(szItems, sizeof( szItems ), "%s" , Wepp);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Wepp, SMGs[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditSMGsHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);

	if( action == MenuAction_Select )
	{
		if(PerkOverkill[client])
		{
			PerkOverkill[client] = false;
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, SMGs[item][0]);
		}
		else
		{
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PrimaryWeapon], 32, SMGs[item][0]);
		}
		//PrintToChat(client, "You have selected: %s", SMGs[item][0])
		//PlayerCustomClassInfo[client][class][PrimaryGun]
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditPrimary(client, info);
    } 
}

public Action EditShotguns(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditShotgunsHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select SMG:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Shotguns); i++)
	{
		char Wepp[32];
		strcopy(Wepp, sizeof(Wepp), Shotguns[i][0][7]);
		Wepp[0] = CharToUpper(Wepp[0]);

		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Shotguns[i][1] ))
		{
			Format(szItems, sizeof( szItems ), "%s" ,Wepp);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Wepp, Shotguns[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditShotgunsHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		if(PerkOverkill[client])
		{
			PerkOverkill[client] = false;
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, Shotguns[item][0]);
		}
		else
		{
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PrimaryWeapon], 32, Shotguns[item][0]);
		}
		//PrintToChat(client, "You have selected: %s", Shotguns[item][0])	
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditPrimary(client, info);
    } 
}

public Action EditSnipers(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditSnipersHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select SMG:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Snipers); i++)
	{
		char Wepp[32];
		strcopy(Wepp, sizeof(Wepp), Snipers[i][0][7]);
		Wepp[0] = CharToUpper(Wepp[0]);

		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Snipers[i][1] ))
		{
			Format(szItems, sizeof( szItems ), "%s" , Wepp);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Wepp, Snipers[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditSnipersHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		if(PerkOverkill[client])
		{
			PerkOverkill[client] = false;
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, Snipers[item][0]);
		}
		else
		{
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PrimaryWeapon], 32, Snipers[item][0]);
		}
		//PrintToChat(client, "You have selected: %s", Snipers[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditPrimary(client, info);
    } 
}

public void EditSecondary(int client, char[] customclass)
{
	if( StrEqual(PlayerCustomClassInfo[client][StringToInt(customclass)][PerkTwo], "Overkill")  )
	{
		EditPrimary(client, customclass); 
		PerkOverkill[client] = true;		
	}
	else
	{
		EditPistols(client, customclass);
	}
}

public Action EditPistols(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditPistolsHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Pistol:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Pistols); i++)
	{
		char Wepp[32];
		strcopy(Wepp, sizeof(Wepp), Pistols[i][0][7]);
		Wepp[0] = CharToUpper(Wepp[0]);

		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Pistols[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Wepp);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Wepp, Pistols[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditPistolsHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, Pistols[item][0]);
		//PrintToChat(client, "You have selected: %s", Pistols[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
       EditSecondary(client, info);
    } 
}

public Action EditEquipment(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditEquipmentsHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Equipment:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Equipments); i++)
	{
		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Equipments[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Equipments[i][0]);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Equipments[i][0], Equipments[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditEquipmentsHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][Equipment], 32, Equipments[item][0]);
		//PrintToChat(client, "You have selected: %s", Equipments[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}

public Action EditTactical(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditTacticalsHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Tactical:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Tacticals); i++)
	{
		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Tacticals[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Tacticals[i][0]);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Tacticals[i][0], Tacticals[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditTacticalsHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][Tactical], 32, Tacticals[item][0]);
		//PrintToChat(client, "You have selected: %s", Tacticals[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}

public Action EditPerkOne(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditPerkOnesHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Perk One:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Perk1); i++)
	{
		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Perk1[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Perk1[i][0]);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Perk1[i][0], Perk1[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
		
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditPerkOnesHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PerkOne], 32, Perk1[item][0]);
		//PrintToChat(client, "You have selected: %s", Perk1[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}

public Action EditPerkTwo(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditPerkTwosHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Perk Two:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Perk2); i++)
	{
		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Perk2[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Perk2[i][0]);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Perk2[i][0], Perk2[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}	
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditPerkTwosHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		if(StrEqual(PlayerCustomClassInfo[client][StringToInt(info)][PerkTwo], "Overkill"))
		{
			strcopy(PlayerCustomClassInfo[client][StringToInt(info)][SecondaryWeapon], 32, "");
			PrintToChat(client, "Please re-select your pistol.")
		}
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PerkTwo], 32, Perk2[item][0]);
		//PrintToChat(client, "You have selected: %s", Perk2[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}

public Action EditPerkThree(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditPerkThreesHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Perk Three:" );
	SetMenuTitle(menu, szMsg);

	for(int i = 0; i < sizeof(Perk3); i++)
	{
		char szItems[128];
		if( PlayerStatsInfo[client][Level] >= StringToInt(Perk3[i][1] ) )
		{
			Format(szItems, sizeof( szItems ), "%s" , Perk3[i][0]);
			AddMenuItem(menu, customclass, szItems);	
		}
		else
		{
			Format(szItems, sizeof( szItems ), "%s (lv:%s)" , Perk3[i][0], Perk3[i][1]);
			AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
		}
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditPerkThreesHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		strcopy(PlayerCustomClassInfo[client][StringToInt(info)][PerkThree], 32, Perk3[item][0]);
		//PrintToChat(client, "You have selected: %s", Perk3[item][0])
		SaveData2(client, StringToInt(info))
		CustomeClassSelectMenu(client, info);
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}

public Action EditStrikePackage(int client, char[] customclass)
{
	Handle menu = CreateMenu(EditStrikePackageHandle);

	char szMsg[128];
	Format(szMsg, sizeof( szMsg ), "Select Strike Package:" );
	SetMenuTitle(menu, szMsg);

	char szItems[128];

	Format(szItems, sizeof( szItems ), "Assault");
	AddMenuItem(menu, customclass, szItems);	

	Format(szItems, sizeof( szItems ), "Support");
	AddMenuItem(menu, customclass, szItems);	

	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int EditStrikePackageHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		PlayerStrikePackageCount[client] = 3;

		switch(item)
		{
			case 0: { Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "Assault("); SelectAssualtPackage(client, info, PlayerStrikePackageCount[client]); }
			case 1: { Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "Support("); SelectSupportPackage(client, info, PlayerStrikePackageCount[client]);}
		}

		//PrintToChat(client, "You have selected: %s", StringToInt(info))
		//SaveData2(client, StringToInt(info))
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_Cancel && item == MenuCancel_ExitBack) 
    { 
    	EditClassMainMenu(client, info);
    } 
}



public Action SelectAssualtPackage(int client, char[] customclass, int amount)
{
	if(amount > 0)
	{
		Handle menu = CreateMenu(SelectAssualtPackageHandle);

		char szMsg[128];
		Format(szMsg, sizeof( szMsg ), "Select %d Assault Packages:", amount );
		SetMenuTitle(menu, szMsg);

		for(int i = 0; i < sizeof(StrikePackages); i++)
		{
			char szItems[256];
			//if( PlayerStatsInfo[client][Level] >= StringToInt(StrikePackages[i][1] ) )
			//{
			if( StrContains(PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage], StrikePackages[i][0], false) == -1) 
			{
				Format(szItems, sizeof( szItems ), "[ ] %s" , StrikePackages[i][0]);
				AddMenuItem(menu, customclass, szItems);	
			}
			else
			{
				Format(szItems, sizeof( szItems ), "[x] %s" , StrikePackages[i][0]);
				AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
			}
			//}
			//else if( PlayerStatsInfo[client][Level] < StringToInt(StrikePackages[i][1] ) )
			//{
			//	Format(szItems, sizeof( szItems ), "[ ] %s (lv:%s)" , StrikePackages[i][0], StrikePackages[i][1]);
			//	AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
			//}
		}
		SetMenuExitBackButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER );
	}
	else
	{
		Format(PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage], 128, "%s)", PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage]);
		SaveData2(client, StringToInt(customclass));
		EditClassMainMenu(client, customclass);
	}
}

public int SelectAssualtPackageHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		if(PlayerStrikePackageCount[client] > 1)
			Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "%s %s, ", PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], StrikePackages[item][0]);
		else
			Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "%s %s ", PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], StrikePackages[item][0]);
		PlayerStrikePackageCount[client]--
		SelectAssualtPackage(client, info, PlayerStrikePackageCount[client])
		//SaveData2(client, StringToInt(info))
	}
	else if (action == MenuAction_End )	
	{
		CloseHandle(menu);
		EditClassMainMenu(client, info);
	}
	else if ( action == MenuAction_Cancel )
	{
		PrintToChat(client, "Strike package selection cancelled.")
		Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "");
		CloseHandle(menu);
		EditClassMainMenu(client, info);
	}
}


public Action SelectSupportPackage(int client, char[] customclass, int amount)
{
	if(amount > 0)
	{
		Handle menu = CreateMenu(SelectSupportPackageHandle);

		char szMsg[128];
		Format(szMsg, sizeof( szMsg ), "Select %d Support Packages:", amount );
		SetMenuTitle(menu, szMsg);

		for(int i = 0; i < sizeof(SupportPackages); i++)
		{
			char szItems[256];
			//if( PlayerStatsInfo[client][Level] >= StringToInt(SupportPackages[i][1] ) )
			//{
			if( StrContains(PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage], SupportPackages[i][0], false) == -1) 
			{
				Format(szItems, sizeof( szItems ), "[ ] %s" , SupportPackages[i][0]);
				AddMenuItem(menu, customclass, szItems);	
			}
			else
			{
				Format(szItems, sizeof( szItems ), "[x] %s" , SupportPackages[i][0]);
				AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
			}
			//}
			//else if( PlayerStatsInfo[client][Level] < StringToInt(SupportPackages[i][1] ) )
			//{
			//	Format(szItems, sizeof( szItems ), "[ ] %s (lv:%s)" , SupportPackages[i][0], SupportPackages[i][1]);
			//	AddMenuItem(menu, customclass, szItems, ITEMDRAW_DISABLED);	
			//}
		}
		SetMenuExitBackButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER );
	}
	else
	{
		Format(PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage], 128, "%s)", PlayerCustomClassInfo[client][StringToInt(customclass)][StrikePackage]);
		SaveData2(client, StringToInt(customclass));
		EditClassMainMenu(client, customclass);
	}
}

public int SelectSupportPackageHandle(Handle menu, MenuAction action, int client, int item)
{
	char info[32];
	GetMenuItem(menu, item, info, 32);
	if( action == MenuAction_Select )
	{
		if(PlayerStrikePackageCount[client] > 1)
			Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "%s %s, ", PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], SupportPackages[item][0]);
		else
			Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "%s %s ", PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], SupportPackages[item][0]);
		PlayerStrikePackageCount[client]--
		SelectSupportPackage(client, info, PlayerStrikePackageCount[client])
		//SaveData2(client, StringToInt(info))
	}
	else if (action == MenuAction_End)	
	{
		
		CloseHandle(menu);
		EditClassMainMenu(client, info);
	}
	else if ( action == MenuAction_Cancel )
	{
		PrintToChat(client, "Strike package selection cancelled.")
		Format(PlayerCustomClassInfo[client][StringToInt(info)][StrikePackage], 128, "");
	}
}
