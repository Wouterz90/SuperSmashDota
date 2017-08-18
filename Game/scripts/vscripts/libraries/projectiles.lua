-- Based on BMD's projectile libary, working with his physics library
PROJECTILES_THINK = FrameTime()

--[[PROJECTILES_NOTHING = nil
PROJECTILES_DESTROY = 1
PROJECTILES_BOUNCE = 2
PROJECTILES_FOLLOW = 3]]

if Projectiles == nil then
  print ( '[PROJECTILES] creating Projectiles' )
  Projectiles = {}
  Projectiles.__index = Projectiles
end

function Projectiles:start()
  Projectiles = self

  if self.thinkEnt == nil then
    self.timers = {}
    self.thinkEnt = SpawnEntityFromTableSynchronous("info_target", {targetname="projectiles_lua_thinker"})
    self.thinkEnt:SetThink("Think", self, "projectiles", PROJECTILES_THINK)
  end
end

function Projectiles:Think()
  if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
    return
  end

   -- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
  local now = GameRules:GetGameTime()
  if Projectiles.t0 == nil then
    Projectiles.t0 = now
  end

  local dt = now - Projectiles.t0
  Projectiles.t0 = now

  if dt > 0 then
    -- Process timers
    for k,v in pairs(Projectiles.timers) do
      local bUseGameTime = true
      -- Check if the timer has finished
        
      -- Run the callback
      local status, nextCall = pcall(v.callback, Projectiles, v)

      -- Make sure it worked
      if status then
        -- Check if it needs to loop
        if nextCall then
          -- Change it's end time
          v.endTime = nextCall
        else
          Projectiles.timers[k] = nil
        end
      else
        Projectiles.timers[k] = nil
        print('[PROJECTILES] Timer error:' .. nextCall)
      end
    end  
  end

  return PROJECTILES_THINK
end

function Projectiles:CreateTimer(name, args)
  if not args.endTime or not args.callback then
    print("Invalid timer created: "..name)
    return
  end

  Projectiles.timers[name] = args
end

function Projectiles:RemoveTimer(name)
  Projectiles.timers[name] = nil
end

function Projectiles:OnGroundHit(unit,keys)
  local normal = keys.normal
  local multiplier = keys.multiplier or 1 
  

  local newBounceVelocity = unit:GetStaticVelocity()
  if newBounceVelocity:Dot(normal) >= 0 then
    return
  end
  newBounceVelocity = (((-2 * newBounceVelocity:Dot(normal) * normal) + newBounceVelocity) * multiplier * 30)

  local newFollowVelocity = unit:GetStaticVelocity()
  if newFollowVelocity:Dot(normal) >= 0 then
    return
  end

  if keys.leg1 then -- If round then go through instead of following
    local direction = (keys.leg1-keys.leg2):Normalized()
    newFollowVelocity = direction*(unit:GetStaticVelocity()*30)
  else
    newFollowVelocity = unit:GetStaticVelocity()*30
  end
  unit.zConnect = {newBounceVelocity,newFollowVelocity}
end

function Projectiles:OnWallHit(unit,keys)
  local normal = keys.normal
  local multiplier = keys.multiplier
  if not multiplier then multiplier = 1 end
  local newBounceVelocity = unit:GetStaticVelocity()
  if newBounceVelocity:Dot(normal) >= 0 then
    return
  end
  newBounceVelocity = (((-2 * newBounceVelocity:Dot(normal) * normal) + newBounceVelocity) * multiplier * 30)

  local newFollowVelocity = unit:GetStaticVelocity()
  if newFollowVelocity:Dot(normal) >= 0 then
    return
  end
  if keys.leg1 then -- If round then go through instead of following
    local direction = (keys.leg1-keys.leg2):Normalized()
    newFollowVelocity = direction*(unit:GetStaticVelocity()*30)
  else
    newFollowVelocity = unit:GetStaticVelocity()*30
  end
  unit.yConnect = {newBounceVelocity,newFollowVelocity}
end

