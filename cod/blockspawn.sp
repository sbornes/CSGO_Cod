
void BlockSpawn(int client)
{
    bool showmsg = false;
    //static int ticks = 0;
    //ticks ++;

    //if(ticks > 2)
    //{
    if( !showmsg )
    {
        PreTeam[client] = GetClientTeam(client)
        ChangeClientTeam(client, CS_TEAM_SPECTATOR)
        //CS_SwitchTeam(client, CS_TEAM_SPECTATOR)
        
        //SetEntProp(client, Prop_Send, "m_lifeState", 2);

        PrintToChat(client, " \x04You must select a class before playing!")
        CreateTimer(3.0, ShowMenu, GetClientUserId(client))

        showmsg = true;
    }
    //}
}

public Action ShowMenu(Handle timer, any client)
{
    client = GetClientOfUserId(client);

    if(!IsValidClient(client))
        return;

    ClassMenu(client);
}

public Action DoRespawn(Handle timer, any client)
{
    client = GetClientOfUserId(client)

    if(!IsValidClient(client))
    {
        return Plugin_Stop;
    }

    if(GetGameTime() >= RespawnTime[client])
    {
        //SetEntProp(client, Prop_Send, "m_iTeamNum", PreTeam[client]);
        //ChangeClientTeam(client, PreTeam[client])
        SetEntProp(client, Prop_Send, "m_iTeamNum", CS_TEAM_CT);
        ChangeClientTeam(client, CS_TEAM_CT)
        SetEntProp(client, Prop_Send, "m_lifeState", 0);
        CS_RespawnPlayer(client);
        //PrintToChat(client, "you are now on team %s", PreTeam[client] == CS_TEAM_T ? "T" : "CT")
        
        return Plugin_Stop;
    }
    else
        PrintHintText(client, "\nRespawning in <font color='#ff0000'>%.1f</font>s ", RespawnTime[client] - GetGameTime());

    return Plugin_Continue;
}