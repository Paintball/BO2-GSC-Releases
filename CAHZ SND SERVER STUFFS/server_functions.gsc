resetDvars()
{
	level endon("dvars_reset");
	level waittill("game_ended");
	
	for(;;)
	{
		setDvar("jump_ladderPushVel",128);
		setDvar("bg_ladder_yawcap",100);
		setDvar("bg_prone_yawcap",85);
		wait 0.05;
		level notify("dvars_reset");
	}
}

spawnBot(value)
{
	for(i = 0; i < value; i++)
	{
		self thread maps\mp\bots\_bot::spawn_bot( "axis" );
	}
}

checkBot()
{
	level.numberOfBots = 0;
	foreach(player in level.players)
	{
		if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
			level.numberOfBots += 1;
	}
	wait 1;
	if(level.numberOfBots == 0)
		level thread spawnBot(1);
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
}

changeClass()
{
   self endon("disconnect");
   level endon("game_ended");
   for(;;)
   {
        self waittill("changed_class");
        //self.pers[ "class" ] = undefined;
        self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
   }
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

Callback_PlayerDamageHook( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, timeoffset, boneindex ) 
{
	self endon( "disconnect" );

	OnGround = eattacker IsOnGround();
	IsClose = Distance( self.origin, eattacker.origin ) < 500;
	meterdist = int( Distance( self.origin, eattacker.origin ) / 39.37 );

	if( smeansofdeath != "MOD_TRIGGER_HURT" && smeansofdeath != "MOD_FALLING" && smeansofdeath != "MOD_SUICIDE" ) 
	{
		if( isDefined(eattacker.dontkill) )
			self.health += idamage;
		else if( !OnGround && isDefined(eattacker.customweapon) && IsSubStr( sweapon, self.customweapon ) && meterdist > 15 )
			idamage = 10000000;
		else if( smeansofdeath == "MOD_MELEE" || IsSubStr( sweapon, "+gl" ))
			self.health += idamage;
		else if( einflictor != eattacker && sweapon == "hatchet_mp" )
			self.health += idamage;
		else if( einflictor != eattacker && sweapon == "knife_ballistic_mp" )
			self.health += idamage;
		else if( OnGround )
			self.health += idamage;
		else if( getWeaponClass( sweapon ) == "weapon_sniper" || IsSubStr( sweapon, "sa58" ) || IsSubStr( sweapon, "saritch" ) )
		{
			if( meterdist < 5 )
			{
				self.health += idamage;
				eattacker iprintln("^5Barrel Stuff Protection! ^1Hitmarkered ^5from ( ^1"+meterdist+" ^5) meters away!" );
			}
			else
				idamage = 10000000;
		}
		else
			self.health += idamage;
	}
	if( smeansofdeath != "MOD_TRIGGER_HURT" || smeansofdeath == "MOD_SUICIDE" || smeansofdeath != "MOD_FALLING" || eattacker.classname == "trigger_hurt" ) 
		self.attackers = undefined;
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

