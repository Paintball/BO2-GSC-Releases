#include codescripts\character;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_spawnlogic;
#include maps\mp\animscripts\traverse\shared;
#include maps\mp\animscripts\utility;
#include maps\mp\zombies\_load;
#include maps\mp\_createfx;
#include maps\mp\_music;
#include maps\mp\_busing;
#include maps\mp\_script_gen;
#include maps\mp\gametypes_zm\_globallogic_audio;
#include maps\mp\gametypes_zm\_tweakables;
#include maps\mp\_challenges;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\_demo;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\gametypes_zm\_globallogic_utils;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_globallogic_spawn;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_ai_faller;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_pers_upgrades;
#include maps\mp\zombies\_zm_score;
#include maps\mp\animscripts\zm_run;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\animscripts\zm_shared;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_ai_basic;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_server_throttle;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_melee_weapon;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_magicbox;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_ai_dogs;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_playerhealth;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_ballistic_knife;

///////////////////////////////////
//INITIALIZE GAME FUNCTIONS BELOW//
///////////////////////////////////
init()
{
	thread initPrecache();
	thread initCallbacks();
	thread initGameDvars();
	thread initLevelVariables();
	thread initLevelThreads();
	thread initPlayerThreads();
}

initPrecache()
{
	thread precacheCollisionClips();
	thread precacheEffectsForWeapons();
	thread precacheZombieHitmarkers();
	thread precacheZombieVendingMachines();
}

initCallbacks()
{
	//none
}

initCustomPerkPurchaseLimit()
{
	while( isPreGame() )
		wait 1;
	level.get_player_perk_purchase_limit = ::get_player_perk_purchase_limit;
}

initGameDvars()
{
	setDvar( "scr_screecher_ignore_player", 1 );	//no stupid ass denizens
}

initLevelVariables()
{
	//level.player_out_of_playable_area_monitor = 0;
	thread initCustomPerkSpawnpoints();
	thread initCustomPlayerSpawnpoints();
	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.zombie_weapons[ "emp_grenade_zm" ].is_in_box = 0;
}

initLevelThreads()
{
	level thread initBuildAllBuildables();		//this is necessary so the pap machine gets built
	level thread initCustomMapBarriers();		//map barriers to show designated play area
	level thread initCustomMysteryBox();		//custom mystery box location & thinking
	level thread initCustomPerkMachineSpawns(); //custom pap location
	level thread initCustomPerkPurchaseLimit(); //extra perk slots when achieving X kills
	level thread initCustomPowerupMoving();		//moves powerups to the log outside the cabin so they dont get stuck outside the playable area
	level thread initCustomWallbuyLocations();	//custom wallbuy locations
	level thread initCustomWunderfizz();		//wunderfizz for the perks
	level thread initOverrideZombieSpeed();		//force zombies to move quicker
	level thread initPowerOnGameStart();		//force power ON at the beginning of the game
	level thread initZombieHitmarkers();		//add hitmarkers for zombies
	level thread create_spawner_list();			//modify spawnpoints??//
}

initPlayerThreads()
{
	level thread onPlayerConnect();
}

////////////////////////////
//PRECACHE COLLISION CLIPS//
////////////////////////////
precacheCollisionClips()
{
	precacheModel( "collision_clip_32x32x128" );
	precacheModel( "collision_geo_cylinder_32x128_standard" );
}

///////////////////////////
//PRECACHE WALLBUY CHALKS//
///////////////////////////
precacheEffectsForWeapons() //custom function
{
	level._effect[ "olympia_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_olympia" );
	level._effect[ "m16_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" );
	level._effect[ "galvaknuckles_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_taseknuck" );
	level._effect[ "mp5k_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_mp5k" );
	level._effect[ "bowie_knife_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_bowie" );
	level._effect[ "m14_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m14" );
	level._effect[ "ak74u_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_ak74u" );
	level._effect[ "b23r_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_berreta93r" );
	level._effect[ "claymore_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_claymore" );
}

///////////////////////////////
//PRECACHE PERKS & PAP MODELS//
///////////////////////////////
precacheZombieHitmarkers()
{
	precacheshader( "damage_feedback" );
}

///////////////////////////////
//PRECACHE PERKS & PAP MODELS//
///////////////////////////////
precacheZombieVendingMachines()
{
	precacheModel( "zombie_vending_jugg" );
	precacheModel( "zombie_vending_jugg_on" );
	precacheModel( "zombie_vending_doubletap2" );
	precacheModel( "zombie_vending_doubletap2_on" );
	precacheModel( "zombie_vending_marathon" );
	precacheModel( "zombie_vending_marathon_on" );
	precacheModel( "zombie_vending_sleight" );
	precacheModel( "zombie_vending_sleight_on" );
	precacheModel( "zombie_vending_three_gun" );
	precacheModel( "zombie_vending_three_gun_on" );
	precacheModel( "zombie_vending_revive" );
	precacheModel( "zombie_vending_revive_on" );
	precacheModel( "zombie_vending_tombstone" );
	precacheModel( "zombie_vending_tombstone_on" );
	precacheModel( "p6_anim_zm_buildable_pap" );
	precacheModel( "p6_anim_zm_buildable_pap_on" );
}

/////////////////////////////////
//SETUP SPAWNPOINTS ARRAY BELOW//
/////////////////////////////////
initCustomPlayerSpawnpoints()
{
	level.customSpawnpoints = [];
	level.customSpawnpoints[ 0 ] = spawnstruct();
	level.customSpawnpoints[ 0 ].origin = ( 5071, 7022, -20 );
	level.customSpawnpoints[ 0 ].angles = ( 0, 315, 0 );
	level.customSpawnpoints[ 0 ].radius = 32;
	level.customSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 0 ].script_int = 2048;
	
	level.customSpawnpoints[ 1 ] = spawnstruct();
	level.customSpawnpoints[ 1 ].origin = ( 5358, 7034, -20 );
	level.customSpawnpoints[ 1 ].angles = ( 0, 246, 0 );
	level.customSpawnpoints[ 1 ].radius = 32;
	level.customSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 1 ].script_int = 2048;
	
	level.customSpawnpoints[ 2 ] = spawnstruct();
	level.customSpawnpoints[ 2 ].origin = ( 5078, 6733, -20 );
	level.customSpawnpoints[ 2 ].angles = ( 0, 56, 0 );
	level.customSpawnpoints[ 2 ].radius = 32;
	level.customSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 2 ].script_int = 2048;
	
	level.customSpawnpoints[ 3 ] = spawnstruct();
	level.customSpawnpoints[ 3 ].origin = ( 5334, 6723, -20 );
	level.customSpawnpoints[ 3 ].angles = ( 0, 123, 0 );
	level.customSpawnpoints[ 3 ].radius = 32;
	level.customSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 3 ].script_int = 2048;
	
	level.customSpawnpoints[ 4 ] = spawnstruct();
	level.customSpawnpoints[ 4 ].origin = ( 5057, 6583, -10 );
	level.customSpawnpoints[ 4 ].angles = ( 0, 0, 0 );
	level.customSpawnpoints[ 4 ].radius = 32;
	level.customSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 4 ].script_int = 2048;
	
	level.customSpawnpoints[ 5 ] = spawnstruct();
	level.customSpawnpoints[ 5 ].origin = ( 5305, 6591, -20 );
	level.customSpawnpoints[ 5 ].angles = ( 0, 180, 0 );
	level.customSpawnpoints[ 5 ].radius = 32;
	level.customSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 5 ].script_int = 2048;
	
	level.customSpawnpoints[ 6 ] = spawnstruct();
	level.customSpawnpoints[ 6 ].origin = ( 5350, 6882, -20 );
	level.customSpawnpoints[ 6 ].angles = ( 0, 180, 0 );
	level.customSpawnpoints[ 6 ].radius = 32;
	level.customSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 6 ].script_int = 2048;
	
	level.customSpawnpoints[ 7 ] = spawnstruct();
	level.customSpawnpoints[ 7 ].origin = ( 5102, 6851, -20 );
	level.customSpawnpoints[ 7 ].angles = ( 0, 0, 0 );
	level.customSpawnpoints[ 7 ].radius = 32;
	level.customSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.customSpawnpoints[ 7 ].script_int = 2048;
}

initCustomPerkSpawnpoints()
{
	level.customPerkArray = array( "specialty_weapupgrade" );

	level.customPerks["specialty_weapupgrade"] = spawnstruct();
	level.customPerks["specialty_weapupgrade"].origin = ( 5405,6869,-23 );
	level.customPerks["specialty_weapupgrade"].angles = ( 0, 90, 0 );
	level.customPerks["specialty_weapupgrade"].model = "tag_origin";
	level.customPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
}

