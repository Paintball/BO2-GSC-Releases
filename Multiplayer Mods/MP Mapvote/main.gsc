#include maps/mp/gametypes/_globallogic_spawn;
#include maps/mp/gametypes/_spectating;
#include maps/mp/_tacticalinsertion;
#include maps/mp/_challenges;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	init_precache(); //used for mapvote
	precachestring( &"PLATFORM_PRESS_TO_SKIP" );
	precachestring( &"PLATFORM_PRESS_TO_RESPAWN" );
	precacheshader( "white" );
	level.killcam = getgametypesetting( "allowKillcam" );
	level.finalkillcam = getgametypesetting( "allowFinalKillcam" );
	initfinalkillcam();
}

//mapvote functions//

init_precache()
{
	shaders_list_str = ( "white;line_horizontal;loadscreen_mp_takeoff;loadscreen_mp_pod;loadscreen_mp_frostbite;loadscreen_mp_dig;loadscreen_mp_paintball;loadscreen_mp_castaway;loadscreen_mp_bridge;loadscreen_mp_uplink;loadscreen_mp_studio;loadscreen_mp_vertigo;loadscreen_mp_magma;loadscreen_mp_concert;loadscreen_mp_skate;loadscreen_mp_hydro;loadscreen_mp_mirage;loadscreen_mp_downhill;loadscreen_mp_nuketown_2020;loadscreen_mp_socotra;loadscreen_mp_turbine;loadscreen_mp_village;loadscreen_mp_la;loadscreen_mp_dockside;loadscreen_mp_carrier;loadscreen_mp_drone;loadscreen_mp_express;loadscreen_mp_hijacked;loadscreen_mp_meltdown;loadscreen_mp_overflow;loadscreen_mp_nightclub;loadscreen_mp_raid;loadscreen_mp_slums" );
	shaders_list = strtok( shaders_list_str, ";" );
	foreach( shader in shaders_list )
	{
		precacheShader( shader );
	}
}

start_mapvote()
{
	level.numberOfBots = 0;
	level.map_vote = [];
	level.map1_votes = 0;
	level.map2_votes = 0;
	level.map3_votes = 0;
	level.player_votes = 0;
	
	level.map_list_str = getDvar( "mapList" );
	if( level.map_list_str == "" )
		level.map_list_str = "mp_la mp_dockside mp_carrier mp_drone mp_express mp_hijacked mp_meltdown mp_overflow mp_nightclub mp_raid mp_slums mp_village mp_turbine mp_socotra mp_nuketown_2020 mp_downhill mp_mirage mp_hydro mp_skate mp_concert mp_magma mp_vertigo mp_studio mp_uplink mp_bridge mp_castaway mp_paintball mp_dig mp_frostbite mp_pod mp_takeoff";
	level.map_list = strtok( level.map_list_str, " " );
	level.gametype_list_str = getDvar( "gametypeList" );
	level.gametype_list = strtok( level.gametype_list_str, " " );
	thread start_mapvote_countdown();
	foreach( player in level.players )
	{
		if( isDefined( player.pers[ "isBot" ] )&& player.pers[ "isBot" ] )
			level.numberOfBots += 1;
		else 
			player thread player_voting_handler();
	}
}

start_mapvote_countdown()
{
	level.countdown = getDvarIntDefault( "mapVoteTime", 15 );
    level.timerText = createServerFontString( "default" , 2 );
    level.timerText setPoint( "CENTER", "CENTER", 0, 190 );
    level.timerText setValue( level.countdown );
    level.timerText.foreground = 1;
	level endon( "mapvote_ended" );
	wait 1;
	while( 1 )
	{
		playbombsound();
		level.countdown--;
		level.timerText.fontscale = 3.3;
		level.timerText setValue( level.countdown );
		level.timerText changefontscaleovertime( 0.5 );
		level.timerText.fontscale = 2;
        wait 1;
        if( level.player_votes == ( level.players.size - level.numberOfBots ))
		{
			setup_next_map();
		}
        if( level.countdown == 0 )
        {
            level notify( "voting_timedout" );
            foreach( player in level.players )
            {
            	if( !isDefined( level.map1_map ))
            		player.onscreenText setText( "^7Timer Ran Out: ^3No Votes - Choosing Random Map" );
            	else
            		player.onscreenText setText( "^3Timer Ran Out" );
            	player thread end_screen_handler();
            	level notify( "player_voted" );
            }
            setup_next_map();
        }
	}
}

player_voting_handler()
{
	self endon( "disconnect" );
	level endon( "voting_timedout" );
	self.gamemode = random_gamemode();
	self setup_map_index();
	self.background = self createrectangle( "CENTER", "CENTER", 0, 0, 505, 255, (0.05, 0.05, 0.05), "white", 1, 85 );
	self.textBackground = self createrectangle( "CENTER", "CENTER", 0, 150, 500, 40, (0, 0, 0), "line_horizontal", 1, 100 );
	self.mapImage = self createrectangle( "CENTER", "CENTER", 0, 0, 500, 250, (1, 1, 1), "loadscreen_" + level.map_list[ self.mapIndex ], 1, 100 );
	self.mapImage.foreground = 1;
	self.onscreenText = self drawText( self text_handling(), "default", 1.5, "CENTER", 343, (1, 1, 1), 1, (0, 0, 0), 3, 1 );
	self.onscreenText.foreground = 1;
	wait 1;
	while( 1 )
	{
		if( self attackbuttonpressed() )
		{
			self map_index_handler( 1 );
			wait 0.15;
		}
		if( self adsbuttonpressed() )
		{
			self map_index_handler( 0 );
			wait 0.15;
		}
		if( self jumpbuttonpressed() )
		{
			self thread vote_for_map( level.map_list[ self.mapIndex ], self.mapIndex, self.gamemode );
			break;
		}
		wait 0.05;
	}
}

