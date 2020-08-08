/*/////////////////////////////////
//	SIMPLE VOTE KICK SYSTEM BO2	//
//	  DEVELOPED BY @ITSCAHZ	   //
////////////////////////////////

 VERSION 1.1 ( ZOMBIES )

THANKS @THEHIDDENHOUR FOR THE HELP AND ANSWERING QUESTIONS WHEN I HAD THEM

  VERSION 1.1 ADDED A DVAR FOR BANNING TO PREVENT SOMEONE FROM REJOINING AFTER BEING VOTEKICKED
              ADDED VOTE KICK LIMIT: ONE VOTE KICK PER PERSON, PER MAP*/

#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for( ;; )
    {
        level waittill( "connected", player );
        player thread activateVoteKick();
    }
}

activateVoteKick()
{
	if( getPlayerDvar( player, "banned" ) == "" )
	{}
    else if( getPlayerDvar( player, "banned" ) == true )
    {
        kick( player getEntityNumber(), "EXE_PLAYERKICKED" );
    }
	self endon( "disconnect" );
	level endon( "end_game" );
	for(;;)
	{
		if( self adsbuttonpressed() && self actionslottwobuttonpressed() && !isDefined( level.voting ) && !isDefined( self.checkingToVote ) && level.players.size >= 3 )
		{
			self thread votekickText();
			self thread func_whotokick();
		}
		wait 0.05;
	}
}

func_whotokick()
{
	self endon( "disconnect" );
	self endon( "close_voting" );
	level endon( "end_game" );
	
	self.checkingToVote = true;
	level thread recountPlayers();
	
	i = 0;
	player = level.players[i];
	
	self.VoteKickTopString setText( "Vote Kick Who?" );
	self.VoteKickBottomString setText( "[{+actionslot 3}] << ^1"+player.name+"^7 >> [{+actionslot 4}]" );
	self.VoteKickInfoString setText( "^5Press [{+gostand}] to Select, [{+melee}] to Close" );
	
	for( ;; )
	{
		if( self actionslotfourbuttonpressed() )
		{
			if( i != ( level.players.size - 1) )
			{
				i++;
				player = level.players[i];
				self.VoteKickBottomString setText( "[{+actionslot 3}] << ^1" + player.name + "^7 >> [{+actionslot 4}]" );
			}
			else
			{
				i = 0;
				player = level.players[i];
				self.VoteKickBottomString setText( "[{+actionslot 3}] << ^1" + player.name + "^7 >> [{+actionslot 4}]" );
			}
		}
		if( self actionslotthreebuttonpressed() )
		{
			if( i == 0 )
			{
				i = (level.players.size - 1);
				player = level.players[i];
				self.VoteKickBottomString setText( "[{+actionslot 3}] << ^1" + player.name + "^7 >> [{+actionslot 4}]" );
			}
			else
			{
				i--;
				player = level.players[i];
				self.VoteKickBottomString setText( "[{+actionslot 3}] << ^1" + player.name + "^7 >> [{+actionslot 4}]" );
			}
		}
		if( self meleebuttonpressed() )
		{
			self.checkingToVote = undefined;
			self.VoteKickTopString destroy();
			self.VoteKickBottomString destroy();
			self.VoteKickInfoString destroy();
			self notify("close_voting");
		}
		if( self jumpbuttonpressed() )
		{
			self thread CheckIfCanVoteKick( player );
		}
		wait 0.05;
	}
}

CheckIfCanVoteKick( badplayer )
{
	if( !isDefined( level.voting ) )
	{
		
		if( isDefined( self.VoteKickedAlready ) )
		{
			self iprintln( "^1You cannot vote kick more than once a game!" );
		}
		else
		{
			level.voting = true;
			self.VoteKickedAlready = true;
			foreach( player in level.players )
			{
				player.VoteKickTopString destroy();
				player.VoteKickBottomString destroy();
				player.VoteKickInfoString destroy();
			}
			level thread StartVoteKick( badplayer );
			self.checkingToVote = undefined;
			self notify( "close_voting" );
		}
	}
	else
	{
		self iprintln( "^1Voting taking place! Please wait until it has finished!" );
	}
}

StartVoteKick( badplayer )
{
	level endon( "voting_ended" );
	level endon( "end_game" );
	
	level thread StartVoteKickTimeLimit( badplayer );
	level thread KickIfVotesAreEnough( badplayer );
	
	level.votesneeded = ceil( level.numberOfPlayers / 2 );
	level.votestokick = 0;
	
	foreach( player in level.players )
	{
		player thread votekickText();
		if( player.name == badplayer.name )
		{
			player freezeControls( true );
			player.VoteKickTopString setText( "^1Vote Kicking " + badplayer.name );
			player.VoteKickBottomString setText( "^1( " + level.votestokick + " / " + level.votesneeded + " ) ^7votes needed!" );
			player.VoteKickInfoString setText( "The lobby is vote kicking you please wait" );
		}
		else
		{
			player thread VotingButtonMonitor( badplayer );
			player.VoteKickTopString setText( "^1Vote Kicking " + badplayer.name );
			player.VoteKickBottomString setText( "^1( " + level.votestokick + " / " + level.votesneeded + " ) ^7votes needed!" );
			player.VoteKickInfoString setText( "^5Prone [{+actionslot 1}] ^1Vote to Kick\n^5Prone [{+actionslot 2}] ^2Vote to Stay" );
		}
	}
}

