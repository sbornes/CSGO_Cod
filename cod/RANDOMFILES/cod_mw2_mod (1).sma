#define PLUGIN	"Modern Warfare 2"
#define VERSION	"1.3.6b"
#define AUTHOR	"D.Moder"

/*

    Modern Warfare 2 Mod
    Copyright (C) 2011 by D.Moder

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.



-	Description:						
-								
-	    Modern Warfare 2 (MW2) is a Counter-Strike server	
-	    side modification,  which turns the game into	
-	    Call of Duty: Modern Warfare 2 gameplay.		
-								
-								
-	This plugin gives you:					
-								
-	    - 14/16 of the perks in MW2				
-	      (the other 2 is not compatible with CS1.6)	
-								
-	    - 8/15 of the killstreak-rewards in MW2		
-	      (the other 8 are on the way!)			
-								
-	    - Customizable player classes			
-								
-	    - MW2 models! (Optional)				
-								
-	    - Military Rankings					
-								
-	    - Melee attack (character pulls knife out and 	
-	      attacks instantly)				
-								
-	    - Health regeneration				
-								
-	    - Martyrdom death streak (3! deaths no kill)	
-								
-	    - TDM Respawn system (credits to MeRcyLeZZ)		
-								
-	    - Hitmarker						
-								
-	    - Multi Kill Announcements (MW2 style)		
-								
-	    - Grenade launcher (attachment for AK47-M4A1)	
-								
-	Over all, it gives you the MW2 style game play and if	
-	you've seen the game before, you'll probably like it.	
-								
-								
\***************************************************************/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <orpheu_memory>
#include <orpheu_stocks>

// *** CHOOSE YOUR VAULT MODULE HERE ***

//#include <sqlx> 	// Save data using sqlx (comment to disable)
#include <nvault> 	// Save data using nVault (comment to disable)


/***************************************************************\
- Customizatios							-
\***************************************************************/
#define DO_RESPAWN			// comment to disable
#define RESPAWN_DELAY 	3.0		// automatic respawn in x sec.
#define MAXKS 		64 		// maximum killstreak rewards a player can hold
#define AUTOJOIN 			// comment to disable (credits to VEN)
#define ADMIN_ACCESS_FLAG  ADMIN_RCON 	// admin access flas
#define XACCURATE 			// doubles accuracy (comment to disable)

//#define TEST_MODE 			// this should only be On for testing (comment to disable)

// available weapons (DEagle is given as secondary for all classes)
new const PLAYER_CLASSES[] = { CSW_M4A1, CSW_P90, CSW_AK47, CSW_SCOUT, CSW_M249, CSW_M3 }

/******************** modify at your own risk! *****************\
-								-
- or if you touch 'em... did you know how sharp this sword is?	-
-								-
- o==[]::::::::::::::::>					-
-								-
\***************************************************************/
#define USUR 		0.40 		// User Screen(hud) Update Rate in sec. (0.20 and above no lags)
#define CLASSMAX 	6 		// no change
#define TIME_LIMIT	10.0 		// map time limit
#define SCORE_LIMIT 	7500 		// score limit
#define RESTART_DELAY 	16.0 		// seconds after round end until new round start
#define MAX_KS_SET 	3 		// maximum killstreak rewards per player
#define GODMODE_DELAY 	2.0		// on respawn you get x sec godmode
#define HP_LIMIT 	100.0		// health max
#define HUD_POS_X 	0.02 		// my hud x (percentage. 0.5 = in center)
#define HUD_POS_Y 	0.9 		// my hud y (percentage)
#define LIGHT_SPEED 	440.0		// speed when having lightwight on
#define DEF_SPEED 	240.0		// default speed
#define REMOVE_DROPPED 	15.0		// remove guns after x sec. (comment to disable)
#define DAMAGE_MULTI 	1.5 		// damage multiplier (when having StoppingPower or DangerClose on)
#define LASTSTAND_DUR 	10.0 		// the amount of time you live in Last Stand perk
#define MARTYRDOM_D 	2.5 		// seconds to explosion
#define MARTYRDOM_DS 	3 		// how many deaths no kills, to get a martyrdom
#define DMGTIME_XTRA 	0.35 		// add a little more time to grenade explosion time
#define GL_SAFTY_RANGE 	250.0 		// grenade launcher safty range (how long has to travel in order to explode!) (GL_POWER[3])
#define GL_MAX 		2 		// max nubetubes player can carry
#define CLASS_CHANGE_D 	3.5 		// seconds takes to change class (one man army)
#define ATTN_LOUD 	0.25 		// grenade sound range
#define HIDE_NORMAL 	(1<<1)|(1<<4)|(1<<5) // Flashlight, Timer, Money

// this is my baby. mmmuuah
#define USERPERKS(%1,%2) 	(perks[%1][player_class[%1]][%2])
#define USEREQUIP(%1) 		(equipment[%1][player_class[%1]])
#define USERKSR(%1) 		(player_killstreak_queue[%1][player_killstreak_index[%1]])
#define USERRANK(%1) 		(RANK_LABLE[player_rank[%1] - 1])
#define SAMETEAM(%1,%2) 	(get_user_team(%1) == get_user_team(%2))
#define eng_get_user_health(%1) floatround(GET_health(%1))
#define ADD_LANGUAGE(%1) 	formatex(tempLable,charsmax(tempLable),"%L",LANG_PLAYER,%1)
#define NAME_FORMAT 		" %i [%s] %L: %s" // rank - ranklable - enemy/friend - Name
#define HUD_FORMAT 		"%L:[%s] %L: %i [%s] " // Class: - Rank: rank - ranklable
#define PITCH_RANDOM(%1) 	random_num(100-%1,100+%1) // random pitch for emit_sound
#define VALIDTEAM(%1) 		(%1 == TEAM_T || %1 == TEAM_CT)
#define emit_sound_amb(%1,%2,%3,%4,%5) 	engfunc(EngFunc_EmitAmbientSound, 0, %1, %2, %3, %4, 0, %5)
#define IS_SEC(%1) 		(%1 == CSW_DEAGLE || %1 == CSW_GLOCK18)
#define RESET_MODEL(%1) 	set_user_info(%1, "model", g_playermodel[%1])

// user ent values set/get
#define GET_NADE_TYPE(%1) 		entity_get_int(%1, EV_INT_flTimeStepSound)
#define SET_NADE_TYPE(%1,%2) 		entity_set_int(%1, EV_INT_flTimeStepSound, %2)
#define GET_ATTACHED(%1) 		entity_get_edict(%1, EV_ENT_euser1)
#define SET_ATTACHED(%1,%2) 		entity_set_edict(%1, EV_ENT_euser1, %2)
#define GET_STUCK(%1) 			entity_get_int(%1, EV_INT_iuser1)
#define SET_STUCK(%1,%2) 		entity_set_int(%1, EV_INT_iuser1, %2)
#define GET_TRIGGERED(%1) 		entity_get_int(%1, EV_INT_iuser2)
#define SET_TRIGGERED(%1,%2) 		entity_set_int(%1, EV_INT_iuser2, %2)
#define GET_COUNTS_KS(%1) 		entity_get_int(%1, EV_INT_iuser4)
#define SET_COUNTS_KS(%1,%2) 		entity_set_int(%1, EV_INT_iuser4, %2)
#define GET_CP_CONTAINS(%1) 		entity_get_int(%1, EV_INT_iuser1)
#define SET_CP_CONTAINS(%1,%2) 		entity_set_int(%1, EV_INT_iuser1, %2)
#define GET_SENTRY_ACTIVE(%1) 		entity_get_int(%1, EV_INT_iuser2)
#define SET_SENTRY_ACTIVE(%1,%2) 	entity_set_int(%1, EV_INT_iuser2, %2)
#define GET_SENTRY_TARGET(%1) 		entity_get_int(%1, EV_INT_iuser3)
#define SET_SENTRY_TARGET(%1,%2) 	entity_set_int(%1, EV_INT_iuser3, %2)
#define SET_SENTRY_TILT_TURRET(%1,%2) 	set_pev(%1, pev_controller_1, %2) 	// has to be pev_

// easier switching
#define SET_origin(%1,%2) 		entity_set_origin(%1, %2) // bugfix
#define GET_owner(%1) 			entity_get_edict(%1, EV_ENT_owner)
#define SET_owner(%1,%2) 		entity_set_edict(%1, EV_ENT_owner, %2)
#define GET_classname(%1,%2) 		entity_get_string(%1, EV_SZ_classname, %2, charsmax(%2))
#define SET_classname(%1,%2) 		entity_set_string(%1, EV_SZ_classname, %2)
#define SET_viewmodel(%1,%2) 		entity_set_string(%1, EV_SZ_viewmodel, %2)
#define GET_dmgtime(%1) 		entity_get_float(%1, EV_FL_dmgtime)
#define SET_dmgtime(%1,%2) 		entity_set_float(%1, EV_FL_dmgtime, %2)
#define SET_nextthink(%1,%2) 		entity_set_float(%1, EV_FL_nextthink, %2)
#define GET_health(%1) 			entity_get_float(%1, EV_FL_health)
#define SET_health(%1,%2) 		entity_set_float(%1, EV_FL_health, %2)
#define GET_takedamage(%1) 		entity_get_float(%1, EV_FL_takedamage)
#define SET_takedamage(%1,%2) 		entity_set_float(%1, EV_FL_takedamage, %2)
#define SET_armorvalue(%1,%2) 		entity_set_float(%1, EV_FL_armorvalue, %2)
#define SET_frame(%1,%2) 		entity_set_float(%1, EV_FL_frame, %2)
#define SET_framerate(%1,%2) 		entity_set_float(%1, EV_FL_framerate, %2)
#define SET_maxspeed(%1,%2) 		entity_set_float(%1, EV_FL_maxspeed, %2)
#define SET_gravity(%1,%2) 		entity_set_float(%1, EV_FL_gravity, %2)
#define GET_flFallVelocity(%1) 		entity_get_float(%1, EV_FL_flFallVelocity)
#define GET_velocity(%1,%2) 		entity_get_vector(%1, EV_VEC_velocity, %2)
#define SET_velocity(%1,%2) 		entity_set_vector(%1, EV_VEC_velocity, %2)
#define GET_absmax(%1,%2) 		entity_get_vector(%1, EV_VEC_absmax, %2)
#define GET_angles(%1,%2) 		entity_get_vector(%1, EV_VEC_angles, %2)
#define SET_angles(%1,%2) 		entity_set_vector(%1, EV_VEC_angles, %2)
#define GET_mins(%1,%2) 		entity_get_vector(%1, EV_VEC_mins, %2)
#define GET_v_angle(%1,%2) 		entity_get_vector(%1, EV_VEC_v_angle, %2)
#define SET_punchangle(%1,%2) 		entity_set_vector(%1, EV_VEC_punchangle, %2)
#define GET_origin(%1,%2) 		entity_get_vector(%1, EV_VEC_origin, %2)
#define SET_body(%1,%2) 		entity_set_int(%1, EV_INT_body, %2)
#define SET_sequence(%1,%2) 		entity_set_int(%1, EV_INT_sequence, %2)
#define GET_button(%1) 			entity_get_int(%1, EV_INT_button)
#define SET_button(%1,%2) 		entity_set_int(%1, EV_INT_button, %2)
#define GET_flags(%1) 			entity_get_int(%1, EV_INT_flags)
#define SET_flags(%1,%2) 		entity_set_int(%1, EV_INT_flags, %2)
#define GET_spawnflags(%1) 		entity_get_int(%1, EV_INT_spawnflags)
#define SET_spawnflags(%1,%2) 		entity_set_int(%1, EV_INT_spawnflags, %2)
#define GET_effects(%1) 		entity_get_int(%1, EV_INT_effects)
#define SET_effects(%1,%2) 		entity_set_int(%1, EV_INT_effects, %2)
#define SET_colormap(%1,%2) 		entity_set_int(%1, EV_INT_colormap, %2)
#define SET_watertype(%1,%2) 		entity_set_int(%1, EV_INT_watertype, %2)
#define SET_movetype(%1,%2) 		entity_set_int(%1, EV_INT_movetype, %2)
#define GET_solid(%1) 			entity_get_int(%1, EV_INT_solid)
#define SET_solid(%1,%2) 		entity_set_int(%1, EV_INT_solid, %2)
#define SET_flTimeStepSound(%1,%2) 	entity_set_int(%1, EV_INT_flTimeStepSound, %2)
#define GET_frags(%1) 			floatround(entity_get_float(%1, EV_FL_frags))
#define SET_frags(%1,%2) 		entity_set_float(%1, EV_FL_frags, float(%2))

// MW2 rankings
#define RANKING_DIFFICULTY 	po_difficulty * 100.0
#define LEVEL_REQ_XP(%1) 	floatround(floatpower(float(%1) * RANKING_DIFFICULTY, 1.4054467)) // the fomula
#define MAXRANK 		70 	// last rank MW2 default (no change)

// uav
#define UAV_DUR 	30.0 	// how long uav stays on in seconds

// predator missile
#define PREDATOR_SPEED 	700 	// predator missile speed normal
#define ATTN_PREDATOR 	0.1 	// explosion sound range (used in emit_sound)

// care packare
#define CP_RESUPPLY 	-5 				// resupply
#define CP_TAKE_SPEED 	floatround(USUR * 100.0) 	// taking speed for owner
#define CP_STEAL_SPEED 	floatround(USUR * 25.0) 	// taking speed for others

// sentries (credits to The_Thing)
#define SENTRY_HEALTH 		200 	// Health
#define SENTRY_LIFE 		90.0 	// Seconds
#define SENTRY_RANGE 		1300.0 	// Range
#define SENTRY_RETARGET 	1.0 	// change target delay
#define SENTRY_DAMAGE 		28.0 	// sentry bullet damage

// precision
#define P_MAXBOMBS 		10 	// amount of bombs dropped from precision air strike
#define P_BOMBSPACE 		80 	// space between each bomb

// stealth
#define MAXBOMBS 		5 	// amount of bombs dropped from stealth bomber
#define BOMBSPACE 		150 	// space between each bomb
#define PLANE_Z 		200 	// plane height from ground

// EMP
#define EMP_HIDE_FLAGS 		(1<<0)|(1<<1)|(1<<3)|(1<<4)|(1<<5)  // hide in order: CAL + FLASH + RHA + TIMER + MONEY
#define EMP_DUR 		60.0 	// how long emp stays on in seconds

// class menu options
#define CREATE_YES 		-1
#define CREATE_NO 		-2

// CS Teams
#define TEAM_UNASSIGNED 0
#define TEAM_T 		1
#define TEAM_CT 	2
#define TEAM_SPECTATOR 	3

// CS zoom (cstrike.h)
#define CS_FIRST_ZOOM		0x28
#define CS_SECOND_AWP_ZOOM	0xA
#define CS_SECOND_NONAWP_ZOOM	0xF
#define CS_AUGSG552_ZOOM	0x37
#define CS_NO_ZOOM		0x5A

// for Last Stand perk
#define LS_WID 			0
#define LS_KILLER 		1

// Radius Damage Ratios (gl_radius_damage)
#define RDR_PREDATOR 		2.50 // predator missile
#define RDR_STEALTH 		2.00 // stealth bomber
#define RDR_PRECISION 		1.50 // precision airstrike

// grenade types
#define GT_FRAG 	1111
#define GT_SEMTEX 	2222
#define GT_FLASH 	3333
#define GT_SMOKE 	4444

// low health indicator stats
enum { HI_HIDE, HI_SHOW, HI_FLASH }

// Task offsets
enum (+= 100)
{
	TASK_MAINLOOP = 2000,
	TASK_GIVESTUFF,
	TASK_RESPAWN,
	TASK_GODMODE_OFF,
	TASK_PHURT,
	TASK_PBETTER,
	TASK_MELEE,
	TASK_MELEE_Q,
	TASK_ANNOUNCE,
	TASK_DEATH,
	TASK_CLAYMORE_EXPLODE,
	TASK_TACTICAL_INSERTION,
	TASK_MESSAGE_BONUS,
	TASK_SEMTEX_STICK,
	TASK_CLASS_CHANGE,
	TASK_ONTARGET,
	TASK_TARGET_RESET,
	TASK_SENTRY_ACTIVATE,
	TASK_SENTRY_DEACTIVATE,
	TASK_SENTRY_REMOVE,
	TASK_PRED_FLY,
	TASK_CAREPACKAGE,
	TASK_UN_EMP,
	TASK_PRECISIONAIRSTRIKE,
	TASK_STEALTHBOMBER,
	TASK_TACTICAL_NUKE
}

// perk types
enum { BLUE_PERK, RED_PERK, GREEN_PERK }

// perks
enum {
	// Blue perks
	PERK_MARATHON,
	PERK_SLEIGHT_OF_HAND,
	PERK_SCAVENGER,
	PERK_BLING, 	// unavailable
	PERK_ONE_MAN_ARMY,
	// red perks
	PERK_STOPPING_POWER,
	PERK_LIGHTWEIGHT,
	PERK_HARDLINE,
	PERK_COLD_BLOODED,
	PERK_DANGER_CLOSE,
	// green perks
	PERK_COMMANDO,
	PERK_STEADY_AIM,
	PERK_SCRAMBLER,
	PERK_NINJA,
	PERK_SITREP, 	// unavailable
	PERK_LAST_STAND
}

// equipments
enum
{
	UE_FRAG,
	UE_SEMTEX,
	UE_THROWING_KNIFE,
	UE_TACTICAL_INSERTION,
	UE_CLAYMORE,
	UE_C4
}

//  *** THIS IS NOT IN ORIGINAL ORDER ***
//  I'm still working on them
// killstreak rewards
enum
{
	KSR_UAV,
	KSR_CARE_PACKAGE,
	KSR_PREDATOR_MISSILE,
	KSR_SENTRY_GUN,
	KSR_PRECISION_AIRSTRIKE,
	KSR_STEALTH_BOMBER,
	KSR_EMP,
	KSR_TACTICAL_NUKE,
	KSR_TOTAL
}

// required kills for reward
new const KILLS_REQUIRED[] = 
{
	3, // uav
	4, // care
	5, // pred
	6, // sentry
	7, // prec
	9, // stealth
	15,// emp
	25 // nuke
}

// care package reward chances
new const CP_CHANCE[] = 
{
//	55  // Resupply!
	18, // uav
	0,  // - (invalid)
	7,  // pred
	6,  // sentry
	9,  // prec
	3,  // stealth
	2,  // emp
	0   // - (invalid)
}

// killstreak reward lables
new const KILLSTREAK_LABLE[][] = 
{
	"UAV",
	"Care Package",
	"Predator Missile",
	"Sentry Gun",
	"Precision Airstrike",
	"Stealth Bomber",
	"EMP",
	"Tactical Nuke"
}

// killstreaks use extra XP
new const KS_USE_POINT[] = 
{
	150, // uav
	100, // care
	100, // pred
	100, // sentry
	150, // prec
	200, // stealth
	400, // emp
	150  // nuke
}

// killstreak sound types
// used in KSE_SOUNDS
enum
{
	KSST_ACHIEVE1,
	KSST_ACHIEVE2,
	KSST_ENEMY,
	KSST_FRIENDLY
}

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
	BM_AVENGER
}

// bonus messages points
new const MESSAGE_POINTS[] = 
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
	50
}

// bonus messages lables
new const MESSAGE_LABLE[][] = 
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
	"Avenger!"
}

// player ranking lables (MW2!)
new const RANK_LABLE[MAXRANK][]=
{
	"Private",
	"Private I",
	"Private II",
	"Private First Class",
	"Private First Class I",
	"Private First Class II",
	"Specialist",
	"Specialist I",
	"Specialist II",
	"Corporal",
	"Corporal I",
	"Corporal II",
	"Sergeant",
	"Sergeant I",
	"Sergeant II",
	"Staff Sergeant",
	"Staff Sergeant I",
	"Staff Sergeant II",
	"Sergeant First Class",
	"Sergeant First Class I",
	"Sergeant First Class II",
	"Master Sergeant",
	"Master Sergeant I",
	"Master Sergeant II",
	"First Sergeant",
	"First Sergeant I",
	"First Sergeant II",
	"Sergeant Major",
	"Sergeant Major I",
	"Sergeant Major II",
	"Command Sergeant Major",
	"Command Sergeant Major I",
	"Command Sergeant Major II",
	"2nd Lieutenant",
	"2nd Lieutenant I",
	"2nd Lieutenant II",
	"1st Lieutenant",
	"1st Lieutenant I",
	"1st Lieutenant II",
	"Captain",
	"Captain I",
	"Captain II",
	"Major",
	"Major I",
	"Major II",
	"Lieutenant Colonel",
	"Lieutenant Colonel I",
	"Lieutenant Colonel II",
	"Lieutenant Colonel III",
	"Colonel",
	"Colonel I",
	"Colonel II",
	"Colonel III",
	"Brigadier General",
	"Brigadier General I",
	"Brigadier General II",
	"Brigadier General III",
	"Major General",
	"Major General I",
	"Major General II",
	"Major General III",
	"Lieutenant General",
	"Lieutenant General I",
	"Lieutenant General II",
	"Lieutenant General III",
	"General",
	"General I",
	"General II",
	"General III",
	"Commander"
}

// pdata offsets
const EXTRAOFFSET 		= 5
const EXTRAOFFSET_WEAPONS 	= 4
const OFFSET_MAPZONE 		= 235
const OFFSET_ZOOMTYPE 		= 363
const OFFSET_CSDEATHS 		= 444
const OFFSET_HE_AMMO 		= 388
const m_rgpPlayerItems_Slot0 	= 367
const m_pNext 			= 42
const m_iId 			= 43
const m_pActiveItem 		= 373
const m_pPlayer 		= 41
const m_fInReload 		= 54
const m_flNextAttack 		= 83
const m_flNextPrimaryAttack 	= 46
const m_flNextSecondaryAttack 	= 47
const m_iShotsFired 		= 64

const IC_FLASHLIGHT = 100

// stuff for Display_Fade
const UNIT_SECOND 	= (1<<12)
const FFADE_IN 		= 0x0000
const FFADE_OUT 	= 0x0001
const FFADE_MODULATE 	= 0x0002
const FFADE_STAYOUT 	= 0x0004

// catch shot event (credits to VEN)
new g_fwid, g_guns_eventids_bitsum
new const g_guns_events[][] = {
	"events/awp.sc",
	"events/g3sg1.sc",
	"events/ak47.sc",
	"events/scout.sc",
	"events/m249.sc",
	"events/m4a1.sc",
	"events/sg552.sc",
	"events/aug.sc",
	"events/sg550.sc",
	"events/m3.sc",
	"events/xm1014.sc",
	"events/usp.sc",
	"events/mac10.sc",
	"events/ump45.sc",
	"events/fiveseven.sc",
	"events/p90.sc",
	"events/deagle.sc",
	"events/p228.sc",
	"events/glock18.sc",
	"events/mp5n.sc",
	"events/tmp.sc",
	"events/elite_left.sc",
	"events/elite_right.sc",
	"events/galil.sc",
	"events/famas.sc"
}

// all wavs and mdls used.
new const 
	ROCKET_MDL[] = 		"models/grenade.mdl",
	MEDKIT_MDL[] = 		"models/w_battery.mdl",
	MARTYRDOM_MDL[] = 	"models/w_hegrenade.mdl",
	CLAYMORE_MODEL[] = 	"models/v_tripmine.mdl",
	CLAYMORE_TRIGGER_MODEL[] = "models/bag.mdl",
	C4_MODEL[] = 		"models/w_c4.mdl",
	TI_MODEL[] = 		"models/w_flare.mdl",
	PACKAGE_HELI_MODEL[] = 	"models/stealth.mdl", 		// c.p.
	PACKAGE_PACK_MODEL[] = 	"models/w_gaussammo.mdl", 	// c.p.
	PICKUP_SOUND[] = 	"items/gunpickup2.wav",
	NADEDROP_SOUND[] = 	"weapons/he_bounce-1.wav",
	DRY_SOUND[] = 		"weapons/dryfire1.wav",
	SWITCH_SOUND[] = 	"buttons/lightswitch2.wav",
	STEALTH_FLYBY_SOUND[] = "ambience/jetflyby1.wav", 	// c.p.
	NUKE_HIT_SOUND[] = 	"weapons/mortarhit.wav", 	// nuke
	SMOKE_SOUND[] = 	"weapons/sg_explode.wav",
	
	TKNIFE_MODEL[] = 	"models/codmw2/w_throwingknife.mdl",
	KNIFE_DEP_SOUND[] = 	"codmw2/knife_deploy1.wav",
	KNIFE_HIT_SOUND[][] = 	{ "codmw2/knife_hit1.wav", "codmw2/knife_hit2.wav" },
	KNIFE_WAL_SOUND[] = 	"codmw2/knife_hitwall1.wav",
	KNIFE_SLA_SOUND[] = 	"codmw2/knife_slash1.wav",
	KNIFE_STA_SOUND[] = 	"codmw2/knife_stab.wav",
	MENU1_SOUND[] = 	"codmw2/menu1.wav",
	ANNOUNCE_SOUND[] = 	"codmw2/announcer.wav",
	BONUS_SOUND[] = 	"codmw2/bonus.wav",
	FLASH_BEEP[] = 		"codmw2/fbeep.wav",
	GL_SOUND[] = 		"codmw2/gl_thro.wav",
	R_REL_SOUND[] = 	"codmw2/gl_relo.wav",
	EXPLDE_SOUND[] = 	"codmw2/gl_expl.wav",
	EXPLDE2_SOUND[][] = 	{ "codmw2/gr_expl_1.wav", "codmw2/gr_expl_2.wav", "codmw2/gr_expl_3.wav" },
	MEDKIT_SOUND[] = 	"codmw2/mk_pickup.wav",
	SND_BETTER[] = 		"codmw2/pl_better.wav",
	BULLETX_SOUND[][] = 	{ "codmw2/hitmark_0.wav", "codmw2/hitmark_1.wav", "codmw2/hitmark_2.wav", "codmw2/hitmark_3.wav" },
	SND_WARN[][] = 		{ "codmw2/pl_hurt_1.wav", "codmw2/pl_hurt_2.wav", "codmw2/pl_hurt_3.wav" },
	CLAYMORE_SOUND[] = 	"codmw2/claymore.wav",
	CLAYMORE_T_SOUND[] = 	"codmw2/claymore_t.wav",
	THROW_SOUND[] = 	"codmw2/throw.wav",
	C4_STUCK_SOUND[] = 	"codmw2/c4_stuck.wav",
	C4_TRIGGER_SOUND[] = 	"codmw2/c4_trigger.wav",
	SEMTEX_SOUND[] = 	"codmw2/semtex.wav",
	TKNIFE_SOUND[] = 	"codmw2/tknife.wav",
	TI_SOUND[] = 		"codmw2/ti.wav",
	FLASH_SOUND[] = 	"codmw2/flashbang.wav",
	BADNEWS_SOUND[] = 	"codmw2/badnews.wav",
	HEADSHOT_SOUND[] = 	"codmw2/headshot.wav",
	WIND_SOUND[] = 		"codmw2/wind.wav",
	OMA_SOUND[] = 		"codmw2/oma_change.wav",
	TDM_SOUND[] = 		"codmw2/TDM.wav",
	MEND_SOUND[][] = 	{ "codmw2/mission_success1.wav", "codmw2/mission_success2.wav", "codmw2/mission_fail1.wav", "codmw2/mission_fail2.wav" },
	
	ROUND_START_SOUND[] = 	"codmw2/mp3/roundstart.mp3",   // mp3
	ROUND_NUKE_SOUND[] = 	"codmw2/mp3/defeat_nuke.mp3",
	ROUND_LOSE_SOUND[] = 	"codmw2/mp3/roundlose.mp3",
	ROUND_WIN_SOUND[] = 	"codmw2/mp3/roundwin.mp3",
	LEVELUP_MP3[] = 	"codmw2/mp3/levelup2.mp3",
	
	// sentry gun
	SENRYBASE_MODEL[] = 	"models/sentry.mdl",
	SENRY_MODEL[] = 	"models/codmw2/sentry1.mdl",
	SENTRY_BLT[] = 		"models/rshell.mdl",
	SENTRY_SHOOT[] = 	"codmw2/ks/sentry_shoot.wav",
	SENTRY_SPOT[] = 	"fvox/buzz.wav",
	SENTRY_READY[] = 	"buttons/button9.wav",
	SENTRY_BREAK[] = 	"buttons/spark6.wav",
	
	// predator missile
	PR_EXPL_SOUND[][] = 	{ "codmw2/ks/pr_explo_1.wav", "codmw2/ks/pr_explo_2.wav", "codmw2/ks/pr_explo_3.wav" },
	PR_FLY[] = 		"codmw2/ks/pr_fly.wav",
	PR_FLY_START[] = 	"codmw2/ks/pr_start.wav",
	PR_FLY_STOP[] = 	"codmw2/ks/pr_fly_stop.wav",
	
	// tactical nuke
	NUKE_ALARM_SOUND[] = 	"codmw2/ks/nuke_alarm.wav",
	
	// killstreak sounds + announces
	KSE_SOUNDS[][][] = 
	{
		{ "codmw2/ks_earn/uav_achieve1.wav", "codmw2/ks_earn/uav_achieve2.wav", "codmw2/ks_earn/uav_enemy.wav", "codmw2/ks_earn/uav_friendly.wav" }, 			// UAV
		{ "codmw2/ks_earn/cp_achieve1.wav", "codmw2/ks_earn/cp_achieve2.wav", "codmw2/ks_earn/cp_enemy.wav", "codmw2/ks_earn/cp_friendly.wav" }, 			// CARE PACKAGE
		{ "codmw2/ks_earn/pred_achieve1.wav", "codmw2/ks_earn/pred_achieve2.wav", "codmw2/ks_earn/pred_enemy.wav", "codmw2/ks_earn/pred_friendly.wav" }, 		// PREDATOR MISSILE
		{ "codmw2/ks_earn/sentry_achieve1.wav", "codmw2/ks_earn/sentry_achieve2.wav", "codmw2/ks_earn/sentry_enemy.wav", "codmw2/ks_earn/sentry_friendly.wav" }, 	// SENTRY GUN
		{ "codmw2/ks_earn/prec_achieve1.wav", "codmw2/ks_earn/stealth_achieve2.wav", "codmw2/ks_earn/prec_enemy.wav", "codmw2/ks_earn/stealth_friendly.wav" }, 	// PRECISION AIRSTRIKE
		{ "codmw2/ks_earn/stealth_achieve1.wav", "codmw2/ks_earn/stealth_achieve2.wav", "codmw2/ks_earn/stealth_enemy.wav", "codmw2/ks_earn/stealth_friendly.wav" }, 	// STEALTH BOMBER
		{ "codmw2/ks_earn/emp_achieve1.wav", "codmw2/ks_earn/emp_achieve2.wav", "codmw2/ks_earn/emp_enemy.wav", "codmw2/ks_earn/emp_friendly.wav" }, 			// EMP
		{ "codmw2/ks_earn/nuke_achieve1.wav", "codmw2/ks_earn/nuke_achieve2.wav", "codmw2/ks_earn/nuke_enemy.wav", "codmw2/ks_earn/nuke_friendly.wav" } 		// TACTICAL NUKE
	}

