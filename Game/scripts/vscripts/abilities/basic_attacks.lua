require('abilities/basic_attack_animations')
LinkLuaModifier("modifier_basic_attack_charge","abilities/basic_attacks.lua",LUA_MODIFIER_MOTION_NONE)
-- Still do to, basic attacks for up and down

basic_attack_mid = class({})

function basic_attack_mid:GetCastPoint()
  return self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor
end

function basic_attack_mid:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate= caster:GetAttackAnimationPoint()/self:GetCastPoint()})
  caster:EmitSound("hero_Crystal.attack")
  return true
end

function basic_attack_mid:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  --caster:StopSound("hero_Crystal.attack")
  EndAnimation(caster)
end


function basic_attack_mid:IsHiddenAbilityCastable()
  return true
end
function basic_attack_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange
  local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage)

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do

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
    Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)
    break
  end
end

modifier_basic_attack_charge = class({})

function modifier_basic_attack_charge:OnCreated()
  if IsServer() then
    local caster = self:GetCaster()

    caster:AddNewModifier(caster,self,"modifier_smash_root",{})
    local name = self:GetName()
    caster:RemoveModifierByName("modifier_animation")
    StartAnimation(caster, {duration=5, activity=ACT_DOTA_ATTACK, rate=1})
    -- Freezing and unfreezing seems unstable. Crashes.
    Timers:CreateTimer(caster:GetAttackAnimationPoint()/2 ,function()
      if caster:HasModifier(name) then
        local modifier = caster:FindModifierByName("modifier_left")
        if modifier then
          modifier:SetDuration(1,false)
        end
        local modifier = caster:FindModifierByName("modifier_right")
        if modifier then
          modifier:SetDuration(1,false)
        end
        caster:RemoveModifierByName("modifier_jump")
        FreezeAnimation(caster,4)
      end
    end)
    self:SetStackCount(0)
    self.particle = ParticleManager:CreateParticle("particles/basic/basic_attack_glow.vpcf", PATTACH_CUSTOMORIGIN, caster) --particles/basic/basic_attack_glow.vpcf
    --ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1 ", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.particle,1,Vector(self:GetStackCount()+2,0,0))
    self:StartIntervalThink(1/30)
  end
end

function modifier_basic_attack_charge:OnIntervalThink()
  local caster = self:GetCaster()
  self:IncrementStackCount()
  ParticleManager:SetParticleControl(self.particle,1,Vector(self:GetStackCount()/1.5+2,0,0))
  if caster:HasModifier("modifier_smash_stun") or caster:HasModifier("modifier_smash_disarm") then
    self:Destroy()
  end
end

function modifier_basic_attack_charge:OnRemoved()
  if IsServer() then
    self:GetCaster():RemoveModifierByName("modifier_smash_root")
    if self:GetCaster():HasModifier("modifier_animation_freeze") then 
      UnfreezeAnimation(self:GetCaster())
      ChangeAnimationRate(self:GetCaster(),2)
    end
    local abName = self:GetAbility():GetAbilityName().."_release"
    local ab = self:GetCaster():FindAbilityByName(abName)
    ab.Push = ab:GetSpecialValueFor("push") + self:GetStackCount()/25
    ab.plusDamage = self:GetStackCount()/30
    self:GetCaster():CastAbilityNoTarget(ab,-1)
    self:GetCaster().isChargingAbility = nil
    local cp = ab:GetCastPoint()

    Timers:CreateTimer(cp,function()
      if self.particle then
        ParticleManager:DestroyParticle(self.particle,true)
        ParticleManager:ReleaseParticleIndex(self.particle)
      end
    end)
  end
end

basic_attack_left = class({})
function basic_attack_left:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  caster:SetForwardVector(Vector(-1,0,0))
  
  
  caster:AddNewModifier(caster,self,"modifier_basic_attack_charge",{ duration = 1})
  return true
end

function basic_attack_left:GetCastPoint()
  return 0--self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor * 3
end

function basic_attack_left:IsHiddenAbilityCastable()
  return true
end

basic_attack_left_release = class({})
function basic_attack_left_release:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=caster:GetAttackAnimationPoint()/self:GetCastPoint()})
  self:GetCaster():EmitSound("Hero_Ursa.PreAttack")
  self:GetCaster():SetForwardVector(Vector(-1,0,0))

  return true

end
function basic_attack_left_release:GetCastPoint()
  return self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor
