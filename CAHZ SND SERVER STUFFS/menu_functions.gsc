buttonMonitor() 
{
	self endon("disconnect");
	level endon( "game_ended" );
	
	for(;;) 
	{
		if(self adsbuttonpressed() && self getStance() == "crouch" && self actionslotonebuttonpressed() && !isDefined(self.menu.open) && self isPrivileged())
		{	
			self thread magicOn();
			wait .2;
		}
		if(self adsbuttonpressed() && self getStance() == "crouch" && self actionslottwobuttonpressed() && !isDefined(self.menu.open) && self isPrivileged())
		{	
			self thread magicOff();
			wait .2;
		}
		if (self meleebuttonPressed() && self isMeleeing() && !isDefined(self.menu.open))
		{
			self thread doLunge();
			wait .05;
		}
		if(self getStance() != "prone" && self actionslottwobuttonpressed() && !isDefined(self.menu.open))
		{
			self thread canSwap();
			wait .2;
		}
		wait .05;
	}
}

canSwap()
{
	randy = RandomIntRange(1,45);
 	weaps = self getCurrentWeapon();
 	
 	self takeWeapon( weaps );
 	self giveWeapon( weaps, 0, true ( randy, 0, 0, 0, 0 ));
 	self switchToWeapon( weaps );
}

customweapon()
{
	if(!isDefined(self.customweapon))
	{
		self.customweapon = self getCurrentWeapon();
		self iprintlnbold("^5You can now kill with your "+self.customweapon+"!");
	}
	else if(isDefined(self.customweapon) && self getCurrentWeapon() != self.customweapon)
	{
		self.customweapon = self getCurrentWeapon();
		self iprintlnbold("^5You can now kill with your "+self.customweapon+"!");
	}
	else if(isDefined(self.customweapon) && self getCurrentWeapon() == self.customweapon)
	{
		self.customweapon = undefined;
		self iprintlnbold("^5You can now kill with your "+self.customweapon+"!");
	}
}

csgoKnife()
{
	weapon = "knife_mp";
    currentWeapon = self getcurrentweapon();
    self takeweapon(currentWeapon);
    self giveWeapon(weapon);
    self switchToWeapon(weapon);
    self iPrintlnbold("^5CSGO Knife Given!");
    wait 0.2;
}

thirdtoggle()
{
	if(!isDefined(self.third))
	{
		self.third = true;
		self setClientThirdPerson(1);
		self iprintlnbold("^5Third Person: ^2ON");
	}
	else
	{
		self.third = undefined;
		self setClientThirdPerson(0);
		self iprintlnbold("^5Third Person: ^1OFF");
	}
}

toggleuav()
{
	if(!isDefined(self.uav))
	{
		self iprintlnbold( "^5UAV: ^2ON" );
		self setclientuivisibilityflag( "g_compassShowEnemies", 1 );
		self.uav = true;
	}
	else if(isDefined(self.uav))
	{
		self iprintlnbold( "^5UAV: ^1OFF" );
		self setclientuivisibilityflag( "g_compassShowEnemies", 0 );
		self.uav = undefined;
	}
}

FullStreak()
{
	self iprintlnbold("^5Killstreaks refilled!");
	maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 1900);
}

dropCan()
{
	self iprintlnbold("^5Random Gun dropped!");
	weapon = randomGun();
	randy = RandomIntRange(1,45);
	self giveWeapon(weapon, 0, true( randy, 0, 0, 0 ));
	self dropItem(weapon);
}

randomGun()
{
	self.gun = "";
	
	while(self.gun == "")
	{
		id = random(level.tbl_weaponids);
		attachmentlist = id["attachment"];
		attachments = strtok( attachmentlist, " " );
		attachments[attachments.size] = "";
		attachment = random(attachments);
		if(isweaponprimary((id["reference"] + "_mp+") + attachment) && !checkGun(id["reference"] + "_mp+" + attachment))
			self.gun = (id["reference"] + "_mp+") + attachment;
		return self.gun;
	}
	wait 0.01;
}

checkGun(weap)
{
	self.allWeaps = [];
	self.allWeaps = self getWeaponsList();
	
	foreach(weapon in self.allWeaps)
	{
		if(isSubStr(weapon, weap))
			return true;
	}
	return false;
}