// optional MW2 models
new const V_AK47_MODEL[] = 	"models/codmw2/v_ak47.mdl" 	// AK47
new const V_DEAGLE_MODEL[] = 	"models/codmw2/v_deagle.mdl" 	// DEAGLE
new const V_M3_MODEL[] = 	"models/codmw2/v_m3.mdl" 	// SPAS-12
new const V_M4A1_MODEL[] = 	"models/codmw2/v_m4a1.mdl" 	// M4A1
new const V_M249_MODEL[] = 	"models/codmw2/v_m249.mdl" 	// M249
new const V_SCOUT_MODEL[] = 	"models/codmw2/v_scout.mdl" 	// INTERVENTION
new const V_P90_MODEL[] = 	"models/codmw2/v_p90.mdl" 	// P90
new const V_KNIFE_MODEL[] = 	"models/codmw2/v_knife.mdl" 	// KNIFE
new const V_GLOCK18_MODEL[] = 	"models/codmw2/v_glock18.mdl" 	// KNIFE

new const INTERVENTION_FIRE[] = "weapons/intervention_fire.wav" // intervention sound!!!

// all weapon names (without weapon_)
new const WEAPONNAMES[][] = { "", "p228", "", "scout", "hegrenade", "xm1014", "c4", "mac10", "aug",
			"smokegrenade", "elite", "fiveseven", "ump45", "sg550", "galil", "famas",
			"usp", "glock18", "awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1",
			"flashbang", "deagle", "sg552", "ak47", "knife", "p90", "", ""}


// Max BP ammo for weapons
new const MAXBPAMMO[] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120,
			30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 }
// Max bullets in each pack
new const AMMOPACK[] = { -1, 13, -1, 30, -1, 8, -1, 12, 30, -1, 30, 50, 12, 30, 30, 30, 12, 30,
			10, 30, 30, 8, 30, 30, 30, -1, 7, 30, 30, -1, 50 }
// ammo types (sorted by weapon index!)
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "",
			"9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm",
			"338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm", "762nato",
			"", "50ae", "556nato", "762nato", "", "57mm" }

new const WEAPONSLOT[] = {
	-1, 2, -1, 1, 4, 1, 5, 1, 1, 4, 2, 2, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 4, 2, 1, 1, 3, 1
}

// objectives to remove
new const g_objective_ents[][] = { "func_bomb_target", "info_bomb_target", "hostage_entity", 
	"monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "info_vip_start", 
	"func_vip_safetyzone", "func_escapezone"
}

// unreloadables
const NOCLIP_WPN_BS	= ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
const SHOTGUNS_BS	= ((1<<CSW_M3)|(1<<CSW_XM1014))

// lables for perks
new const PERKS_LABLE[][] = {
	"[Marathon]",
	"[Sleight of Hand]",
	"[Scavenger]",
	"[Bling]",
	"[One Man Army]",
	
	"[Stopping Power]",
	"[Lightweight]",
	"[Hardline]",
	"[Cold-Blooded]",
	"[Danger Close]",
	
	"[Commando]",
	"[Steady Aim]",
	"[Scrambler]",
	"[Ninja]",
	"[SitRep]",
	"[Last Stand]"
}

// lables for equipments
new const EQUIPMENTS_LABLE[][] = {
	"[Frag]",
	"[Semtex]",
	"[Throwing knife]",
	"[Tactical insertion]",
	"[Claymore]",
	"[C4]"
}

// load / save
#if defined _sqlx_included
	new Handle:g_SqlTuple
	new g_Error[512]
#endif
#if defined _nvault_included
	new g_vault
#endif

// add language
new tempLable[128]

// class names
new const glnade_classname[] = "cod_glnade", medkit_classname[] = "cod_medkit", martyrdom_classname[] = "cod_martyrdom"
new const claymore_classname[] = "cod_claymore", claymore_trigger_classname[] = "cod_claymoret", c4_classname[] = "cod_c4", tknife_classname[] = "cod_tknife", ti_classname[] = "cod_ti"
new const sentrybase_classname[] = "sentrybase", sentry_classname[] = "sentry", sentryblt_classname[] =  "sentrybullet"
new const pred_classname[] = "predator_missile", bomb_classname[] = "stealth_bomb", stealth_classname[] = "cod_stealth", package_classname[] = "care_package", pbomb_classname[] = "precision_bomb"

// grenade launcher settings
new const Float:GL_POWER[] = { 2.0, 1500.0, 110.0, 250.0 } // (delay,speed,damage,range)

// func_breakable materials
//    0 = Glass, 1 = Wood, 2 = Metal, 3 = Flesh, 4 = Cinder Block
//    5 = Ceiling Tile, 6 = Computer, 7 = Unbreakable Glass, 8 = Rocks
new const material_Computer[] = "6"

// Orpheu stuff
#define set_mp_pdata(%1,%2)	( OrpheuMemorySetAtAddress( g_pGameRules, %1, 1, %2 ) )
#define get_mp_pdata(%1)	( OrpheuMemoryGetAtAddress( g_pGameRules, %1 ) )
enum /* Win Status */
{
	WinStatus_Ct = 1,
	WinStatus_Terrorist,
	WinStatus_RoundDraw
};
new g_pGameRules

// global vars
new imp_falldamage
new bool:g_newround, Float:g_round_started_time, team_score[4], bool:score_freeze, winner
new g_maxplayers, g_maxentities
new spr_explosion, spr_trail, spr_white, spr_smoke, spr_money
new g_MsgSyncHUD, g_MsgSyncAX
new g_fwSpawn, g_fwPrecacheSound
new g_msgStatusIcon, g_msgScreenFade, g_msgDeathMsg, g_msgHostagePos, g_msgHostageK, g_msgBarTime2, g_msgHideWeapon, g_msgScreenShake, g_msgDamage, g_msgScoreInfo
new g_flasher, Float:flash_explosion_time // flash grenade things
new g_pluginenabled, toggle_used // MW2 enabled

new po_enable, po_skin, Float:po_difficulty, po_start_hp, po_medkit_hp, po_random_spawn, po_desert_fx
new sqlx_host[64], sqlx_user[32], sqlx_pass[32], sqlx_db[32]

// **************
// *   Arrays   *
// **************

// gameplay things
new Float:melee_time[33], bool:g_isFalling[33], hasgl[33], g_playermodel[33][32], g_playername[33][32],
	bool:low_hp_warning[33], bool:had_knife[33], g_szAuthID[33][35], g_currentweapon[33],
	Float:last_glnade[33], bool:glsets[33][3], player_used_bind[33], user_last_target[33],
	Float:combo_time[33], player_combos[33] = 0, first_spawn[33], Float:aim_target[33],
	g_assists[33], g_kills[33], g_deaths[33]

// XP things
new player_points[33], player_rank[33], temp_xp[33], first_killer, bool:is_selfkill[33]
new bool:got_bullseye[33], last_attacker[33], damage_count[33], damage_prcnt_from[33][33]
new bool:to_payback[33][33], bool:is_bullet_kill[33], bool:is_comeback[33], Float:last_kill[33]
new player_message_queue[33][16], player_message_index[33] // bonus message queue

// player class-perks, ks-sets
new player_class[33], is_creating[33], user_next_class[33], bool:is_changing[33]
new perks[33][CLASSMAX][3], in_last_stand[33][2], martyrdoms[32], death_inrow[33], bool:using_martyrdom[33]
new bool:user_killstreak_set[33][KSR_TOTAL], bool:user_ks_temp[33][KSR_TOTAL], bool:is_user_ks_set[33]

// Equipments stuff
new equipment[33][CLASSMAX]
new player_c4[33][2] 		// stores ent#
new player_claymore[33][2] 	// stores ent# (only 2 of them per person)
new player_ti[33] 		// stores ent# (only 1)
new bool:has_c4[33], bool:has_claymore[33], bool:has_ti[33], bool:has_tknife[33]

// killstreak stuff
new kills_no_deaths[33], player_killstreak_queue[33][MAXKS], player_killstreak_index[33]
new bool:killstreak_counts_ks[33][MAXKS]
new bool:hasUAV[4], Float:uavEndTime[4], has_sentry[33], bool:ignore_ks_add[33], user_ctrl_pred[33], user_pred_speed[33], user_stealth[33], user_precision[33]
new bool:is_EMPd[4], id_nuker, team_nuker, nuke_countdown, bool:is_nuke_time
new Float:cpd_time[33], cpd_taking_package[33], cpd_progress[33]

// random spawns from ZP 4.3 (credits to MeRcyLeZZ)
const MAX_CSDM_SPAWNS = 128
new g_spawnCount, g_spawnCount2 // available spawn points counter
new Float:g_spawns[MAX_CSDM_SPAWNS][3], Float:g_spawns2[MAX_CSDM_SPAWNS][3] // spawn points data

/*---------------------*\
- Plugin initialization -
\*---------------------*/
public plugin_init()
{
	// plugin enable?
	if (!g_pluginenabled) return
	
	// language file
	register_dictionary("cod_mw2.txt")
	
	// events
	register_event 	("DeathMsg", 	"event_DeathMsg", 	"a", 	"1>0"			) // death event
	register_event 	("Damage", 	"event_Damage", 	"b", 	"2!0", 	"3=0", 	"4!0"	) // damage event
	register_event 	("HLTV", 	"event_HLTV", 		"a", 	"1=0", 	"2=0"		) // round start
	register_event 	("CurWeapon", 	"event_CurWeapon", 	"be", 	"1=1"			) // check weapon
	register_event 	("ResetHUD", 	"event_ResetHUD", 	"b"				) // random spawn
	
	// fakemeta forwards
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	#if defined XACCURATE
	register_forward(FM_StartFrame, 	"fw_StartFrame")
	#endif
//	register_forward(FM_Touch, 		"fw_Touch")
	register_forward(FM_CmdStart, 		"fw_CmdStart")
	register_forward(FM_SetModel, 		"fw_SetModel")
	register_forward(FM_EmitSound, 		"fw_EmitSound")
	register_forward(FM_FindEntityInSphere, "fw_FindEntityInSphere", 0)
	if (po_skin) register_forward(FM_SetClientKeyValue, "fw_SetClientKeyValue")
	unregister_forward(FM_Spawn, 		g_fwSpawn)
	unregister_forward(FM_PrecacheSound, 	g_fwPrecacheSound)
	
	// catch shot event (credits to VEN)
	unregister_forward(FM_PrecacheEvent, g_fwid, 1)
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")
	
	// ham forwards
	RegisterHam(Ham_TakeDamage, "player", 	"fw_TakeDamage")
	RegisterHam(Ham_Spawn,      "player", 	"fw_PlayerSpawn_Post", 1)
	RegisterHam(Ham_Killed,     "player", 	"fw_PlayerKilled")
	RegisterHam(Ham_Think,      "grenade", 	"fw_ThinkGrenade")
	RegisterHam(Ham_Player_PreThink, "player", "fw_Player_PreThink")
	RegisterHam(Ham_Player_PostThink, "player", "fw_Player_PostThink")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_scout", "fw_ScoutSecondaryAttack_Post", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_m4a1", "fw_M4A1SecondaryAttack", 1)
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_glock18", "CGLOCK18_PrimaryAttack_Post", true)
	
	// self note: fw_Touch / fw_Player_PreThink / fw_Player_PostThink
	
	new sWeapon[32]
	for(new i=1; i<=CSW_P90; i++)
		if(!(NOCLIP_WPN_BS&(1<<i)) && !(SHOTGUNS_BS&(1<<i)) && get_weaponname(i, sWeapon, charsmax(sWeapon)))
			RegisterHam(Ham_Weapon_Reload, sWeapon, "Weapon_Reload", 1)
	
	// console commands
	register_clcmd("say", 		"cmd_say")
	register_clcmd("glfire", 	"cmd_glfire")
	register_clcmd("radio2", 	"cmd_glfire")
	register_clcmd("radio3", 	"cmd_c4det")
	register_clcmd("flashsmoke", 	"cmd_flashsmoke")
	register_clcmd("codclass", 	"cmd_cchoose_menu")
	register_clcmd("codkillstreak", "cmd_codkillstreak")
	register_clcmd("chooseteam", 	"cmd_gamemenu")
	
	// messages
	g_msgStatusIcon = get_user_msgid("StatusIcon")
	g_msgScreenFade = get_user_msgid("ScreenFade")
	g_msgDeathMsg 	= get_user_msgid("DeathMsg")
	g_msgBarTime2 	= get_user_msgid("BarTime2")
	g_msgHideWeapon = get_user_msgid("HideWeapon")
	g_msgScreenShake= get_user_msgid("ScreenShake")
	g_msgHostagePos = get_user_msgid("HostagePos")
	g_msgHostageK 	= get_user_msgid("HostageK")
	g_msgDamage 	= get_user_msgid("Damage")
	g_msgScoreInfo 	= get_user_msgid("ScoreInfo")
	register_message(g_msgStatusIcon, "msgStatusIcon")
	register_message(g_msgScreenFade, "msgScreenFade")
	register_message(g_msgHideWeapon, "msgHideWeapon")
	#if defined AUTOJOIN
	register_message(get_user_msgid("ShowMenu"), "msgShowMenu")
	register_message(get_user_msgid("VGUIMenu"), "msgVGUIMenu")
	#endif
	
	// no dead bodies!
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET)
	
	// no radio sounds
	set_msg_block(get_user_msgid("SendAudio"), BLOCK_SET)
	
	// some global vars
	g_maxplayers 	= get_maxplayers()
	g_maxentities 	= global_get(glb_maxEntities)
	g_MsgSyncHUD 	= CreateHudSyncObj()
	g_MsgSyncAX 	= CreateHudSyncObj()
	
	// load / save
	#if defined _sqlx_included
		set_task(1.0, "MySql_Init")
	#endif
	#if defined _nvault_included
		g_vault = nvault_open(AUTHOR)
		if (g_vault == INVALID_HANDLE) set_fail_state("Error opening nVault")
	#endif
	
	// mp cvar pointers
	imp_falldamage = get_cvar_num("mp_falldamage") // just value
	
	// cvar settings
	set_cvar_num("sv_cheats", 1)
	set_cvar_num("mp_playerid", 2)
	set_cvar_num("mp_flashlight", 1)
//	set_cvar_float("mp_buytime", 0.0)
//	set_cvar_num("sv_skycolor_r", 0)
//	set_cvar_num("sv_skycolor_g", 0)
//	set_cvar_num("sv_skycolor_b", 0)
	
	// announcements
	Task_Announce()
	
	// spawn spots
	load_spawns()
	
	#if !defined XACCURATE
	set_task(0.1, "fw_StartFrame", _, _, _, "b")
	#endif
	
	// uav loop
	set_task(2.0, "radar_scan", _, _, _, "b")
	
	// sentry think
	#if defined XACCURATE
	set_task(0.1, "sentry_think", _, _, _, "b")
	#endif
	
	score_freeze = false
}

public plugin_end()
{
	if (!g_pluginenabled) return
	
	#if defined _sqlx_included
		SQL_FreeHandle(g_SqlTuple)
	#endif
	
	#if defined _nvault_included
		nvault_close(g_vault)
	#endif
}



/*-------------------
|   Plugin precache   |
  -------------------*/
public plugin_precache()
{
	// whos done all the work here?
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// load the config file
	load_cod_mw2_ini()
	
	// To switch plugin on/off
	register_concmd("cod_toggle", "cmd_toggle", _, "<1/0> - Enable/Disable Modern Warfare 2", 0)
	
	if (toggle_used)
		toggle_used = 0
	else
		g_pluginenabled = 1
	
	if (!po_enable || !g_pluginenabled) return
	
	// Orpheu
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost);
	
	// precache files
	new d
	// avoid loading unneeded stuff (credits to MeRcyLeZZ)
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	g_fwPrecacheSound = register_forward(FM_PrecacheSound, "fw_PrecacheSound")
	
	// catch shot event (credits to VEN)
	g_fwid = register_forward(FM_PrecacheEvent, "fw_PrecacheEvent", 1)
	
	// recache models, sounds, sprites
	spr_explosion 	= precache_model("sprites/fexplo1.spr")
	spr_trail 	= precache_model("sprites/smoke.spr")
	spr_white 	= precache_model("sprites/white.spr")
	spr_smoke 	= precache_model("sprites/black_smoke4.spr")
	spr_money 	= precache_model("sprites/blood.spr")
	precache_model(ROCKET_MDL)
	precache_model(MEDKIT_MDL)
	precache_model(MARTYRDOM_MDL)
	precache_model(PACKAGE_HELI_MODEL)
	precache_model(PACKAGE_PACK_MODEL)
	precache_model(CLAYMORE_TRIGGER_MODEL)
	precache_model(CLAYMORE_MODEL)
	precache_model(C4_MODEL)
	precache_model(TI_MODEL)
	precache_model(TKNIFE_MODEL)
	precache_model(SENRYBASE_MODEL)
	precache_model(SENRY_MODEL)
	precache_model(SENTRY_BLT)
	precache_model("models/computergibs.mdl") // "6"
	
	// optional mw2 models/sounds
	if (po_skin)
	{
		for (d = 1; d <= 3; d++){
			new temp[64]
			formatex(temp, charsmax(temp), "models/player/rangers%i/rangers%i.mdl", d, d)
			precache_model(temp)
			formatex(temp, charsmax(temp), "models/player/spetsnaz%i/spetsnaz%i.mdl", d, d)
			precache_model(temp)
		}
		precache_model(V_AK47_MODEL)
		precache_model(V_DEAGLE_MODEL)
		precache_model(V_M3_MODEL)
		precache_model(V_M4A1_MODEL)
		precache_model(V_M249_MODEL)
		precache_model(V_SCOUT_MODEL)
		precache_model(V_P90_MODEL)
		precache_model(V_KNIFE_MODEL)
		precache_model(V_GLOCK18_MODEL)
		precache_sound("weapons/intervention_bolt1.wav")
		precache_sound("weapons/intervention_bolt2.wav")
		precache_sound("weapons/intervention_endbolt1.wav")
		precache_sound("weapons/intervention_endbolt2.wav")
		precache_sound("weapons/intervention_magin.wav")
		precache_sound("weapons/intervention_magout.wav")
		precache_sound("weapons/m249_boxin.wav")
		precache_sound("weapons/m249_boxout.wav")
		precache_sound("weapons/m249_chain.wav")
		precache_sound("weapons/m249_coverdown.wav")
		precache_sound("weapons/m249_coverup.wav")
		precache_sound("weapons/rpd_boltpull.wav")
		precache_sound("weapons/M4A1_Carbine/Clipin.wav")
		precache_sound("weapons/M4A1_Carbine/Clipout.wav")
		precache_sound("weapons/M4A1_Carbine/cloth.wav")
		precache_sound("weapons/M4A1_Carbine/Forearm.wav")
		precache_sound("weapons/p90_cock.wav")
		precache_sound("weapons/p90_magin.wav")
		precache_sound("weapons/p90_magout.wav")
		precache_sound("weapons/p90_unlock.wav")
		precache_sound("weapons/Glock/Glock_clipin.wav")
		precache_sound("weapons/Glock/Glock_clipout.wav")
		precache_sound("weapons/Glock/Glock_sliderelease.wav")
		precache_sound("weapons/Glock/Glock_slipslap.wav")
		precache_sound(INTERVENTION_FIRE)
	}
	precache_sound(SND_BETTER)
	precache_sound(KNIFE_DEP_SOUND)
	precache_sound(KNIFE_HIT_SOUND[0])
	precache_sound(KNIFE_HIT_SOUND[1])
	precache_sound(KNIFE_WAL_SOUND)
	precache_sound(KNIFE_SLA_SOUND)
	precache_sound(KNIFE_STA_SOUND)
	precache_sound(ANNOUNCE_SOUND)
	precache_sound(BONUS_SOUND)
	precache_sound(FLASH_BEEP)
	precache_sound(GL_SOUND)
	precache_sound(R_REL_SOUND)
	precache_sound(MEDKIT_SOUND)
	precache_sound(MENU1_SOUND)
	precache_sound(EXPLDE_SOUND)
	precache_sound(PICKUP_SOUND)
	precache_sound(DRY_SOUND)
	precache_sound(SWITCH_SOUND)
	precache_sound(NADEDROP_SOUND)
	for (d = 0; d < 3; d++){
		precache_sound(SND_WARN[d])
		precache_sound(EXPLDE2_SOUND[d])
		precache_sound(PR_EXPL_SOUND[d])
	}
	for (d = 0; d < 4; d++){
		precache_sound(BULLETX_SOUND[d])
		precache_sound(MEND_SOUND[d])
	}
	precache_sound(TDM_SOUND)
	precache_sound(CLAYMORE_SOUND)
	precache_sound(CLAYMORE_T_SOUND)
	precache_sound(TI_SOUND)
	precache_sound(THROW_SOUND)
	precache_sound(C4_STUCK_SOUND)
	precache_sound(C4_TRIGGER_SOUND)
	precache_sound(SEMTEX_SOUND)
	precache_sound(TKNIFE_SOUND)
	precache_sound(FLASH_SOUND)
	precache_sound(BADNEWS_SOUND)
	precache_sound(WIND_SOUND)
	precache_sound(ROUND_START_SOUND)
	precache_sound(ROUND_NUKE_SOUND)
	precache_sound(ROUND_LOSE_SOUND)
	precache_sound(ROUND_WIN_SOUND)
	precache_sound(HEADSHOT_SOUND)
	precache_sound(OMA_SOUND)
	precache_sound(SMOKE_SOUND)
	precache_sound(LEVELUP_MP3)
	precache_sound(SENTRY_SHOOT)
	precache_sound(SENTRY_READY)
	precache_sound(SENTRY_BREAK)
	precache_sound(SENTRY_SPOT)
	precache_sound(PR_FLY)
	precache_sound(PR_FLY_STOP)
	precache_sound(PR_FLY_START)
	precache_sound(STEALTH_FLYBY_SOUND)
	precache_sound(NUKE_ALARM_SOUND)
	precache_sound(NUKE_HIT_SOUND)
	precache_sound("debris/bustmetal1.wav") // "6"
	precache_sound("debris/bustmetal2.wav") // "6"
	precache_sound("debris/metal1.wav") // "6"
	precache_sound("debris/metal3.wav") // "6"
	
	// killstreak earn sounds
	for (d = 0; d <= charsmax(KSE_SOUNDS); d++)
		for (new i = 0; i <= charsmax(KSE_SOUNDS[]); i++)
			precache_sound(KSE_SOUNDS[d][i])
	
	// fog (weather effect credits to MeRcyLeZZ)
	if (po_desert_fx > 0)
	{
		new ent = create_entity("env_fog")
		if (is_valid_ent(ent))
		{
			new szDensity[6], Float:fDes = float(po_desert_fx) / 10000.0
			formatex(szDensity, charsmax(szDensity), "%f", fDes)
			DispatchKeyValue(ent, "density", szDensity) 		// fog density
			DispatchKeyValue(ent, "rendercolor", "128 128 128") 	// fog color
			set_task(13.0, "wind_sound_loop", _, _, _, "b") 	// wind
		}
	}
}

// ************************************************************************************************************
// ==================================================================================== registered cmds =======

// cod_toggle [1/0] (credits to MeRcyLeZZ)
public cmd_toggle(id, level, cid)
{
	if (!cmd_access(id, ADMIN_ACCESS_FLAG, cid, 2)) return PLUGIN_HANDLED
	
	new arg[2], num
	read_argv(1, arg, charsmax(arg))
	num = str_to_num(arg)
	if (!(num == 0 || num == 1)) return PLUGIN_HANDLED // 0-1 only!
	if (num == g_pluginenabled) return PLUGIN_HANDLED
	
	g_pluginenabled = num
	toggle_used = 1
	
	client_print(id, print_console, "%s %L.", id, PLUGIN, LANG_PLAYER, str_to_num(arg) ? "ENABLE" : "DISABLE")
	
	// Restart
	new mapname[32]
	get_mapname(mapname, charsmax(mapname))
	server_cmd("changelevel %s", mapname)
	return PLUGIN_HANDLED
}

public cmd_codkillstreak(id)
	use_killstreak(id)

// say command
public cmd_say(id)
{
	if (!is_user_connected(id) || score_freeze)
		return PLUGIN_CONTINUE
	
	new szArgs[32], szArg1[32], szArg2[32]
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	parse(szArgs, szArg1, charsmax(szArg1), szArg2, charsmax(szArg2))
	
	// no funny business here!
	#if defined TEST_MODE
	if(equali(szArg1, "/x"))
	{
		if (equal(szArg2, "hp")) eng_set_user_health(id, 100000)
		else if (equal(szArg2, "uav")) give_ks(id, KSR_UAV)
		else if (equal(szArg2, "cp")) give_ks(id, KSR_CARE_PACKAGE)
		else if (equal(szArg2, "sentry")) give_ks(id, KSR_SENTRY_GUN)
		else if (equal(szArg2, "pred")) give_ks(id, KSR_PREDATOR_MISSILE)
		else if (equal(szArg2, "stealth")) give_ks(id, KSR_STEALTH_BOMBER)
		else if (equal(szArg2, "prec")) give_ks(id, KSR_PRECISION_AIRSTRIKE)
		else if (equal(szArg2, "emp")) give_ks(id, KSR_EMP)
		else if (equal(szArg2, "nuke")) give_ks(id, KSR_TACTICAL_NUKE)
		else if (equal(szArg2, "gl")) hasgl[id] += 10
		else
			give_CSW(id, weapon_str_to_id(szArg2))
		return PLUGIN_HANDLED
	}
	#endif
	
	// show help motd
	if(equali(szArg1, "/help"))
		help_motd(id)
	
	return PLUGIN_CONTINUE
}

// use equipment / 
// predator missile speed boost
public cmd_equipment(id)
{
	if (!is_user_alive(id) || score_freeze)
		return
	
	// on predator missile give speed boost
	new pred = user_ctrl_pred[id]
	if (is_valid_ent(pred))
	{
		if (user_pred_speed[id] == PREDATOR_SPEED)
		{
			user_pred_speed[id] = PREDATOR_SPEED * 2
			emit_sound(pred, CHAN_AUTO, PR_FLY_START, VOL_NORM, ATTN_STATIC, 0, PITCH_RANDOM(2))
		}
		return
	}
	
	// use equipment
	switch(USEREQUIP(id))
	{
		case UE_FRAG, UE_SEMTEX:
		{
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				engclient_cmd(id, "weapon_hegrenade")
				set_pdata_float(id, m_flNextAttack, 0.0, EXTRAOFFSET)
				client_cmd(id, "+attack ; wait ; -attack")
			}
		}
		case UE_THROWING_KNIFE: throw_knife(id)
		case UE_TACTICAL_INSERTION: put_ti(id)
		case UE_CLAYMORE: put_claymore(id)
		case UE_C4:
		{
			// if already has setup some C4 and no more c4 in pocket, detonate, else set one
			if ( (player_c4[id][0] || player_c4[id][1]) && !has_c4[id])
				cmd_c4det(id)
			else
				put_c4(id)
		}
	}
}

