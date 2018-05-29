public Action pingCheckCallBack(int client, int args)
{
	int ping = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iPing", _, client)  

	PrintToChat(client, "Your ping is %d", ping);
}

public Action Command_GiveXP(int client, int args)
{
	if (args < 2)
	{
		PrintToConsole(client, "Usage: sm_codgivexp <PlayerName> <XP>");
		return Plugin_Handled;
	}
 
	char name[32];
	int target = -1;
	char xptogive[32];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, xptogive, sizeof(xptogive));
 
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		char other[32];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(name, other, false))
		{
			target = i;
		}
	}
 
	if (target == -1)
	{
		PrintToConsole(client, "Could not find any player with the name: \"%s\"", name);
		return Plugin_Handled;
	}

	PlayerStatsInfo[target][XP] += StringToInt(xptogive);

	PrintToChat(client, "You have added %d xp to %N. ", StringToInt(xptogive), target);
	PrintToChat(target, "Admin %N gave you %d XP.", client, StringToInt(xptogive));

	CheckLevelUp(target);

	return Plugin_Handled;
}

public Action RenameClassCallBack(int client, int args)
{
	if (args < 2)
	{
		PrintToConsole(client, "Usage: cod_renameclass <CustomClassID> <\"Name\">");
		PrintToConsole(client, "e.g. cod_renameclass 1 \"Custom Rifle\" ");
		return Plugin_Handled;
	}

	char id[32];
	char customname[32];
	int classID;
	GetCmdArg(1, id, sizeof(id));
	GetCmdArg(2, customname, sizeof(customname));

	classID = StringToInt(id);

	if(classID < 1 || classID > MAX_CUSTOM_CLASS)
	{
		PrintToConsole(client, "ClassID %d is invalid, please enter a ID between 1 -> %d" , classID, MAX_CUSTOM_CLASS );
		return Plugin_Handled;				
	}

	if(strlen(customname) >= sizeof(customname)-1)
	{
		PrintToConsole(client, "Custom name is too long, MAX %d characters" , sizeof(customname)-1);
		return Plugin_Handled;		
	}


	strcopy(PlayerCustomClassInfo[client][classID-1][ClassName], sizeof(customname), customname);
	
	PrintToConsole(client, "You have set Custom Class %d's name to %s" , classID, customname );
	SaveData2(client, classID-1)
	return Plugin_Handled;			
}

public Action Command_SetLevel(int client, int args)
{
	if (args < 2)
	{
		PrintToConsole(client, "Usage: sm_codsetlvl <PlayerName> <Level>");
		return Plugin_Handled;
	}
 
	char name[32];
	int target = -1;
	char leveltogive[32];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, leveltogive, sizeof(leveltogive));
 
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		char other[32];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(name, other, false))
		{
			target = i;
		}
	}
 
	if (target == -1)
	{
		PrintToConsole(client, "Could not find any player with the name: \"%s\"", name);
		return Plugin_Handled;
	}

	PlayerStatsInfo[target][Level] = StringToInt(leveltogive);
	PlayerStatsInfo[target][XP] = 0;

	PrintToChat(client, "You have set %N's level to %d", StringToInt(leveltogive));
	PrintToChat(target, "Your level has been set to %d by admin %N", StringToInt(leveltogive), client);

	SaveData(client)

	return Plugin_Handled;
}
