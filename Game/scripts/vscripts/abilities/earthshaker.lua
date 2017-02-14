earthshaker_special_side = class({})

function earthshaker_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end 
  return true
end
function earthshaker_special_side:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local block_width = 90
  local block_height = 100
  local range = ability:GetSpecialValueFor("range")
  local radius = ability:GetSpecialValueFor("radius")
  local duration = ability:GetSpecialValueFor("duration")

  -- Sound
  caster:EmitSound("Hero_EarthShaker.Fissure")

  -- Set the direction either left or right
  -- a rotated platform hasnt been fixed yet
  local direction
  if self.mouseVector.x < 0 then
    direction = Vector(-1,0,0)
  else
    direction = Vector(1,0,0)
  end



  self.blocks = {}
  -- Create the platform for the game to walk on
  local fissure = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  -- fissure location
  fissure:SetAbsOrigin(caster:GetAbsOrigin()+(direction*range*0.5)+Vector(0,0,block_height+200))
  fissure.height = -100
  fissure.radius = range*0.5
  fissure.unitsOnPlatform= {}  
  fissure.owner = caster
  -- fissure rotation
  --[[if VectorToAngles(self.mouseVector).x >= 180 then
    fissure.rotation = (VectorToAngles(self.mouseVector).x) - 360
  else
    fissure.rotation = VectorToAngles(self.mouseVector).x
  end
  fissure:SetAngles(fissure.rotation,0,0)
  --print(fissure.rotation)]]
  table.insert(platform, #platform + 1, fissure)
  
  -- Create the visual stuff
  for i=0,range/block_width do
    local block = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/items/earthshaker/totem_dragon_wall/fissure_body.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    block:SetAbsOrigin(caster:GetAbsOrigin()+direction*block_width*i-Vector(0,0,block_height-200))
    --block:SetForwardVector(self.mouseVector)
    self.blocks[i] = block
  end

  Timers:CreateTimer(duration,function()
    -- Remove platform for the game
    for k,v in pairs(platform) do
      if v.owner and v.owner == caster then
        platform[k] = nil
        break
      end
    end
    for k,v in pairs(self.blocks) do
      --Remove visual stuff
      UTIL_Remove(v)
    end
  end)
end

earthshaker_special_top = class({})

function earthshaker_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 2 then return false end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint() + self:GetSpecialValueFor("duration"), activity=ACT_DOTA_OVERRIDE_ABILITY_2, rate=1})
  return true
end
function earthshaker_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  caster.jumps = 3 

  
  -- Make sure the caster jumps
  caster:RemoveModifierByName("modifier_jump")
  caster:AddNewModifier(caster,self,"modifier_earthshaker_jump",{duration = ability:GetSpecialValueFor("duration")})
  -- Start this to check if the target is on a platform
  Timers:CreateTimer(0.25,function()
    caster:AddNewModifier(caster,self,"modifier_eartshaker_slam",{})
  end)
end

LinkLuaModifier("modifier_earthshaker_jump","abilities/earthshaker.lua",LUA_MODIFIER_MOTION_NONE)
modifier_earthshaker_jump = class({})

function modifier_earthshaker_jump:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_earthshaker_jump:OnIntervalThink()
  -- handle lowest platform
  if self:GetParent():isUnderPlatform() and self:GetCaster():HasModifier("modifier_basic") then return end
  --
  local vec = self:GetParent():GetAbsOrigin()
  local z = vec[3] + Laws.flJumpSpeed
  vec = Vector(vec[1],vec[2],z)
  self:GetParent():SetAbsOrigin(vec)
end

function modifier_earthshaker_jump:OnDestroy()
  if IsServer() then
    -- Make sure the animation stays the same and not his drop animation
    StartAnimation(self:GetParent(), {duration=1, activity=ACT_DOTA_CAST_ABILITY_2, rate=4 })
    FreezeAnimation(self:GetParent(),5)
    self:GetParent():AddNewModifier(self:GetParent(),nil,"modifier_drop",{})
  end
end

LinkLuaModifier("modifier_eartshaker_slam","abilities/earthshaker.lua",LUA_MODIFIER_MOTION_NONE)
modifier_eartshaker_slam = class({})

function modifier_eartshaker_slam:OnCreated()
  if IsServer() then
    self:StartIntervalThink(1/32)
  end
end