// grenade launcher fire
public cmd_glfire(id)
{
	if (!is_user_alive(id) || score_freeze)
		return PLUGIN_HANDLED
	
	// faster reload if using Sleight Of Hand perk
	new Float:RelDelay = GL_POWER[0]
	RelDelay *= (USERPERKS(id, BLUE_PERK) == PERK_SLEIGHT_OF_HAND) ? 0.5 : 1.0
	new wid = g_currentweapon[id]
	if (wid == CSW_AK47 || wid == CSW_M4A1)
	{
		if (hasgl[id] > 0 && glsets[id][0])
		{
			emit_sound(id, CHAN_WEAPON, GL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			set_task (0.1, "glthrow", id)
			glsets[id][2] = true
			hasgl[id]--
			last_glnade[id] = get_gametime() + RelDelay
		}
		else if (!hasgl[id])
		{
			PlaySound(id, DRY_SOUND)
		}
	}
	return PLUGIN_HANDLED
}

public cmd_flashsmoke(id)
{
	if (!is_user_alive(id) || score_freeze)
		return
	
	new bool:pass = false
	if (user_has_weapon(id, CSW_FLASHBANG))
	{
		pass = true
		engclient_cmd(id, "weapon_flashbang")
	}
	else if (user_has_weapon(id, CSW_SMOKEGRENADE))
	{
		pass = true
		engclient_cmd(id, "weapon_smokegrenade")
	}
	if (pass)
	{
		set_pdata_float(id, m_flNextAttack, 0.0, EXTRAOFFSET)
		client_cmd(id, "+attack ; wait ; -attack")
		remove_task(TASK_MELEE_Q+id)
		set_task(0.8, "melee_switch_back", TASK_MELEE_Q+id)
	}
}

public cmd_melee(id)
{
	if (!is_user_alive(id) || score_freeze)
		return
	
	new Float:gltime = get_gametime()
	
	if (gltime < melee_time[id] || cpd_taking_package[id])
		return
	
	melee_time[id] = gltime + 1.5
	
	// better knife with commando pro perk
	commando_move(id)
	
	// switch to knife
	if (g_currentweapon[id] == CSW_KNIFE)
		had_knife[id] = true
	else{
		had_knife[id] = false
		engclient_cmd(id, "weapon_knife")
	}
	
	// do it fast!
	set_pdata_float(id, m_flNextAttack, 0.0, EXTRAOFFSET)
	
	// melee
	remove_task(TASK_MELEE+id)
	set_task(0.06, "melee_attack", TASK_MELEE+id)
	
	// switch back to previous weapon
	remove_task(TASK_MELEE_Q+id)
	set_task(0.8, "melee_switch_back", TASK_MELEE_Q+id)
}
public melee_attack(taskid){
	new id = taskid - TASK_MELEE
	if (!is_user_alive(id)) return PLUGIN_HANDLED
	client_cmd(id, "+attack ; wait ; -attack")
	return PLUGIN_HANDLED
}
public melee_switch_back(taskid){
	new id = taskid - TASK_MELEE_Q
	if (is_user_alive(id) && !had_knife[id])
		client_cmd(id, "lastinv")
	return PLUGIN_HANDLED
}

commando_move(id)
{
	if (!is_user_alive(id))
		return 0
	
	if (USERPERKS(id, GREEN_PERK) != PERK_COMMANDO)
		return 0
	
	// get player origin
	new Float:fOrigin[3], toAttack
	static Float:victimOrigin[3]
	GET_origin(id, fOrigin)
	
	// alive players
	new players[32], pnum, target
	get_players(players, pnum, "a")
	for (new i = 0; i < pnum; i++)
	{
		target = players[i]
		
		// enemy only
		if (SAMETEAM(id, target))
			continue
		
		// get enemy origin
		GET_origin(target, victimOrigin)
		
		// enemy has to be in player's view cone
		if (!is_in_viewcone(id, victimOrigin))
			continue
		
		// player has to be close enough to enemy
		if (get_distance_f(fOrigin, victimOrigin) > 400.0)
			continue
		
		// player has to be able to see enemy
		static hitent; hitent = trace_line(id, fOrigin, victimOrigin, victimOrigin)
		if (hitent != target)
			continue
		
		/*here on, player has a person standing right infront of him...
		*//////////////////////////////////////////////////////////////
		
		// the target will be the one last-aimed at
		if (!toAttack || target == user_last_target[id])
			toAttack = target
	}
	
	if (toAttack)
	{
		GET_origin(toAttack, victimOrigin)
		aim_target[id] = get_gametime() + 0.5 // for a half a sec stay on the target
		
		new param[1]
		param[0] = toAttack
		set_task(0.1, "stay_on_target", TASK_ONTARGET+id, param, sizeof param, "b")
		
		// increase melee distance
		static Float:velocity[3], xSpeed
		xSpeed = get_speed(id) + (USERPERKS(id, RED_PERK) == PERK_LIGHTWEIGHT ? 700 : 500)
		velocity_by_aim(id, xSpeed, velocity)
		velocity[2] = 5.0
		SET_velocity(id, velocity)
		
		return toAttack
	}
	
	return 0
}

// commando thing
public stay_on_target(param[], taskid)
{
	new id = taskid - TASK_ONTARGET
	new target = param[0]
	if (!is_user_alive(id) || !is_user_alive(target) || aim_target[id] < get_gametime())
	{
		remove_task(taskid)
		return
	}
	
	if (entity_range(id, target) < 100.0 && g_currentweapon[id] == CSW_KNIFE)
	{
		set_pdata_float(id, m_flNextAttack, 0.0, EXTRAOFFSET)
		client_cmd(id, "+attack2 ; wait ; -attack2")
	}
}

//======================================================================================= GAME MENU ==========
public cmd_gamemenu(id){
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	static menu
	ADD_LANGUAGE("MENU_L0")
	menu = menu_create(tempLable, "menu_handler")
	if (is_user_alive(id) && player_killstreak_index[id] > -1)
	{
		new i = USERKSR(id)
		formatex(tempLable, charsmax(tempLable), "\y[ %s ]%s", KILLSTREAK_LABLE[i], (player_used_bind[id] == 3) ? " [F4]" : "")
		menu_additem(menu, tempLable)
	}
	else
	{
		ADD_LANGUAGE((player_used_bind[id] == 3) ? "MENU_L1B" : "MENU_L1")
		menu_additem(menu, tempLable)
	}
	
	ADD_LANGUAGE("MENU_L2")
	menu_additem(menu, tempLable)
	
	ADD_LANGUAGE((player_used_bind[id] == 3) ? "MENU_L3B" : "MENU_L3")
	menu_additem(menu, tempLable)
	
	ADD_LANGUAGE((!is_user_alive(id) && !score_freeze) ? "MENU_L4B" : "MENU_L4")
	menu_additem(menu, tempLable)
	
	ADD_LANGUAGE("MENU_L5")
	menu_additem(menu, tempLable)
	
	// one time only
	if (!is_user_ks_set[id])
	{
		ADD_LANGUAGE("MENU_L6")
		menu_additem(menu, tempLable)
	}
	
	menu_additem(menu, "Change team")
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	
	return PLUGIN_HANDLED
}
public menu_handler(id, menu, item){
	if(item != MENU_EXIT){
		switch(item){
			case 0: // killstreak rewards
			{
				if (player_killstreak_index[id] < 0)
				{
					menu_destroy(menu)
					cmd_gamemenu(id)
					return PLUGIN_HANDLED
				}
				use_killstreak(id)
			}
			case 1: // create class
			{
				is_creating[id] = CREATE_YES
				cmd_cchoose_menu(id)
			}
			case 2: // choose class
			{
				is_creating[id] = CREATE_NO
				cmd_cchoose_menu(id)
			}
			case 3: // respawn
			{
				if (is_user_alive(id))
				{
					menu_destroy(menu)
					cmd_gamemenu(id)
					return PLUGIN_HANDLED
				}
				else if (!score_freeze)
				{
					remove_task(TASK_RESPAWN+id)
					set_task(0.25, "RespawnMe", TASK_RESPAWN+id)
				}
			}
			case 4: // show help motd
			{
				PlaySound(id, MENU1_SOUND)
				help_motd(id)
			}
			case 5: // killstreak setting
			{
				if (!is_user_ks_set[id])
					cmd_ks_set(id)
				else
					client_cmd(id, "jointeam")
			}
			case 6: // join team
			{
				if (!is_user_ks_set[id]) client_cmd(id, "jointeam")
			}
		}
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
//=============================================================================== CHOOSE CLASS MENU ==========
public cmd_cchoose_menu(id){
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	
	static menu, temp[100], tmpWeapon[20], signCurrent[8], signNext[8]
	
	ADD_LANGUAGE((is_creating[id] == CREATE_YES) ? "MENU2_L0" : "MENU2_L0B")
	menu = menu_create(tempLable, "choose_class_handler")
	
	for (new i = 0; i < CLASSMAX; i++)
	{
		copy(tmpWeapon, charsmax(tmpWeapon), WEAPONNAMES[PLAYER_CLASSES[i]])
		strtoupper(tmpWeapon) // make it uppercase (ex. m4a1 >> M4A1)
		
		signCurrent = (player_class[id] == i && USERPERKS(id, BLUE_PERK) != PERK_ONE_MAN_ARMY) ? "\d" : "\w"
		signNext = (user_next_class[id] == i) ? "\r X" : ""
		
		// format: weapon > perk1 + perk2 + perk3
		formatex(temp, charsmax(temp), "%s%s-\w%s\r%s\y%s\w%s%s", signCurrent, tmpWeapon, 
			PERKS_LABLE[perks[id][i][BLUE_PERK]], 
			PERKS_LABLE[perks[id][i][RED_PERK]], 
			PERKS_LABLE[perks[id][i][GREEN_PERK]], 
			EQUIPMENTS_LABLE[equipment[id][i]], signNext)
		
		menu_additem(menu, temp)
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	
	return PLUGIN_HANDLED
}
public choose_class_handler(id, menu, item){
	if(item != MENU_EXIT)
	{
		if (is_creating[id] == CREATE_YES && item == player_class[id] && is_user_alive(id))
		{
			client_print(id, print_center, "%L", LANG_PLAYER, "CLASS_NOT")
			menu_destroy(menu)
			cmd_cchoose_menu(id)
		}
		else
		{
			for (new i = 0; i < CLASSMAX; i++)
			{
				if (is_user_connected(id) && item == i)
				{
					if (is_creating[id] == CREATE_YES)
					{
						is_creating[id] = i
						menu_destroy(menu)
						cblue_menu(id)
						return PLUGIN_HANDLED
					}
					is_creating[id] = CREATE_NO
					user_next_class[id] = i
					
					// player may change class with One Man Army perk
					if (USERPERKS(id, BLUE_PERK) == PERK_ONE_MAN_ARMY && is_user_alive(id) && !task_exists(TASK_CLASS_CHANGE+id))
					{
						is_changing[id] = true
						Make_BarTime2(id, floatround(CLASS_CHANGE_D+0.5), 0)
						set_task(CLASS_CHANGE_D, "change_player_class", TASK_CLASS_CHANGE + id)
						ham_strip_user_weapon_all(id)
						client_print(id, print_center, "%L", LANG_PLAYER, "CLASS_CHANGING")
						PlaySound(id, OMA_SOUND)
					}
					else
					{
						client_print(id, print_center, "%L", LANG_PLAYER, "CLASS_NEXT")
					}
				}
			}
		}
		PlaySound(id, MENU1_SOUND)
	}
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
//============================================================================== CREATE CLASS MENU ==========
// blue
public cblue_menu(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	static menu
	ADD_LANGUAGE("MENU3_L0")
	menu = menu_create(tempLable, "cblue_handler")
	menu_additem(menu, PERKS_LABLE[PERK_MARATHON])
	menu_additem(menu, PERKS_LABLE[PERK_SLEIGHT_OF_HAND])
	menu_additem(menu, PERKS_LABLE[PERK_SCAVENGER])
	menu_additem(menu, PERKS_LABLE[PERK_ONE_MAN_ARMY])
	//menu_additem(menu, PERKS_LABLE[PERK_BLING])
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public cblue_handler(id, menu, item){
	new clss = is_creating[id]
	if (item != MENU_EXIT && clss > -1){
		switch(item){
			case 0: perks[id][clss][BLUE_PERK] = PERK_MARATHON
			case 1: perks[id][clss][BLUE_PERK] = PERK_SLEIGHT_OF_HAND
			case 2: perks[id][clss][BLUE_PERK] = PERK_SCAVENGER
			case 3: perks[id][clss][BLUE_PERK] = PERK_ONE_MAN_ARMY
			//case 3: perks[id][clss][BLUE_PERK] = PERK_BLING
		}
		menu_destroy(menu)
		cred_menu(id)
		return PLUGIN_HANDLED
	}
	is_creating[id] = CREATE_NO
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

// red
public cred_menu(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	static menu
	ADD_LANGUAGE("MENU4_L0")
	menu = menu_create(tempLable, "cred_handler")
	menu_additem(menu, PERKS_LABLE[PERK_STOPPING_POWER])
	menu_additem(menu, PERKS_LABLE[PERK_LIGHTWEIGHT])
	menu_additem(menu, PERKS_LABLE[PERK_HARDLINE])
	menu_additem(menu, PERKS_LABLE[PERK_COLD_BLOODED])
	menu_additem(menu, PERKS_LABLE[PERK_DANGER_CLOSE])
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public cred_handler(id, menu, item){
	new clss = is_creating[id]
	if (item != MENU_EXIT && clss > -1){
		switch(item){
			case 0: perks[id][clss][RED_PERK] = PERK_STOPPING_POWER
			case 1: perks[id][clss][RED_PERK] = PERK_LIGHTWEIGHT
			case 2: perks[id][clss][RED_PERK] = PERK_HARDLINE
			case 3: perks[id][clss][RED_PERK] = PERK_COLD_BLOODED
			case 4: perks[id][clss][RED_PERK] = PERK_DANGER_CLOSE
		}
		menu_destroy(menu)
		cgreen_menu(id)
		return PLUGIN_HANDLED
	}
	is_creating[id] = CREATE_NO
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
	
// green
public cgreen_menu(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	static menu
	ADD_LANGUAGE("MENU5_L0")
	menu = menu_create(tempLable, "cgreen_handler")
	menu_additem(menu, PERKS_LABLE[PERK_COMMANDO])
	menu_additem(menu, PERKS_LABLE[PERK_STEADY_AIM])
	menu_additem(menu, PERKS_LABLE[PERK_SCRAMBLER])
	menu_additem(menu, PERKS_LABLE[PERK_NINJA])
	menu_additem(menu, PERKS_LABLE[PERK_LAST_STAND])
	//menu_additem(menu, PERKS_LABLE[PERK_SITREP])
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public cgreen_handler(id, menu, item){
	new clss = is_creating[id]
	if (item != MENU_EXIT && clss > -1){
		switch(item){
			case 0: perks[id][clss][GREEN_PERK] = PERK_COMMANDO
			case 1: perks[id][clss][GREEN_PERK] = PERK_STEADY_AIM
			case 2: perks[id][clss][GREEN_PERK] = PERK_SCRAMBLER
			case 3: perks[id][clss][GREEN_PERK] = PERK_NINJA
			case 4: perks[id][clss][GREEN_PERK] = PERK_LAST_STAND
			//case : perks[id][clss][GREEN_PERK] = PERK_SITREP
		}
		menu_destroy(menu)
		equipment_menu(id)
		return PLUGIN_HANDLED
	}
	is_creating[id] = CREATE_NO
	menu_destroy(menu)
	return PLUGIN_HANDLED
}

// equipments
public equipment_menu(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	static menu
	ADD_LANGUAGE("MENU6_L0")
	menu = menu_create(tempLable, "equipment_handler")
	menu_additem(menu, EQUIPMENTS_LABLE[UE_FRAG])
	menu_additem(menu, EQUIPMENTS_LABLE[UE_SEMTEX])
	menu_additem(menu, EQUIPMENTS_LABLE[UE_THROWING_KNIFE])
	menu_additem(menu, EQUIPMENTS_LABLE[UE_TACTICAL_INSERTION])
	menu_additem(menu, EQUIPMENTS_LABLE[UE_CLAYMORE])
	menu_additem(menu, EQUIPMENTS_LABLE[UE_C4])
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public equipment_handler(id, menu, item){
	new clss = is_creating[id]
	if (item != MENU_EXIT && clss > -1)
	{
		// painless!
		equipment[id][clss] = item
		
		// and were done making class!
		client_print(id, print_chat, "%L", LANG_PLAYER, "CLASS_SET")
	}
	is_creating[id] = CREATE_NO
	menu_destroy(menu)
	return PLUGIN_HANDLED
}
//---------------------------------- choose killstreak settings
// choose killstreak setting
public ks_set_menu(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	static menu, sLable[64]
	menu = menu_create("\rChoose 3 Killstreaks then press OK.", "ks_set_handler")
	menu_additem(menu, "OK.")
	for (new i = 0; i < KSR_TOTAL; i++)
	{
		// [ ] 3 Kills : UAV
		formatex(sLable, charsmax(sLable), "%s %i Kills : %s", user_ks_temp[id][i] ? "\y [X]" : "\d [_]", KILLS_REQUIRED[i], KILLSTREAK_LABLE[i])
		
		menu_additem(menu, sLable)
	}
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public ks_set_handler(id, menu, item1)
{
	new item = item1 - 1
	new bool:showagain = false
	
	if (item >= 0 && item < KSR_TOTAL)
	{
		user_ks_temp[id][item] = !user_ks_temp[id][item]
		showagain = true
	}
	
	if (item1 == 0) // pressed OK.
	{
		new ksc = ks_temp_count(id)
		if (ksc > MAX_KS_SET)
		{
			client_print(id, print_center, "%L", LANG_PLAYER, "KSR_LIMIT", MAX_KS_SET)
			showagain = true
		}
		else if (ksc > 0)
		{
			apply_killstreak_sets(id)
			is_user_ks_set[id] = true
			client_print(id, print_center, "Killstreaks OK.")
		}
	}
	
	menu_destroy(menu)
	if (showagain) ks_set_menu(id)
	return PLUGIN_HANDLED
}

// === ask player if he wants to bind gameplaykeys! =========================================================
public bindpermission(id){
	if(!is_user_connected(id)) return PLUGIN_HANDLED
	player_used_bind[id] = 0
	static menu
	ADD_LANGUAGE("MENU7_L0")
	menu = menu_create(tempLable, "bindpermission_handler")
	
	ADD_LANGUAGE("MENU7_YES")
	menu_additem(menu, tempLable)
	
	ADD_LANGUAGE("MENU7_NO")
	menu_additem(menu, tempLable)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
	PlaySound(id, MENU1_SOUND)
	return PLUGIN_HANDLED
}
public bindpermission_handler(id, menu, item){
	if(item != MENU_EXIT){
		if (item == 0)
		{
			player_used_bind[id] = 3
			client_cmd(id, "bind MOUSE3 glfire")
			client_cmd(id, "bind v flashsmoke")
			client_cmd(id, "bind F3 codclass")
			client_cmd(id, "bind F4 codkillstreak")
		}
		else player_used_bind[id] = 2
	}
	menu_destroy(menu)
	if (!is_user_ks_set[id]) cmd_ks_set(id)
	return PLUGIN_HANDLED
}

//============================================================================================================
/*---------------------------------------
| Game loop.                              |
|                                         |
|    show custom user hud                 |
|    do health regeneration               |
|    program bots to use grenade launcher |
|                                         |
  ---------------------------------------*/
public GameLoop(taskid)
{
	static id; id = taskid - TASK_MAINLOOP
	static hp_user
	
	if (score_freeze)
	{
		show_main_score(id)
		return
	}
	
	// if just joined, show menu.
	static iTeam; iTeam = get_user_team(id)
	if(is_user_connected(id) && !is_user_alive(id) && !id_nuker)
	{
		if (VALIDTEAM(iTeam))
		{
			set_hudmessage(255, 25, 25, -1.0, 0.30, 0, 6.0, 1.1, 0.0, 0.0, 1)
			ShowSyncHudMsg(id, g_MsgSyncHUD, "Press [M] for Menu.")
		}
		return
	}
	
	// picking up care package?
	care_package_check(id)
	
	// health regeneration
	hp_user = eng_get_user_health(id)
	if(hp_user < po_start_hp && !low_hp_warning[id] && !task_exists(TASK_PHURT+id))
		set_task (1.5,"lhp_player_hurt", TASK_PHURT+id)
	if(hp_user >= po_start_hp && low_hp_warning[id])
		set_task (0.8,"lhp_player_better", TASK_PBETTER+id)
	if(hp_user < po_start_hp){
		hp_user += floatround(USUR * 10.0)
		if(hp_user > po_start_hp) hp_user = po_start_hp
		eng_set_user_health(id, hp_user)
	}
	user_heal_icon(id, (hp_user < po_start_hp) ? HI_FLASH : HI_HIDE)
	
	// show custom hud
	const SIZE = 1024
	static msg[SIZE + 1], len; len = 0
	
	// my class
	static tmpWeapon[8]
	copy(tmpWeapon, charsmax(tmpWeapon), WEAPONNAMES[PLAYER_CLASSES[player_class[id]]])
	strtoupper(tmpWeapon) // make it uppercase
	
	len += formatex(msg[len], SIZE - len, HUD_FORMAT, LANG_PLAYER, "HUD_CLASS", tmpWeapon, LANG_PLAYER, "HUD_RANK", player_rank[id], USERRANK(id))
	
	// required XP
	static rxp; rxp = LEVEL_REQ_XP(player_rank[id]) - player_points[id]
	if (rxp > 0)
		len += formatex(msg[len], SIZE - len, "%L:[%i]", LANG_PLAYER, "HUD_REQXP", rxp)
	else
		if (player_rank[id] != MAXRANK)
			len += formatex(msg[len], SIZE - len, "%L", LANG_PLAYER, "HUD_PRM")
		else
			len += formatex(msg[len], SIZE - len, "%L", LANG_PLAYER, "HUD_PRS")
	
	len += formatex(msg[len], SIZE - len, "^n") // new line
	
	// show equipments
	static frags; frags = user_has_weapon(id, CSW_HEGRENADE)
	switch(USEREQUIP(id))
	{
		case UE_FRAG: if (frags) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_FRAG])
		case UE_SEMTEX: if (frags) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_SEMTEX])
		case UE_THROWING_KNIFE: if (has_tknife[id]) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_THROWING_KNIFE])
		case UE_TACTICAL_INSERTION: if (has_ti[id]) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_TACTICAL_INSERTION])
		case UE_CLAYMORE: if (has_claymore[id]) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_CLAYMORE])
		case UE_C4: if (has_c4[id]) len += formatex(msg[len], SIZE - len, " %s", EQUIPMENTS_LABLE[UE_C4])
	}
	
	// noobtubes
	if (user_has_weapon(id, CSW_AK47) || user_has_weapon(id, CSW_M4A1))
		len += formatex(msg[len], SIZE - len, (hasgl[id] >= 2) ? " [G] [G]" : (hasgl[id] == 1) ? " [G]" : " ")
	
	// killstreak
	if (player_killstreak_index[id] > -1)
	{
		static i; i = USERKSR(id)
		len += formatex(msg[len], SIZE - len, " > > > [ %s ]", KILLSTREAK_LABLE[i])
	}
	
	len += formatex(msg[len], SIZE - len, "^n") // new line
	
	// show game timer + team score
	static iMinute, iSecond
	iSecond = floatround((g_round_started_time + (TIME_LIMIT * 60.0)) - get_gametime())
	if (iSecond < 0) iSecond = 0
	iMinute = iSecond / 60
	iSecond = iSecond - ((iSecond / 60) * 60)
	len += formatex(msg[len], SIZE - len, "[%i:%i] - [CT: %i | T: %i]", iMinute, iSecond, team_score[TEAM_CT], team_score[TEAM_T])
	
	// bots fire grenade launchers
	static iTarget, iBody; iTarget = 0; iBody = 0
	get_user_aiming(id, iTarget, iBody)
	
	if (is_valid_player(iTarget))
	{
		if (iTeam == get_user_team(iTarget))
		{
			// friendly
			set_hudmessage(25, 255, 25, -1.0, 0.45, 0, 6.0, 1.1, 0.0, 0.0, 1)
			formatex(msg, charsmax(msg), NAME_FORMAT, player_rank[iTarget], USERRANK(iTarget), LANG_PLAYER, "HUD_FRIEND", g_playername[iTarget])
		}
		else
		{
			// store last target
			user_last_target[id] = iTarget
			
			// enemy, bots thing
			if (USERPERKS(iTarget, RED_PERK) != PERK_COLD_BLOODED)
			{
				set_hudmessage(225, 0, 0, -1.0, 0.45, 0, 6.0, 1.1, 0.0, 0.0, 1)
				formatex(msg, charsmax(msg), NAME_FORMAT, player_rank[iTarget], USERRANK(iTarget), LANG_PLAYER, "HUD_ENEMY", g_playername[iTarget])
			} else
				set_hudmessage(55, 255, 25, HUD_POS_X, HUD_POS_Y, 0, 6.0, 1.1, 0.0, 0.0, 1)
			if (is_user_bot(id)) cmd_glfire(id)
		}
	}
	else
	{
		if (user_ctrl_pred[id])
		{
			set_hudmessage(255, 25, 25, -1.0, 0.10, 0, 6.0, 1.1, 0.0, 0.0, 1)
			if (user_pred_speed[id] == PREDATOR_SPEED)
				formatex(msg, charsmax(msg), "%L", LANG_PLAYER, "HUD_PREDATOR")
			else
				formatex(msg, charsmax(msg), "%L", LANG_PLAYER, "HUD_PREDATORB")
		}
		else
		{
			// setting for hp and stuff
			set_hudmessage(55, 255, 25, HUD_POS_X, HUD_POS_Y, 0, 6.0, 1.1, 0.0, 0.0, 1)
		}
	}
	
	// show my hud (but not when: combos are on screen / emp / nuke)
	if (!is_user_EMPd(id) && !id_nuker)
		ShowSyncHudMsg(id, g_MsgSyncHUD, msg)
}

// ========================================================================= HAM/fakemeta Forwards ==========

// glock18 Full-Auto (credits to ConnorMcLeod)
public CGLOCK18_PrimaryAttack_Post(iGlock)
{
	if (!is_valid_ent(iGlock)) return
	if(get_pdata_int(iGlock, m_iShotsFired, EXTRAOFFSET_WEAPONS))
	{
		set_pdata_int(iGlock, m_iShotsFired, 0, EXTRAOFFSET_WEAPONS)
		// set_pdata_float(iGlock, m_flNextPrimaryAttack, get_pdata_float(iGlock, m_flNextPrimaryAttack, EXTRAOFFSET_WEAPONS) + 0.16 - 0.2, EXTRAOFFSET_WEAPONS)
	}
}

// client info change event
public fw_SetClientKeyValue(id, szInfoBuffer[], szKey[], szValue[])
{
	if(g_playermodel[id][0] && equal(szKey, "model") && !equal(szValue, g_playermodel[id]))
	{
		RESET_MODEL(id)
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

// no scout first zoom
public fw_ScoutSecondaryAttack_Post(iEnt)
{
	if (!is_valid_ent(iEnt)) return
	static id; id = GET_owner(iEnt)
	if (!is_valid_player(id)) return
	switch(get_pdata_int(id, OFFSET_ZOOMTYPE, EXTRAOFFSET))
	{
		case CS_FIRST_ZOOM:
		{
			set_pdata_int(id, OFFSET_ZOOMTYPE, CS_SECOND_AWP_ZOOM, EXTRAOFFSET)
		}
		case CS_SECOND_AWP_ZOOM:
		{
			set_pdata_int(id, OFFSET_ZOOMTYPE, CS_NO_ZOOM, EXTRAOFFSET)
		}
	}
}

// m4a1 fast secondary attack (credits to Hunter-Digital)
public fw_M4A1SecondaryAttack(iEnt)
{
	if (!is_valid_ent(iEnt)) return
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.0, EXTRAOFFSET_WEAPONS)
}

// cmd start
public fw_CmdStart(id, handle, seed)
{
	// when pressed F, throw grenage/use equipment
	if (get_uc(handle, UC_Impulse) == IC_FLASHLIGHT)
	{
		cmd_equipment(id)
		set_uc(handle, UC_Impulse, 0)
	}
	
	#if !defined XACCURATE
	if (get_uc(handle, UC_Buttons)&IN_USE)
		cmd_melee(id)
	#endif
	
	return FMRES_IGNORED
}

public fw_SetModel(entity, const model[])
{
	if (strlen(model) < 8) return
	
	if (model[9] == 'h' && model[10] == 'e') // is HE grenade
	{
		// give grenade a white trail
		msg_beam_follow(entity, 255, 255, 255)
		
		// delay grenade explosion (a little)
		SET_dmgtime(entity, GET_dmgtime(entity) + DMGTIME_XTRA)
		
		// semtex sound
		static id; id = GET_owner(entity)
		if (!is_user_connected(id)) return
		if (USEREQUIP(id) == UE_SEMTEX)
		{
			SET_NADE_TYPE(entity, GT_SEMTEX)
			emit_sound(entity, CHAN_ITEM, SEMTEX_SOUND, 0.5, ATTN_NORM, 0, PITCH_NORM)
		}else{
			SET_NADE_TYPE(entity, GT_FRAG)
		}
		return
	}
	
	if (model[9] == 'f' && model[10] == 'l') // is Flash grenade
	{
		SET_NADE_TYPE(entity, GT_FLASH)
	}
	
//	if (model[9] == 's' && model[10] == 'm') // is Smoke grenade
//	{
//		SET_NADE_TYPE(entity, GT_SMOKE)
//	}
	
	#if defined REMOVE_DROPPED
	static classname[10]
	GET_classname(entity, classname)
	if (equal(classname, "weaponbox"))
	{
		// They get automatically removed when thinking
		SET_nextthink(entity, get_gametime() + REMOVE_DROPPED)
		return
	}
	#endif
}

public fw_EmitSound(id, channel, const sample[])
{
	// player death sounds
	// if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	
	// replace "weapons/flashbang-1.wav"
	if (sample[8] == 'f' && sample[9] == 'l' && sample[10] == 'a' && sample[13] == 'b' && sample[14] == 'a')
	{
		emit_sound(id, channel, FLASH_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		return FMRES_SUPERCEDE
	}
	
	// no "player/bhit_kevlar-1.wav" sound
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't' && sample[12] == 'k')
		return FMRES_SUPERCEDE
	
	// knife sounds replace
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i'){
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a'){ 	// slash
			emit_sound(id, channel, KNIFE_SLA_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't'){ 	// hit
			if (sample[17] == 'w'){ 					// wall
				emit_sound(id, channel, KNIFE_WAL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			} else {							// hit
				emit_sound(id, channel, KNIFE_HIT_SOUND[random_num(0,1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a'){ 	// stab
			emit_sound(id, channel, KNIFE_STA_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE
		}
		if (sample[14] == 'd' && sample[15] == 'e' && sample[16] == 'p'){ 	// deploy
			emit_sound(id, channel, KNIFE_DEP_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE
		}
	}
	
	// if knifed, no death sound
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) // die
	{
		static attacker, iWeapID
		attacker = last_attacker[id]
		if (is_user_alive(attacker))
		{
			iWeapID = g_currentweapon[attacker]
			if (iWeapID == CSW_KNIFE)
				return FMRES_SUPERCEDE
		}
	}
	
	return FMRES_IGNORED
}

// catch shot event (credits to VEN)
public fw_PlaybackEvent(flags, invoker, eventid)
{
	if (!(g_guns_eventids_bitsum & (1<<eventid)) || !(1 <= invoker <= g_maxplayers))
		return FMRES_IGNORED
	
	static id; id = invoker
	
	// gun fired (scout/intervention)
	if (eventid == 4 && po_skin)
		emit_sound(id, CHAN_ITEM, INTERVENTION_FIRE, VOL_NORM, ATTN_LOUD, 0, PITCH_RANDOM(2))
	
	// tracer
	new vec1[3], vec2[3]
	get_user_origin(id, vec1, 1)
	get_user_origin(id, vec2, 3)
	
	// tracer effect
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_TRACER)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	message_end()
	
	return FMRES_HANDLED
}
public fw_PrecacheEvent(type, const name[])
{
	for (new i = 0; i < sizeof g_guns_events; ++i)
	{
		if (equal(g_guns_events[i], name))
		{
			g_guns_eventids_bitsum |= (1<<get_orig_retval())
			return FMRES_HANDLED
		}
	}
	
	return FMRES_IGNORED
}

public fw_StartFrame()
{
	static id, Float:gltime; gltime = get_gametime()
	for (id = 1; id < 33; id++) // 33 not g_maxplayers
	{
		// martyrdom explosion time check
		exptime_check(id-1, gltime) // less 'for' loops!
		
		if (!is_user_alive(id))
			continue
		
		// gl ammo check
		if (hasgl[id] > 0) check_glnade(id)
		
		// E to melee
		if (GET_button(id)&IN_USE) set_task(0.01, "cmd_melee", id)
		
		// combo time over! let's calculate all the XPs earned.
		if (gltime > combo_time[id] && combo_time[id] != 0.0){
			combo_time[id] = 0.0
			
			// combo announces
			if (player_combos[id] == 2) add_message_in_queue(id, BM_DOUBLE_KILL)
			if (player_combos[id] == 3) add_message_in_queue(id, BM_TRIPLE_KILL)
			if (player_combos[id] >  3) add_message_in_queue(id, BM_MULTI_KILL)
			
			// points add up
			player_points[id] += temp_xp[id]
			set_task(2.0, "check_player_xp", id)
			temp_xp[id] = 0
			player_combos[id] = 0
		}
		
		// check if player is stuck
		stuck_check(id)
	}
	
	// uav end time check
	uav_endtime_check(TEAM_T)
	uav_endtime_check(TEAM_CT)
	
	// sentry think!
	#if !defined XACCURATE
	sentry_think()
	#endif
	
	// round time
	if (floatround((g_round_started_time + (TIME_LIMIT * 60.0)) - gltime) <= 0)  // round timer = 0
	{
		end_game_check()
	}
}

public fw_GetGameDescription(){
	forward_return(FMV_STRING, PLUGIN)
	return FMRES_SUPERCEDE
}

public fw_Player_PreThink(id)
//public client_PreThink(id)
{
	if (!g_pluginenabled) return	
	
	// predator missile control
	if(is_user_connected(id) && user_ctrl_pred[id] > 0)
	{
		static ent; ent = user_ctrl_pred[id]
		if (is_valid_ent(ent))
		{
			static Float:Velocity[3], Float:Angle[3]
			velocity_by_aim(id, user_pred_speed[id], Velocity)
			GET_v_angle(id, Angle)
			SET_velocity(ent, Velocity)
			SET_angles(ent, Angle)
		}
		else
			attach_view(id, id)
	}
	
	if (!is_user_alive(id))
		return
	
	// end round freeze
	if (score_freeze)
	{
		SET_velocity(id, Float:{0.0,0.0,0.0})
		SET_maxspeed(id, 1.0)
		SET_button(id, 0)
		return
	}
	
	// no fall damage
	if(!imp_falldamage && USERPERKS(id, GREEN_PERK) == PERK_COMMANDO)
		g_isFalling[id] = (GET_flFallVelocity(id) >= 350.0) // FALL_VELOCITY=350.0
	
	// add little more speed (to player)
	static Float:fSpeed; fSpeed = (USERPERKS(id, BLUE_PERK) == PERK_MARATHON) ? 100.0 : 0.0
	fSpeed += (USERPERKS(id, RED_PERK) == PERK_LIGHTWEIGHT) ? LIGHT_SPEED + fSpeed : DEF_SPEED
	SET_maxspeed(id, fSpeed)
	
	// set gravity percentage
	SET_gravity(id, (USERPERKS(id, BLUE_PERK) == PERK_MARATHON) ? 0.6 : 1.0)
	
	// silent steps
	if (USERPERKS(id, GREEN_PERK) == PERK_NINJA)
		SET_flTimeStepSound(id, 999)
	
	// no recoil 2
	if (USERPERKS(id, GREEN_PERK) == PERK_STEADY_AIM)
		SET_punchangle(id, Float:{0.0,0.0,0.0})
}

public fw_Player_PostThink(id)
//public client_PostThink(id)
{
	if (!g_pluginenabled) return
	
	if(!imp_falldamage && is_user_alive(id) && g_isFalling[id])
		SET_watertype(id, CONTENTS_WATER)
}

// handle assisted suicide
public fw_PlayerKilled(victim, attacker, shouldgib)
{
	is_selfkill[victim] = (victim == attacker || !is_user_connected(attacker)) ? true : false
	
	if (!last_attacker[victim])
		return HAM_IGNORED
	
	// the person who caused the enemy selfkill gets an actual kill point!
	
	// assisted suicide?
	if (is_selfkill[victim] && last_attacker[victim] && last_attacker[victim] != victim)
	{
		attacker = last_attacker[victim]
		last_attacker[victim] = 0
		
		log_kill_B(attacker, victim, "_", 0)
		
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	// round end, no more kills
	if (score_freeze) return HAM_SUPERCEDE
	
	damage_count[victim]++
	
	if (victim == attacker || (SAMETEAM(victim, attacker) && victim != attacker) || !is_user_connected(attacker))
		return HAM_IGNORED
	
	last_attacker[victim] = attacker
	damage_prcnt_from[victim][attacker] = floatround(get_damage_percentage(damage) * 100.0)
	
	// has Last Stand ?
	if (USERPERKS(victim, GREEN_PERK) != PERK_LAST_STAND)
		return HAM_IGNORED
	
	// player lays on ground, and get the pistol out
	if(damage >= float(get_user_health(victim)) && !in_last_stand[victim][LS_KILLER])
	{
		// put player in last stand
		static Float:origin[3]
		// drop_to_floor(victim) // not tested yet
		GET_origin(victim, origin)
		origin[2] -= 30.0
		SET_origin(victim, origin)
		
		// user gets full hp
		SET_health(victim, float(po_start_hp))
		
		in_last_stand[victim][LS_WID] = g_currentweapon[attacker]
		in_last_stand[victim][LS_KILLER] = attacker
		
		remove_task(TASK_DEATH+victim)
		set_task(LASTSTAND_DUR, "last_stand_death", TASK_DEATH+victim)
		
		set_task(0.3, "do_last_stand", victim)
		
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
}

public fw_PlayerSpawn_Post(id)
{
	static iTeam; iTeam = get_user_team(id)
	if (!is_user_alive(id) || !iTeam)
		return
	
	if (g_playername[id][0] == '^0')
		get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	// optional MW2 models
	if (po_skin)
	{
		if (!(iTeam == TEAM_T && equal(g_playermodel[id], "spetsna", 7)) || !(iTeam == TEAM_CT && equal(g_playermodel[id], "rangers", 7)))
			formatex(g_playermodel[id], charsmax(g_playermodel[]), (iTeam == TEAM_T) ? "spetsnaz%i" : "rangers%i", random_num(1, 3))
		
		static currentmodel[32]
		get_user_info(id, "model", currentmodel, charsmax(currentmodel))
		if (!equal(currentmodel, g_playermodel[id]))
			RESET_MODEL(id)
	}
	
	// refresh guns/equipments...
	ham_strip_user_weapon_all(id)
	handle_player_class(id)
	
	// a few seconds of godmode
	eng_set_user_godmode(id, 1)
	remove_task(TASK_GODMODE_OFF+id)
	set_task(GODMODE_DELAY, "godmode_off", TASK_GODMODE_OFF+id)
	
	// if died 3 times w/o kills, gets martyrdom
	// hard line perk
	static KR; KR = USERPERKS(id, RED_PERK) == PERK_HARDLINE ? 1 : 0
	if (death_inrow[id] >= MARTYRDOM_DS - KR)
	{
		is_comeback[id] = true
		using_martyrdom[id] = true
		set_task(0.8, "martyrdom_message", id)
	}
	
	// if player has ks, remind him
	static i; i = player_killstreak_index[id]
	if (i > -1){
		i = player_killstreak_queue[id][i]
		PlaySound(id, KSE_SOUNDS[i][KSST_ACHIEVE2])
	}
	
	// this will make sure player sees:
	// gameplay keys, killstreak settings menu
	if (!player_used_bind[id])
		set_task(3.0, "bindpermission", id)
	else if (!is_user_ks_set[id]) set_task(3.0, "cmd_ks_set", id)
	
	// remove any previous equipments
	safe_remove_entity(player_c4[id][0])
	safe_remove_entity(player_c4[id][1])
	safe_remove_entity(player_claymore[id][0])
	safe_remove_entity(player_claymore[id][1])
	player_c4[id][0] = 0
	player_c4[id][1] = 0
	player_claymore[id][0] = 0
	player_claymore[id][1] = 0
}

public fw_Spawn(entity)
{
	if (!is_valid_ent(entity))  // bigfix
		return FMRES_IGNORED
	
	new classname[32]
	GET_classname(entity, classname)
	
	for (new i = 0; i <= charsmax(g_objective_ents); i++){
		if (equal(classname, g_objective_ents[i])){
			remove_entity(entity)
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}

public fw_PrecacheSound(const sound[]){
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE
	return FMRES_IGNORED
}

// public fw_Touch(ptr, ptd)
public pfn_touch(ptr, ptd)
{
	if (!g_pluginenabled) return PLUGIN_CONTINUE
	
	if(!is_valid_ent(ptr))
		return PLUGIN_CONTINUE
	
	static classname[32], victim
	GET_classname(ptr, classname)
	
	victim = is_valid_player(ptd)
	
	if(equal(classname, medkit_classname) && victim && is_user_alive(victim))
	{
		give_medkit(victim)
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, martyrdom_classname))
	{
		if (!GET_STUCK(ptr) && !victim){
			// it finally made the collision sound
			SET_STUCK(ptr, 1)
			emit_sound(ptr, CHAN_ITEM, NADEDROP_SOUND, 0.3, ATTN_NORM, 0, PITCH_NORM)
		}
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, glnade_classname))
	{
		new attacker = GET_owner(ptr)
		if (!is_user_connected(attacker)) return PLUGIN_CONTINUE  // bugfix
		new Float:dist = entity_range(attacker, ptr)
		
		// grenade launcher safty!
		if (dist <= GL_SAFTY_RANGE)
		{
			// noobtube hits player it kills (explodes or not!)
			if (victim && is_user_alive(victim) && !SAMETEAM(attacker, victim))
			{
				log_kill_B(attacker, victim, "grenade", 0)
				BulletX(attacker, 0.60 * HP_LIMIT)
			}
			
			// remove nade
			emit_sound(ptr, CHAN_WEAPON, NADEDROP_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			remove_entity(ptr)
			return PLUGIN_CONTINUE
		}
		
		// damage
		gl_radius_damage(ptr)
		
		// play sound
		emit_sound(ptr, CHAN_WEAPON, EXPLDE_SOUND, VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
		
		// a nice explosion
		show_explosion2(ptr)
		
		breakable_check(ptr, ptd)
		
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, tknife_classname))
	{
		if (victim && is_user_alive(victim))
		{
			new attacker = GET_owner(ptr)
			if (SAMETEAM(attacker,victim) || !is_user_connected(attacker))
				return PLUGIN_CONTINUE
			
			got_bullseye[attacker] = true
			log_kill_B(attacker, victim, "weapon_knife", 0)
			BulletX(attacker, 0.60 * HP_LIMIT)
		}
		emit_sound(ptr, CHAN_ITEM, TKNIFE_SOUND, 0.5, ATTN_STATIC, 0, PITCH_RANDOM(10))
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, "grenade"))
	{
		if (GET_NADE_TYPE(ptr) == GT_SEMTEX)
		{
			SET_movetype(ptr, MOVETYPE_NONE)
			SET_sequence(ptr, 0)
			SET_velocity(ptr, Float:{0.0, 0.0, 0.0})
			
			// if semtex hit player, stick
			if(victim && is_user_alive(victim) && !GET_ATTACHED(ptr))
			{
				new attacker = GET_owner(ptr)
				if (is_user_connected(attacker) && !SAMETEAM(attacker, victim))
				{
					set_task(0.1, "semtex_stick", TASK_SEMTEX_STICK+ptr)
					set_task(0.25, "semtex_stuck_message", attacker)
					set_task(0.2, "semtex_stuck_message_victim", victim)
					SET_ATTACHED(ptr, victim)
				}
			}
		}
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, claymore_classname))
	{
		if (!GET_STUCK(ptr) && !victim)
		{
			new Float:origin[3], Float:origin_t[3]
			
			SET_STUCK(ptr, 1)
			emit_sound(ptr, CHAN_ITEM, CLAYMORE_SOUND, 0.3, ATTN_NORM, 0, PITCH_NORM)
			
			SET_movetype(ptr, MOVETYPE_FLY)
			
			// set trigger zone z
			new trg = GET_ATTACHED(ptr)
			GET_origin(ptr, origin)
			GET_origin(trg, origin_t)
			origin_t[2] = origin[2]
			SET_origin(trg, origin_t)
			SET_solid(trg, SOLID_NOT)
		}
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, claymore_trigger_classname) && !GET_TRIGGERED(ptr))
	{
		// if semtex hit player, stick
		if(victim && is_user_alive(victim))
		{
			SET_TRIGGERED(ptr, 1)
			
			new attacker = GET_owner(ptr)
			
			// avoid bad loop (check only once on touch)
			static i_last_attacker, i_last_victim
			if (!i_last_attacker && !i_last_victim && i_last_attacker == attacker && i_last_victim == victim) return PLUGIN_CONTINUE
			i_last_attacker = attacker; i_last_victim = victim
			
			if (!is_user_connected(attacker)) return PLUGIN_CONTINUE  // bugfix
			if (SAMETEAM(attacker, victim))
				return PLUGIN_CONTINUE
			
			new cm = GET_ATTACHED(ptr)
			
			if (task_exists(TASK_CLAYMORE_EXPLODE + cm))
				return PLUGIN_CONTINUE
			
			new Float:tDelay = 0.25
			if (USERPERKS(victim, GREEN_PERK) == PERK_SCRAMBLER)
				tDelay = 2.5
			
			set_task(tDelay, "claymore_explode", TASK_CLAYMORE_EXPLODE + cm)
			emit_sound(cm, CHAN_ITEM, CLAYMORE_T_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		return PLUGIN_CONTINUE
	}
	
	if(equal(classname, c4_classname))
	{
		if (!GET_STUCK(ptr) && !victim)
		{
			SET_STUCK(ptr, 1)
			emit_sound(ptr, CHAN_ITEM, C4_STUCK_SOUND, 0.3, ATTN_NORM, 0, PITCH_NORM)
			SET_movetype(ptr, MOVETYPE_NONE)
			SET_velocity(ptr, Float:{0.0, 0.0, 0.0})
		}
		return PLUGIN_CONTINUE
	}
	
	// sentry gun bullets
	if (equal(classname, sentryblt_classname))
	{
		new bool:ShowParticles = true
		if (is_valid_ent(ptd))
		{
			new trg[32]
			GET_classname(ptd, trg)
			if (equal(trg, sentrybase_classname) || equal(trg, sentry_classname))
				return PLUGIN_CONTINUE
			
			if (equal(trg, "player"))
			{
				new victim = ptd
				new attacker = GET_owner(ptr)
				if (!is_user_connected(attacker)) return PLUGIN_CONTINUE
				new ent = has_sentry[attacker]
				
				if (!SAMETEAM(attacker, victim))
				{
					if(eng_get_user_health(victim) > floatround(SENTRY_DAMAGE))
						fakedamage(victim, "weapon_m249", SENTRY_DAMAGE, DMG_BULLET)
					else
					{
						if (!GET_COUNTS_KS(ent)) ignore_ks_add[attacker] = true
						log_kill_B(attacker, victim, "_Sentry Gun", 0)
					}
				}
				
				ShowParticles = false
			}
		}
		
		if (ShowParticles)
		{
			new iOrigin[3]
			get_origin_int(ptr, iOrigin)
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iOrigin)
			write_byte(TE_GUNSHOT)
			write_coord(iOrigin[0])
			write_coord(iOrigin[1])
			write_coord(iOrigin[2])
			message_end()
		}
		
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	// predator missile
	if(equal(classname, pred_classname))
	{
		new id = GET_owner(ptr)
		if (!is_user_connected(id)) return PLUGIN_CONTINUE
		
		// damage
		gl_radius_damage(ptr, RDR_PREDATOR)
		
		// play sound
		emit_sound(ptr, CHAN_WEAPON, PR_EXPL_SOUND[random_num(0,2)], VOL_NORM, ATTN_PREDATOR, 0, PITCH_NORM)
		
		// a nice explosion
		show_explosion2(ptr)
		
		breakable_check(ptr, ptd)
		
		// deattach view
		attach_view(id, id)
		user_ctrl_pred[id] = 0
		
		// remove thermal
		Display_Fade(id, 1, 0, FFADE_IN, 150, 150, 150, 100, true)
		
		// mute fly sound and remove
		emit_sound(ptr, CHAN_ITEM, PR_FLY_STOP, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	// care package
	if(equal(classname, package_classname) && is_user_alive(victim))
	{
		// victim = the person whos getting the package!
		cpd_time[victim] = get_gametime()
		cpd_taking_package[victim] = ptr
		return PLUGIN_CONTINUE
	}
	
	// stealth bomber bombs
	if(equal(classname, bomb_classname))
	{
		SET_COUNTS_KS(ptr, GET_COUNTS_KS(GET_ATTACHED(ptr)))
		
		// damage
		gl_radius_damage(ptr, RDR_STEALTH)
		
		// play sound
		emit_sound(ptr, CHAN_WEAPON, PR_EXPL_SOUND[random_num(0,2)], VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
		
		// explosion
		show_explosion2(ptr)
		
		breakable_check(ptr, ptd)
		
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	// precision airstrike bombs
	if(equal(classname, pbomb_classname))
	{
		SET_COUNTS_KS(ptr, GET_COUNTS_KS(GET_ATTACHED(ptr)))
		
		// damage
		gl_radius_damage(ptr, RDR_PRECISION)
		
		// play sound
		emit_sound(ptr, CHAN_WEAPON, EXPLDE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		// explosion
		show_explosion1(ptr)
		
		breakable_check(ptr, ptd)
		
		remove_entity(ptr)
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

// block HE grenade explosion
// use my own explosion
public fw_ThinkGrenade(entity)
{
	if (!is_valid_ent(entity))
		return HAM_IGNORED
	
	static Float:dmgtime
	dmgtime = GET_dmgtime(entity)
	if (dmgtime > get_gametime())
		return HAM_IGNORED
	
	flash_explosion_time = 0.0
	g_flasher = 0
	
	switch(GET_NADE_TYPE(entity))
	{
		case GT_FRAG, GT_SEMTEX:
		{
			blast_da_mofo(entity)
			return HAM_SUPERCEDE
		}
		case GT_FLASH:
		{
			flash_explosion_time = get_gametime()
			g_flasher = GET_owner(entity)
			if (!is_valid_player(g_flasher))
				g_flasher = 0
			
			return HAM_IGNORED
		}
		// case GT_SMOKE:
	}
	return HAM_IGNORED
}

// credits to Numb
public fw_FindEntityInSphere(start, Float:origin[3], Float:radius)
{
	if(radius != 1500.0 || flash_explosion_time != get_gametime())
		return FMRES_IGNORED
	
	static hit, trace, Float:user_origin[3], Float:absmax[3], Float:fraction, g_flasher_team
	g_flasher_team = (g_flasher) ? get_user_team(g_flasher) : -1
	hit = start
	
	// run the same check to see what its result will be
	while( ( hit = find_ent_in_sphere(hit, origin, radius) ) > 0 )
	{
		// hit a non- or dead-player
		if(!is_user_alive(hit))
		{
			forward_return(FMV_CELL, hit)
			return FMRES_SUPERCEDE
		}
		
		// aim for the body eyes
		GET_origin(hit, user_origin)
		GET_absmax(hit, absmax)
		user_origin[2] = absmax[2] - 20.0
		engfunc(EngFunc_TraceLine, origin, user_origin, DONT_IGNORE_MONSTERS, 0, trace)
		
		// hit player eyes, grenade ok
		if(get_tr2(trace, TR_pHit) == hit)
		{
			// start backup check (de_dust2 B bug - outmap bug)
			engfunc(EngFunc_TraceLine, user_origin, origin, DONT_IGNORE_MONSTERS, hit, trace)
			
			// hit player eyes with backup check
			get_tr2(trace, TR_flFraction, fraction)
			if(fraction == 1.0)
			{
				if(g_flasher == hit || g_flasher_team != get_user_team(hit))
				{
					if (g_flasher != hit) set_task(0.1, "flash_hitmark", g_flasher)
					forward_return(FMV_CELL, hit)
					return FMRES_SUPERCEDE
				}
			}
		}
	}
	
	// grenade could not hit anyones eyes, cancel the check
	forward_return(FMV_CELL, -1)
	return FMRES_SUPERCEDE
}
public flash_hitmark(id)
	BulletX(id, 0.60 * HP_LIMIT)

//========================================================================== AMX Forwards ===============

public client_authorized(id)
	get_user_authid(id, g_szAuthID[id], charsmax(g_szAuthID[]))

public client_putinserver(id)
{
	if (!g_pluginenabled) return
	
	get_user_name(id, g_playername[id], charsmax(g_playername[]))
	
	perks_reset(id)
	reset_player_vars(id)
	remove_all_player_tasks(id)
	
	g_assists[id] = 0
	g_kills[id] = 0
	g_deaths[id] = 0
	death_inrow[id] = 0
	player_points[id] = 0
	player_rank[id] = 1
	user_next_class[id] = (is_user_bot(id)) ? random_num(0, CLASSMAX - 1) : 0
	
	// clear killstreak setting
	reset_ks_set(id)
	
	// load profile
	LOAD(id)
	
	set_task(USUR, "GameLoop", TASK_MAINLOOP+id, _, _, "b")
}

public client_disconnect(id)
{
	if (!g_pluginenabled) return
	
	main_reset(id)
}

public main_reset(id)
{
	if (!g_pluginenabled) return
	
	// save profile
	SAVE(id)
	
	// remove player's stuff
	safe_remove_entity(player_c4[id][0])
	safe_remove_entity(player_c4[id][1])
	safe_remove_entity(player_claymore[id][0])
	safe_remove_entity(player_claymore[id][1])
	safe_remove_entity(player_ti[id])
	safe_remove_entity(has_sentry[id])
	
	player_c4[id][0] = 0
	player_c4[id][1] = 0
	player_claymore[id][0] = 0
	player_claymore[id][1] = 0
	player_ti[id] = 0
	has_sentry[id] = 0
	
	g_playermodel[id][0] = '^0'
	
	player_killstreak_index[id] = -1
	for (new i = 0; i < MAXKS; i++)
		player_killstreak_queue[id][i] = 0
	
	reset_player_vars(id)
}

//=========================================================================================== Events =====

public event_CurWeapon(id)
{
	// get the weapon
	static wid
	wid = read_data(2)
	
	g_currentweapon[id] = wid
	
	// no guns when changing class
	// and no secondary weapon when using one man army
	if ( is_changing[id] || (USERPERKS(id, BLUE_PERK) == PERK_ONE_MAN_ARMY && IS_SEC(wid)) )
	{
		engclient_cmd(id, "drop")
		return
	}
	
	// if weapon custom model exists, switch model.
	if (po_skin)
	{
		switch(wid)
		{
			case CSW_AK47: 	SET_viewmodel(id, V_AK47_MODEL)
			case CSW_DEAGLE:SET_viewmodel(id, V_DEAGLE_MODEL)
			case CSW_M3: 	SET_viewmodel(id, V_M3_MODEL)
			case CSW_M4A1: 	SET_viewmodel(id, V_M4A1_MODEL)
			case CSW_M249: 	SET_viewmodel(id, V_M249_MODEL)
			case CSW_SCOUT: SET_viewmodel(id, V_SCOUT_MODEL)
			case CSW_P90: 	SET_viewmodel(id, V_P90_MODEL)
			case CSW_KNIFE: SET_viewmodel(id, V_KNIFE_MODEL)
			case CSW_GLOCK18: SET_viewmodel(id, V_GLOCK18_MODEL)
		}
	}
}

// this is better than ham's
// it doesn't get called for suicides
// and thats what I need
//
public event_DeathMsg()
{
	new killer = read_data(1)
	new victim = read_data(2)
	new headshot = read_data(3)
	
	if (killer == victim || !is_user_connected(killer))
		return PLUGIN_CONTINUE
	
	kills_no_deaths[victim] = 0
	last_kill[killer] = get_gametime()
	g_kills[killer]++
	g_deaths[victim]++
	
	// check extra points
	extra_points_calcs(killer, victim, headshot)
	
	// store payback thing
	to_payback[victim][killer] = true
	
	// combo
	do_combo(killer)
	
	// drop ammo package
	drop_medkit(victim)
	
	// death streak counter
	death_inrow[victim]++
	
	// victim's killstreaks no longer count toward ks
	killstreak_invalidate(victim)
	
	// killstreak counter
	if (!ignore_ks_add[killer] && !is_nuke_time)
	{
		kills_no_deaths[killer]++
		killstreak_rewards_check(killer)
	}
	if(ignore_ks_add[killer]) ignore_ks_add[killer] = false
	
	// drop a live grenade!
	if (using_martyrdom[victim])
		set_task(0.1, "drop_martyrdom", victim)
	
	// if changing class, stop
	if (is_changing[victim])
	{
		remove_task(TASK_CLASS_CHANGE+victim)
		Make_BarTime2(victim, floatround(CLASS_CHANGE_D+0.5), 100)
	}
	
	// reset all player vars/arrays
	reset_player_vars(victim)
	
	// bots randomly pick a class
	if (is_user_bot(victim))
		user_next_class[victim] = random_num(0, CLASSMAX - 1)
	
	user_heal_icon(victim, HI_HIDE)
	
	// respawn task for T/CT teams
	remove_task(TASK_RESPAWN+victim)
	#if defined DO_RESPAWN
	new iTeam = get_user_team(victim)
	if (VALIDTEAM(iTeam))
		set_task((is_user_bot(victim)) ? 3.0 : RESPAWN_DELAY, "RespawnMe", TASK_RESPAWN+victim)
	#endif
	
	// team score
	if (!score_freeze)
	{
		new team = get_user_team(killer)
		if (VALIDTEAM(team) && !id_nuker)
		{
			team_score[team] += 100
			if (team_score[team] >= SCORE_LIMIT)
				end_game_check()
		}
	}
	
	return PLUGIN_CONTINUE
}

public event_HLTV()
{
	g_newround = true
	
	winner = 0
	
	set_cvar_num("sv_maxspeed", 999)
	
	set_task(0.5, "set_map_lighting", 999, "l", 1)
	
	set_task(2.0, "round_start")
	
	team_score[TEAM_T] = 0
	team_score[TEAM_CT] = 0
	
	// reset first blood
	first_killer = 0
	
	// reset player killstreak's stuff
	// first spawn at home
	for (new id = 1; id <= g_maxplayers; id++)
	{
		// kills-assists-deaths
		g_assists[id] = 0
		g_kills[id] = 0
		g_deaths[id] = 0
		fm_eng_set_user_deaths(id, 0)
		
		// martyrdom
		death_inrow[id] = 0
		
		// ask player for game settings
		player_used_bind[id] = 0
		is_user_ks_set[id] = false
		
		// first 2 spawns are at base.
		first_spawn[id] = 2
		
		// predator missile
		user_ctrl_pred[id] = 0
		
		// precision airstrike
		user_precision[id] = 0
		
		// stealth bomber
		user_stealth[id] = 0
		
		// deep clean up
		main_reset(id)
		
		// reset payback thing
		for (new j = 1; j <= g_maxplayers; j++)
			to_payback[id][j] = false
	}
	
	// killstreak settings
	hasUAV[TEAM_T] = false
	hasUAV[TEAM_CT] = false
	uavEndTime[TEAM_T] = 0.0
	uavEndTime[TEAM_CT] = 0.0
	remove_task(TASK_UN_EMP+TEAM_T)
	remove_task(TASK_UN_EMP+TEAM_CT)
	remove_task(TASK_TACTICAL_NUKE)
	id_nuker = 0
	is_nuke_time = false
	
	// clean up map
	remove_entity_name(glnade_classname)
	remove_entity_name(medkit_classname)
	remove_entity_name(martyrdom_classname)
	remove_entity_name(claymore_classname)
	remove_entity_name(claymore_trigger_classname)
	remove_entity_name(c4_classname)
	remove_entity_name(tknife_classname)
	remove_entity_name(ti_classname)
	remove_entity_name(sentrybase_classname)
	remove_entity_name(sentry_classname)
	remove_entity_name(sentryblt_classname)
	remove_entity_name(pred_classname)
	remove_entity_name(stealth_classname)
	remove_entity_name(package_classname)
	remove_entity_name(bomb_classname)
	remove_entity_name(pbomb_classname)
	
	// reset martyrdom settings
	reset_martyrdom()
	
	// clean up sentry guns
	sentry_cleanup()
}

public round_start()
{
	// after freeze time
	if (g_newround)
	{
		// round started
		g_round_started_time = get_gametime()
		g_newround = false
		score_freeze = false
		PlayMP3(0, ROUND_START_SOUND)
		PlaySound(0, TDM_SOUND)
	}
}

public event_Damage(victim)
{
	new iWeapID, iHitzone, attacker = get_user_attacker(victim, iWeapID, iHitzone)
	if(!is_user_alive(victim) || !is_user_alive(attacker))
		return PLUGIN_CONTINUE
	
	static HS, sWeapon[32]
	HS = (iHitzone == HIT_HEAD) ? 1 : 0
	
	// knife or scout upper chest kills instantly
	if (iWeapID == CSW_KNIFE || iWeapID == CSW_SCOUT && (iHitzone == HIT_CHEST || iHitzone == HIT_HEAD))
	{
		formatex(sWeapon, charsmax(sWeapon), "weapon_%s", WEAPONNAMES[iWeapID])
		log_kill_B(attacker, victim, sWeapon, HS)
		BulletX(attacker, 0.85 * HP_LIMIT)
		return PLUGIN_HANDLED
	}
	
	static Float:damage
	read_data(2, damage)
	
	static dmgType; dmgType = (iWeapID == CSW_HEGRENADE) ? DMG_BLAST : DMG_BULLET
	
	// damage muliplier
	if (dmgType == DMG_BULLET && USERPERKS(attacker, RED_PERK) == PERK_STOPPING_POWER)
	{
		damage = (damage * DAMAGE_MULTI) - damage // extra damage calculation
		if(get_user_health(victim) > floatround(damage))
		{
			eng_set_user_health(victim, get_user_health(victim) - floatround(damage))
		}
		else
		{
			log_kill_B(attacker, victim, WEAPONNAMES[iWeapID], HS)
			BulletX(attacker, damage)
			return PLUGIN_HANDLED
		}
	}
	
	// shake screen on explosion damages!
	if (dmgType == DMG_BLAST)
		user_scr_shake(victim, damage)
	
	// the hitmark X
	BulletX(attacker, damage)
	
	// screen goes red
	user_scr_blood(victim, damage)
	
	return PLUGIN_CONTINUE
}

//================================================================== Messages ===============
// block buyzone (credits to Doc-Holiday)
public msgStatusIcon(msgid, msgdest, id)
{
	if (!is_user_alive(id)) return PLUGIN_HANDLED
	static szIcon[8]
	get_msg_arg_string(2, szIcon, 7)
	if(equal(szIcon, "buyzone") && get_msg_arg_int(1))
	{
		set_pdata_int(id, OFFSET_MAPZONE, get_pdata_int(id, OFFSET_MAPZONE, EXTRAOFFSET) & ~(1<<0), EXTRAOFFSET)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

// beep sound on flashed, kill on last stand
public msgScreenFade(msgid, msgdest, victim)
{
	// enemy flash kills (when in last stand)
	if (in_last_stand[victim][LS_KILLER])
	{
		in_last_stand[victim][LS_WID] = CSW_FLASHBANG
		remove_task(TASK_DEATH+victim)
		set_task(0.1, "last_stand_death", TASK_DEATH+victim)
	}
	else
	{
		// when flashed, you hear beep
		if (get_msg_arg_int(6) == 255)
			PlaySound(victim, FLASH_BEEP)
	}
}

public msgHideWeapon()
	set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | HIDE_NORMAL)

// this is optional
#if defined AUTOJOIN
public msgShowMenu(msgid, dest, id){
	if (get_user_team(id)) return PLUGIN_CONTINUE
	static menu_text_code[16]
	get_msg_arg_string(4, menu_text_code, charsmax(menu_text_code))
	if (equal(menu_text_code, "#Team_Select")){
		set_force_team_join_task(id, msgid)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
public msgVGUIMenu(msgid, dest, id){
	// 2 = TEAM_SELECT_VGUI_MENU_ID
	if (get_msg_arg_int(1) == 2 && !get_user_team(id))
	{
		
		set_force_team_join_task(id, msgid)
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
set_force_team_join_task(id, msgid){
	new param[2]
	param[0] = id
	param[1] = msgid
	set_task(0.25, "force_team_join", _, param, sizeof param)
}
public force_team_join(param[])
{
	new id = param[0]
	new menu_msgid = param[1]
	
	if (get_user_team(id)) return
	new msg_block = get_msg_block(menu_msgid)
	set_msg_block(menu_msgid, BLOCK_SET)
	engclient_cmd(id, "jointeam", "5")
	engclient_cmd(id, "joinclass", "5")
	set_msg_block(menu_msgid, msg_block)
	
	// join right away!
	remove_task(TASK_RESPAWN+id)
	set_task(0.25, "RespawnMe", TASK_RESPAWN+id)
}
#endif

//======================================================================= Stuff to reset/initialize ========

public remove_all_player_tasks(id)
{
	remove_task(TASK_MAINLOOP+id)
	remove_task(TASK_GIVESTUFF+id)
	remove_task(TASK_RESPAWN+id)
	remove_task(TASK_GODMODE_OFF+id)
	remove_task(TASK_PHURT+id)
	remove_task(TASK_MELEE+id)
	remove_task(TASK_MELEE_Q+id)
	remove_task(TASK_PBETTER+id)
	remove_task(TASK_DEATH+id)
	remove_task(TASK_CLASS_CHANGE+id)
	remove_task(TASK_TACTICAL_INSERTION+id)
	remove_task(TASK_PRED_FLY+id)
	remove_task(TASK_CAREPACKAGE+id)
}

public reset_player_vars(id)
{
	low_hp_warning[id] = false
	hasgl[id] = 0
	glsets[id][0] = false
	had_knife[id] = false
	combo_time[id] = 0.0
	melee_time[id] = 0.0
	player_combos[id] = 0
	temp_xp[id] = 0
	is_creating[id] = CREATE_NO
	is_changing[id] = false
	in_last_stand[id][LS_WID] = 0
	in_last_stand[id][LS_KILLER] = 0
	using_martyrdom[id] = false
	has_c4[id] = false
	has_claymore[id] = false
	has_ti[id] = false
	has_tknife[id] = false
	got_bullseye[id] = false
	last_attacker[id] = 0
	damage_count[id] = 0
	is_comeback[id] = false
	last_kill[id] = 0.0
	aim_target[id] = 0.0
	
	kills_no_deaths[id] = 0
	ignore_ks_add[id] = false
	
	reset_message_queue(id)
	for (new i = 1; i < 33; i++)
		damage_prcnt_from[id][i] = 0
}

public perks_reset(id)
{
	// set default classes settings, then these can be changed by user!
	for (new clss = 0; clss < CLASSMAX; clss++)
	{
		switch(PLAYER_CLASSES[clss])
		{
			case CSW_M4A1:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_SCAVENGER
				perks[id][clss][RED_PERK] = 	PERK_STOPPING_POWER
				perks[id][clss][GREEN_PERK] = 	PERK_STEADY_AIM
				equipment[id][clss] = 		UE_CLAYMORE
			}
			case CSW_P90:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_SLEIGHT_OF_HAND
				perks[id][clss][RED_PERK] = 	PERK_LIGHTWEIGHT
				perks[id][clss][GREEN_PERK] = 	PERK_COMMANDO
				equipment[id][clss] = 		UE_SEMTEX
			}
			case CSW_AK47:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_ONE_MAN_ARMY
				perks[id][clss][RED_PERK] = 	PERK_DANGER_CLOSE
				perks[id][clss][GREEN_PERK] = 	PERK_COMMANDO
				equipment[id][clss] = 		UE_FRAG
			}
			case CSW_SCOUT:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_SCAVENGER
				perks[id][clss][RED_PERK] = 	PERK_COLD_BLOODED
				perks[id][clss][GREEN_PERK] = 	PERK_NINJA
				equipment[id][clss] = 		UE_TACTICAL_INSERTION
			}
			case CSW_M249:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_SLEIGHT_OF_HAND
				perks[id][clss][RED_PERK] = 	PERK_HARDLINE
				perks[id][clss][GREEN_PERK] = 	PERK_LAST_STAND
				equipment[id][clss] = 		UE_C4
			}
			case CSW_M3:
			{
				perks[id][clss][BLUE_PERK] = 	PERK_MARATHON
				perks[id][clss][RED_PERK] = 	PERK_STOPPING_POWER
				perks[id][clss][GREEN_PERK] = 	PERK_SCRAMBLER
				equipment[id][clss] = 		UE_THROWING_KNIFE
			}
		}
	}
}

//======================================================================== Martyrdom things ==============
public drop_martyrdom(id)
{
	static ix
	ix = new_martyrdom_index()
	if (ix == -1) return
	
	// its been used, now reset it
	using_martyrdom[id] = false
	
	static Float:origin[3]
	GET_origin(id, origin)
	origin[2] += 10.0
	
	new martyrdom = make_entity(id, martyrdom_classname, MARTYRDOM_MDL, origin, SOLID_TRIGGER, MOVETYPE_TOSS, _, 1.0)
	martyrdoms[ix] = martyrdom
	
	// set timer on it
	SET_dmgtime(martyrdom, get_gametime() + MARTYRDOM_D + DMGTIME_XTRA)
	
	// it hasn't collided to anything yet
	SET_STUCK(martyrdom, 0)
}

// martyrdom explosion
public blast_da_mofo(entity)
{
	if (!is_valid_ent(entity)) return
	
	// do damage
	gl_radius_damage(entity)
	
	// explosion sound
	emit_sound(entity, CHAN_WEAPON, EXPLDE2_SOUND[random_num(0,charsmax(EXPLDE2_SOUND))], VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
	
	// the visual effects
	show_explosion1(entity)
	
	// remove the object
	remove_entity(entity)
}

exptime_check(m, Float:gltime)
{
	static iMartyrdom; iMartyrdom = martyrdoms[m]
	if (iMartyrdom != -1)
	{
		if (is_valid_ent(iMartyrdom))
		{
			if (gltime > GET_dmgtime(iMartyrdom))
			{
				martyrdoms[m] = -1
				set_task(0.1, "blast_da_mofo", iMartyrdom)
			}
		}
		else martyrdoms[m] = -1
	}
}

new_martyrdom_index(){
	for (new m = 0; m <= charsmax(martyrdoms); m++)
		if (martyrdoms[m] == -1)
			return m
	return -1
}

reset_martyrdom()
	for (new m = 0; m <= charsmax(martyrdoms); m++)
		martyrdoms[m] = -1

public martyrdom_message(id)
{
	PlaySound(id, BONUS_SOUND)
	AnnounceX_L(id, "INFO_MARTYRDOM")
}

//==================================================================== Grenade launcher things ============
public glthrow(id)
{
	static Float:vSrc[3], Float:Aim[3], Float:origin[3]
	GET_origin(id, vSrc)
	velocity_by_aim(id, 64, Aim)
	GET_origin(id, origin)
	vSrc[0] += Aim[0]; vSrc[1] += Aim[1]; vSrc[2] += 10.0
	new glnade = make_entity(id, glnade_classname, ROCKET_MDL, vSrc, SOLID_BBOX, MOVETYPE_TOSS, _, 0.1)
	static Float:velocity[3], Float:angles[3]
	velocity_by_aim(id, floatround(GL_POWER[1]), velocity)
	SET_velocity(glnade, velocity)
	vector_to_angle(velocity, angles)
	SET_angles(glnade, angles)
	SET_takedamage(glnade, DAMAGE_YES)
	set_rendering(glnade, kRenderFxGlowShell, 255, 0, 0)
	msg_beam_follow(glnade, 224, 224, 255)
	return PLUGIN_CONTINUE
}

//bool:is_gl_ready(id)
//	return glsets[id][0]

public check_glnade(id){
	if (last_glnade[id] > get_gametime()){
		glsets[id][0] = false
		glsets[id][1] = true
	}else{
		if (glsets[id][2]){
			glsets[id][1] = false
			glsets[id][2] = false
		}
		if (!glsets[id][1]){
			emit_sound(id, CHAN_WEAPON, R_REL_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			glsets[id][1] = true
		}
		glsets[id][0] = true
	}
}

// =========================================================================== Orpheu stuff =================
public OnInstallGameRules() g_pGameRules = OrpheuGetReturn();
TerminateRound_TE ( const WinStatus )
{
	switch ( WinStatus )
	{
		case WinStatus_Ct:
		{
			if ( get_mp_pdata( "m_iNumSpawnableTerrorist" ) && get_mp_pdata( "m_iNumSpawnableCT" ) )
			{
				set_mp_pdata( "m_iNumCTWins", get_mp_pdata( "m_iNumCTWins" ) + 1 );
				UpdateTeamScores( .notifyAllPlugins = true );
			}
			RoundTerminating( .winStatus = WinStatus_Ct, .delay = RESTART_DELAY );
		}
		case WinStatus_Terrorist:
		{
			if ( get_mp_pdata( "m_iNumSpawnableTerrorist" ) && get_mp_pdata( "m_iNumSpawnableCT" ) )
			{
				set_mp_pdata( "m_iNumTerroristWins", get_mp_pdata( "m_iNumTerroristWins" ) + 1 );
				UpdateTeamScores( .notifyAllPlugins = true );
			}
			RoundTerminating( .winStatus = WinStatus_Terrorist, .delay = RESTART_DELAY );
		}
		case WinStatus_RoundDraw:
		{
			RoundTerminating( .winStatus = WinStatus_RoundDraw, .delay = RESTART_DELAY );
		}
	}
}
RoundTerminating ( const winStatus, const Float:delay )
{
	set_mp_pdata( "m_iRoundWinStatus"  , winStatus );
	set_mp_pdata( "m_fTeamCount"	   , get_gametime() + delay );
	set_mp_pdata( "m_bRoundTerminating", true );
}
UpdateTeamScores ( const bool:notifyAllPlugins = false )
{
	static OrpheuFunction:handleFuncUpdateTeamScores;
	if ( !handleFuncUpdateTeamScores )
	{
		handleFuncUpdateTeamScores = OrpheuGetFunction( "UpdateTeamScores", "CHalfLifeMultiplay" )
	}
	( notifyAllPlugins ) ?
		OrpheuCallSuper( handleFuncUpdateTeamScores, g_pGameRules ) :
		OrpheuCall( handleFuncUpdateTeamScores, g_pGameRules );
}

// ==================================================================== = = = = = = = = = = criticals 1 = = =

// gives player killstreak 
// rewards (if earned)
killstreak_rewards_check(id, bool:is_carepackage = false)
{
	if (!is_user_connected(id))
		return
	
	// hard line perk
	new KR = USERPERKS(id, RED_PERK) == PERK_HARDLINE ? 1 : 0
	for (new i = 0; i < KSR_TOTAL; i++)
	{
		// note: KILLS_REQUIRED[ /* no enums if it's used in 'if' */ ]
		if (kills_no_deaths[id] == KILLS_REQUIRED[i] - KR)
		{
			// user has the killstreak in settings?
			if (!is_carepackage && !user_killstreak_set[id][i])
				return
			
			// we reached MAXKS? (too many ks?)
			if (player_killstreak_index[id] >= MAXKS - 1)
			{
				client_print(id, print_center, "%L", LANG_PLAYER, "KS_MAX")
				return
			}
			
			// add ks to queue
			player_killstreak_index[id]++
			player_killstreak_queue[id][player_killstreak_index[id]] = i
			
			// counts ks towards killstreak
			if (!is_carepackage)
				killstreak_counts_ks[id][player_killstreak_index[id]] = true
			
			// some fx (so user'll know he recieved something!)
			Display_Fade(id, 1, 0, FFADE_IN, 205, 255, 255, 55)
			
			// bots use it right away!
			if (is_user_bot(id))
			{
				use_killstreak(id) // bots
				return
			}
			
			// tell player: heres your reward
			new sMessage[64]
			if (player_used_bind[id] == 3)
				formatex(sMessage, charsmax(sMessage), "[ %s ]^n^n%L.", KILLSTREAK_LABLE[i], LANG_PLAYER, "INFO_KS_USE")
			else
				formatex(sMessage, charsmax(sMessage), "[ %s ]^n^n%L.", KILLSTREAK_LABLE[i], LANG_PLAYER, "INFO_KS_USEB")
			AnnounceX(id, sMessage, _, 255, 255)
			PlaySound(id, KSE_SOUNDS[i][KSST_ACHIEVE1])
			PlaySound(id, KSE_SOUNDS[i][KSST_ACHIEVE2])
		}
	}
	
	// inform player kills no death
	if (kills_no_deaths[id] > 1 && !is_carepackage)
		client_print(id, print_chat, "[MW2] %i KillStreak", kills_no_deaths[id])
}

// player use reward
use_killstreak(id)
{
	if (!is_user_alive(id))
		return
	
	// is EMPd ?
	if (is_user_EMPd(id))
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "EMP_BLOCKS")
		return
	}
	
	// get next ks from queue
	new i = player_killstreak_index[id]
	if (i <= -1) return
	
	new iTeam = get_user_team(id)
	new ks = player_killstreak_queue[id][i]
	new bool:stealth_used = false
	
	switch(ks)
	{
		case KSR_UAV:
		{
			set_UAV(iTeam)
			PlaySound(0, SWITCH_SOUND)
		}
		case KSR_CARE_PACKAGE:
		{
			CreateCarePackage(id)
		}
		case KSR_SENTRY_GUN:
		{
			new ent = sentry_build(id)
			if (!ent) return
			if (killstreak_counts_ks[id][i]) SET_COUNTS_KS(ent, 1)
		}
		case KSR_PREDATOR_MISSILE:
		{
			new ent = CreatePredator(id)
			if (!ent) return
			if (killstreak_counts_ks[id][i]) SET_COUNTS_KS(ent, 1)
		}
		case KSR_PRECISION_AIRSTRIKE:
		{
			new ent = CreatePrecision(id)
			if (!ent) return
			if (killstreak_counts_ks[id][i]) SET_COUNTS_KS(ent, 1)
		}
		case KSR_STEALTH_BOMBER:
		{
			new ent = CreateStealthBomber(id)
			if (!ent) return
			if (killstreak_counts_ks[id][i]) SET_COUNTS_KS(ent, 1)
			stealth_used = true
		}
		case KSR_EMP:
		{
			launch_EMP(id)
		}
		case KSR_TACTICAL_NUKE:
		{
			launch_nuke(id)
		}
	}
	
	// tell teams, player gets XP!
	team_inform(iTeam, ks, stealth_used)
	ShowPointAdd(id, KS_USE_POINT[ks])
	
	// done, go stay on next one
	player_killstreak_index[id]--
}

// play sound on team
team_inform(team, ksid, bool:teammatesOnly = false)
{
	new num, players[32], id, iteam
	get_players(players, num, "a")
	for(new a = 0; a < num; a++)
	{
		id = players[a]
		iteam = get_user_team(id)
		if (iteam != TEAM_T && iteam != TEAM_CT)
			continue
		
		if (iteam == team)
			PlaySound(id, KSE_SOUNDS[ksid][KSST_FRIENDLY])
		else
			if (!teammatesOnly)
				PlaySound(id, KSE_SOUNDS[ksid][KSST_ENEMY])
	}
}

// turn off ks counter on a killstreak
killstreak_invalidate(id)
{
	// sentry
	NO_COUNT(has_sentry[id])
	
	// predator missile
	NO_COUNT(user_ctrl_pred[id])
	
	// precision airstrike
	NO_COUNT(user_precision[id])
	
	// stealth bomber
	NO_COUNT(user_stealth[id])
	
	// in queue killstreaks
	for (new i = 0; i < MAXKS; i++)
		killstreak_counts_ks[id][i] = false
}

// KSR stops adding killstreaks
NO_COUNT(ent) if (ent && is_valid_ent(ent)) SET_COUNTS_KS(ent, 0)

// care package. (may be used for admins)
give_ks(id, ksid)
{
	// it can be a resupply!
	if (ksid == CP_RESUPPLY)
	{
		remove_task(TASK_GIVESTUFF+id)
		set_task(0.1, "give_stuff", TASK_GIVESTUFF+id)
		return
	}
	new tmp = kills_no_deaths[id]
	kills_no_deaths[id] = KILLS_REQUIRED[ksid]
	killstreak_rewards_check(id, true)
	kills_no_deaths[id] = tmp
}

// handle player rankings
public check_player_xp(id)
{
	// is level up?
	if (player_points[id] > LEVEL_REQ_XP(player_rank[id]))
	{
		// last rank? (Commander)
		if (player_rank[id] >= MAXRANK)
			return
		
		player_rank[id]++
		
		new sMessage[64]
		formatex(sMessage, charsmax(sMessage), "*** %L ***^n>>> %s <<<", LANG_PLAYER, "INFO_PROMOTED", USERRANK(id))
		AnnounceX(id, sMessage, _, 255, 255)
		PlayMP3(id, LEVELUP_MP3)
	}
}

// =================== killstreak setting ===
// killstreak setting command
public cmd_ks_set(id)
{
	if (is_user_ks_set[id])
		return
	
	reset_ks_temp(id)
	ks_set_menu(id)
}
ks_temp_count(id)
{
	static k, c; c = 0
	for (k = 0; k < KSR_TOTAL; k++)
		if (user_ks_temp[id][k]) c++
	return c
}
apply_killstreak_sets(id)
	for (new k = 0; k < KSR_TOTAL; k++)
		user_killstreak_set[id][k] = user_ks_temp[id][k]

reset_ks_set(id)
{
	for (new k = 0; k < KSR_TOTAL; k++)
		user_killstreak_set[id][k] = false
	is_user_ks_set[id] = false
}
reset_ks_temp(id)
	for (new k = 0; k < KSR_TOTAL; k++)
		user_ks_temp[id][k] = user_killstreak_set[id][k]

//=============================================

// log kill with death message
log_kill_B(killer, victim, const weapon[], headshot, bool:ignore_ibk = false)
{
	if (score_freeze) return
	
	new weapname[64]
	if(containi(weapon, "nade") != -1){
		copy(weapname, 63, "grenade")
	}else{
		copy(weapname, 63, weapon)
		replace(weapname, 63, "weapon_", "")
	}
	
	// this had to fit in here!
	if (!ignore_ibk)
		is_bullet_kill[killer] = (!equal(weapname, "grenade") && !equal(weapname, "knife") && weapname[0] != '_')
	
	set_msg_block(g_msgDeathMsg, BLOCK_SET)
	ExecuteHamB(Ham_Killed, victim, killer, 0)
	set_msg_block(g_msgDeathMsg, BLOCK_NOT)
	make_deathmsg(killer, victim, headshot, weapname)
}

// main explosion creator (default damage type = grenades)
gl_radius_damage(entity, Float:fRDR = 1.0)
{
	if (!is_valid_ent(entity)) // bugfix (thanks to mattisbogus)
		return
	
	if (score_freeze) return
	
	// statics a little faster
	static id, damaged, hp, dist, Float:damage, range, Float:maxDamage, Float:blastOrigin[3]
	id = GET_owner(entity)
	damaged = 0; hp = 0; dist = 0; damage = 0.0; range = 0; maxDamage = 0.0
	GET_origin(entity, blastOrigin)
	
	// damage/range multiplication
	static Float:multiDamageRange; multiDamageRange = fRDR
	
	// if using Danger Close perk, increase damage and range
	if (USERPERKS(id, RED_PERK) == PERK_DANGER_CLOSE)
		multiDamageRange *= DAMAGE_MULTI
	
	static iKills, Float:fShake, i; iKills = 0; fShake = 0.0; i = 0
	
	for(i = 1; i <= g_maxplayers; i++)
	{
		if (!is_user_connected(i))
			continue
		
		if(SAMETEAM(id, i) && id != i) // damage if enemy or self
			continue
		
		range = floatround(GL_POWER[3] * multiDamageRange)
		damage = GL_POWER[2] * multiDamageRange
		
		// explosion hit enemy's c4/claymore/ti?
		victim_equipment_break(entity, range, i, damage)
		
		if (!is_user_alive(i) || eng_get_user_godmode(i))
			continue
		
		dist = floatround(entity_range(entity,i))
		
		// explosions cause screen shake
		if(dist < GL_POWER[3] * 3.0)
		{
			fShake = 100.0 - ((dist / (GL_POWER[3] * 2.5)) * 100.0)
			user_scr_shake(i, fShake)
		}
		
		if(dist > range) continue
		
		hp = eng_get_user_health(i)
		damage = damage - (damage / range) * float(dist)
		
		if (maxDamage < damage) maxDamage = damage
		
		if (id != i) damaged = 1
		if(hp > damage)
		{
			blast_damage(i, damage, blastOrigin)
		}
		else
		{
			eng_do_knock(entity, i, damage)
			if (multiDamageRange > DAMAGE_MULTI && !GET_COUNTS_KS(entity)) ignore_ks_add[id] = true
			log_kill_B(id, i, "grenade", 0)
			iKills++
		}
	}
	
	// hitmark clacs!
	if (iKills > 1) maxDamage = HP_LIMIT
	if (damaged) BulletX(id, maxDamage)
}

// blasts break enemy's stuff if in range!
public victim_equipment_break(ent, range, victim, Float:damage)
{
	if (!is_valid_ent(ent) || !is_user_connected(victim)) return
	static j, tmp, dist
	
	for (j = 0; j < 2; j++)
	{
		// Claymores
		tmp = player_claymore[victim][j]
		if (is_valid_ent(tmp))
		{
			if (floatround(entity_range(ent, tmp)) < range)
			{
				remove_task(TASK_CLAYMORE_EXPLODE+tmp)
				set_task(0.2, "claymore_explode", TASK_CLAYMORE_EXPLODE+tmp)
			}
		}
		
		// C4s
		tmp = player_c4[victim][j]
		if (is_valid_ent(tmp))
		{
			if (floatround(entity_range(ent, tmp)) < range)
			{
				player_c4[victim][j] = 0
				set_task(0.2, "c4_explode", tmp)
			}
		}
	}
	
	// TIs
	tmp = player_ti[victim]
	if (is_valid_ent(tmp))
	{
		if (floatround(entity_range(ent, tmp)) < range)
		{
			remove_entity(tmp)
			set_task(0.2, "ti_destroy", victim)
		}
	}
	
	// sentry gun!
	tmp = has_sentry[victim]
	if (is_valid_ent(tmp))
	{
		dist = floatround(entity_range(ent, tmp))
		if (dist < range)
			SET_health(tmp, GET_health(tmp) - (damage - (damage / float(range)) * float(dist)))
	}
}

do_combo(id)
{
	// nuke isn't multikill in mw2
	if (id != id_nuker) player_combos[id]++
	death_inrow[id] = 0
	ShowPointAdd(id, 100)
}

ShowPointAdd(id, iPoint)
{
	if (iPoint <= 0 || score_freeze) return
	combo_time[id] = get_gametime() + 1.6
	temp_xp[id] += iPoint
	// set_hudmessage(250, 250, 20, -1.0, 0.3, 1, 0.05,/*delay=*/ 2.0, 0.05, 0.1, 3)
	// ShowSyncHudMsg(id, g_MsgSyncHUD, "+%i", temp_xp[id])
	client_print(id, print_center, "+%i", temp_xp[id])
}

// game message announcer
AnnounceX(id, const msg[], announcer = 0, r = 0, g = 255, b = 0, bool:teammatesOnly = false)
{
	// message to one
	if (id){
		set_hudmessage(r, g, b, -1.0, 0.20, 1, 0.0, 3.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(id, g_MsgSyncAX, msg)
	}
	
	// message to all
	if (id == 0 && announcer && is_user_connected(announcer))
	{
		// the easiest part!
		PlaySound(0, ANNOUNCE_SOUND)
		
		// show message green to friendly, red to enemy
		new players[32], pnum, id, bool:sameTeam
		get_players(players, pnum)
		new iTeam = get_user_team(announcer)
		for (new i = 0; i < pnum; i++)
		{
			id = players[i]
			sameTeam = (iTeam == get_user_team(id))
			if (sameTeam)
				set_hudmessage(0, 255, 0, -1.0, 0.20, 1, 0.0, 3.0, 1.0, 1.0, -1)
			else
				set_hudmessage(255, 0, 0, -1.0, 0.20, 1, 0.0, 3.0, 1.0, 1.0, -1)
			
			if (sameTeam || (!sameTeam && !teammatesOnly))
				ShowSyncHudMsg(id, g_MsgSyncAX, "=========>>>   %s   <<<=========^n|||[ %s ]|||", msg, g_playername[announcer])
		}
	}
}

// add language
AnnounceX_L(id, const msg[], announcer = 0, r = 0, g = 255, b = 0, bool:teammatesOnly = false)
{
	static sText[128]
	formatex(sText, charsmax(sText), "%L", LANG_PLAYER, msg)
	AnnounceX(id, sText, announcer, r, g, b, teammatesOnly)
}

// kill bonuses
extra_points_calcs(killer, victim, isheadshot)
{
	// rescuer
	if (is_rescue_kill(killer, victim))
		add_message_in_queue(killer, BM_RESCUER)
	
	// avenger
	new Float:fTemp = get_gametime() - last_kill[victim]
	if (fTemp < 1.0 && fTemp > 0.0)
		add_message_in_queue(killer, BM_AVENGER)
	
	// bullets kills only
	if (is_bullet_kill[killer])
	{
		// One Shot Kill (1 bullet only)
		if (damage_count[victim] <= 1)
			add_message_in_queue(killer, BM_ONE_SHOT_KILL)
		
		// Headshot!
		if (isheadshot){
			add_message_in_queue(killer, BM_HEADSHOT)
			set_task(0.15, "play_headshot_sound", killer)
		}
		
		// Longshot!
		if (floatround(entity_range(killer, victim)) > 1300)
			add_message_in_queue(killer, BM_LONGSHOT)
	}
	
	// Bullseye!
	if (got_bullseye[killer]){
		got_bullseye[killer] = false
		add_message_in_queue(killer, BM_BULLS_EYE)
	}
	
	// afterlife!
	if (is_user_connected(killer) && !is_user_alive(killer))
		add_message_in_queue(killer, BM_AFTER_LIFE)
	
	// Payback!
	if (to_payback[killer][victim])
	{
		to_payback[killer][victim] = false 	// hes paid!
		add_message_in_queue(killer, BM_PAYBACK)
		show_payback(victim)
	}
	
	// First Blood!
	if (!first_killer && !is_selfkill[victim])
	{
		first_killer = killer
		add_message_in_queue(killer, BM_FIRST_BLOOD)
	}
	
	// Assisted Suicide! or kill assist point!
	if (last_attacker[victim])
	{
		if (!killer)
			add_message_in_queue(last_attacker[victim], BM_ASSISTED_SUICIDE)
		else
		{
			for (new i = 1; i < 33; i++)
			{
				if (!is_user_connected(i)) continue
				static dmg; dmg = damage_prcnt_from[victim][i]
				if (killer != i && dmg > 0)
				{
					g_assists[i]++
					ShowPointAdd(i, dmg)
				}
			}
		}
	}
	
	// Execution!
	if (in_last_stand[victim][LS_KILLER] == killer)
		add_message_in_queue(killer, BM_EXECUTION)
	
	// comeback
	if (is_comeback[killer])
	{
		is_comeback[killer] = false
		add_message_in_queue(killer, BM_COMEBACK)
	}
	
	// Buzzkill!
	// it's not like original
	if (kills_no_deaths[victim] > 3)
		add_message_in_queue(killer, BM_BUZZKILL)
}

// help message
public Task_Announce()
{
	static iPlayers[32], iNum
	get_players(iPlayers, iNum, "ac")
	for(new i=0; i < iNum;i++)
		client_print(iPlayers[i], print_chat, "%L", LANG_PLAYER, "HELP_MESSAGE")
	
	remove_task(TASK_ANNOUNCE)
	set_task(60.0, "Task_Announce", TASK_ANNOUNCE)
}

// a little delay is good
public play_headshot_sound(id)
	if (!is_nuke_time) PlaySound(id, HEADSHOT_SOUND)

// this has to be called every 1.5 sec.
public show_player_next_message(taskid)
{
	new id = taskid - TASK_MESSAGE_BONUS
	new index = player_message_index[id]
	
	new msgid = player_message_queue[id][index]
	if (msgid == -1)
		return
	
	// bonus message +sound
	PlaySound(id, BONUS_SOUND)
	AnnounceX(id, MESSAGE_LABLE[msgid])
	
	// its been read
	player_message_queue[id][index] = -1
	
	player_message_index[id]++
	if (player_message_index[id] > charsmax(player_message_queue[]))
		player_message_index[id] = 0
	
	// call this again, there maybe more messages to show
	set_task(1.5, "show_player_next_message", taskid)
}

// player's bonus messages
// also handles adding points (XP)
add_message_in_queue(id, msgid)
{
	if (id == id_nuker) return
	
	// XP
	new points = MESSAGE_POINTS[msgid]
	ShowPointAdd(id, points)
	
	new iPos = player_message_index[id]
	for (new i = 0; i <= charsmax(player_message_queue[]); i++)
	{
		if (player_message_queue[id][iPos] == -1)
			break
		iPos++
		if (iPos > charsmax(player_message_queue[])) iPos = 0
	}
	player_message_queue[id][iPos] = msgid
	if (!task_exists(TASK_MESSAGE_BONUS+id))
		set_task(0.1, "show_player_next_message", TASK_MESSAGE_BONUS+id)
	
	// msg to all also?
	if (msgid == BM_FIRST_BLOOD || msgid == BM_TRIPLE_KILL || msgid == BM_MULTI_KILL)
		AnnounceX(0, MESSAGE_LABLE[msgid], id)
}

reset_message_queue(id){
	for (new i = 0; i <= charsmax(player_message_queue[]); i++)
		player_message_queue[id][i] = -1
	player_message_index[id] = 0
}

// load cod_mw2.ini (credits to MeRcyLeZZ)
load_cod_mw2_ini()
{
	new path[64]
	get_configsdir(path, charsmax(path))
	format(path, charsmax(path), "%s/cod_mw2.ini", path)
	if (!file_exists(path)){
		new error[100]
		formatex(error, charsmax(error), "Cannot load customization file %s!", path)
		set_fail_state(error)
		return
	}
	new linedata[1024], key[64], value[960]
	new file = fopen(path, "rt")
	while (file && !feof(file))
	{
		fgets(file, linedata, charsmax(linedata))				// read a line
		replace(linedata, charsmax(linedata), "^n", "")				// remove new-lines
		if (!linedata[0] || linedata[0] == ';') continue			// ignore empty or ;
		strtok(linedata, key, charsmax(key), value, charsmax(value), '=')	// get key / value
		trim(key); trim(value)							// trim spaces
		if      (equal(key, "ENABLE")) 		po_enable     	= str_to_num(value)
		else if (equal(key, "MW2 SKIN")) 	po_skin 	= str_to_num(value)
		else if (equal(key, "DIFFICULTY")) 	po_difficulty 	= str_to_float(value)
		else if (equal(key, "START HP")) 	po_start_hp 	= str_to_num(value)
		else if (equal(key, "MEDKIT HP")) 	po_medkit_hp 	= str_to_num(value)
		else if (equal(key, "RANDOM SPAWN")) 	po_random_spawn = str_to_num(value)
		else if (equal(key, "DESERT FX")) 	po_desert_fx 	= str_to_num(value)
		else if (equal(key, "SQLX HOST")) 	copy(sqlx_host,  charsmax(sqlx_host),  value)
		else if (equal(key, "SQLX USER")) 	copy(sqlx_user,  charsmax(sqlx_user),  value)
		else if (equal(key, "SQLX PASS")) 	copy(sqlx_pass,  charsmax(sqlx_pass),  value)
		else if (equal(key, "SQLX DB")) 	copy(sqlx_db,    charsmax(sqlx_db),    value)
	}
	if (file) fclose(file)
	
	// cell min/max limits
	po_start_hp = clamp(po_start_hp, 1, floatround(HP_LIMIT))
	po_medkit_hp = clamp(po_medkit_hp, 0, 50)
	new xcxcxc[64]
	format(xcxcxc, 63, "------po: %i  ----  des: %f", po_desert_fx, float(po_desert_fx) / 10000.0)
	server_print(xcxcxc)
}

// round end stuff
end_game_check()
{
	if (score_freeze || id_nuker) return
	
	score_freeze = true
	if (team_score[TEAM_T] > team_score[TEAM_CT]) 	// T win
	{
		// TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist)
		TerminateRound_TE(WinStatus_Terrorist)
		round_end_sound(TEAM_T)
		winner = TEAM_T
	}
	else if (team_score[TEAM_T] < team_score[TEAM_CT]) 	// CT win
	{
		// TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct)
		TerminateRound_TE(WinStatus_Ct)
		round_end_sound(TEAM_CT)
		winner = TEAM_CT
	}
	else if (team_score[TEAM_T] == team_score[TEAM_CT]) 	// Draw
	{
		// TerminateRound(RoundEndType_Draw)
		TerminateRound_TE(WinStatus_RoundDraw)
		round_end_sound()
		winner = -1
	}
	round_end_stuff()
}

round_end_sound(team = 0)
{
	new players[32], pnum, id, param[2]
	get_players(players, pnum)
	
	for (new i = 0; i < pnum; i++)
	{
		id = players[i]
		if (!team)
		{
			PlayMP3(id, ROUND_NUKE_SOUND)
		}
		else if (team == get_user_team(id))
		{
			PlayMP3(id, ROUND_WIN_SOUND)
			param[0] = id; param[1] = random_num(0,1)
			set_task(1.5, "taskSound", _, param, 2)
		}
		else
		{
			PlayMP3(id, ROUND_LOSE_SOUND)
			param[0] = id; param[1] = random_num(2,3)
			set_task(1.5, "taskSound", _, param, 2)
		}
	}
}
public taskSound(param[])
{
	new id = param[0]
	new SNDid = param[1]
	if (is_user_connected(id))
		PlaySound(id, MEND_SOUND[SNDid])
}

round_end_stuff()
{
	set_task(0.25, "set_map_lighting", 999, "z", 1)
	set_task(0.25, "set_map_lighting", 999, "q", 1)
	set_task(0.75, "set_map_lighting", 999, "g", 1)
	
//	message_begin(MSG_ALL, SVC_FINALE)
//	write_string("")
//	message_end()
	
	message_begin(MSG_ALL, g_msgHideWeapon)
	write_byte((1<<0)|(1<<1)|(1<<3)|(1<<4)|(1<<5)|(1<<6)) // CAL, FLASH, RHA, TIMER, MONEY, CROSS
	message_end()
	
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if(!is_user_alive(id))
			continue
		
		// stop fire
		client_cmd(id, "-attack; -attack2")
		
		// disallow fire till next round
		// set_pdata_float(id, m_flNextAttack, 20.0, EXTRAOFFSET)
		
		// godmode
		eng_set_user_godmode(id, 1)
	}
}

public set_map_lighting(lt[])
{
	set_lights(lt)
}

// ============================= end round score board
show_main_score(id)
{
	// not connected / not CT-T / no winner
	if (!is_user_connected(id))
		return
	
	static iTeam; iTeam = get_user_team(id)
	if (!VALIDTEAM(iTeam))
		return
	
	if (!VALIDTEAM(winner))
		return
	
	const SIZE = 1024
	static msg[SIZE + 1], len; len = 0
	
	// victory or defeat
	if (iTeam == winner)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.20, 1, 0.0, 3.0, 1.0, 1.0, -1)
		copy(msg, charsmax(msg), "Victory!")
	}
	else
	{
		set_hudmessage(255, 0, 0, -1.0, 0.20, 1, 0.0, 3.0, 1.0, 1.0, -1)
		copy(msg, charsmax(msg), "Defeat!")
	}
	ShowSyncHudMsg(id, g_MsgSyncAX, msg)
	
	// get players list and sort by most kills
	new players[32], pnum, player, sortT[16], sortCT[16], counterT, counterCT
	get_players(players, pnum)
	for (new i = 0; i < pnum; i++)
	{
		player = players[i]
		switch(get_user_team(player))
		{
			case TEAM_T:
			{
				sortT[counterT] = player
				counterT++
			}
			case TEAM_CT:
			{
				sortCT[counterCT] = player
				counterCT++
			}
		}
	}
	
	// sort players by kills
	bubble_sort_by_kills(sortT, counterT)
	bubble_sort_by_kills(sortCT, counterCT)
	
	len += formatex(msg[len], SIZE - len, " .: NAME :. ... KILLS | ASSISTS | DEATHS^n")
	
	// T's
	len += formatex(msg[len], SIZE - len, "_____________Spetsnaz_____________^n")
	for (new t = 0; t < counterT; t++)
	{
		player = sortT[t]
		len += formatex(msg[len], SIZE - len, "[ %s ... %i ... %i ... %i ]^n", 
			g_playername[player], g_kills[player], g_assists[player], g_deaths[player])
	}
	
	// CT's
	len += formatex(msg[len], SIZE - len, "^n_____________Rangers______________^n")
	for (new ct = 0; ct < counterCT; ct++)
	{
		player = sortCT[ct]
		len += formatex(msg[len], SIZE - len, "[ %s ... %i ... %i ... %i ]^n", 
			g_playername[player], g_kills[player], g_assists[player], g_deaths[player])
	}
	
	set_hudmessage(25, 125, 225, 0.3, 0.3, 0, 6.0, 1.1, 0.0, 0.0, 1)
	ShowSyncHudMsg(id, g_MsgSyncHUD, msg)
}

bubble_sort_by_kills(list[16], count)
{
	if (count < 2) return
	static temp, a, b
	for (a = 0; a < count; a++)
	{
		for (b = a + 1; b < count; b++)
		{
			if (g_kills[list[a]] < g_kills[list[b]])
			{
				temp = list[a]
				list[a] = list[b]
				list[b] = temp
			}
		}
	}
}

check_equipments(id)
{
	if (!is_user_connected(id))
		return
	
	static ent, i
	for (i = 0; i < 2; i++)
	{
		ent = player_c4[id][i]
		if (is_valid_ent(ent) && GET_health(ent) <= 0.0)
		{
			player_c4[id][i] = 0
			set_task(0.2, "c4_explode", ent)
		}
		
		ent = player_claymore[id][i]
		if (is_valid_ent(ent) && GET_health(ent) <= 0.0 && !task_exists(TASK_CLAYMORE_EXPLODE+ent))
		{
			set_task(0.2, "claymore_explode", TASK_CLAYMORE_EXPLODE+ent)
		}
	}
	
	ent = player_ti[id]
	if (is_valid_ent(ent) && GET_health(ent) <= 0.0)
	{
		remove_entity(ent)
		set_task(0.2, "ti_destroy", id)
	}
}

// ============================================

// ==================================================================== = = = = = = = = = = criticals 2 = = =

//=== load / save ===
// save player data
public SAVE(id)
{
	if (player_rank[id] == 1 && player_points[id] == 0)
		return
	
	#if defined _sqlx_included
	
	SaveData(id)
	
	#endif
	
	#if defined _nvault_included
	
	new szKey[40], szData[32]
	formatex(szKey, charsmax(szKey), "%sMW2", g_szAuthID[id])
	formatex(szData, charsmax(szData), "%d %d %d", player_rank[id], player_points[id], player_class[id])
	nvault_set(g_vault, szKey, szData)
	
	#endif
}

// retrieve player data
public LOAD(id)
{
	#if defined _sqlx_included
	
	LoadData(id)
	
	#endif
	
	#if defined _nvault_included
	
	new szKey[40], szData[32]
	formatex(szKey, charsmax(szKey), "%sMW2", g_szAuthID[id])
	if (nvault_get(g_vault, szKey, szData, charsmax(szData)))
	{
		new params[3][32]
		parse(szData, params[0], 31, params[1], 31, params[2], 31)
		player_rank[id] = str_to_num(params[0])
		if (!player_rank[id]) player_rank[id] = 1
		player_points[id] = str_to_num(params[1])
		player_class[id] = str_to_num(params[2])
		user_next_class[id] = player_class[id]
	}
	// else no player data found
	
	#endif
}
#if defined _sqlx_included
public MySql_Init()
{
	g_SqlTuple = SQL_MakeDbTuple(sqlx_host,sqlx_user,sqlx_pass,sqlx_db)
	
	new ErrorCode,Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,charsmax(g_Error))
	if(SqlConnection == Empty_Handle)
	{
		set_fail_state(g_Error)
	}
	new Handle:Queries
	Queries = SQL_PrepareQuery(SqlConnection,"CREATE TABLE IF NOT EXISTS mw2 (steamid varchar(32), rank TEXT(11), points INT(11), class INT(11))")
	
	if(!SQL_Execute(Queries))
	{
		SQL_QueryError(Queries,g_Error,charsmax(g_Error))
		set_fail_state(g_Error)
	}
	
	SQL_FreeHandle(Queries)
	SQL_FreeHandle(SqlConnection)
}

public LoadData(id)
{
	new ErrorCode,Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,charsmax(g_Error))
	
	if(g_SqlTuple == Empty_Handle)
		set_fail_state(g_Error)
	
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))
	
	new Data[1]
	Data[0] = id

	format(szTemp,charsmax(szTemp),"SELECT * FROM `mw2` WHERE (`mw2`.`steamid` = '%s')", szSteamId)
	SQL_ThreadQuery(g_SqlTuple,"register_client",szTemp,Data,1)
	SQL_FreeHandle(SqlConnection)
}

public register_client(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	if(FailState == TQUERY_CONNECT_FAILED)
	{
		log_amx("Load - Could not connect to SQL database.  [%d] %s", Errcode, Error)
	}
	else if(FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("Load Query failed. [%d] %s", Errcode, Error)
	}
	new id = Data[0]
	
	if(SQL_NumResults(Query) < 1)
	{
		
		new szSteamId[32]
		get_user_authid(id, szSteamId, charsmax(szSteamId))
		
		if (equal(szSteamId,"ID_PENDING"))
			return PLUGIN_HANDLED
		
		new szTemp[512]
		
		new ErrorCode,Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,charsmax(g_Error))
		if(g_SqlTuple == Empty_Handle)
			set_fail_state(g_Error)

		format(szTemp,charsmax(szTemp),"INSERT INTO `mw2`(`steamid`, `rank`, `points`, `class`) VALUES ('%s', '0', '0', '0')", szSteamId)
		SQL_ThreadQuery(g_SqlTuple,"IgnoreHandle",szTemp)
		server_print("seach information ")
		SQL_FreeHandle(SqlConnection)
	} 
	else 
	{

		player_rank[id] = SQL_ReadResult(Query, 1)
		player_points[id] = SQL_ReadResult(Query, 2)
		player_class[id] = SQL_ReadResult(Query, 3)
		user_next_class[id] = player_class[id]
		server_print("read the result ")
	}
	return PLUGIN_CONTINUE
}  

public IgnoreHandle(FailState,Handle:Query,Error[],Errcode,Data[],DataSize)
{
	SQL_FreeHandle(Query)
	return PLUGIN_HANDLED
}

public SaveData(id)
{
	new ErrorCode,Handle:SqlConnection = SQL_Connect(g_SqlTuple,ErrorCode,g_Error,511)
	if(g_SqlTuple == Empty_Handle)
		set_fail_state(g_Error)
	
	new szSteamId[32], szTemp[512]
	get_user_authid(id, szSteamId, charsmax(szSteamId))
	
	format(szTemp,charsmax(szTemp),"UPDATE `mw2` SET `rank` = '%d' , `points` = '%d' , `class` = '%d' WHERE `mw2`.`steamid` = '%s';", player_rank[id],  player_points[id], player_class[id], szSteamId)
	SQL_ThreadQuery(g_SqlTuple,"IgnoreHandle",szTemp)
	SQL_FreeHandle(SqlConnection)
}
#endif


// this checks if wether or not
// the kill was a rescue
bool:is_rescue_kill(rescuer, enemy)
{
	new num, players[32], teammate
	get_players(players, num, "a")
	for(new i = 0; i < num; i++)
	{
		teammate = players[i]
		
		// ignore self and enemy's teammate
		if (teammate == rescuer || !SAMETEAM(rescuer, teammate))
			continue
		
		// was enemy attacking my teamate?
		if (last_attacker[teammate] == enemy)
			return true
	}
	return false
}

// last stand's death time!
// the time has come, time to die!
public last_stand_death(taskid)
{
	static id, attacker
	id = taskid - TASK_DEATH
	attacker = in_last_stand[id][LS_KILLER]
	if(!in_last_stand[id][LS_KILLER] || !is_user_alive(id))
		return
	
	// put back on ground
	new Float:origin[3]
	GET_origin(id, origin)
	origin[2] += 30.0
	SET_origin(id, origin)
	
	new iWeapon = in_last_stand[id][LS_WID]
	
	// reset here first, for the execution XP
	in_last_stand[id][LS_WID] = 0
	in_last_stand[id][LS_KILLER] = 0
	
	log_kill_B(attacker, id, WEAPONNAMES[iWeapon], 0, true)
}

// last stand
public do_last_stand(id)
{
	ham_strip_user_weapon_all(id)
	give_CSW(id, CSW_DEAGLE)
	BP_refill(id, CSW_DEAGLE, 2)
	ham_give_weapon(id, "weapon_hegrenade")
	PlaySound(id, BONUS_SOUND)
	AnnounceX_L(id, "INFO_LASTSTAND")
}

public give_medkit(id)
{
	// give health?
	if (po_medkit_hp)
		eng_set_user_health(id, clamp(eng_get_user_health(id) + po_medkit_hp, 1, floatround(HP_LIMIT)))
	
	BP_refill(id, CSW_DEAGLE)
	
	if(USERPERKS(id, BLUE_PERK) == PERK_SCAVENGER)
	{
		PlaySound(id, MEDKIT_SOUND)
		BP_refill(id)
		if (hasgl[id] < GL_MAX) hasgl[id]++
		ham_give_weapon(id, "weapon_flashbang")
		ham_give_weapon(id, "weapon_flashbang")
		//ham_give_weapon(id, "weapon_smokegrenade")
		
		give_equipment(id)
	}
}

public drop_medkit(id)
{
	new Float:origin[3]
	GET_origin(id, origin)
	origin[2] += 10.0
	new medkit = make_entity(0, medkit_classname, MEDKIT_MDL, origin, SOLID_TRIGGER, MOVETYPE_TOSS)
	set_rendering(medkit, kRenderFxGlowShell, 50, 0, 200)
}

// this is called right after spawning
public give_stuff(taskid)
{
	new id = taskid - TASK_GIVESTUFF
	if(!is_user_alive(id)) return
	
	eng_set_user_health(id, po_start_hp)
	ham_give_weapon(id, "weapon_knife")
	//ham_give_weapon(id, "weapon_smokegrenade")
	ham_give_weapon(id, "weapon_flashbang")
	ham_give_weapon(id, "weapon_flashbang")
	eng_give_item(id, "item_kevlar")
	eng_give_item(id, "item_assaultsuit")
	
	new clss = player_class[id]
	new iWid = PLAYER_CLASSES[clss]
	
	give_CSW(id, iWid)
	
	if (iWid == CSW_AK47 || iWid == CSW_M4A1)
		hasgl[id] = GL_MAX
	
	// give DEagle (oma has no secondary)
	if (USERPERKS(id, BLUE_PERK) != PERK_ONE_MAN_ARMY)
	{
		give_CSW(id, CSW_DEAGLE)
		give_CSW(id, CSW_GLOCK18)
	}
	
	give_equipment(id)
	
	// if scavrnger on, 3 more ammo clips! otherwise only 2
	new ammoCount = (USERPERKS(id, BLUE_PERK) == PERK_SCAVENGER) ? 5 : 2
	BP_refill(id, _, ammoCount)
	
	// extra grenade on scavenger
	set_pdata_int(id, OFFSET_HE_AMMO, abs(ammoCount - 3), EXTRAOFFSET)
}

public give_equipment(id)
{
	// give equipments
	switch(USEREQUIP(id))
	{
		case UE_FRAG, UE_SEMTEX: ham_give_weapon(id, "weapon_hegrenade")
		case UE_THROWING_KNIFE: has_tknife[id] = true
		case UE_TACTICAL_INSERTION: has_ti[id] = true
		case UE_CLAYMORE: has_claymore[id] = true
		case UE_C4: has_c4[id] = true
	}
}

// this returns something between 0.0 to 1.0
Float:get_damage_percentage(Float:fdamage)
{
	static Float:start_hp; start_hp = float(po_start_hp)
	return floatclamp(fdamage, 0.0, start_hp) / start_hp
}

// respawn
public RespawnMe(taskid)
{
	if (score_freeze) return
	
	new id = taskid - TASK_RESPAWN
	if (!is_user_connected(id) || is_user_alive(id))
		return
	
	// no respawns when nuked
	if (is_nuke_time) return
	
	new iget_user_team = get_user_team(id)
	if (iget_user_team != TEAM_T && iget_user_team != TEAM_CT)
		return
	
	ExecuteHam(Ham_CS_RoundRespawn, id)
}

public godmode_off(taskid){
	new id = taskid - TASK_GODMODE_OFF
	if (!is_user_alive(id)) return
	eng_set_user_godmode(id, 0)
}

public wind_sound_loop()
	PlaySound(0, WIND_SOUND)

public lhp_player_hurt(taskid){
	new id = taskid - TASK_PHURT
	if (!is_user_alive(id)) return
	new ihp = eng_get_user_health(id)
	
	for (new i = 0; i < 33; i++)
		damage_prcnt_from[id][i] = floatround(float(damage_prcnt_from[id][i]) * float(ihp) / float(po_start_hp))
	
	if(!low_hp_warning[id]){
		PlaySound(id, SND_WARN[random_num(0,2)])
		if (ihp > po_start_hp * 0.8) low_hp_warning[id] = true
	}
}

public lhp_player_better(taskid){
	new id = taskid - TASK_PBETTER
	if (!is_user_alive(id)) return
	if(low_hp_warning[id]){
		PlaySound(id, SND_BETTER)
		low_hp_warning[id] = false
		SET_armorvalue(id, 100.0)
		
		// user heath is back to normal
		last_attacker[id] = 0
		damage_count[id] = 0
		for (new i = 1; i < 33; i++)
			damage_prcnt_from[id][i] = 0
	}
}

// for one man army
public change_player_class(taskid)
{
	new id = taskid - TASK_CLASS_CHANGE
	if (!is_user_alive(id))
		return
	
	is_changing[id] = false
	
	handle_player_class(id)
	
	client_print(id, print_center, "%L", LANG_PLAYER, "CLASS_CHANGED")
}

// give class things
handle_player_class(id)
{
	// change class is done here
	player_class[id] = user_next_class[id]
	
	// give guns/ammo and stuff
	remove_task(TASK_GIVESTUFF+id)
	set_task(0.5, "give_stuff", TASK_GIVESTUFF+id)
	
	// cold blooded?
	set_rendering(id, _, 0, 0, 0)
	if (USERPERKS(id, RED_PERK) == PERK_COLD_BLOODED)
		set_rendering(id, _, _, _, _, kRenderTransTexture, 80)
}

// break, if breakable
breakable_check(iEnt, ent){
	if(is_valid_ent(ent)){
		static classname2[32]
		GET_classname(ent, classname2)
		if(equal(classname2, "func_breakable"))
			force_use(iEnt, ent)
	}
}

// help motd
help_motd(id){
	new codmotd[2048], title[64], dpos = 0
	formatex(title, charsmax(title), "[MW2] %s", PLUGIN)
	dpos += format(codmotd[dpos],2047-dpos,"<html><head><style type=^"text/css^">pre{color:#00FF00;}body{background:#000000;margin-left:16px;margin-top:1px;}</style></head><pre><body>")
	dpos += format(codmotd[dpos],2047-dpos,"<b>%s</b>^n^n",title)
	dpos += format(codmotd[dpos],2047-dpos,"%L:^n", LANG_PLAYER, "MOTD_L1")
	dpos += format(codmotd[dpos],2047-dpos,"============^n^n")
	dpos += format(codmotd[dpos],2047-dpos,"  <b>M</b> = %L^n", LANG_PLAYER, "MOTD_L2")
	if (player_used_bind[id] == 3)
	{
		dpos += format(codmotd[dpos],2047-dpos,"  <b>F3</b> = %L^n", LANG_PLAYER, "MOTD_L3")
		dpos += format(codmotd[dpos],2047-dpos,"  <b>F4</b> = %L^n", LANG_PLAYER, "MOTD_L4")
	}
	dpos += format(codmotd[dpos],2047-dpos,"  <b>E</b> = %L^n", LANG_PLAYER, "MOTD_L5")
	dpos += format(codmotd[dpos],2047-dpos,"  <b>F</b> = %L^n", LANG_PLAYER, "MOTD_L6")
	dpos += format(codmotd[dpos],2047-dpos,"  <b>C</b> = %L^n", LANG_PLAYER, "MOTD_L7")
	if (player_used_bind[id] == 3)
	{
		dpos += format(codmotd[dpos],2047-dpos,"  <b>V</b> = %L^n", LANG_PLAYER, "MOTD_L8")
		dpos += format(codmotd[dpos],2047-dpos,"  <b>X / Mouse3</b> = %L (M4A1/AK47)^n", LANG_PLAYER, "MOTD_L9")
	}
	dpos += format(codmotd[dpos],2047-dpos,"^n%L^n", LANG_PLAYER, "MOTD_L10")
	show_motd(id, codmotd, title)
}

// ============================================================== = = = = = = = = = = stocks = = = = = = =

// my version of stuck check ( but still credits to 'NL)Ramon(NL' )
stock stuck_check(id)
{
	if (!is_user_alive(id)) return
	
	if (in_last_stand[id][LS_KILLER]) return
	
	static Float:stuck[33], Float:curTime; curTime = get_gametime()
	static Float:origin[3], Float:mins[3], hull, Float:vec[3], v
	static const Float:size[][3] = {
		{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
		{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
		{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
		{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
		{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
	}
	
	GET_origin(id, origin)
	hull = GET_flags(id) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
	if (!is_hull_vacant_2(origin, hull, id))
	{
		if (stuck[id] > curTime) return
		stuck[id] = curTime + 0.5
		GET_mins(id, mins)
		vec[2] = origin[2]
		for (v = 0; v < sizeof size; ++v)
		{
			vec[0] = origin[0] - mins[0] * size[v][0]
			vec[1] = origin[1] - mins[1] * size[v][1]
			vec[2] = origin[2] - mins[2] * size[v][2]
			if (is_hull_vacant_2(vec, hull, id))
			{
				SET_origin(id, vec)
				SET_velocity(id, Float:{0.0,0.0,0.0})
				v = sizeof size
			}
		}
	}
	else stuck[id] = 0.0
}
stock bool:is_hull_vacant_2(const Float:origin[3], hull,id){
	static tr; engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	return (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid))
}

// gives a player a weapon efficiently (XxAvalanchexX's version)
stock ham_give_weapon(id, const weapon[])
{
	if (!is_user_alive(id))
		return 0
	
	if (!equal(weapon, "weapon_", 7))
		return 0
	
	new wEnt = create_entity(weapon)
	if (!is_valid_ent(wEnt))
		return 0
	
	SET_spawnflags(wEnt, SF_NORESPAWN)
	DispatchSpawn(wEnt)
	
	if (!ExecuteHamB(Ham_AddPlayerItem, id, wEnt))
	{
		if (is_valid_ent(wEnt))
			SET_flags(wEnt, GET_flags(wEnt) | FL_KILLME)
		
		return 0
	}
	
	ExecuteHamB(Ham_Item_AttachToPlayer, wEnt, id)
	return 1
}

// strip user weapon (ConnorMcLeod's version)
stock ham_strip_user_weapon(id, iCswId, iSlot = 0, bool:bSwitchIfActive = true)
{
	if (!is_user_alive(id)) return 0
	static iWeapon
	if( !iSlot ) iSlot = WEAPONSLOT[iCswId]
	iWeapon = get_pdata_cbase(id, m_rgpPlayerItems_Slot0 + iSlot, EXTRAOFFSET)
	while( iWeapon > 0 )
	{
		if( get_pdata_int(iWeapon, m_iId, EXTRAOFFSET_WEAPONS) == iCswId )
		{
			break
		}
		iWeapon = get_pdata_cbase(iWeapon, m_pNext, EXTRAOFFSET_WEAPONS)
	}
	if( iWeapon > 0 )
	{
		if( bSwitchIfActive && get_pdata_cbase(id, m_pActiveItem, EXTRAOFFSET) == iWeapon )
		{
			ExecuteHamB(Ham_Weapon_RetireWeapon, iWeapon)
		}
		
		if( ExecuteHamB(Ham_RemovePlayerItem, id, iWeapon) )
		{
			user_has_weapon(id, iCswId, 0)
			ExecuteHamB(Ham_Item_Kill, iWeapon)
			return 1
		}
	}
	return 0
}

// this is now mine :|
stock ham_strip_user_weapon_all(id)
{
	static weapons[32], num, i, toRemove; num = 0
	get_user_weapons(id, weapons, num)
	for (i = 0; i < num; i++){
		toRemove = weapons[i]
		ham_strip_user_weapon(id, toRemove)
	}
}

stock blast_damage(victim, Float:damage, Float:origin[3])
{
	set_msg_block(g_msgDamage, BLOCK_ONCE)
	fakedamage(victim, "grenade", damage, DMG_BLAST)
	message_begin(MSG_ONE, g_msgDamage, _,victim)
	write_byte(floatround(damage)+1)
	write_byte(floatround(damage))
	write_long(DMG_BLAST)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	message_end()
}

// knock (credits to KleeneX)
stock eng_do_knock(attacker, victim, Float:fPower1)
{
	new Float:damage = get_damage_percentage(fPower1) * 100
	new Float:fPower2 = ( damage > 100.0 ? 100.0 : damage ) * 225.0
	new Float:vec[3], Float:vicorigin[3], Float:attorigin[3]
	new Float:oldvelo[3], Float:origin2[3], Float:largestnum = 0.0
	GET_velocity(victim, oldvelo)
	GET_origin(victim, vicorigin)
	GET_origin(attacker, attorigin)
	origin2[0] = vicorigin[0] - attorigin[0]
	origin2[1] = vicorigin[1] - attorigin[1]
	if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0])
	if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1])
	origin2[0] /= largestnum
	origin2[1] /= largestnum
	vec[0] = ( origin2[0] * fPower2 ) / floatround(entity_range(victim , attacker))
	vec[1] = ( origin2[1] * fPower2 ) / floatround(entity_range(victim , attacker))
	if(vec[0] <= 20.0 || vec[1] <= 20.0)
		vec[2] = random_float(200.0 , 275.0)
	vec[0] += oldvelo[0]
	vec[1] += oldvelo[1]
	SET_velocity(victim, vec)
}

stock user_scr_shake(id, Float:damage)
{
	new Float:pct, shakeFreq, Float:velocity[3]
	pct = get_damage_percentage(damage)
	shakeFreq = floatround( pct * 10 * UNIT_SECOND )
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, id)
	write_short(UNIT_SECOND * 8) 	// Amplitude
	write_short(UNIT_SECOND) 	// Duration
	write_short(shakeFreq) 		// Frequency
	message_end()
	
	// decrease player speed by given damage amount
	GET_velocity(id, velocity)
	velocity[0] *= (1.0 - pct)
	velocity[1] *= (1.0 - pct)
	SET_velocity(id, velocity)
}

stock user_scr_blood(id, Float:damage)
{
	if (damage < 1.0) return
	new Float:prc = get_damage_percentage(damage)
	new damage_red = floatround(prc * 255)
	new hold_time = 1 + floatround(prc * 2.0)
	Display_Fade(id, 1, hold_time, FFADE_IN, damage_red, 0, 0, 155)
}

stock Display_Fade(id, duration, holdtime, fadetype, red, green, blue, alpha, bool:reliable = false)
{
	message_begin((id) ? (reliable) ? MSG_ONE : MSG_ONE_UNRELIABLE : MSG_BROADCAST, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND * duration)
	write_short(UNIT_SECOND * holdtime)
	write_short(fadetype)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(alpha)
	message_end()
}

// explosion effect
stock show_explosion(origin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_explosion)
	write_byte(30) // scale in 0.1's
	write_byte(15) // framerate
	write_byte(TE_EXPLFLAG_NOSOUND) // TE_EXPLFLAG_NONE with sound
	message_end()
}

stock show_explosion1(ent)
{
	static iOrigin[3]
	get_origin_int(ent, iOrigin)
	show_explosion(iOrigin)
}

stock show_explosion2(ent)
{
	new iOrigin[3]
	get_origin_int(ent, iOrigin)
	show_explosion(iOrigin)
	message_begin(MSG_ALL,SVC_TEMPENTITY,iOrigin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2]+200)
	write_short(spr_white)
	write_byte(0)
	write_byte(1)
	write_byte(6)
	write_byte(8)
	write_byte(1)
	write_byte(255)
	write_byte(255)
	write_byte(192)
	write_byte(128)
	write_byte(5)
	message_end()
}

stock show_payback(id)
{
	new iOrigin[3]
	get_origin_int(id, iOrigin)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_short(spr_money)
	write_short(spr_money)
	write_byte(243)
	write_byte(20)
	message_end()
}

stock make_entity(iOwner, const szClassname[], const szModel[], Float:origin[3], iSolid, iMovetype, iHealth = 0, Float:fSize = 4.0){
	static iEnt, Float:vSize1[3], Float:vSize2[3]
	vSize1[0] = -fSize; vSize1[1] = -fSize; vSize1[2] = -fSize
	vSize2[0] = fSize;  vSize2[1] = fSize;  vSize2[2] = fSize
	
	if (iHealth){
		iEnt = create_entity("func_breakable")   // func_wall   func_breakable
		DispatchKeyValue(iEnt, "material", material_Computer)
		SET_health(iEnt, float(iHealth))
		SET_takedamage(iEnt, DAMAGE_YES)
	}else{
		iEnt = create_entity("info_target")
	}
	
	if (!iEnt) return 0
	if (!iHealth) DispatchSpawn(iEnt)
	SET_classname(iEnt, szClassname)
	entity_set_model(iEnt, szModel)
	entity_set_size(iEnt, vSize1, vSize2)
	SET_origin(iEnt, origin)
	SET_solid(iEnt, iSolid)
	SET_movetype(iEnt, iMovetype)
	SET_owner(iEnt, iOwner)
	return iEnt
}

stock PlaySound(id, const soundFile[])
	client_cmd(id, "spk ^"%s^"", soundFile)

stock PlayMP3(id, const mp3File[])
	client_cmd(id, "mp3 play ^"sound/%s^"", mp3File)

stock user_heal_icon(id, mode)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgStatusIcon, _, id)
	write_byte(mode)
	write_string("item_healthkit")
	write_byte(10)
	write_byte(10)
	write_byte(10)
	message_end()
}

stock get_origin_int(iEnt, origin[3])
{
	if (!is_valid_ent(iEnt)) return
	static Float:fOrigin[3]
	GET_origin(iEnt, fOrigin)
	FVecIVec(fOrigin, origin)
}

// show a hitmark
stock BulletX(id, Float:fDamage)
{
	static hitmark
	hitmark = clamp(floatround((fDamage / HP_LIMIT) * 4.1) - 1, 0, 3)
	
	// dont show X when showing points / nuke
	if (!id_nuker)
	{
		set_hudmessage(50, 100, 100, -1.0, 0.49, 2, 0.1,/*delay=*/ 0.20, 0.02, 0.02, 2)
		ShowSyncHudMsg(id, g_MsgSyncHUD, "X")
	}
	
	PlaySound(id, BULLETX_SOUND[hitmark])
}

stock give_CSW(id, iCSW)
{
	if (!id || !iCSW) return
	
	new tmp[32]
	formatex(tmp, 31, "weapon_%s", WEAPONNAMES[iCSW])
	ham_give_weapon(id, tmp)
	eng_give_item(id, tmp)
}

stock get_CSW_id(ent){
	static wname[32] //, tmp[32]
	for (new i = g_maxplayers + 1; i < g_maxentities; ++i)
	{
		if (is_valid_ent(i) && ent == GET_owner(i))
		{
			GET_classname(i, wname)
			for (new j = 0; j <= charsmax(WEAPONNAMES); j++)
			{
				// formatex(tmp, charsmax(tmp), "weapon_%s", WEAPONNAMES[j])
				if (contain(wname, WEAPONNAMES[j])) return j
			}
		}
	}
	return 0
}

// convert "weapon_*" to weapon id
// returns weapon id or 0 when fail.
stock weapon_str_to_id(const wname[])
{
	for (new i = 0; i <= charsmax(WEAPONNAMES); i++)
		if (equal(wname, WEAPONNAMES[i]))
			return i
	return 0
}

// hide weapon
stock set_hud_flags(id, iFlags)
{
	message_begin(MSG_ONE, g_msgHideWeapon, _, id)
	write_byte(iFlags)
	message_end()
}

// smoke effect
stock show_smoke(origin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin)
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(spr_smoke)
	write_byte(15) // scale in 0.1's
	write_byte(15) // framerate
	write_byte(TE_EXPLFLAG_NOSOUND)
	message_end()
}

// beam follow
stock msg_beam_follow(ent, r, g, b, iBullet = 0)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(spr_trail)
	write_byte(iBullet ? 3 : 5)
	write_byte(iBullet ? 2 : 3)
	write_byte(r)
	write_byte(g)
	write_byte(b)
	write_byte(iBullet ? 100 : 150)
	message_end()
}

// critical
stock is_valid_player(id){
	if (id > 0 && id <= g_maxplayers && is_valid_ent(id))
		return id
	return 0
}

// check/remove
stock safe_remove_entity(iEnt)
	if (is_valid_ent(iEnt))
		remove_entity(iEnt)

// one BP Ammo (credits to MeRcyLeZZ)
stock BP_refill(id, wid = 0, count = 1)
{
	static weapons[32], num, i, weaponid, j; num = 0
	if (wid)
	{
		if (user_has_weapon(id, wid))
			for (j = 0; j < count; j++)
				ExecuteHamB(Ham_GiveAmmo, id, AMMOPACK[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
	}
	else
	{
		get_user_weapons(id, weapons, num)
		for (i = 0; i < num; i++)
		{
			weaponid = weapons[i]
			if (MAXBPAMMO[weaponid] <= 2) // Primary and secondary only
				continue
			
			
			for (j = 0; j < count; j++)
				ExecuteHamB(Ham_GiveAmmo, id, AMMOPACK[weaponid], AMMOTYPE[weaponid], MAXBPAMMO[weaponid])
		}
	}
}

stock fm_eng_set_user_deaths(id, newdeaths)
{
	if (!is_user_connected(id)) return
	SET_frags(id, newdeaths)
	set_pdata_int(id, OFFSET_CSDEATHS, newdeaths, EXTRAOFFSET)
	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(GET_frags(id))
	write_short(g_deaths[id])
	write_short(0)
	write_short(get_user_team(id))
	message_end()
}

//********************************************************************************************************
// =============================== fakemeta_util stocks converted to engine ==============================
//********************************************************************************************************

stock eng_set_user_godmode(index, godmode = 0) {
	SET_takedamage(index, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM);

	return 1;
}
stock eng_get_user_godmode(index) {
	return (GET_takedamage(index) == DAMAGE_NO);
}
stock eng_set_user_health(index, health) {
	health > 0 ? SET_health(index, float(health)) : user_kill(index);

	return 1;
}
stock eng_give_item(index, const item[]){
	if (!is_user_alive(index)) return 0

	if (!equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = create_entity(item);
	if (!is_valid_ent(ent))
		return 0;

	new Float:origin[3];
	GET_origin(index, origin);
	SET_origin(ent, origin);
	SET_spawnflags(ent, GET_spawnflags(ent) | SF_NORESPAWN);
	DispatchSpawn(ent);

	new save = GET_solid(ent);
	fake_touch(ent, index);
	if (GET_solid(ent) != save)
		return ent;

	remove_entity(ent);

	return -1;
}

// =========================================================================================== Fast reload
// increase reload speed when using Sleight Of Hand perk.
public Weapon_Reload(iEnt)
{
	if (!is_valid_ent(iEnt)) return HAM_IGNORED
	new id = get_pdata_cbase(iEnt, m_pPlayer, EXTRAOFFSET_WEAPONS)
	if (!is_user_alive(id))
		return HAM_IGNORED
	
	if(get_pdata_int(iEnt, m_fInReload, EXTRAOFFSET_WEAPONS))
	{
		if (USERPERKS(id, BLUE_PERK) != PERK_SLEIGHT_OF_HAND)
			return HAM_IGNORED
		
		new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, EXTRAOFFSET) * 0.2
		set_pdata_float(id, m_flNextAttack, flNextAttack, EXTRAOFFSET)
		new iSeconds = floatround(flNextAttack, floatround_ceil)
		Make_BarTime2(id, iSeconds, 100 - floatround( (flNextAttack/iSeconds) * 100 ))
		
	//	if (GET_button(id) & IN_RELOAD)
	//	{
	//		// inform reload sound
	//	}
	}
	return HAM_IGNORED
}

Make_BarTime2(id, iSeconds, iPercent){
	message_begin(MSG_ONE_UNRELIABLE, g_msgBarTime2, _, id)
	write_short(iSeconds)
	write_short(iPercent)
	message_end()
}

// =========================================================================================== Random respawn
// Collect random spawn points
stock load_spawns(){
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), "%s/csdm/%s.spawns.cfg", cfgdir, mapname)
	
	if (file_exists(filepath)){
		new csdmdata[10][6], file = fopen(filepath,"rt")
		while (file && !feof(file)){
			fgets(file, linedata, charsmax(linedata))
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			parse(linedata,csdmdata[0],5,csdmdata[1],5,csdmdata[2],5,csdmdata[3],5,csdmdata[4],5,csdmdata[5],5,csdmdata[6],5,csdmdata[7],5,csdmdata[8],5,csdmdata[9],5)
			g_spawns[g_spawnCount][0] = floatstr(csdmdata[0])
			g_spawns[g_spawnCount][1] = floatstr(csdmdata[1])
			g_spawns[g_spawnCount][2] = floatstr(csdmdata[2])
			g_spawnCount++
			if (g_spawnCount >= sizeof g_spawns) break;
		}
		if (file) fclose(file)
	}else{
		collect_spawns_ent("info_player_start")
		collect_spawns_ent("info_player_deathmatch")
	}
	collect_spawns_ent2("info_player_start")
	collect_spawns_ent2("info_player_deathmatch")
}

// Collect spawn points from entity origins
stock collect_spawns_ent(const classname[]){
	new ent = -1
	while ((ent = find_ent_by_class(ent, classname)) != 0){
		new Float:originF[3]
		GET_origin(ent, originF)
		g_spawns[g_spawnCount][0] = originF[0]
		g_spawns[g_spawnCount][1] = originF[1]
		g_spawns[g_spawnCount][2] = originF[2]
		g_spawnCount++
		if (g_spawnCount >= sizeof g_spawns) break;
	}
}

// Collect spawn points from entity origins
stock collect_spawns_ent2(const classname[]){
	new ent = -1
	while ((ent = find_ent_by_class(ent, classname)) != 0){
		new Float:originF[3]
		GET_origin(ent, originF)
		g_spawns2[g_spawnCount2][0] = originF[0]
		g_spawns2[g_spawnCount2][1] = originF[1]
		g_spawns2[g_spawnCount2][2] = originF[2]
		g_spawnCount2++
		if (g_spawnCount2 >= sizeof g_spawns2) break;
	}
}

// Place user at a random spawn
public event_ResetHUD(id){
	// hide money n stuff
	set_hud_flags(id, HIDE_NORMAL)
	
	new ti = player_ti[id]
	if (is_valid_ent(ti)) 		// has tactical insertion?
	{
		// put player on top of ti
		new Float:ti_origin[3]
		GET_origin(ti, ti_origin)
		ti_origin[2] += 50.0
		SET_origin(id, ti_origin)
		
		// put him in same direction he was when making ti
		GET_angles(ti, ti_origin) // angles
		SET_angles(id, ti_origin)
		
		// remove ti
		remove_entity(ti)
		player_ti[id] = 0
		return
	}
	else if (ti) player_ti[id] = 0  // bugfix
	
	// first spawn at home
	if (first_spawn[id] > 0){
		first_spawn[id]--
		return
	}
	
	// random spawn
	static hull, sp_index, i
	hull = (GET_flags(id) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN
	if (!g_spawnCount || !po_random_spawn)
		return
	sp_index = random_num(0, g_spawnCount - 1)
	for (i = sp_index + 1; /*no condition*/; i++){
		if (i >= g_spawnCount) i = 0
		if (is_hull_vacant(g_spawns[i], hull)){
			SET_origin(id, g_spawns[i])
			break;
		}
		if (i == sp_index) break;
	}
}

// Checks if a space is vacant (credits to VEN)
stock bool:is_hull_vacant(Float:origin[3], hull){
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, 0, 0)
	if (!get_tr2(0, TR_StartSolid) && !get_tr2(0, TR_AllSolid) && get_tr2(0, TR_InOpen))
		return true;
	return false;
}

// Stock by (probably) Twilight Suzuka -counts number of chars in a string
stock str_count(const str[], searchchar){
	new count, i, len = strlen(str)
	for (i = 0; i <= len; i++){
		if(str[i] == searchchar)
			count++
	}
	return count;
}
//*****************************************************************************************************
//*****************************************************************************************************

//*************************************** Equipments things here **************************************

// semtex
public semtex_stick(taskid)
{
	new semtex = taskid - TASK_SEMTEX_STICK
	if (!is_valid_ent(semtex))
		return
	new victim = GET_ATTACHED(semtex)
	if (!is_user_alive(victim))
		return
	
	static Float:victimOrigin[3]
	GET_origin(victim, victimOrigin)
	SET_origin(semtex, victimOrigin)
	
	// loop this
	set_task(0.1, "semtex_stick", taskid)
}

// tell attacker semtex got stuck
// to enemy player
public semtex_stuck_message(id)
	add_message_in_queue(id, BM_STUCK)

// tell victim semtex got stuck
// to him (+sound +screen goes red)
public semtex_stuck_message_victim(id)
{
	user_scr_blood(id, HP_LIMIT)
	PlaySound(id, BADNEWS_SOUND)
	AnnounceX_L(id, "INFO_STUCK", _, 255, 0, 0)
}

//================================================================================ THROWING KNIFE =======
public throw_knife(id)
{
	if (!is_user_alive(id))
		return
	
	if (!has_tknife[id])
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "TKNIFE_OUT")
		return
	}
	
	has_tknife[id] = false
	
	new Float:origin[3], Float:Aim[3]
	GET_origin(id, origin)
	velocity_by_aim(id, 64, Aim)
	origin[0] += Aim[0]; origin[1] += Aim[1]
	
	new tknife = make_entity(id, tknife_classname, TKNIFE_MODEL, origin, SOLID_SLIDEBOX, MOVETYPE_TOSS, _, 1.0)
	
	new Float:velocity[3]
	velocity_by_aim(id, 900, velocity)
	SET_velocity(tknife, velocity)
	vector_to_angle(velocity, Aim)
	Aim[0] -= 90.0
	SET_angles(tknife, Aim)
}

