/*

  _____  ______          _____     _____ _____ _      ______ _   _  _____ ______ 
 |  __ \|  ____|   /\   |  __ \   / ____|_   _| |    |  ____| \ | |/ ____|  ____|
 | |  | | |__     /  \  | |  | | | (___   | | | |    | |__  |  \| | |    | |__   
 | |  | |  __|   / /\ \ | |  | |  \___ \  | | | |    |  __| | . ` | |    |  __|  
 | |__| | |____ / ____ \| |__| |  ____) |_| |_| |____| |____| |\  | |____| |____ 
 |_____/|______/_/    \_\_____/  |_____/|_____|______|______|_| \_|\_____|______|
                                                                                 
*/

public Action FootstepCheck(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags) 
{ 
    // Player 
    if (0 < entity <= MaxClients) 
    { 
        if(StrContains(sample, "physics") != -1 || StrContains(sample, "footsteps") != -1) 
        { 
            // Player not ninja, play footsteps 
            if(!hasPerk(entity, "Dead Silence")) 
            { 
                numClients = 0; 

                for(int i = 1; i <= MaxClients; i++) 
                { 
                    if(IsClientInGame(i) && !IsFakeClient(i)) 
                    { 
                        clients[numClients++] = i; 
                    } 
                } 

                EmitSound(clients, numClients, sample, entity); 
                //return Plugin_Changed; 
            } 
            return Plugin_Stop; 
        } 
    } 
    return Plugin_Continue; 
}  

/*
  __  __          _____  _  __ _____ __  __          _   _ 
 |  \/  |   /\   |  __ \| |/ // ____|  \/  |   /\   | \ | |
 | \  / |  /  \  | |__) | ' /| (___ | \  / |  /  \  |  \| |
 | |\/| | / /\ \ |  _  /|  <  \___ \| |\/| | / /\ \ | . ` |
 | |  | |/ ____ \| | \ \| . \ ____) | |  | |/ ____ \| |\  |
 |_|  |_/_/    \_\_|  \_\_|\_\_____/|_|  |_/_/    \_\_| \_|

*/                                                           
                                                           

public Action MarksmanTransmit(int entity, int client)
{
    if(!hasPerk(client, "Marksman"))
        SDKUnhook(client, SDKHook_SetTransmit, MarksmanTransmit);

    if(entity != client)
        if(IsValidClientAlive(entity) && IsValidClientAlive(client) && GetClientTeam(entity) != GetClientTeam(client))
            if(IsVisibleTo(entity, client))
                SetEntProp(client, Prop_Send, "m_bSpotted", 1); 
        
}  

/*
   _____ _______       _      _  ________ _____  
  / ____|__   __|/\   | |    | |/ /  ____|  __ \ 
 | (___    | |  /  \  | |    | ' /| |__  | |__) |
  \___ \   | | / /\ \ | |    |  < |  __| |  _  / 
  ____) |  | |/ ____ \| |____| . \| |____| | \ \ 
 |_____/   |_/_/    \_\______|_|\_\______|_|  \_\                                               
*/

public Action DoStalker(Handle timer, any client)
{
    if(IsValidClientAlive(client))
        return Plugin_Stop;


    bool isSpotted[MAXPLAYERS+1];

    for(int i = 1; i <= MaxClients; i++) {
        if(IsValidClientAlive(i)) {
            if(GetClientTeam(i) != GetClientTeam(client)) {
                if(IsVisibleTo(i, client)) {
                    isSpotted[client] = true; break;
                }
            }
        }
    }

    if(isSpotted[client]) {
        if(!IsSprinting[client] && GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1.0){
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.0);
        }
    }
    else {
        if(!IsSprinting[client] && GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") == 1.0){
            SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", 1.10);
        }
    }

    return Plugin_Continue;
}