/////////////////////////////////////
//SETUP MAP BARRIERS & BUSHES BELOW//
/////////////////////////////////////
initCustomMapBarriers() //custom function
{
	//HOUSE BARRIERS
	housebarrier1 = spawn("script_model", (5568,6336,-70));
	housebarrier1 setModel("collision_player_wall_512x512x10");
	housebarrier1 rotateTo((0,266,0),.1);
	housebarrier1 ConnectPaths();

	housebarrier2 = spawn("script_model", (5074,7089,-24));
	housebarrier2 setModel("collision_player_wall_128x128x10");
	housebarrier2 rotateTo((0,0,0),.1);
	housebarrier2 ConnectPaths();

	housebarrier3 = spawn("script_model", (4985,5862,-64));
	housebarrier3 setModel("collision_player_wall_512x512x10");
	housebarrier3 rotateTo((0,159,0),.1);
	housebarrier3 ConnectPaths();

	housebarrier4 = spawn("script_model", (5207,5782,-64));
	housebarrier4 setModel("collision_player_wall_512x512x10");
	housebarrier4 rotateTo((0,159,0),.1);
	housebarrier4 ConnectPaths();

	housebarrier5 = spawn("script_model", (4819,6475,-64));
	housebarrier5 setModel("collision_player_wall_512x512x10");
	housebarrier5 rotateTo((0,258,0),.1);
	housebarrier5 ConnectPaths();

	housebarrier6 = spawn("script_model", (4767,6200,-64));
	housebarrier6 setModel("collision_player_wall_512x512x10");
	housebarrier6 rotateTo((0,258,0),.1);
	housebarrier6 ConnectPaths();

	housebarrier7 = spawn("script_model", (5459,5683,-64));
	housebarrier7 setModel("collision_player_wall_512x512x10");
	housebarrier7 rotateTo((0,159,0),.1);
	housebarrier7 ConnectPaths();
			
	housebush1 = spawn("script_model", (5548.5, 6358, -72));
	housebush1 setModel("t5_foliage_bush05");
	housebush1 rotateTo((0,271,0),.1);
			
	housebush2 = spawn("script_model", (5543.79, 6269.37, -64.75));
	housebush2 setModel("t5_foliage_bush05");
	housebush2 rotateTo((0,-45,0),.1);
			
	housebush3 = spawn("script_model", (5553.23, 6446, -76));
	housebush3 setModel("t5_foliage_bush05");
	housebush3 rotateTo((0,90,0),.1);
			
	housebush4 = spawn("script_model", (5534, 6190.8, -64));
	housebush4 setModel("t5_foliage_bush05");
	housebush4 rotateTo((0,180,0),.1);
			
	housebush5 = spawn("script_model", (5565.1, 5661, -64));
	housebush5 setModel("t5_foliage_bush05");
	housebush5 rotateTo((0,-45,0),.1);
			
	housebush6 = spawn("script_model", (5380.4, 5738, -64));
	housebush6 setModel("t5_foliage_bush05");
	housebush6 rotateTo((0,80,0),.1);
			
	housebush7 = spawn("script_model", (5467, 5702, -64));
	housebush7 setModel("t5_foliage_bush05");
	housebush7 rotateTo((0,40,0),.1);
			
	housebush8 = spawn("script_model", (5323.1, 5761.7, -64));
	housebush8 setModel("t5_foliage_bush05");
	housebush8 rotateTo((0,120,0),.1);
			
	housebush9 = spawn("script_model", (5261, 5787.5, -64));
	housebush9 setModel("t5_foliage_bush05");
	housebush9 rotateTo((0,150,0),.1);
			
	housebush10 = spawn("script_model", (5199, 5813.5, -64));
	housebush10 setModel("t5_foliage_bush05");
	housebush10 rotateTo((0,230,0),.1);
			
	housebush11 = spawn("script_model", (5137, 5839.5, -64)); //-62, +26
	housebush11 setModel("t5_foliage_bush05");
	housebush11 rotateTo((0,0,0),.1);
			
	housebush12 = spawn("script_model", (5075, 5865.5, -64));
	housebush12 setModel("t5_foliage_bush05");
	housebush12 rotateTo((0,70,0),.1);
			
	housebush13 = spawn("script_model", (5013, 5891.5, -64));
	housebush13 setModel("t5_foliage_bush05");
	housebush13 rotateTo((0,170,0),.1);
			
	housebush14 = spawn("script_model", (4951, 5917.5, -64));
	housebush14 setModel("t5_foliage_bush05");
	housebush14 rotateTo((0,0,0),.1);
			
	housebush15 = spawn("script_model", (4889, 5943.5, -64));
	housebush15 setModel("t5_foliage_bush05");
	housebush15 rotateTo((0,245,0),.1);
			
	housebush16 = spawn("script_model", (4810, 5926.5, -64));
	housebush16 setModel("t5_foliage_bush05");
	housebush16 rotateTo((0,53,0),.1);
			
	housebush17 = spawn("script_model", (4762, 6069, -64));
	housebush17 setModel("t5_foliage_bush05");
	housebush17 rotateTo((0,100,0),.1);
			
	housebush18 = spawn("script_model", (4777, 6149, -64)); //+15, +80
	housebush18 setModel("t5_foliage_bush05");
	housebush18 rotateTo((0,200,0),.1);
			
	housebush19 = spawn("script_model", (4792, 6229, -64));
	housebush19 setModel("t5_foliage_bush05");
	housebush19 rotateTo((0,100,0),.1);
			
	housebush20 = spawn("script_model", (4807, 6309, -64));
	housebush20 setModel("t5_foliage_bush05");
	housebush20 rotateTo((0,200,0),.1);
			
	housebush21 = spawn("script_model", (4822, 6389, -64));
	housebush21 setModel("t5_foliage_bush05");
	housebush21 rotateTo((0,100,0),.1);
			
	housebush22 = spawn("script_model", (4837, 6469, -64));
	housebush22 setModel("t5_foliage_bush05");
	housebush22 rotateTo((0,200,0),.1);
			
	housebush23 = spawn("script_model", (4852, 6549, -64));
	housebush23 setModel("t5_foliage_bush05");
	housebush23 rotateTo((0,100,0),.1);
			
	housebush24 = spawn("script_model", (4867, 6629, -64));
	housebush24 setModel("t5_foliage_bush05");
	housebush24 rotateTo((0,200,0),.1);
			
	housebush25 = spawn("script_model", (5557.4, 6524.5, -80));
	housebush25 setModel("t5_foliage_bush05");
	housebush25 rotateTo((0,200,0),.1);
			
	housebush26 = spawn("script_model", (5078.68, 7172.37, -64));
	housebush26 setModel("t5_foliage_bush05");
	housebush26 rotateTo((0,234,0),.1);
			
	housebush27 = spawn("script_model", (5017, 7130.22, -64));
	housebush27 setModel("t5_foliage_bush05");
	housebush27 rotateTo((0,45,0),.1);
			
	housebush28 = spawn("script_model", (5154.25, 7133.65, -64));
	housebush28 setModel("t5_foliage_bush05");
	housebush28 rotateTo((0,130,0),.1);
			
	housebush29 = spawn("script_model", (5105.25, 7166.65, -64));
	housebush29 setModel("t5_foliage_bush05");
	housebush29 rotateTo((0,292,0),.1);
}

//////////////////////////////////
//PLAYER RELATED FUNCTIONS BELOW//
//////////////////////////////////
onPlayerConnect()
{
	level endon("end_game");
    for( ;; )
    { 
        level waittill( "connected", player );
        player thread onPlayerSpawned();
        player thread display_popups_waiter();
        player thread setupZombieHitmarkers();
        player thread addPerkSlot();
        player thread welcomeMessage();
    }
}

welcomeMessage()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	self waittill( "spawned_player" );
	flag_wait( "initial_blackscreen_passed" );
	self hintmessage("^3Welcome to Bonus Survival Map: ^1Cabin", 10 );
	wait 10;
	self hintmessage("^3Developed by: ^1JezuzLizard, GerardS0406, ^3& ^1Cahz", 10 );
}

onPlayerSpawned()
{
    self endon( "disconnect" );
	level endon( "end_game" );
    for( ;; )
    {
        self waittill( "spawned_player" );
        self thread teleportToCustomSpawnpoint();
    }
}

teleportToCustomSpawnpoint() //TELEPORT PLAYER TO SPAWNPOINTS FROM CREATED ARRAY//
{
	level endon("end_game");

	while( ispregame() )
		wait 0.05;
	
    for( i = 0; i < level.players.size; i++ )
	{
		if( level.players[ i ] == self )
		{
			self setOrigin( level.customSpawnpoints[ i ].origin );
			self.angles = level.customSpawnpoints[ i ].angles;
			return;
		}
	}
}

display_popups_waiter()
{
    self endon("disconnect");
    level endon("end_game");

    self.messagenotifyqueue = [];

    for(;;)
    {
        if (self.messagenotifyqueue.size == 0)
            self waittill("received award");

        if (self.messagenotifyqueue.size > 0)
        {
            nextnotifydata = self.messagenotifyqueue[0];
            arrayremoveindex(self.messagenotifyqueue, 0, 0);

            duration = 6; // level.regulargamemessages.waittime
            if (isdefined(nextnotifydata.duration))
                duration = nextnotifydata.duration;

            self maps\mp\gametypes_zm\_hud_message::shownotifymessage(nextnotifydata, duration);
        }
    }
}

/////////////////////////////////////////
//MAP COLLISION & MODELS FUNCTION BELOW//
/////////////////////////////////////////
initCustomMapBarriers() //custom function
{
	//HOUSE BARRIERS
	housebarrier1 = spawn("script_model", (5568,6336,-70));
	housebarrier1 setModel("collision_player_wall_512x512x10");
	housebarrier1 rotateTo((0,266,0),.1);
	housebarrier1 ConnectPaths();

	housebarrier2 = spawn("script_model", (5074,7089,-24));
	housebarrier2 setModel("collision_player_wall_128x128x10");
	housebarrier2 rotateTo((0,0,0),.1);
	housebarrier2 ConnectPaths();

	housebarrier3 = spawn("script_model", (4985,5862,-64));
	housebarrier3 setModel("collision_player_wall_512x512x10");
	housebarrier3 rotateTo((0,159,0),.1);
	housebarrier3 ConnectPaths();

	housebarrier4 = spawn("script_model", (5207,5782,-64));
	housebarrier4 setModel("collision_player_wall_512x512x10");
	housebarrier4 rotateTo((0,159,0),.1);
	housebarrier4 ConnectPaths();

	housebarrier5 = spawn("script_model", (4819,6475,-64));
	housebarrier5 setModel("collision_player_wall_512x512x10");
	housebarrier5 rotateTo((0,258,0),.1);
	housebarrier5 ConnectPaths();

	housebarrier6 = spawn("script_model", (4767,6200,-64));
	housebarrier6 setModel("collision_player_wall_512x512x10");
	housebarrier6 rotateTo((0,258,0),.1);
	housebarrier6 ConnectPaths();

	housebarrier7 = spawn("script_model", (5459,5683,-64));
	housebarrier7 setModel("collision_player_wall_512x512x10");
	housebarrier7 rotateTo((0,159,0),.1);
	housebarrier7 ConnectPaths();
		
	housebush1 = spawn("script_model", (5548.5, 6358, -72));
	housebush1 setModel("t5_foliage_bush05");
	housebush1 rotateTo((0,271,0),.1);
		
	housebush2 = spawn("script_model", (5543.79, 6269.37, -64.75));
	housebush2 setModel("t5_foliage_bush05");
	housebush2 rotateTo((0,-45,0),.1);
		
	housebush3 = spawn("script_model", (5553.23, 6446, -76));
	housebush3 setModel("t5_foliage_bush05");
	housebush3 rotateTo((0,90,0),.1);
		
	housebush4 = spawn("script_model", (5534, 6190.8, -64));
	housebush4 setModel("t5_foliage_bush05");
	housebush4 rotateTo((0,180,0),.1);
		
	housebush5 = spawn("script_model", (5565.1, 5661, -64));
	housebush5 setModel("t5_foliage_bush05");
	housebush5 rotateTo((0,-45,0),.1);
		
	housebush6 = spawn("script_model", (5380.4, 5738, -64));
	housebush6 setModel("t5_foliage_bush05");
	housebush6 rotateTo((0,80,0),.1);
		
	housebush7 = spawn("script_model", (5467, 5702, -64));
	housebush7 setModel("t5_foliage_bush05");
	housebush7 rotateTo((0,40,0),.1);
		
	housebush8 = spawn("script_model", (5323.1, 5761.7, -64));
	housebush8 setModel("t5_foliage_bush05");
	housebush8 rotateTo((0,120,0),.1);
		
	housebush9 = spawn("script_model", (5261, 5787.5, -64));
	housebush9 setModel("t5_foliage_bush05");
	housebush9 rotateTo((0,150,0),.1);
		
	housebush10 = spawn("script_model", (5199, 5813.5, -64));
	housebush10 setModel("t5_foliage_bush05");
	housebush10 rotateTo((0,230,0),.1);
		
	housebush11 = spawn("script_model", (5137, 5839.5, -64)); //-62, +26
	housebush11 setModel("t5_foliage_bush05");
	housebush11 rotateTo((0,0,0),.1);
		
	housebush12 = spawn("script_model", (5075, 5865.5, -64));
	housebush12 setModel("t5_foliage_bush05");
	housebush12 rotateTo((0,70,0),.1);
		
	housebush13 = spawn("script_model", (5013, 5891.5, -64));
	housebush13 setModel("t5_foliage_bush05");
	housebush13 rotateTo((0,170,0),.1);
		
	housebush14 = spawn("script_model", (4951, 5917.5, -64));
	housebush14 setModel("t5_foliage_bush05");
	housebush14 rotateTo((0,0,0),.1);
		
	housebush15 = spawn("script_model", (4889, 5943.5, -64));
	housebush15 setModel("t5_foliage_bush05");
	housebush15 rotateTo((0,245,0),.1);
		
	housebush16 = spawn("script_model", (4810, 5926.5, -64));
	housebush16 setModel("t5_foliage_bush05");
	housebush16 rotateTo((0,53,0),.1);
		
	housebush17 = spawn("script_model", (4762, 6069, -64));
	housebush17 setModel("t5_foliage_bush05");
	housebush17 rotateTo((0,100,0),.1);
		
	housebush18 = spawn("script_model", (4777, 6149, -64)); //+15, +80
	housebush18 setModel("t5_foliage_bush05");
	housebush18 rotateTo((0,200,0),.1);
		
	housebush19 = spawn("script_model", (4792, 6229, -64));
	housebush19 setModel("t5_foliage_bush05");
	housebush19 rotateTo((0,100,0),.1);
		
	housebush20 = spawn("script_model", (4807, 6309, -64));
	housebush20 setModel("t5_foliage_bush05");
	housebush20 rotateTo((0,200,0),.1);
		
	housebush21 = spawn("script_model", (4822, 6389, -64));
	housebush21 setModel("t5_foliage_bush05");
	housebush21 rotateTo((0,100,0),.1);
		
	housebush22 = spawn("script_model", (4837, 6469, -64));
	housebush22 setModel("t5_foliage_bush05");
	housebush22 rotateTo((0,200,0),.1);
		
	housebush23 = spawn("script_model", (4852, 6549, -64));
	housebush23 setModel("t5_foliage_bush05");
	housebush23 rotateTo((0,100,0),.1);
		
	housebush24 = spawn("script_model", (4867, 6629, -64));
	housebush24 setModel("t5_foliage_bush05");
	housebush24 rotateTo((0,200,0),.1);
		
	housebush25 = spawn("script_model", (5557.4, 6524.5, -80));
	housebush25 setModel("t5_foliage_bush05");
	housebush25 rotateTo((0,200,0),.1);
		
	housebush26 = spawn("script_model", (5078.68, 7172.37, -64));
	housebush26 setModel("t5_foliage_bush05");
	housebush26 rotateTo((0,234,0),.1);
		
	housebush27 = spawn("script_model", (5017, 7130.22, -64));
	housebush27 setModel("t5_foliage_bush05");
	housebush27 rotateTo((0,45,0),.1);
		
	housebush28 = spawn("script_model", (5154.25, 7133.65, -64));
	housebush28 setModel("t5_foliage_bush05");
	housebush28 rotateTo((0,130,0),.1);
		
	housebush29 = spawn("script_model", (5105.25, 7166.65, -64));
	housebush29 setModel("t5_foliage_bush05");
	housebush29 rotateTo((0,292,0),.1);
}