vote_for_map( mapname, mapindex, gametype )
{
	level.player_votes++;
	if( !isDefined( level.map_vote[ mapname ][ gametype ] ))
	{
		level.map_vote[ mapname ][ gametype ][ "Votes" ] = 1;
		level.map_vote[ mapname ][ gametype ][ "Mapname" ] = mapname;
		level.map_vote[ mapname ][ gametype ][ "Gametype" ] = gametype;
	}
	else
	{
		level.map_vote[ mapname ][ gametype ][ "Votes" ]++;
	}
	if( !isDefined( level.map1_map ))
	{
		level.map1_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
		level.map1_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
		level.map1_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
	}
	else if( !isDefined( level.map2_map ))
	{
		level.map2_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
		level.map2_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
		level.map2_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
	}
	else if( !isDefined( level.map3_map ))
	{
		level.map3_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
		level.map3_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
		level.map3_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
	}
	else if( isTop3Map( mapname, gametype ) == 0 )
	{
		if( level.map_vote[ mapname ][ gametype ][ "Votes" ] > level.map3_votes )
		{
			level.map3_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
			level.map3_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
			level.map3_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
		}
	}
	else if( isTop3Map( mapname, gametype ) == 1 )
	{
		level.map1_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
		level.map1_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
		level.map1_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
	}
	else if( isTop3Map( mapname, gametype ) == 2 )
	{
		if( level.map_vote[ mapname ][ gametype ][ "Votes" ] > level.map1_votes )
		{
			level.map2_votes = level.map1_votes;
			level.map2_map = level.map1_map;
			level.map2_gametype = level.map1_gametype;
		
			level.map1_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
			level.map1_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
			level.map1_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
		}
		else
		{
			level.map2_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
			level.map2_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
			level.map2_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
		}
	}
	else if( isTop3Map( mapname, gametype ) == 3 )
	{
		if( level.map_vote[ mapname ][ gametype ][ "Votes" ] > level.map2_votes )
		{
			level.map3_votes = level.map2_votes;
			level.map3_map = level.map2_map;
			level.map3_gametype = level.map2_gametype;
		
			level.map2_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
			level.map2_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
			level.map2_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
		}
		else
		{
			level.map3_votes = level.map_vote[ mapname ][ gametype ][ "Votes" ];
			level.map3_map = level.map_vote[ mapname ][ gametype ][ "Mapname" ];
			level.map3_gametype = level.map_vote[ mapname ][ gametype ][ "Gametype" ];
		}
	}
	self.onscreenText setText( "Voted for ^3" + get_map_name( mapname ) + " - " + get_gametype_name( gametype ));
	self thread end_screen_handler();
	level notify( "player_voted" );
}

isTop3Map( mapname, gametype )
{
	if( level.map_vote[ mapname ][ gametype ][ "Mapname" ] == level.map1_map && level.map_vote[ mapname ][ gametype ][ "Gametype" ] == level.map1_gametype )
		return 1;
	else if( level.map_vote[ mapname ][ gametype ][ "Mapname" ] == level.map2_map && level.map_vote[ mapname ][ gametype ][ "Gametype" ] == level.map2_gametype )
		return 2;
	else if( level.map_vote[ mapname ][ gametype ][ "Mapname" ] == level.map3_map && level.map_vote[ mapname ][ gametype ][ "Gametype" ] == level.map3_gametype )
		return 3;
	else
		return 0;
}

end_screen_handler()
{
	self endon( "disconnect" );
	level endon( "mapvote_ended" );
	if( isDefined( self.end_voting ))
		return;
	self.end_voting = 1;
	self.mapImage Destroy();
	if( getDvar( "discordLink" ) != "" )
	{
		self.info_text = drawText( get_info_text(), "default", 1, ( 220 - get_info_text().size ), 315, (1, 1, 1), 1, (0, 0, 0), 3, 1 );
		self.info_text.foreground = 1;
	}
	while( 1 )
	{
		level waittill_any( "player_voted", "voting_timedout" );
		if( isDefined( level.next_map ))
		{
			break;
		}
		if( isDefined( level.map1_map ))
		{
			self.map1_image Destroy();
			self.map1_image = self createrectangle( "CENTER", "CENTER", -170, -80, 145, 75, (1, 1, 1), "loadscreen_" + level.map1_map, 1, 100 );
			self.map1_image.foreground = 1;
			if( !isDefined( self.map1_text ))
			{
				self.map1_text = drawText( get_vote_count( level.map1_map, level.map1_votes, level.map1_gametype ), "default", 1.6, -40, 100, (1, 1, 1), 1, (0, 0, 0), 3, 1 );
			}
			self.map1_text setText( get_vote_count( level.map1_map, level.map1_votes, level.map1_gametype ));
			self.map1_text.foreground = 1;
		}
		if( isDefined( level.map2_map ))
		{
			self.map2_image Destroy();
			self.map2_image = self createrectangle( "CENTER", "CENTER", -170, -80, 145, 75, (1, 1, 1), "loadscreen_" + level.map2_map, 1, 100 );
			self.map2_image.foreground = 1;
			if( !isDefined( self.map1_text ))
			{
				self.map2_text = drawText( get_vote_count( level.map2_map, level.map2_votes, level.map2_gametype ), "default", 1.6, -40, 180, (1, 1, 1), 1, (0, 0, 0), 3, 1 );
			}
			self.map2_text setText( get_vote_count( level.map2_map, level.map2_votes, level.map2_gametype ));
			self.map2_text.foreground = 1;
		}
		if( isDefined( level.map3_map ))
		{
			self.map3_image Destroy();
			self.map3_image = self createrectangle( "CENTER", "CENTER", -170, -80, 145, 75, (1, 1, 1), "loadscreen_" + level.map3_map, 1, 100 );
			self.map3_image.foreground = 1;
			if( !isDefined( self.map3_text ))
			{
				self.map3_text = drawText( get_vote_count( level.map3_map, level.map3_votes, level.map3_gametype ), "default", 1.6, -40, 260, (1, 1, 1), 1, (0, 0, 0), 3, 1 );
			}
			self.map3_text setText( get_vote_count( level.map3_map, level.map3_votes, level.map3_gametype ));
			self.map3_text.foreground = 1;
		}
	}
}

