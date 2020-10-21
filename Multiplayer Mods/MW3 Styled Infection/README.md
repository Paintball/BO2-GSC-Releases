# MW3 STYLED INFECTED
## DIRECTIONS
- Compile _**tdm.gsc**_ as _**tdm.gsc**_ and place it in the directory _**maps/mp/gametypes/tdm.gsc**_

Customizable DVARS that can be used to edit the game settings
```
scr_scorestreaks 0 //0 = scorestreaks disabled, 1 = scorestreaks enabled
set infectedTimelimit 15 //timelimit in minutes (default 10)
set enableFirstInfectedLoadout 1 //first infected gets survivor loadout - 0 = disable, 1 = enable

//you can add as many guns as you choose, it will choose randomly from list created
//examples below
//to have a weapon not be used, change it to "none"

set survivorPrimary "hk416_mp+reflex+extclip,insas_mp+extclip+rf,pdw57_mp+silencer+extclip"
set survivorSecondary "fiveseven_mp+fmj,fnp45_mp+fmj"
set survivorTactical "flash_grenade_mp,willy_pete_mp"
set survivorGrenade "bouncingbetty_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp"
set enableScavenger 1 //0 = disable scavenger packs, 1 = enable

set infectedPrimary "knife_mp" //knife_mp is default infected weapon
set infectedSecondary "hatchet_mp" //hatchet_mp is the tomahawk :)
set enableTacInsert 1 //0 = disable tacinserts, 1 = enable

//dvars without comments//

scr_scorestreaks 0
set infectedTimelimit 15
set enableFirstInfectedLoadout 1

set survivorPrimary "hk416_mp+reflex+extclip,insas_mp+extclip+rf,pdw57_mp+silencer+extclip"
set survivorSecondary "fiveseven_mp+fmj,fnp45_mp+fmj"
set survivorTactical "flash_grenade_mp,willy_pete_mp"
set survivorGrenade "bouncingbetty_mp,sticky_grenade_mp,frag_grenade_mp,hatchet_mp"
set enableScavenger 1

set infectedPrimary "knife_mp"
set infectedSecondary "hatchet_mp"
set enableTacInsert 1
```
