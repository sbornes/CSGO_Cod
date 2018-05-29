void GiveXP(int client, int amount)
{
    if(PlayerStatsInfo[client][Level] == MAX_LEVEL)
    {
        CS_SetClientContributionScore(client, 0);
        return;
    }

    PlayerStatsInfo[client][XP] += amount;
    //PrintToChat(client, "+%dXP", amount);
    CheckLevelUp(client);

    //CS_SetClientContributionScore(client, XPtoLevel[PlayerStatsInfo[client][Level]+1] - PlayerStatsInfo[client][XP]);
    //CS_SetClientContributionScore(client, XPtoLevel[PlayerStatsInfo[client][Level]] - PlayerStatsInfo[client][XP]);       
}

void CheckLevelUp(int client)
{
    //while(PlayerStatsInfo[client][XP] >= XPtoLevel[PlayerStatsInfo[client][Level]+1])
    while(PlayerStatsInfo[client][XP] >= XPtoLevel[PlayerStatsInfo[client][Level]])
    {
        EmitSoundToClientAny(client, "cod/levelup.mp3", _, SNDCHAN_STATIC );
        PlayerStatsInfo[client][Level]++;
        PrintToChat(client, " \x04You have been promoted to \x03%s\x01 (Lv%d).", Titles[PlayerStatsInfo[client][Level]], PlayerStatsInfo[client][Level]);
        CheckUnlocks(client);
        PlayerStatsInfo[client][XP] = 0;

        CS_SetMVPCount(client, PlayerStatsInfo[client][Level])
    }
}

