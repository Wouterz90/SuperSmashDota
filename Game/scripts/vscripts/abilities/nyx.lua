--Nyx

-- Side Mana burn, damage + silence
-- Mid Reflect
-- Bottom Linear projectile from platform
-- Top Quick invisible jump, heavy damage when hitting

nyx_assassin_special_bottom = class({})
function nyx_assassin_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  if not caster:isOnPlatform() then return false end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function nyx_assassin_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function nyx_assassin_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local vector = self.mouseVector
  local ability = self
  StoreSpecialKeyValues(self)
  local duration = self.duration
  local projectile_speed = self.projectile_speed
  
  if not caster:isOnPlatform() then
    ability:EndCooldown()
    return
  end

  -- Move the caster a little up to prevent it missing
  --caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,10))
  -- Drop the projectile immediatly so it follows the platform
 

  caster:EmitSound("Hero_NyxAssassin.Impale")

  -- Fire a projectile to determine if a unit would be hit
  local projectile = {
    --EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
    EffectName = "particles/nyx/nyx_assassin_impale.vpcf",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,10),  
    --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,0)},
    fDistance = self.range,
    fStartRadius = 200,
    fEndRadius = 200,
    Source = caster,
    --fExpireTime = self:GetSpecialValueFor("duration"),
    vVelocity = caster:GetForwardVector() * projectile_speed ,--self.mouseVector * (self:GetSpecialValueFor("distance")/self:GetSpecialValueFor("duration")), -- RandomVector(1000),
    UnitBehavior = PROJECTILES_NOTHING ,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_NOTHING,
    GroundBehavior = PROJECTILES_FOLLOW,
    fGroundOffset = 100,
    nChangeMax = 1,
    bRecreateOnChange = true,
    bZCheck = true,
    bGroundLock = false,
    bProvidesVision = true,
    iVisionRadius = 200,
    iVisionTeamNumber = caster:GetTeam(),
    bFlyingVision = false,
    fVisionTickTime = .1,
    fVisionLingerDuration = 1,
    draw = IsInToolsMode(),
    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
    OnUnitHit = function(self, unit)
      local damageTable = {
        victim = unit,
        attacker = caster,
        damage =  ability.damage + RandomInt(0,ability.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      casterloc = caster:GetAbsOrigin()
      caster:SetAbsOrigin(unit:GetAbsOrigin()-Vector(0,0,-50))
      ApplyDamage(damageTable)
      caster:SetAbsOrigin(casterloc)
      unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = duration})
      caster:EmitSound("Hero_NyxAssassin.Impale.Target")
    end,
  }
  local proj = Projectiles:CreateProjectile(projectile)
end

nyx_assassin_special_side = class({})
function nyx_assassin_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=1.75})
  return true
end

function nyx_assassin_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function nyx_assassin_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local vector = self.mouseVector
  local ability = self
  ability.unit = nil

  caster:EmitSound("Hero_NyxAssassin.ManaBurn.Cast")

  -- Fire a projectile to determine if a unit would be hit
  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    EffectName = "",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    vSpawnOrigin = caster:GetAbsOrigin(),
    --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,0)},
    fDistance = range,
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
      ability.unit = unit
      ApplyDamage(damageTable)
      unit:AddNewModifier(caster,ability,"modifier_smash_silence",{duration = ability:GetSpecialValueFor("silence_duration")})
      caster:EmitSound("Hero_NyxAssassin.ManaBurn.Target")
    end,
    OnFinish = function(self,unit)
      if not ability.unit then
        unit = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+ability.mouseVector*range,false,caster,caster:GetOwner(),caster:GetTeamNumber())
        unit:SetAbsOrigin(caster:GetAbsOrigin()+ability.mouseVector*range)
        unit:FindAbilityByName("dummy_unit"):SetLevel(1)
      else
        unit = ability.unit  
      end
      local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN, unit )
      Timers:CreateTimer( 1, function()
        ParticleManager:DestroyParticle( particle, false)
        ParticleManager:ReleaseParticleIndex(particle)
        ability.unit = nil
      end)
    end,
  }
  local proj = Projectiles:CreateProjectile(projectile)
