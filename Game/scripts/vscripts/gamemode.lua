  -- Basic values
Laws = {

  
  flJumpSpeed = 35,
  flJumpDuration = 20/32,
  flJumpDeceleration = 0.925,
  flDropAcceleration = 1.015,
  flDropSpeed = 40,
  flMove = 16,

  flPushDeceleration = 0.5, -- 0.5 per second


  flMinDamage = 4,
  flMaxDamage = 8,
  flAttackRange = 130,
  flSideAttackFactor = 2,

  flMaxHeight = 3000,
  flMinHeight = 150,

  flRuneDuration = 10,
}
Laws.flPushDeceleration = math.pow(0.925,1/32) -- Converting the number to 1/32th
--Laws.flDropAcceleration = math.pow(1.155,1/32) -- Converting the number to 1/32th


-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time.
-- 0 is no debug calls, 1 is giving function names, 2 also includes timers and loops.
LUA_DEBUG_SPEW = 0
--PANORAMA_DEBUG_SPEW = 0


if GameMode == nil then
    DebugPrint(1, '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end
-- STATS! 
require("statcollection/init")

-- This library allow for easily delayed/timed actions
require('libraries/timers')
--require('libraries/worldpanels')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
--require('libraries/matrix')
-- My own physics shit
require('physics2d')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
require('libraries/trackingprojectile')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
--require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
--require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
--require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
--require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')
require('internal/util')


-- File to handle setup, init ally pick screen
require('game_setup/ally_selection')
-- File everything about hero picks
require('game_setup/hero_selection')
-- Store the hero ratings based on the balance tool based on ability values(not game stats!)
require('game_setup/heroratingvalues')
require('tables/chargeable_abilities')
require('tables/gravity_removing_modifiers')
-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')
-- order filter, negates every order for now
require('orders')
-- File with the linked modifiers
require('modifiers')
-- File to manage thie controls
require('controls')
-- File with all the maps
require('maps')
-- File to manage the platforms created
require('platforms')
-- File to handle to pushing back, requires damagefilter
require('push')
-- Handle the creation and effects of items
require('items')


--require("examples/worldpanelsExample")

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint(1,"[BAREBONES] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  
  PrecacheUnitByNameAsync("npc_dota_hero_earthshaker", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint(1,"[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint(1,"[BAREBONES] All Players have loaded into the game")
  spawnPlatform()
  GameMode.Players = {}
  

  for i=0,3 do
    if PlayerResource:IsValidPlayerID(i) then
      local player = PlayerResource:GetPlayer(i)
      if player ~= nil then
        --player:MakeRandomHeroSelection()
        --PlayerResource:SetHasRepicked(i)
        PlayerTables:CreateTable(tostring(i).."heroes",{},true)
        player.id = i
        player.team = i+2
        table.insert(GameMode.Players, player)
      end
    end
  end
  

  --Create the camera unit
  GameMode:CreateCameraUnit() 
end

function GameMode:CreateCameraUnit()
  cameraDummyUnit = CreateUnitByName("npc_dummy_unit",Vector(0,0,0),false,nil,nil,DOTA_TEAM_NOTEAM)
  cameraDummyUnit:SetAbsOrigin(Vector(0,0,0))
  cameraDummyUnit:FindAbilityByName("dummy_unit"):SetLevel(1)
  CustomNetTables:SetTableValue("settings","cameraUnit",{value = cameraDummyUnit:entindex()})
  --cameraDummyUnit:StopPhysicsSimulation()
  Timers:CreateTimer(0,function()
    GameMode:ControlCamera()
    return 1/30
  end)
end

function GameMode:ControlCamera()
  local positionsTableX = {}
  local positionsTableZ = {}
  for i=0,3 do
    if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) ~= DOTA_TEAM_NOTEAM then
      local hero = PlayerResource:GetSelectedHeroEntity(i)
      if hero and hero:IsAlive() then
        positionsTableX[i] = hero:GetAbsOrigin().x
        positionsTableZ[i] = hero:GetAbsOrigin().z
      end
    end
  end

  local horizontalMid = GetMinMaxValue(positionsTableX)
  local verticalMid = GetMinMaxValue(positionsTableZ)
  cameraDummyUnit:SetAbsOrigin(Vector(horizontalMid,0,verticalMid))
end
--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  if not IsValidEntity(hero) then return end
  DebugPrint(1,"[SMASH] "..hero:GetUnitName().." has spawned")
  if hero:GetUnitName() == "npc_dota_hero_wisp" then
    hero.IsSmashUnit = false
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:AddNoDraw() 
    hero:SetAbsOrigin(Vector(0,0,0))
    hero:AddNewModifier(hero,nil,"modifier_puck_phase_shift",{})
    return 
  end
  if not firstHeroSpawned then 
    --spawnPlatform() 
    firstHeroSpawned = true 
  end

  
  deadplayers = 0
  
  --print("table created for "..hero:GetUnitName())
  if hero:IsRealHero() then
    DebugPrint(1,"[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
    -- Lock the camera on our hero
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(),"fix_camera",{})
    PlayerResource:SetCameraTarget(hero:GetPlayerID(),cameraDummyUnit)
    --GameRules:GetGameModeEntity():SetCameraDistanceOverride(1600)

    Physics2D:CreateObject("AABB",hero:GetAbsOrigin(),true,false,hero,100,150,"Unit")

    -- Init hero values here -- They can be adjusted personally somewhere after, eg. axe more force, less speed
    hero.IsSmashUnit = true
    hero.jumps = 0
    hero.amplify = 1
    hero.movespeedFactor = 1
    hero.jumpfactor = 1
    hero.attackspeedFactor = 1
    hero.attackDamageFactor = 1
    hero.spellDamageFactor = 1
    hero.zDelta = 0

    -- For future use, like starting with missing 300 health?ba
    hero:SetHealth(hero:GetMaxHealth())


    -- Make sure we control the hero and it doesn't control itself
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    hero:SetRespawnsDisabled(false)
    --hero:AddNewModifier(hero,nil,"modifier_jump",{duration = 1})
    Timers:CreateTimer(4,function()
      if hero and IsValidEntity(hero) then
        DebugPrint(1,"[SMASH] [TIMERS] Gamemode, OnHeroInGame")
        hero:AddNewModifier(hero,nil,"modifier_basic",{})
      end
    end)

    hero:AddAbility("basic_attack_mid")
    hero:AddAbility("basic_attack_top")
    hero:AddAbility("basic_attack_top_release")
    hero:AddAbility("basic_attack_bottom")
    hero:AddAbility("basic_attack_bottom_release")
    hero:AddAbility("basic_attack_left")
    hero:AddAbility("basic_attack_left_release")
    hero:AddAbility("basic_attack_right")
    hero:AddAbility("basic_attack_right_release")

    hero:AddAbility("special_shield")
    
    PrecacheUnitByNameAsync(hero:GetUnitName(), function(...) end)
    for i =0, 23 do 
      local abil = hero:GetAbilityByIndex(i)
      if abil and chargeableAbilities[abil:GetAbilityName()] then
        hero:AddAbility(abil:GetAbilityName().."_release")
      end
    end

    for i =0, 23 do
      local abil = hero:GetAbilityByIndex(i)
      if abil then
        PrecacheItemByNameAsync(abil:GetAbilityName(),function(...)end)
        abil:SetLevel(1)
      end
    end

    -- Phoenix egg fix, causes a spike on spawn
    if not bPhoenixHasSpawnedOnce and hero:GetUnitName() == "npc_dota_hero_phoenix" then
      hero:RemoveModifierByName("modifier_smash_stun")
      bPhoenixHasSpawnedOnce = true
      local ab = hero:FindAbilityByName("phoenix_special_bottom")
      if ab then
        hero:CastAbilityNoTarget(ab,-1)
        ab:EndCooldown()
        Timers:CreateTimer(1/30,function()
          hero:RemoveModifierByName("modifier_phoenix_special_down_egg")
        end)
      end
    end
  end
end


-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint(1,"[BAREBONES] NPC Spawned",EntIndexToHScript(keys.entindex):GetUnitName())
  DebugPrintTable(1,keys)
  local npc = EntIndexToHScript(keys.entindex)
  
  Timers:CreateTimer(0.1,function()
    DebugPrint(1,"[SMASH] [TIMERS] Gamemode, OnNPCSpawned1")
    if not npc:IsNull() and npc:IsRealHero() then
      local hero = npc
      if hero:GetUnitName() == "npc_dota_hero_wisp" then
        hero:SetAbsOrigin(Vector(-3000,-3000,0))
        hero:AddNoDraw()
        return
      else
        hero:RemoveNoDraw()
      end

      --hero:ClearStaticVelocity()
      --hero:SetPhysicsVelocity(Vector(0,0,0))
      hero:RemoveModifierByName("modifer_smash_stun")
      --print(hero:GetUnitName()..hero:GetPlayerOwnerID())
      if not hero.firstRespawn then
        if not CustomNetTables:GetTableValue("settings","nStartingLifes") then
          CustomNetTables:SetTableValue("settings","nStartingLifes",{value = 1})
        end 
        PlayerTables:CreateTable(tostring(hero:GetPlayerOwnerID()),{lifes = CustomNetTables:GetTableValue("settings","nStartingLifes").value},true)
        PlayerTables:SetTableValue(tostring(hero:GetPlayerOwnerID()),"hero",hero:entindex())
        PlayerTables:SetTableValue(tostring(hero:GetPlayerOwnerID()),"charges",0)
        hero.firstRespawn = true  
      end
      --hero:SetAbsOrigin(Vector(RandomInt(-platform[1].radius,platform[1].radius),0,1100))
      hero:SetAbsOrigin(Vec(000,1000))
      --hero:AddNewModifier(hero,nil,"modifier_jump",{duration=1})
      hero.jumps = 0 
      Timers:CreateTimer(1/32,function()
        DebugPrint(1,"[SMASH] [TIMERS] Gamemode, OnNPCSpawned2")
        if IsValidEntity(hero) then -- Only relevant for toolsmode tests
          hero:AddNewModifier(hero,nil,"modifier_basic",{})
        end
      end)
    end
  end)
end


--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()

  DebugPrint(1,"[BAREBONES] The game has officially begun")
  -- Allow the teams to have 2 players per team
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS,2)
  GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS,2)

  -- Statcollection stuff
  GameMode.flags = {
    version = SMASHVERSION,
    HeroSelection = CustomNetTables:GetTableValue("settings","HeroSelection").value,
    Format = CustomNetTables:GetTableValue("settings","Format").value,
    StartingLifes = CustomNetTables:GetTableValue("settings","nStartingLifes").value,
  }

  Timers:CreateTimer(RandomInt(20,40),function()
    if platform then
      DebugPrint(1,"[SMASH] [TIMERS] Gamemode, OnGameInProgress")
      items:CreateItem({categoryName = "runes",layAroundDuration=10})
      return RandomInt(20,40)
    end
  end)

  statCollection:setFlags(GameMode.flags) 
  statCollection:sendStage2()

  if PlayerResource:GetTeamPlayerCount() == 1 then
    SINGLE_PLAYER_GAME = true
  end
  -- Set the format to ffa if there aren't 4 players
 -- if PlayerResource:GetTeamPlayerCount() ~= 4 and not IsInToolsMode() then
    CustomNetTables:SetTableValue("settings","Format",{value = "1"})
  --end
  if CustomNetTables:GetTableValue("settings","Format").value ~= "2" then -- not 2v2
    --Timers:CreateTimer(0.25,function()
      GameMode:HeroPickStarted()
    --  end)
  else
    
  end
  
end
function GameMode:Reset()
  DebugPrint(1,"[SMASH] The game is resetting after a round")
  if not self.playersLeft then self.playersLeft = 0 end

  for i=0,DOTA_MAX_TEAM_PLAYERS do
    if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetSelectedHeroEntity(i) then
      PlayerResource:GetSelectedHeroEntity(i):RemoveModifierByName("modifier_basic")
      PlayerResource:GetSelectedHeroEntity(i):RemoveModifierByName("modifier_drop")
      PlayerResource:ReplaceHeroWith(i,"npc_dota_hero_wisp",0,0)
    end
  end



  -- Remove all the platforms
  ClearPlatforms()
  local winTeam = GameMode:FindTheOnlyConnectedTeam()
  if winTeam and not SINGLE_PLAYER_GAME then
    statCollection:submitRound(true)
    DeclareWinningTeam(GameMode:FindTheOnlyConnectedTeam())
    return
  end

  if not resetcount then resetcount = 0 end
  resetcount = resetcount +1

  if not CustomNetTables:GetTableValue("settings","nAmountOfRounds").value then
    CustomNetTables:SetTableValue("settings","nAmountOfRounds",{value = "50"})
  end
  if tonumber(CustomNetTables:GetTableValue("settings","nAmountOfRounds").value) ~= -1 and resetcount >= tonumber(CustomNetTables:GetTableValue("settings","nAmountOfRounds").value) then 
    DebugPrint(1,"[SMASH] The last round has been played")
    local score = 0
    local winner = DOTA_TEAM_GOODGUYS
    for i=0,3 do
      if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetTeam(i) ~= DOTA_TEAM_NOTEAM then
        assists = PlayerResource:GetAssists(i)
        if assists > score then
          score = assists
          winner = PlayerResource:GetTeam(i)
        end
      end
    end
    CustomGameEventManager:Send_ServerToAllClients("reset_camera",{})
    statCollection:submitRound(true)
    DeclareWinningTeam(winner)
    return
  else
    statCollection:submitRound(false)
    spawnPlatform()
  end
  
  -- Map pick stuff -- Before or after hero pick?
  --[[mapPickTimerStarted = false
  GameMode:MapPickStarted()
  
  ]]
  -- Stun all alive heroes first
  for i=0,3 do
      if PlayerResource:IsValidPlayerID(i) then
        if PlayerResource:GetSelectedHeroEntity(i) and PlayerResource:GetSelectedHeroEntity(i):IsAlive() then
          PlayerResource:GetSelectedHeroEntity(i):AddNewModifier(PlayerResource:GetSelectedHeroEntity(i),nil,"modifier_smash_stun",{})
        end
      end
    end

  -- Hero pick stuff
  GameMode.heroesPicked = nil
  GameMode.heroesPicked = {}
  GameMode.playersPicked = nil
  GameMode.playersPicked = {}
  
  heroPickTimerStarted = false
  GameMode["lifeTable"] = {}
  GameMode:HeroPickStarted()

end
function DeclareWinningTeam(winningTeam)
  DebugPrint(1,"[SMASH] Winning team has been declared")
  GameRules:SetGameWinner(winningTeam)
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint(1,'[BAREBONES] Starting to load Barebones gamemode...')
  self:SetupGame()

  for k,v in pairs(Rules) do
    CustomNetTables:SetTableValue("settings", k, {value=v})
  end
  -- Update the value for debugging
  CustomNetTables:SetTableValue("settings","debug_spew",{value =PANORAMA_DEBUG_SPEW})
  -- Send the hero ratings to the client. 
  HeroRatingsPlayerTable()

  
  
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode,"FilterExecuteOrder"),self)
  GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(push,"DamageFilter"),self)
  GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(GameMode,"ModifierGainedFilter"),self)

  --Listening to events
  CustomGameEventManager:RegisterListener("key_event", Dynamic_Wrap(control, 'KeyEvent'))
  CustomGameEventManager:RegisterListener("request_start", Dynamic_Wrap(GameMode, 'RequestStart'))
  CustomGameEventManager:RegisterListener("setting_change", Dynamic_Wrap(GameMode, 'ChangeRadioSettings'))
  CustomGameEventManager:RegisterListener("ally_selection", Dynamic_Wrap(GameMode, 'StoreAlliedRequest'))
  CustomGameEventManager:RegisterListener("submit_pick", Dynamic_Wrap(GameMode, 'ConfirmHeroPick'))
  CustomGameEventManager:RegisterListener("get_lifes", Dynamic_Wrap(GameMode, 'SetStartingLifes'))
  CustomGameEventManager:RegisterListener("player_leaves", Dynamic_Wrap(GameMode, 'CheckLeftoverPlayers'))
  CustomGameEventManager:RegisterListener("player_votes_endscreen", Dynamic_Wrap(GameMode, 'StoreEndScreenVote'))
  CustomGameEventManager:RegisterListener("player_forfeits", Dynamic_Wrap(GameMode, 'PlayerForfeitsRound'))
  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand( "reload_kv", Reload_AbilityKeyValues, "Reloads values from npc_abilities files", FCVAR_CHEAT )
  Convars:RegisterCommand( "add_obj", Dynamic_Wrap(Physics2D, 'CreateObject'), "Reloads values from npc_abilities files", FCVAR_CHEAT )


  DebugPrint(1,'[BAREBONES] Done loading Barebones gamemode!\n\n')