//================================================================================ TACTICAL INSERTION ====

public put_ti(id)
{
	if (!is_user_alive(id))
		return
	
	if (task_exists(TASK_TACTICAL_INSERTION + id))
		return
	
	if (!has_ti[id])
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "TI_OUT")
		return
	}
	
	emit_sound(id, CHAN_ITEM, TI_SOUND, 0.5, ATTN_STATIC, 0, PITCH_NORM)
	set_task(2.01, "ti_create", TASK_TACTICAL_INSERTION + id)
}

public ti_create(taskid)
{
	new id = taskid - TASK_TACTICAL_INSERTION
	
	if (!is_user_alive(id) || !has_ti[id])
		return
	
	has_ti[id] = false
	if (player_ti[id]){
		remove_entity(player_ti[id])
		player_ti[id] = 0
	}
	
	new Float:origin[3]
	GET_origin(id, origin)
	new ti = make_entity(id, ti_classname, TI_MODEL, origin, SOLID_SLIDEBOX, MOVETYPE_TOSS, 1)
	player_ti[id] = ti 	// store ent#
	
	switch(get_user_team(id)){
		case TEAM_T: set_rendering(ti, kRenderFxGlowShell, 255, 0, 0)
		case TEAM_CT: set_rendering(ti, kRenderFxGlowShell, 0, 0, 255)
	}
	
	new Float:angles[3]
	GET_angles(id, angles)
	SET_angles(ti, angles)
}

