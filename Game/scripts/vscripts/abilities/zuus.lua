zuus_special_top = class({})
function zuus_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_4, rate=self:GetCastPoint()/0.2})
  if caster.jumps > 2 then return false end
  return true
end

function zuus_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius")
  local ability = self
  caster.jumps = 3

  
  local cloud_duration = self:GetSpecialValueFor("cloud_duration")

  --Create cloud
  local cloud = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+Vector(0,0,range),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  cloud:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,range))
  cloud:FindAbilityByName("dummy_unit"):SetLevel(1)
  cloud:SetModel("models/heroes/zeus/zeus_sigil.vmdl")
  cloud:SetAngles(0,90,0)
  -- Jump
  local particle_one = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
  caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,range))
  local particle_two = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
  -- Release particles
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle_one,false)
    ParticleManager:ReleaseParticleIndex(particle_one)
    ParticleManager:DestroyParticle(particle_two,false)
    ParticleManager:ReleaseParticleIndex(particle_two)
  end)

  --Remove cloud and shock
  Timers:CreateTimer(cloud_duration,function()
    if IsValidEntity(cloud) then

      local units = FindUnitsInRadius(caster:GetTeam(), cloud:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      for k,v in pairs(units) do
        if v:GetAbsOrigin().z < cloud:GetAbsOrigin().z then
          -- Particle
          local particleThunder = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, v)
          ParticleManager:SetParticleControl(particleThunder,0, cloud:GetAbsOrigin())
          ParticleManager:SetParticleControl(particleThunder,1, v:GetAbsOrigin())
          caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
          Timers:CreateTimer(1,function()
            ParticleManager:DestroyParticle(particleThunder,false)
            ParticleManager:ReleaseParticleIndex(particleThunder)
          end)
          
          -- Damage
          local damageTable = {
            victim = v,
            attacker = caster,
            damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
          }
          local oldloc = caster:GetAbsOrigin()
          caster:SetAbsOrigin(cloud:GetAbsOrigin())
          ApplyDamage(damageTable)
          caster:SetAbsOrigin(oldloc)
        end
      end
      
      UTIL_Remove(cloud)
    end
  end)  
end

zuus_special_side = class({})
function zuus_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.2})
  return true
end

function zuus_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_side:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius") *2
  local vector = self.mouseVector
  local ability = self

  -- Shoot a linear projectile that searches for target, once acquired, it becomes a tracking projectile till another unit is closer and in search range 

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flDuration = ability.max_duration,
      sEffectName = "particles/units/heroes/hero_zuus/zuus_base_attack.vpcf",
      PlatformBehavior = PROJECTILES_BOUNCE,
      OnPlatformHit = function(projectile,unit)
        caster:EmitSound("Hero_Disruptor.ThunderStrike.Target") 
      end,
      UnitBehavior = PROJECTILES_DESTROY,
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
        
        ability.target = unit
  
        caster:EmitSound("Hero_Zuus.ArcLightning.Target")
  
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_zuus/zuus_base_attack_explosion.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location, true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
      end,
      OnProjectileThink = function(projectile,location)
        local units = FindUnitsInRadius(caster:GetTeam(), location, nil, ability.search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
        units = FilterUnitsBasedOnHeight(units,location,ability.search_radius)
        if units[1] then
          projectile.target = units[1]
          projectile.IsProjectile = "Tracking"
        end
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable) 
         
end

zuus_special_bottom = class({})

function zuus_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.4})
  return true
end

function zuus_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local range = self.range
  local radius = self.radius
  local vector = self.mouseVector
  local ability = self
  local direction = caster:GetForwardVector()
  local loc = caster:GetAbsOrigin() + direction * range
  loc.z = 2500
  --caster:EmitSound("Ability.LightStrikeArray")

  -- Fire a bolt from 2500 height
  -- A projectile is used to determine that first platform

  local projectileTable = 
    { 
      vDirection = Vector(0,0,-1),
      hCaster = caster,
      vSpawnOrigin = loc,
      flSpeed = 6000,
      flRadius = ability.radius,
      sEffectName = "",
      PlatformBehavior = PROJECTILES_DESTROY,
      OnPlatformHit = function(projectile,platform)
        DestroyPlatform(platform,5)
      end,
      UnitBehavior = PROJECTILES_NOTHING,
      UnitTest = function(projectile, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(projectile,unit)
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage =  ability.damage + RandomInt(0,ability.damage_offset),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        local casterLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(projectile.location)
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(casterLoc)
      end,
      OnFinish = function(projectile)
        loc = projectile.location
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
    
        ParticleManager:SetParticleControl(particle, 0, loc)
        ParticleManager:SetParticleControl(particle, 1, Vector(loc.x,loc.y,2500))
        ParticleManager:SetParticleControl(particle, 2, loc)
      
        Timers:CreateTimer(1,function()
          ParticleManager:DestroyParticle(particle,false)
          ParticleManager:ReleaseParticleIndex(particle)
        end)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable)
  
  caster:EmitSound("Hero_Zuus.LightningBolt")

end