setup_map_index()
{
	self.mapIndex = randomintrange( 0, level.map_list.size );
	if( level.map_list[ self.mapIndex ] == getDvar( "mapname" ) && getDvarIntDefault( "stopSameMapVote", 0 ) == 1 )
	{
		return setup_map_index();
	}
	return;
}

map_index_handler( up )
{
	self.gamemode = random_gamemode( self.gamemode );
	if( level.map_list.size == 1 )
	{
		self.mapIndex = self.mapIndex;
		self.onscreenText setText( self text_handling() );
		return;
	}
	else if( up )
	{
		if( self.mapIndex == ( level.map_list.size - 1 ))
			self.mapIndex = 0;
		else
			self.mapIndex++;
		if( level.map_list[ self.mapIndex ] == getDvar( "mapname" ) && getDvarIntDefault( "stopSameMapVote", 0 ) == 1 )
		{
			self thread map_index_handler( 1 );
			return;
		}
	}
	else
	{
		if( self.mapIndex == 0 )
			self.mapIndex = level.map_list.size - 1;
		else
			self.mapIndex--;
		if( level.map_list[ self.mapIndex ] == getDvar( "mapname" ) && getDvarIntDefault( "stopSameMapVote", 0 ) == 1 )
		{
			self thread map_index_handler( 0 );
			return;
		}
	}
	self.mapImage Destroy();
	self.mapImage = self createrectangle( "CENTER", "CENTER", 0, 0, 500, 250, (1, 1, 1), "loadscreen_" + level.map_list[ self.mapIndex ], 1, 100 );
	self.mapImage.foreground = 1;
	self.onscreenText setText( self text_handling() );
}

setup_next_map()
{
	level.timerText Destroy();
	wait 4;
	foreach( player in level.players )
	{
		player.info_text Destroy();
		player.map1_text Destroy();
		player.map2_text Destroy();
		player.map3_text Destroy();
		player.map1_image Destroy();
		player.map2_image Destroy();
		player.map3_image Destroy();
	}
	if( level.map1_votes > level.map2_votes && level.map1_votes > level.map3_votes )
	{
		level.next_map = level.map1_map;
		level.next_gametype = level.map1_gametype;
	}
	else if( level.map2_votes > level.map1_votes && level.map2_votes > level.map3_votes )
	{
		level.next_map = level.map2_map;
		level.next_gametype = level.map2_gametype;
	}
	else if( level.map3_votes > level.map1_votes && level.map3_votes > level.map2_votes )
	{
		level.next_map = level.map3_map;
		level.next_gametype = level.map3_gametype;
	}
	else if( level.map1_votes == level.map2_votes && level.map1_votes > level.map3_votes )
	{
		if( randomintrange( 0, 1 ) == 1 )
		{
			level.next_map = level.map1_map;
			level.next_gametype = level.map1_gametype;
		}
		else
		{
			level.next_map = level.map2_map;
			level.next_gametype = level.map2_gametype;
		}
	}
	else if( level.map1_votes == level.map3_votes && level.map1_votes > level.map2_votes )
	{
		if( randomintrange( 0, 1 ) == 1 )
		{
			level.next_map = level.map1_map;
			level.next_gametype = level.map1_gametype;
		}
		else
		{
			level.next_map = level.map3_map;
			level.next_gametype = level.map3_gametype;
		}
	}
	else if( level.map2_votes == level.map3_votes && level.map2_votes > level.map1_votes )
	{
		if( randomintrange( 0, 1 ) == 1 )
		{
			level.next_map = level.map2_map;
			level.next_gametype = level.map2_gametype;
		}
		else
		{
			level.next_map = level.map3_map;
			level.next_gametype = level.map3_gametype;
		}
	}
	else if( level.map1_votes == level.map2_votes && level.map1_votes == level.map3_votes && level.map1_votes > 0 )
	{
		random_int = randomIntRange( 0, 2 );
		if( random_int == 0 )
		{
			level.next_map = level.map1_map;
			level.next_gametype = level.map1_gametype;
		}
		else if( random_int == 0 )
		{
			level.next_map = level.map2_map;
			level.next_gametype = level.map2_gametype;
		}
		else
		{
			level.next_map = level.map3_map;
			level.next_gametype = level.map3_gametype;
		}
	}
	else
	{
		level.next_map = level.map_list[ randomintrange( 0, level.map_list.size )];
		level.next_gametype = random_gamemode();
	}
	setDvar( "sv_maprotation", "exec " + level.next_gametype + ".cfg map " + level.next_map );
	foreach( player in level.players )
	{
		player.mapImage Destroy();
		player.mapImage = player createrectangle( "CENTER", "CENTER", 0, 0, 500, 250, (1, 1, 1), "loadscreen_" + level.next_map, 1, 100 );
		player.mapImage.foreground = 1;
		player.onscreenText setText( "Next Map: ^3" + get_map_name( level.next_map ) + " - " + get_gametype_name( level.next_gametype )); 
	}
	wait 3;
	foreach( player in level.players )
	{
		player.background Destroy();
		player.mapImage Destroy();
		player.map1_text Destroy();
		player.map2_text Destroy();
		player.map3_text Destroy();
		player.map1_image Destroy();
		player.map2_image Destroy();
		player.map3_image Destroy();
		player.onscreenText Destroy();
		player.textBackground Destroy();
	}
    level notify( "mapvote_ended" );
}