///////////////////////////////
//MYSTERY BOX FUNCTIONS BELOW//
///////////////////////////////
initCustomMysteryBox()
{
	level endon("end_game");
	flag_wait( "initial_blackscreen_passed" );
	setdvar( "magic_chest_movable", 0 );
	add_zombie_hint( "default_shared_box", "Hold ^3&&1^7 for weapon");
    for(i = 0; i < level.chests.size; i++)
    {
        level.chests[ i ] notify( "kill_chest_think" ); //kill all exsiting mystery boxes
	}
	setupCustomMysteryBoxLocation();
}

setupCustomMysteryBoxLocation() //modify box location here//
{
	level.chests = [];
	start_chest = spawnstruct();
	start_chest.origin = ( 5387, 6594, -24 );
	start_chest.angles = ( 0, 90, 0 );
	start_chest.script_noteworthy = "start_chest";
	start_chest.zombie_cost = 950;
	level.chests[ 0 ] = start_chest;
	level.chests[ 0 ].unitrigger_stub.prompt_and_visibility_func = ::boxtrigger_update_prompt;
	level.chests[ 0 ].no_fly_away = 1;
	level.chest_index = 0;
	treasure_chest_init( "start_chest" );
}

treasure_chest_init( start_chest_name )
{
	flag_init( "moving_chest_enabled" );
	flag_init( "moving_chest_now" );
	flag_init( "chest_has_been_used" );
	level.chest_moves = 0;
	level.chest_level = 0;
	if ( level.chests.size == 0 )
	{
		return;
	}
	for ( i = 0; i < level.chests.size; i++ )
	{
		level.chests[ i ].box_hacks = [];
		level.chests[ i ].orig_origin = level.chests[ i ].origin;
		level.chests[ i ] get_chest_pieces();
		if ( isDefined( level.chests[ i ].zombie_cost ) )
		{
			level.chests[ i ].old_cost = level.chests[ i ].zombie_cost;
		}
		else
		{
			level.chests[ i ].old_cost = 950;
		}
	}
	if ( !level.enable_magic )
    {
        foreach ( chest in level.chests )
            chest hide_chest();

        return;
    }
    level.chest_accessed = 0;
	
    if ( level.chests.size > 1 )
    {
        flag_set( "moving_chest_enabled" );
        level.chests = array_randomize( level.chests );
    }
    else
    {
        level.chest_index = 0;
        level.chests[0].no_fly_away = 1;
    }
	level.chest_accessed = 0;
	init_starting_chest_location( start_chest_name );
	array_thread( level.chests, ::custom_treasure_chest_think );
}
/*
reset_box()
{
	self notify( "kill_chest_think" );
    wait .1;
	if( !self.hidden )
    {
		self.grab_weapon_hint = 0;
		self thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    	self.unitrigger_stub run_visibility_function_for_all_triggers();
	}
	self thread custom_treasure_chest_think();
}
*/
get_chest_pieces() //modified function
{
	self.chest_box = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
	self.chest_box.origin = ( 5387, 6594, -24 );
	self.chest_box.angles = ( 0, 90, 0 );

	if ( self.chest_box.angles == ( 0, 92, 0 ) || self.chest_box.angles == ( 0, 90, 0 ) || self.chest_box.angles == ( 0, -90, 0 ) )
	{
		collision = spawn( "script_model", self.chest_box.origin );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin - ( 0, 32, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin + ( 0, 32, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
	}
	else if ( self.chest_box.angles == ( 0, 10, 0 ) || self.chest_box.angles == ( 0, 1, 0 ) || self.chest_box.angles == ( 0, 0, 0 ) || self.chest_box.angles == ( 0, 180, 0 ) || self.chest_box.angles == ( 0, -180, 0 ) || self.chest_box.angles == ( 0, -185, 0 ) )
	{
		collision = spawn( "script_model", self.chest_box.origin );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin - ( 32, 0, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin + ( 32, 0, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
	}

	self.chest_rubble = [];
	rubble = getentarray( self.script_noteworthy + "_rubble", "script_noteworthy" );
	for ( i = 0; i < rubble.size; i++ )
	{
		if ( distancesquared( self.origin, rubble[ i ].origin ) < 10000 )
		{
			self.chest_rubble[ self.chest_rubble.size ] = rubble[ i ];
		}
	}
	self.zbarrier = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
	if ( isDefined( self.zbarrier ) )
	{
		self.zbarrier zbarrierpieceuseboxriselogic( 3 );
		self.zbarrier zbarrierpieceuseboxriselogic( 4 );
	}
	self.unitrigger_stub = spawnstruct();
	self.unitrigger_stub.origin = self.origin + anglesToRight( self.angles * -22.5 );
	self.unitrigger_stub.angles = self.angles;
	self.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	self.unitrigger_stub.script_width = 104;
	self.unitrigger_stub.script_height = 60;
	self.unitrigger_stub.script_length = 60;
	self.unitrigger_stub.trigger_target = self;
	maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( self.unitrigger_stub, 1 );
	self.unitrigger_stub.prompt_and_visibility_func = ::boxtrigger_update_prompt;
	self.zbarrier.owner = self;
}

boxtrigger_update_prompt( player )
{
	can_use = self custom_boxstub_update_prompt( player );
	if ( isDefined( self.hint_string ) )
	{
		if ( isDefined( self.hint_parm1 ) )
		{
			self sethintstring( self.hint_string, self.hint_parm1 );
		}
		else
		{
			self sethintstring( self.hint_string );
		}
	}
	return can_use;
}

custom_boxstub_update_prompt( player )
{
    self setcursorhint( "HINT_NOICON" );
    if( !self trigger_visible_to_player( player ) )
    {
        if( level.shared_box )
        {
            self setvisibletoplayer( player );
            self.hint_string = get_hint_string( self, "default_shared_box" );
            return 1;
        }
        return 0;
    }
    self.hint_parm1 = undefined;
    if ( isDefined( self.stub.trigger_target.grab_weapon_hint ) && self.stub.trigger_target.grab_weapon_hint )
    {
        if( level.shared_box )
        {
            self.hint_string = get_hint_string( self, "default_shared_box" );
        }    
        else
        {
            if (isDefined( level.magic_box_check_equipment ) && [[ level.magic_box_check_equipment ]]( self.stub.trigger_target.grab_weapon_name ) )
            {
                self.hint_string = "Hold ^3&&1^7 for Equipment ^1or ^7Press ^3[{+melee}]^7 to let teammates pick it up";
            }
            else 
            {
                self.hint_string = "Hold ^3&&1^7 for Weapon ^1or ^7Press ^3[{+melee}]^7 to let teammates pick it up";
            }
        }
    }
    else if(getdvar("mapname") == "zm_tomb" && isDefined(level.zone_capture.zones) && !level.zone_capture.zones[self.stub.zone] ent_flag( "player_controlled" )) 
    {
        self.stub.hint_string = &"ZM_TOMB_ZC";
        return 0;
    }
    else
    {
        if ( isDefined( level.using_locked_magicbox ) && level.using_locked_magicbox && isDefined( self.stub.trigger_target.is_locked ) && self.stub.trigger_target.is_locked )
        {
            self.hint_string = get_hint_string( self, "locked_magic_box_cost" );
        }
        else
        {
            self.hint_parm1 = self.stub.trigger_target.zombie_cost;
            self.hint_string = get_hint_string( self, "default_treasure_chest" );
        }
    }
    return 1;
}

custom_treasure_chest_think() //modified function
{
	level endon("end_game");
	self endon( "kill_chest_think" );
	user = undefined;
	user_cost = undefined;
	self.box_rerespun = undefined;
	self.weapon_out = undefined;
	self thread unregister_unitrigger_on_kill_think();
	self.unitrigger_stub run_visibility_function_for_all_triggers();
	
	while ( 1 )
	{
		if ( !isdefined( self.forced_user ) )
		{
			self waittill( "trigger", user );
			if ( user == level )
			{
				wait 0.1;
				continue;
			}
		}
		else
		{
			user = self.forced_user;
		}
		if ( user in_revive_trigger() )
		{
			wait 0.1;
			continue;
		}
		if ( user.is_drinking > 0 )
		{
			wait 0.1;
			continue;
		}
		if ( isdefined( self.disabled ) && self.disabled )
		{
			wait 0.1;
			continue;
		}
		if ( user getcurrentweapon() == "none" )
		{
			wait 0.1;
			continue;
		}
		reduced_cost = undefined;
		if ( is_player_valid( user ) && user maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			reduced_cost = int( self.zombie_cost / 2 );
		}
		if ( isdefined( level.using_locked_magicbox ) && level.using_locked_magicbox && isdefined( self.is_locked ) && self.is_locked ) 
		{
			if ( user.score >= level.locked_magic_box_cost )
			{
				user maps/mp/zombies/_zm_score::minus_to_player_score( level.locked_magic_box_cost );
				self.zbarrier set_magic_box_zbarrier_state( "unlocking" );
				self.unitrigger_stub run_visibility_function_for_all_triggers();
			}
			else
			{
				user maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			}
			wait 0.1 ;
			continue;
		}
		else if ( isdefined( self.auto_open ) && is_player_valid( user ) )
		{
			if ( !isdefined( self.no_charge ) )
			{
				user maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}
			self.chest_user = user;
			break;
		}
		else if ( is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps/mp/zombies/_zm_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( isdefined( reduced_cost ) && user.score >= reduced_cost )
		{
			user maps/mp/zombies/_zm_score::minus_to_player_score( reduced_cost );
			user_cost = reduced_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			play_sound_at_pos( "no_purchase", self.origin );
			user maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			wait 0.1;
			continue;
		}
		wait 0.05;
	}
	flag_set( "chest_has_been_used" );
	maps/mp/_demo::bookmark( "zm_player_use_magicbox", getTime(), user );
	user maps/mp/zombies/_zm_stats::increment_client_stat( "use_magicbox" );
	user maps/mp/zombies/_zm_stats::increment_player_stat( "use_magicbox" );
	if ( isDefined( level._magic_box_used_vo ) )
	{
		user thread [[ level._magic_box_used_vo ]]();
	}
	self thread watch_for_emp_close();
	if ( isDefined( level.using_locked_magicbox ) && level.using_locked_magicbox )
	{
		self thread custom_watch_for_lock();
	}
	self._box_open = 1;
	level.box_open = 1;
	self._box_opened_by_fire_sale = 0;
	if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !isDefined( self.auto_open ) && self [[ level._zombiemode_check_firesale_loc_valid_func ]]() )
	{
		self._box_opened_by_fire_sale = 1;
	}
	if ( isDefined( self.chest_lid ) )
	{
		self.chest_lid thread treasure_chest_lid_open();
	}
	if ( isDefined( self.zbarrier ) )
	{
		play_sound_at_pos( "open_chest", self.origin );
		play_sound_at_pos( "music_chest", self.origin );
		self.zbarrier set_magic_box_zbarrier_state( "open" );
	}
	self.timedout = 0;
	self.weapon_out = 1;
	self.zbarrier thread treasure_chest_weapon_spawn( self, user );
	self.zbarrier thread treasure_chest_glowfx();
	thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
	self.zbarrier waittill_any( "randomization_done", "box_hacked_respin" );
	if ( flag( "moving_chest_now" ) && !self._box_opened_by_fire_sale && isDefined( user_cost ) )
	{
		user maps/mp/zombies/_zm_score::add_to_player_score( user_cost, 0 );
	}
	if ( flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !self._box_opened_by_fire_sale )
	{
		self thread treasure_chest_move( self.chest_user );
	}
	else
	{
		self.grab_weapon_hint = 1;
		self.grab_weapon_name = self.zbarrier.weapon_string;
		self.chest_user = user;
		thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		
		if ( isDefined( self.zbarrier ) && !is_true( self.zbarrier.closed_by_emp ) )
		{
			self thread treasure_chest_timeout();
		}
		timeout_time = 105;
		grabber = user;
		for( i=0;i<105;i++ )
		{
			if(user meleeButtonPressed() && isplayer( user ) && distance(self.origin, user.origin) <= 100)
			{
				//shared_box_fx = SpawnFX( level._effect[ "powerup_on" ], self.origin + ( 0, 0, 24 ) );
				shared_box_fx = SpawnFX( level._effect[ "powerup_on_caution" ], self.origin + ( 0, 0, 24 ), AnglesToForward( self.angles ),AnglesToUp( self.angles ));
				TriggerFX( shared_box_fx );
				level.magic_box_grab_by_anyone = 1;
				level.shared_box = 1;
				self.unitrigger_stub run_visibility_function_for_all_triggers();
				for( a=i;a<105;a++ )
				{
					foreach(player in level.players)
					{
						if(player usebuttonpressed() && distance(self.origin, player.origin) <= 100 && isDefined( player.is_drinking ) && !player.is_drinking)
						{
						
							player thread treasure_chest_give_weapon( self.zbarrier.weapon_string );
							a = 105;
							break;
						}
					}
					wait 0.1;
				}
				break;
			}
			if(grabber usebuttonpressed() && isplayer( grabber ) && user == grabber && distance(self.origin, grabber.origin) <= 100 && isDefined( grabber.is_drinking ) && !grabber.is_drinking)
			{
				grabber thread treasure_chest_give_weapon( self.zbarrier.weapon_string );
				break;
			}
			wait 0.1;
		}
		if( isDefined( shared_box_fx ) )
			shared_box_fx delete();
		self.weapon_out = undefined;
		self notify( "user_grabbed_weapon" );
		user notify( "user_grabbed_weapon" );
		
		self.grab_weapon_hint = 0;
		self.zbarrier notify( "weapon_grabbed" );
		if ( isDefined( self._box_opened_by_fire_sale ) && !self._box_opened_by_fire_sale )
		{
			level.chest_accessed += 1;
		}
		if ( level.chest_moves > 0 && isDefined( level.pulls_since_last_ray_gun ) )
		{
			level.pulls_since_last_ray_gun += 1;
		}
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		if ( isDefined( self.chest_lid ) )
		{
			self.chest_lid thread treasure_chest_lid_close( self.timedout );
		}
		if ( isDefined( self.zbarrier ) )
		{
			self.zbarrier set_magic_box_zbarrier_state( "close" );
			play_sound_at_pos( "close_chest", self.origin );
			self.zbarrier waittill( "closed" );
			wait 1;
		}
		else
		{
			wait 3;
		}
		if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] || self [[ level._zombiemode_check_firesale_loc_valid_func ]]() || self == level.chests[ level.chest_index ] )
		{
			thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
		}
	}
	self._box_open = 0;
	level.box_open = 0;
	level.shared_box = 0;
	level.magic_box_grab_by_anyone = 0;
	self._box_opened_by_fire_sale = 0;
	self.chest_user = undefined;
	self notify( "chest_accessed" );
	self thread custom_treasure_chest_think();
}

custom_watch_for_lock() //modified function
{
	level endon("end_game");
    self endon( "user_grabbed_weapon" );
    self endon( "chest_accessed" );
    self waittill( "box_locked" );
    self notify( "kill_chest_think" );
    self.grab_weapon_hint = 0;
    wait 0.1;
    self thread maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    self.unitrigger_stub run_visibility_function_for_all_triggers();
    self thread custom_treasure_chest_think();
}

//////////////////////////////
//PERK SETUP FUNCTIONS BELOW//
//////////////////////////////
initCustomPerkMachineSpawns()
{
	level thread removeAllExistingPerkMachines();
	setupCustomPerkMachine( ( 5405,6869,-23 ), ( 0, 90, 0 ), "tag_origin", "doubletap_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );
}

removeAllExistingPerkMachines()
{
	perks = strToK( "specialty_armorvest specialty_rof specialty_longersprint specialty_fastreload specialty_quickrevive specialty_scavenger", " " );
	while( isPreGame() )
		wait .1;
	foreach( perk in perks )
	{
		level thread perk_machine_removal( perk );
	}
}

setupCustomPerkMachine( origin, angles, model, fx, sound, name, cost, perk, solo_cost )
{
	perk_machine = spawn( "script_model", origin );
	perk_machine setmodel( model );
	perk_machine.angles = angles;

	perk_machine_collision = spawn( "script_model", origin );
	perk_machine_collision setmodel( "zm_collision_perks1" );
	perk_machine_collision.angles = angles;

	if( isDefined( fx ))
		perk_machine thread play_fx( fx );
	
	if( name != "Quick Revive" )
	{
    	perk_machine thread perk_machine_think( perk, sound, name, cost );
	}
	else
	{
		perk_machine thread quick_revive_machine_think( perk, sound, name, cost, solo_cost );
	}
}

play_fx( fx )
{
	level endon( "game_ended" );
	while( !level.gameended )
	{
		level waittill( "connected", player );
		playfxontag( level._effect[ fx ], self, "tag_origin" );
	}
}

////////////////////////////////////
//customized perk machine thinking//
////////////////////////////////////
perk_machine_think( perk, sound, name, cost )
{
    level endon( "game_ended" );
    
    trigger = spawn("trigger_radius_use", self.origin + ( 0, 0, 32 ), 1, 100, 128);
    trigger SetCursorHint("HINT_NOICON");
    trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
    trigger triggerignoreteam();
	trigger usetriggerrequirelookat();
    trigger setvisibletoall();

	trigger thread givePoints();

    for(;;)
    {
        trigger waittill("trigger", player);
		trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
       	if( name != "Quick Revive" && name != "Pack-A-Punch" && player usebuttonpressed() && !player hasperk(perk) && player.score >= cost && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !player.is_drinking )
        {
        	trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
			player playsound( "zmb_cha_ching" );
			player.score -= cost;
			playsoundatposition( sound, self.origin + ( 0, 0, 32 ) );
			player thread DoGivePerk( perk );
			wait 3;
		}
		currgun = player getcurrentweapon();
		if( name == "Pack-A-Punch" && player usebuttonpressed() && !is_weapon_upgraded(currgun) && can_upgrade_weapon(currgun) && player.score >= cost && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand())
        {
        	trigger SetHintString( "" );
			player playsound( "zmb_cha_ching" );
			player.score -= cost;
			playsoundatposition( sound, self.origin + ( 0, 0, 32 ) );
			player takeweapon(currgun);
			gun = player maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 );
			player giveweapon(player maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 ), 0, player custom_get_pack_a_punch_weapon_options(gun));
			player switchToWeapon(gun);
			playfx(loadfx( "maps/zombie/fx_zombie_packapunch"), ( 12865.8, -661, -175.5195 ), anglestoforward( ( 0, 180, 55  ) ) ); 
			wait 3;
			trigger SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
		}
		else
		{
			if( player usebuttonpressed() && player.score < cost )
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
        }
		wait 0.5;
    }
}

////////////////////////////////////
//customized quick revive thinking//
////////////////////////////////////
quick_revive_machine_think( perk, sound, name, cost, solo_cost )
{

    level.solo_revives = 0;
    level.max_solo_revives = 3;

	level endon( "game_ended" );
    
    trigger = spawn("trigger_radius_use", self.origin + ( 0, 0, 32 ), 1, 100, 128);
    trigger SetCursorHint("HINT_NOICON");
    trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
    trigger triggerignoreteam();
	trigger usetriggerrequirelookat();
    trigger setvisibletoall();

    for(;;)
    {
		if(level.players.size > 1)
        {
			trigger SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
		}
		else
		{
			trigger SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + solo_cost + "]" );
		}
        trigger waittill("trigger", player);
		if((level.players.size > 1) && player usebuttonpressed() && !(player hasperk( perk )) && (player.score >= cost ) && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand()) 
		{
			level.solo_revives = 0;
			player playsound( "zmb_cha_ching" );
			player.score -= 1500;
			player playsound ( sound );
			player thread DoGivePerk( perk );
		}
		if(!level.max_revives && (level.players.size <= 1) && player usebuttonpressed() && !(player hasperk( perk )) && (player.score >= solo_cost) && !maps\mp\zombies\_zm_laststand::player_is_in_laststand()) 
		{
			level.solo_revives++;
			player playsound( "zmb_cha_ching" );
			player.score -= solo_cost;
			player playsound ( sound );
			player thread DoGivePerk( perk );
			//self.setorigin( (2366.8, -731.829, -999 ) );
		}
		if(level.max_revives && (level.players.size <= 1) && player usebuttonpressed() && (player.score >= solo_cost) && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand()) 
		{
			player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "oh_shit" );
			wait 3;
		}
		if(level.solo_revives >= level.max_solo_revives)
		{
			level.max_revives = 1;
		}
		else 
		{
			if((level.players.size == 1) && player usebuttonpressed() && player.score < 500)
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
			if((level.players.size > 1) && player usebuttonpressed() && player.score < 1500)
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
		}
		wait 0.1;
	}
}

