batrider_special_side = class({})


function batrider_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Batrider.Flamebreak")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function batrider_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Batrider.Flamebreak")
  EndAnimation(caster)
end

function batrider_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVectorDistance
  local ability = self
  StoreSpecialKeyValues(self)

  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    EffectName = "particles/batrider/batrider_flamebreak.vpcf",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    --vSpawnOrigin = caster:GetAbsOrigin(),
    vSpawnOrigin = {unit=caster, attach="attach_attack1"},
    fDistance = (direction *ability.projectile_range):Length(),
    fStartRadius = ability.projectile_radius,
    fEndRadius =  ability.projectile_radius,
    Source = caster,
    fExpireTime = ability.projectile_range/ability.projectile_speed,
    vVelocity = ability.mouseVector * ability.projectile_speed, -- RandomVector(1000),
    UnitBehavior = PROJECTILES_DESTROY,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_DESTROY,
    GroundBehavior = PROJECTILES_DESTROY,
    fGroundOffset = 0,
    nChangeMax = 1,
    bRecreateOnChange = true,
    bZCheck = true,
    bGroundLock = false,
    bProvidesVision = true,
    iVisionRadius = 0,
    iVisionTeamNumber = caster:GetTeam(),
    bFlyingVision = false,
    fVisionTickTime = .1,
    fVisionLingerDuration = 1,
    draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},

    UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
    OnUnitHit = function(self, unit)
    end,
    OnFinish = function(self,pos)
      caster:EmitSound("Hero_Batrider.Flamebreak.Impact")
      self.particle = ParticleManager:CreateParticle("particles/batrider/batrider_flamebreak_explosion.vpcf",PATTACH_ABSORIGIN,caster)
      ParticleManager:SetParticleControl( self.particle, 3, pos)
      --ParticleManager:SetParticleControl( self.particle, 2, Vector(ability.explosion_radius*100,0,0))
      Timers:CreateTimer(1,function()
        ParticleManager:DestroyParticle(self.particle,false)
        ParticleManager:ReleaseParticleIndex(self.particle)
      end)

      local units = FindUnitsInRadius(caster:GetTeam(), pos, nil, ability.explosion_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,pos,ability.explosion_radius)
      for k,v in pairs(units) do

        local damageTable = {
          victim = v,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        local casterLoc = caster:GetAbsOrigin()
        caster:SetAbsOrigin(pos)
        ApplyDamage(damageTable)
        caster:SetAbsOrigin(casterLoc)
      end
    end,
  }
  Projectiles:CreateProjectile(projectile)
end

LinkLuaModifier("modifier_batrider_lasso_smash","abilities/batrider.lua",LUA_MODIFIER_MOTION_NONE)
batrider_special_bottom = class({})

function batrider_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Batrider.FlamingLasso.Loop")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function batrider_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Batrider.FlamingLasso.Loop")
  EndAnimation(caster)
end

function batrider_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVector
  local ability = self
  StoreSpecialKeyValues(self)
  
  caster:StopSound("Hero_Batrider.FlamingLasso.Loop")
  local dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  Physics:Unit(dummy)
  local modifier = dummy:AddNewModifier(caster,self,"modifier_batrider_lasso_smash",{duration = self.search_duration})
  dummy:SetAbsOrigin(caster:GetAbsOrigin())
  dummy:AddNewModifier(dummy,nil,"modifier_basic",{})
  dummy:FindAbilityByName("dummy_unit"):SetLevel(1)

  modifier.dummy = dummy
end

modifier_batrider_lasso_smash = class({})

function modifier_batrider_lasso_smash:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self:StartIntervalThink(FrameTime())

    self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_smash_stun",{}) 
    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_flaming_lasso.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControlEnt(self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin() + Vector(0,0,50), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin() + Vector(0,0,0), true)
    --self:OnIntervalThink()  
  end
end


