gameended(){
	level waittill("game_ended");
		if(level.maptovote["vote"][0] > level.maptovote["vote"][1] && level.maptovote["vote"][0] > level.maptovote["vote"][2]){
			setmap(0);
		}else if(level.maptovote["vote"][1] > level.maptovote["vote"][0] && level.maptovote["vote"][1] > level.maptovote["vote"][2]){
			setmap(1);
		}else if(level.maptovote["vote"][2] > level.maptovote["vote"][0] && level.maptovote["vote"][2] > level.maptovote["vote"][1]){
			setmap(2);
		}else if(level.maptovote["vote"][0] > level.maptovote["vote"][1] && level.maptovote["vote"][0] == level.maptovote["vote"][2]){
			x = randomintrange(0,1);
			if(x == 0)
				setmap(0);
			else
				setmap(2);
		}else if(level.maptovote["vote"][0] > level.maptovote["vote"][2] && level.maptovote["vote"][0] == level.maptovote["vote"][1]){
			setmap(randomintrange(0,1));
		}else if(level.maptovote["vote"][1] > level.maptovote["vote"][0] && level.maptovote["vote"][1] == level.maptovote["vote"][2]){
			setmap(randomintrange(1,2));	
		}else{
			setmap(3);
		}
}
setmap( index ){		
	setdvar( "sv_maprotation", "map " + level.maptovote["name"][index] );
	wait 5;
	printToAll( "^5Next Map: ^7"+level.maptovote["map"][index] );
}
printToAll(str){
	foreach(player in level.players){
		player iprintln(str);
	}
}
mapvote(){
	 level.maptovote["map"] = [];
	 level.maptovote["name"] = [];
	 level.maptovote["image"] = [];
	 level.maptovote["vote"] = [];
	 
	 level.maptovote["vote"][0] = 0;
	 level.maptovote["vote"][1] = 0;
	 level.maptovote["vote"][2] = 0;
	 
	 randommapbyindex(0);
	 randommapbyindex(1);
	 randommapbyindex(2);
}

randommapbyindex( index ){
	level endon("mapnotvalid");
	if(index == 0){
		i = randomintrange( 0, 11 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname")){
			randommapbyindex(index);
			level notify("mapnotvalid");
		}
	}else if(index == 1){
		i = randomintrange( 11, 20 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname") && level.maptovote["name"][index] == level.maptovote["name"][0]){
			randommapbyindex(index);
			level notify("mapnotvalid");
		}
	}else if(index == 2){
		i = randomintrange( 20, 30 );
		mapdata(i, index);
		if(level.maptovote["name"][index] == getDvar("mapname") && level.maptovote["name"][index] == level.maptovote["name"][0] && level.maptovote["name"][index] == level.maptovote["name"][1]){
			randommapbyindex(index);
			level notify("mapnotvalid");
		}
	}
	
	precacheshader( level.maptovote["image"][index] );
}

