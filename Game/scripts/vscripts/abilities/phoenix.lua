LinkLuaModifier("modifier_phoenix_special_side_spirit_manager","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_special_side_burn","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_special_down_egg","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)

--"particles/phoenix/phoenix_fire_spirit_launch.vpcf"
phoenix_special_side = class({})
-- Throw a small projectile that deals damage and slows the targets attack speed

function phoenix_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Phoenix.FireSpirits.Launch")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_2, rate=1})
  return true
end

function phoenix_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Phoenix.FireSpirits.Launch")
  EndAnimation(caster)
end

-- Made based on ( https://github.com/Pizzalol/SpellLibrary/blob/master/game/scripts/vscripts/heroes/hero_phoenix/fire_spirits.lua) by Ractidous
function phoenix_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVector
  local ability = self
  StoreSpecialKeyValues(self)

  local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
  if modifier and modifier:GetStackCount() > 0 then
    modifier:DecrementStackCount()
    if modifier:GetStackCount() > 0 then
      self:EndCooldown()
    else
      self:EndCooldown()
      self:StartCooldown(modifier.nextThink-GameRules:GetGameTime())
    end
    local radius = self.radius
    local range = self.range
    local projectile_speed = self.projectile_speed
    
    --local duration = 4 --self:GetSpecialValueFor("duration")

    

    local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/phoenix/phoenix_fire_spirit_launch.vpcf",
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

        unit:AddNewModifier(caster,ability,"modifier_phoenix_special_side_burn",{duration = ability.duration})
        DealDamage(damageTable,projectile.location)
  
        caster:EmitSound("Hero_Phoenix.FireSpirits.ProjectileHit")

        local particle = ParticleManager:CreateParticle( "particles/generic_gameplay/dust_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
        ParticleManager:SetParticleControlEnt( particle, 0, projectile, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile:GetAbsOrigin(), true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(particle,false) 
          ParticleManager:ReleaseParticleIndex(particle)
        end)
        
        
      end,
  
    }
  Physics2D:CreateLinearProjectile(projectileTable)
  end
end

function phoenix_special_side:GetIntrinsicModifierName()
  return "modifier_phoenix_special_side_spirit_manager"
end

modifier_phoenix_special_side_spirit_manager = class({})

function modifier_phoenix_special_side_spirit_manager:IsPermanent()
  return true
end

function modifier_phoenix_special_side_spirit_manager:OnCreated()
  if IsServer() then
    local caster = self:GetCaster()
    self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("spirit_recharge_time"))
    self:SetStackCount(self:GetAbility():GetSpecialValueFor("number_of_spirits"))
    -- Create particle FX
    local particleName = "particles/units/heroes/hero_phoenix/phoenix_fire_spirits.vpcf"
    self.pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
    ParticleManager:SetParticleControl( self.pfx, 1, Vector( self:GetStackCount(), 0, 0 ) )
    for i=1, self:GetStackCount() do
      ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( 1, 0, 0 ) )
    end
  end
end

function modifier_phoenix_special_side_spirit_manager:OnStackCountChanged(nOldStackCount)
  if IsClient() then return end
  if not self.pfx then return end

  local caster = self:GetCaster()
  
  ParticleManager:SetParticleControl( self.pfx, 1, Vector( self:GetStackCount(), 0, 0 ) )
  for i=1, self:GetAbility():GetSpecialValueFor("number_of_spirits") do
    local radius = 0
    if i <= self:GetStackCount() then
      radius = 1
    end

    ParticleManager:SetParticleControl( self.pfx, 8+i, Vector( radius, 0, 0 ) )
  end
end
function modifier_phoenix_special_side_spirit_manager:OnIntervalThink()
  self.nextThink = GameRules:GetGameTime()+self:GetAbility():GetSpecialValueFor("spirit_recharge_time")
  if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("number_of_spirits") then self:SetStackCount(self:GetAbility():GetSpecialValueFor("number_of_spirits")) return end
  
  self:IncrementStackCount()
  self:GetAbility():EndCooldown() 
end

modifier_phoenix_special_side_burn = class({})

function modifier_phoenix_special_side_burn:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1)
    self:GetParent().attackspeedFactor = self:GetParent().attackspeedFactor + self:GetAbility():GetSpecialValueFor("attack_speed_slow")
  end
end

function modifier_phoenix_special_side_burn:OnDestroy()
  if IsServer() then
    self:GetParent().attackspeedFactor = self:GetParent().attackspeedFactor - self:GetAbility():GetSpecialValueFor("attack_speed_slow")
  end
end

function modifier_phoenix_special_side_burn:OnIntervalThink()
  local damageTable = {
    victim = self:GetParent(),
    attacker = self:GetCaster(),
    damage = self:GetAbility():GetSpecialValueFor("damage"),
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = self:GetAbility(),
  } 
  ApplyDamage(damageTable)
end

function modifier_phoenix_special_side_burn:GetEffectName()
  return "particles/units/heroes/hero_phoenix/phoenix_fire_spirit_burn.vpcf"
end

function modifier_phoenix_special_side_burn:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

phoenix_special_bottom = class({})
-- Move Phoenix 200 units up, throw a projectile down that explodes when it hits a platform, phoenix moves along with that platform

function phoenix_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Phoenix.SuperNova.Begin")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_5, rate=1})
  return true
end

function phoenix_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Phoenix.SuperNova.Begin")
  EndAnimation(caster)
end

