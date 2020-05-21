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

addMenu(Menu, prevmenu, menutitle)
{
    self.menu.getmenu[Menu] = Menu;
    self.menu.scrollerpos[Menu] = 0;
    self.menu.curs[Menu] = 0;
    self.menu.menucount[Menu] = 0;
    self.menu.subtitle[Menu] = menutitle;
    self.menu.previousmenu[Menu] = prevmenu;
}

addOpt(Menu, Text, Func, arg1, arg2, toggle)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    if(isDefined(toggle))
    	self.menu.toggle[Menu][Num] = toggle;
    else
    	self.menu.toggle[Menu][Num] = undefined;
    self.menu.menucount[Menu]++;
}

addSlider(Menu, Text, Slider, Func, arg1, arg2)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];
    
    if(isDefined(slider))
    	self.menu.menuslider[Menu][Num] = strTok(slider,";");
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    self.menu.menucount[Menu]++;
}

newMenu(menu, title)
{
	for(i = 0; i < self.AIO["OPT"].size; i++) 
		self.AIO["OPT"][i].alpha = 0;
	self.AIO["Title"].alpha = 0;
	
	if(menu == self.AIO["menu"]) 
		self thread drawText(self.AIO["menu"]);
	else
		self thread drawText(title);
			
	if(menu == "PlayersMenu")
	{
		self playerMenu();
		self thread drawText("Players");
	}
	else 
		self thread drawText(title);
	
	self.CurMenu = menu;
	self.CurTitle = title;
	
	self.menu.scrollerpos[menu] = self.menu.curs[menu];
	self.menu.curs[menu] = self.menu.scrollerpos[menu];
	
	for(i = 0; i < self.AIO["OPT"].size; i++) 
		self.AIO["OPT"][i].alpha = 1;
	self.AIO["SubTitle"].alpha = 1;
	
	self refreshTitle();
	self updateScrollbar();
}

refreshMenu()
{
	savedCurs = [];
	foreach(key in getArrayKeys(self.menu.curs))
		savedCurs[key] = self.menu.curs[key];
	self menuOptions();
	foreach(key in getArrayKeys(savedCurs))
		self.menu.curs[key] = savedCurs[key];
	if(self inMenu())
	{
		self refreshTitle();
		self updateScrollbar();
	}
}

inMenu()
{
	if(isDefined(self.hasMenu) && isDefined(self.menu.open))
		return true;
	return false;
}