void CheckUnlocks(int client)
{
    int count = 0;
    char[][] display = new char[128][128];
    //Format(display, sizeof(display), " \x04You have unlocked:\x01 ");
    if(PlayerStatsInfo[client][Level] == Class_CustomLevel.IntValue)
    {
        Format(display[count], 128, " \nCustom Class Creation");
        count++;            
    }
    for(int i = 0; i < sizeof(Rifles); i++)
    {
        if( StringToInt(Rifles[i][1]) == PlayerStatsInfo[client][Level] )
        {
            char Wepp[32];
            strcopy(Wepp, 32, Rifles[i][0]);
            ReplaceString(Wepp, 32, "weapon_", "", false);
            Wepp[0] = CharToUpper(Wepp[0]);

            /*if(count)
                Format(display, sizeof(display), "%s, Rifle: %s", display, Wepp);
            else
                Format(display, sizeof(display), "%s Rifle: %s", display, Wepp);*/
            //Format(display[count], sizeof(display[count]), "%s \nRifle: %s", display, Wepp);
            Format(display[count], 128, " \nRifle:\x01 %s", Wepp);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Pistols); i++)
    {
        if( StringToInt(Pistols[i][1]) == PlayerStatsInfo[client][Level] )
        {
            char Wepp[32];
            strcopy(Wepp, 32, Pistols[i][0]);
            ReplaceString(Wepp, 32, "weapon_", "", false);
            Wepp[0] = CharToUpper(Wepp[0]);

            /*if(count)
                Format(display, sizeof(display), "%s, Pistol: %s", display, Wepp);
            else
                Format(display, sizeof(display), "%s Pistol: %s", display, Wepp);*/
            //Format(display[count], sizeof(display[count]), "%s \nPistol: %s", display, Wepp);
            Format(display[count], 128, " \nPistol:\x01 %s", Wepp);
            count++;
        }
    }
    for(int i = 0; i < sizeof(SMGs); i++)
    {
        if( StringToInt(SMGs[i][1]) == PlayerStatsInfo[client][Level] )
        {
            char Wepp[32];
            strcopy(Wepp, 32, SMGs[i][0]);
            ReplaceString(Wepp, 32, "weapon_", "", false);
            Wepp[0] = CharToUpper(Wepp[0]);

            /*if(count)
                Format(display, sizeof(display), "%s, SMG: %s", display, Wepp);
            else
                Format(display, sizeof(display), "%s SMG: %s", display, Wepp);*/
            //Format(display[count], sizeof(display[count]), "%s \nSMG: %s", display, Wepp);
            Format(display[count], 128, " \nSMG:\x01 %s", Wepp);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Shotguns); i++)
    {
        if( StringToInt(Shotguns[i][1]) == PlayerStatsInfo[client][Level] )
        {
            char Wepp[32];
            strcopy(Wepp, 32, Shotguns[i][0]);
            ReplaceString(Wepp, 32, "weapon_", "", false);
            Wepp[0] = CharToUpper(Wepp[0]);

            /*if(count)
                Format(display, sizeof(display), "%s, Shotgun: %s", display, Wepp);
            else
                Format(display, sizeof(display), "%s Shotgun: %s", display, Wepp);*/
            //Format(display[count], sizeof(display[count]), "%s \nShotgun: %s", display, Wepp);
            Format(display[count], 128, " \nShotgun:\x01 %s", Wepp);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Snipers); i++)
    {
        if( StringToInt(Snipers[i][1]) == PlayerStatsInfo[client][Level] )
        {
            char Wepp[32];
            strcopy(Wepp, 32, Snipers[i][0]);
            ReplaceString(Wepp, 32, "weapon_", "", false);
            Wepp[0] = CharToUpper(Wepp[0]);

            /*if(count)
                Format(display, sizeof(display), "%s, Sniper: %s", display, Wepp);
            else
                Format(display, sizeof(display), "%s Sniper: %s", display, Wepp);*/
            //Format(display[count], sizeof(display[count]), "%s \nSniper: %s", display, Wepp);
            Format(display[count], 128, " \nSniper:\x01 %s", Wepp);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Equipments); i++)
	{
		if( StringToInt(Equipments[i][1]) == PlayerStatsInfo[client][Level] )
		{
			/*if(count)
				Format(display, sizeof(display), "%s, Equipment: %s", display, Equipments[i][0]);
			else
				Format(display, sizeof(display), "%s Equipment: %s", display, Equipments[i][0]);*/
            //Format(display[count], sizeof(display[count]), "%s \nEquipment: %s", display, Equipments[i][0]);
            Format(display[count], 128, " \nEquipment:\x01 %s", Equipments[i][0]);
            count++;
		}
    }
    for(int i = 0; i < sizeof(Tacticals); i++)
    {
        if( StringToInt(Tacticals[i][1]) == PlayerStatsInfo[client][Level] )
        {
            /*if(count)
                Format(display, sizeof(display), "%s, Tactical: %s", display, Tacticals[i][0]);
            else
                Format(display, sizeof(display), "%s Tactical: %s", display, Tacticals[i][0]);*/
            //Format(display[count], sizeof(display[count]), "%s \nTactical: %s", display, Tacticals[i][0]);
            Format(display[count], 128, " \nTactical:\x01 %s", Tacticals[i][0]);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Perk1); i++)
    {
        if( StringToInt(Perk1[i][1]) == PlayerStatsInfo[client][Level] )
        {
            /*if(count)
                Format(display, sizeof(display), "%s, Perk 1: %s", display, Perk1[i][0]);
            else
                Format(display, sizeof(display), "%s Perk 1: %s", display, Perk1[i][0]);*/
            //Format(display[count], sizeof(display[count]), "%s \nPerk 1: %s", display, Perk1[i][0]);
            Format(display[count], 128, " \nPerk 1:\x01 %s", Perk1[i][0]);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Perk2); i++)
    {
        if( StringToInt(Perk2[i][1]) == PlayerStatsInfo[client][Level] )
        {
            /*if(count)
                Format(display, sizeof(display), "%s, Perk 2: %s", display, Perk2[i][0]);
            else
                Format(display, sizeof(display), "%s Perk 2: %s", display, Perk2[i][0]);*/
            //Format(display[count], sizeof(display[count]), "%s \nPerk 2: %s", display, Perk2[i][0]);
            Format(display[count], 128, " \nPerk 2:\x01 %s", Perk2[i][0]);
            count++;
        }
    }
    for(int i = 0; i < sizeof(Perk3); i++)
    {
        if( StringToInt(Perk3[i][1]) == PlayerStatsInfo[client][Level] )
        {
            /*if(count)
                Format(display, sizeof(display), "%s, Perk 3: %s", display, Perk3[i][0]);
            else
                Format(display, sizeof(display), "%s Perk 3: %s", display, Perk3[i][0]);*/
            //Format(display[count], sizeof(display[count]), "%s \nPerk 3: %s", display, Perk3[i][0]);
            Format(display[count], 128, " \nPerk 3:\x01 %s", Perk3[i][0]);
            count++;
        }
    }

    if(count)
    {

        //Format(display, sizeof(display), "%s \n", display);
        //Format(display, sizeof(display), " \x04You have unlocked:\x01 ");
        PrintToChat(client, " \x04You have unlocked:\x01 ");
        for (int i = 0; i < count; i++)
            PrintToChat(client, display[i])
        //PrintToChat(client, display);
    }
}

