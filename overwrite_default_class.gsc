#include maps/mp/gametypes/_hud;
#include maps/mp/gametypes/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

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
        
    	player thread onPlayerSpawned();
    	player thread doChangeClass();
    }
}

onPlayerSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	for(;;)
	{
		self waittill("spawned_player");
		
		if(isDefined(self.RandomClass))
			self thread doLoadout();
	}
}

doChangeClass()
{
   	self endon("disconnect");
	for(;;)
	{
		self waittill("changed_class");
		if(self.pers[ "class" ] == "CLASS_SMG")
		{
			self.pers[ "class" ] = undefined;
			self maps/mp/gametypes/_class::giveloadout( self.team, self.class );
			self thread doRandomClass();
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

doRandomClass()
{
	self.Sniper = strTok("dsr50_mp+steadyaim+fmj,dsr50_mp+steadyaim+acog,dsr50_mp+steadyaim+ir,dsr50_mp+steadyaim+dualclip,ballista_mp+steadyaim+fmj,ballista_mp+steadyaim+acog,ballista_mp+steadyaim+ir,ballista_mp+steadyaim+dualclip,ballista_mp+steadyaim+is,as50_mp+steadyaim+fmj,as50_mp+steadyaim+acog,as50_mp+steadyaim+ir,as50_mp+steadyaim+dualclip,svu_mp+steadyaim+fmj,svu_mp+steadyaim+acog,svu_mp+steadyaim+ir,svu_mp+steadyaim+dualclip", ",");
	self.Weapon = strTok("hk416_mp+dualoptic,srm1216_mp,870mcs_mp,an94_mp+gl,as50_mp+fmj,ballista_mp+fmj+is,ballista_mp+fmj,beretta93r_mp,beretta93r_dw_mp,crossbow_mp,dsr50_mp+fmj,evoskorpion_mp+sf,fiveseven_mp,knife_ballistic_mp,ksg_mp+silencer,mp7_mp+sf,pdw57_mp+silencer,peacekeeper_mp+sf,riotshield_mp,sa58_mp+sf,sa58_mp+fmj+silencer,saritch_mp+sf,saritch_mp+fmj+silencer,scar_mp+gl,svu_mp+fmj+silencer,tar21_mp+dualclip,type95_mp+dualclip,vector_mp+sf,vector_mp+rf,usrpg_mp", ",");
	self.Tactical = strTok("trophy_system_mp,sensor_grenade_mp,emp_grenade_mp,proximity_grenade_mp,flash_grenade_mp,willy_pete_mp", ",");
	self.Frag = strTok("satchel_charge_mp,bouncingbetty_mp,claymore_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp", ",");
	
	self.RandSniper = RandomInt(self.Sniper.size);
	self.RandWeapon = RandomInt(self.Weapon.size);
	self.RandTactical = RandomInt(self.Tactical.size);
	self.RandFrag = RandomInt(self.Frag.size);
	self.randy = RandomIntRange(1,45);
	self thread doLoadout();
}

doLoadout()
{
	self thread takeDefaultClass();
	self thread doPerks();
	
	self giveWeapon(self.Sniper[self.RandSniper], 0, true(self.randy,0,0,0,0));
	self giveWeapon(self.Weapon[self.RandWeapon], 0, true(self.randy,0,0,0,0));
	self giveWeapon(self.Frag[self.RandFrag]);
	self giveWeapon(self.Frag[self.RandFrag]);
	self giveWeapon(self.Tactical[self.RandTactical]);
	self giveWeapon(self.Tactical[self.RandTactical]);
	self switchToWeapon(self.Sniper[self.RandSniper]);
}

takeDefaultClass()
{
	self takeWeapon("evoskorpion_mp+extclip+grip");
	self takeWeapon("beretta93r_mp+steadyaim");
	self takeWeapon("satchel_charge_mp");
	self takeWeapon("willy_pete_mp");
}

doPerks()
{
	self setperk("specialty_fallheight");
    self setperk("specialty_fastequipmentuse");
    self setperk("specialty_fastladderclimb");
    self setperk("specialty_fastmantle");
    self setperk("specialty_fastmeleerecovery");
    self setperk("specialty_fasttoss");
    self setperk("specialty_fastweaponswitch");
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
