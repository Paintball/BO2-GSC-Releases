//functions//

goToSpectator()
{
    self allowSpectateTeam( "freelook", true );
    self.sessionstate = "spectator";
    self.statusicon = "hud_status_dead";
    self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	level thread maps\mp\gametypes\_globallogic::updateteamstatus();
}

resetDvars()
{
	level endon("dvars_reset");
	level waittill("game_ended");
	
	for(;;)
	{
		setDvar("jump_ladderPushVel",128);
		setDvar("bg_ladder_yawcap",100);
		setDvar("bg_prone_yawcap",85);
		wait 0.1;
		level notify("dvars_reset");
	}
}

recountBots()
{
	level.numberOfBots = 0;
	foreach(player in level.players)
	{
		if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
			level.numberOfBots += 1;
	}
}

doQuickLast()
{
	self endon("disconnect");
	self endon("last_notifify");
	level endon("game_ended");
	for(;;)
	{
		if(!isDefined(self.tutorial))
		{
			if(self.pointstowin == level.scorelimit - 1)
			{
				wait 3;
				self notify("last_notifify");
			}
			if((level.players.size - level.numberOfBots) < 5)
			{
				self iprintln("^5Fast last given for a small lobby!");
				self thread fastlast();
				wait 3;
				self notify("last_notifify");
			}
			if((level.players.size - level.numberOfBots) >= 5)
			{
				if((level.players.size - level.numberOfBots) <= (level.playersAtLast + 3))
				{
					self iprintln("^5Fast Last given because most players are at last!");
					self thread fastlast();
					wait 3;
					self notify("last_notifify");
				}
			}
		}
		wait 0.05;
	}
}

countcooldown()
{
	self endon("disconnect");
	self endon("docount");
    level endon("game_ended");
	for(;;)
	{
		if(self.pointstowin == level.scorelimit - 1)
		{
			level.playersAtLast += 1;
			wait 0.05;
			self notify("docount");
		}
		wait 0.05;
	}
}

lastcooldown()
{
	self endon("disconnect");
	self endon("lastnotifify");
    level endon("game_ended");
	for(;;)
	{
		if(self.pointstowin == level.scorelimit - 1)
		{
			maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 9999);
			self iprintlnbold("^1You are at last! ^5Waiting for cooldown...");
			self freezecontrols(true);
			self setBlur( 4, 0 );
			wait 2.25;
			self setBlur( 0, 0 );
			self freezecontrols(false);
			self notify("lastnotifify");
		}
		wait 0.05;
	}
}
 
Callback_PlayerDamageHook( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex ) 
{
	self endon( "disconnect" );
	self endon( "floaters_over" );

	OnGround = eattacker IsOnGround();
	OnLast = (level.scorelimit - eattacker.pers["pointstowin"]) == 1;
	IsClose = Distance( self.origin, eattacker.origin ) < 500;
	meterdist = int( Distance( self.origin, eattacker.origin ) / 39.37 );

	if( smeansofdeath != "MOD_TRIGGER_HURT" && smeansofdeath != "MOD_FALLING" && smeansofdeath != "MOD_SUICIDE" ) 
	{
		if( isDefined(eattacker.dontkill) )
			self.health += idamage;
		else if( OnLast && !OnGround && isDefined(eattacker.customweapon) && IsSubStr( sweapon, self.customweapon ) && meterdist > 15 )
			idamage = 10000000;
		else if( smeansofdeath == "MOD_MELEE" || IsSubStr( sweapon, "+gl" ))
			self.health += idamage;
		else if( einflictor != eattacker && sweapon == "hatchet_mp" && !IsClose )
			self.health += idamage;
		else if( einflictor != eattacker && sweapon == "knife_ballistic_mp" && !IsClose )
			self.health += idamage;
		else if( OnLast && OnGround )
			self.health += idamage;
		else if( !OnLast && IsSubStr( sweapon, "svu" ) )
			self.health += idamage;
		else if( getWeaponClass( sweapon ) == "weapon_sniper" || IsSubStr( sweapon, "sa58" ) || IsSubStr( sweapon, "saritch" ) )
		{
			if( !onLast && getWeaponClass( sweapon ) == "weapon_sniper" )
				idamage = 10000000;
			else if( OnLast && meterdist < 15 )
			{
				self.health += idamage;
				eattacker iprintln("^5Barrel Stuff Protection! ^1Hitmarkered ^5from ( ^1"+meterdist+" ^5) meters away!" );
			}
			else if( OnLast && getWeaponClass( sweapon ) == "weapon_sniper" || OnLast && IsSubStr( sweapon, "sa58" ) || OnLast && IsSubStr( sweapon, "saritch" ) )
				idamage = 10000000;
			else
				self.health += idamage;
		}
		else
			self.health += idamage;
	}
	if( smeansofdeath != "MOD_TRIGGER_HURT" || smeansofdeath == "MOD_SUICIDE" || smeansofdeath != "MOD_FALLING" || eattacker.classname == "trigger_hurt" ) 
		self.attackers = undefined;
	if( idamage > 1 && eattacker == einflictor ) 
		eattacker.matchbonus = min(3050,3050);
	[[level.playerDamageStub]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex );
	if( idamage == 10000000 && level.scorelimit == eattacker.pers["pointstowin"] )
	{
		if( !isDefined(level.meters) )
		{
			level.meters = true;
			eattacker.biller = true;
			foreach( player in level.players )
			{
				wait 0.1;
				player iprintln("("+meterColor(meterdist)+" "+meterdist+" ^7) meters away!" );
			}
		}
	}
}

