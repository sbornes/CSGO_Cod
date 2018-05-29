//#pragma dynamic 131072 
#pragma newdecls required

#define IsValidClient(%1)  ( 1 <= %1 <= MaxClients && IsClientInGame(%1) )
#define IsValidClientAlive(%1)  ( 1 <= %1 <= MaxClients && IsClientInGame(%1) && IsPlayerAlive(%1) )

#define MAX_LEVEL 80
#define MAX_PRESTIGE 10
#define MAX_CUSTOM_CLASS 5

#define GROUP_TAG "SAGUN |"

#define VIP_FLAG ADMFLAG_CUSTOM6