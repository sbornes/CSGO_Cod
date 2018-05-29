ConVar XP_Kill = null;
ConVar XP_TagBonus = null;
//Handle XP_Assist = null;

int OriginOffset;
int g_iVelocity;

int g_beamsprite, g_halosprite;

int skinOwner[2048];
//int ownerSkin[MAXPLAYERS+1];
#define DMG_HEADSHOT		(1 << 30)

int XPtoLevel[MAX_LEVEL+1] =
{
	0, 800, 1100, // 3
	1200, 1800, 2200, // 6
	2500, 2800, 3200, // 9
	3600, 3900, 4400, // 12
	4900, 5400, 5900, //15
	6400, 6900, 7400, 7900, // 19
	8400, 8900, 9400, 9900, // 23
	10400, 10900, 11400, 11900, // 27
	12400, 12900, 13400, 14000, // 31
	14600, 15200, 15800, 16400, // 35
	17000, 17600, 18200, 18800, // 39
	19400, 20000, 20600, 21200, // 43
	21800, 22400, 23000, 23600, // 47
	24200, 24800, 25400, 26150, // 51
	26900, 27650, 28400, 29150, // 55
	29900, 30650, 31400, 32150, // 59
	32900, 33650, 34400, 35150, // 63
	35900, 36650, 37400, 38150, // 67
	38900, 39650, 40400, 41150, // 71
	41650, 42650, 43150, 44150, // 75
	44650, 45650, 46150, 47150, // 79
	47650, 50500 // 81
}

char Rifles[5][2][256] = 
{	 //WeaponName   //Level
	{ "weapon_galilar", "20" },
	{ "weapon_famas", "35" },
	{ "weapon_m4a1_silencer", "45" },
	{ "weapon_m4a1", "58" },
	{ "weapon_ak47", "68" }
}

char SMGs[5][2][256] =
{
	{ "weapon_bizon", "4" },
	{ "weapon_mac10", "9" },
	{ "weapon_mp7", "15" },
	{ "weapon_mp9", "22" },
	{ "weapon_p90", "38" }
}

char Snipers[4][2][256] =
{
	{ "weapon_scout", "10" },
	{ "weapon_aug", "25" },
	{ "weapon_sg552", "30" },
	{ "weapon_awp", "63" }
}

char Pistols[9][2][256] =
{
	{ "weapon_glock", "2" },
	{ "weapon_usp_silencer", "4" },
	{ "weapon_hkp2000", "6" },
	{ "weapon_elite", "8" }, 
	{ "weapon_p250", "14" }, 
	{ "weapon_fiveseven", "21" }, 
	{ "weapon_tec9", "25" },
	{ "weapon_cz75a", "31" },
	{ "weapon_deagle", "42" }
}

char Shotguns[4][2][256] =
{
	{ "weapon_nova", "3" },
	{ "weapon_sawedoff", "10" },
	{ "weapon_xm1014", "17" },
	{ "weapon_mag7", "24" }, 
}


char Equipments[6][2][256] =
{
	{ "Semtex", "2" },
	{ "Frag Grenade", "4" },
	{ "Throwing Knife", "7" },
	{ "Bouncy Betty", "37" },
	{ "Claymore", "53" },
	{ "C4", "69" },
}

char Tacticals[6][2][256] =
{
	{ "Concussion Grenade", "4" },
	{ "Flash Grenade", "5" },
	{ "Scrambler", "13" },
	{ "Smoke Grenade", "29" },
	{ "Tactical Insertion", "71" },
	{ "Tactical Awareness Grenade", "77" }
}

char Perk1[5][3][256] =
{
	{ "Recon", "4", "Every enemy that takes explosive damage is marked on the radar." },
	{ "Sleight of Hand", "6", "Reload your weapons 50% faster than normal." },
	{ "Blind Eye", "11", "Enemy air support and sentries can't detect you." },
	{ "Extreme Conditioning", "22", "Allows you to sprint 2x times longer. "},
	{ "Scavenger", "38", "Replenishes your ammunition when you walk over Scavenger bags that are dropped by players when they die." }
}

char Perk2[5][3][256] =
{
	{ "Quickdraw", "4", "Allows you to switch weapons without delay." },
	{ "Blast Shield", "8", "Reduces explosive damage by 50%%. "},
	{ "Hardline", "15", "Reduces the amount of kills required for any killstreak by one." },
	{ "Assassin", "27", "Makes you undetectable by UAV." },
	{ "Overkill", "47", "Allows you to carry two primary weapons." }
}