doGivePerk( perk )
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("perk_abort_drinking");

    last_weapon = self getcurrentweapon();
    self.is_drinking = 1;
    gun = self maps\mp\zombies\_zm_perks::perk_give_bottle_begin( perk );
	//( "GIVING PeRK!" );
	wait 1;
	//iprintln( "STARTING WAITTILL PERK!" );
    evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
    if (evt == "weapon_change_complete")
        self thread maps\mp\zombies\_zm_perks::wait_give_perk(perk, 1);
    self maps\mp\zombies\_zm_perks::perk_give_bottle_end(gun, perk);
    if (self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        return;
    self notify("burp");
    self.is_drinking = 0;
	self switchToWeapon( last_weapon );
}

//////////////////////////
//GET PAP WEAPON OPTIONS//
//////////////////////////
custom_get_pack_a_punch_weapon_options( weapon )
{
	if( !(IsDefined( self.pack_a_punch_weapon_options )) )
	{
		self.pack_a_punch_weapon_options = [];
	}
	if( !(is_weapon_upgraded( weapon )) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if( IsDefined( self.pack_a_punch_weapon_options[ weapon] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon];
	}
	smiley_face_reticle_index = 1;
	base = get_base_name( weapon );
	if( base == "m16_zm" || weapon == "m16_upgraded_zm" || base == "qcw05_upgraded_zm" || weapon == "qcw05_zm" || base == "fivesevendw_upgraded_zm" || weapon == "fivesevendw_zm" || base == "fiveseven_upgraded_zm" || weapon == "fiveseven_zm" || base == "m32_upgraded_zm" || weapon == "m32_zm" || base == "ray_gun_upgraded_zm" || weapon == "ray_gun_zm" || base == "raygun_mark2_upgraded_zm" || weapon == "raygun_mark2_zm" || base == "m1911_upgraded_zm" || weapon == "m1911_zm" || base == "knife_ballistic_upgraded_zm" || weapon == "knife_ballistic_zm")
	{
		camo_index = 39;
	}
	else
	{
		camo_index = 44;
	}
	lens_index = randomintrange( 0, 6 );
	reticle_index = randomintrange( 0, 16 );
	reticle_color_index = randomintrange( 0, 6 );
	plain_reticle_index = 16;
	r = randomint( 10 );
	use_plain = r < 3;
	if( base == "saritch_upgraded_zm" )
	{
		reticle_index = smiley_face_reticle_index;
	}
	else
	{
		if( use_plain )
		{
			reticle_index = plain_reticle_index;
		}
	}
	scary_eyes_reticle_index = 8;
	purple_reticle_color_index = 3;
	if( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2;
	pink_reticle_color_index = 6;
	if( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7;
	green_reticle_color_index = 1;
	if( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}
	self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[ weapon];

}

initCustomPerkLocations() //modified function
{
	level endon("end_game");
	//initCustomPerkSpawnpoints();
	match_string = "";

	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && IsDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}		

	match_string = level.scr_zm_ui_gametype + "_perks_" + location;
	pos = [];
	if ( isdefined( level.override_perk_targetname ) )
	{
		structs = getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = getstructarray( "zm_perk_machine", "targetname" );
	}
	if ( match_string == "zclassic_perks_rooftop" || match_string == "zclassic_perks_tomb" || match_string == "zstandard_perks_nuked" )
	{
		useDefaultLocation = 1;
	}
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			k = 0;
			while ( k < tokens.size )
			{
				if ( tokens[ k ] == match_string )
				{
					pos[ pos.size ] = structs[ i ];
				}
				k++;
			}
		}
		else if ( isDefined( useDefaultLocation ) && useDefaultLocation )
		{
			pos[ pos.size ] = structs[ i ];
		}
		i++;
	}
	foreach( perk in level.customPerkArray )
	{
		pos[pos.size] = level.customPerks[ perk ];
	}
	if ( !IsDefined( pos ) || pos.size == 0 )
	{
		return;
	}
	PreCacheModel("zm_collision_perks1");
	for ( i = 0; i < pos.size; i++ )
	{
		perk = pos[ i ].script_noteworthy;
		//added for grieffix gun game
		if ( IsDefined( perk ) && IsDefined( pos[ i ].model ) )
		{
			use_trigger = Spawn( "trigger_radius_use", pos[ i ].origin + ( 0, 0, 30 ), 0, 40, 70 );
			use_trigger.targetname = "zombie_vending";			
			use_trigger.script_noteworthy = perk;
			use_trigger TriggerIgnoreTeam();
			use_trigger thread givePoints();
			//use_trigger thread debug_spot();
			perk_machine = Spawn( "script_model", pos[ i ].origin );
			perk_machine.angles = pos[ i ].angles;
			perk_machine SetModel( pos[ i ].model );
			
			perk_machine.is_locked = 0;
			if ( isdefined( level._no_vending_machine_bump_trigs ) && level._no_vending_machine_bump_trigs )
			{
				bump_trigger = undefined;
			}
			else
			{
				bump_trigger = spawn("trigger_radius", pos[ i ].origin, 0, 35, 64);
				bump_trigger.script_activated = 1;
				bump_trigger.script_sound = "zmb_perks_bump_bottle";
				bump_trigger.targetname = "audio_bump_trigger";
				if ( perk != "specialty_weapupgrade" )
				{
					bump_trigger thread thread_bump_trigger();
				}
			}
			collision = Spawn( "script_model", pos[ i ].origin, 1 );
			collision.angles = pos[ i ].angles;
			collision SetModel( "zm_collision_perks1" );
			collision DisconnectPaths();
			collision.script_noteworthy = "clip";
			//disable collision for the perk machine//
			collision NotSolid();
			collision ConnectPaths();
			//since the pap is in the fireplace//
			// Connect all of the pieces for easy access.
			use_trigger.clip = collision;
			use_trigger.bump = bump_trigger;
			use_trigger.machine = perk_machine;
			//missing code found in cerberus output
			if ( isdefined( pos[ i ].blocker_model ) )
			{
				use_trigger.blocker_model = pos[ i ].blocker_model;
			}
			if ( isdefined( pos[ i ].script_int ) )
			{
				perk_machine.script_int = pos[ i ].script_int;
			}
			if ( isdefined( pos[ i ].turn_on_notify ) )
			{
				perk_machine.turn_on_notify = pos[ i ].turn_on_notify;
			}
			switch( perk )
			{
				case "specialty_quickrevive":
				case "specialty_quickrevive_upgrade":
					use_trigger.script_sound = "mus_perks_revive_jingle";
					use_trigger.script_string = "revive_perk";
					use_trigger.script_label = "mus_perks_revive_sting";
					use_trigger.target = "vending_revive";
					perk_machine.script_string = "revive_perk";
					perk_machine.targetname = "vending_revive";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "revive_perk";
					}
					break;
				case "specialty_fastreload":
				case "specialty_fastreload_upgrade":
					use_trigger.script_sound = "mus_perks_speed_jingle";
					use_trigger.script_string = "speedcola_perk";
					use_trigger.script_label = "mus_perks_speed_sting";
					use_trigger.target = "vending_sleight";
					perk_machine.script_string = "speedcola_perk";
					perk_machine.targetname = "vending_sleight";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "speedcola_perk";
					}
					break;
				case "specialty_longersprint":
				case "specialty_longersprint_upgrade":
					use_trigger.script_sound = "mus_perks_stamin_jingle";
					use_trigger.script_string = "marathon_perk";
					use_trigger.script_label = "mus_perks_stamin_sting";
					use_trigger.target = "vending_marathon";
					perk_machine.script_string = "marathon_perk";
					perk_machine.targetname = "vending_marathon";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "marathon_perk";
					}
					break;
				case "specialty_armorvest":
				case "specialty_armorvest_upgrade":
					use_trigger.script_sound = "mus_perks_jugganog_jingle";
					use_trigger.script_string = "jugg_perk";
					use_trigger.script_label = "mus_perks_jugganog_sting";
					use_trigger.longjinglewait = 1;
					use_trigger.target = "vending_jugg";
					perk_machine.script_string = "jugg_perk";
					perk_machine.targetname = "vending_jugg";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "jugg_perk";
					}
					break;
				case "specialty_scavenger":
				case "specialty_scavenger_upgrade":
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
					break;
				case "specialty_rof":
				case "specialty_rof_upgrade":
					use_trigger.script_sound = "mus_perks_doubletap_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_doubletap_sting";
					use_trigger.target = "vending_doubletap";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_doubletap";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_finalstand":
				case "specialty_finalstand_upgrade":
					use_trigger.script_sound = "mus_perks_whoswho_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_whoswho_sting";
					use_trigger.target = "vending_chugabud";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_chugabud";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_additionalprimaryweapon":
				case "specialty_additionalprimaryweapon_upgrade":
					use_trigger.script_sound = "mus_perks_mulekick_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_mulekick_sting";
					use_trigger.target = "vending_additionalprimaryweapon";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_additionalprimaryweapon";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_weapupgrade":
					use_trigger.target = "vending_packapunch";
					use_trigger.script_sound = "mus_perks_packa_jingle";
					use_trigger.script_label = "mus_perks_packa_sting";
					use_trigger.longjinglewait = 1;
					perk_machine.targetname = "vending_packapunch";
					flag_pos = getstruct( pos[ i ].target, "targetname" );
					if ( isDefined( flag_pos ) )
					{
						perk_machine_flag = spawn( "script_model", flag_pos.origin );
						perk_machine_flag.angles = flag_pos.angles;
						perk_machine_flag setmodel( flag_pos.model );
						perk_machine_flag.targetname = "pack_flag";
						perk_machine.target = "pack_flag";
					}
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "perks_rattle";
					}
					break;
				case "specialty_deadshot":
				case "specialty_deadshot_upgrade":
					use_trigger.script_sound = "mus_perks_deadshot_jingle";
					use_trigger.script_string = "deadshot_perk";
					use_trigger.script_label = "mus_perks_deadshot_sting";
					use_trigger.target = "vending_deadshot";
					perk_machine.script_string = "deadshot_vending";
					perk_machine.targetname = "vending_deadshot_model";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "deadshot_vending";
					}
					break;
				default:
					if ( isdefined( level._custom_perks[ perk ] ) && isdefined( level._custom_perks[ perk ].perk_machine_set_kvps ) )
					{
						[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( use_trigger, perk_machine, bump_trigger, collision );
					}
					break;
			}
		}
	}
}