int otherTeam(int client)
{
    if(GetClientTeam(client) == CS_TEAM_T)
        return CS_TEAM_CT;
    return CS_TEAM_T;
}

int hasPerk(int client, char[] target)
{
	if(StrEqual(PlayerClassInfo[client][PerkOne], target, false) || StrEqual(PlayerClassInfo[client][PerkTwo], target, false) || StrEqual(PlayerClassInfo[client][PerkThree], target, false))
		return 1;
	return 0;
}


public void StartPara(int client,bool open)
{
    float velocity[3];
    float fallspeed;
    bool isfallspeed;
    if (g_iVelocity == -1) return;
    fallspeed = 100*(-1.0);
    //GetEntDataVector(client, g_iVelocity, velocity);
    velocity[0] = 0.0;
    velocity[1] = 0.0;
    velocity[2] = -100.0;

    if(velocity[2] >= fallspeed)
    {
        isfallspeed = true;
    }
    if(velocity[2] < 0.0) 
    {
        if(isfallspeed)
        {
            velocity[2] = fallspeed;
        }
        else
        {
			velocity[2] = velocity[2] + 50;
        }
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
        SetEntDataVector(client, g_iVelocity, velocity);
        SetEntityGravity(client,0.1);
        if(open) OpenParachute(client);
    }
}

public void EndPara(int ent)
{
    if(IsValidEdict(ent) && IsValidEntity(ent)) 
    {
        //SetEntityGravity(ent, 1.0);
        CloseParachute(ent);
    }
}

void OpenParachute(int Ent)
{
    Parachute_Ent[Ent] = CreateEntityByName("prop_dynamic_override");
    DispatchKeyValue(Parachute_Ent[Ent],"model", "models/parachute/parachute_carbon.mdl");
    SetEntityMoveType(Parachute_Ent[Ent], MOVETYPE_NOCLIP);
    DispatchSpawn(Parachute_Ent[Ent]);    

    TeleportParachute(Ent);
}

void CloseParachute(int ent)
{
    if(IsValidEntity(Parachute_Ent[ent]))
    {
        RemoveEdict(Parachute_Ent[ent]);
    }
}

public void TeleportParachute(int Ent)
{
    if(IsValidEntity(Parachute_Ent[Ent]))
    {
        float Client_Origin[3];
        //decl Float:Client_Angles[3];
        //decl Float:Parachute_Angles[3] = { 0.0, 0.0, 0.0 };
        GetEntityOrigin(Ent, Client_Origin)
        Client_Origin[2] -= 40
        //GetClientAbsOrigin(Ent,Client_Origin);
        //GetClientAbsAngles(Ent,Client_Angles);
        //Parachute_Angles[1] = Client_Angles[1];
        TeleportEntity(Parachute_Ent[Ent], Client_Origin, NULL_VECTOR/*Parachute_Angles*/, NULL_VECTOR);
    }
}

