public void MySQL_Init()
{

	if( SQL_CheckConfig("Cod"))
		SQL_TConnect(SQL_CallBack, "Cod");

	if( SQL_CheckConfig("Cod"))
		SQL_TConnect(SQL_CallBack2, "Cod");

}

/*
   _____             __      __  ______      _____   _______              _______    _____ 
  / ____|     /\     \ \    / / |  ____|    / ____| |__   __|     /\     |__   __|  / ____|
 | (___      /  \     \ \  / /  | |__      | (___      | |       /  \       | |    | (___  
  \___ \    / /\ \     \ \/ /   |  __|      \___ \     | |      / /\ \      | |     \___ \ 
  ____) |  / ____ \     \  /    | |____     ____) |    | |     / ____ \     | |     ____) |
 |_____/  /_/    \_\     \/     |______|   |_____/     |_|    /_/    \_\    |_|    |_____/ 
                                                                                           
                                                                                           
*/

public void SQL_CallBack(Handle owner, Handle hndl, const char[] error, any data)
{
	char Error[255];

	if ( hndl == null )
	{
		PrintToServer("Failed to connect: %s", Error)
		LogError( "%s", Error ); 
		LogError( "FAILED AT SQL_CALLBACK" ); 
	}
	hDatabase = CloneHandle(hndl);
	
	char TQuery[5000];

	Format( TQuery, sizeof( TQuery ), "CREATE TABLE IF NOT EXISTS `CodStats` ( 	`player_id` varchar(45) NOT NULL, \
																					`player_name` varchar(128) NOT NULL, \
																					`player_level` int(16) NOT NULL DEFAULT '1', \
																					`player_xp` int(16) default NULL, \
																					`player_prestige` int(16) default NULL, \
																					PRIMARY KEY (`player_id`) );" );



	SQL_TQuery( hDatabase, QueryCreateTable, TQuery);
}


public void QueryCreateTable( Handle owner, Handle hndl, char[] error, any data)
{ 
	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYCREATETABLE" ); 
		return;
	} 
}


public void SaveData(int client)
{
	char szQuery[256]; 
	
	char szKey[64];
	//GetClientAuthString( client, szKey, sizeof(szKey) );

	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, MAX_NAME_LENGTH);

	int iLength = ((strlen(sName) * 2) + 1);
	char[] sEscapedName = new char[iLength]; 
	SQL_EscapeString(hDatabase, sName, sEscapedName, iLength);

	GetClientAuthId(client, AuthId_Steam3, szKey, sizeof(szKey));

	Format( szQuery, sizeof( szQuery ), "REPLACE INTO `CodStats` (	`player_id`, \
																	`player_name`, \
																	`player_level`,\
																	`player_xp`,\
																	`player_prestige` )  \
																	VALUES ('%s', '%s', '%d', '%d', '%d');", \
																	szKey , sEscapedName, PlayerStatsInfo[client][Level],PlayerStatsInfo[client][XP], PlayerStatsInfo[client][Prestige] );
	
	SQL_TQuery( hDatabase, QuerySetData, szQuery, GetClientUserId(client));
}

public void QuerySetData( Handle owner, Handle hndl, char[] error, any data)
{ 
	data = GetClientOfUserId(data);
	if(data == 0)
		return;

	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYSETDATA" ); 
		return;
	} 
} 

public void LoadData(int client)
{
	char szQuery[ 256 ]; 
	
	char szKey[64];
	//GetClientAuthString( client, szKey, sizeof(szKey) );
	GetClientAuthId(client, AuthId_Steam3, szKey, sizeof(szKey));

	Format( szQuery, sizeof( szQuery ), "SELECT `player_level`, \
												`player_xp`, \
												`player_prestige` \
												FROM `CodStats` WHERE ( `player_id` = '%s' );", szKey );
	
	SQL_TQuery( hDatabase, QuerySelectData, szQuery, GetClientUserId(client));
}

