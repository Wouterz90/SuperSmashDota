LinkLuaModifier("modifier_tusk_walrus_kick","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_sigil_dummy","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_sigil_aura","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_sigil_slow","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_snowball","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_snowball_dummy","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)

tusk_special_side = class({})

function tusk_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  -- Start the animations for walrus kick
  caster:EmitSound("Hero_Tusk.WalrusPunch.Cast")
  caster:AddNewModifier(caster,self,"modifier_tusk_walrus_kick",{duration = self:GetCastPoint()*1})
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_5, rate=0.5})
  return true
end

function tusk_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Tusk.WalrusPunch.Cast")
  EndAnimation(caster)
  caster:RemoveModifierByName("modifier_tusk_walrus_kick")
end

function tusk_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local height = self:GetSpecialValueFor("height")
  -- Do show the walrus kick text
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", PATTACH_ABSORIGIN, caster) 
  ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()+Vector(0,0,175))
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)
  -- Hit units
  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),height)
  for k,v in pairs(units) do
    local damage = self:GetSpecialValueFor("damage") +  RandomInt(0,self:GetSpecialValueFor("damage_offset"))
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
    caster:EmitSound("Hero_Tusk.WalrusPunch.Target")
    break
  end
  self:SetAbsOrigin(self:GetAbsOrigin()+Vector(0,0,100))
end

modifier_tusk_walrus_kick = class({})

function modifier_tusk_walrus_kick:GetEffectName()
  return "particles/units/unit_greevil/greevil_transformation_glow.vpcf"
end
function modifier_tusk_walrus_kick:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end

--[[ Basially a copy of side
tusk_special_mid = class({})

function tusk_special_mid:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end

  local caster = self:GetCaster()
  caster:AddNewModifier(caster,self,"modifier_tusk_walrus_kick",{duration = self:GetCastPoint()*1})
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1.5, activity=ACT_DOTA_CAST_ABILITY_4, rate=0.5})
  caster:EmitSound("Hero_Tusk.WalrusPunch.Cast")
  return true
end

function tusk_special_mid:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
  caster:StopSound("Hero_Tusk.WalrusPunch.Cast")
  caster:RemoveModifierByName("modifier_tusk_walrus_kick")
end

function tusk_special_mid:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local height = self:GetSpecialValueFor("height")

  

  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_walruspunch_txt_ult.vpcf", PATTACH_ABSORIGIN, caster) 
  ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin()+Vector(0,0,75))
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),height)
  for k,v in pairs(units) do
    local damage = self:GetSpecialValueFor("damage") +  RandomInt(0,self:GetSpecialValueFor("damage_offset"))
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push

    caster:EmitSound("Hero_Tusk.WalrusPunch.Target")
    break
  end

  self:SetAbsOrigin(self:GetAbsOrigin()+Vector(0,0,100))
end

LinkLuaModifier("modifier_tusk_walrus_punch","abilities/tusk.lua",LUA_MODIFIER_MOTION_NONE)
modifier_tusk_walrus_punch = class({})

function modifier_tusk_walrus_punch:GetEffectName()
  return "particles/units/unit_greevil/greevil_transformation_glow.vpcf"
end
function modifier_tusk_walrus_punch:GetEffectAttachType()
  return PATTACH_POINT_FOLLOW
end

]]

tusk_special_top = class({})

function tusk_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  if caster.jumps > 2 then return end
  return true
end


function tusk_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  local height = self:GetSpecialValueFor("height")
  
  caster.jumps = 3


  -- Create the sigil
  self.sigil = nil
  self.sigil = CreateUnitByName("npc_dota_tusk_frozen_sigil1",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  self.sigil:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,height))
  self.sigil:AddNewModifier(caster,self,"modifier_tusk_sigil_aura",{duration = self:GetSpecialValueFor("slow_duration")}) 
end

modifier_tusk_sigil_dummy = class({})

modifier_tusk_sigil_aura = class({})

function modifier_tusk_sigil_aura:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end
function modifier_tusk_sigil_aura:OnIntervalThink()
  local unit = self:GetParent()
  local caster = self:GetCaster()
  local height = self:GetAbility():GetSpecialValueFor("height")
  local speed = self:GetAbility():GetSpecialValueFor("speed") /32
  caster:RemoveModifierByName("modifier_drop")

  -- Destroy the unit if the hero has dropped too low due to reasons
  if unit:GetAbsOrigin().z < caster:GetAbsOrigin().z + height+200 then
    caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,speed))
    unit:SetAbsOrigin(Vector(caster:GetAbsOrigin().x,0,unit:GetAbsOrigin().z+speed))
  else
    self:Destroy()
  end
end
function modifier_tusk_sigil_aura:OnDestroy()
  if IsServer() then
    UTIL_Remove(self:GetAbility().sigil)
    self:GetAbility().sigil = nil

    self:GetCaster():FindModifierByName("modifier_tusk_sigil_dummy")
  end
end
function modifier_tusk_sigil_aura:GetEffectName()
  return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end
function modifier_tusk_sigil_aura:GetEffectName()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tusk_sigil_aura:IsAura()
  return true
end

