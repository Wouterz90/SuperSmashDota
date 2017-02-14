-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end
-- STATS!
require("statcollection/init")

-- This library allow for easily delayed/timed actions
require('libraries/timers')
require('libraries/worldpanels')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
--require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
--require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')
require('internal/util')

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
-- File to handle setup
require('game_setup/ally_selection')
-- File everything about hero picks
require('game_setup/hero_selection')
-- Store the hero ratings based on the balance tool based on ability values(not game stats!)
require('game_setup/heroratingvalues')



-- This is a detailed example of many of the containers.lua possibilities, but only activates if you use the provided "playground" map
if GetMapName() == "playground" then
  require("examples/playground")
end

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
  DebugPrint("[BAREBONES] Performing Post-Load precache")    
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
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
  spawnPlatform()

  for i=0,3 do
    if PlayerResource:GetPlayer(i) then
      local player = PlayerResource:GetPlayer(i)
      if player ~= nil then
        --player:MakeRandomHeroSelection()
        --PlayerResource:SetHasRepicked(i)
      end
    end
  end
  
  --CustomGameEventManager:Send_ServerToAllClients("register_keys",{}) 
end



--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  if hero:GetUnitName() == "npc_dota_hero_wisp" then
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:AddNoDraw() 
    hero:SetAbsOrigin(Vector(-3000,-3000,0))
    return 
  end
  if not firstHeroSpawned then 
    --spawnPlatform() 
    firstHeroSpawned = true 
  end

  
  if not IsValidEntity(hero) then return end
  deadplayers = 0
  
  --print("table created for "..hero:GetUnitName())
  if hero:IsRealHero() then
    DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
    -- Lock the camera on our hero
    CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(),"fix_camera",{})
    --PlayerResource:SetCameraTarget(hero:GetPlayerID(),hero)
    --GameRules:GetGameModeEntity():SetCameraDistanceOverride(1600)
    
    -- Init hero values here
    hero.jumps = 0
    hero.amplify = 1
    hero.movespeedFactor = 1
    hero.attackspeedFactor = 1
    -- Place the hero
    --hero:SetAbsOrigin(Vector(0,0,RandomInt(-500,500)))
    --PlayerResource:ReplaceHeroWith(hero:GetPlayerOwnerID(),hero:GetUnitName(),0,0)

    -- Make sure we control the hero and it doesn't control itself
    hero:SetAttackCapability(DOTA_UNIT_CAP_NO_ATTACK)
    hero:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    hero:SetRespawnsDisabled(false)
    hero:AddNewModifier(hero,nil,"modifier_jump",{duration = 1})
    Timers:CreateTimer(1.5,function()
      if hero then
        hero:AddNewModifier(hero,nil,"modifier_basic",{})
      end
    end)

    hero:AddAbility("basic_attack_mid")
    hero:AddAbility("basic_attack_top")
    hero:AddAbility("basic_attack_bottom")
    hero:AddAbility("basic_attack_left")
    hero:AddAbility("basic_attack_right")
    
    PrecacheUnitByNameAsync(hero:GetUnitName(), function(...) end)
    for i =0, 23 do
      local abil = hero:GetAbilityByIndex(i)
      if abil then
        PrecacheItemByNameAsync(abil:GetAbilityName(),function(...)end)
        abil:SetLevel(1)
      end
    end

  end
end