givePoints()
{
	level endon("end_game");
	change_collected = false;
	while(1)
	{
		players = get_players();
		for(i=0;i<players.size;i++)
		{
			if( Distance( players[i].origin, self.origin ) < 60 && players[i] GetStance() == "prone" )
			{
				players[i].score += 100;
				change_collected = true;
			}
		}
		if( isdefined( change_collected ) && change_collected )
			break;
		wait .1;
	}
}

//////////////////////////////////////////////////
//MOVE ZOMBIE POWERUPS ON DROPPED FUNCTION BELOW//
//////////////////////////////////////////////////
initCustomPowerupMoving()
{
	level endon( "end_game" );
	flag_wait( "initial_blackscreen_passed" );

	while( !level.gameended )
	{
		level waittill( "powerup_dropped", powerup );
		wait 0.05;
		powerup moveTo( ( 5200, 6313, -15 ), 5, 0, 0 );
	}
}

///////////////////////////////////
//WALLBUY RELATED FUNCTIONS BELOW//
///////////////////////////////////
initCustomWallbuyLocations()
{
	level endon("end_game");
	flag_wait( "initial_blackscreen_passed" );
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location == "default" || location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if ( location != "" )
	{
		match_string = match_string + "_" + location;
	}
	match_string_plus_space = " " + match_string;
	i = 0;
	while ( i < spawnable_weapon_spawns.size )
	{
		spawnable_weapon = spawnable_weapon_spawns[ i ];
		if ( isDefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && is_true( level.headshots_only ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
		{
			spawn_list[ spawn_list.size ] = spawnable_weapon;
			i++;
			continue;
		}
		matches = strtok( spawnable_weapon.script_noteworthy, "," );
		for ( j = 0; j < matches.size; j++ )
		{
			if ( matches[ j ] == match_string || matches[ j ] == match_string_plus_space )
			{
				spawn_list[ spawn_list.size ] = spawnable_weapon;
			}
		}
		i++;
	}
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	i = 0;
	while ( i < spawn_list.size )
	{
		clientfieldname = spawn_list[ i ].zombie_weapon_upgrade + "_" + spawn_list[ i ].origin;
		numbits = 2;
		if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
		{
			spawn_list[ i ].origin = (5270, 6668, 31);
			spawn_list[ i ].angles = ( 0, 0, 0 );
			thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,0,0));
		}
		if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
		{
			spawn_list[ i ].origin = (5004, 6696, 31);
			spawn_list[ i ].angles = ( 0, 0, 0 );
			thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,270,0));
		}
		if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
		{
			spawn_list[ i ].origin = (5143, 6651, 31);
			spawn_list[ i ].angles = ( 0, 0, 0 );
			thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,180,0));
		}
		if ( isDefined( level._wallbuy_override_num_bits ) )
		{
			numbits = level._wallbuy_override_num_bits;
		}
		//registerclientfield( "world", clientfieldname, 1, numbits, "int" );
		target_struct = getstruct( spawn_list[ i ].target, "targetname" );
		if ( spawn_list[ i ].targetname == "buildable_wallbuy" )
		{
			bits = 4;
			if ( isDefined( level.buildable_wallbuy_weapons ) )
			{
				bits = getminbitcountfornum( level.buildable_wallbuy_weapons.size + 1 );
			}
			//registerclientfield( "world", clientfieldname + "_idx", 12000, bits, "int" );
			spawn_list[ i ].clientfieldname = clientfieldname;
			i++;
			continue;
		}
		precachemodel( target_struct.model );
		unitrigger_stub = spawnstruct();
		unitrigger_stub.origin = spawn_list[ i ].origin;
		unitrigger_stub.angles = spawn_list[ i ].angles;
		tempmodel.origin = spawn_list[ i ].origin;
		tempmodel.angles = spawn_list[ i ].angles;
		mins = undefined;
		maxs = undefined;
		absmins = undefined;
		absmaxs = undefined;
		tempmodel setmodel( target_struct.model );
		tempmodel useweaponhidetags( spawn_list[ i ].zombie_weapon_upgrade );
		mins = tempmodel getmins();
		maxs = tempmodel getmaxs();
		absmins = tempmodel getabsmins();
		absmaxs = tempmodel getabsmaxs();
		bounds = absmaxs - absmins;
		unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
		unitrigger_stub.script_width = bounds[ 1 ];
		unitrigger_stub.script_height = bounds[ 2 ];
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
		unitrigger_stub.target = spawn_list[ i ].target;
		unitrigger_stub.targetname = spawn_list[ i ].targetname;
		unitrigger_stub.cursor_hint = "HINT_NOICON";
		if ( spawn_list[ i ].targetname == "weapon_upgrade" )
		{
			unitrigger_stub.cost = get_weapon_cost( spawn_list[ i ].zombie_weapon_upgrade );
			if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
			{
				unitrigger_stub.hint_string = get_weapon_hint( spawn_list[ i ].zombie_weapon_upgrade );
				unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			}
			else
			{
				unitrigger_stub.hint_parm1 = get_weapon_display_name( spawn_list[ i ].zombie_weapon_upgrade );
				if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
				{
					unitrigger_stub.hint_parm1 = "missing weapon name " + spawn_list[ i ].zombie_weapon_upgrade;
				}
				unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
				unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			}
		}
		unitrigger_stub.weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.require_look_at = 1;
		if ( isDefined( spawn_list[ i ].require_look_from ) && spawn_list[ i ].require_look_from )
		{
			unitrigger_stub.require_look_from = 1;
		}
		unitrigger_stub.zombie_weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.clientfieldname = clientfieldname;
		maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
		if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
			{
				unitrigger_stub.origin += level.taser_trig_adjustment;
			}
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
		}
		else
		{
			unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		spawn_list[ i ].trigger_stub = unitrigger_stub;
		i++;
	}
	level._spawned_wallbuys = spawn_list;
	tempmodel delete();
}

