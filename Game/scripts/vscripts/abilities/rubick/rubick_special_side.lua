rubick_special_side = class({})

function rubick_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Rubick.SpellSteal.Cast")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_1, rate=self:GetCastPoint()/0.5})
  return true
end

function rubick_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Rubick.SpellSteal.Cast")
  EndAnimation(caster)
end

function rubick_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)



  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      vSpawnOrigin = caster:GetAbsOrigin(),
      flMaxDistance = ability.range,
      flSpeed = ability.projectile_speed,
      flRadius = ability.projectile_radius,
      sEffectName = "particles/rubick/rubick_spell_steal.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitTest = function() return false end,
      UnitBehavior = PROJECTILES_NOTHING,
      ProjectileBehavior = PROJECTILES_DESTROY,
      OnProjectileHit = function(projectile,other)
        if other.caster:GetTeamNumber() ~= caster:GetTeamNumber() then
          if other.target then
            other.target = caster
          end
          other.caster = caster
          other.creationTime = GameRules:GetGameTime()
          other.distanceTravelled = 0
          local tab = CirclevsCircle(projectile,other)

          other.velocity = tab[3] * other.speed
          caster:EmitSound("Hero_Rubick.SpellSteal.Target")
          Physics2D:DestroyProjectile(projectile)
          ability:EndCooldown()
        end
      end,
      
    }
  Physics2D:CreateLinearProjectile(projectileTable) --
end