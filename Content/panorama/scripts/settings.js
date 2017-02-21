// Based on Noya's 1v5
"use strict";

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

var max_level = 8;
var min_level = 0;
function ValueChange(name, amount)
{
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
    var currentRadioOption = '1'
    var radios = {}
    radios['1'] = $("#Normal")
    radios['2'] = $("#Random")

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
        
        GameEvents.SendCustomGameEventToServer("setting_change", {setting: "Format", value: option}); 
    }
}
function SelectRadioHeroSelection(option) {
    var currentRadioOption = '1'
    var radios = {}
    radios['1'] = $("#FFA")
    radios['2'] = $("#2v2")

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
        GameEvents.SendCustomGameEventToServer("setting_change", {setting: "HeroSelection", value: option}); 
    }
}
function SelectRadioMapSelection(option) {
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

var number_settings = ["nAmountOfRounds","nStartingRounds"]
var bool_settings = ["duplicate_rounds","duplicate_player"]
function UpdateSettings() {
    if (!IsHost)
    {
        //$.Msg("Host Changed Settings: ", CustomNetTables.GetAllTableValues("settings"))

        //gold = CustomNetTables.GetTableValue("settings", "starting_gold").value
        for (var k of number_settings)
        {
            $("#"+k).text = CustomNetTables.GetTableValue("settings", k).value
        }
        
        //bools
        for (var k of bool_settings)
        {
            $("#"+k).checked = CustomNetTables.GetTableValue("settings", k).value == 1;
        }

        //radio FIX THIS
        currentRadioOption = CustomNetTables.GetTableValue("settings", "win_at_tier").value
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
    $.Schedule(0.1, CheckForHostPrivileges)
}

//--------------------------------------------------------------------------------------------------
// Entry point called when the team select panel is created
//--------------------------------------------------------------------------------------------------
(function()
{   
    CheckForHostPrivileges();
    CustomNetTables.SubscribeNetTableListener("settings", UpdateSettings)
})();