public void GetEntityOrigin(int entity, float output[3])
{
    GetEntDataVector(entity, OriginOffset, output);
}

public bool TraceRayTryToHit(int entity, int mask, any data)
{
    // Check if the beam hit a player and tell it to keep tracing if it did
    if(entity == data || (entity > 0 && entity <= MaxClients))
        return false;
    return true;
}

stock void ScreenFade(int iClient, int iFlags = FFADE_PURGE, int iaColor[4] = {0, 0, 0, 0}, int iDuration = 0, int iHoldTime = 0)
{
    Handle hScreenFade = StartMessageOne("Fade", iClient);
    PbSetInt(hScreenFade, "duration", iDuration * 500);
    PbSetInt(hScreenFade, "hold_time", iHoldTime * 500);
    PbSetInt(hScreenFade, "flags", iFlags);
    PbSetColor(hScreenFade, "clr", iaColor);
    EndMessage();
}

stock bool hasEquipment(int client, char[] clientEquipment)
{
	return StrEqual(PlayerClassInfo[client][Equipment], clientEquipment, false);
}

stock bool hasTactical(int client, char[] clientTactical)
{
	return StrEqual(PlayerClassInfo[client][Tactical], clientTactical, false);
}

stock int CreateGlow(int ent) {
    int GLOW_ENTITY = CreateEntityByName("env_glow");
    float position[3];
    GetEntityOrigin(ent, position)
    SetEntProp(GLOW_ENTITY, Prop_Data, "m_nBrightness", 70, 4);

    DispatchKeyValue(GLOW_ENTITY, "model", "sprites/ledglow.vmt");

    DispatchKeyValue(GLOW_ENTITY, "rendermode", "3");
    DispatchKeyValue(GLOW_ENTITY, "renderfx", "13");
    DispatchKeyValue(GLOW_ENTITY, "scale", "0.1");
    DispatchKeyValue(GLOW_ENTITY, "renderamt", "255");
    DispatchKeyValue(GLOW_ENTITY, "rendercolor", "255 0 0 255");
    DispatchSpawn(GLOW_ENTITY);
    AcceptEntityInput(GLOW_ENTITY, "ShowSprite");
    TeleportEntity(GLOW_ENTITY, position, NULL_VECTOR, NULL_VECTOR);

    char target[20];
    FormatEx(target, sizeof(target), "glowclient_%d", ent);
    DispatchKeyValue(ent, "targetname", target);
    SetVariantString(target);
    AcceptEntityInput(GLOW_ENTITY, "SetParent");
    AcceptEntityInput(GLOW_ENTITY, "TurnOn");

    return GLOW_ENTITY
}

// TAKEN FROM GUN GAME //
void UTIL_FastSwitch(int client, int weapon, bool setActiveWeapon) {
    float GameTime = GetGameTime();

    if (setActiveWeapon) {
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
        SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime);
    }

    SetEntPropFloat(client, Prop_Send, "m_flNextAttack", GameTime);
    int ViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (ViewModel != -1) {
        SetEntProp(ViewModel, Prop_Send, "m_nSequence", 0);
    }
}


stock void SetRadar(int client, bool On)
{
	if(On)
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR_CSGO)
	else
		SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") & ~HIDE_RADAR_CSGO)
}

stock void SetPlayerAim(int client, int target)
{
    float TargetPos[3], TargetAngles[3], ClientPos[3], Result[3], Final[3];

    GetEntityOrigin(client, ClientPos);
    GetEntityOrigin(target, TargetPos);
    //GetClientEyePosition(client, ClientPos);
    //GetClientEyePosition(target, TargetPos);
    
    GetClientAbsAngles(target, TargetAngles);
    
    float vecFinal[3];
    AddInFrontOf(TargetPos, TargetAngles, 8.0, vecFinal);

    MakeVectorFromPoints(ClientPos, vecFinal, Result);
    GetVectorAngles(Result, Result);
    
    Final[0] = Result[0];
    Final[1] = Result[1];
    //Final[2] = Result[2];
    Final[2] = 0.0;

    TeleportEntity(client, NULL_VECTOR, Final, NULL_VECTOR);
}