customWallbuy( weapon, displayName, cost, ammoCost, origin, angles, fx ) //custom function
{
	level endon("end_game");
	if(!isdefined(weapon) || !isdefined(origin) || !isdefined(angles))
		return;
	if(!isdefined(cost))
		cost = 1000;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	thread playchalkfx(fx, origin + (0,0,55), angles);
	if(is_melee_weapon(weapon) || weapon_no_ammo(weapon))
	{
		trig SetHintString("Hold ^3&&1^7 to buy " + displayName + " [Cost: " + cost + "]");
	}
	else
	{
		trig SetHintString("Hold ^3&&1^7 to buy " + displayName + " [Cost: " + cost + " Ammo: " + ammoCost + " Upg: 4500]");
	}
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player can_buy_weapon())
		{

			if(!player has_weapon_or_upgrade( weapon ) && player.score >= cost)
			{
				player maps/mp/zombies/_zm_score::minus_to_player_score(cost,1);
				player playsound("zmb_cha_ching");
				if(weapon == "one_inch_punch_zm" && isdefined(level.oneInchPunchGiveFunc))
				{
					player thread [[level.oneInchPunchGiveFunc]]();
				}
				else
					player weapon_give(weapon);
				wait 3;
			}
			else
			{
				if(player has_upgrade(weapon) && player.score >= 4500)
				{
					if(player ammo_give(get_upgrade_weapon(weapon)))
					{
						player maps/mp/zombies/_zm_score::minus_to_player_score(4500,1);
						player playsound("zmb_cha_ching");
						wait 3;
					}
				}
				else if(player.score >= ammoCost)
				{
					if(player ammo_give(weapon))
					{
						player maps/mp/zombies/_zm_score::minus_to_player_score(ammoCost,1);
						player playsound("zmb_cha_ching");
						wait 3;
					}
				}
			}
		}
		wait .1;
	}
}

weapon_no_ammo( weapon ) //custom function
{
	if(weapon == "one_inch_punch_zm")
	{
		return 1;
	}
	return 0;
}

playchalkfx( effect, origin, angles ) //custom function
{
	level endon("end_game");
	if(!isdefined(effect))
		return;
	for(;;)
	{
		fx = SpawnFX(level._effect[ effect ], origin,AnglesToForward(angles),AnglesToUp(angles));
		TriggerFX(fx);
		level waittill("connected", player);
		fx Delete();
	}
}

//////////////////////////////	///////////////////////////////////
//WUNDERFIZZ FUNCTIONS BELOW// 	//RECOMMENDED TO LEAVE THIS ALONE//
//////////////////////////////	///////////////////////////////////
initCustomWunderfizz()
{
	level.wunderfizzChecksPower = getDvarIntDefault( "wunderfizzChecksPower", 1 );
	level.wunderfizzCost = getDvarIntDefault( "wunderfizzCost", 1500 );
	wunderfizzUseRandomStart = getDvarIntDefault("wunderfizzUseRandomStart", 0 );
	level.wunderfizz_locations = 0;
	if(wunderfizzUseRandomStart)
		level.currentWunderfizzLocation = 0;
	else
		level.currentWunderfizzLocation = 1;

    wunderfizzSetup((4782,5998,-64),(0,111,0), "zombie_vending_jugg");
    //DO NOT TOUCH BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING
    if(wunderfizzUseRandomStart)
    {
    	level waittill("connected", player);
    	wait 1;
		level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
		level notify("wunderfizzMove");
    }
}

getPerkModel( perk )
{
	if( perk == "specialty_armorvest" )
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_jugg_on";
		else
			return "zombie_vending_jugg";
	}
	if(perk == "specialty_nomotionsensor")
		return "p6_zm_vending_vultureaid";
	if(perk == "specialty_rof")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_doubletap2_on";
		else
			return "zombie_vending_doubletap2";
	}
	if(perk == "specialty_longersprint")
		return "zombie_vending_marathon";
	if(perk == "specialty_fastreload")
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_sleight_on";
		else
			return "zombie_vending_sleight";
	}
	if(perk == "specialty_quickrevive")
		if(level.script == "zm_prison")
			return "p6_zm_vending_electric_cherry_on";
		else
			return "zombie_vending_revive";
	if(perk == "specialty_scavenger")
		return "zombie_vending_tombstone";
	if(perk == "specialty_finalstand")
		return "p6_zm_vending_chugabud";
	if(perk == "specialty_grenadepulldeath")
		return "p6_zm_vending_electric_cherry_on";
	if(perk == "specialty_additionalprimaryweapon")
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_three_gun_on";
		else
			return "zombie_vending_three_gun";
	if(perk == "specialty_deadshot")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_ads_on";
		else
			return "zombie_vending_ads";
	}
	if(perk == "specialty_flakjacket")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_nuke_on";
		else if(level.script == "zm_highrise")
			return "zombie_vending_nuke_on_lo";
		else
			return "zombie_vending_ads";
	}
}

getPerkBottleModel( perk )
{
	if(perk == "specialty_armorvest")
		return "t6_wpn_zmb_perk_bottle_jugg_world";
	if(perk == "specialty_rof")
		return "t6_wpn_zmb_perk_bottle_doubletap_world";
	if(perk == "specialty_longersprint")
		return "t6_wpn_zmb_perk_bottle_marathon_world";
	if(perk == "specialty_nomotionsensor")
		return "t6_wpn_zmb_perk_bottle_vultureaid_world";
	if(perk == "specialty_fastreload")
		return "t6_wpn_zmb_perk_bottle_sleight_world";
	if(perk == "specialty_flakjacket")
		return "t6_wpn_zmb_perk_bottle_nuke_world";
	if(perk == "specialty_quickrevive")
		return "t6_wpn_zmb_perk_bottle_revive_world";
	if(perk == "specialty_scavenger")
		return "t6_wpn_zmb_perk_bottle_tombstone_world";
	if(perk == "specialty_finalstand")
		return "t6_wpn_zmb_perk_bottle_chugabud_world";
	if(perk == "specialty_grenadepulldeath")
		return "t6_wpn_zmb_perk_bottle_cherry_world";
	if(perk == "specialty_additionalprimaryweapon")
		return "t6_wpn_zmb_perk_bottle_mule_kick_world";
	if(perk == "specialty_deadshot")
		return "t6_wpn_zmb_perk_bottle_deadshot_world";
}

wunderfizzSetup( origin, angles, model )
{
	level.wunderfizz_locations++;
	collision = spawn("script_model", origin);
	collision setModel("collision_geo_cylinder_32x128_standard");
	collision rotateTo(angles, .1);
	wunderfizzMachine = spawn("script_model", origin);
	wunderfizzMachine setModel(model);
	wunderfizzMachine rotateTo(angles, .1);
	wunderfizzBottle = spawn("script_model", origin);
	wunderfizzBottle setModel("tag_origin");
	wunderfizzBottle.angles = angles;
	wunderfizzBottle.origin += vectorScale( ( 0, 0, 1 ), 55 );
	wunderfizzMachine.bottle = wunderfizzBottle;
	wunderfizzMachine.location = level.wunderfizz_locations;
	wunderfizzMachine.uses = 0;
	////////////////////////////////////////////////////////////////////
	//fixed the perks output and the wunderfizz was working right away//
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv//
	perks = strToK( "specialty_armorvest specialty_rof specialty_longersprint specialty_fastreload specialty_quickrevive specialty_scavenger", " " );
	cost = level.wunderfizzCost;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	wunderfizzMachine thread wunderfizz(origin, angles, model, cost, perks, trig, wunderfizzBottle);
}

