-- Blink Refresh -- After the blink you are silenced for a medium long duration
tinker_special_top = class({})
function tinker_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_4, rate=0.53/self:GetCastPoint()})
  if caster.jumps > 2 then return false end
  return true
end

function tinker_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  caster.jumps = 3

  local vector = self.mouseVector
  local refresh_time = self:GetSpecialValueFor("refresh_time")

  -- Jump
  local particle_one = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
  caster:SetAbsOrigin(caster:GetAbsOrigin()+vector*range)
  local particle_two = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
  -- Release particles
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle_one,false)
    ParticleManager:ReleaseParticleIndex(particle_one)
    ParticleManager:DestroyParticle(particle_two,false)
    ParticleManager:ReleaseParticleIndex(particle_two)
  end)
  --Disable (not stun because of movement)
  caster:AddNewModifier(caster,self,"modifier_smash_disarm",{duration = refresh_time}) -- Particles broken
  caster:AddNewModifier(caster,self,"modifier_smash_silence",{duration = refresh_time})

  -- Refresh all the spells
  for i=0,23 do
    local ab = caster:GetAbilityByIndex(i)
    if ab and string.find(ab:GetAbilityName(), "special") then
      ab:EndCooldown()
    end
  end



end
-- Laser
tinker_special_side = class({})
function tinker_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=0.4/self:GetCastPoint()})
  return true
end

function tinker_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_side:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local vector = self.mouseVector
  local ability = self
  if ability.unit then
    UTIL_Remove(ability.unit)
    ability.unit = nil
  end

  caster:EmitSound("Hero_Tinker.Laser")
    
  -- Use find units in line to find a unit, check for height
  local units = FindUnitsInLine(caster:GetTeam(),caster:GetAbsOrigin(),caster:GetAbsOrigin()+caster:GetForwardVector() * (self.range-200) ,nil,200,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE)
  -- Create a dummy unit at the end
  ability.unit = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+(caster:GetForwardVector()*self.range),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  ability.unit:SetAbsOrigin(caster:GetAbsOrigin()+(caster:GetForwardVector()*1*self.range)+Vector(0,0,100))
  ability.unit:FindAbilityByName("dummy_unit"):SetLevel(1)
  -- Launch the tracking projectile
  local projTable = {
    Target = ability.unit,
    Source = caster,
    Ability = ability,
    EffectName = "particles/units/heroes/hero_tinker/tinker_laser.vpcf",
    bDodgeable = false,
    bProvidesVision = true,
    iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"), 
    vSpawnOrigin = caster:GetAbsOrigin()
  }
  ProjectileManager:CreateTrackingProjectile(projTable)
  -- Deal damage and disarm
  for k,v in pairs(units) do
    if math.abs(caster:GetAbsOrigin().z - v:GetAbsOrigin().z) < 200 then
      local damageTable = {
        victim = v,
        attacker = caster,
        damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
      v:AddNewModifier(caster,ability,"modifier_smash_disarm",{duration = ability:GetSpecialValueFor("disarm_duration")})  
      caster:EmitSound("Hero_Tinker.LaserImpact")
    end
  end
end

-- March
--[[tinker_special_bottom = class({})
function tinker_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
  return true
end

function tinker_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local radius =  self:GetSpecialValueFor("radius")
  local ability = self
  local projectile_speed = self:GetSpecialValueFor("projectile_speed")

  local midPoint = caster:GetAbsOrigin() - ability.mouseVector * radius
  
  caster:EmitSound("Hero_Tinker.March_of_the_Machines")

  for i=1,ability:GetSpecialValueFor("machine_count") do
    local projectile = {
    EffectName = "particles/tinker/tinker_bottom/tinker_machine.vpcf",  
    vSpawnOrigin = midPoint+Vector(RandomInt(-radius,radius),0,RandomInt(-radius,radius)),
    fDistance = radius * 2,--self:GetSpecialValueFor("distance"),
    fStartRadius = 50,
    fEndRadius = 50,
    Source = caster,
    fExpireTime = self:GetSpecialValueFor("duration"),
    vVelocity = self.mouseVector * projectile_speed, -- RandomVector(1000),
    UnitBehavior = PROJECTILES_DESTROY ,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_NOTHING,
    GroundBehavior = PROJECTILES_DESTROY,
    fGroundOffset = 0,
    nChangeMax = 1,
    bRecreateOnChange = false,
    bZCheck = true,
    bGroundLock = false,
    bProvidesVision = true,
    iVisionRadius = 200,
    iVisionTeamNumber = caster:GetTeam(),
    bFlyingVision = false,
    fVisionTickTime = .1,
    fVisionLingerDuration = 1,
    draw = false,
    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
    OnUnitHit = function(self, unit) 
      local damageTable = {
        victim = unit,
        attacker = caster,
        damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
    end,
    OnFinish = function(self,unit)
    end,
  }
  local proj = Projectiles:CreateProjectile(projectile)
    
  end
end
]]
-- Rockets -- Rockets are slowly homing and appear after some time
tinker_special_bottom = class({})

function tinker_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function tinker_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local ability = self
  caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")
  self.targets = self.targets or {}
  
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),self.radius)
  
  self.targets[1] = units[1]
  self.targets[2] = units[2]

  if self.targets[1] then
    local testUnit = self.targets[1]
    local projectileTable = 
    { 
      hTarget = self.targets[1],
      vDirection = Vector(0,0,1),
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = 50,
      flDuration = ability.rocket_duration,
      sEffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
      PlatformBehavior = PROJECTILES_BOUNCE,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      UnitTest = function(projectile, unit) return unit == self.targets[1] end,
      OnUnitHit = function(projectile,unit)
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage =  ability.damage,
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
      end,
      OnFinish = function(projectile)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, projectile) 
        ParticleManager:SetParticleControl( particle, 0, projectile.location ) 
        ParticleManager:SetParticleControl( particle, 1, projectile.location ) 
        --ParticleManager:SetParticleControlEnt(particle, 1, projectile, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location , true)
        Timers:CreateTimer(1,function()
          ParticleManager:DestroyParticle(particle,false)
          ParticleManager:ReleaseParticleIndex(particle)
        end)
        projectile:EmitSound("Hero_Tinker.Heat-Seeking_Missile.Impact")
      end,
      
    }
    local proj = Physics2D:CreateTrackingProjectile(projectileTable)

  end

  if self.targets[2] then
    local projectileTable = 
    { 
      hTarget = self.targets[2],
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = 50,
      flDuration = ability.rocket_duration,
      sEffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      UnitTest = function(projectile, unit) return unit == self.targets[2] end,
      OnUnitHit = function(projectile,unit)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit) 
        ParticleManager:SetParticleControl( particle, 0, projectile.location ) 
        ParticleManager:SetParticleControlEnt(particle, 1, projectile, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location , true)
        Timers:CreateTimer(1,function()
          ParticleManager:DestroyParticle(particle,false)
          ParticleManager:ReleaseParticleIndex(particle)
        end)
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage =  ability:GetSpecialValueFor("damage"),
          damage_type = ability:GetAbilityDamageType() or DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
    }
    local proj = Physics2D:CreateTrackingProjectile(projectileTable)

  end
    
end
