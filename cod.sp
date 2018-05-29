#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <smlib>
#include <emitsoundany>
#include <clientprefs>

#include <CustomPlayerSkins>

#include "cod/defines.sp"
#include "cod/Titles.sp"
#include "cod/globals.sp"
#include "cod/hud.sp"
#include "cod/healthregen.sp"
#include "cod/classmenu.sp"
#include "cod/killstreaks.sp"
#include "cod/stocks.sp"
#include "cod/saveload.sp"
#include "cod/XP.sp"
#include "cod/equipment.sp"
#include "cod/tactical.sp"
#include "cod/sprint.sp"

#include "cod/natives.sp"
#include "cod/consolecmd.sp"

#include "cod/perks_one.sp"
#include "cod/perks_two.sp"
#include "cod/perks_three.sp"

#include "cod/KillStreaks/uav.sp"
#include "cod/KillStreaks/counteruav.sp"
#include "cod/KillStreaks/carepackage.sp"
#include "cod/KillStreaks/sentrygun.sp"
#include "cod/KillStreaks/predatormissile.sp"
#include "cod/KillStreaks/airstrike.sp"
#include "cod/KillStreaks/attackheli.sp"
#include "cod/KillStreaks/straferun.sp"
#include "cod/KillStreaks/reaper.sp"
#include "cod/KillStreaks/juggernaut.sp"		


#include "cod/KillStreaks/emp.sp"
#include "cod/KillStreaks/advanceuav.sp"
#include "cod/KillStreaks/ballisticdrop.sp"

/*
// Knife move
https://forums.alliedmods.net/showthread.php?t=247639

// CLAYMORE
https://garrysmods.org/download/3693/claymore-adv-dupe

VIP BENEFITS
More custom classes
Ability to rename classes

– Added new Killer Replay to Casual and Demolition modes. GOTV must be active on the server to enable the feature.
– Menu option Help/Options->Game Settings->Automatic Killer Replay will turn replay off.
– Several convars are available to customize the Killer Replay. Search for ‘replay’ in the console for a complete list.

MODELS CHECK OUT
https://gmod-project-killstreaks.googlecode.com/svn/trunk/garrysmod/addons/Modern%20warfare%20killstreaks/

// REPLAY
https://forums.alliedmods.net/showthread.php?t=277773

// ROUND END
https://forums.alliedmods.net/showthread.php?p=2310299#post2310299

MAPS
https://steamcommunity.com/sharedfiles/filedetails/?id=216482375

PROGESS BAR,
https://forums.alliedmods.net/showthread.php?t=184088

FOR INVISIBILTIY WHEN IN CHOPPER
sv_disable_immunity_alpha 1

REMOVE QUESTION MARK IN RADAR
https://forums.alliedmods.net/showpost.php?p=2337791&postcount=7

CSGO ITEMS
https://forums.alliedmods.net/showthread.php?p=2159938

models/weapon/melee/w_riotshield

mp_join_grace_time = 0

SOUNDS AT http://www.40calgames.com/cstrike/sound/mw2/killstreaks/
http://www.torrentz.eu/34bc692a71cbc1b45f59cbe3e0c60160bf3894b9
http://www.mp3down.eu/playlist/mp3/ns-1-mc-heli.xhtml

	NS_1mc_achieve_heli_03.mp3

https://www.youtube.com/watch?v=J4I4XnYLGlU
https://www.youtube.com/watch?v=82C0ig9uSfY
https://www.youtube.com/watch?v=sLz3_uRT8Fo
http://www.soundboard.com/sb/SPETSNAZ_CATS#

text generator
http://patorjk.com/software/taag/#p=testall&f=Big&t=SEMTEX
Font: BIG

http://tf3dm.com/3d-model/sentry-turret-44080.html
TURRET MODEL

RELOAD SPEED
https://forums.alliedmods.net/showthread.php?t=188455&page=2

glow_outline_effect_enable 
SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);

http://www.turbosquid.com/3d-models/free-world-war-bouncing-betty-3d-model/658176

If Claymore Should DMG
https://forums.alliedmods.net/showthread.php?t=107448
*/

public void OnPluginStart()
{ 
	OriginOffset 		= FindSendPropInfo("CBaseEntity", "m_vecOrigin");
	g_iVelocity 		= FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");

	XP_Kill 			= CreateConVar("sm_cod_kill_xp", "100", "XP Per Kill", _, true, 1.0, _, _);
	XP_TagBonus			= CreateConVar("sm_cod_kill_xpbonus", "0.10", "XP Per Kill BONUS", _, _, _, _, _);
	//XP_Assist 			= CreateConVar("sm_cod_assist_xp", "25", "XP Per Assist", _, true, 1.0, _, _);

	gLastClass 			= RegClientCookie("cod_lastclass", "Last Class Cookie", CookieAccess_Protected);

	Class_CustomLevel 	= CreateConVar("sm_cod_custom_class_level", "5", "What level before accessing custom classes", _, _, _, true, float(MAX_LEVEL));

	KS_UAV				= CreateConVar("sm_cod_ks_uav", "3", "How many kills for UAV", _, true, 1.0, false, _);
	KS_CounterUAV		= CreateConVar("sm_cod_ks_cuav", "5", "How many kills for Counter-UAV", _, true, 1.0, false, _);
	KS_CarePackage 		= CreateConVar("sm_cod_ks_carepackage", "4", "How many kills for Care Package", _, true, 1.0, false, _);
	KS_PredatorMissile 	= CreateConVar("sm_cod_ks_predatormissile", "5", "How many kills for Predator missile", _, true, 1.0, false, _);
	KS_SentryGun 		= CreateConVar("sm_cod_ks_sentrygun", "5", "How many kills for Sentry Gun", _, true, 1.0, false, _);
	KS_Airstrike 		= CreateConVar("sm_cod_ks_airstrike", "6", "How many kills for Airstrike", _, true, 1.0, false, _);
	KS_AttackHeli 		= CreateConVar("sm_cod_ks_attackheli", "7", "How many kills for Attack Helicopter", _, true, 1.0, false, _);
	KS_StrafeRun 		= CreateConVar("sm_cod_ks_straferun", "9", "How many kills for Strafe Run", _, true, 1.0, false, _);
	KS_ReaperAmmo		= CreateConVar("sm_cod_ks_reaperammo", "14", "How many shots can the Reaper fire", _, true, 1.0, false, _);
	KS_Reaper			= CreateConVar("sm_cod_ks_reaper", "9", "How many kills for Reaper", _, true, 1.0, false, _);
	KS_Juggernaut		= CreateConVar("sm_cod_ks_juggernaut", "15", "How many kills for Juggernaut", _, true, 1.0, false, _);

	KS_AirDropTrap 		= CreateConVar("sm_cod_ks_airdroptrap", "5", "How many kills for Care Package TRAP", _, true, 1.0, false, _);
	KS_EMP				= CreateConVar("sm_cod_ks_emp", "18", "How many Kills for EMP", _, true, 1.0, false, _);
	KS_AdvanceUAV		= CreateConVar("sm_cod_ks_advanceuav", "12", "How many kills for advance UAV", _, true, 1.0, false, _);
	KS_BallisticDrop 	= CreateConVar("sm_cod_ks_ballisticvest", "5", "How many kills for ballistic vest", _, true, 1.0, false, _);

	PredTime 			= CreateConVar("sm_cod_ks_predtime", "12.0", "how long pred last for", _, true, 1.0, false, _);

	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_start", Event_OnRoundStart);

	AddCommandListener(OnJoinTeam, "jointeam");
	AddCommandListener(OnKnifeAttack, "drop");

	HookEvent("player_blind", Event_PlayerBlind, EventHookMode_Pre);
	HookEvent("flashbang_detonate", Event_FlashbangDetonate);
	HookEvent("player_use", Event_PlayerUse );
	HookEvent("player_hurt", Event_PlayerHurt);

	RegConsoleCmd("sm_class", ClassCallBack);
	RegAdminCmd("sm_test", test, ADMFLAG_GENERIC);
	RegConsoleCmd("sm_ping", pingCheckCallBack)

	HookEvent("weapon_fire", weapon_fire);

	RegAdminCmd("cod_renameclass", RenameClassCallBack, VIP_FLAG, "Rename custom classes");
	RegAdminCmd("sm_codsetlvl", Command_SetLevel, ADMFLAG_KICK, "Sets level");
	RegAdminCmd("sm_codgivexp", Command_GiveXP, ADMFLAG_KICK, "Gives XP");

	AddNormalSoundHook(FootstepCheck);
	sv_footsteps = FindConVar("sv_footsteps");

	AddCommandListener(Command_LAW, "+lookatweapon");	

	OFFSET_THROWER  = FindSendPropInfo("CBaseGrenade", "m_hThrower");
	OFFSET_DAMAGE = FindSendPropInfo("CBaseGrenade", "m_flDamage");
	OFFSET_RADIUS = FindSendPropInfo("CBaseGrenade", "m_DmgRadius");

	g_hThrownKnives = CreateArray();

	MySQL_Init();
}

