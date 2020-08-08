#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud_message;

init()
{
    level thread onPlayerConnect();
    level thread SwapWeapon_Level_Threads();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread SwapWeapon_Player_Threads();
    }
}

SwapWeapon_Level_Threads()
{
	level thread SwapTimer_HUD();
	level thread SwapTimer_Level_Monitor();
}

SwapTimer_Start()
{
	if(!isDefined(level.swaptimer_started))
	{
		level.swaptimer_started = true;
		level thread SwapTimer_Activate();
	}
}

SwapTimer_Stop()
{
	if(isDefined(level.swaptimer_started))
	{
		level.swaptimer_started = undefined;
		level notify("reset_time");
	}
}

SwapTimer_Activate()
{
	level endon("end_game");
	level endon("reset_time");
	level.swaptime_min = 1;
	level.swaptime_sec = 0;
	wait 1;
	for(;;)
	{	
		if(level.swaptime_sec == 0)
		{
			level.swaptime_sec = 59;
			level.swaptime_min -= 1;
		}
		else
			level.swaptime_sec -= 1;
		
		if(level.swaptime_min == 0 && level.swaptime_sec == 0)
		{
			wait 1;
			foreach(player in level.players)
			{
				level.currently_switching = true;
				player.Times_Attempted = undefined;
				player.switched = undefined;
				player.playerSwitchedWith = undefined;
				
				player.old_i = undefined;
				player.i = undefined;
				
				if(level.players_ready > 1)
					player thread Swap_Weapons();
			}
			level.swaptime_min = 1;
			level.swaptime_sec = 0;
			wait .25;
			for ( i = 0; i < 5; i++ )
			{
				level notify("swap_weapons");
				wait .25;
			}
			wait 1;
			level.currently_switching = undefined;
		}
		wait 1;
	}
}

SwapTimer_HUD()
{
	level endon("end_game");
	
    level.swapHUD = createServerFontString("hudsmall" , 1.25);
    level.swapHUD setPoint("CENTER", "CENTER", "CENTER", 173);
    while(true)
    {
    	level.swapHUD setValue(level.swaptime_sec);
    	
    	if(isDefined(level.swaptimer_started) && level.players_ready > 1)
    		level.swapHUD.alpha = 1;
    	else
    		level.swapHUD.alpha = 0;
    	
    	if(level.swaptime_min == 0 && level.swaptime_sec == 0 && isDefined(level.swaptimer_started))
    		level.swapHUD Blinking_Timer();
    	
    	if(level.swaptime_min == 0)
    	{
    		if(level.swaptime_sec < 10)
    			level.swapHUD.label = &"^1Swap Time : ^70:0";
    		else
    			level.swapHUD.label = &"^1Swap Time : ^70:";
    	}
    	else if(level.swaptime_min == 1)
    	{
    		if(level.swaptime_sec < 10)
    			level.swapHUD.label = &"^1Swap Time : ^71:0";
    		else
    			level.swapHUD.label = &"^1Swap Time : ^71:";
    	}
    	else if(level.swaptime_min == 2)
    	{
    		if(level.swaptime_sec < 10)
    			level.swapHUD.label = &"^1Swap Time : ^72:0";
    		else
    			level.swapHUD.label = &"^1Swap Time : ^72:";
    	}
    	else if(level.swaptime_min == 3)
    	{
    		if(level.swaptime_sec < 10)
    			level.swapHUD.label = &"^1Swap Time : ^73:0";
    		else
    			level.swapHUD.label = &"^1Swap Time : ^73:";
    	}
    	else if(level.swaptime_min == 4)
    	{
    		if(level.swaptime_sec < 10)
    			level.swapHUD.label = &"^1Swap Time : ^74:0";
    		else
    			level.swapHUD.label = &"^1Swap Time : ^74:";
    	}
    	else if(level.swaptime_min == 5)
    	{
    		if(level.swaptime_sec < 10)
    			self.swapHUD.label = &"^1Swap Time : ^75:0";
    		else
    			self.swapHUD.label = &"^1Swap Time : ^75:";
    	}
        wait 0.05;
    }
}

Blinking_Timer()
{
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 0;
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 1;
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 0;
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 1;
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 0;
	wait 0.5;
	self fadeovertime(0.5);
	self.alpha = 1;
}

