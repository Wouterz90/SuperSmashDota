rattletrap_special_bottom = class({})
-- Battery Assault(3s, per 0.5?)
function rattletrap_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function rattletrap_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function rattletrap_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local explosion_radius = self:GetSpecialValueFor("explosion_radius")
  local interval = self:GetSpecialValueFor("interval")
  local duration = self:GetSpecialValueFor("duration")
  local particles = {}
  local count = 0

  Timers:CreateTimer(0,function()
    if count <= duration/interval then
      caster:EmitSound("Hero_Rattletrap.Battery_Assault_Launch")
      -- Look for targets
      local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
      if units[1] then
        caster:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
        local assaultloc = units[1]:GetAbsOrigin() + Vector(RandomInt(-50,50),0,RandomInt(-50,50))
        particles[count] = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN, caster) 
        ParticleManager:SetParticleControl(particles[count], 0, assaultloc)

        local damageTable = {
          victim = units[1],
          attacker = caster,
          damage = self:GetSpecialValueFor("damage") + RandomInt(0,self:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self,
        }
        ApplyDamage(damageTable)
      else
        local assaultloc = caster:GetAbsOrigin() + RandomVector(radius)
        particles[count] = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_ABSORIGIN, caster) 
        ParticleManager:SetParticleControl(particles[count], 0, assaultloc)
      end
      
      count = count + 1
      return interval
    else
      return
    end
  end)
  Timers:CreateTimer(duration + 1,function()
    for k,v in pairs (particles) do
      ParticleManager:DestroyParticle(v,false)
      ParticleManager:ReleaseParticleIndex(v)
    end
  end)

end

rattletrap_special_side = class({})
function rattletrap_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function rattletrap_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function rattletrap_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local range = ability:GetSpecialValueFor("range")
  local radius = ability:GetSpecialValueFor("radius")
  local vector = self.mouseVectorDistance -- Based on distance
 
  

  caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Fire")
  self.unit = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin() + vector * range,false,caster,caster:GetOwner(),caster:GetTeamNumber())

  self.unit:SetAbsOrigin((caster:GetAbsOrigin() + vector * range))
  self.unit:FindAbilityByName("dummy_unit"):SetLevel(1)
  
  local projTable = {
    Target = self.unit,
    Source = caster,
    Ability = ability,
    EffectName = "particles/clockwerk/clockwerk_rocket.vpcf",
    bDodgeable = false,
    bProvidesVision = true,
    iMoveSpeed = ability:GetSpecialValueFor("projectile_speed"), 
    vSpawnOrigin = caster:GetAbsOrigin()
  }
  ProjectileManager:CreateTrackingProjectile(projTable)

 end 

function rattletrap_special_side:OnProjectileHit(hTarget,vLocation)
  local caster = self:GetCaster()
  local ability = self
  local radius = ability:GetSpecialValueFor("radius")
  self.casterloc = caster:GetAbsOrigin()
  local units = FindUnitsInRadius(caster:GetTeam(), vLocation , nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,vLocation,radius)

  -- Move to location to change damage origin
  caster:SetAbsOrigin(vLocation)
  caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")
  for k,v in pairs (units) do
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = ability,
    }
    ApplyDamage(damageTable)
  end
  Timers:CreateTimer(1,function()
    UTIL_Remove(self.unit)
  end)
    
  caster:SetAbsOrigin(self.casterloc)

end

rattletrap_special_top = class({})
-- Hookshot, stun and damage target if hits, go there anyways

function rattletrap_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  if caster.jumps > 2 then return end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  return true
end

function rattletrap_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function rattletrap_special_top:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local radius = self.radius
  local range = self.range
  local ability = self
  local vector = self.mouseVector

  caster.jumps = 3
  ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot_b.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControlEnt(ability.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(ability.particle, 3, caster:GetAbsOrigin())
  caster:EmitSound("Hero_Rattletrap.Hookshot.Fire")

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      --sEffectName = "particles/mirana/mirana_side.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
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

        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = ability.stun_duration})
        DealDamage(damageTable,projectile.location)
  
        caster:EmitSound("Hero_Phoenix.FireSpirits.ProjectileHit")
      end,
      OnFinish = function(projectile)
        
        ParticleManager:SetParticleControlEnt(ability.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(ability.particle, 3, projectile.location)
        Timers:CreateTimer(0.1,function()
          if ability.particle then
            ParticleManager:DestroyParticle(ability.particle,false)
            ParticleManager:ReleaseParticleIndex(ability.particle)
          end
        end)
        caster:SetAbsOrigin(projectile.location)
      end,
      OnProjectileThink = function(projectile,location)
        ParticleManager:SetParticleControlEnt(ability.particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(ability.particle, 3, projectile.location)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable)
end
  



--rattletrap_special_bottom = class({})
-- Cogs
--[[
function rattletrap_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function rattletrap_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function rattletrap_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  --local cogs = self:GetSpecialValueFor("cogs")
  local duration = self:GetSpecialValueFor("cog_duration")

  caster:EmitSound("Hero_Rattletrap.Power_Cogs")

  local upVector = caster:GetUpVector()
  local cogUnits = {}

  --Vectors for the cogs
  local Vectors = {
    Vector(0,0,0.75),
    Vector(0.5,0,0.5),
    Vector(0.75,0,0),
    Vector(0.5,0,-0.5),
    Vector(0,0,-0.75),
    Vector(-0.5,0,-0.5),
    Vector(-0.75,0,0),
    Vector(-0.5,0,0.5),
  }
  for k,v in pairs (Vectors) do
    local position = (caster:GetAbsOrigin() + v * radius)
     
    cogUnits[k] = CreateUnitByName("npc_dummy_unit",position,false,caster,caster:GetOwner(),caster:GetTeamNumber())
    cogUnits[k]:SetAbsOrigin(position)
    cogUnits[k]:FindAbilityByName("dummy_unit"):SetLevel(1)
    cogUnits[k]:AddNewModifier(caster,self,"modifier_rattletrap_cogs",{duration = duration})
    cogUnits[k]:SetModel("models/heroes/rattletrap/rattletrap_cog.vmdl")
    cogUnits[k]:SetForwardVector(Vector(0,1,1))
  end

end

LinkLuaModifier("modifier_rattletrap_cogs","abilities/clockwerk.lua",LUA_MODIFIER_MOTION_NONE)
modifier_rattletrap_cogs = class({})

function modifier_rattletrap_cogs:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
    self.targets ={}
  end
end

function modifier_rattletrap_cogs:OnIntervalThink()
  local caster = self:GetCaster()
  local unit = self:GetParent()
  local ability = self:GetAbility()
  if not ability then
    UTIL_Remove(unit)
  end

  local radius = ability:GetSpecialValueFor("explosion_radius")
  local units = FindUnitsInRadius(caster:GetTeam(), unit:GetAbsOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,unit:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not self.targets[v] then
      local damageTable = {
        victim = v,
        attacker = caster,
        damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
      --self.targets[v] = true
      caster:EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
      UTIL_Remove(unit)
    end
  end
end

function modifier_rattletrap_cogs:OnDestroy()
  if IsServer() then
    UTIL_Remove(self:GetParent())
  end
end]]