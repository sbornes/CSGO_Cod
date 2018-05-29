/*
  ______ __  __ _____  
 |  ____|  \/  |  __ \ 
 | |__  | \  / | |__) |
 |  __| | |\/| |  ___/ 
 | |____| |  | | |     
 |______|_|  |_|_|     
                       
*/

public void doEMP(int client)
{
	char globalName[32];
	for(int i = 0; i < 2048; i++)
	{
		if(IsValidEntity(i))
		{
			Entity_GetGlobalName(i, globalName, 32);
			if(StrEqual(globalName, "airsupport"))
				AcceptEntityInput(i, "break", 0, 0);
		}
	}
	teamHasUAV[otherTeam(client)] = false;
	hasEMP[client] = false;

	for(int i = 1; i < MaxClients; i++) {
		if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
			EmitSoundToClientAny(i, "cod/ks/emp_enemy.mp3", _, SNDCHAN_STATIC );
		else if( IsValidClient(i) )
			EmitSoundToClientAny(i, "cod/ks/emp_friend.mp3", _, SNDCHAN_STATIC );
		if(IsValidClient(i))
			EmitSoundToClientAny(i, "cod/ks/emp_effect.mp3", _, SNDCHAN_STATIC );
	}
	add_message_in_queue(client, KSR_EMP, MESSAGE_POINTS[KSR_EMP])
}