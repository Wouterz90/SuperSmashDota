FT_INV = 1/FrameTime()

STATIC_FRICTION = 0.3
PHYSICS_FRICTION = 0.2
PROJECTILES_STATIC_FRICTION = 0.1
PROJECTILES_PHYSICS_FRICTION = 0.05

PROJECTILES_NOTHING = 1
PROJECTILES_DESTROY = 2
PROJECTILES_BOUNCE = 3


COLLISION_CORRECT = 1 -- Setting the unit outside the other
COLLISION_RESOLVE = 2 -- Moving the units from each other
COLLISION_CORRECT_OR_RESOLVE = 3

Physics2D = Physics2D or class({})


--vSpawnOrigin: Spawn location
--hCaster
--hTarget: Target to move to
--flDuration: Whenever this projectile expires, optional
--flSpeed
--flTurnRate: Use this to make the bouncing turn rate smaller
--flAcceleration: Speed * this, ran every frame, optional
--flStartRadius
--flEndRadius, Optional will default to startRadius
--flMaxDistance -- Max distance from target for tracking, linear max elapsed distance
--nSourceAttachment = the attachment the projectile originates from. Optional
--sEffectName, optional
--sSoundName, optional
--sDestructionEffectName, optional
--PlatformBehavior
--UnitBehavior
--ProjectileBehavior
--Debug?
--Functions: All optional
  --OnUnitHit(self,unit)
  --OnPlatformHit(self,platform)
  --OnProjectileHit(self,projectile)
  --OnProjectileThink(self)
  --OnFinish(self) -- Does only run when the timer expires.


