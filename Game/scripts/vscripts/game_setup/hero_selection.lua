function GameMode:ConfirmHeroPick(keys)
  DebugPrint(1,"[SMASH] [HERO SELECTION] ConfirmHeroPick")
  local pID = keys.PlayerID
  local heroname = keys.heroname

  -- If this hero has been picked do nothing?
  if GameMode.heroesPicked[heroname] then return end
  if PlayerTables:GetTableValue(tostring(pID.."heroes"),heroname) then return end
  if GameMode.playersPicked[pID] then return end
  
  if heroname == "npc_dota_hero_wisp" then
    heroname = "npc_dota_hero_"
  end
  if heroname == "npc_dota_hero_" then
    GetRandomHero(pID)
  else
    
    fullHeroname = heroname
    heroname=string.sub(heroname, 15)
    SubmitHeroPick(pID,heroname)
  end

  -- Start a timer to random heroes for players who haven't picked after some seconds
  if not heroPickTimerStarted then
    heroPickTimerStarted = true
    local time = 10
    if IsInToolsMode() then
      time = 2
    end
    Timers:CreateTimer(time,function()
      DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] ConfirmHeroPick")
      for i=0, 3 do
        if not GameMode.playersPicked[i] and PlayerResource:IsValidTeamPlayerID(i) and PlayerResource:GetTeam(i) ~= DOTA_TEAM_NOTEAM then
          GetRandomHero(i,true)
        end
      end
      -- Remove the pick screen and play!
      CustomGameEventManager:Send_ServerToAllClients("kill_pick_screen",{})
      -- Unstun them
      for i=0,3 do
        local hero = PlayerResource:GetSelectedHeroEntity(i)
        if hero then
          hero:RemoveModifierByName("modifier_smash_stun")
        end
      end
    end)
  end
end

function GetRandomHero(pID,bForced)
  DebugPrint(1,"[SMASH][HERO SELECTION] GetRandomHero")
  local random = RandomInt(1,#allowedHeroes)
  local fullHeroname = allowedHeroes[random]
  
  
  heroname=string.sub(allowedHeroes[random], 15)
  
  Timers:CreateTimer(function()
    DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] GetRandomHero")
    if not PlayerResource:GetSelectedHeroEntity(pID) then
      return 0.1
    else
      while GameMode.heroesPicked[fullHeroname] or PlayerTables:GetTableValue(tostring(pID.."heroes"),fullHeroname) do
        random = RandomInt(1,#allowedHeroes)
        fullHeroname = allowedHeroes[random]
        DebugPrint(2,"[SMASH] [HERO SELECTION] Looping in hero HeroSelection")
      end
      heroname=string.sub(fullHeroname, 15)
      SubmitHeroPick(pID,heroname,bForced)
      return nil
    end
  end)
end

function RandomForAll()
  DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] RandomForAll")
  for i=0,3 do
    if PlayerResource:IsValidPlayerID(i) then
      GetRandomHero(i,true)
    end
  end
  Timers:CreateTimer(10,function()
    CustomGameEventManager:Send_ServerToAllClients("kill_pick_screen",{})
  end)
  --for i=0,3 do
  --  local hero = PlayerResource:GetSelectedHeroEntity(i)
  -- if hero then
  --    hero:RemoveModifierByName("modifier_smash_stun")
  --  end
  --end
end

function GameMode:HeroPickStarted()
  DebugPrint(1,"[SMASH] [Hero_Selection] The hero selection phase started")
  -- Check if all random is active
  if  CustomNetTables:GetTableValue("settings","HeroSelection").value == "2" then
    Timers:CreateTimer(1,function()
      CustomGameEventManager:Send_ServerToAllClients("kill_ally_selection_screen",{})
      CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
      RandomForAll()
    end)
  else
    CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
    
  end
end


function ReplaceHero(pID,heroname)
  DebugPrint(1,"[SMASH] [HERO SELECTION] ReplaceHero")
  local oldhero = PlayerResource:GetSelectedHeroEntity(pID)
  local hero = PlayerResource:ReplaceHeroWith(pID,heroname,0,0)
  
    if not hero then
      hero = PlayerResource:ReplaceHeroWith(pID,heroname,0,0)
      return false
    else
      if oldhero and IsValidEntity(oldhero) then
        UTIL_Remove(oldhero)
      end
      return hero
    end
  
end

function SubmitHeroPick(pID,heroname,bForcedRandom)
  DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] SubmitHeroPick")
  CustomGameEventManager:Send_ServerToAllClients("hero_pick_accepted",{pid=pID,heroname=heroname})
  --[[local playerID = "Player"..pID
  if not playerID then
    playerID = {}
  end]]

  

  GameMode.playersPicked[pID] = true
  fullHeroname = "npc_dota_hero_"..heroname
  -- Somehow replace hero doesn't always return something anymore
  Timers:CreateTimer(1/30,function()
    local check = ReplaceHero(pID,fullHeroname)
    if check then
      if not bForcedRandom then
        -- Stun heroes so they dont do stuff while we cant see it
        PlayerResource:GetSelectedHeroEntity(pID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(pID),nil,"modifier_smash_stun",{})
      end
      GameMode.heroesPicked[fullHeroname] = true
      PlayerTables:SetTableValue(tostring(pID.."heroes"),PlayerResource:GetSelectedHeroEntity(pID):GetUnitName(),true)
      return false
    else
      print("ReplaceHeroWith Failed...")
      return 1/30
    end
  end)
  
  
  
  
end