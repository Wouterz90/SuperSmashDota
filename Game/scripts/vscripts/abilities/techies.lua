techies_special_side = class({})

LinkLuaModifier("modifier_techies_rolling_mine","abilities/techies.lua",LUA_MODIFIER_MOTION_NONE)

function techies_special_side:GetCastPoint()
  if self.mine then return 0 end
  return self.cast_point or self:GetSpecialValueFor("cast_point")
end
function techies_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StoreSpecialKeyValues(self)
  local caster = self:GetCaster()
  if not self.mine then
    caster:EmitSound("RoshanDT.BucketDrop")
    StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_6 , rate=self:GetCastPoint()/self.original_ability_cast_time})
  end
  return true
end

function techies_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("RoshanDT.BucketDrop")
  EndAnimation(caster)
end

function techies_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = caster:GetForwardVector()
  local ability = self


  if not self.mine then
    if direction.x > 0 then
      direction = Vector(1,0,0)
    else
      direction = Vector(-1,0,0)
    end
    self.mine = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/rolling_mine.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    self.mine:SetAngles(0,0,90)
    self.mine:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,150))
    
    --self.mine:FindAbilityByName("dummy_unit"):SetLevel(1)
    Physics2D:CreateObject("circle",self.mine:GetAbsOrigin(),true,false,self.mine,50,0,"Unit")
    self.mine.IsSmashUnit = true
    self.mine.NoFriction = true
    Physics2D:AddPhysicsVelocity(self.mine,Vec(caster:GetForwardVector().x * 15),0)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mine_plant.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.mineDummy)
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_remote", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particle, 1, self.mine:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, self.mine:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    self:EndCooldown()
  else
    self:BlowUpMine()
  end
  
end

function techies_special_side:BlowUpMine()
  if not self.mine then return end
  if self.mine:IsNull() then
    UTIL_Remove(self.mine)
    self.mine = nil
    return
  end
  local origin = self.mine:GetAbsOrigin()
  local particle = ParticleManager:CreateParticle("particles/techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
  ParticleManager:SetParticleControl(particle, 0, origin)
  ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 1, 1))
  ParticleManager:SetParticleControl(particle, 3, origin)
  ParticleManager:ReleaseParticleIndex(particle)

  self:GetCaster():EmitSound("Hero_Techies.LandMine.Detonate")

  local platforms = FindPlatformsInRadius(origin,self.radius/6) 
  for k,v in pairs(platforms) do
    DestroyPlatform(v)
  end

  local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self.mine:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self.mine:GetAbsOrigin(),self.radius)
  for k,v in pairs(units) do
    local damageTable = {
      victim = v,
      attacker = self:GetCaster(),
      damage = self.damage + RandomInt(0,self.damage_offset),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    DealDamage(damageTable,self.mine:GetAbsOrigin())
  end

  if (self:GetCaster():GetAbsOrigin() -self.mine:GetAbsOrigin()):Length() < self.radius then
    local damageTable = {
      victim = self:GetCaster(),
      attacker = self:GetCaster(),
      damage = 0.5*self.damage + RandomInt(0,self.damage_offset),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable)
  end

  UTIL_Remove(self.mine)
  self.mine = nil

end

techies_special_bottom = class({})

LinkLuaModifier("modifier_techies_land_mine_smash","abilities/techies.lua",LUA_MODIFIER_MOTION_NONE)

function techies_special_bottom:GetCastPoint()
  if self.mine then return 0 end
  return self.cast_point or self:GetSpecialValueFor("cast_point")
end

function techies_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StoreSpecialKeyValues(self)
  local caster = self:GetCaster()
  
  caster:EmitSound("Hero_Techies.LandMine.Plant")
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_6 , rate=self:GetCastPoint()/self.original_ability_cast_time})
  
  return true
end

function techies_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Techies.LandMine.Plant")
  EndAnimation(caster)
end

function techies_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = caster:GetForwardVector()
  local ability = self
  
  local mine = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  mine:SetAbsOrigin(caster:GetAbsOrigin())
  mine:FindAbilityByName("dummy_unit"):SetLevel(1)
  Physics2D:CreateObject("AABB",mine:GetAbsOrigin(),true,false,mine,75,50,"Unit")
  mine:AddNewModifier(caster,self,"modifier_techies_land_mine_smash",{})
  mine:AddNewModifier(caster,self,"modifier_basic",{})

  mine.IsSmashUnit = true

end

modifier_techies_land_mine_smash = class({})