function Projectiles:CreateProjectile(projectile)
-- set defaults
  projectile.vVelocity = projectile.vVelocity or Vector(0,0,0)
  projectile.fDistance = projectile.fDistance or 1000
  projectile.fStartRadius = projectile.fStartRadius or 100
  projectile.fEndRadius = projectile.fEndRadius or 100
  projectile.iPositionCP = projectile.iPositionCP or 0
  projectile.iVelocityCP = projectile.iVelocityCP or 1
  projectile.fExpireTime = projectile.fExpireTime or 10
  projectile.ControlPoints = projectile.ControlPoints or {}
  projectile.UnitBehavior = projectile.UnitBehavior or PROJECTILES_DESTROY
  if projectile.bIgnoreSource == nil then projectile.bIgnoreSource = true end
  if projectile.bMultipleHits == nil then projectile.bMultipleHits = false end
  if projectile.bRecreateOnChange == nil then projectile.bRecreateOnChange = true end
  if projectile.bZCheck == nil then projectile.bZCheck = true end
  projectile.fRehitDelay = projectile.fRehitDelay or 1
  if projectile.bDestroyImmediate == nil then projectile.bDestroyImmediate = true end
  projectile.WallBehavior = projectile.WallBehavior or PROJECTILES_DESTROY
  projectile.GroundBehavior = projectile.GroundBehavior or PROJECTILES_DESTROY
  projectile.bGroundLock = projectile.bGroundLock or false
  projectile.fGroundOffset = projectile.fGroundOffset or 0
  projectile.nChangeMax = projectile.nChangeMax or 1
  projectile.fChangeDelay = projectile.fChangeDelay or .1
  projectile.UnitTest = projectile.UnitTest or function() return false end
  projectile.OnUnitHit = projectile.OnUnitHit or function() return end
  projectile.OnWallHit = projectile.OnWallHit or function() return end
  projectile.OnGroundHit = projectile.OnGroundHit or function() return end
  projectile.OnFinish = projectile.OnFinish or nil

  projectile.ControlPointForwards = projectile.ControlPointForwards or {}
  projectile.ControlPointOrientations = projectile.ControlPointOrientations or {}
  projectile.ControlPointEntityAttaches = projectile.ControlPointEntityAttaches or {}

  if projectile.vSpawnOrigin and projectile.vSpawnOrigin.unit then
    local attach = projectile.vSpawnOrigin.unit:ScriptLookupAttachment(projectile.vSpawnOrigin.attach)
    local attachPos = projectile.vSpawnOrigin.unit:GetAttachmentOrigin(attach)
    projectile.vSpawnOrigin = attachPos + (projectile.vSpawnOrigin.offset or Vector(0,0,0))
  else
    projectile.vSpawnOrigin = projectile.vSpawnOrigin or Vector(0,0,0)
  end

  projectile.rehit = {}
  projectile.targets = {}
  projectile.pos = projectile.vSpawnOrigin
  projectile.vel = projectile.vVelocity / 30
  projectile.prevVel = projectile.vel
  projectile.prevPos = projectile.vSpawnOrigin
  projectile.radius = projectile.fStartRadius
  projectile.changes = projectile.nChangeMax

  projectile.spawnTime = GameRules:GetGameTime()
  projectile.changeTime = projectile.spawnTime
  projectile.distanceTraveled = 0

  if projectile.fRadiusStep then
    projectile.radiusStep = projectile.fRadiusStep / 30
  else
    projectile.radiusStep = (projectile.fEndRadius - projectile.fStartRadius) / (projectile.fDistance / projectile.vel:Length())
  end

  projectile.id = ParticleManager:CreateParticle(projectile.EffectName, PATTACH_CUSTOMORIGIN, nil)
  ParticleManager:SetParticleAlwaysSimulate(projectile.id)
  for k,v in pairs(projectile.ControlPoints) do
    ParticleManager:SetParticleControl(projectile.id, k, v)
  end
  for k,v in pairs(projectile.ControlPointForwards) do
    ParticleManager:SetParticleControlForward(projectile.id, k, v)
  end
  for k,v in pairs(projectile.ControlPointOrientations) do
    ParticleManager:SetParticleControlOrientation(projectile.id, k, v[1], v[2], v[3])
  end
  for k,v in pairs(projectile.ControlPointEntityAttaches) do
    local unit = v.unit or projectile.Source
    local pattach = v.pattach or PATTACH_CUSTOMORIGIN
    local attachPoint = v.attachPoint
    local origin = v.origin or projectile.vSpawnOrigin
    ParticleManager:SetParticleControlEnt(projectile.id, k, unit, pattach, attachPoint, origin, true)
  end

  ParticleManager:SetParticleControl(projectile.id, projectile.iPositionCP, projectile.vSpawnOrigin)
  if projectile.ControlPointForwards[1] == nil and projectile.ControlPointOrientations[1] == nil then
    ParticleManager:SetParticleControlForward(projectile.id, projectile.iPositionCP, projectile.vel:Normalized())
  end
  ParticleManager:SetParticleControl(projectile.id, projectile.iVelocityCP, projectile.vel * 30)

  -- Create a leading physics unit
  local projectileUnit = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  
  Physics:Unit(projectileUnit)
  projectileUnit:SetStaticVelocity("projectile_velocity",projectile.vel*30)
  projectileUnit:SetPhysicsVelocity(Vector(0,0,0))
  projectileUnit:SetAbsOrigin(projectile.vSpawnOrigin)
  projectileUnit:Hibernate(false)
  projectileUnit:OnHibernate(function(unit) unit:Hibernate(false)end)
  for k,v in pairs(projectile) do
    projectileUnit[k] = v
  end
  projectile = projectileUnit

  function projectile:GetCreationTime()
    return projectile.spawnTime
  end

  function projectile:IsProjectile()
    return true
  end

  function projectile:GetDistanceTraveled()
    return projectile.distanceTraveled
  end
  function projectile:GetPosition()
    return projectile.pos
  end
  function projectile:GetVelocity()
    return projectile.vel * 30
  end
  function projectile:SetVelocity(newVel, newPos)
    projectile.changes = projectile.changes - 1
    projectile.vel = newVel / 30
    projectile.changeTime = GameRules:GetGameTime() + projectile.fChangeDelay
    
    ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
    projectile.id = ParticleManager:CreateParticle(projectile.EffectName, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleAlwaysSimulate(projectile.id)
    ParticleManager:SetParticleControl(projectile.id, projectile.iPositionCP, newPos or projectile.pos + projectile.vel)
    
    ParticleManager:SetParticleControl(projectile.id, projectile.iVelocityCP, newVel)
    projectile:SetStaticVelocity("projectile_velocity",newVel)  
  end

  function projectile:Destroy()
    ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
    Projectiles:RemoveTimer(projectile.ProjectileTimerName)
    UTIL_Remove(projectile)
  end

  projectile.ProjectileTimerName = DoUniqueString('proj')
  projectile:SetAbsOrigin(projectile.vSpawnOrigin)
  projectileUnit:SetPhysicsVelocity(Vector(0,0,0))
  Projectiles:CreateTimer(projectile.ProjectileTimerName, {

    endTime = GameRules:GetGameTime(),
    useGameTime = true,
    callback = function()
      local curTime = GameRules:GetGameTime()
      local vel = projectile.vel
      projectile.pos = projectile:GetAbsOrigin()
      local pos = projectile:GetAbsOrigin()
      if projectile.bGroundLock then
        -- Declare something for platform to decide what to do
      end
      -- OnProjectileThink
      if projectile.OnProjectileThink then
        local status, out = pcall(projectile.OnProjectileThink, projectile, pos)
        if not status then
          print('[PROJECTILES] OnProjectileThink Error!: ' .. out)
        end
      end

      -- Checks time
      if curTime > projectile.spawnTime + projectile.fExpireTime or projectile.distanceTraveled > projectile.fDistance then
        ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
        if projectile.OnFinish then
          local status, out = pcall(projectile.OnFinish, projectile, pos)
          if not status then
            print('[PROJECTILES] Collision UnitTest Failure!: ' .. out)
          end
          projectile:Destroy()
        end
        return
      end

      -- update values
      local radius = projectile.radius
      local rad2 = radius * radius
      
      -- debug draw (Bad but whatever)
      if projectile.draw then
        local alpha = 1
        local color = Vector(200,0,0)
        if type(projectile.draw) == "table" then
          alpha = projectile.draw.alpha or alpha
          color = projectile.draw.color or color
        end
        DebugDrawSphere(pos, color, alpha, radius, true, .01)
      end

      -- frame and sub-frame collision checks
      local subpos = pos
      local velLength = vel:Length()
      local tot = math.max(1, math.ceil(velLength / 32)) -- lookahead number
      local div = 1 / tot

      -- unit detectio
      local framehalf = pos + (vel * div * (tot-1))/2
      local framerad = (framehalf - pos):Length() + radius
      local ents = Entities:FindAllInSphere(framehalf, framerad)

      for k,v in pairs(ents) do
        if IsValidEntity(v) and v.GetUnitName and v:IsAlive() and not projectile.targets[v] then
          projectile.targets[v] = true
          local status, test = pcall(projectile.UnitTest, projectile, v)
          if not status then
            print('[PROJECTILES] Projectile UnitTest Failure!: ' .. test)
          elseif test then
            local status, action = pcall(projectile.OnUnitHit, projectile, v)
            if not status then
              print('[PROJECTILES] Projectile OnUnitHit Failure!: ' .. action)
            end

            if projectile.UnitBehavior == PROJECTILES_DESTROY then
              ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
              if projectile.OnFinish then
                local status, out = pcall(projectile.OnFinish, projectile, subpos)
                if not status then
                  print('[PROJECTILES] Projectile OnFinish Failure!: ' .. out)
                end
                projectile:Destroy()
              end
              return
            end
          end
        end
      end

      if projectile.zConnect then
        if projectile.GroundBehavior == PROJECTILES_DESTROY then
          ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
          if projectile.OnFinish then
            local status, out = pcall(projectile.OnFinish, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnFinish Failure!: ' .. out)
            end
            projectile:Destroy()
          end
          return
        elseif projectile.GroundBehavior == PROJECTILES_BOUNCE then
          projectile:SetVelocity(projectile.zConnect[1], projectile.pos)
          if projectile.OnGroundHit then
            local status, out = pcall(projectile.OnGroundHit, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnGroundHit Failure!: ' .. out)
            end
          end
        elseif projectile.GroundBehavior == PROJECTILES_FOLLOW then
          projectile:SetVelocity(projectile.zConnect[2], projectile.pos)
           if projectile.OnGroundHit then
            local status, out = pcall(projectile.OnGroundHit, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnGroundHit Failure!: ' .. out)
            end
          end
        end
        projectile.zConnect = nil
      end

      if projectile.yConnect then
        if projectile.WallBehavior == PROJECTILES_DESTROY then
          ParticleManager:DestroyParticle(projectile.id, projectile.bDestroyImmediate)
          if projectile.OnFinish then
            local status, out = pcall(projectile.OnFinish, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnFinish Failure!: ' .. out)
            end
            projectile:Destroy()
          end
          return
        elseif projectile.WallBehavior == PROJECTILES_BOUNCE then
          projectile:SetVelocity(projectile.yConnect[1], projectile.pos)
          if projectile.OnWallHit then
            local status, out = pcall(projectile.OnWallHit, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnWallHit Failure!: ' .. out)
            end
          end
        elseif projectile.WallBehavior == PROJECTILES_FOLLOW then
          projectile:SetVelocity(projectile.yConnect[2], projectile.pos)
           if projectile.OnWallHit then
            local status, out = pcall(projectile.OnGroundHit, projectile, subpos)
            if not status then
              print('[PROJECTILES] Projectile OnWallHit Failure!: ' .. out)
            end
          end
        end
        projectile.yConnect = nil
      end

      projectile.radius = radius + projectile.radiusStep
      projectile.prevPos = projectile:GetAbsOrigin()
      projectile.distanceTraveled = projectile.distanceTraveled + velLength
     
      projectile:SetPhysicsVelocity(Vector(0,0,0))
      projectile.pos = projectile:GetAbsOrigin()

      return curTime
    end
  })

  return projectile
end

if not Projectiles.timers then Projectiles:start() end