void AddInFrontOf(float vecOrigin[3], float vecAngle[3], float units, float output[3])
{
    float vecView[3];
    GetViewVector(vecAngle, vecView);

    output[0] = vecView[0] * units + vecOrigin[0];
    output[1] = vecView[1] * units + vecOrigin[1];
    output[2] = vecView[2] * units + vecOrigin[2];
}
 
void GetViewVector(float vecAngle[3], float output[3])
{
    output[0] = Cosine(vecAngle[1] / (180 / FLOAT_PI));
    output[1] = Sine(vecAngle[1] / (180 / FLOAT_PI));
    output[2] = -Sine(vecAngle[0] / (180 / FLOAT_PI));
}

stock bool IsVisibleTo(int client, int entity)
{
    float vAngles[3], vOrigin[3], vEnt[3], vLookAt[3], TargetAngles[3];

    if(IsValidClient(client))
    {
    	GetClientEyePosition(client, vOrigin);
    }
    else
    {
    	//SetEntPropVector(client, Prop_Send, "m_angRotation", vOrigin);
    	GetEntityOrigin(client, vOrigin);
    	//vOrigin[2] += 75;
    }
    
    
    GetClientEyePosition(entity, vEnt);
    GetClientAbsAngles(entity, TargetAngles);
    
    AddInFrontOf(vEnt, TargetAngles, 8.0, vEnt);
    
    MakeVectorFromPoints(vOrigin, vEnt, vLookAt);

    GetVectorAngles(vLookAt, vAngles);

    Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_VISIBLE, RayType_Infinite, _DI_TraceFilter);

    bool isVisible = false;
    if (TR_DidHit(trace))
    {
        float vStart[3];
        TR_GetEndPosition(vStart, trace);

        if ((GetVectorDistance(vOrigin, vStart, false) + 100.0) >= GetVectorDistance(vOrigin, vEnt))
        {
            isVisible = true;
        }
    }
    else
    {
        isVisible = true;
    }
    CloseHandle(trace);
    return isVisible;
}

public bool _DI_TraceFilter(int entity, int contentsMask)
{
    if (entity > MaxClients || !IsValidEntity(entity))
    {
        return false;
    }
    
    return true;
} 


stock int CreateBulletTrace(float origin[3], float dest[3], float speed, float startwidth, float endwidth, char[] color)
{
	int entity = CreateEntityByName("env_spritetrail");
	if (entity == -1)
	{
		LogError("Couldn't create entity 'bullet_trace'");
		return -1;
	}
	DispatchKeyValue(entity, "classname", "bullet_trace");
	DispatchKeyValue(entity, "spritename", "materials/sprites/laser.vmt");
	DispatchKeyValue(entity, "renderamt", "255");
	DispatchKeyValue(entity, "rendercolor", color);
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValueFloat(entity, "startwidth", startwidth);
	DispatchKeyValueFloat(entity, "endwidth", endwidth);
	DispatchKeyValueFloat(entity, "lifetime", 240.0 / speed);
	if (!DispatchSpawn(entity))
	{
		AcceptEntityInput(entity, "Kill");
		LogError("Couldn't create entity 'bullet_trace'");
		return -1;
	}
	
	SetEntPropFloat(entity, Prop_Send, "m_flTextureRes", 0.05);
	
	float vecVeloc[3], angRotation[3];
	MakeVectorFromPoints(origin, dest, vecVeloc);
	GetVectorAngles(vecVeloc, angRotation);
	NormalizeVector(vecVeloc, vecVeloc);
	ScaleVector(vecVeloc, speed);
	
	TeleportEntity(entity, origin, angRotation, vecVeloc);
	
	char _tmp[128];
	FormatEx(_tmp, sizeof(_tmp), "OnUser1 !self:kill::%f:-1", GetVectorDistance(origin, dest) / speed);
	SetVariantString(_tmp);
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
	
	return entity;
}