-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)
  Timers:CreateTimer(0.1,function()
    if not npc:IsNull() and npc:IsRealHero() then
      local hero = npc
      if hero:GetUnitName() == "npc_dota_hero_wisp" then
        hero:SetAbsOrigin(Vector(-3000,-3000,0))
        hero:AddNoDraw()
        return
      else
        hero:RemoveNoDraw()
      end
      
      --print(hero:GetUnitName()..hero:GetPlayerOwnerID())
      if not hero.firstRespawn then
        if not CustomNetTables:GetTableValue("settings","nStartingLifes") then
          CustomNetTables:SetTableValue("settings","nStartingLifes",{value = 5})
        end 
        PlayerTables:CreateTable(tostring(hero:GetPlayerOwnerID()),{lifes = CustomNetTables:GetTableValue("settings","nStartingLifes").value},true)
        PlayerTables:SetTableValue(tostring(hero:GetPlayerOwnerID()),"hero",hero:entindex())
        hero.firstRespawn = true  
      end
      hero:SetAbsOrigin(Vector(RandomInt(-500,500),0,500))
      hero.jumps = 0 
      hero:AddNewModifier(hero,nil,"modifier_jump",{duration=1})
      Timers:CreateTimer(1.5,function()
        hero:AddNewModifier(hero,nil,"modifier_basic",{})
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
  DebugPrint("[BAREBONES] The game has officially begun")
  if CustomNetTables:GetTableValue("settings","Format").value ~= "2" or PlayerResource:GetTeamPlayerCount() ~= 4 then -- not 2v2
    --Timers:CreateTimer(0.25,function()
      GameMode:HeroPickStarted()
    --  end)
  end
  
end
function GameMode:Reset()
  --CustomGameEventManager:Send_ServerToAllClients("reset_camera",{})
  -- This might have to change into round, counted from start
  if not resetcount then resetcount = 0 end
  resetcount = resetcount +1

  if not CustomNetTables:GetTableValue("settings","nAmountOfRounds").value then
    CustomNetTables:SetTableValue("settings","nAmountOfRounds",{value = "5"})
  end
  if tonumber(CustomNetTables:GetTableValue("settings","nAmountOfRounds").value) ~= -1 and resetcount > tonumber(CustomNetTables:GetTableValue("settings","nAmountOfRounds").value) then 
    GameRules:SetGameWinner(2)
  end
  
  --[[Remove all the platforms and walls
  for k,v in pairs(platform) do
    UTIL_Remove(v)
    v = nil
  end
  for k,v in pairs(wall) do
    UTIL_Remove(v)
    v = nil
  end]]
  
  GameMode.heroesPicked = nil
  GameMode.heroesPicked = {}
  GameMode.playersPicked = nil
  GameMode.playersPicked = {}
  
  heroPickTimerStarted = false
  
  GameMode:HeroPickStarted()

end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self

  self:SetupGame()

  for k,v in pairs(Rules) do
    CustomNetTables:SetTableValue("settings", k, {value=v})
  end

  HeroRatingsPlayerTable()

  
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')
  GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(GameMode,"FilterExecuteOrder"),self)
  GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(push,"DamageFilter"),self)

  --Listening to events
  CustomGameEventManager:RegisterListener("key_event", Dynamic_Wrap(control, 'KeyEvent'))
  CustomGameEventManager:RegisterListener("setting_change", Dynamic_Wrap(GameMode, 'ChangeSettings'))
  CustomGameEventManager:RegisterListener("ally_selection", Dynamic_Wrap(GameMode, 'StoreAlliedRequest'))
  CustomGameEventManager:RegisterListener("submit_pick", Dynamic_Wrap(GameMode, 'ConfirmHeroPick'))
  


  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
  Convars:RegisterCommand( "reload_kv", Dynamic_Wrap(GameMode, 'Reload_KeyValues'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end


function GameMode:Reload_KeyValues()
  GameRules:Playtesting_UpdateAddOnKeyValues()
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
  
  -- Store values
  allowedHeroes = {
  -- Str
    "npc_dota_hero_tusk",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_rattletrap",
  -- Agi
    "npc_dota_hero_mirana",
  -- Int
    "npc_dota_hero_tinker",
    "npc_dota_hero_lina",
    "npc_dota_hero_puck",
    "npc_dota_hero_zuus",
  }
  -- Basic values
  Laws = {

    
    flJumpSpeed = 30,
    flJumpDuration = 0.5,
    flDropSpeed = 20,
    flMove = 20,

    flMinDamage = 4,
    flMaxDamage = 8,
    flAttackRange = 75,
    flSideAttackFactor = 1.5,

    flMaxHeight = 2500,
    flMinHeight = -100,
  }

  GameMode.heroesPicked = {}
  GameMode.playersPicked = {}
  Rules = {
    -- Things that should be changable
    nStartingLifes= 0, -- Starting Lifes
    nAmountOfRounds = 5, -- How many rounds are we playing?

    -- Radio options
    MapSelection = 1, -- Should the maps be switched
    HeroSelection = 1, -- Force a random?
    Format = 1, -- Teams or ffa?
    
    -- Checkbox options
    duplicate_rounds = 0, -- Do we allow 2 the same heroes?

  }
end

function GameMode:ChangeSettings(keys)
  
  CustomNetTables:SetTableValue("settings",keys.setting,{value =keys.value})
end