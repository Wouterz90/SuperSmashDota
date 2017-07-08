"use strict";
var debugging = 0
var colorPlayer1 = "red"
var colorPlayer2 = "blue"
var colorPlayer3 = "green"
var colorPlayer4 = "yellow"
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var someonePicked = false
var LoadBarWidth = 350

function BuildHeroSelectionScreen()
{
	if(debugging >= 1) {$.Msg("hero_selection BuildHeroSelectionScreen") }
	// Make them all visible again
    var panel =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_HeroBox")
    panel.GetParent().GetParent().visible = true
	
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_HeroBox").GetParent().visible  = true 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible  = true 
	
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("puck")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("puck")).GetChild(0))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("puck")).RemoveAndDeleteChildren()
	}
    /*$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("rattletrap")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("rattletrap")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("rattletrap")).RemoveAndDeleteChildren()
	}*/
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("zuus")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("zuus")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("zuus")).RemoveAndDeleteChildren()
	}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tusk")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tusk")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tusk")).RemoveAndDeleteChildren()
	}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("earthshaker")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("earthshaker")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("earthshaker")).RemoveAndDeleteChildren()
	}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("mirana")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("mirana")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("mirana")).RemoveAndDeleteChildren()
	}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("lina")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("lina")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("lina")).RemoveAndDeleteChildren()
	}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tinker")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tinker")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tinker")).RemoveAndDeleteChildren()
	}
	/*$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("nyx_assassin")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("nyx_assassin")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("nyx_assassin")).RemoveAndDeleteChildren()
	}*/
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("axe")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("axe")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("axe")).RemoveAndDeleteChildren()
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("storm_spirit")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("storm_spirit")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("storm_spirit")).RemoveAndDeleteChildren()
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("magnataur")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("magnataur")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("magnataur")).RemoveAndDeleteChildren()
	}
	/*$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("batrider")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("batrider")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("batrider")).RemoveAndDeleteChildren()
	}*/
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("centaur")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("centaur")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("centaur")).RemoveAndDeleteChildren()
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("pudge")).style.opacity = 1
	if ($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("pudge")).FindChild("AvatarOverlay"))
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("pudge")).RemoveAndDeleteChildren()
	}
	 
	var table = PlayerTables.GetAllTableValues(Players.GetLocalPlayer().toString().concat("heroes"))
	for (var k in table)
	{
			
		
		var string = k.substr(14)
		
		string = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat(string)).style.opacity = 0.1
		
	}
	someonePicked = false
	LoadBarWidth = 400
	var panel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CountDownBarHS")
	panel.style.opacity = 1
	panel.style.width = (LoadBarWidth).toString().concat("px")
	
}


// Functions for selecting a hero
function selectedHero(heroName)
{
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname = "npc_dota_hero_".concat(heroName)
    // Set his abilities
    var string = heroName
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_top").abilityname = string.concat("_special_top")
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_side").abilityname = string.concat("_special_side")
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_mid").abilityname = string.concat("_special_mid")
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_bottom").abilityname = string.concat("_special_bottom")

    // Set the values for his ratings
    SetRatings(string)
    // Set the bio in the tooltip box
    OnSelectedHeroClicked()
}
function SetRatings(heroName)
{   
    // Import table
    var table = PlayerTables.GetTableValue("heroRatings", heroName.concat("Values"))
    for (var k in table)
    {
        if (table.hasOwnProperty(k)) 
        {
            var string = "RatingScore".concat(k)
            
            for (var i = 0; i < 3; i++) 
            {
                if (table[k] <= i)
                {
                    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(string.concat((i+1).toString())).visible = false
                }
                else 
                {
                    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(string.concat((i+1).toString())).visible = true
                }
            }
        }
    }
}


function OnSelectedHeroClicked()
{
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var string = "npc_dota_hero_".concat(hero)
    var tooltip = $.Localize(string.concat("_bio"))
    var tooltipbox = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TooltipBox").GetChild(0).text = tooltip
}

function OnSpecialTopClicked()
{
    // Get the hero that is currently highlighted
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var string = hero.concat("_special_top")
    var tooltip = $.Localize("AbilityTooltip_".concat(string))
    var tooltipbox = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TooltipBox").GetChild(0).text = tooltip
}
function OnSpecialMidClicked()
{
    // Get the hero that is currently highlighted
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var string = hero.concat("_special_mid")
    var tooltip = $.Localize("AbilityTooltip_".concat(string))
    var tooltipbox = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TooltipBox").GetChild(0).text = tooltip
}
function OnSpecialSideClicked()
{
    // Get the hero that is currently highlighted
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var string = hero.concat("_special_side")
    var tooltip = $.Localize("AbilityTooltip_".concat(string))
    var tooltipbox = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TooltipBox").GetChild(0).text = tooltip
}
function OnSpecialBottomClicked()
{
	
    // Get the hero that is currently highlighted
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var string = hero.concat("_special_bottom")
    var tooltip = $.Localize("AbilityTooltip_".concat(string))
    var tooltipbox = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("TooltipBox").GetChild(0).text = tooltip
}