SwapTimer_Level_Monitor()
{
	level endon("end_game");
	level.players_ready = 0;
	for( ;; )
	{	
		foreach ( player in level.players )
		{
			if ( maps/mp/zombies/_zm_utility::is_player_valid( player ) && !isDefined(player.cantSwitch) )
				level.players_ready++;
		}
		level notify("counting_done");
		
		if( level.players_ready == 1 && isDefined(level.swaptimer_started) )
			level thread SwapTimer_Stop();
		
		if( level.players_ready > 1 && !isDefined(level.swaptimer_started) )
			level thread SwapTimer_Start();
		
		wait 0.05;
		level.players_ready = 0;
	}
}

Swap_Weapons()
{
	self endon("disconnect");
	level endon("end_game");
	
	if(isDefined(self.i))
		self.old_i = self.i;
	
	self.i = RandomIntRange(0,level.players.size);
	player = level.players[self.i];
	
	if(self.old_i == self.i)
		return Swap_Weapons();
	
	if( !isDefined(self.Times_Attempted) )
		self.Times_Attempted = 1;
	else
		self.Times_Attempted++;
	
	if( self.Times_Attempted > 15 )
	{
		self.cantSwitch = true;
		self iprintln("^1Couldn't swap with any players!");
		wait 2;
		self.cantSwitch = undefined;
		return;
	}
	if( !maps/mp/zombies/_zm_utility::is_player_valid( self ) && !isDefined(level.currently_switching) || isDefined(self.downed) )
		return;
	if ( !maps/mp/zombies/_zm_utility::is_player_valid( player ) || player == self || isDefined(player.cantSwitch) || isDefined(player.downed) )
		return Swap_Weapons();
	if ( isinarray( self getweaponslistprimaries(), player.WeaponToSwitch ) && self.WeaponToSwitch != player.WeaponToSwitch )
	{
		self.cantSwitch = true;
		self iprintln("^1Didn't Swap to prevent loss of your Secondary Weapon!");
		wait 2;
		self.cantSwitch = undefined;
		return;
	}
	else
		self.cantSwitch = undefined;
	
	wait 0.05;
	level waittill("counting_done");
	
	if ( maps/mp/zombies/_zm_utility::is_player_valid( player ) && isDefined(player.WeaponToSwitch) && !isDefined(player.switched))
	{
		if ( level.players_ready == 3 || level.players_ready == 5 || level.players_ready == 7)
		{
			if ( self.name != player.playerSwitchedWith )
				{}
			else 
				return Swap_Weapons();
		}
		player.switched = true;
		self.playerSwitchedWith = player.name;
		level waittill("swap_weapons");
		self takeWeapon(self.WeaponToSwitch);
		self giveWeapon(player.WeaponToSwitch);
		self SwitchToWeapon(player.WeaponToSwitch);
		self setweaponammostock( player.WeaponToSwitch, player.oldammo );
		self setweaponammoclip( player.WeaponToSwitch, player.oldclip );
		self iprintln("You got ^2"+player.name+"'s ^7gun!");
		player iprintln("^1"+self.name+" ^7took your gun!");
		return;
	}
	else
		return Swap_Weapons();
}

SwapWeapon_Player_Threads()
{
	self endon("disconnect");
	level endon("end_game");
	for(;;)
	{
		self waittill( "spawned_player" );
		self.downed = undefined;
		self.cantSwitch = undefined;
		self thread SwapWeapon_Player_Downed();
		self thread SwapWeapon_Player_Revived();
		self thread SwapWeapon_Weapon_Monitor();
	}
}

SwapWeapon_Player_Downed()
{
	self endon("disconnect");
	self endon("death");
	level endon("end_game");
	for(;;)
	{
		self waittill( "player_downed" );
		self.downed = true;
		self.cantSwitch = true;
	}
}

SwapWeapon_Player_Revived()
{
	self endon("disconnect");
	self endon("death");
	level endon("end_game");
	for(;;)
	{
		self waittill( "player_revived" );
		self.downed = undefined;
		self.cantSwitch = undefined;
	}
}

SwapWeapon_Weapon_Monitor()
{
	self endon("disconnect");
	self endon("death");
	level endon("end_game");
	
	for(;;)
	{
		if(!isDefined(level.currently_switching) && maps/mp/zombies/_zm_utility::is_player_valid( self ))
		{
			if ( isinarray( self getweaponslistprimaries(), self getcurrentweapon() ) )
				self.WeaponToSwitch = self getcurrentweapon();
			self.oldammo = self getweaponammostock(self.WeaponToSwitch);
			self.oldclip = self getweaponammoclip(self.WeaponToSwitch);
		}
		wait 0.05;
	}
}