function GameMode:ConfirmHeroPick(keys)
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
    Timers:CreateTimer(10,function()
      for i=0, PlayerResource:GetTeamPlayerCount()-1 do
        if not GameMode.playersPicked[i] and PlayerResource:GetPlayer(i) then
          GetRandomHero(i)
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

function GetRandomHero(pID)
  local random = RandomInt(1,#allowedHeroes)
  local fullHeroname = allowedHeroes[random]
  while GameMode.heroesPicked[fullHeroname] or PlayerTables:GetTableValue(tostring(pID.."heroes"),fullHeroname) do
    random = RandomInt(1,#allowedHeroes)
    fullHeroname = allowedHeroes[random]
  end
  
  heroname=string.sub(allowedHeroes[random], 15)
  
  Timers:CreateTimer(0.1,function()
    if not PlayerResource:GetSelectedHeroEntity(pID) then
      return 0.1
    else
      SubmitHeroPick(pID,heroname)
      return nil
    end
  end)
end

function RandomForAll()
  for i=0,PlayerResource:GetTeamPlayerCount()-1 do
    GetRandomHero(i)
  end
  CustomGameEventManager:Send_ServerToAllClients("kill_pick_screen",{})
  for i=0,3 do
    local hero = PlayerResource:GetSelectedHeroEntity(i)
    if hero then
      hero:RemoveModifierByName("modifier_smash_stun")
    end
  end
end

function GameMode:HeroPickStarted()
  -- Check if all random is active
  if  CustomNetTables:GetTableValue("settings","HeroSelection").value == "2" then
    RandomForAll()
  else
    CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
  end
end


function ReplaceHero(pID,heroname)
  local oldhero = PlayerResource:GetSelectedHeroEntity(pID)
  PlayerResource:ReplaceHeroWith(pID,heroname,0,0)
  if oldhero and IsValidEntity(oldhero) then
    UTIL_Remove(oldhero)
  end
end

function SubmitHeroPick(pID,heroname)
  CustomGameEventManager:Send_ServerToAllClients("hero_pick_accepted",{pid=pID,heroname=heroname})
  --[[local playerID = "Player"..pID
  if not playerID then
    playerID = {}
  end]]

  GameMode.heroesPicked[heroname] = true
  GameMode.playersPicked[pID] = true
  fullHeroname = "npc_dota_hero_"..heroname
  ReplaceHero(pID,fullHeroname)
  -- Stun heroes so they dont do stuff while we cant see it
  PlayerResource:GetSelectedHeroEntity(pID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(pID),nil,"modifier_smash_stun",{})

  PlayerTables:SetTableValue(tostring(pID.."heroes"),PlayerResource:GetSelectedHeroEntity(pID):GetUnitName(),true)
  
end