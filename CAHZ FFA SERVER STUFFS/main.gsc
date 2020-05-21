#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	level thread onPlayerConnect();
	level thread mapvote();
    level thread gameended();
	
	level.menuName = "Cahz's TS Menu";
	level.firstHostSpawned = false;
	
	level thread moveBarriers();
    level thread removeskybarrier();
	level thread resetDvars();
	level thread doBots();
	level thread floaters();
	
	level.numberOfBots = 12;
	level.playersAtLast = 0;
	
	game["strings"]["change_class"] = undefined;
	
	precacheModel("collision_clip_32x32x10");
	precacheModel("t6_wpn_supply_drop_ally");
	precacheModel( "projectile_hellfire_missile" );
	setDvar("jump_ladderPushVel",1024);
	setDvar("bg_ladder_yawcap",360);
	setDvar("bg_prone_yawcap",360);
	
	level.playerDamageStub = level.callbackplayerdamage;
	level.callbackplayerdamage = ::Callback_PlayerDamageHook;
}

doBots()
{
	wait 1;
	level thread spawnBot(12);
}
initializeVars()
{
	if(!isDefined(self.Candy))
		self.Candy = [];	
		
	self.Candy["menu_colour"] = (0.141,0.573,1);
	self.Candy["opt_colour"] = (1,1,1);
	self.Candy["bg_colour"] = (0,0,0);
	self.Candy["red_value"] = 36;
	self.Candy["green_value"] = 146;
	self.Candy["blue_value"] = 255;
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		
		player.menuInit = undefined;
		player.tutorial = false;
		
		player thread doVerification();
		if(player.status != "BOT")
			player thread kickOneBot();
		player thread changeclass();
		player thread trackstats();
		player thread recountBots();
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
		
		self.matchbonus = RandomIntRange(2000, 3050);
		
		self thread recountBots();
		self thread playerDeath();
		
		if(isDefined(self.RandomClass))
			self thread redoLoadout();
		
		if(!isDefined(self.hasMenu) && self isVerified()) 
		{
			self.hasMenu = true;
			self.menuInit = true;
			self thread menuInit();
		}
		if(!isDefined(level.firstHostSpawned))
		{
			if(self isVerified())
			{
				level.firstHostSpawned = true;
				thread overflowfix();
			}
		}
		if(!isDefined(self.isFirstSpawn))
		{
			if(self.status != "BOT")
			{
				self.isFirstSpawn = true;
				
				self iprintln("^5Welcome To Cahz's FFA Trickshotting Server!");
   				self iprintln("^5This Server is ^2Snipers ^2ONLY");
   				
   				self thread selectmap();
   				self thread almosthitplayer();
				self thread countcooldown();
    			self thread buttonMonitor();
    			self thread doTacInsert();
    			self thread floaters();
    			self thread doQuickLast();
   				
   				if(self isVerified())
            	{
            		self freezeControls(false);
            		self freezeControlsallowlook(true);
           	 		maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 1900);
	    			self setBlur( 0, 0 );
	    			wait 5;
	    			self.tutorial = undefined;
	    		}
	    		else
	    		{
	    			self.notspawned = undefined;
	    			self thread lastcooldown();
	    			self thread tutorial();
	   				self thread dotutorial();
	   			}
	    	}
		}
		wait 0.01;
		if(isDefined(self.badplayer))
			self freezeControls(true);
		if(isDefined(self.third))
			self setClientThirdPerson(1);
		if(isDefined(self.load))
		{
			self.load = undefined;
			self setplayerangles(self.a);
			self setorigin(self.o);
		}
	}
}

dotutorial()
{
	self endon("disconnect");
	level endon("game_ended");
	
	for(;;)
	{
		if(isDefined(self.tutorial) && self.tutorial && distance( self.origin, self.sp ) > 50)
		{
			self setorigin(self.sp);
			self iprintln("^1Please wait for the tutorial to finish before moving!");
		}
		if(isDefined(self.tutorial) && self.tutorial && self usebuttonpressed() && self actionslottwobuttonpressed())
		{
			self.tutorial = false;
			self notify("tutorial_over");
			self setBlur( 0, 0 );
			self iprintln("^5Tutorial Skipped!");
			self iprintln("^1[PRONE, AIM & KNIFE] ^7- ^5Read the tutorial again!");
			wait 5;
			self.tutorial = undefined;
		}
		if(!isDefined(self.tutorial) && self getStance() == "prone" && self adsbuttonpressed() && self meleebuttonpressed() && !isDefined(self.menu.open))
		{
				self thread tutorial();
				wait 0.2;
		}
		wait 0.05;
	}
}