text_handling()
{
	if( !isDefined( self.end_voting ))
		return "[{+speed_throw}]     Press ^3[{+gostand}]^7 to Vote for ^3" + get_map_name( level.map_list[ self.mapIndex ] ) + " - " + get_gametype_name( self.gamemode ) + "     [{+attack}]";
	else if( !isDefined( level.next_map ))
		return "Voted for ^3" + get_map_name( level.map_list[ self.mapIndex ] ) + " - " + get_gametype_name( self.gamemode );
}

random_gamemode( gamemode )
{
	if( level.gametype_list.size > 0 )
	{
		i = randomintrange( 0, level.gametype_list.size );
		return level.gametype_list[ i ];
	}
	else
		return getDvar( "ui_gametype" );
}

playbombsound()
{
    foreach( player in level.players )
    	player playsound("mpl_sab_ui_suitcasebomb_timer");
}

get_vote_count( map, votecount, gametype )
{
	return "^3" + get_map_name( map ) + "\n" + get_gametype_name( gametype ) + "\n^7[ ^3" + votecount + " ^7/ ^3" + ( level.players.size - level.numberOfBots ) + " ^7]";
}

get_info_text()
{
	return getDvar( "discordLink" );
}

get_gametype_name( gametype )
{
	switch( gametype )
	{
		case "customgamemode":
			return "Custom Gamemode";
		case "conf":
			return "Kill Confirmed";
		case "ctf":
			return "Capture The Flag";
		case "dem":
			return "Demolition";
		case "dm":
			return "Free-For-All";
		case "dom":
			return "Domination";
		case "gun":
			return "Gun Game";
		case "hq":
			return "Headquarters";
		case "koth":
			return "Hardpoint";
		case "oic":
			return "One In The Chamber";
		case "oneflag":
			return "One Flag CTF";
		case "sas":
			return "Sticks & Stones";
		case "sd":
			return "Search & Destroy";
		case "shrp":
			return "Sharpshooter";
		case "tdm":
			return "Team Deathmatch";
		default:
            return "Invalid";
	}
}

get_map_name( mapname )
{
    switch( mapname ) 
    {
        case "mp_la":
		    return "Aftermath";
		case "mp_dockside":
		    return "Cargo";
		case "mp_carrier":
            return "Carrier";
		case "mp_drone":
            return "Drone";
		case "mp_express":
		    return "Express";
		case "mp_hijacked":
		    return "Hijacked";
		case "mp_meltdown":
		    return "Meltdown";
		case "mp_overflow":
		    return "Overflow";
		case "mp_nightclub":
		    return "Plaza";
		case "mp_raid":
		    return "Raid";
		case "mp_slums":
		    return "Slums";
		case "mp_village":
		    return "Standoff";
		case "mp_turbine":
		    return "Turbine";
		case "mp_socotra":
		    return "Yemen";
		case "mp_nuketown_2020":
		    return "Nuketown";
		case "mp_downhill":
		    return "Downhill";
		case "mp_mirage":
		    return "Mirage";
		case "mp_hydro":
		    return "Hydro";
		case "mp_skate":
		    return "Grind";
		case "mp_concert":
		    return "Encore";
		case "mp_magma":
		    return "Magma";
		case "mp_vertigo":
		    return "Vertigo";
	    case "mp_studio":
		    return "Studio";
		case "mp_uplink":
		    return "Uplink";
		case "mp_bridge":
		    return "Detour";
		case "mp_castaway":
		    return "Cove";
		case "mp_paintball":
		    return "Rush";
		case "mp_dig":
		    return "Dig";
		case "mp_frostbite":
		    return "Frost";
		case "mp_pod":
		    return "Pod";
		case "mp_takeoff":
		    return "Takeoff";
		default:
            return "Invalid";
    }
}

// end mapvote functions//

initfinalkillcam() 
{
	level.finalkillcamsettings = [];
	initfinalkillcamteam( "none" );
	foreach ( team in level.teams )
	{
		initfinalkillcamteam( team );
	}
	level.finalkillcam_winner = undefined;
}

initfinalkillcamteam( team ) 
{
	level.finalkillcamsettings[ team ] = spawnstruct();
	clearfinalkillcamteam( team );
}

clearfinalkillcamteam( team ) 
{
	level.finalkillcamsettings[ team ].spectatorclient = undefined;
	level.finalkillcamsettings[ team ].weapon = undefined;
	level.finalkillcamsettings[ team ].deathtime = undefined;
	level.finalkillcamsettings[ team ].deathtimeoffset = undefined;
	level.finalkillcamsettings[ team ].offsettime = undefined;
	level.finalkillcamsettings[ team ].entityindex = undefined;
	level.finalkillcamsettings[ team ].targetentityindex = undefined;
	level.finalkillcamsettings[ team ].entitystarttime = undefined;
	level.finalkillcamsettings[ team ].perks = undefined;
	level.finalkillcamsettings[ team ].killstreaks = undefined;
	level.finalkillcamsettings[ team ].attacker = undefined;
}