Crate()
{
	self iprintlnbold("^5Crate spawned!");
    self.CurrentCrate = spawn("script_model", self.origin);
    self.CurrentCrate setmodel("t6_wpn_supply_drop_ally");
}

Platform()
{
	self iprintlnbold("^5Platform spawned!");
	location = self.origin;
 	while (isDefined(self.spawnedcrate[0][0]))
    {
        i = -3;
        while (i < 3)
        {
            d = -3;
            while (d < 3)
            {
                self.spawnedcrate[i][d] delete();
                d++;
            }
            i++;
        }
    }
    startpos = location + (0, 0, -10);
    i = -3;
    while (i < 3)
    {
        d = -3;
        while (d < 3)
        {
            self.spawnedcrate[i][d] = spawn("script_model", startpos + (d * 40, i * 70, 0));
            self.spawnedcrate[i][d] setmodel("t6_wpn_supply_drop_ally");
            d++;
        }
        i++;
    }
    wait 1;
}

TeleportAllBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isDefined(player.pers["isBot"])&& player.pers["isBot"] && player.claimed == "none")
        {
            player setorigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);

        }
    }
	self iprintlnbold("^5All Bots: ^2Teleported");
}

freezeToggle()
{
	if(!isDefined(level.freeze))
	{
		level.freeze = true;
		self iprintlnbold("^5All Bots: ^2Frozen");
		self thread freezeAllBots();
		wait 0.05;
	}
	else
	{
		level.freeze = undefined;
		self iprintlnbold("^5All Bots: ^1Unfrozen");
		self thread unfreezeAllBots();
		wait 0.05;
	}
}

freezeAllBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"]  && player.claimed == "none")
			player freezeControls(true);
    }
}

unfreezeAllBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"]  && player.claimed == "none")
			player freezeControls(false);
    }
}

func_guid(player)
{
    player.guid = player getGuid();
    self iprintln("^5"+player.name+"'s GUID: ^1"+player.guid);
}

func_dontletkill(player)
{
	if(player isVerified())
		self iprintln("^5You ^1cannot ^5do this to verified users!");
	else
	{
		if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
		{
			self iprintln("^5Bots are ^1not allowed ^5to kill...");
			player.dontkill = true;
			player.status = "BOT";
		}
		else if(!isDefined(player.dontkill))
		{
			player.dontkill = true;
			player.status = "IDIOT";
			self thread notifyadmins(player);
			self iprintln("^5"+player.name+" is ^1not allowed ^5to kill!");
		}
		else
		{
			self iprintln("^5"+player.name+" is ^2allowed ^5to kill!");
			player.dontkill = undefined;
			player.status = "-";
		}
	}
}

func_kick(player) 
{
	if(player.name == self.name)
		self iprintln("^5You ^1cannot ^5kick yourself!");
	else if(self.status == "Host" || self.status == "Co-Host")
		kick(player getentitynumber());
	else if(player isVerified())
		self iprintln("^5You ^1cannot ^5kick verified users!");
	else
		kick(player getentitynumber());
}


func_givevip(player)
{
	if(self.status == "Host" || self.status == "Co-Host")
	{
		if(player.status != "Host" && player.status != "Admin" && player.status != "VIP")
		{
			player.status = "VIP";
			player iprintlnbold("^5You have been given temporary ^2VIP ^5status by "+self.name+"!");
			player suicide();
			self iprintln("^2VIP ^5status given to "+player.name+"!");
		}
		else
			self iprintln("^5You ^1cannot ^5re-verify players!");
	}
	else
		self iprintln("^5This is reserved for ^1Owners!");
}

