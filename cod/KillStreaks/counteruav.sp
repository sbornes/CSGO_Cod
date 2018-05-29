/*
   _____ ____  _    _ _   _ _______ ______ _____    _    _    __      __
  / ____/ __ \| |  | | \ | |__   __|  ____|  __ \  | |  | |  /\ \    / /
 | |   | |  | | |  | |  \| |  | |  | |__  | |__) | | |  | | /  \ \  / / 
 | |   | |  | | |  | | . ` |  | |  |  __| |  _  /  | |  | |/ /\ \ \/ /  
 | |___| |__| | |__| | |\  |  | |  | |____| | \ \  | |__| / ____ \  /   
  \_____\____/ \____/|_| \_|  |_|  |______|_|  \_\  \____/_/    \_\/    
                                                                        
*/

void doCounterUAV(int client)
{	
	teamHasUAV[otherTeam(client)] = false;
	hasCounterUAV[client] = false;
	UAVTicks[otherTeam(client)] -= 15;
	if(UAVTicks[otherTeam(client)] < 0)
		UAVTicks[otherTeam(client)] = 0;

	add_message_in_queue(client, KSR_COUNTER_UAV, MESSAGE_POINTS[KSR_COUNTER_UAV])

	for(int i = 1; i < MaxClients; i++)
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/counter_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/counter_friend.mp3", _, SNDCHAN_STATIC );

}

