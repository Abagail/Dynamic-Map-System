#include <a_samp>

public OnFilterScriptInit()
{
	// Place objects you want converted here.
	// Replace "CreateObject" or "CreateDynamicObject" with "ImportObject".
	
	return 1;
}

ImportObject(objectid, Float: x, Float: y, Float: z, Float: rX, Float: rY, Float: rZ)
{
	new DB: DBHandle = db_open("objects.db");
	if(DBHandle != DB:0) {
	    new query[256];
	    format(query, sizeof(query), "INSERT INTO objects (ObjectID, PosX, PosY, PosZ, PosrX, PosrY, PosrZ, Spawn) VALUES (%d, %f, %f, %f, %f, %f, %f, 1);", \
	        objectid, x, y, z, rX, rY, rZ);

		print(query);

		db_query(DBHandle, query);
	}
	else printf("Unable to connect to database(objects.db).");
}
