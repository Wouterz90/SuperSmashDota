function GameMode:ConfirmHeroPick(keys)
  DebugPrint(1,"[SMASH] [HERO SELECTION] ConfirmHeroPick")
  local pID = keys.PlayerID
  local heroname = keys.heroname

  -- If this hero has been picked do nothing?
  --if not IsInToolsMode() then

    if GameMode.heroesPicked[heroname] then DebugPrint(1,"[SMASH] [HERO SELECTION] Already picked by another player") return end
    if PlayerTables:GetTableValue(tostring(pID.."heroes"),heroname) then DebugPrint(1,"[SMASH] [HERO SELECTION] Already picked in another round") return end
    if GameMode.playersPicked[pID] then return end
  --end
  if heroname == "npc_dota_hero_wisp" then
    heroname = "npc_dota_hero_"
  end
  if heroname == "npc_dota_hero_" then
    GetRandomHero(pID,false,false)
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
          GetRandomHero(i,true,false)
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

function GetRandomHero(pID,bForced,bStrategyPhase)
  DebugPrint(1,"[SMASH][HERO SELECTION] GetRandomHero")
  local random = RandomInt(1,#allowedHeroes)
  local fullHeroname = allowedHeroes[random]
  bStrategyPhase = bStrategyPhase or false
  
  heroname=string.sub(allowedHeroes[random], 15)
  
  Timers:CreateTimer(function()
    DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] GetRandomHero")
    --if not PlayerResource:GetSelectedHeroEntity(pID) then
    --  return 0.1
    --else
      while GameMode.heroesPicked[fullHeroname] or PlayerTables:GetTableValue(tostring(pID.."heroes"),fullHeroname) do
        random = RandomInt(1,#allowedHeroes)
        fullHeroname = allowedHeroes[random]
        DebugPrint(2,"[SMASH] [HERO SELECTION] Looping in hero HeroSelection")
      end
      heroname=string.sub(fullHeroname, 15)
      SubmitHeroPick(pID,heroname,bForced,bStrategyPhase)
      --return nil
    --end
  end)
end

function RandomForAll()
  DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] RandomForAll")
  for i=0,3 do
    if PlayerResource:IsValidPlayerID(i) then
      GetRandomHero(i,true,false)
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
      --CustomGameEventManager:Send_ServerToAllClients("kill_ally_selection_screen",{})
      --CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
      RandomForAll()
    end)
  else
    --CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
    
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

function SubmitHeroPick(pID,heroname,bForcedRandom,bStrategyPhase)
  DebugPrint(1,"[SMASH] [TIMER] [HERO SELECTION] SubmitHeroPick")
  CustomGameEventManager:Send_ServerToAllClients("hero_pick_accepted",{pid=pID,heroname=heroname})
  --[[local playerID = "Player"..pID
  if not playerID then
    playerID = {}
  end]]

  

  GameMode.playersPicked[pID] = true
  fullHeroname = "npc_dota_hero_"..heroname
  -- Somehow replace hero doesn't always return something anymore
  --Timers:CreateTimer(1/30,function()
    local check = PlayerResource:GetSelectedHeroEntity(pID) --ReplaceHero(pID,fullHeroname)
    if check then
      if not bForcedRandom then
        -- Stun heroes so they dont do stuff while we cant see it
        PlayerResource:GetSelectedHeroEntity(pID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(pID),nil,"modifier_smash_stun",{duration = 5})
      end
      GameMode.heroesPicked[fullHeroname] = true
      PlayerTables:SetTableValue(tostring(pID.."heroes"),PlayerResource:GetSelectedHeroEntity(pID):GetUnitName(),true)
      return false
    else

      local hero = CreateHeroForPlayer(fullHeroname,PlayerResource:GetPlayer(pID) )
      PlayerTables:SetTableValue(tostring(pID.."heroes"),fullHeroname,true)
      --if not bStrategyPhase then 
        UTIL_Remove(hero)
      --end
    end
  --end)
  
  
  
  
end