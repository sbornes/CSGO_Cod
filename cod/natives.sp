public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
   CreateNative("COD_GetLevel", Native_COD_GetLevel);
   CreateNative("COD_GetTitle", Native_COD_GetTitle);
   CreateNative("COD_GiveXP", Native_COD_GiveXP);
   return APLRes_Success;
}

public int Native_COD_GetLevel(Handle plugin, int numParams)
{
   int client = GetNativeCell(1);

   return PlayerStatsInfo[client][Level];
}

public int Native_COD_GetTitle(Handle plugin, int numParams)
{
   int client = GetNativeCell(1);

   return SetNativeString(1, Titles[PlayerStatsInfo[client][Level]], 32, true);
}

public int Native_COD_GiveXP(Handle plugin, int numParams)
{
   int client = GetNativeCell(1);
   int amount = GetNativeCell(2);
   GiveXP(client, amount);

   SaveData(client);
}

