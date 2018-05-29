#include <sourcemod>
#include <scp>
#include <cod>

#include "cod/Titles.sp"

#define IsValidClient(%1)  ( 1 <= %1 <= MaxClients && IsClientInGame(%1) )

public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	if(IsValidClient(author))
	{
		if(GetUserFlagBits(author) & ADMFLAG_GENERIC || GetUserFlagBits(author) & ADMFLAG_ROOT)
			Format(name, MAXLENGTH_NAME, " \x04[ADMIN]\x05 %s\x03 %s", Titles[COD_GetLevel(author)], name);		
		else if(GetUserFlagBits(author) & ADMFLAG_CUSTOM6)
			Format(name, MAXLENGTH_NAME, " \x04[VIP]\x05 %s\x03 %s", Titles[COD_GetLevel(author)], name);		
		else
			Format(name, MAXLENGTH_NAME, " \x05%s\x03 %s", Titles[COD_GetLevel(author)], name);		
		return Plugin_Changed;
	}
	return Plugin_Continue;
}