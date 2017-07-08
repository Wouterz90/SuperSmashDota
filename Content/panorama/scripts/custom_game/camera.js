var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var colorPlayer1 = "red"
var colorPlayer2 = "blue"
var colorPlayer3 = "green"
var colorPlayer4 = "yellow"
var colorTeam1 = "red"
var colorTeam2 = "blue"
var debugging = 0
var camera = 1
CameraSettings() // To instantly edit

function CameraSettings()	
{ 
	if(debugging >= 2) {$.Msg("camera CameraSettings") }
  // Do camera stuff
  GameUI.SetCameraYaw( 0 ); 
  GameUI.SetCameraPitchMin(1);
  GameUI.SetCameraPitchMax(1);
  var width = Game.GetScreenWidth()
  var height = Game.GetScreenHeight()
  
  var minDistance = 1000
  var maxDistance = 2250
  
  var positions = {}
  var positionsX = {}
  var positionsZ = {}
  
  // Get positions
  for (var i = 0; i <= 3; i++) 
  {
	if (Players.IsValidPlayerID(i))
	{
		var hero = PlayerTables.GetTableValue(i.toString(),"hero");
		if (hero && Entities.IsAlive( hero )) 
		{
			//GameUI.SetCameraTarget(hero)
			positions[i] = Entities.GetAbsOrigin(hero)
			if (positions[i])
			{
				positionsX[i] = Number(positions[i][0])
				positionsZ[i] = Number(positions[i][2])
			}
		}
	}
  }
  
  
	// Get the needed width
  var horizontalDifference = GetMinMaxValue(positionsX) + 400
  var verticalDifference = GetMinMaxValue(positionsZ) + 400
  
  // Width needed to display the units
  var desiredDistanceWidth = 1/(Game.GetScreenWidth()/(632.975*horizontalDifference))
  if (desiredDistanceWidth < minDistance)
  {
	desiredDistanceWidth = minDistance
  }
  if (desiredDistanceWidth > maxDistance)
  {
	  // Todo aim at player hero instead of camera or something?
	desiredDistanceWidth = maxDistance
  }
  

  var desiredDistanceHeight = 1/(Game.GetScreenHeight()/(632.975*verticalDifference))
  if (desiredDistanceHeight < minDistance)
  {
	desiredDistanceHeight = minDistance
  }
  if (desiredDistanceHeight > maxDistance)
  {
	desiredDistanceHeight = maxDistance
  }
  
 
  GameUI.SetCameraDistance(Math.max(desiredDistanceWidth,desiredDistanceHeight))
  //$.Msg(Math.max(desiredDistanceWidth,desiredDistanceHeight))
  /*var x = 0, total = 0, y = 0
  for( x in positionsZ) 
  {
	total = total + positionsZ[x]
	y = x
  }
	
  var hero = PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(),"hero")
  if (hero)
  {
	GameUI.SetCameraLookAtPositionHeightOffset(Entities.GetAbsOrigin(hero)[2]+100)
  }
  else
  {
	GameUI.SetCameraLookAtPositionHeightOffset(1200)
  }
  
   
  */
  
  //GameUI.SetCameraDistance( 1100 );
  var hero = PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(),"hero");
  if (hero && PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(), "lifes") >= 0) 
  { 
	var camUnit = CustomNetTables.GetTableValue("settings","cameraUnit").value
    GameUI.SetCameraTarget(camUnit);
	
    if (Entities.GetAbsOrigin(camUnit)) 
	{ 
		var height = Entities.GetAbsOrigin(camUnit)[2]
		/*$.Msg(height)	
		if (height > 3000 - 300)
		{
			height = 2700
		}
		if (height < 500)
		{
			height = 500	
		}*/
      GameUI.SetCameraLookAtPositionHeightOffset(height-100);
    }
  }
  else 
  { 
    GameUI.SetCameraTarget(-1)
    GameUI.SetCameraLookAtPositionHeightOffset(700);
  }


  
  

  // Do the health part stuff
  
  var top = $.GetContextPanel().GetParent().GetParent();
  
  var next = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("HealthPanel")
  var Player1_Health = next.GetChild(0).GetChild(0)
  var Player2_Health = next.GetChild(1).GetChild(0)
  var Player3_Health = next.GetChild(2).GetChild(0)
  var Player4_Health = next.GetChild(3).GetChild(0)
  var Player1_Lifes = next.GetChild(0).GetChild(1)
  var Player2_Lifes = next.GetChild(1).GetChild(1)
  var Player3_Lifes = next.GetChild(2).GetChild(1)
  var Player4_Lifes = next.GetChild(3).GetChild(1)
  var Player1_Avatar 
  var Player2_Avatar 
  var Player3_Avatar 
  var Player4_Avatar
  


  // Player 1
  if (PlayerTables.GetTableValue(0,"hero") > 0) 
  {
    var hero = PlayerTables.GetTableValue(0,"hero");
    if (Entities.IsAlive(hero))
	{
      var player_1_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } 
	else 
	{
      var player_1_hp = 0
    }
    Player1_Health.text = player_1_hp;

    if (PlayerTables.GetTableValue(0, "lifes") !== null)  
	{
    var player_1_life = (PlayerTables.GetTableValue(0, "lifes")).toString()
    
    Player1_Lifes.text = player_1_life.concat("x")
    }
	Player1_Health.style.color = eval("colorPlayer".concat(Players.GetTeam(0)-5))
	Player1_Health.style.opacity = 0.75
	next.GetChild(0).FindChild("Player1_Bar").style.width = (PlayerTables.GetTableValue(0, "charges") * 1.5).toString().concat("px")
  }
  // Player 2
  if (PlayerTables.GetTableValue(1,"hero") > 0) 
  {
    var hero = PlayerTables.GetTableValue(1,"hero");
    if (Entities.IsAlive(hero))
	{
      var player_2_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } 
	else 
	{
      var player_2_hp = 1
    }
    Player2_Health.text = player_2_hp;
    if (PlayerTables.GetTableValue(1, "lifes") !== null)  
	{
    var player_2_life = (PlayerTables.GetTableValue(1, "lifes")).toString()
    
    Player2_Lifes.text = player_2_life.concat("x")
    Player2_Health.style.color = eval("colorPlayer".concat(Players.GetTeam(1)-5))  
	Player2_Health.style.opacity = 0.75
	next.GetChild(1).FindChild("Player2_Bar").style.width = (PlayerTables.GetTableValue(1, "charges") * 1.5).toString().concat("px")
	}

  }
  // Player 3
  if (PlayerTables.GetTableValue(2,"hero") > 0) 
  {
    var hero = PlayerTables.GetTableValue(2,"hero");
    if (Entities.IsAlive(hero))
	{
      var player_3_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } 
	else 
	{
      var player_3_hp = 0
    }
    Player3_Health.text = player_3_hp;
    if (PlayerTables.GetTableValue(2, "lifes") !== null)  
	{
		var player_3_life = (PlayerTables.GetTableValue(2, "lifes")).toString()
		
		Player3_Lifes.text = player_3_life.concat("x")
		Player3_Health.style.color = eval("colorPlayer".concat(Players.GetTeam(2)-5))
		Player3_Health.style.opacity = 0.75
		next.GetChild(2).FindChild("Player3_Bar").style.width = (PlayerTables.GetTableValue(2, "charges") * 1.5).toString().concat("px")
    }  
  }
  // Player 4
  if (PlayerTables.GetTableValue(3,"hero") > 0) 
  {
    var hero = PlayerTables.GetTableValue(3,"hero");
    if (Entities.IsAlive(hero))
	{
		
      var player_4_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } 
	else  
	{
      var player_4_hp = 0
    }
    Player4_Health.text = player_4_hp;

    if (PlayerTables.GetTableValue(3, "lifes") !== null)  
	{
		var player_4_life = (PlayerTables.GetTableValue(3, "lifes")).toString()
		
		Player4_Lifes.text = player_4_life.concat("x")
		
		Player4_Health.style.color = eval("colorPlayer".concat(Players.GetTeam(3)-5))
		Player4_Health.style.opacity = 0.75
		next.GetChild(3).FindChild("Player4_Bar").style.width = (PlayerTables.GetTableValue(3, "charges") * 1.5).toString().concat("px")
	
    }  
  }

  
  // Repeat and repeat
	//if (camera == 1)
	//{
		$.Schedule(0.01, function(){CameraSettings();})
	//}
}


