function spawnPlatform()
  DebugPrint(1,"[SMASH] [PLATFORMS] spawnPlatform")
  --print("Created Platforms")
  
  -- For rotation use values that are divisible by 9 instead of 10 for easier maths, also don't go over 90, use negative values then instead
  -- Rotation is broken
  -- Walls are just used to prevent getting under the lowest platform, might get use in the future
  if platform then
    for k,v in pairs(platform) do
      UTIL_Remove(v)
    end
  end

  if items.itemStorage then
    for k,v in pairs(items.itemStorage) do
      UTIL_Remove(v)
    end
  end

  wall = {}
  platform = {}
  
  -- Get map name from nettable or pick it randomly
  
  mapnames2 = {
    [1] = "MapSmall",
    [2] = "MapSmallDestructable",
    [3] = "MapFerrisWheel",
    [4] = "MapSliders",
  }
  mapnames3 = {
    [1] = "MapSmall",
    [2] = "MapSmallDestructable",
    [3] = "MapMedium",
    [4] = "MapLargeDestructable",
    [5] = "MapFerrisWheel",
    [6] = "MapSliders",
  }
  mapnames4 = {
    [1] = "MapMedium",
    [2] = "MapLargeDestructable",
    [3] = "MapFerrisWheel",
    [4] = "MapSliders",
    
  }
  if PlayerResource:GetTeamPlayerCount() == 1 then
    mapname =  mapnames3[RandomInt(1,#mapnames3)]
  elseif PlayerResource:GetTeamPlayerCount() == 2 then
    mapname = mapnames2[RandomInt(1,#mapnames2)]
  elseif PlayerResource:GetTeamPlayerCount() == 3 then
    mapname =  mapnames3[RandomInt(1,#mapnames3)]
  else
    mapname = mapnames4[RandomInt(1,#mapnames4)]
  end
  --print(mapname)

  _G[mapname]()

end

function ClearPlatforms()
  DebugPrint(1,"[SMASH] [PLATFORMS] ClearPlatform")
  for k,v in pairs(platform) do
    UTIL_Remove(v)
  end
  platform = nil
end

function MovePlatform(hPlatform,flSpeed,sDirection,flTimeTilLReverse) -- sDirection inputs are (up,down,left,right)
  DebugPrint(1,"[SMASH] [PLATFORMS] MovePlatform")
  local directions = {
    up = Vector(0,0,1),
    down = Vector(0,0,-1),
    left = Vector(-1,0,0),
    right = Vector(1,0,0),
  }

  if not directions[sDirection] then
    print("Directions is not properly passed, inputs are up,down,left,right as string") 
    return
  end
  local direction = directions[sDirection]

  -- Start moving in the direction
  Timers:CreateTimer(1/32,function()
    DebugPrint(2,"[SMASH] [TIMER] [PLATFORMS] MovePlatform")
    if not IsValidEntity(hPlatform) then return end
    if not hPlatform.count then 
      hPlatform.count = 1
    else
      hPlatform.count = hPlatform.count + 1
    end
    -- Turn around
    if not flTimeTilLReverse or hPlatform.count > flTimeTilLReverse * 32 then
      if sDirection == "up" or sDirection == "down" then
        direction.z = direction.z*-1
      else
        direction.x = direction.x*-1
      end
      hPlatform.count = 0 
    end
    hPlatform:SetAbsOrigin(hPlatform:GetAbsOrigin() + direction * flSpeed)
    -- Move units on the platform along
    for k,v in pairs(hPlatform.unitsOnPlatform) do
      if not k:IsNull() then
        k:SetAbsOrigin(k:GetAbsOrigin() + direction * flSpeed)
      end
    end

    --[[ Move the obstruction objects along
    for k,v in pairs(hPlatform.obstructionObjects) do
      v:SetAbsOrigin(v:GetAbsOrigin()+ direction * flSpeed)
    end]]

    return 1/32
  end)
end

function RotatePlatformAroundPoint(hPlatform,vBaseLocation,flRadius,flSpeed,bClockWise)
  DebugPrint(1,"[SMASH] [PLATFORMS] RotatePlatformAroundPoint")
  if not hPlatform then return end
  if hPlatform:IsNull() then return end
  if not flSpeed then 
    flSpeed = 1 
  end

  -- Translating the direction
  local direction = flSpeed
  if not bClockWise then
    direction = -flSpeed
  end 
  

  -- Starting the timer to loop its rotation
  local count = 0

  Timers:CreateTimer(1/32,function()
    DebugPrint(2,"[SMASH] [TIMER] [PLATFORMS] RotatePlatformAroundPoint")
    if not hPlatform then return end
    if hPlatform:IsNull() then return end
    -- Get the remainder of 360
    local count = hPlatform.rotationCount 
    count = math.fmod(count, 360)

    -- Get the position of the platform and add the new rotation to it
    --local pos = hPlatform:GetAbsOrigin() - vBaseLocation
    local angle = --[[math.atan2(pos.z, pos.x) +]] 2*math.pi*(count/360)

    local newPos = vBaseLocation + flRadius * Vector(math.cos(angle), 0, math.sin(angle))
    hPlatform:SetAbsOrigin(newPos)


    -- Move units on the platform along
    for k,v in pairs(hPlatform.unitsOnPlatform) do
      if hPlatform.oldPos and not k:IsNull() then
        k:SetAbsOrigin(k:GetAbsOrigin()+(newPos - hPlatform.oldPos))
      end
    end
    hPlatform.oldPos = newPos
    hPlatform.rotationCount = count + direction
    return 1/32
  end)
end

function CDOTA_BaseNPC:isOnPlatform()
  DebugPrint(2,"[SMASH] [PLATFORMS] isOnPlatform")
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z


  if not platform then return end

  sortPlatforms()
  self.rotation = nil
  for k,v in pairs(platform) do
    v.unitsOnPlatform[self] = nil
  end

  for k,v in pairs(platform) do
    -- Check if the unit has the same x coordinates as the platform
    if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then

      -- If rotation is over (X) then slide backward?
      -- Adjust movement to the platform
      self.rotation = v:GetAngles().x
      --[[
      if self:GetForwardVector().x >= 0 then
        self:SetAngles(self.rotation,0,0)
      else
        --print(self.rotation)
        self:SetFor
      end]]
      local distance_from_center = x - v:GetAbsOrigin().x
      local delta_z = (-distance_from_center / 55) * self.rotation

      -- Check if the height matches as well
      if z >= v:GetAbsOrigin().z + v.height - (Laws.flDropSpeed) + delta_z and z<= v:GetAbsOrigin().z + v.height + (Laws.flDropSpeed * 0.5) + delta_z then

        -- Slide the unit down
        -- 0 means nothing, 45 means half general movespeed so 90 is general movespeed.
        local delta_x = Laws.flMove * (self.rotation/90)
        local delta_z = (-delta_x / 55) * self.rotation /2
        --print(delta_x,delta_z)
        self:SetAbsOrigin(Vector(self:GetAbsOrigin().x+delta_x,0,self:GetAbsOrigin().z+delta_z))

        v.unitsOnPlatform[self] = true
        return true
      end

      



    
    end
  end
  return false
end

function CDOTA_BaseNPC:isUnderPlatform()
  DebugPrint(2,"[SMASH] [PLATFORMS] isUnderPlatform")
  if not platform then return end
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z
  local v = platform[1]
  -- Check if x coordinates match with platform
  if v and  not v:IsNull() then
    if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
      -- Check height
      if z >= v:GetAbsOrigin().z - Laws.flJumpSpeed and z<= v:GetAbsOrigin().z + v.height - Laws.flJumpSpeed then
        return true
      end
    end
  end
  return false
end

function RotatePlatform(hPlatform,flRotation)
  DebugPrint(1,"[SMASH] [PLATFORMS] RotatePlatform")
  if hPlatform:IsNull() then return end
  
  if not hPlatform.originalRadius  then 
    hPlatform.originalRadius = hPlatform.radius
  end
  flRotation = flRotation +  hPlatform:GetAngles().x
  if flRotation >= 90 then
    flRotation = -flRotation
  end 
  -- Update the radius
  local delta_z = (hPlatform.originalRadius / 55) *flRotation
  local radius = math.sqrt(math.pow(hPlatform.originalRadius,2) -  math.pow(delta_z,2))
  -- Move the units on it along
  --[[for k,v in pairs(hPlatform.unitsOnPlatform) do
    if IsValidEntity(k) then
      local distance_from_center = k:GetAbsOrigin().x - hPlatform:GetAbsOrigin().x
      local delta_z = (-distance_from_center / 55) *flRotation
      
      local correcting_x = radius / hPlatform.radius

      distance_from_center = distance_from_center * correcting_x
      print(distance_from_center,delta_z)
      k:SetAbsOrigin(Vector(hPlatform:GetAbsOrigin().x + distance_from_center,0,hPlatform:GetAbsOrigin().z+delta_z))
    end
  end]]
  hPlatform.radius = radius
  -- Rotate the platform
  hPlatform:SetAngles(flRotation,0,0)
end
function sortPlatforms()
  DebugPrint(2,"[SMASH] [PLATFORMS] sortPlatforms")
  if not platform then return end
  local sorted = {}
  local tempTable = {}
  for k,v in pairs(platform) do
    if not v:IsNull() then
      table.insert(sorted, k, v:GetAbsOrigin().z) 
    end 
  end
  local i=1
  -- spairs is found in util.lua, sorting the table with platform so that units will stay on the highest
  for k,v in spairs(sorted, function(t,a,b) return t[b] > t[a] end) do
    tempTable[i] = platform[k]
    i = i +1
  end
  platform = tempTable
  

end

function CDOTA_BaseNPC:CheckForWalls()
  DebugPrint(2,"[SMASH] [PLATFORMS] CheckForWalls")
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z


  if not wall then return end
  if self.lastLocation then 
  
    for k,v in pairs(wall) do
      --if v.owner and v.owner:GetTeamNumber() ~= self:GetTeamNumber() then return end
      -- Check if height matches first, then check position
      if not v:IsNull() then
        if z >= v:GetAbsOrigin().z - v.height and z<= v:GetAbsOrigin().z  + (v.height) -40 then
          if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
            self:SetAbsOrigin(Vector(self.lastLocation.x,0,self:GetAbsOrigin().z))
          end
        end
      end
    end
  end
  self.lastLocation = self:GetAbsOrigin()
  
end

function DestroyPlatform(hPlatform,flDuration)
  DebugPrint(1,"[SMASH] [PLATFORMS] DestroyPlatform")
  if not platform then return end
  local fadeTime = 5 -- 1 Divided by this
  local blinks = 5 -- Should be uneven
  local model = hPlatform:GetModelName()
  local radius = hPlatform.radius

  if not hPlatform.isDestructable then return end

  -- Do not interupt the platform movement, that doesn't matter

  -- Make it blink a few times before really being gone
  local hide = 1
  Timers:CreateTimer(1/fadeTime,function()
    if hide <= blinks then
      if math.fmod(hide,2) == 1 then
        hPlatform:SetModel("")
      else
        hPlatform:SetModel(model)
      end
      hide = hide +1
      return 1/fadeTime
    else
      hPlatform.radius = 0
      return nil
    end
  end)

  

  if flDuration then
    Timers:CreateTimer(flDuration,function()
      if not hPlatform:IsNull() then
        hPlatform:SetModel(model)
        hPlatform.radius = radius
      end
    end)
  end
end

function FindNearestPlatform(vLocation)
  DebugPrint(1,"[SMASH] [PLATFORMS] FindNearestPlatform")
  -- Use the location to spot nearby platforms
  for k,v in pairs(platform) do
    local abs = v:GetAbsOrigin()
    if abs.x - v.radius <= vLocation.x and abs.x + v.radius >= vLocation.x then
      if abs.z - v.height <= vLocation.z and abs.z + v.height >= vLocation.z then
        return v
      end
    end
  end
end