LinkLuaModifier("modifier_storm_spirit_special_top_counter","abilities/storm.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_storm_ball_lightning","abilities/storm.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_storm_remnant","abilities/storm.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_storm_side_grab","abilities/storm.lua",LUA_MODIFIER_MOTION_NONE)

storm_spirit_special_top = class({})

function storm_spirit_special_top:GetIntrinsicModifierName()
  return "modifier_storm_spirit_special_top_counter"
end

function storm_spirit_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
  -- Instead of jump count watch for charges
  if modifier:GetStackCount() <= 20  then return end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1, activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  return true
end

function storm_spirit_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function storm_spirit_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local modifier = caster:FindModifierByName(self:GetIntrinsicModifierName())
  self:EndCooldown()
  --local vector = self.mouseVector
 modifier:SetStackCount(modifier:GetStackCount()-15 )
 
  -- Multi ball lightning should be allowed
  caster.jumps = 2
  caster:EmitSound("Hero_StormSpirit.BallLightning")
  local modifier = caster:AddNewModifier(caster,self,"modifier_storm_ball_lightning",{})
end

modifier_storm_ball_lightning = class({})
function modifier_storm_ball_lightning:GetEffectName()
  return "particles/storm/stormspirit_ball_lightning.vpcf"
end

function modifier_storm_ball_lightning:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end



function modifier_storm_ball_lightning:OnCreated()
  if IsServer() then
    self:GetCaster():EmitSound("Hero_StormSpirit.BallLightning.Loop")
    local caster = self:GetCaster()
    self:StartIntervalThink(1/30)
    self.targets = {}

    --[[local particle = ParticleManager:CreateParticle("particles/storm/stormspirit_ball_lightning.vpcf",PATTACH_ABSORIGIN_FOLLOW,caster)
    ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    --ParticleManager:SetParticleControl(particle,2,Vector(0,0,300))
    self:AddParticle(particle,false,false,-1,false,false)]]
  end
end

function modifier_storm_ball_lightning:OnIntervalThink()
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  local modifier = caster:FindModifierByName(ability:GetIntrinsicModifierName())
  local direction = ability.mouseVector

  if caster:GetUnitName() ~= "npc_dota_hero_storm_spirit" then
    self:Destroy()
    return
  end

  local radius = ability:GetSpecialValueFor("radius")
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),radius)
  for k,v in pairs(units) do
    if not self.targets[v] then
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
      } 
      ApplyDamage(damageTable)
      self.targets[v] = true
      --caster:EmitSound("Hero_Tusk.Snowball.ProjectileHit")
    end
  end

  modifier:DecrementStackCount()
  modifier:DecrementStackCount()
  modifier:DecrementStackCount()
  if RollPercentage(33) then
    modifier:DecrementStackCount()
  end
  
  Physics2D:SetStaticVelocity(self:GetParent(),"storm_zip",direction*35)
  --caster:SetAbsOrigin(caster:GetAbsOrigin()+direction*35)
  --if caster:GetAbsOrigin().z +100 > Laws.flMaxHeight then
  --  caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0,0,-35))
  --end

  if modifier:GetStackCount() <= 0 then
    caster.isChargingAbility = nil
    self:Destroy()
  end
  
end

function modifier_storm_ball_lightning:OnDestroy()
  if IsServer() then
    self:GetCaster():StopSound("Hero_StormSpirit.BallLightning.Loop")
    self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(1))
    CustomGameEventManager:Send_ServerToPlayer(self:GetCaster():GetPlayerOwner(),"show_cooldown",{sAbilityName = self:GetAbility():GetAbilityName(),ability = self:GetAbility():entindex(), nCooldown = self:GetAbility():GetCooldown(1)})
    Physics2D:SetStaticVelocity(self:GetParent(),"storm_zip",Vector(0))
  end
end

modifier_storm_spirit_special_top_counter = class({})

function modifier_storm_spirit_special_top_counter:IsPermanent()
  return true
end

function modifier_storm_spirit_special_top_counter:OnCreated()
  if IsServer() then
    self.pID = self:GetCaster():GetPlayerOwnerID()
    self:SetStackCount(100)-- self:GetAbility():GetSpecialValueFor("max_charges") * 10
    --self:GetAbility().particle = ParticleManager:CreateParticle("particles/custom/storm_counter.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    self:StartIntervalThink(1/20)
    --self.chargeCount = 0
  end
end

function modifier_storm_spirit_special_top_counter:OnIntervalThink()
  if not self:GetCaster() or PlayerResource:GetSelectedHeroEntity(self.pID):GetUnitName() ~= "npc_dota_hero_storm_spirit" then
    self:Destroy()
    return
  end
  --[[for i=1,8 do
    if self:GetStackCount()/10 >= i then
      ParticleManager:SetParticleControl(self:GetAbility().particle, i, Vector(1,0,0))
    else
      ParticleManager:SetParticleControl(self:GetAbility().particle, i, Vector(0,0,0))
    end
    
    self.chargeCount = self.chargeCount + 1

    
  end]]
  --if self.chargeCount >= 10 then
      --self.chargeCount = 0
    self:IncrementStackCount()
    --end
   

    if self:GetStackCount() > 100 then
      self:SetStackCount(100)
    end
  PlayerTables:SetTableValue(tostring(self:GetCaster():GetPlayerOwnerID()),"charges",self:GetStackCount())
end

storm_spirit_special_top_release = class({})

function storm_spirit_special_top_release:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_storm_ball_lightning")
end

storm_spirit_special_bottom = class({})

function storm_spirit_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1})
  self:GetCaster():EmitSound("Hero_StormSpirit.StaticRemnantPlant")
  return true
