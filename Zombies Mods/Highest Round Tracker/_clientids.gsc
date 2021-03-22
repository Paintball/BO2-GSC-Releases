high_round_tracker()
{
	thread high_round_info_giver();
	gamemode = gamemodeName( getDvar( "ui_gametype" ) );
	map = mapName( level.script );
	if( level.script == "zm_transit" && getDvar( "ui_gametype" ) == "zsurvival" )
		map = startLocationName( getDvar( "ui_zm_mapstartlocation" ) );
	//file handling//
	level.basepath = getDvar("fs_basepath") + "/" + getDvar("fs_basegame") + "/";
	path = level.basepath + "/logs/" + map + gamemode + "HighRound.txt";
	file = fopen(path, "r");
	text = fread(file);
	fclose(file);
	//end file handling//
	highroundinfo = strToK( text, ";" );
	level.HighRound = int( highroundinfo[ 0 ] );
	level.HighRoundPlayers = highroundinfo[ 1 ];
	for ( ;; )
	{
		level waittill ( "end_game" );
		if ( level.round_number > level.HighRound )
		{
			level.HighRoundPlayers = "";
			players = get_players();
			for ( i = 0; i < players.size; i++ )
			{
				if( level.HighRoundPlayers == "" )
				{
					level.HighRoundPlayers = players[i].name;
				}
				else
				{
					level.HighRoundPlayers = level.HighRoundPlayers + "," + players[i].name;
				}
			}
			foreach( player in level.players )
			{
				player tell( "New Record: ^1" + level.round_number );
				player tell( "Set by: ^1" + level.HighRoundPlayers );
			}
			log_highround_record( level.round_number + ";" + level.HighRoundPlayers );
		}
	}
}

log_highround_record( newRecord )
{
	gamemode = gamemodeName( getDvar( "ui_gametype" ) );
	map = mapName( level.script );
	if( level.script == "zm_transit" && getDvar( "ui_gametype" ) == "zsurvival" )
		map = startLocationName( getDvar( "ui_zm_mapstartlocation" ) );
	level.basepath = getDvar("fs_basepath") + "/" + getDvar("fs_basegame") + "/";
	path = level.basepath + "/logs/" + map + gamemode + "HighRound.txt";
	file = fopen( path, "w" );
	fputs( newRecord, file );
	fclose( file );
}

startLocationName( location )
{
	if( location == "cornfield" )
		return "Cornfield";
	else if( location == "diner" )
		return "Diner";
	else if( location == "farm" )
		return "Farm";
	else if( location == "power" )
		return "Power";
	else if( location == "town" )
		return "Town";
	else if( location == "transit" )
		return "BusDepot";
	else if( location == "tunnel" )
		return "Tunnel";
}

mapName( map )
{
	if( map == "zm_buried" )
		return "Buried";
	else if( map == "zm_highrise" )
		return "DieRise";
	else if( map == "zm_prison" )
		return "Motd";
	else if( map == "zm_nuked" )
		return "Nuketown";
	else if( map == "zm_tomb" )
		return "Origins";
	else if( map == "zm_transit" )
		return "Tranzit";
	return "NA";
}

gamemodeName( gamemode )
{
	if( gamemode == "zstandard" )
		return "Standard";
	else if( gamemode == "zclassic" )
		return "Classic";
	else if( gamemode == "zsurvival" )
		return "Survival";
	else if( gamemode == "zgrief" )
		return "Grief";
	else if( gamemode == "zcleansed" )
		return "Turned";
	return "NA";
}

high_round_info_giver()
{
	highroundinfo = 1;
	roundmultiplier = 5;
	level endon( "end_game" );
	while( 1 )
	{	
		level waittill( "start_of_round" );
		if( level.round_number == ( highroundinfo * roundmultiplier ))
		{
			highroundinfo++;
			foreach( player in level.players )
			{
				player tell( "High Round Record for this map: ^1" + level.HighRound );
				player tell( "Record set by: ^1" + level.HighRoundPlayers );
			}
		}
	}
}

high_round_info()
{
	wait 6;
	self tell( "High Round Record for this map: ^1" + level.HighRound );
	self tell( "Record set by: ^1" + level.HighRoundPlayers );
}
