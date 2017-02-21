function spawnPlatform()
  --print("Created Platforms")
  
  -- For rotation use values that are divisible by 9 instead of 10 for easier maths, also don't go over 90, use negative values then instead
  -- Rotation is broken
  -- Walls are just used to prevent getting under the lowest platform, might get use in the future
  if platform then
    for k,v in pairs(platform) do
      UTIL_Remove(v)
    end
  end

  wall = {}
  platform = {}
  
  -- Get map name from nettable or pick it randomly
  
  mapnames = {
    [1] = "MapSmall",
    [2] = "MapMedium",
    [3] = "MapSmallWalls"
  }
  local mapname
  if PlayerResource:GetTeamPlayerCount() == 1 then
    mapname = mapnames[RandomInt(1,3)]
  elseif PlayerResource:GetTeamPlayerCount() == 2 then
    mapname = "MapSmall"
  elseif PlayerResource:GetTeamPlayerCount() == 3 then
    mapname =  mapnames[RandomInt(1,2)]
  else
    mapname = "MapMedium"
  end

  _G[mapname]()

end

function ClearPlatforms()
  for k,v in pairs(platform) do
    UTIL_Remove(v)
  end
  platform = nil
end

function MovePlatform(hPlatform,flSpeed,sDirection,flTimeTilLReverse) -- sDirection inputs are (up,down,left,right)
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

function CDOTA_BaseNPC:isOnPlatform()
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z


  if not platform then return end

  sortPlatforms()
  --self.rotation = nil -- Not used atm
  for k,v in pairs(platform) do
    v.unitsOnPlatform[self] = nil
  end

  for k,v in pairs(platform) do
    -- Check if the unit has the same x coordinates as the platform
    if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
      if not v.rotation then -- Use the straightforward method
        -- Check if the height matches as well
        if z >= v:GetAbsOrigin().z + v.height - (Laws.flDropSpeed) and z<= v:GetAbsOrigin().z + v.height + (Laws.flDropSpeed * 0.5)then
          v.unitsOnPlatform[self] = true

          return true
        end
      --[[else
         Rotated platforms do not work yet
        local distance_from_middle  =  x - v:GetAbsOrigin().x
        local factor_to_100 = 10/900
        local height_difference_per_unit = v.rotation * factor_to_100
        local platform_z = v:GetAbsOrigin().z + (distance_from_middle * height_difference_per_unit)
        --DebugDrawLine(v:GetAbsOrigin(),v:GetAbsOrigin()+Vector(v.radius,0,(distance_from_middle * height_difference_per_unit)),255,255,255,true,6)
        if z >= platform_z + v.height - Laws.flDropSpeed and z<= platform_z + v.height then
          self.rotation = v.rotation
          v.unitsOnPlatform[self] = true

          return true
        end]]
      end
    end
  end
  return false
end

function CDOTA_BaseNPC:isUnderPlatform()
  if not platform then return end
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z
  local v = platform[1]
  -- Check if x coordinates match with platform
  if not v:IsNull() then
    if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
      -- Check height
      if z >= v:GetAbsOrigin().z - Laws.flJumpSpeed and z<= v:GetAbsOrigin().z + v.height - Laws.flJumpSpeed then
        return true
      end
    end
  end
  return false
end


function sortPlatforms()
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
      hPlatform:SetModel(model)
      hPlatform.radius = radius
    end)
  end
end

function FindNearestPlatform(vLocation)
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