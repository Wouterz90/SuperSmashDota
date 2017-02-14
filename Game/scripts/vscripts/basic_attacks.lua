basic_attack_mid = class({})


function basic_attack_mid:IsHiddenAbilityCastable()
  return true
end
function basic_attack_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange
  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage)
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable)
    break
  end
end


basic_attack_left = class({})


function basic_attack_left:IsHiddenAbilityCastable()
  return true
end
function basic_attack_left:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  caster:SetForwardVector(Vector(-1,0,0))
  
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * 3
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end

basic_attack_right = class({})


function basic_attack_left:IsHiddenAbilityCastable()
  return true
end
function basic_attack_left:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  caster:SetForwardVector(Vector(1,0,0))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * 3
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end
basic_attack_top = class({})


function basic_attack_top:IsHiddenAbilityCastable()
  return true
end
function basic_attack_top:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5

  caster:SetForwardVector(Vector(0,0,1))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * 3
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end

basic_attack_bottom = class({})


function basic_attack_bottom:IsHiddenAbilityCastable()
  return true
end
function basic_attack_bottom:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5

  caster:SetForwardVector(Vector(0,0,-1))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * 3
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end