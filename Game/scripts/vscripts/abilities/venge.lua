vengefulspirit_special_top = class({})

function vengefulspirit_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_top:OnSpellStart()
  local caster = self:GetCaster()

  if caster.jumps > 2 then return end
  caster.jumps = 3 
  caster:AddNewModifier(caster,self,"modifier_smash_stun",{})


    local projectile = {
      --EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj_core.vpcf",
      EffectName = "particles/venge/venge_swap.vpcf",
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      --EffectName = "",
      vSpawnOrigin = caster:GetAbsOrigin(),
      --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,0)},
      fDistance = self:GetSpecialValueFor("range"),
      fStartRadius = 200,--self:GetSpecialValueFor("radius"),
      fEndRadius = 200,--self:GetSpecialValueFor("radius"),
      Source = caster,
      fExpireTime = 0.5,--self:GetSpecialValueFor("range")/self:GetSpecialValueFor("projectile_speed"),
      vVelocity = self.mouseVector * self:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
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
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = 300,--self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = IsInToolsMode(),--             draw = {alpha=1, color=Vector(200,0,0)},
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
          damage = caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage") + RandomInt(0,caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = caster:FindAbilityByName("vengefulspirit_special_top"),
        }
        ApplyDamage(damageTable)

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
      OnFinish = function(self,unit)
        caster:SetAbsOrigin(self:GetPosition())
        caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
        local particle_a = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_a, 0, caster:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle_a, 1, unit)

        local particle_b = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_b, 0, unit)
        ParticleManager:SetParticleControl(particle_b, 1, caster:GetAbsOrigin())
        

        Timers:CreateTimer(caster:FindAbilityByName("vengefulspirit_special_top"):GetSpecialValueFor("self_stun_duration"),function()
          ParticleManager:DestroyParticle(particle_a,false)
          ParticleManager:ReleaseParticleIndex(particle_a)
          ParticleManager:DestroyParticle(particle_b,false)
          ParticleManager:ReleaseParticleIndex(particle_b)
          caster:RemoveModifierByName("modifier_smash_stun")
        end)
      end,
    }
    Projectiles:CreateProjectile(projectile)

end

vengefulspirit_special_side = class({})

function vengefulspirit_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self



    local projectile = {
      --EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj_core.vpcf",
      EffectName = "venge/venge_side.vpcf",
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      --EffectName = "",
      --vSpawnOrigin = caster:GetAbsOrigin(),
      vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,0)},
      fDistance = self:GetSpecialValueFor("range"),
      fStartRadius = self:GetSpecialValueFor("radius"),
      fEndRadius = self:GetSpecialValueFor("radius"),
      Source = caster,
      fExpireTime = self:GetSpecialValueFor("range")/self:GetSpecialValueFor("projectile_speed"),
      vVelocity = self.mouseVector * self:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
      UnitBehavior = PROJECTILES_DESTROY ,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_BOUNCE,
      fGroundOffset = 0,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = 300,--self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = IsInToolsMode(),--             draw = {alpha=1, color=Vector(200,0,0)},
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
        caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
        unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = ability:GetSpecialValueFor("stun_duration")})
      end,
    }
    Projectiles:CreateProjectile(projectile)
    caster:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
end



vengefulspirit_special_bottom = class({})

function vengefulspirit_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function vengefulspirit_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  caster:EmitSound("Hero_VengefulSpirit.WaveOfTerror")

    local projectile = {
      --EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj_core.vpcf",
      EffectName = "particles/venge/vengeful_wave_of_terror.vpcf",
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      --EffectName = "",
      vSpawnOrigin = caster:GetAbsOrigin(),
      --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(-1,0,-1) * 100},
      fDistance = self:GetSpecialValueFor("range"),
      fStartRadius = self:GetSpecialValueFor("radius"),
      fEndRadius = self:GetSpecialValueFor("radius"),
      Source = caster,
      fExpireTime = self:GetSpecialValueFor("range")/self:GetSpecialValueFor("projectile_speed"),
      vVelocity = Vector(1,0,0) * ability:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
      UnitBehavior = PROJECTILES_NOTHING ,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_NOTHING,
      fGroundOffset = 0,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = 300,--self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},

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

    local projectile_2 = {
      --EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj_core.vpcf",
      EffectName = "particles/venge/vengeful_wave_of_terror.vpcf",
      --EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      --EffectName = "",
      vSpawnOrigin = caster:GetAbsOrigin(),
      --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(1,0,-1) * 100},
      fDistance = self:GetSpecialValueFor("range"),
      fStartRadius = self:GetSpecialValueFor("radius"),
      fEndRadius = self:GetSpecialValueFor("radius"),
      Source = caster,
      fExpireTime = self:GetSpecialValueFor("range")/self:GetSpecialValueFor("projectile_speed"),
      vVelocity = Vector(-1,0,0) * self:GetSpecialValueFor("projectile_speed"), -- RandomVector(1000),
      UnitBehavior = PROJECTILES_NOTHING ,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_NOTHING,
      fGroundOffset = 0,
      nChangeMax = 1,
      bRecreateOnChange = true,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = 300,--self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},

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
    local proj_2 = Projectiles:CreateProjectile(projectile_2)
    
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



