/*
           _______      __     _   _  _____ ______   _    _    __      __
     /\   |  __ \ \    / /\   | \ | |/ ____|  ____| | |  | |  /\ \    / /
    /  \  | |  | \ \  / /  \  |  \| | |    | |__    | |  | | /  \ \  / / 
   / /\ \ | |  | |\ \/ / /\ \ | . ` | |    |  __|   | |  | |/ /\ \ \/ /  
  / ____ \| |__| | \  / ____ \| |\  | |____| |____  | |__| / ____ \  /   
 /_/    \_\_____/   \/_/    \_\_| \_|\_____|______|  \____/_/    \_\/    
                                                                         
*/

public void doAdvanceUAV(int client)
{
	if( !teamHasAdvanceUAV[GetClientTeam(client)])
	{

		if(teamHasUAV[GetClientTeam(client)])
			teamHasUAV[GetClientTeam(client)] = false;
		//Playsound
		hasAdvanceUAV[client] = false;
		teamHasAdvanceUAV[GetClientTeam(client)] = true;
		CreateTimer(0.5, AdvanceUAV, client, TIMER_REPEAT);

		add_message_in_queue(client, KSR_UAV, MESSAGE_POINTS[KSR_UAV])

		for(int i = 1; i < MaxClients; i++)
		{
			if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			{
				if(!hasPerk(i, "Assassin"))
					SDKHook(i, SDKHook_PostThink, Radar);
				EmitSoundToClientAny(i, "cod/ks/uav_enemy.mp3", _, SNDCHAN_STATIC );
			}
			else if( IsValidClient(i) ) 
			{
				EmitSoundToClientAny(i, "cod/ks/uav_friend.mp3", _, SNDCHAN_STATIC );
			}
		}
		add_message_in_queue(client, KSR_ADVANCE_UAV, MESSAGE_POINTS[KSR_ADVANCE_UAV])
	}
	else
	{
		PrintToChat(client, "Advance UAV is already active for your team.")
	}
}

public Action AdvanceUAV(Handle timer, any client)
{

	static int ticks = 0;

	if(!teamHasAdvanceUAV[GetClientTeam(client)])
		return Plugin_Stop;
					
	if(ticks < 60) // 30s ( 60ticks / 0.5s )
	{
		ticks++;
		//for(int i = 1; i < MaxClients; i++)
		//	if(IsValidClientAlive(i) && GetClientTeam(i) != GetClientTeam(client) && !hasPerk(i, "Assassin"))
		//		SetEntPropEnt(i, Prop_Send, "m_bSpotted", 1);		

		//PrintToChat(client, "DEBUG: UAV TICK");
	}
	else
	{
		for(int i = 1; i < MaxClients; i++)
			if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
				SDKUnhook(i, SDKHook_PostThink, Radar);
		teamHasAdvanceUAV[GetClientTeam(client)] = false;
		return Plugin_Stop;
	
	}

	return Plugin_Continue;
}