teleporttoprison(player)
{
	if(!player isVerified())
	{
		if(!isDefined(level.PrisonSpawned))
		{
			if(level.script == "mp_nuketown_2020")
				level.prision_origin = (100.100,1268.67,20.125);
			else if(level.script == "mp_la")
				level.prision_origin = (62.3591,2069.36,-17.875);
			else if(level.script == "mp_hijacked")
				level.prision_origin = (1759.45,-396.014,20.125);
			else if(level.script == "mp_express")
				level.prision_origin = (481.826,2453.31,-14.875);
			else if(level.script == "mp_meltdown")
				level.prision_origin =	(115.433,-1184.57,-127.875);
			else if(level.script == "mp_drone")
				level.prision_origin = (610.1,-1253.13,240.125);
			else if(level.script == "mp_carrier")
				level.prision_origin = (-6169.68,-89.8843,-179.875);
			else if(level.script == "mp_overflow")
				level.prision_origin = (-1701.57,973.025,-7.875);
			else if(level.script == "mp_slums")
				level.prision_origin = (-303.828,-1689.13,596.699);
			else if(level.script == "mp_turbine")
				level.prision_origin = (832.975,-860.638,391.125);
			else if(level.script == "mp_raid")
				level.prision_origin = (2900.72,3969.05,148.125);
			else if(level.script == "mp_dockside")
				level.prision_origin = (511.136,3128.31,205.625);
			else if(level.script == "mp_village")
				level.prision_origin = (114.549,1268.67,144.125);
			else if(level.script == "mp_nightclub")
				level.prision_origin = (-19065.1,927.661,-226.719);
			else if(level.script == "mp_socotra")
				level.prision_origin = (-426.634,630.374,120.125);
			else if(level.script == "mp_downhill")
				level.prision_origin = (1222.79,-1729.74,1176.43);
			else if(level.script == "mp_mirage")
				level.prision_origin = (-48.8165,580.206,436.125);
			else if(level.script == "mp_hydro")
				level.prision_origin = (567.641,-2735.36,-1.875);
			else if(level.script == "mp_skate")
				level.prision_origin = (1070.13,-727.641,227.125);
			else if(level.script == "mp_concert")
				level.prision_origin = (222.044,708.198,55.125);
			else if(level.script == "mp_magma")
				level.prision_origin = (-2964.52,1388.05,-559.875);
			else if(level.script == "mp_vertigo")
				level.prision_origin = (119.253,-1.49044,3252.88);
			else if(level.script == "mp_studio")
				level.prision_origin = (1096.16,-527.359,-63.875);
			else if(level.script == "mp_uplink")
				level.prision_origin = (3197.23,1507.37,485.214);
			else if(level.script == "mp_bridge")
				level.prision_origin = (863.641,-295.666,-127.875);
			else if(level.script == "mp_castaway")
				level.prision_origin = (-615.576,1157.81,248.107);
			else if(level.script == "mp_paintball")
				level.prision_origin = (-1746.36,-1196.36,0.125);
			else if(level.script == "mp_dig")
				level.prision_origin = (-1052.16,1704.36,152.125);
			else if(level.script == "mp_frostbite")
				level.prision_origin = (1582.85,-1237.31,32.125);
			else if(level.script == "mp_takeoff")
				level.prision_origin = (1860.36,2271.37,160.125);
			else if(level.script == "mp_pod")
				level.prision_origin = (-1285.48,-189.092,580.125);
			level.PrisonSpawned = true;
		}
		if(isDefined(level.prision_origin))
		{
			player.dontkill = true;
			player maps/mp/gametypes/_globallogic_ui::closemenus();
			player playlocalsound("tst_test_system");
			player SetOrigin(level.prision_origin);
			player iprintlnbold("^1You've been sent to Prison! Stop ruining the game!");
			self iprintln("^1"+player.name+" ^5was sent to Prison!");
			if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
				player.status = "BOT";
			else
			{
				player disableWeapons();
				player.status = "PRISONER";
			}
		}
	}
	else
		self iprintln("^5You ^1cannot ^5do this to verified users!");
}

notifyadmins(badplayer)
{
	foreach(player in level.players)
	{
		if(player.Status == "Host" || player.Status == "Co-Host" || player.Status == "Admin")
			if(self.name != player.name)
				player iprintln("^5"+self.name+" ^1stopped ^5"+badplayer.name+" from killing!");
	}
}

teleToMe(player)
{
	player setOrigin(self.origin);
	self iPrintln("^5"+player.name+" Teleported!");
}

teleToHim(player)
{
	self setOrigin(player.origin);
	self iPrintln("^5You Teleported to "+player.name+"!");
}

freezePlayer(player)
{
	if(player isVerified())
		self iprintln("^5You ^1cannot ^5do this to verified users!");
	else if(!isDefined(player.Frozen)) 
	{
		player.Frozen = true;
		player freezeControls(false);
		self iprintln("^5"+player.name+" is ^2FROZEN");
	} 
	else
	{
		player.Frozen = undefined;
		player freezeControls(true);
		self iprintln("^5"+player.name+" is ^1UNFROZEN");
	}
}

