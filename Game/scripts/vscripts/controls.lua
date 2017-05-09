control = control or class({})

function control:KeyEvent(keys)
  DebugPrint(2,"[SMASH] [CONTROLS] KeyEvent")
  local self = control
  --PrintTable(keys)
  local button = keys.button
  local action = keys.action
  local PlayerID = keys.PlayerID

  local hero = PlayerResource:GetPlayer(PlayerID):GetAssignedHero()

  local buttonDirection = self:FindMousePosition(keys.x,keys.y)
  local mouseVector = self:FindMousePositionVector(keys.x,keys.y)
  local mouseVectorDistance = self:FindMousePositionVectorWithDistance(keys.x,keys.y)

  if not hero then
    return 
  end
  if hero:HasModifier("modifier_smash_stun") then
    if action == "pressed" then
      EmitSoundOnClient("General.Cancel",hero:GetPlayerOwner())
    end
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


  if button == "left_mouse" and action == "pressed" then
    local abName = "basic_attack_"..buttonDirection
    local ab = hero:FindAbilityByName(abName)
    if ab and not ab:IsInAbilityPhase() then
      hero:Interrupt()
      hero:CastAbilityNoTarget(ab,-1)
      return
    end
  end

  if button == "right_mouse" then

    -- Activate shield if mid
    if buttonDirection == "mid" then
      local abName = "special_shield"
      local ab = hero:FindAbilityByName(abName)
      if action == "pressed" then
        if not ab:IsInAbilityPhase() then
          hero:Interrupt()
          hero:CastAbilityNoTarget(ab,-1)
          hero.isChargingAbility = ab
          return
        end
      end
    end

    if action == "released" and hero.isChargingAbility then
      
      local newAbName = hero.isChargingAbility:GetAbilityName().."_release"
      if string.find(newAbName, "special_shield") then
        hero:Interrupt()
        hero.isChargingAbility = nil
        return
      end
      local newAb = hero:FindAbilityByName(newAbName)

      if not newAb:IsInAbilityPhase() then
        hero:Interrupt()
        hero:CastAbilityNoTarget(newAb,-1)
      end
      hero.isChargingAbility = nil
    end
    
    -- Rename left right to side and put the hero in the right direction
    if buttonDirection == "left" or buttonDirection == "right" then
      if buttonDirection == "right" then
        hero:SetForwardVector(Vector(1,0,0))
      else
        hero:SetForwardVector(Vector(-1,0,0))
      end

      buttonDirection = "side"
    end
    
    local heroName = hero:GetUnitName()
    local abName = string.sub(heroName, 15).."_special_"..buttonDirection
    local ab = hero:FindAbilityByName(abName)

    if action == "pressed" then 
      if not ab:IsCooldownReady() then
        EmitSoundOnClient("General.CastFail_AbilityInCooldown",PlayerResource:GetPlayer(PlayerID))
        return
      end
      hero:FindAbilityByName(abName).mouseVector = mouseVector
      hero:FindAbilityByName(abName).mouseVectorDistance = mouseVectorDistance
      if not ab:IsInAbilityPhase() then
        hero:Interrupt()
        hero:CastAbilityNoTarget(ab,-1)
      end
      if chargeableAbilities[abName] then
        hero.isChargingAbility = ab
      return
      end
    end

    
  end
end

function control:FindMousePositionVector(x,y)
  DebugPrint(2,"[SMASH] [CONTROLS] FindMousePositionVector")
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
  DebugPrint(2,"[SMASH] [CONTROLS] FindMousePositionVectorWithDistance")
  x = x*100
  y = y*100
  local a = (x-50)/50 
  local b = -1* (y-50)/50
  return Vector(a,0,b)
end

function control:FindMousePosition(x,y)
  DebugPrint(2,"[SMASH] [CONTROLS] FindMousePosition")
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
