#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_utility;

init()
{
	if ( !isDefined ( level.Mod_Loaded ) )
	{
		level.Mod_Loaded = true;
		level thread drawZombiesCounter();
		level thread onPlayerConnect();
		level thread add_bots();
	}
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
		wait 3;
		if(isDefined(self.pers["isBot"])&& self.pers["isBot"])
		{
			self EnableInvulnerability();
		}
		else
		{
			self.ignoreme = 1;
			self.score = 1000000;
			self thread debugButtonMonitor();
			wait 3;
			self giveWeapon ( "dsr50_zm" );
			self switchToWeapon ( "dsr50_zm" );
		}
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
	botsToSpawn = 1;
	for( i=0; i < botsToSpawn; i++ )
	{
		zbot_spawn();
		wait 1;
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

zbot_spawn()
{
	bot = AddTestClient();
	if ( !IsDefined( bot ) )
	{
		return;
	}
	bot.pers["isBot"] = true;
	bot.equipment_enabled = false;
	return bot;
}

debugButtonMonitor()
{
	self notify("reset_debug_binds");
	self endon("disconnect");
	self endon("reset_debug_binds");
	level endon( "end_game" );
	
	for(;;) 
	{
		if(self adsbuttonpressed() && self actionslotonebuttonpressed())
		{
			foreach ( player in level.players )
			{
				if ( isDefined ( player.pers["isBot"] ) && player.pers["isBot"] )
				{
					player setorigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
				}
			}
		}
		if(self adsbuttonpressed() && self secondaryoffhandbuttonPressed())
		{
			if(!isDefined(self.god))
			{
				self.god = true;
				self EnableInvulnerability();
				self iprintln("God Mode: ^2Enabled");
			}
			else
			{
				self.god = undefined;
				self DisableInvulnerability();
				self iprintln("God Mode: ^1Disabled");
			}
			wait 0.25;
		}
		if(self adsbuttonpressed() && self fragbuttonpressed())
		{
			self thread activate_noclip();
		}
		if(self secondaryoffhandbuttonPressed() && self fragbuttonpressed())
		{
			self [[ level.spawnplayer ]]();
			wait 0.5;
		}
		wait 0.05;
	}
}

activate_noclip()
{
    if(!isDefined(self.UFO))
    {
    	self.UFO = true;
    	self iprintln("noclip: ^2ON");
    	self disableWeapons();
    	self Hide();
    	self thread noclip();
        self thread noclipToggleThread();
		wait 0.5;
		self.noclipbound = true;
    }
}

noclipToggleThread()
{
	self endon("stop_toggleThread");
	for(;;)
	{
		if(self attackbuttonpressed())
		{
			if(isDefined(self.noclipbound))
			{
				self.noclipbound = undefined;
				self.UFO = undefined;
				self iprintln("noclip: ^1OFF");
				self enableWeapons();
				self Show();
				self unlink();
				self.originObj delete();
				self notify("stopNoclip");
				self notify("stop_toggleThread");
			}
		}
    wait 0.2;
	}
}

noclip()
{
    self endon("stopNoclip");
    self.originObj=spawn("script_origin",self.origin,1);
    self.originObj.angles=self.angles;
    self playerlinkto(self.originObj,undefined);

    for(;;)
    {
        if(self sprintbuttonpressed())
        {
            normalized=anglesToForward(self getPlayerAngles());
            scaled=vectorScale(normalized,20);
            originpos=self.origin + scaled;
            self.originObj.origin=originpos;
        }
        wait 0.05;
    }
}

drawZombiesCounter()
{
    level.zombiesCounter = createServerFontString("hudsmall" , 1.9);
    level.zombiesCounter setPoint("CENTER", "CENTER", "CENTER", 190);
    level thread updateZombiesCounter();
}

updateZombiesCounter()
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