function CancelCameraSettings(){
  if(debugging >= 1) {$.Msg("camera CancelCameraSettings") }
  // Place to control triangles
  var next = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("MainPanelBoxes")
  var topbox = next.GetChild(0)
  var leftbox = next.GetChild(1)
  var rightbox = next.GetChild(2)
  var bottombox = next.GetChild(3)
  topbox.style.visibility = "collapse";
  leftbox.style.visibility = "collapse";
  rightbox.style.visibility = "collapse";
  bottombox.style.visibility = "collapse";

	

  // Unlock the camera
  GameUI.SetCameraTarget(-1)
  GameUI.SetCameraLookAtPositionHeightOffset(700);

  // Cancel the updates
  camera = 0
}
function CreatePlayerHeroAvatars()
{
	if(debugging >= 1) {$.Msg("camera CreatePlayerHeroAvatars") }
  $.Schedule(2, function()
  {	
	if(debugging >= 1) {$.Msg("camera CreatePlayerHeroAvatars2") }
	var next = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("MainPanelBoxes")
	  var topbox = next.GetChild(0)
	  var leftbox = next.GetChild(1)
	  var rightbox = next.GetChild(2)
	  var bottombox = next.GetChild(3)
	  topbox.style.visibility = "visible";
	  leftbox.style.visibility = "visible";
	  rightbox.style.visibility = "visible";
	  bottombox.style.visibility = "visible";
	// Create the avatars in the bottom for the players
    var playerIDs = Game.GetAllPlayerIDs()     
    for (var i = 1; i < playerIDs.length +1; i++) 
    {
      var string = "Player" + i + "_box"
      var panel =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(string)
      Player_Avatar = $.CreatePanel('DOTAHeroImage', panel, '');
	  Player_Avatar.SetHasClass("Player_Avatar",true)
      var hero = Players.GetPlayerHeroEntityIndex(i-1)
      Player_Avatar.heroname = Entities.GetUnitName(hero);
      Player_Avatar.heroimagestyle = "portrait"
    }
	var hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
	var str = Entities.GetUnitName(hero).substr(14)
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").abilityname = str.concat("_special_top")
	if (Entities.GetAbilityByName( hero, str.concat("_special_top_release")) !== -1)
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").AddClass("Releasable")
	}
	else
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").RemoveClass("Releasable")
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left").abilityname = str.concat("_special_side")
	if (Entities.GetAbilityByName( hero, str.concat("_special_side_release")) !== -1)
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left").AddClass("Releasable")
	}
	else
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left").RemoveClass("Releasable")
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right").abilityname = str.concat("_special_side")
	if (Entities.GetAbilityByName( hero, str.concat("_special_side_release")) !== -1)
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right").AddClass("Releasable")
	}
	else
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right").RemoveClass("Releasable")
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom").abilityname = str.concat("_special_bottom")
	if (Entities.GetAbilityByName( hero, str.concat("_special_bottom_release")) !== -1)
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom").AddClass("Releasable")
	}
	else
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom").RemoveClass("Releasable")
	}
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_topSilence").style.opacity = 0
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_leftSilence").style.opacity = 0
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_rightSilence").style.opacity = 0
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottomSilence").style.opacity = 0
	
	camera = 1


  })
}

