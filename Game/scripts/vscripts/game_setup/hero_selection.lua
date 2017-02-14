function GameMode:ConfirmHeroPick(keys)
  local pID = keys.PlayerID
  local heroname = keys.heroname

  -- If this hero has been picked do nothing?
  if GameMode.heroesPicked[heroname] then return end
  if GameMode.playersPicked[pID] then return end
  
  if heroname == "npc_dota_hero_" then
    GetRandomHero(pID)
  else
    GameMode.heroesPicked[heroname] = true
    GameMode.playersPicked[pID] = true
    fullHeroname = heroname
    heroname=string.sub(heroname, 15)
    CustomGameEventManager:Send_ServerToAllClients("hero_pick_accepted",{pid=pID,heroname=heroname})
    PlayerResource:ReplaceHeroWith(pID,fullHeroname,0,0)
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
    end)
  end
end

function GetRandomHero(pID)
  local random = RandomInt(1,#allowedHeroes)
  while GameMode.heroesPicked[allowedHeroes[random]] do
    random = RandomInt(1,#allowedHeroes)
  end
  fullHeroname = allowedHeroes[random]
  heroname=string.sub(allowedHeroes[random], 15)
  
  Timers:CreateTimer(0.1,function()
    if not PlayerResource:GetSelectedHeroEntity(pID) then
      return 0.1
    else
      CustomGameEventManager:Send_ServerToAllClients("hero_pick_accepted",{pid=pID,heroname=heroname})
      GameMode.heroesPicked[random] = true
      GameMode.playersPicked[pID] = true
      PlayerResource:ReplaceHeroWith(pID,fullHeroname,0,0)
      return nil
    end
  end)
end

function RandomForAll()
  for i=0,PlayerResource:GetTeamPlayerCount()-1 do
    GetRandomHero(i)
  end
  CustomGameEventManager:Send_ServerToAllClients("kill_pick_screen",{})
end

function GameMode:HeroPickStarted()
  -- Check if all random is active
  if  CustomNetTables:GetTableValue("settings","HeroSelection").value == "2" then
    RandomForAll()
  else
    CustomGameEventManager:Send_ServerToAllClients("pick_heroes",{})
  end
end