char Perk3[5][3][256] =
{
	{ "Marksman", "4", "Allows you to identify enemies from farther away by marking them on the radar when they are visible to you." },
	{ "Stalker", "13", "Faster movement when sprinting and when you are not visible to the enemies." },
	{ "Sitrep", "19", "Highlights enemy explosives and tactical equipment in red." },
	{ "Steady Aim", "30", "No aim punch when being shot." },
	{ "Dead Silence", "55", "Makes your footstep silent." }
}

char StrikePackages[9][3][256] =
{
	{ "UAV", "3", "Shows enemies on the radar as red dots for 30 seconds. Enemies that have the Assassin perk equipped are not shown on the radar." },
	{ "Care Package", "4", "The Care Package is dropped to the battlefield and contains a random killstreak. The Care Package can be picked up by anyone, even the enemy." },
	{ "Predator Missile", "5", "Allows you to remote control one Predator Missile to the ground." },
	{ "Sentry Gun", "5", "Setup a sentry gun at the players location." },
	{ "Precision Airstrike", "6", "Allows you to call in a directional airstrike." },
	{ "Attack Helicopter", "7", "Calls in an Attack Helicopter that flies around the map and attacks enemies for a short while." },
	{ "Strafe Run", "9", "Calls in five helicopters to sweep the indicated area with massive firepower." },
	{ "Reaper", "9", "Take control of a Reaper-UAV and use it to launch 14 laser-guided missiles to the ground." },
	//{ "AC130", "12", "Be the gunner of an AC130 for 30 seconds. Use the 25mm, 45mm and 105mm guns to attack enemies." },
	{ "Juggernaut", "15", "Receive the Juggernaut suit, equipped with the M60E4 LMG and MP412 handgun. Lowers mobility, but makes you more resistant to damage." }
}

char SupportPackages[7][3][256] =
{
	{ "UAV", "4", "Shows enemies on the radar as red dots for 10 seconds every 2seconds." },
	{ "Counter UAV", "5", "Temporarily disables enemy radar for 30 seconds." },
	{ "Ballistic Vests", "5", "Drop a bag to the ground that supplies your teammates with Ballistic Vests." },
	{ "Airdrop Trap", "5", "Drops a rigged Care Package that explodes once the enemy tries to reach for its contents." },
	{ "Advanced UAV", "12", "Shows enemies on the radar as red dots in real time." },
	{ "EMP", "18", "Disables enemy electronics and knocks out all enemy air support." },
	{ "Juggernaut Recon", "18", "Receive the Juggernaut suit, equipped with the USP .45 handgun and a Riot Shield. Lowers mobility, but makes you more resistant to damage." }
}

enum PlayerClass
{
	String:PrimaryWeapon[32],
	String:SecondaryWeapon[32],
	String:Equipment[32],
	String:Tactical[32],
	String:PerkOne[32],
	String:PerkTwo[32],
	String:PerkThree[32],
	String:StrikePackage[128],
	String:ClassName[32]
}

enum PlayerStats
{
	Level,
	XP,
	Prestige,
	KillStreak
}

Handle gLastClass;

ConVar Class_CustomLevel;
ConVar sv_footsteps; 

bool showGlow[MAXPLAYERS+1];
int PlayerStatsInfo[MAXPLAYERS+1][PlayerStats];
int PlayerCustomClassInfo[MAXPLAYERS+1][MAX_CUSTOM_CLASS][PlayerClass];
int PlayerClassInfo[MAXPLAYERS+1][PlayerClass];
int PlayerClassStandardInfo[MAXPLAYERS+1][PlayerClass];
int PlayerStrikePackageCount[MAXPLAYERS+1];

float playerPredTime[MAXPLAYERS+1];

int hpAmount[MAXPLAYERS+1];

int temp_xp[MAXPLAYERS+1];
int death_inrow[MAXPLAYERS+1];
int PlayerCombos[MAXPLAYERS+1];
float PlayerComboTime[MAXPLAYERS+1];
bool SelectedClass[MAXPLAYERS+1];
bool ChangeClassStandard[MAXPLAYERS+1];
bool ChangeClass[MAXPLAYERS+1];
int ChangeID[MAXPLAYERS+1];

float flashDuration[MAXPLAYERS+1];
bool g_bFlashed[MAXPLAYERS+1];
bool g_bScramblerFlashed[MAXPLAYERS+1];
bool PlayerHasTatical[MAXPLAYERS+1];
int PlayerTaticalEnt[MAXPLAYERS+1];

/* Perks */
bool PerkOverkill[MAXPLAYERS+1];

