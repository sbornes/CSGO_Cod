float lastHit[MAXPLAYERS+1];

public Action HealthRegen (Handle timer, any client)
{
	if(!IsValidClientAlive(client))
		return Plugin_Stop;

	
	if (isJuggernaut[client])
		hpAmount[client] = 500;
	else if(wearingBallisticVest[client])
		hpAmount[client] = 150;
	else
		hpAmount[client] = 100;

	if(GetGameTime() > lastHit[client])
		if(GetClientHealth(client) < hpAmount[client] )
			SetEntityHealth(client, GetClientHealth(client)+1)

	int Colour[4];
	if (!isJuggernaut[client] || !wearingBallisticVest[client]) 
	{
		Colour[0] = 255-RoundToZero(GetClientHealth(client)*2.5);
		Colour[1] = 0;
		Colour[2] = 0;
		Colour[3] = 255-RoundToZero(GetClientHealth(client)*2.5);
	}
	else if(isJuggernaut[client])
	{
		Colour[0] = 255-RoundToZero(GetClientHealth(client)/5*2.5);
		Colour[1] = 0;
		Colour[2] = 0;
		Colour[3] = 255-RoundToZero(GetClientHealth(client)/5*2.5);
	}
	else
	{
		Colour[0] = 255-RoundToZero(GetClientHealth(client)*0.66*2.5);
		Colour[1] = 0;
		Colour[2] = 0;
		Colour[3] = 255-RoundToZero(GetClientHealth(client)*0.66*2.5);
	}

	if(GetClientHealth(client) < hpAmount[client])
		ScreenFade(client, FFADE_IN|FFADE_PURGE|FFADE_MODULATE, Colour, 1, 1);

	return Plugin_Continue;
}