"use strict";
var debugging = 0  
function RemoveHudThings() 
{
	if(debugging >= 1) {$.Msg("mouse_control RemoveHudThings" )}
  $.GetContextPanel().GetParent().GetParent().FindChild("HUDElements").FindChild("quickstats").style.visibility = "collapse";
  var top = $.GetContextPanel().GetParent().GetParent();
  var hud = top.FindChild("HUDElements");

  hud.FindChild("KillCam").style.visibility = "collapse"; 
  top.FindChild("ChannelBar").style.visibility = "collapse";

 
}

function OnDownPressed()
{ 
	if(debugging >= 2) {$.Msg("mouse_control OnDownPressed") }
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button:"down",action:"pressed",x:table[0],y:table[1]} )
}
function OnUpPressed()
{ 
	if(debugging >= 2) {$.Msg("mouse_control OnUpPressed" )}
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "up",action: "pressed",x:table[0],y:table[1]} )
}
function OnLeftPressed()
{
	if(debugging >= 2) {$.Msg("mouse_control OnLeftPressed" )}
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "left",action: "pressed",x:table[0],y:table[1]} )
}
function OnRightPressed()
{
	if(debugging >= 2) {$.Msg("mouse_control OnRightPressed") }
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "right",action: "pressed",x:table[0],y:table[1]} )
}
function OnDownReleased()
{
	if(debugging >= 2) {$.Msg("mouse_control OnDownReleased" )}
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "down",action: "released",x:table[0],y:table[1]} )
}
function OnUpReleased()
{
	if(debugging >= 2) {$.Msg("mouse_control OnUpReleased") }
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "up",action: "released",x:table[0],y:table[1]} )
}
function OnLeftReleased()
{
	if(debugging >= 2) {$.Msg("mouse_control OnLeftReleased" )}
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "left",action: "released",x:table[0],y:table[1]} )
}
function OnRightReleased()
{
	if(debugging >= 2) {$.Msg("mouse_control OnRightReleased" )}
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button: "right",action: "released",x:table[0],y:table[1]} )
}




// Handle Left Button events
function OnLeftButtonPressed(eventName)
{
  //$.Msg("LEFT BUTTON CAST")
  //$.Msg("entities: ", mouseEntities.length)
  var table = GetMousePosition();
  GameEvents.SendCustomGameEventToServer( "key_event", {button:"left_mouse",action:eventName,x:table[0],y:table[1]} )

}

// Handle Right Button events
function OnRightButtonPressed(eventName)
{
  //$.Msg("RIGHT BUTTON CAST")
  //$.Msg("entities: ", mouseEntities.length)
  GetMousePosition()
  var table = GetMousePosition()
  GameEvents.SendCustomGameEventToServer( "key_event", {button:"right_mouse",action:eventName,x:table[0],y:table[1]} )
}


GameUI.SetMouseCallback( function( eventName, arg ) {
  if(debugging >= 2) {$.Msg("mouse_control SetMouseCallback" )}
  var CONSUME_EVENT = true;
  var CONTINUE_PROCESSING_EVENT = false;
  //$.Msg("MOUSE: ", eventName, " -- ", arg, " -- ", GameUI.GetClickBehaviors())

  if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
  {
    return CONTINUE_PROCESSING_EVENT;
  }

  if ( eventName === "pressed" || eventName === "doublepressed" || eventName === "released" )
  {
    if ( arg === 0 )
    {
      // Left-click is attack normally
      OnLeftButtonPressed(eventName);
      //$.Msg("left")
      return CONSUME_EVENT;
    }
    // Right-click is use special abilities
    if ( arg === 1 )
    {
      OnRightButtonPressed(eventName);
      //$.Msg("right")
      return CONSUME_EVENT;
    }
  }
} );

function GetMousePosition()
{
	if(debugging >= 2) {$.Msg("mouse_control GetMousePosition") }
  var position = GameUI.GetCursorPosition();
  var x = Game.GetScreenWidth();
  var y = Game.GetScreenHeight();
  var x = position[0] / x;
  var y = position[1] / y;
  return [x,y];
  
  //$.Msg(world_position);
  //GameEvents.SendCustomGameEventToServer("MousePosition", { world_position:world_position});
}

RemoveHudThings();

(function() {
  Game.AddCommand( "+MDownPressed", OnDownPressed, "", 0 );
  Game.AddCommand( "+MUpPressed", OnUpPressed, "", 0 );
  Game.AddCommand( "+MLeftPressed", OnLeftPressed, "", 0 );
  Game.AddCommand( "+MRightPressed", OnRightPressed, "", 0 );
  Game.AddCommand( "-MDownPressed", OnDownReleased, "", 0 );
  Game.AddCommand( "-MUpPressed", OnUpReleased, "", 0 );
  Game.AddCommand( "-MLeftPressed", OnLeftReleased, "", 0 );
  Game.AddCommand( "-MRightPressed", OnRightReleased, "", 0 );
   
})();