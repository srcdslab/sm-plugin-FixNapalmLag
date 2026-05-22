#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>

DynamicHook g_hRadiusDamage;

public Plugin myinfo =
{
	name = "Napalm Lag Fix",
	author = "GoD-Tony + BotoX",
	description = "Prevents lag when napalm is used on players",
	version = "1.0.6",
	url = "https://forums.alliedmods.net/showthread.php?t=188093"
};

public void OnPluginStart()
{
	// Gamedata.
	GameData hConfig = new GameData("fixnapalmlag.games");
	if (!hConfig)
		SetFailState("Could not find gamedata file: fixnapalmlag.games.txt");

	int offset = hConfig.GetOffset("RadiusDamage");
	if (offset == -1)
	{
		delete hConfig;
		SetFailState("Failed to find RadiusDamage offset");
	}

	delete hConfig;

	// DHooks
	g_hRadiusDamage = new DynamicHook(offset, HookType_GameRules, ReturnType_Void, ThisPointer_Ignore);
	g_hRadiusDamage.AddParam(HookParamType_ObjectPtr);		// 1 - CTakeDamageInfo &info
	g_hRadiusDamage.AddParam(HookParamType_VectorPtr);		// 2 - Vector &vecSrc
	g_hRadiusDamage.AddParam(HookParamType_Float);			// 3 - float flRadius
	g_hRadiusDamage.AddParam(HookParamType_Int);			// 4 - int iClassIgnore
	g_hRadiusDamage.AddParam(HookParamType_CBaseEntity);	// 5 - CBaseEntity *pEntityIgnore
}

public void OnMapStart()
{
	g_hRadiusDamage.HookGamerules(Hook_Pre, Hook_RadiusDamage);
}

public MRESReturn Hook_RadiusDamage(DHookParam hParams)
{
	if (hParams.IsNull(5))
		return MRES_Ignored;

	int iDmgBits = hParams.GetObjectVar(1, 60, ObjectValueType_Int);
	int iEntIgnore = hParams.Get(5);

	if (!(iDmgBits & DMG_BURN))
		return MRES_Ignored;

	// Block napalm damage if it's coming from another client.
	if (iEntIgnore >= 1 && iEntIgnore <= MaxClients)
		return MRES_Supercede;

	// Block napalm that comes from grenades
	char sEntClassName[64];
	if (GetEntityClassname(iEntIgnore, sEntClassName, sizeof(sEntClassName)))
	{
		if (!strcmp(sEntClassName, "hegrenade_projectile"))
			return MRES_Supercede;
	}

	return MRES_Ignored;
}
