#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/gametypes/_globallogic_score;
#include maps/mp/gametypes/_spawnlogic;
#include maps/mp/gametypes/_spawning;
#include maps/mp/gametypes/_gameobjects;
#include maps/mp/gametypes/_callbacksetup;
#include maps/mp/gametypes/_globallogic;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;

main() //checked matches cerberus output
{
	if ( getDvar( "mapname" ) == "mp_background" )
	{
		return;
	}
	maps/mp/gametypes/_globallogic::init();
	maps/mp/gametypes/_callbacksetup::setupcallbacks();
	maps/mp/gametypes/_globallogic::setupcallbacks();
	maps/mp/_utility::registerroundswitch( 0, 9 );
	maps/mp/_utility::registertimelimit( 0, 1440 );
	maps/mp/_utility::registerscorelimit( 0, 50000 );
	maps/mp/_utility::registerroundlimit( 0, 10 );
	maps/mp/_utility::registerroundwinlimit( 0, 10 );
	maps/mp/_utility::registernumlives( 0, 100 );
	maps/mp/gametypes/_globallogic::registerfriendlyfiredelay( level.gametype, 15, 0, 1440 );
	level.scoreroundbased = getgametypesetting( "roundscorecarry" ) == 0;
	level.teamscoreperkill = getgametypesetting( "teamScorePerKill" );
	level.teamscoreperdeath = getgametypesetting( "teamScorePerDeath" );
	level.teamscoreperheadshot = getgametypesetting( "teamScorePerHeadshot" );
	level.teambased = 1;
	level.overrideteamscore = 1;
	level.onstartgametype = ::onstartgametype;
	level.onspawnplayer = ::onspawnplayer;
	level.onspawnplayerunified = ::onspawnplayerunified;
	level.onroundendgame = ::onroundendgame;
	level.onroundswitch = ::onroundswitch;
	level.onplayerkilled = ::onPlayerKilled;
	game[ "dialog" ][ "gametype" ] = "tdm_start";
	game[ "dialog" ][ "gametype_hardcore" ] = "hctdm_start";
	game[ "dialog" ][ "offense_obj" ] = "generic_boost";
	game[ "dialog" ][ "defense_obj" ] = "generic_boost";
	setscoreboardcolumns( "score", "kills", "deaths", "kdratio", "assists" );
	
    thread setup_infected();
    //thread add_bots(); //use this to test with bots!!!
}

