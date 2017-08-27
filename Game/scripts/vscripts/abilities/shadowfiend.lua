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

function nevermore_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVector
  local ability = self
  StoreSpecialKeyValues(self)


  local radius = self.radius
  local range = self.range
  local projectile_speed = self.projectile_speed
  caster:StopSound("Hero_Nevermore.RequiemOfSoulsCast")
  caster:EmitSound("Hero_Nevermore.RequiemOfSouls")

  local projectileTable = 
    { 
      --vDirection = direction,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/shadowfiend/nevermore_base_attack.vpcf",
      PlatformBehavior = PROJECTILES_NOTHING,
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
          ability = ability,
        }

        
        DealDamage(damageTable,projectile.location)
  
        caster:EmitSound("Hero_Phoenix.FireSpirits.ProjectileHit")

        --local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/dust_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
        --ParticleManager:SetParticleControlEnt( particle, 0, projectile, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile:GetAbsOrigin(), true )
        Timers:CreateTimer(0.5,function()
          --ParticleManager:DestroyParticle(particle,false) 
          --ParticleManager:ReleaseParticleIndex(particle)
        end)
        
        
      end,
  
    }
  



  for i=1,12 do
    local direction = RotatePosition(Vector(0,0,0), QAngle(i*30,0,0), caster:GetAbsOrigin()):Normalized()
    projectileTable.vDirection = direction
    --projectileTable.vSpawnOrigin = caster:GetAbsOrigin() + direction * 1
    Physics2D:CreateLinearProjectile(projectileTable)
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