public void OnMapStart()
{
	PrecacheModel("models/player/custom_player/legacy/tm_phoenix_heavy.mdl",true);
	PrecacheModel("models/weapons/w_eq_sensorgrenade_dropped.mdl",true);
	
	PrecacheModel("materials/sprites/laser.vtf", true);
	PrecacheModel("materials/sprites/laser.vmt", true);
	PrecacheModel("models/props_vehicles/helicopter_rescue.mdl", true);

	AddFileToDownloadsTable("models/weapons/W_missile_closed.mdl");
	AddFileToDownloadsTable("models/weapons/W_missile_closed.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/W_missile_closed.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/W_missile_closed.phy");
	AddFileToDownloadsTable("models/weapons/W_missile_closed.sw.vtx");
	AddFileToDownloadsTable("models/weapons/W_missile_closed.vvdy");
	AddFileToDownloadsTable("materials/models/weapons/w_missile/missile side.vmt");
	AddFileToDownloadsTable("materials/models/weapons/stinger_missile/missile side.vtf");
	PrecacheModel("models/weapons/W_missile_closed.mdl", true);

	PrecacheModel("models/f18/f18.mdl", true)
	PrecacheModel("models/weapons/w_c4_planted.mdl", true);

	AddFileToDownloadsTable("materials/cod/magazine/magazine.vmt");
	AddFileToDownloadsTable("materials/cod/magazine/S.vtf");
	AddFileToDownloadsTable("models/cod/magazine/magazine.dx80.vtx");
	AddFileToDownloadsTable("models/cod/magazine/magazine.dx90.vtx");
	AddFileToDownloadsTable("models/cod/magazine/magazine.phy");
	AddFileToDownloadsTable("models/cod/magazine/magazine.sw.vtx");
	AddFileToDownloadsTable("models/cod/magazine/magazine.vvd");
	AddFileToDownloadsTable("models/cod/magazine/magazine.mdl");
	PrecacheModel("models/cod/magazine/magazine.mdl", true);

	AddFileToDownloadsTable("materials/models/bf2/claymore.vmt");
	AddFileToDownloadsTable("materials/models/bf2/claymore.vtf");
	AddFileToDownloadsTable("materials/models/bf2/claymore_n.vtf");
	AddFileToDownloadsTable("models/bf2/claymore.dx90.vtx");
	AddFileToDownloadsTable("models/bf2/claymore.dx90.vtx");
	AddFileToDownloadsTable("models/bf2/claymore.phy");
	AddFileToDownloadsTable("models/bf2/claymore.sw.vtx");
	AddFileToDownloadsTable("models/bf2/claymore.vvd");
	AddFileToDownloadsTable("models/bf2/claymore.mdl");
	PrecacheModel("models/bf2/claymore.mdl", true);

	AddFileToDownloadsTable("materials/models/duffle/duffle.vmt");
	AddFileToDownloadsTable("materials/models/duffle/duffle.vtf");
	AddFileToDownloadsTable("materials/models/duffle/duffle_nm.vtf");
	AddFileToDownloadsTable("materials/models/duffle/floor.vmt");
	AddFileToDownloadsTable("materials/models/duffle/floor.vtf");
	AddFileToDownloadsTable("materials/models/duffle/phongwarp.vtf");

	AddFileToDownloadsTable("models/hostags/hostage_varianta.dx90.vtx");
	AddFileToDownloadsTable("models/hostags/hostage_varianta.mdl");
	AddFileToDownloadsTable("models/hostags/hostage_varianta.phy");
	AddFileToDownloadsTable("models/hostags/hostage_varianta.vvd");

	PrecacheModel("models/hostags/hostage_varianta.mdl", true)

	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.dx80.vtx");
	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.dx90.vtx");
	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.mdl");
	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.phy");
	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.sw.vtx");
	AddFileToDownloadsTable("models/cod/sentryv4/cod_sentryv4.vvd");
	PrecacheModel("models/cod/sentryv4/cod_sentryv4.mdl", true);

	PrecacheSound("vehicles/loud_helicopter_lp_01.wav", true);

	AddFileToDownloadsTable("materials/cod/sentryv4/SentryGunWY.vmt");
	AddFileToDownloadsTable("materials/cod/sentryv4/SentryGunWY_D.vtf");
	PrecacheModel("materials/sprites/ledglow.vmt", true);
	PrecacheModel("materials/sprites/ledglow.vtf", true);
	AddFileToDownloadsTable("sound/cod/knife_stab.mp3");
	AddFileToDownloadsTable("sound/cod/ks/sentry_achieve1.mp3");
	AddFileToDownloadsTable("sound/cod/ks/sentry_achieve2.mp3");
	AddFileToDownloadsTable("sound/cod/ks/sentry_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/sentry_friendly.mp3");
	AddFileToDownloadsTable("sound/cod/sentry_shoot.mp3");
	AddFileToDownloadsTable("sound/cod/semtex.mp3");
	AddFileToDownloadsTable("sound/cod/down1.mp3");
	AddFileToDownloadsTable("sound/cod/down2.mp3");
	AddFileToDownloadsTable("sound/cod/down3.mp3");
	AddFileToDownloadsTable("sound/cod/down4.mp3");
	AddFileToDownloadsTable("sound/cod/levelup.mp3");
	AddFileToDownloadsTable("sound/cod/bonus.mp3");
	AddFileToDownloadsTable("sound/cod/ks/cp_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/cp_friendly.mp3");
	AddFileToDownloadsTable("sound/cod/ks/cp_achieve2.mp3");
	AddFileToDownloadsTable("sound/cod/ks/counter_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/counter_friend.mp3");
	AddFileToDownloadsTable("sound/cod/ks/counter_give.mp3");
	AddFileToDownloadsTable("sound/cod/ks/uav_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/uav_friend.mp3");
	AddFileToDownloadsTable("sound/cod/ks/uav_give.mp3");
	AddFileToDownloadsTable("sound/cod/ks/air_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/air_friend.mp3");
	AddFileToDownloadsTable("sound/cod/ks/air_give.mp3");
	AddFileToDownloadsTable("sound/cod/ks/predator_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/predator_friend.mp3");
	AddFileToDownloadsTable("sound/cod/ks/predator_give.mp3");
	AddFileToDownloadsTable("sound/cod/ks/emp_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/emp_friend.mp3");
	AddFileToDownloadsTable("sound/cod/ks/emp_give.mp3");
	AddFileToDownloadsTable("sound/cod/ks/emp_effect.mp3");
	AddFileToDownloadsTable("sound/cod/ks/pr_fly.mp3");
	AddFileToDownloadsTable("sound/cod/ks/pr_start.mp3");
	AddFileToDownloadsTable("sound/cod/mw2_spawn3.mp3");
	AddFileToDownloadsTable("sound/cod/exhausted.mp3");
	AddFileToDownloadsTable("sound/cod/claymore.mp3");
	AddFileToDownloadsTable("sound/cod/claymore_t.mp3");

	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap1.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap1.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap1_n.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap2.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap2.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/caleon1/nkpolice/policemap2_n.vtf");

	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice.mdl");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice.phy");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice.vvd");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/caleon1/nkpolice/nkpolice_arms.vvd");

	PrecacheModel("models/player/custom_player/caleon1/nkpolice/nkpolice.mdl", true)
	PrecacheModel("models/player/custom_player/caleon1/nkpolice/nkpolice_arms.mdl", true)

	AddFileToDownloadsTable("sound/cod/ks/jet_fly1.mp3");
	AddFileToDownloadsTable("sound/cod/ks/jet_fly2.mp3");
	AddFileToDownloadsTable("sound/cod/ks/heli_achieve.mp3");
	AddFileToDownloadsTable("sound/cod/ks/heli_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/heli_friendly.mp3");
	AddFileToDownloadsTable("sound/cod/ks/straferun_achieve.mp3");
	AddFileToDownloadsTable("sound/cod/ks/straferun_enemy.mp3");
	AddFileToDownloadsTable("sound/cod/ks/straferun_friendly.mp3");
	AddFileToDownloadsTable("sound/cod/loud_helicopter_lp_01.mp3");
	PrecacheSoundAny("cod/knife_stab.mp3", true);
	PrecacheSoundAny("cod/ks/sentry_achieve1.mp3", true);
	PrecacheSoundAny("cod/ks/sentry_achieve2.mp3", true);
	PrecacheSoundAny("cod/ks/sentry_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/sentry_friendly.mp3", true);
	PrecacheSoundAny("cod/sentry_shoot.mp3", true);
	PrecacheSoundAny("cod/semtex.mp3", true);
	PrecacheSoundAny("cod/down1.mp3", true);
	PrecacheSoundAny("cod/down2.mp3", true);
	PrecacheSoundAny("cod/down3.mp3", true);
	PrecacheSoundAny("cod/down4.mp3", true);
	PrecacheSoundAny("cod/levelup.mp3", true);
	PrecacheSoundAny("cod/bonus.mp3", true);
	PrecacheSoundAny("cod/ks/cp_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/cp_friendly.mp3", true);
	PrecacheSoundAny("cod/ks/cp_achieve2.mp3", true);
	PrecacheSoundAny("cod/ks/counter_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/counter_friend.mp3", true);
	PrecacheSoundAny("cod/ks/counter_give.mp3", true);
	PrecacheSoundAny("cod/ks/uav_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/uav_friend.mp3", true);
	PrecacheSoundAny("cod/ks/uav_give.mp3", true);
	PrecacheSoundAny("cod/ks/air_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/air_friend.mp3", true);
	PrecacheSoundAny("cod/ks/air_give.mp3", true);
	PrecacheSoundAny("cod/ks/predator_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/predator_friend.mp3", true);
	PrecacheSoundAny("cod/ks/predator_give.mp3", true);
	PrecacheSoundAny("cod/ks/emp_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/emp_friend.mp3", true);
	PrecacheSoundAny("cod/ks/emp_give.mp3", true);
	PrecacheSoundAny("cod/ks/emp_effect.mp3", true);
	PrecacheSoundAny("cod/mw2_spawn3.mp3", true);
	PrecacheSoundAny("cod/ks/jet_fly1.mp3", true);
	PrecacheSoundAny("cod/ks/jet_fly2.mp3", true);
	PrecacheSoundAny("cod/ks/heli_achieve.mp3", true);
	PrecacheSoundAny("cod/ks/heli_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/heli_friendly.mp3", true);
	PrecacheSoundAny("cod/ks/straferun_achieve.mp3", true);
	PrecacheSoundAny("cod/ks/straferun_enemy.mp3", true);
	PrecacheSoundAny("cod/ks/straferun_friendly.mp3", true);
	PrecacheSoundAny("cod/ks/pr_fly.mp3", true);
	PrecacheSoundAny("cod/ks/pr_start.mp3", true);
	PrecacheSoundAny("cod/loud_helicopter_lp_01.mp3", true);
	PrecacheSoundAny("cod/claymore.mp3", true);
	PrecacheSoundAny("cod/claymore_t.mp3", true);
	PrecacheSound( "weapons/c4/c4_disarm.wav", true );
	PrecacheSoundAny("cod/exhausted.mp3", true);
	PrecacheSoundAny("weapon/negev/negev-1.wav", true);

	PrecacheModel("models/props_junk/wood_crate001a.mdl", true);
	PrecacheModel("models/parachute/parachute_carbon.mdl",true);
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.mdl" );
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.dx80.vtx" );
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.dx90.vtx" );
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.sw.vtx" );
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.vvd" );
	AddFileToDownloadsTable( "models/parachute/parachute_carbon.xbox.vtx" );
	AddFileToDownloadsTable( "materials/models/parachute/parachute_carbon.vmt" );
	AddFileToDownloadsTable( "materials/models/parachute/parachute_carbon.vtf" );
	AddFileToDownloadsTable( "materials/models/parachute/pack_carbon.vtf" );
	AddFileToDownloadsTable( "materials/models/parachute/pack_carbon.vmt" );

	AddFileToDownloadsTable( "materials/models/items/ammocrate_smg1.vmt" );
	AddFileToDownloadsTable( "materials/models/items/ammocrate_items.vmt" );
	AddFileToDownloadsTable( "materials/models/items/ammocrate_smg1.vtf" );
	AddFileToDownloadsTable( "materials/models/items/ammocrate_items.vtf" );
	AddFileToDownloadsTable( "materials/models/items/ammocrate_normal.vtf" );
	
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.dx90.vtx" );
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.dx80.vtx" );
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.mdl" );
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.phy" );
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.sw.vtx" );
	AddFileToDownloadsTable( "models/items/ammocrate_smg1.vvd" );

	PrecacheModel("models/items/ammocrate_smg1.mdl",true);	
	
	PrecacheSound( "weapons/hegrenade/explode3.wav" );
	PrecacheSound( "weapons/hegrenade/explode4.wav" );
	PrecacheSound( "weapons/hegrenade/explode5.wav" );

	CreateTimer(1.5, HUD, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	UAVTicks[CS_TEAM_T] = 0;
	UAVTicks[CS_TEAM_CT] = 0;
	UAVTIMER[CS_TEAM_T] = null;
	UAVTIMER[CS_TEAM_CT] = null;

	g_beamsprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_halosprite = PrecacheModel("materials/sprites/halo.vmt");
} 