onstartgametype() //checked changed to match cerberus output
{
	setclientnamemode( "auto_change" );
	if ( !isDefined( game[ "switchedsides" ] ) )
	{
		game[ "switchedsides" ] = 0;
	}
	if ( game[ "switchedsides" ] )
	{
		oldattackers = game[ "attackers" ];
		olddefenders = game[ "defenders" ];
		game[ "attackers" ] = olddefenders;
		game[ "defenders" ] = oldattackers;
	}
	allowed = [];
	allowed[ 0 ] = "tdm";
	level.displayroundendtext = 0;
	maps/mp/gametypes/_gameobjects::main( allowed );
	maps/mp/gametypes/_spawning::create_map_placed_influencers();
	level.spawnmins = ( 0, 0, 0 );
	level.spawnmaxs = ( 0, 0, 0 );
	foreach ( team in level.teams )
	{
		maps/mp/_utility::setobjectivetext( team, &"OBJECTIVES_TDM" );
		maps/mp/_utility::setobjectivehinttext( team, &"OBJECTIVES_TDM_HINT" );
		if ( level.splitscreen )
		{
			maps/mp/_utility::setobjectivescoretext( team, &"OBJECTIVES_TDM" );
		}
		else
		{
			maps/mp/_utility::setobjectivescoretext( team, &"OBJECTIVES_TDM_SCORE" );
		}
		maps/mp/gametypes/_spawnlogic::addspawnpoints( team, "mp_tdm_spawn" );
		maps/mp/gametypes/_spawnlogic::placespawnpoints( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
	}
	maps/mp/gametypes/_spawning::updateallspawnpoints();
	/*
/#
	level.spawn_start = [];
	_a161 = level.teams;
	_k161 = getFirstArrayKey( _a161 );
	while ( isDefined( _k161 ) )
	{
		team = _a161[ _k161 ];
		level.spawn_start[ team ] = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( team ) );
		_k161 = getNextArrayKey( _a161, _k161 );
#/
	}
	*/
	level.mapcenter = maps/mp/gametypes/_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
	setmapcenter( level.mapcenter );
	spawnpoint = maps/mp/gametypes/_spawnlogic::getrandomintermissionpoint();
	setdemointermissionpoint( spawnpoint.origin, spawnpoint.angles );
	if ( !maps/mp/_utility::isoneround() )
	{
		level.displayroundendtext = 1;
		if ( maps/mp/_utility::isscoreroundbased() )
		{
			maps/mp/gametypes/_globallogic_score::resetteamscores();
		}
	}
}

onspawnplayerunified( question ) //checked matches cerberus output
{
	self.usingobj = undefined;
	if ( level.usestartspawns && !level.ingraceperiod && !level.playerqueuedrespawn )
	{
		level.usestartspawns = 0;
	}
	spawnteam = self.pers[ "team" ];
	if ( game[ "switchedsides" ] )
	{
		spawnteam = maps/mp/_utility::getotherteam( spawnteam );
	}
	if ( isDefined( question ) )
	{
		question = 1;
	}
	if ( !isDefined( question ) )
	{
		question = -1;
	}
	if ( isDefined( spawnteam ) )
	{
		spawnteam = spawnteam;
	}
	if ( !isDefined( spawnteam ) )
	{
		spawnteam = -1;
	}
	maps/mp/gametypes/_spawning::onspawnplayer_unified();
}

onspawnplayer( predictedspawn, question ) //minor edit to fix spawns 
{
	pixbeginevent( "TDM:onSpawnPlayer" );
	self.usingobj = undefined;
	if ( isDefined( question ) )
	{
		question = 1;
	}
	if ( isDefined( question ) )
	{
		question = -1;
	}
	spawnteam = self.pers[ "team" ];
	if ( isDefined( spawnteam ) )
	{
		spawnteam = spawnteam;
	}
	if ( !isDefined( spawnteam ) )
	{
		spawnteam = -1;
	}
	if ( level.ingraceperiod )
	{
		spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::gettdmstartspawnname( spawnteam ) );
		if ( !spawnpoints.size )
		{
			spawnpoints = maps/mp/gametypes/_spawnlogic::getspawnpointarray( maps/mp/gametypes/_spawning::getteamstartspawnname( spawnteam, "mp_sab_spawn" ) );
		}
		if ( !spawnpoints.size )
		{
			if ( game[ "switchedsides" ] )
			{
				spawnteam = maps/mp/_utility::getotherteam( spawnteam );
			}
			spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
		}
		else
		{
			spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_random( spawnpoints );
		}
	}
	else 
	{
		if ( game[ "switchedsides" ] )
		{
			spawnteam = maps/mp/_utility::getotherteam( spawnteam );
		}
		spawnpoints = maps/mp/gametypes/_spawnlogic::getteamspawnpoints( spawnteam );
		spawnpoint = maps/mp/gametypes/_spawnlogic::getspawnpoint_nearteam( spawnpoints );
	}
	if ( predictedspawn )
	{
		self predictspawnpoint( spawnpoint.origin, spawnpoint.angles );
	}
	else
	{
		self spawn( spawnpoint.origin, spawnpoint.angles, "tdm" );
	}
	pixendevent();
}

onendgame( winningteam ) //checked matches cerberus output
{
	if ( isDefined( winningteam ) && isDefined( level.teams[ winningteam ] ) )
	{
		maps/mp/gametypes/_globallogic_score::giveteamscoreforobjective( winningteam, 1 );
	}
}

onroundswitch() //checked changed to match cerberus output
{
	game[ "switchedsides" ] = !game[ "switchedsides" ];
	if ( level.roundscorecarry == 0 )
	{
		foreach ( team in level.teams )
		{
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
		}
	}
}