wunderfizz( origin, angles, model, cost, perks, trig, wunderfizzBottle )
{
	level endon("end_game");
	
	self thread playLocFX();
	if(level.wunderfizzChecksPower && level.script != "zm_prison" && level.script != "zm_nuked")
	{
		trig SetHintString("Power Must Be Activated First");
		flag_wait("power_on");
		trig SetHintString(" ");
	}
	else
	{
		trig SetHintString(" ");
	}
	for(;;)
	{
		if(level.currentWunderfizzLocation == self.location)
		{
			self ShowPart("j_ball");
			for(;;)
			{
				trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				trig waittill("trigger", player);
				if(player UseButtonPressed() && player.score >= cost && player.isDrinkingPerk == 0)
				{
					if(player.num_perks < player get_player_perk_purchase_limit())
					{
						if(player.num_perks < perks.size)
						{
							self thread wunderfizzSounds();
							player playsound("zmb_cha_ching");
							self.uses++;
							player.score -= cost;
							trig setHintString(" ");
							rtime = 3;
							wunderfx = SpawnFX(level._effect["wunderfizz_loop"], self.origin,AnglesToForward(angles),AnglesToUp(angles));
							TriggerFX(wunderfx);
							self thread perk_bottle_motion();
							wait .1;
							while(rtime>0)
							{
								for(;;)
								{
									perkForRandom = perks[randomInt(perks.size)];
									if(!(player hasPerk(perkForRandom) || (player maps/mp/zombies/_zm_perks::has_perk_paused(perkForRandom))))
									{
										if(level.script == "zm_tomb")
										{
											self.bottle setModel(getPerkBottleModel(perkForRandom));
											break;
										}
										else
										{
											self setModel(getPerkModel(perkForRandom));
											break;
										}
									}
								}
								if(level.script == "zm_tomb")
								{
									TriggerFX(wunderfx);
									wait .2;
									rtime -= .2;
								}
								else
								{
									wait .1;
									rtime -= .1;
								}
							}
							self notify( "done_cycling" );
							if((self.uses >= RandomIntRange(3,7)) && (level.wunderfizz_locations > 1))
							{
								if(level.script == "zm_tomb")
								{
									self.bottle setModel("t6_wpn_zmb_perk_bottle_bear_world");
									if(level.script != "zm_tomb")
										self setModel("zombie_teddybear");
									level notify("wunderSpinStop");
									wunderfx Delete();
									wait 7;
									self.bottle setModel("tag_origin");
									level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
									level notify("wunderfizzMove");
									self setModel(model);
									self.uses = 0;
									break;
								}
								else{
									self setModel("zombie_teddybear");
									self.angles = angles + (0,-90,0);
									wunderfx Delete();
									player.score += cost;
									trig SetHintString("Wunderfizz is Moving");
									wait 7;
									level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
									level notify("wunderfizzMove");
									self.angles = angles;
									self setModel(model);
									self.uses = 0;
									break;
								}
							}
							else{
								perklist = array_randomize(perks);
								for(j=0;j<perklist.size;j++)
								{
									if(!(player hasPerk(perklist[j]) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perklist[j]))))
									{
										perkName = getPerkName(perklist[j]);
										if(level.script == "zm_tomb")
										{
											self.bottle setModel(getPerkBottleModel(perklist[j]));

										}
										else
										{
											if(level.script == "zm_prison")
											{
												self setModel(getPerkModel(perklist[j]));
												fx = SpawnFX(level._effect["electriccherry"], origin, AnglesToForward(angles),AnglesToUp(angles));
											}
											else
											{
												self setModel(getPerkModel(perklist[j]) + "_on");
												fx = SpawnFX(level._effect["tombstone_light"], origin, AnglesToForward(angles),AnglesToUp(angles));
											}
											TriggerFX(fx);
										}
										trig SetHintString("Hold ^3&&1^7 for " + perkName);
										time = 7;
										while(time > 0)
										{
											if(player UseButtonPressed() && distance(player.origin, trig.origin) < 65 && player can_buy_weapon())
											{
												player thread givePerk(perklist[j]);
												break;
											}
											TriggerFX(wunderfx);
											wait .2;
											time -= .2;
										}
										self setModel(model);
										self.bottle setModel("tag_origin");
										trig SetHintString(" ");
										level notify("wunderSpinStop");
										fx Delete();
										break;
									}
								}
								wunderfx Delete();
								wait 2;
								trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
							}
						}
						else
						{
							trig SetHintString("You Have All " + perks.size + " Perks");
							wait 2;
							trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
						}
					}
					else{
						trig SetHintString("You Can Only Hold ^3" + player get_player_perk_purchase_limit() + "^7 Perks");
						wait 2;
						trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
					}
				}
				wait .1;
			}
		}
		else{
			trig SetHintString("Wunderfizz Orb is at Another Location");
			self HidePart("j_ball");
			level waittill("wunderfizzMove");
		}
		wait .1;
	}
}

can_buy_weapon() //checked matches cerberus output
{
	if ( isDefined( self.is_drinking ) && self.is_drinking > 0 )
	{
		return 0;
	}
	if ( self hacker_active() )
	{
		return 0;
	}
	if ( self IsSwitchingWeapons() )
	{
		return 0;
	}
	current_weapon = self getcurrentweapon();
	if ( is_placeable_mine( current_weapon ) || is_equipment_that_blocks_purchase( current_weapon ) )
	{
		return 0;
	}
	if ( self in_revive_trigger() )
	{
		return 0;
	}
	if ( current_weapon == "none" )
	{
		return 0;
	}
	return 1;
}

playLocFX()
{
	level endon("end_game");
	level waittill("connected", player);
	for(;;)
	{
		fx = SpawnFX(level._effect["lght_marker"], self.origin);
		if(self.location == level.currentWunderfizzLocation)
		{
			TriggerFX(fx);
		}
		level waittill("wunderfizzMove");
		fx Delete();
	}
}

chooseLocation( currLoc )
{
	level endon("end_game");
	for(;;)
	{
		loc = RandomIntRange(1, level.wunderfizz_locations + 1);
		if(currLoc != loc)
		{
			return loc;
		}
		wait .1;
	}
}

perk_bottle_motion()
{
	putouttime = 3;
	putbacktime = 10;
	v_float = anglesToForward( self.angles - ( 0, 90, 0 ) ) * 10;
	self.bottle.origin = self.origin + ( 0, 0, 53 );
	self.bottle.angles = self.angles;
	self.bottle.origin -= v_float;
	self.bottle moveto( self.bottle.origin + v_float, putouttime, putouttime * 0.5 );
	self.bottle.angles += ( 0, 0, 10 );
	self.bottle rotateyaw( 720, putouttime, putouttime * 0.5 );
	self waittill( "done_cycling" );
	self.bottle.angles = self.angles;
	self.bottle moveto( self.bottle.origin - v_float, putbacktime, putbacktime * 0.5 );
	self.bottle rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}

wunderfizzSounds()
{
	sound_ent = spawn("script_origin", self.origin);
	sound_ent StopSounds();
	sound_ent PlaySound( "zmb_rand_perk_start");
	sound_ent PlayLoopSound("zmb_rand_perk_loop", 0.5);
	level waittill("wunderSpinStop");
	sound_ent StopLoopSound(1);
	sound_ent PlaySound("zmb_rand_perk_stop");
	sound_ent Delete();
}

givePerk( perk )
{
	if(!(self hasPerk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
	{
		self.isDrinkingPerk = 1;
		gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
        self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
       	self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
       	self.isDrinkingPerk = 0;
    	if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        	return;
    	self notify("burp");
	}
}

getPerkName( perk )
{
	if(perk == "specialty_armorvest")
		return "Juggernog";
	if(perk == "specialty_rof")
		return "Double Tap";
	if(perk == "specialty_longersprint")
		return "Stamin-Up";
	if(perk == "specialty_fastreload")
		return "Speed Cola";
	if(perk == "specialty_additionalprimaryweapon")
		return "Mule Kick";
	if(perk == "specialty_quickrevive")
		return "Quick Revive";
	if(perk == "specialty_finalstand")
		return "Who's Who";
	if(perk == "specialty_grenadepulldeath")
		return "Electric Cherry";
	if(perk == "specialty_flakjacket")
		return "PHD Flopper";
	if(perk == "specialty_deadshot")
		return "Deadshot Daiquiri";
	if(perk == "specialty_scavenger")
		return "Tombstone";
	if(perk == "specialty_nomotionsensor")
		return "Vulture Aid";
}

/*
getPerks() //This function was not working at all on console womp womp
{
	perks = [];
	//Order is Rainbow
	if(isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
	{
		perks[perks.size] = "specialty_armorvest";
	}
	if(isDefined(level._custom_perks[ "specialty_nomotionsensor"] ))
	{
		perks[perks.size] = "specialty_nomotionsensor";
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		perks[perks.size] = "specialty_rof";
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		perks[perks.size] = "specialty_longersprint";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		perks[perks.size] = "specialty_fastreload";
	}
	if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
	{
		perks[perks.size] = "specialty_additionalprimaryweapon";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		perks[perks.size] = "specialty_quickrevive";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk && level.customMap != "building1top" && level.customMap != "redroom")
	{
		perks[perks.size] = "specialty_finalstand";
	}
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ] ))
	{
		perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ]) && level.script != "zm_buried" )
	{
		perks[perks.size] = "specialty_flakjacket";
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		perks[perks.size] = "specialty_deadshot";
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		perks[perks.size] = "specialty_scavenger";
	}
	return perks;
}
*/

/////////////////////////////////////////////////
//MOVE & DISABLE ZOMBIE SPAWNERD FUNCTION BELOW//
/////////////////////////////////////////////////
/*
initModifyZombieSpawners()
{
	level thread modifyZombieSpawners();
}
*/
//////////////////////////////////////
//MODIFY ZOMBIE SPEED FUNCTION BELOW//
//////////////////////////////////////
initOverrideZombieSpeed()
{
	level endon( "end_game" );

	level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.speed_change_round = undefined;

	while ( !level.intermission )
	{
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( zombies[ i ].zombie_move_speed != "sprint" )
			{
				zombies[ i ] set_zombie_run_cycle( "sprint" );
			}
		}
		wait 1;
	}
}

//////////////////////////////////////////
//START POWER IMMEDIATELY FUNCTION BELOW//
//////////////////////////////////////////
initPowerOnGameStart()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 2;
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
}


/////////////////////////////////////
//ZOMBIE HITMARKERS FUNCTIONS BELOW//
/////////////////////////////////////
initZombieHitmarkers()
{
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback( ::do_hitmarker );
    maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback( ::do_hitmarker_death );
}

setupZombieHitmarkers()
{
	self.hitsoundtracker = 1;
	
    self.hud_damagefeedback = newdamageindicatorhudelem( self );
    self.hud_damagefeedback.horzalign = "center";
    self.hud_damagefeedback.vertalign = "middle";
    self.hud_damagefeedback.x = -12;
    self.hud_damagefeedback.y = -12;
    self.hud_damagefeedback.alpha = 0;
    self.hud_damagefeedback.archived = 1;
    self.hud_damagefeedback.color = ( 1, 1, 1 );
    self.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
    
    self.hud_damagefeedback_ondeath = newdamageindicatorhudelem( self );
    self.hud_damagefeedback_ondeath.horzalign = "center";
    self.hud_damagefeedback_ondeath.vertalign = "middle";
    self.hud_damagefeedback_ondeath.x = -12;
    self.hud_damagefeedback_ondeath.y = -12;
    self.hud_damagefeedback_ondeath.alpha = 0;
    self.hud_damagefeedback_ondeath.archived = 1;
    self.hud_damagefeedback_ondeath.color = ( 1, 0, 0 );
    self.hud_damagefeedback_ondeath setshader( "damage_feedback", 24, 48 );
}

