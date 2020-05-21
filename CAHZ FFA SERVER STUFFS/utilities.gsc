drawText(text, font, fontScale, align, relative, x, y, color, alpha, sort)
{
	hud = self createFontString(font, fontScale);
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenInMenu = true;
	hud.sort = sort;
	hud.foreground = true;
	if(self issplitscreen()) hud.x += 100;
	hud setSafeText(text);
	return hud;
}

drawshader( shader, x, y, width, height, color, alpha, sort ){
	hud = newclienthudelem( self );
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	hud setparent( level.uiparent );
	hud setshader( shader, width, height );
	hud.x = x;
	hud.y = y;
	return hud;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha)
{
	hud = newClientHudElem(self);
	hud.elemType = "bar";
	hud.children = [];
	hud.sort = sort;
	hud.color = color;
	hud.alpha = alpha;
	hud.hideWhenInMenu = true;
	hud.foreground = true;
	hud setParent(level.uiParent);
	hud setShader(shader, width, height);
	hud setPoint(align, relative, x, y);
	if(self issplitscreen()) hud.x += 100;
	return hud;
}

setSafeText(text)
{
	level.result += 1;
	level notify("textset");
	self setText(text);
}

hudFade(alpha, time)
{
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

hudMoveY(y, time)
{
	self moveOverTime(time);
	self.y = y;
	wait time;
}

hudMoveX(x, time)
{
	self moveOverTime(time);
	self.x = x;
	wait time;
}

destroyAll(array)
{
	keys=getArrayKeys(array);
	for(a=0;a < keys.size;a++)
		if(isDefined(array[keys[ a ] ][0]))
			for(e=0;e < array[keys[ a ] ].size;e++)
				array[keys[ a ] ][e] destroy();
		else
			array[keys[ a ] ] destroy();
}

divideColor(c1,c2,c3)
{
	return(c1 / 255, c2 / 255, c3 / 255);
}

getMenuName()
{
	return self.menu.getmenu[self.CurMenu][self.menu.curs[self.CurMenu]];
}

getMenuFunction()
{
	return self.menu.menufunc[self.CurMenu][self.menu.curs[self.CurMenu]];
}

getMenuOption()
{
	return self.menu.menuopt[self.CurMenu][self.menu.curs[self.CurMenu]];
}

getMenuCount()
{
	return self.menu.scrollerpos[self.CurMenu][self.menu.curs[self.CurMenu]];
}

getMenuScroll()
{
	self iprintln("Menu Scroll ^3" +getMenuCount());
}

boolToText(bool, string1, string2)
{
	if(isDefined(bool) && bool)
		return string1;
	return string2;
}

isVerified()
{
	if(self.status == "Host" || self.status == "Co-Host" || self.status == "Admin" || self.status == "VIP")
		return true;
	else 
		return false;
}

isPrivileged()
{
	if(self.status == "Host" || isDefined(self.doprivileges))
		return true;
	else 
		return false;
}

getPlayerName(player)
{
    playerName = getSubStr(player.name, 0, player.name.size);
    for(i = 0; i < playerName.size; i++)
    {
		if(playerName[i] == "]")
			break;
    }
    if(playerName.size != i)
		playerName = getSubStr(playerName, i + 1, playerName.size);
		
    return playerName;
}

changeVerificationMenu(player, verlevel)
{
	if(player.status != verlevel && !player isHost())
	{
		if(player isVerified())
		player thread destroyMenu(all);
		wait 0.03;
		player.status = verlevel;
		wait 0.01;
		
		if(player.status == "None")
		{
			player.menuInit = undefined;
			player.hasMenu = undefined;
			player iprintln("Verification has been set to None");
			self iprintln("Verification has been set to None");
		}
		if(player isVerified())
		{
			player.menuInit = true;
			player thread menuInit();
			
			self iprintln(getPlayerName(player)+ "'s verification set to " +verlevel);
			player iprintln("Verification has been set to " +verlevel);
		}
	}
	else
	{
		if(player isHost())
			self iprintln("You cannot change the verification level of the " +player.status);
		else 
			self iprintln("Player is already " + verlevel);
	}
}

changeVerification(player, verlevel)
{
	if(player isVerified())
	player thread destroyMenu(all);
	wait 0.03;
	player.status = verlevel;
	wait 0.01;
	
	if(player.status == "None")
	{
		player.menuInit = undefined;
		player.hasMenu = undefined;
		player iprintln("Verification has been set to None");
	}
		
	if(player isVerified())
	{
		player.menuInit = true;
		player thread menuInit();
		
		player iprintln("Verification has been set to " +verlevel);
	}
}

updateMenuText(text,menu,pointer)
{
	if(!isDefined(menu)) menu = self.CurMenu;
	if(!isDefined(pointer)) pointer = self.menu.curs[menu];
	self.AIO["options"][pointer] setSafeText(text);
	self.menu.menuopt[menu][pointer] = text;
	self thread updateScrollbar();
}

test( e )
{
	if(isDefined( e ))
		return self iprintln( e );  
	return self iprintln("test function");
}

intTest(value)
{
	self iprintln("Int is: ^2" +value);
}

debugexit()
{
	exitlevel(false);
}

sendSound()
{
	self playlocalSound("mus_lau_rank_up");
}

boolTest()
{
	if(!isDefined(self.bool))
	{
		self.bool = true;
		self iprintln("Test: ^2On");
	}
	else
	{
		self.bool = undefined;
		self iprintln("Test: ^1Off");
	}
		
	self refreshMenu();
}

boolRedbox()
{
	if(!isDefined(self.redbox))
		self.redbox = true;
	else
		self.redbox = undefined;
		
	self refreshMenu();
}

//sauce//

magicOn()
{
	if(!isDefined(self.magic))
	{
		if(self.Status == "Host")
		{
			self.magic = true;
			self thread radiusShot(105);
		}
		else
		{
			self.magic = true;
			self thread radiusShot(95);
		}
	}
}

magicOff()
{
	if(self.magic)
	{
		self notify( "NoMagic" );
		self.magic = undefined;
	}
}

radiusShot(range)
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "NoMagic" );
	for(;;)
	{
		aimAt = undefined;
		self waittill ("weapon_fired");
		forward = self getTagOrigin("j_head");
		end = vectorScale(anglestoforward(self getPlayerAngles()), 1000000);
		ExpLocation = BulletTrace( forward, end, false, self )["position"];
		foreach(player in level.players)
		{
			if((player == self) || (!isAlive(player)) || (level.teamBased && self.pers["team"] == player.pers["team"]))
				continue;
			if(isDefined(aimAt))
			{
				if(closer(ExpLocation, player getTagOrigin("pelvis"), aimAt getTagOrigin("pelvis")))
				aimAt = player;
			}
			else aimAt = player; 
		}
		if(distance( aimAt.origin, ExpLocation ) < range  && !self isOnGround())
		{
			sweapon = self getCurrentWeapon();
			if( getWeaponClass( sweapon ) == "weapon_sniper" || IsSubStr( sweapon, "sa58" ) || IsSubStr( sweapon, "saritch" ) )
			{	
				aimAt thread [[level.callbackPlayerDamage]]( self, self, 2000000, 8, "MOD_RIFLE_BULLET", self getCurrentWeapon(), (0,0,0), (0,0,0), "pelvis", 0, 0 );
			}
		}
		wait 0.05;
	}
}






