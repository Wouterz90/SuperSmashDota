
"use strict";
var debugging = 1
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
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
function OnVote(nVote)
{
	if(debugging >= 1) {$.Msg("Settings OnVote", nVote )}
	GameEvents.SendCustomGameEventToServer("player_votes_endscreen", {vote : nVote})
	
}
function OnHoverVote(nVote)
{
	
	if (PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(),"endVote")) {return}
	if(debugging >= 1) {$.Msg("Settings OnHoverVote", nVote)}	
	for (var i = 1; i < 4; i++)	
	{
		if (i==nVote)
		{
			$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Vote".concat(i)).style.boxShadow = "green 0px 0px 60px 0px"
		}
		else
		{
			$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Vote".concat(i)).style.boxShadow = "black 0px 0px 60px 0px"
		}
	}
	
}
function OnHoverOutVote(nVote)
{
	
	if (PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(),"endVote") !== null) {return}
	if(debugging >= 1) {$.Msg("Settings OnHoverOutVote", nVote)}
		
	for (var i = 1; i < 4; i++)	
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Vote".concat(i)).style.boxShadow = "black 0px 0px 60px 0px"
	}
	
}
 
(function()
{  
    
	GameEvents.Subscribe( "start_game", StartGame);
})();