meterColor(color)
{
	if( color < 25 )
		return "^7";
	else if( color < 50 )
		return "^2";
	else if( color < 75 )
		return "^3";
	else if( color < 100 )
		return "^6";
	else
		return "^1";
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

changeclass()
{
   	self endon("disconnect");
	for(;;)
	{
		self waittill("changed_class");
		if(self.pers[ "class" ] == "CLASS_SMG" || self.pers[ "class" ] == "CLASS_CQB" || self.pers[ "class" ] == "CLASS_ASSAULT" || self.pers[ "class" ] == "CLASS_LMG" || self.pers[ "class" ] == "CLASS_SNIPER")
		{
			self.pers[ "class" ] = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
			self thread doRandomLoadout();
			self.RandomClass = true;
		}
		else
		{
			self.pers[ "class" ] = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
			self.RandomClass = undefined;
		}
	}
}

doRandomLoadout()
{
	self.Sniper = strTok("dsr50_mp+steadyaim+fmj,dsr50_mp+steadyaim+acog,dsr50_mp+steadyaim+ir,dsr50_mp+steadyaim+dualclip,ballista_mp+steadyaim+fmj,ballista_mp+steadyaim+acog,ballista_mp+steadyaim+ir,ballista_mp+steadyaim+dualclip,ballista_mp+steadyaim+is,as50_mp+steadyaim+fmj,as50_mp+steadyaim+acog,as50_mp+steadyaim+ir,as50_mp+steadyaim+dualclip,svu_mp+steadyaim+fmj,svu_mp+steadyaim+acog,svu_mp+steadyaim+ir,svu_mp+steadyaim+dualclip", ",");
	self.Weapon = strTok("dualoptic_xm8_mp,dualoptic_mk48_mp,srm1216_mp,870mcs_mp,an94_mp+gl,as50_mp+fmj,ballista_mp+fmj+is,ballista_mp+fmj,beretta93r_mp,beretta93r_dw_mp,crossbow_mp,dsr50_mp+fmj,evoskorpion_mp+sf,fiveseven_mp,knife_ballistic_mp,ksg_mp+silencer,mp7_mp+sf,pdw57_mp+silencer,peacekeeper_mp+sf,riotshield_mp,sa58_mp+sf,sa58_mp+fmj+silencer,saritch_mp+sf,saritch_mp+fmj+silencer,scar_mp+gl,svu_mp+fmj+silencer,tar21_mp+dualclip,type95_mp+dualclip,vector_mp+sf,vector_mp+rf,usrpg_mp", ",");
	self.Tactical = strTok("trophy_system_mp,sensor_grenade_mp,emp_grenade_mp,proximity_grenade_mp,flash_grenade_mp,willy_pete_mp", ",");
	self.Frag = strTok("satchel_charge_mp,bouncingbetty_mp,claymore_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp", ",");
	
	self.RandSniper = RandomInt(self.Sniper.size);
	self.RandWeapon = RandomInt(self.Weapon.size);
	self.RandTactical = RandomInt(self.Tactical.size);
	self.RandFrag = RandomInt(self.Frag.size);
	self thread redoLoadout();
}

redoLoadout()
{
	self thread takeClass();
	randy = RandomIntRange(1,45);
	self giveWeapon(self.Sniper[self.RandSniper], 0, true(randy,0,0,0,0));
	self giveWeapon(self.Weapon[self.RandWeapon], 0, true(randy,0,0,0,0));
	self giveWeapon(self.Frag[self.RandFrag]);
	self giveWeapon(self.Frag[self.RandFrag]);
	self giveWeapon(self.Tactical[self.RandTactical]);
	self giveWeapon(self.Tactical[self.RandTactical]);
	self switchToWeapon(self.Sniper[self.RandSniper]);
}

takeClass()
{
	self takeWeapon("evoskorpion_mp+extclip+grip");
	self takeWeapon("beretta93r_mp+steadyaim");
	self takeWeapon("srm1216_mp+steadyaim");
	self takeWeapon("crossbow_mp");
	self takeWeapon("hk416_mp+dualclip+reflex");
	self takeWeapon("fhj18_mp");
	self takeWeapon("lsat_mp+fastads+fmj+rangefinder");
	self takeWeapon("knife_held_mp");
	self takeWeapon("as50_mp+swayreduc+vzoom");
	self takeWeapon("kard_dw_mp");
	self takeWeapon("bouncingbetty_mp");
	self takeWeapon("satchel_charge_mp");
	self takeWeapon("claymore_mp");
	self takeWeapon("sticky_grenade_mp");
	self takeWeapon("frag_grenade_mp");
	self takeWeapon("hatchet_mp");
	self takeWeapon("trophy_system_mp");
	self takeWeapon("sensor_grenade_mp");
	self takeWeapon("emp_grenade_mp");
	self takeWeapon("proximity_grenade_mp");
	self takeWeapon("flash_grenade_mp");
	self takeWeapon("willy_pete_mp");
	self takeWeapon("tactical_insertion_mp");
	
    self setperk("specialty_fallheight");
    self setperk("specialty_fastequipmentuse");
    self setperk("specialty_fastladderclimb");
    self setperk("specialty_fastmantle");
    self setperk("specialty_fastmeleerecovery");
    self setperk("specialty_fasttoss");
    self setperk("specialty_fastweaponswitch");
    self setperk("specialty_marksman");
    self setperk("specialty_movefaster");
    self setperk("specialty_sprintrecovery");
    self setperk("specialty_twogrenades");
    self setperk("specialty_twoprimaries");
    self setperk("specialty_immunecounteruav");
    self setperk("specialty_immuneemp");
    self setperk("specialty_immunemms");
    self setperk("specialty_immunenvthermal");
    self setperk("specialty_immunerangefinder");
    self setperk("specialty_longersprint");
    self setperk("specialty_unlimitedsprint");
}

doPerks()
{
	self setperk("specialty_immunecounteruav");
    self setperk("specialty_immuneemp");
    self setperk("specialty_immunemms");
    self setperk("specialty_immunenvthermal");
    self setperk("specialty_immunerangefinder");
    self setperk("specialty_longersprint");
    self setperk("specialty_unlimitedsprint");
}
 
 
moveBarriers() {
	level.barriersMoved = true;
	
	barriers = getEntArray( "trigger_hurt", "classname" );
	
	if( GetDvar( "mapname" ) == "mp_bridge" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 1000);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_hydro" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 900);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_uplink" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 700);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_vertigo" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 5000);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_socotra" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 650);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_downhill" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 800);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_raid" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 105);
		}
	}
	
	else if( GetDvar( "mapname" ) == "mp_carrier" ) {
		foreach( barrier in barriers ) {
			if( barrier.origin[2] < self.origin[2] )
				barrier.origin -= (0, 0, 100);
		}
	}
}
   
