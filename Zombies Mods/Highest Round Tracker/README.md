# HIGHEST ROUND TRACKER

## DIRECTIONS

###### ADDING TO YOUR _CLIENTIDS.GSC
- Copy the scripts and place them in your **_clientids.gsc** file
- Add **thread high_round_tracker();** into your **init()** function
- Add **player thread high_round_info();** into your **onPlayerConnect()** function
- Download @fed's t6-gsc-utils plugin and place the .dll file inside gameserver/t6r/data/plugins
https://github.com/fedddddd/t6-gsc-utils

Using these steps will allow the server to track the highest round achieved on the server, and the players who were in the lobby at the time.
All high round records will be recorded in .txt files inside gameserver/t6r/data/logs and they will be updated automatically.
