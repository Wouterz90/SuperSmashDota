-- Lift Rubick straight up, when done fire a projectile forward that destroys itself when it hits a platform or a unit
rubick_special_top = class({})
function rubick_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  self:GetCaster():EmitSound("Hero_Rubick.Telekinesis.Cast") 
  return true
end

function rubick_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Rubick.Telekinesis.Cast")
  EndAnimation(caster)
end

function rubick_special_top:OnSpellStart()
  local caster = self:GetCaster()

  if caster.jumps > 2 then return end
  StoreSpecialKeyValues(self)
  local ability = self
  caster.jumps = 3 

  caster:AddNewModifier(caster,ability,"rubick_lift",{duration = ability.lift_duration})

  caster:EmitSound("Hero_Rubick.Telekinesis.Target")
end

LinkLuaModifier("rubick_lift","abilities/rubick/rubick_special_top.lua",LUA_MODIFIER_MOTION_NONE)
rubick_lift = class({})

function rubick_lift:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,1)*self.lift_speed)
  end
end

function rubick_lift:OnDestroy()
  if IsServer() then
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    Physics2D:SetStaticVelocity(self:GetParent(),"rubick_lift",Vec(0))
    Physics2D:ClearPhysicsVelocity(self:GetParent())
    local vector = ability.mouseVector
    vector.z = -0.5
    vector = vector:Normalized()
    
    local projectileTable = 
    { 
      vSpawnOrigin = self:GetCaster():GetAbsOrigin() + Vec(0,50),
      vDirection = vector,
      hCaster = self:GetCaster(),
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      --flMaxDistance = ability.range,
      sEffectName = "particles/rubick/up_projectile.vpcf",
      PlatformBehavior = PROJECTILES_DESTROY,
      OnPlatformHit = function(projectile,unit)
        caster:EmitSound("Hero_Rubick.Telekinesis.Target.Land")
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
        caster:EmitSound("Hero_Rubick.Telekinesis.Target.Land")
        
        unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = ability.stun_duration})

      end,
  
    }
  Physics2D:CreateLinearProjectile(projectileTable)
  end
end