function modifier_techies_land_mine_smash:DeclareFunctions()
  local funcs = 
  {
    MODIFIER_PROPERTY_MODEL_CHANGE,
    MODIFIER_PROPERTY_MODEL_SCALE,

  }
  return funcs
end

function modifier_techies_land_mine_smash:GetModifierModelScale()
  return 0.5
end
function modifier_techies_land_mine_smash:GetModifierModelChange()
  return "models/heroes/techies/fx_techiesfx_mine.vmdl"
end

function modifier_techies_land_mine_smash:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self:StartIntervalThink(1/30)
    self:GetParent():SetModelScale(0.75)
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 3, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
  else
    self:GetParent().delta_z = -40
  end
end

function modifier_techies_land_mine_smash:OnDestroy()
  if IsServer() then
    local mine = self:GetParent()
    local origin = mine:GetAbsOrigin()
    
    mine:EmitSound("Hero_Techies.LandMine.Detonate")

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, origin)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),self.radius)
    
    local platforms = FindPlatformsInRadius(origin,self.radius/8) 
    for k,v in pairs(platforms) do
      DestroyPlatform(v)
    end

    for k,v in pairs(units) do
      local damageTable = {
        victim = v,
        attacker = self:GetCaster(),
        damage = self.damage + RandomInt(0,self.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      local casterLoc = self:GetCaster():GetAbsOrigin()
      self:GetCaster():SetAbsOrigin(origin)
      ApplyDamage(damageTable)
      self:GetCaster():SetAbsOrigin(casterLoc)
    end
    if (self:GetCaster():GetAbsOrigin() -mine:GetAbsOrigin()):Length() < self.radius then
      local damageTable = {
        victim = self:GetCaster(),
        attacker = self:GetCaster(),
        damage = 0.5*self.damage + RandomInt(0,self.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      ApplyDamage(damageTable)
    end
  end
end

function modifier_techies_land_mine_smash:OnIntervalThink()
  if self:GetElapsedTime() < self.activation_delay then return end
  
  local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),self.radius)

  if units and #units >= 1 then
    self:Destroy()
  end
end

techies_special_top = class({}) 
LinkLuaModifier("modifier_blast_off_jump","abilities/techies.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_blast_off_explosive_landing","abilities/techies.lua",LUA_MODIFIER_MOTION_NONE)

function techies_special_top:GetCastPoint()
  if self.mine then return 0 end
  return self.cast_point or self:GetSpecialValueFor("cast_point")
end

function techies_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 2 then return end
  StoreSpecialKeyValues(self)
  local caster = self:GetCaster()
  
  caster:EmitSound("Hero_Techies.BlastOff.Cast")
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_3 , rate=1})
  
  return true
end

function techies_special_top:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Techies.BlastOff.Cast")
  EndAnimation(caster)
end

function techies_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  caster.jumps = 3

  caster:AddNewModifier(caster,self,"modifier_blast_off_jump",{duration =  self.jump_duration})
end


modifier_blast_off_jump = class({})
function modifier_blast_off_jump:OnCreated()
  if IsServer() then
    
    Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,30))
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
  end
end



function modifier_blast_off_jump:OnDestroy()
  if IsServer() then
    
    self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_blast_off_explosive_landing",{})
  end
end

modifier_blast_off_explosive_landing = class({})

function modifier_blast_off_explosive_landing:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self:StartIntervalThink(1/30)
  end
end

function modifier_blast_off_explosive_landing:OnDestroy()
  if IsServer() then
    self:GetParent():EmitSound("Hero_Techies.Suicide")

    local origin = self:GetParent():GetAbsOrigin() -Vec(0,50)
    local particle = ParticleManager:CreateParticle("particles/techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, origin)
    ParticleManager:SetParticleControl(particle, 2, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(particle)

    local units = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),self.radius)
    for k,v in pairs(units) do
      local damageTable = {
        victim = v,
        attacker = self:GetCaster(),
        damage = self.damage + RandomInt(0,self.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      local casterLoc = self:GetCaster():GetAbsOrigin()
      self:GetCaster():SetAbsOrigin(origin)
      ApplyDamage(damageTable)
      self:GetCaster():SetAbsOrigin(casterLoc)
    end
    
    local damageTable = {
      victim = self:GetCaster(),
      attacker = self:GetCaster(),
      damage = 0.5*self.damage + RandomInt(0,self.damage_offset),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self:GetAbility(),
    }
    ApplyDamage(damageTable)
    
  end
end

function modifier_blast_off_explosive_landing:OnIntervalThink()
  if self:GetParent():HasModifier("modifier_on_platform") then
    self:Destroy()
  end
end