end
function basic_attack_left_release:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  
  local particle = ParticleManager:CreateParticle("particles/basic/basic_swipe_left.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage+self.plusDamage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    caster:EmitSound("Hero_Ursa.Attack")
    break
  end
  
end


basic_attack_right = class({})
function basic_attack_right:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  caster:SetForwardVector(Vector(1,0,0))
  
  
  caster:AddNewModifier(caster,self,"modifier_basic_attack_charge",{ duration = 1})
  return true
end

function basic_attack_right:GetCastPoint()
  return 0--self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor * 3
end

function basic_attack_right:IsHiddenAbilityCastable()
  return true
end

basic_attack_right_release = class({})
function basic_attack_right_release:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=caster:GetAttackAnimationPoint()/self:GetCastPoint()})
  self:GetCaster():EmitSound("Hero_Ursa.PreAttack")
  self:GetCaster():SetForwardVector(Vector(1,0,0))
  return true

end
function basic_attack_right_release:GetCastPoint()
  return self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor
end
function basic_attack_right_release:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5

  local particle = ParticleManager:CreateParticle("particles/basic/basic_swipe_right.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)
  

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = RandomInt(Laws.flMinDamage,Laws.flMaxDamage) * Laws.flSideAttackFactor
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage+self.plusDamage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    caster:EmitSound("Hero_Ursa.Attack")
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
    break
  end
  
end
basic_attack_top = class({})
function basic_attack_top:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  
  
  caster:AddNewModifier(caster,self,"modifier_basic_attack_charge",{ duration = 1})
  return true
end

function basic_attack_top:GetCastPoint()
  return 0--self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor * 3
end

function basic_attack_top:IsHiddenAbilityCastable()
  return true
end

basic_attack_top_release = class({})
function basic_attack_top_release:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=caster:GetAttackAnimationPoint()/self:GetCastPoint()})
  self:GetCaster():EmitSound("Hero_Ursa.PreAttack")
  return true

end
function basic_attack_top_release:GetCastPoint()
  return self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor
end
function basic_attack_top_release:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5



  local particle = ParticleManager:CreateParticle("particles/basic/basic_swipe_up.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (Vector(0,0,1) * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (Vector(0,0,1) * radius),radius)
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
    caster:EmitSound("Hero_Ursa.Attack")
    local particle = ParticleManager:CreateParticle("particles/basic/basic_attack_mid_hit.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
    --[[Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,true)
      ParticleManager:ReleaseParticleIndex(particle)
    end)]]
    break
  end
  
end

basic_attack_bottom = class({})
function basic_attack_bottom:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  
  
  caster:AddNewModifier(caster,self,"modifier_basic_attack_charge",{ duration = 1})
  return true
end

function basic_attack_bottom:GetCastPoint()
  return 0--self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor * 3
end

function basic_attack_bottom:IsHiddenAbilityCastable()
  return true
end

basic_attack_bottom_release = class({})
function basic_attack_bottom_release:OnAbilityPhaseStart()
  local caster = self:GetCaster()
  if not self:GetCaster():CanCast(self) then return false end
  --StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=caster:GetAttackAnimationPoint()/self:GetCastPoint()})
  self:GetCaster():EmitSound("Hero_Ursa.PreAttack")
  return true

end
function basic_attack_bottom_release:GetCastPoint()
  return self:GetSpecialValueFor("cast_point") * self:GetCaster().attackspeedFactor
end
function basic_attack_bottom_release:OnSpellStart()
  local caster = self:GetCaster()
  local radius = Laws.flAttackRange * 1.5
  
   local particle = ParticleManager:CreateParticle("particles/basic/basic_swipe_down.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,true)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (Vector(0,0,-1) * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (Vector(0,0,-1) * radius),radius)
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
    caster:EmitSound("Hero_Ursa.Attack")
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
    ParticleManager:SetParticleControlEnt(self.particle,0,self:GetCaster(),PATTACH_POINT_FOLLOW,"attach_hitloc",self:GetCaster():GetAbsOrigin()+Vector(0,0,0),true)
    ParticleManager:SetParticleControl(self.particle,1,Vector(5 + (self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() * 3),0,0))
  end
end

function modifier_special_shield:OnIntervalThink()
  if self:GetCaster():FindModifierByName("modifier_special_shield_count"):GetStackCount() <= 0 then
    
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
