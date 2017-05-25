zuus_special_top = class({})
function zuus_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_4, rate=1})
  if caster.jumps > 2 then return false end
  return true
end

function zuus_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius")
  local ability = self
  caster.jumps = 3

  
  local cloud_duration = self:GetSpecialValueFor("cloud_duration")

  --Create cloud
  local cloud = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+Vector(0,0,range),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  cloud:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,range))
  cloud:FindAbilityByName("dummy_unit"):SetLevel(1)
  cloud:SetModel("models/heroes/zeus/zeus_sigil.vmdl")
  cloud:SetAngles(0,90,0)
  -- Jump
  local particle_one = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
  caster:SetAbsOrigin(caster:GetAbsOrigin()+Vector(0,0,range))
  local particle_two = ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)
  -- Release particles
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle_one,false)
    ParticleManager:ReleaseParticleIndex(particle_one)
    ParticleManager:DestroyParticle(particle_two,false)
    ParticleManager:ReleaseParticleIndex(particle_two)
  end)

  --Remove cloud and shock
  Timers:CreateTimer(cloud_duration,function()
    if IsValidEntity(cloud) then

      local units = FindUnitsInRadius(caster:GetTeam(), cloud:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      for k,v in pairs(units) do
        if v:GetAbsOrigin().z < cloud:GetAbsOrigin().z then
          -- Particle
          local particleThunder = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_ABSORIGIN, v)
          ParticleManager:SetParticleControl(particleThunder,0, cloud:GetAbsOrigin())
          ParticleManager:SetParticleControl(particleThunder,1, v:GetAbsOrigin())
          caster:EmitSound("Hero_Zuus.ArcLightning.Cast")
          Timers:CreateTimer(1,function()
            ParticleManager:DestroyParticle(particleThunder,false)
            ParticleManager:ReleaseParticleIndex(particleThunder)
          end)
          
          -- Damage
          local damageTable = {
            victim = v,
            attacker = caster,
            damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
          }
          local oldloc = caster:GetAbsOrigin()
          caster:SetAbsOrigin(cloud:GetAbsOrigin())
          ApplyDamage(damageTable)
          caster:SetAbsOrigin(oldloc)
        end
      end
      
      UTIL_Remove(cloud)
    end
  end)  
end

