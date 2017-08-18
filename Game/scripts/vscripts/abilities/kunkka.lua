kunkka_special_side = class({})


function kunkka_special_side:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  EmitSoundOnLocationForAllies(caster:GetAbsOrigin(),"Ability.pre.Torrent",caster)
  StartAnimation(caster, {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_1 , rate=self:GetCastPoint()/0.5 })

  return true
end

function kunkka_special_side:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  StopSoundOn("Ability.pre.Torrent",caster)
  EndAnimation(caster)
end

function kunkka_special_side:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVectorDistance
  local ability = self
  StoreSpecialKeyValues(self)
 
  
  local loc = caster:GetAbsOrigin()+caster:GetForwardVector()*self.radius*(0+(4*math.abs(direction.x)))
  local plat
  local z
  for i=#platform,1,-1 do
    if caster:GetAbsOrigin().z > platform[i]:GetAbsOrigin().z then
      if loc.x > platform[i]:GetAbsOrigin().x - platform[i].radius and loc.x < platform[i]:GetAbsOrigin().x + platform[i].radius then
       
        z = platform[i]:GetAbsOrigin().z + platform[i].height
        plat = platform[i]
        break
      end
    end
  end
  loc = Vector(loc.x,0,z)

  self.dummy = CreateUnitByName("npc_dummy_unit",loc,false,caster,caster:GetOwner(),caster:GetTeamNumber())
  self.dummy:AddNewModifier(self.dummy,nil,"modifier_basic",{})
  self.dummy:SetAbsOrigin(loc)
  self.dummy:FindAbilityByName("dummy_unit"):SetLevel(1)

  local particle_bubbles = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_ABSORIGIN, caster, caster:GetTeam())
  ParticleManager:SetParticleControl(particle_bubbles, 0, self.dummy:GetAbsOrigin())
  ParticleManager:SetParticleControl(particle_bubbles, 1, Vector(radius,0,0))
  Timers:CreateTimer(1/30,function()
    if IsValidEntity(self.dummy) then
      local pos = self.dummy:GetAbsOrigin()
      if pos.z < 100 then
        pos.z = 150
      end
      self.dummy:SetAbsOrigin(pos)
      ParticleManager:SetParticleControl(particle_bubbles, 0, self.dummy:GetAbsOrigin())
      return 1/30
    else
      ParticleManager:DestroyParticle(particle_bubbles,false)
      ParticleManager:ReleaseParticleIndex(particle_bubbles)
    end
  end)
  
  Timers:CreateTimer(self.cast_delay,function()
    
    caster:EmitSound("Ability.Torrent")
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, self.dummy:GetAbsOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(self.radius,0,0))
    

    local units = FindUnitsInRadius(caster:GetTeam(), self.dummy:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    units = FilterUnitsBasedOnHeight(units,self.dummy:GetAbsOrigin()+Vector(0,0,self.torrent_height/2),self.torrent_height)
    for _,unit in pairs(units) do
      unit:AddNewModifier(caster,self,"modifier_smash_stun",{duration = self.stun_duration})
      local damageTable = {
        victim = unit,
        attacker = caster,
        damage = self.damage + RandomInt(0,self.damage_offset),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
      }
      local casterloc = caster:GetAbsOrigin()
      caster:SetAbsOrigin(self.dummy:GetAbsOrigin()+Vector(0,0,-50))
      ApplyDamage(damageTable)
      caster:SetAbsOrigin(casterloc)
    end
    UTIL_Remove(self.dummy)
    Timers:CreateTimer(1,function()
      
      ParticleManager:DestroyParticle(particle,false)
      ParticleManager:ReleaseParticleIndex(particle)
    end)
  end)
end

kunkka_special_bottom = class({})

function kunkka_special_bottom:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  local caster = self:GetCaster()
  caster:EmitSound("Ability.Ghostship.bell")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_2, rate=1})
  self.direction = caster:GetForwardVector()
  return true
end

function kunkka_special_bottom:OnAbilityPhaseInterrupted()
  -- Cancel animations!
  local caster = self:GetCaster()
  caster:StopSound("Ability.Ghostship.bell")
  EndAnimation(caster)
