teamwageroutcomenotify( winner, isroundend, endreasontext )
{
	self endon( "disconnect" );
	self notify( "reset_outcome" );
	team = self.pers[ "team" ];
	if ( !isDefined( team ) || !isDefined( level.teams[ team ] ) )
	{
		team = "allies";
	}
	wait 0.05;
	while ( self.doingnotify )
	{
		wait 0.05;
	}
	self endon( "reset_outcome" );
	headerfont = "extrabig";
	font = "objective";
	if ( self issplitscreen() )
	{
		titlesize = 2;
		textsize = 1.5;
		iconsize = 30;
		spacing = 10;
	}
	else
	{
		titlesize = 3;
		textsize = 2;
		iconsize = 70;
		spacing = 15;
	}
	halftime = 0;
	if ( isDefined( level.sidebet ) && level.sidebet )
	{
		halftime = 1;
	}
	duration = 60000;
	outcometitle = createfontstring( headerfont, titlesize );
	outcometitle setpoint( "TOP", undefined, 0, spacing );
	outcometitle.glowalpha = 1;
	outcometitle.hidewheninmenu = 0;
	outcometitle.archived = 0;
	outcometitle.immunetodemogamehudsettings = 1;
	outcometitle.immunetodemofreecamera = 1;
	outcometext = createfontstring( font, 2 );
	outcometext setparent( outcometitle );
	outcometext setpoint( "TOP", "BOTTOM", 0, 0 );
	outcometext.glowalpha = 1;
	outcometext.hidewheninmenu = 0;
	outcometext.archived = 0;
	outcometext.immunetodemogamehudsettings = 1;
	outcometext.immunetodemofreecamera = 1;
	if ( winner == "tie" )
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_draw" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "draw" ] );
		}
		outcometitle.color = ( 1, 0.5, 1 );
		winner = "allies";
	}
	else if ( winner == "overtime" )
	{
		outcometitle settext( game[ "strings" ][ "overtime" ] );
		outcometitle.color = ( 1, 0.5, 1 );
	}
	else if ( isDefined( self.pers[ "team" ] ) && winner == team )
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_win" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "victory" ] );
		}
		outcometitle.color = ( 1, 0.5, 1 );
	}
	else
	{
		if ( isroundend )
		{
			outcometitle settext( game[ "strings" ][ "round_loss" ] );
		}
		else
		{
			outcometitle settext( game[ "strings" ][ "defeat" ] );
		}
		outcometitle.color = ( 1, 0.5, 1 );
	}
	if ( !isDefined( level.dontshowendreason ) || !level.dontshowendreason )
	{
		outcometext settext( endreasontext );
	}
	outcometitle setpulsefx( 100, duration, 1000 );
	outcometext setpulsefx( 100, duration, 1000 );
	teamicons = [];
	teamicons[ team ] = createicon( game[ "icons" ][ team ], iconsize, iconsize );
	teamicons[ team ] setparent( outcometext );
	teamicons[ team ] setpoint( "TOP", "BOTTOM", -60, spacing );
	teamicons[ team ].hidewheninmenu = 0;
	teamicons[ team ].archived = 0;
	teamicons[ team ].alpha = 0;
	teamicons[ team ] fadeovertime( 0.5 );
	teamicons[ team ].alpha = 1;
	teamicons[ team ].immunetodemogamehudsettings = 1;
	teamicons[ team ].immunetodemofreecamera = 1;
	_a1269 = level.teams;
	_k1269 = getFirstArrayKey( _a1269 );
	while ( isDefined( _k1269 ) )
	{
		enemyteam = _a1269[ _k1269 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamicons[ enemyteam ] = createicon( game[ "icons" ][ enemyteam ], iconsize, iconsize );
			teamicons[ enemyteam ] setparent( outcometext );
			teamicons[ enemyteam ] setpoint( "TOP", "BOTTOM", 60, spacing );
			teamicons[ enemyteam ].hidewheninmenu = 0;
			teamicons[ enemyteam ].archived = 0;
			teamicons[ enemyteam ].alpha = 0;
			teamicons[ enemyteam ] fadeovertime( 0.5 );
			teamicons[ enemyteam ].alpha = 1;
			teamicons[ enemyteam ].immunetodemogamehudsettings = 1;
			teamicons[ enemyteam ].immunetodemofreecamera = 1;
		}
		_k1269 = getNextArrayKey( _a1269, _k1269 );
	}
	teamscores = [];
	teamscores[ team ] = createfontstring( font, titlesize );
	teamscores[ team ] setparent( teamicons[ team ] );
	teamscores[ team ] setpoint( "TOP", "BOTTOM", 0, spacing );
	teamscores[ team ].glowalpha = 1;
	teamscores[ team ] setvalue( getteamscore( team ) );
	teamscores[ team ].hidewheninmenu = 0;
	teamscores[ team ].archived = 0;
	teamscores[ team ].immunetodemogamehudsettings = 1;
	teamscores[ team ].immunetodemofreecamera = 1;
	teamscores[ team ] setpulsefx( 100, duration, 1000 );
	_a1299 = level.teams;
	_k1299 = getFirstArrayKey( _a1299 );
	while ( isDefined( _k1299 ) )
	{
		enemyteam = _a1299[ _k1299 ];
		if ( team == enemyteam )
		{
		}
		else
		{
			teamscores[ enemyteam ] = createfontstring( font, titlesize );
			teamscores[ enemyteam ] setparent( teamicons[ enemyteam ] );
			teamscores[ enemyteam ] setpoint( "TOP", "BOTTOM", 0, spacing );
			teamscores[ enemyteam ].glowalpha = 1;
			teamscores[ enemyteam ] setvalue( getteamscore( enemyteam ) );
			teamscores[ enemyteam ].hidewheninmenu = 0;
			teamscores[ enemyteam ].archived = 0;
			teamscores[ enemyteam ].immunetodemogamehudsettings = 1;
			teamscores[ enemyteam ].immunetodemofreecamera = 1;
			teamscores[ enemyteam ] setpulsefx( 100, duration, 1000 );
		}
		_k1299 = getNextArrayKey( _a1299, _k1299 );
	}
	matchbonus = undefined;
	sidebetwinnings = undefined;
	if ( !isroundend && !halftime && isDefined( self.wagerwinnings ) )
	{
		matchbonus = createfontstring( font, 2 );
		matchbonus setparent( outcometext );
		matchbonus setpoint( "TOP", "BOTTOM", 0, iconsize + ( spacing * 3 ) + teamscores[ team ].height );
		matchbonus.glowalpha = 1;
		matchbonus.hidewheninmenu = 0;
		matchbonus.archived = 0;
		matchbonus.immunetodemogamehudsettings = 1;
		matchbonus.immunetodemofreecamera = 1;
		matchbonus.label = game[ "strings" ][ "wager_winnings" ];
		matchbonus setvalue( self.wagerwinnings );
		if ( isDefined( game[ "side_bets" ] ) && game[ "side_bets" ] )
		{
			sidebetwinnings = createfontstring( font, 2 );
			sidebetwinnings setparent( matchbonus );
			sidebetwinnings setpoint( "TOP", "BOTTOM", 0, spacing );
			sidebetwinnings.glowalpha = 1;
			sidebetwinnings.hidewheninmenu = 0;
			sidebetwinnings.archived = 0;
			sidebetwinnings.immunetodemogamehudsettings = 1;
			sidebetwinnings.immunetodemofreecamera = 1;
			sidebetwinnings.label = game[ "strings" ][ "wager_sidebet_winnings" ];
			sidebetwinnings setvalue( self.pers[ "wager_sideBetWinnings" ] );
		}
	}
	self thread resetoutcomenotify( teamicons, teamscores, outcometitle, outcometext, matchbonus, sidebetwinnings );
}