function modifier_batrider_lasso_smash:OnIntervalThink()
  -- If the distance is too big, break_range

  if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length() > self.break_range then self:Destroy() print("DES") return end
  if (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length() > self.pull_range then
    local direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
    self:GetParent():SetStaticVelocity("batrider_lasso",self:GetCaster():GetStaticVelocity()  )
    --print(self:GetCaster():GetStaticVelocity())
    --self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin() + direction*self.pull_range)
  end
  if self:GetParent():GetUnitName() ~= "npc_dummy_unit" then
    self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_no_gravity",{duration = 2* FrameTime()})
    --jumpModifiers[self:GetName()] = false
    -- Damage
    self.count = (self.count or 5 ) +1
    --self.count = self.count +1
    if self.count == 6 then
      local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("damage") + RandomInt(0,self:GetAbility():GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      ApplyDamage(damageTable)
      self.count = 0
    end

  else
    -- Search for units to catch
    --jumpModifiers[self:GetName()] = true

    local caster = self:GetCaster()
    local units = FindUnitsInRadius(caster:GetTeam(), self:GetParent():GetAbsOrigin(), nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
    units = FilterUnitsBasedOnHeight(units,self:GetParent():GetAbsOrigin(),self.search_radius)
    if units and units[1] then
      units[1]:EmitSound("Hero_Batrider.FlamingLasso.Cast")
      units[1]:AddNewModifier(caster,self:GetAbility(),"modifier_batrider_lasso_smash",{duration = self.lasso_duration})
      self:Destroy()
    end
  end
end

function modifier_batrider_lasso_smash:OnDestroy()
  if IsServer() then
    self:GetParent():RemoveModifierByName("modifier_smash_stun")
    ParticleManager:DestroyParticle(self.particle,false)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self:GetParent():SetStaticVelocity("batrider_lasso",Vector(0,0,0))
    if self:GetParent():GetUnitName() == "npc_dummy_unit" then
      UTIL_Remove(self:GetParent())
    end
  end
end


LinkLuaModifier("modifier_batrider_firefly_smash","abilities/batrider.lua",LUA_MODIFIER_MOTION_NONE)
batrider_special_top = class({})

function batrider_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 3 then return end
  local caster = self:GetCaster()
  caster:EmitSound("Hero_Batrider.Firefly.Cast")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1, activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function batrider_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Batrider.Firefly.Cast")
  EndAnimation(caster)
end

function batrider_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  StoreSpecialKeyValues(self)
  

  caster:AddNewModifier(caster,self,"modifier_batrider_firefly_smash",{duration = self.duration})
  caster.jumps = 0
  caster:AddNewModifier(caster,self,"modifier_jump",{duration = 1.75})
end


modifier_batrider_firefly_smash = class({})

function modifier_batrider_firefly_smash:OnCreated()
  if IsServer() then
    StoreSpecialKeyValues(self,self:GetAbility())
    self.dummies = {}
    self:StartIntervalThink(1/30)
    self:GetCaster():EmitSound("Hero_Batrider.Firefly.loop")
    
  end
end
function modifier_batrider_firefly_smash:OnIntervalThink()
  local caster = self:GetCaster()
  local dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin(),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  dummy:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,150))
  dummy:FindAbilityByName("dummy_unit"):SetLevel(1)
  dummy.particle = ParticleManager:CreateParticle("particles/batrider/batrider_firefly.vpcf",PATTACH_CUSTOMORIGIN,self:GetCaster())
  
  table.insert(self.dummies, dummy)

  self.targets = {}
  for k,v in pairs(self.dummies) do
    ParticleManager:SetParticleControl(dummy.particle,0,dummy:GetAbsOrigin())
    local units = FindUnitsInRadius(caster:GetTeam(), v:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,v:GetAbsOrigin(),self.radius)
    for _,unit in pairs(units) do
      if not self.targets[unit] then

        self.targets[unit] = true
        local damageTable = {
          victim = unit,
          attacker = self:GetCaster(),
          damage = 1,--self:GetAbility():GetSpecialValueFor("damage") + RandomInt(0,self:GetAbility():GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self:GetAbility(),
        }
        ApplyDamage(damageTable)

        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_firefly_debuff.vpcf",PATTACH_ABSORIGIN_FOLLOW, caster)
      end
    end
  end
  if not caster:HasModifier("modifier_jump") and not caster:HasModifier("modifier_drop") then
    Timers:CreateTimer(self.fire_linger_duration,function()
      if IsValidEntity(self) then
        self:Destroy()
      end
    end)
  end
end

function modifier_batrider_firefly_smash:OnDestroy()
  if IsServer() then
    self:GetCaster():StopSound("Hero_Batrider.Firefly.loop")
    for k,v in pairs(self.dummies) do
      ParticleManager:DestroyParticle(v.particle,false)
      ParticleManager:ReleaseParticleIndex(v.particle)
      UTIL_Remove(v)
    end
  end
end

function modifier_batrider_firefly_smash:GetEffectName()
  return "particles/units/heroes/hero_batrider/batrider_firefly_ember.vpcf"
end
function modifier_batrider_firefly_smash:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end