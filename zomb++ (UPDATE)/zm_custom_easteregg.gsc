CustomWeaponSystem(string, origin, weapon)
{
	level thread LowerMessage( "Secret Room Weapons", string );
	RoomWeapons = spawn("trigger_radius", origin, 1, 20, 20);
	RoomWeapons rotateTo((0, 90, 0), .1);
	RoomWeapons SetCursorHint( "HINT_NOICON" );
	RoomWeapons setLowerMessage( RoomWeapons, "Secret Room Weapons" );
	for(;;)
	{
		RoomWeapons waittill("trigger", i);
		if(isDefined(self.staffgrabbed))
		{
			RoomWeapons delete();
		}
		if(i useButtonPressed() && distance(i.origin, origin) < 40)
		{
			wait .3;
			if(i useButtonPressed())
			{
				if(!isDefined(self.staffgrabbed))
				{
					self.staffgrabbed = true;
					w = i GetWeaponsListPrimaries();
					i playsound( "zmb_cha_ching" );
					playerCurrent = i getCurrentWeapon();
					if(w.size > 1)i takeWeapon(playerCurrent);
					i giveweapon( "knife_zm" );
					i giveWeapon( weapon );
					i givemaxammo( weapon );
					i switchToWeapon( weapon );
					i play_weapon_vo( weapon );
					wait 1;
					RoomWeapons delete();
				}
			}
		}
	}
}
CustomEventTrigger( origin )
{
	self endon( "disconnect" );
	level endon( "end_game" );
	if(!isDefined(self.totalskulls))
		self.totalskulls = 1;
	else
		self.totalskulls += 1;
	trig = spawn("trigger_radius", origin, 1, 25, 25);
	for(;;)
	{
		trig waittill("trigger", self);
		if(self useButtonPressed())
		{
			wait .25;
			if(self useButtonPressed())
			{
				if(!isDefined(self.skulls))
					self.skulls = 1;
				else
					self.skulls += 1;
				wait 0.05;
				if(self.skulls != self.totalskulls)
				{
					self playsound("zmb_insta_kill");
					return;
				}
				else
				{
                    self playsound("zmb_cha_ching");
                    self thread getAllPerks();
                    if(level.script == "zm_tomb")
					{
						self thread CustomWeaponSystem("Hold ^3F ^7for Lightning Staff", (54, 230.5, -752), "staff_lightning_zm");
						self thread CustomWeaponSystem("Hold ^3F ^7for Fire Staff", (139.4, 189, -752), "staff_fire_zm");
						self thread CustomWeaponSystem("Hold ^3F ^7for Water Staff", (-57.5, 230, -752), "staff_water_zm");
						self thread CustomWeaponSystem("Hold ^3F ^7for Wind Staff", (-142, 187, -752), "staff_lightning_zm");
					}
					else if(level.script == "zm_prison")
					{
						self playsound( "zmb_buildable_complete" );
						w = self GetWeaponsListPrimaries();
                    	if(w.size > 1)
                    		self takeWeapon(self getCurrentWeapon());
						self giveWeapon("blundergat_zm");
						self SwitchToWeapon("blundergat_zm");
					}
					else
						self playsoundtoplayer( level.zmb_laugh_alias, self );
					self iprintln("Congratulations! You completed the easter egg!");
					return;
				}
			}
		}
	}
}
customEasterEgg()
{
	if(level.script == "zm_tranzit")
	{
		self thread CustomEventTrigger( (10411, 7326, -570) );
		self thread CustomEventTrigger( (-7622, 4903, -54) );
		self thread CustomEventTrigger( (452, -384, -62) );
	}
	else if(level.script == "zm_buried")
	{
		self thread CustomEventTrigger( (2596, 34.5, 88) );
		self thread CustomEventTrigger( (1333, 1391, 200) );
		self thread CustomEventTrigger( (3281, 430, 240) );
	}
	else if(level.script == "zm_highrise")
	{
		self thread CustomEventTrigger( (3448, 1347, 3032) );
		self thread CustomEventTrigger( (2843.5, 1228.5, 2711) );
		self thread CustomEventTrigger( (2105, 103, 1120) );
	}
	else if(level.script == "zm_nuked")
	{
		self thread CustomEventTrigger( (184, 664, -61.5) );
		self thread CustomEventTrigger( (795, 373, 88) );
		self thread CustomEventTrigger( (-485, 554, 85) );
	}
	else if(level.script == "zm_prison")
	{
		self thread CustomEventTrigger( (436, 10264, 1337) );
		self thread CustomEventTrigger( (2503, 9440, 1528) );
		self thread CustomEventTrigger( (4.5, 7610, 64) );
	}
	else if(level.script == "zm_tomb")
	{
		self thread CustomEventTrigger( (-446, 3976, -352) );
		self thread CustomEventTrigger( (-479, 2952, -256) );
		self thread CustomEventTrigger( (2095, 4567, -304) );
	}
}
getAllPerks()
{
    self endon("disconnect");
    level endon("end_game");
    
    for(;;)
    {
		wait 0.5;
		if (isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
			self doGivePerk("specialty_armorvest");
		if (isDefined(level.zombiemode_using_sleightofhand_perk) && level.zombiemode_using_sleightofhand_perk)
			self doGivePerk("specialty_fastreload");
		if (isDefined(level.zombiemode_using_revive_perk) && level.zombiemode_using_revive_perk)
			self doGivePerk("specialty_quickrevive");
		if (isDefined(level.zombiemode_using_doubletap_perk) && level.zombiemode_using_doubletap_perk) 
			self doGivePerk("specialty_rof");
		if (isDefined(level.zombiemode_using_marathon_perk) && level.zombiemode_using_marathon_perk)
			self doGivePerk("specialty_longersprint");
		if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
			self doGivePerk("specialty_additionalprimaryweapon");
		if (isDefined(level.zombiemode_using_deadshot_perk) && level.zombiemode_using_deadshot_perk)
			self doGivePerk("specialty_deadshot");
		if (isDefined(level.zombiemode_using_tombstone_perk) && level.zombiemode_using_tombstone_perk)
			self doGivePerk("specialty_scavenger");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_flakjacket"]) && (level.script != "zm_buried"))
			self doGivePerk("specialty_flakjacket");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_nomotionsensor"]))
			self doGivePerk("specialty_nomotionsensor");
		if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_grenadepulldeath"]))
			self doGivePerk("specialty_grenadepulldeath");
		//if (isDefined(level.zombiemode_using_chugabud_perk) && level.zombiemode_using_chugabud_perk)
			//self doGivePerk("specialty_finalstand");
	}
}
doGivePerk(perk)
{
    if (!(self hasperk(perk)))
        self thread maps/mp/zombies/_zm_perks::give_perk(perk, 1);
}


