var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var colorPlayer1 = "red"
var colorPlayer2 = "blue"
var colorPlayer3 = "green"
var colorPlayer4 = "yellow"

function CameraSettings(){ 
  // Do camera stuff
  GameUI.SetCameraYaw( 0 ); 
  GameUI.SetCameraPitchMin(10);
  GameUI.SetCameraPitchMax(10);
  GameUI.SetCameraDistance( 1000 );
  //GameUI.SetCameraLookAtPositionHeightOffset(Entities.GetAbsOrigin(Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()))[2]);
  var hero = PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(),"hero");
  //$.Msg(hero)
  //$.Msg(PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(), "lifes"))
  if (hero && PlayerTables.GetTableValue(Players.GetLocalPlayer().toString(), "lifes") >= 0) { 
    GameUI.SetCameraTarget(hero);
    if (Entities.GetAbsOrigin(hero)) { 
      GameUI.SetCameraLookAtPositionHeightOffset(Entities.GetAbsOrigin(hero)[2]-100);
    }
  }
  else { 
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
  if (PlayerTables.GetTableValue(0,"hero") > 0) {
    var hero = PlayerTables.GetTableValue(0,"hero");
    if (Entities.IsAlive(hero)){
      var player_1_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } else {
      var player_1_hp = 0
    }
    Player1_Health.text = player_1_hp;

    if (PlayerTables.GetTableValue(0, "lifes") !== null)  {
    var player_1_life = (PlayerTables.GetTableValue(0, "lifes")).toString()
    
    Player1_Lifes.text = player_1_life.concat("x")
    }  
    // Player 1 is always red
    Player1_Health.style.color = colorPlayer1
    Player1_Health.style.opacity = 0.75

  }
  // Player 2
  if (PlayerTables.GetTableValue(1,"hero") > 0) {
    var hero = PlayerTables.GetTableValue(1,"hero");
    if (Entities.IsAlive(hero)){
      var player_2_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } else {
      var player_2_hp = 1
    }
    Player2_Health.text = player_2_hp;
    if (PlayerTables.GetTableValue(1, "lifes") !== null)  {
    var player_2_life = (PlayerTables.GetTableValue(1, "lifes")).toString()
    
    Player2_Lifes.text = player_2_life.concat("x")
    }  
    //Set the color based on team
    if (Players.GetTeam(1) == DOTATeam_t.DOTA_TEAM_GOODGUYS)
    {
      Player2_Health.style.color = colorPlayer1
    }
    else if (Players.GetTeam(1) == DOTATeam_t.DOTA_TEAM_BADGUYS) 
    {
      Player2_Health.style.color = colorPlayer2
    }
    Player2_Health.style.opacity = 0.75

  }
  // Player 3
  if (PlayerTables.GetTableValue(2,"hero") > 0) {
    var hero = PlayerTables.GetTableValue(2,"hero");
    if (Entities.IsAlive(hero)){
      var player_3_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } else {
      var player_3_hp = 0
    }
    Player3_Health.text = player_3_hp;
    if (PlayerTables.GetTableValue(2, "lifes") !== null)  {
    var player_3_life = (PlayerTables.GetTableValue(2, "lifes")).toString()
    
    Player3_Lifes.text = player_3_life.concat("x")
    //Set the color based on team
    if (Players.GetTeam(2) == DOTATeam_t.DOTA_TEAM_GOODGUYS)
    {
      Player3_Health.style.color = colorPlayer1
    }
    else if (Players.GetTeam(2) == DOTATeam_t.DOTA_TEAM_BADGUYS) 
    {
      Player3_Health.style.color = colorPlayer2
    }
    else if (Players.GetTeam(2) == DOTATeam_t.DOTA_TEAM_CUSTOM_1) 
    {
      Player3_Health.style.color = colorPlayer3
    }
    Player3_Health.style.opacity = 0.75
    
    }  
  }
  // Player 4
  if (PlayerTables.GetTableValue(3,"hero") > 0) {
    var hero = PlayerTables.GetTableValue(3,"hero");
    if (Entities.IsAlive(hero)){
      var player_4_hp = Entities.GetMaxHealth(hero) - Entities.GetHealth(hero)
    } else {
      var player_4_hp = 0
    }
    Player3_Health.text = player_3_hp;
    if (PlayerTables.GetTableValue(3, "lifes") !== null)  {
    var player_4_life = (PlayerTables.GetTableValue(3, "lifes")).toString()
    
    Player4_Lifes.text = player_4_life.concat("x")
    if (Players.GetTeam(3) == DOTATeam_t.DOTA_TEAM_GOODGUYS)
    {
      Player4_Health.style.color = colorPlayer1
    }
    else if (Players.GetTeam(3) == DOTATeam_t.DOTA_TEAM_BADGUYS) 
    {
      Player4_Health.style.color = colorPlayer2
    }
    else if (Players.GetTeam(3) == DOTATeam_t.DOTA_TEAM_CUSTOM_2) 
    {
      Player4_Health.style.color = colorPlayer4
    }
    Player4_Health.style.opacity = 0.75
    }  
  }
  
  // Repeat and repeat
  $.Schedule(0.01, function(){CameraSettings();})
}


function CancelCameraSettings(){
  $.Msg("CancelCameraSettings")
  // Place to control triangles
  var next = $.GetContextPanel().GetParent().GetParent().FindChildTraverse("MainPanel")
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
  $.CancelScheduled(CameraSettings);
}

function CreatePlayerHeroAvatars()
{
  $.Schedule(1, function()
  {
    var playerIDs = Game.GetAllPlayerIDs()     
    for (var i = 1; i < playerIDs.length +1; i++) 
    {
      var string = "Player" + i + "_box"
      var panel =  $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse(string)
      Player_Avatar = $.CreatePanel('DOTAHeroImage', panel, '');
      var hero = Players.GetPlayerHeroEntityIndex(i-1)
      Player_Avatar.heroname = Entities.GetUnitName(hero);
      Player_Avatar.heroimagestyle = "portrait"
    }
  })
}


(function() {
  GameEvents.Subscribe( "kill_pick_screen", CreatePlayerHeroAvatars)
  GameEvents.Subscribe( "fix_camera", CameraSettings)
  GameEvents.Subscribe( "reset_camera", CameraSettings)
})();



