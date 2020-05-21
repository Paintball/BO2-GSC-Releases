menuOptions()
{
	if(self isVerified())
	{
		if(self.status == "VIP")
		{
			addMenu(self.AIO["menu"], undefined, self.AIO["menu"]);
			addOpt(self.AIO["menu"], "Toggle UAV", ::toggleuav);
			addOpt(self.AIO["menu"], "Refill Killstreaks", ::FullStreak);
			addOpt(self.AIO["menu"], "Drop Canswap", ::dropcan);
			addOpt(self.AIO["menu"], "Toggle Knife Lunge", ::knifelungetoggle);
			addOpt(self.AIO["menu"], "Toggle Third Person", ::thirdtoggle);
			addOpt(self.AIO["menu"], "Spawn Carepackage Stall", ::carePackageStall);
			addOpt(self.AIO["menu"], "Give Csgo Knife", ::csgoKnife);
		}
		if(self.status == "Host" || self.status == "Co-Host" || self.status == "Admin")
		{
			addMenu(self.AIO["menu"], undefined, self.AIO["menu"]);
			
			D="D";
			addOpt(self.AIO["menu"], "Self Menu", ::newMenu, D, "Self Menu");
				addMenu(D, self.AIO["menu"], "Self Menu");
				addOpt(D, "Toggle UAV", ::toggleuav);
				addOpt(D, "Refill Killstreaks", ::FullStreak);
				addOpt(D, "Drop Canswap", ::dropcan);
				addOpt(D, "Toggle Knife Lunge", ::knifelungetoggle);
				addOpt(D, "Toggle Third Person", ::thirdtoggle);
				addOpt(D, "Spawn Carepackage Stall", ::carePackageStall);
				addOpt(D, "Give Csgo Knife", ::csgoKnife);
			
				A="A";
				addOpt(self.AIO["menu"], "Admin Menu", ::newMenu, A, "Admin Menu");
					addMenu(A, self.AIO["menu"], "Admin Menu");
						addOpt(A, "Spawn Mystery Box", ::weaponboxSpawn);
						addOpt(A, "Spawn Crate", ::Crate);
						addOpt(A, "Spawn Platform", ::Platform);
				C="C";
				addOpt(self.AIO["menu"], "Bot Menu", ::newMenu, C, "Bot Menu");
					addMenu(C, self.AIO["menu"], "Bot Menu");
						addOpt(C, "Teleport All Bots", ::TeleportAllBots);
						addOpt(C, "Freeze/Unfreeze Bots", ::freezeToggle);
		}
		addOpt(self.AIO["menu"], "Players", ::newMenu, "PlayersMenu", "Players");
			addMenu("PlayersMenu", self.AIO["menu"], "Players");
				for (i = 0; i < 18; i++)
					addMenu("pOpt " + i, "PlayersMenu", "");
	}
}

playerMenu()
{
	self endon("disconnect");
	level endon("game_ended");
	
	self.menu.menucount["PlayersMenu"] = 0;
	
	for (i = 0; i < 18; i++)
	{
		player = level.players[i];
		playerName = getPlayerName(player);
		playersizefixed = level.players.size - 1;
		
        if(self.menu.curs["PlayersMenu"] > playersizefixed)
        {
            self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
            self.menu.curs["PlayersMenu"] = playersizefixed;
        }
		addOpt("PlayersMenu", "["+player.status+"^7] " + playerName, ::newMenu, "pOpt " + i, "["+player.status+"^7] " + playerName);
			addMenu("pOpt " + i, "PlayersMenu", "["+player.status+"^7] " + playerName);
				if(self.Status == "Host" || self.Status == "Co-Host" || self.Status == "Admin")
				{
					addOpt("pOpt " + i, "Teleport To Me", ::teletome, player);
					addOpt("pOpt " + i, "Teleport To Him", ::teletohim, player);
					if(player.status != "Host" && player.status != "Co-Host" && player.status != "Admin" && player.status != "VIP")
					{
						addOpt("pOpt " + i, "Freeze/Unfreeze", ::freezeplayer, player);
						addOpt("pOpt " + i, "Dont Let Player Kill Toggle", ::func_dontletkill, player);
						addOpt("pOpt " + i, "Send To Prison", ::teleporttoprison, player);
					}
					if(self.status == "Host" || self.status == "Co-Host")
					{
						if(player.status != "BOT" && player.status != "Host" && player.status != "Co-Host" && player.status != "Admin" && player.status != "VIP")
						{
							addOpt("pOpt " + i, "Get GUID", ::func_guid, player);
							addOpt("pOpt " + i, "Give VIP", ::func_givevip, player);
						}
					}
					addOpt("pOpt " + i, "Kick Player", ::func_kick, player);
				}
				addOpt("pOpt " + i, "Start Vote To Kick", ::func_votekick, player);
	}
}

openMenu()
{
	self.menu.open = true;
	self.recreateOptions = true;
	self drawMenu();
	self refreshMenu();
	self updateScrollbar();
	self.recreateOptions = undefined;
}

closeMenu()
{
	self.menu.open = undefined;
	self destroyMenu(true);
}