end

function kunkka_special_bottom:OnSpellStart() 
  local caster = self:GetCaster()
  local direction = self.mouseVectorDistance
  local ability = self
  StoreSpecialKeyValues(self)
  local projectileBoat = 
  {
    Ability = self,
    EffectName = "particles/kunkka/kunkka_ghost_ship.vpcf",
    vSpawnOrigin = caster:GetAbsOrigin() - (ability.direction * ability.boat_spawn_distance),
    fDistance =  ability.projectile_range,
    fStartRadius = self.radius,
    fEndRadius = self.radius,
    fExpireTime = GameRules:GetGameTime() + 3,
    Source = caster,
    bHasFrontalCone = false,
    bReplaceExisting = false,
    bProvidesVision = false,
    vVelocity = ability.direction * ability.projectile_speed,
  }
  ProjectileManager:CreateLinearProjectile(projectileBoat)
  
  caster:EmitSound("Ability.Ghostship")
  local projectile = {
    --EffectName = "particles/test_particle/ranged_tower_good.vpcf",
    --EffectName = "particles/kunkka/kunkka_ghost_ship.vpcf",
    --EffectName = "particles/units/heroes/hero_puck/puck_illusory_orb.vpcf",
    --EeffectName = "",
    --vSpawnOrigin = caster:GetAbsOrigin(),

    vSpawnOrigin = caster:GetAbsOrigin() - (ability.direction * ability.boat_spawn_distance),
    fDistance =   ability.projectile_range,
    fStartRadius = ability.projectile_radius,
    fEndRadius =  ability.projectile_radius,
    Source = caster,
    --fExpireTime = -1,
    vVelocity = ability.direction * ability.projectile_speed, -- RandomVector(1000),
    UnitBehavior = PROJECTILES_NOTHING,
    bMultipleHits = false,
    bIgnoreSource = true,
    TreeBehavior = PROJECTILES_NOTHING,
    bCutTrees = false,
    bTreeFullCollision = false,
    WallBehavior = PROJECTILES_NOTHING  ,
    GroundBehavior = PROJECTILES_NOTHING  ,
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
      caster:EmitSound("Ability.Ghostship.crash")
      local units = FindUnitsInRadius(caster:GetTeam(), pos, nil, ability.projectile_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
      units = FilterUnitsBasedOnHeight(units,pos,ability.projectile_radius)
      for k,v in pairs(units) do

        local damageTable = {
          victim = v,
          attacker = caster,
          damage = ability.damage + RandomInt(0,ability.damage_offset),
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

kunkka_special_top = class({})

function kunkka_special_top:OnAbilityPhaseStart()
  if not self:GetCaster():CanCast(self) then return false end
  if not self:IsCooldownReady() then return false end
  if self:GetCaster().jumps > 3 then return end
  local caster = self:GetCaster()
  StoreSpecialKeyValues(self)
  caster:EmitSound("Ability.XMarksTheSpot.Target")
  StartAnimation(self:GetCaster(), {duration=self:GetCastPoint(), activity=ACT_DOTA_CAST_ABILITY_3, rate=1})
  return true
end

function kunkka_special_top:OnAbilityPhaseInterrupted()
  local caster = self:GetCaster()
  caster:StopSound("Ability.XMarksTheSpot.Target")
  EndAnimation(caster)
end

function kunkka_special_top:OnSpellStart()
  local caster = self:GetCaster()
  local radius = self:GetSpecialValueFor("radius")
  StoreSpecialKeyValues(self)
  caster.jumps = 3
  

  caster:SetAbsOrigin(caster:GetAbsOrigin()+self.mouseVector*self.range)
  Timers:CreateTimer(1/10,function()

    self.particle = ParticleManager:CreateParticle("particles/kunkka/kunkka_spell_x_spot.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(self.particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.particle, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    
    caster:AddNewModifier(caster,self,"modifier_no_gravity",{duration = self.x_time})
    Timers:CreateTimer(self.x_time,function()
      ParticleManager:DestroyParticle(self.particle,false)
      ParticleManager:ReleaseParticleIndex(self.particle)
    end)
  end)
end

  