public void onMapEnd()
{
	for(int i = 0; i < sizeof(teamHasUAV); i++) {
		teamHasUAV[i] = false;
		teamHasAdvanceUAV[i] = false;
	}

	first_killer = 0;

}

public Action OnJoinTeam(int client, char[] command, int numArgs)
{
	if (!IsClientInGame(client) || numArgs < 1) return Plugin_Continue;

	if(!IsPlayerAlive(client))
		CreateTimer(0.5, RespawnClient, GetClientUserId(client));

	return Plugin_Continue;
}

public Action RespawnClient(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client == 0) return;
	
	if(IsClientInGame(client) && !IsPlayerAlive(client) && GetClientTeam(client) > 1) CS_RespawnPlayer(client)
}


public void OnClientPostAdminCheck(int client)
{
	if(IsValidClient(client) && !IsFakeClient(client))
	{
		LoadData(client);
		LoadData2(client);

		SelectedClass[client] = false;
		PlayerHasTatical[client] = false;

		SendConVarValue(client, sv_footsteps, "0");
	}

	ResetStuff(client, true);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	//if(!IsFakeClient(client))
		//SDKHook(client, SDKHook_ReloadPost, Hook_OnReloadPost);
}

public Action OnWeaponDrop(int client, int weapon)
{	
	return Plugin_Handled;
}