function modifier_tusk_sigil_aura:GetModifierAura()
  return "modifier_tusk_sigil_slow"
end

function modifier_tusk_sigil_aura:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tusk_sigil_aura:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end



function modifier_tusk_sigil_aura:CheckState()
  local funcs = {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }
  return funcs
end


modifier_tusk_sigil_slow= class({})

function modifier_tusk_sigil_slow:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
  }
  return funcs
end
function modifier_tusk_sigil_slow:GetEffectName()
  return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_frost_rope.vpcf"
end
function modifier_tusk_sigil_slow:GetEffectName()
  return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_tusk_sigil_slow:GetModifierPercentageCasttime()
  if IsServer() then
    return self:GetAbility():GetSpecialValueFor("slow") * -1
  end
end

tusk_special_bottom = class({})

function tusk_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end


function tusk_special_bottom:GetChannelTime()
  return self:GetSpecialValueFor("duration") --
end

function tusk_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Tusk.Snowball.Cast")
  -- Stop any movement
  caster:RemoveModifierByName("modifier_left")
  caster:RemoveModifierByName("modifier_right")
  caster:RemoveModifierByName("modifier_jump")
  -- Start being a snowball
  caster:AddNewModifier(caster,self,"modifier_tusk_snowball",{duration = self:GetChannelTime()})
  self.dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  self.dummy:AddNewModifier(caster,self,"modifier_tusk_snowball_dummy",{})

end
function tusk_special_bottom:OnChannelFinish(bInterrupted)
  -- Remvoe the snowball
  self:GetCaster():RemoveModifierByName("modifier_tusk_snowball")
end


modifier_tusk_snowball = class({})

function modifier_tusk_snowball:OnCreated()
  if IsServer() then
    -- Hide the hero, start the checks and init values
    self:GetParent():AddNoDraw()
    self:StartIntervalThink(1/32)
    self.speed = self:GetAbility():GetSpecialValueFor("speed") /32
    self.speedFactor = 1
    self.speedIncrement = self:GetAbility():GetSpecialValueFor("speed_increase") -- 0.03
    self.targets = {}
  end
end

function modifier_tusk_snowball:OnDestroy()
  if IsServer() then
    -- Remove the snowball dummy unit and make the hero visible again
    UTIL_Remove(self:GetAbility().dummy)
    self:GetParent():RemoveNoDraw()
  end
end
function modifier_tusk_snowball:OnIntervalThink()
  local caster = self:GetCaster()
  local ability =self:GetAbility()
  -- Movement does not interrupt but in this case that is what we want
  if caster:HasModifier("modifier_left") or caster:HasModifier("modifier_right") or caster:HasModifier("modifier_jump") then
    -- Destroy this
    self:GetCaster():InterruptChannel()
    self:Destroy()
  else
    -- Handle visual part
    local myPlatform
    if caster:isOnPlatform() then
      for k,v in pairs(platform) do
        if v.unitsOnPlatform[caster] then
          myPlatform = v
          break
        end
      end
    end
    local direction
    local angles = 0
    if myPlatform then
      angles = myPlatform:GetAngles().x/55
    end
    if caster:GetForwardVector().x > 0 then
      direction = Vector(1,0,-angles)
    else
      direction = Vector(-1,0,angles)
    end
    
    -- Increase the speed

    self.speedFactor = self.speedFactor + self.speedIncrement
  
    
    local speed = self.speed * self.speedFactor

    -- Move the hero and the rotating snowball along
    local vec = caster:GetAbsOrigin()+direction*speed
    if GridNav:IsWall(vec) then
      self:GetParent():SetAbsOrigin(Vector(caster:GetAbsOrigin().x,0,vec.z))
    else
      self:GetParent():SetAbsOrigin(vec)
    end
    self:GetAbility().dummy:SetAbsOrigin(caster:GetAbsOrigin())

     -- Determine which way the snowball should rotate
     if caster:GetForwardVector().x < 0 then
      self:GetAbility().dummy:SetAngles(self:GetAbility().dummy:GetAngles()[1] - 10*self.speedFactor,self:GetAbility().dummy:GetAngles()[2],self:GetAbility().dummy:GetAngles()[3])
    else
      self:GetAbility().dummy:SetAngles(self:GetAbility().dummy:GetAngles()[1] + 10*self.speedFactor,self:GetAbility().dummy:GetAngles()[2],self:GetAbility().dummy:GetAngles()[3])
    end
    
    
    -- Handle damage
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
        caster:EmitSound("Hero_Tusk.Snowball.ProjectileHit")
      end
    end
  end
end


modifier_tusk_snowball_dummy = class({})

function modifier_tusk_snowball_dummy:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
    MODIFIER_PROPERTY_VISUAL_Z_DELTA,
  }
  return funcs
end

function modifier_tusk_snowball_dummy:GetVisualZDelta()
  -- It shouldnt be in the ground
  return 80
end


function modifier_tusk_snowball_dummy:GetModifierModelChange()
  return "models/snowball_0.vmdl"
end

function modifier_tusk_snowball_dummy:CheckState()
  local funcs = {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
  }
  return funcs
end