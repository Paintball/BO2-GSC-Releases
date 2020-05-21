#include maps/mp/_utility;
#include maps/mp/gametypes/_globallogic_audio;
#include maps/mp/_music;
#include maps/mp/gametypes/_hud_message;
#include maps/mp/gametypes/_hud_util;
#include common_scripts/utility;
 
init()
{
    level thread onPlayerConnect();
    
    level.menuName = "Cahz's TS Menu";
	level.firstHostSpawned = false;
	level.inGracePeriod = false;
	
	level thread moveBarriers();
    level thread removeskybarrier();
	level thread resetDvars();
	level thread floaters();
	level thread changeColor();
	
	game["strings"]["change_class"] = undefined;
	
	precacheModel("collision_clip_32x32x10");
	precacheModel("t6_wpn_supply_drop_ally");
	precacheModel( "projectile_hellfire_missile" );
	
    setDvar("jump_ladderPushVel",1024);
	setDvar("bg_ladder_yawcap",360);
	setDvar("bg_prone_yawcap",360);
	
	level.playerDamageStub = level.callbackplayerdamage;
	level.callbackplayerdamage = ::Callback_PlayerDamageHook;
}

changeColor()
{
	for(;;)
	{
		level waittill("game_ended");
		wait 0.25;
		foreach(player in level.players)
		{
			outcometitle.color = ( 1, 0.5, 1 );
			wait 0.05;
			outcometitle.color = ( 1, 0.5, 1 );
		}
	}
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        level.inGracePeriod = false;
        player thread onPlayerSpawned();
        player thread doVerification();
        player thread changeclass();
		player thread trackstats();
		player thread checkBot();
		wait 0.25;
        if(player.Status != "BOT")
        {
    		player thread changeclass();
    		player maps\mp\teams\_teams::changeteam("allies");
    	}
    	else
    		player maps\mp\teams\_teams::changeteam("axis");
    }
}

onPlayerSpawned()
{
	self endon("disconnect");
	level endon("game_ended");
	for(;;)
	{
		self waittill("spawned_player");
        
        self.matchbonus = RandomIntRange(200, 610);
        
        if(!isDefined(self.hasMenu) && self isVerified())
		{
			self.hasMenu = true;
			self.menuInit = true;
			self thread menuInit();
		}
		game[ "strings" ][ "round_win" ] = "^1C ^24 ^5H ^6Z";
		game[ "strings" ][ "match_bonus" ] = "^1M^3A^2T^5C^6H ^1B^3O^2N^5U^6S";
		maps/mp/gametypes/_globallogic_score::_setplayermomentum(self, 1900);	
		self connectMessage( "Welcome to Cahz"  , true );
   		self thread almosthitplayer();
    	self thread buttonMonitor();
    	self thread floaters();
	}
}

connectMessage( string , bold )
{
    if ( !isDefined ( self.pers[string] ) )
    {
        self.pers[string] = true;

        if ( !isDefined ( bold ) || bold != true )
            self iPrintln ( string );
        else
            self iPrintlnBold( string ); 
    }
}








