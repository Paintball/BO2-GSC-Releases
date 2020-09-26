# HIGHEST ROUND TRACKER

## DIRECTIONS

###### ADDING TO YOUR _CLIENTIDS.GSC
- Copy the scripts and place them in your **_clientids.gsc** file
- Add **thread high_round_tracker();** into your **init()** function
- Add **player thread high_round_info();** into your **onPlayerConnect()** function
###### IF YOU NEED TO RESET YOUR SERVER AND WANT TO KEEP RECORDS
- Logs by default are kept in your game folder **/t6r/data/logs/games_zm.log**
- Open your log and check for any new records *(you can ctrl+f and search for "set by")*
- Add the record into your **dedicated_zm.cfg** file *(high round number & players)*
- When the server restarts, it will check the **dedicated_zm.cfg** file for any manually written records
###### EXAMPLES FOR ALL MAPS
```set BuriedHighRound 1
set BuriedPlayers "Player1, Player2"
set DieRiseHighRound 1
set DieRisePlayers "Player1, Player2"
set MotdHighRound 1
set MotdPlayers "Player1, Player2"
set OriginsHighRound 1
set OriginsPlayers "Player1, Player2"
set NuketownHighRound 1
set NuketownPlayers "Player1, Player2"
set TransitHighRound 1
set TransitPlayers "Player1, Player2"
set TownHighRound 1
set TownPlayers "Player1, Player2"
