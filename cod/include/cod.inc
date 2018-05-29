/** Double-include prevention */
#if defined _cod_included_
  #endinput
#endif
#define _cod_included_
 
native int COD_GetLevel(int client);
native char COD_GetTitle(int client);
native void COD_GiveXP(int client, int xp);

