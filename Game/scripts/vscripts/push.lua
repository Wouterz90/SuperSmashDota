push = push or class({})

push.flDamageDivision = 25
push.flPushDistance = 50
push.flPushSpeed = 1000


function push:DamageFilter(filterTable)
  local self = push
  if not filterTable["entindex_attacker_const"] or not filterTable["entindex_victim_const"] or not filterTable["entindex_inflictor_const"] then return end
  local attacker = EntIndexToHScript(filterTable["entindex_attacker_const"])
  local victim = EntIndexToHScript(filterTable["entindex_victim_const"])
  local ability = EntIndexToHScript(filterTable["entindex_inflictor_const"])

  if not ability.GetSpecialValueFor then return end

  
  local push_ability = ability:GetSpecialValueFor("push")
  if not push_ability then return end

  local damageType = filterTable["damagetype_const"]
  local damage = filterTable["damage"]
  local pushDirection = (victim:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized()
  
  
  victim.pushDirection = pushDirection

  local pushFactorBasedOnHealth = victim:GetHealthDeficit() / self.flDamageDivision
  local pushFactorBasedOnTargetPower = 1 -- Not yet
  local pushFactorAmplify = 1 -- victim.Amplify -- Not yet

  push_ability = push_ability * pushFactorBasedOnHealth * pushFactorBasedOnTargetPower * pushFactorAmplify * self.flPushDistance
  victim.pushDistance = push_ability
  victim:AddNewModifier(attacker,nil,"modifier_push",{})
  
  -- For tracking score
  if not attacker:IsRealHero() then
    attacker = PlayerResource:GetSelectedHeroEntity(attacker:GetPlayerOwnerID())
  end
  victim.lastAttacker = attacker

  return true


end
