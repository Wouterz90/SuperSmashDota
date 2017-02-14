-- Blink Refresh -- After the blink you are silenced for a medium long duration
tinker_special_top = class({})
function tinker_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
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
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function tinker_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local vector = self.mouseVector
  local ability = self

  caster:EmitSound("Hero_Tinker.Laser")

  -- Fire a projectile to determine if a unit would be hit
  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    EffectName = "particles/tinker/tinker_laser.vpcf",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    vSpawnOrigin = caster:GetAbsOrigin(),
    --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,0)},
    fDistance = self:GetSpecialValueFor("range"),
    fStartRadius = 200,
    fEndRadius = 200,
    Source = caster,
    fExpireTime = 0.5,--self:GetSpecialValueFor("duration"),
    vVelocity = self.mouseVector * 8000 ,--self.mouseVector * (self:GetSpecialValueFor("distance")/self:GetSpecialValueFor("duration")), -- RandomVector(1000),
    UnitBehavior = PROJECTILES_DESTROY ,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_NOTHING,
    GroundBehavior = PROJECTILES_NOTHING,
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
      if not unit.GetUnitName then
        unit = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+ability.mouseVector*range,false,caster,caster:GetOwner(),caster:GetTeamNumber())
        unit:SetAbsOrigin(caster:GetAbsOrigin()+ability.mouseVector*range)
        unit:FindAbilityByName("dummy_unit"):SetLevel(1)  
      end
      local projTable = {
        Target = unit,
        Source = caster,
        Ability = ability,
        EffectName = "particles/units/heroes/hero_tinker/tinker_laser.vpcf",
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"), 
        vSpawnOrigin = caster:GetAbsOrigin()
      }
      ProjectileManager:CreateTrackingProjectile(projTable)
    end,
  }
  local proj = Projectiles:CreateProjectile(projectile)
end

-- March
tinker_special_bottom = class({})
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

-- Rockets -- Rockets are slowly homing and appear after some time
tinker_special_mid = class({})

function tinker_special_mid:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function tinker_special_mid:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function tinker_special_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")

  caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")

  self.targets = {}
  self.projectiles = {}
  local ability = self
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)

  self.targets[1] = units[1]
  self.targets[2] = units[2]
  if ability.targets[1] then
    local projTable = {
      Target = self.targets[1],
      Source = caster,
      Ability = ability,
      EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
      bDodgeable = false,
      bProvidesVision = true,
      iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"), 
      vSpawnOrigin = caster:GetAbsOrigin(),
    }
    ProjectileManager:CreateTrackingProjectile(projTable)
    
  end

  if ability.targets[2] then
    local projTable = {
      Target = self.targets[2],
      Source = caster,
      Ability = ability,
      EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
      bDodgeable = false,
      bProvidesVision = true,
      iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"), 
      vSpawnOrigin = caster:GetAbsOrigin()
    }
    ProjectileManager:CreateTrackingProjectile(projTable)
  end
end

function tinker_special_mid:OnProjectileHit(hTarget,vLocation)
  local caster = self:GetCaster()
  local ability = self

  -- Add a little delay because the rockets don't disappear as soon as this happens :s
  Timers:CreateTimer(0.1,function()
    if IsValidEntity(hTarget) then
      local damageTable = {
        victim = hTarget,
        attacker = caster,
        damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
    end
  end)
end