int  ignoreClient;
public bool AimTargetFilter(int entity, int contentsMask)
{
    return !(entity==ignoreClient);
}
 
stock bool FindTargetInViewCone(int iViewer, int iTarget, float max_distance, float cone_angle, bool samelevel) // 180.0 could be for backstabs and stuff
{
    if(IsValidEntity(iViewer))
    {

        char Classname[32];
        Entity_GetClassName(iViewer, Classname, 32); 
        // Entity
        if(max_distance<0.0)    max_distance=0.0;
        if(cone_angle<0.0)      cone_angle=0.0;

        float PlayerEyePos[3];
        float PlayerAimAngles[3];
        float PlayerToTargetVec[3];

        float OtherPlayerPos[3];
        //GetClientEyePosition(iViewer,PlayerEyePos);
        GetEntPropVector(iViewer, Prop_Send, "m_vecOrigin", PlayerEyePos);
        PlayerEyePos[2] += 75.0;
        //GetClientEyeAngles(iViewer,PlayerAimAngles);
        GetEntPropVector(iViewer, Prop_Data, "m_angRotation", PlayerAimAngles);

        if(StrEqual(Classname, "claymore")) {
            if(PlayerAimAngles[1] >= 0.0)
                PlayerAimAngles[1] = PlayerAimAngles[1] - 180.0;
            else
                PlayerAimAngles[1] = PlayerAimAngles[1] + 180.0;
        }

        float ThisAngle;
        float playerDistance;
        float PlayerAimVector[3];

        GetAngleVectors(PlayerAimAngles,PlayerAimVector,NULL_VECTOR,NULL_VECTOR);

        //new bool:foundtarget=false;

        if(IsValidClient(iTarget) && IsPlayerAlive(iTarget) && iViewer!=iTarget)
        {
            GetClientEyePosition(iTarget,OtherPlayerPos);

            if(samelevel)
                PlayerEyePos[2] = OtherPlayerPos[2];

            playerDistance = GetVectorDistance(PlayerEyePos,OtherPlayerPos);
            if(max_distance>0.0 && playerDistance>max_distance)
            {
                return false;
            }
            SubtractVectors(OtherPlayerPos,PlayerEyePos,PlayerToTargetVec);
            ThisAngle=ArcCosine(GetVectorDotProduct(PlayerAimVector,PlayerToTargetVec)/(GetVectorLength(PlayerAimVector)*GetVectorLength(PlayerToTargetVec)));
            ThisAngle=ThisAngle*360/2/3.14159265;
            if(ThisAngle<=cone_angle)
            {
                ignoreClient=iViewer;
                TR_TraceRayFilter(PlayerEyePos,OtherPlayerPos,MASK_ALL,RayType_EndPoint,AimTargetFilter);
                if(TR_DidHit())
                {
                    int entity=TR_GetEntityIndex();
                    if(entity!=iTarget)
                    {
                        return false;
                    }
                    else
                    {
                        return true;
                    }
                    //else
                    //{
                        //foundtarget=true;
                    //}
                }
            }
        }
    }
    return false;
}  

/* Available icons 
    "icon_bulb" 
    "icon_caution" 
    "icon_alert" 
    "icon_alert_red" 
    "icon_tip" 
    "icon_skull" 
    "icon_no" 
    "icon_run" 
    "icon_interact" 
    "icon_button" 
    "icon_door" 
    "icon_arrow_plain" 
    "icon_arrow_plain_white_dn" 
    "icon_arrow_plain_white_up" 
    "icon_arrow_up" 
    "icon_arrow_right" 
    "icon_fire" 
    "icon_present" 
    "use_binding" 
*/ 