function phoenix_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)
  caster:RemoveModifierByName("modifier_left")
  caster:RemoveModifierByName("modifier_right")
  caster:RemoveModifierByName("modifier_jump")

  --self.targets = {}
  caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,200))
  caster:AddNewModifier(caster,self,"modifier_phoenix_special_down_egg",{duration = 4})

  
  local projectileTable = 
    { 
      vDirection = Vec(0,-1),
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flAcceleration = 1.1,
      --flMaxDistance = ability.range,
      sEffectName = "particles/phoenix/phoenix_egg_drop.vpcf",
      PlatformBehavior = PROJECTILES_DESTROY,
      OnPlatformHit = function(projectile,unit)
        local particle_exp = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf",PATTACH_ABSORIGIN,self:GetCaster())
        ParticleManager:SetParticleControlEnt( particle_exp, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "follow_origin", self:GetCaster():GetAbsOrigin(), true )
        ParticleManager:SetParticleControlEnt( particle_exp, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
      
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(particle_exp,false) 
          ParticleManager:ReleaseParticleIndex(particle_exp)
        end)
        local radius = ability:GetSpecialValueFor("radius") * 2.5
        local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)

        caster:EmitSound("Hero_Phoenix.SuperNova.Explode")
        caster:RemoveModifierByName("modifier_phoenix_special_down_egg")
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
        
        ApplyDamage(damageTable)
        
        unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = ability:GetSpecialValueFor("stun_duration")})

      end,
      OnProjectileThink = function(projectile,location)
        if caster:HasModifier("modifier_left") or caster:HasModifier("modifier_right") or caster:HasModifier("modifier_jump") then
          -- Destroy this
          Physics2D:DestroyProjectile(projectile)
          caster:RemoveModifierByName("modifier_phoenix_special_down_egg")
          return
        end
        caster:SetAbsOrigin(location)
      end,
  
    }
  Physics2D:CreateLinearProjectile(projectileTable)
end


modifier_phoenix_special_down_egg = class({})

function modifier_phoenix_special_down_egg:DeclareFunctions()
  local funcs =
  {
    MODIFIER_PROPERTY_MODEL_CHANGE,
    MODIFIER_PROPERTY_MODEL_SCALE
  }

  return funcs
end

function modifier_phoenix_special_down_egg:GetModifierModelChange()
return "models/development/invisiblebox.vmdl"
  --return "models/phoenix_egg.vmdl.vmdl"
end

function modifier_phoenix_special_down_egg:GetModifierModelScale()
  return 1
end

function modifier_phoenix_special_down_egg:OnCreated()

  local index = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
  ParticleManager:SetParticleControlEnt(index, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(index, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
  self:AddParticle(index, false, false, -1, false, false)

end

    

function modifier_phoenix_special_down_egg:GetEffectName()
  return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_phoenix_special_down_egg:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

phoenix_special_top = class({})

function phoenix_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  self:GetCaster():EmitSound("Hero_Phoenix.IcarusDive.Cast")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end
function phoenix_special_top:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Phoenix.IcarusDive.Cast")
  EndAnimation(caster)
end

function phoenix_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)
  local dashLength  = 300

  caster:AddNewModifier(caster,ability,"modifier_smash_root",{})

  ability.targets = {}
  
  local casterOrigin = caster:GetAbsOrigin()
  local ellipseCenter = casterOrigin + Vector(0,0,1) * ( dashLength )
  local upPoint = casterOrigin + Vector(0,0,1) * ( dashLength * 2 ) 

  if not self.isFlying then
    if self:GetCaster().jumps > 2 then return false end
    caster.jumps = 3  
    self:EndCooldown()
    self.isFlying = true

    --self:GetSpecialValueFor("dash_length")
    local dashDuration  = 2

    local dir = 1
    if ability.mouseVector.x <0 then
      dir = -1
    end

    local ellipseCenter = casterOrigin + Vector(0,0,1) * ( dashLength )
    local startTime = GameRules:GetGameTime()
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)


    caster:SetContextThink( DoUniqueString("updateIcarusDive"), function ( )
      local elapsedTime = GameRules:GetGameTime() - startTime
      local progress = elapsedTime / dashDuration
      

      if not ability.isFlying or progress > 0.85 or caster:HasModifier("modifier_phoenix_special_down_egg") then 
        ability:StopDiving()
        ability.isFlying = false
        return 
      end
      progress = progress * 360
      progress = progress - 180
      progress = progress * caster:GetForwardVector().x * -1

      local radius = ability:GetSpecialValueFor("radius")
      local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
      for k,v in pairs(units) do
        local damageTable = {
          victim = v,
          attacker = self:GetCaster(),
          damage = self:GetSpecialValueFor("damage")/20, 
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self,
        } 
        ApplyDamage(damageTable)

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_icarus_dive_burn_debuff.vpcf",PATTACH_ABSORIGIN_FOLLOW,v)
        Timers:CreateTimer(1,function()
          ParticleManager:DestroyParticle(particle,true)
          ParticleManager:ReleaseParticleIndex(particle)
        end)
      end

      pos = (RotatePosition(ellipseCenter, QAngle(progress,0,0), upPoint))
      caster:SetAbsOrigin( pos )
      return FrameTime()
    end, 0 )
  else
    ability:StopDiving()
    ability.isFlying = false
  end
end

function phoenix_special_top:StopDiving()
  local caster = self:GetCaster()
  local modifier = caster:FindModifierByNameAndCaster("modifier_smash_root",caster)
  if modifier then
    modifier:Destroy()
  end
  caster:StopSound("Hero_Phoenix.IcarusDive.Cast")
  ParticleManager:DestroyParticle(self.particle,true)
  ParticleManager:ReleaseParticleIndex(self.particle) 
  self.isFlying = false
  self:StartCooldown(self:GetCooldown(1))
  CustomGameEventManager:Send_ServerToPlayer(self:GetCaster():GetPlayerOwner(),"show_cooldown",{sAbilityName = self:GetAbilityName(),ability = self:entindex(), nCooldown = self:GetCooldown(1)})
end