public Action KillStreak_OnPlayerRunCmd( int client, int &buttons )
{
	if ( buttons & IN_USE && !( GetEntProp( client, Prop_Data, "m_nOldButtons" ) & IN_USE ) )
	{
		KillStreakRewardMenu(client);
	}
}

public Action KillStreakRewardMenu(int client)
{
	Handle menu = CreateMenu(KillStreakRewardMenu_Handle);

	char szMsg[128];
	char szItems[128];	
	Format(szMsg, sizeof( szMsg ), "Killstreak: %d", PlayerStatsInfo[client][KillStreak]);
	SetMenuTitle(menu, szMsg);

	if( hasUAV[client] )
	{
		Format(szItems, sizeof( szItems ), "UAV" );
		AddMenuItem(menu, "UAV", szItems);
	}
	if( hasCounterUAV[client] )
	{
		Format(szItems, sizeof( szItems ), "Counter-UAV" );
		AddMenuItem(menu, "CounterUAV", szItems);
	}
	if( hasCarePackage[client] )
	{
		Format(szItems, sizeof( szItems ), "Care Package" );
		AddMenuItem(menu, "Care Package", szItems);
	}
	if( hasPredatorMissile[client] )
	{
		Format(szItems, sizeof( szItems ), "Predator Missile" );
		AddMenuItem(menu, "Predator Missile", szItems);		
	}

	if( hasSentryGun[client] )
	{
		Format(szItems, sizeof( szItems ), "Sentry Gun" );
		AddMenuItem(menu, "Sentry Gun", szItems);
	}
	if( hasAirstrike[client] )
	{
		Format(szItems, sizeof( szItems ), "Precision Airstrike" );
		AddMenuItem(menu, "Precision Airstrike", szItems);
	}

	if( hasAttackHeli[client] )
	{
		Format(szItems, sizeof( szItems ), "Attack Helicopter" );
		AddMenuItem(menu, "Attack Helicopter", szItems);
	}

	if( hasStrafeRun[client] )
	{
		Format(szItems, sizeof( szItems ), "Strafe Run" );
		AddMenuItem(menu, "Strafe Run", szItems);
	}

	if( hasReaper[client] )
	{
		Format(szItems, sizeof( szItems ), "Reaper" );
		AddMenuItem(menu, "Reaper", szItems);
	}

	if( hasJuggernaut[client] )
	{
		Format(szItems, sizeof( szItems ), "Juggernaut" );
		AddMenuItem(menu, "Juggernaut", szItems);
	}

	if( hasAirDropTrap[client] )
	{
		Format(szItems, sizeof( szItems ), "Airdrop Trap" );
		AddMenuItem(menu, "Airdrop Trap", szItems);
	}

	if( hasEMP[client] )
	{
		Format(szItems, sizeof( szItems ), "EMP" );
		AddMenuItem(menu, "EMP", szItems);
	}

	if( hasAdvanceUAV[client] )
	{
		Format(szItems, sizeof( szItems ), "Advance UAV" );
		AddMenuItem(menu, "Advance UAV", szItems);
	}

	if( hasBallisticVest[client])
	{
		Format(szItems, sizeof( szItems ), "Ballistic Vest" );
		AddMenuItem(menu, "Ballistic Vest", szItems);
	}

	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int KillStreakRewardMenu_Handle(Handle menu, MenuAction action, int client, int item)
{
	if( action == MenuAction_Select )
	{
		char info[32];
		GetMenuItem(menu, item, info, 32);

		if(StrEqual(info, "UAV")) doUAV(client);
		if(StrEqual(info, "CounterUAV")) doCounterUAV(client);
		if(StrEqual(info, "Care Package")) doCarePackage(client);
		if(StrEqual(info, "Predator Missile")) doPredMissile(client);
		if(StrEqual(info, "Sentry Gun")) doSentryGun(client);
		if(StrEqual(info, "Precision Airstrike")) doAirstrike(client);
		if(StrEqual(info, "Attack Helicopter")) doAttackHeli(client);
		if(StrEqual(info, "Strafe Run")) doStrafeRun(client);
		if(StrEqual(info, "Reaper")) doReaper(client);
		if(StrEqual(info, "Juggernaut")) doJuggernaut(client);
		if(StrEqual(info, "Airdrop Trap")) doCarePackageFake(client);
		if(StrEqual(info, "EMP")) doEMP(client);
		if(StrEqual(info, "Advance UAV")) doAdvanceUAV(client);
		if(StrEqual(info, "Ballistic Vest")) doBallisticVest(client);
		
	}
	else if (action == MenuAction_End)	
	{
		CloseHandle(menu);
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

void doKillStreaks(int client, bool CP = false)
{
	int random = -1;
	if(CP)
		random = GetRandomInt(0, 11);

	int perkHardline 		= hasPerk(client, "Hardline");
	int ksUAV 				= GetConVarInt(KS_UAV) 				- perkHardline;
	int ksCounterUAV 		= GetConVarInt(KS_CounterUAV) 		- perkHardline;
	int ksCarePackage 		= GetConVarInt(KS_CarePackage) 		- perkHardline;
	int ksPredatorMissile	= GetConVarInt(KS_PredatorMissile)	- perkHardline;
	int ksSentryGun 		= GetConVarInt(KS_SentryGun) 		- perkHardline;
	int ksAirstrike 		= GetConVarInt(KS_Airstrike) 		- perkHardline;
	int ksAttackHeli 		= GetConVarInt(KS_AttackHeli) 		- perkHardline;
	int ksStrafeRun 		= GetConVarInt(KS_StrafeRun) 		- perkHardline;
	int ksReaper 			= GetConVarInt(KS_Reaper) 			- perkHardline;
	int ksJuggernaut		= GetConVarInt(KS_Juggernaut)		- perkHardline;

	int ksAirdropTrap		= GetConVarInt(KS_AirDropTrap)		- perkHardline;
	int ksEMP 				= GetConVarInt(KS_EMP) 				- perkHardline;
	int ksAdvanceUAV 		= GetConVarInt(KS_AdvanceUAV)		- perkHardline;
	int ksBallisticVest 	= GetConVarInt(KS_BallisticDrop)	- perkHardline;


	if( StrContains(PlayerClassInfo[client][StrikePackage], "assault", false ) != -1 || CP)
	{
		if( StrContains(PlayerClassInfo[client][StrikePackage], "UAV", false ) != -1 || random == 0 ) {
			if(PlayerStatsInfo[client][KillStreak] == ksUAV && !hasUAV[client] || random == 0 ) {
				hasUAV[client] = true; EmitSoundToClientAny(client, "cod/ks/uav_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "UAV READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Care Package") != -1) {
			if(PlayerStatsInfo[client][KillStreak] == ksCarePackage && !hasCarePackage[client]) {
				hasCarePackage[client] = true; EmitSoundToClientAny(client, "cod/ks/cp_achieve2.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "CARE PACKAGE READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Predator Missile") != -1 || random == 1) {
			if(PlayerStatsInfo[client][KillStreak] == ksPredatorMissile && !hasPredatorMissile[client] || random == 1) {
				hasPredatorMissile[client] = true; EmitSoundToClientAny(client, "cod/ks/predator_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "PREDATOR MISSILE READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Sentry Gun") != -1 || random == 2) {
			if(PlayerStatsInfo[client][KillStreak] == ksSentryGun && !hasSentryGun[client] || random == 2) {
				hasSentryGun[client] = true; EmitSoundToClientAny(client, "cod/ks/sentry_achieve2.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "SENTRY GUN READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Precision Airstrike") != -1 || random == 3 ) {
			if(PlayerStatsInfo[client][KillStreak] == ksAirstrike && !hasAirstrike[client] || random == 3) {
				hasAirstrike[client] = true; EmitSoundToClientAny(client, "cod/ks/air_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "AIRSTRIKE READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Attack Helicopter") != -1 || random == 4) {
			if(PlayerStatsInfo[client][KillStreak] == ksAttackHeli && !hasAttackHeli[client] || random == 4) {
				hasAttackHeli[client] = true; EmitSoundToClientAny(client, "cod/ks/heli_achieve.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "ATTACK HELICOPTER READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Strafe Run") != -1 || random == 5) {
			if(PlayerStatsInfo[client][KillStreak] == ksStrafeRun && !hasStrafeRun[client] || random == 5) {
				hasStrafeRun[client] = true; EmitSoundToClientAny(client, "cod/ks/straferun_achieve.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "STRAFE RUN READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Reaper") != -1 || random == 6) {
			if(PlayerStatsInfo[client][KillStreak] == ksReaper && !hasReaper[client] || random == 6) {
				hasReaper[client] = true; EmitSoundToClientAny(client, "cod/ks/straferun_achieve.mp3"/*, _, SNDCHAN_STATIC */);HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "REAPER READY", "0.45", "0.2");			
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Juggernaut") != -1 || random == 7) {
			if(PlayerStatsInfo[client][KillStreak] == ksJuggernaut && !hasJuggernaut[client] || random == 7) {
				hasJuggernaut[client] = true; EmitSoundToClientAny(client, "cod/ks/straferun_achieve.mp3"/*, _, SNDCHAN_STATIC */);HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "JUGGERNAUT READY", "0.45", "0.2");			
			}
		}
	}

	if( StrContains(PlayerClassInfo[client][StrikePackage], "support", false ) != -1 || CP )
	{
		if( StrContains(PlayerClassInfo[client][StrikePackage], "UAV", false ) != -1 || random == 8) {
			if(PlayerStatsInfo[client][KillStreak] == ksUAV+1  && !hasUAV[client] || random == 8) {
				hasUAV[client] = true; EmitSoundToClientAny(client, "cod/ks/uav_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "UAV READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Counter UAV", false ) != -1 || random == 9) {
			if(PlayerStatsInfo[client][KillStreak] == ksCounterUAV && !hasCounterUAV[client] || random == 9) {
				hasCounterUAV[client] = true; EmitSoundToClientAny(client, "cod/ks/counter_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "COUNTER-UAV READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Airdrop Trap", false) != -1 || random == 10 ) {
			if(PlayerStatsInfo[client][KillStreak] == ksAirdropTrap && !hasAirDropTrap[client] || random == 10 ) {
				hasAirDropTrap[client] = true; EmitSoundToClientAny(client, "cod/ks/cp_achieve2.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "AIRDROP TRAP READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Ballistic Vests", false) != -1 || random == 11) {
			if(PlayerStatsInfo[client][KillStreak] == ksBallisticVest && !hasBallisticVest[client] || random == 11 ) {
				hasBallisticVest[client] = true; EmitSoundToClientAny(client, "cod/ks/cp_achieve2.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "BALLISTIC VEST READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "Advance UAV", false) != -1 || random == 12 ) {
			if(PlayerStatsInfo[client][KillStreak] == ksAdvanceUAV && !hasAdvanceUAV[client] || random == 12) {
				hasAdvanceUAV[client] = true; EmitSoundToClientAny(client, "cod/ks/counter_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "ADVANCE UAV READY", "0.45", "0.2");
			}
		}

		if( StrContains(PlayerClassInfo[client][StrikePackage], "EMP", false ) != -1 || random == 13) {
			if(PlayerStatsInfo[client][KillStreak] == ksEMP && !hasEMP[client] || random == 13) {
				hasEMP[client] = true; EmitSoundToClientAny(client, "cod/ks/emp_give.mp3"/*, _, SNDCHAN_STATIC */); HudText(client, "3", "255 255 255", "0.75", "0.75", "2.5", "EMP READY", "0.45", "0.2");
			}
		}
	}
}

