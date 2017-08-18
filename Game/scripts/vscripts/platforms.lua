function spawnPlatform()
  DebugPrint(1,"[SMASH] [PLATFORMS] spawnPlatform")
  --print("Created Platforms")
  
  -- For rotation use values that are divisible by 9 instead of 10 for easier maths, also don't go over 90, use negative values then instead
  -- Rotation is broken
  -- Walls are just used to prevent getting under the lowest platform, might get use in the future
  if platform then
    for k,v in pairs(platform) do
      Physics:RemoveCollider(v.colliderName)
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
  --
  mapnames2 = {
    [1] = "MapSmall",
    [2] = "MapSmallDestructable",
    [3] = "MapSliders",
    [4] = "MapSmallFunnel",
    [5] = "MapFerrisWheel",
    [6] = "MapPyramidSmall",
  }
  mapnames3 = {
    [1] = "MapSmall",
    [2] = "MapSmallDestructable",
    [3] = "MapMedium",
    [4] = "MapLargeDestructable",
    [5] = "MapSliders",
    [6] = "MapFerrisWheel",
    [7] = "MapPyramidSmall",
    [8] = "MapPyramidLarge",
    [9] = "MapSmallFunnel",
  }
  mapnames4 = {
    [1] = "MapMedium",
    [2] = "MapLargeDestructable",
    [3] = "MapSliders",
    [4] = "MapFerrisWheel",
    [5] = "MapPyramidLarge",
  }
  if PlayerResource:GetTeamPlayerCount() == 1 then
    mapname = "MapSmall"--mapnames3[RandomInt(1,#mapnames3)]
  elseif PlayerResource:GetTeamPlayerCount() == 2 then
    mapname = mapnames2[RandomInt(1,#mapnames2)]
  elseif PlayerResource:GetTeamPlayerCount() == 3 then
    mapname =  mapnames3[RandomInt(1,#mapnames3)]
  else
    mapname = mapnames4[RandomInt(1,#mapnames4)]
  end
  --print(mapname)
  CustomNetTables:SetTableValue("settings","map",{value = mapname})
  _G[mapname]()

end

function ClearPlatforms()
  DebugPrint(1,"[SMASH] [PLATFORMS] ClearPlatform")
  bNoSort = nil
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
  Timers:CreateTimer(FrameTime(),function()
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
    hPlatform.collider.box[1] = hPlatform.collider.box[1] + direction * flSpeed
    hPlatform.collider.box[2] = hPlatform.collider.box[2] + direction * flSpeed
    hPlatform.collider.box[3] = hPlatform.collider.box[3] + direction * flSpeed
    hPlatform.collider.box[4] = hPlatform.collider.box[4] + direction * flSpeed

    hPlatform.collider.velocity = direction * flSpeed
    hPlatform.collider.recalculate = true

    --[[ Move the obstruction objects along
    for k,v in pairs(hPlatform.obstructionObjects) do
      v:SetAbsOrigin(v:GetAbsOrigin()+ direction * flSpeed)
    end]]

    return FrameTime()
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
    local angle = --[[math.atan2(pos.z, pos.x) +]] math.pi*(2*count/360)

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
  DebugPrint(1,"[SMASH] [PLATFORMS] isOnPlatform")
  return self:HasModifier("modifier_on_platform")
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
  if not hPlatform or hPlatform:IsNull() then return end

  hPlatform.rotation = (hPlatform.rotation or 0) + flRotation

  hPlatform:GetAbsOrigin()
  hPlatform.collider.box[1] = RotatePosition(hPlatform:GetAbsOrigin(), QAngle(hPlatform.rotation,0,0), hPlatform.collider.box[1])
  hPlatform.collider.box[2] = RotatePosition(hPlatform:GetAbsOrigin(), QAngle(hPlatform.rotation,0,0), hPlatform.collider.box[2])
  hPlatform.collider.box[3] = RotatePosition(hPlatform:GetAbsOrigin(), QAngle(hPlatform.rotation,0,0), hPlatform.collider.box[3])
  hPlatform.collider.box[4] = RotatePosition(hPlatform:GetAbsOrigin(), QAngle(hPlatform.rotation,0,0), hPlatform.collider.box[4])

  hPlatform:SetAngles(hPlatform.rotation,0,0)

  hPlatform.collider.recalculate = true
end

function sortPlatforms()
  DebugPrint(2,"[SMASH] [PLATFORMS] sortPlatforms")
  if not platform then return end
  local sorted = {}
  local tempTable = {}
  for k,v in pairs(platform) do
    if not v:IsNull() and not bNoSort then
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


  if not platform then return end
  if self.lastLocation then 
  --[[
    for k,v in pairs(platform) do
      --if v.owner and v.owner:GetTeamNumber() ~= self:GetTeamNumber() then return end
      -- Check if height matches first, then check position
      if not v:IsNull() then
        if v.bIsWall then
          if z >= v:GetAbsOrigin().z - v.height and z<= v:GetAbsOrigin().z  + (v.height) -40 then
            if x >= v:GetAbsOrigin().x - v.radius and x <= v:GetAbsOrigin().x + v.radius then
              self:SetAbsOrigin(Vector(self.lastLocation.x,0,self:GetAbsOrigin().z))
            end
          end
        end
      end
    end]]
    if GridNav:IsWall(origin) then
      --self:SetAbsOrigin(Vector(self.lastLocation.x,0,self:GetAbsOrigin().z))
    end

  end
  self.lastLocation = self:GetAbsOrigin()
  
end

function DestroyPlatform(hPlatform,flDuration)
  DebugPrint(1,"[SMASH] [PLATFORMS] DestroyPlatform")
  flDuration = flDuration or 5
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
      hPlatform.destroyed = true
      return nil
    end
  end)

  

  if flDuration then
    Timers:CreateTimer(flDuration,function()
      if not hPlatform:IsNull() then
        hPlatform:SetModel(model)
        hPlatform.destroyed = nil
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

function FindPlatformsInRadius(vLocation,flRadius)
  DebugPrint(1,"[SMASH] [PLATFORMS] FindPlatformsInRadius")
  if not platform then return end
  local tab = {}
  local entsInRadius = Entities:FindAllInSphere(vLocation,flRadius)
  
  for K,V in pairs(entsInRadius) do
    if V.unitsOnPlatform then
      table.insert(tab, V)
    end
  end
  
  return tab
end

function GridNav:IsWall(pos)
  DebugPrint(2,"[SMASH] [PLATFORMS] IsWall")
  if not platform then return end
  for k,v in pairs(platform) do
    
    if not v:IsNull() and v.bIsWall then

      -- If there is no rotation keep in quick and simple.
      if v:GetAngles().x == 0 then
        if pos.z >= v:GetAbsOrigin().z - v.height and pos.z <= v:GetAbsOrigin().z  + (v.height) -32 then
          if pos.x >= v:GetAbsOrigin().x - v.radius and pos.x <= v:GetAbsOrigin().x + v.radius then 
            return true
          end
        end
        
      end
        
      -- Radius is adjusted in the rotate platform part
      
      if v.originalRadius then
        local delta_z = (v.originalRadius / 55) * v:GetAngles().x
        local height = v.height + (delta_z *2)

        if pos.z >= v:GetAbsOrigin().z - height and pos.z <= v:GetAbsOrigin().z  + (height) -80 then
          if pos.x >= v:GetAbsOrigin().x - v.radius and pos.x <= v:GetAbsOrigin().x + v.radius then 
            -- Now calculate if unit hits a wall based on distance from center
            local distance_from_center = pos.x - v:GetAbsOrigin().x
            local delta_z = (distance_from_center / 55) * v:GetAngles().x
            if pos.z >= v:GetAbsOrigin().z - v.height + delta_z - 0 and pos.z <= v:GetAbsOrigin().z  + v.height + delta_z -80  then
              return true
            end
          end
        end

      end
    end
  end
  return false
end

-- Edited, overwriting this function
function GetPlatformPosition(pos,unit)
 DebugPrint(2,"[SMASH] [PLATFORMS] GetGroundPosition")
  local x = pos.x
  local z = pos.z
  local this = {}

  if not platform then return end

  sortPlatforms()
  

  for i=#platform,1,-1 do
    -- Check if the unit has the same x coordinates as the platform
    if x >= platform[i]:GetAbsOrigin().x - platform[i].radius and x <= platform[i]:GetAbsOrigin().x + platform[i].radius then

      -- If rotation is over (X) then slide backward?
      -- Adjust movement to the platform

      local distance_from_center = x - platform[i]:GetAbsOrigin().x
      local delta_z = (-distance_from_center / 55) * platform[i]:GetAngles().x

      -- Check if the height matches as well
      if z >= platform[i]:GetAbsOrigin().z + platform[i].height - (Laws.flDropSpeed) + delta_z and z<= platform[i]:GetAbsOrigin().z + platform[i].height + (Laws.flDropSpeed * 0.5) + delta_z then
        return Vector(pos.x,0,platform[i]:GetAbsOrigin().z + platform[i].height)
      end
    end
  end
  return Vector(pos.x,0,128)
end

function ConnectLowestAndMiddle(hPlatform)
  Timers:CreateTimer(function()
    if hPlatform and IsValidEntity(hPlatform) then
      local origin = Vector(hPlatform:GetAbsOrigin().x,0,hPlatform.dummy:GetAbsOrigin().z+hPlatform.radius)
      hPlatform:SetAbsOrigin(origin)
      hPlatform.dummy:SetAbsOrigin(origin-Vector(0,0, hPlatform.radius))
      return FrameTime()
    end
  end)
end