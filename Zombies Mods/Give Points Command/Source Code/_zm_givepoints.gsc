#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerMessage();
    }
}

onPlayerMessage() 
{
	level endon( "game_ended" );
	for (;;) 
	{
		level waittill("say", player, message );
		message_strings = strToK( message, " " );
		for( i = 0; i < level.players.size; i++ )
		{
			if( tolower( message_strings[ 0 ] ) == "/give" && isSubStr( tolower( getPlayerName( level.players[ i ] )), message_strings[ 1 ] ) )
			{
				value = int( message_strings[ ( message_strings.size - 1 ) ] );
				if( value < 0 )
					value = ( value * -1 );
				player give_points( level.players[ i ], int( value ));
			}
		}
	}
}

give_points( player, var )
{
	if( !isDefined( self.giving_points ) )
	{
		self.giving_points = true;
		if ( player.score == 1000000 )
			self tell( getPlayerName( player ) + " already has ^51000000 ^7points" );
		else if( self.score >= var )
		{
			self maps/mp/zombies/_zm_score::minus_to_player_score( var, 1 );
			self tell( "^1Gave ^7" + getPlayerName( player ) + " ^1" + var + " ^7points" );
			player maps/mp/zombies/_zm_score::add_to_player_score( var, 1 );
			player tell( "^2" + getPlayerName( self ) + " ^7gave you ^2" + var + " ^7points" );
		}
		else
			self tell( "^1You don't have enough points for that" );
		wait 1;
		self.giving_points = undefined;
	}
}

getPlayerName( player )
{
    playerName = getSubStr( player.name, 0, player.name.size );
    for( i = 0; i < playerName.size; i++ )
    {
		if( playerName[ i ] == "]" )
			break;
    }
    if( playerName.size != i )
		playerName = getSubStr( playerName, i + 1, playerName.size );
		
    return playerName;
}
