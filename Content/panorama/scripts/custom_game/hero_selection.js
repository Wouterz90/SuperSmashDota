"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables

function BuildHeroSelectionScreen()
{
	// Make them all visible again
    var panel =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_HeroBox")
    panel.GetParent().GetParent().visible = true
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_HeroBox").GetParent().visible  = true 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible  = true 

    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("puck")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("rattletrap")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("zuus")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tusk")).style.opacity = 1

    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("earthshaker")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("mirana")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("lina")).style.opacity = 1
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat("tinker")).style.opacity = 1
	
	// Hide heroes players already picked
	 
	var table = PlayerTables.GetAllTableValues(Players.GetLocalPlayer().toString().concat("heroes"))
	for (var k in table)
	{
			
		
		var string = k.substr(14)
		
		string = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat(string)).style.opacity = 0.1
		
	}
	
}


// Functions for selecting a hero
function SetSelectedHero(heroName)
{
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname = "npc_dota_hero_".concat(heroName)
    // Set his abilities
    var string = heroName
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_top").abilityname = string.concat("_special_top")
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_side").abilityname = string.concat("_special_side")
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("special_mid").abilityname = string.concat("_special_mid")
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


function selectedHeroClock()
{
    var heroName = "rattletrap"
    SetSelectedHero(heroName)
}
function selectedHeroPuck()
{
    var heroName = "puck"
    SetSelectedHero(heroName)
}
function selectedHeroTusk()
{
    var heroName = "tusk"
    SetSelectedHero(heroName)
}
function selectedHeroEarthshaker()
{
    var heroName = "earthshaker"
    SetSelectedHero(heroName)
}
function selectedHeroMirana()
{
    var heroName = "mirana"
    SetSelectedHero(heroName)
}
function selectedHeroTinker()
{
    var heroName = "tinker"
    SetSelectedHero(heroName)
}
function selectedHeroZuus()
{
    var heroName = "zuus"
    SetSelectedHero(heroName)
}
function selectedHeroLina()
{
    var heroName = "lina"
    SetSelectedHero(heroName)
}
function selectedHeroRandom()
{   
    var heroName = ""
    SetSelectedHero(heroName)
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
    var hero = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("SelectedHero").heroname
    var heroname = "npc_dota_hero_".concat(hero)

    // Send the name to lua, server handles it
    GameEvents.SendCustomGameEventToServer("submit_pick", {heroname: heroname})
}

function HeroPickAccepted(keys)
{
    // Put player avatar above the hero
    //$.Msg(keys.heroname)
    var pan = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HeroPick".concat(keys.heroname))
    //var idpanel = $.CreatePanel("DOTAAvatarImage", pan, "" ) 
    pan.style.opacity = 0.1
	if (keys.pid)
	{
		if (keys.pid == Players.GetLocalPlayer())
		{   
			// Remove the button
			$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible = false
		}
    }
}



function KillPickScreen()
{
    
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_Main").GetParent().visible = false 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Hero_Selection_Main").visible = false 
    $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("LockHero").visible = false 
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").GetParent().visible = false
    //$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Ally_Selection_Main").visible = false
}

(function()
{  
    
    GameEvents.Subscribe( "pick_heroes", BuildHeroSelectionScreen);
    GameEvents.Subscribe( "hero_pick_accepted", HeroPickAccepted);
    GameEvents.Subscribe( "kill_pick_screen", KillPickScreen);
})();
