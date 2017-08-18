pudge_special_side = class({})
function pudge_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  local ability = self
  
  
  Timers:CreateTimer(self:GetCastPoint()/2,function()
    caster:EmitSound("Hero_Pudge.AttackHookExtend")
    StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_OVERRIDE_ABILITY_1  , rate=self:GetCastPoint()/0.3 })
  end)
  return true
end

function pudge_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Pudge.AttackHookExtend")
  EndAnimation(caster)
end


function pudge_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)
  self.target = nil    

  local hHook = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
  if hHook ~= nil then
    hHook:AddEffects( EF_NODRAW )
  end

  --self.mouseVector = Vector(0,0,1)
  local vKillswitch = Vector(((self.range/self.projectile_speed )*2),0,0)

  local targetLocation = caster:GetAbsOrigin() + ability.mouseVector * ability.range

  local projectileTable = 
    { 
      vDirection = ability.mouseVector,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = ability.range,
      sEffectName = "",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_DESTROY,
      UnitTest = function(projectile, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
        
        ability.target = unit
  
        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = 2})
        caster:EmitSound("Hero_Pudge.AttackHookImpact")
  
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
        ability:RetractHook(unit:GetAbsOrigin(),unit)
      end,
      OnFinish = function(projectile)
        if not ability.target then
          ability:RetractHook(projectile.location)
        end
      end,
      
    }
  Physics2D:CreateLinearProjectile(projectileTable)

  self.particle = ParticleManager:CreateParticle( "particles/pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
  ParticleManager:SetParticleAlwaysSimulate( self.particle)
  ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self:GetCaster():GetAbsOrigin(), true )
  ParticleManager:SetParticleControl( self.particle, 1, targetLocation) 
  ParticleManager:SetParticleControl( self.particle, 2, Vector( self.projectile_speed, self.range, self.radius ) )
  ParticleManager:SetParticleControl( self.particle, 3, vKillswitch )
  ParticleManager:SetParticleControl( self.particle, 4, Vector( 1, 0, 0 ) )
  ParticleManager:SetParticleControl( self.particle, 5, Vector( 0, 0, 0 ) )
  ParticleManager:SetParticleControlEnt( self.particle, 7, self:GetCaster(), PATTACH_CUSTOMORIGIN, nil, self:GetCaster():GetAbsOrigin(), true )

end

