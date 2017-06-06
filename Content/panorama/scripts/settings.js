
"use strict";
var debugging = 0

function SelectRadioGameMode(option) {
	if(debugging >= 1) {$.Msg("settings SelectRadioGameMode",option )}
    var currentRadioOption = '1'
    var radios = {}
	radios['1'] = $("#FFA")
    radios['2'] = $("#2v2")
    
    GameEvents.SendCustomGameEventToServer("setting_change", {setting: "Format", value: option}); 
}
function SelectRadioHeroSelection(option) {
if(debugging >= 1) {$.Msg("settings SelectRadioHeroSelection",option)}
    var currentRadioOption = '1'
    var radios = {}
	radios['1'] = $("#Normal")
    radios['2'] = $("#Random")

    GameEvents.SendCustomGameEventToServer("setting_change", {setting: "HeroSelection", value: option}); 
}
function SelectRadioMapSelection(option) {
	if(debugging >= 1) {$.Msg("settings SelectRadioMapSelection") }
    var currentRadioOption = '1'
    var radios = {}
    radios['1'] = $("#RandomMap")
    radios['2'] = $("#LoserPiks")
    radios['3'] = $("#WinnerPicks")

    GameEvents.SendCustomGameEventToServer("setting_change", {setting: "MapSelection", value: option}); 
}

function RequestStart()
{
	if(debugging >= 1) {$.Msg("settings RequestStart" )}
	// Lock the team selection so that no more team changes can be made
	GameEvents.SendCustomGameEventToServer("request_start", {}); 
}

function StartGame()
{
	if(debugging >= 1) {$.Msg("settings StartCounter" )}
	Game.EmitSound("Courier.Spawn")
	Game.SetRemainingSetupTime( 5 )
	Game.AutoAssignPlayersToTeams();
	Game.SetTeamSelectionLocked( true );
}


(function()
{  
    
	GameEvents.Subscribe( "start_game", StartGame);
})();


