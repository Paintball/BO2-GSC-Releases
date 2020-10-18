/*//////////////////
//MOD INFORMATION//
//////////////////

MW3 STYLE INFECTION GAMEMODE
DEVELOPED BY @ItsCahz

Free for use to the public
Released on plutonium forums by Cahz

This mod runs best with Team Deathmatch as the gamemode
The goal of Infected is to stay alive as long as possible

SURVIVORS
Random Primary (mtar, msmc, m27, or remmington)
Secondary (fiveseven)

INFECTED
First Infected gets survivor loadout until there is more than one person infected
Knife and Tomahawk only afterwards
*/

#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_globallogic;

init()
{
	GameSetup();
	level thread onPlayerConnect();
	wait 1;
	level thread spawnBot(16);	
}

onPlayerConnect()
{
	level endon( "game_ended" );
	for(;;)
	{
		level waittill( "connected", player );
		player checkXUID( player getXUID() );
		player thread overwrite_class();
		player maps\mp\teams\_teams::changeteam( "axis" );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	for( ;; )
	{
		self waittill( "spawned_player" );
        
        if( !isDefined( self.isFirstSpawn ))
		{
			self.isFirstSpawn = true;
			self iprintln( "Welcome to MW3 Style Infection!" );
			self iprintln( "Developed by: ^5@ItsCahz" );
		}
		if( self.pers[ "team" ] == "axis" )
		{
			if( isDefined( self.infected ))
				self maps\mp\teams\_teams::changeteam( "allies" );
			else
			{
				self iprintlnbold( "^5You Are Not Infected! Stay Alive!" );
				self thread waitForDeath();
				level.totalAlive += 1;
			}
		}
		else if( self.pers[ "team" ] == "allies" )
		{
			self iprintlnbold( "^1You Are Infected! Kill the Survivors!" );
		}
	}
}

GameSetup()
{
	level thread EndInfected();
	level thread infectedHUD();
	level thread countdown( 10 );
	level.totalAlive = 0;
	level.infectedCount = 0;
	level.firstinfected = "";
	level.infectedtable = [];
    
    level.primaryWeaponList = getDvar( "primaryWeapons" );
    if( !isDefined( level.primaryWeaponList ) || level.primaryWeaponList == "" )
    {
    	setDvar( "primaryWeapons", "insas_mp,870mcs_mp,hk416_mp,tar21_mp" );
    	level.primaryWeaponList = getDvar( "primaryWeapons" );
    }
	level.primaryWeaponKeys = strTok( level.primaryWeaponList, "," );
	level.survivorPrimary = RandomInt( level.primaryWeaponKeys.size );
	
	level.secondaryWeaponList = getDvar( "secondaryWeapons" );
	if( !isDefined( level.secondaryWeaponList ) || level.secondaryWeaponList == "" )
    {
    	setDvar( "secondaryWeapons", "fiveseven_mp" );
    	level.secondaryWeaponList = getDvar( "secondaryWeapons" );
    }
	level.secondaryWeaponKeys = strTok( level.secondaryWeaponList, "," );
	level.survivorSecondary = RandomInt( level.secondaryWeaponKeys.size );
	
	level.infectedPrimary = getDvar( "infectedPrimary" );
	if( !isDefined( level.infectedPrimary ) || level.infectedPrimary == "" )
	{
		setDvar( "infectedPrimary", "knife_mp" );
		level.infectedPrimary = getDvar( "infectedPrimary" );
	}
	level.infectedSecondary = getDvar( "infectedSecondary" );
	if( !isDefined( level.infectedSecondary ) || level.infectedSecondary == "" )
	{
		setDvar( "infectedSecondary", "hatchet_mp" );
		level.infectedSecondary = getDvar( "infectedSecondary" );
	}
	level.infectedTacInsert = getDvarIntDefault( "enableTacInsert", 1 );
	if( level.infectedTacInsert )
	{
		level.infectedTactical = "tactical_insertion_mp";
	}
	else
	{
		level.infectedTactical = "none";
	}
}

overwrite_class()
{
	level.disableweapondrop = 1;
   	game["strings"]["change_class"] = undefined;
	self endon("disconnect");
	level endon( "game_ended" );
	for(;;)
	{
		self waittill_any("changed_class", "spawned_player");
		self give_loadout( self.pers[ "team" ] );
	}
}

give_loadout( Team )
{
	self takeallweapons();
	if( Team == "allies" ) //infected team
	{
		if( level.infectedCount == 1 )
		{
			self thread take_weapons_on_kill();
			if( isDefined( level.survivorPrimary ))
			{
				self giveWeapon( level.primaryWeaponKeys[ level.survivorPrimary ]);
				self switchToWeapon( level.primaryWeaponKeys[ level.survivorPrimary ]);
			}
			if( isDefined( level.survivorSecondary ))
			{
				self giveWeapon( level.secondaryWeaponKeys[ level.survivorSecondary ]);	
			}
		}
		else
		{
			if( isDefined( level.infectedPrimary ))
			{
				self giveWeapon( level.infectedPrimary );
				self switchToWeapon( level.infectedPrimary );
			}
			if( isDefined( level.infectedSecondary ))
			{
				self giveWeapon( level.infectedSecondary );
			}
			if( isDefined( level.infectedTactical ))
			{
				self giveWeapon( level.infectedTactical );
			}
		}
	}
	else
	{
		if( isDefined( level.survivorPrimary ))
		{
			self giveWeapon( level.primaryWeaponKeys[ level.survivorPrimary ]);
			self switchToWeapon( level.primaryWeaponKeys[ level.survivorPrimary ]);
		}
		if( isDefined( level.survivorSecondary ))
		{
			self giveWeapon( level.secondaryWeaponKeys[ level.survivorSecondary ]);	
		}
	}
	self ClearPerks();
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
}

waitForDeath()
{
	self endon( "disconnect" );
	self endon( "stop_thread" );
	level endon( "game_ended" );
	
	for( ;; )
	{
		self waittill( "death" );
		
		self.infected = true;
		level.totalAlive -=1;
		level.infectedCount += 1;
		self maps\mp\teams\_teams::changeteam( "allies" );
		self thread saveXUID( self getXUID() );
		self notify( "stop_thread" );
	}
}

take_weapons_on_kill()
{
	self endon( "force_end" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	while( true )
	{
		if( level.infectedCount == 1 )
		{
			wait 0.25;
		}
		else
		{
			self give_loadout( self.pers[ "team" ] );
			self notify( "force_end" );
		}
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

spawnBot( value )
{
	for( i = 0; i < value; i++ )
	{
		self thread maps\mp\bots\_bot::spawn_bot( "axis" );
	}
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

infectedHUD()
{
	level endon( "game_ended" );
	level waittill( "prematch_over" );
	level.onScreenText = createServerFontString( "objective", 1.75 );
	while( true )
    {
    	if( !isDefined( level.game_started ))
    	{
        	level.onScreenText setPoint( "CENTER", "CENTER", 0, 150 );
        	level.onScreenText.label = &"^1Choosing First Infected... ";
        	level.onScreenText setValue( level.count_down );
        }
        else
        {
        	level.onScreenText setPoint( "CENTER", "CENTER", -355, 150 );
       		if( level.totalAlive == 1 || level.totalAlive == 0 )
        	{
        		level.onScreenText.label = &"Survivors Left: ^1";
        	}
       		else
        	{
        		level.onScreenText.label = &"Survivors Left: ^5";
        	}
        	level.onScreenText setValue( level.totalAlive );
        }
        wait 0.05;
    }
}

countdown( waittime )
{
	level endon( "game_started" );
	level.count_down = waittime;
	level waittill( "prematch_over" );
	wait 1;
	for( i = -10; i < waittime; i++ )
	{
		level.count_down--;
		i++;
		wait 1;
		if( level.count_down == 0 )
		{
			level.game_started = 1;
			level.firstinfected = pickRandomPlayer();
			level.firstinfected.infected = true;
			level.firstinfected suicide();
			level.firstinfected maps\mp\teams\_teams::changeteam( "allies" );
			level notify( "game_started" );
		}
	}
}

EndInfected()
{
	level endon( "game_ended" );
    while( true )
    {
		if( level.totalAlive == 0 && isDefined( level.game_started ))
		{
			thread endgame( "allies", "^7The Infected Win!" );
			break;
		}
		else
		{
			wait 0.5;
		}
	}
}