VotingButtonMonitor( badplayer )
{
	self endon( "disconnect" );
	level endon( "voting_ended" );
	level endon( "end_game" );
	
	for( ;; )
	{
		if( self getStance() == "prone" && self actionslotonebuttonpressed() && !isDefined( self.menu.open ) && !isDefined( self.voted ) )
		{
			self.voted = true;
			level.votestokick += 1;
			level notify( "update_vote_text" );
			self iprintln("^1You voted for ^5"+badplayer.name+" to get kicked!" );
			self.VoteKickInfoString destroy();
		}
		if( self getStance() == "prone" && self actionslottwobuttonpressed() && !isDefined( self.menu.open ) && !isDefined( self.voted ) )
		{
			self.voted = true;
			self iprintln( "^2You voted for ^5"+badplayer.name+" to stay!" );
			self.VoteKickInfoString destroy();
		}
		wait 0.05;
	}
}

KickIfVotesAreEnough( badplayer )
{
	level endon( "voting_ended" );
	level endon( "end_game" );
	
	for( ;; )
	{
		if( level.votestokick >= level.votesneeded )
		{
			foreach( player in level.players )
			{
				player iprintln( "^5Vote Passed! ^1" + badplayer.name + " got Kicked!" );
				player.voted = undefined;
				player.checkingToVote = undefined;
			}
			setPlayerDvar( badplayer, "banned", true ); //this dvar is sticky, and will "ban" the player until
													  //the server is reset
			kick( badplayer getentitynumber() );
			level.votestokick = undefined;
			level.voting = undefined;
			level notify( "voting_ended" );
		}
		wait 0.05;
	}
}

StartVoteKickTimeLimit( badplayer )
{
	level endon( "voting_ended" );
	level endon( "end_game" );
	
	level thread updateText();
	level thread removeText();
	level.votesneeded = ceil( level.numberOfPlayers / 2 );
	level.votestokick = 0;
	wait 15;
	if( level.votestokick < level.votesneeded )
	{
		foreach( player in level.players )
		{
			player.voted = undefined;
			player.checkingToVote = undefined;
			if( player.name == badplayer.name )
			{
				player iprintln( "^1Not Enough votes to kick you!" );
			}
			else
			{
				player iprintln("^1Not Enough Votes to Kick ^5" + badplayer.name + "!");
			}
		}
	}
	level.votestokick = undefined;
	level.voting = undefined;
	level notify( "voting_ended" );
}

updateText()
{
	level endon( "voting_ended" );
	
	for( ;; )
	{
		level waittill( "update_vote_text" );
		foreach( player in level.players )
		{
			player.VoteKickBottomString setText( "^1( " + level.votestokick + " / " + level.votesneeded + " ) ^7votes needed!" );
		}
	}
}

removeText()
{
	for(;;)
	{
		level waittill( "voting_ended" );
		foreach( player in level.players )
		{
			player.VoteKickTopString destroy();
			player.VoteKickBottomString destroy();
			player.VoteKickInfoString destroy();
		}
	}
}

votekickText()
{	
	self.VoteKickTopString = self createFontString( "objective", 1.2 );
	self.VoteKickTopString setPoint( "CENTER", "CENTER", -345, -100 );
	self.VoteKickBottomString = self createFontString( "objective", 1.2 );
	self.VoteKickBottomString setPoint( "CENTER", "CENTER", -345, -85 );
	self.VoteKickInfoString = self createFontString( "objective", 1 );
	self.VoteKickInfoString setPoint( "CENTER", "CENTER", -345, -70 );
}

recountPlayers()
{
	level.numberOfBots = 0;
	level.numberOfPlayers = 0;
	foreach( player in level.players )
	{
		if( isDefined( player.pers[ "isBot" ] ) && player.pers[ "isBot" ] )
		{
			level.numberOfBots += 1;
		}
		else
		{
			level.numberOfPlayers += 1;
		}
	}
}

setPlayerDvar( player, dvar, value ) 
{
    thedvar = player getXUID() + "_" + dvar;
    setDvar( thedvar, value );
}

getPlayerDvar( player, dvar ) 
{
    thedvar = player getXUID() + "_" + dvar;
    
    return getDvar( thedvar );
}