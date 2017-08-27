  

function SetWantedAlliesAsSelf() -- Use this to prevent nil values in the nettable
  DebugPrint(1,"[SMASH] [ALLY SELECTION] SetWantedAlliesAsSelf")
  for i=0,3 do 
    CustomNetTables:SetTableValue("settings","p"..i,{requested = i})
  end
end

function GameMode:StoreAlliedRequest(keys)
  DebugPrint(1,"[SMASH] [ALLY SELECTION] StoreAlliedRequest")
  if not hasStoredRequestedAllies then
    SetWantedAlliesAsSelf()
    hasStoredRequestedAllies = true
  end
  local requesting = keys.PlayerID
  local requested = keys.requested_ally
  
  -- Send to clients
  local table = {}
  table.requesting = requesting
  table.requested = requested
  
  CustomGameEventManager:Send_ServerToAllClients("confirm_allies",table)

  -- Store in table
  CustomNetTables:SetTableValue("settings","p"..requesting,{requested = requested})

  -- Start a timer to proceed to the next screen (Show teams)
  Timers:CreateTimer(ALLY_SELECTION_TIME,function()
    DebugPrint(1,"[SMASH] [TIMER] [ALLY SELECTION] SetWantedAlliesAsSelf1")
    local A0,A1,B0,B1 = MakeTeams()
    
    
    CustomNetTables:SetTableValue("settings","A0",{value = A0})
    CustomNetTables:SetTableValue("settings","A1",{value = A1})
    CustomNetTables:SetTableValue("settings","B0",{value = B0})
    CustomNetTables:SetTableValue("settings","B1",{value = B1})

    PlayerResource:UpdateTeamSlot(A0,DOTA_TEAM_CUSTOM_1,0)  
    PlayerResource:UpdateTeamSlot(A1,DOTA_TEAM_CUSTOM_1,1)
    PlayerResource:UpdateTeamSlot(B0,DOTA_TEAM_CUSTOM_2,0)
    PlayerResource:UpdateTeamSlot(B1,DOTA_TEAM_CUSTOM_2,1)

    if PlayerResource:IsValidPlayerID(A0) then
      GameMode.Players[PlayerResource:GetPlayer(A0)] = DOTA_TEAM_CUSTOM_1
    end
    if PlayerResource:IsValidPlayerID(A1) then
    GameMode.Players[PlayerResource:GetPlayer(A1)] = DOTA_TEAM_CUSTOM_1
    end
    if PlayerResource:IsValidPlayerID(B0) then
    GameMode.Players[PlayerResource:GetPlayer(B0)] = DOTA_TEAM_CUSTOM_2
    end
    if PlayerResource:IsValidPlayerID(B1) then
    GameMode.Players[PlayerResource:GetPlayer(B1)] = DOTA_TEAM_CUSTOM_2
    end
    
    CustomGameEventManager:Send_ServerToAllClients("show_teams",{})
    hasStoredRequestedAllies = nil
    Timers:CreateTimer(ALLY_DISPLAY_TIME,function()
      DebugPrint(1,"[SMASH] [TIMER] [ALLY SELECTION] SetWantedAlliesAsSelf2")
      --GameMode:HeroPickStarted()
    end)
  end)
end

function MakeTeams()
  DebugPrint(1,"[SMASH] [ALLY SELECTION] MakeTeams")
  local A0,A1,B0,B1
  -- Find couples
  local team_a = {}
  local coupleFound
  for i=0,2 do
    for j=i+1,3 do
        
      if CustomNetTables:GetTableValue("settings","p"..i).requested == j and CustomNetTables:GetTableValue("settings","p"..j).requested == i then
        team_a[i] = true
        team_a[j] = true
        coupleFound = true
        A0 = i
        A1 = j
        break
      end
    end
  end
  -- Find the other team
  team_b = {}
  if coupleFound then
    for i=0,3 do
      if not team_a[i] then
        team_b[i] = true
        if not B0 then
          B0 = i
        else
          B1 = i
        end
      end
    end
    -- Switch to keep p0 in team 1
    if not team_a[0] then
      temp = team_a
      team_a = team_b
      team_b = temp
      T0 = A0
      T0 = A0
      A0 = B0
      A1 = B1
      B0 = T0
      B1 = T0
    end
    for k,v in pairs(team_a) do
      team_a[k] = k
    end
    for k,v in pairs(team_b) do
      team_b[k] = k
    end
    return A0,A1,B0,B1
  end

   --Here 2 players didn't pick each other, it will be random
 

  local random = RandomInt(1,3)
  team_a[0] = true
  team_a[random] = true
  A0=0
  A1 = random


  for i=0,3 do
    if not team_a[i] then
      team_b[i] = true
      if not B0 then
        B0= i
      else
        B1=i
      end
    end
  end
  return A0,A1,B0,B1
end