end

nyx_assassin_special_top = class({})
function nyx_assassin_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
  return true
end

function nyx_assassin_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function nyx_assassin_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local vector = self.mouseVector
  local ability = self

  caster:EmitSound("Hero_NyxAssassin.SpikedCarapace")

  caster:AddNewModifier(caster,ability,"modifier_nyx_assassin_spiked_carapace_smash",{ duration = ability:GetSpecialValueFor("duration")})

  
end

LinkLuaModifier("modifier_nyx_assassin_spiked_carapace_smash","abilities/nyx.lua",LUA_MODIFIER_MOTION_NONE)
modifier_nyx_assassin_spiked_carapace_smash = class({})

function modifier_nyx_assassin_spiked_carapace_smash:OnCreated()
  if IsServer() then
    --self:StartIntervalThink(1/32)
    local caster = self:GetCaster()
    local vector = self:GetAbility().mouseVector
    local range = self:GetAbility():GetSpecialValueFor("jump_speed")
    caster:SetStaticVelocity("nyx_spiked",vector*range)
  end
end

function modifier_nyx_assassin_spiked_carapace_smash:OnDestroy()
  local caster = self:GetCaster()
  caster:SetStaticVelocity("nyx_spiked",VECTOR_0)
  --caster:SetAbsOrigin(caster:GetAbsOrigin()+vector*range/32)
end
function modifier_nyx_assassin_spiked_carapace_smash:DeclareFunctions()
  local funcs = 
  {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }
  return funcs
end

function modifier_nyx_assassin_spiked_carapace_smash:OnTakeDamage(keys)
  if IsServer() and keys.unit == self:GetParent() then
    self:GetCaster().bFilterThisDamage = true

    local damageTable = {
      victim = keys.attacker,
      attacker = self:GetParent(),
      damage =  keys.damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
    keys.attacker:AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_smash_stun",{duration = self:GetAbility():GetSpecialValueFor("duration")})  
  end
end

function modifier_nyx_assassin_spiked_carapace_smash:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW;
end

function modifier_nyx_assassin_spiked_carapace_smash:GetEffectName()
    return "particles/items_fx/blademail.vpcf";
end

function modifier_nyx_assassin_spiked_carapace_smash:GetStatusEffectName()
    return "particles/status_fx/status_effect_blademail.vpcf";
end

function modifier_nyx_assassin_spiked_carapace_smash:GetHeroEffectName()
    return "particles/status_fx/status_effect_blademail.vpcf";
end

--[[
nyx_assassin_special_top = class({})
function nyx_assassin_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  if caster.jumps > 2 then return false end
  return true
end

function nyx_assassin_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function nyx_assassin_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("movespeed")
  caster.jumps = 3

  local vector = self.mouseVector
  
  local count = 0
  -- Invis
  caster:AddNewModifier(caster,self,"modifier_invisible",{ duration = self:GetSpecialValueFor("duration")})
  local particle_one = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_vendetta_start.vpcf", PATTACH_ABSORIGIN, caster)
  Timers:CreateTimer(function()
    caster:SetAbsOrigin(caster:GetAbsOrigin()+vector*range/32)
    if count < 16 then
      count = count +1
      return 1/32
    else
      -- Add the bonus damage modifier
      caster:RemoveModifierByName("modifier_invisible")
      caster:AddNewModifier(caster,self,"modifier_nyx_vendetta",{ duration = self:GetSpecialValueFor("vendetta_duration")})
      return
    end
  end)

  -- Release particles
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle_one,false)
    ParticleManager:ReleaseParticleIndex(particle_one)
  end)
end

LinkLuaModifier("modifier_nyx_vendetta","abilities/nyx.lua",LUA_MODIFIER_MOTION_NONE)
modifier_nyx_vendetta = class({})

function modifier_nyx_vendetta:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
  }
  return funcs
end

function modifier_nyx_vendetta:GetModifierTotalDamageOutgoing_Percentage(keys)
  if IsServer() and keys.attacker == self:GetParent() then
    self:Destroy()
    return self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
  end
end]]