/* Killstreaks */
ConVar KS_UAV;
ConVar KS_CounterUAV;
ConVar KS_CarePackage;
ConVar KS_PredatorMissile;
ConVar KS_SentryGun;
ConVar KS_Airstrike;
ConVar KS_AttackHeli;
ConVar KS_StrafeRun;
ConVar KS_ReaperAmmo;
ConVar KS_Reaper;
ConVar KS_AirDropTrap;
ConVar KS_EMP;
ConVar KS_AdvanceUAV;
ConVar KS_Juggernaut;
ConVar KS_BallisticDrop;

ConVar PredTime;

Handle UAVTIMER[4];
int UAVTicks[4];
bool hasUAV[MAXPLAYERS+1];
bool teamHasUAV[4];
bool hasAdvanceUAV[MAXPLAYERS+1];
bool teamHasAdvanceUAV[MAXPLAYERS+1];
bool hasCounterUAV[MAXPLAYERS+1];
bool hasCarePackage[MAXPLAYERS+1];
bool hasPredatorMissile[MAXPLAYERS+1];
bool hasSentryGun[MAXPLAYERS+1];
bool hasAirstrike[MAXPLAYERS+1];
bool hasAttackHeli[MAXPLAYERS+1];
bool hasStrafeRun[MAXPLAYERS+1];
bool hasJuggernaut[MAXPLAYERS+1];
bool isJuggernaut[MAXPLAYERS+1];
bool hasReaper[MAXPLAYERS+1];
bool predAttacked[MAXPLAYERS+1];
bool InPredator[MAXPLAYERS+1];
bool hasAirDropTrap[MAXPLAYERS+1];
bool hasEMP[MAXPLAYERS+1];
bool PackageFalling[2048];
bool hasBallisticVest[MAXPLAYERS+1];
bool wearingBallisticVest[MAXPLAYERS+1];
int Parachute_Ent[2048];

#define DEFUSE_ANGLE_THRESHOLD 5.0  // 5 degrees
#define DEFUSE_POSITION_THRESHOLD 1.0 // 1 unit

int last_cp_used;
int last_ballistic_used;
//codPackageOwner[2048]
int defuse_time[MAXPLAYERS+1];
int defuse_target[MAXPLAYERS+1];
float defuse_position[MAXPLAYERS+1][3];
float defuse_angles[MAXPLAYERS+1][3];
bool defuse_cancelled[MAXPLAYERS+1];
int defuse_userid[MAXPLAYERS+1];

Handle hDatabase = INVALID_HANDLE;
Handle hDatabase2 = INVALID_HANDLE;

bool KnifeAttack[MAXPLAYERS+1];
//char centerText[MAXPLAYERS+1][1024]; //HUD buffer	

// Semtex
int OFFSET_THROWER;
int OFFSET_DAMAGE;
int OFFSET_RADIUS;

// Throwing Knives
Handle g_hThrownKnives; // Store thrown knives
Handle g_hTimerDelay[MAXPLAYERS+1];
bool g_bHeadshot[MAXPLAYERS+1];
int g_iPlayerKniveCount[MAXPLAYERS+1];

// Sprint
float LastSprintReleased[MAXPLAYERS+1];
float LastSprintUsed[MAXPLAYERS+1];
float SprintTime[MAXPLAYERS+1];
float gSprinttime[MAXPLAYERS+1];
float LastKeyPressed[MAXPLAYERS+1];
bool IsSprinting[MAXPLAYERS+1];

float nextKnifeAttack[MAXPLAYERS+1];
float nextKnifeAttackBack[MAXPLAYERS+1];

float SentryGunNextFire[2048];
float PredSound[2048];
//int PredatorMissileOwner[2048];

int EntityOwner[2048];

// OverKill

int primClip[MAXPLAYERS+1];
int primAmmo[MAXPLAYERS+1];
int OverKillClip[MAXPLAYERS+1];
int OverKillAmmo[MAXPLAYERS+1];
bool WepSwitches[MAXPLAYERS+1];

// Block Spawn
float RespawnTime[MAXPLAYERS+1];

//int ClaymoreOwner[2048];

int playersC4[2048]; 

//int AirstrikeOwner[2048];
float AirstrikeLocation[2048][3];

//int HeliOwner[2048];
int HeliTarget[2048];
int HeliEntity[MAXPLAYERS+1];
float HeliOwnerLocation[MAXPLAYERS+1][3];
float HeliNextFire[2048];
bool InReaper[MAXPLAYERS+1];
int ReaperAmmo[MAXPLAYERS+1];
//float NextHeliSoundLoop[2048];
float entityDamage[2048];

//int ClientCamera[MAXPLAYERS+1];
//int missileOwner[2048];