function Physics2D:CreateTrackingProjectile(keys)
  local location
  if keys.vSpawnOrigin then
      location = keys.vSpawnOrigin
  elseif keys.iSourceAttachment then
      location = keys.hCaster:GetAttachmentOrigin( keys.iSourceAttachment )
  else
      location = keys.hCaster:GetAbsOrigin() + Vec(0,50)
  end

  local unit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  unit:SetAbsOrigin(location)
  

  Physics2D:CreateObject("circle",keys.vSpawnOrigin,false,true,unit,keys.flRadius,keys.flRadius,"Platform")
  unit.IsProjectile = "Tracking"
  --unit.dummy = dummy
  unit.startLoc = location
  unit.target = keys.hTarget
  unit.caster = keys.hCaster
  unit.creationTime = GameRules:GetGameTime()
  if keys.flDuration then unit.duration = keys.flDuration end
  unit.speed = keys.flSpeed * FrameTime()
  if keys.flAcceleration then unit.acceleration = keys.flAcceleration end
  unit.turnRate = turnRate or 1
  unit.startRadius = keys.flRadius
  if keys.flMaxDistance then unit.maxDistance = keys.flMaxDistance end
  if keys.sEffectName then unit.effectName = keys.sEffectName end
  if keys.sSoundName then unit.soundName = keys.sSoundName end
  if keys.sDestructionEffectName then unit.destructionEffectName = keys.sDestructionEffectName end
  if keys.PlatformBehavior then unit.PlatformBehavior = keys.PlatformBehavior end
  if keys.OnPlatformHit then unit.OnPlatformHit = keys.OnPlatformHit end
  if keys.UnitBehavior then unit.UnitBehavior = keys.UnitBehavior end
  if keys.ProjectileBehavior then unit.ProjectileBehavior = keys.ProjectileBehavior end
  if keys.OnProjectileHit then unit.OnProjectileHit = keys.OnProjectileHit end
  if keys.UnitTest then unit.UnitTest = keys.UnitTest end
  if keys.OnProjectileThink then unit.OnProjectileThink = keys.OnProjectileThink end
  if keys.OnFinish then unit.OnFinish = keys.OnFinish end
  if keys.OnUnitHit then unit.OnUnitHit = keys.OnUnitHit end


  unit.distanceTravelled = 0
  unit.location = unit:GetAbsOrigin()
  local direction = (unit.target:GetAbsOrigin() - unit.location):Normalized()
  unit.velocity = direction * unit.speed
  unit.hitByProjectile = {}

  --Make the particle
  unit.particle = ParticleManager:CreateParticle(unit.effectName, PATTACH_CUSTOMORIGIN, unit.caster)
  ParticleManager:SetParticleControl(unit.particle,0,unit:GetAbsOrigin())
  ParticleManager:SetParticleControlEnt(unit.particle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
  ParticleManager:SetParticleControl(unit.particle,2,Vector(unit.speed *30,0,0))

  unit.maxSpeed = unit.speed
  return unit
end

function Physics2D:ManageTrackingProjectile(hProjectile)
  -- This gets called in the Physics Think function before
  if hProjectile.OnProjectileThink then
    local status, out = pcall(hProjectile.OnProjectileThink, hProjectile, hProjectile.location)
    if not status then
      print('[TRACKING PROJECTILE] OnProjectileThink Error!: ' .. out)
    end
  end

  -- Add this acceleration to the unit's max speed
  if hProjectile.acceleration then
    hProjectile.velocity = hProjectile.velocity * hProjectile.acceleration
    hProjectile.maxSpeed = hProjectile.maxSpeed * hProjectile.acceleration
  end

  --Update the velocity
  -- I think I should add it, get the length and math.min the speed with the length
  local direction = (hProjectile.target:GetAbsOrigin() - hProjectile.location):Normalized()
  hProjectile.velocity = hProjectile.velocity + (direction * hProjectile.turnRate)
  hProjectile.speed = math.min(hProjectile.velocity:Length(),hProjectile.maxSpeed)
  hProjectile.velocity = hProjectile.velocity:Normalized() * hProjectile.speed

  hProjectile.distanceTravelled = hProjectile.distanceTravelled + hProjectile.speed
  
  ParticleManager:SetParticleControl(hProjectile.particle, 2, Vector(hProjectile.speed*30,0,0))

  -- Run all checks why this projectile could be destroyed
  if hProjectile.duration and hProjectile.creationTime + hProjectile.duration < GameRules:GetGameTime() then
    Physics2D:DestroyProjectile(hProjectile)
  end


  if hProjectile.maxDistance and hProjectile.maxDistance <= hProjectile.distanceTravelled then
    Physics2D:DestroyProjectile(hProjectile)
  end
end

function Physics2D:CreateLinearProjectile(keys)
  local location
  if keys.vSpawnOrigin then
      location = keys.vSpawnOrigin
  elseif keys.iSourceAttachment then
      location = keys.hCaster:GetAttachmentOrigin( keys.iSourceAttachment )
  else
      location = keys.hCaster:GetAbsOrigin() + Vec(0,50)
  end

  local unit =SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  unit:SetAbsOrigin(location)
  

  Physics2D:CreateObject("circle",keys.vSpawnOrigin,false,true,unit,keys.flRadius,keys.flRadius,"Platform")
  unit.IsProjectile = "Linear"
  --unit.dummy = dummy
  unit.startLoc = location
  unit.direction = keys.vDirection:Normalized()
  unit.caster = keys.hCaster
  unit.creationTime = GameRules:GetGameTime()
  if keys.flDuration then unit.duration = keys.flDuration end
  unit.speed = keys.flSpeed * FrameTime()
  if keys.flAcceleration then unit.acceleration = keys.flAcceleration end
  unit.turnRate = turnRate or 1
  unit.startRadius = keys.flRadius
  --if not keys.flEndRadius then unit.endRadius = keys.flStartRadius end
  if keys.flMaxDistance then unit.maxDistance = keys.flMaxDistance end
  if keys.sEffectName then unit.effectName = keys.sEffectName end
  if keys.sSoundName then unit.soundName = keys.sSoundName end
  if keys.sDestructionEffectName then unit.destructionEffectName = keys.sDestructionEffectName end
  if keys.PlatformBehavior then unit.PlatformBehavior = keys.PlatformBehavior end
  if keys.OnPlatformHit then unit.OnPlatformHit = keys.OnPlatformHit end
  if keys.UnitBehavior then unit.UnitBehavior = keys.UnitBehavior end
  if keys.ProjectileBehavior then unit.ProjectileBehavior = keys.ProjectileBehavior end
  if keys.OnProjectileHit then unit.OnProjectileHit = keys.OnProjectileHit end
  if keys.UnitTest then unit.UnitTest = keys.UnitTest end
  if keys.OnProjectileThink then unit.OnProjectileThink = keys.OnProjectileThink end
  if keys.OnFinish then unit.OnFinish = keys.OnFinish end
  if keys.OnUnitHit then unit.OnUnitHit = keys.OnUnitHit end

  unit:SetAbsOrigin(location + (unit.direction * unit.speed * FrameTime()))
  unit.location = unit:GetAbsOrigin()
  unit.velocity = unit.direction * unit.speed
  unit.distanceTravelled = 0
  unit.hitByProjectile = {}
  --Make the particle
  unit.particle = ParticleManager:CreateParticle(unit.effectName, PATTACH_CUSTOMORIGIN, unit.caster)
  ParticleManager:SetParticleControl(unit.particle,0,unit:GetAbsOrigin())
  ParticleManager:SetParticleControlEnt(unit.particle,1,unit,PATTACH_POINT_FOLLOW,"attach_hitloc",unit:GetAbsOrigin(),true)
  ParticleManager:SetParticleControl(unit.particle,2,Vector(unit.speed *30,0,0))
  unit.maxSpeed = unit.speed
  return unit
end

function Physics2D:ManageLinearProjectile(hProjectile)
  if hProjectile.destroyed then return end
  -- This gets called in the Physics Think function before
  if hProjectile.OnProjectileThink then
    local status, out = pcall(hProjectile.OnProjectileThink, hProjectile, hProjectile.location)
    if not status then
      print('[LINEAR PROJECTILE] OnProjectileThink Error!: ' .. out)
    end
  end

  -- Add this acceleration to the unit's max speed
  if hProjectile.acceleration then
    hProjectile.velocity = hProjectile.velocity * hProjectile.acceleration
    hProjectile.speed = hProjectile.speed * hProjectile.acceleration
  end
  hProjectile.distanceTravelled = hProjectile.distanceTravelled + hProjectile.speed
  hProjectile.velocity = hProjectile.velocity:Normalized() * hProjectile.speed
  ParticleManager:SetParticleControl(hProjectile.particle, 2, Vector(hProjectile.speed*30,0,0))

  -- Run all checks why this projectile could be destroyed
  if hProjectile.duration and hProjectile.creationTime + hProjectile.duration < GameRules:GetGameTime() then
    Physics2D:DestroyProjectile(hProjectile)
  end
  
  if hProjectile.maxDistance and hProjectile.maxDistance <= hProjectile.distanceTravelled then
    Physics2D:DestroyProjectile(hProjectile)
  end
end

function Physics2D:DestroyProjectile(hProjectile)
  if hProjectile.destroyed then return end
  if hProjectile.OnFinish then
    local status, out = pcall(hProjectile.OnFinish, hProjectile)
    if not status then
      print('[PROJECTILE] OnFinish Failure!: ' .. out)
    end
  end
  hProjectile.destroyed = true
  ParticleManager:DestroyParticle(hProjectile.particle,false)
  ParticleManager:ReleaseParticleIndex(hProjectile.particle)
  -- Keep the unit for a while to have the destruction particle
  Timers:CreateTimer(0.5,function()
    hProjectile.RemoveProjectile = true
  end)
end

function Physics2D:CreateObject(sType,vLocation,bGravity,bCanHaveVelocity,hUnit,flWidth,flHeight,sMaterial)
  Physics2D.units = Physics2D.units or {}
  -- sType: AABB or Circle
  -- vLocation: Vector location of object center
  -- sMaterial: One of the materials below, if omitted defaults to Platform
  -- bGravity: True/False if unit should experience gravity
  -- flWidth: Width of AABB platform, radius of circle platform
  -- flHeight: Can be ommitted if circle
  -- hUnit: Unit attached to the physics unit, can be nil

  flHeight = flHeight or flWidth
 
  local radius = flWidth
  if sType == "AABB" then
    radius = (flWidth + flHeight) /2
  end
  local mass,inv_mass,restitution = Physics2D:CalculateMass(sType,{flWidth,flHeight},sMaterial)
  hUnit = hUnit or {}
  hUnit.unit = hUnit or nil
  hUnit.material = sMaterial
  hUnit.bVelocity = bCanHaveVelocity
  hUnit.draw = false
  hUnit.type = sType
  hUnit.location = vLocation
  hUnit.width = flWidth
  hUnit.height = flHeight
  hUnit.radius = radius
  hUnit.gravity = bGravity
  hUnit.mass = mass
  hUnit.inv_mass = inv_mass
  hUnit.restitution = restitution
  --[[hUnit.rotation = 0 or flRotation
  hUnit.angular_velocity = Vec(0)
  hUnit.torque = 0 ]] 

  hUnit.velocity = hUnit.velocity or Vec(0)
  hUnit.staticVelTable = {}
  hUnit.forces = {}
  
  table.insert(Physics2D.units,hUnit)
  return hUnit
end

-- These functions return a table if there is collision else nothing.
function AABBvsAABB(a,b)
  local normal
  local penetration
  if not a.pos or not b.pos then return end
  -- Vector From A to B
  local n = b.pos - a.pos

  local amin = a.pos - (Vec(a.width/2,a.height/2) )
  local bmin = b.pos - (Vec(b.width/2,b.height/2) )
  local amax = a.pos + (Vec(a.width/2,a.height/2) )
  local bmax = b.pos + (Vec(b.width/2,b.height/2) )

  -- Calculate half extents along x axis for each object
  local a_extent = (amax.x - amin.x)/2
  local b_extent = (bmax.x - bmin.x)/2

  -- Calculate overlap on x axis
  local x_overlap = a_extent + b_extent - math.abs(n.x)

  -- SAT test on x axis
  if x_overlap > 0 then

    -- Calculate half extents along z axis for each object
    a_extent = (amax.z - amin.z)/2
    b_extent = (bmax.z - bmin.z)/2

    -- Calculate overlap on z axis
    local z_overlap = a_extent + b_extent - math.abs(n.z)

    -- SAT test on z axis
    if z_overlap > 0 then

      -- Find out which axis is axis of least penetration
      if x_overlap < z_overlap then
        -- Point towards B knowing that n points from A to B
        penetration = x_overlap
        if n.x < 0 then
          normal  = Vec(-1,0)
        else
          normal = Vec(1,0)  
        end
        return {a=a,b=b,normal=normal,penetration=penetration}
      else
        -- Point towards B knowing that n points from A to B
        penetration = z_overlap
        if n.z < 0 then
          normal = Vec(0,-1)
        else
          normal = Vec(0,1)
        end
        return {a=a,b=b,normal=normal,penetration=penetration}
      end
    end
  end
end

function CirclevsCircle(a,b)
  local normal
  local penetration
  -- Vector from A to B
  if not a.pos or not b.pos then return end
  local n = b.pos - a.pos
  
  local r = math.pow(a.radius + b.radius,2)
  
  local bCollision =  r > LengthSquared(n)
  if not bCollision then return end

  -- Circles have collided, now compute manifold
  local d = n:Length() -- Perform actual sqrt

  -- If distance between circles is not zero
  if d ~= 0 then 
    -- Distance is differene between radius and distance
    penetration = r-d
    -- Utilize our d since we performed sqrt on it already within Length( )
    -- Points from A to B, and is a unit vector
    normal = n/d
    return {a,b,normal,penetration}
  else
    penetration = a.radius
    normal = Vec(1,0)
    local tab = {
      a=a,
      b=b,
      normal=normal,
      penetration=penetration
    }
    return tab
  end
end

function CirclevsAABB(a,b)
  -- Vector from A to B
  if not a.pos or not b.pos then return end
  local n = b.pos - a.pos
  -- Closest point on A to center of B
  local closest = Vec(n.x,n.z)
  -- Calculate half extents along each axis
  local bmin = b.pos - Vec(b.width/2,b.height/2)
  local bmax = b.pos + Vec(b.width/2,b.height/2)

  local x_extent = (bmax.x - bmin.x)/2
  local z_extent = (bmax.z - bmin.z)/2

  -- Clamp point to edges of the AABB
  closest.x = math.clamp( -x_extent, x_extent, closest.x )
  closest.z = math.clamp( -z_extent, z_extent, closest.z )

  local bInside = false

  -- Circle is inside the AABB, so we need to clamp the circle's center
  -- to the closest edge
  if n == closest then
    bInside = true
    -- Find closest axis
    if math.abs(n.x) > math.abs(n.z) then
      -- Clamp to closest extent
      if closest.x > 0 then
        closest.x = x_extent
      else
        closest.x = -x_extent
      end
      -- z axis is shorter
    else
      -- Clamp to closest extent
      if closest.z > 0 then
        closest.z = z_extent
      else
        closest.z = -z_extent
      end
    end
  end
  local normal = n - closest


  local d = LengthSquared(normal)
  local r = a.radius

  -- Early out of the radius is shorter than distance to closest point and
  -- Circle not inside the AABB
  if d > r*r and not bInside then return end
  d = math.sqrt(d)

  if bInside then
    normal = -normal
    penetration = r-d
  else
    normal = normal
    penetration = r-d
  end
  return {a=a,b=b,normal=normal:Normalized(),penetration=penetration}
end

function AABBvsCircle(a,b)
  -- Vector from A to B
  local n = a.pos - b.pos
  -- Closest point on A to center of B
  local closest = Vec(n.x,n.z)
  -- Calculate half extents along each axis
  local amin = a.pos - Vec(a.width/2,a.height/2)
  local amax = a.pos + Vec(a.width/2,a.height/2)

  local x_extent = (amax.x - amin.x)/2
  local z_extent = (amax.z - amin.z)/2

  -- Clamp point to edges of the AABB
  closest.x = math.clamp( -x_extent, x_extent, closest.x )
  closest.z = math.clamp( -z_extent, z_extent, closest.z )

  local bInside = false

  -- Circle is inside the AABB, so we need to clamp the circle's center
  -- to the closest edge
  if n == closest then
    bInside = true
    -- Find closest axis
    if math.abs(n.x) > math.abs(n.z) then
      -- Clamp to closest extent
      if closest.x > 0 then
        closest.x = x_extent
      else
        closest.x = -x_extent
      end
      -- z axis is shorter
    else
      -- Clamp to closest extent
      if closest.z > 0 then
        closest.z = z_extent
      else
        closest.z = -z_extent
      end
    end
  end
  local normal = n - closest


  local d = LengthSquared(normal)
  local r = b.radius

  -- Early out of the radius is shorter than distance to closest point and
  -- Circle not inside the AABB
  if d > r*r and not bInside then return end
  d = math.sqrt(d)

  if bInside then
    normal = normal
    penetration = r-d
  else
    normal = -normal
    penetration = r-d
  end
  return {a=a,b=b,normal=normal:Normalized(),penetration=penetration}
end

function Physics2D:ProjectileHitUnit(projectile,unit)
  if projectile.destroyed then return end
  if projectile.hitByProjectile.unit then return end
  local status, test = pcall(projectile.UnitTest, projectile, unit)
  if not status then
    print('[PROJECTILES] Projectile UnitTest Failure!: ' .. test)
  elseif test then
    projectile.hitByProjectile.unit = true
    if projectile.OnUnitHit then
      local status, out = pcall(projectile.OnUnitHit, projectile, unit)
      if not status then
        print('[PROJECTILES] OnUnitHit Error!: ' .. out)
      end
    end
    if projectile.UnitBehavior == PROJECTILES_DESTROY then
      Physics2D:DestroyProjectile(projectile)
    end
    return true
  end
  return false
end

function Physics2D:ProjectileHitPlatform(projectile,platform)
  if projectile.destroyed then return end
  if projectile.PlatformBehavior == PROJECTILES_DESTROY then
    Physics2D:DestroyProjectile(projectile)
  end

  if projectile.OnPlatformHit then
    local status, out = pcall(projectile.OnPlatformHit, projectile, platform)
    if not status then
      print('[PROJECTILES] OnPlatformHit Error!: ' .. out)
    end
  end
  return
end

function Physics2D:ProjectileHitProjectile(a,b)
  if a.destroyed then return end
  if b.destroyed then return end
  if a.OnProjectileHit then
    local status, out = pcall(a.OnProjectileHit, a, b)
    if not status then
      print('[PROJECTILES] OnProjectileHit Error!: ' .. out)
    end
  end
  if b.OnProjectileHit then
    local status, out = pcall(b.OnProjectileHit, b, a)
    if not status then
      print('[PROJECTILES] OnProjectileHit Error!: ' .. out)
    end
  end
end

function ResolveCollision( collision )
  -- Calculate relative velocity

  local a = collision.a or collision[1]
  local b = collision.b or collision[2]
  local normal = collision.normal or collision[3]
  local penetration = collision.penetration or collision[4]

  DebugPrint(2,"Physics2D ResolveCollision")
  DebugPrintTable(2,collision)

  local rv = b.velocity - a.velocity
  -- Calculate relative velocity in terms of the normal direction
  local velAlongNormal = rv:Dot(normal)
  -- Do not resolve if velocities are separating
  if velAlongNormal > 0 then return end

  if a.IsProjectile and b.IsProjectile then
    if a.ProjectileBehavior or b.ProjectileBehavior then
      Physics2D:ProjectileHitProjectile(a,b)
    end
    return
  end

  -- Check if one is a unit and the other a projectile
  if a.IsProjectile and b.IsSmashUnit then
    if a.UnitBehavior then
      if not Physics2D:ProjectileHitUnit(a,b) then
        return
      end
      if a.UnitBehavior ~= PROJECTILES_BOUNCE then
        return
      end
    end
    return
  elseif b.IsProjectile and a.IsSmashUnit then
    if b.UnitBehavior then
      if not Physics2D:ProjectileHitUnit(b,a) then
        return
      end
      if b.UnitBehavior ~= PROJECTILES_BOUNCE then
        return
      end
    return
    end

  end
  -- Check if one is a platform and the other a projectile
  if a.IsProjectile and b.IsPlatform and a.PlatformBehavior then
    Physics2D:ProjectileHitPlatform(a,b)
    if a.PlatformBehavior ~= PROJECTILES_BOUNCE then
      if a.PlatformBehavior == PROJECTILES_DESTROY then
        Physics2D:DestroyProjectile(a)
      end
      return
    end
    
  elseif b.IsProjectile and a.IsPlatform and b.PlatformBehavior then
    Physics2D:ProjectileHitPlatform(b,a)
    if b.PlatformBehavior ~= PROJECTILES_BOUNCE then
      if b.PlatformBehavior == PROJECTILES_DESTROY then
        Physics2D:DestroyProjectile(b)
      end
      return
    end
  end
  -- If only one of them is a platform overwrite it
  if a.IsPlatform and not b.IsPlatform then
    movingUnit = b
    if normal.z >= 0 then
      if b.HasModifier then
        b.jumps = 0
        b:AddNewModifier(b,nil,"modifier_on_platform",{duration = 4*FrameTime()})
        b.IsOnPlatfrom = a
        a.unitsOnPlatform[b] = GameRules:GetGameTime() + (FrameTime()*4)
      end
      
    end
    if b.IsSmashUnit and a.IsPassable and b.HasModifier then
      -- Check z values to decide if you can jump through
      if b:HasModifier("modifier_drop") then
        return
      end
      if a.pos.z-a.height/2 >= b.pos.z-b.height/2  then
        return
      end
    end
  elseif b.IsPlatform and not a.IsPlatform then
    movingUnit = a
    if normal.z <= 0 then
      if a.HasModifier then
        a.jumps = 0
        a:AddNewModifier(b,nil,"modifier_on_platform",{duration = 4*FrameTime()})
        b.unitsOnPlatform[a] = GameRules:GetGameTime() + (FrameTime()*4)
      end
    end
    if a.IsSmashUnit and b.IsPassable and a.HasModifier then
      -- Check z values to decide if you can jump through
      if a:HasModifier("modifier_drop") then
        return
      end
      if b.pos.z+b.height/2 >= a.pos.z-a.height/2 and a.velocity.z > 0 then
        return
      end
    end
  end
 
  -- Calculate restitution
  local e = math.min(a.restitution, b.restitution)
 
  -- Calculate impulse scalar
  local j = -(1 + e) * velAlongNormal
  j =  j / b.inv_mass + a.inv_mass
 
  -- Apply impulse
  local impulse = j * normal
  --if a.IsProjectile or b.IsProjectile then impulse = impulse * 3 end

  local oldvec = a.velocity
  a.velocity =  a.velocity - a.inv_mass * impulse
  b.velocity =  b.velocity + b.inv_mass * impulse

  if a.NoFriction or b.NoFriction then return end
  -- Solve for the tangent vector
  local tangent = rv - rv:Dot(normal) * normal
  tangent = tangent:Normalized()
   
  -- Solve for magnitude to apply along the friction vector
  local jt = -1*rv:Dot(tangent)
  jt = jt / (a.inv_mass + b.inv_mass)
   
  -- PythagoreanSolve = A^2 + B^2 = C^2, solving for C given A and B
  -- Use to approximate mu given friction coefficients of each body
  --local  mu = PythagoreanSolve( A->staticFriction, B->staticFriction )

  -- If friction becomes material based change this
  local mu = math.sqrt((STATIC_FRICTION * STATIC_FRICTION) * 2)
   
  -- Clamp magnitude of friction and create impulse vector
  local frictionImpulse = Vec(0,0)
  if math.abs(jt) < j * mu then
    frictionImpulse = jt * tangent
  else
    frictionImpulse = -j * tangent * math.sqrt((PHYSICS_FRICTION * PHYSICS_FRICTION) * 2)
  end
  --if CheckCollision(a,b) then
    a.velocity =  a.velocity - a.inv_mass * frictionImpulse
    b.velocity =  b.velocity + b.inv_mass * frictionImpulse
  --end
end

function CorrectPosition(collision)
  local a = collision.a or collision[1]
  local b = collision.b or collision[2]
  local normal = collision.normal or collision[3] -- From a to b
  local penetration = collision.penetration or collision[4]
  -- Find out what the unit with static velocity is first
  --if not a.staticVelocity and not b.staticVelocity then return end -- How did we get here?
  --if a.IsSmashUnit and b.IsSmashUnit then return end -- How did we get here?

  local movingUnit

  -- Find out the unit that moves
  if Physics2D:GetStaticVelocity(a) ~= Vec(0) and Physics2D:GetStaticVelocity(b) == Vec(0) then
    movingUnit = a
  elseif Physics2D:GetStaticVelocity(b) ~= Vec(0) and not Physics2D:GetStaticVelocity(a) == Vec(0) then
    movingUnit = b
    normal = normal * -1
  end

  -- If only one of them is a platform overwrite it
  if a.IsPlatform and not b.IsPlatform then
    movingUnit = b
    if b.IsSmashUnit and a.IsPassable and b.HasModifier then
      -- Check z values to decide if you can jump through
      if b:HasModifier("modifier_drop") then
        return
      end
       if a.type == "AABB" and normal.z <= 0 or b.velocity.z > 0 then
        return
      end
    end
    a.unitsOnPlatform[b] = GameRules:GetGameTime() + (FrameTime()*4)
  elseif b.IsPlatform and not a.IsPlatform then
    movingUnit = a
    if a.IsSmashUnit and b.IsPassable and a.HasModifier  then
      -- Check z values to decide if you can jump through
      if a:HasModifier("modifier_drop") then
        return
      end
      if b.type == "AABB" and normal.z >= 0 or a.velocity.z > 0 then
        return
      end
    end
    b.unitsOnPlatform[a]  = GameRules:GetGameTime() + (FrameTime()*4)
  end

  if movingUnit then -- Only one unit moves, simply fix that
    --local orig = Vec(normal.x,math.min(0,normal.z))

    movingUnit:SetAbsOrigin(movingUnit:GetAbsOrigin() + (normal * penetration))
  else
    -- Simply calculate % of mass and use that to resolve it
    -- Same for velocity
    -- This should be close enough to reality, and this will rarely be executed.
    local totalMass = a.mass + b.mass
    local aMassPct = a.mass/totalMass -- from 0 to 1
    local bMassPct = b.mass/totalMass -- from 0 to 1

    local aVelLength = Physics2D:GetStaticVelocity(a):Length()
    local bVelLength = Physics2D:GetStaticVelocity(b):Length()

    local totalVel = aVelLength + bVelLength
    local aVellPct = aVelLength/totalVel -- from 0 to 1
    local bVellPct = bVelLength/totalVel -- from 0 to 1

    local aSimpleForce = aMassPct * aVellPct
    local bSimpleForce = bMassPct * bVellPct
    local tSimpleForce = aSimpleForce + bSimpleForce
    local aSimpleForce = aSimpleForce/tSimpleForce -- from 0 to 1
    local bSimpleForce = bSimpleForce/tSimpleForce -- from 0 to 1

    a:SetAbsOrigin(a:GetAbsOrigin() + normal * penetration * aSimpleForce)
    b:SetAbsOrigin(b:GetAbsOrigin() + -1* normal * penetration * bSimpleForce)
  end
end

function CheckCollision(a,b)
 -- Return the kind of interaction a and b have
  if a.IsPlatform then
    if b.IsPlatform then 
      return COLLISION_CORRECT
    elseif b.IsSmashUnit then
      return COLLISION_CORRECT_OR_RESOLVE
    elseif b.IsProjectile then -- Must be projectile?
      return COLLISION_RESOLVE
    end
  elseif a.IsSmashUnit then
    if b.IsProjectile then
      return COLLISION_RESOLVE
    end
  elseif a.IsProjectile then
    if b.IsProjectile then
      return COLLISION_RESOLVE
    end
  end

  if b.IsPlatform then
    if a.IsSmashUnit then
      return COLLISION_CORRECT_OR_RESOLVE
    elseif a.IsProjectile then
      return COLLISION_RESOLVE
    end
  elseif b.IsSmashUnit then
    if a.IsProjectile then
      return COLLISION_RESOLVE
    end
  end
  return nil
end



function Physics2D:Think()
  -- dt is always FrameTime()
  local ftinv = 1/FrameTime()

  -- Remove null values from table
  RemoveNullFromTable(Physics2D.units)

  -- Do static movement
  for _,unit in pairs(Physics2D.units) do
    if unit.draw then
      local origin = unit:GetAbsOrigin() or unit.location
      if unit.type == "circle" then
        DebugDrawSphere(origin,Vector(255,0,0),1,unit.radius,true,2*FrameTime())
      elseif unit.type == "AABB" then
        DebugDrawLine(origin+Vec(-unit.width/2,-unit.height/2),origin+Vec(unit.width/2,-unit.height/2),255,0,0,true,2*FrameTime())
        DebugDrawLine(origin+Vec(-unit.width/2,-unit.height/2),origin+Vec(-unit.width/2,unit.height/2),255,0,0,true,2*FrameTime())
        DebugDrawLine(origin+Vec(unit.width/2,unit.height/2),origin+Vec(unit.width/2,-unit.height/2),255,0,0,true,2*FrameTime())
        DebugDrawLine(origin+Vec(unit.width/2,unit.height/2),origin+Vec(-unit.width/2,unit.height/2),255,0,0,true,2*FrameTime())
      end
    end

    local staticSum = Physics2D:GetStaticVelocity(unit)
    unit.pos = staticSum + (unit:GetAbsOrigin() or unit.location)
    if unit.GetAbsOrigin then
      unit:SetAbsOrigin(unit.pos)
    end
    --unit.IsOnPlatfom = nil
    if unit.unitsOnPlatform then 
      for k,v in pairs(unit.unitsOnPlatform) do
        if k:IsNull() or v < GameRules:GetGameTime() then
         --table.remove(unit.unitsOnPlatform,k)
          unit.unitsOnPlatform[k] = nil

        end
      end
    end
  end

  -- Correct all collisons caused by this
  for i = 1,#Physics2D.units-1 do
    if not Physics2D.units[i]["destroyed"] then
      for j = i+1,#Physics2D.units do
        if not Physics2D.units[j]["destroyed"] then
          local collision

          -- Check if a correction has to be made
          if CheckCollision(self.units[i],self.units[j]) == COLLISION_CORRECT or CheckCollision(self.units[i],self.units[j]) == COLLISION_CORRECT_OR_RESOLVE then
            if self.units[i]["type"] == "AABB" then
              if self.units[j]["type"] == "AABB" then
                collision = AABBvsAABB(self.units[i],self.units[j])
              elseif self.units[j]["type"] == "circle" then
                collision = AABBvsCircle(self.units[i],self.units[j])
              end
            elseif self.units[i]["type"] == "circle" then
              if self.units[j]["type"] == "AABB" then
                --collision = CirclevsAABB(self.units[i],self.units[j])
                collision = CirclevsAABB(self.units[i],self.units[j]) 
                --collision = AABBvsCircle(self.units[j],self.units[i])
              elseif self.units[j]["type"] == "circle" then
                --collision = CirclevsCircle(self.units[i],self.units[j])
              end
            end
          end
          if collision then -- Collision is a table containing objects, normal and penetration
            CorrectPosition(collision)
          end
        end
      end
    end
  end

  -- Calculate next position for each unit based on physics position
  for n,unit in pairs(Physics2D.units) do
    local origin = unit:GetAbsOrigin() or unit.location
    unit.velocity = Physics2D:CalculateVelocity(unit)
    unit.pos = origin + unit.velocity
  end
  -- Check for collision between them
  -- Don't check twice
  for i = 1,#Physics2D.units-1 do
    if not Physics2D.units[i]["destroyed"] then
      for j = i+1,#Physics2D.units do
        if not Physics2D.units[i]["destroyed"] then
          local collision
          if CheckCollision(self.units[i],self.units[j]) == COLLISION_RESOLVE or CheckCollision(self.units[i],self.units[j]) == COLLISION_CORRECT_OR_RESOLVE then
            if self.units[i]["type"] == "AABB" then
              if self.units[j]["type"] == "AABB" then
                collision = AABBvsAABB(self.units[i],self.units[j])
              elseif self.units[j]["type"] == "circle" then
                collision = CirclevsAABB(self.units[j],self.units[i]) 
              end
            elseif self.units[i]["type"] == "circle" then
              if self.units[j]["type"] == "AABB" then
                collision = CirclevsAABB(self.units[i],self.units[j])
              elseif self.units[j]["type"] == "circle" then
                collision = CirclevsCircle(self.units[i],self.units[j])
              end
            end
          end
          if collision then -- Collision is a table containing objects, normal and penetration
            ResolveCollision(collision)
          end
        end
      end
    end
  end

  -- Update unit positions
  for _,unit in pairs(Physics2D.units) do
    -- Rotate unit
    if unit.type == "circle" then
      Physics2D:RotateRollingUnits(unit)
    end
    -- Update velocity
    unit.location = unit:GetAbsOrigin() + unit.velocity
    --if unit.location.z < GetGroundPosition(unit.location,unit).z then
    --  unit.location.z = GetGroundPosition(unit.location,unit).z
    --end
    if not unit.IsPlatform then
      unit:SetAbsOrigin(unit.location)
    end


  end
end

function Physics2D:Init()
  -- Start a timer to run every frame to control interactions
  if self.started then return end
  self.started = true
  Physics2D.units = Physics2D.units or {}
  Timers:CreateTimer(FrameTime()*1,function()
    Physics2D:Think()
    if GameRules:State_Get() < DOTA_GAMERULES_STATE_POST_GAME then
      return FrameTime()*1
    end
  end)
end

Physics2D:Init()

Physics2D.materials = {
  Rock = {Density = 0.6,  Restitution = 0.1},
  Wood = {Density = 0.3,  Restitution = 0.2},
  Metal = {Density = 1.2,  Restitution = 0.05},
  Projectile = {Density = 0.01,  Restitution = 0.5},
  BouncyBall = {Density = 0.3,  Restitution = 0.5},
  SuperBall = {Density = 0.1,  Restitution = 0.95},
  Pillow = {Density = 0.1,  Restitution = 0.2},
  Static = {Density = 0.0,  Restitution = 0.4},
  BasePlatform = {Density = 0.1,  Restitution = 0.5},
  Platform = {Density = 0.1,  Restitution = 0.5},
  Unit = {Density = 0.25, Restitution = 0.00}
}


function Physics2D:CalculateMass(sType,keys,sMaterial)
  local mass = 1
  if not sMaterial or not self.materials[sMaterial] then
    sMaterial = "Platform"
  end

  --[[if sType == "circle" then
    mass = self.materials[sMaterial]["Density"] * math.pi * math.pow(keys[1],2)
  elseif sType == "AABB" then
    mass = self.materials[sMaterial]["Density"] * keys[1] * keys[2]
  end]]
  local inv_mass = 1/mass
  if inv_mass == 0 or IsInf(inv_mass) then inv_mass = 1 end
  --[[
  local inertia = (1/12)*mass*keys[1]
  local inv_intertia = 1/ inertia
  if inv_intertia == 0 then inv_intertia = 1 end]]

  return mass, inv_mass, self.materials[sMaterial]["Restitution"]--,inertia,inv_intertia
end



function Vec(x,z) -- Turns a 2d vector into a 3d one
  if x == 0 and not z then --Vec(0)
    return Vector(0,0,0)
  end
  return Vector(x,0,z)
end


function Physics2D:CalculateVelocity(hUnit)
  -- This should return physics velocity + static velocity
  -- Static velocity is caused by movement and is stored by name so it can be removed

  if hUnit.IsPlatform then return Vec(0) end
  if hUnit.IsTimeLocked then
    hUnit.vOriginalVelocity = hUnit.velocity
    return Vec(0)
  end

  if hUnit.IsProjectile then
    if hUnit.IsProjectile == "Tracking" then
      Physics2D:ManageTrackingProjectile(hUnit)
    elseif hUnit.IsProjectile then
      Physics2D:ManageLinearProjectile(hUnit)
    end
    --if hUnit.velocity:Length() > 50 then
    --  hUnit.velocity = hUnit.velocity:Normalized() * 50
    --end
    return hUnit.velocity
  else
    --hUnit.velocity = hUnit.velocity*0.99
    if LengthSquared(hUnit.velocity) < 0.5 then
      hUnit.velocity = Vec(0)
    end
  end
  
  local vel = hUnit.velocity

  -- Gravity
  local vel = (hUnit.velocity)
  if hUnit.gravity then
    vel = vel + Vec(0,-1)
    vel.z = math.max(-20,vel.z)
  end
  -- Maximum velocity for units
  if hUnit.IsSmashUnit then
    vel = vel * 0.986
    vel.z = math.min(45,vel.z)
  end
  vel.y=0
  return vel
end

function Physics2D:RotateRollingUnits(hUnit)
  if hUnit.IsPlatform then return end
  local vel = hUnit.velocity
  local angles = hUnit:GetAngles()
  local velRotation = 0.5*vel.x
  hUnit:SetAngles(angles.x+velRotation,angles.y,angles.z)
end

function Physics2D:GetStaticVelocity(hUnit,sName)
  if hUnit.IsTimeLocked then return Vec(0) end
  if sName then return hUnit.staticVelTable.sName end
  local sum = Vec(0,0)
  for k,v in pairs(hUnit.staticVelTable) do
    sum = sum + v
  end
  return sum
end

function Physics2D:ClearStaticVelocity(hUnit)
  hUnit.staticVelTable = {}
end

function Physics2D:SetStaticVelocity(hUnit,sName,vVelocity)
  hUnit.staticVelTable["sName"] = vVelocity 
end

function Physics2D:AddPhysicsVelocity(hUnit,vVelocity)
  hUnit.velocity = hUnit.velocity + vVelocity
end

function Physics2D:ClearPhysicsVelocity(hUnit)
  hUnit.velocity = Vec(0)
end