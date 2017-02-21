push = --[[push or ]]class({})

push.flDamageDivision = 25
push.flPushDistance = 60
--push.flPushSpeed = 1000


function push:DamageFilter(filterTable)
  local self = push
  if not filterTable["entindex_attacker_const"] or not filterTable["entindex_victim_const"] or not filterTable["entindex_inflictor_const"] then return end
  local attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
  local victim = EntIndexToHScript(filterTable["entindex_victim_const"])
  local ability = EntIndexToHScript(filterTable["entindex_inflictor_const"])

  if not ability.GetSpecialValueFor then return end

  
  local push_ability = ability:GetSpecialValueFor("push")
  if not push_ability then return true end

  local damageType = filterTable["damagetype_const"]
  local damage = filterTable["damage"]
  local pushDirection = (victim:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
  
  
  victim.pushDirection = pushDirection

  local pushFactorBasedOnHealth = victim:GetHealthDeficit() / self.flDamageDivision
  local pushFactorBasedOnTargetPower = 1 -- Not yet
  local pushFactorAmplify = 1 -- victim.Amplify -- Not yet

  push_ability = push_ability * pushFactorBasedOnHealth * pushFactorBasedOnTargetPower * pushFactorAmplify * push.flPushDistance
  
  victim.pushDistance = push_ability
  victim:AddNewModifier(attacker,nil,"modifier_push",{})
  
  -- For tracking score
  if not attacker:IsRealHero() then
    attacker = PlayerResource:GetSelectedHeroEntity(attacker:GetPlayerOwnerID())
  end
  victim.lastAttacker = attacker

  return true


end
LinkLuaModifier("modifier_push","push.lua",LUA_MODIFIER_MOTION_BOTH)
modifier_push = class({})

function modifier_push:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_push:OnIntervalThink()
  local unit = self:GetParent()
  unit.pushDistance = unit.pushDistance * Laws.flPushDeceleration
  local distance = unit.pushDistance /32

  -- Destroy the modifier is the movement is really slow
  if unit.pushDistance < 400 then
    self:Destroy()
    return
  end

  -- Prevent the unit from going through a platform, it bounces back
  if unit:isOnPlatform() and unit.pushDirection.z < 0 then
    unit.pushDirection = Vector(unit.pushDirection.x,0,unit.pushDirection.z * -0.75)
  end

  -- Prevent the unit from going through a wall
  if GridNav:IsWall(unit:GetAbsOrigin() + unit.pushDirection * distance) then
    unit.pushDirection = Vector(unit.pushDirection.x * -0.75,0,unit.pushDirection.z)
  end

  unit:SetAbsOrigin(unit:GetAbsOrigin() + unit.pushDirection * distance)
end