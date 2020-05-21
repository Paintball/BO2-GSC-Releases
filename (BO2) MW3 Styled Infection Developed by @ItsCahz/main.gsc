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
	level thread onPlayerConnect();
	level thread StartInfected();
	level thread EndInfected();
	//wait 1;
	//level thread spawnBot(10);	
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread checkName(player.name);
		player maps\mp\teams\_teams::changeteam("axis");
		player thread onScreenText();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	for(;;)
	{
		self waittill("spawned_player");
		level notify("update_text");
        
		self givePerks();
        
		if(!isDefined(self.isFirstSpawn))
		{
			self.isFirstSpawn = true;
			self iprintln("Welcome to MW3 Style Infection!");
			self iprintln("Developed by: ^5@ItsCahz");
		}
		if(self.pers["team"] == "axis")
		{
			if(isDefined(self.infected))
				self maps\mp\teams\_teams::changeteam("allies");
			else
			{
				self iprintlnbold("^5You Are Not Infected! Stay Alive!");
        		
				self thread giveWeapons("Survivor");
				self thread monitorWeapons();
				self thread waitForDeath();
        		
				level.totalAlive += 1;
			}
		}
		if(self.pers["team"] == "allies")
		{
			if(!isDefined(self.infected))
				self maps\mp\teams\_teams::changeteam("axis");
			else
			{
				self iprintlnbold("^1You Are Infected! Kill the Survivors!");
				
				if(level.infectedCount == 1)
					self thread giveWeapons("Survivors");
				else
					self thread giveWeapons("Infected");
				
				self thread monitorWeapons();
			}
		}
	}
}