recordkillcamsettings( spectatorclient, targetentityindex, sweapon, deathtime, deathtimeoffset, offsettime, entityindex, entitystarttime, perks, killstreaks, attacker ) 
{
	if ( level.teambased && isDefined( attacker.team ) && isDefined( level.teams[ attacker.team ] ) )
	{
		team = attacker.team;
		level.finalkillcamsettings[ team ].spectatorclient = spectatorclient;
		level.finalkillcamsettings[ team ].weapon = sweapon;
		level.finalkillcamsettings[ team ].deathtime = deathtime;
		level.finalkillcamsettings[ team ].deathtimeoffset = deathtimeoffset;
		level.finalkillcamsettings[ team ].offsettime = offsettime;
		level.finalkillcamsettings[ team ].entityindex = entityindex;
		level.finalkillcamsettings[ team ].targetentityindex = targetentityindex;
		level.finalkillcamsettings[ team ].entitystarttime = entitystarttime;
		level.finalkillcamsettings[ team ].perks = perks;
		level.finalkillcamsettings[ team ].killstreaks = killstreaks;
		level.finalkillcamsettings[ team ].attacker = attacker;
	}
	level.finalkillcamsettings[ "none" ].spectatorclient = spectatorclient;
	level.finalkillcamsettings[ "none" ].weapon = sweapon;
	level.finalkillcamsettings[ "none" ].deathtime = deathtime;
	level.finalkillcamsettings[ "none" ].deathtimeoffset = deathtimeoffset;
	level.finalkillcamsettings[ "none" ].offsettime = offsettime;
	level.finalkillcamsettings[ "none" ].entityindex = entityindex;
	level.finalkillcamsettings[ "none" ].targetentityindex = targetentityindex;
	level.finalkillcamsettings[ "none" ].entitystarttime = entitystarttime;
	level.finalkillcamsettings[ "none" ].perks = perks;
	level.finalkillcamsettings[ "none" ].killstreaks = killstreaks;
	level.finalkillcamsettings[ "none" ].attacker = attacker;
}

erasefinalkillcam() 
{
	clearfinalkillcamteam( "none" );
	foreach ( team in level.teams )
	{
		clearfinalkillcamteam( team );
	}
	level.finalkillcam_winner = undefined;
}

finalkillcamwaiter() 
{
	if ( !isDefined( level.finalkillcam_winner ) )
	{
		return 0;
	}
	level waittill( "final_killcam_done" );
	return 1;
}

postroundfinalkillcam() 
{
	if ( is_true( level.sidebet ) )
	{
		return;
	}
	level notify( "play_final_killcam" );
	maps/mp/gametypes/_globallogic::resetoutcomeforallplayers();
	finalkillcamwaiter();
}

dofinalkillcam() 
{
	level waittill( "play_final_killcam" );
	level.infinalkillcam = 1;
	winner = "none";
	if ( isDefined( level.finalkillcam_winner ) )
	{
		winner = level.finalkillcam_winner;
	}
	if ( !isDefined( level.finalkillcamsettings[ winner ].targetentityindex ) )
	{
		level.infinalkillcam = 0;

        // this is where we do mapvote stuff?
        if(waslastround()) {
			foreach (player in level.players)
				player FreezeControls(true);
			wait .6;
        	visionsetnaked(getDvar("mapname"), 0);

    		foreach(player in level.players) {
        		player closemenu();
       			player closeingamemenu();
       			player.sessionstate = "spectator";
    			player.spectatorclient = -1;
    		}
            start_mapvote();
			level waittill( "mapvote_ended" );
			wait 2.5;
			foreach (player in level.players)
				player SetBlur(0.1, 0);
			visionsetnaked(getDvar("mapname"), 0);
		}

		level notify( "final_killcam_done" );
		return;
	}
	if ( isDefined( level.finalkillcamsettings[ winner ].attacker ) )
	{
		maps/mp/_challenges::getfinalkill( level.finalkillcamsettings[ winner ].attacker );
	}
	visionsetnaked( getDvar( "mapname" ), 0 );
	players = level.players;
	for ( index=0; index < players.size; index++ )
	{
		player = players[ index ];
		player closemenu();
		player closeingamemenu();
		player thread finalkillcam( winner );
	}
	wait 0.1;
	while ( areanyplayerswatchingthekillcam() )
	{
		wait 0.05;
	}
    // this is where we do mapvote stuff?
        // this is where we do mapvote stuff?
        if(waslastround()) {
			foreach (player in level.players)
				player FreezeControls(true);
			wait .6;
        	visionsetnaked(getDvar("mapname"), 0);

    		foreach(player in level.players) {
        		player closemenu();
       			player closeingamemenu();
       			player.sessionstate = "spectator";
    			player.spectatorclient = -1;
    		}
            start_mapvote();
			level waittill( "mapvote_ended" );
			wait 2.5;
			foreach ( player in level.players )
				player SetBlur(0.1, 0);
			visionsetnaked(getDvar("mapname"), 0);
		}
		level notify( "final_killcam_done" );
		level.infinalkillcam = 0;
}

startlastkillcam() 
{
}

areanyplayerswatchingthekillcam() 
{
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[ index ];
		if ( isDefined( player.killcam ) )
		{
			return 1;
		}
	}
	return 0;
}

