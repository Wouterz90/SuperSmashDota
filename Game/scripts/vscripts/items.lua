items = items or class({})

items.itemStorage = {}
-- Items are units that simply check collision?
items.categories = {
  runes = {
    --"attack_rune", -- DD
    --"spell_rune", -- Arcane

    "speed_rune", -- Haste
    "jump_rune", -- Bounty
    "regen_rune", --regen
  }
}
 
RUNE_BONUS_ATTACKDAMAGE_FACTOR = 0.5
RUNE_BONUS_COOLDOWN_REDUCTION = 0.2
RUNE_BONUS_SPEED_FACTOR = 0.33
RUNE_BONUS_JUMP_FACTOR = 0.75
RUNE_BONUS_REGEN_SEC = 25

function items:CreateItem(table)
  -- table.bFallsDown
  -- table.categoryName
  -- table.layAroundDuration
  DebugPrint(1,"[SMASH] [ITEMS] CreateItem")
  if not platform then return end

  if not table.categoryName then
    return -- Maybe later change this to chose a random category first
  end
  local mapRadius
  for i=1, #platform do
    mapRadius = platform[i].mapRadius
    if mapRadius then
      break
    end
  end
  local vItemSpawnLoc = Vector(RandomInt(-platform[1].mapRadius,platform[1].mapRadius),0,2000)

  self.item = CreateUnitByName("npc_dummy_unit",vItemSpawnLoc,false,nil,nil,DOTA_TEAM_NEUTRALS)
  self.item:SetAbsOrigin(vItemSpawnLoc)
  local a = #self.categories[table.categoryName] 
  local name = self.categories[table.categoryName][RandomInt(1,a)]
  local modifierName = "modifier_"..name
  self.item:AddNewModifier(self.item,nil,modifierName,{})
  self.item:AddNewModifier(self.item,nil,"modifier_basic",{})
  local ab = self.item:AddAbility("dummy_unit")
  ab:SetLevel(1)

  table.insert(items.itemStorage, self.item)
  --[[if table.layAroundDuration then
    
    Timers:CreateTimer(table.layAroundDuration,function()
      print(GameRules:GetGameTime(),table.layAroundDuration)
      if self.item and IsValidEntity(self.item) then
        UTIL_Remove(self.item)
      else
        self.item = nil
      end
      return -1
    end)
  end]]
end

-- DD
modifier_attack_rune = class({})
LinkLuaModifier("modifier_attack_rune","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_attack_rune:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_attack_rune:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  }
  return funcs
end

function modifier_attack_rune:OnIntervalThink()
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin() , nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),50)
  if units[1] and units[1]:GetUnitName() ~= "npc_dummy_unit" then
    units[1]:RemoveModifierByName(self:GetName().."_buff")
units[1]:AddNewModifier(self:GetParent(),nil,self:GetName().."_buff",{duration = Laws.flRuneDuration})
    units[1]:EmitSound("General.RunePickUp")
    UTIL_Remove(self:GetParent())
  end
end

function modifier_attack_rune:GetModifierModelChange()
  return "models/props_gameplay/rune_doubledamage01.vmdl"
end

modifier_attack_rune_buff = class({})
LinkLuaModifier("modifier_attack_rune_buff","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_attack_rune_buff:OnCreated()
  if IsServer() then
    self:GetParent().attackDamageFactor = self:GetParent().attackDamageFactor + RUNE_BONUS_ATTACKDAMAGE_FACTOR
  end
end

function modifier_attack_rune_buff:OnRefresh()
  self:OnCreated()
end
function modifier_attack_rune_buff:OnDestroy()
  if IsServer() then
   self:GetParent().attackDamageFactor = self:GetParent().attackDamageFactor - RUNE_BONUS_ATTACKDAMAGE_FACTOR
  end
end

function modifier_attack_rune_buff:GetEffectName()
  return "particles/basic_effects/runes/doubledamage/rune_doubledamage_owner.vpcf"
end

function modifier_attack_rune:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end


-- Arcana
modifier_spell_rune = class({})
LinkLuaModifier("modifier_spell_rune","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_spell_rune:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_spell_rune:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  }
  return funcs
end

function modifier_spell_rune:OnIntervalThink()
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin() , nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),50)
  if units[1] and units[1]:GetUnitName() ~= "npc_dummy_unit" then
    units[1]:RemoveModifierByName(self:GetName().."_buff")
units[1]:AddNewModifier(self:GetParent(),nil,self:GetName().."_buff",{duration = Laws.flRuneDuration})
    units[1]:EmitSound("General.RunePickUp")
    UTIL_Remove(self:GetParent())
  end
end

function modifier_attack_rune:GetModifierModelChange()
  return "models/props_gameplay/rune_arcane.vmdl"
end

modifier_spell_rune_buff = class({})
LinkLuaModifier("modifier_spell_rune_buff","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_spell_rune_buff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
  }
  return funcs
end