public void OnPostThinkPost(int client)
{
	if(hasPerk(client, "Steady Aim"))
	{
		float NoRecoil[3];
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", NoRecoil);
	}

	if(hasPerk(client, "Marksman")) 
	{
		for(int entity = 1; entity <= MaxClients; entity++)
		{
		    if(IsValidClientAlive(entity) && entity != client) 
		    {
		        if(IsValidClientAlive(entity) && IsValidClientAlive(client) && GetClientTeam(entity) != GetClientTeam(client)) 
		        {
		            if(IsVisibleTo(entity, client)) 
		            {
		                SetEntProp(entity, Prop_Send, "m_bSpotted", 1);
		            }
		        }
		    }
		}
    }
	/*if(hasEquipment(client, "Claymore"))
	{
		char cWeapon[32];
		Client_GetActiveWeaponName(client, cWeapon, 32);

		if(StrEqual(cWeapon, "weapon_c4"))
			Weapon_SetViewModelIndex(Client_GetActiveWeapon(client), PrecacheModel("models/cod/claymore/claymore.mdl", true));
	}*/
}

public Action OnWeaponSwitch(int client, int weapon) 
{
    DoQuickDraw(client, weapon)
    DoOverKill(client, weapon)
    DoReaperSwitch(client, weapon)
    

}

public void OnEntityCreated(int iEntity, const char[] classname) 
{
	DoGrenade(iEntity, classname);
	DoShotgunsReload(iEntity, classname);
}

