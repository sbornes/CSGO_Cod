/*

       _ _    _  _____  _____ ______ _____  _   _         _    _ _______ 
      | | |  | |/ ____|/ ____|  ____|  __ \| \ | |   /\  | |  | |__   __|
      | | |  | | |  __| |  __| |__  | |__) |  \| |  /  \ | |  | |  | |   
  _   | | |  | | | |_ | | |_ |  __| |  _  /| . ` | / /\ \| |  | |  | |   
 | |__| | |__| | |__| | |__| | |____| | \ \| |\  |/ ____ \ |__| |  | |   
  \____/ \____/ \_____|\_____|______|_|  \_\_| \_/_/    \_\____/   |_|   
                                                                         
*/

public void doJuggernaut(int client)
{
	add_message_in_queue(client, KSR_JUGGERNAUT, MESSAGE_POINTS[KSR_JUGGERNAUT])

	hasJuggernaut[client] = false;
	isJuggernaut[client] = true;
	hasBallisticVest[client] = false;
	
	Client_RemoveAllWeapons(client, "weapon_knife", true);
							
	int mainGun = GivePlayerItem(client, "weapon_negev");
	int SecGun = GivePlayerItem(client, "weapon_revolver");

	Client_SetWeaponPlayerAmmoEx(client, mainGun, GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_PRIMARY), Prop_Send, "m_iPrimaryReserveAmmoCount")) 
	Client_SetWeaponPlayerAmmoEx(client, SecGun, GetEntProp(Client_GetWeaponBySlot(client, CS_SLOT_SECONDARY), Prop_Send, "m_iPrimaryReserveAmmoCount")) 

	SetEntityHealth(client, 500)

	GivePlayerItem(client, "item_heavyassaultsuit");
	if(GetClientTeam(client) == CS_TEAM_T )
		SetEntityModel(client, "models/player/custom_player/legacy/tm_phoenix_heavy.mdl");
	else
	{
		SetEntityModel(client, "models/player/custom_player/caleon1/nkpolice/nkpolice.mdl");
		SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/custom_player/caleon1/nkpolice/nkpolice_arms.mdl");
	}
}