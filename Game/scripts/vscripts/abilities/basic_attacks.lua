require('abilities/basic_attack_animations')
-- Still do to, basic attacks for up and down

basic_attack_mid = class({})
function basic_attack_mid:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=4})
  caster:EmitSound("hero_Crystal.attack")
  return true
end


function basic_attack_mid:IsHiddenAbilityCastable()
  return true
end
function basic_attack_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange

  
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
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
    break
  end
end


basic_attack_left = class({})
function basic_attack_left:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  caster:SetForwardVector(Vector(-1,0,0))
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=2})
  caster:EmitSound("hero_Crystal.attack")
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
    caster:EmitSound("hero_Crystal.projectileImpact")
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
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
  caster:EmitSound("hero_Crystal.attack")
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
    caster:EmitSound("hero_Crystal.projectileImpact")
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
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
  caster:EmitSound("hero_Crystal.attack")
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
    caster:EmitSound("hero_Crystal.projectileImpact")
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
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
  caster:EmitSound("hero_Crystal.attack")
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
    caster:EmitSound("hero_Crystal.projectileImpact")
    --[[local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
    break
  end
  
end

special_shield = class({})
modifier_special_shield = class({})
modifier_special_shield_count = class({})
LinkLuaModifier("modifier_special_shield_count","abilities/basic_attacks.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_shield","abilities/basic_attacks.lua",LUA_MODIFIER_MOTION_NONE)

function special_shield:IsHiddenAbilityCastable()
  return true
end

function special_shield:GetChannelTime()
  if IsServer() then
    return self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() * 0.1
  end
end
function special_shield:GetIntrinsicModifierName()
  return "modifier_special_shield_count"
end
function special_shield:OnUpgrade()
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_special_shield_count",{})
end
function special_shield:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  if self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() <= 0 then 
    return false 
  end
  return true
end

function special_shield:OnSpellStart()
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_special_shield",{ duration = self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() * 0.1})
  self:GetCaster().bShieldActivated = true
end

function special_shield:OnChannelFinish(bInterrupted)
  self:GetCaster():RemoveModifierByName("modifier_special_shield")
   self:GetCaster().bShieldActivated = nil
end


function modifier_special_shield:OnCreated()
  if IsServer() then 
    self:GetCaster().bShieldActivated = true
    self:StartIntervalThink(0.1)
    self.particle = ParticleManager:CreateParticle("particles/shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    --ParticleManager:SetParticleControl(self.particle,0,self:GetCaster():GetAbsOrigin()+Vector(0,0,100))
    ParticleManager:SetParticleControlEnt(self.particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_hitloc",self:GetCaster():GetAbsOrigin()+Vector(0,0,0),true)
    ParticleManager:SetParticleControl(self.particle,1,Vector(5 + (self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() * 3),0,0))
  end
end

function modifier_special_shield:OnIntervalThink()
  if self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() <= 0 then
    self:GetCaster():Interrupt()
    return 
  end
ParticleManager:SetParticleControl(self.particle,1,Vector(5 + (self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() * 3),0,0))
self:GetCaster():FindModifierByName("modifier_special_shield_count"):DecrementStackCount()

end

function modifier_special_shield:OnDestroy()
  if IsServer() then
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self:GetCaster().bShieldActivated = nil
  end
end



function modifier_special_shield_count:IsPermanent()
  return true
end

function modifier_special_shield_count:IsPurgable()
  return false
end

function modifier_special_shield_count:OnCreated()
  if IsServer() then
    local ability = self:GetCaster():FindAbilityByName("special_shield")
    self:StartIntervalThink(1)
  end
end

function modifier_special_shield_count:OnIntervalThink()
  local ability = self:GetAbility()
  if self:GetCaster():IsAlive() and self:GetStackCount() < ability:GetSpecialValueFor("max_value") then
    self:IncrementStackCount()
  end
end