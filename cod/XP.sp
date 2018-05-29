
// bonus messages
enum
{
	BM_PAYBACK,
	BM_BUZZKILL,
	BM_BULLS_EYE,
	BM_STUCK,
	BM_RESCUER,
	BM_HIJACKER,
	BM_FIRST_BLOOD,
	BM_COMEBACK,
	BM_DOUBLE_KILL,
	BM_TRIPLE_KILL,
	BM_MULTI_KILL,
	BM_LONGSHOT,
	BM_SHARE_PACKAGE,
	BM_ONE_SHOT_KILL,
	BM_HEADSHOT,
	BM_AFTER_LIFE,
	BM_ASSISTED_SUICIDE,
	BM_EXECUTION,
	BM_AVENGER,
	BM_ASSIST,
	KSR_UAV,
	KSR_COUNTER_UAV,
	KSR_CARE_PACKAGE,
	KSR_PREDATOR_MISSILE,
	KSR_SENTRY_GUN,
	KSR_PRECISION_AIRSTRIKE,
	KSR_ATTACK_HELICOPTER,
	KSR_STRAFE_RUN,
	KSR_REAPER,
	KSR_EMP,
	KSR_JUGGERNAUT,
	KSR_AIRDROPTRAP,
	KSR_ADVANCE_UAV,
	KSR_BALLISTIC_VEST,
	KSR_BALLISTIC_VEST_SHARE,
	BM_KILL
};

// bonus messages points
int MESSAGE_POINTS[36] = 
{
	50,
	100,
	50,
	50,
	50,
	100,
	100,
	100,
	50,
	75,
	100,
	50,
	100,
	50,
	50,
	25,
	350,
	100,
	50,
	0,
	150, // uav
	150, // cuav
	100, // care
	100, // pred
	100, // sentry
	150, // prec
	150, // heli
	200,  // strafe run
	200,  // reaper
	350,  // emp
	300,  // juggernaut
	100,  // airdroptrap
	250, // advance uav
	100, // ballistic vests
	50, // vest shared
	100
};

// bonus messages 
char MESSAGE_LABLE[36][32] = 
{
	"Payback!",
	"Buzzkill!",
	"Bulls-eye!",
	"Stuck!",
	"Rescuer!",
	"Hijacker!",
	"First Blood!",
	"Comeback!",
	"Double Kill!",
	"Triple Kill!",
	"Multi Kill!",
	"Longshot!",
	"Share Package!",
	"One Shot One Kill",
	"Headshot!",
	"Afterlife!",
	"Assisted Suicide!",
	"Execution!",
	"Avenger!",
	"Assist!",
	"UAV",
	"Counter UAV",
	"Care Package",
	"Predator Missile",
	"Sentry Gun",
	"Precision Airstrike",
	"Attack Helicopter",
	"Strafe Run",
	"Reaper",
	"EMP",
	"Juggernaut",
	"Airdrop Trap",
	"Advance UAV",
	"Ballistic Vest",
	"Ballsitic Vest Shared",
	"Kill"
};

int first_killer;
bool is_selfkill[MAXPLAYERS+1];
bool got_bullseye[MAXPLAYERS+1];
int last_attacker[MAXPLAYERS+1];
int damage_count[MAXPLAYERS+1];
int damage_prcnt_from[MAXPLAYERS+1][MAXPLAYERS+1];
bool to_payback[MAXPLAYERS+1][MAXPLAYERS+1];
bool is_bullet_kill[MAXPLAYERS+1];
bool is_comeback[MAXPLAYERS+1];
float last_kill[MAXPLAYERS+1];

Handle message_queue_timer[MAXPLAYERS+1] = null;
int player_message_queue[MAXPLAYERS+1][16];
int player_message_index[MAXPLAYERS+1]; // bonus message queue