function UpdateCooldowns(ability,panel)
{
	if(debugging >= 2) {$.Msg("camera UpdateCooldowns") }
	var hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer())
	var heroName = Entities.GetUnitName(hero).substr(14)
	var abilityName = Abilities.GetAbilityName(ability)
	
	if (Abilities.IsCooldownReady(ability))
	{
		panel.style.clip = "radial(50% 50%, 0deg, " + 100 * 	360 + "deg)"
		panel.style.opacity = 1
		if (Entities.GetAbilityByName( hero, abilityName.concat("_release")) !== -1)
		{
			if (abilityName.indexOf("special_top") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_topPress").style.opacity = 0
			}
			else if (abilityName.indexOf("special_bottom") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottomPress").style.opacity = 0
			}
			else if (abilityName.indexOf("special_side") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_leftPress").style.opacity = 0
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_rightPress").style.opacity = 0
			}
		}
	}
	else 
	{
		// Show press icon while ability is on cooldown
		if (Entities.GetAbilityByName( hero, abilityName.concat("_release")) !== -1)
		{
			if (abilityName.indexOf("special_top") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_topPress").style.opacity = 0.75
			}
			else if (abilityName.indexOf("special_bottom") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottomPress").style.opacity = 0.75
			}
			else if (abilityName.indexOf("special_side") !== -1)
			{
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_leftPress").style.opacity = 0.75
				$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_rightPress").style.opacity = 0.75
			}
		}
			
		var cooldownLength = Abilities.GetCooldownLength( ability );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( ability );
		var cooldownPercent = 1 -(cooldownRemaining / cooldownLength);
		panel.style.opacity = 0.75
		panel.style.clip = "radial(50% 50%, 0deg, " + cooldownPercent * 360 + "deg)";
		$.Schedule(0.01,function(){UpdateCooldowns(ability,panel);})
	}	
		
	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").abilityname 	
}