end

function storm_spirit_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_StormSpirit.StaticRemnantPlant")
  EndAnimation(caster)
end


function storm_spirit_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local remnant = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),true,caster,caster:GetOwner(),caster:GetTeamNumber())
  remnant:SetAbsOrigin(caster:GetAbsOrigin())
  Physics2D:CreateObject("AABB",remnant:GetAbsOrigin(),true,false,remnant,100,150,"Unit")
  remnant.IsSmashUnit = true
  remnant:AddNewModifier(caster,self,"modifier_basic",{})
  remnant:AddNewModifier(caster,self,"modifier_storm_remnant",{duration = self:GetSpecialValueFor("remnant_duration")})
end

modifier_storm_remnant = class({})
function modifier_storm_remnant:GetEffectName()
  return "particles/storm/stormspirit_static_remnant.vpcf" 
end

function modifier_storm_remnant:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_storm_remnant:DeclareFunctions()
  return {MODIFIER_PROPERTY_MODEL_CHANGE}
end

function modifier_storm_remnant:GetModifierModelChange()
  if IsServer() then
    return self:GetCaster():GetModelName()
  end
end

function modifier_storm_remnant:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/30)
  end
end

function modifier_storm_remnant:OnIntervalThink()
  -- When a unit is in the radius look for for all units in 1.5x the radius and damage them
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  local unit = self:GetParent()
  local radius = ability:GetSpecialValueFor("radius")
  local units = FindUnitsInRadius(caster:GetTeam(), unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,unit:GetAbsOrigin(),radius)
  if #units > 0 then
    self:Destroy()
  end
end


function modifier_storm_remnant:OnDestroy()
  if IsServer() then
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local unit = self:GetParent()
    local radius = ability:GetSpecialValueFor("radius") * 1.5
    local units = FindUnitsInRadius(caster:GetTeam(), unit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,unit:GetAbsOrigin(),radius)
    for k,v in pairs(units) do
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability
      } 
      local oldloc = caster:GetAbsOrigin()
      caster:SetAbsOrigin(unit:GetAbsOrigin())
      ApplyDamage(damageTable)
      caster:SetAbsOrigin(oldloc)
    end
    self:GetParent():EmitSound("Hero_StormSpirit.StaticRemnantExplode")
    Timers:CreateTimer(0.5,function()
      if not unit:IsNull() then
        UTIL_Remove(unit)
      end
    end)
  end
end

storm_spirit_special_side = class({})

function storm_spirit_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(),{duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, rate=self:GetCastPoint()/0.3})
  self:GetCaster():EmitSound("Hero_StormSpirit.Attack")
  return true
end

function storm_spirit_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_StormSpirit.Attack")
  EndAnimation(caster)
end
function storm_spirit_special_side:OnSpellStart()

  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)
  --caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")
  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      vSpawnOrigin = caster:GetAbsOrigin(),
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "particles/units/heroes/hero_stormspirit/stormspirit_base_attack.vpcf",
      PlatformBehavior = PROJECTILES_DESTROY,
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
        ApplyDamage(damageTable)
        
        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{ duration = ability:GetSpecialValueFor("grab_duration")})
        unit:AddNewModifier(caster,ability,"modifier_storm_side_grab",{ duration = ability:GetSpecialValueFor("grab_duration")})
  
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_base_attack_explosion.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", projectile.location, true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
      end,
    }
  Physics2D:CreateLinearProjectile(projectileTable) 
end

modifier_storm_side_grab = class({})

function modifier_storm_side_grab:OnCreated()
  if IsServer() then
    self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetCaster(),PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
    self:StartIntervalThink(1/30)

    
    self:GetCaster():EmitSound("Hero_StormSpirit.ElectricVortex")
  end
end

function modifier_storm_side_grab:OnIntervalThink()
  local ability = self:GetAbility()
  local caster = self:GetCaster()
  local unit = self:GetParent()

  local direction = (caster:GetAbsOrigin()-unit:GetAbsOrigin()):Normalized()
  local pull_speed = ability:GetSpecialValueFor("pull_speed")
  --self:GetParent():SetStaticVelocity("storm_pull",direction*pull_speed)
  Physics2D:SetStaticVelocity(self:GetParent(),"storm_pull",direction*pull_speed*FrameTime())
  --unit:SetAbsOrigin(unit:GetAbsOrigin()+direction*pull_speed)
end


function modifier_storm_side_grab:OnDestroy()
  if IsServer() then
    self:GetCaster():StopSound("Hero_StormSpirit.ElectricVortex")
    ParticleManager:DestroyParticle(self.particle,true)
    ParticleManager:ReleaseParticleIndex(self.particle)
    Physics2D:SetStaticVelocity(self:GetParent(),"storm_pull",Vec(0))
  end
end