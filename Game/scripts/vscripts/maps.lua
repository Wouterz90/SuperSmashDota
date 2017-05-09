-- Do not use platform[1] if the platform isn't the lowest one (Like FerrisWheel)

function MapSmall()
--[[local background = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/big_background.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  background:SetAbsOrigin(Vector(0,256,0))
  background:SetModelScale(2)]]
  
  --Numbers are meaningless, will be arranged on from highest to lowest
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,256))
  platform[1]:SetModelScale(1)
  platform[1].radius = 1024
  platform[1].height = 256
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  platform[1].mapRadius = 1024

  --platform[1].obstructionObjects = CreateSimpleObstruction(platform[1].radius, platform[1].height,platform[1]:GetAbsOrigin())

  wall[1] = platform[1]
  
  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(-1024,0,900))
  platform[2]:SetModelScale(1)
  platform[2].radius = 256
  platform[2].height = 32
  platform[2].isDestructable = true
  platform[2].canDropThrough = true

  --platform[2].obstructionObjects = CreateSimpleObstruction(platform[2].radius, platform[2].height,platform[2]:GetAbsOrigin())
  --platform[2].rotation = 18
  --platform[2]:SetAngles(platform[2].rotation,0,0)
  platform[2].unitsOnPlatform = {}
  MovePlatform(platform[2],10,"right",6)

  --wall[2] = platform[2]
  
  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(0,0,800))
  platform[3]:SetModelScale(1)
  platform[3].radius = 128
  platform[3].height = 32
  platform[3].isDestructable = true
  platform[3].canDropThrough = true
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[3].unitsOnPlatform = {}
  MovePlatform(platform[3],6,"up",3)
  --wall[3] = platform[3]
end

function MapMedium()
--[[local background = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/big_background.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  background:SetAbsOrigin(Vector(0,256,0))
  background:SetModelScale(2)]]
  
  --Numbers are meaningless, will be arranged on from highest to lowest
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform_medium.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,256))
  platform[1]:SetModelScale(1)
  platform[1].radius = 1536
  platform[1].height = 256
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  platform[1].mapRadius = 1536

  --platform[1].obstructionObjects = CreateSimpleObstruction(platform[1].radius, platform[1].height,platform[1]:GetAbsOrigin())

  wall[1] = platform[1]
  
  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(1000,0,1300))
  platform[2]:SetModelScale(1)
  platform[2].radius = 128
  platform[2].height = 32
  platform[2].isDestructable = true
  platform[2].canDropThrough = true
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[2].unitsOnPlatform = {}
  MovePlatform(platform[2],6,"down",3)
  

  
  
  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(0,0,1000))
  platform[3]:SetModelScale(1)
  platform[3].radius = 256
  platform[3].height = 32
  platform[3].isDestructable = true
  platform[3].canDropThrough = true
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[3].unitsOnPlatform = {}
  --MovePlatform(platform[3],6,"up",3)
  
  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(-1000,0,1300))
  platform[4]:SetModelScale(1)
  platform[4].radius = 128
  platform[4].height = 32
  platform[4].isDestructable = true
  platform[4].canDropThrough = true
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[4].unitsOnPlatform = {}
  MovePlatform(platform[4],6,"down",3)
end

function MapSmallWalls()
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,256))
  platform[1]:SetModelScale(1)
  platform[1].radius = 1024
  platform[1].height = 256
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  wall[1] = platform[1]

  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(-platform[1].radius+32,0,platform[1].height+256))
  platform[2].radius = 32 * 1.5
  platform[2].height = 128
  platform[2].unitsOnPlatform = {}
  platform[2].canDropThrough = false
  wall[2] = platform[2]

  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(platform[1].radius-32,0,platform[1].height+256))
  platform[3].radius = 32 * 1.5
  platform[3].height = 128
  platform[3].unitsOnPlatform = {}
  platform[3].canDropThrough = false
  wall[3] = platform[3]

  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(-platform[1].radius+32,0,platform[1].height+384))
  platform[4].radius = 32 * 1.5
  platform[4].height = 128
  platform[4].unitsOnPlatform = {}
  platform[4].canDropThrough = false
  wall[4] = platform[4]

  platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[5]:SetAbsOrigin(Vector(platform[1].radius-32,0,platform[1].height+384))
  platform[5].radius = 32 * 1.5
  platform[5].height = 128
  platform[5].unitsOnPlatform = {}
  platform[5].canDropThrough = false
  wall[5] = platform[5]