public void Radar(int client)
{
	SetEntPropEnt(client, Prop_Send, "m_bSpotted", 1);
}  

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!IsValidClient(attacker))
		return Plugin_Handled;

	if(!IsValidClient(victim))
	{
		char Classname[32];
		GetEntityClassname(victim, Classname, 32);

		if(StrEqual(Classname, "attack_helicopter", false))
			Heli_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)
		else if(StrEqual(Classname, "straferun_helicopter", false))
			Straferun_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)
		else if(StrEqual(Classname, "reaper", false))
			Reaper_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)
		else if(StrEqual(Classname, "cod_sentry", false))
			Sentry_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)
		else if(StrEqual(Classname, "claymore", false))
			Claymore_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)
		else if(StrEqual(Classname, "cod_ballisitcdrop", false))
			Vest_OnTakeDamage(victim, attacker, inflictor, damage, damagetype)

		return Plugin_Handled;
	}

	if (victim == attacker/* || (GetClientTeam(attacker) == GetClientTeam(victim)) */ )
		return Plugin_Handled;

	char inflictorClass[32];
	GetEntityClassname(inflictor, inflictorClass, 32);

	last_attacker[victim] = attacker
	damage_prcnt_from[victim][attacker] = RoundFloat((Math_Clamp(damage, 0.0, 100) / 100) * 100.0);
	damage_count[victim]++
	lastHit[victim] = GetGameTime() + 5.0;

	if(damagetype & DMG_BLAST)
	{
		if(hasPerk(victim, "Blast Shield"))
			damage = damage/2.0;
		if(hasPerk(victim, "Recon"))
			SetEntProp(victim, Prop_Send, "m_bSpotted", 1);	

		if(hasEquipment(attacker, "Bouncy Betty") && StrEqual(inflictorClass, "weapon_hegrenade") && GetClientButtons(victim) & IN_DUCK)
			damage = damage/3.0;
	}

	int dmgtype = DMG_SLASH|DMG_NEVERGIB;

	if(0 < inflictor <= MaxClients && inflictor == attacker && damagetype == dmgtype)
	{
		g_bHeadshot[attacker] = false; // no headshot when slash

		if(g_hTimerDelay[attacker] != INVALID_HANDLE)
		{
			KillTimer(g_hTimerDelay[attacker]);
			g_hTimerDelay[attacker] = INVALID_HANDLE;
		}
	}

	if(IsValidClientAlive(inflictor))
	{
		char sWeapon[32]; 
		GetClientWeapon(inflictor, sWeapon, sizeof(sWeapon));

		if (StrContains(sWeapon, "knife", false) != -1) 
		{ 
			damage = 1000.0;
			return Plugin_Changed; 
		} 
	}

	return Plugin_Changed;
}

public void Event_PlayerHurt(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int healthRemaining = GetEventInt(event, "health");
	
	if (healthRemaining <= 0)
	{
		int c4ent = GetPlayerWeaponSlot(client, CS_SLOT_C4);
		
		if (c4ent != INVALID_ENT_REFERENCE)
		{
			RemovePlayerItem(client, c4ent);
		}
	}
}

public Action OnKnifeAttack(int client, char[] command, int argc)
{
	if(IsValidClientAlive(client))
		KnifeAttack[client] = true;
}

public void Event_PlayerUse( Handle event, char[] name, bool dontBroadcast )
{
    openCP(event, name, dontBroadcast)
    openBallistic(event, name, dontBroadcast)
}


public void Event_OnPlayerDeath(Handle event, char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	//int assist = GetClientOfUserId(GetEventInt(event, "assister"));
	bool headshot = GetEventBool(event, "headshot");

	char szWeapon[32];
	GetEventString(event, "weapon", szWeapon, sizeof(szWeapon));

	if( attacker == victim)
		return;

	//GiveXP(attacker, GetConVarInt(XP_Kill));

	is_selfkill[victim] = (victim == attacker || !IsClientConnected(attacker)) ? true : false

	last_kill[attacker] = GetGameTime();

	if(!StrEqual(szWeapon, "weapon_knife", false) || !StrEqual(szWeapon, "cod_sentry", false) || !StrContains(szWeapon, "grenade", false) || !StrContains(szWeapon, "env_explosion", false))
		is_bullet_kill[attacker] = true

	to_payback[victim][attacker] = true

	death_inrow[victim]++;

	do_combo(attacker);

	extra_points_calcs(attacker, victim, headshot)

	createMagazine(victim);
	//if(IsValidClient(assist))
	//	ShowPointAdd(assist, GetConVarInt(XP_Assist))
		//GiveXP(assist, GetConVarInt(XP_Assist));

	PlayerStatsInfo[attacker][KillStreak]++;

	if(!IsFakeClient(attacker))
		SaveData(attacker);

	doKillStreaks(attacker);

	int randomsound = GetRandomInt(1, 4)
	switch(randomsound)
	{
		case 1: {EmitSoundToClientAny(attacker, "cod/down1.mp3", _, SNDCHAN_STATIC ); }
		case 2: {EmitSoundToClientAny(attacker, "cod/down2.mp3", _, SNDCHAN_STATIC ); }
		case 3: {EmitSoundToClientAny(attacker, "cod/down3.mp3", _, SNDCHAN_STATIC ); }
		case 4: {EmitSoundToClientAny(attacker, "cod/down4.mp3", _, SNDCHAN_STATIC ); }
	}

	ResetStuff(victim, false);
	/*if(!IsVoteInProgress())
	{
		UpdateHUD_CSGO2(attacker);
		UpdateHUD_CSGO2(victim);
	}*/
}

public void Event_OnRoundStart(Handle event, char[] name, bool dontBroadcast) 
{
	EmitSoundToAllAny("cod/mw2_spawn3.mp3");
}

public void Event_OnPlayerSpawn(Handle event, char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsValidClientAlive(client) && !SelectedClass[client] && !IsFakeClient(client))
	{
		//BlockSpawn(client);
		//return;
		if(AreClientCookiesCached(client))
		{
			char sCookieValue[32];
			GetClientCookie(client, gLastClass, sCookieValue, sizeof(sCookieValue));

			int lastclass = StringToInt(sCookieValue);

			if(lastclass < 5)
			{
				//PrintToChat(client, "Last Class cookie is %d", lastclass)
				SetClass(client, lastclass)
			}
			else
			{
				//PrintToChat(client, "Last Class cookie is %d", lastclass-5)
				ChangeClass[client] = true;
				ChangeID[client] = lastclass-5;
			}
			SelectedClass[client] = true;
		}
		else
		{
			SetClass(client, GetRandomInt(0, 4));
		}
	}

	if(IsFakeClient(client)) {
		SetClass(client, GetRandomInt(0, 4));
	}

	CreateTimer(0.1, SetUpPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.1, HealthRegen, client, TIMER_REPEAT);

	if(PlayerHasTatical[client])
	{
		CreateTimer(0.1, tacInsertion, GetClientUserId(client))
	}

	if (death_inrow[client] >= 3)
	{
		is_comeback[client] = true
	}

	gSprinttime[client] = 4.0;

	if(hasPerk(client, "Extreme Conditioning"))
		gSprinttime[client] = 8.0;

}

public Action tacInsertion(Handle timer, any client)
{
	client = GetClientOfUserId(client)

	if(!IsValidClientAlive(client))
		return;

	if(!IsValidEntity(PlayerTaticalEnt[client]))
	{
		PlayerHasTatical[client] = false;
		return;
	}
	PlayerHasTatical[client] = false;
	float TactLocation[3];
	GetEntityOrigin(PlayerTaticalEnt[client], TactLocation);
	RemoveEdict(PlayerTaticalEnt[client]);
	TeleportEntity(client, TactLocation, NULL_VECTOR, NULL_VECTOR);
}