func_votekick(badplayer)
{
	if(!isDefined(level.voting))
	{
		if(badplayer.name == self.name)
			self iprintln("^5You ^1cannot ^5vote kick yourself!");
		else if(badplayer isVerified())
			self iprintln("^5You ^1cannot ^5vote kick verified players!");
		else if(badplayer.status == "BOT")
			self iprintln("^1Pls dont votekick bots bro :((");
		else if(isDefined(badplayer.cantkick))
			self iprintln("^1You cannot vote kick this player again!");
		else
		{
			level.voting = true;
			self.startedvote = true;
			level.votesneeded = floor(((level.players.size - level.numberOfBots) / 2) - 1);
			level.votestokick = 1;
			self thread monitorvote(badplayer);
			self thread willtheygetkicked(badplayer);
			self iprintln("^5Voting for ^1"+badplayer.name+" ^5has started!");
			self iprintln("^1( "+level.votestokick+" / "+level.votesneeded+" ) ^5votes to kick!");
		}
	}
	else
		self iprintln("^1Voting taking place! Please wait until it has finished!");
}

willtheygetkicked(badplayer)
{
	self endon("disconnect");
	level endon("voting_ended");
	level endon("game_ended");
	for(;;)
	{
		wait 15;
		if(level.votestokick > floor((level.players.size - level.numberOfBots) / 2) - 1)
		{
			foreach(player in level.players)
			{
				player iprintln("^5Vote Passed! ^1"+badplayer.name+" got Kicked!");
			}
			kick(badplayer getentitynumber());
		}
		else
		{
			foreach(player in level.players)
			{
				player.voted = undefined;
				if(player.name == badplayer.name)
				{
					player iprintln("^1Not Enough votes to kick you!");
					player freezeControls(false);
					player.dontkill = undefined;
					player.badplayer = undefined;
					player.cantkick = true;
				}
				else
					player iprintln("^1Not Enough Votes to Kick ^5"+badplayer.name+"!");
			}
		}
		wait 0.05;
		self.startedvote = undefined;
		level.votestokick = undefined;
		level.voting = undefined;
		wait 0.05;
		level notify("voting_ended");
	}
}

monitorvote(badplayer)
{
	self endon("disconnect");
	level endon("voting_ended");
	level endon("game_ended");
	foreach(player in level.players)
	{
		if(player.name == badplayer.name)
		{
			player iprintln("^1The lobby is Vote Kicking You!");
			player iprintln("^1Please wait to see what the outcome is...");
			player freezeControls(true);
			player.dontkill = true;
			player.badplayer = true;
		}
		else if(player.name != badplayer.name && player.name != self.name)
		{
			player iprintln("^5Voting to Kick ^1"+badplayer.name+" ^5has started!");
			player thread checkvote(badplayer);
			player thread printvote(badplayer);
		}
		wait 0.05;
	}
}

printvote(badplayer)
{
	self endon("disconnect");
	level endon("voting_ended");
	level endon("game_ended");
	
	for(;;)
	{
		if(!isDefined(self.voted))
		{
			self iprintln("^5PRONE[{+actionslot 1}]: ^1VOTE TO KICK ^5"+badplayer.name+"!");
			self iprintln("^5PRONE[{+actionslot 2}]: ^2VOTE NOT TO KICK ^5"+badplayer.name+"!");
		}
		wait 2.5;
	}
}

checkvote(badplayer)
{
	self endon("disconnect");
	level endon("voting_ended");
	level endon("game_ended");
	
	for(;;)
	{
		if(self getStance() == "prone" && self actionslotonebuttonpressed() && !isDefined(self.menu.open) && !isDefined(self.voted))
		{
			self.voted = true;
			level.votestokick += 1;
			self iprintln("^1You voted for ^5"+badplayer.name+" to get kicked!");
			foreach(player in level.players)
				player iprintln("^1( "+level.votestokick+" / "+level.votesneeded+" ) ^5votes to kick!");
		}
		if(self getStance() == "prone" && self actionslottwobuttonpressed() && !isDefined(self.menu.open) && !isDefined(self.voted))
		{
			self.voted = true;
			self iprintln("^2You voted for ^5"+badplayer.name+" to stay!");
		}
		wait 0.05;
	}
}

