--Movement modifiers
LinkLuaModifier("modifier_jump","movement.lua",LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_drop","movement.lua",LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_left","movement.lua",LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_right","movement.lua",LUA_MODIFIER_MOTION_HORIZONTAL)
-- Basic control modifier
LinkLuaModifier("modifier_basic","modifiers.lua",LUA_MODIFIER_MOTION_NONE)


LinkLuaModifier("modifier_no_gravity","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_root","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_silence","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_stun","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_disarm","modifiers.lua",LUA_MODIFIER_MOTION_NONE)

modifier_smash_silence = class({})

function modifier_smash_silence:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_smash_silence:GetEffectName()
  return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_smash_silence:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_smash_silence:OnCreated()
  if IsServer() then
    CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(),"show_silence",{flStartTime = GameRules:GetGameTime(), flDuration = self:GetRemainingTime()})
  end
end



--[[function modifier_smash_silence:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_smash_silence:OnAbilityStart(keys)
  if IsClient() then return end
  if keys.unit ~= self:GetParent() then return end

  local abilityName = keys.ability:GetAbilityName()
  if string.find(abilityName, "special") then
    self:GetParent():Interrupt()
  end
end]]


modifier_smash_stun = class({})

function modifier_smash_stun:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_smash_stun:GetEffectName()
  return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_smash_stun:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_smash_stun:OnCreated()
  if IsServer() then
    Timers:CreateTimer(0,function()
      if not self.dontColor then
        self:GetParent():SetRenderColor(0,0,0)
      end
    end)
  end
end
function modifier_smash_stun:OnDestroy()
  if IsServer() then
    if not self.dontColor then
      self:GetParent():SetRenderColor(255,255,255)
    end
  end
end

modifier_smash_disarm = class({})

function modifier_smash_disarm:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_smash_disarm:GetEffectName()
  return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_smash_disarm:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

--[[function modifier_smash_disarm:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_START,
  }
  return funcs
end

function modifier_smash_disarm:OnAbilityStart(keys)
  if IsClient() then return end
  if keys.unit ~= self:GetParent() then return end

  local abilityName = keys.ability:GetAbilityName()
  if string.find(abilityName, "basic_attack") then
    self:GetParent():Interrupt()
  end
end]]

modifier_smash_root = class({})
function modifier_smash_root:OnCreated()
  if IsServer() then
    --[[
    self:GetParent():RemoveModifierByName("modifier_left")
    self:GetParent():RemoveModifierByName("modifier_right")
    self:GetParent():RemoveModifierByName("modifier_jump")]]
  end
end

--function modifier_smash_root:GetEffectName()
  --return "particles/econ/items/lone_druid/lone_druid_cauldron/lone_druid_bear_entangle_body_cauldron.vpcf"
--end

--function modifier_smash_root:GetEffectAttachType()
 -- return PATTACH_OVERHEAD_FOLLOW
--end

modifier_basic = class({})

function modifier_basic:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
    MODIFIER_PROPERTY_VISUAL_Z_DELTA,
  }
  return funcs
end
function modifier_basic:IsPurgable()
  return false
end

function modifier_basic:RemoveOnDeath()
  return true
end

function modifier_basic:GetVisualZDelta()
  if IsClient() then return end
  if self:GetParent():GetUnitName() == "npc_dota_hero_phoenix" then
    return self:GetParent().zDelta-50
  else
    return self:GetParent().zDelta
  end
end
function modifier_basic:OnDeath(keys)
  if self:GetParent() == keys.unit and IsServer() then
    GameMode:OnHeroDeath(self:GetParent())
  end
end

function modifier_basic:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_basic:OnIntervalThink()
  -- Store last position to predict next position for clientside height location
  -- I don't think this will work because I need to know what ticks are only clientside, without delay that seems unlikely.
  --[[if self.prevPos then
    local delta_z = self.prevPos.z - self:GetParent():GetAbsOrigin().z
    PlayerTables:SetTableValue(tostring(self:GetParent():GetPlayerOwnerID()),"delta_z",delta_z)
  end
  self.prevPos = unit:GetAbsOrigin()]]


  -- Always return to y = 0!
  if self:GetParent():GetAbsOrigin().y ~= 0 then
    self:GetParent():SetAbsOrigin(Vector(self:GetParent():GetAbsOrigin().x,0,self:GetParent():GetAbsOrigin().z))
  end
  -- Kill the unit if it is either too low or too high.
  if self:GetParent():GetAbsOrigin().z > Laws.flMaxHeight or self:GetParent():GetAbsOrigin().z < Laws.flMinHeight then
    self:GetParent():ForceKill(false)
  end
  -- Make sure gravity works when we are not on a platform
  if not self:GetParent():isOnPlatform() and not self:GetParent():HasModifier("modifier_jump") then
    for k,v in pairs(jumpModifiers) do
      if self:GetParent():HasModifier(k) then
        return
      end
    end
    self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
  end
  
  self:GetParent():CheckForWalls()
end
function modifier_basic:CheckState()
  local funcs = {
    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_UNSELECTABLE] = true,
  }
  return funcs
end

modifier_no_gravity = class({})