mapdata( i, index ){
	
	switch( i ){
		//Base MAP
		case 0:
		level.maptovote["map"][index] = "Aftermath";
	 	level.maptovote["name"][index] = "mp_la";
	    level.maptovote["image"][index] = "loadscreen_mp_la";
		break;
		case 1:
		level.maptovote["map"][index] = "Cargo";
	 	level.maptovote["name"][index] = "mp_dockside";
	    level.maptovote["image"][index] = "loadscreen_mp_dockside";
		break;
		case 2:
		level.maptovote["map"][index] = "Carrier";
	 	level.maptovote["name"][index] = "mp_carrier";
	    level.maptovote["image"][index] = "loadscreen_mp_carrier";
		break;
		case 3:
		level.maptovote["map"][index] = "Drone";
	 	level.maptovote["name"][index] = "mp_drone";
	    level.maptovote["image"][index] = "loadscreen_mp_drone";
		break;
		case 4:
		level.maptovote["map"][index] = "Express";
	 	level.maptovote["name"][index] = "mp_express";
	    level.maptovote["image"][index] = "loadscreen_mp_express";
		break;
		case 5:
		level.maptovote["map"][index] = "Hijacked";
	 	level.maptovote["name"][index] = "mp_Hijacked";
	    level.maptovote["image"][index] = "loadscreen_mp_hijacked";
		break;
		case 6:
		level.maptovote["map"][index] = "Meltdown";
	 	level.maptovote["name"][index] = "mp_Meltdown";
	    level.maptovote["image"][index] = "loadscreen_mp_meltdown";
		case 7:
		level.maptovote["map"][index] = "Overflow";
	 	level.maptovote["name"][index] = "mp_Overflow";
	    level.maptovote["image"][index] = "loadscreen_mp_overflow";
		break;
		case 8:
		level.maptovote["map"][index] = "Plaza";
	 	level.maptovote["name"][index] = "mp_nightclub";
	    level.maptovote["image"][index] = "loadscreen_mp_nightclub";
		break;
		case 9:
		level.maptovote["map"][index] = "Raid";
	 	level.maptovote["name"][index] = "mp_raid";
	    level.maptovote["image"][index] = "loadscreen_mp_raid";
		break;
		case 10:
		level.maptovote["map"][index] = "Slums";
	 	level.maptovote["name"][index] = "mp_Slums";
	    level.maptovote["image"][index] = "loadscreen_mp_Slums";
		break;
		case 11:
		level.maptovote["map"][index] = "Standoff";
	 	level.maptovote["name"][index] = "mp_village";
	    level.maptovote["image"][index] = "loadscreen_mp_village";
		break;
		case 12:
		level.maptovote["map"][index] = "Turbine";
	 	level.maptovote["name"][index] = "mp_Turbine";
	    level.maptovote["image"][index] = "loadscreen_mp_Turbine";
		break;
		case 13:
		level.maptovote["map"][index] = "Yemen";
	 	level.maptovote["name"][index] = "mp_socotra";
	    level.maptovote["image"][index] = "loadscreen_mp_socotra";
		break;
		//Bouns MAP
		case 14:
		level.maptovote["map"][index] = "Nuketown 2025";
	 	level.maptovote["name"][index] = "mp_nuketown_2020";
	    level.maptovote["image"][index] = "loadscreen_mp_nuketown_2020";
		break;
		//DLC MAP 1 Revolution
		case 15:
		level.maptovote["map"][index] = "Downhill";
	 	level.maptovote["name"][index] = "mp_downhill";
	    level.maptovote["image"][index] = "loadscreen_mp_downhill";
		break;
		case 16:
		level.maptovote["map"][index] = "Mirage";
	 	level.maptovote["name"][index] = "mp_Mirage";
	    level.maptovote["image"][index] = "loadscreen_mp_Mirage";
		break;
		case 17:
		level.maptovote["map"][index] = "Hydro";
	 	level.maptovote["name"][index] = "mp_Hydro";
	    level.maptovote["image"][index] = "loadscreen_mp_Hydro";
		break;
		case 18:
		level.maptovote["map"][index] = "Grind";
	 	level.maptovote["name"][index] = "mp_skate";
	    level.maptovote["image"][index] = "loadscreen_mp_skate";
		break;
		//DLC MAP 2 Uprising
		case 19:
		level.maptovote["map"][index] = "Encore";
	 	level.maptovote["name"][index] = "mp_concert";
	    level.maptovote["image"][index] = "loadscreen_mp_concert";
		break;
		case 20:
		level.maptovote["map"][index] = "Magma";
	 	level.maptovote["name"][index] = "mp_Magma";
	    level.maptovote["image"][index] = "loadscreen_mp_Magma";
		break;
		case 21:
		level.maptovote["map"][index] = "Vertigo";
	 	level.maptovote["name"][index] = "mp_Vertigo";
	    level.maptovote["image"][index] = "loadscreen_mp_Vertigo";
		break;
	    case 22:
		level.maptovote["map"][index] = "Studio";
	 	level.maptovote["name"][index] = "mp_Studio";
	    level.maptovote["image"][index] = "loadscreen_mp_Studio";
		break;
		//DLC MAP 3 Vengeance
		case 23:
		level.maptovote["map"][index] = "Uplink";
	 	level.maptovote["name"][index] = "mp_Uplink";
	    level.maptovote["image"][index] = "loadscreen_mp_Uplink";
		break;
		case 24:
		level.maptovote["map"][index] = "Detour";
	 	level.maptovote["name"][index] = "mp_bridge";
	    level.maptovote["image"][index] = "loadscreen_mp_bridge";
		break;
		case 25:
		level.maptovote["map"][index] = "Cove";
	 	level.maptovote["name"][index] = "mp_castaway";
	    level.maptovote["image"][index] = "loadscreen_mp_castaway";
		break;
		case 26:
		level.maptovote["map"][index] = "Rush";
	 	level.maptovote["name"][index] = "mp_paintball";
	    level.maptovote["image"][index] = "loadscreen_mp_paintball";
		break;
		//DLLC MAP 4 Apocalypse 
		case 27:
		level.maptovote["map"][index] = "Dig";
	 	level.maptovote["name"][index] = "mp_Dig";
	    level.maptovote["image"][index] = "loadscreen_mp_Dig";
		break;
		case 28:
		level.maptovote["map"][index] = "Frost";
	 	level.maptovote["name"][index] = "mp_frostbite";
	    level.maptovote["image"][index] = "loadscreen_mp_frostbite";
		break;
		case 29:
		level.maptovote["map"][index] = "Pod";
	 	level.maptovote["name"][index] = "mp_Pod";
	    level.maptovote["image"][index] = "loadscreen_mp_Pod";
		break;
		case 30:
		level.maptovote["map"][index] = "Takeoff";
	 	level.maptovote["name"][index] = "mp_Takeoff";
	    level.maptovote["image"][index] = "loadscreen_mp_Takeoff";
		break;
/*case def:
		level.maptovote["map"][index] = "";
	 	level.maptovote["name"][index] = "mp_";
	    level.maptovote["image"][index] = "loadscreen_mp_";
		break;*/
	}

}

