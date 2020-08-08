#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;

init()
{
    level thread onplayerconnected();
}
 
onplayerconnected()
{
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread watch_for_grenade_throw();
    }
}
 
watch_for_grenade_throw()
{
    self endon ( "disconnect" );
    level endon ( "end_game" );
    for ( ;; )
    {
        self waittill ("grenade_fire", grenade, weapname);
        if ( weapname == "frag_grenade_zm" )
        {
            grenade thread multiply_grenades();
        }
        wait 0.1;
    }
}
 
multiply_grenades()
{
    self endon ( "death" );
    wait 1.25;
    self magicgrenadetype( "frag_grenade_zm", self.origin + ( 20, 0, 0 ), ( 50, 0, 400 ), 2.5 );
    wait 0.25;
    self magicgrenadetype( "frag_grenade_zm", self.origin + ( -20, 0, 0 ), ( -50, 0, 400 ), 2.5 );
    wait 0.25;
    self magicgrenadetype( "frag_grenade_zm", self.origin + ( 0, 20, 0 ), ( 0, 50, 400 ), 2.5 );
    wait 0.25;
    self magicgrenadetype( "frag_grenade_zm", self.origin + ( 0, -20, 0 ), ( 0, -50, 400 ), 2.5 );
    wait 0.25;
    self magicgrenadetype( "frag_grenade_zm", self.origin, ( 0, 0, 400 ), 2.5 );
}