end 

function GameMode:PlayerForfeitsRound(keys)
  Timers:CreateTimer(0.1,function()
    DebugPrint(1,"[SMASH] [TIMERS] Gamemode, Forfeit")
    local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    Timers:CreateTimer(1/30,function()
      if not hero:IsAlive() then
        hero:RespawnHero(false,false,false)
      end
      
      PlayerTables:SetTableValue(tostring(keys.PlayerID),"lifes",0)
      hero:ForceKill(false)
    end)
  end)
end
function GameMode:StoreEndScreenVote(keys)
  -- Everything is already sent at this point, find something else
  GameMode.endScreenVotes = GameMode.endScreenVotes or {}
  GameMode.endScreenVotes[keys.PlayerID] = keys.vote
end

function GameMode:CheckLeftoverPlayers(keys)

  DebugPrint(1,"GameMode:CheckLeftoverPlayers")
  Timers:CreateTimer(0.1,function()
    local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
    if not hero:IsAlive() then
      hero:RespawnHero(false,false,false)
    end
    Say(PlayerResource:GetPlayer(keys.PlayerID),"I am out!",false)
    PlayerTables:SetTableValue(tostring(keys.PlayerID),"lifes",0)
    hero:ForceKill(false)

    PlayerResource:UpdateTeamSlot(keys.PlayerID,DOTA_TEAM_NOTEAM,0)
    local winning = GameMode:FindTheOnlyConnectedTeam()
    if winning then 
      statCollection:submitRound(true)
      DeclareWinningTeam(winning)
      return
    end


    if GameRules:PlayerHasCustomGameHostPrivileges(PlayerResource:GetPlayer(keys.PlayerID)) then
      statCollection:submitRound(true)
      DeclareWinningTeam(1)
    else
      -- Show screen to player (Done clientside)
    end 
  end)