public ti_destroy(victim)
{
	if (!is_user_connected(victim) || !player_ti[victim]) return
	player_ti[victim] = 0
	PlaySound(victim, BADNEWS_SOUND)
	AnnounceX(victim, "blocked your TI!", _, 255, 0, 0)
}

//=========================================================================================== C4 ============
public put_c4(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
	
	// if player already had set 1/2 c4, if has c4 (in hud) continue
	if (!has_c4[id])
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "C4_OUT")
		return PLUGIN_HANDLED
	}
	has_c4[id] = false
	
	// find a free index, if there is none, detonate first one
	new freeIndex
	if (!player_c4[id][0]) freeIndex = 0
	else if (!player_c4[id][1]) freeIndex = 1
	else{
		c4_explode(player_c4[id][0])
		player_c4[id][0] = player_c4[id][1]
		player_c4[id][1] = 0
		freeIndex = 1
	}
	
	new Float:origin[3], Float:Aim[3]
	GET_origin(id, origin)
	velocity_by_aim(id, 64, Aim)
	origin[0] += Aim[0]; origin[1] += Aim[1]
	
	new c4 = make_entity(id, c4_classname, C4_MODEL, origin, SOLID_SLIDEBOX, MOVETYPE_TOSS, 1)
	SET_STUCK(c4, 0)
	
	player_c4[id][freeIndex] = c4 	// store ent#
	
	new Float:velocity[3]
	velocity_by_aim(id, 500, velocity)
	SET_velocity(c4, velocity)
	
	PlaySound(id, THROW_SOUND)
	
	return PLUGIN_HANDLED
}