do_hitmarker_internal( mod, death )
{
    if( !isPlayer( self ) )
        return;

    if( !isDefined( death ))
        death = false;

    if( isDefined( mod ) && mod != "MOD_CRUSH" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_HIT_BY_OBJECT" )
    {
    	if( death )
    	{
        	self.hud_damagefeedback_ondeath.alpha = 1;
        	self.hud_damagefeedback_ondeath fadeovertime( 1 );
        	self.hud_damagefeedback_ondeath.alpha = 0;
    	}
    	else
    	{
        	self.hud_damagefeedback.alpha = 1;
        	self.hud_damagefeedback fadeovertime( 1 );
        	self.hud_damagefeedback.alpha = 0;
    	}
    }
}

do_hitmarker( mod, hit_location, hit_origin, player, amount )
{
    if ( isDefined( player ) && isPlayer( player ) && player != self )
        player thread do_hitmarker_internal( mod );

    return false;
}

do_hitmarker_death()
{
    // self is the zombie victim in this case
    if ( isDefined( self.attacker ) && isPlayer( self.attacker ) && self.attacker != self )
    {
        self.attacker thread do_hitmarker_internal( self.damagemod, true );
	}
}

//////////////////////////////////////////
//CUSTOM PERK LIMIT FUNCTIONS/////////////
//THESE WERE PUT TOGETHER BY GERARDS0406//
//////////////////////////////////////////
addPerkSlot()
{
	self endon( "disconnect" );
	level endon( "end_game" );
	perks = strToK( "specialty_armorvest specialty_rof specialty_longersprint specialty_fastreload specialty_quickrevive specialty_scavenger", " " );
	killsNeeded = getDvarIntDefault( "perkSlotIncreaseKills", 100 );
	completedCount = 0;
	for( ;; )
	{
		if( killsNeeded == 0 )
			break;
		if( ( self.kills - ( killsNeeded * completedCount ) ) >= killsNeeded )
		{
			self increment_player_perk_purchase_limit();
			self IPrintLnBold( "You can now hold ^1" + self.player_perk_purchase_limit + " ^7perks!" );
			completedCount++;
		}
		if( ( perks.size - level.perk_purchase_limit ) <= completedCount )
			break;
		wait .1;
	}
}

get_player_perk_purchase_limit()
{
	if ( isDefined( self.player_perk_purchase_limit ) )
	{
		return self.player_perk_purchase_limit;
	}
	return level.perk_purchase_limit;
}

increment_player_perk_purchase_limit()
{
	perks = strToK( "specialty_armorvest specialty_rof specialty_longersprint specialty_fastreload specialty_quickrevive specialty_scavenger", " " );
	if ( !isDefined( self.player_perk_purchase_limit ) )
	{
		self.player_perk_purchase_limit = level.perk_purchase_limit;
	}
	if ( self.player_perk_purchase_limit < perks.size )
	{
		self.player_perk_purchase_limit++;
	}
}

/////////////////////////////////////
//BUILDABLE RELATED FUNCTIONS BELOW//
/////////////////////////////////////
initBuildAllBuildables()
{
	flag_wait( "initial_blackscreen_passed" );
	//iprintln( "BUILDING!!!!" );
	buildbuildable( "dinerhatch", 1 );
	buildbuildable( "pap", 1 );
	buildbuildable( "turbine" );
	buildbuildable( "electric_trap" );
	buildbuildable( "riotshield_zm", 1 );
	removebuildable( "jetgun_zm" );
	removebuildable( "powerswitch" );
	removebuildable( "sq_common" );
	removebuildable( "busladder" );
	removebuildable( "bushatch" );
	removebuildable( "cattlecatcher" );
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}
	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}
			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

buildbuildable( buildable, craft ) //credit to Jbleezy for this function
{
	if ( !isDefined( craft ) )
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach ( stub in level.buildable_stubs )
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}

				i = 0;
				foreach ( piece in stub.buildablezone.pieces )
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if ( !craft && i > 0 )
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built( piece );
					}
					i++;
				}
				return;
			}
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

get_equipname() //credit to Jbleezy for this function
{
	if ( self.equipname == "turbine" )
	{
		return "Turbine";
	}
	else if ( self.equipname == "electric_trap" )
	{
		return "Electric Trap";
	}
	else if ( self.equipname == "riotshield_zm" )
	{
		return "Zombie Shield";
	}
}

//MODIFY ZOMBIE SPAWNPOINTS//
create_spawner_list() //modified function
{
	flag_wait( "initial_blackscreen_passed" );
	level.zombie_spawn_locations = [];
	level.inert_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.quad_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_astro_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	level.zombie_napalm_locations = [];
	zkeys = getarraykeys( level.zones );
	for ( z = 0; z < zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		for ( i = 0; i < zone.spawn_locations.size; i++ )
		{
			if( level.script == "zm_transit" )
			{
				if ( zone.spawn_locations[ i ].origin == ( -11447, -3424, 254.2 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				if ( zone.spawn_locations[ i ].origin == ( -10944, -3846, 221.14 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				if ( zone.spawn_locations[ i ].origin == ( -11093, 393, 192 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				if ( zone.spawn_locations[ i ].origin == ( -11347, -3134, 283.9 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11332.9, -2876.95, 207 );
				}
				if ( zone.spawn_locations[ i ].origin == ( -11182, -4384, 196.7 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11115, -3152, 207 );
				}
				if ( zone.spawn_locations[ i ].origin == ( -11251, -4397, 200.02 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11107.8, -1301, 184 );
				}
				if ( zone.spawn_locations[ i ].origin == ( 8394, -2545, -205.16 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
				{
					zone.spawn_locations[ i ].origin = ( 10249.4, 7691.71, -569.875 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( 9339, 6411, -566.9 ) )
				{
					zone.spawn_locations[ i ].origin = ( 9993.29, 7486.83, -582.875 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( 9914, 8408, -576 ) )
				{
					zone.spawn_locations[ i ].origin = ( 9993.29, 7550, -582.875 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( 9429, 5281, -539.6 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( 13019.1, 7382.5, -754 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( -3825, -6576, -52.7 ) )
				{
					zone.spawn_locations[ i ].origin = ( -4061.03, -6754.44, -58.0897 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -3450, -6559, -51.9 ) )
				{
					zone.spawn_locations[ i ].origin = ( -4060.93, -6968.64, -65.3446 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -4165, -6098, -64 ) )
				{
					zone.spawn_locations[ i ].origin = ( -4239.78, -6902.81, -57.0494 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -5058, -5902, -73.4 ) )
				{
					zone.spawn_locations[ i ].origin = ( -4846.77, -6906.38, 54.8145 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -6462, -7159, -64 ) )
				{
					zone.spawn_locations[ i ].origin = ( -6201.18, -7107.83, -59.7182 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -5130, -6512, -35.4 ) )
				{
					zone.spawn_locations[ i ].origin = ( -5396.36, -6801.88, -60.0821 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -6531, -6613, -54.4 ) )
				{
					zone.spawn_locations[ i ].origin = ( -6116.62, -6586.81, -50.8905 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -5373, -6231, -51.9 ) )
				{
					zone.spawn_locations[ i ].origin = ( -4827.92, -7137.19, -62.9082 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -5752, -6230, -53.4 ) )
				{
					zone.spawn_locations[ i ].origin = ( -5572.47, -6426, -39.1894 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -5540, -6508, -42 ) )
				{
					zone.spawn_locations[ i ].origin = ( -5789.51, -6935.81, -57.875 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11093 , 393 , 192 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -10944, -3846, 221.14 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11351.7, -1988.58, 184.125 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11251, -4397, 200.02 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11334 , -5280, 212.7 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11600.6, -1918.41, 192.125 );
					zone.spawn_locations[ i ].script_noteworthy = "riser_location";
				}
				else if (zone.spawn_locations[ i ].origin == ( -10836, 1195, 209.7 ) )
				{
					zone.spawn_locations[ i ].origin = ( -11241.2, -1118.76, 184.125 );
				}
				/*
				else if ( zone.spawn_locations[ i ].origin == ( -10747, -63, 203.8 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11347, -3134, 283.9 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11447, -3424, 254.2 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( -10761, 155, 236.8 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				else if ( zone.spawn_locations[ i ].origin == ( -11110, -2921, 195.79 ) )
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				*/
				else if ( zone.spawn_locations[ i ].targetname == "zone_trans_diner_spawners")
				{
					zone.spawn_locations[ i ].is_enabled = 0;
				}
				if ( zone.spawn_locations[ i ].is_enabled )
				{
					level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = zone.spawn_locations[ i ];
				}
			}
			if(zone.spawn_locations[ i ].is_enabled)
			{
				level.zombie_spawn_locations[level.zombie_spawn_locations.size] = zone.spawn_locations[i];
			}
			for(x = 0; x < zone.inert_locations.size; x++)
			{
				if(zone.inert_locations[x].is_enabled)
				{
					level.inert_locations[level.inert_locations.size] = zone.inert_locations[x];
				}
			}
			for(x = 0; x < zone.dog_locations.size; x++)
			{
				if(zone.dog_locations[x].is_enabled)
				{
					level.enemy_dog_locations[level.enemy_dog_locations.size] = zone.dog_locations[x];
				}
			}
			for(x = 0; x < zone.screecher_locations.size; x++)
			{
				if(zone.screecher_locations[x].is_enabled)
				{
					level.zombie_screecher_locations[level.zombie_screecher_locations.size] = zone.screecher_locations[x];
				}
			}
			/*
			for(x = 0; x < zone.avogadro_locations.size; x++)
			{
				if(zone.avogadro_locations[x].is_enabled)
				{
					level.zombie_avogadro_locations[level.zombie_avogadro_locations.size] = zone.avogadro_locations[x];
				}
			}
			*/
			for(x = 0; x < zone.quad_locations.size; x++)
			{
				if(zone.quad_locations[x].is_enabled)
				{
					level.quad_locations[level.quad_locations.size] = zone.quad_locations[x];
				}
			}
			for(x = 0; x < zone.leaper_locations.size; x++)
			{
				if(zone.leaper_locations[x].is_enabled)
				{
					level.zombie_leaper_locations[level.zombie_leaper_locations.size] = zone.leaper_locations[x];
				}
			}
			for(x = 0; x < zone.astro_locations.size; x++)
			{
				if(zone.astro_locations[x].is_enabled)
				{
					level.zombie_astro_locations[level.zombie_astro_locations.size] = zone.astro_locations[x];
				}
			}
			for(x = 0; x < zone.napalm_locations.size; x++)
			{
				if(zone.napalm_locations[x].is_enabled)
				{
					level.zombie_napalm_locations[level.zombie_napalm_locations.size] = zone.napalm_locations[x];
				}
			}
			for(x = 0; x < zone.brutus_locations.size; x++)
			{
				if(zone.brutus_locations[x].is_enabled)
				{
					level.zombie_brutus_locations[level.zombie_brutus_locations.size] = zone.brutus_locations[x];
				}
			}
			for(x = 0; x < zone.mechz_locations.size; x++)
			{
				if(zone.mechz_locations[x].is_enabled)
				{
					level.zombie_mechz_locations[level.zombie_mechz_locations.size] = zone.mechz_locations[x];
				}
			}
		}
	}
}
