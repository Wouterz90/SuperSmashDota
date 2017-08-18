centaur_special_side = class({})


function centaur_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  --caster:EmitSound("Hero_Centaur.HoofStomp")
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2 , rate=self:GetCastPoint()/0.5 })

  return true
end

function centaur_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  --caster:StopSound("Hero_Centaur.HoofStomp")
  EndAnimation(caster)
end

function centaur_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVectorDistance
  local ability = self
  StoreSpecialKeyValues(self)
  caster:EmitSound("Hero_Centaur.DoubleEdge")

  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", PATTACH_ABSORIGIN, caster)   
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()+caster:GetForwardVector()*self.radius+Vector(0,0,100))
  ParticleManager:SetParticleControl(particle, 1, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 4, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 5, caster:GetAbsOrigin()+caster:GetForwardVector()*self.radius+Vector(0,0,100))
  
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin()+caster:GetForwardVector()*self.radius+Vector(0,0,100), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin()+caster:GetForwardVector()*self.radius+Vector(0,0,100),self.radius)
  for _,unit in pairs(units) do
    local damageTable = {
      victim = unit,
      attacker = caster,
      damage = self:GetSpecialValueFor("damage") + RandomInt(0,self:GetSpecialValueFor("damage_offset")),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable)
  end
  local damageTable = {
    victim = caster,
    attacker = caster,
    damage = self.self_damage,  
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = self,
  }
  ApplyDamage(damageTable)
end

centaur_special_bottom = class({})

function centaur_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  --caster:EmitSound("Hero_Centaur.HoofStomp")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function centaur_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  --caster:StopSound("Hero_Centaur.HoofStomp.Loop")
  EndAnimation(caster)
end

function centaur_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVector
  local ability = self
  StoreSpecialKeyValues(self)
  
  caster:EmitSound("Hero_Centaur.HoofStomp")
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle, 1, Vector(self.radius, 1, 1))
  ParticleManager:SetParticleControl(particle, 2, caster:GetAbsOrigin())
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),self.radius)
  for _,unit in pairs(units) do
    local damageTable = {
      victim = unit,
      attacker = caster,
      damage = self.damage + RandomInt(0,self.damage_offset),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable)
    unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = self.stun_duration})
  end

end


LinkLuaModifier("modifier_centaur_stampede_smash","abilities/centaur.lua",LUA_MODIFIER_MOTION_NONE)
centaur_special_top = class({})

function centaur_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 3 then return end
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  caster:EmitSound("Hero_Centaur.Stampede.Cast")
  StartAnimation(self:GetCaster(), {duration=self.duration, activity=ACT_DOTA_CENTAUR_STAMPEDE, rate=1})
  return true
end

function centaur_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Centaur.Stampede.Cast")
  EndAnimation(caster)
end

function centaur_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  
  caster:AddNewModifier(caster,self,"modifier_centaur_stampede_smash",{duration = self.duration,x=self.mouseVector.x,z=self.mouseVector.z})
  

end


modifier_centaur_stampede_smash = class({})

function modifier_centaur_stampede_smash:OnCreated(keys)
  if IsServer() then
    self.direction = Vec(keys.x,keys.z)
    StoreSpecialKeyValues(self,self:GetAbility())
    self.targets = {}
    self:StartIntervalThink(FrameTime())
    self:GetCaster():EmitSound("Hero_Centaur.Stampede.Movement")
    --self:GetCaster().movespeedFactor = self:GetCaster().movespeedFactor + self.bonus_speed_factor
    --self:GetCaster().jumpfactor = self:GetCaster().jumpfactor + self.bonus_speed_factor
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_centaur/centaur_stampede.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
    self:AddParticle(self.particle, false, false, -1, false, false)
  end
end

function modifier_centaur_stampede_smash:OnIntervalThink()
  local caster = self:GetCaster()
  Physics2D:SetStaticVelocity(caster,"centaur_stampede",self.direction*30)
  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),self.radius)
  
  for _,unit in pairs(units) do
    if not self.targets[unit] then
      self.targets[unit] = true
      local damageTable = {
        victim = unit,
        attacker = caster,
        damage = self.damage + RandomInt(0,self.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      ApplyDamage(damageTable)
      unit:AddNewModifier(caster,self:GetAbility(),"modifier_smash_stun",{duration = self.stun_duration})
    end
  end
end

function modifier_centaur_stampede_smash:OnDestroy()
  if IsServer() then
    self:GetCaster():StopSound("Hero_Centaur.Stampede.Movement")
    self:GetCaster().jumps = 3
    
    
    Physics2D:SetStaticVelocity(self:GetCaster(),"centaur_stampede",Vector(0,1)*30)
    --self:GetCaster().movespeedFactor = self:GetCaster().movespeedFactor - self.bonus_speed_factor
    --self:GetCaster().jumpfactor = self:GetCaster().jumpfactor - self.bonus_speed_factor
    Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(self.particle,false)
      ParticleManager:ReleaseParticleIndex(self.particle)
    end)
  end
end

function modifier_centaur_stampede_smash:GetEffectName()
  return "particles/units/heroes/hero_centaur/centaur_stampede_overhead.vpcf"
end
function modifier_centaur_stampede_smash:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end