function modifier_spell_rune_buff:GetModifierPercentageCooldown()
  if IsServer() then
    return RUNE_BONUS_COOLDOWN_REDUCTION
  end
end

function modifier_spell_rune_buff:GetEffectName()
  return "particles/generic_gameplay/rune_arcane_owner.vpcf"
end

function modifier_spell_rune_buff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

-- Haste
modifier_speed_rune = class({})
LinkLuaModifier("modifier_speed_rune","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_speed_rune:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end


function modifier_speed_rune:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  }
  return funcs
end

function modifier_speed_rune:OnIntervalThink()
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin() , nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),50)
  if units[1] and units[1]:GetUnitName() ~= "npc_dummy_unit" then
    units[1]:RemoveModifierByName(self:GetName().."_buff")
    units[1]:AddNewModifier(self:GetParent(),nil,self:GetName().."_buff",{duration = Laws.flRuneDuration})
    units[1]:EmitSound("General.RunePickUp")
    UTIL_Remove(self:GetParent())
  end
end

function modifier_speed_rune:GetModifierModelChange()
  return "models/props_gameplay/rune_haste01.vmdl"
end

modifier_speed_rune_buff = class({})
LinkLuaModifier("modifier_speed_rune_buff","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_speed_rune_buff:OnCreated()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor + RUNE_BONUS_SPEED_FACTOR
  end
end
function modifier_speed_rune_buff:OnRefresh()
  self:OnCreated()
end

function modifier_speed_rune_buff:OnDestroy()
  if IsServer() then
    self:GetParent().movespeedFactor = self:GetParent().movespeedFactor - RUNE_BONUS_SPEED_FACTOR
  end
end

function modifier_speed_rune_buff:GetEffectName()
  return "particles/generic_gameplay/rune_haste_owner.vpcf"
end

function modifier_speed_rune_buff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

-- jump
modifier_jump_rune = class({})
LinkLuaModifier("modifier_jump_rune","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_jump_rune:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_jump_rune:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  }
  return funcs
end

function modifier_jump_rune:OnIntervalThink()
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin() , nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),50)
  if units[1] and units[1]:GetUnitName() ~= "npc_dummy_unit" then
    units[1]:RemoveModifierByName(self:GetName().."_buff")
    units[1]:AddNewModifier(self:GetParent(),nil,self:GetName().."_buff",{duration = Laws.flRuneDuration})
    units[1]:EmitSound("General.RunePickUp")
    UTIL_Remove(self:GetParent())
  end
end

function modifier_jump_rune:GetModifierModelChange()
  return "models/props_gameplay/boots_of_speed.vmdl"
end

modifier_jump_rune_buff = class({})
LinkLuaModifier("modifier_jump_rune_buff","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_jump_rune_buff:OnCreated()
  if IsServer() then
    self:GetParent().jumpfactor = self:GetParent().jumpfactor + RUNE_BONUS_JUMP_FACTOR
  end
end

function modifier_jump_rune_buff:OnRefresh()  
  self:OnCreated()
end

function modifier_jump_rune_buff:OnDestroy()
  if IsServer() then
    self:GetParent().jumpfactor = self:GetParent().jumpfactor - RUNE_BONUS_JUMP_FACTOR
  end
end

function modifier_jump_rune_buff:GetEffectName()
  return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_jump_rune_buff:GetEffectAttachType()
  return PATTACH_ABSORIGIN
end

-- jump
modifier_regen_rune = class({})
LinkLuaModifier("modifier_regen_rune","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_regen_rune:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MODEL_CHANGE,
  }
  return funcs
end

function modifier_regen_rune:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_regen_rune:OnIntervalThink()
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, self:GetParent():GetAbsOrigin() , nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),50)
  if units[1] and units[1]:GetUnitName() ~= "npc_dummy_unit" then
    units[1]:RemoveModifierByName(self:GetName().."_buff")
    units[1]:AddNewModifier(self:GetParent(),nil,self:GetName().."_buff",{duration = Laws.flRuneDuration})
    units[1]:EmitSound("General.RunePickUp")
    UTIL_Remove(self:GetParent())
  end
end

function modifier_regen_rune:GetModifierModelChange()
  return "models/props_gameplay/rune_regeneration01.vmdl"
end

modifier_regen_rune_buff = class({})
LinkLuaModifier("modifier_regen_rune_buff","items.lua",LUA_MODIFIER_MOTION_NONE)

function modifier_regen_rune_buff:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
  }
  return funcs
end

function modifier_regen_rune_buff:GetModifierConstantHealthRegen()
  if IsServer() then
    return RUNE_BONUS_REGEN_SEC
  end
end

function modifier_regen_rune_buff:OnTakeDamage(keys)
  if IsServer() then
    if keys.unit == self:GetParent() then
      self:Destroy()
    end
  end
end

function modifier_regen_rune_buff:GetEffectName()
  return "particles/generic_gameplay/rune_regen_owner.vpcf"
end

function modifier_regen_rune_buff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end


