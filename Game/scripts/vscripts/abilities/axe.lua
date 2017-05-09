--[[axe_special_side = class({})
-- Throw a small projectile that deals damage and slows the target. Dispels when dealing damage

function axe_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_AbyssalUnderlord.Firestorm.Start")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function axe_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_AbyssalUnderlord.Firestorm.Start")
  EndAnimation(caster)
end

function axe_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local radius = 200--self:GetSpecialValueFor("radius")
  local range = 600--self:GetSpecialValueFor("range")
  local projectile_speed = 600--self:GetSpecialValueFor("projectile_speed")
  local direction = self.mouseVector
  local ability = self
  local duration = 4 --self:GetSpecialValueFor("duration")

  -- Fire the projectile particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf

  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    EffectName = "particles/axe/axe_battle_hunger.vpcf",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    --vSpawnOrigin = caster:GetAbsOrigin(),
    vSpawnOrigin = {unit=caster, attach="attach_attack1"},
    fDistance = range,
    fStartRadius = radius,
    fEndRadius = radius,
    Source = caster,
    fExpireTime = range/projectile_speed,
    vVelocity = self.mouseVector * projectile_speed, -- RandomVector(1000),
    UnitBehavior = PROJECTILES_DESTROY,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_DESTROY,
    GroundBehavior = PROJECTILES_DESTROY,
    fGroundOffset = 0,
    nChangeMax = 1,
    bRecreateOnChange = true,
    bZCheck = true,
    bGroundLock = false,
    bProvidesVision = true,
    iVisionRadius = radius,
    iVisionTeamNumber = caster:GetTeam(),
    bFlyingVision = false,
    fVisionTickTime = .1,
    fVisionLingerDuration = 1,
    draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},

    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
    OnUnitHit = function(self, unit)
      caster:EmitSound("Hero_Puck.ProjectileImpact")
      unit:AddNewModifier(caster,ability,"modifier_axe_battle_hunger_smash",{ duration = duration})
      
    end,
  }
  Projectiles:CreateProjectile(projectile)
end

LinkLuaModifier("modifier_axe_battle_hunger_smash","abilities/axe.lua",LUA_MODIFIER_MOTION_NONE)
modifier_axe_battle_hunger_smash = class({})
function modifier_axe_battle_hunger_smash:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/8)
  end
end

function modifier_axe_battle_hunger_smash:OnIntervalThink()
  local damageTable = {
    victim = self:GetParent(),
    attacker = self:GetCaster(),
    damage = self:GetAbility():GetSpecialValueFor("damage") /8,
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = self:GetAbility(),
  }
  ApplyDamage(damageTable) -- Push
end

function modifier_axe_battle_hunger_smash:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }
  return funcs
end

function modifier_axe_battle_hunger_smash:OnTakeDamage(keys)
  if IsServer() and keys.attacker == self:GetParent() then
    self:Destroy()
  end
end

function modifier_axe_battle_hunger_smash:GetEffectName()
  return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end
function modifier_axe_battle_hunger_smash:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end
]]
-- Spin once dealing damage to everyone around you
axe_special_side = class({})

function axe_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end

  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  caster:EmitSound("Hero_Axe.CounterHelix")
  return true
end

function axe_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
  caster:StopSound("Hero_Axe.CounterHelix")
end

function axe_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  
  -- Visual stuff
  StartAnimation(self:GetCaster(), {duration=self:GetSpecialValueFor("spin_duration"), activity=ACT_DOTA_CAST_ABILITY_3, rate=0.5})
  caster:AddNewModifier(caster,self,"modifier_axe_counter_helix_smash",{duration = self:GetSpecialValueFor("spin_duration")})

  -- Find the units and damage them
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    local damage = self:GetSpecialValueFor("damage") +  RandomInt(0,self:GetSpecialValueFor("damage_offset"))
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable)
  end
end

LinkLuaModifier("modifier_axe_counter_helix_smash","abilities/axe.lua",LUA_MODIFIER_MOTION_NONE)
modifier_axe_counter_helix_smash = class({})

function modifier_axe_counter_helix_smash:GetEffectName()
  return "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"
end
function modifier_axe_counter_helix_smash:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end