killcam( attackernum, targetnum, killcamentity, killcamentityindex, killcamentitystarttime, sweapon, deathtime, deathtimeoffset, offsettime, respawn, maxtime, perks, killstreaks, attacker ) 
{
	self endon( "disconnect" );
	self endon( "spawned" );
	level endon( "game_ended" );
	if ( attackernum < 0 )
	{
		return;
	}
	postdeathdelay = ( getTime() - deathtime ) / 1000;
	predelay = postdeathdelay + deathtimeoffset;
	camtime = calckillcamtime( sweapon, killcamentitystarttime, predelay, respawn, maxtime );
	postdelay = calcpostdelay();
	killcamlength = camtime + postdelay;
	if ( isDefined( maxtime ) && killcamlength > maxtime )
	{
		if ( maxtime < 2 )
		{
			return;
		}
		if ( ( maxtime - camtime ) >= 1 )
		{
			postdelay = maxtime - camtime;
		}
		else
		{
			postdelay = 1;
			camtime = maxtime - 1;
		}
		killcamlength = camtime + postdelay;
	}
	killcamoffset = camtime + predelay;
	self notify( "begin_killcam" );
	killcamstarttime = getTime() - ( killcamoffset * 1000 );
	self.sessionstate = "spectator";
	self.spectatorclient = attackernum;
	self.killcamentity = -1;
	if ( killcamentityindex >= 0 )
	{
		self thread setkillcamentity( killcamentityindex, killcamentitystarttime - killcamstarttime - 100 );
	}
	self.killcamtargetentity = targetnum;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsettime;
	recordkillcamsettings( attackernum, targetnum, sweapon, deathtime, deathtimeoffset, offsettime, killcamentityindex, killcamentitystarttime, perks, killstreaks, attacker );
	foreach ( team in level.teams )
	{
		self allowspectateteam( team, 1 );
	}
	self allowspectateteam( "freelook", 1 );
	self allowspectateteam( "none", 1 );
	self thread endedkillcamcleanup();
	wait 0.05;
	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify( "end_killcam" );
		return;
	}
	self thread checkforabruptkillcamend();
	self.killcam = 1;
	self addkillcamskiptext( respawn );
	if ( !self issplitscreen() && level.perksenabled == 1 )
	{
		self addkillcamtimer( camtime );
		self maps/mp/gametypes/_hud_util::showperks();
	}
	self thread spawnedkillcamcleanup();
	self thread waitskipkillcambutton();
	self thread waitteamchangeendkillcam();
	self thread waitkillcamtime();
	self thread maps/mp/_tacticalinsertion::cancel_button_think();
	self waittill( "end_killcam" );
	self endkillcam( 0 );
	self.sessionstate = "dead";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

setkillcamentity( killcamentityindex, delayms ) 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	self endon( "spawned" );
	if ( delayms > 0 )
	{
		wait ( delayms / 1000 );
	}
	self.killcamentity = killcamentityindex;
}

waitkillcamtime() 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	wait ( self.killcamlength - 0.05 );
	self notify( "end_killcam" );
}

waitfinalkillcamslowdown( deathtime, starttime )  
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	secondsuntildeath = ( deathtime - starttime ) / 1000;
	deathtime = getTime() + ( secondsuntildeath * 1000 );
	waitbeforedeath = 2;
	maps/mp/_utility::setclientsysstate( "levelNotify", "fkcb" );
	wait max( 0, secondsuntildeath - waitbeforedeath );
	setslowmotion( 1, 0.25, waitbeforedeath );
	wait ( waitbeforedeath + 0.5 );
	setslowmotion( 0.25, 1, 1 );
	wait 0.5;
	maps/mp/_utility::setclientsysstate( "levelNotify", "fkce" );
}

waitskipkillcambutton() 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( self usebuttonpressed() )
	{
		wait 0.05;
	}
	while ( !self usebuttonpressed() )
	{
		wait 0.05;
	}
	self notify( "end_killcam" );
	self clientnotify( "fkce" );
}

waitteamchangeendkillcam() 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	self waittill( "changed_class" );
	endkillcam( 0 );
}

waitskipkillcamsafespawnbutton() 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( self fragbuttonpressed() )
	{
		wait 0.05;
	}
	while ( !self fragbuttonpressed() )
	{
		wait 0.05;
	}
	self.wantsafespawn = 1;
	self notify( "end_killcam" );
}

endkillcam( final ) 
{
	if ( isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext.alpha = 0;
	}
	if ( isDefined( self.kc_timer ) )
	{
		self.kc_timer.alpha = 0;
	}
	self.killcam = undefined;
	if ( !self issplitscreen() )
	{
		self hideallperks();
	}
	self thread maps/mp/gametypes/_spectating::setspectatepermissions();
}

checkforabruptkillcamend() 
{
	self endon( "disconnect" );
	self endon( "end_killcam" );
	while ( 1 )
	{
		if ( self.archivetime <= 0 )
		{
			break;
		}
		wait 0.05;
	}
	self notify( "end_killcam" );
}

spawnedkillcamcleanup()  
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	self waittill( "spawned" );
	self endkillcam( 0 );
}

spectatorkillcamcleanup( attacker ) 
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	attacker waittill( "begin_killcam", attackerkcstarttime );
	waittime = max( 0, attackerkcstarttime - self.deathtime - 50 );
	wait waittime;
	self endkillcam( 0 );
}

endedkillcamcleanup() 
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	level waittill( "game_ended" );
	self endkillcam( 0 );
}

endedfinalkillcamcleanup() 
{
	self endon( "end_killcam" );
	self endon( "disconnect" );
	level waittill( "game_ended" );
	self endkillcam( 1 );
}

cancelkillcamusebutton() 
{
	return self usebuttonpressed();
}

cancelkillcamsafespawnbutton() 
{
	return self fragbuttonpressed();
}

cancelkillcamcallback() 
{
	self.cancelkillcam = 1;
}

cancelkillcamsafespawncallback() 
{
	self.cancelkillcam = 1;
	self.wantsafespawn = 1;
}

