phoenix_special_mid = class({})
-- Throw a small projectile that deals damage and slows the targets attack speed

function phoenix_special_mid:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_2, rate=1})
  return true
end

function phoenix_special_mid:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Phoenix.FireSpirits.Launch")
  EndAnimation(caster)
end

function phoenix_special_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = 200--self:GetSpecialValueFor("radius")
  local range = 600--self:GetSpecialValueFor("range")
  local projectile_speed = 600--self:GetSpecialValueFor("projectile_speed")
  local direction = self.mouseVector
  local ability = self
  local duration = 4 --self:GetSpecialValueFor("duration")

  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    EffectName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_launch.vpcf",
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

    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
    OnUnitHit = function(self, unit)
      caster:EmitSound("Hero_Puck.ProjectileImpact")
      
    end,
  }
  Projectiles:CreateProjectile(projectile)
end