stock void DisplayInstructorHint(int iTargetEntity, float fTime, float fHeight, float fRange, bool bFollow, bool bShowOffScreen, char[] sIconOnScreen, char[] sIconOffScreen, char[] sCmd, bool bShowTextAlways, int iColor[3], char sText[100]) 
{ 
    int iEntity = CreateEntityByName("env_instructor_hint"); 
     
    if(iEntity <= 0) 
        return; 
         
    char sBuffer[32]; 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", iTargetEntity); 
     
    // Target 
    DispatchKeyValue(iTargetEntity, "targetname", sBuffer); 
    DispatchKeyValue(iEntity, "hint_target", sBuffer); 
     
    // Static 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", !bFollow); 
    DispatchKeyValue(iEntity, "hint_static", sBuffer); 
     
    // Timeout 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", RoundToFloor(fTime)); 
    DispatchKeyValue(iEntity, "hint_timeout", sBuffer); 
    if(fTime > 0.0) 
        RemoveEntity(iEntity, fTime); 
     
    // Height 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", RoundToFloor(fHeight)); 
    DispatchKeyValue(iEntity, "hint_icon_offset", sBuffer); 
     
    // Range 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", RoundToFloor(fRange)); 
    DispatchKeyValue(iEntity, "hint_range", sBuffer); 
     
    // Show off screen 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", !bShowOffScreen); 
    DispatchKeyValue(iEntity, "hint_nooffscreen", sBuffer); 
     
    // Icons 
    DispatchKeyValue(iEntity, "hint_icon_onscreen", sIconOnScreen); 
    DispatchKeyValue(iEntity, "hint_icon_onscreen", sIconOffScreen); 
     
    // Command binding 
    DispatchKeyValue(iEntity, "hint_binding", sCmd); 
     
    // Show text behind walls 
    FormatEx(sBuffer, sizeof(sBuffer), "%d", bShowTextAlways); 
    DispatchKeyValue(iEntity, "hint_forcecaption", sBuffer); 
     
    // Text color 
    FormatEx(sBuffer, sizeof(sBuffer), "%d %d %d", iColor[0], iColor[1], iColor[2]); 
    DispatchKeyValue(iEntity, "hint_color", sBuffer); 
     
    //Text 
    ReplaceString(sText, sizeof(sText), "\n", " "); 
    DispatchKeyValue(iEntity, "hint_caption", sText); 
     
    DispatchSpawn(iEntity); 
    AcceptEntityInput(iEntity, "ShowHint"); 
} 

stock void RemoveEntity(int entity, float time = 0.0) 
{ 
    if (time == 0.0) 
    { 
        if (IsValidEntity(entity)) 
        { 
            char edictname[32]; 
            GetEdictClassname(entity, edictname, 32); 

            if (!StrEqual(edictname, "player")) 
                AcceptEntityInput(entity, "kill"); 
        } 
    } 
    else if(time > 0.0) 
        CreateTimer(time, RemoveEntityTimer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE); 
} 

public Action RemoveEntityTimer(Handle Timer, any entityRef) 
{ 
    int entity = EntRefToEntIndex(entityRef); 
    if (entity != INVALID_ENT_REFERENCE) 
        RemoveEntity(entity); // RemoveEntity(...) is capable of handling references 
     
    return (Plugin_Stop); 
}  


void HudText(int client, char[] channel, char[] color, char[] fadein, char[] fadeout, char[] holdtime, char[] message, char[] x, char[] y)
{
        int ent = CreateEntityByName("game_text");
        DispatchKeyValue(ent, "channel", channel);
        DispatchKeyValue(ent, "color", color);
        DispatchKeyValue(ent, "color2", "0 0 0");
        DispatchKeyValue(ent, "effect", "0");
        DispatchKeyValue(ent, "fadein", fadein);
        DispatchKeyValue(ent, "fadeout", fadeout);
        DispatchKeyValue(ent, "fxtime", "0.25");        
        DispatchKeyValue(ent, "holdtime", holdtime);
        DispatchKeyValue(ent, "message", message);
        DispatchKeyValue(ent, "spawnflags", "0");   
        DispatchKeyValue(ent, "x", x);
        DispatchKeyValue(ent, "y", y);      
        DispatchSpawn(ent);
        SetVariantString("!activator");
        AcceptEntityInput(ent,"display",client);    
}