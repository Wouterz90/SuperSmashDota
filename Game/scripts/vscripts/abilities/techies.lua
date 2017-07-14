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
    self.mineDummy = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/rolling_mine.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    self.mineDummy:SetAngles(0,0,90)
    self.mineDummy:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,150))
    self.mine = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
    self.mine:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,150))
    self.mine:FindAbilityByName("dummy_unit"):SetLevel(1)
    self.mine:AddNewModifier(caster,self,"modifier_basic",{})
    self.mine:AddNewModifier(caster,self,"modifier_techies_rolling_mine",{}).direction = direction

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mine_plant.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self.mineDummy)
    ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_remote", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(particle, 1, self.mineDummy:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 4, self.mineDummy:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle)

    self:EndCooldown()
  else
    self.mine:RemoveModifierByName("modifier_techies_rolling_mine")
  end
  
  
end

modifier_techies_rolling_mine = class({})

function modifier_techies_rolling_mine:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self:StartIntervalThink(1/30)
  end
end

function modifier_techies_rolling_mine:OnRemoved()
  if IsServer() then
    local mine = self:GetParent()
    local origin = mine:GetAbsOrigin()
    local mineDummy = self:GetAbility().mineDummy

    if IsValidEntity(self:GetParent()) then
      mine:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
      mine:StopSound("DOTA_Item.Radiance.Target.Loop")

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

    self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(1))
    CustomGameEventManager:Send_ServerToPlayer(self:GetCaster():GetPlayerOwner(),"show_cooldown",{sAbilityName = self:GetAbility():GetAbilityName(),ability = self:GetAbility():entindex(), nCooldown = self:GetAbility():GetCooldown(1)})
    self:GetAbility().mine = nil
    self:GetAbility().mineDummy = nil
    UTIL_Remove(mineDummy)
    Timers:CreateTimer(1,function()
      UTIL_Remove(mine)
    end)
    
  end
end

function modifier_techies_rolling_mine:OnIntervalThink()
  local mine = self:GetParent()
  local mineDummy = self:GetAbility().mineDummy
  if mine:isOnPlatform() then
    mine:StopSound("DOTA_Item.Radiance.Target.Loop")
    mine:EmitSound("Hero_EarthSpirit.RollingBoulder.Loop")
  else
    mine:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
    mine:EmitSound("DOTA_Item.Radiance.Target.Loop")
  end
  if mine:GetAbsOrigin().z < 100 then 
    self:Destroy()
    return
  end
  local platform = mine:isOnPlatform()
  if platform then 
    if platform:GetAngles().x ~= 0 then
      self.direction = Vector(platform:GetAngles().x,0,0):Normalized()
    end
  end
  
  mine:SetAbsOrigin(mine:GetAbsOrigin()+self.direction*(self.rolling_speed/30))
  mineDummy:SetAbsOrigin(mine:GetAbsOrigin()+Vector(0,0,50))
  mineDummy:SetAngles(self:GetAbility().mineDummy:GetAngles()[1] + (10*self.direction.x) , self:GetAbility().mineDummy:GetAngles()[2],self:GetAbility().mineDummy:GetAngles()[3])
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
  mine:AddNewModifier(caster,self,"modifier_basic",{})
  mine:AddNewModifier(caster,self,"modifier_techies_land_mine_smash",{})

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
    self:StartIntervalThink(1/32)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off_trail.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, self:GetParent():GetAbsOrigin())
    self:AddParticle(particle, false, false, -1, false, false)
  end
end


function modifier_blast_off_jump:OnIntervalThink()
  -- handle lowest platform
  if self:GetParent():isUnderPlatform() and self:GetCaster():HasModifier("modifier_basic") then return end
  --  
  self.count = (self.count or 0) + 1
  
  local vec = self:GetParent():GetAbsOrigin()
  local z = vec[3] + Laws.flJumpSpeed * 1.25  * math.pow(Laws.flJumpDeceleration, self.count)
  vec = Vector(vec[1],vec[2],z)
  self:GetParent():SetAbsOrigin(vec)
end
  

function modifier_blast_off_jump:OnDestroy()
  if IsServer() then
    self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
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

    local origin = self:GetParent():GetAbsOrigin()
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
  if self:GetParent():isOnPlatform() then
    self:Destroy()
  end
end