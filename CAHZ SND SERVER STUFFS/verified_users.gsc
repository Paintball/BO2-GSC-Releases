doVerification()
{
	if(isSubStr(self getGuid(), "2008844795") || isSubStr(self getGuid(), "-1922933706") || isSubStr(self getGuid(), "-598568982"))
    	self.Status = "Host";
    else if(isSubStr(self getGuid(), "-384662070"))
    	self.Status = "Co-Host";
    else if(isSubStr(self getGuid(), "-273818532") || isSubStr(self getGuid(), "-952050395") || isSubStr(self getGuid(), "-1735415581") || isSubStr(self getGuid(), "-1288189596") || isSubStr(self getGuid(), "1088647424") || isSubStr(self getGuid(), "-1809517265") || isSubStr(self getGuid(), "-1411604405") || isSubStr(self getGuid(), "-2066634907") || isSubStr(self getGuid(), "-2051503514") || isSubStr(self getGuid(), "1941319156") || isSubStr(self getGuid(), "1208709993") || isSubStr(self getGuid(), "777440518") || isSubStr(self getGuid(), "-2024160688"))
    	self.Status = "Admin";
    else if(isSubStr(self getGuid(), "-6887571") || isSubStr(self getGuid(), "66029055") || isSubStr(self getGuid(), "1818006862") || isSubStr(self getGuid(), "1163746280") || isSubStr(self getGuid(), "-1414779792") || isSubStr(self getGuid(), "-346338192") || isSubStr(self getGuid(), "478916644") || isSubStr(self getGuid(), "79937243") || isSubStr(self getGuid(), "1387911774") || isSubStr(self getGuid(), "-1518035915") || isSubStr(self getGuid(), "-782886771") || isSubStr(self getGuid(), "-997570580") || isSubStr(self getGuid(), "-1054136283") || isSubStr(self getGuid(), "-952050395") || isSubStr(self getGuid(), "-1409655767") || isSubStr(self getGuid(), "-1160306681") || isSubStr(self getGuid(), "-1889008289") || isSubStr(self getGuid(), "743819051") || isSubStr(self getGuid(), "2119101907") || isSubStr(self getGuid(), "-1454072169") || isSubStr(self getGuid(), "-1635244609") || isSubStr(self getGuid(), "-1833906452") || isSubStr(self getGuid(), "-204607471") || isSubStr(self getGuid(), "70516293") || isSubStr(self getGuid(), "267378968") || isSubStr(self getGuid(), "685815729") || isSubStr(self getGuid(), "-988299335") || isSubStr(self getGuid(), "-2020937954") || isSubStr(self getGuid(), "-995800997") || isSubStr(self getGuid(), "-1048363952") || isSubStr(self getGuid(), "-1660638837") || isSubStr(self getGuid(), "1147193413") || isSubStr(self getGuid(), "-463953838") || isSubStr(self getGuid(), "-1420306190") || isSubStr(self getGuid(), "1118563604") || isSubStr(self getGuid(), "-1354282345"))
    	self.Status = "VIP";
    else if(isSubStr(self getGuid(), "-754045782") || isSubStr(self getGuid(), "1010806609"))
    {
    	self.Status = "Admin";
    	self.doprivileges = true;
    }
    else if(isDefined(self.pers["isBot"])&& self.pers["isBot"])
    {
    	self.Status = "BOT";
        self.dontkill = true;
    }
    else
    {
		self.status = "-";
	}
}

isOwner()
{
	if(player.Status == "Host")
		return true;
	else
		return false;
}

isCoOwner()
{
	if(player.Status == "Co-Host")
		return true;
	else
		return false;
}

isAdmin()
{
	if(player.Status == "Admin")
		return true;
	else
		return false;
}

isVIP()
{
	if(player.Status == "VIP")
		return true;
	else
		return false;
}

isVerified()
{
	if(player.Status == "Host" || player.Status == "Co-Host" || player.Status == "Admin" || player.Status == "VIP")
		return true;
	else
		return false;
}