axe_special_top = class({})
-- Jump and dunk

function axe_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  --StartAnimation(self:GetCaster(),{duration=self:GetCastPoint()+0.1, activity=ACT_DOTA_TELEPORT_END, rate=0.5})
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint()+0.5+0.25, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.6})
  self:GetCaster():EmitSound("Hero_MonkeyKing.TreeJump.Cast")
  local caster = self:GetCaster()

  if caster.jumps > 2 then return end
  return true
end


function axe_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = 400--self:GetSpecialValueFor("radius")
  local jump_speed = 1200 --self:GetSpecialValueFor("jump_speed")
  local vector = self.mouseVector
  FreezeAnimation(self:GetCaster(),0.75)
  caster.jumps = 3
  local count = 0
  -- Go up first
  --StartAnimation(self:GetCaster(),{duration=0.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.75})
  Timers:CreateTimer(function()
    caster:SetAbsOrigin(caster:GetAbsOrigin()+vector*jump_speed/32)
    if count < 16 then
      count = count +1
      return 1/32
    else
      
      -- Hit everyone in front of you
      local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin() + caster:GetForwardVector() * (radius/2), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + caster:GetForwardVector() * (radius/2),radius)
      for k,v in pairs(units) do
        -- Deal damage
        local damageTable = {
          victim = v,
          attacker = caster,
          damage = self:GetSpecialValueFor("damage") + RandomInt(0,self:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self,
        }
        ApplyDamage(damageTable)
      end
      if units and #units > 0 then
        -- Refresh this if you hit something
        caster:EmitSound("Hero_Axe.Culling_Blade_Success")
        self:EndCooldown()
      else
        caster:EmitSound("Hero_Axe.Culling_Blade_Fail")
      end
      return
    end
  end)
end

axe_special_bottom = class({})

function axe_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1})
  self:GetCaster():EmitSound("Hero_Axe.BerserkersCall.Start")
  return true
end

function axe_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Axe.BerserkersCall.Start")
  EndAnimation(caster)
end


function axe_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local duration = self:GetSpecialValueFor("taunt_duration")
  caster:EmitSound("Hero_Axe.Berserkers_Call")
  
  caster:AddNewModifier(caster,ability,"modifier_axe_call_armor",{duration = duration})

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    -- Add the taunt modifier + stun
    v:AddNewModifier(caster,self,"modifier_smash_stun",{duration = duration})
    v:AddNewModifier(caster,self,"modifier_axe_call_taunt",{duration = duration})
  end
end

-- Modifier to increase axe armor
LinkLuaModifier("modifier_axe_call_armor","abilities/axe.lua",LUA_MODIFIER_MOTION_NONE)
modifier_axe_call_armor = class({})

function modifier_axe_call_armor:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
  }
  return funcs
end

function modifier_axe_call_armor:GetModifierIncomingDamage_Percentage(keys)
  PrintTable(keys)
  if IsServer() and keys.target == self:GetParent() and string.find(keys.inflictor:GetAbilityName(),"basic_attack") then
    return -self:GetAbility():GetSpecialValueFor("damage_reduction")
  else
    return 0
  end
end

function modifier_axe_call_armor:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_axe_call_armor:GetEffectName()
  return "particles/units/heroes/hero_axe/axe_beserkers_call_owner.vpcf"
end

-- Modifier to lure targets towards axe
LinkLuaModifier("modifier_axe_call_taunt","abilities/axe.lua",LUA_MODIFIER_MOTION_NONE)
modifier_axe_call_taunt = class({})

function modifier_axe_call_taunt:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
    self.counter = 0
  end
end

function modifier_axe_call_taunt:OnIntervalThink()
  if self.counter < self:GetAbility():GetSpecialValueFor("taunt_duration") /32 then
    local direction = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
    local taunt_speed = self:GetAbility():GetSpecialValueFor("taunt_speed")
    self:GetParent():SetAbsOrigin(self:GetParent():GetAbsOrigin()+direction*taunt_speed)
  else
    self:Destroy()
  end
end

function modifier_axe_call_taunt:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_axe_call_taunt:GetEffectName()
  return "particles/units/heroes/hero_axe/axe_beserkers_call.vpcf"
end