end

function GameMode:SetStartingLifes(keys)
  GameMode["lifeTable"] = GameMode["lifeTable"] or {}
  GameMode["lifeTable"][keys.PlayerID+1] = keys.nStartingLifes
  local number = 0
  for k,v in pairs(GameMode["lifeTable"]) do
    number = number + v
  end
  number  = math.ceil(number / #GameMode["lifeTable"])
  CustomNetTables:SetTableValue("settings","nStartingLifes",{value = number})
  for i=0,3 do
    if PlayerResource:IsValidTeamPlayerID(i) then
      PlayerTables:SetTableValue(tostring(i),"lifes",number)
    end
  end
end

function GameMode:RequestStart(keys)
  if GAME_HAS_STARTED then return end
  GAME_HAS_STARTED = true
  CustomGameEventManager:Send_ServerToAllClients("start_game",{})
end

function Reload_KeyValues()
  print("Reloading Ability files")
  ABILITIES_TXT = LoadKeyValues("scripts/npc/npc_abilities.txt")
  for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_override.txt")) do ABILITIES_TXT[k] = v end
  for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_custom.txt")) do ABILITIES_TXT[k] = v end
end
-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end



function GameMode:SetupGame()
  DebugPrint(1,"[SMASH] Setting up values and gamemode")
  -- Store values

  -- Heroes for randoming
  allowedHeroes = {
  -- Str
    "npc_dota_hero_tusk",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_rattletrap",
    "npc_dota_hero_axe",
    "npc_dota_hero_magnataur",
    "npc_dota_hero_phoenix",
    "npc_dota_hero_pudge",
    "npc_dota_hero_kunkka",
    "npc_dota_hero_centaur",
  -- Agi
    "npc_dota_hero_mirana",
    "npc_dota_hero_nyx_assassin",
    "npc_dota_hero_vengefulspirit",
    "npc_dota_hero_nevermore",
  -- Int
    "npc_dota_hero_tinker",
    --"npc_dota_hero_batrider", -- Lasso is broken, hero isnt great either.
    "npc_dota_hero_lina",
    "npc_dota_hero_puck",
    "npc_dota_hero_zuus",
    "npc_dota_hero_storm_spirit",
    "npc_dota_hero_techies",
  }

  GameMode.heroesPicked = {}
  GameMode.playersPicked = {}
  Rules = {
    -- Things that should be changable
    nStartingLifes= 1, -- Starting Lifes
    nAmountOfRounds = 50, -- How many rounds are we playing?

    -- Radio options
    MapSelection = 1, -- Should the maps be switched
    HeroSelection = 1, -- Force a random?
    Format = 1, -- Teams or ffa?
    

  }
end

function GameMode:ChangeRadioSettings(keys)
  GameMode[keys.setting] = GameMode[keys.setting] or {}
  GameMode[keys.setting][keys.PlayerID] = keys.value

  local count = {}

  for i = 0,3 do
    if PlayerResource:IsValidPlayerID(i) then
      if GameMode[keys.setting][keys.PlayerID] then
        count[GameMode[keys.setting][keys.PlayerID]] = (count[GameMode[keys.setting][keys.PlayerID]] or 0) + 1
      end
    end
  end
  local max = 0
  local highest
  for k,v in pairs(count) do
    if v > 0 then
      max = v
      highest = k
    end
  end
  CustomNetTables:SetTableValue("settings",keys.setting,{value =highest})
end

function GameMode:OnHeroDeath(hero)
  if not hero:IsRealHero() then return end
  hero:SetAbsOrigin(cameraDummyUnit:GetAbsOrigin())
  DebugPrint(1,"[SMASH] A hero died")
  -- Store the lifes to display on client
  PlayerTables:SetTableValue(tostring(hero:GetPlayerOwnerID()), "lifes", PlayerTables:GetTableValue(tostring(hero:GetPlayerOwnerID()), "lifes") -1)
  if hero.lastAttacker then
    killerID = hero.lastAttacker:GetPlayerOwnerID()
    PlayerResource:IncrementKills(killerID, 1)
    hero.lastAttacker = nil
  end
  
  if PlayerTables:GetTableValue(tostring(hero:GetPlayerOwnerID()),"lifes") <= -1 then
    --hero:StopPhysicsSimulation()
    hero:SetRespawnsDisabled(true)
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(),"reset_camera",{})
    deadplayers = deadplayers + 1
    if deadplayers >= PlayerResource:GetTeamPlayerCount() -1 then
      -- Resetting
      deadplayers = 0

      -- Find the player with lives left
      for i=0, PlayerResource:GetTeamPlayerCount()-1 do
        if tonumber(  PlayerTables:GetTableValue(tostring(i),"lifes")) >= 0 then
          -- Use assists to track score for now
          GameRules.Winner = PlayerResource:GetTeam(i)
          PlayerResource:IncrementAssists(i,i)
        end
      end
      DebugPrint(1,"[SMASH] Found the last player alive")
      GameMode:Reset()
    end

    -- If there are teams, check if there is someone on a team still alive
    if PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS) == 2 or PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS) == 2 then
      
      local A0 = CustomNetTables:GetTableValue("settings","A0").value
      local A1 = CustomNetTables:GetTableValue("settings","A1").value
      local B0 = CustomNetTables:GetTableValue("settings","B0").value
      local B1 = CustomNetTables:GetTableValue("settings","B1").value

      -- Check for A0 and A1 if they have lifes
      if PlayerTables:GetTableValue(tostring(A0), "lifes") + PlayerTables:GetTableValue(tostring(A1), "lifes") < -1 then
        -- No lifes
        PlayerResource:IncrementAssists(B0)
        PlayerResource:IncrementAssists(B1)
        GameMode:Reset()
      end
      if PlayerTables:GetTableValue(tostring(B0), "lifes") + PlayerTables:GetTableValue(tostring(B1), "lifes") < -1 then
        -- No lifes
        PlayerResource:IncrementAssists(A0)
        PlayerResource:IncrementAssists(A1)
        GameMode:Reset()
      end
    end
    
  end



  -- Remove ourselves from any platform
  if platform then
    for k,v in pairs(platform) do
      if v.unitsOnPlatform then
        v.unitsOnPlatform[hero] = nil
      end
    end
  end