end

function MapSmallDestructable()
  for i=0,8 do
    platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[i]:SetAbsOrigin(Vector(-1024+i*256,0,512))
    platform[i]:SetModelScale(1)
    platform[i].radius = 128
    platform[i].height = 32
    platform[i].isDestructable = true
    platform[i].canDropThrough = false
    platform[i].mapRadius = 1536
    platform[i].unitsOnPlatform = {}
  end
  platform[1].mapRadius = 1536
end

function MapLargeDestructable()
  for i=0,12 do
    platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[i]:SetAbsOrigin(Vector(-1536+i*256,0,512))
    platform[i]:SetModelScale(1)
    platform[i].radius = 128
    platform[i].height = 32
    platform[i].isDestructable = true
    platform[i].canDropThrough = false
    platform[i].mapRadius = 1536
    platform[i].unitsOnPlatform = {}
  end
end

function MapFerrisWheel()
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,100))
  platform[1]:SetModelScale(1)
  platform[1].radius = 512
  platform[1].height = 32
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = true
  platform[1].isDestructable = false
  platform[1].mapRadius = 512

  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(600,0,900))
  platform[2]:SetModelScale(1)
  platform[2].radius = 128
  platform[2].height = 32
  platform[2].isDestructable = true
  platform[2].canDropThrough = true
  platform[2].mapRadius = 1000
  platform[2].unitsOnPlatform = {}
  platform[2].rotationCount = 0
  RotatePlatformAroundPoint(platform[2],Vector(0,0,900),600,0.6,true)

  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(000,0,300))
  platform[3]:SetModelScale(1)
  platform[3].radius = 128
  platform[3].height = 32
  platform[3].isDestructable = true
  platform[3].canDropThrough = true
  platform[3].mapRadius = 1000
  platform[3].unitsOnPlatform = {}
  platform[3].rotationCount = 90
  RotatePlatformAroundPoint(platform[3],Vector(0,0,900),600,0.6,true)
  
  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(-600,0,900))
  platform[4]:SetModelScale(1)
  platform[4].radius = 128
  platform[4].height = 32
  platform[4].isDestructable = true
  platform[4].canDropThrough = true
  platform[4].mapRadius = 1000
  platform[4].unitsOnPlatform = {}
  platform[4].rotationCount = 180
  RotatePlatformAroundPoint(platform[4],Vector(0,0,900),600,0.6,true)

  platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[5]:SetAbsOrigin(Vector(000,0,1500))
  platform[5]:SetModelScale(1)
  platform[5].radius = 128
  platform[5].height = 32
  platform[5].isDestructable = true
  platform[5].canDropThrough = true
  platform[5].mapRadius = 1000
  platform[5].unitsOnPlatform = {}
  platform[5].rotationCount = 270
  RotatePlatformAroundPoint(platform[5],Vector(0,0,900),600,0.6,true)

  platform[6] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[6]:SetAbsOrigin(Vector(300,0,600))
  platform[6]:SetModelScale(1)
  platform[6].radius = 128
  platform[6].height = 32
  platform[6].isDestructable = true
  platform[6].canDropThrough = true
  platform[6].mapRadius = 1000
  platform[6].unitsOnPlatform = {}
  platform[6].rotationCount = 45
  RotatePlatformAroundPoint(platform[6],Vector(0,0,900),600,0.6,true)

  platform[7] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[7]:SetAbsOrigin(Vector(-300,0,600))
  platform[7]:SetModelScale(1)
  platform[7].radius = 128
  platform[7].height = 32
  platform[7].isDestructable = true
  platform[7].canDropThrough = true
  platform[7].mapRadius = 1000
  platform[7].unitsOnPlatform = {}
  platform[7].rotationCount = 135
  RotatePlatformAroundPoint(platform[7],Vector(0,0,900),600,0.6,true)
  
  platform[8] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[8]:SetAbsOrigin(Vector(-300,0,1200))
  platform[8]:SetModelScale(1)
  platform[8].radius = 128
  platform[8].height = 32
  platform[8].isDestructable = true
  platform[8].canDropThrough = true
  platform[8].mapRadius = 1000
  platform[8].unitsOnPlatform = {}
  platform[8].rotationCount = 225
  RotatePlatformAroundPoint(platform[8],Vector(0,0,900),600,0.6,true)

  platform[9] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[9]:SetAbsOrigin(Vector(300,0,1200))
  platform[9]:SetModelScale(1)
  platform[9].radius = 128
  platform[9].height = 32
  platform[9].isDestructable = true
  platform[9].canDropThrough = true
  platform[9].mapRadius = 1000
  platform[9].unitsOnPlatform = {}
  platform[9].rotationCount = 315
  RotatePlatformAroundPoint(platform[9],Vector(0,0,900),600,0.6,true)
