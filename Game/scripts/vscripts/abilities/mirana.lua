mirana_special_bottom = class({})

function mirana_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.5})
  return true
end

function mirana_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function mirana_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  ability = self

  caster:EmitSound("Ability.Starfall")
  self.targets = nil
  self.targets = {}
  self.targets2 = nil
  self.targets2 = {}

  -- Give mirana the starfall animation
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_circle.vpcf", PATTACH_ABSORIGIN, caster) 
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  -- Not filtering for height
  for k,v in pairs(units) do
    -- Create a particle that shoots from above them
    local loc = v:GetAbsOrigin()
    loc.z = 2500

    local projectileTable = 
    { 
      vDirection = Vector(0,0,-1),
      hCaster = caster,
      vSpawnOrigin = loc,
      flSpeed = ability.drop_speed,
      flRadius = ability.star_radius,
      sEffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
      PlatformBehavior = PROJECTILES_DESTROY,
      OnPlatformHit = function(projectile,platform)
        DestroyPlatform(platform,5)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      UnitTest = function(projectile, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(projectile,unit)
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage =  ability.damage + RandomInt(0,ability.damage_offset),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)

      end,
      OnFinish = function(projectile)
        loc = projectile.location
        
        caster:EmitSound("Ability.StarfallImpact")
        
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable)
  end
end


LinkLuaModifier("modifier_starfall_drop","abilities/mirana.lua",LUA_MODIFIER_MOTION_VERTICAL)
modifier_starfall_drop = class({})

function modifier_starfall_drop:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_starfall_drop:OnIntervalThink()
  local dropspeed =  self:GetAbility():GetSpecialValueFor("drop_speed")/32
  local vec = self:GetParent():GetAbsOrigin()
  local ability = self:GetAbility()
  local radius = ability:GetSpecialValueFor("star_radius")
  local caster = self:GetCaster()
  self:GetParent():SetAbsOrigin(Vector(vec.x,0,vec.z-dropspeed))
  -- Grab the units around it, filter them in height and add them to ability.targets
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not ability.targets[v] then
      ability.targets[v] = true
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
    end
  end

  if self:GetParent():isOnPlatform() then
    UTIL_Remove(self:GetParent())
  end 
  if vec[3] < 0 then
    UTIL_Remove(self:GetParent())
  end
end

--[[function modifier_starfall_drop:GetEffectName()
  return "particles/econ/courier/courier_gold_horn/courier_gold_horn_ambient_flying.vpcf"
end

function modifier_starfall_drop:GetEffectAttachType()
  return PATTACH_ABSORIGIN
end]]

LinkLuaModifier("modifier_starfall_drop2","abilities/mirana.lua",LUA_MODIFIER_MOTION_VERTICAL)
modifier_starfall_drop2 = class({})

function modifier_starfall_drop2:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_starfall_drop2:OnIntervalThink()
  local dropspeed =  self:GetAbility():GetSpecialValueFor("drop_speed")/32
  local vec = self:GetParent():GetAbsOrigin()
  local ability = self:GetAbility()
  local radius = ability:GetSpecialValueFor("star_radius")
  local caster = self:GetCaster()
  self:GetParent():SetAbsOrigin(Vector(vec.x,0,vec.z-dropspeed))
  -- Grab the units around it, filter them in height and add them to ability.targets
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not ability.targets2[v] then
      ability.targets2[v] = true
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
    end
  end

  if self:GetParent():isOnPlatform() then
    UTIL_Remove(self:GetParent())
  end 
  if vec[3] < 0 then
    UTIL_Remove(self:GetParent())
  end
end

--[[function modifier_starfall_drop2:GetEffectName()
  return "particles/econ/courier/courier_gold_horn/courier_gold_horn_ambient_flying.vpcf"
end

function modifier_starfall_drop2:GetEffectAttachType()
  return PATTACH_ABSORIGIN
end]]

mirana_special_side = class({})

function mirana_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.5})
  return true
end

function mirana_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function mirana_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)

  local radius = self:GetSpecialValueFor("radius")
  local projectile_speed = self:GetSpecialValueFor("projectile_speed")
  local distance_factor = self:GetSpecialValueFor("stun_distance_factor")



  --caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")
  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      vSpawnOrigin = caster:GetAbsOrigin(),
      flDuration = 8,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      sEffectName = "particles/mirana/mirana_side.vpcf",
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
        ApplyDamage(damageTable)
        
        local stun_duration = projectile.distanceTravelled/distance_factor
        if stun_duration > 5 then
          stun_duration = 5
        end

        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = stun_duration})
        
        caster:EmitSound("Hero_Mirana.ProjectileImpact")
  
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_spell_arrow_destruction.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location, true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable) 
  

  end

mirana_special_top = class({})

function mirana_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  if caster.jumps > 2 then return end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
  return true
end

function mirana_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function mirana_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local vector = self.mouseVector
  caster.jumps = 3
  caster:EmitSound("Ability.Leap")
  local modifier = caster:AddNewModifier(caster,self,"modifier_mirana_leap_jump",{duration = self:GetSpecialValueFor("jump_duration"),x=vector.x,z=vector.z})
  --modifier.vector = vector
  caster:AddNewModifier(caster,self,"modifier_mirana_leap_ms",{duration = self:GetSpecialValueFor("buff_duration")})
  
end

LinkLuaModifier("modifier_mirana_leap_jump","abilities/mirana.lua",LUA_MODIFIER_MOTION_NONE)
modifier_mirana_leap_jump = class({})

function modifier_mirana_leap_jump:OnCreated(keys)
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    --self:GetParent():SetStaticVelocity("mirana_leap",self.vector*self:GetAbility():GetSpecialValueFor("jump_speed")*30)
    Physics2D:SetStaticVelocity(self:GetParent(),"mirana_leap",Vec(keys.x,keys.z)*self.jump_speed)
    --self:StartIntervalThink(1/32)
  end
end

function modifier_mirana_leap_jump:OnIntervalThink()
  -- handle lowest platform
  --if self:GetParent():isUnderPlatform() and self:GetCaster():HasModifier("modifier_basic") then return end
  --

  local vec = self:GetParent():GetAbsOrigin()
  vec = vec + self.vector * self:GetAbility():GetSpecialValueFor("jump_speed")
  --self:GetParent():SetAbsOrigin(vec)
end

function modifier_mirana_leap_jump:OnDestroy()
  if IsServer() then
    local vel = Physics2D:GetStaticVelocity(self:GetParent(),"mirana_leap")
    Physics2D:SetStaticVelocity(self:GetParent(),"mirana_leap",Vec(0))
    --Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(vel.x*0.5,0))
    --self:GetParent():SetStaticVelocity("mirana_leap",VECTOR_0)
    --self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
  end
end

-- Could make this an aura later
-- Movement speed is multiplied because it's not the same as in game
LinkLuaModifier("modifier_mirana_leap_ms","abilities/mirana.lua",LUA_MODIFIER_MOTION_NONE)
modifier_mirana_leap_ms = class({})

function modifier_mirana_leap_ms:OnCreated()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor + (self:GetAbility():GetSpecialValueFor("speed_boost")/100)
  end
end

function modifier_mirana_leap_ms:OnDestroy()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor - (self:GetAbility():GetSpecialValueFor("speed_boost")/100)
  end
end

--[[mirana_special_bottom = class({})

function mirana_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function mirana_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function mirana_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")

  caster:AddNewModifier(caster,self,"modifier_invisible",{duration = self:GetSpecialValueFor("invis_duration")})
    
  
end]]

