LinkLuaModifier("modifier_magnus_skewer","abilities/magnus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magnus_skewer_target","abilities/magnus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magnus_skewer_target_slow","abilities/magnus.lua",LUA_MODIFIER_MOTION_NONE)

magnataur_special_top_release = class({})

function magnataur_special_top_release:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_magnus_skewer")
end

magnataur_special_top = class({})

function magnataur_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 2 then return end
  local caster = self:GetCaster()

  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  return true
end

function magnataur_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function magnataur_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  
  --local vector = self.mouseVector
  caster:SetForwardVector(self.mouseVector)
  
  caster.jumps = 3
  caster:EmitSound("Hero_Magnataur.Skewer.Cast")
  caster:AddNewModifier(caster,self,"modifier_magnus_skewer",{duration = 1.25})
end

modifier_magnus_skewer = class({})

function modifier_magnus_skewer:OnCreated()
  if IsServer() then
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local direction = ability.mouseVector 
    local speed = ability:GetSpecialValueFor("speed")

    --caster:SetStaticVelocity("magnus_skewer",direction*speed*30)

    self:StartIntervalThink(1/30)
    self.targets = {}

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_skewer.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_horn", caster:GetAbsOrigin(), true)
  end
end

function modifier_magnus_skewer:OnIntervalThink()
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  local direction = ability.mouseVector 
  local speed = ability:GetSpecialValueFor("speed") *1.5
  local radius = ability:GetSpecialValueFor("radius")

  --caster:SetAbsOrigin(caster:GetAbsOrigin()+direction*speed)
  Physics2D:SetStaticVelocity(caster,"magnataur_skewer",direction*speed)
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not self.targets[v] then
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
      } 
      ApplyDamage(damageTable)
      self.targets[v] = true
      v:EmitSound("Hero_Magnataur.Skewer.Target")
    end
    --v:SetAbsOrigin(caster:GetAbsOrigin()+(direction*speed)+RandomVector(5))
    v:AddNewModifier(caster,ability,"modifier_magnus_skewer_target",{duration = 2*FrameTime()})
    v:AddNewModifier(caster,ability,"modifier_magnus_skewer_target_slow",{duration = ability:GetSpecialValueFor("slow_duration")})
  end

  
  
end

function modifier_magnus_skewer:OnDestroy()
  if IsServer() then

    local caster = self:GetCaster()
    local ability = self:GetAbility()


    Physics2D:SetStaticVelocity(caster,"magnataur_skewer",Vec(0))

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    if self:GetParent():GetForwardVector().x > 0 then
      self:GetParent():SetForwardVector(Vector(1,0,0))
    else
      self:GetParent():SetForwardVector(Vector(-1,0,0))
    end

  end
end

modifier_magnus_skewer_target = class({})

function modifier_magnus_skewer_target:OnCreated()
  if IsServer() then
    self:StartIntervalThink(FrameTime())
  end
end
function modifier_magnus_skewer_target:OnIntervalThink()
  Physics2D:ClearPhysicsVelocity(self:GetParent())
  Physics2D:AddPhysicsVelocity(self:GetParent(),Physics2D:GetStaticVelocity(self:GetCaster()))
end

function modifier_magnus_skewer_target:OnDestroy()
  if IsServer() then
    Physics2D:ClearPhysicsVelocity(self:GetParent())
    --Physics2D:SetStaticVelocity(self:GetParent(),"magnataur_skewer",Vec(0))
  end
end

modifier_magnus_skewer_target_slow = class({})

function modifier_magnus_skewer_target_slow:GetEffectName()
  return "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf"
end

function modifier_magnus_skewer_target_slow:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_magnus_skewer_target_slow:OnCreated()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor - self:GetAbility():GetSpecialValueFor("movement_slow")
  end
end

function modifier_magnus_skewer_target_slow:OnDestroy()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor + self:GetAbility():GetSpecialValueFor("movement_slow")
  end
end

magnataur_special_bottom = class({})

function magnataur_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_4, rate=1})
  self:GetCaster():EmitSound("Hero_Magnataur.ReversePolarity.Anim")

  self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
  ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, nil, self:GetCaster():GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(self.particle, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
  ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetCastPoint(), 0, 0))
  ParticleManager:SetParticleControl(self.particle, 3, self:GetCaster():GetAbsOrigin())

  Timers:CreateTimer(1, function()
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
  end)
  
  return true
end

function magnataur_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Magnataur.ReversePolarity.Anim")
  EndAnimation(caster)
end


function magnataur_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  caster:EmitSound("Hero_Magnataur.ReversePolarity.Cast")
  local radius = ability:GetSpecialValueFor("radius")
  local duration = ability:GetSpecialValueFor("stun_duration")

  local direction = Vector(1,0,0)
  if caster:GetForwardVector().x < 0 then
    direction = Vector(-1,0,0)
  end
  local target_position = caster:GetAbsOrigin() + ability:GetSpecialValueFor("distance") * direction

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)

  for k,v in pairs(units) do
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = ability
    } 
    ApplyDamage(damageTable)
    v:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = duration})
    v:SetAbsOrigin(target_position+RandomVector(5))
  end
end

magnataur_special_side = class({})

function magnataur_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=1})
  self:GetCaster():EmitSound("Hero_Magnataur.ShockWave.Cast")
  return true
end

function magnataur_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Magnataur.ShockWave.Cast")
  EndAnimation(caster)
end
function magnataur_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  self:GetCaster():EmitSound("Hero_Magnataur.ShockWave.Particle")
  StoreSpecialKeyValues(self)

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/magnus/magnataur_shockwave.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_NOTHING,
      UnitTest = function(projectile, unit) return unit.IsSmashUnit and unit:IsRealHero() and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(projectile,unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability.damage + RandomInt(0,ability.damage_offset),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        local casterLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(projectile.location)
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(casterLoc)
        
  
        caster:EmitSound("Hero_Magnataur.ShockWave.Target")
  
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location, true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable) 

end
