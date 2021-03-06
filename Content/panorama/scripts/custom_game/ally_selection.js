"use strict";
var debugging = 1
var colorPlayer1 = "red"
var colorPlayer2 = "blue"
var colorPlayer3 = "green"
var colorPlayer4 = "yellow"

// Check if the Format is 2v2 or free for all.
function BuildAllySelectionScreen()
{
    if(debugging >= 1) {$.Msg("Ally_Selection BuildAllySelectionScreen" )}
    //$.GetContextPanel().GetParent().GetParent().FindChildTraverse("Hero_Selection_HeroBox").visible  = false
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible  = false 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").visibility = "visible"
    // Create panels for each player, refuse selfpicking send an event about the choice only if 2 players chose each other they certainly get matched together
    var playerIDs = Game.GetAllPlayerIDs()
    
    for (var i = 0; i < playerIDs.length; i++) 
    {
        var playerInfo = Game.GetPlayerInfo(i);
        var stringName = "Player".concat((i+1).toString()).concat("_SteamName")
        var stringAvatar = "Player".concat((i+1).toString()).concat("_SteamAvatar")

        
        var playerName = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(stringName).FindChild("steamname");	
        var playerAvatarPanel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(stringAvatar).FindChild("AvatarImageProfile");
        playerName.text =  playerInfo.player_name;
        playerAvatarPanel.steamid = playerInfo.player_steamid;

    }
}

function OnRequestAllyPlayer1()
{   
	if(debugging >= 1) {$.Msg("Ally_Selection OnRequestAllyPlayer1" )}
    if (Players.GetLocalPlayer() != 0   )
    {
        GameEvents.SendCustomGameEventToServer("ally_selection", {"requested_ally": 0})
    }
}
function OnRequestAllyPlayer2()
{
	if(debugging >= 1) {$.Msg("Ally_Selection OnRequestAllyPlayer2") }
    if (Players.GetLocalPlayer() != 1)
    {
        GameEvents.SendCustomGameEventToServer("ally_selection", {"requested_ally": 1})
    }   
}
function OnRequestAllyPlayer3()
{
	if(debugging >= 1) {$.Msg("Ally_Selection OnRequestAllyPlayer3") }
    if (Players.GetLocalPlayer() != 2)
    {
        GameEvents.SendCustomGameEventToServer("ally_selection", {"requested_ally": 2})
    }
}
function OnRequestAllyPlayer4()
{
	if(debugging >= 1) {$.Msg("Ally_Selection OnRequestAllyPlayer4") }
    if (Players.GetLocalPlayer() != 3)
    {
        GameEvents.SendCustomGameEventToServer("ally_selection", {"requested_ally": 3})
    }
}

function ColorPlayerBox(ids)
{   
	if(debugging >= 1) {$.Msg("Ally_Selection ColorPlayerBox") }
    var color = ""
    if (ids.requested == 0) 
    {   
        color = colorPlayer1
    }
    else if (ids.requested == 1) 
    {   
        color = colorPlayer2
    }
    else if (ids.requested == 2) 
    {   
        color = colorPlayer3
    }
    else if (ids.requested == 3) 
    {   
        color = colorPlayer4
    }
    var colorString = "0px 0px 50px ".concat(color)
    if (ids.requesting == 0) 
    {   
        $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Player1").style.boxShadow = colorString
    }
    else if (ids.requesting == 1) 
    {   
        $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Player2").style.boxShadow = colorString
    }
    else if (ids.requesting == 2) 
    {   
        $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Player3").style.boxShadow = colorString
    }
    else if (ids.requesting == 3) 
    {   
        $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Player4").style.boxShadow = colorString
    }
    
}
    
function ShowTeams()
{
	if(debugging >= 1) {$.Msg("Ally_Selection ShowTeams") }
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally_Selection_Header").text = "The teams are:"
    // Mark the players for team A red and team B blue
    // Player one is always on team A
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Player1").style.backgroundColor = colorPlayer1
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Player1").style.boxShadow = "none"
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("AllyPlayer1").style.visibility = "collapse"
    
    // The other players are determined here
    var string = "Player".concat(CustomNetTables.GetTableValue( "settings", "A1").value+1)
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.backgroundColor = colorPlayer1
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.boxShadow = "none"
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally".concat(string)).style.visibility = "collapse"

    var string = "Player".concat(CustomNetTables.GetTableValue( "settings", "B0").value+1)
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.backgroundColor = colorPlayer2
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.boxShadow = "none"
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally".concat(string)).style.visibility = "collapse"
    
    var string = "Player".concat(CustomNetTables.GetTableValue( "settings", "B1").value+1)
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.backgroundColor = colorPlayer2
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse(string).style.boxShadow = "none"
    $.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally".concat(string)).style.visibility = "collapse"
}


function KillAllySelectionScreen()
{
	if(debugging >= 1) {$.Msg("ally_selection KillAllySelectionScreen")}
	if ($.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main"))
	{
		if(debugging >= 1) {$.Msg("ally_selection KillAllySelectionScreen killed")}
		$.Msg($.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally_Selection_X").GetParent().GetParent())
		$.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally_Selection_X").GetParent().GetParent().RemoveAndDeleteChildren()
		
	}
    //$.GetContextPanel().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").GetParent().style.visibility = "collapse"	
}
(function()
{  
    BuildAllySelectionScreen()
    GameEvents.Subscribe( "confirm_allies", ColorPlayerBox);
    GameEvents.Subscribe( "show_teams", ShowTeams);
    GameEvents.Subscribe( "pick_heroes", KillAllySelectionScreen);
	GameEvents.Subscribe( "kill_ally_selection_screen", KillAllySelectionScreen);
})();
