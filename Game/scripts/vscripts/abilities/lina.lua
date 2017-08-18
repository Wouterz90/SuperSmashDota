--[[lina - cyclone
dragon slave -- fire platform around her
finger -- Massive strike(phoenix beam)
light strike array -- mid]]

lina_special_top = class({})

function lina_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  return true
end
function lina_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  if caster.jumps > 2 then return end
  caster.jumps = 3
  StoreSpecialKeyValues(self)
  caster:EmitSound("DOTA_Item.Cyclone.Activate")
  local tornado_degrees_to_spin = nil
  local tornado_height =  (self.height /32)
  local tornado_lift_duration = self.duration
  local total_degrees = 1440/32 -- 22.5 720 is 2 full rotations
  local count = 1 -- Count to stop the timer
  local caster_x_origin = caster:GetAbsOrigin().x

  caster:AddNewModifier(caster,ability,"modifier_lina_cyclone",{duration = tornado_lift_duration})

  local particle = ParticleManager:CreateParticle("particles/econ/items/invoker/invoker_ti6/invoker_tornado_child_ti6.vpcf",PATTACH_ABSORIGIN,caster)

  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  Timers:CreateTimer(tornado_lift_duration,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  Timers:CreateTimer(1/32,function()
    -- Idea taken from the spelllibrary, credit goes to Noya and Rook.
    if not tornado_degrees_to_spin and tornado_lift_duration then
      local ideal_degrees_per_second = 720
      local ideal_full_spins = (ideal_degrees_per_second / 360) * tornado_lift_duration
      ideal_full_spins = math.floor(ideal_full_spins + .5)  --Round the number of spins to aim for to the closest integer.
      local degrees_per_second_ending_in_same_forward_vector = (360 * ideal_full_spins) / tornado_lift_duration
      
      tornado_degrees_to_spin = degrees_per_second_ending_in_same_forward_vector * .03
    end
    caster:SetForwardVector(RotatePosition(Vector(0,0,0), QAngle(0, tornado_degrees_to_spin, 0), caster:GetForwardVector()))
    caster:SetAbsOrigin(Vector(caster_x_origin,0,caster:GetAbsOrigin().z))
    --caster:SetStaticVelocity("lina_tornado",tornado_height*30)
    Physics2D:SetStaticVelocity(caster,"lina_tornado",tornado_height)
    --caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,tornado_height))
    if count < tornado_lift_duration*32 then
      
      count = count + 1
      return 1/32
    else
      Physics2D:SetStaticVelocity(caster,"lina_tornado",Vec(0,0))
      return 
    end
  end)
  
end
LinkLuaModifier("modifier_lina_cyclone","abilities/lina.lua",LUA_MODIFIER_MOTION_NONE)
modifier_lina_cyclone = class({})

--[[function modifier_lina_cyclone:DeclareFunctions()
  local funcs = {

  }
  return funcs
end]]
function modifier_lina_cyclone:CheckState()
  local funcs = {
    [MODIFIER_STATE_INVULNERABLE] = true,
  }
  return funcs
end
lina_special_side = class({})

function lina_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_smash_stun",{duration = self:GetCastPoint()})
  self:GetCaster():EmitSound("Ability.LagunaBlade")
  return true
end
function lina_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  StoreSpecialKeyValues(self)
  
  if ability.unit then
    UTIL_Remove(ability.unit)
    ability.unit = nil
  end

  -- Use find units in line to find a unit, check for height
  local units = FindUnitsInLine(caster:GetTeam(),caster:GetAbsOrigin(),caster:GetAbsOrigin()+caster:GetForwardVector() * (self.range-self.radius) ,nil,self.radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,DOTA_UNIT_TARGET_FLAG_NONE)
  -- Create a dummy unit at the end
  ability.unit = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+(caster:GetForwardVector()*self.range),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  ability.unit:SetAbsOrigin(caster:GetAbsOrigin()+(caster:GetForwardVector()*1*self.range)+Vector(0,0,100))
  ability.unit:FindAbilityByName("dummy_unit"):SetLevel(1)
  -- Fire the laguna blade at the dummy
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf",PATTACH_CUSTOMORIGIN,nil)
  ParticleManager:SetParticleControlEnt( particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetOrigin(), true )
  ParticleManager:SetParticleControlEnt( particle, 1, ability.unit, PATTACH_POINT_FOLLOW, nil, ability.unit:GetOrigin(), true )
  -- Clean it
  Timers:CreateTimer(1,function()
    UTIL_Remove(ability.unit)
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)
  -- Deal damage
  for k,v in pairs(units) do
    if math.abs(caster:GetAbsOrigin().z - v:GetAbsOrigin().z) < 200 then
      local damageTable = {
        victim = v,
        attacker = caster,
        damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable)
      caster:EmitSound("Ability.LagunaBladeImpact")
    end
  end
  