selectmap()
{
	self freezeControlsallowlook(true);
	self thread buttonsmonitor();
	self.textMAP1 = self createFontString("objective", 1.75);
	self.textMAP1 setPoint("CENTER", "CENTER", -220, -75);
	self.textMAP2 = self createFontString("objective", 1.75);
	self.textMAP2 setPoint("CENTER", "CENTER", 0, -75);
	self.textMAP3 = self createFontString("objective", 1.75);
	self.textMAP3 setPoint("CENTER", "CENTER", 220, -75);
	self.buttons = self createFontString("objective", 1.5);
	self.buttons setPoint("CENTER", "CENTER", 0, -50);
	self.buttons setSafeText( "^5Aim/Shoot ^7 to switch map | [{+usereload}] ^7to select" );	
	baseText();
	self.map1 = self drawshader( level.maptovote["image"][0], -220, -10, 200, 125, ( 1, 1, 1 ), 100, 0 );
	self.map1 fadeovertime( 0.3 );
	self.map1.alpha = 0.65;
	self.map2 = self drawshader( level.maptovote["image"][1], 0, -10, 200, 125, ( 1, 1, 1 ), 100, 0 );
	self.map2 fadeovertime( 0.3 );
	self.map2.alpha = 0.65;
	self.map3 = self drawshader( level.maptovote["image"][2], 220, -10, 200, 125, ( 1, 1, 1 ), 100, 0 );
	self.map3 fadeovertime( 0.3 );
	self.map3.alpha = 0.65;
}

baseText(){
	self.textMAP1 setSafeText( level.maptovote["map"][0] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][0] );		
	self.textMAP2 setSafeText( level.maptovote["map"][1] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][1] );		
	self.textMAP3 setSafeText( level.maptovote["map"][2] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][2] );		
}

buttonsmonitor(){
	self endon("disconnect");
	self endon("closemapmenu");
	level endon("game_ended");	
	i = 0;
	wait 0.05;
	self.textMAP1 setSafeText( "^5<<^7"+ level.maptovote["map"][0] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][0] + "^5>>" );		
	for(;;){
		wait 0.05;
		if(self adsbuttonpressed()){
			if(i == 0){
				i = 2;
			}else i = i - 1;
			baseText();
			if(i == 0){
				self.textMAP1 setSafeText( "^5<<^7"+ level.maptovote["map"][0] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][0] + "^5>>" );		
			}else if(i == 1){
				self.textMAP2 setSafeText( "^5<<^7"+ level.maptovote["map"][1] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][1] + "^5>>" );		
			}else if(i == 2){
				self.textMAP3 setSafeText( "^5<<^7"+ level.maptovote["map"][2] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][2] + "^5>>" );		
			}
			wait 0.25;
		}
		if(self attackbuttonpressed()){
			if(i == 2){
				i = 0;
			}else i = i + 1;
			baseText();
			if(i == 0){
				self.textMAP1 setSafeText( "^5<<^7"+ level.maptovote["map"][0] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][0] + "^5>>" );		
			}else if(i == 1){
				self.textMAP2 setSafeText( "^5<<^7"+ level.maptovote["map"][1] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][1] + "^5>>" );		
			}else if(i == 2){
				self.textMAP3 setSafeText( "^5<<^7"+ level.maptovote["map"][2] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][2] + "^5>>" );		
			}
			wait 0.25;
		}
		
		if(self usebuttonpressed()){
			level.maptovote["vote"][i] = level.maptovote["vote"][i] + 1;
			if(i == 0){
				self.textMAP1 setSafeText( "^5<<^7"+ level.maptovote["map"][0] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][0] + "^5>>" );		
			}else if(i == 1){
				self.textMAP2 setSafeText( "^5<<^7"+ level.maptovote["map"][1] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][1] + "^5>>" );		
			}else if(i == 2){
				self.textMAP3 setSafeText( "^5<<^7"+ level.maptovote["map"][2] + " ^5|^7 Vote:^5 " + level.maptovote["vote"][2] + "^5>>" );		
			}
			wait 1;
			closemenumapmenu();
		}
	}
}
closemenumapmenu(){
self.textMAP1 DestroyElement();
self.textMAP2 DestroyElement();
self.textMAP3 DestroyElement();
self.buttons DestroyElement();
self.map1 DestroyElement();
self.map2 DestroyElement();
self.map3 DestroyElement();
self freezeControlsallowlook(false);
self.mapVote = true;
self notify("closemapmenu");
}

DestroyElement(){
    if (IsInArray(level.textelementtable, self))
        ArrayRemoveValue(level.textelementtable, self);
    if (IsDefined(self.elemtype)){
        self.frame Destroy();
        self.bar Destroy();
        self.barframe Destroy();
    }       
    self Destroy();
}

drawshader( shader, x, y, width, height, color, alpha, sort ){
	hud = newclienthudelem( self );
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	hud setparent( level.uiparent );
	hud setshader( shader, width, height );
	hud.x = x;
	hud.y = y;
	return hud;
}

