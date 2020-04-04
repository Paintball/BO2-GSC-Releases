#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
 
init()
{
    level thread onPlayerConnect();	
	game["strings"]["change_class"] = undefined;
}
 
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread changeclass();
    }
}

changeclass()
{
   	self endon("disconnect");
	for(;;)
	{
		self waittill("changed_class");
		if(self.pers[ "class" ] == "CLASS_SMG")
		{
			self.pers[ "class" ] = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
			self thread doRandomLoadout();
		}
		else
		{
			self.pers[ "class" ] = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
		}
	}
}

doRandomLoadout()
{
	self thread takeClass();
	
	RandCamo = RandomIntRange(1,45);
	
	self.Primary = strTok("dsr50_mp+steadyaim,ballista_mp+steadyaim,svu_mp+steadyaim,as50_mp+steadyaim", ",");
	self.Secondary = strTok("dualoptic_xm8_mp,dualoptic_mk48_mp,srm1216_mp,870mcs_mp,an94_mp+gl,as50_mp+fmj,ballista_mp+fmj+is,ballista_mp+fmj,beretta93r_mp,beretta93r_dw_mp,crossbow_mp,dsr50_mp+fmj,evoskorpion_mp+sf,fiveseven_mp,knife_ballistic_mp,ksg_mp+silencer,mp7_mp+sf,pdw57_mp+silencer,peacekeeper_mp+sf,riotshield_mp,sa58_mp+sf,sa58_mp+fmj+silencer,saritch_mp+sf,saritch_mp+fmj+silencer,scar_mp+gl,svu_mp+fmj+silencer,tar21_mp+dualclip,type95_mp+dualclip,vector_mp+sf,vector_mp+rf,usrpg_mp", ",");
	self.Tactical = strTok("trophy_system_mp,sensor_grenade_mp,emp_grenade_mp,proximity_grenade_mp,flash_grenade_mp,willy_pete_mp", ",");
	self.Frag = strTok("satchel_charge_mp,bouncingbetty_mp,claymore_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp", ",");
	
	self.RandPrimary = RandomInt(self.Sniper.size);
	self.RandSecondary = RandomInt(self.Weapon.size);
	self.RandTactical = RandomInt(self.Tactical.size);
	self.RandFrag = RandomInt(self.Frag.size);
	
	self giveWeapon(self.Primary[self.RandPrimary], 0, true(RandCamo,0,0,0,0));
	self giveWeapon(self.Secondary[self.RandSecondary], 0, true(RandCamo,0,0,0,0));
	
	self giveWeapon(self.Frag[self.RandFrag]);
	self giveWeapon(self.Frag[self.RandFrag]);
	
	self giveWeapon(self.Tactical[self.RandTactical]);
	self giveWeapon(self.Tactical[self.RandTactical]);
	
	self switchToWeapon(self.Sniper[self.RandSniper]);
}

takeClass()
{
	//default loadout//
	self takeWeapon("evoskorpion_mp+extclip+grip");
	self takeWeapon("beretta93r_mp+steadyaim");
	self takeWeapon("satchel_charge_mp");
	self takeWeapon("willy_pete_mp");
	self thread initPerks();
}

initPerks()
{
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
