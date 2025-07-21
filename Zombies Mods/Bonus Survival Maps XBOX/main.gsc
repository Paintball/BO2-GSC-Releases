//#include codescripts\character;
//#include maps\mp\_utility;
//#include common_scripts\utility;
//#include maps\mp\gametypes_zm\_hud_util;

//#include maps\mp\gametypes_zm\_globallogic;
//#include maps\mp\gametypes_zm\_spawnlogic;
//#include maps\mp\zombies\_load;
//#include maps\mp\zombies\_zm;
//#include maps\mp\zombies\_zm_utility;
//#include maps\mp\zombies\_zm_magicbox;
//#include maps\mp\zombies\_zm_perks;
//#include maps\mp\zombies\_zm_spawner;
//#include maps\mp\zombies\_zm_weapons;

///////////////////////////////////
//INITIALIZE GAME FUNCTIONS BELOW//
///////////////////////////////////
init()
{
	setupGame();
	thread initPrecache();
	thread initCallbacks();
	thread initGameDvars();
	thread initLevelVariables();
	thread initLevelThreads();
	thread initPlayerThreads();
}

setupGame()
{
	//these set the first map & rotation//
	getGameDvar( "customMap", "Cabin" );
	getGameDvar( "mapRotation", "Cabin Tunnel Diner Cornfield Power" );
	getGameDvar( "mapRoationEnabled", true );
	level thread mapRotate();
}

mapRotate()
{
	setNextMap();
	level waittill( "end_game" );
	currentMap = getDvar( "customMap" );
	nextMap = getDvar( "nextMap" );
	if( currentMap != nextMap )
		changeMap( nextMap );
}

setNextMap()
{
	currentMap = getDvar( "customMap" );
	setDvar( "nextMap", currentMap );
	rotationEnabled = getDvar( "mapRotationEnabled" );
	mapList = getDvar( "mapRotation" );
	mapListArray = strToK( mapList, " " );
	mapListSize = int( mapListArray.size );
	
	if( common_scripts\utility::is_true( rotationEnabled ) && mapListSize > 1 )
	{
		for( i = 0; i < mapListSize; i++ )
		{
			if( currentMap == mapListArray[ i ] )
			{
				if( ( i + 1 ) == mapListSize )
				{
					return setDvar( "nextMap", mapListArray[ 0 ] );
				}
				return setDvar( "nextMap", mapListArray[ i + 1 ] );
			}
			wait 0.05;
		}
	}
}

changeMap( map )
{
	iprintln( "^3Next Map: ^1" + displayCustomMapName( map ) );
	setDvar( "customMap", map );
}

displayCustomMapName( map )
{
	if( map == "Power" )
		return "Power Station";
	return map;
}

getGameDvar( dvar, value )
{
    if( getDvar( dvar ) == "" && isDefined( value ) )
    {
        setdvar( dvar, value );
        return getDvar( dvar );
    }
    return getDvar( dvar );
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
	while( maps\mp\_utility::isPreGame() )
		wait 1;
	level.get_player_perk_purchase_limit = ::get_player_perk_purchase_limit;
}

initGameDvars()
{
	setDvar( "scr_screecher_ignore_player", 1 );	//no stupid ass denizens
}

initLevelVariables()
{
	level.player_out_of_playable_area_monitor = 0;
	//thread initCustomPerkSpawnpoints();
	thread initCustomPlayerSpawnpoints();
	level.zombie_weapons[ "emp_grenade_zm" ].is_in_box = 0;
	arrayremovevalue( level.zombie_include_weapons, level.zombie_include_weapons[ "emp_grenade_zm" ] );
}

initLevelThreads()
{
	while( maps\mp\_utility::isPreGame() )
	{
		wait 0.5;
	}
	level.player_out_of_playable_area_monitor = 0;
	level thread deleteTheBus();
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

deleteTheBus()
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap == "Cabin" )
		return;
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	level.the_bus notify( "death" );
	level.the_bus destroy();
	level.busschedule notify( "death" );
	level.busschedule = undefined;
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
	precacheModel( "collision_player_wall_512x512x10" );
	precacheModel( "collision_player_wall_128x128x10" );
	precacheModel( "t5_foliage_bush05" );
    precacheModel( "veh_t6_civ_60s_coupe_dead" );
    precacheModel( "veh_t6_civ_smallwagon_dead" );
    precacheModel( "veh_t6_civ_microbus_dead" );
    precacheModel( "veh_t6_civ_movingtrk_cab_dead" );
    precacheModel( "p6_zm_rocks_small_cluster_01" );
	precacheModel( "veh_t6_civ_bus_zombie" );
	precacheModel( "zombie_teddybear" );
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
	vending_machines = strTok( "zombie_vending_jugg zombie_vending_doubletap2 zombie_vending_marathon zombie_vending_sleight zombie_vending_three_gun zombie_vending_revive zombie_vending_tombstone p6_anim_zm_buildable_pap", " " );
	foreach( machine in vending_machines )
	{
		precacheModel( machine );
		precacheModel( machine + "_on" );
	}
}

/////////////////////////////////
//SETUP SPAWNPOINTS ARRAY BELOW//
/////////////////////////////////
initCustomPlayerSpawnpoints()
{
	//supports up to 8 players//
	//cabin spawnpoints//
	createCustomSpawnpoint( "Cabin", ( 5071, 7022, -20 ), ( 0, 315, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5358, 7034, -20 ), ( 0, 246, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5078, 6733, -20 ), ( 0, 56, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5334, 6723, -20 ), ( 0, 123, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5057, 6583, -10 ), ( 0, 0, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5305, 6591, -20 ), ( 0, 180, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5350, 6882, -20 ), ( 0, 180, 0 ) );
	createCustomSpawnpoint( "Cabin", ( 5102, 6851, -20 ), ( 0, 0, 0 ) );
	//tunnel spawnpoints//
	createCustomSpawnpoint( "Tunnel", ( -11196, -837, 192 ), ( 0, -94, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -11386, -863, 192 ), ( 0, -44, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -11405, -1000, 192 ), ( 0, -32, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -11498, -1151, 192 ), ( 0, 4, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -11398, -1326, 191 ), ( 0, 50, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -11222, -1345, 192 ), ( 0, 89, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -10934, -1380, 192 ), ( 0, 157, 0 ) );
	createCustomSpawnpoint( "Tunnel", ( -10999, -1072, 192 ), ( 0, -144, 0 ) );
	//diner spawnpoints//
	createCustomSpawnpoint( "Diner", ( -3991, -7317, -63 ), ( 0, 161, 0 ) );
	createCustomSpawnpoint( "Diner", ( -4231, -7395, -60 ), ( 0, 120, 0 ) );
	createCustomSpawnpoint( "Diner", ( -4127, -6757, -54 ), ( 0, 217, 0 ) );
	createCustomSpawnpoint( "Diner", ( -4465, -7346, -58 ), ( 0, 173, 0 ) );
	createCustomSpawnpoint( "Diner", ( -5770, -6600, -55 ), ( 0, -106, 0 ) );
	createCustomSpawnpoint( "Diner", ( -6135, -6671, -56 ), ( 0, -46, 0 ) );
	createCustomSpawnpoint( "Diner", ( -6182, -7120, -60 ), ( 0, 51, 0 ) );
	createCustomSpawnpoint( "Diner", ( -5882, -7174, -61 ), ( 0, 99, 0 ) );
	//cornfield spawnpoints//
	createCustomSpawnpoint( "Cornfield", ( 7521, -545, -198 ), ( 0, 40, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 7751, -522, -202 ), ( 0, 145, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 7691, -395, -201 ), ( 0, -131, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 7536, -432, -199 ), ( 0, -24, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 13745, -336, -188 ), ( 0, -178, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 13758, -681, -188 ), ( 0, -179, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 13816, -1088, -189 ), ( 0, -177, 0 ) );
	createCustomSpawnpoint( "Cornfield", ( 13752, -1444, -182 ), ( 0, -177, 0 ) );
	//power station spawnpoints//
	createCustomSpawnpoint( "Power", ( 11288, 7988, -550 ), ( 0, -137, 0 ) );
	createCustomSpawnpoint( "Power", ( 11284, 7760, -549 ), ( 0, 141775, 0 ) );
	createCustomSpawnpoint( "Power", ( 10784, 7623, -584 ), ( 0, -10, 0 ) );
	createCustomSpawnpoint( "Power", ( 10866, 7473, -580 ), ( 0, 21, 0 ) );
	createCustomSpawnpoint( "Power", ( 10261, 8146, -580 ), ( 0, -31, 0 ) );
	createCustomSpawnpoint( "Power", ( 10595, 8055, -541 ), ( 0, -43, 0 ) );
	createCustomSpawnpoint( "Power", ( 10477, 7679, -567 ), ( 0, -9, 0 ) );
	createCustomSpawnpoint( "Power", ( 10165, 7879, -570 ), ( 0, -15, 0 ) );
}