function ShowCooldown(table)
{	
	if(debugging >= 1) {$.Msg("camera ShowCooldown") }
	if (table.sAbilityName.search("_special_top") !== -1)
	{
		//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").style.opacity = 0.25
		//$.Schedule(table.nCooldown,function()
		//{
			//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top").style.opacity = 1
			UpdateCooldowns(table.ability,$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_top"))
		//})
	}	
	if (table.sAbilityName.search("_special_side") !== -1)
	{
		//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left").style.opacity = 0.25
		//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right").style.opacity = 0.25
		//$.Schedule(table.nCooldown,function()
		//{
			//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left").style.opacity = 1
			//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right").style.opacity = 1
			UpdateCooldowns(table.ability,$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_left"))
			UpdateCooldowns(table.ability,$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_right"))
		//})
	}
	if (table.sAbilityName.search("_special_bottom") !== -1)
	{
		//$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom").style.opacity = 0.25
		//$.Schedule(table.nCooldown,function()
		//{
		//	$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom").style.opacity = 1
			UpdateCooldowns(table.ability,$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottom"))
		//})
	}

}


function ShowSilence(table)
{
	if(debugging >= 2) {$.Msg("camera ShowSilence") }
	if ((Game.GetGameTime()-table.flStartTime) <= table.flDuration)
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_topSilence").style.opacity = 1
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_leftSilence").style.opacity = 1
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_rightSilence").style.opacity = 1
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottomSilence").style.opacity = 1
		$.Schedule(0.01,function(){ShowSilence(table);})
	}
	else 
	{
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_topSilence").style.opacity = 0
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_leftSilence").style.opacity = 0
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_rightSilence").style.opacity = 0
		$.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("Mainspecial_bottomSilence").style.opacity = 0
	}
}

function PlayerPressedForfeit()
{
	if(debugging >= 1) {$.Msg("Camera PlayerPressedForfeit" )}
	GameEvents.SendCustomGameEventToServer("player_forfeits", {})
}

function GetMinMaxValue(input)
{
	var min = Infinity, max = -Infinity, x;
	for( x in input) 
	{
		if( input[x] < min) min = input[x];
		if( input[x] > max) max = input[x];
	}
	
	return Math.abs(min-max)
}
function GetMinValue(input)
{
	var min = Infinity, x;
	for( x in input) 
	{
		if( input[x] < min) min = input[x];
	}
	
	return min
}
function GetMaxValue(input)
{
	var max = Infinity, x;
	for( x in input) 
	{
		if( input[x] < max) max = input[x];
	}
	
	return max
}
(function() {
  GameEvents.Subscribe( "kill_pick_screen", CreatePlayerHeroAvatars)
  GameEvents.Subscribe( "fix_camera", CameraSettings)
  GameEvents.Subscribe( "reset_camera", CancelCameraSettings)
  GameEvents.Subscribe( "show_cooldown", ShowCooldown)
  GameEvents.Subscribe( "show_silence", ShowSilence)
  
})();