public Action OnSetTransmit(int entity, int client)
{
	/*if(showGlow[client]) {
		if(IsValidClientAlive(entity) && GetClientTeam(client) != GetClientTeam(entity))
		{
			return Plugin_Continue;
		}
	}*/

	/*if(hasPerk(client, "Marksman")) {
	    if(entity != client) {
	        if(IsValidClientAlive(entity) && IsValidClientAlive(client) && GetClientTeam(entity) != GetClientTeam(client)) {
	            if(IsVisibleTo(entity, client)) {
	                SetEntProp(entity, Prop_Send, "m_bSpotted", 1); return Plugin_Continue;
	            }
	        }
	    }
    }
*/
	//return Plugin_Handled;
	if(showGlow[client] && GetClientTeam(client) != GetClientTeam(skinOwner[entity]))
		return Plugin_Continue;
		
	return Plugin_Handled;
	//return !showGlow[client] ? Plugin_Handled : Plugin_Continue;
}
	
void SetupGlow(int entity, int r, int g, int b, int a, float range)
{
	static int offset;

	// Get sendprop offset for prop_dynamic_override
	if (!offset && (offset = GetEntSendPropOffs(entity, "m_clrGlow")) == -1)
	{
		LogError("Unable to find property offset: \"m_clrGlow\"!");
		return;
	}

	// Enable glow for custom skin
	SetEntProp(entity, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(entity, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(entity, Prop_Send, "m_flGlowMaxDist", range);
	

	// So now setup given glow colors for the skin
	SetEntData(entity, offset, r, _, true);    // Red
	SetEntData(entity, offset + 1, g, _, true) // Green
	SetEntData(entity, offset + 2, b, _, true) // Blue
	SetEntData(entity, offset + 3, a, _, true) // Alpha
}

public void weapon_fire(Handle event, char[] name,bool dontBroadcast)
{
	OnReaperFire(event, name, dontBroadcast);
	OnPredMissileFire(event, name, dontBroadcast);
	OnKnifeFire(event, name, dontBroadcast);
}

public void ResetStuff(int client, bool all)
{
	if(all)
	{
		SelectedClass[client] = false;
		RespawnTime[client] = 0.0;

		hasUAV[client] = false;
		hasCounterUAV[client] = false;
		hasCarePackage[client] = false;
		hasPredatorMissile[client] = false;
		hasSentryGun[client] = false;
		hasAirstrike[client] = false;
		hasAttackHeli[client] = false;
		hasStrafeRun[client] = false;
		hasReaper[client] = false;
		hasJuggernaut[client] = false;

		hasAirDropTrap[client] = false;
		hasEMP[client] = false;
		hasAdvanceUAV[client] = false;
		hasBallisticVest[client] = false;
	}
	
	wearingBallisticVest[client] = false
	InReaper[client] = false;
	KnifeAttack[client] = false;
	SprintTime[client] = 0.0;
	LastSprintReleased[client] = 0.0;
	g_bFlashed[client] = false;
	g_bScramblerFlashed[client] = false;
	flashDuration[client] = 0.0;
	lastHit[client] = 0.0
	PlayerStatsInfo[client][KillStreak] = 0;
	PlayerCombos[client] = 0;
	PlayerComboTime[client] = 0.0;
	temp_xp[client] = 0;
	last_attacker[client] = 0;
	damage_count[client] = 0;
	is_comeback[client] = false;
	last_kill[client] = 0.0;
	is_bullet_kill[client] = false;
	isJuggernaut[client] = false;

	reset_message_queue(client);
	for (int i = 1; i <= MaxClients; i++)
		if(IsValidClient(i))
			damage_prcnt_from[client][i] = 0
}

public Action SetUpPlayer(Handle timer, any client)
{
	if(!IsValidClientAlive(client))
		return;

	if (IsValidClientAlive(client) && !IsFakeClient(client) )
	{
		showGlow[client] = false;
		
		char model[PLATFORM_MAX_PATH];

		// Retrieve current player model
		GetClientModel(client, model, sizeof(model));

		// Remove old custom skin and create a new one with same model as player
		//CPS_RemoveSkin(client); // Does not make the model invisible. (useful for glows) (c) CustomPlayerSkins.inc file

		int skin = CPS_SetSkin(client, model, CPS_RENDER);

		skinOwner[skin] = client;
		//ownerSkin[client] = skin;
		//PrintToChat(client, "GLOW ENABLE")
		
		// Validate skin entity by SDKHookEx native return
		if (SDKHookEx(skin, SDKHook_SetTransmit, OnSetTransmit))
			SetupGlow(skin, 255, 0, 0, 255, 10000000.0);
			//SetupGlow(skin, 192, 160, 96, 64);
		//SDKHook(client, SDKHook_SetTransmit, OnSetTransmit)
		SetClientViewEntity(client, client);
	}

	if(CS_GetMVPCount(client) == 0)
		CS_SetMVPCount(client, PlayerStatsInfo[client][Level])
	/*if(CS_GetClientContributionScore(client) == 0)
		if(PlayerStatsInfo[client][Level] != MAX_LEVEL)
			CS_SetClientContributionScore(client, XPtoLevel[PlayerStatsInfo[client][Level]+1] - PlayerStatsInfo[client][XP]);
		else
			CS_SetClientContributionScore(client, 0);*/

	if(ChangeClass[client])
	{
		strcopy(PlayerClassInfo[client][PrimaryWeapon], 32, PlayerCustomClassInfo[client][ChangeID[client]][PrimaryWeapon]);
		strcopy(PlayerClassInfo[client][SecondaryWeapon], 32, PlayerCustomClassInfo[client][ChangeID[client]][SecondaryWeapon]);
		strcopy(PlayerClassInfo[client][Equipment], 32, PlayerCustomClassInfo[client][ChangeID[client]][Equipment]);
		strcopy(PlayerClassInfo[client][Tactical], 32, PlayerCustomClassInfo[client][ChangeID[client]][Tactical]);
		strcopy(PlayerClassInfo[client][PerkOne], 32, PlayerCustomClassInfo[client][ChangeID[client]][PerkOne]);
		strcopy(PlayerClassInfo[client][PerkTwo], 32, PlayerCustomClassInfo[client][ChangeID[client]][PerkTwo]);
		strcopy(PlayerClassInfo[client][PerkThree], 32, PlayerCustomClassInfo[client][ChangeID[client]][PerkThree]);
		strcopy(PlayerClassInfo[client][StrikePackage], 128, PlayerCustomClassInfo[client][ChangeID[client]][StrikePackage]);
		ChangeClass[client] = false;
	}

	if(ChangeClassStandard[client])
	{
		strcopy(PlayerClassInfo[client][PrimaryWeapon], 32, PlayerClassStandardInfo[client][PrimaryWeapon]);
		strcopy(PlayerClassInfo[client][SecondaryWeapon], 32, PlayerClassStandardInfo[client][SecondaryWeapon]);
		strcopy(PlayerClassInfo[client][Equipment], 32, PlayerClassStandardInfo[client][Equipment]);
		strcopy(PlayerClassInfo[client][Tactical], 32, PlayerClassStandardInfo[client][Tactical]);
		strcopy(PlayerClassInfo[client][PerkOne], 32, PlayerClassStandardInfo[client][PerkOne]);
		strcopy(PlayerClassInfo[client][PerkTwo], 32, PlayerClassStandardInfo[client][PerkTwo]);
		strcopy(PlayerClassInfo[client][PerkThree], 32, PlayerClassStandardInfo[client][PerkThree]);
		strcopy(PlayerClassInfo[client][StrikePackage], 128, PlayerClassStandardInfo[client][StrikePackage]);
		ChangeClassStandard[client] = false;		
	}

	/*if(!IsFakeClient(client))
	{
		SendConVarValue(client, FindConVar("weapon_accuracy_nospread"), "1")
		SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0")
		SendConVarValue(client, FindConVar("weapon_recoil_decay1_exp"), "99999")
		SendConVarValue(client, FindConVar("weapon_recoil_decay2_exp"), "99999")
		SendConVarValue(client, FindConVar("weapon_recoil_decay2_lin"), "99999")
		SendConVarValue(client, FindConVar("weapon_recoil_scale"), "0")
		SendConVarValue(client, FindConVar("weapon_recoil_suppression_shots"), "500")
	}*/

	Client_RemoveAllWeapons(client, "weapon_knife", true);

	if(hasEquipment(client, "Semtex") || hasEquipment(client, "Frag Grenade") || hasEquipment(client, "Bouncy Betty"))
		GivePlayerItem(client, "weapon_hegrenade");

	if(hasTactical(client, "Concussion Grenade") || hasTactical(client, "Flash Grenade") || hasTactical(client, "Tactical Insertion") || hasTactical(client, "Scrambler"))
		GivePlayerItem(client, "weapon_flashbang");

	if(hasTactical(client, "Tactical Awareness Grenade"))
		GivePlayerItem(client, "weapon_tagrenade");

	if(hasTactical(client, "Smoke Grenade"))
		GivePlayerItem(client, "weapon_smokegrenade");

	if(hasEquipment(client, "Claymore") || hasEquipment(client, "C4")) {
		//int claymore;
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			CS_SwitchTeam(client, CS_TEAM_T)
			GivePlayerItem(client, "weapon_c4")
			CS_SwitchTeam(client, CS_TEAM_CT)
		}
		else
		{
			GivePlayerItem(client, "weapon_c4")
		}
	}

	if(hasEquipment(client, "Throwing Knife"))
		g_iPlayerKniveCount[client] = 1;

	/*if(hasPerk(client, "Marksman") && !IsFakeClient(client))
		SDKHook(client, SDKHook_SetTransmit, MarksmanTransmit);*/
		//CreateTimer(0.5, MarksmanCheck, client, TIMER_REPEAT);

	if(hasPerk(client, "Stalker"))
		CreateTimer(0.1, DoStalker, client, TIMER_REPEAT)

	if(hasPerk(client, "Overkill") && !IsFakeClient(client))
	{
		SetupOverkill(client)
	}
	
	if(!hasPerk(client, "Overkill"))
	{
		int mainGun = GivePlayerItem(client, PlayerClassInfo[client][PrimaryWeapon]);
		int SecGun = GivePlayerItem(client, PlayerClassInfo[client][SecondaryWeapon]);

		//Client_SetWeaponPlayerAmmoEx(client, mainGun, GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")) 
		//Client_SetWeaponPlayerAmmoEx(client, SecGun, GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_SECONDARY), Prop_Send, "m_iPrimaryReserveAmmoCount")) 
		if(mainGun != -1) Client_SetWeaponPlayerAmmoEx(client, mainGun, Weapon_GetPrimaryAmmoCount(mainGun)) 
		if(SecGun != -1) Client_SetWeaponPlayerAmmoEx(client, SecGun, Weapon_GetSecondaryAmmoCount(SecGun)) 
	}
}

public Action ClassCallBack(int client, int args)
{
	ClassMenu(client);
}

public Action test(int client, int args)
{
	//DoReaper(client);
	PrintToChat(client, "Glow Status is: %s", showGlow[client] ? "ON" : "OFF")
	KillStreakRewardMenuTEST(client);
}

public Action KillStreakRewardMenuTEST(int client)
{
	Handle menu = CreateMenu(KillStreakRewardMenuTEST_Handle);

	char szMsg[128];
	char szItems[128];	
	Format(szMsg, sizeof( szMsg ), "Killstreak: %d", PlayerStatsInfo[client][KillStreak]);
	SetMenuTitle(menu, szMsg);

	Format(szItems, sizeof( szItems ), "UAV" );
	AddMenuItem(menu, "UAV", szItems);

	Format(szItems, sizeof( szItems ), "Counter-UAV" );
	AddMenuItem(menu, "CounterUAV", szItems);
	
	Format(szItems, sizeof( szItems ), "Care Package" );
	AddMenuItem(menu, "Care Package", szItems);
	
	Format(szItems, sizeof( szItems ), "Predator Missile" );
	AddMenuItem(menu, "Predator Missile", szItems);		
	
	Format(szItems, sizeof( szItems ), "Sentry Gun" );
	AddMenuItem(menu, "Sentry Gun", szItems);

	Format(szItems, sizeof( szItems ), "Precision Airstrike" );
	AddMenuItem(menu, "Precision Airstrike", szItems);

	Format(szItems, sizeof( szItems ), "Attack Helicopter" );
	AddMenuItem(menu, "Attack Helicopter", szItems);
	
	Format(szItems, sizeof( szItems ), "Strafe Run" );
	AddMenuItem(menu, "Strafe Run", szItems);

	Format(szItems, sizeof( szItems ), "Reaper" );
	AddMenuItem(menu, "Reaper", szItems);

	Format(szItems, sizeof( szItems ), "Juggernaut" );
	AddMenuItem(menu, "Juggernaut", szItems);
	
	Format(szItems, sizeof( szItems ), "Airdrop Trap" );
	AddMenuItem(menu, "Airdrop Trap", szItems);

	Format(szItems, sizeof( szItems ), "EMP" );
	AddMenuItem(menu, "EMP", szItems);

	Format(szItems, sizeof( szItems ), "Advance UAV" );
	AddMenuItem(menu, "Advance UAV", szItems);

	Format(szItems, sizeof( szItems ), "Ballistic Vest" );
	AddMenuItem(menu, "Ballistic Vest", szItems);

	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER );
}