end


function MapSliders()
--[[local background = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/big_background.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  background:SetAbsOrigin(Vector(0,256,0))
  background:SetModelScale(2)]]
  
  --Numbers are meaningless, will be arranged on from highest to lowest
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(-1024,0,200))
  platform[1]:SetModelScale(1)
  platform[1].radius = 512
  platform[1].height = 32
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = true
  platform[1].isDestructable = false
  platform[1].mapRadius = 1024 + 512 - 64
  MovePlatform(platform[1],8,"right",8)

  --platform[1].obstructionObjects = CreateSimpleObstruction(platform[1].radius, platform[1].height,platform[1]:GetAbsOrigin())

  --wall[1] = platform[1]
  --Timers:CreateTimer(4,function()
    platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[2]:SetAbsOrigin(Vector(1024,0,500))
    platform[2]:SetModelScale(1)
    platform[2].radius = 512
    platform[2].height = 32
    platform[2].unitsOnPlatform = {}
    platform[2].canDropThrough = true
    platform[2].isDestructable = false
    platform[2].mapRadius = 1024 + 512 - 64
    MovePlatform(platform[2],8,"left",8)
  --end)

  
  
  --Timers:CreateTimer(8,function()
    platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[3]:SetAbsOrigin(Vector(0,0,800))
    platform[3]:SetModelScale(1)
    platform[3].radius = 512
    platform[3].height = 32
    platform[3].unitsOnPlatform = {}
    platform[3].canDropThrough = true
    platform[3].isDestructable = false
    platform[3].mapRadius = 1024 + 512 -64
    --[[Timers:CreateTimer(1,function()
      if platform and not platform[3]:IsNull() then
        RotatePlatform(platform[3],0.05)
        return 1/32
      else
        return -1
      end
    end)]]
    --MovePlatform(platform[3],8,"right",8)
  --end)

  --Timers:CreateTimer(8,function()
    platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[4]:SetAbsOrigin(Vector(-1024,0,1100))
    platform[4]:SetModelScale(1)
    platform[4].radius = 512
    platform[4].height = 32
    platform[4].unitsOnPlatform = {}
    platform[4].canDropThrough = true
    platform[4].isDestructable = false
    platform[4].mapRadius = 1024 + 512 -64
    MovePlatform(platform[4],8,"right",8)
  --end)

  --Timers:CreateTimer(4,function()
    platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[5]:SetAbsOrigin(Vector(1024,0,1400))
    platform[5]:SetModelScale(1)
    platform[5].radius = 512
    platform[5].height = 32
    platform[5].unitsOnPlatform = {}
    platform[5].canDropThrough = true
    platform[5].isDestructable = false
    platform[5].mapRadius = 1024 + 512 -64
    MovePlatform(platform[5],8,"left",8)
  --end)
end

