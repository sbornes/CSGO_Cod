void doUAV(int client)
{	
	if( !teamHasAdvanceUAV[GetClientTeam(client)])
	{
		//Playsound
		hasUAV[client] = false;
		teamHasUAV[GetClientTeam(client)] = true;
		if(UAVTIMER[GetClientTeam(client)] != null)
		{
			UAVTIMER[GetClientTeam(client)] = CreateTimer(2.0, UAV, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		UAVTicks[GetClientTeam(client)] += 15;

		add_message_in_queue(client, KSR_UAV, MESSAGE_POINTS[KSR_UAV])

		for(int i = 1; i < MaxClients; i++) 
		{
			if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			{
				EmitSoundToClientAny(i, "cod/ks/uav_enemy.mp3", _, SNDCHAN_STATIC );
			}
			else if( IsValidClient(i) )
			{
				EmitSoundToClientAny(i, "cod/ks/uav_friend.mp3", _, SNDCHAN_STATIC );
			}
		}
		
	}
	else
	{
		PrintToChat(client, "An AdvanceUAV is in active for your team. UAV cannot be used right now.")
	}
}


public Action UAV(Handle timer, any client)
{

	static int ticks = 0;

	if(!teamHasUAV[GetClientTeam(client)])
		return Plugin_Stop;

	if(ticks < UAVTicks[GetClientTeam(client)])
	{
		ticks++;
		for(int i = 1; i < MaxClients; i++) {
			if(IsValidClientAlive(i) && GetClientTeam(i) != GetClientTeam(client) && !hasPerk(i, "Assassin")) {
				SDKHook(i, SDKHook_PostThink, Radar); SDKUnhook(i, SDKHook_PostThink, Radar);	
			}
		}

		//PrintToChat(client, "DEBUG: UAV TICK");
	}
	else
	{
		for(int i = 1; i < MaxClients; i++)
			if(IsValidClientAlive(i) && GetClientTeam(i) != GetClientTeam(client) && !hasPerk(i, "Assassin"))
				SDKUnhook(i, SDKHook_PostThink, Radar);	

		KillTimer(UAVTIMER[GetClientTeam(client)]);
		UAVTicks[GetClientTeam(client)] = 0;
		UAVTIMER[GetClientTeam(client)] = null;
		teamHasUAV[GetClientTeam(client)] = false;
		return Plugin_Stop;
	
	}

	return Plugin_Continue;
}