function pudge_special_side:RetractHook(vLocation,hTarget)
  local ability = self
  local caster = self:GetCaster()



  local projectileTable = 
    { 
      vDirection = (caster:GetAbsOrigin()-vLocation):Normalized(),
      vSpawnOrigin = vLocation,
      hCaster = caster,
      flSpeed = ability.projectile_speed,
      flRadius = ability.radius,
      flMaxDistance = (caster:GetAbsOrigin()-vLocation):Length() - 100,
      sEffectName = "",
      PlatformBehavior = PROJECTILES_NOTHING,
      OnPlatformHit = function(projectile,unit)
      end,
      UnitBehavior = PROJECTILES_NOTHING,
      UnitTest = function(projectile, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
        
        ability.target = unit
  
        unit:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = 2})
        caster:EmitSound("Hero_Pudge.AttackHookImpact")
  
        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, unit)
        ParticleManager:SetParticleControlEnt( nFXIndex, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
        Timers:CreateTimer(0.5,function()
          ParticleManager:DestroyParticle(nFXIndex,false)
          ParticleManager:ReleaseParticleIndex( nFXIndex )
        end)
        ability:RetractHook(unit:GetAbsOrigin(),unit)
      end,
      OnFinish = function(projectile)
     -- Destory particles etc
      if hTarget then
        hTarget:SetAbsOrigin(projectile.location)
        hTarget:RemoveModifierByNameAndCaster("modifier_smash_stun",caster)  
      end
      local hHook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
      if hHook ~= nil then
        hHook:RemoveEffects( EF_NODRAW )                
      end
      ParticleManager:DestroyParticle( ability.particle, true )     
      StopSoundOn( "Hero_Pudge.AttackHookRetract", caster)
      StopSoundOn( "Hero_Pudge.AttackHookExtend", caster)
      caster:EmitSound( "Hero_Pudge.AttackHookRetractStop")    
    end,
    OnProjectileThink = function(projectile)
      if hTarget then
        hTarget:SetAbsOrigin(projectile.location)
      end
    end,
      
    }
  Physics2D:CreateLinearProjectile(projectileTable)

  if not hTarget  then 
    ParticleManager:SetParticleControlEnt( ability.particle, 1, ability:GetCaster(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", ability:GetCaster():GetAbsOrigin(), true);
  else
    ParticleManager:SetParticleControlEnt( ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
    ParticleManager:SetParticleControl( ability.particle, 4, Vector( 0, 0, 0 ) )
    ParticleManager:SetParticleControl( ability.particle, 5, Vector( 1, 0, 0 ) )   
  end
end

LinkLuaModifier("modifier_pudge_dismember_smash","abilities/pudge.lua",LUA_MODIFIER_MOTION_NONE)

pudge_special_bottom_release = class({})

function pudge_special_bottom_release:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_pudge_dismember_smash")
  self:GetCaster():Interrupt()
  EndAnimation(self:GetCaster())
end

pudge_special_bottom = class({})

function pudge_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  local ability = self
  self.Push = 0
  StoreSpecialKeyValues(self)
  
  caster:EmitSound("Hero_Pudge.Dismember")
  StartAnimation(caster, {duration=self.duration, activity=ACT_DOTA_CHANNEL_ABILITY_4  , rate=self:GetCastPoint()/0.3 })
  return true
end

function pudge_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Hero_Pudge.Dismember")
  
end

function pudge_special_bottom:GetChannelTime()
  return self.duration
end

function pudge_special_bottom:OnChannelFinish(bInterrupted)
  if self.target then
    self.target:RemoveModifierByName("modifier_pudge_dismember_smash")
  end
  EndAnimation( self:GetCaster())
  --self:GetCaster():InterruptChannel()
end
function pudge_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local ability = self
  local direction = caster:GetForwardVector()
  StoreSpecialKeyValues(self)

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_CLOSEST, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),self.radius)

  for _,unit in pairs(units) do
    if (direction.x == 1 and (unit:GetAbsOrigin().x-caster:GetAbsOrigin().x) > 0) or (direction.x == -1 and (unit:GetAbsOrigin().x-caster:GetAbsOrigin().x) <  0) then 
      caster:RemoveModifierByName("modifier_left")
      caster:RemoveModifierByName("modifier_right")
      caster:RemoveModifierByName("modifier_jump")
      caster:AddNewModifier(caster,self,"modifier_smash_root",{duration = self.duration})
      unit:AddNewModifier(caster,self,"modifier_pudge_dismember_smash",{duration = self.duration})
      self.target = unit
      return
    end
  end
  caster:Interrupt()
end

modifier_pudge_dismember_smash = class({})

function modifier_pudge_dismember_smash:OnCreated()
  if IsServer() then
    self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_smash_stun",{})
    self:StartIntervalThink(0.4)
    local damageTable = {
      victim = self:GetParent(),
      attacker = self:GetCaster(),
      damage = self:GetAbility():GetSpecialValueFor("damage") + RandomInt(0,self:GetAbility():GetSpecialValueFor("damage_offset")),
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self:GetAbility(),
    }
  end
end

function modifier_pudge_dismember_smash:OnRemoved(keys)
  if IsServer() then
    if self:GetRemainingTime() <= 0 then
      self:GetAbility().Push = self:GetAbility().final_push
      local damageTable = {
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetAbility():GetSpecialValueFor("damage") + RandomInt(0,self:GetAbility():GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility(),
      }
      ApplyDamage(damageTable)
      local heal = ApplyDamage(damageTable)
      self:GetCaster():Heal(heal,self:GetCaster())
    end

    self:GetParent():RemoveModifierByNameAndCaster("modifier_smash_stun",self:GetCaster())
  end
end

function modifier_pudge_dismember_smash:OnIntervalThink()
  
  ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_dismember.vpcf", PATTACH_ABSORIGIN  , self:GetParent())
  local damageTable = {
    victim = self:GetParent(),
    attacker = self:GetCaster(),
    damage = self:GetAbility():GetSpecialValueFor("damage") + RandomInt(0,self:GetAbility():GetSpecialValueFor("damage_offset")),
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = self:GetAbility(),
  }
  local heal = ApplyDamage(damageTable)
  self:GetCaster():Heal(heal,self:GetCaster())
end

LinkLuaModifier("modifier_pudge_rot_smash","abilities/pudge.lua",LUA_MODIFIER_MOTION_NONE)
pudge_special_top = class({})

function pudge_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 3 then return end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint()*1, activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  return true
end

function pudge_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function pudge_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  StoreSpecialKeyValues(self)
  
  caster.jumps = 3
  
  caster:AddNewModifier(caster,self,"modifier_pudge_rot_smash",{ duration = self.duration})
end

modifier_pudge_rot_smash = class({})

function modifier_pudge_rot_smash:OnCreated()
  if IsServer() then
    self:GetCaster():EmitSound("Hero_Pudge.Rot")
    self:StartIntervalThink(FrameTime())
    self.duration = self:GetRemainingTime()
    self:GetCaster():SetAbsOrigin(self:GetCaster():GetAbsOrigin()+Vector(0,0,self:GetAbility().jump_speed))
    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self:GetAbility().radius, 1, self:GetAbility().radius))
    self:AddParticle(nFXIndex, false, false, -1, false, false)

  end
end
function modifier_pudge_rot_smash:OnIntervalThink()
  local caster = self:GetCaster()
  local ability = self:GetAbility()
  --print(ability.jump_speed)
  --caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,ability.jump_speed))
  local pct_duration = (self:GetRemainingTime()/self.duration)
  --self:GetCaster():AddPhysicsVelocity(Vector(0,0,120*pct_duration))
  Physics2D:AddPhysicsVelocity(self:GetParent(),Vec(0,2*pct_duration))

  local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin(),ability.radius)

  for k,v in pairs(units) do
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = (ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")))/5,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = ability
    } 
    ApplyDamage(damageTable)
  end
  local damageTable = {
      victim = caster,
      attacker = caster,
      damage = (ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")))/20,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = ability
    } 
    ApplyDamage(damageTable) 
end
function modifier_pudge_rot_smash:OnDestroy()
  if IsServer() then
    self:GetCaster():StopSound("Hero_Pudge.Rot")
  end
end

function modifier_pudge_rot_smash:GetEffectName()
  return "particles/units/heroes/hero_pudge/pudge_rot.vpcf"
end


pudge_special_top_release = class({})

function pudge_special_top_release:OnSpellStart()
  self:GetCaster():RemoveModifierByName("modifier_pudge_rot_smash")
end