function modifier_eartshaker_slam:OnIntervalThink()
  --Check when the units hits the platform
  if self:GetParent():isOnPlatform() then

    -- Sound
    self:GetParent():EmitSound("Hero_EarthShaker.Totem")

    -- Cleaning up animations, showing particles
    self:GetParent():RemoveModifierByName("modifier_animation")
    UnfreezeAnimation(self:GetParent())
    StartAnimation(self:GetParent(), {duration=1, activity=ACT_DOTA_CAST_ABILITY_2, rate=4 })
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_totem_leap_impact.vpcf",PATTACH_ABSORIGIN,self:GetParent())
    ParticleManager:SetParticleControl(particle, 0, self:GetParent():GetAbsOrigin())
    Timers:CreateTimer(1,function()
      ParticleManager:DestroyParticle(particle,false)
      ParticleManager:ReleaseParticleIndex(particle)
    end)

    local caster = self:GetParent()
    local ability = self:GetAbility()
    local radius = ability:GetSpecialValueFor("radius")
    -- Getting the units and damaging them
    local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
    for k,v in pairs(units) do
      local damage = ability:GetSpecialValueFor("damage") +  RandomInt(0,ability:GetSpecialValueFor("damage_offset"))
      local damageTable = {
        victim = v,
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = ability,
      }
      ApplyDamage(damageTable) -- Push
      v:AddNewModifier(caster,ability,"modifier_smash_stun",{duration = ability:GetSpecialValueFor("stun_duration")})
    end

    -- Removing this modifier
    self:Destroy()
  end
end



earthshaker_special_bottom = class({})

function earthshaker_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if not self:GetCaster():isOnPlatform() then return false end 
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_4, rate=0.2})
  self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_smash_stun",{duration = self:GetCastPoint()})
  return true
end
function earthshaker_special_bottom:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  -- Show the particle
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf",PATTACH_ABSORIGIN,caster)
  ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  Timers:CreateTimer(1,function()
    ParticleManager:DestroyParticle(particle,false)
    ParticleManager:ReleaseParticleIndex(particle)
  end)

  -- Store the platform I am on
  local my_platform
  for k,v in pairs(platform) do
    if v.unitsOnPlatform[caster] then
      my_platform = v
      break
    end
  end

  -- Shaking the platform
  local time = 0
  local angles = my_platform:GetAngles()
  Timers:CreateTimer(1/32,function()
    if time < 16 then
      time = time +1
      my_platform:SetAngles(angles[1]+RandomInt(-5,5),angles[2],angles[3])
      return 1/32
    else
      my_platform:SetAngles(angles[1],angles[2],angles[3])
      return
    end
  end)

  -- Damaging all units on the platform (units are stored in per platform in platforms.lua)  
  for k,v in pairs(my_platform.unitsOnPlatform) do
    if not IsValidEntity(k) then 
      k = nil
    else
      if caster:GetTeamNumber() ~= k:GetTeamNumber() then
        k:AddNewModifier(caster,self,"modifier_smash_stun",{duration = self:GetSpecialValueFor("duration")})
        local damage = self:GetSpecialValueFor("damage") +  RandomInt(0,self:GetSpecialValueFor("damage_offset"))
        local damageTable = {
          victim = k,
          attacker = caster,
          damage = damage,
          damage_type = DAMAGE_TYPE_MAGICAL,
          ability = self,
        }
        ApplyDamage(damageTable) -- Push
      end
    end
  end
end

earthshaker_special_mid = class({})

function earthshaker_special_mid:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_ATTACK, translate="enchant_totem", rate=1})
  return true
end
function earthshaker_special_mid:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local radius = ability:GetSpecialValueFor("radius")
  
  -- Getting all the units in front of the hero and damaging them
  local units = FindUnitsInLine(caster:GetTeamNumber(),caster:GetAbsOrigin(),caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),nil,radius,DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_HERO,FIND_CLOSEST)
  units = FilterUnitsBasedOnHeight(units,caster:GetAbsOrigin() + (caster:GetForwardVector() * radius),radius)
  for k,v in pairs(units) do
    local damage = self:GetSpecialValueFor("damage") +  RandomInt(0,self:GetSpecialValueFor("damage_offset"))
    local damageTable = {
      victim = v,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_MAGICAL,
      ability = self,
    }
    ApplyDamage(damageTable) -- Push
  end
end