public void QuerySelectData( Handle owner, Handle hndl, char[] error, any data)
{ 
	data = GetClientOfUserId(data);
	if(data == 0)
		return; 
		
	if ( hndl != INVALID_HANDLE )
	{
		while ( SQL_FetchRow(hndl) ) 
		{
			PlayerStatsInfo[data][Level] 			= SQL_FetchInt(hndl, 0);
			PlayerStatsInfo[data][XP] 				= SQL_FetchInt(hndl, 1);
			PlayerStatsInfo[data][Prestige] 		= SQL_FetchInt(hndl, 2);
		}
		if(PlayerStatsInfo[data][Level]==0)
			PlayerStatsInfo[data][Level] = 1
		PrintToServer("%N loaded [Level: %d][XP: %d]", data, PlayerStatsInfo[data][Level], PlayerStatsInfo[data][XP]);
	}
	else
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYSELECTDATA" ); 
		return;
	}
}

/*
   _____             __      __  ______      _____   _                    _____    _____ 
  / ____|     /\     \ \    / / |  ____|    / ____| | |          /\      / ____|  / ____|
 | (___      /  \     \ \  / /  | |__      | |      | |         /  \    | (___   | (___  
  \___ \    / /\ \     \ \/ /   |  __|     | |      | |        / /\ \    \___ \   \___ \ 
  ____) |  / ____ \     \  /    | |____    | |____  | |____   / ____ \   ____) |  ____) |
 |_____/  /_/    \_\     \/     |______|    \_____| |______| /_/    \_\ |_____/  |_____/ 
                                                                                         
                                                                                         
*/    

public void SQL_CallBack2(Handle owner, Handle hndl, const char[] error, any data)
{
	char Error[255];

	if ( hndl == null )
	{
		PrintToServer("Failed to connect: %s", Error)
		LogError( "%s", Error ); 
		LogError( "FAILED AT SQL_CALLBACK2" ); 
	}
	hDatabase2 = CloneHandle(hndl);
	
	char TQuery[5000];

	Format( TQuery, sizeof( TQuery ), "CREATE TABLE IF NOT EXISTS `CodClass` ( 	`player_id` varchar(45) NOT NULL, \
																					`player_name` varchar(128) NOT NULL, \
																					`classID` int(16) NOT NULL, \
																					`customClassName` int(16) NOT NULL, \
																					`PrimaryWep` varchar(45) DEFAULT NULL, \
																					`SecondaryWep` varchar(45) DEFAULT NULL, \
																					`Equipment` varchar(45) DEFAULT NULL, \
																					`Tactical` varchar(45) DEFAULT NULL, \
																					`PerkOne` varchar(45) DEFAULT NULL, \
																					`PerkTwo` varchar(45) DEFAULT NULL, \
																					`PerkThree` varchar(45) DEFAULT NULL, \
																					`StrikePackage` varchar(128) DEFAULT NULL, \
																					 PRIMARY KEY (`player_id`, `classID`));" );



	SQL_TQuery( hDatabase2, QueryCreateTable2, TQuery);
}


public void QueryCreateTable2( Handle owner, Handle hndl, char[] error, any data)
{ 
	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYCREATETABLE2" ); 
		return;
	} 
}


public void SaveData2(int client, int ID)
{
	char szQuery[512]; 
	
	char szKey[64];
	//GetClientAuthString( client, szKey, sizeof(szKey) );

	char sName[MAX_NAME_LENGTH];
	GetClientName(client, sName, MAX_NAME_LENGTH);
	
	int iLength = ((strlen(sName) * 2) + 1);
	char[] sEscapedName = new char[iLength]; 
	SQL_EscapeString(hDatabase2, sName, sEscapedName, iLength);

	int iLengthClass = ((strlen(PlayerCustomClassInfo[client][ID][ClassName]) * 2) + 1);
	char[] sEscapedClass = new char[iLengthClass]; 
	SQL_EscapeString(hDatabase, PlayerCustomClassInfo[client][ID][ClassName], sEscapedClass, iLengthClass);

	GetClientAuthId(client, AuthId_Steam3, szKey, sizeof(szKey));

	Format( szQuery, sizeof( szQuery ), "REPLACE INTO `CodClass` (`player_id`, \
																	`player_name`, \
																	`classID`,\
																	`customClassName`, \
																	`PrimaryWep`,\
																	`SecondaryWep`,  \
																	`Equipment`,  \
																	`Tactical`,  \
																	`PerkOne`,  \
																	`PerkTwo`,  \
																	`PerkThree`,  \
																	`StrikePackage` )  \
																	VALUES ('%s', '%s', '%d', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');", \
																	szKey , sEscapedName, \
																	ID, \
																	sEscapedClass, \
																	PlayerCustomClassInfo[client][ID][PrimaryWeapon],\
																	PlayerCustomClassInfo[client][ID][SecondaryWeapon],\
																	PlayerCustomClassInfo[client][ID][Equipment],\
																	PlayerCustomClassInfo[client][ID][Tactical],\
																	PlayerCustomClassInfo[client][ID][PerkOne],\
																	PlayerCustomClassInfo[client][ID][PerkTwo],\
																	PlayerCustomClassInfo[client][ID][PerkThree],\
																	PlayerCustomClassInfo[client][ID][StrikePackage] );
	SQL_TQuery( hDatabase2, QuerySetData2, szQuery, GetClientUserId(client))
}

