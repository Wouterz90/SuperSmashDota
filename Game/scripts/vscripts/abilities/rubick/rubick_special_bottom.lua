rubick_special_bottom = class({})

function rubick_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Rubick.FadeBolt.Cast")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.5})
  return true
end

function rubick_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Rubick.FadeBolt.Cast")
  EndAnimation(caster)
end

function rubick_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)

  ability.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_ABSORIGIN, caster)
  ability.source = caster
  ability.targets = {}

  local units = FindUnitsInRadius(caster:GetTeam(),caster:GetAbsOrigin(), nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),self.search_radius)
  local direction
  if units and units[1] then
    direction = (units[1]:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
  else
    if self.mouseVector.x > 0 then
      direction = Vec(1,0)
    else
      direction = Vec(-1,0)
    end
  end

  ability.projectileTable = 
    { 
      vDirection = direction,
      hCaster = caster,
      vSpawnOrigin = caster:GetAbsOrigin(),
      flMaxDistance = ability.range,
      flSpeed = ability.projectile_speed,
      flRadius = ability.projectile_radius,
      sEffectName = "particles/units/heroes/hero_rubick/rubick_fade_bolt.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitTest = function(projectile, unit) return unit.IsSmashUnit and unit:IsRealHero() and unit:GetTeamNumber() ~= caster:GetTeamNumber() and not ability.targets.unit end,
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
        caster:EmitSound("Hero_Rubick.FadeBolt.Target")
        
        unit:AddNewModifier(caster,self,"modifier_rubick_fade_bolt",{duration = ability.duration})
        ability.targets.unit = true
        ability:Relaunch(unit,ability.targets)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      OnFinish = function(projectile)
        ParticleManager:DestroyParticle(ability.particle,false)
        ParticleManager:ReleaseParticleIndex(ability.particle)
      end,
      OnProjectileThink = function(projectile,location)

        ParticleManager:SetParticleControl(ability.particle, 0, ability.source:GetAbsOrigin())
        ParticleManager:SetParticleControl(ability.particle, 1, projectile:GetAbsOrigin())
      end,
      
    }
  Physics2D:CreateLinearProjectile(ability.projectileTable) --
end

function rubick_special_bottom:Relaunch(hTarget,keys)
  local units = FindUnitsInRadius(self:GetCaster():GetTeam(),hTarget:GetAbsOrigin(), nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
  units = FilterUnitsBasedOnHeight(units,hTarget:GetAbsOrigin(),self.search_radius)
  for i=#units,1,-1 do
    if self.targets[units[i]] then
      table.remove(units, i)
    end
  end
  if units and units[1] then
    self.projectileTable.direction = (units[1]:GetAbsOrigin() - hTarget:GetAbsOrigin()):Normalized()
    Physics2D:CreateLinearProjectile(self.projectileTable)
  end
  
end

LinkLuaModifier("modifier_rubick_fade_bolt","abilities/rubick/rubick_special_bottom.lua",LUA_MODIFIER_MOTION_NONE)
modifier_rubick_fade_bolt  = class({})

function modifier_rubick_fade_bolt:GetEffectName()
  return "particles/units/heroes/hero_rubick/rubick_fade_bolt_debuff.vpcf"
end

function modifier_rubick_fade_bolt:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_rubick_fade_bolt:OnCreated()
  if IsServer() then
    print(self:GetParent():GetUnitName())
    StoreSpecialKeyValues(self,self:GetAbility())
    self:GetParent().attackDamageFactor = self:GetParent().attackDamageFactor - self.damage_reduction
  end
end

function modifier_rubick_fade_bolt:OnDestroy()
  if IsServer() then
    self:GetParent().attackDamageFactor = self:GetParent().attackDamageFactor + self.damage_reduction
  end
end