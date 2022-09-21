<cfscript>
/* Include this file as a header in any samples to store your apikey in settings.apikey */
ini_file = ExpandPath("settings.ini");
if (NOT FileExists(ini_file)) {
	throw(
		message      = "Settings file settings.ini not found", 
		detail       = "To use the sample scripts, please see settings_sample.ini.  Rename it to settings.ini and update your code"
	
	);
}

try {
	settings["apikey"] = getProfileString(ini_file, "docraptor","apikey");
	
	if (settings.apikey EQ "") {
		throw("code is blank");
	}
}
catch (any e) {
	throw(
		message      = "'apikey' setting not defined in ini file", 
		detail       = "please see settings_sample.ini for the correct format"
	);
}


</cfscript>