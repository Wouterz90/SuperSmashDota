// Based on Noya's 1v5
"use strict";
var debugging = 0
//--------------------------------------------------------------------------------------------------
// CUSTOM HOST PANEL
//--------------------------------------------------------------------------------------------------
var IsHost = false;

//$("#only_mid").checked = true;
//$("#disable_neutrals").checked = false;
//$("#tier2").checked = true;
//var gold = "3125"

//$.Msg($.GetContextPanel().FindChild("TeamSelectContainer"))
var tpanel = $.GetContextPanel().FindChild("TeamSelectContainer")    
tpanel.FindChild("TeamsList").style.visibility = "collapse";
var temppanel = tpanel.FindChild("GameAndPlayersRoot")
temppanel.FindChild("GameInfoPanel").style.opacity = 1;
temppanel.FindChild("UnassignedPlayerPanel").style.opacity = 1;



//Game.SetTeamSelectionLocked( true )

var max_level = 10;
var min_level = 0;
function ValueChange(name, amount)
{
	if(debugging >= 1) {$.Msg("settings ValueChange" )}
    if (!IsHost) return

    var panel = $("#"+name);
    if (panel !== null){
        var current_level = parseInt(panel.text)
        var new_level = current_level + parseInt(amount)
        if (new_level <= max_level && new_level >= min_level)
            panel.text = new_level
        else
            if (new_level < min_level)
                panel.text = min_level
            else
                panel.text = max_level
    }

    GameEvents.SendCustomGameEventToServer("setting_change", {setting: name, value: panel.text});

}



function SelectRadioGameMode(option) {
	if(debugging >= 1) {$.Msg("settings SelectRadioGameMode",option )}
    var currentRadioOption = '1'
    var radios = {}
	radios['1'] = $("#FFA")
    radios['2'] = $("#2v2")

    if (!IsHost)
    {
        for (var i in radios)
        {
            var panel = radios[i]
            panel.checked = i == CustomNetTables.GetTableValue("settings", "Format").value
        }
    }
    else
    {   
        currentRadioOption = option
        GameEvents.SendCustomGameEventToServer("setting_change", {setting: "Format", value: option}); 
    }
}
function SelectRadioHeroSelection(option) {
if(debugging >= 1) {$.Msg("settings SelectRadioHeroSelection",option)}
    var currentRadioOption = '1'
    var radios = {}
	radios['1'] = $("#Normal")
    radios['2'] = $("#Random")

    if (!IsHost)
    {
        for (var i in radios)
        {
            var panel = radios[i]
            panel.checked = i == CustomNetTables.GetTableValue("settings", "HeroSelection").value
        }
    }
    else
    {   
        currentRadioOption = option
        GameEvents.SendCustomGameEventToServer("setting_change", {setting: "HeroSelection", value: option}); 
    }
}
function SelectRadioMapSelection(option) {
	if(debugging >= 1) {$.Msg("settings SelectRadioMapSelection") }
    var currentRadioOption = '1'
    var radios = {}
    radios['1'] = $("#RandomMap")
    radios['2'] = $("#LoserPiks")
    radios['3'] = $("#WinnerPicks")

    if (!IsHost)
    {
        for (var i in radios)
        {
            var panel = radios[i]
            panel.checked = i == currentRadioOption
        }
    }
    else
    {
        currentRadioOption = option
        GameEvents.SendCustomGameEventToServer("setting_change", {setting: "MapSelection", value: option}); 
    }
}

function Toggle(setting) {
    //if (!IsHost)
    //    $("#"+setting).checked = !$("#"+setting).checked;
    //else    
    //    GameEvents.SendCustomGameEventToServer("setting_change", {setting: setting, value: $("#"+setting).checked}); 
}

var number_settings = ["nAmountOfRounds","nStartingLifes"]
var bool_settings = ["duplicate_rounds","duplicate_player"]
var radios = {}
radios['1'] = $("#RandomMap")
radios['2'] = $("#LoserPiks")
radios['3'] = $("#WinnerPicks")
	
function UpdateSettings() {
	if(debugging >= 1) {$.Msg("settings UpdateSettings" )}
    if (!IsHost)
    	{
        //$.Msg("Host Changed Settings: ", CustomNetTables.GetAllTableValues("settings"))
        for (var k of number_settings)
        {
            $("#"+k).text = CustomNetTables.GetTableValue("settings", k).value
        }
        
        //bools
        //for (var k of bool_settings)
        //{
        //    $("#"+k).checked = CustomNetTables.GetTableValue("settings", k).value == 1;
        //}
		
		//HeroSelection
        var currentRadioOption = CustomNetTables.GetTableValue("settings", "HeroSelection").value
		var radios = {}
		radios['1'] = $("#Pick")
		radios['2'] = $("#Random")
		
        for (var i in radios)
        {
            var panel = radios[i]
            panel.checked = i == currentRadioOption
        }
		
		//GameMode
        var currentRadioOption = CustomNetTables.GetTableValue("settings", "Format").value
		var radios = {}
		radios['1'] = $("#FFA")
		radios['2'] = $("#2v2")
		
        for (var i in radios)
        {
            var panel = radios[i]
            panel.checked = i == currentRadioOption
        }
    }
}

//--------------------------------------------------------------------------------------------------
// Check to see if the local player has host privileges and set the 'player_has_host_privileges' on
// the root panel if so, this allows buttons to only be displayed for the host.
//--------------------------------------------------------------------------------------------------
function CheckForHostPrivileges()
{
	if(debugging >= 2) {$.Msg("settings CheckForHostPrivileges")}	
	if (Game.GetState() !== DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)
		return
	if (Game.GetState() == DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP)
	{
		var playerInfo = Game.GetLocalPlayerInfo();
		if ( !playerInfo )
			return;

		// Set the "player_has_host_privileges" class on the panel, this can be used 
		// to have some sub-panels on display or be enabled for the host player.
		IsHost = playerInfo.player_has_host_privileges;
		$.GetContextPanel().SetHasClass( "player_has_host_privileges", IsHost );

		// Update the Host name
		var playerIDs = Game.GetAllPlayerIDs()
		for (var i = 0; i < playerIDs.length; i++) {
			var pInfo = Game.GetPlayerInfo( i );
			if ( pInfo && pInfo.player_has_host_privileges){
				var HostName = Players.GetPlayerName( i )
				$('#Host').text = "HOST: "+HostName
			}
		}
		
	}
}	

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
var hostCheck
(function()
{   
    hostCheck = $.Schedule(0.1, function(){CheckForHostPrivileges();})
    CustomNetTables.SubscribeNetTableListener("settings", UpdateSettings)
})();