knifelungetoggle()
{
	if (!isDefined(self.knifelunge))
	{
		self.knifelunge = true;
		self iprintlnbold("^5Knife Lunge: ^2ON");
	}
	else
	{
		self.knifelunge = undefined;
		self iprintlnbold("^5Knife Lunge: ^1OFF");
	}
}

doLunge()
{
	if (isDefined(self.knifelunge) && !isDefined(self.cooldown) && !self adsButtonPressed())
	{
		self.cooldown = true;
		self.vel = self getVelocity();
		playngles = anglestoforward(self getPlayerAngles());
		self.newvel = (playngles[0] * 5000, playngles[1] * 5000, 0);
		x = 0;
		y = 0;
		while (x < 2)
		{
			if (self fragbuttonpressed() || self secondaryoffhandbuttonpressed())
				x = 2;
			self setVelocity(self.newvel);
			x++;
			wait .01;
		}
		self.newvel = (0, 0, 0);
		self setVelocity(self.newVel);
		wait 3;
		self.cooldown = undefined;
	}
}

carePackageStall()
{
	self thread cpstall(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"] + (0,0,15), self getPlayerAngles());
}

cpstall( cpPos, cpAng )
{
	if(!isDefined(self.dostall))
	{
		self.dostall = spawn("script_model", cpPos);
		self.dostall setmodel("t6_wpn_supply_drop_trap");
		self.dostall.angles = (0, cpAng[1], 0);
		self iprintlnbold("^5Carepackage Stall Spawned!");
	}
	else
	{
		self.dostall RotateTo((0, cpAng[1], 0), 0.001, 0, 0 );
        self.dostall MoveTo(cpPos, 0.001, 0, 0 );
        self notify(self.name+"changecpstall");
        self iprintlnbold("^5Carepackage Stall Moved!");
	}
	self thread carePackageStallThink(cpPos);
}

showCarePackageInfo()
{
	currentSize = self.name;
	self.infoStall[currentSize] = self createFontString("default", 1.25);
	self.infoStall[currentSize] setPoint( "CENTER", "CENTER", 0, 70 );
	self.infoStall[currentSize] setText("Press [{+usereload}] for Care Package");
}

carePackageStallThink(Stall)
{
	self endon("disconnect");
	level endon( "game_ended" );
	self endon(self.name+"changecpstall");

	currentSize = self.name;
	self.onlyLinkOnce = true;

	for(;;)
	{
		self.infoStall[currentSize] destroy();
		if(!(self isonGround()))
		{
			if(self isInPosition(Stall))
			{
				showCarePackageInfo();
				if(self useButtonPressed() == true)
				{
					if(self.onlyLinkOnce == true)
					{
						self.stall = spawn("script_model", self.origin);
						self playerLinkTo(self.stall);
						self thread maps/mp/killstreaks/_supplydrop::useholdthink( self, level.cratenonownerusetime );
						self freeze_player_controls( 0 );
						self.onlyLinkOnce = false;
					}
				}
				else if(!self useButtonPressed())
				{		
					self.onlyLinkOnce = true;
					self.stall delete();
				}
			}
			else
				self.InfoStall[currentSize] destroy();
		}
	wait 0.05;
	}
}

isInPosition( cP ) 
{
	if(distance( self.origin, cP ) < 130)
		return true;
	return false;
}

floaters()
{
    self endon("disconnect");
    self endon("floaters_over");
    level waittill("game_ended");

	level.botCount = undefined;
	level.botsChecked = undefined;

    foreach(player in level.players)
    {
        if(isAlive(player) && !player isOnGround())
        {
            player thread executeFloater();
            player thread endFloater();
        }
    }

}
executeFloater()
{
    z = 0;
    startingOrigin = self getOrigin();
    floaterPlatform = spawn("script_model", startingOrigin - (0, 0, 20));
    playerAngles = self getPlayerAngles();
    floaterPlatform.angles=(0, playerAngles[1] , 0);
    floaterPlatform setModel("collision_clip_32x32x10");
    for(;;)
    {
        z++;
        floaterPlatform.origin=(startingOrigin - (0, 0, z*1 ));
        wait .01;
    }
}

endFloater()
{
	self endon("disconnect");
    self endon("floaters_over");
    
    for(;;)
    {
		wait 10;
		self notify("floaters_over");
	}
}
	

almosthitplayer()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	for(;;)
	{
		if(self.pointstowin == level.scorelimit - 1)
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
			meterdist = int(distance(self.origin, aimAt.origin) / 39.97);
			if(distance( aimAt.origin, ExpLocation ) > 1 && distance( aimAt.origin, ExpLocation ) < 90  && !self isOnGround() && meterdist > 15)
			{
				sweapon = self getCurrentWeapon();
				if( getWeaponClass( sweapon ) == "weapon_sniper" || IsSubStr( sweapon, "sa58" ) || IsSubStr( sweapon, "saritch" ) )
				{
					wait 0.10;
					if( !isDefined(level.meters) )
						self iprintlnbold("^1You nearly hit ^7"+ aimAt.name +" ^1from ( ^7" + meterdist + "^1 ) m away!");
					if( !isDefined(self.jewcount) )
						self.jewcount = 1;
					else
						self.jewcount += 1;
				}
			}
		}
		wait 0.05;
	}
}