cancelkillcamonuse() 
{
	self thread cancelkillcamonuse_specificbutton( ::cancelkillcamusebutton, ::cancelkillcamcallback );
}

cancelkillcamonuse_specificbutton( pressingbuttonfunc, finishedfunc )
{
	self endon( "death_delay_finished" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	for ( ;; )
	{
		if ( !self [[ pressingbuttonfunc ]]() )
		{
			wait 0.05;
			continue;
		}
		buttontime = 0;
		while ( self [[ pressingbuttonfunc ]]() )
		{
			buttontime += 0.05;
			wait 0.05;
		}
		if ( buttontime >= 0.5 )
		{
			continue;
		}
		buttontime = 0;
		while ( !( self [[ pressingbuttonfunc ]]() ) && buttontime < 0.5 )
		{
			buttontime += 0.05;
			wait 0.05;
		}
		if ( buttontime >= 0.5 )
		{
			continue;
		}
		else
		{
			self [[ finishedfunc ]]();
			return;
		}
		wait 0.05;
	}
}

finalkillcam( winner ) 
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	if ( waslastround() )
	{
		setmatchflag( "final_killcam", 1 );
		setmatchflag( "round_end_killcam", 0 );
	}
	else
	{
		setmatchflag( "final_killcam", 0 );
		setmatchflag( "round_end_killcam", 1 );
	}
	/*
/#
	if ( getDvarInt( "scr_force_finalkillcam" ) == 1 )
	{
		setmatchflag( "final_killcam", 1 );
		setmatchflag( "round_end_killcam", 0 );
#/
	}
	*/
	if ( level.console )
	{
		self maps/mp/gametypes/_globallogic_spawn::setthirdperson( 0 );
	}
	killcamsettings = level.finalkillcamsettings[ winner ];
	postdeathdelay = ( getTime() - killcamsettings.deathtime ) / 1000;
	predelay = postdeathdelay + killcamsettings.deathtimeoffset;
	camtime = calckillcamtime( killcamsettings.weapon, killcamsettings.entitystarttime, predelay, 0, undefined );
	postdelay = calcpostdelay();
	killcamoffset = camtime + predelay;
	killcamlength = ( camtime + postdelay ) - 0.05;
	killcamstarttime = getTime() - ( killcamoffset * 1000 );
	self notify( "begin_killcam" );
	self.sessionstate = "spectator";
	self.spectatorclient = killcamsettings.spectatorclient;
	self.killcamentity = -1;
	if ( killcamsettings.entityindex >= 0 )
	{
		self thread setkillcamentity( killcamsettings.entityindex, killcamsettings.entitystarttime - killcamstarttime - 100 );
	}
	self.killcamtargetentity = killcamsettings.targetentityindex;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = killcamsettings.offsettime;
	foreach ( team in level.teams )
	{
		self allowspectateteam( team, 1 );
	}
	self allowspectateteam( "freelook", 1 );
	self allowspectateteam( "none", 1 );
	self thread endedfinalkillcamcleanup();
	wait 0.05;
	if ( self.archivetime <= predelay )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		self notify( "end_killcam" );
		return;
	}
	self thread checkforabruptkillcamend();
	self.killcam = 1;
	if ( !self issplitscreen() )
	{
		self addkillcamtimer( camtime );
	}
	self thread waitkillcamtime();
	self thread waitfinalkillcamslowdown( level.finalkillcamsettings[ winner ].deathtime, killcamstarttime );
	self waittill( "end_killcam" );
	self endkillcam( 1 );
	setmatchflag( "final_killcam", 0 );
	setmatchflag( "round_end_killcam", 0 );
	self spawnendoffinalkillcam();
}

spawnendoffinalkillcam() 
{
	[[ level.spawnspectator ]]();
	self freezecontrols( 1 );
}

iskillcamentityweapon( sweapon ) 
{
	if ( sweapon == "planemortar_mp" )
	{
		return 1;
	}
	return 0;
}

iskillcamgrenadeweapon( sweapon ) 
{
	if ( sweapon == "frag_grenade_mp" )
	{
		return 1;
	}
	else if ( sweapon == "frag_grenade_short_mp" )
	{
		return 1;
	}
	else if ( sweapon == "sticky_grenade_mp" )
	{
		return 1;
	}
	else if ( sweapon == "tabun_gas_mp" )
	{
		return 1;
	}
	return 0;
}

calckillcamtime( sweapon, entitystarttime, predelay, respawn, maxtime )
{
	camtime = 0;
	if ( getDvar( "scr_killcam_time" ) == "" )
	{
		if ( iskillcamentityweapon( sweapon ) )
		{
			camtime = ( ( getTime() - entitystarttime ) / 1000 ) - predelay - 0.1;
		}
		else if ( !respawn )
		{
			camtime = 5;
		}
		else if ( iskillcamgrenadeweapon( sweapon ) )
		{
			camtime = 4.25;
		}
		else
		{
			camtime = 2.5;
		}
	}
	else
	{	
		camtime = getDvarFloat( "scr_killcam_time" );
	}
	if ( isDefined( maxtime ) )
	{
		if ( camtime > maxtime )
		{
			camtime = maxtime;
		}
		if ( camtime < 0.05 )
		{
			camtime = 0.05;
		}
	}
	return camtime;
}

calcpostdelay()
{
	postdelay = 0;
	if ( getDvar( "scr_killcam_posttime" ) == "" )
	{
		postdelay = 2;
	}
	else
	{
		postdelay = getDvarFloat( "scr_killcam_posttime" );
		if ( postdelay < 0.05 )
		{
			postdelay = 0.05;
		}
	}
	return postdelay;
}

