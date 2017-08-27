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
  ability.unit = nil
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
  local proj = Physics2D:CreateLinearProjectile(projectileTable)

    
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
  caster:EmitSound("Hero_VengefulSpirit.MagicMissile")

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = 150,--ability.projectile_speed,
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
          damage = ability.damage + RandomInt(0,ability.damage_offset),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = caster:FindAbilityByName("vengefulspirit_special_side"),
        }
        local casterLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(projectile.location)
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(casterLoc)
        caster:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
        
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

  local projectileTable = 
    { 
      vDirection = Vec(1,0),
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/venge/vengeful_wave_of_terror.vpcf",
      PlatformBehavior = PROJECTILES_BOUNCE,
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

        unit:AddNewModifier(caster,self,"modifier_wave_of_terror_armor_reduction",{duration = ability:GetSpecialValueFor("duration")})
      end,
  
    }
  Physics2D:CreateLinearProjectile(projectileTable)
  projectileTable.vDirection = Vec(-1,0)
  Physics2D:CreateLinearProjectile(projectileTable)
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