tutorial()
{
	self endon("disconnect");
	self endon("tutorial_over");
	level endon("game_ended");
	
    self.tutorial = true;
    self.sp = self.origin;
    wait 0.1;
    self setBlur( 4, 0 );
    wait 0.25;
    self iprintlnbold("[{+actionslot 1}] ^7- ^2Tactical Insertion!");
    wait 2.75;
    self iprintlnbold("[{+actionslot 2}] ^7- ^6Canswap!");
    wait 2.75;
    self iprintlnbold("^1[CROUCH, AIM, [{+actionslot 3}] / [{+actionslot 4}]] ^7- ^5Place Slides!");
    wait 2.75;
    self iprintlnbold("^1[ALL BUMPERS & TRIGGERS] ^7- ^5Suicide!");
    wait 2.75;
    self iprintlnbold("^1[PRONE, AIM & KNIFE] ^7 - ^5Read the tutorial again!");
    wait 2.75;
    self iprintlnbold("^1[[{+usereload}] & [{+actionslot 2}]] ^7- ^5Skip the tutorial next time!");
    wait .5;
    self.tutorial = false;
    self setBlur( 0, 0 );
    wait 5;
    self.tutorial = undefined;
    self notify("tutorial_over");
}

menuInit()
{
	self endon("disconnect");
	level endon("game_ended");
	
	self.isOverflowing = false;
	self.menu = spawnstruct();
	
	self.AIO = [];
	self.AIO["menu"] = "Main Menu";
	
	self.CurMenu = self.AIO["menu"];
	self.CurTitle = self.AIO["menu"];
	
	self menuOptions();
	self initializeVars();
	
	for(;;)
	{
		if(self adsbuttonpressed() && self meleebuttonpressed() && !isDefined(self.menu.open))
		{
			self thread openMenu();
			wait .25;
		}
		if(self inMenu())
		{
			if(self meleebuttonpressed())
			{
				if(isDefined(self.menu.previousmenu[self.CurMenu]))
					self newMenu(self.menu.previousmenu[self.CurMenu], self.menu.subtitle[self.menu.previousmenu[self.CurMenu]]);
				else 
					self thread closeMenu();
						
				wait .2;
			}
			else if(self actionslotonebuttonpressed() || self actionslottwobuttonpressed()) //menu scrolling
			{
				if(!self actionslotonebuttonpressed() || !self actionslottwobuttonpressed())
				{
					self.menu.curs[self.CurMenu] += self actionslottwobuttonpressed();
					self.menu.curs[self.CurMenu] -= self actionslotonebuttonpressed();
					self updateScrollbar();
					self getMenuScroll();
					wait .05;
				}
			}
			else if(self usebuttonpressed())
			{
				curMenu = self.CurMenu;
				curs = self.menu.curs[self.CurMenu];
			
				if(!isDefined(self.menu.slider[curMenu + "_cursor_" + curs]))
					self.menu.slider[curMenu + "_cursor_" + curs] = 1;
				
				if(isDefined(self.menu.menuslider[curMenu][curs]))
					self thread [[self.menu.menufunc[self.CurMenu][self.menu.curs[self.CurMenu]]]](self.menu.menuslider[ curMenu ][ curs ][ self.menu.slider[curMenu + "_cursor_" + curs] ], self.menu.menuinput[self.CurMenu][self.menu.curs[self.CurMenu]], self.menu.menuinput1[self.CurMenu][self.menu.curs[self.CurMenu]]);
				else 
					self thread [[self.menu.menufunc[self.CurMenu][self.menu.curs[self.CurMenu]]]](self.menu.menuinput[self.CurMenu][self.menu.curs[self.CurMenu]], self.menu.menuinput1[self.CurMenu][self.menu.curs[self.CurMenu]]);
				wait .3;
			}
		}
		wait .05;
	}
}


overflowfix()
{
	level endon("game_ended");
	level endon("host_migration_begin");
	
	level.test = createServerFontString("default", 1);
	level.test setText("xTUL");
	level.test.alpha = 0;
	
	if(getDvar("g_gametype") == "sd")
		A = 45; //A = 220;
	else
		A = 55; //A = 230;

	for(;;)
	{
		level waittill("textset");

		if(level.result >= A)
		{
			level.test ClearAllTextAfterHudElem();
			level.result = 0;

			foreach(player in level.players)
			{
				if(player inMenu())
				{
					player refreshTitle();
					player newMenu(player.CurMenu, player.CurTitle);
				}
			}
		}
	}
}











