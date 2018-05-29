public Action Sprint_OnPlayerRunCmd( int client, int &buttons )
{
	if( buttons & IN_FORWARD && !( GetEntProp( client, Prop_Data, "m_nOldButtons" ) & IN_FORWARD ) )
	{
		if(GetGameTime() - LastKeyPressed[client] < 0.2 )
		{
			if( (GetGameTime() - LastSprintReleased[client]) >= 5.0)
			{
				LastSprintUsed[client] = GetGameTime();
				IsSprinting[client] = true;
				SprintTime[client] = 0.0;
			}
			else if( SprintTime[client] > 0.0 && SprintTime[client] < gSprinttime[client] ) 
			{
				LastSprintUsed[client] = GetGameTime();
				IsSprinting[client] = true;
			}
		}
		LastKeyPressed[client] = GetGameTime();
	}  
	else if( ( GetEntProp( client, Prop_Data, "m_nOldButtons" ) ) & IN_FORWARD && buttons & IN_FORWARD ) 
	{ 
		if(IsSprinting[client])
		{
			if(GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") == 1.0) 
			{
				SetEntPropFloat(client, Prop_Data,"m_flNextAttack", GetGameTime()+99999.0);
				if(hasPerk(client, "Stalker"))
					SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.35);
				else
					SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.25);
			}
			if( ( SprintTime[client] + GetGameTime() - LastSprintUsed[client] ) > gSprinttime[client]) 
			{
				IsSprinting[client] = false;
				SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
				SprintTime[client] = 0.0;
				LastSprintReleased[client] = GetGameTime();
				SetEntPropFloat(client,Prop_Data,"m_flNextAttack", GetGameTime());
				EmitSoundToClientAny(client, "cod/exhausted.mp3", _, SNDCHAN_STATIC );
			}
		}
	}
	else if( ( GetEntProp( client, Prop_Data, "m_nOldButtons" ) & IN_FORWARD ) && !(buttons & IN_FORWARD))
	{
		if(IsSprinting[client])
		{
			LastSprintReleased[client] = GetGameTime();
			SprintTime[client] += ( GetGameTime() - LastSprintUsed[client]);
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
			IsSprinting[client] = false;
			SetEntPropFloat(client,Prop_Data,"m_flNextAttack", GetGameTime());
		}
	}
}