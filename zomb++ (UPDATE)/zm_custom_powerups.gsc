startCustomPowerups()
{
	if(!isDefined(level.custompowerupinit))
	{
		level.custompowerupinit = true;
		wait 2;
        	if(isDefined(level._zombiemode_powerup_grab))
        		level.original_zombiemode_powerup_grab = level._zombiemode_powerup_grab;
		wait 2;
        	level._zombiemode_powerup_grab = ::custom_powerup_grab;
	}
}
initCustomPowerups() //credit goes to _Ox for the original code <3
{
	level.unlimited_ammo_duration = 20;
	//unlimited ammo drop "bottomless clip" credit to _Ox
	include_zombie_powerup("unlimited_ammo");
	add_zombie_powerup("unlimited_ammo", "T6_WPN_AR_GALIL_WORLD", &"ZOMBIE_POWERUP_UNLIMITED_AMMO", ::func_should_always_drop, 0, 0, 0);
	powerup_set_can_pick_up_in_last_stand("unlimited_ammo", 1);
	if(getDvar("mapname") == "zm_prison")
	{
		//fast feet - speed potion, basically you run fast for 15 seconds
		include_zombie_powerup("fast_feet");
		add_zombie_powerup("fast_feet", "bottle_whisky_01", &"ZOMBIE_POWERUP_FAST_FEET", ::func_should_always_drop, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("fast_feet", 1);
		//pack a punch - pack a punches your current gun credit Knight
		include_zombie_powerup("pack_a_punch");
		add_zombie_powerup("pack_a_punch", "p6_zm_al_vending_pap_on", &"ZOMBIE_POWERUP_PACK_A_PUNCH", ::func_should_drop_pack_a_punch, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("pack_a_punch", 0);
		//couldn't find a better model for this money drop, if you find a better one pls let me know haha
		include_zombie_powerup("money_drop");
		add_zombie_powerup("money_drop", "p6_anim_zm_al_magic_box_lock_red", &"ZOMBIE_POWERUP_MONEY_DROP", ::func_should_always_drop, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("money_drop", 1);
	}
	else
	{
		include_zombie_powerup("fast_feet");
		add_zombie_powerup("fast_feet", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FAST_FEET", ::func_should_always_drop, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("fast_feet", 1);
		
		include_zombie_powerup("pack_a_punch");
		add_zombie_powerup("pack_a_punch", "p6_anim_zm_buildable_pap", &"ZOMBIE_POWERUP_PACK_A_PUNCH", ::func_should_drop_pack_a_punch, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("pack_a_punch", 0);
		
		include_zombie_powerup("money_drop");
		add_zombie_powerup("money_drop", "zombie_teddybear", &"ZOMBIE_POWERUP_MONEY_DROP", ::func_should_always_drop, 0, 0, 0);
		powerup_set_can_pick_up_in_last_stand("money_drop", 1);
	}
}
func_should_drop_pack_a_punch()
{
	if ( level.zmPowerupsEnabled[ "pack_a_punch" ].active != 1 || level.round_number < 12 || isDefined( level.rounds_since_last_pack_a_punch_drop ) && level.rounds_since_last_pack_a_punch_drop < 5 )
	{
		return 0;
	}
	return 1;
}
custom_powerup_grab(powerup, player) //credit to _Ox much thx for powerup functions
{
	if(powerup.powerup_name == "money_drop")
		player thread doRandomScore(); //some cash money
	else if(powerup.powerup_name == "pack_a_punch")
		player thread doPackAPunchWeapon(); //i dont even use this one, its so OP lmao. If we could edit drop rate for this drop only it'd be better
	else if(powerup.powerup_name == "unlimited_ammo")
		player thread doUnlimitedAmmo(); //credit to _Ox for this one baby. its so good
	else if(powerup.powerup_name == "fast_feet")
		player thread doFastFeet(); //go fast as fuck boi
	else if (isDefined(level.original_zombiemode_powerup_grab))
		level thread [[level.original_zombiemode_powerup_grab]](s_powerup, e_player);
}
doFastFeet() //gotta go fast!
{
	self thread poweruptext("Fast Feet!"); //thanks to _Ox again for the powerup pickup string
	self playsound("zmb_cha_ching"); //m-m-m-m-m-money shot
	self setmovespeedscale(3); //super sonic speed
	wait 15;
	self setmovespeedscale(1);
	self playsound("zmb_insta_kill"); //less happy sound than before
}
doUnlimitedAmmo() //unlimited ammo powerup function credit _Ox
{
	foreach(player in level.players)
	{
		player notify("end_unlimited_ammo");
		player playsound("zmb_cha_ching");
		player thread poweruptext("Bottomless Clip");
		player thread monitorUnlimitedAmmo(); //bottomless clip
		player thread notifyUnlimitedAmmoEnd(); //notify when it ends
	}
}
monitorUnlimitedAmmo() //credit to _Ox
{
	level endon("end_game");
	self endon("disonnect");
	self endon("end_unlimited_ammo");
	for(;;)
	{
		self setWeaponAmmoClip(self GetCurrentWeapon(), 150);
		wait .05;
	}
}
notifyUnlimitedAmmoEnd() //credit to _Ox
{
	level endon("end_game");
	self endon("disonnect");
	self endon("end_unlimited_ammo");
	wait level.unlimited_ammo_duration;
	self playsound("zmb_insta_kill");
	self notify("end_unlimited_ammo");
}
doPackAPunchWeapon() //pack a punch function credit Knight
{
    baseweapon = get_base_name(self getcurrentweapon());
    weapon = get_upgrade(baseweapon);
    if(IsDefined(weapon) && isDefined(self.packapunching))
    {
        level.rounds_since_last_pack_a_punch_drop = 0;
        self.packapunching = undefined;
        self takeweapon(baseweapon);
        self giveweapon(weapon, 0, self get_pack_a_punch_weapon_options(weapon));
        self switchtoweapon(weapon);
        self givemaxammo(weapon);
    }
    else
    	self playsoundtoplayer( level.zmb_laugh_alias, self );
}
get_upgrade(weapon)
{
    if(IsDefined(level.zombie_weapons[weapon].upgrade_name) && IsDefined(level.zombie_weapons[weapon]))
    {
    	self.packapunching = true;
        return get_upgrade_weapon(weapon, 0 );
    }
    else
        return get_upgrade_weapon(weapon, 1 );
}
doRandomScore() //this is a bad way of doing this but i couldnt get the array to work before and did this out of frustration
{
	x = randomInt(9); //picks a number 0-9
	self playsound("zmb_cha_ching");
	if(x==1)
		self.score += 50; //+50
	else if(x==2)
		self.score += 100; //+100
	else if(x==3)
		self.score += 250; //+250 I think you get the idea
	else if(x==4)
		self.score += 500;
	else if(x==5)
		self.score += 750;
	else if(x==6)
		self.score += 1000;
	else if(x==7)
		self.score += 2500;
	else if(x==8)
		self.score += 5000;
	else if(x==9)
		self.score += 7500;
	else
		self.score += 10000;
}
poweruptext(text) //credit to _Ox for base string hud
{
	self endon("disconnect");
	level endon("end_game");
	hud_string = newclienthudelem(self);
	hud_string.elemtype = "font";
	hud_string.font = "objective";
	hud_string.fontscale = 2;
	hud_string.x = 0;
	hud_string.y = 0;
	hud_string.width = 0;
	hud_string.height = int( level.fontheight * 2 );
	hud_string.xoffset = 0;
	hud_string.yoffset = 0;
	hud_string.children = [];
	hud_string setparent(level.uiparent);
	hud_string.hidden = 0;
	hud_string maps/mp/gametypes_zm/_hud_util::setpoint("TOP", undefined, 0, level.zombie_vars["zombie_timer_offset"] - (level.zombie_vars["zombie_timer_offset_interval"] * 2));
	hud_string.sort = .5;
	hud_string.alpha = 0;
	hud_string fadeovertime(.5);
	hud_string.alpha = 1;
	hud_string setText(text);
	hud_string thread poweruptextmove();
}
poweruptextmove() //credit to _Ox for base string hud
{
	wait .5;
	self fadeovertime(1.5);
	self moveovertime(1.5);
	self.y = 270;
	self.alpha = 0;
	wait 1.5;
	self destroy();
}
