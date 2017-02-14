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
  
  -- Get map name from some event
  mapname = "MapSmallMedium"
  _G[mapname]()


  
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
        if z >= v:GetAbsOrigin().z + v.height - (Laws.flDropSpeed *2) and z<= v:GetAbsOrigin().z + v.height then
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
  local origin = self:GetAbsOrigin()
  local x = origin.x
  local z = origin.z
  local v = platform[1]
  -- Check if x coordinates match with platform
  if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
    -- Check height
    if z >= v:GetAbsOrigin().z - Laws.flJumpSpeed and z<= v:GetAbsOrigin().z + v.height - Laws.flJumpSpeed then
      return true
    end
  end
  return false
end


function sortPlatforms()
  local sorted = {}
  local tempTable = {}
  for k,v in pairs(platform) do
    table.insert(sorted, k, v:GetAbsOrigin().z)  
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
      if v.owner and v.owner:GetTeamNumber() ~= self:GetTeamNumber() then return end
      -- Check if height matches first, then check position
      if z >= v:GetAbsOrigin().z - v.height and z<= v:GetAbsOrigin().z  + (v.height) -80 then
        if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
          self:SetAbsOrigin(Vector(self.lastLocation.x,0,self:GetAbsOrigin().z))
        end
      end
    end
  end
  self.lastLocation = self:GetAbsOrigin()
  
end

--[[function CreateSimpleObstruction(flObjectRadius, flObjectHeight,vObjectCenter)
  local scale = 1
  local l = 128 * scale
  local h = 96 * scale

  -- Table for storing the objects
  local tab = {}

  local startingPoint = vObjectCenter - Vector(flObjectRadius,0,flObjectHeight)
  -- Move it a bit because it's centered
  startingPoint = startingPoint + Vector(l/2,0,0)

  -- Get the lowest amount of blocks to fully fill the object
  local num_blocks_height = math.ceil(flObjectHeight/h)
  local height_distance = flObjectHeight/num_blocks_height
  num_blocks_height = num_blocks_height * 2

  local num_blocks_length = math.ceil(flObjectRadius/l)
  local length_distance = flObjectRadius/num_blocks_length
  num_blocks_length = num_blocks_length * 2

  for i = 0,num_blocks_height-1 do
    for j = 0,num_blocks_length-1 do
      local point = startingPoint + Vector(j*length_distance,0,i*height_distance)
      local obs = SpawnEntityFromTableSynchronous("point_simple_obstruction", {origin = point})
      for k,v in pairs(obs:GetBounds()) do
        print(k,v)
      end
      obs:SetEnabled(true,true)
      table.insert(tab, obs)
    end
  end
  return tab
end]]