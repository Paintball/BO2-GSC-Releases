#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;

init()
{
	level.player_out_of_playable_area_monitor = 0;
	level.perk_purchase_limit = 9;
	thread gscRestart();
	thread setPlayersToSpectator();
	level thread onplayerconnected();
	level thread openAllDoors();
	level thread turnOnPower();
	level thread zombies_override();
	setDvar( "scr_screecher_ignore_player", 1 );
}

onplayerconnected()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		player thread [[ level.givecustomcharacters ]]();
		player [[ level.spawnplayer ]]();
	}
}

onplayerspawned()
{
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread getAllPerks();
	}
}

gscRestart()
{
	level waittill( "end_game" );
	setDvar( "customMapsMapRestarted", 1 );
	wait 10;
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
	level.no_end_game_check = 0;
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

openAllDoors()
{
	if(!isDefined(level.varsArray["doors"]))
	{
		level.varsArray["doors"]=true;
		setdvar("zombie_unlock_all",1);
		wait .05;
		Triggers=StrTok("zombie_doors|zombie_door|zombie_airlock_buy|zombie_debris|flag_blocker|window_shutter|zombie_trap","|");
		for(a=0;a<Triggers.size;a++)
		{
			Trigger=GetEntArray(Triggers[a],"targetname");
			for(b=0;b<Trigger.size;b++)
				Trigger[b] notify("trigger");
		}
		wait .05;
		setdvar("zombie_unlock_all",0);
	}
}

turnOnPower()
{
	if(!flag("power_on"))
	{
		trig = getEnt("use_elec_switch", "targetname");
		powerSwitch = getEnt("elec_switch", "targetname");
		powerSwitch notSolid();
		trig setHintString(&"ZOMBIE_ELECTRIC_SWITCH");
		trig setVisibleToAll();
		trig notify("trigger", self);
		trig setInvisibleToAll();
		powerSwitch rotateRoll(-90,0,3);
		powerSwitch playSound("zmb_switch_flip");
		powerSwitch playSound("zmb_poweron");
		level thread maps/mp/zombies/_zm_perks::perk_unpause_all_perks();
		powerSwitch waittill("rotatedone");
		playFx(level._effect["switch_sparks"], powerSwitch.origin+(0, 12, -60), anglesToForward(powerSwitch.angles));
		powerSwitch playSound("zmb_turn_on");
		level notify("electric_door");
		flag_set("power_on");
		level setClientField("zombie_power_on", 1); 
	}
}

getAllPerks()
{
    self notify ( "end_perks" );
    self endon ( "end_perks" );
    self endon ( "disconnect" );
    level endon ( "end_game" );
    
    for(;;)
    {
		wait 0.5;
		if (isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
			self doGivePerk("specialty_armorvest");
		if (isDefined(level.zombiemode_using_sleightofhand_perk) && level.zombiemode_using_sleightofhand_perk)
			self doGivePerk("specialty_fastreload");
		if (isDefined(level.zombiemode_using_doubletap_perk) && level.zombiemode_using_doubletap_perk) 
			self doGivePerk("specialty_rof");
		if (isDefined(level.zombiemode_using_marathon_perk) && level.zombiemode_using_marathon_perk)
			self doGivePerk("specialty_longersprint");
		if (isDefined(level.zombiemode_using_tombstone_perk) && level.zombiemode_using_tombstone_perk)
			self doGivePerk("specialty_scavenger");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_flakjacket"]) && (level.script != "zm_buried"))
			self doGivePerk("specialty_flakjacket");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_nomotionsensor"]))
			self doGivePerk("specialty_nomotionsensor");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_grenadepulldeath"]))
			self doGivePerk("specialty_grenadepulldeath");
		self doGivePerk("specialty_deadshot");
	}
}

doGivePerk(perk)
{
    if (!(self hasperk(perk)))
        self thread maps/mp/zombies/_zm_perks::give_perk(perk, 1);
	self notify ( "burp" );
}

buried_turn_power_on()
{
	trigger = getent( "use_elec_switch", "targetname" );
	if ( isDefined( trigger ) )
	{
		trigger delete();
	}
	master_switch = getent( "elec_switch", "targetname" );
	if ( isDefined( master_switch ) )
	{
		master_switch notsolid();
		master_switch rotateroll( -90, 0.3 );
		clientnotify( "power_on" );
		flag_set( "power_on" );
	}
}

buried_deleteslothbarricades()
{
	sloth_trigs = getentarray( "sloth_barricade", "targetname" );
	foreach (trig in sloth_trigs)
	{
		if ( isDefined( trig.script_flag ) && level flag_exists( trig.script_flag ) )
		{
			flag_set( trig.script_flag );
		}
		parts = getentarray( trig.target, "targetname" );
		array_thread( parts, ::self_delete );
	}
	array_thread( sloth_trigs, ::self_delete );
}

zombies_override()
{
	while ( 1 )
	{
		level waittill( "start_of_round" );
		level.zombie_total = 1;
		level.zombie_health = 1;
		level.zombie_move_speed = 30;
	}
}