onroundendgame( roundwinner ) //checked changed to match cerberus output
{
	if ( level.roundscorecarry == 0 )
	{
		foreach ( team in level.teams )
		{
			[[ level._setteamscore ]]( team, game[ "roundswon" ][ team ] );
		}
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbygamestat( "roundswon" );
	}
	else
	{
		winner = maps/mp/gametypes/_globallogic::determineteamwinnerbyteamscore();
	}
	return winner;
}

onscoreclosemusic() //added parenthese to fix order of operations
{
	teamscores = [];
	while ( !level.gameended )
	{
		scorelimit = level.scorelimit;
		scorethreshold = scorelimit * 0.1;
		scorethresholdstart = abs( scorelimit - scorethreshold );
		scorelimitcheck = scorelimit - 10;
		topscore = 0;
		runnerupscore = 0;
		foreach ( team in level.teams )
		{
			score = [[ level._getteamscore ]]( team );
			if ( score > topscore )
			{
				runnerupscore = topscore;
				topscore = score;
			}
			if ( score > runnerupscore )
			{
				runnerupscore = score;
			}
		}
		scoredif = topscore - runnerupscore;
		if ( ( scoredif <= scorethreshold ) && ( scorethresholdstart <= topscore ) )
		{
			thread maps/mp/gametypes/_globallogic_audio::set_music_on_team( "TIME_OUT", "both" );
			thread maps/mp/gametypes/_globallogic_audio::actionmusicset();
			return;
		}
		wait 1;
	}
}

//infected functions//

setup_infected()
{
	level thread onPlayerConnect();
	thread do_infected_score();
	thread countdown( 10 );
	level.givecustomloadout = ::give_loadout();
	level.randy = RandomIntRange( 30, 45 );
	level.primaryWeaponList = getDvar( "survivorPrimary" );
    if( !isDefined( level.primaryWeaponList ) || level.primaryWeaponList == "" )
    {
    	setDvar( "survivorPrimary", "hk416_mp+reflex+extclip,insas_mp+extclip+rf,870mcs_mp+stalker,tar21_mp+extclip,pdw57_mp+silencer+extclip" );
    	level.primaryWeaponList = getDvar( "survivorPrimary" );
    }
	level.primaryWeaponKeys = strTok( level.primaryWeaponList, "," );
	level.survivorPrimary = RandomInt( level.primaryWeaponKeys.size );
	
	level.secondaryWeaponList = getDvar( "survivorSecondary" );
	if( !isDefined( level.secondaryWeaponList ) || level.secondaryWeaponList == "" )
    {
    	setDvar( "survivorSecondary", "fiveseven_mp+fmj+extclip,fnp45_mp+fmj+extclip" );
    	level.secondaryWeaponList = getDvar( "survivorSecondary" );
    }
	level.secondaryWeaponKeys = strTok( level.secondaryWeaponList, "," );
	level.survivorSecondary = RandomInt( level.secondaryWeaponKeys.size );
	
	level.survivorTacticalList = getDvar( "survivorTactical" );
	if( !isDefined( level.survivorTacticalList ) || level.survivorTacticalList == "" )
	{
		setDvar( "survivorTactical", "flash_grenade_mp,willy_pete_mp,proximity_grenade_mp" );
		level.survivorTacticalList = getDvar( "survivorTactical" );
	}
	level.survivorTacticalKeys = strTok( level.survivorTacticalList, "," );
	level.survivorTactical = RandomInt( level.survivorTacticalKeys.size );
	
	level.survivorGrenadeList = getDvar( "survivorGrenade" );
	if( !isDefined( level.survivorGrenadeList ) || level.survivorGrenadeList == "" )
	{
		setDvar( "survivorGrenade", "claymore_mp,bouncingbetty_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp" );
		level.survivorGrenadeList = getDvar( "survivorGrenade" );
	}
	level.survivorGrenadeKeys = strTok( level.survivorGrenadeList, "," );
	level.survivorGrenade = RandomInt( level.survivorGrenadeKeys.size );
	
	level.infectedPrimaryList = getDvar( "infectedPrimary" );
	if( !isDefined( level.infectedPrimaryList ) || level.infectedPrimaryList == "" )
	{
		setDvar( "infectedPrimary", "knife_mp" );
		level.infectedPrimaryList = getDvar( "infectedPrimary" );
	}
	level.infectedPrimaryKeys = strTok( level.infectedPrimaryList, "," );
	level.infectedPrimary = RandomInt( level.infectedPrimaryKeys.size );
	
	level.infectedSecondaryList = getDvar( "infectedSecondary" );
	if( !isDefined( level.infectedSecondaryList ) || level.infectedSecondaryList == "" )
	{
		setDvar( "infectedSecondary", "hatchet_mp" );
		level.infectedSecondaryList = getDvar( "infectedSecondary" );
	}
	level.infectedSecondaryKeys = strTok( level.infectedSecondaryList, "," );
	level.infectedSecondary = RandomInt( level.infectedSecondaryKeys.size );
	level.infectedTacInsert = getDvarIntDefault( "enableTacInsert", 1 );
	level.enable_scavenger = getDvarIntDefault( "enableScavenger", 1 );
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player maps\mp\teams\_teams::changeteam( "axis" );
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	for( ;; )
	{
		self waittill( "spawned_player" );
		if( self.pers[ "team" ] == "axis" && isDefined( self.infected ))
		{
			self maps\mp\teams\_teams::changeteam( "allies" );
		}
		else if( self.pers[ "team" ] == "allies" && !isDefined( self.infected ))
		{
			self maps\mp\teams\_teams::changeteam( "axis" );
		}
	}
}

