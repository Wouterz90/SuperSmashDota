LinkLuaModifier("modifier_nevermore_special_side_1","abilities/shadowfiend.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_special_side_2","abilities/shadowfiend.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nevermore_special_side_3","abilities/shadowfiend.lua",LUA_MODIFIER_MOTION_NONE)
modifier_nevermore_special_side_1 = class({})
modifier_nevermore_special_side_2 = class({})
modifier_nevermore_special_side_3 = class({})

nevermore_special_side = class({})
function nevermore_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  local ability = self
  
  local distance = math.abs(ability.mouseVectorDistance.x)
  local raze = 1
  if ability.mouseVectorDistance.x < 0 then
    raze = -raze
  end

  if distance > 0.45 and distance < 0.63 then
    raze = raze*1
  elseif distance > 0.63 and distance < 0.81 then
    raze = raze*2
  else
    raze = raze*3
  end

  if caster:HasModifier("modifier_nevermore_special_side_"..math.abs(raze)) then 
    self:StartCooldown(self:GetCooldown(1)) 
    CustomGameEventManager:Send_ServerToPlayer(ability:GetCaster():GetPlayerOwner(),"show_cooldown",{sAbilityName = ability:GetAbilityName(),ability = ability:entindex(), nCooldown = ability:GetCooldown(1)})
    caster:RemoveModifierByName("modifier_nevermore_special_side_1")
    caster:RemoveModifierByName("modifier_nevermore_special_side_2")
    caster:RemoveModifierByName("modifier_nevermore_special_side_3")
    return false
  end

  --caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_RAZE_2 , rate=self:GetCastPoint()/0.55 })

  self.raze = raze
  return true
end

function nevermore_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  --caster:StopSound("Hero_Phoenix.FireSpirits.Launch")
  EndAnimation(caster)
end

  
function nevermore_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local ability = self
  local radius = self:GetSpecialValueFor("radius")
  local raze_range = self:GetSpecialValueFor("raze_range") 
  local raze_height = self:GetSpecialValueFor("raze_height") 
  self:EndCooldown()
  
  local raze = self.raze


  

  caster:AddNewModifier(caster,ability,"modifier_nevermore_special_side_"..math.abs(raze),{duration = ability:GetCooldown(1)})
  if caster:HasModifier("modifier_nevermore_special_side_1") and caster:HasModifier("modifier_nevermore_special_side_2") and caster:HasModifier("modifier_nevermore_special_side_3") then
    self:EndCooldown()
    caster:RemoveModifierByName("modifier_nevermore_special_side_1")
    caster:RemoveModifierByName("modifier_nevermore_special_side_2")
    caster:RemoveModifierByName("modifier_nevermore_special_side_3")
    caster:EmitSound("General.LevelUp.Bonus")
    local particle = ParticleManager:CreateParticle("particles/econ/events/ti6/hero_levelup_ti6.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
  end
  
  local point = caster:GetAbsOrigin() + Vector(raze_range*raze,0,0)

  caster:EmitSound("Hero_Nevermore.Shadowraze")
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(particle, 0, point)
  ParticleManager:SetParticleControl(particle, 1, Vector(radius, 1, 1)) 

  local units = FindUnitsInRadius(caster:GetTeam(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,point,raze_height)

  for k,v in pairs(units) do
    local damageTable = {
      victim = v,
      attacker = self:GetCaster(),
      damage = self:GetSpecialValueFor("damage")+RandomInt(0,self:GetSpecialValueFor("damage_offset")),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    local oldLoc = caster:GetAbsOrigin()
    caster:SetAbsOrigin(point) 
    ApplyDamage(damageTable)
    caster:SetAbsOrigin(oldLoc)
  end
end

nevermore_special_bottom = class({})
-- Throw a small projectile that deals damage and slows the targets attack speed

function nevermore_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:AddNewModifier(caster,self,"modifier_smash_stun",{duration=self:GetCastPoint()}).dontColor = true
  caster:EmitSound("Hero_Nevermore.RequiemOfSoulsCast")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_6 , rate=1.67/self:GetCastPoint()})
  --FreezeAnimation(caster,self:GetCastPoint())
  return true
end

function nevermore_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Nevermore.RequiemOfSoulsCast")
  EndAnimation(caster)
end

-- Made based on ( https://github.com/Pizzalol/SpellLibrary/blob/master/game/scripts/vscripts/heroes/hero_phoenix/fire_spirits.lua) by Ractidous
function nevermore_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVector
  local ability = self

  local radius = self:GetSpecialValueFor("radius")
  local range = self:GetSpecialValueFor("range")
  local projectile_speed = self:GetSpecialValueFor("projectile_speed")
  caster:StopSound("Hero_Nevermore.RequiemOfSoulsCast")
  caster:EmitSound("Hero_Nevermore.RequiemOfSouls")
  for i=1,18 do
    local direction = RotatePosition(Vector(0,0,0), QAngle(i*20,0,0), caster:GetAbsOrigin()):Normalized()

    local projectile = {
      --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
      EffectName = "particles/shadowfiend/requiem_projectile.vpcf",
      --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
      --EeffectName = "",
      --vSpawnOrigin = caster:GetAbsOrigin(),
      vSpawnOrigin = caster:GetAbsOrigin()+direction*(000 +(200*math.fmod(i, 2))),
      fDistance = range,
      fStartRadius = radius,
      fEndRadius = radius,
      Source = caster,
      fExpireTime = 4,
      vVelocity = direction * projectile_speed, -- RandomVector(1000),
      UnitBehavior = PROJECTILES_NOTHING,
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
      iVisionRadius = radius,
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetUnitName() ~= "npc_dota_hero_announcer" and unit:GetUnitName() ~= "npc_dota_hero_announcer_killing_spree" end,
      OnUnitHit = function(self, unit)
        local damageTable = {
          victim = unit,
          attacker = ability:GetCaster(),
          damage = ability:GetSpecialValueFor("damage")+RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        } 
        local oldLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(unit:GetAbsOrigin()-direction*5) 
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(oldLoc)
      end,
    }
    Projectiles:CreateProjectile(projectile)
  end
end

nevermore_special_top = class({})

function nevermore_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 2 then return false end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_6, rate=1})
  return true
end

function nevermore_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  caster.jumps = 3
  local range = self:GetSpecialValueFor("blink_range")
  local particle_one = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
  caster:SetAbsOrigin(caster:GetAbsOrigin()+self.mouseVector * range)
  local particle_two = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)

  -- Release particles
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle_one,false)
    ParticleManager:ReleaseParticleIndex(particle_one)
    ParticleManager:DestroyParticle(particle_two,false)
    ParticleManager:ReleaseParticleIndex(particle_two)
  end)
end