trackstats()
{
	self endon( "disconnect" );
	self endon( "statsdisplayed" );
	level waittill("game_ended");

	for(;;)
	{
		wait .12;
		if(!isDefined(self.biller))	
		{
			if(isDefined(self.jewcount))
			{
				wait .5;
				if(self.jewcount == 1)
					self iprintln("You almost hit ^1"+self.jewcount+" ^7time this game!");
				else
					self iprintln("You almost hit ^1"+self.jewcount+" ^7times this game!");
				self notify( "statsdisplayed" );
			}
		}
		wait 0.05;
		self notify( "statsdisplayed" );
	}
}

weaponboxSpawn()
{
	self thread weaponbox(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"] + (0,0,15), self getPlayerAngles());
}

weaponbox( wbPos, wbAng )
{
	if(!isDefined(self.mysterybox))
	{
		self.mysterybox = spawn("script_model", wbPos);
		self.mysterybox setmodel("t6_wpn_supply_drop_ally");
		self.mysterybox.angles = (0, wbAng[1], 0);
		self iprintlnbold("^5Mystery Box Spawned!");
	}
	else
	{
		self.mysterybox RotateTo((0, wbAng[1], 0), 0.001, 0, 0 );
        self.mysterybox MoveTo(wbPos, 0.001, 0, 0 );
        level notify(self.name+"changemysterybox");
        self iprintlnbold("^5Mystery Box Moved!");
	}
	self thread weaponboxThink(wbPos);
}

showweaponboxInfo()
{
	currentSize = self.name;
	self.infoBox[currentSize] = self createFontString("default", 1.25);
	self.infoBox[currentSize] setPoint( "CENTER", "CENTER", 0, 70 );
	self.infoBox[currentSize] setText("Press [{+usereload}] for a Random Weapon");
}

weaponboxThink(mysterybox)
{
	self endon("disconnect");
	level endon( "game_ended" );
	level endon(self.name+"changemysterybox");

	for(;;)
	{
		foreach(player in level.players)
		{
			currentSize = player.name;
			player.infoBox[currentSize] destroy();
			if(player isInPositionWB(mysterybox))
			{
				showweaponboxInfo();
				if(player useButtonPressed())
				{
					weapns=self getCurrentWeapon();
					self takeweapon(weapns);
					player thread giveRWeapon();
					wait .2;
				}
			}
			else
				player.infoBox[currentSize] destroy();
		}
	wait 0.05;
	}
}

isInPositionWB( wb ) 
{
	if(distance( self.origin, wb ) < 85)
		return true;
	return false;
}

giveRWeapon()
{
	randy = RandomIntRange(1,45);
	self.Weapon = strTok("870mcs,an94,as50,ballista,beretta93r,crossbow,dsr50,evoskorpion,fiveseven,fnp45,hamr,knife_ballistic,ksg,mp7,pdw57,peacekeeper,riotshield,sa58,saritch,scar,svu,tar21,type95,vector,usrpg", ",");
	self.RandWeapon = RandomInt(self.Weapon.size);
	attachmentlist=self.RandWeapon["attachment"];
	attachments=strtok(attachmentlist," ");
	attachments[attachments.size]="";
	attachment=random(attachments);
	self GiveWeapon((self.RandWeapon[self.Weapon]+"_mp+")+attachment,0,true(randy,0,0,0,0));
	self switchToWeapon((self.RandWeapon[self.Weapon]+"_mp+")+attachment,0,true(randy,0,0,0,0));
}