createCustomSpawnpoint( map, origin, angles )
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap != map )
		return;
	if( !isDefined( level.customSpawnpoints ) )
		level.customSpawnpoints = [];
	index = level.customSpawnpoints.size;
	level.customSpawnpoints[ index ] = spawnstruct();
	level.customSpawnpoints[ index ].origin = origin;
	level.customSpawnpoints[ index ].angles = angles;
}

initCustomPerkSpawnpoints()
{
	/*
	level.customPerkArray = array( "specialty_weapupgrade" );

	level.customPerks["specialty_weapupgrade"] = spawnstruct();
	level.customPerks["specialty_weapupgrade"].origin = ( 5405,6869,-23 );
	level.customPerks["specialty_weapupgrade"].angles = ( 0, 90, 0 );
	level.customPerks["specialty_weapupgrade"].model = "tag_origin";
	level.customPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
	*/
}

/////////////////////////////////////
//SETUP MAP BARRIERS & BUSHES BELOW//
/////////////////////////////////////
initCustomMapBarriers() //custom function
{
	//Cabin Barriers//
	spawnModel( "Cabin", ( 5568, 6336, -70 ), ( 0, 266, 0 ), "collision_player_wall_512x512x10", true );
	spawnModel( "Cabin", ( 5074, 7089, -24 ), ( 0, 0, 0 ), "collision_player_wall_128x128x10", true );
	spawnModel( "Cabin", ( 4985, 5862, -64 ), ( 0, 159, 0 ), "collision_player_wall_512x512x10", true );
	spawnModel( "Cabin", ( 5207, 5782, -64 ), ( 0, 159, 0 ), "collision_player_wall_512x512x10", true );
	spawnModel( "Cabin", ( 4819, 6475, -64 ), ( 0, 258, 0 ), "collision_player_wall_512x512x10", true );
	spawnModel( "Cabin", ( 4767, 6200, -64 ), ( 0, 258, 0 ), "collision_player_wall_512x512x10", true );
	spawnModel( "Cabin", ( 5459, 5683, -64 ), ( 0, 159, 0 ), "collision_player_wall_512x512x10", true );
	//Bushes//
	spawnModel( "Cabin", ( 5548.5, 6358, -72 ), ( 0, 271, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5543.79, 6269.37, -64.75 ), ( 0, -45, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5553.23, 6446, -76 ), ( 0, 90, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5534, 6190.8, -64 ), ( 0, 180, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5565.1, 5661, -64 ), ( 0, -45, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5380.4, 5738, -64 ), ( 0, 80, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5467, 5702, -64 ), ( 0, 40, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5323.1, 5761.7, -64 ), ( 0, 120, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5261, 5787.5, -64 ), ( 0, 150, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5199, 5813.5, -64 ), ( 0, 230, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5137, 5839.5, -64 ), ( 0, 0, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5075, 5865.5, -64 ), ( 0, 70, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5017, 5877.5, -64 ), ( 0, 70, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4951, 5917.5, -64 ), ( 0, 0, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4889, 5943.5, -64 ), ( 0, 245, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4810, 5926.5, -64 ), ( 0, 53, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4762, 6069, -64 ), ( 0, 100, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4777, 6149, -64 ), ( 0, 200, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4792, 6229, -64 ), ( 0, 100, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4807, 6309, -64 ), ( 0, 200, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4822, 6389, -64 ), ( 0, 100, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4837, 6469, -64 ), ( 0, 200, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4852, 6549, -64 ), ( 0, 100, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 4867, 6629, -64 ), ( 0, 200, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5557.4, 6524.5, -80 ), ( 0, 200, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5078.68, 7172.37, -64 ), ( 0, 234, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5017, 7130.22, -64 ), ( 0, 45, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5154.25, 7133.65, -64 ), ( 0, 130, 0 ), "t5_foliage_bush05", false );
	spawnModel( "Cabin", ( 5105.25, 7166.65, -64 ), ( 0, 292, 0 ), "t5_foliage_bush05", false );
	createTeddyBear( "Cabin", ( 5020.57, 6857.91, -1 ), ( 0, 0, 0 ) );
	createTeddyBear( "Cabin", ( 5210.24, 6855.34, 188.624 ), ( 15, 87.8777, 0 ) );
	createTeddyBear( "Cabin", ( 4887.6, 6776.57, -58.0821 ), ( 0, -40.4, 0 ) );
	createTeddyBear( "Cabin", ( 4767.17, 5923.71, -63.875 ), ( 0, 55.5, 0 ) );
	createTeddyBear( "Cabin", ( 5487.48, 6095.5, 198.279 ) + ( 0, 0, 45 ), ( -15, 173.197, 0 ) );
	createTeddyBear( "Cabin", ( 5214.16, 6553.36, 57.1931 ) + ( 0, 0, 50 ), ( 0, -91, 0 ) ); //-75
	//TUNNEL BARRIERS
	spawnModel( "Tunnel", ( -11250, -520, 255 ), ( 0, 172, 0 ), "veh_t6_civ_movingtrk_cab_dead" );
	spawnModel( "Tunnel", ( -11250, -580, 255 ), ( 0, 180, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Tunnel", ( -11506, -580, 255 ), ( 0, 180, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Tunnel", ( -10770, -3240, 255 ), ( 0, 214, 0 ), "veh_t6_civ_movingtrk_cab_dead" );
	spawnModel( "Tunnel", ( -10840, -3190, 255 ), ( 0, 214, 0 ), "collision_player_wall_256x256x10" );
	createTeddyBear( "Tunnel", ( -11197.4, -1147.44, 184.125 ) - ( 0, 0, 2.5 ), ( -90, -28, 0 ) );
	createTeddyBear( "Tunnel", ( -11440.4, 498.007, 192.125 ), ( -35, -63.2275, 0 ) );
	createTeddyBear( "Tunnel", ( -11078.8, -1697.13, 347.396 ) + ( 0, 0, 40 ), ( 0, -86.7164, -20 ) );
	createTeddyBear( "Tunnel", ( -11311.5, -1753.65, 180.696 ) + ( 0, 0, 30 ), ( -30, -38.9861, -5 ) );
	createTeddyBear( "Tunnel", ( -12232.2, -1082.71, 228.125 ) + ( 0, 0, 50 ), ( 0, 0, -90 ) );
	createTeddyBear( "Tunnel", ( -12176.4, -2349.92, 228.125 ), ( 0, 0, 0 ) );
    //diner clips//
    spawnModel( "Diner", ( -3952, -6957, -67 ), ( 0, 82, 0 ), "collision_player_wall_256x256x10" );
    spawnModel( "Diner", ( -4173, -6679, -60 ), ( 0, 0, 0 ), "collision_player_wall_512x512x10" );
    spawnModel( "Diner", ( -5073,-6732,-59 ), ( 0, 328, 0 ), "collision_player_wall_512x512x10" );
    spawnModel( "Diner", ( -6104,-6490,-38 ), ( 0, 2, 0 ), "collision_player_wall_512x512x10" );
    spawnModel( "Diner", ( -5850,-6486,-38 ), ( 0, 0, 0 ), "collision_player_wall_256x256x10" );
    spawnModel( "Diner", ( -5624,-6406,-40 ), ( 0, 226, 0 ), "collision_player_wall_256x256x10" );
    spawnModel( "Diner", ( -6348,-6886,-55 ), ( 0, 98, 0 ), "collision_player_wall_512x512x10" );
	//killzone//
	//-6504.11, -7188.68, -63.875
    //diner blockade models//
    spawnModel( "Diner", ( -5787.8, 4677.4, 5.5 ), ( 8.376, 234.842, -92 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -7932.1, 5228.3, -58 ), ( 0.4, 58.8821, -0.650838 ), "veh_t6_civ_smallwagon_dead" );
    spawnModel( "Diner", ( -8017.1, 5024.1, -59 ), ( 0, 260.7, 0 ), "veh_t6_civ_microbus_dead" );
    spawnModel( "Diner", ( -8105.3, 4655.9, 4.6 ), ( 359.348, 232.659, -91.8907 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -8066.7, 4813.7, -56.5 ), ( 0.12802, 263.505, -0.897897 ), "veh_t6_civ_60s_coupe_dead" );
    spawnModel( "Diner", ( -6663.96, 4816.34, -71.8 ), ( 359.381, 359.485, 17.1622 ), "veh_t6_civ_smallwagon_dead" );
    spawnModel( "Diner", ( -6807.05, 4765.23, -68.01 ), ( 357.802, 156.179, 0.968984 ), "veh_t6_civ_microbus_dead" );
    spawnModel( "Diner", ( -6652.9, 4767.7, -6.73 ), ( 3.98037, 358.737, -102.621 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -6745.48, 4782.86, -79.01 ), ( 357.802, 198.779, 0.968982 ), "p6_zm_rocks_small_cluster_01" );
    spawnModel( "Diner", ( -6550.5, -6901.7, 6.8 ), ( 1.54649, 20, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -6460.7, -7115, 6.8 ), ( 1.54649, 65, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -5822.9, -6434.6, 20.8 ), ( 1.54649, 180, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -6251.1, -6449.4, 20.8 ), ( 1.54649, 1.00179, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -5589.5, -6310.3, 24.8 ), ( 1.54649, 225, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -5017.5, -6676.9, 0.8 ), ( 1.54649, 160, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -4813, -6665.3, 0.8 ), ( 1.54649, 220, -0.891569 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -4117.2, -6617.9, 0.8 ), ( 1.54649, 185, -0.891568 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", (-3978.4, -6484.9, 0.8 ), ( 1.54649, 260, -0.891567 ), "veh_t6_civ_movingtrk_cab_dead" );
    spawnModel( "Diner", ( -3902.4, -6884.9, 0.8 ), ( 1.54649, 260, -0.891567 ), "veh_t6_civ_movingtrk_cab_dead" );
	createTeddyBear( "Diner", ( -5369.52, -7136.91, 171.865 ), ( 0, -1.4, 0 ) );
	createTeddyBear( "Diner", ( -3758.88, -6418.94, -39.723 ), ( 0, -122, 0 ) );
	createTeddyBear( "Diner", ( -3766.41, -7700.57, -73.6108 ), ( 0, 111.25, 0 ) );
	createTeddyBear( "Diner", ( -4197.08, -7897.63, 133.579 ), ( 0, -178.5, 0 ) );
	createTeddyBear( "Diner", ( -5455.64, -8133.03, -34.628 ), ( 0, -34.628, 0 ) );
	createTeddyBear( "Diner", ( -5895.63, -7971.57, 225.312 ), ( 0, -2.066, 0 ) );
	createTeddyBear( "Diner", ( -7172.76, -8017.16, 121.054 ), ( 0, 19.5, 0 ) );
	createTeddyBear( "Diner", ( -5254.82, -6484.1, -32.6762 ), ( 0, -81.92, 0 ) );
	thread killOutOfBoundsZombies( "Diner", ( -6318.64, -7407.57, -63.875 ) );
	//diner killzone//
	//-6504.11, -7188.68, -63.875 works if the one above doesnt
	//cornfield//
	spawnModel( "Cornfield", ( 10190, 135, -159 ), ( 0, 172, 0 ), "veh_t6_civ_movingtrk_cab_dead" );
	spawnModel( "Cornfield", ( 10100, 100, -159 ), ( 0, 172, 0 ), "collision_player_wall_512x512x10" );
	spawnModel( "Cornfield", ( 10100, -1800, -217 ), ( 0, 126, 0 ), "veh_t6_civ_bus_zombie" );
	spawnModel( "Cornfield", ( 10045, -1607, -181 ), ( 0, 126, 0 ), "collision_player_wall_512x512x10" );
	createTeddyBear( "Cornfield", ( 7398.55, -464.617, -198.138 ), ( 0, -1, 0 ) );
	createTeddyBear( "Cornfield", ( 10121.2, -1225.64, -219.875 ), ( -90, -174, 0 ) );
	createTeddyBear( "Cornfield", ( 13951.7, -610.629, -45.875 ), ( 0, -120.5, 0 ) );
	createTeddyBear( "Cornfield", ( 12040.5, -559.927, -142.5 ), ( 0, -8, 0 ) );
	createTeddyBear( "Cornfield", ( 9826.39, -1436.23, -212.972 ), ( 0, -1, 0 ) );
	//power station//
	spawnModel( "Power", ( 9965, 8133, -556 ), ( 15, 5, 0 ), "veh_t6_civ_60s_coupe_dead" );
	spawnModel( "Power", ( 9955, 8105, -575 ), ( 0, 0, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Power", ( 10056, 8350, -584 ), ( 0, 340, 0 ), "veh_t6_civ_bus_zombie" );
	spawnModel( "Power", ( 10267, 8194, -556 ), ( 0, 340, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Power", ( 10409, 8220, -181 ), ( 0, 250, 0 ), "collision_player_wall_512x512x10" );
	spawnModel( "Power", ( 10409, 8220, -556 ), ( 0, 250, 0 ), "collision_player_wall_128x128x10" );
	spawnModel( "Power", ( 10281, 7257, -575 ), ( 0, 13, 0 ), "veh_t6_civ_microbus_dead" );
	spawnModel( "Power", ( 10268, 7294, -569 ), ( 0, 13, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Power", ( 10100, 7238, -575 ), ( 0, 52, 0 ), "veh_t6_civ_60s_coupe_dead" );
	spawnModel( "Power", ( 10170, 7292, -505 ), ( 0, 140, 0 ), "collision_player_wall_128x128x10" );
	spawnModel( "Power", ( 10030, 7216, -569 ), ( 0, 49, 0 ), "collision_player_wall_256x256x10" );
	spawnModel( "Power", ( 10563, 8630, -344 ), ( 0, 270, 0 ), "collision_player_wall_256x256x10" );
	createTeddyBear( "Power", ( 9872.05, 7557.18, -456.851 ), ( 0, -2.4, 0 ) );
	createTeddyBear( "Power", ( 10552.2, 7033.43, -562.276 ), ( 0, 117, 0 ) );
	createTeddyBear( "Power", ( 11277.8, 7442.93, -522.215 ), ( 0, 166, 0 ) );
	createTeddyBear( "Power", ( 11259.6, 7579.25, -554.291 ), ( 0, 176.598, 0 ) );
	createTeddyBear( "Power", ( 12620.8, 8506.34, -751.375 ), ( 0, -133.185, 0 ) );
	createTeddyBear( "Power", ( 11607.6, 8803.08, -575.875 ), ( 0, -71, 0 ) );
	createTeddyBear( "Power", ( 11460, 8386.34, -577.145 ), ( 0, 129, 0 ) );
	thread killOutOfBoundsZombies( "Power", ( 10484, 8613, -574.832 ) );
	//killzone power//
	//10389, 8381.5, -576.571
}

spawnModel( map, origin, angles, model, connectPaths )
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap != map )
		return;
	spawnModel = spawn("script_model", origin );
	spawnModel setModel( model );
	spawnModel.angles = angles;
	if( common_scripts\utility::is_true( connectPaths ) )
		spawnModel ConnectPaths();
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
	currentMap = getGameDvar( "customMap" );
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	self iprintln( "^3Welcome to Bonus Survival Map: ^1" + displayCustomMapName( currentMap ) );
	//self maps\mp\gametypes_zm\_hud_message::hintmessage("^3Welcome to Bonus Survival Map: ^1Tunnel", 10 );
	wait 5;
	self iprintln( "^3Developed by: ^1JezuzLizard, GerardS0406, ^3& ^1Cahz" );
	//self maps\mp\gametypes_zm\_hud_message::hintmessage("^3Developed by: ^1JezuzLizard, GerardS0406, ^3& ^1Cahz", 10 );
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
	level endon( "end_game" );

	while( maps\mp\_utility::ispregame() )
		wait 0.05;
	
    for( i = 0; i < level.players.size; i++ )
	{
		if( level.players[ i ] == self )
		{
			self setOrigin( level.customSpawnpoints[ i ].origin );
			self setPlayerAngles( level.customSpawnpoints[ i ].angles );
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

///////////////////////////////
//MYSTERY BOX FUNCTIONS BELOW//
///////////////////////////////
initCustomMysteryBox()
{
	level endon("end_game");
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	maps\mp\zombies\_zm_utility::add_zombie_hint( "default_shared_box", "Hold ^3&&1^7 for weapon");
    for(i = 0; i < level.chests.size; i++)
    {
    	level.chests[ i ] maps\mp\zombies\_zm_magicbox::hide_chest();
        level.chests[ i ] notify( "kill_chest_think" ); //kill all exsiting mystery boxes
	}
	setupCustomMysteryBoxLocation();
}

setupCustomMysteryBoxLocation() //modify box location here//
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap == "Cabin" )
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
	if( currentMap == "Tunnel" )
	{
		level.chests = [];
		start_chest = spawnstruct();
		start_chest.origin = ( -11090, -349, 193 );
		start_chest.angles = ( 0, -100, 0 );
		start_chest.script_noteworthy = "start_chest";
		start_chest.zombie_cost = 950;

		start_chest2 = spawnstruct();
		start_chest2.origin = ( -11772, -2501, 232 );
		start_chest2.angles = ( 0, 90, 0 );
		start_chest2.script_noteworthy = "farm_chest";
		start_chest2.zombie_cost = 950;

		level.chests[ 0 ] = start_chest;
		level.chests[ 1 ] = start_chest2;
		
		if ( common_scripts\utility::cointoss() )
			return treasure_chest_init( "farm_chest" );
		treasure_chest_init( "start_chest" );
	}
	else if( currentMap == "Diner" )
	{
		normalChests = common_scripts\utility::getstructarray( "treasure_chest_use", "targetname" );
		level.chests = [];
		start_chest = spawnstruct();
		start_chest.origin = ( -5708, -7968, 229 );
		start_chest.angles = ( 0, 1, 0 );
		start_chest.script_noteworthy = "depot_chest";
		start_chest.zombie_cost = 950;
		level.chests[ 0 ] = normalChests[ 3 ];
		level.chests[ 1 ] = start_chest;
		if ( common_scripts\utility::cointoss() )
			return treasure_chest_init( "depot_chest" );
		treasure_chest_init( "start_chest" );
	}
	else if( currentMap == "Cornfield" )
	{
		level.chests = [];
		start_chest = spawnstruct();
		start_chest.origin = ( 13566, -541, -188 );
		start_chest.angles = ( 0, -90, 0 );
		start_chest.script_noteworthy = "start_chest";
		start_chest.zombie_cost = 950;
		start_chest2 = spawnstruct();
		start_chest2.origin = ( 7458, -464, -196 );
		start_chest2.angles = ( 0, -90, 0 );
		start_chest2.script_noteworthy = "depot_chest";
		start_chest2.zombie_cost = 950;
		start_chest3 = spawnstruct();
		start_chest3.origin = ( 10158, 49, -220 );
		start_chest3.angles = ( 0, -185, 0 );
		start_chest3.script_noteworthy = "farm_chest";
		start_chest3.zombie_cost = 950;
		level.chests[ 0 ] = start_chest;
		level.chests[ 1 ] = start_chest2;
		level.chests[ 2 ] = start_chest3;
		//randomNumber = RandomIntRange( 0, level.chests.size );
		treasure_chest_init( level.chests[ RandomIntRange( 0, level.chests.size ) ].script_noteworthy );
	}
	else if( currentMap == "Power" )
	{
		normalChests = common_scripts\utility::getstructarray( "treasure_chest_use", "targetname" );
		level.chests = [];
		start_chest = spawnstruct();
		start_chest.origin = ( 10806, 8518, -407 );
		start_chest.angles = ( 0, 180, 0 );
		start_chest.script_noteworthy = "depot_chest";
		start_chest.zombie_cost = 950;
		level.chests[ 0 ] = normalChests[ 2 ];
		level.chests[ 1 ] = start_chest;
		if ( common_scripts\utility::cointoss() )
			return treasure_chest_init( "pow_chest" );
		treasure_chest_init( "depot_chest" );
	}
}

treasure_chest_init( start_chest_name )
{
	common_scripts\utility::flag_init( "moving_chest_enabled" );
	common_scripts\utility::flag_init( "moving_chest_now" );
	common_scripts\utility::flag_init( "chest_has_been_used" );
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
            chest maps\mp\zombies\_zm_magicbox::hide_chest();

        return;
    }
    level.chest_accessed = 0;
	
    if ( level.chests.size > 1 )
    {
        common_scripts\utility::flag_set( "moving_chest_enabled" );
    }
    else
    {
        level.chest_index = 0;
        level.chests[0].no_fly_away = 1;
    }
	level.chest_accessed = 0;
	maps\mp\zombies\_zm_magicbox::init_starting_chest_location( start_chest_name );
	common_scripts\utility::array_thread( level.chests, ::custom_treasure_chest_think );
}
/*
reset_box()
{
	self notify( "kill_chest_think" );
    wait .1;
	if( !self.hidden )
    {
		self.grab_weapon_hint = 0;
		self thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, ::magicbox_unitrigger_think );
    	self.unitrigger_stub run_visibility_function_for_all_triggers();
	}
	self thread custom_treasure_chest_think();
}
*/
get_chest_pieces() //modified function
{
	self.chest_box = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
	currentMap = getGameDvar( "customMap" );
	if( currentMap == "Cabin" )
	{
		self.chest_box.origin = ( 5387, 6594, -24 );
		self.chest_box.angles = ( 0, 90, 0 );
	}
	if( currentMap == "Tunnel" )
	{
		if ( self.script_noteworthy == "start_chest" )
		{
			self.chest_box.origin = ( -11090, -349, 195 );
			self.chest_box.angles = ( 0, -100, 0 );

			collision = spawn( "script_model", self.chest_box.origin );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", self.chest_box.origin - ( 4, 30, 0 ) );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", self.chest_box.origin + ( 4, 30, 0 ) );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
		}
		if ( self.script_noteworthy == "farm_chest" )
		{
			self.chest_box.origin = ( -11772, -2501, 229 );
			self.chest_box.angles = ( 0, 0, 0 );
			
			collision = spawn( "script_model", self.chest_box.origin );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", self.chest_box.origin - ( 36, 0, 0 ) );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
			collision = spawn( "script_model", self.chest_box.origin + ( 36, 0, 0 ) );
			collision.angles = self.chest_box.angles;
			collision setmodel( "collision_clip_32x32x128" );
			collision disconnectpaths();
		}
	}
	if( currentMap == "Diner" )
	{
		if ( self.script_noteworthy == "depot_chest" )
		{
			self.chest_box.origin = ( -5708, -7968, 229 );
			self.chest_box.angles = ( 0, 1, 0 );
		}
	}
	if( currentMap == "Cornfield" )
	{
		if ( self.script_noteworthy == "start_chest" )
		{
			self.chest_box.origin = ( 13566, -541, -188 );
			self.chest_box.angles = ( 0, -90, 0 );
		}
		if ( self.script_noteworthy == "depot_chest" )
		{
			self.chest_box.origin = ( 7458, -464, -196 );
			self.chest_box.angles = ( 0, -90, 0 );
		}
		if ( self.script_noteworthy == "farm_chest" )
		{
			self.chest_box.origin = ( 10158, 49, -220 );
			self.chest_box.angles = ( 0, -185, 0 );
		}
	}
	if( currentMap == "Power" )
	{
		if ( self.script_noteworthy == "depot_chest" )
		{
			self.chest_box.origin = ( 10806, 8518, -407 );
			self.chest_box.angles = ( 0, 180, 0 );
		}
	}
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
	if ( self.chest_box.angles == ( 0, 10, 0 ) || self.chest_box.angles == ( 0, 1, 0 ) || self.chest_box.angles == ( 0, 0, 0 ) || self.chest_box.angles == ( 0, 180, 0 ) || self.chest_box.angles == ( 0, -180, 0 ) || self.chest_box.angles == ( 0, -185, 0 ) )
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
	maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( self.unitrigger_stub, 1 );
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
    if( !self maps\mp\zombies\_zm_magicbox::trigger_visible_to_player( player ) )
    {
        if( level.shared_box )
        {
            self setvisibletoplayer( player );
            self.hint_string = maps\mp\zombies\_zm_utility::get_hint_string( self, "default_shared_box" );
            return 1;
        }
        return 0;
    }
    self.hint_parm1 = undefined;
    if ( isDefined( self.stub.trigger_target.grab_weapon_hint ) && self.stub.trigger_target.grab_weapon_hint )
    {
        if( level.shared_box )
        {
            self.hint_string = maps\mp\zombies\_zm_utility::get_hint_string( self, "default_shared_box" );
        }
        else
        {
            if (isDefined( level.magic_box_check_equipment ) && [[ level.magic_box_check_equipment ]]( self.stub.trigger_target.grab_weapon_name ) )
            {
                self.hint_string = "Hold ^3&&1^7 for Equipment ^3OR ^7Press ^3[{+melee}]^7 to let teammates pick it up";
            }
            else 
            {
                self.hint_string = "Hold ^3&&1^7 for Weapon ^3OR ^7Press ^3[{+melee}]^7 to let teammates pick it up";
            }
        }
    }
    else if(getdvar("mapname") == "zm_tomb" && isDefined(level.zone_capture.zones) && !level.zone_capture.zones[self.stub.zone] maps\mp\zombies\_zm_utility::ent_flag( "player_controlled" )) 
    {
        self.stub.hint_string = &"ZM_TOMB_ZC";
        return 0;
    }
    else
    {
        if ( isDefined( level.using_locked_magicbox ) && level.using_locked_magicbox && isDefined( self.stub.trigger_target.is_locked ) && self.stub.trigger_target.is_locked )
        {
            self.hint_string = maps\mp\zombies\_zm_utility::get_hint_string( self, "locked_magic_box_cost" );
        }
        else
        {
            self.hint_parm1 = self.stub.trigger_target.zombie_cost;
            self.hint_string = maps\mp\zombies\_zm_utility::get_hint_string( self, "default_treasure_chest" );
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
	self thread maps\mp\zombies\_zm_magicbox::unregister_unitrigger_on_kill_think();
	self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
	
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
		if ( user maps\mp\zombies\_zm_utility::in_revive_trigger() )
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
		if ( maps\mp\zombies\_zm_utility::is_player_valid( user ) && user maps\mp\zombies\_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			reduced_cost = int( self.zombie_cost / 2 );
		}
		if ( isdefined( level.using_locked_magicbox ) && level.using_locked_magicbox && isdefined( self.is_locked ) && self.is_locked ) 
		{
			if ( user.score >= level.locked_magic_box_cost )
			{
				user maps\mp\zombies\_zm_score::minus_to_player_score( level.locked_magic_box_cost );
				self.zbarrier maps\mp\zombies\_zm_magicbox::set_magic_box_zbarrier_state( "unlocking" );
				self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
			}
			else
			{
				user maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			}
			wait 0.1 ;
			continue;
		}
		else if ( isdefined( self.auto_open ) && maps\mp\zombies\_zm_utility::is_player_valid( user ) )
		{
			if ( !isdefined( self.no_charge ) )
			{
				user maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
				user_cost = self.zombie_cost;
			}
			else
			{
				user_cost = 0;
			}
			self.chest_user = user;
			break;
		}
		else if ( maps\mp\zombies\_zm_utility::is_player_valid( user ) && user.score >= self.zombie_cost )
		{
			user maps\mp\zombies\_zm_score::minus_to_player_score( self.zombie_cost );
			user_cost = self.zombie_cost;
			self.chest_user = user;
			break;
		}
		else if ( isdefined( reduced_cost ) && user.score >= reduced_cost )
		{
			user maps\mp\zombies\_zm_score::minus_to_player_score( reduced_cost );
			user_cost = reduced_cost;
			self.chest_user = user;
			break;
		}
		else if ( user.score < self.zombie_cost )
		{
			maps\mp\zombies\_zm_utility::play_sound_at_pos( "no_purchase", self.origin );
			user maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "no_money_box" );
			wait 0.1;
			continue;
		}
		wait 0.05;
	}
	common_scripts\utility::flag_set( "chest_has_been_used" );
	maps\mp\_demo::bookmark( "zm_player_use_magicbox", getTime(), user );
	user maps\mp\zombies\_zm_stats::increment_client_stat( "use_magicbox" );
	user maps\mp\zombies\_zm_stats::increment_player_stat( "use_magicbox" );
	if ( isDefined( level._magic_box_used_vo ) )
	{
		user thread [[ level._magic_box_used_vo ]]();
	}
	self thread maps\mp\zombies\_zm_magicbox::watch_for_emp_close();
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
		self.chest_lid thread maps\mp\zombies\_zm_magicbox::treasure_chest_lid_open();
	}
	if ( isDefined( self.zbarrier ) )
	{
		maps\mp\zombies\_zm_utility::play_sound_at_pos( "open_chest", self.origin );
		maps\mp\zombies\_zm_utility::play_sound_at_pos( "music_chest", self.origin );
		self.zbarrier maps\mp\zombies\_zm_magicbox::set_magic_box_zbarrier_state( "open" );
	}
	self.timedout = 0;
	self.weapon_out = 1;
	self.zbarrier thread maps\mp\zombies\_zm_magicbox::treasure_chest_weapon_spawn( self, user );
	self.zbarrier thread maps\mp\zombies\_zm_magicbox::treasure_chest_glowfx();
	thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
	self.zbarrier common_scripts\utility::waittill_any( "randomization_done", "box_hacked_respin" );
	if ( common_scripts\utility::flag( "moving_chest_now" ) && !self._box_opened_by_fire_sale && isDefined( user_cost ) )
	{
		user maps\mp\zombies\_zm_score::add_to_player_score( user_cost, 0 );
	}
	if ( common_scripts\utility::flag( "moving_chest_now" ) && !level.zombie_vars[ "zombie_powerup_fire_sale_on" ] && !self._box_opened_by_fire_sale )
	{
		self thread maps\mp\zombies\_zm_magicbox::treasure_chest_move( self.chest_user );
	}
	else
	{
		self.grab_weapon_hint = 1;
		self.grab_weapon_name = self.zbarrier.weapon_string;
		self.chest_user = user;
		thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, maps\mp\zombies\_zm_magicbox::magicbox_unitrigger_think );
		
		if ( isDefined( self.zbarrier ) && !common_scripts\utility::is_true( self.zbarrier.closed_by_emp ) )
		{
			self thread maps\mp\zombies\_zm_magicbox::treasure_chest_timeout();
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
				self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
				for( a=i;a<105;a++ )
				{
					foreach(player in level.players)
					{
						if(player usebuttonpressed() && distance(self.origin, player.origin) <= 100 && isDefined( player.is_drinking ) && !player.is_drinking)
						{
						
							player thread maps\mp\zombies\_zm_magicbox::treasure_chest_give_weapon( self.zbarrier.weapon_string );
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
				grabber thread maps\mp\zombies\_zm_magicbox::treasure_chest_give_weapon( self.zbarrier.weapon_string );
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
		thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger_stub );
		if ( isDefined( self.chest_lid ) )
		{
			self.chest_lid thread maps\mp\zombies\_zm_magicbox::treasure_chest_lid_close( self.timedout );
		}
		if ( isDefined( self.zbarrier ) )
		{
			self.zbarrier maps\mp\zombies\_zm_magicbox::set_magic_box_zbarrier_state( "close" );
			maps\mp\zombies\_zm_utility::play_sound_at_pos( "close_chest", self.origin );
			self.zbarrier waittill( "closed" );
			wait 1;
		}
		else
		{
			wait 3;
		}
		if ( isDefined( level.zombie_vars[ "zombie_powerup_fire_sale_on" ] ) && level.zombie_vars[ "zombie_powerup_fire_sale_on" ] || self [[ level._zombiemode_check_firesale_loc_valid_func ]]() || self == level.chests[ level.chest_index ] )
		{
			thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, maps\mp\zombies\_zm_magicbox::magicbox_unitrigger_think );
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
    self thread maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( self.unitrigger_stub, maps\mp\zombies\_zm_magicbox::magicbox_unitrigger_think );
    self.unitrigger_stub maps\mp\zombies\_zm_unitrigger::run_visibility_function_for_all_triggers();
    self thread custom_treasure_chest_think();
}

//////////////////////////////
//PERK SETUP FUNCTIONS BELOW//
//////////////////////////////
initCustomPerkMachineSpawns()
{
	removeAllExistingPerkMachines();
	setupCustomPerkMachine( "Power", ( 10746, 7282, -557 ), ( 0, -132, 0 ), "zombie_vending_jugg_on", "jugger_light", "mus_perks_jugganog_sting", "Jugger-Nog", 2500, "specialty_armorvest" );
	setupCustomPerkMachine( "Power", ( 11879, 7296, -755 ), (0, -138, 0), "zombie_vending_doubletap2_on", "doubletap_light", "mus_perks_doubletap_sting", "Double Tap Root Beer", 2000,  "specialty_rof" );
	setupCustomPerkMachine( "Power", ( 10856, 7879, -576 ), ( 0, -35, 0 ), "zombie_vending_marathon_on", "marathon_light", "mus_perks_stamin_sting", "Stamin-Up", 2000, "specialty_longersprint" );
	setupCustomPerkMachine( "Power", ( 11568, 7723, -755 ), ( 0, -1, 0 ),"zombie_vending_sleight_on", "sleight_light", "mus_perks_speed_sting", "Speed Cola", 3000, "specialty_fastreload" );
	setupCustomPerkMachine( "Power", ( 11156, 8120, -575 ), ( 0, -4, 0 ), "zombie_vending_revive_on", "revive_light", "mus_perks_revive_jingle", "Quick Revive", 1500, "specialty_quickrevive", 500 );	
	setupCustomPerkMachine( "Power", ( 10946, 8308.77, -408 ), ( 0, 270, 0 ), "zombie_vending_tombstone_on", "tombstone_light", "mus_perks_tombstone_jingle", "Tombstone", 2000, "specialty_scavenger");
	setupCustomPerkMachine( "Power", ( 12625, 7434, -755 ), ( 0, 162, 0 ), "p6_anim_zm_buildable_pap_on", "revive_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );

	setupCustomPerkMachine( "Cornfield", ( 13936, -649, -189 ), ( 0, 179, 0 ), "zombie_vending_jugg_on", "jugger_light", "mus_perks_jugganog_sting", "Jugger-Nog", 2500, "specialty_armorvest" );
	setupCustomPerkMachine( "Cornfield", ( 12052, -1943, -160 ), (0, -137, 0), "zombie_vending_doubletap2_on", "doubletap_light", "mus_perks_doubletap_sting", "Double Tap Root Beer", 2000,  "specialty_rof" );
	setupCustomPerkMachine( "Cornfield", ( 9944, -725, -211 ), ( 0, 133, 0 ), "zombie_vending_marathon_on", "marathon_light", "mus_perks_stamin_sting", "Stamin-Up", 2000, "specialty_longersprint" );
	setupCustomPerkMachine( "Cornfield", ( 13255, 74, -195 ), ( 0, -4, 0 ),"zombie_vending_sleight_on", "sleight_light", "mus_perks_speed_sting", "Speed Cola", 3000, "specialty_fastreload" );
	setupCustomPerkMachine( "Cornfield", ( 7831, -464, -203 ), ( 0, -90, 0 ), "zombie_vending_revive_on", "revive_light", "mus_perks_revive_jingle", "Quick Revive", 1500, "specialty_quickrevive", 500 );	
	setupCustomPerkMachine( "Cornfield", ( 13551, -1384, -188 ), ( 0, 90, 0 ), "zombie_vending_tombstone_on", "tombstone_light", "mus_perks_tombstone_jingle", "Tombstone", 2000, "specialty_scavenger");
	setupCustomPerkMachine( "Cornfield", ( 9960, -1288, -217 ), ( 0, 123, 0 ), "p6_anim_zm_buildable_pap_on", "revive_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );

	setupCustomPerkMachine( "Diner", ( -3634, -7464, -58 ), ( 0, 176, 0 ), "zombie_vending_jugg_on", "jugger_light", "mus_perks_jugganog_sting", "Jugger-Nog", 2500, "specialty_armorvest" );
	setupCustomPerkMachine( "Diner", ( -4170, -7610, -61 ), ( 0, -90, 0), "zombie_vending_doubletap2_on", "doubletap_light", "mus_perks_doubletap_sting", "Double Tap Root Beer", 2000,  "specialty_rof" );
	setupCustomPerkMachine( "Diner", ( -4576, -6704, -61 ), ( 0, 4, 0 ), "zombie_vending_marathon_on", "marathon_light", "mus_perks_stamin_sting", "Stamin-Up", 2000, "specialty_longersprint" );
	setupCustomPerkMachine( "Diner", ( -5470, -7859.5, 0 ), ( 0, 270, 0 ),"zombie_vending_sleight_on", "sleight_light", "mus_perks_speed_sting", "Speed Cola", 3000, "specialty_fastreload" );
	setupCustomPerkMachine( "Diner", ( -5424, -7920, -64 ), ( 0, 137, 0 ), "zombie_vending_revive_on", "revive_light", "mus_perks_revive_jingle", "Quick Revive", 1500, "specialty_quickrevive", 500 );	
	setupCustomPerkMachine( "Diner", ( -6496, -7691, 0 ), ( 0, 90, 0 ), "zombie_vending_tombstone_on", "tombstone_light", "mus_perks_tombstone_jingle", "Tombstone", 2000, "specialty_scavenger");
	setupCustomPerkMachine( "Diner", ( -6351, -7778, 227 ), ( 0, 175, 0 ), "p6_anim_zm_buildable_pap_on", "revive_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );

	setupCustomPerkMachine( "Tunnel", ( -11541, -2630, 194 ), ( 0, -180, 0 ), "zombie_vending_jugg_on", "jugger_light", "mus_perks_jugganog_sting", "Jugger-Nog", 2500, "specialty_armorvest" );
	setupCustomPerkMachine( "Tunnel", ( -11170, -590, 196 ), ( 0, -10, 0), "zombie_vending_doubletap2_on", "doubletap_light", "mus_perks_doubletap_sting", "Double Tap Root Beer", 2000,  "specialty_rof" );
	setupCustomPerkMachine( "Tunnel", ( -11681, -734, 228 ), ( 0, -19, 0 ), "zombie_vending_marathon_on", "marathon_light", "mus_perks_stamin_sting", "Stamin-Up", 2000, "specialty_longersprint" );
	setupCustomPerkMachine( "Tunnel", ( -11373, -1674, 192 ), ( 0, -89, 0 ),"zombie_vending_sleight_on", "sleight_light", "mus_perks_speed_sting", "Speed Cola", 3000, "specialty_fastreload" );
	setupCustomPerkMachine( "Tunnel", ( -10780, -2565, 224 ), ( 0, 270, 0 ), "zombie_vending_revive_on", "revive_light", "mus_perks_revive_jingle", "Quick Revive", 1500, "specialty_quickrevive", 500 );	
	setupCustomPerkMachine( "Tunnel", ( -10664, -757, 196 ), ( 0, -98, 0 ), "zombie_vending_tombstone_on", "tombstone_light", "mus_perks_tombstone_jingle", "Tombstone", 2000, "specialty_scavenger");
	setupCustomPerkMachine( "Tunnel", ( -11301, -2096, 180 ), ( 0, 115, 0 ), "p6_anim_zm_buildable_pap_on", "revive_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );
	
	setupCustomPerkMachine( "Cabin", ( 5405, 6869, -23 ), ( 0, 90, 0 ), "tag_origin", "doubletap_light", "zmb_perks_packa_upgrade", "Pack-A-Punch", 5000, "specialty_weapupgrade" );
}

removeAllExistingPerkMachines( exclusion )
{
	perks = strToK( "specialty_armorvest specialty_rof specialty_longersprint specialty_fastreload specialty_quickrevive specialty_scavenger", " " );
	while( maps\mp\_utility::isPreGame() )
		wait .1;
	foreach( perk in perks )
	{
		if( isDefined( exclusion ) && exclusion == perk )
			continue;
		level thread maps\mp\zombies\_zm_perks::perk_machine_removal( perk );
	}
}

setupCustomPerkMachine( map, origin, angles, model, fx, sound, name, cost, perk, solo_cost )
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap != map )
		return;
	
	perk_machine = spawn( "script_model", origin );
	perk_machine setmodel( model );
	perk_machine.angles = angles;

	perk_machine_collision = spawn( "script_model", origin );
	perk_machine_collision setmodel( "zm_collision_perks1" );
	perk_machine_collision.angles = angles;

	if( isDefined( fx ))
		perk_machine thread play_fx( fx, origin, angles );
	
	if( name == "Quick Revive" )
		return perk_machine thread quick_revive_machine_think( perk, sound, name, cost, solo_cost );

	if( name == "Pack-A-Punch" )
		return perk_machine thread packapunch_machine_think( perk, sound, name, cost );

    perk_machine thread perk_machine_think( perk, sound, name, cost );
}

play_fx( effect, origin, angles ) //custom function
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

perk_machine_think( perk, sound, name, cost )
{
    //common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
    level endon( "game_ended" );
    
    perk_machine = self;
    trigger = spawn( "trigger_radius_use", perk_machine.origin + ( 0, 0, 32 ), 1, 100, 128 );
    trigger SetCursorHint("HINT_NOICON");
    trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
    trigger triggerignoreteam();
	trigger usetriggerrequirelookat();
    trigger setvisibletoall();
	trigger thread givePoints();

    bump_trigger = spawn( "trigger_radius", perk_machine.origin, 0, 35, 64 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps\mp\zombies\_zm_perks::thread_bump_trigger();

    for(;;)
    {
        trigger waittill( "trigger", player );
		trigger SetHintString("Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
		if( player useButtonPressed() && !player hasperk( perk ) && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !player.is_drinking && player.num_perks < player get_player_perk_purchase_limit() )
		{
			if( player.score < cost )
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
				continue;
			}
			player playsound( "zmb_cha_ching" );
			player.score -= cost;
			playsoundatposition( sound, perk_machine.origin + ( 0, 0, 32 ) );
			player thread DoGivePerk( perk );
		}
		wait 0.5;
    }
}
////////////////////////
//PAP Machine Thinking//
////////////////////////
packapunch_machine_think( perk, sound, name, cost )
{
    //common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
    level endon( "game_ended" );
	packapunch = self;
    trigger = spawn("trigger_radius_use", packapunch.origin + ( 0, 0, 32 ), 1, 100, 128);
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
		currgun = player getcurrentweapon();
		if( player useButtonPressed() && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && !maps\mp\zombies\_zm_weapons::is_weapon_upgraded( currgun ) && maps\mp\zombies\_zm_weapons::can_upgrade_weapon( currgun ) )
		{
			if( player.score < cost )
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
				continue;
			}
        	trigger SetHintString( "" );
			player playsound( "zmb_cha_ching" );
			player.score -= cost;
			playsoundatposition( sound, packapunch.origin + ( 0, 0, 32 ) );
			player takeweapon( currgun );
			gun = player maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 );
			player giveweapon( player maps\mp\zombies\_zm_weapons::get_upgrade_weapon( currgun, 0 ), 0, player custom_get_pack_a_punch_weapon_options( gun ) );
			player switchToWeapon( gun );
			//playfx( loadfx( "maps/zombie/fx_zombie_packapunch"), packapunch.origin, anglestoforward( packapunch.angles ) ); 
			wait 3;
			trigger SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
		}
		wait 0.5;
    }
}

////////////////////////////////////
//customized quick revive thinking//
////////////////////////////////////
quick_revive_machine_think( perk, sound, name, cost, solo_cost )
{
    common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	level endon( "game_ended" );
    
	quickrevive = self;
    max_revives = 3;
	solo_revives = 0;

    trigger = spawn("trigger_radius_use", quickrevive.origin + ( 0, 0, 32 ), 1, 100, 128);
    trigger SetCursorHint("HINT_NOICON");
    trigger quick_revive_set_hintstring();
    trigger triggerignoreteam();
	trigger usetriggerrequirelookat();
    trigger setvisibletoall();
	trigger givePoints();

    bump_trigger = spawn("trigger_radius", quickrevive.origin, 0, 35, 64);
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	bump_trigger thread maps\mp\zombies\_zm_perks::thread_bump_trigger();

    for(;;)
    {
		trigger quick_revive_set_hintstring( name, cost, solo_cost );
        trigger waittill( "trigger", player );
		if( player useButtonPressed() && !player hasPerk( perk ) && !player maps\mp\zombies\_zm_laststand::player_is_in_laststand() && player.num_perks < player get_player_perk_purchase_limit() )
		{
			//non-solo function//
			if( level.players.size > 1 )
			{
				if( player.score < cost )
				{
					player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
					continue;
				}
				solo_revives = 0;
				player playsound( "zmb_cha_ching" );
				player.score -= cost;
				playsoundatposition( sound, quickrevive.origin + ( 0, 0, 32 ) );
				player thread DoGivePerk( perk );
				continue;
			}
			//solo//
			if( solo_revives >= max_revives )
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "oh_shit" );
				continue;
			}
			if( player.score < solo_cost )
			{
				player maps\mp\zombies\_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
				continue;
			}
			solo_revives++;
			player playsound( "zmb_cha_ching" );
			player.score -= solo_cost;
			playsoundatposition( sound, quickrevive.origin + ( 0, 0, 32 ) );
			player thread DoGivePerk( perk );
		}
		wait 0.1;
	}
}

quick_revive_set_hintstring( name, cost, solo_cost )
{
	if( level.players.size == 1 )
	{
		return self SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + solo_cost + "]" );
	}
	return self SetHintString( "Hold ^3&&1^7 for " + name + " [Cost: " + cost + "]" );
}

doGivePerk( perk )
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("perk_abort_drinking");
	self disableweaponcycling();
    last_weapon = self getcurrentweapon();
    self.is_drinking = 1;
    gun = self maps\mp\zombies\_zm_perks::perk_give_bottle_begin( perk );
    evt = self common_scripts\utility::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
    if (evt == "weapon_change_complete")
        self thread maps\mp\zombies\_zm_perks::wait_give_perk(perk, 1);
    self maps\mp\zombies\_zm_perks::perk_give_bottle_end(gun, perk);
    if (self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        return;
    self notify("burp");
    self.is_drinking = 0;
	self switchToWeapon( last_weapon );
	self enableweaponcycling();
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
	if( !(maps\mp\zombies\_zm_weapons::is_weapon_upgraded( weapon )) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if( IsDefined( self.pack_a_punch_weapon_options[ weapon] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon];
	}
	smiley_face_reticle_index = 1;
	base = maps\mp\zombies\_zm_weapons::get_base_name( weapon );
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
		structs = common_scripts\utility::getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = common_scripts\utility::getstructarray( "zm_perk_machine", "targetname" );
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
					bump_trigger thread maps\mp\zombies\_zm_perks::thread_bump_trigger();
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
					flag_pos = common_scripts\utility::getstruct( pos[ i ].target, "targetname" );
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
		players = common_scripts\utility::get_players();
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
	currentMap = getGameDvar( "customMap" );
	if( currentMap != "Cabin" )
		return;
	level endon( "end_game" );
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );

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
	currentMap = getGameDvar( "customMap" );
	level endon("end_game");
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	spawn_list = [];
	spawnable_weapon_spawns = common_scripts\utility::getstructarray( "weapon_upgrade", "targetname" );
	if( currentMap != "Cabin" )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, common_scripts\utility::getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	}
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, common_scripts\utility::getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	if( currentMap != "Diner" )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, common_scripts\utility::getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	}
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, common_scripts\utility::getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	if ( !common_scripts\utility::is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, common_scripts\utility::getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
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
		if ( isDefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && common_scripts\utility::is_true( level.headshots_only ) )
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
		if( currentMap == "Power" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (10559, 8226, -504);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,90,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (11769, 7662, -701);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,170,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (10859, 8146, -353);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,0,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (11452, 8692, -521);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,90,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "bowie_knife_zm" )
			{
				spawn_list[ i ].origin = (10837, 8135, -490);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("bowie_knife_effect", spawn_list[ i ].origin, (0,180,0));
			}
		}
		if( currentMap == "Cornfield" )
		{
			//if( spawn_list[ i ].zombie_weapon_upgrade == "beretta93r_zm" )
			//{
				//spawn_list[ i ].origin = (12968, -917, -142);
				//spawn_list[ i ].angles = ( 0, 0, 0 );
				//thread playchalkfx("b23r_effect", spawn_list[ i ].origin, (0,0,0));
			//}
			if( spawn_list[ i ].zombie_weapon_upgrade == "claymore_zm" )
			{
				spawn_list[ i ].origin = (13603, -1282, -134);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("claymore_effect", spawn_list[ i ].origin, (0,-180,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (13663, -1166, -134);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,-90,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (14092, -351, -133);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,90,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (13542, -764, -133);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin + (0, 7, 0), (0,90,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "tazer_knuckles_zm" )
			{
				spawn_list[ i ].origin = (13502, -12, -125);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("galvaknuckles_effect", spawn_list[ i ].origin + (0, 13, 0), (0,90,0));
			}
		}
		if( currentMap == "Diner" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (-4280, -7486, -5);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,0,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (-5085, -7807, -5);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,0,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (-3578, -7181, 0);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,180,0));
			}
		}
		if( currentMap == "Tunnel" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (-11166, -2844, 247);
				spawn_list[ i ].angles = ( 0, -86, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,-86,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (-10790, -1430, 247);
				spawn_list[ i ].angles = ( 0, 83, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,83,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (-10625, -545, 247);
				spawn_list[ i ].angles = ( 0, 83, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,83,0));
			}
		}
		if( currentMap == "Cabin" )
		{
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
		}
		if ( isDefined( level._wallbuy_override_num_bits ) )
		{
			numbits = level._wallbuy_override_num_bits;
		}
		//registerclientfield( "world", clientfieldname, 1, numbits, "int" );
		target_struct = common_scripts\utility::getstruct( spawn_list[ i ].target, "targetname" );
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
			unitrigger_stub.cost = maps\mp\zombies\_zm_weapons::get_weapon_cost( spawn_list[ i ].zombie_weapon_upgrade );
			if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
			{
				unitrigger_stub.hint_string = maps\mp\zombies\_zm_weapons::get_weapon_hint( spawn_list[ i ].zombie_weapon_upgrade );
				unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			}
			else
			{
				unitrigger_stub.hint_parm1 = maps\mp\zombies\_zm_weapons::get_weapon_display_name( spawn_list[ i ].zombie_weapon_upgrade );
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
		maps\mp\zombies\_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
		if ( maps\mp\zombies\_zm_utility::is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
			{
				unitrigger_stub.origin += level.taser_trig_adjustment;
			}
			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_weapons::weapon_spawn_think );
		}
		else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_stub.prompt_and_visibility_func = maps\mp\zombies\_zm_weap_claymore::claymore_unitrigger_update_prompt;
			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_weap_claymore::buy_claymores );
		}
		else
		{
			unitrigger_stub.prompt_and_visibility_func = maps\mp\zombies\_zm_weapons::wall_weapon_update_prompt;
			maps\mp\zombies\_zm_unitrigger::register_static_unitrigger( unitrigger_stub, maps\mp\zombies\_zm_weapons::weapon_spawn_think );
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
	if( maps\mp\zombies\_zm_utility::is_melee_weapon( weapon ) || weapon_no_ammo( weapon ))
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

			if(!player maps\mp\zombies\_zm_weapons::has_weapon_or_upgrade( weapon ) && player.score >= cost)
			{
				player maps\mp\zombies\_zm_score::minus_to_player_score(cost,1);
				player playsound("zmb_cha_ching");
				if(weapon == "one_inch_punch_zm" && isdefined(level.oneInchPunchGiveFunc))
				{
					player thread [[level.oneInchPunchGiveFunc]]();
				}
				else
					player maps\mp\zombies\_zm_weapons::weapon_give(weapon);
				wait 3;
			}
			else
			{
				if(player maps\mp\zombies\_zm_weapons::has_upgrade(weapon) && player.score >= 4500)
				{
					if(player maps\mp\zombies\_zm_weapons::ammo_give(maps\mp\zombies\_zm_weapons::get_upgrade_weapon(weapon)))
					{
						player maps\mp\zombies\_zm_score::minus_to_player_score(4500,1);
						player playsound("zmb_cha_ching");
						wait 3;
					}
				}
				else if(player.score >= ammoCost)
				{
					if(player maps\mp\zombies\_zm_weapons::ammo_give(weapon))
					{
						player maps\mp\zombies\_zm_score::minus_to_player_score(ammoCost,1);
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
	currentMap = getGameDvar( "customMap" );
	if( currentMap != "Cabin" )
		return;
	level.wunderfizzChecksPower = maps\mp\_utility::getDvarIntDefault( "wunderfizzChecksPower", 1 );
	level.wunderfizzCost = maps\mp\_utility::getDvarIntDefault( "wunderfizzCost", 1500 );
	wunderfizzUseRandomStart = maps\mp\_utility::getDvarIntDefault("wunderfizzUseRandomStart", 0 );
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
		common_scripts\utility::flag_wait("power_on");
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
									if(!(player hasPerk(perkForRandom) || (player maps\mp\zombies\_zm_perks::has_perk_paused(perkForRandom))))
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
								perklist = common_scripts\utility::array_randomize(perks);
								for(j=0;j<perklist.size;j++)
								{
									if(!(player hasPerk(perklist[j]) || (self maps\mp\zombies\_zm_perks::has_perk_paused(perklist[j]))))
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
	if ( self maps\mp\zombies\_zm_utility::hacker_active() )
	{
		return 0;
	}
	if ( self IsSwitchingWeapons() )
	{
		return 0;
	}
	current_weapon = self getcurrentweapon();
	if ( maps\mp\zombies\_zm_utility::is_placeable_mine( current_weapon ) || maps\mp\zombies\_zm_utility::is_equipment_that_blocks_purchase( current_weapon ) )
	{
		return 0;
	}
	if ( self maps\mp\zombies\_zm_utility::in_revive_trigger() )
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
	if(!(self hasPerk(perk) || (self maps\mp\zombies\_zm_perks::has_perk_paused(perk))))
	{
		self.isDrinkingPerk = 1;
		gun = self maps\mp\zombies\_zm_perks::perk_give_bottle_begin(perk);
        evt = self common_scripts\utility::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
        self thread maps\mp\zombies\_zm_perks::wait_give_perk(perk, 1);
       	self maps\mp\zombies\_zm_perks::perk_give_bottle_end(gun, perk);
       	self.isDrinkingPerk = 0;
    	if (self maps\mp\zombies\_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
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

//////////////////////////////////////
//MODIFY ZOMBIE SPEED FUNCTION BELOW//
//////////////////////////////////////
initOverrideZombieSpeed()
{
	currentMap = getGameDvar( "customMap" );
	if( currentMap == "Cabin" || currentMap == "Cornfield" )
		level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;

	if( currentMap == "Tunnel" )
		level.zombie_vars[ "zombie_spawn_delay" ] = 1;

	if( currentMap != "Cabin" && currentMap != "Cornfield" )
		return;

	level endon( "end_game" );
	
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	
	//level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	level.speed_change_round = undefined;

	while ( !level.intermission )
	{
		zombies = maps\mp\zombies\_zm_utility::get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( zombies[ i ].zombie_move_speed != "sprint" )
			{
				zombies[ i ] maps\mp\zombies\_zm_utility::set_zombie_run_cycle( "sprint" );
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
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	wait 2;
	maps\mp\zombies\_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	common_scripts\utility::flag_set( "power_on" );
	level maps\mp\_utility::setclientfield( "zombie_power_on", 1 );
}


/////////////////////////////////////
//ZOMBIE HITMARKERS FUNCTIONS BELOW//
/////////////////////////////////////
initZombieHitmarkers()
{
	maps\mp\zombies\_zm_spawner::register_zombie_damage_callback( ::do_hitmarker );
    maps\mp\zombies\_zm_spawner::register_zombie_death_event_callback( ::do_hitmarker_death );
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
    if( !isPlayer( self ) || mod == "MOD_CRUSH" || mod == "MOD_GRENADE_SPLASH" || mod == "MOD_HIT_BY_OBJECT" )
        return;
	
    if( common_scripts\utility::is_true( death ) )
    {
        self.hud_damagefeedback_ondeath.alpha = 1;
        self.hud_damagefeedback_ondeath fadeovertime( 1 );
        self.hud_damagefeedback_ondeath.alpha = 0;
		return;
	}
	self.hud_damagefeedback.alpha = 1;
    self.hud_damagefeedback fadeovertime( 1 );
    self.hud_damagefeedback.alpha = 0;
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
	killsNeeded = maps\mp\_utility::getDvarIntDefault( "perkSlotIncreaseKills", 100 );
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
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
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
	player = common_scripts\utility::get_players()[ 0 ];
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
	player = common_scripts\utility::get_players()[ 0 ];
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
			level maps\mp\_utility::setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self maps\mp\_utility::setclientfieldtoplayer( "craftable", piecestub.client_field_state );
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
		thread maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

buildbuildable( buildable, craft ) //credit to Jbleezy for this function
{
	if ( !isDefined( craft ) )
	{
		craft = 0;
	}

	player = common_scripts\utility::get_players()[ 0 ];
	foreach ( stub in level.buildable_stubs )
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps\mp\zombies\_zm_buildables::buildablestub_finish_build( player );
					stub maps\mp\zombies\_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}

				i = 0;
				foreach ( piece in stub.buildablezone.pieces )
				{
					piece maps\mp\zombies\_zm_buildables::piece_unspawn();
					if ( !craft && i > 0 )
					{
						stub.buildablezone maps\mp\zombies\_zm_buildables::buildable_set_piece_built( piece );
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
				maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
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
					stub maps\mp\zombies\_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps\mp\zombies\_zm_buildables::piece_unspawn();
					}
					maps\mp\zombies\_zm_unitrigger::unregister_unitrigger( stub );
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
	common_scripts\utility::flag_wait( "initial_blackscreen_passed" );
	level.avogadro_spawners = getentarray( "avogadro_zombie_spawner", "script_noteworthy" );
	//remove all avogadro spawnpoints!!!//
    foreach( spawner in level.avogadro_spawners )
    {
        spawner delete();
    }
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

//TEDDY BEAR EASTER EGGS//
createTeddyBear( map, origin, angles )
{
	currentMap = getGameDvar( "customMap" );
	if( map != currentMap )
		return;
	spawnModel = spawn("script_model", origin );
	spawnModel setModel( "zombie_teddybear" );
	spawnModel.angles = angles;
	spawnModel thread damageCallback();
}

damageCallback()
{
    self setcandamage( 1 );
	self.health = 100000;
    while ( true )
    {
        self waittill( "damage", amount, attacker, directionvec, point, type );
		self.health = 100000; //reset health each time damaged//

        if ( isdefined( attacker ) && isplayer( attacker ) )
        {
			if( type == "MOD_GRENADE_SPLASH" )
			{
				attacker.score += 500;
				attacker thread do_hitmarker_internal( "MOD_IMPACT", true );
				playfx( level._effect["upgrade_aquired"], self.origin );
				self delete();
				return;
			}
			attacker thread do_hitmarker_internal( type );
			/*
            if ( !isdefined( self.dmgfxorigin ) )
            {
                self.dmgfxorigin = spawn( "script_model", point );
                self.dmgfxorigin setmodel( "tag_origin" );

                if ( isdefined( type ) && type == "MOD_GRENADE_SPLASH" )
                    self.dmgfxorigin.origin = self gettagorigin( "tag_origin" ) + vectorscale( ( 0, 0, 1 ), 40.0 );

                self.dmgfxorigin linkto( self );
            }
			*/
        }
		/*
        if ( isdefined( self.dmgfxorigin ) )
        {
            self.dmgfxorigin unlink();
            self.dmgfxorigin delete();
            self.dmgfxorigin = undefined;
        }
		*/
    }
}

killOutOfBoundsZombies( map, origin ) //this helps fix certain spots where zombies get stuck oob
{
	currentMap = getDvar( "customMap" );
	if( currentMap != map )
		return;
	
	level endon( "game_ended" );
	for( ;; )
	{
		zombies = maps\mp\zombies\_zm_utility::get_round_enemy_array();
		if( isDefined( zombies ) )
		{
			foreach( zombie in zombies )
			{
				if( distance( zombie.origin, origin ) < 200 )
				{
					zombie doDamage( zombie.health, zombie.origin );
				}
			}
		}
		wait 2;
	}
}