zuus_special_side = class({})
function zuus_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function zuus_special_side:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius")
  local vector = self.mouseVector
  local ability = self
  local direction
  if caster:GetForwardVector().x > 0 then
    direction = Vector(1,0,0)
  else
    direction = Vector(-1,0,0)
  end
  ability.targets = {}
  local bounceCenter
  --  print(radius)
  

  --Create a unit and drop it till it hits a platform
  local dummy = CreateUnitByName("npc_dummy_unit",caster:GetAbsOrigin()+Vector(0,0,range),false,caster,caster:GetOwner(),caster:GetTeamNumber())
  dummy:SetAbsOrigin(caster:GetAbsOrigin()+direction*50)
  dummy:FindAbilityByName("dummy_unit"):SetLevel(1)
  dummy:AddNewModifier(caster,self,"modifier_zuus_arc_dummy",{})


  

  Timers:CreateTimer(1/32,function()
    if not dummy:isOnPlatform() then
      
      if dummy:GetAbsOrigin().z < 300 then return end
      dummy:SetAbsOrigin(dummy:GetAbsOrigin()+Vector(direction.x*(radius/8),0,-radius/8))
      return 1/32
    else
      
      local bounceCenter = dummy:GetAbsOrigin()+direction*radius+Vector(0,0,-16 )

      -- Make the unit bounce on a platform
      local halfarcTable = {
        Vector(-8/8,0,0) * radius,
        Vector(-7/8,0,1/16) * radius,
        Vector(-6/8,0,2/16) * radius,
        Vector(-5/8,0,3/16) * radius,
        Vector(-4/8,0,4/16) * radius,
        Vector(-3/8,0,5/16) * radius,
        Vector(-2/8,0,6/16) * radius,
        Vector(-1/8,0,7/16) * radius,
        Vector(0/8,0,8/16) * radius,
        Vector(1/8,0,7/16) * radius,
        Vector(2/8,0,6/16) * radius,
        Vector(3/8,0,5/16) * radius,
        Vector(4/8,0,4/16) * radius,
        Vector(5/8,0,3/16) * radius,
        Vector(6/8,0,2/16) * radius,
        Vector(7/8,0,1/16) * radius,
      }

      --Invert the x values if direction is negative
      if direction.x < 0 then
        for k,v in pairs (halfarcTable) do
          halfarcTable[k] = Vector(-1*v.x,v.y,v.z)
        end
      end
      caster:EmitSound("Hero_Disruptor.ThunderStrike.Target")
      local bouncecontroller = 0
      Timers:CreateTimer(1/32,function()
        -- Check for new targets
        local units = FindUnitsInRadius(caster:GetTeam(), dummy:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
        units = FilterUnitsBasedOnHeight(units,dummy:GetAbsOrigin(),radius)
        for k,v in pairs (units) do
          if not self.targets[v] then
            self.targets[v] = true
            local damageTable = {
              victim = v,
              attacker = caster,
              damage =  ability:GetSpecialValueFor("damage") + RandomInt(0,ability:GetSpecialValueFor("damage_offset")),
              damage_type = DAMAGE_TYPE_MAGICAL,
              ability = ability,
            }
            ApplyDamage(damageTable)
            UTIL_Remove(dummy)
            return
          end
        end
        bouncecontroller = bouncecontroller +1
        if bouncecontroller > 16 then
          -- Remove if no longer bouncing on a platform
          if not dummy:isOnPlatform() then
            UTIL_Remove(dummy)
            --ParticleManager:DestroyParticle(particle,true)
            --ParticleManager:ReleaseParticleIndex(particle)
            return
          end
          bouncecontroller = 1
          bounceCenter = bounceCenter + direction * (radius*2)
          -- Bouncing sound
          caster:EmitSound("Hero_Disruptor.ThunderStrike.Target") 
        end
        dummy:SetAbsOrigin(bounceCenter+halfarcTable[bouncecontroller])
        return 1/32
      end)
    end
  end)
end

LinkLuaModifier("modifier_zuus_arc_dummy","abilities/zuus.lua",LUA_MODIFIER_MOTION_NONE)
modifier_zuus_arc_dummy = class({})


function modifier_zuus_arc_dummy:GetEffectName()
  return "particles/zuus/zuus_bouncing_arc.vpcf"
end
function modifier_zuus_arc_dummy:GetEffectAttachType()
  return PATTACH_ABSORIGIN
end

zuus_special_bottom = class({})

function zuus_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  return true
end

function zuus_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  EndAnimation(caster)
end

function zuus_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius")
  local vector = self.mouseVector
  local ability = self
  local direction
   if caster:GetForwardVector().x > 0 then
    direction = Vector(1,0,0)
  else
    direction = Vector(-1,0,0)
  end

  local loc = caster:GetAbsOrigin() + direction * range
  --caster:EmitSound("Ability.LightStrikeArray")

  -- Look for highest platform with the location to land the spell on 
  local plat
  local z
  for i=#platform,1,-1 do
    if loc.x > platform[i]:GetAbsOrigin().x - platform[i].radius and loc.x < platform[i]:GetAbsOrigin().x + platform[i].radius then
      z = platform[i]:GetAbsOrigin().z + platform[i].height
      plat = platform[i]
      break
    end
  end
    
  if plat then
    DestroyPlatform(plat,10)
  end

  if not z then z=0 end

  loc = Vector(loc.x,0,z)

  caster:EmitSound("Hero_Zuus.LightningBolt")
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
    
  ParticleManager:SetParticleControl(particle, 0, loc)
  ParticleManager:SetParticleControl(particle, 1, Vector(loc.x,loc.y,2500))
  ParticleManager:SetParticleControl(particle, 2, loc)

  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  local units = FindUnitsInRadius(caster:GetTeam(),loc, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
  --units = FilterUnitsBasedOnHeight(units,loc,radius) -- Not using this, we check if the unit is higher than the location
  for k,v in pairs(units) do
    if v:GetAbsOrigin().z >= loc.z - 50 then
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
end

--[[zuus_special_bottom = class({})

function zuus_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1, rate=1})
  caster:EmitSound("Hero_Zuus.GodsWrath.PreCast")
  return true
end

function zuus_special_bottom:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Hero_Zuus.GodsWrath.PreCast")
  EndAnimation(caster)
end

function zuus_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local range = self:GetSpecialValueFor("range")
  local radius = self:GetSpecialValueFor("radius")
  local vector = self.mouseVector
  local ability = self
  
  caster:EmitSound("Hero_Zuus.GodsWrath")
  -- Get every hero
  
  for i=0, 3 do
    local hero = PlayerResource:GetSelectedHeroEntity(i)

    if hero and hero ~= caster then  

      local loc = hero:GetAbsOrigin()
      --caster:EmitSound("Ability.LightStrikeArray")

      -- Look for highest platform with the location to land the spell on 
      local plat
      local z
      for i=#platform,1,-1 do
        if loc.x > platform[i]:GetAbsOrigin().x - platform[i].radius and loc.x < platform[i]:GetAbsOrigin().x + platform[i].radius then
          z = platform[i]:GetAbsOrigin().z + platform[i].height
          plat = platform[i]
          break
        end
      end
        
      if plat then
        DestroyPlatform(plat,10)
      end
        
      if not z then z=0 end

      loc = Vector(loc.x,0,z)

      local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, caster)
        
      ParticleManager:SetParticleControl(particle, 0, loc)
      ParticleManager:SetParticleControl(particle, 1, Vector(loc.x,loc.y,2500))
      ParticleManager:SetParticleControl(particle, 2, loc)

      Timers:CreateTimer(1,function()
        ParticleManager:DestroyParticle(particle,false)
        ParticleManager:ReleaseParticleIndex(particle)
      end)

      local units = FindUnitsInRadius(caster:GetTeam(),loc, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      --units = FilterUnitsBasedOnHeight(units,loc,radius) -- Not using this, we check if the unit is higher than the location
      for k,v in pairs(units) do
        if v:GetAbsOrigin().z >= loc.z - 50 then
          caster:EmitSound("Hero_Zuus.GodsWrath.Target")
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
    end
  end
end]]