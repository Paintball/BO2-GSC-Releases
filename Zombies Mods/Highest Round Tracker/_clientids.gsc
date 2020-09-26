high_round_tracker()
{
	level.HighRound = getDvarIntDefault( mapName( level.script ) + "HighRound", 1 );
	level.HighRoundPlayers = getDvar( mapName( level.script ) + "Players" );
	if ( level.HighRoundPlayers == "" )
	{
		level.HighRoundPlayers = "UnNamed Players";
	}
	for ( ;; )
	{
		level waittill ( "end_game" );
		if ( level.round_number > level.HighRound )
		{
			setDvar( mapName( level.script ) + "HighRound", level.round_number );
			setDvar( mapName( level.script ) + "Players", "" );
			level.HighRound = getDvarIntDefault(  mapName( level.script ) + "HighRound", 1 );
			players = get_players();
			for ( i = 0; i < players.size; i++ )
			{
				if ( getDvar( mapName( level.script ) + "Players" ) == "" )
				{
					setDvar( mapName( level.script ) + "Players", players[i].name );
					level.HighRoundPlayers = getDvar( mapName( level.script ) + "Players" );
				}
				else
				{
					setDvar( mapName( level.script ) + "Players", level.HighRoundPlayers + ", " + players[i].name );
					level.HighRoundPlayers = getDvar( mapName( level.script ) + "Players" );
				}
			}
			iprintln ( "New Record: ^1" + level.HighRound );
			iprintln ( "Set by: ^1" + level.HighRoundPlayers );
			logprint( "Map: " + mapName( level.script ) + " Record: " + level.HighRound + " Set by: " + level.HighRoundPlayers );
		}
	}
}

mapName( name )
{
	if( name == "zm_highrise" )
		return "DieRise";
	else if( name == "zm_buried" )
		return "Buried";
	else if( name == "zm_prison" )
		return "Motd";
	else if( name == "zm_tomb" )
		return "Origins";
	else if( name == "zm_nuked" )
		return "Nuketown";
	else if( name == "zm_transit" && level.scr_zm_map_start_location == "transit" )
		return "Transit";
	else if( name == "zm_transit" && level.scr_zm_map_start_location == "town" )
		return "Town";
}

high_round_info()
{
	wait 5;
	self iprintln ( "Highest Round for this Map: ^1" + level.HighRound );
	self iprintln ( "Record set by: ^1" + level.HighRoundPlayers );
}