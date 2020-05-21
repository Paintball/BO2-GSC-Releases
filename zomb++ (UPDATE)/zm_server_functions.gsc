//EVERYTHING CAN BE TOGGLED ON/OFF IN THE DEDICATED_ZM.CFG FILE
startInit()
{
	PrecacheModel("collision_geo_cylinder_32x128_standard");
	PrecacheModel("zombie_vending_jugg");
	PrecacheModel("zombie_perk_bottle_marathon");
	PrecacheModel("zombie_perk_bottle_whoswho");
	PrecacheModel("zombie_vending_nuke_on_lo");
	PrecacheModel("p6_zm_al_vending_pap_on");
	PrecacheModel("p6_anim_zm_buildable_pap");
	PrecacheModel("p6_zm_al_vending_pap_on");
	PrecacheModel("p6_zm_al_vending_jugg_on");
	PrecacheModel("p6_zm_al_vending_sleight_on");
	PrecacheModel("p6_zm_al_vending_doubletap2_on");	
	PrecacheModel("p6_zm_al_vending_ads_on");
	PrecacheModel("p6_zm_al_vending_nuke_on");
	PrecacheModel("p6_zm_al_vending_three_gun_on");
	PrecacheModel("zombie_vending_revive");
	PrecacheModel("zombie_vending_doubletap2");
	PrecacheModel("zombie_x2_icon");
	PrecacheModel("zombie_bomb");
	PrecacheModel("zombie_ammocan");
	PrecacheModel("zombie_x2_icon");
	PrecacheModel("zombie_skull");
	PrecacheShader("specialty_deadshot_zombies");
	if(isDefined(level.player_out_of_playable_area_monitor))
		level.player_out_of_playable_area_monitor = false;
	level.pers_sniper_misses = 9999; //sniper perma perk! never lose it hahahahahahahahaha
	//level.no_end_game_check = 1;
	thread gscRestart(); //JezuzLizard fix sound stuff
    thread setPlayersToSpectator(); //JezuzLizard fix sound stuff
}
initServerDvars() //credits to JezuzLizard!!! This is a huge help in making this happen
{
	level.player_starting_points = getDvarIntDefault( "playerStartingPoints", 500 );
	//sets the perk limit for all players
	level.perk_purchase_limit = getDvarIntDefault( "perkLimit", 4 );
	//sets the maximum number of zombies that can be on the map at once 32 max
	level.zombie_ai_limit = getDvarIntDefault( "zombieAiLimit", 24 );
	//sets the number of zombie bodies that can be on the map at once
	level.zombie_actor_limit = getDvarIntDefault( "zombieActorLimit", 32 );
	//enables midround hellhounds WARNING: causes permanent round pauses on maps that aren't bus depot, town or farm
	level.mixed_rounds_enabled = getDvarIntDefault( "midroundDogs", 0 );
	//disables the end game check WARNING: make sure to include a spectator respawner and auto revive function
	level.no_end_game_check = getDvarIntDefault( "noEndGameCheck", 0 );
	//sets the solo laststand pistol
	level.default_solo_laststandpistol = getDvar( "soloLaststandWeapon" );
	//the default laststand pistol
	level.default_laststandpistol = getDvar( "coopLaststandWeapon" );
	//set the starting weapon
	level.start_weapon = getDvar( "startWeaponZm" );
	//sets all zombies to this speed lower values result in walkers higher values sprinters
	level.zombie_move_speed = getDvarIntDefault( "zombieMoveSpeed", 1 );
	//locks the zombie movespeed to the above value
	level.zombieMoveSpeedLocked = getDvarIntDefault( "zombieMoveSpeedLocked", 0 );
	//sets whether there is a cap to the zombie movespeed active
	level.zombieMoveSpeedCap = getDvarIntDefault( "zombieMoveSpeedCap", 0 );
	//sets the value to the zombie movespeed cap
	level.zombieMoveSpeedCapValue = getDvarIntDefault( "zombieMoveSpeedCapValue", 1 );
	//sets the round number any value between 1-255
	level.round_number = getDvarIntDefault( "roundNumber", 1 );
	//enables the override for zombies per round
	level.overrideZombieTotalPermanently = getDvarIntDefault( "overrideZombieTotalPermanently", 0 );
	//sets the number of zombies per round to the value indicated
	level.overrideZombieTotalPermanentlyValue = getDvarIntDefault( "overrideZombieTotalPermanentlyValue", 6 );
	//enables the override for zombie health
	level.overrideZombieHealthPermanently = getDvarIntDefault( "overrideZombieHealthPermanently", 0 );
	//sets the health of zombies every round to the value indicated
	level.overrideZombieHealthPermanentlyValue = getDvarIntDefault( "overrideZombieHealthPermanentlyValue", 150 );
	//enables the health cap override so zombies health won't grow beyond the value indicated
	level.overrideZombieMaxHealth = getDvarIntDefault( "overrideZombieMaxHealth", 0 );
	//sets the maximum health zombie health will increase to 
	level.overrideZombieMaxHealthValue = getDvarIntDefault( "overrideZombieMaxHealthValue" , 150 );
	
	//disables walkers 
	level.disableWalkers = getDvarIntDefault( "disableWalkers", 0 );
	if ( level.disableWalkers )
	{
		level.speed_change_round = undefined;
	}
	//set afterlives on mob to 1 like a normal coop match and sets the prices of doors on origins to be higher
	level.disableSoloMode = getDvarIntDefault( "disableSoloMode", 0 );
	if ( level.disableSoloMode )
	{
		level.is_forever_solo_game = undefined;
	}
	//disables all drops
	level.zmPowerupsNoPowerupDrops = getDvarIntDefault( "zmPowerupsNoPowerupDrops", 0 );
	
	//Zombie_Vars:
	//The reason zombie_vars are first set to a var is because they don't reliably set when set directly to the value of a dvar
	//sets the maximum number of drops per round
	level.maxPowerupsPerRound = getDvarIntDefault( "maxPowerupsPerRound", 4 );
	level.zombie_vars["zombie_powerup_drop_max_per_round"] = level.maxPowerupsPerRound;
	//sets the powerup drop rate lower is better
	level.powerupDropRate = getDvarIntDefault( "powerupDropRate", 2000 );
	level.zombie_vars["zombie_powerup_drop_increment"] = level.powerupDropRate;
	//makes every zombie drop a powerup
	level.zombiesAlwaysDropPowerups = getDvarIntDefault( "zombiesAlwaysDropPowerups", 0 );
	level.zombie_vars[ "zombie_drop_item" ] = level.zombiesAlwaysDropPowerups;
	//increase these below vars to increase drop rate
	//points to the powerup increment to a powerup drop related to level.zombie_vars["zombie_powerup_drop_increment"]
	level.fourPlayerPowerupScore = getDvarIntDefault( "fourPlayerPowerupScore", 50 );
	level.zombie_vars[ "zombie_score_kill_4p_team" ] = level.fourPlayerPowerupScore;
	//points to the powerup increment to a powerup drop related to level.zombie_vars["zombie_powerup_drop_increment"]
	level.threePlayerPowerupScore = getDvarIntDefault( "threePlayerPowerupScore", 50 );
	level.zombie_vars[ "zombie_score_kill_3p_team" ] = level.threePlayerPowerupScore;
	//points to the powerup increment to a powerup drop related to level.zombie_vars["zombie_powerup_drop_increment"]
	level.twoPlayerPowerupScore = getDvarIntDefault( "twoPlayerPowerupScore", 50 );
	level.zombie_vars[ "zombie_score_kill_2p_team" ] = level.twoPlayerPowerupScore;
	//points to the powerup increment to a powerup drop related to level.zombie_vars["zombie_powerup_drop_increment"]
	level.onePlayerPowerupScore = getDvarIntDefault( "onePlayerPowerupScore", 50 );
	level.zombie_vars[ "zombie_score_kill_1p_team" ] = level.onePlayerPowerupScore;
	//points for melee kills to the powerup increment to a powerup drop
	level.powerupScoreMeleeKill = getDvarIntDefault( "powerupScoreMeleeKill", 80 );
	level.zombie_vars[ "zombie_score_bonus_melee" ] = level.powerupScoreMeleeKill;
	//points for headshot kills to the powerup increment to a powerup drop
	level.powerupScoreHeadshotKill = getDvarIntDefault( "powerupScoreHeadshotKill", 50 );
	level.zombie_vars[ "zombie_score_bonus_head" ] = level.powerupScoreHeadshotKill;
	//points for neck kills to the powerup increment to a powerup drop
	level.powerupScoreNeckKill = getDvarIntDefault( "powerupScoreNeckKill", 20 );
	level.zombie_vars[ "zombie_score_bonus_neck" ] = level.powerupScoreNeckKill;
	//points for torso kills to the powerup increment to a powerup drop
	level.powerupScoreTorsoKill = getDvarIntDefault( "powerupScoreTorsoKill", 10 );
	level.zombie_vars[ "zombie_score_bonus_torso" ] = level.powerupScoreTorsoKill;
	//sets the zombie spawnrate; max is 0.08 
	level.zombieSpawnRate = getDvarFloatDefault( "zombieSpawnRate", 2 );
	level.zombie_vars[ "zombie_spawn_delay" ] = level.zombieSpawnRate;
	//sets the zombie spawnrate multiplier increase
	level.zombieSpawnRateMultiplier = getDvarFloatDefault( "zombieSpawnRateMultiplier", 0.95 );
	//locks the spawnrate so it does not change throughout gameplay
	level.zombieSpawnRateLocked = getDvarIntDefault( "zombieSpawnRateLocked", 0 );
	//alters the number of zombies per round formula amount of zombies per round is roughly correlated to this value
	//ie half as many zombies per player is half as many zombies per round
	level.zombiesPerPlayer = getDvarIntDefault( "zombiesPerPlayer", 6 );
	level.zombie_vars["zombie_ai_per_player"] = level.zombiesPerPlayer;
	//sets the flat amount of hp the zombies gain per round not used after round 10
	level.zombieHealthIncreaseFlat = getDvarIntDefault( "zombieHealthIncreaseFlat", 100 );
	level.zombie_vars[ "zombie_health_increase" ] = level.zombieHealthIncreaseFlat;
	//multiplies zombie health by this value every round after round 10
	level.zombieHealthIncreaseMultiplier = getDvarFloatDefault( "zombieHealthIncreaseMultiplier", 0.1 );
	level.zombie_vars[ "zombie_health_increase_multiplier" ] = level.zombieHealthIncreaseMultiplier;
	//base zombie health before any multipliers or additions
	level.zombieHealthStart = getDvarIntDefault( "zombieHealthStart", 150 );
	level.zombie_vars[ "zombie_health_start" ] = level.zombieHealthStart;
	//time before new runners spawn on early rounds
	level.zombieNewRunnerInterval = getDvarIntDefault( "zombieNewRunnerInterval", 10 );
	level.zombie_vars[ "zombie_new_runner_interval" ] = level.zombieNewRunnerInterval;
	//determines level.zombie_move_speed on original
	level.zombieMoveSpeedMultiplier = getDvarIntDefault( "zombieMoveSpeedMultiplier", 10 );
	level.zombie_vars[ "zombie_move_speed_multiplier" ] = level.zombieMoveSpeedMultiplier;
	//determines level.zombie_move_speed on easy
	level.zombieMoveSpeedMultiplierEasy = getDvarIntDefault( "zombieMoveSpeedMultiplierEasy", 8 );
	level.zombie_vars[ "zombie_move_speed_multiplier_easy"] = level.zombieMoveSpeedMultiplierEasy;
	//affects the number of zombies per round formula
	level.zombieMaxAi = getDvarIntDefault( "zombieMaxAi", 24 );
	level.zombie_vars[ "zombie_max_ai" ] = level.zombieMaxAi;
	//affects the check for zombies that have fallen thru the map
	level.belowWorldCheck = getDvarIntDefault( "belowWorldCheck", -1000 );
	level.zombie_vars[ "below_world_check" ] = level.belowWorldCheck;
	//sets whether spectators respawn at the end of the round
	level.customSpectatorsRespawn = getDvarIntDefault( "customSpectatorsRespawn", 1 );
	level.zombie_vars[ "spectators_respawn" ] = level.customSpectatorsRespawn;
	//sets the time that the game takes during the end game intermission
	level.zombieIntermissionTime = getDvarIntDefault( "zombieIntermissionTime", 20 );
	level.zombie_vars["zombie_intermission_time"] = level.zombieIntermissionTime;
	//the time between rounds
	level.zombieBetweenRoundTime = getDvarIntDefault( "zombieBetweenRoundTime", 15 );
	level.zombie_vars["zombie_between_round_time"] = level.zombieBetweenRoundTime;
	//time before the game starts 
	level.roundStartDelay = getDvarIntDefault( "roundStartDelay", 0 );
	level.zombie_vars[ "game_start_delay" ] = level.roundStartDelay;
	//points all players lose when a player bleeds out %10 default
	level.bleedoutPointsLostAllPlayers = getDvarFloatDefault( "bleedoutPointsLostAllPlayers", 0.1 );
	level.zombie_vars[ "penalty_no_revive" ] = level.bleedoutPointsLostAllPlayers;
	//penalty to the player who died 10% of points by default
	level.bleedoutPointsLostSelf = getDvarFloatDefault( "bleedoutPointsLostSelf", 0.1 );
	level.zombie_vars[ "penalty_died" ] = level.bleedoutPointsLostSelf;
	//points players lose on down %5 by default
	level.downedPointsLostSelf = getDvarFloatDefault( "downedPointsLostSelf", 0.05 );
	level.zombie_vars[ "penalty_downed" ] = level.downedPointsLostSelf;
	//unknown
	level.playerStartingLives = getDvarIntDefault( "playerStartingLives", 1 );
	level.zombie_vars[ "starting_lives" ] = level.playerStartingLives;
	//points earned per zombie kill in a 4 player game
	level.fourPlayerScorePerZombieKill = getDvarIntDefault( "fourPlayerScorePerZombieKill", 50 );
	level.zombie_vars[ "zombie_score_kill_4player" ] = level.fourPlayerScorePerZombieKill;
	//points earned per zombie kill in a 3 player game
	level.threePlayerScorePerZombieKill = getDvarIntDefault( "threePlayerScorePerZombieKill", 50 );
	level.zombie_vars[ "zombie_score_kill_3player" ] = level.threePlayerScorePerZombieKill;
	//points earned per zombie kill in a 2 player game
	level.twoPlayerScorePerZombieKill = getDvarIntDefault( "twoPlayerScorePerZombieKill", 50 );
	level.zombie_vars[ "zombie_score_kill_2player" ] = level.twoPlayerScorePerZombieKill;
	//points earned per zombie kill in a 1 player game
	level.onePlayerScorePerZombieKill = getDvarIntDefault( "onePlayerScorePerZombieKill", 50 );
	level.zombie_vars[ "zombie_score_kill_1player" ] = level.onePlayerScorePerZombieKill;
	//points given for a normal attack
	level.pointsPerNormalAttack = getDvarIntDefault( "pointsPerNormalAttack", 10 );
	level.zombie_vars[ "zombie_score_damage_normal" ] = level.pointsPerNormalAttack;
	//points given for a light attack
	level.pointsPerLightAttack = getDvarIntDefault( "pointsPerLightAttack", 10 );
	level.zombie_vars[ "zombie_score_damage_light" ] = level.pointsPerLightAttack;
	//players turn into a zombie on death WARNING: buggy as can be and is missing assets
	level.shouldZombifyPlayer = getDvarIntDefault( "shouldZombifyPlayer", 0 );
	level.zombie_vars[ "zombify_player" ] = level.shouldZombifyPlayer;
	//points scalar for allies team
	level.alliesPointsMultiplier = getDvarIntDefault( "alliesPointsMultiplier", 1 );
	level.zombie_vars[ "allies" ][ "zombie_point_scalar" ] = level.alliesPointsMultiplier;
	//points scalar for axis team
	level.axisPointsMultiplier = getDvarIntDefault( "axisPointsMultiplier", 1 );
	level.zombie_vars[ "axis" ][ "zombie_point_scalar" ] = level.axisPointsMultiplier;
	//sets the radius of emps explosion lower this to 1 to render emps useless
	level.empPerkExplosionRadius = getDvarIntDefault( "empPerkExplosionRadius", 420 );
	level.zombie_vars[ "emp_perk_off_range" ] = level.empPerkExplosionRadius;
	//sets the duration of emps on perks set to 0 for infiinite emps
	level.empPerkOffDuration = getDvarIntDefault( "empPerkOffDuration", 90 );
	level.zombie_vars[ "emp_perk_off_time" ] = level.empPerkOffDuration;
	//riotshield health 
	level.riotshieldHitPoints = getDvarIntDefault( "riotshieldHitPoints", 2250 );
	level.zombie_vars[ "riotshield_hit_points" ] = level.riotshieldHitPoints;
	//jugg health bonus
	level.juggHealthBonus = getDvarIntDefault( "juggHealthBonus", 160 );
	level.zombie_vars[ "zombie_perk_juggernaut_health" ] = level.juggHealthBonus;	
	//perma jugg health bonus 
	level.permaJuggHealthBonus = getDvarIntDefault( "permaJuggHealthBonus", 190 );
	level.zombie_vars[ "zombie_perk_juggernaut_health_upgrade" ] = level.permaJuggHealthBonus;
	//phd min explosion damage
	level.minPhdExplosionDamage = getDvarIntDefault( "minPhdExplosionDamage", 1000 );
	level.zombie_vars[ "zombie_perk_divetonuke_min_damage" ] = level.minPhdExplosionDamage;
	//phd max explosion damage
	level.maxPhdExplosionDamage = getDvarIntDefault( "maxPhdExplosionDamage", 5000 );
	level.zombie_vars[ "zombie_perk_divetonuke_max_damage" ] = level.maxPhdExplosionDamage;
	//phd explosion radius
	level.phdDamageRadius = getDvarIntDefault( "phdDamageRadius", 300 );
	level.zombie_vars[ "zombie_perk_divetonuke_radius" ] = level.phdDamageRadius;
	//zombie counter onscreen
	level.enableZombieCounter = getDvarIntDefault( "enableZombieCounter", 1 );
	level.zombie_vars[ "enableZombieCounter" ] = level.enableZombieCounter;
	//custom bank
	level.customBankEnabled = getDvarIntDefault( "customBankEnabled", 1 );
	level.zombie_vars[ "customBankEnabled" ] = level.customBankEnabled;
	//custom bank amount
	level.customBankTotal = getDvarIntDefault( "customBankTotal", 10000 );
	level.zombie_vars[ "customBankTotal" ] = level.customBankTotal;
	//custom anti kiting
	level.antiKitingEnabled = getDvarIntDefault( "antiKitingEnabled", 0 );
	level.zombie_vars[ "antiKitingEnabled" ] = level.antiKitingEnabled;
	//anti kiting waittime (how long before zombies get auto killed)
	level.antiKitingWaittime = getDvarIntDefault( "antiKitingWaittime", 45 );
	level.zombie_vars[ "antiKitingWaittime" ] = level.antiKitingWaittime;
	//change mystery box price
	level.customMysteryBoxPriceEnabled = getDvarIntDefault( "customMysteryBoxPriceEnabled", 0 );
	level.zombie_vars[ "customMysteryBoxPriceEnabled" ] = level.customMysteryBoxPriceEnabled;
	//set mystery box price
	level.customMysteryBoxPrice = getDvarIntDefault( "customMysteryBoxPrice", 500 );
	level.zombie_vars[ "customMysteryBoxPrice" ] = level.customMysteryBoxPrice;
	//disable custom perks
	level.disableAllCustomPerks = getDvarIntDefault( "disableAllCustomPerks", 0 );
	level.zombie_vars[ "disableAllCustomPerks" ] = level.disableAllCustomPerks;
	//enable custom phdflopper
	level.enablePHDFlopper = getDvarIntDefault( "enablePHDFlopper", 1 );
	level.zombie_vars[ "enablePHDFlopper" ] = level.enablePHDFlopper;
	//enable custom staminup
	level.enableStaminUp = getDvarIntDefault( "enableStaminUp", 1 );
	level.zombie_vars[ "enableStaminUp" ] = level.enableStaminUp;
	//enable custom deadshot
	level.enableDeadshot = getDvarIntDefault( "enableDeadshot", 1 );
	level.zombie_vars[ "enableDeadshot" ] = level.enableDeadshot;
	//enable custom mule kick
	level.enableMuleKick = getDvarIntDefault( "enableMuleKick", 1 );
	level.zombie_vars[ "enableMuleKick" ] = level.enableMuleKick;
	//debug mode
	level.enableDebugMode = getDvarIntDefault( "enableDebugMode", 0 );
	level.zombie_vars[ "enableDebugMode" ] = level.enableDebugMode;
	disable_specific_powerups();
	checks();
	thread zombies_always_drop_powerups();
	thread zombies_per_round_override();
	thread zombie_health_override();
	thread zombie_health_cap_override();
	thread zombie_spawn_delay_fix();
	thread zombie_speed_fix();
	thread doTimer();
}
trackPackAPunchDrops()
{
	level endon("end_game");
	level.rounds_since_last_pack_a_punch = 0;
	for(;;)
	{
		level waittill("start_of_round");
		level.rounds_since_last_pack_a_punch_drop += 1;
		wait 0.5;
	}
}
gscRestart()
{
	level waittill( "end_game" );
	wait 15;
	map_restart( false );
}
setPlayersToSpectator()
{
	level.no_end_game_check = 1;
	wait 3;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( i == 0 )
		{
			i++;
		}
		players[ i ] setToSpectator();
		i++;
	}
	wait 5; 
	spawnAllPlayers();
}
setToSpectator()
{
    self.sessionstate = "spectator"; 
    if (isDefined(self.is_playing))
    {
        self.is_playing = false;
    }
}
spawnAllPlayers()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();
			if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			{
				thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
			}
		}
		i++;
	}
	level.no_end_game_check = 0;
}
disable_all_powerups()
{
	if ( level.zmPowerupsNoPowerupDrops )
	{
		flag_clear( "zombie_drop_powerups" );
	}
}
zombies_always_drop_powerups()
{
	if ( !level.zombiesAlwaysDropPowerups )
	{
		return;
	}
	while ( 1 )
	{
		level.zombie_vars[ "zombie_drop_item" ] = level.zombiesAlwaysDropPowerups;
		wait 0.05;
	}
}
zombies_per_round_override()
{
	if ( !level.overrideZombieTotalPermanently )
	{
		return;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		level.zombie_total = getDvarIntDefault( "overrideZombieTotalPermanentlyValue", 6 );
	}
}
zombie_health_override()
{
	if ( !level.overrideZombieHealthPermanently )
	{
		return;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		level.zombie_health = getDvarIntDefault( "overrideZombieHealthPermanentlyValue", 150 );
	}
}
zombie_health_cap_override()
{
	if ( !level.overrideZombieMaxHealth )
	{
		return;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( level.zombie_health > level.overrideZombieMaxHealthValue )
		{
			level.zombie_health = getDvarIntDefault( "overrideZombieHealthMaxHealthValue", 150 );
		}
	}
}
zombie_spawn_delay_fix()
{
	if ( level.zombieSpawnRateLocked )
	{
		return;
	}
	i = 1;
	while ( i <= level.round_number )
	{
		timer = level.zombieSpawnRate;
		if ( timer > 0.08 )
		{
			level.zombieSpawnRate = timer * level.zombieSpawnRateMultiplier;
			i++;
			continue;
		}
		else if ( timer < 0.08 )
		{
			level.zombieSpawnRate = 0.08;
			break;
		}
		i++;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( level.zombieSpawnRate > 0.08 )
		{
			level.zombieSpawnRate = level.zombieSpawnRate * level.zombieSpawnRateMultiplier;
		}
		level.zombie_vars[ "zombie_spawn_delay" ] = level.zombieSpawnRate;
	}
}
zombie_speed_fix()
{
	if ( level.zombieMoveSpeedLocked )
	{
		return;
	}
	if ( level.gamedifficulty == 0 )
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
	}
	else
	{
		level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
	}
}
zombie_speed_override()
{
	if ( !level.zombieMoveSpeedLocked )
	{
		return;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		level.zombie_move_speed = getDvarIntDefault( "zombieMoveSpeed", 1 );
	}
}
zombie_speed_cap_override()
{
	if ( !level.zombieMoveSpeedCap )
	{
		return;
	}
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( level.zombie_move_speed > level.zombieMoveSpeedCapValue )
		{
			level.zombie_move_speed = level.zombieMoveSpeedCapValue;
		}
	}
}
checks()
{
	if( level.customMysteryBoxPriceEnabled == 1) //custom mystery box price
	{
		level thread setMysteryBoxPrice();
	}
	if( level.enableZombieCounter == 1 ) //draw zombie counter
	{
		level thread drawZombiesCounter(); //credit carbonmodding
	}
	if( level.antiKitingEnabled == 1 ) //custom anti kiting credit @itscahz big brain
	{
		level thread antiKiting(); //checks if zombie count is below 3 and waits set time to all kill zombies
	}
	if ( level.mixed_rounds_enabled )
	{
		if ( level.script != "zm_transit" || is_classic() || level.scr_zm_ui_gametype == "zgrief" )
		{
			level.mixed_rounds_enabled = 0;
		}
	}

	if ( level.start_weapon == "" || level.start_weapon== "m1911_zm" )
	{
		level.start_weapon = "m1911_zm";
		if ( level.script == "zm_tomb" )
		{
			level.start_weapon = "c96_zm";
		}
	}
	if ( level.default_laststandpistol == "" || level.default_laststandpistol == "m1911_zm" )
	{
		level.default_laststandpistol = "m1911_zm";
		if ( level.script == "zm_tomb" )
		{
			level.default_laststandpistol = "c96_zm";
		}
	}
	if ( level.default_solo_laststandpistol == "" || level.default_solo_laststandpistol == "m1911_upgraded_zm" )
	{
		level.default_solo_laststandpistol = "m1911_upgraded_zm";
		if ( level.script == "zm_tomb" )
		{
			level.default_solo_laststandpistol = "c96_upgraded_zm";
		}
	}

}
disable_specific_powerups()
{
	level.powerupNames = array( "fast_feet", "unlimited_ammo", "pack_a_punch", "money_drop", "nuke", "insta_kill", "full_ammo", "double_points", "fire_sale", "free_perk", "carpenter" );
	array = level.powerupNames;
	//custom powerups and regular powerups
	level.zmPowerupsEnabled = [];
	//fast feet custom drop
	level.zmPowerupsEnabled[ "fast_feet" ] = spawnstruct();
	level.zmPowerupsEnabled[ "fast_feet" ].name = "fast_feet";
	level.zmPowerupsEnabled[ "fast_feet" ].active = getDvarIntDefault( "zmPowerupsFastFeetEnabled", 1 );
	//custom unlimited ammo drop
	level.zmPowerupsEnabled[ "unlimited_ammo" ] = spawnstruct();
	level.zmPowerupsEnabled[ "unlimited_ammo" ].name = "unlimited_ammo";
	level.zmPowerupsEnabled[ "unlimited_ammo" ].active = getDvarIntDefault( "zmPowerupsUnlimitedAmmoEnabled", 1 );
	//custom pack a punch drop
	level.zmPowerupsEnabled[ "pack_a_punch" ] = spawnstruct();
	level.zmPowerupsEnabled[ "pack_a_punch" ].name = "pack_a_punch";
	level.zmPowerupsEnabled[ "pack_a_punch" ].active = getDvarIntDefault( "zmPowerupsPackAPunchEnabled", 1 );
	//custom money drop
	level.zmPowerupsEnabled[ "money_drop" ] = spawnstruct();
	level.zmPowerupsEnabled[ "money_drop" ].name = "money_drop";
	level.zmPowerupsEnabled[ "money_drop" ].active = getDvarIntDefault( "zmPowerupsMoneyDropEnabled", 1 );
	//nuke
	level.zmPowerupsEnabled[ "nuke" ] = spawnstruct();
	level.zmPowerupsEnabled[ "nuke" ].name = "nuke";
	level.zmPowerupsEnabled[ "nuke" ].active = getDvarIntDefault( "zmPowerupsNukeEnabled", 1 );
	//remove insta kills from the drop cycle and special drops
	level.zmPowerupsEnabled[ "insta_kill" ] = spawnstruct();
	level.zmPowerupsEnabled[ "insta_kill" ].name = "insta_kill";
	level.zmPowerupsEnabled[ "insta_kill" ].active = getDvarIntDefault( "zmPowerupsInstaKillEnabled", 1 );
	//remove max ammos from the drop cycle and special drops
	level.zmPowerupsEnabled[ "full_ammo" ] = spawnstruct();
	level.zmPowerupsEnabled[ "full_ammo" ].name = "full_ammo";
	level.zmPowerupsEnabled[ "full_ammo" ].active = getDvarIntDefault( "zmPowerupsMaxAmmoEnabled", 1 );
	//remove carpenter from the drop cycle and special drops
	level.zmPowerupsEnabled[ "double_points" ] = spawnstruct();
	level.zmPowerupsEnabled[ "double_points" ].name = "double_points";
	level.zmPowerupsEnabled[ "double_points" ].active = getDvarIntDefault( "zmPowerupsDoublePointsEnabled", 1 );
	//remove fire sale from the drop cycle and special drops NOTE: fire sale isn't on all maps already this being enabled won't make it spawn
	level.zmPowerupsEnabled[ "fire_sale" ] = spawnstruct();
	level.zmPowerupsEnabled[ "fire_sale" ].name = "fire_sale";
	level.zmPowerupsEnabled[ "fire_sale" ].active = getDvarIntDefault( "zmPowerupsFireSaleEnabled", 1 );
	//remove the perk bottle from the drop cycle and special drops
	level.zmPowerupsEnabled[ "free_perk" ] = spawnstruct();
	level.zmPowerupsEnabled[ "free_perk" ].name = "free_perk";
	level.zmPowerupsEnabled[ "free_perk" ].active = getDvarIntDefault( "zmPowerupsPerkBottleEnabled", 1 );
	//removes carpenter from the drop cycle and special drops
	level.zmPowerupsEnabled[ "carpenter" ] = spawnstruct();
	level.zmPowerupsEnabled[ "carpenter" ].name = "carpenter";
	level.zmPowerupsEnabled[ "carpenter" ].active = getDvarIntDefault( "zmPowerupsCarpenterEnabled", 1 );
	//removes zombie blood from the drop cycle and special drops
	level.zmPowerupsEnabled[ "zombie_blood" ] = spawnstruct();
	level.zmPowerupsEnabled[ "zombie_blood" ].name = "zombie_blood";
	level.zmPowerupsEnabled[ "zombie_blood" ].active = getDvarIntDefault( "zmPowerupsZombieBloodEnabled", 1 );
	
	//you can expand this list with custom powerups if you'd like just add a new spawnstruct() and add to the array at the top
	
	for ( i = 0; i < array.size; i++ )
	{	
		if ( !level.zmPowerupsEnabled[ array[ i ] ].active )
		{
			name = level.zmPowerupsEnabled[ array[ i ] ].name;
			if ( isInArray( level.zombie_include_powerups, name ) )
			{
				arrayremovevalue( level.zombie_include_powerups, name );
			}
			if ( isInArray( level.zombie_powerups, name ) )
			{
				arrayremovevalue( level.zombie_powerups, name );
			}
			if ( isInArray( level.zombie_powerup_array, name ) )
			{
				arrayremovevalue( level.zombie_powerup_array, name );
			}
		}
	}
}
connectMessage( string , bold ) //connect message
{
    if ( !isDefined ( self.pers[string] ) )
    {
        self.pers[string] = true;

        if ( !isDefined ( bold ) || bold != true )
            self iPrintln ( string );
        else
            self iPrintlnBold( string ); 
    }
}
drawZombiesCounter() //credit carbonmodding, edited to use setValue instead of SetText & colors
{
    level.zombiesCounter = createServerFontString("hudsmall" , 1.9);
    level.zombiesCounter setPoint("CENTER", "CENTER", "CENTER", 190);
    level thread updateZombiesCounter();
}
updateZombiesCounter() //credit carbonmodding
{
    oldZombiesCount = get_current_zombie_count();
    while(true)
    {
        newZombiesCount = get_current_zombie_count();
        wait 0.05;
        if(oldZombiesCount != newZombiesCount)
        {
            level thread updateZombiesCounter();
            return;
        }
        else
        {
        	if(newZombiesCount != 0)
        		level.zombiesCounter.label = &"Zombies: ^1";
        	else
        		level.zombiesCounter.label = &"Zombies: ^6";
        	level.zombiesCounter setValue(newZombiesCount);
        }
    }
}
antiKiting() //credit @ItsCahz
{
	level endon("end_game");
	for(;;)
	{
		if(level.round_number >= 3 && oldZombCount <= 3)
		{
			wait level.antiKitingWaittime;
			if(get_current_zombie_count() <= 3)
			{
				enemy = getaiarray( level.zombie_team );
				foreach( zombie in enemy )
					zombie dodamage( zombie.health * 2, zombie.origin );
			}
		}
		wait 1;
	}
}
setMysteryBoxPrice() //mystery box price
{
	i = 0;
    while (i < level.chests.size)
    {
        level.chests[ i ].zombie_cost = level.customMysteryBoxPrice;
        level.chests[ i ].old_cost = level.customMysteryBoxPrice;
        i++;
    }
}
spawnIfRoundOne() //spawn player
{
	wait 3;
	if ( self.sessionstate == "spectator" && level.round_number == 1 )
		self iprintln("Get ready to be spawned!");
	wait 5;
	if ( self.sessionstate == "spectator" && level.round_number == 1 )
	{
		self [[ level.spawnplayer ]]();
		if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
	}
}
drawHealth() //credit carbonmodding, edited to use setValue instead of SetText & colors
{
    self.healthBar = createFontString("hudsmall" , 1.25);
    self.healthBar setPoint("CENTER", "CENTER", "CENTER", 173);
    self.healthBar.label = &"^1Health: ^7";
    while(true)
    {
        self.healthBar setValue(self.health);
        wait 0.1;
    }
}
startCustomBank()
{
	if( level.customBankEnabled == 1)
	{
		self.AmountInBank = level.customBankTotal;
		if( getDvar("mapname") == "zm_buried" )
			self thread CustomBank((-276, -315, 11));
		if( getDvar("mapname") == "zm_highrise" )
			self thread CustomBank((2262, 623, 1296));
		if( getDvar("mapname") == "zm_transit" )
			self thread CustomBank((587, 504, -35));
	}
}
CustomBank(origin) //custom bank
{
	self endon("disconnect");
	level endon("end_game");
	level thread LowerMessage( "Custom Perks", "Hold ^3F ^7to withdraw 1000" );
	trig = spawn("trigger_radius", (origin), 1, 25, 25);
	trig SetCursorHint( "HINT_NOICON" );
	trig setLowerMessage( trig, "Custom Perks" );
	for(;;)
	{
		trig waittill("trigger", self);
		if(self useButtonPressed())
		{
			wait .2;
			if(self useButtonPressed())
			{
				if(self.AmountInBank != 0)
				{
					self connectMessage( "You can withdraw money, but depositing will not save!"  , false );
					self iprintln( "Money Available: "+self.AmountInBank );
					self playsound( "zmb_cha_ching" ); //money shot
					self.score += 1000;
					self.score -= 100;
					self.AmountInBank -= 1000;
				}
				else
					self connectMessage( "Your Bank is Empty!"  , false );
			}
		}
	}
}
doTimer()
{
	level endon("end_game");
	level endon("timer_started");
	for(;;)
	{
		level waittill("start_of_round");
		if(level.round_number == 1 && level.players.size > 0 && !isDefined(level.timerStarted))
		{
			level.timerStarted = true;
			level thread startTimer();
			level thread notifyTimeOnEndGame();
			wait 0.1;
			level notify("timer_started");
		}
	}
}
startTimer()
{
	level.minutesPlayed = 0;
	level.hoursPlayed = 0;
	for(;;)
	{
		wait 59;
		level.minutesPlayed += 1;
		wait 1;
		if(level.minutesPlayed == 60)
		{
			level.hoursPlayed += 1;
			level.minutesPlayed = 0;
		}
	}
}
notifyTimeOnEndGame()
{
	level endon("time_displayed");
	for(;;)
	{
		level waittill("end_game");
		foreach(player in level.players)
		{
			if(level.hoursPlayed > 0)
			{
				if(level.hoursPlayed == 1)
				{
					if(level.minutesPlayed == 1)
						player iprintln("That game lasted "+level.hoursPlayed+" hour and "+level.minutesPlayed+" minute!");
					else
						player iprintln("That game lasted "+level.hoursPlayed+" hour and "+level.minutesPlayed+" minutes!");
				}
				else
				{
					if(level.minutesPlayed == 1)
						player iprintln("That game lasted "+level.hoursPlayed+" hours and "+level.minutesPlayed+" minute!");
					else
						player iprintln("That game lasted "+level.hoursPlayed+" hours and "+level.minutesPlayed+" minutes!");
				}
			}
			else
			{
				if(level.minutesPlayed == 1)
					player iprintln("That game lasted "+level.minutesPlayed+" minute!");
				else
					player iprintln("That game lasted "+level.minutesPlayed+" minutes!");
			}
		}
		wait 2;
		level notify("time_displayed");
	}
}
solo_tombstone_removal()
{
	notify( "tombstone_on" );
}
turn_tombstone_on()
{
	while ( 1 )
	{
		machine = getentarray( "vending_tombstone", "targetname" );
		machine_triggers = getentarray( "vending_tombstone", "target" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].off_model );
			i++;
		}
		level thread do_initial_power_off_callback( machine, "tombstone" );
		array_thread( machine_triggers, ::set_power_on, 0 );
		level waittill( "tombstone_on" );
		i = 0;
		while ( i < machine.size )
		{
			machine[ i ] setmodel( level.machine_assets[ "tombstone" ].on_model );
			machine[ i ] vibrate( vectorScale( ( 0, -1, 0 ), 100 ), 0,3, 0,4, 3 );
			machine[ i ] playsound( "zmb_perks_power_on" );
			machine[ i ] thread perk_fx( "tombstone_light" );
			machine[ i ] thread play_loop_on_machine();
			i++;
		}
		level notify( "specialty_scavenger_power_on" );
		array_thread( machine_triggers, ::set_power_on, 1 );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_on_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_on_callback );
		}
		level waittill( "tombstone_off" );
		if ( isDefined( level.machine_assets[ "tombstone" ].power_off_callback ) )
		{
			array_thread( machine, level.machine_assets[ "tombstone" ].power_off_callback );
		}
		array_thread( machine, ::turn_perk_off );
		players = get_players();
		_a1718 = players;
		_k1718 = getFirstArrayKey( _a1718 );
		while ( isDefined( _k1718 ) )
		{
			player = _a1718[ _k1718 ];
			player.hasperkspecialtytombstone = undefined;
			_k1718 = getNextArrayKey( _a1718, _k1718 );
		}
	}
}
perk_machine_spawn_init()
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location != "default" && location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = ( level.scr_zm_ui_gametype + "_perks_" ) + location;
	pos = [];
	if ( isDefined( level.override_perk_targetname ) )
	{
		structs = getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = getstructarray( "zm_perk_machine", "targetname" );
	}
	_a3578 = structs;
	_k3578 = getFirstArrayKey( _a3578 );
	while ( isDefined( _k3578 ) )
	{
		struct = _a3578[ _k3578 ];
		if ( isDefined( struct.script_string ) )
		{
			tokens = strtok( struct.script_string, " " );
			_a3583 = tokens;
			_k3583 = getFirstArrayKey( _a3583 );
			while ( isDefined( _k3583 ) )
			{
				token = _a3583[ _k3583 ];
				if ( token == match_string )
				{
					pos[ pos.size ] = struct;
				}
				_k3583 = getNextArrayKey( _a3583, _k3583 );
			}
		}
		else pos[ pos.size ] = struct;
		_k3578 = getNextArrayKey( _a3578, _k3578 );
	}
	if ( !isDefined( pos ) || pos.size == 0 )
	{
		return;
	}
	precachemodel( "zm_collision_perks1" );
	i = 0;
	while ( i < pos.size )
	{
		perk = pos[ i ].script_noteworthy;
		if ( isDefined( perk ) && isDefined( pos[ i ].model ) )
		{
			use_trigger = spawn( "trigger_radius_use", pos[ i ].origin + vectorScale( ( 0, -1, 0 ), 30 ), 0, 40, 70 );
			use_trigger.targetname = "zombie_vending";
			use_trigger.script_noteworthy = perk;
			use_trigger triggerignoreteam();
			perk_machine = spawn( "script_model", pos[ i ].origin );
			perk_machine.angles = pos[ i ].angles;
			perk_machine setmodel( pos[ i ].model );
			if ( isDefined( level._no_vending_machine_bump_trigs ) && level._no_vending_machine_bump_trigs )
			{
				bump_trigger = undefined;
			}
			else
			{
				bump_trigger = spawn( "trigger_radius", pos[ i ].origin, 0, 35, 64 );
				bump_trigger.script_activated = 1;
				bump_trigger.script_sound = "zmb_perks_bump_bottle";
				bump_trigger.targetname = "audio_bump_trigger";
				if ( perk != "specialty_weapupgrade" )
				{
					bump_trigger thread thread_bump_trigger();
				}
			}
			collision = spawn( "script_model", pos[ i ].origin, 1 );
			collision.angles = pos[ i ].angles;
			collision setmodel( "zm_collision_perks1" );
			collision.script_noteworthy = "clip";
			collision disconnectpaths();
			use_trigger.clip = collision;
			use_trigger.machine = perk_machine;
			use_trigger.bump = bump_trigger;
			if ( isDefined( pos[ i ].blocker_model ) )
			{
				use_trigger.blocker_model = pos[ i ].blocker_model;
			}
			if ( isDefined( pos[ i ].script_int ) )
			{
				perk_machine.script_int = pos[ i ].script_int;
			}
			if ( isDefined( pos[ i ].turn_on_notify ) )
			{
				perk_machine.turn_on_notify = pos[ i ].turn_on_notify;
			}
			if ( perk == "specialty_scavenger" || perk == "specialty_scavenger_upgrade" )
			{
				use_trigger.script_sound = "mus_perks_tombstone_jingle";
				use_trigger.script_string = "tombstone_perk";
				use_trigger.script_label = "mus_perks_tombstone_sting";
				use_trigger.target = "vending_tombstone";
				perk_machine.script_string = "tombstone_perk";
				perk_machine.targetname = "vending_tombstone";
				if ( isDefined( bump_trigger ) )
				{
					bump_trigger.script_string = "tombstone_perk";
				}
			}
			if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].perk_machine_set_kvps ) )
			{
				[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( use_trigger, perk_machine, bump_trigger, collision );
			}
		}
		i++;
	}
}
isTown()
{
	if (isDefined(level.zombiemode_using_tombstone_perk) && level.zombiemode_using_tombstone_perk)
	{
		level thread perk_machine_spawn_init();
		thread solo_tombstone_removal();
		thread turn_tombstone_on();
	}
}


