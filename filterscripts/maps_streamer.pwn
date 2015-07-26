#include <a_samp>
#include <streamer>
#include <sscanf2>

new DB: DbHandle;
#define MAX_MAP_OBJECTS 350
enum MapEnum
{
	mObjectID,
	mObjectModel,
	bool: mObjectActive,
	Float: mPosX,
	Float: mPosY,
	Float: mPosZ,
	Float: mrPosX,
	Float: mrPosY,
	Float: mrPosZ,
	mGroup
}

new MapData[MAX_MAP_OBJECTS][MapEnum];
public OnFilterScriptInit()
{
	DbHandle = db_open("objects.db");
	if(DbHandle != DB:0)
	{
		printf("Connected to database.");
		LoadMaps();
	}
	else printf("Unable to connect to the database.");
}

public OnFilterScriptExit()
{
	db_close(DbHandle);
	DbHandle = DB:0;
	UnloadMaps();

	return 1;
}

LoadMaps()
{
	new DBResult: db_result, query[128];
	format(query, sizeof(query), "SELECT * FROM `objects` WHERE `Spawn` = 1");

	db_result = db_query(DbHandle, query);

	if(db_num_rows(db_result)) {
		printf("[Maps]: Attempting to load %d objects from the database.", db_num_rows(db_result));
		new idx, Float: pos[3], objectid, Float: rot[3], result[64], object;
		while(idx < db_num_rows(db_result))
		{
            db_get_field_assoc(db_result, "ObjectID", result, sizeof(result)); objectid = strval(result);
            db_get_field_assoc(db_result, "PosX", result, sizeof(result)); pos[0] = floatstr(result);
            db_get_field_assoc(db_result, "PosY", result, sizeof(result)); pos[1] = floatstr(result);
            db_get_field_assoc(db_result, "PosZ", result, sizeof(result)); pos[2] = floatstr(result);
            db_get_field_assoc(db_result, "PosrX", result, sizeof(result)); rot[0] = floatstr(result);
            db_get_field_assoc(db_result, "PosrY", result, sizeof(result)); rot[1] = floatstr(result);
            db_get_field_assoc(db_result, "PosrZ", result, sizeof(result)); rot[2] = floatstr(result);
            db_get_field_assoc(db_result, "ObjectGroup", result, sizeof(result)); object = strval(result);

            MapData[idx][mObjectID] = CreateDynamicObject(objectid, pos[0], pos[1], pos[2], rot[0], rot[1], rot[2]);
            if(IsValidDynamicObject(MapData[idx][mObjectID]))
            {
                MapData[idx][mObjectActive] = true;
                MapData[idx][mPosX] = pos[0];
                MapData[idx][mPosY] = pos[1];
                MapData[idx][mPosZ] = pos[2];
                MapData[idx][mrPosX] = rot[0];
                MapData[idx][mrPosY] = rot[1];
                MapData[idx][mrPosZ] = rot[2];
				MapData[idx][mGroup] = object;
				MapData[idx][mObjectModel] = objectid;
			}
			idx++;

			db_next_row(db_result);
		}
		printf("[Maps]: %d maps loaded from the database.", idx);
	}

	return 1;
}

UnloadMaps()
{
	new count;
	for(new i; i < MAX_MAP_OBJECTS; i++)
	{
	    if(IsValidDynamicObject(MapData[i][mObjectID])) {
	        DestroyDynamicObject(MapData[i][mObjectID]);
	        MapData[i][mObjectActive] = false;
	        count++;
		}
	}

	printf("[Maps]: %d objects deleted.", count);
	db_close(DbHandle);

	return 1;
}

LoadGroupMaps(groupid)
{
	for(new i; i < MAX_MAP_OBJECTS; i++)
	{
	    if(MapData[i][mGroup] == groupid) {
	        MapData[i][mObjectID] = CreateDynamicObject(MapData[i][mObjectModel], MapData[i][mPosX], MapData[i][mPosY], MapData[i][mPosZ], MapData[i][mrPosX], MapData[i][mrPosY], MapData[i][mrPosZ]);
            if(IsValidDynamicObject(MapData[i][mObjectID]))
            {
                MapData[i][mObjectActive] = true;
			}
		}
		
		else {
			continue;
		}
	}
	
	return 1;
}

UnloadGroupMaps(groupid)
{
	for(new i; i < MAX_MAP_OBJECTS; i++)
	{
	    if(IsValidDynamicObject(MapData[i][mObjectID]) && MapData[i][mGroup] == groupid) {
	        DestroyDynamicObject(MapData[i][mObjectID]);
	        MapData[i][mObjectActive] = false;
		}
	}
	return 1;
}

public OnRconCommand(cmd[])
{
	new operation[24], integer;
	if(sscanf(cmd, "sD", operation, integer))
	{
		if(strcmp(operation, "loadall", true) == 0) {
		    UnloadMaps();
		    LoadMaps();
		}
		else if(strcmp(operation, "unloadall", true) == 0) {
		    UnloadMaps();
		}
		
		else if(strcmp(operation, "loadgroup", true) == 0) {
			UnloadGroupMaps(integer);
		    LoadGroupMaps(integer);
		}
		
		else if(strcmp(operation, "unloadgroup", true) == 0) {
		    UnloadGroupMaps(integer);
		}
	}

	return 1;
}