public int KillStreakRewardMenuTEST_Handle(Handle menu, MenuAction action, int client, int item)
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

/*public Action Hook_SetTransmit(int entity, int client)  
{  
	//SetEntProp(Entity_GetModelIndex(entity), Prop_Send, "m_bShouldGlow", true, true)
    if (entity != client)  
        return Plugin_Handled; 
      
    return Plugin_Continue;  
}  */

public Action OnPlayerRunCmd( int client, int &buttons )
{
	KillStreak_OnPlayerRunCmd(client, buttons);
	Sprint_OnPlayerRunCmd(client, buttons);
	SleightOfHand_OnPlayerRunCmd(client, buttons);
	
	C4_OnPlayerRunCmd(client, buttons);
	Claymore_OnPlayerRunCmd(client, buttons);
	BouncyBetty_OnPlayerRunCmd(client, buttons);

	CarePackageOpen_OnPlayerRunCmd(client, buttons);

	KnifeRightClickOnly(client, buttons);

	doKnifeAttack(client, buttons);
}  

public Action KnifeRightClickOnly( int client, int &buttons )
{
	
	if(buttons & IN_ATTACK && Client_GetActiveWeapon(client) == Client_GetWeaponBySlot(client, CS_SLOT_KNIFE) && !InReaper[client])
	{
		Event event = CreateEvent("weapon_fire");
		if (event == null)
		{
			return;
		}
	 
		event.SetInt("userid", GetClientUserId(client));
		event.SetString("weapon", "knife");
		event.SetBool("silenced", false);
		event.Fire();

		buttons &= ~IN_ATTACK
		buttons = IN_ATTACK2	
	}
}