public cmd_c4det(id)
{
	if (!is_user_alive(id) || (!player_c4[id][0] && !player_c4[id][1]))
		return PLUGIN_HANDLED
	
	PlaySound(id, C4_TRIGGER_SOUND)
	set_task(0.15, "c4detonate", id)
	return PLUGIN_HANDLED
}

public c4detonate(id)
{
	new ent, i
	for (i = 0; i < 2; i++)
	{
		ent = player_c4[id][i]
		if (is_valid_ent(ent))
		{
			c4_explode(ent)
			player_c4[id][i] = 0
		}
	}
}

public c4_explode(ent)
{
	if (!is_valid_ent(ent))
		return
	
	// do damage
	gl_radius_damage(ent)
	
	// explosion sound/fire
	emit_sound(ent, CHAN_WEAPON, EXPLDE2_SOUND[random_num(0,charsmax(EXPLDE2_SOUND))], VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
	
	show_explosion1(ent)
	
	remove_entity(ent)
}


//=========================================================================================== CLAYMORE ====
public put_claymore(id)
{
	if (!is_user_alive(id))
		return PLUGIN_HANDLED
	
	// if player already had set 1/2 claymores, if has claymore (in hud) continue
	if (!has_claymore[id])
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "CLAYMORE_OUT")
		return PLUGIN_HANDLED
	}
	has_claymore[id] = false
	
	// find a free index, if there is none, detonate first one
	new freeIndex
	if (!player_claymore[id][0]) freeIndex = 0
	else if (!player_claymore[id][1]) freeIndex = 1
	else{
		claymore_explode(TASK_CLAYMORE_EXPLODE+player_claymore[id][0])
		player_claymore[id][0] = player_claymore[id][1]
		player_claymore[id][1] = 0
		freeIndex = 1
	}
	
	new Float:origin[3], Float:Aim[3]
	GET_origin(id, origin)
	velocity_by_aim(id, 64, Aim)
	origin[0] += Aim[0]; origin[1] += Aim[1]
	new claymore = make_entity(id, claymore_classname, CLAYMORE_MODEL, origin, SOLID_SLIDEBOX, MOVETYPE_TOSS, 1, 8.0)
	player_claymore[id][freeIndex] = claymore
	SET_STUCK(claymore, 0)
	SET_frame(claymore, 0.0)
	SET_body(claymore, 3)
	SET_sequence(claymore, 7)
	SET_framerate(claymore, 0.0)
	// set where it should face
	new Float:playerAngle[3]
	GET_angles(id, playerAngle)
	playerAngle[0] = 0.0
	SET_angles(claymore, playerAngle) // fix z axis
	
	// make its trigger
	velocity_by_aim(id, 80, Aim)
	origin[0] += Aim[0]; origin[1] += Aim[1]
	new claymore_t = make_entity(id, claymore_trigger_classname, CLAYMORE_TRIGGER_MODEL, origin, SOLID_TRIGGER, MOVETYPE_NONE, _, 64.0)
	SET_TRIGGERED(claymore_t, 0)
	SET_ATTACHED(claymore, claymore_t)
	SET_ATTACHED(claymore_t, claymore)
	SET_effects(claymore_t, GET_effects(claymore_t) | EF_NODRAW)
	drop_to_floor(claymore_t)
	
	return PLUGIN_HANDLED
}