public void QuerySetData2( Handle owner, Handle hndl, char[] error, any data)
{ 
	data = GetClientOfUserId(data);
	if(data == 0)
		return;

	if ( hndl == INVALID_HANDLE )
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYSETDATA2" ); 
		return;
	} 
} 

public void LoadData2(int client)
{
	char szQuery[ 512 ]; 
	
	char szKey[64];
	//GetClientAuthString( client, szKey, sizeof(szKey) );
	GetClientAuthId(client, AuthId_Steam3, szKey, sizeof(szKey));

	Format( szQuery, sizeof( szQuery ), "SELECT `classID`, \
												`customClassName`, \
												`PrimaryWep`,\
												`SecondaryWep`,  \
												`Equipment`,  \
												`Tactical`,  \
												`PerkOne`,  \
												`PerkTwo`,  \
												`PerkThree`,  \
												`StrikePackage`  \
												FROM `CodClass` WHERE ( `player_id` = '%s' );", szKey );
	
	SQL_TQuery( hDatabase2, QuerySelectData2, szQuery, GetClientUserId(client));
}

public void QuerySelectData2( Handle owner, Handle hndl, char[] error, any data)
{ 
	data = GetClientOfUserId(data)
	if(data == 0)
		return;

	if ( hndl != INVALID_HANDLE )
	{
		char loadCustomClassName[64];
		char loadPrimaryWeapon[64];
		char loadSecondaryWeapon[64];
		char loadEquipment[64];
		char loadTactical[64];
		char loadPerkOne[64];
		char loadPerkTwo[64];
		char loadPerkThree[64];
		char loadStrikePackage[128];

		while ( SQL_FetchRow(hndl) ) 
		{
			int ID = SQL_FetchInt(hndl, 0);

			SQL_FetchString(hndl, 1, loadCustomClassName, 64)

			SQL_FetchString(hndl, 2, loadPrimaryWeapon, 64)
			SQL_FetchString(hndl, 3, loadSecondaryWeapon, 64)
			SQL_FetchString(hndl, 4, loadEquipment, 64)
			SQL_FetchString(hndl, 5, loadTactical, 64)
			SQL_FetchString(hndl, 6, loadPerkOne, 64)
			SQL_FetchString(hndl, 7, loadPerkTwo, 64)
			SQL_FetchString(hndl, 8, loadPerkThree, 64)
			SQL_FetchString(hndl, 9, loadStrikePackage, 128)

			strcopy(PlayerCustomClassInfo[data][ID][ClassName], 32, loadCustomClassName);
			strcopy(PlayerCustomClassInfo[data][ID][PrimaryWeapon], 32, loadPrimaryWeapon);
			strcopy(PlayerCustomClassInfo[data][ID][SecondaryWeapon], 32, loadSecondaryWeapon);
			strcopy(PlayerCustomClassInfo[data][ID][Equipment], 32, loadEquipment);
			strcopy(PlayerCustomClassInfo[data][ID][Tactical], 32, loadTactical);
			strcopy(PlayerCustomClassInfo[data][ID][PerkOne], 32, loadPerkOne);
			strcopy(PlayerCustomClassInfo[data][ID][PerkTwo], 32, loadPerkTwo);
			strcopy(PlayerCustomClassInfo[data][ID][PerkThree], 32, loadPerkThree);
			strcopy(PlayerCustomClassInfo[data][ID][StrikePackage], 128, loadStrikePackage);

		}
	}
	else
	{
		LogError( "%s", error ); 
		LogError( "FAILED AT QUERYSELECTDATA2" ); 
		return;
	}
}