end

function GameMode:OnDisconnect(keys)
  DebugPrint(1,'[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(1,keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.PlayerID

  if GameRules:State_Get() == DOTA_GAMERULES_STATE_POST_GAME or GameRules:State_Get() == DOTA_GAMERULES_STATE_DISCONNECT then
    DebugPrint(1,'[SMASH] Player Disconnected after the game')
    return
  end
  Timers:CreateTimer(1,function()
    DebugPrint(1,"[SMASH] [TIMERS] Gamemode, Forfeit")
    local hero = PlayerResource:GetSelectedHeroEntity(userid)
    if not hero:IsAlive() then
      hero:RespawnHero(false,false,false)
    end
    
    PlayerTables:SetTableValue(tostring(userid),"lifes",0)
    hero:ForceKill(false)

    if GameMode:FindTheOnlyConnectedTeam() then
      statCollection:submitRound(true)
      DeclareWinningTeam(GameMode:FindTheOnlyConnectedTeam())
    end

  end)
end
  --[[
  local team = PlayerResource:GetTeam(userid)
  -- Check if the team still has players
  print("teams in leaver team "..PlayerResource:GetPlayerCountForTeam(team))
  if PlayerResource:GetPlayerCountForTeam(team) > 0 then
    return
  end

  if CustomNetTables:GetTableValue("settings","Format").value ~= "2" then -- not 2v2
    -- Here the team has no more players left
    if PlayerResource:GetTeamPlayerCount() <= 1 then
      DeclareWinningTeam(FindTheOnlyConnectedTeam())
      return
    else
      return
    end
  else -- Game is 2v2
    DeclareWinningTeam(FindTheOnlyConnectedTeam())
    return
  end
end
]]
function GameMode:FindTheOnlyConnectedTeam()
  DebugPrint(1,'[SMASH] Finding the only connected team')

  local teams = {}
  local winning
  local teamsLeft = 0
  for i=0,10 do
    teams[i] = 0
  end

  for i=0,3 do
    if PlayerResource:IsValidTeamPlayerID(i) then 
      if PlayerResource:GetTeam(i) == DOTA_TEAM_NOTEAM or PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_ABANDONED or PlayerResource:GetConnectionState(i) ~= DOTA_CONNECTION_STATE_DISCONNECTED then
        teams[PlayerResource:GetTeam(i)] = teams[PlayerResource:GetTeam(i)] + 1
      end
    end
  end

  for i=0,10 do
    if  i ~= 5 and teams[i] > 0 then
      teamsLeft = teamsLeft + 1
      winning = i
    end
  end

  if teamsLeft == 0 then
    return teams[1]
  elseif
    teamsLeft == 1 then
    return winning
  else 
    return 
  end
  return
end

function GameMode:ModifierGainedFilter(keys)
  if not keys["entindex_caster_const"] then return true end
  -- If the same modifier would be applied, check the duration so that the longest one counts.
  local modifierCasterIndex = keys["entindex_caster_const"]

  local caster = EntIndexToHScript(modifierCasterIndex)
  local modifierAbilityIndex = keys["entindex_ability_const"]
  if modifierAbilityIndex then
    local modifierAbility = EntIndexToHScript(modifierAbilityIndex)
  end
  local modifierDuration = keys["duration"]
  local modifierTargetIndex =  keys["entindex_parent_const"]
  local target = EntIndexToHScript(modifierTargetIndex)
  local modifierName = keys["name_const"]

  -- Checking if the new modifier last longer than the old one. -- Replaced by allowing multiple modifiers
  --[[if target:HasModifier(modifierName) then
    if target:FindModifierByName(modifierName):GetRemainingTime() > modifierDuration then
      keys["duration"] = target:FindModifierByName(modifierName):GetRemainingTime()
    end
  end]]

  if target.bShieldActivated and caster:GetTeamNumber() ~= target:GetTeamNumber() then
    return false
  end
   

  return true
end