// this has to be called every 1.5 sec.
public Action show_player_next_message(Handle timer, any pack)
{

	int client, points;
 
	/* Set to the beginning and unpack it */
	ResetPack(pack);
	client = ReadPackCell(pack);
	points = ReadPackCell(pack);
	//msgidpack = ReadPackCell(pack);
	if(!IsValidClient(client))
		return;
	//int id = taskid - TASK_MESSAGE_BONUS
	int index = player_message_index[client]
	
	int msgid = player_message_queue[client][index]
	if (msgid == -1)
	{
		message_queue_timer[client] = null;
		return
	}
	
	// bonus message +sound
	//PlaySound(client, BONUS_SOUND)
	EmitSoundToClientAny(client, "cod/bonus.mp3", _, SNDCHAN_STATIC );

	AnnounceX(client, MESSAGE_LABLE[msgid], points)
	
	// its been read
	player_message_queue[client][index] = -1
	
	player_message_index[client]++
	if (player_message_index[client] > sizeof(player_message_queue[])-1)
		player_message_index[client] = 0
	
	// call this again, there maybe more messages to show
	//set_task(1.5, "show_player_next_message", taskid)
	DataPack pack2;
	CreateDataTimer(1.5, show_player_next_message, pack2);
	pack2.WriteCell(client);
	pack2.WriteCell(points);
}

// player's bonus messages
// also handles adding points (XP)
void add_message_in_queue(int client, int msgid, int points)
{
	//if (client == id_nuker) return
	
	// XP
	//int points = MESSAGE_POINTS[msgid]
	//ShowPointAdd(client, points)
	
	PlayerComboTime[client] = GetGameTime() + 1.6;

	int iPos = player_message_index[client]
	for (int i = 0; i < sizeof(player_message_queue[]); i++)
	{
		if (player_message_queue[client][iPos] == -1)
			break
		iPos++
		if (iPos > sizeof(player_message_queue[])-1) 
			iPos = 0
	}
	player_message_queue[client][iPos] = msgid
	if (message_queue_timer[client] == null) {
		DataPack pack;
		message_queue_timer[client] = CreateDataTimer(0.1, show_player_next_message, pack) //set_task(0.1, "show_player_next_message", TASK_MESSAGE_BONUS+client)
		pack.WriteCell(client);
		pack.WriteCell(points);
		//pack.WriteCell(msgid);
	}
	
}

void reset_message_queue(int client)
{
	for (int i = 0; i < sizeof(player_message_queue[]); i++)
		player_message_queue[client][i] = -1
	player_message_index[client] = 0
}

void AnnounceX(int client, char[] msg, int points )
{
	// message to one
	if (client)
	{
		char buffer[32];
		CS_GetClientClanTag(client, buffer, sizeof(buffer))
		if(StrEqual(buffer, GROUP_TAG))
			points = points + RoundToCeil(points * GetConVarFloat(XP_TagBonus));

		char centerText[128];
		//Format(centerText, sizeof(centerText), " \n             <font color='#00ff00'>+%dXP</font> %s", points, msg)
		//PrintHintText(client,  centerText);
		Format(centerText, sizeof(centerText), "+%dXP %s", points, msg)
		HudText(client, "1", "255 255 50", "0.0", "0.0", "1.5", centerText, "0.55", "0.5");


		GiveXP(client, points);

		
		//char centerText[100];
		//Format(centerText, sizeof(centerText), "+%dXP %s", points, msg)
		//DisplayInstructorHint(client, 1.4, 800.0, 1.0, true, true, " ", " ", " ", true, { 255, 255, 0}, centerText) 

	}
}


/*void ShowPointAdd(int client, int xp)
{
	if (xp <= 0) return
	PlayerComboTime[client] = GetGameTime() + 1.6
	temp_xp[client] += xp

	Format(centerText[client], sizeof(centerText[]), " \n             <font color='#00ff00'>+%dXP</font>", temp_xp[client])

}*/

void do_combo(int client)
{
	// nuke isn't multikill in mw2
	//if (id != id_nuker) 
	PlayerCombos[client]++
	death_inrow[client] = 0;

	int XPs = 0;
	char buffer[32];
	CS_GetClientClanTag(client, buffer, sizeof(buffer))
	if(StrEqual(buffer, GROUP_TAG))
		XPs = RoundToCeil(GetConVarInt(XP_Kill) * GetConVarFloat(XP_TagBonus));
	else
		XPs = GetConVarInt(XP_Kill);
	
	//GiveXP(client, XPs);
	AnnounceX(client, MESSAGE_LABLE[BM_KILL], XPs);
	//ShowPointAdd(client, GetConVarInt(XP_Kill));

}