onPlayerKilled( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked matches cerberus output
{
	self.infected = true;
	if( self.pers[ "team" ] == "axis" )
	{
		if( !isDefined( level.first_blood ) && self.name != level.firstinfected.name )
		{
			level.first_blood = 1;
			foreach( player in level.players )
			{
				if( player.pers[ "team" ] == "allies" )
				{
					player thread give_loadout();
				}
			}
		}
		self saveXUID( self getXUID() ); wait 0.2;
		self maps\mp\teams\_teams::changeteam( "allies" );
	}
}

countdown( waittime )
{
	level endon( "game_started" );
	level.custom_timelimit = getDvarIntDefault( "infectedTimelimit", 10 );
	level.firstinfected = "";
	level.infectedtable = [];
	level.count_down = waittime;
	level.waiting = 0;
	level.mins_to_add = 0;
	level waittill( "prematch_over" );
	level.disableweapondrop = 1;
	players = get_players();
	while ( players.size <= 2 )
	{
		players = get_players();
		wait 1;
		iprintlnbold( "Waiting For More Players..." );
		level.waiting++;
		if( level.waiting == 60 )
		{
			level.waiting = 1;
			level.mins_to_add++;
		}
	}
	if( level.mins_to_add > 0 )
	{
		setgametypesetting( "timelimit", ( level.custom_timelimit + level.mins_to_add ));
	}
	else
	{
		setgametypesetting( "timelimit", level.custom_timelimit );
	}
	wait 1;
	for( i = waittime; i >= 0; i-- )
	{
		iprintlnbold( "^1Choosing Infected In... " + level.count_down );
		level.count_down--;
		wait 1;
		if( level.count_down == 0 )
		{
			level.firstinfected = pickRandomPlayer();
			level.firstinfected.infected = true;
			level.firstinfected suicide();
			level.firstinfected maps\mp\teams\_teams::changeteam( "allies" );
			level.firstinfected saveXUID( level.firstinfected getXUID() );
			foreach( player in level.players )
			{
				if( player.pers[ "team" ] == "axis" )
				{
					player iprintlnbold( "^5You are NOT Infected! Stay Alive!" );
				}
			}
			level notify( "game_started" );
		}
	}
}

give_loadout()
{
	self takeallweapons();
	self ClearPerks();
	if( self.pers[ "team" ] == "allies" ) //infected team
	{
		if( !isDefined( level.first_blood ))
			self survivor_loadout();
		else
			self infected_loadout();
	}
	else
		self survivor_loadout();
	self setperk( "specialty_additionalprimaryweapon" );
    self setperk( "specialty_fallheight" );
    self setperk( "specialty_fastequipmentuse" );
    self setperk( "specialty_fastladderclimb" );
    self setperk( "specialty_fastmantle" );
    self setperk( "specialty_fastmeleerecovery" );
    self setperk( "specialty_fasttoss" );
    self setperk( "specialty_fastweaponswitch" );
    self setperk( "specialty_longersprint" );
    self setperk( "specialty_sprintrecovery" );
    self setperk( "specialty_twogrenades" );
    self setperk( "specialty_twoprimaries" );
    self setperk( "specialty_unlimitedsprint" );
    if( level.enable_scavenger && self.pers[ "team" ] == "axis" )
    	self setperk( "specialty_scavenger" );
}

survivor_loadout()
{
	if( isDefined( level.survivorPrimary ))
	{
		self giveWeapon( level.primaryWeaponKeys[ level.survivorPrimary ], 0, true( level.randy,0,0,0,0 ));
		self switchToWeapon( level.primaryWeaponKeys[ level.survivorPrimary ]);
	}
	if( isDefined( level.survivorSecondary ))
	{
		self giveWeapon( level.secondaryWeaponKeys[ level.survivorSecondary ], 0, true( level.randy,0,0,0,0 ));
	}
	if( isDefined( level.survivorGrenade ))
	{
		self giveWeapon( level.survivorGrenadeKeys[ level.survivorGrenade ]);
	}
	if( isDefined( level.survivorTactical ))
	{
		self giveWeapon( level.survivorTacticalKeys[ level.survivorTactical ]);
	}
}

infected_loadout()
{
	if( isDefined( level.infectedPrimary ))
	{
		self giveWeapon( level.infectedPrimaryKeys[ level.infectedPrimary ], 0, true( level.randy,0,0,0,0 ));
		self switchToWeapon( level.infectedPrimaryKeys[ level.infectedPrimary ] );
	}
	if( isDefined( level.infectedSecondary ))
	{
		self giveWeapon( level.infectedSecondaryKeys[ level.infectedSecondary ], 0, true( level.randy,0,0,0,0 ));
	}
	if( level.infectedTacInsert )
	{
		self giveWeapon( "tactical_insertion_mp" );
	}
}

do_infected_score()
{
	level endon( "game_ended" );
	level endon( "game_finished" );
	level waittill( "prematch_over" );
    while( true )
    {
		game[ "teamScores" ][ "allies" ] = infected_alive();
		game[ "teamScores" ][ "axis" ] = survivors_alive();
		maps/mp/gametypes/_globallogic_score::updateteamscores( "allies" );
		maps/mp/gametypes/_globallogic_score::updateteamscores( "axis" );
		if( survivors_alive() == 0 )
		{
			thread endgame( "allies", "^7The Infected Win!" );
			level notify( "game_finished" );
		}
		wait 0.2;
	}
}

checkXUID( XUID )
{
	if( IsInArray( level.infectedtable, XUID ))
	{
		self.infected = true;
	}
}

saveXUID( XUID )
{
	if( !IsInArray( level.infectedtable, XUID ))
	{
		level.infectedtable[ level.infectedtable.size ] = XUID;
	}
}

survivors_alive()
{
	playercount = 0;
	foreach( player in level.players )
	{
		if( player.pers[ "team" ] == "axis" && isAlive( player ))
		{
			playercount++;
		}
	}
	return playercount;
}

infected_alive()
{
	infectedcount = 0;
	foreach( player in level.players )
	{
		if( player.pers[ "team" ] == "allies" )
		{
			infectedcount++;
		}
	}
	return infectedcount;
}

pickRandomPlayer()
{
	randomnum = randomintrange( 0, level.players.size );
	infected = level.players[ randomnum ];

	if ( isAlive( infected ))
	{
		return infected;
	}
	else
	{
		return pickRandomPlayer();
	}
}

add_bots()
{
	players = get_players();
	while ( players.size < 1 )
	{
		players = get_players();
		wait 1;
	}
	thread spawnBot( 16 );
}

spawnBot( value )
{
	for( i = 0; i < value; i++ )
	{
		self thread maps\mp\bots\_bot::spawn_bot( "axis" );
	}
}
