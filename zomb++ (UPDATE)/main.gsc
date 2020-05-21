#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_transit;


init()
{
	startInit(); //precaching models
	level thread onPlayerConnect(); //on connect
	thread initCustomPowerups(); //initilize custom powerups
	thread initServerDvars(); //initilize server dvars (credit JezuzLizard)
	level.playerDamageStub = level.callbackplayerdamage; //damage callback for phd flopper
	level.callbackplayerdamage = ::phd_flopper_dmg_check; //more damage callback stuff. everybody do the flop
	isTown(); //jezuzlizard's fix for tombstone :)
	//level.using_solo_revive = 0; //disables solo revive, fixing only 3 revives per game.
	//level.is_forever_solo_game = 0; //changes afterlives on motd from 3 to 1
}
onPlayerConnect()
{ 
	level endon( "end_game" );
    self endon( "disconnect" );
	for (;;)
	{
		level waittill( "connected", player );
		
		player thread [[level.givecustomcharacters]]();
		player thread onPlayerSpawned();
		player thread spawnIfRoundOne(); //force spawns if round 1. no more spectating one player on round 1
		player thread startCustomPowerups(); //start custom powerups - Credit _Ox. just edited and added more powerups.
		player thread startCustomPerkMachines(); //spawns custom perk machines on the map
		player thread startCustomBank(); //custom bank (this doesnt fix the bank,it just emulates it)
		player thread customEasterEgg(); //not optimized code tbh
	}
}
onPlayerSpawned()
{
	level endon( "end_game" );
    self endon( "disconnect" );
	for(;;)
	{
		self waittill( "spawned_player" );
		
		if( level.enableDebugMode == 1)
		{
			self notify("reset_debug_binds");
			self thread debugButtonMonitor();
			self.score = 500000;
		}
		if(level.round_number >= 5 && self.score < 2500) //in case players have low score and die or players join late (Helps to aid the high round, cant afford jug or gun situation)
			self.score = 2500;
		else if(level.round_number >= 15 && self.score < 5000)
			self.score = 5000;
		wait 5;
		//self EnableInvulnerability();
		self giveWeapon("ray_gun_zm");
		self SwitchToWeapon("ray_gun_zm");
		//self thread ConnectMessages(); //just does the connect messages when you spawn in
		self thread initCustomPerksOnPlayer(); //checks mapname and if it should give PHD flopper automatically
	}
}
ConnectMessages()
{
	wait 5;
	self connectMessage( "Welcome to ^1ZOMBIES++^7! \nDeveloped by ^5@ItsCahz"  , false );
	wait 5;
	self connectMessage( "Your ^2Perk Limit ^7is ^2"+level.perk_purchase_limit+" ^7perks!"  , false );
	wait 5;
	if(getDvar("mapname") == "zm_prison" || getDvar("mapname") == "zm_highrise" || getDvar("mapname") == "zm_buried" || getDvar("mapname") == "zm_nuked" || getDvar("mapname") == "zm_transit")
	{
		if(level.disableAllCustomPerks == 0) //if the perks are enabled, send the next messages
		{
			if(isDefined(level.customPerksAreSpawned)) //this just checks to make sure there's actually custom perk machines within the map before sending the print msg
				self connectMessage( "There are extra perk machines located within the map!"  , false );
			if(isDefined(self.customPerkNum) && self.customPerkNum == 4) //if there's 4 custom perk machines loaded, wait 5 seconds so the player can read the print msg in the killfeed before
				wait 5;
			if(getDvar("mapname") == "zm_highrise")
			{
				if(level.enablePHDFlopper == 1)
					self connectMessage( "-^6PHD Flopper"  , false );
				if(level.enableDeadShot == 1)
					self connectMessage( "-^8Deadshot Daiquiari"  , false );
				if(level.enableStaminUp == 1)
					self connectMessage( "-^3Stamin-Up"  , false );
			}
			else if(getDvar("mapname") == "zm_buried")
			{
				if(level.enablePHDFlopper == 1)
					self connectMessage( "-^6PHD Flopper"  , false );
				if(level.enableDeadShot == 1)
					self connectMessage( "-^8Deadshot Daiquiari"  , false );
			}
			else if(getDvar("mapname") == "zm_prison")
			{
				if(level.enablePHDFlopper == 1)
					self connectMessage( "-^6PHD Flopper"  , false );
				if(level.enableStaminUp == 1)
					self connectMessage( "-^3Stamin-Up"  , false );
			}
			else if(getDvar("mapname") == "zm_nuked" || getDvar("mapname") == "zm_transit")
			{
				if(level.enablePHDFlopper == 1)
					self connectMessage( "-^6PHD Flopper"  , false );
				if(level.enableDeadShot == 1)
					self connectMessage( "-^8Deadshot Daiquiari"  , false );
				if(level.enableStaminUp == 1)
					self connectMessage( "-^3Stamin-Up"  , false );
				if(level.enableMuleKick == 1)
					self connectMessage( "-^2Mule Kick"  , false );
			}
		}
	}
	else if(getDvar("mapname") != "zm_tomb" && level.disableAllCustomPerks == 0 && level.enablePHDFlopper == 1)
		self connectMessage( "^6PHD Flopper ^7is ^2Enabled ^7Automatically On This Map!"  , false ); //pretty sure this would work on maps like town or farm. never tested
}

