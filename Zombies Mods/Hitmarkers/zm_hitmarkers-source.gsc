#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
    level thread init_hitmarkers();
}

init_hitmarkers()
{
	precacheshader( "damage_feedback" );
	
	maps/mp/zombies/_zm_spawner::register_zombie_damage_callback(::do_hitmarker);
    maps/mp/zombies/_zm_spawner::register_zombie_death_event_callback(::do_hitmarker_death);
    
    for( ;; )
    {
        level waittill( "connected", player );
        player.hud_damagefeedback = newdamageindicatorhudelem( player );
    	player.hud_damagefeedback.horzalign = "center";
    	player.hud_damagefeedback.vertalign = "middle";
    	player.hud_damagefeedback.x = -12;
    	player.hud_damagefeedback.y = -12;
    	player.hud_damagefeedback.alpha = 0;
    	player.hud_damagefeedback.archived = 1;
    	player.hud_damagefeedback.color = ( 1, 1, 1 );
    	player.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
		player.hud_damagefeedback_red = newdamageindicatorhudelem( player );
    	player.hud_damagefeedback_red.horzalign = "center";
    	player.hud_damagefeedback_red.vertalign = "middle";
    	player.hud_damagefeedback_red.x = -12;
    	player.hud_damagefeedback_red.y = -12;
    	player.hud_damagefeedback_red.alpha = 0;
    	player.hud_damagefeedback_red.archived = 1;
    	player.hud_damagefeedback_red.color = ( 1, 0, 0 );
    	player.hud_damagefeedback_red setshader( "damage_feedback", 24, 48 );
    }
}

updatedamagefeedback( mod, inflictor, death ) //checked matches cerberus output
{
	if ( !isplayer( self ) || isDefined( self.disable_hitmarkers ))
	{
		return;
	}
	if ( isDefined( mod ) && mod != "MOD_CRUSH" && mod != "MOD_GRENADE_SPLASH" && mod != "MOD_HIT_BY_OBJECT" )
	{
		if ( isDefined( inflictor ))
		{
			self playlocalsound( "mpl_hit_alert" );
		}
		if( death && getdvarintdefault( "redhitmarkers", 1 ))
		{
    		self.hud_damagefeedback_red setshader( "damage_feedback", 24, 48 );
			self.hud_damagefeedback_red.alpha = 1;
			self.hud_damagefeedback_red fadeovertime( 1 );
			self.hud_damagefeedback_red.alpha = 0;
		}
		else
		{
        	self.hud_damagefeedback setshader( "damage_feedback", 24, 48 );
			self.hud_damagefeedback.alpha = 1;
			self.hud_damagefeedback fadeovertime( 1 );
			self.hud_damagefeedback.alpha = 0;
		}
	}
    return 0;
}

do_hitmarker_death()
{
	if( isDefined( self.attacker ) && isplayer( self.attacker ) && self.attacker != self )
    {
		self.attacker thread updatedamagefeedback( self.damagemod, self.attacker, 1 );
    }
    return 0;
}

do_hitmarker(mod, hitloc, hitorig, player, damage)
{
    if( isDefined( player ) && isplayer( player ) && player != self )
    {
		player thread updatedamagefeedback( mod, player, 0 );
    }
    return 0;
}