function LockHeroAndReady()
{
	if(debugging >= 1) {$.Msg("hero_selection LockHeroAndReady") }
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var heroname = "npc_dota_hero_".concat(hero)

    // Send the name to lua, server handles it
    GameEvents.SendCustomGameEventToServer("submit_pick", {heroname: heroname})
}

function HeroPickAccepted(keys)
{
	
	if(debugging >= 1) {$.Msg("hero_selection HeroPickAccepted") }
    // Put player avatar above the hero
    var pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat(keys.heroname))
    //var steamIDpanel = $.CreatePanel("DOTAAvatarImage", pan, "" )
	//steamIDpanel.steamid = Game.GetPlayerInfo(keys.pid).player_steamid
	//steamIDpanel.style.opacity = 0.5
	//steamIDpanel.AddClass("SteamAvatarHS")
	//steamIDpanel.hittest = true

	
	var idpaneloverlay = $.CreatePanel("Panel", pan, "AvatarOverlay" )
	idpaneloverlay.AddClass("SteamAvatarOverlay")
	var color = "colorPlayer".concat(Players.GetTeam(keys.pid)-5)
	idpaneloverlay.style.backgroundColor = eval(color)
	idpaneloverlay.hittest = false
    idpaneloverlay.style.opacity = 0.5
	if (keys.pid)
	{
		if (keys.pid == Players.GetLocalPlayer())
		{   
			// Remove the button
			$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible = false
		}
    }
	if (someonePicked == false)
	{
		var endTime = Game.GetGameTime() + 10
		SlideProgressBar(endTime)
		someonePicked = true
		LoadBarWidth = 400
		var panel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CountDownBarHS")
		panel.style.width = (LoadBarWidth).toString().concat("px")
	}
}	

function SlideProgressBar(endTime)
{
	if(debugging >= 2) {$.Msg("hero_selection SlideProgressBar ",endTime) }
	var panel = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("CountDownBarHS")

	LoadBarWidth = (endTime - Game.GetGameTime()) * 40
	
	
	panel.style.width = (LoadBarWidth).toString().concat("px")	
	if (LoadBarWidth > 10)
	{	
		$.Schedule(0.02,function(){SlideProgressBar(endTime);})
	}
	else
	{
		panel.style.opacity = 0
	}
}

function KillPickScreen()
{
	if(debugging >= 1) {$.Msg("hero_selection KillPickScreen" )}
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_Main").GetParent().visible = false 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_Main").visible = false 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible = false 
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").GetParent().visible = false
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").visible = false
	GameEvents.SendCustomGameEventToServer("get_lifes", {nStartingLifes: parseInt($.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("nStartingLifes").text)})
	// Send all players lifes to server, so it can use the average as lifes
}
function ValueChange(name, amount)
{
	if(debugging >= 1) {$.Msg("Hero Select ValueChange" )}
	var min_level = 0
	var max_level = 10
    var panel = $("#"+name);
    if (panel !== null)
	{
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
}

function PlayerPressedDashboard()
{
	if(debugging >= 1) {$.Msg("HeroSelect PlayerPressedDashboard" )}
	GameEvents.SendCustomGameEventToServer("player_leaves", {})
	$.GetContextPanel().GetParent().RemoveAndDeleteChildren()
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("EndScreen").style.visibility = "visible"
}
function PlayerPressedHelp()
{
	if(debugging >= 1) {$.Msg("HeroSelect PlayerPressedHelp" )}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HelpScreen").style.visibility = "visible"
}
function PlayerPressedHelpOut()
{
	if(debugging >= 1) {$.Msg("HeroSelect PlayerPressedHelp" )}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HelpScreen").style.visibility = "collapse"
}
(function()
{  
    GameEvents.Subscribe( "pick_heroes", BuildHeroSelectionScreen);
    GameEvents.Subscribe( "hero_pick_accepted", HeroPickAccepted);
    GameEvents.Subscribe( "kill_pick_screen", KillPickScreen);
})();