addkillcamskiptext( respawn ) 
{
	if ( !isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext = newclienthudelem( self );
		self.kc_skiptext.archived = 0;
		self.kc_skiptext.x = 0;
		self.kc_skiptext.alignx = "center";
		self.kc_skiptext.aligny = "middle";
		self.kc_skiptext.horzalign = "center";
		self.kc_skiptext.vertalign = "bottom";
		self.kc_skiptext.sort = 1;
		self.kc_skiptext.font = "objective";
	}
	if ( self issplitscreen() )
	{
		self.kc_skiptext.y = -100;
		self.kc_skiptext.fontscale = 1.4;
	}
	else
	{
		self.kc_skiptext.y = -120;
		self.kc_skiptext.fontscale = 2;
	}
	if ( respawn )
	{
		self.kc_skiptext settext( &"PLATFORM_PRESS_TO_RESPAWN" );
	}
	else
	{
		self.kc_skiptext settext( &"PLATFORM_PRESS_TO_SKIP" );
	}
	self.kc_skiptext.alpha = 1;
}

addkillcamtimer( camtime ) 
{
}

initkcelements() 
{
	if ( !isDefined( self.kc_skiptext ) )
	{
		self.kc_skiptext = newclienthudelem( self );
		self.kc_skiptext.archived = 0;
		self.kc_skiptext.x = 0;
		self.kc_skiptext.alignx = "center";
		self.kc_skiptext.aligny = "top";
		self.kc_skiptext.horzalign = "center_adjustable";
		self.kc_skiptext.vertalign = "top_adjustable";
		self.kc_skiptext.sort = 1;
		self.kc_skiptext.font = "default";
		self.kc_skiptext.foreground = 1;
		self.kc_skiptext.hidewheninmenu = 1;
		if ( self issplitscreen() )
		{
			self.kc_skiptext.y = 20;
			self.kc_skiptext.fontscale = 1.2;
		}
		else
		{
			self.kc_skiptext.y = 32;
			self.kc_skiptext.fontscale = 1.8;
		}
	}
	if ( !isDefined( self.kc_othertext ) )
	{
		self.kc_othertext = newclienthudelem( self );
		self.kc_othertext.archived = 0;
		self.kc_othertext.y = 48;
		self.kc_othertext.alignx = "left";
		self.kc_othertext.aligny = "top";
		self.kc_othertext.horzalign = "center";
		self.kc_othertext.vertalign = "middle";
		self.kc_othertext.sort = 10;
		self.kc_othertext.font = "small";
		self.kc_othertext.foreground = 1;
		self.kc_othertext.hidewheninmenu = 1;
		if ( self issplitscreen() )
		{
			self.kc_othertext.x = 16;
			self.kc_othertext.fontscale = 1.2;
		}
		else
		{
			self.kc_othertext.x = 32;
			self.kc_othertext.fontscale = 1.6;
		}
	}
	if ( !isDefined( self.kc_icon ) )
	{
		self.kc_icon = newclienthudelem( self );
		self.kc_icon.archived = 0;
		self.kc_icon.x = 16;
		self.kc_icon.y = 16;
		self.kc_icon.alignx = "left";
		self.kc_icon.aligny = "top";
		self.kc_icon.horzalign = "center";
		self.kc_icon.vertalign = "middle";
		self.kc_icon.sort = 1;
		self.kc_icon.foreground = 1;
		self.kc_icon.hidewheninmenu = 1;
	}
	if ( !self issplitscreen() )
	{
		if ( !isDefined( self.kc_timer ) )
		{
			self.kc_timer = createfontstring( "hudbig", 1 );
			self.kc_timer.archived = 0;
			self.kc_timer.x = 0;
			self.kc_timer.alignx = "center";
			self.kc_timer.aligny = "middle";
			self.kc_timer.horzalign = "center_safearea";
			self.kc_timer.vertalign = "top_adjustable";
			self.kc_timer.y = 42;
			self.kc_timer.sort = 1;
			self.kc_timer.font = "hudbig";
			self.kc_timer.foreground = 1;
			self.kc_timer.color = vectorScale( ( 1, 1, 1 ), 0.85 );
			self.kc_timer.hidewheninmenu = 1;
		}
	}
}

createRectangle( align, relative, x, y, width, height, color, shader, sort, alpha, server )
{
    if( isDefined( server ))
        boxElem = newHudElem();
    else
        boxElem = newClientHudElem( self );

    boxElem.elemType = "icon";
    boxElem.color = color;
    if( !level.splitScreen )
    {
        boxElem.x = -2;
        boxElem.y = -2;
    }
    boxElem.hideWhenInMenu = true;
    boxElem.archived = false;
    boxElem.width = width;
    boxElem.height = height;
    boxElem.align = align;
    boxElem.relative = relative;
    boxElem.xOffset = 0;
    boxElem.yOffset = 0;
    boxElem.children = [];
    boxElem.sort = sort;
    boxElem.alpha = alpha;
    boxElem.shader = shader;
    boxElem setParent( level.uiParent );
    boxElem setShader( shader, width, height );
    boxElem.hidden = false;
    boxElem setPoint( align, relative, x, y );
    return boxElem;
}

drawText( text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort, server )
{
    if( isDefined( server ))
    {
    	hud = self createServerFontString( font, fontScale );
    }
    else
    {
    	hud = self createFontString( font, fontScale );
    }
    hud = self createFontString( font, fontScale );
    hud setText( text );
    hud.x = x;
    hud.y = y;
    hud.color = color;
    hud.alpha = alpha;
    hud.glowColor = glowColor;
    hud.glowAlpha = glowAlpha;
    hud.sort = sort;
    hud.alpha = alpha;
    return hud;
}