void extra_points_calcs(int killer, int victim, bool isheadshot)
{
	// rescuer
	if (is_rescue_kill(killer, victim))
		add_message_in_queue(killer, BM_RESCUER, MESSAGE_POINTS[BM_RESCUER])
	
	// avenger
	float fTemp = GetGameTime() - last_kill[victim]
	if (fTemp < 1.0 && fTemp > 0.0)
		add_message_in_queue(killer, BM_AVENGER, MESSAGE_POINTS[BM_AVENGER])
	
	// bullets kills only
	if (is_bullet_kill[killer])
	{
		// One Shot Kill (1 bullet only)
		if (damage_count[victim] <= 1)
			add_message_in_queue(killer, BM_ONE_SHOT_KILL, MESSAGE_POINTS[BM_ONE_SHOT_KILL])
		
		// Headshot!
		if (isheadshot){
			add_message_in_queue(killer, BM_HEADSHOT, MESSAGE_POINTS[BM_HEADSHOT])
			//set_task(0.15, "play_headshot_sound", killer)
		}
		
		// Longshot!
		if (Entity_GetDistance(killer, victim) > 1300)
			add_message_in_queue(killer, BM_LONGSHOT, MESSAGE_POINTS[BM_LONGSHOT])
	}
	
	// Bullseye!
	if (got_bullseye[killer]){
		got_bullseye[killer] = false
		add_message_in_queue(killer, BM_BULLS_EYE, MESSAGE_POINTS[BM_BULLS_EYE])
	}
	
	// afterlife!
	if (IsValidClient(killer) && !IsPlayerAlive(killer))
		add_message_in_queue(killer, BM_AFTER_LIFE, MESSAGE_POINTS[BM_AFTER_LIFE])
	
	// Payback!
	if (to_payback[killer][victim])
	{
		to_payback[killer][victim] = false 	// hes paid!
		add_message_in_queue(killer, BM_PAYBACK, MESSAGE_POINTS[BM_PAYBACK])
		//show_payback(victim)
	}
	
	// First Blood!
	if (!first_killer && killer != victim)
	{
		first_killer = killer
		add_message_in_queue(killer, BM_FIRST_BLOOD, MESSAGE_POINTS[BM_FIRST_BLOOD])
	}
	
	// Assisted Suicide! or kill assist point!
	if (last_attacker[victim])
	{
		if (!killer)
			add_message_in_queue(last_attacker[victim], BM_ASSISTED_SUICIDE, MESSAGE_POINTS[BM_ASSISTED_SUICIDE])
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsValidClient(i)) continue
				int dmg; 
				dmg = damage_prcnt_from[victim][i];
				if (killer != i && dmg > 0)
				{
					add_message_in_queue(i, BM_ASSIST, dmg)
					//ShowPointAdd(i, dmg)
				}
			}
		}
	}
	
	// Execution!
	//if (in_last_stand[victim][LS_KILLER] == killer)
	//	add_message_in_queue(killer, BM_EXECUTION)
	
	// comeback
	if (is_comeback[killer])
	{
		is_comeback[killer] = false
		add_message_in_queue(killer, BM_COMEBACK, MESSAGE_POINTS[BM_COMEBACK])
	}
	
	// Buzzkill!
	// it's not like original
	if (PlayerStatsInfo[victim][KillStreak] > 3)
		add_message_in_queue(killer, BM_BUZZKILL, MESSAGE_POINTS[BM_BUZZKILL])
}

bool is_rescue_kill(int rescuer, int enemy)
{
	int teammate
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsValidClient(rescuer))
		{
			teammate = i
			
			// ignore self and enemy's teammate
			if (teammate == rescuer || !(GetClientTeam(rescuer) == GetClientTeam(teammate)))
				continue
			
			// was enemy attacking my teamate?
			if (last_attacker[teammate] == enemy)
				return true
		}
	}
	return false
}