drawMenu()
{
	self.AIO["HUD"]["Background"] = self createRectangle("RIGHT","CENTER",215,-90,160,210,self.Candy["bg_colour"],"white",0,0);
	self.AIO["HUD"]["Background"] thread hudFade(.5, .1);
	
	self.AIO["HUD"]["Topline"] = self createRectangle("CENTER","CENTER",135,-195,160,1,self.Candy["menu_colour"],"white",5,0);
	self.AIO["HUD"]["Topline"] thread hudFade(1, .1);
	
	self.AIO["HUD"]["Bottomline"] = self createRectangle("CENTER","CENTER",135,15,160,1,self.Candy["menu_colour"],"white",5,0);
	self.AIO["HUD"]["Bottomline"] thread hudFade(1, .1);
	
	self.AIO["HUD"]["Leftline"] = self createRectangle("CENTER","CENTER",55,-90,1,210,self.Candy["menu_colour"],"white",5,0);
	self.AIO["HUD"]["Leftline"] thread hudFade(1, .1);
	
	self.AIO["HUD"]["Rightline"] = self createRectangle("CENTER","CENTER",215,-90,1,210,self.Candy["menu_colour"],"white",5,0);
	self.AIO["HUD"]["Rightline"] thread hudFade(1, .1);
	
	self.AIO["HUD"]["Title"] = self drawText(level.menuName,"big",1.6,"LEFT","CENTER",60,-184,(1,1,1),0,10);
	self.AIO["HUD"]["SubTitle"] = self drawText("","big",1.5,"LEFT","CENTER",60,-166,(1,1,1),0,10);
	
	self refreshTitle();
	self drawText(self.CurTitle);
}

drawText(menu)
{
	self.AIO["HUD"]["SubTitle"] setSafeText(menu);
		
	if(isDefined(self.recreateOptions))
		for(i = 0; i < 7; i++)
			self.AIO["OPT"][i] = drawText("","small",1.4,"LEFT","CENTER",60,-142+(i*23),self.Candy["opt_colour"],1,10);
}

updateScrollbar()
{
	if(self.menu.curs[self.CurMenu]<0)
		self.menu.curs[self.CurMenu] = self.menu.menuopt[self.CurMenu].size-1;
		
	if(self.menu.curs[self.CurMenu]>self.menu.menuopt[self.CurMenu].size-1)
		self.menu.curs[self.CurMenu] = 0;
	
	if(!isDefined(self.menu.menuopt[self.CurMenu][self.menu.curs[self.CurMenu]-3])||self.menu.menuopt[self.CurMenu].size<=7)
	{
    	for(i = 0; i < 7; i++)
    	{
	    	if(isDefined(self.menu.menuopt[self.CurMenu][i]))
				self.AIO["OPT"][i] setSafeText(self.menu.menuopt[self.CurMenu][i]);
			else
				self.AIO["OPT"][i] setSafeText("");
					
			if(self.menu.curs[self.CurMenu] == i)
				self.AIO["OPT"][i].color = self.Candy["menu_colour"];
			else
				self.AIO["OPT"][i].color = self.Candy["opt_colour"];
		}
	}
	else
	{
	    if(isDefined(self.menu.menuopt[self.CurMenu][self.menu.curs[self.CurMenu]+3]))
	    {
			xePixTvx = 0;
			for(i=self.menu.curs[self.CurMenu]-3;i<self.menu.curs[self.CurMenu]+4;i++)
			{
			    if(isDefined(self.menu.menuopt[self.CurMenu][i]))
					self.AIO["OPT"][xePixTvx] setSafeText(self.menu.menuopt[self.CurMenu][i]);
				else
					self.AIO["OPT"][xePixTvx] setSafeText("");
					
				if(self.menu.curs[self.CurMenu]==i)
					self.AIO["OPT"][xePixTvx].color = self.Candy["menu_colour"];
				else
					self.AIO["OPT"][xePixTvx].color = self.Candy["opt_colour"];
					
				xePixTvx ++;
			}  
		}
		else
		{
			for(i = 0; i < 7; i++)
			{
				self.AIO["OPT"][i] setSafeText(self.menu.menuopt[self.CurMenu][self.menu.menuopt[self.CurMenu].size+(i-7)]);
				
         		if(self.menu.curs[self.CurMenu]==self.menu.menuopt[self.CurMenu].size+(i-7))
					self.AIO["OPT"][i].color = self.Candy["menu_colour"];
				else
					self.AIO["OPT"][i].color = self.Candy["opt_colour"];
			}
		}
	}
}

refreshTitle()
{
	if(isDefined(self.AIO["HUD"]["Title"]))
		self.AIO["HUD"]["Title"] destroy();
	
	self.AIO["HUD"]["Title"] = self drawText(level.menuName,"big",2,"LEFT","CENTER",60,-185,(1,1,1),1,10);
	self.AIO["HUD"]["Title"].glowAlpha = 1;
	self.AIO["HUD"]["Title"].glowColor = self.Candy["menu_colour"];
	self.AIO["HUD"]["SubTitle"] thread hudFade(1, .1);
}

destroyMenu(all)
{
	if(isDefined(all))
	{
		for(i=0;i<self.AIO["OPT"].size;i++) 
		self.AIO["OPT"][i] destroy();
		
		self destroyAll(self.AIO["HUD"]);
	}
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