public claymore_explode(taskid)
{
	new cm = taskid - TASK_CLAYMORE_EXPLODE
	if (!is_valid_ent(cm)) return
	new cmt = GET_ATTACHED(cm)
	if (!is_valid_ent(cmt)) return
	new id = GET_owner(cm)
	if (!is_user_connected(id)) return
	
	// remove it from array
	for (new i = 0; i < 2; i++)
		if (player_claymore[id][i] == cm)
			player_claymore[id][i] = 0
	
	gl_radius_damage(cmt)
	
	// fire sprite on cm, damage on trigger area
	// explosion sound
	emit_sound(cm, CHAN_WEAPON, EXPLDE2_SOUND[random_num(0,charsmax(EXPLDE2_SOUND))], VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
	
	show_explosion1(cm)
	
	remove_entity(cm)
	remove_entity(cmt)
}

//*****************************************************************************************************
//*****************************************************************************************************

//********************************** Killstreak rewards things here ***********************************


//===================================================================================== UAV ===========
//*************************************************************************************     ***********

// UAV ************************ turn off if EMPd
public radar_scan()
{
	// if no team has UAV, zziiip
	if (!hasUAV[TEAM_T] && !hasUAV[TEAM_CT])
		return
	static num, players[32], id, team; num = 0; id = 0; team = 0
	get_players(players, num, "a")
	for(new a = 0; a < num; a++)
	{
		id = players[a]; team = get_user_team(id)
		if ((hasUAV[TEAM_T] && team == TEAM_T) || (hasUAV[TEAM_CT] && team == TEAM_CT))
			user_UAV(id, team)
	}
}

// > this shows enemy locations to player
// except enemy-players who have cold-blood perk!
user_UAV(id, team)
{
	new PlayerCoords[3], num, players[32], i
	get_players(players, num, "a")
	for(new a = 0; a < num; a++)
	{
		i = players[a]
		
		// don't show teammats/cold-blooded ones in radar
		if (get_user_team(i) == team || USERPERKS(i, RED_PERK) == PERK_COLD_BLOODED)
			continue
		
		get_user_origin(i, PlayerCoords)
		message_begin(MSG_ONE_UNRELIABLE, g_msgHostagePos, _, id)
		write_byte(id)
		write_byte(i)
		write_coord(PlayerCoords[0])
		write_coord(PlayerCoords[1])
		write_coord(PlayerCoords[2])
		message_end()
		message_begin(MSG_ONE_UNRELIABLE, g_msgHostageK, _, id)
		write_byte(i)
		message_end()
	}
}

// turn on UAV
set_UAV(team)
{
	new Float:gltime = get_gametime()
	hasUAV[team] = true
	if (uavEndTime[team] > gltime)
		uavEndTime[team] += UAV_DUR
	else
		uavEndTime[team] = gltime + UAV_DUR
}

// uav end time check (in server frame)
uav_endtime_check(iTeam)
{
	if (uavEndTime[iTeam] < get_gametime() && hasUAV[iTeam])
	{
		hasUAV[iTeam] = false
		uavEndTime[iTeam] = 0.0
	}
}

//__________________________________________________________________________________________________________
//==================================================================================== CARE PACKAGE ========
//************************************************************************************              ********

CreateCarePackage(id)
{
	if (!is_user_alive(id)) return
	
	// make plane
	new Float:Origin[3], Float: Angle[3], Float: Velocity[3]
	velocity_by_aim(id, 1000, Velocity)
	GET_origin(id, Origin)
	GET_v_angle(id, Angle)
	Origin[2] += PLANE_Z; Angle[0] = 0.0; Velocity[2] = Origin[2]
	new ent = make_entity(id, stealth_classname, PACKAGE_HELI_MODEL, Origin, SOLID_BBOX, MOVETYPE_NOCLIP)
	SET_velocity(ent, Velocity)
	SET_angles(ent, Angle)
	emit_sound(ent, CHAN_ITEM, STEALTH_FLYBY_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	set_task(4.5, "remove_plane", ent)
	
	// drop package location/task
	new iorigin[3]
	if (is_user_bot(id))
		get_user_origin(id, iorigin)
	else
		get_user_origin(id, iorigin, 3) // end position from eyes (hit point for weapon) origin
	set_task(3.0, "airdrop", TASK_CAREPACKAGE+id, iorigin, 3)
	
	// show smoke
	show_smoke(iorigin)
	
	new Float:puff_origin[3]
	IVecFVec(iorigin, puff_origin)
	emit_sound_amb(puff_origin, SMOKE_SOUND, 0.5, ATTN_LOUD, PITCH_NORM)
}
public remove_plane(ent) safe_remove_entity(ent)
public airdrop(const origin[3], taskid)
{
	new id = taskid - TASK_CAREPACKAGE
	new Float:fOrigin[3]
	IVecFVec(origin, fOrigin)
	fOrigin[2] += 150.0
	new cp = make_entity(id, package_classname, PACKAGE_PACK_MODEL, fOrigin, SOLID_TRIGGER, MOVETYPE_TOSS, _, 16.0)
	
	switch(get_user_team(id)){
		case TEAM_T: set_rendering(cp, kRenderFxGlowShell, 255, 0, 0)
		case TEAM_CT: set_rendering(cp, kRenderFxGlowShell, 0, 0, 255)
	}
	
	SET_CP_CONTAINS(cp, random_killstreak_reward())
}

// player picking up care package
care_package_check(id)
{
	static iDiffrence, cp
	iDiffrence = floatround((get_gametime() - cpd_time[id]) * 100.0)
	cp = cpd_taking_package[id]
	if (iDiffrence >= 0 && iDiffrence < 10 && is_valid_ent(cp))
	{
		new ks = GET_CP_CONTAINS(cp) - 100 // item in care package
		
		if (GET_button(id)&IN_USE)
		{
			// care package pickup is faster for owner
			new cp_owner = GET_owner(cp)
			new iPerc
			if (id == cp_owner)
				iPerc = CP_TAKE_SPEED
			else
				iPerc = CP_STEAL_SPEED
			
			cpd_progress[id] += iPerc
			
			// player picked up package?
			if (cpd_progress[id] >= 100)
			{
				cpd_progress[id] = 100
				
				// was it stolen?
				if (cp_owner != id)
				{
					if (SAMETEAM(id, cp_owner))
					{
						add_message_in_queue(cp_owner, BM_SHARE_PACKAGE)
					}
					else
					{
						add_message_in_queue(id, BM_HIJACKER)
						new params[2]
						params[0] = cp_owner
						params[1] = id
						set_task(0.1, "cp_steal_message_victim", _, params, sizeof params)
					}
				}
				
				// give reward
				give_ks(id, ks)
				PlaySound(id, PICKUP_SOUND)
				remove_entity(cp)
			}
			Make_BarTime2(id, floatround(100.0 / float(iPerc) * USUR), cpd_progress[id])
			//client_print(id, print_center, "Picking up package... %i", cpd_progress[id])
		}
		else
		{
			if (ks == CP_RESUPPLY)
				client_print(id, print_center, "%L %L", LANG_PLAYER, "INFO_CP_PICKUP", LANG_PLAYER, "KS_CP_RESUPPLY")
			else
				client_print(id, print_center, "%L [%s]", LANG_PLAYER, "INFO_CP_PICKUP", KILLSTREAK_LABLE[ks])
			if (cpd_progress[id] > 0) Make_BarTime2(id, 1, 100)
			cpd_progress[id] = 0
		}
	}
	else
	{
		if (cpd_progress[id] > 0) Make_BarTime2(id, 1, 100)
		cpd_progress[id] = 0
		cpd_time[id] = 0.0
		cpd_taking_package[id] = 0
	}
}

// pick a random reward
random_killstreak_reward()
{
	new chance, ks = CP_RESUPPLY
	for (new i = 0; i < KSR_TOTAL; i++)
	{
		chance = CP_CHANCE[i]
		if (chance && !random_num(0, 100 / chance)) ks = i
	}
	return 100 + ks
}

// tell victim package was stolen
public cp_steal_message_victim(params[])
{
	new victim = params[0], stealer = params[1]
	new sMessage[64]
	if (is_user_connected(stealer))
		formatex(sMessage, charsmax(sMessage), "[ %s, %L ]", g_playername[stealer], LANG_PLAYER, "KS_CP_TOOK")
	else
		formatex(sMessage, charsmax(sMessage), "[ %L ]", LANG_PLAYER, "KS_CP_TOOKB")
	
	PlaySound(victim, BADNEWS_SOUND)
	AnnounceX(victim, sMessage, _, 255, 0, 0)
}

//__________________________________________________________________________________________________________
//==================================================================================== SENTRY GUN ==========
//************************************************************************************            **********

public sentry_target_reset(taskid){
	new ent = taskid - TASK_TARGET_RESET
	if (!is_valid_ent(ent)) return
	SET_SENTRY_TARGET(ent, 0)
}
public sentry_deactivate(taskid){
	new ent = taskid - TASK_SENTRY_DEACTIVATE
	if (!is_valid_ent(ent)) return
	SET_SENTRY_ACTIVE(ent, 0)
	SET_SENTRY_TILT_TURRET(ent, 0)
	
	new id = GET_owner(ent)
	if (!is_user_connected(id)) return
	has_sentry[id] = 0
	
	// break smoke effect
	new iorigin[3]
	get_origin_int(ent, iorigin)
	show_smoke(iorigin)
	
	// break sound
	emit_sound(ent, CHAN_BODY, SENTRY_BREAK, 0.6, ATTN_NORM, 0, PITCH_NORM)
	
	// tell player
	client_print(id, print_center, "%L", LANG_PLAYER, "SENTRY_DEST")
}
public sentry_remove(taskid)
{
	new ent = taskid - TASK_SENTRY_REMOVE
	if (!is_valid_ent(ent)) return
	new entbase = GET_ATTACHED(ent)
	safe_remove_entity(ent)
	safe_remove_entity(entbase)
}

// clean up
public sentry_cleanup()
{
	new ent
	for (new i = 1; i <= g_maxplayers; i++)
	{
		ent = has_sentry[i]
		if (ent)
		{
			// remove it right away!
			if (task_exists(TASK_SENTRY_REMOVE+ent))
				remove_task(TASK_SENTRY_REMOVE+ent)
			sentry_remove(TASK_SENTRY_REMOVE+ent)
		}
		has_sentry[i] = 0
	}
}

// sentry and all equipments think!
public sentry_think()
{
	static ent, entbase
	for (new e = 1; e <= g_maxplayers; e++)
	{
		check_equipments(e)
		
		ent = 0
		entbase = 0
		if (!is_valid_ent(has_sentry[e]))
			continue
		
		ent = has_sentry[e]
		
		if (!GET_SENTRY_ACTIVE(ent))
			continue
		
		if (GET_health(ent) <= 0.0)
		{
			sentry_break(ent)
			continue
		}
		
		entbase = GET_ATTACHED(ent)
		
		new Float:sentryOrigin[3], Float:hitOrigin[3], hitent
		GET_origin(entbase, sentryOrigin)
		sentryOrigin[2] += 40.0
		
		SET_origin(ent, sentryOrigin)
		entity_set_size(ent, Float:{-20.0,-20.0,-20.0}, Float:{20.0,20.0,20.0}) // testt
		
		new closestTarget = 0, Float:closestDistance, Float:distance, Float:closestOrigin[3], Float:targetOrigin[3]
		new sentryTeam
		sentryTeam = get_user_team(GET_owner(ent))
		
		closestTarget = GET_SENTRY_TARGET(ent)
		
		if (closestTarget == 0)
		{
			for (new i = 1; i <= g_maxplayers; i++)
			{
				if (!is_user_connected(i) || !is_user_alive(i) || get_user_team(i) == sentryTeam)
					continue
				
				// sentries don't see cold blooded ones!
				if (USERPERKS(i, RED_PERK) == PERK_COLD_BLOODED)
					continue
				
				GET_origin(i, targetOrigin)
				distance = vector_distance(sentryOrigin, targetOrigin)
				
				if (distance > SENTRY_RANGE)
					continue
				
				hitent = trace_line(ent, sentryOrigin, targetOrigin, hitOrigin)
				if (hitent == entbase)
					hitent = trace_line(hitent, hitOrigin, targetOrigin, hitOrigin)
				
				if (hitent == i)
				{
					closestOrigin = targetOrigin
					
					if (distance < closestDistance || closestTarget == 0) 
					{
						closestTarget = i
						closestDistance = distance
					}
				}
			}
			// if just found one, make noise
			if (closestTarget)
				emit_sound(ent, CHAN_ITEM, SENTRY_SPOT, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		}
		
		if (closestTarget)
		{
			// change the target after x sec if target is hard to get
			if (!task_exists(TASK_TARGET_RESET+ent))
				set_task(SENTRY_RETARGET, "sentry_target_reset", TASK_TARGET_RESET+ent)
			
			// store target id (in sentry entity)
			SET_SENTRY_TARGET(ent, closestTarget)
			
			// turn to target
			GET_origin(closestTarget, targetOrigin)
			sentry_turntotarget(ent, sentryOrigin, targetOrigin)
			
			// shoot the mofo
			sentry_fire(ent, sentryOrigin, targetOrigin)
		}
	}
}

sentry_turntotarget(ent, Float:sentryOrigin[3], Float:closestOrigin[3]){
	new Float:newAngle[3]
	GET_angles(ent, newAngle)
	new Float:x = closestOrigin[0] - sentryOrigin[0]
	new Float:z = closestOrigin[1] - sentryOrigin[1]
	new Float:radians = floatatan(z/x, radian)
	newAngle[1] = radians * (180.0 / M_PI)
	if (closestOrigin[0] < sentryOrigin[0])
		newAngle[1] -= 180.0
	new Float:h = closestOrigin[2] - sentryOrigin[2]
	new Float:b = vector_distance(sentryOrigin, closestOrigin)
	radians = floatatan(h/b, radian)
	new Float:degs = radians * (180.0 / M_PI)
	new Float:degreeByte = 830.0/256.0 // SENTRYTILTRADIUS
	new Float:tilt = 127.0 - degreeByte * degs
	SET_SENTRY_TILT_TURRET(ent, floatround(tilt))
	SET_angles(ent, newAngle)
}

sentry_fire(iEnt, Float:entity_origin[3], Float:target_origin[3]){
	static blt, Float:speed = 2500.0
	target_origin[2] -= 10.0
	entity_origin[2] += 20.0
	blt = make_entity(GET_owner(iEnt), sentryblt_classname, SENTRY_BLT, entity_origin, SOLID_BBOX, MOVETYPE_FLY, _, 2.0)
	new Float:diff[3]
	diff[0] = target_origin[0] - entity_origin[0]
	diff[1] = target_origin[1] - entity_origin[1]
	diff[2] = target_origin[2] - entity_origin[2]
	new Float:length = floatsqroot(floatpower(diff[0], 2.0) + floatpower(diff[1], 2.0) + floatpower(diff[2], 2.0))
	new Float:velocity[3]
	velocity[0] = diff[0] * (speed / length) * random_float(0.95, 1.05)
	velocity[1] = diff[1] * (speed / length)
	velocity[2] = diff[2] * (speed / length) * random_float(0.95, 1.05)
	SET_velocity(blt, velocity)
	new Float:angles[3]
	vector_to_angle(velocity, angles)
	SET_angles(blt, angles)
	msg_beam_follow(blt, 255, 255, 0, 1)
	emit_sound(blt, CHAN_WEAPON, SENTRY_SHOOT, VOL_NORM, ATTN_NORM, 0, random_num(90, 110) /*PITCH_NORM*/)
}

// build sentry gun
public sentry_build(creator)
{
	if (has_sentry[creator])
	{
		client_print(creator, print_chat, "%L", LANG_PLAYER, "SENTRY_LIMIT")
		return 0
	}
	
	// throw it in front of player
	new Float:origin[3], Float:Aim[3]
	GET_origin(creator, origin)
	velocity_by_aim(creator, 64, Aim)
	origin[0] += Aim[0]; origin[1] += Aim[1]
	
	// base
	new entbase, ent
	entbase = make_entity(creator, sentrybase_classname, SENRYBASE_MODEL, origin, SOLID_SLIDEBOX, MOVETYPE_TOSS)
	
	// head
	ent = make_entity(creator, sentry_classname, SENRY_MODEL, origin, SOLID_BBOX, MOVETYPE_FLY, SENTRY_HEALTH, 2.0)
	GET_angles(creator, Aim)
	Aim[0] = 0.0
	SET_angles(ent, Aim)
	SET_SENTRY_TILT_TURRET(ent, 127)
	switch(get_user_team(creator)){
		case TEAM_T: SET_colormap(ent, 0|(0<<8))
		case TEAM_CT: SET_colormap(ent, 150|(160<<8))
	}
	
	// bind sentry head and base
	SET_ATTACHED(ent, entbase)
	SET_ATTACHED(entbase, ent)
	
	// player has a sentry now
	has_sentry[creator] = ent
	
	// deactivition/remove tasks
	set_task(SENTRY_LIFE, "sentry_deactivate", TASK_SENTRY_DEACTIVATE+ent)
	set_task(SENTRY_LIFE + 5.0, "sentry_remove", TASK_SENTRY_REMOVE+ent)
	
	// activate in 3 sec
	set_task(3.0, "sentry_activate", TASK_SENTRY_ACTIVATE+ent)
	SET_SENTRY_ACTIVE(ent, 0)
	
	return ent
}

public sentry_activate(taskid)
{
	new ent = taskid - TASK_SENTRY_ACTIVATE
	if (!is_valid_ent(ent)) return
	
	SET_SENTRY_ACTIVE(ent, 1)
	
	// ready sound
	emit_sound(ent, CHAN_BODY, SENTRY_READY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

sentry_break(ent)
{
	if (!is_valid_ent(ent)) return
	remove_task(TASK_SENTRY_DEACTIVATE+ent)
	sentry_deactivate(TASK_SENTRY_DEACTIVATE+ent)
	set_task(5.0, "sentry_remove", TASK_SENTRY_REMOVE+ent)
}

//__________________________________________________________________________________________________________
//================================================================================ PREDATOR MISSILE ========
//********************************************************************************                  ********

public CreatePredator(id)
{
	if (user_ctrl_pred[id]) return 0
	new Float:Origin[3], Float:Angle[3], Float:Velocity[3]
	velocity_by_aim(id, PREDATOR_SPEED, Velocity)
	GET_origin(id, Origin)
	GET_v_angle(id, Angle)
	Angle[0] *= -1.0
	new iPred = make_entity(id, pred_classname, ROCKET_MDL, Origin, SOLID_BBOX, MOVETYPE_FLY)
	SET_velocity(iPred, Velocity)
	SET_angles(iPred, Angle)
	attach_view(id, iPred)
	user_ctrl_pred[id] = iPred
	user_pred_speed[id] = PREDATOR_SPEED
	msg_beam_follow(iPred, 255, 255, 255)
	SET_effects(iPred, EF_BRIGHTLIGHT)
	set_rendering(iPred, kRenderFxGlowShell, 150, 150, 150) // thermal
	Display_Fade(id, 0, 0, FFADE_STAYOUT, 150, 150, 150, 100, true) // thermal
	emit_sound(iPred, CHAN_AUTO, PR_FLY_START, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	set_task(1.5, "pred_fly_sound", TASK_PRED_FLY+id, _, _, "b")
	return iPred
}

public pred_fly_sound(taskid)
{
	new id = taskid - TASK_PRED_FLY
	new ent = user_ctrl_pred[id]
	if (!is_valid_ent(ent))
	{
		remove_task(taskid)
		return
	}
	emit_sound(ent, CHAN_AUTO, PR_FLY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

//__________________________________________________________________________________________________________
//==================================================================================== EMP =================
//************************************************************************************     *****************

launch_EMP(id)
{
	new enemyTeam = get_user_team(id) == TEAM_T ? TEAM_CT : TEAM_T
	team_EMP(enemyTeam)
	
	// destroy all UAVs
	if (hasUAV[enemyTeam])
	{
		hasUAV[enemyTeam] = false
		uavEndTime[enemyTeam] = 0.0
		set_task(2.0, "destroyed_uavs", id)
	}
	
	// destroy all Sentry guns!
	new ent
	for (new i = 1; i < g_maxplayers; i++)
	{
		ent = has_sentry[i]
		if (is_valid_ent(ent) && get_user_team(i) == enemyTeam)
			sentry_break(ent)
	}
	
	AnnounceX(0, KILLSTREAK_LABLE[KSR_EMP], id)
}

// EMP a team
team_EMP(team)
{
	new num, players[32]
	switch(team)
	{
		case TEAM_T: set_EMP(TEAM_T)
		case TEAM_CT: set_EMP(TEAM_CT)
		default: return
	}
	
	get_players(players, num, "a")
	for(new a = 0; a < num; a++)
	{
		new id = players[a]
		Display_Fade(id, 1, 1, FFADE_IN, 255, 255, 225, 155)
		if (get_user_team(id) == team)
			set_hud_flags(id, EMP_HIDE_FLAGS)
	}
}

set_EMP(team)
{
	is_EMPd[team] = true
	if (task_exists(TASK_UN_EMP+team)) remove_task(TASK_UN_EMP+team)
	set_task(EMP_DUR, "team_unEMP", TASK_UN_EMP+team)
}

public team_unEMP(taskid)
{
	new team = taskid - TASK_UN_EMP
	is_EMPd[team] = false
	
	new num, players[32]
	get_players(players, num, "a")
	for(new a = 0; a < num; a++)
	{
		new id = players[a]
		if (is_user_alive(id) && get_user_team(id) == team)
			set_hud_flags(id, HIDE_NORMAL)
	}
}

bool:is_user_EMPd(id)
{
	if (!is_user_connected(id)) return false
	switch(get_user_team(id))
	{
		case TEAM_T: return is_EMPd[TEAM_T]
		case TEAM_CT: return is_EMPd[TEAM_CT]
	}
	return false
}

public destroyed_uavs(id)
	AnnounceX_L(0, "INFO_DESTUAV", id)

//__________________________________________________________________________________________________________
//=============================================================================== TACTICAL NUKE ============
//*******************************************************************************               ************

public launch_nuke(id)
{
	if (!is_user_alive(id))
		return
	
	if (id_nuker)
	{
		client_print(id, print_center, "%L", LANG_PLAYER, "NUKE_BLOCKED")
		return
	}
	
	id_nuker = id
	team_nuker = get_user_team(id)
	nuke_countdown = 11
	task_countdown()
	
	AnnounceX(0, KILLSTREAK_LABLE[KSR_TACTICAL_NUKE], id)
}

public task_countdown()
{
	nuke_countdown--
	if (nuke_countdown > 0){
		set_task(1.0, "task_countdown", TASK_TACTICAL_NUKE)
		PlaySound(0, NUKE_ALARM_SOUND)
	}
	if (nuke_countdown == 2) Display_Fade(0, 4, 1, FFADE_OUT, 255, 255, 255, 225)
	if (nuke_countdown == 0)
	{
		remove_task(TASK_TACTICAL_NUKE)
		is_nuke_time = true
		// nuke_explode = get_gametime() + 10.0
		PlaySound(0, NUKE_HIT_SOUND)
		
		// what if the mofo nuked and left?
		if (!is_user_connected(id_nuker)) id_nuker = 0
		
		// force win:
		if (team_nuker == TEAM_CT) 	// CT
			// TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct)
			TerminateRound_TE(WinStatus_Ct)
		else if (team_nuker == TEAM_T) 	// T
			// TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist)
			TerminateRound_TE(WinStatus_Terrorist)
		else 				// Draw
			// TerminateRound(RoundEndType_Draw)  // this will never happen but just in case!
			TerminateRound_TE(WinStatus_RoundDraw)
		
		// kill all
		new players[32], pnum
		get_players(players, pnum, "a")
		for (new i = 0; i < pnum; i++)
			if (id_nuker && team_nuker != get_user_team(players[i]))
				log_kill_B(id_nuker, players[i], "Tactical Nuke", 0)
			else
				user_kill(players[i])
		
		// end sound
		round_end_sound()
		score_freeze = true
		round_end_stuff()
		//end_game_check
		winner = team_nuker
	}
	
	// timer!
	set_hudmessage(255, 255, 0, -1.0, 0.30, 1, 0.0, 3.0, 1.0, 1.0, -1)
	new msg[32]; formatex(msg, charsmax(msg), "%s: %i", KILLSTREAK_LABLE[KSR_TACTICAL_NUKE], nuke_countdown)
	ShowSyncHudMsg(0, g_MsgSyncHUD, msg)
}

//__________________________________________________________________________________________________________
//=============================================================================== STEALTH BOMBER ===========
//*******************************************************************************                ***********

CreateStealthBomber(id)
{
	if (!is_user_alive(id)) return 0
	
	// make plane
	new Float:Origin[3], Float: Angle[3], Float: Velocity[3]
	velocity_by_aim(id, 1000, Velocity)
	GET_origin(id, Origin)
	GET_v_angle(id, Angle)
	Origin[2] += PLANE_Z; Angle[0] = 0.0; Velocity[2] = Origin[2]
	new ent = make_entity(id, stealth_classname, PACKAGE_HELI_MODEL, Origin, SOLID_BBOX, MOVETYPE_NOCLIP)
	SET_velocity(ent, Velocity)
	SET_angles(ent, Angle)
	emit_sound(ent, CHAN_ITEM, STEALTH_FLYBY_SOUND, VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
	set_task(4.5, "remove_plane", ent)
	
	// bombing coordz
	new iorigin[3], Float:fVelocity[3], iVelocity[3]
	get_user_origin(id, iorigin, 3)
	velocity_by_aim(id, 150, fVelocity)
	FVecIVec(fVelocity, iVelocity)
	
	// fly sound to all
	new Float:fly_origin[3]
	IVecFVec(iorigin, fly_origin)
	emit_sound_amb(fly_origin, STEALTH_FLYBY_SOUND, VOL_NORM, ATTN_PREDATOR, PITCH_LOW)
	
	new BombCoords[3]
	for (new i = 0; i < MAXBOMBS; i++)
	{
		BombCoords[0] = iorigin[0] + iVelocity[0] * (i + 1)
		BombCoords[1] = iorigin[1] + iVelocity[1] * (i + 1)
		BombCoords[2] = iorigin[2] + BOMBSPACE
		set_task(2.0 + (float(i) * 0.25), "blast_em_mofos", TASK_STEALTHBOMBER+id, BombCoords, 3)
	}
	
	user_stealth[id] = ent
	
	AnnounceX(0, KILLSTREAK_LABLE[KSR_STEALTH_BOMBER], id, _, _, _, true)
	
	return ent
}

// drop bombs on given origin
public blast_em_mofos(const origin[3], taskid)
{
	new id = taskid - TASK_STEALTHBOMBER
	new Float:fOrigin[3]
	IVecFVec(origin, fOrigin)
	new sb = make_entity(id, bomb_classname, ROCKET_MDL, fOrigin, SOLID_BBOX, MOVETYPE_TOSS, _, 1.0)
	
	new plane = user_stealth[id]
	if (!is_valid_ent(plane) || !is_valid_ent(sb))
	{
		safe_remove_entity(plane)
		safe_remove_entity(sb)
		user_stealth[id] = 0
	}
	
	SET_ATTACHED(sb, plane)
	SET_angles(sb, Float:{90.0, 0.0, 0.0})
	SET_takedamage(sb, DAMAGE_YES)
	set_rendering(sb, kRenderFxGlowShell, 255, 0, 0)
	msg_beam_follow(sb, 224, 224, 255)
}

//__________________________________________________________________________________________________________
//========================================================================== PRECISION AIRSTRIKE ===========
//**************************************************************************                     ***********

CreatePrecision(id)
{
	if (!is_user_alive(id)) return 0
	
	// make plane
	new Float:Origin[3], Float: Angle[3], Float: Velocity[3]
	velocity_by_aim(id, 1000, Velocity)
	GET_origin(id, Origin)
	GET_v_angle(id, Angle)
	Origin[2] += PLANE_Z; Angle[0] = 0.0; Velocity[2] = Origin[2]
	new ent = make_entity(id, stealth_classname, PACKAGE_HELI_MODEL, Origin, SOLID_BBOX, MOVETYPE_NOCLIP)
	SET_velocity(ent, Velocity)
	SET_angles(ent, Angle)
	emit_sound(ent, CHAN_ITEM, STEALTH_FLYBY_SOUND, VOL_NORM, ATTN_LOUD, 0, PITCH_NORM)
	set_task(4.5, "remove_plane", ent)
	
	// bombing coordz
	new iorigin[3], Float:fVelocity[3], iVelocity[3]
	get_user_origin(id, iorigin, 3)
	velocity_by_aim(id, 150, fVelocity)
	FVecIVec(fVelocity, iVelocity)
	
	new BombCoords[3]
	for (new i = 0; i < P_MAXBOMBS; i++)
	{
		BombCoords[0] = iorigin[0] + iVelocity[0] * (i + 1)
		BombCoords[1] = iorigin[1] + iVelocity[1] * (i + 1)
		BombCoords[2] = iorigin[2] + P_BOMBSPACE
		set_task(2.0 + (float(i) * 0.15), "drop_bombs", TASK_PRECISIONAIRSTRIKE+id, BombCoords, 3)
	}
	
	user_precision[id] = ent
	
	return ent
}

// drop bombs on given origin
public drop_bombs(const origin[3], taskid)
{
	new id = taskid - TASK_PRECISIONAIRSTRIKE
	new Float:fOrigin[3]
	IVecFVec(origin, fOrigin)
	new pa = make_entity(id, pbomb_classname, ROCKET_MDL, fOrigin, SOLID_BBOX, MOVETYPE_TOSS, _, 1.0)
	
	new plane = user_precision[id]
	if (!is_valid_ent(plane) || !is_valid_ent(pa))
	{
		safe_remove_entity(plane)
		safe_remove_entity(pa)
		user_precision[id] = 0
	}
	
	SET_ATTACHED(pa, plane)
	SET_angles(pa, Float:{90.0, 0.0, 0.0})
	SET_takedamage(pa, DAMAGE_YES)
	set_rendering(pa, kRenderFxGlowShell, 255, 0, 0)
	msg_beam_follow(pa, 224, 224, 255)
}