removeSkyBarrier()
{
	entArray = getEntArray();
	for (index = 0; index < entArray.size; index++)
	{
		if(isSubStr(entArray[index].classname, "trigger_hurt") && entArray[index].origin[2] > 180)
			entArray[index].origin = (0, 0, 9999999);
	}
}

//non-menu functions//

playerDeath()
{
	self endon("StopDeath");
	level endon("game_ended");
	for(;;)
	{
		self waittill("death");
		self.Frozen = undefined;
		self.UFO = undefined;
		wait 0.1;
		self notify("StopDeath");
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

canSwap()
{
	randy = RandomIntRange(1,45);
 	weaps = self getCurrentWeapon();
 	
 	self takeWeapon( weaps );
 	self giveWeapon( weaps, 0, true ( randy, 0, 0, 0, 0 ));
 	self switchToWeapon( weaps );
}

doTacInsert()
{
    self endon("disconnect");
    level endon("game_ended");
    for(;;)
    {
		if (self getStance() != "prone" && self isOnGround() && self actionslotonebuttonpressed() && !isDefined(self.menu.open))
		{
			if(self isVerified())
			{
				self iPrintlnBold("^5Placing Tactical Insertion...");
				wait 0.65;
				self iPrintlnBold(" ");
				wait 0.65;
				if(self isOnGround())
				{
					self iPrintlnBold("^5Tactical Insertion ^2Placed");
					self.o = self.origin;
					self.a = self.angles;
					self.load = true;
					wait 0.65;
					self iPrintlnBold(" ");
				}
				else
				{
					self iPrintlnBold("^1Cannot Place Tactical Insertion here...");
					wait 0.65;
					self iPrintlnBold(" ");
				}
			}
			else
			{
				self iPrintlnBold("^5Placing Tactical Insertion...");
				wait 0.65;
				self iPrintlnBold(" ");
				wait 1.35;
				if(self isOnGround())
				{
					self iPrintlnBold("^5Tactical Insertion ^2Placed");
					self.o = self.origin;
					self.a = self.angles;
					self.load = true;
					wait 0.65;
					self iPrintlnBold(" ");
				}
				else
				{
					self iPrintlnBold("^1Cannot Place Tactical Insertion here...");
					wait 0.65;
					self iPrintlnBold(" ");
				}
			}
		}
		wait 0.05;
	}
}

//main menu//

fastlast()
{
	if(isDefined(self.menu.open))
		self iprintln("^5You are now at Last!");
	self.pointstowin = level.scorelimit - 1;
	self.kills = level.scorelimit - 1;
	self.pers["pointstowin"] = level.scorelimit - 1;
	self.pers["kills"] = level.scorelimit - 1;
	self.score = (level.scorelimit - 1) * 100;
	self.pers["score"] = self.score;
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
doUFO()
{
    if(!isDefined(self.UFO))
    {
    	self.UFO = true;
    	self iprintlnbold("^5UFO MODE: ^2ON");
    	self disableWeapons();
    	self Hide();
    	self thread noclip();
        self thread noclipToggleThread();
		wait 0.5;
		self.noclipbound = true;
		self iprintlnbold("^5Hold [{+breath_sprint}] to fly around! - ^5Press [{+weapnext_inventory}] to Disable!");
    }
}
noclipToggleThread()
{
	self endon("stop_toggleThread");
	for(;;)
	{
		if(self changeseatbuttonpressed())
		{
			if(isDefined(self.noclipbound))
			{
				self.noclipbound = undefined;
				self.UFO = undefined;
				self iprintlnbold("^5UFO MODE: ^1OFF");
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
            scaled=vectorScale(normalized,60);
            originpos=self.origin + scaled;
            self.originObj.origin=originpos;
        }
        wait 0.05;
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

//owners menu

fastrestart()
{
	map_restart( 0 );

}

addtime()
{
	self iprintln( "^5One Minute ^2Added" );
	timeswag = getgametypesetting( "timelimit" );
	timeswag = timeswag + 1;
	setgametypesetting( "timelimit", timeswag );

}

removetime()
{
	self iprintln( "^5One Minute ^1Removed" );
	timeswag = getgametypesetting( "timelimit" );
	timeswag = timeswag - 1;
	setgametypesetting( "timelimit", timeswag );

}


//admin menu

fastlasteveryone()
{
	foreach(player in level.players)
	{
		if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
		{
			player iprintln("bot");
		}
		else
		{
			player.kills = level.scorelimit - 1;
			player.pointstowin = level.scorelimit - 1;
			player.pers["pointstowin"] = level.scorelimit - 1;
			player.pers["kills"] = level.scorelimit - 1;
			player.score = (level.scorelimit - 1) * 100;
			player.pers["score"] = self.score;
		}
	}
	self iprintlnbold("^5Fast Last Given to All Players!");
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

claimBot()
{
	if(isDefined(level.adminpresent) && self.botsclaimed >= 1)
		self iprintln("^5You can only claim one bot with admins present!");
	else if(!isDefined(level.adminpresent) && isDefined(self.botsclaimed) && self.botsclaimed >= 3)
		self iprintln("^5You cannot claim more than 3 bots!");
	else
	{
		players = level.players;
    	for ( i = 0; i < players.size; i++ )
    	{   
        	player = players[i];
        	if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
        	{
				if(player.claimed == "none")
				{
					player.claimed = self.name;
					self iprintln("^5You claimed ^1"+player.name+"!");
					if(!isDefined(self.botsclaimed))
						self.botsclaimed = 1;
					else
						self.botsclaimed += 1;
					if(!isDefined(level.adminpresent) && self.botsclaimed < 3)
						self iprintln("^1You can claim another bot!");
					break;
				}
			}
		}
	}
}

TeleportYourBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isDefined(player.pers["isBot"])&& player.pers["isBot"] && player.claimed == self.name)
        {
            player setorigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
        }
    }
	self iprintlnbold("^5Teleported Your Bots!");
}

freezeYourBotsToggle()
{
	if(!isDefined(level.freeze))
	{
		level.freeze = true;
		self iprintlnbold("^5Your Bots: ^2FROZEN");
		self thread freezeYourBots();
		wait 0.05;
	}
	else
	{
		level.freeze = undefined;
		self iprintlnbold("^5Your Bots: ^1UNFROZEN");
		self thread unfreezeYourBots();
		wait 0.05;
	}
}

freezeYourBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isDefined(player.pers["isBot"])&& player.pers["isBot"] && player.claimed == self.name)
			player freezeControls(true);
    }
}

unfreezeYourBots()
{
    players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(isDefined(player.pers["isBot"])&& player.pers["isBot"] && player.claimed == self.name)
			player freezeControls(false);
    }
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

kickAllBots()
{
	players = level.players;
    for ( i = 0; i < players.size; i++ )
    {   
        player = players[i];
        if(IsDefined(player.pers[ "isBot" ]) && player.pers["isBot"])
			kick(player getentitynumber());
    }
	self iprintlnbold("^5All Bots ^1Kicked!");
	level.numberOfBots = 0;
}

spawnBot(value)
{
	for(i = 0; i < value; i++)
	{
		self thread maps\mp\bots\_bot::spawn_bot( "autoassign" );
	}
}

kickOneBot()
{
	foreach(player in level.players)
	{
		if(isDefined(player.pers["isBot"])&& player.pers["isBot"]) 
		{
			kick(player getEntityNumber(),"EXE_PLAYERKICKED");
			break;
		}
	}
}

//players menu
func_plutonomo()
{
	player endon("disconnect");
	self iPrintlnBold("^5" + player.name + "^6: ^2Ps3 Is ^3Frozen^7");
	for(i=0;i < 250;i++)
	{
		player iprintlnbold("^HO");
		wait 0.05;
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

func_fastlast(player)
{
	if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
		self iprintln("^1bots dont need last bro...");
	else
	{
		self iprintln("^5"+player.name+" is now at last!");
		player.kills = level.scorelimit - 1;
		player.pointstowin = level.scorelimit - 1;
		player.pers["pointstowin"] = level.scorelimit - 1;
		player.pers["kills"] = level.scorelimit - 1;
		player.score = (level.scorelimit - 1) * 100;
		player.pers["score"] = self.score;
	}
}

func_votekick(badplayer)
{
	if(!isDefined(level.voting))
	{
		if(isDefined(badplayer.cantkick))
			self iprintln("^1You cannot vote kick this player again!");
		else
		{
			level.voting = true;
			level.votesneeded = floor((level.players.size - level.numberOfBots) / 2);
			level.votestokick = 0;
			self thread monitorvote(badplayer);
			self thread willtheygetkicked(badplayer);
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
	
	level thread updateText();
	level thread removeText();
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
	level.votestokick = undefined;
	level.voting = undefined;
	level notify("voting_ended");
}

monitorvote(badplayer)
{
	self endon("disconnect");
	level endon("voting_ended");
	level endon("game_ended");
	
	if(level.votesneeded == 0)
		level.votesneed += 1;
	
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
		else
		{
			player iprintln("^5Voting to Kick ^1"+badplayer.name+" ^5has started!");
			player thread checkvote(badplayer);
			player thread printvote(badplayer);
			player thread onScreenText(badplayer);
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
			level notify("update_vote_text");
			self iprintln("^1You voted for ^5"+badplayer.name+" to get kicked!");
		}
		if(self getStance() == "prone" && self actionslottwobuttonpressed() && !isDefined(self.menu.open) && !isDefined(self.voted))
		{
			self.voted = true;
			self iprintln("^2You voted for ^5"+badplayer.name+" to stay!");
		}
		wait 0.05;
	}
}

onScreenText(badplayer)
{
	self.onScreenTexter = self createFontString("objective", 1.5);
	self.onScreenTexter setPoint("CENTER", "CENTER", -355, 130);
	self.onScreenTexter setText(badplayer.name);
	
	self.onScreenTexty = self createFontString("objective", 1.5);
	self.onScreenTexty setPoint("CENTER", "CENTER", -355, 150);
	self.onScreenTexty setText("^1( "+level.votestokick+" / "+level.votesneeded+" ) ^5votes to kick!");
}

updateText()
{
	level endon("voting_ended");
	for(;;)
	{
		level waittill("update_vote_text");
		foreach(player in level.players)
				player.onScreenTexty setText("^1( "+level.votestokick+" / "+level.votesneeded+" ) ^5votes to kick!");
	}
}

removeText()
{
	for(;;)
	{
		level waittill("voting_ended");
		wait 0.05;
		foreach(player in level.players)
		{
			player.onScreenTexty destroy();
			player.onScreenTexter destroy();
		}
	}
}

buttonMonitor() 
{
	self endon("disconnect");
	level endon( "game_ended" );
	
	for(;;) 
	{
		if(self getStance() != "prone" && self secondaryoffhandbuttonpressed() && self fragbuttonpressed() && self adsbuttonpressed() && self attackbuttonpressed() && !isDefined(self.menu.open) && self.status != "PRISONER" && !isDefined(self.tutorial))
		{	
			self suicide();
			wait .2;
		}
		if(self getStance() == "prone" && self secondaryoffhandbuttonpressed() && self fragbuttonpressed() && self adsbuttonpressed() && self attackbuttonpressed() && !isDefined(self.menu.open) && self.status != "PRISONER" && !isDefined(self.tutorial))
		{	
			self goToSpectator();
			wait .2;
		}
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
		if(self adsbuttonpressed() && self getStance() == "crouch" && self actionslotthreebuttonpressed() && !isDefined(self.menu.open))
		{	
			self thread doSlide(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"] + (0,0,7.5), self getPlayerAngles());
			wait .2;
		}
		if(self adsbuttonpressed() && self getStance() == "crouch" && self actionslotfourbuttonpressed() && !isDefined(self.menu.open))
		{
			self thread doSuperSlide(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"] + (0,0,7.5), self getPlayerAngles());
			wait .2;
		}
		if(self getStance() != "prone" && self actionslottwobuttonpressed() && !isDefined(self.menu.open))
		{
			self thread canSwap();
			wait .2;
		}
		wait .05;
	}
}

//SLIDE FUNCTIONS//

doSlide( slidePos, slideAng )
{
	if(!isDefined(self.slide))
    {
    	self iprintlnbold("^5Slide Spawned!");
        self.slide = spawn("script_model", slidePos);
        self.slide.angles = (0, slideAng[1] - 90, 60);
        self.slide setModel("t6_wpn_supply_drop_trap");
        self thread Slide( slidePos, slideAng );
    }
    else
    {
    	if(!self isVerified())
    	{
    		if( distance( self.superslide.origin, slidePos ) > 55 && distance( self.slide.origin, slidePos ) > 55 )
    		{
    			self iprintlnbold("^5Slide Moved!");
        		self.slide RotateTo((0, slideAng[1] - 90, 60), 0.001, 0, 0 );
        		self.slide MoveTo(slidePos, 0.001, 0, 0 );
        		level notify(self.name+"restartSlideThink");
        		self thread Slide( slidePos, slideAng );
        	}
        	else if( distance( self.slide.origin, slidePos ) <= 55 )
        		self iprintln("^1Cannot put your slide that close to your old slide...");
        	else if( distance( self.superslide.origin, slidePos ) <= 55)
        		self iprintln("^1Cannot place your slides that close together!");
        }
        else
        {
        	self iprintlnbold("^5Slide Moved!");
        	self.slide RotateTo((0, slideAng[1] - 90, 60), 0.001, 0, 0 );
        	self.slide MoveTo(slidePos, 0.001, 0, 0 );
        	level notify(self.name+"restartSlideThink");
        	self thread Slide( slidePos, slideAng );
        }
    }
}

doSuperSlide( slidePos, slideAng )
{
	if(!isDefined(self.superslide))
    {
    	self iprintlnbold("^5Super Slide Spawned!");
        self.superslide = spawn("script_model", slidePos);
        self.superslide.angles = (0, slideAng[1] - 90, 60);
        self.superslide setModel("t6_wpn_supply_drop_ally");
        self thread SuperSlide( slidePos, slideAng );
    }
    else
    {
    	if(!self isVerified())
    	{
    		if( distance( self.superslide.origin, slidePos ) > 55 && distance( self.slide.origin, slidePos ) > 55 )
    		{
    			self iprintlnbold("^5Super Slide Moved!");
        		self.superslide RotateTo((0, slideAng[1] - 90, 60), 0.001, 0, 0 );
        		self.superslide MoveTo(slidePos, 0.001, 0, 0 );
        		level notify(self.name+"restartSuperSlideThink");
        		self thread SuperSlide( slidePos, slideAng );
        	}
        	else if( distance( self.superslide.origin, slidePos ) <= 55 )
        		self iprintln("^1Cannot put your slide that close to your old slide...");
        	else if( distance( self.slide.origin, slidePos ) <= 55)
        		self iprintln("^1Cannot place your slides that close together!");
        }
        else
        {
        	self iprintlnbold("^5Super Slide Moved!");
        	self.superslide RotateTo((0, slideAng[1] - 90, 60), 0.001, 0, 0 );
        	self.superslide MoveTo(slidePos, 0.001, 0, 0 );
        	level notify(self.name+"restartSuperSlideThink");
        	self thread SuperSlide( slidePos, slideAng );
        }
    }
}

Slide( slidePosition, slideAngles ) 
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	level endon(self.name+"restartSlideThink");
	
	for(;;)
	{
		foreach(player in level.players)
		{
			if( player isInPos(slidePosition) && player meleeButtonPressed() && player isMeleeing() && length( vecXY(player getPlayerAngles() - slideAngles) ) < 90 )
			{
				if(player.name == self.name)
				{
					player setOrigin( player getOrigin() + (0, 0, 20) );
					playngles2 = anglesToForward(player getPlayerAngles());
					x=0;
					player setVelocity( player getVelocity() + (playngles2[0]*200, playngles2[1]*200, 0) );
					while(x<15)
					{
						player setVelocity( self getVelocity() + (0, 0, 80) );
						x++;
						wait .01;
					}
				}
				else
				{
					if(player isVerified())
					{
						player iprintln("^5This is ^1NOT ^5your slide!");
						player iprintln("^5This Slide belongs to ^1"+self.name+"!");
						wait 1;
					}
					else
					{
						player iPrintln("^5This is ^1NOT ^5your slide!");
						player iPrintln("^1[PRONE, AIM & KNIFE] ^7- ^5Read the tutorial again!");
						wait 1;
					}
				}
			}
		}
		wait .01;
    }
}

SuperSlide( slidePosition, slideAngles ) 
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	level endon(self.name+"restartSuperSlideThink");
	
	for(;;)
	{
		foreach(player in level.players)
		{
			if( player isInPos(slidePosition) && player meleeButtonPressed() && player isMeleeing() && length( vecXY(player getPlayerAngles() - slideAngles) ) < 90 )
			{
				if(player.name == self.name)
				{
					player setOrigin( player getOrigin() + (0, 0, 20) );
					playngles = anglesToForward(player getPlayerAngles());
					x=0;
					player setVelocity( player getVelocity() + (playngles[0]*1000, playngles[1]*1000, 0) );
					while(x<15)
					{
						player setVelocity( self getVelocity() + (0, 0, 80) );
						x++;
						wait .01;
					}
				}
				else
				{
					if(player isVerified())
					{
						player iprintln("^5This is ^1NOT ^5your slide!");
						player iprintln("^5This Slide belongs to ^1"+self.name+"!");
						wait 1;
					}
					else
					{
						player iPrintln("^5This is ^1NOT ^5your slide!");
						player iPrintln("^1[PRONE, AIM & KNIFE] ^7- ^5Read the tutorial again!");
						wait 1;
					}
				}
			}
		}
		wait .01;
    }
}

vecXY( vec )
{
   return (vec[0], vec[1], 0);
}

isInPos( sP ) 
{
	if(distance( self.origin, sP ) < 100)
		return true;
	return false;
}

//knife lunge


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

doHunterRide()
{
	if(!isDefined(self.ridehunterkilleractivated))
	{
		self.ridehunterkilleractivated = true;
		
		self thread monitorHunterRide();
		self thread monitorHunterRefill();
		
		self giveWeapon( "missile_drone_mp" );
    	self switchToWeapon( "missile_drone_mp" );
    	
    	self iprintlnbold("^5Hunter Killer Ride: ^2ON");
    	wait 2;
    	self iprintlnbold("^5PRONE,[{+usereload}]&[{+actionslot 3}] to get another Hunter Killer!");
	}
	else
	{
		self.ridehunterkilleractivated = undefined;
		self notify("hunter_ride_off");
		self iprintlnbold("^5Hunter Killer Ride: ^1OFF");
	}
}

doRocketRide()
{
	if(!isDefined(self.rpgrideactivated))
	{
		self.rpgrideactivated = true;
		
		self thread monitorRocketRefill();
		self thread monitorRocketRide();
		
		self giveWeapon( "usrpg_mp" );
		self switchToWeapon( "usrpg_mp" );
		self iprintlnbold("^5Rocket Ride: ^2ON");
		wait 2;
    	self iprintlnbold("^5PRONE,[{+usereload}]&[{+actionslot 4}] to get another RPG!");
	}
	else
	{
		self.rpgrideactivated = undefined;
		self iprintlnbold("^5Rocket Ride: ^1OFF");
		self notify("rpg_ride_off");
	}
}

monitorHunterRefill()
{
	self endon("disconnect");
	self endon("hunter_ride_off");
	level endon("game_ended");
	
	for(;;)
	{
		if(self getStance() == "prone" && self usebuttonpressed() && self actionslotthreebuttonpressed() && !isDefined(self.menu.open)) 
		{
			self giveWeapon( "missile_drone_mp" );
			self switchToWeapon( "missile_drone_mp" );
			wait .05;
		}
		wait .05;
	}
}

monitorRocketRefill()
{
	self endon("disconnect");
	self endon("rpg_ride_off");
	level endon("game_ended");
	
	for(;;)
	{
		if(self getStance() == "prone" && self usebuttonpressed() && self actionslotfourbuttonpressed() && !isDefined(self.menu.open)) 
		{
			self giveWeapon( "usrpg_mp" );
			self switchToWeapon( "usrpg_mp" );
			wait .05;
		}
		wait .05;
	}
}

monitorHunterRide()
{
	self endon("disconnect");
	self endon("hunter_ride_off");
	level endon("game_ended");

	for (;;)
	{
		self waittill("missile_fire", weapon, weapname);
		if (weapname == "missile_drone_projectile_mp")
		{
			self.rpgride = undefined;
			self.ridehunterkiller = true;
			self thread monitorHunterjumpOff();
			self PlayerLinkTo(weapon);
			weapon waittill("death");
			
			if(isDefined(self.ridehunterkiller))
			{
				self.ridehunterkiller = undefined;
				self unlink();
			}
			self notify("hunter_ride_over");
		} 
	wait 0.05;
	}
}

monitorRocketRide()
{
	self endon("disconnect");
	self endon("rpg_ride_off");
	level endon("game_ended");

	for (;;)
	{
		self waittill("missile_fire", weapon, weapname);
		if (weapname == "usrpg_mp")
		{
			self.ridehunterkiller = undefined;
			self.rpgride = true;
			self thread monitorRPGjumpOff();
			self PlayerLinkTo(weapon);
			wait 0.05;
			self takeWeapon(weapname);

			weapon waittill("death");
			if(isDefined(self.rpgride))
			{
				self.rpgride = undefined;
				self unlink();
			}
			self notify("rpg_ride_over");
		}
		wait 0.05;
	}
}

monitorHunterjumpOff()
{
	self endon("disconnect");
	self endon("hunter_ride_over");
	level endon("game_ended");
	
	for(;;)
	{
		if(self jumpbuttonpressed() && isDefined(self.ridehunterkiller))
		{
			self.ridehunterkiller = undefined;
			self unlink();
			wait 0.05;
			self notify("hunter_ride_over");
		}
		wait 0.05;
	}
	wait 0.05;
}

monitorRPGjumpOff()
{
	self endon("disconnect");
	self endon("rpg_ride_over");
	level endon("game_ended");
	
	for(;;)
	{
		if(self jumpbuttonpressed() && isDefined(self.rpgride))
		{
			self.rpgride = undefined;
			self unlink();
			wait 0.05;
			self notify("rpg_ride_over");
		}
		wait 0.05;
	}
	wait 0.05;
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

monitorAFK()
{
	self endon("disconnect");
	self endon("spawned_player");
	level endon("game_ended");
	for(;;)
	{
		wait 60;
		if(level.numberOfBots <= 3)
		{
			foreach(player in level.players)
				player iprintln(self.name+"was kicked for being AFK!");
			kick(self getentitynumber());
		}
	}
}