public Action doKnifeAttack( int client, int &buttons )
{
	if(KnifeAttack[client])
	{ 
		static int lastWep[MAXPLAYERS+1];

		if(nextKnifeAttack[client] == 0.0)
		{
			if(IsSprinting[client])
			{
				LastSprintReleased[client] = GetGameTime();
				SprintTime[client] += ( GetGameTime() - LastSprintUsed[client]);
				SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
				IsSprinting[client] = false;
				SetEntPropFloat(client,Prop_Data,"m_flNextAttack", GetGameTime());
			}
			lastWep[client] = Client_GetActiveWeapon(client);
			Client_SetActiveWeapon(client, Client_GetWeaponBySlot(client, CS_SLOT_KNIFE));
			nextKnifeAttack[client] = GetGameTime() + 0.15;
		}

		if(GetGameTime() > nextKnifeAttack[client])
		{
			EmitSoundToClientAny(client, "cod/knife_stab.mp3", _, SNDCHAN_STATIC );
			buttons = IN_ATTACK2;
			nextKnifeAttackBack[client] = GetGameTime() + 0.35;
			nextKnifeAttack[client] = 999999.9;
		}

		if(GetGameTime() > nextKnifeAttackBack[client])
		{
			nextKnifeAttackBack[client] = 999999.9;
			nextKnifeAttack[client] = 0.0;
			Client_SetActiveWeapon(client, lastWep[client]);
			KnifeAttack[client] = false;
		}
	}
}

public void OnGameFrame()
{
	CarePackage_OnGameFrame();
	SentryGun_OnGameFrame();
	PredatorMissile_OnGameFrame();
	Ballistic_OnGameFrame();
	PrecisionAirstrike_OnGameFrame();
	AttackHeli_OnGameFrame();
	StrafeRun_OnGameFrame();

	Reaper_OnGameFrame();
	ReaperMissile_OnGameFrame();
	


	for (int i=1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			if( GetGameTime() > PlayerComboTime[i] && PlayerComboTime[i] != 0.0 )
			{
				PlayerComboTime[i] = 0.0;
				// combo announces
				if (PlayerCombos[i] == 2) add_message_in_queue(i, BM_DOUBLE_KILL, MESSAGE_POINTS[BM_DOUBLE_KILL])
				if (PlayerCombos[i] == 3) add_message_in_queue(i, BM_TRIPLE_KILL, MESSAGE_POINTS[BM_TRIPLE_KILL])
				if (PlayerCombos[i] >  3) add_message_in_queue(i, BM_MULTI_KILL, MESSAGE_POINTS[BM_MULTI_KILL])
				
				// points add up
				//GiveXP(i, temp_xp[i]);
				//set_task(2.0, "check_player_xp", id);
				temp_xp[i] = 0;
				PlayerCombos[i] = 0;
			}
		}
	}
}


public Action Command_LAW(int client, char[] command, int argc)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	if(hasEquipment(client, "C4"))
	{
		if(IsValidEntity(playersC4[client]))
		{
			explodeC4(client);
			return Plugin_Handled;
		}
	}
	if(!IsVoteInProgress())
		UpdateHUD_CSGO2(client);

	return Plugin_Continue;
}


public void m_bSetGlow(int client, bool value)
{
	SetEntPropFloat(client, Prop_Send, "m_flDetectedByEnemySensorTime", value ? (GetGameTime() + 9999.0) : 0.0);
}

stock int CreatePlayerModelProp(int entity, char[] sModel) {
	int Ent = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(Ent, "model", sModel);
	DispatchKeyValue(Ent, "disablereceiveshadows", "1");
	DispatchKeyValue(Ent, "disableshadows", "1");
	DispatchKeyValue(Ent, "solid", "0");
	DispatchKeyValue(Ent, "spawnflags", "256");
	SetEntProp(Ent, Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(Ent);
	//SetEntProp(Ent, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW|EF_PARENT_ANIMATES);
	SetVariantString("!activator");
	AcceptEntityInput(Ent, "SetParent", entity, Ent, 0);

	//SetVariantString("primary");
	//AcceptEntityInput(Ent, "SetParentAttachment", Ent, Ent, 0);

	return Ent;
}

public Action OnSetTransmitEntity(int entity, int client)
{
	if(hasPerk(client, "Sitrep") && GetClientTeam(client) != GetClientTeam(EntityOwner[entity]))
		return Plugin_Continue;	
	return Plugin_Handled;
	//return !showGlow[client] ? Plugin_Handled : Plugin_Continue;
}

public Action OnSetTransmitEntityDuffel(int entity, int client)
{
	return IsValidClient(client) && IsValidClient(EntityOwner[entity]) && GetClientTeam(client) == GetClientTeam(EntityOwner[entity]) ? Plugin_Continue : Plugin_Handled;
}
