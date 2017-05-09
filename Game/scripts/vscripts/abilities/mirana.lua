mirana_special_bottom = class({})

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

  
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  -- Not filtering for height
  for k,v in pairs(units) do
    -- Create a particle that shoots from above them
    local projectile = {
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      EffectName = "venge/venge_side.vpcf",
      --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
      --EeffectName = "",
      --vSpawnOrigin = caster:GetAbsOrigin(),
      vSpawnOrigin = Vector(v:GetAbsOrigin().x,0,2500),
      fDistance = 4000,
      fStartRadius = self:GetSpecialValueFor("star_radius"),
      fEndRadius = self:GetSpecialValueFor("star_radius"),
      Source = caster,
      fExpireTime = 8,
      vVelocity = Vector(0,0,-1) * self:GetSpecialValueFor("drop_speed"), -- RandomVector(1000),
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
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},
      

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)

        caster:EmitSound("Ability.StarfallImpact")
      end,
      OnGroundHit = function(self,loc)
        local plat = FindNearestPlatform(loc)
        if plat then
          DestroyPlatform(plat,10)
        end
      end,
    }
    Projectiles:CreateProjectile(projectile)


    Timers:CreateTimer(0.5,function()
      local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      local vSpOrigin = Vector(units[1]:GetAbsOrigin().x,0,2500)
      -- Not filtering for height
      local projectile = {
        --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
        EffectName = "venge/venge_side.vpcf",
        --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
        --EeffectName = "",
        --vSpawnOrigin = caster:GetAbsOrigin(),
        vSpawnOrigin = vSpOrigin,
        fDistance = 4000,
        fStartRadius = self:GetSpecialValueFor("star_radius"),
        fEndRadius = self:GetSpecialValueFor("star_radius"),
        Source = caster,
        fExpireTime = 8,
        vVelocity = Vector(0,0,-1) * self:GetSpecialValueFor("drop_speed"), -- RandomVector(1000),
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
        bRecreateOnChange = true,
        bZCheck = true,
        bGroundLock = false,
        bProvidesVision = true,
        iVisionRadius = self:GetSpecialValueFor("radius"),
        iVisionTeamNumber = caster:GetTeam(),
        bFlyingVision = false,
        fVisionTickTime = .1,
        fVisionLingerDuration = 1,
        draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},
        

        UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
        OnUnitHit = function(self, unit) 
          local damageTable = {
            victim = unit,
            attacker = caster,
            damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
          }
          ApplyDamage(damageTable)
          caster:EmitSound("Ability.StarfallImpact")
        end,
        OnGroundHit = function(self,loc)
        local plat = FindNearestPlatform(loc)
        if plat then
          DestroyPlatform(plat,10)
        end
      end,
      }
      if IsValidEntity(units[1]) then
        Projectiles:CreateProjectile(projectile)
      end
    end)
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
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function mirana_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function mirana_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local radius = self:GetSpecialValueFor("radius")
  local projectile_speed = self:GetSpecialValueFor("projectile_speed")
  local distance_factor = self:GetSpecialValueFor("stun_distance_factor")
  

  local projectile = {
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      EffectName = "particles/mirana/mirana_side.vpcf",
      --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
      --EeffectName = "",
      --vSpawnOrigin = caster:GetAbsOrigin(),
      vSpawnOrigin = {unit=caster, attach="attach_attack1"},
      fDistance = 4000,
      fStartRadius = self:GetSpecialValueFor("radius"),
      fEndRadius = self:GetSpecialValueFor("radius"),
      Source = caster,
      fExpireTime = 8,
      vVelocity = self.mouseVector * self:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
      UnitBehavior = PROJECTILES_DESTROY ,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_DESTROY,
      GroundBehavior = PROJECTILES_NOTHING,
      fGroundOffset = 0,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},
      --iPositionCP = 0,
      --iVelocityCP = 1,
      --ControlPoints = {[5]=Vector(100,0,0), [10]=Vector(0,0,1)},
      --ControlPointForwards = {[4]=hero:GetForwardVector() * -1},
      --ControlPointOrientations = {[1]={hero:GetForwardVector() * -1, hero:GetForwardVector() * -1, hero:GetForwardVector() * -1}},
      --[[ControlPointEntityAttaches = {[0]={
        unit = hero,
        pattach = PATTACH_ABSORIGIN_FOLLOW,
        attachPoint = "attach_attack1", -- nil
        origin = Vector(0,0,0)
      }},]]
      --fRehitDelay = .3,
      --fChangeDelay = 1,
      --fRadiusStep = 10,
      --bUseFindUnitsInRadius = false,

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
        local stun_duration = self:GetDistanceTraveled()/distance_factor
        if stun_duration > 5 then
          stun_duration = 5
        end

        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = stun_duration})
        caster:EmitSound("Hero_Mirana.ProjectileImpact")
      end,
    }
    Projectiles:CreateProjectile(projectile)
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
  local modifier = caster:AddNewModifier(caster,self,"modifier_mirana_leap_jump",{duration = self:GetSpecialValueFor("jump_duration")})
  modifier.vector = vector
  caster:AddNewModifier(caster,self,"modifier_mirana_leap_ms",{duration = self:GetSpecialValueFor("buff_duration")})
  
end

LinkLuaModifier("modifier_mirana_leap_jump","abilities/mirana.lua",LUA_MODIFIER_MOTION_NONE)
modifier_mirana_leap_jump = class({})

function modifier_mirana_leap_jump:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_mirana_leap_jump:OnIntervalThink()
  -- handle lowest platform
  if self:GetParent():isUnderPlatform() and self:GetCaster():HasModifier("modifier_basic") then return end
  --

  local vec = self:GetParent():GetAbsOrigin()
  vec = vec + self.vector * self:GetAbility():GetSpecialValueFor("jump_speed")
  self:GetParent():SetAbsOrigin(vec)
end

function modifier_mirana_leap_jump:OnDestroy()
  if IsServer() then
    self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
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

