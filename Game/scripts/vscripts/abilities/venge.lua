vengefulspirit_special_top = class({})

function vengefulspirit_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_top:OnSpellStart()
  local caster = self:GetCaster()
  if caster.jumps > 2 then return end
  StoreSpecialKeyValues(self)
  local ability = self
  caster.jumps = 3 
  caster:AddNewModifier(caster,self,"modifier_smash_stun",{})

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/venge/venge_swap.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      UnitTest = function(projectile, unit) return unit.IsSmashUnit and unit:IsRealHero() and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(projectile,unit) 
        ability.unit = unit
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage") + RandomInt(0,caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = caster:FindAbilityByName("vengefulspirit_special_top"),
        }
        ApplyDamage(damageTable)

      end,
      OnFinish = function(projectile)
        local unit = ability.unit or projectile
        caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
        
        local particle_a = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_a, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_a, 1, unit:GetAbsOrigin())

        local particle_b = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_b, 0, unit:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_b, 1, caster:GetAbsOrigin())

        local targetLoc = unit:GetAbsOrigin()
        local casterLoc = caster:GetAbsOrigin()
        unit:SetAbsOrigin(casterLoc)
        caster:SetAbsOrigin(targetLoc)
        caster:RemoveModifierByName("modifier_smash_stun")
        unit.jumps = 0

        Timers:CreateTimer(1,function()
          ParticleManager:DestroyParticle(particle_a,false)
          ParticleManager:ReleaseParticleIndex(particle_a)
          ParticleManager:DestroyParticle(particle_b,false)
          ParticleManager:ReleaseParticleIndex(particle_b)
        end)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable)


    
end

vengefulspirit_special_side = class({})

function vengefulspirit_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_side:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local ability = self

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
      PlatformBehavior = PROJECTILES_BOUNCE,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      UnitTest = function(projectile, unit) return unit.IsSmashUnit and unit:IsRealHero() and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(projectile,unit) 
  
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage") + RandomInt(0,caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = caster:FindAbilityByName("vengefulspirit_special_top"),
        }

        local casterLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(projectile.location)
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(casterLoc)

        caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
        unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = ability:GetSpecialValueFor("stun_duration")})

      end,
  
    }
  Physics2D:CreateLinearProjectile(projectileTable)
end



vengefulspirit_special_bottom = class({})

function vengefulspirit_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  local ability = self

  caster:EmitSound("Hero_VengefulSpirit.WaveOfTerror")

  local projectile = {
    EffectName = "particles/venge/vengeful_wave_of_terror.vpcf",
    vSpawnOrigin = caster:GetAbsOrigin(),
    fDistance = self:GetSpecialValueFor("range"),
    fStartRadius = self:GetSpecialValueFor("radius"),
    fEndRadius = self:GetSpecialValueFor("radius"),
    Source = caster,
    fExpireTime = self:GetSpecialValueFor("range")/self:GetSpecialValueFor("projectile_speed"),
    vVelocity = Vector(1,0,0) * ability:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
    UnitBehavior = PROJECTILES_NOTHING,
    bMultipleHits = false,
    bIgnoreSource = true,
    WallBehavior = PROJECTILES_FOLLOW,
    GroundBehavior = PROJECTILES_FOLLOW,
    fGroundOffset = 0,
    nChangeMax = 1,
    bRecreateOnChange = true,
    bZCheck = true,
    bGroundLock = false,
    draw = IsInToolsMode(),--             draw = {alpha=1, color=Vector(200,0,0)},

    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber()--[[ and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS]] end,
    OnUnitHit = function(self, unit) 
      local damageTable = {
        victim = unit,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
      unit:AddNewModifier(caster,ability,"modifier_wave_of_terror_armor_reduction",{duration = ability:GetSpecialValueFor("duration")})
    end,
  }
  local proj_1 = Projectiles:CreateProjectile(projectile)
  projectile.vVelocity = Vector(-1,0,0) * ability:GetSpecialValueFor("projectile_speed")
  local proj_2 = Projectiles:CreateProjectile(projectile)
end

LinkLuaModifier("modifier_wave_of_terror_armor_reduction","abilities/venge.lua",LUA_MODIFIER_MOTION_NONE)
modifier_wave_of_terror_armor_reduction = class({})
function modifier_wave_of_terror_armor_reduction:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
  return funcs
end

function modifier_wave_of_terror_armor_reduction:GetModifierPhysicalArmorBonus()
  return self:GetAbility():GetSpecialValueFor("minus_armor") * -1
end

function modifier_wave_of_terror_armor_reduction:GetEffectName()
  return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf"
end
function modifier_wave_of_terror_armor_reduction:GetEffectAttachType()
  return PATTACH_ABSORIGIN
end



