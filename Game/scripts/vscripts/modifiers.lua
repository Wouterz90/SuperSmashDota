--Movement modifiers
LinkLuaModifier("modifier_jump","movement.lua",LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_drop","movement.lua",LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_left","movement.lua",LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_right","movement.lua",LUA_MODIFIER_MOTION_HORIZONTAL)
-- Basic control modifier
LinkLuaModifier("modifier_basic","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_push","modifiers.lua",LUA_MODIFIER_MOTION_BOTH)


LinkLuaModifier("modifier_smash_root","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_silence","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_stun","modifiers.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smash_disarm","modifiers.lua",LUA_MODIFIER_MOTION_NONE)

modifier_smash_silence = class({})

function modifier_smash_silence:GetEffectName()
  return "particles/generic_gameplay/generic_silenced.vpcf"
end

function modifier_smash_silence:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

modifier_smash_stun = class({})

function modifier_smash_stun:GetEffectName()
  return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_smash_stun:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_smash_stun:OnCreated()
  if IsServer() then
    self:GetParent():SetRenderColor(0,0,0)
  end
end
function modifier_smash_stun:OnDestroy()
  if IsServer() then
    self:GetParent():SetRenderColor(255,255,255)
  end
end

modifier_smash_disarm = class({})

function modifier_smash_disarm:GetEffectName()
  return "particles/generic_gameplay/generic_disarm.vpcf"
end

function modifier_smash_disarm:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

modifier_smash_root = class({})
function modifier_smash_root:OnCreated()
  if IsServer() then
    self:GetParent():RemoveModifierByName("modifier_left")
    self:GetParent():RemoveModifierByName("modifier_right")
    self:GetParent():RemoveModifierByName("modifier_jump")
  end
end

function modifier_smash_root:GetEffectName()
  return "particles/econ/items/lone_druid/lone_druid_cauldron/lone_druid_bear_entangle_body_cauldron.vpcf"
end

function modifier_smash_root:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

modifier_basic = class({})

function modifier_basic:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_DEATH,
    --MODIFIER_PROPERTY_VISUAL_Z_DELTA,
  }
  return funcs
end
function modifier_basic:IsPurgable()
  return false
end

function modifier_basic:RemoveOnDeath()
  return true
end
-- This may look better, it makes it very hard to aim projectiles at each other
--[[function modifier_basic:GetVisualZDelta()
  if self:GetParent():GetUnitName() == "npc_dota_hero_puck" then
    if self:GetParent().zDelta then
      return self:GetParent().zDelta
    else
      return 0
    end
  else
    if self:GetParent().zDelta then
      return self:GetParent().zDelta
    else
      return 0
    end
  end
end]]
function modifier_basic:OnDeath(keys)
  if self:GetParent() == keys.unit and IsServer() then
    local hero = self:GetParent()
    -- Store the lifes to display on client
    PlayerTables:SetTableValue(tostring(hero:GetPlayerOwnerID()), "lifes", PlayerTables:GetTableValue(tostring(hero:GetPlayerOwnerID()), "lifes") -1)
   
    if PlayerTables:GetTableValue(tostring(hero:GetPlayerOwnerID()),"lifes") <= -1 then
      self:GetParent():SetRespawnsDisabled(true)

      deadplayers = deadplayers + 1
      if deadplayers >= PlayerResource:GetTeamPlayerCount() -1 then
        -- Resetting
        deadplayers = 0
        GameMode:Reset()
      end
    end
    -- Remove ourselves from any platform
    for k,v in pairs(platform) do
      v.unitsOnPlatform[self:GetParent()] = nil
    end
  end
end

function modifier_basic:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_basic:OnIntervalThink()
  
  --[[if not GridNav:IsTraversable(self:GetParent():GetAbsOrigin()) or GridNav:IsBlocked(self:GetParent():GetAbsOrigin()) night_stalker_hunter_in_the_night
    print(GridNav:IsTraversable(self:GetParent():GetAbsOrigin()))
    PauseGame(true)
  end]]


  -- Always return to y = 0!
  if self:GetParent():GetAbsOrigin().y ~= 0 then
    self:GetParent():SetAbsOrigin(Vector(self:GetParent():GetAbsOrigin().x,0,self:GetParent():GetAbsOrigin().z))
  end
  -- Kill the unit if it is either too low or too high.
  if self:GetParent():GetAbsOrigin().z > Laws.flMaxHeight or self:GetParent():GetAbsOrigin().z < Laws.flMinHeight then
    self:GetParent():ForceKill(false)
  end
  -- Make sure gravity works when we are not on a platform
  if not self:GetParent():isOnPlatform() then
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

modifier_push = class({})

function modifier_push:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
    local unit = self:GetParent()
    local distance = unit.pushDistance
    local duration = unit.pushDistance /push.flPushSpeed
    self:SetDuration(duration,true)
  end
end

function modifier_push:OnIntervalThink()
  local unit = self:GetParent()
  local distance = unit.pushDistance /32

  -- Prevent the unit from going through a platform, it bounces back with half power
  if unit:isOnPlatform() and unit.pushDirection.z < 0 then
    unit.pushDirection = Vector(unit.pushDirection.x,0,unit.pushDirection.z * -0.5)
  end
  unit:SetAbsOrigin(unit:GetAbsOrigin() + unit.pushDirection * distance)
end