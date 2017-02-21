control = class({})

function control:KeyEvent(keys)
  local self = control
  --PrintTable(keys)
  local button = keys.button
  local action = keys.action
  local PlayerID = keys.PlayerID

  local hero = PlayerResource:GetPlayer(PlayerID):GetAssignedHero()

  local buttonDirection = self:FindMousePosition(keys.x,keys.y)
  local mouseVector = self:FindMousePositionVector(keys.x,keys.y)
  local mouseVectorDistance = self:FindMousePositionVectorWithDistance(keys.x,keys.y)

  if not hero or (string.find(button, "mouse") and action == "released") then
    return 
  end
  if hero:HasModifier("modifier_smash_stun") then 
    return 
  end
  --

  --print(hero:GetAbsOrigin().x)
  -- up
  if button == "up" and action == "pressed" then
    if hero:HasModifier("modifier_smash_root") then
      return
    end
    if hero.jumps < 2 then
      hero:RemoveModifierByName("modifier_jump")
      --hero:RemoveModifierByName("modifier_drop")
      hero:AddNewModifier(hero,nil,"modifier_jump",{duration=Laws.flJumpDuration})
    end
  end

  -- left
  if button == "left" then
    if action == "pressed" then
      if hero:HasModifier("modifier_smash_root") then
        return
      end
      hero:AddNewModifier(hero,nil,"modifier_left",{})
    elseif action == "released" then
      hero:RemoveModifierByName("modifier_left")
    end
  end


  --right
  if button == "right" then
    if action == "pressed" then
      if hero:HasModifier("modifier_smash_root") then
        return
      end
      hero:AddNewModifier(hero,nil,"modifier_right",{})
    elseif action == "released" then
      hero:RemoveModifierByName("modifier_right")
    end
  end

  -- down
  if button == "down" then
    if action == "pressed" then
      if hero:HasModifier("modifier_smash_root") then
        return
      end
      hero.bUnitUsedDrop = true
      hero:AddNewModifier(hero,nil,"modifier_drop",{})
    elseif action == "released" then
      hero.bUnitUsedDrop = false
    end
  end


  if button == "left_mouse" then
    hero:Interrupt()
    local abName = "basic_attack_"..buttonDirection
    hero:CastAbilityNoTarget(hero:FindAbilityByName(abName),-1)
  end

  if button == "right_mouse" then
    hero:Interrupt()
    if buttonDirection == "left" or buttonDirection == "right" then
      if buttonDirection == "right" then
        hero:SetForwardVector(Vector(1,0,0))
      else
        hero:SetForwardVector(Vector(-1,0,0))
      end
      local heroName = hero:GetUnitName()
      local abName = string.sub(heroName, 15).."_special_side"
      hero:FindAbilityByName(abName).mouseVector = mouseVector
      hero:FindAbilityByName(abName).mouseVectorDistance = mouseVectorDistance
      hero:CastAbilityNoTarget(hero:FindAbilityByName(abName),-1)
    end
    if buttonDirection == "top" then
      local heroName = hero:GetUnitName()
      local abName = string.sub(heroName, 15).."_special_"..buttonDirection 
      hero:FindAbilityByName(abName).mouseVector = mouseVector
      hero:FindAbilityByName(abName).mouseVectorDistance = mouseVectorDistance
      hero:CastAbilityNoTarget(hero:FindAbilityByName(abName),-1)
    end
    if buttonDirection == "mid" then
      local heroName = hero:GetUnitName()
      local abName = string.sub(heroName, 15).."_special_"..buttonDirection
      hero:FindAbilityByName(abName).mouseVector = mouseVector
      hero:FindAbilityByName(abName).mouseVectorDistance = mouseVectorDistance
      hero:CastAbilityNoTarget(hero:FindAbilityByName(abName),-1)
    end
    
    if buttonDirection == "bottom" then
      local heroName = hero:GetUnitName()
      local abName = string.sub(heroName, 15).."_special_"..buttonDirection
      hero:FindAbilityByName(abName).mouseVector = mouseVector
      hero:FindAbilityByName(abName).mouseVectorDistance = mouseVectorDistance
      hero:CastAbilityNoTarget(hero:FindAbilityByName(abName),-1)
    end
  end
end

function control:FindMousePositionVector(x,y)
  x = x*100
  y = y*100
  local a = (x-50)/50 
  local b = -1* (y-50)/50

  
  if math.abs(a) > math.abs(b) then
    local m = 1/math.abs(a)
    a = a*m
    b = b*m
  else 
    local m = 1/math.abs(b)
    a = a*m
    b = b*m
  end
  return Vector(a,0,b)
end

function control:FindMousePositionVectorWithDistance(x,y) -- This one does takes distance into account, clicking further will make the projectile go further!
  x = x*100
  y = y*100
  local a = (x-50)/50 
  local b = -1* (y-50)/50
  return Vector(a,0,b)
end

function control:FindMousePosition(x,y)
  x = x*100
  y = y*100
  local top = {}
  top[1] = Vector(-1,-1,0)
  top[2] = Vector(27.5,30,0)
  top[3] = Vector(72,30,0)  
  top[4] = Vector(100,-1,0)
  local left = {}
  left[1] = Vector(-1,-1,0)
  left[2] = Vector(27.5,30,0)
  left[3] = Vector(27.5,70,0)  
  left[4] = Vector(-1,100,0)
  local right = {}
  right[1] = Vector(100,-1,0)
  right[2] = Vector(72,30,0)
  right[3] = Vector(72,70,0)  
  right[4] = Vector(100,100,0)
  local bottom = {}
  bottom[1] = Vector(-1,100,0)
  bottom[2] = Vector(27.5,70,0)
  bottom[3] = Vector(72,70,0)  
  bottom[4] = Vector(100,100,0)
  local mid = {}
  mid[1] = Vector(27.5,30,0)
  mid[2] = Vector(27.5,70,0)
  mid[3] = Vector(72,30,0)  
  mid[4] = Vector(72,70,0)
  local point = {x=x,y=y} 

  if isPointInsidePolygon(point,top) then return "top"
  elseif isPointInsidePolygon(point,left) then return "left"
  elseif isPointInsidePolygon(point,right) then return "right"
  elseif isPointInsidePolygon(point,bottom) then return "bottom"
  elseif isPointInsidePolygon(point,mid) then return "mid"
  else return "mid" end
end