end

lina_special_bottom = class({})

function lina_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1.5})

  return true
end
function lina_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local cast_delay = self:GetSpecialValueFor("cast_delay")
  local radius = self:GetSpecialValueFor("radius")

  caster:EmitSound("Ability.PreLightStrikeArray")
  
  local loc = caster:GetAbsOrigin() + caster:GetForwardVector() * radius
  Timers:CreateTimer(cast_delay,function()
    -- Look for highest platform with the location to land the lsa on
    --Replace this with a projectile
    
    local plat
    local z
    for i=#platform,1,-1 do
      if not platform[i].destroyed then
        if loc.x > platform[i]:GetAbsOrigin().x - platform[i].radius and loc.x < platform[i]:GetAbsOrigin().x + platform[i].radius then
          z = platform[i]:GetAbsOrigin().z + platform[i].height
          plat = platform[i]
          break
        end
      end
    end
      
    if plat then
      DestroyPlatform(plat,5)
    end
    
    if not z then z=0 end

    loc = Vector(loc.x,0,z)
    
    local units = FindUnitsInRadius(caster:GetTeam(),loc, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    --units = FilterUnitsBasedOnHeight(units,loc,radius)
    for k,v in pairs(units) do
      caster:EmitSound("Ability.LightStrikeArray")
      if v:GetAbsOrigin().z > loc.z - 50 then
        v:AddNewModifier(caster,self,"modifier_smash_stun",{duration = self:GetSpecialValueFor("duration")})
        local damageTable = {
          victim = v,
          attacker = caster,
          damage = self:GetSpecialValueFor("damage") + RandomInt(0,self:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self
        } 
        ApplyDamage(damageTable)
      end
    end
  


    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf", PATTACH_WORLDORIGIN ,nil)
    ParticleManager:SetParticleControl(particle, 0, loc)
    ParticleManager:SetParticleControl(particle, 1, loc)
    ParticleManager:SetParticleControl(particle, 2, loc)
    ParticleManager:SetParticleControl(particle, 3, loc)
    Timers:CreateTimer(cast_delay,function()
      ParticleManager:DestroyParticle(particle,false)
      ParticleManager:ReleaseParticleIndex(particle)
    end)
  end)
end
--[[
lina_special_bottom = class({})
function lina_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end

function lina_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  
  caster:EmitSound("Hero_Lina.DragonSlave")
    local projectile = {
      --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
      EffectName = "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf",
      --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
      --EeffectName = "",
      vSpawnOrigin = caster:GetAbsOrigin(),
      --vSpawnOrigin = {unit=caster, attach="attach_attack1", offset=Vector(0,0,100)},
      fDistance = 600,--self:GetSpecialValueFor("distance"),
      fStartRadius = 200,
      fEndRadius = 200,
      Source = caster,
      fExpireTime = 1,--self:GetSpecialValueFor("duration"),
      vVelocity = self.mouseVector * 600 ,--self.mouseVector * (self:GetSpecialValueFor("distance")/self:GetSpecialValueFor("duration")), -- RandomVector(1000),
      UnitBehavior = PROJECTILES_NOTHING ,
      bMultipleHits = false,
      bIgnoreSource = true,
      TreeBehavior = PROJECTILES_NOTHING,
      bCutTrees = false,
      bTreeFullCollision = false,
      WallBehavior = PROJECTILES_NOTHING,
      GroundBehavior = PROJECTILES_BOUNCE,
      fGroundOffset = 200,
      nChangeMax = 1,
      bRecreateOnChange = false,
      bZCheck = true,
      bGroundLock = false,
      bProvidesVision = true,
      iVisionRadius = 200,
      iVisionTeamNumber = caster:GetTeam(),
      bFlyingVision = false,
      fVisionTickTime = .1,
      fVisionLingerDuration = 1,
      draw = false,--             draw = {alpha=1, color=Vector(200,0,0)},
      

      UnitTest = function(self, unit) return unit:GetUnitName() ~= "npc_dummy_unit" and unit:GetTeamNumber() ~= caster:GetTeamNumber() and unit:GetTeamNumber() ~= DOTA_TEAM_NEUTRALS end,
      OnUnitHit = function(self, unit) 
        local damageTable = {
          victim = unit,
          attacker = caster,
          damage = ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = ability,
        }
        ApplyDamage(damageTable)
      end,
      OnFinish = function(self,unit)
      end,
    }
    local proj = Projectiles:CreateProjectile(projectile)
    
  
end]]