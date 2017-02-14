require('abilities/basic_attack_animations')
-- Still do to, basic attacks for up and down

basic_attack_mid = class({})
function basic_attack_mid:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=4})
  return true
end


function basic_attack_mid:IsHiddenAbilityCastable()
  return true
end
function basic_attack_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange

  caster:EmitSound("hero_Crystal.attack")
  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage)
    caster:EmitSound("hero_Crystal.projectileImpact")
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable)
    break
  end
end


basic_attack_left = class({})
function basic_attack_left:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  caster:SetForwardVector(Vector(-1,0,0))
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=2})
  return true
end

function basic_attack_left:IsHiddenAbilityCastable()
  return true
end
function basic_attack_left:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  
  
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end

basic_attack_right = class({})


function basic_attack_right:IsHiddenAbilityCastable()
  return true
end

function basic_attack_right:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  caster:SetForwardVector(Vector(1,0,0))
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=2})
  return true
end
function basic_attack_right:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  --caster:SetForwardVector(Vector(1,0,0))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end
basic_attack_top = class({})


function basic_attack_top:IsHiddenAbilityCastable()
  return true
end

function basic_attack_top:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --caster:SetForwardVector(Vector(0,0,1))
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=attackAnimationTop[caster:GetUnitName()], rate=5})
  return true
end
function basic_attack_top:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5

  --caster:SetForwardVector(Vector(0,0,0))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end

basic_attack_bottom = class({})


function basic_attack_bottom:IsHiddenAbilityCastable()
  return true
end

function basic_attack_bottom:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --caster:SetForwardVector(Vector(-1,0,0))
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=attackAnimationBottom[caster:GetUnitName()], rate=5})
  return true
end
function basic_attack_bottom:OnSpellStart()

  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5

  --caster:SetForwardVector(Vector(0,0,-1))
  --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_right",{duration =self:GetCastPoint()* 0.5})
  --[[local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle,0,caster:GetAbsOrigin()+caster:GetForwardVector() + radius)

  Timers:CreateTimer(self:GetCastPoint(),function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)]]

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    break
  end
  
end