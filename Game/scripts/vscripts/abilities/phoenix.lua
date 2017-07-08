LinkLuaModifier("modifier_phoenix_special_side_spirit_manager","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_special_side_burn","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_special_down_egg","abilities/phoenix.lua",LUA_MODIFIER_MOTION_NONE)

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

  local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
  if modifier and modifier:GetStackCount() > 0 then
    modifier:DecrementStackCount()
    if modifier:GetStackCount() > 0 then
      self:EndCooldown()
    else
      self:EndCooldown()
      self:StartCooldown(modifier.nextThink-GameRules:GetGameTime())
    end
    local radius = self:GetSpecialValueFor("radius")
    local range = self:GetSpecialValueFor("range")
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    
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

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(self, unit)
        caster:EmitSound("Hero_Phoenix.FireSpirits.ProjectileHit")  
        unit:AddNewModifier(caster,ability,"modifier_phoenix_special_side_burn",{duration = ability:GetSpecialValueFor("duration")})
      end,
    }
    Projectiles:CreateProjectile(projectile)
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

  caster:RemoveModifierByName("modifier_left")
  caster:RemoveModifierByName("modifier_right")
  caster:RemoveModifierByName("modifier_jump")

  self.targets = {}
  caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,80))
  caster:AddNewModifier(caster,self,"modifier_phoenix_special_down_egg",{duration = 4})
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
return "models/props_winter/egg.vmdl"
  --return "models/phoenix_egg.vmdl.vmdl"
end

function modifier_phoenix_special_down_egg:GetModifierModelScale()
  return 1
end

function modifier_phoenix_special_down_egg:OnCreated()
  if  IsServer() then print(self:GetParent().GetLocalPlayer) end
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self:GetCaster():SetModelScale(3  )
    self:StartIntervalThink(1/30)
    --self:GetCaster().zDelta = self:GetCaster().zDelta -90

    self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_smash_stun",{}).dontColor = true
    --mod.dontColor = true
    self:GetCaster():SetRenderColor(RandomInt(255,200),RandomInt(100,150),RandomInt(0,0))

    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControlEnt(index, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(index, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
    self:AddParticle(index, false, false, -1, false, false)
  end
end

function modifier_phoenix_special_down_egg:OnIntervalThink()
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  local position = caster:GetAbsOrigin()

  local radius = ability:GetSpecialValueFor("radius")
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not ability.targets[v] then
      ability.targets[v] = true
      local damageTable = {
        victim = v,
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      } 
      ApplyDamage(damageTable)
    end
  end

  local nextPosition = {}
  nextPosition[1] = caster:GetAbsOrigin() + Vector(0,0,-Laws.flDropSpeed * 2 )
  nextPosition[2] = caster:GetAbsOrigin() + Vector(0,0,-Laws.flDropSpeed * 2.5 )
  nextPosition[3] = caster:GetAbsOrigin() + Vector(0,0,-Laws.flDropSpeed * 3 )
  nextPosition[4] = caster:GetAbsOrigin() + Vector(0,0,-Laws.flDropSpeed * 3.5 )
  nextPosition[5] = caster:GetAbsOrigin() + Vector(0,0,-Laws.flDropSpeed * 4 )

  local bOnPlatform = false
  for i=1,5 do
    if GetGroundPosition(nextPosition[i],caster).z ~= 128 then
      bOnPlatform = true
      break
    end
  end



  if not bOnPlatform then
    caster:SetAbsOrigin(nextPosition[1])
  else
    self:StartIntervalThink(-1)
    self:Destroy()
  end
end

function modifier_phoenix_special_down_egg:OnDestroy()
  if IsServer() then


    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local position = caster:GetAbsOrigin()


    -- Only explode if the egg existed for over 0.35 second
    if GameRules:GetGameTime() -  self:GetCreationTime() > self.min_time_to_explode -0.05 then
      
      local radius = ability:GetSpecialValueFor("radius") * 1.5
      local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
      
      local particle_exp = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf",PATTACH_ABSORIGIN,self:GetCaster())
      ParticleManager:SetParticleControlEnt( particle_exp, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "follow_origin", self:GetCaster():GetAbsOrigin(), true )
      ParticleManager:SetParticleControlEnt( particle_exp, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
      
      Timers:CreateTimer(0.5,function()
        ParticleManager:DestroyParticle(particle_exp,false) 
        ParticleManager:ReleaseParticleIndex(particle_exp)
      end)

      caster:EmitSound("Hero_Phoenix.SuperNova.Explode")

      for k,v in pairs(units) do
        local damageTable = {
          victim = v,
          attacker = self:GetCaster(),
          damage = self:GetAbility():GetSpecialValueFor("damage"), 
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self:GetAbility(),
        } 
        ApplyDamage(damageTable)

        v:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = ability:GetSpecialValueFor("stun_duration")})
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf",PATTACH_POINT,v)
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(particle,true)
          ParticleManager:ReleaseParticleIndex(particle)
        end)
      end
    end

    local modifier = caster:FindModifierByNameAndCaster("modifier_smash_stun",caster)
    if modifier then
      modifier:Destroy()
    end
    caster:SetRenderColor(255,255,255)
    --self:GetCaster().zDelta = self:GetCaster().zDelta +90
    self:GetCaster():SetModelScale(1)
    
    --self:GetCaster().zDelta = self:GetCaster().zDelta +900
  end
  

  
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
  
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function phoenix_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  caster:AddNewModifier(caster,ability,"modifier_smash_root",{})

  ability.targets = {}
  
  local casterOrigin = caster:GetAbsOrigin()

  if not self.isFlying then
    if self:GetCaster().jumps > 2 then return false end
    caster.jumps = 3  
    self:EndCooldown()
    self.isFlying = true

    local dashLength  = 600--self:GetSpecialValueFor("dash_length")
    local dashDuration  = 2

    local dir = 1
    if ability.mouseVector.x <0 then
      dir = -1
    end

    local ellipseCenter = casterOrigin + Vector(0.5*dir,0,1) * ( dashLength )
    local startTime = GameRules:GetGameTime()
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)


    caster:SetContextThink( DoUniqueString("updateIcarusDive"), function ( )
      local elapsedTime = GameRules:GetGameTime() - startTime
      local progress = elapsedTime / dashDuration


      if not ability.isFlying or progress > 0.85 or caster:HasModifier("modifier_phoenix_special_down_egg") then 
        StopDiving(ability)
        ability.isFlying = false
        return 
      end

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

      local angle = (math.pi)*(progress)
      local pos
      if progress < 0.5 then
        pos = casterOrigin + dashLength * Vector(math.cos(angle)*dir, 0, math.sin(angle))
      else
        pos = casterOrigin + dashLength * Vector(math.cos(angle)*dir*0.5, 0, math.sin(angle))
      end
      caster:SetAbsOrigin( pos )
      return 0.03
    end, 0 )
  else
    StopDiving(ability)
    ability.isFlying = false
  end
end

function StopDiving(ability)
  local caster = ability:GetCaster()
  local modifier = caster:FindModifierByNameAndCaster("modifier_smash_root",caster)
  if modifier then
    modifier:Destroy()
  end
  ParticleManager:DestroyParticle(ability.particle,true)
  ParticleManager:ReleaseParticleIndex(ability.particle) 
  ability.isFlying = false
  ability:StartCooldown(ability:GetCooldown(1))
  CustomGameEventManager:Send_ServerToPlayer(ability:GetCaster():GetPlayerOwner(),"show_cooldown",{sAbilityName = ability:GetAbilityName(),ability = ability:entindex(), nCooldown = ability:GetCooldown(1)})
end