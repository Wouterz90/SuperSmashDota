-- Do not use platform[1] if the platform isn't the lowest one (Like FerrisWheel)




function MapSmall()
  local i = 1
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(0,0,256))
  platform[i].height = 512
  platform[i].mapRadius = 800
  platform[i].radius = 1044
  platform[i].colliderName = tostring(i)
  platform[i].IsPlatform = true
  platform[i].unitsOnPlatform = {}

  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"BasePlatform")

  i= 2
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(650,0,900))
  platform[i].height = 64
  platform[i].mapRadius = 1024
  platform[i].radius = 256
  platform[i].colliderName = tostring(i)
  platform[i].isDestructable = true
  platform[i].IsPlatform = true
  platform[i].IsPassable = true
  platform[i].unitsOnPlatform = {}
  --
  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")


      
  i = 3
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(-650,0,900))
  platform[i].height = 64
  platform[i].mapRadius = 1024
  platform[i].radius = 276
  platform[i].colliderName = tostring(i)
  platform[i].isDestructable = true
  platform[i].IsPlatform = true
  platform[i].IsPassable = true
  platform[i].velocity = Vec(0,0)
  platform[i].unitsOnPlatform = {}
  --MovePlatform(platform[i],6,"up",4)

  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")

  
  i = 4
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_ball_360x3.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(0,0,1200))
  --MakePhysicsUnit(platform[i])
  platform[i].radius = 140
  platform[i].IsPlatform = true
  platform[i].IsPassable = false
  platform[i].isDestructable = true
  platform[i].colliderName = tostring(i)
  platform[i].unitsOnPlatform = {}
  Physics2D:CreateObject("circle",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius,platform[i].radius,"Platform")
  --MovePlatform(platform[i],6,"down",4)
  --platform[i].velocity = Vec(-4,0)

  --[[
  i = 5
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_ball_360x3.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(700,0,1500))
  platform[i].radius = 140
  platform[i].IsPlatform = true
  platform[i].IsPassable = false
  platform[i].isDestructable = true
  platform[i].colliderName = tostring(i)
  platform[i].unitsOnPlatform = {}
  Physics2D:CreateObject("circle",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius,platform[i].radius,"platform")]]  


end

function MapMedium()
  local i = 1
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform_medium.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(0,0,256))
  platform[i].height = 512
  platform[i].mapRadius = 800
  platform[i].radius = 1536
  platform[i].colliderName = tostring(i)
  platform[i].IsPlatform = true
  platform[i].unitsOnPlatform = {}

  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"BasePlatform")

  i = 2
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(950,0,1200))
  platform[i].height = 64
  platform[i].mapRadius = 1024
  platform[i].radius = 128
  platform[i].colliderName = tostring(i)
  platform[i].isDestructable = true
  platform[i].IsPlatform = true
  platform[i].IsPassable = true
  platform[i].unitsOnPlatform = {}
  --
  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")
  MovePlatform(platform[i],6,Vec(0,-1),3)

  
  i = 3
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(0,0,1200))
  platform[i].height = 64
  platform[i].mapRadius = 1024
  platform[i].radius = 256
  platform[i].colliderName = tostring(i)
  platform[i].isDestructable = true
  platform[i].IsPlatform = true
  platform[i].IsPassable = true
  platform[i].unitsOnPlatform = {}
  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")
  --MovePlatform(platform[3],6,"up",3)
  i = 4
  platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[i]:SetAbsOrigin(Vector(-950,0,1200))
  platform[i].height = 64
  platform[i].mapRadius = 1024
  platform[i].radius = 128
  platform[i].colliderName = tostring(i)
  platform[i].isDestructable = true
  platform[i].IsPlatform = true
  platform[i].IsPassable = true
  platform[i].unitsOnPlatform = {}
  --
  Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")
  MovePlatform(platform[i],6,Vec(0,-1),3)
end

function MapSmallWalls()
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/base_platform.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,256))
  platform[1]:SetModelScale(1)
  platform[1].radius = 1024
  platform[1].height = 256
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  platform[1].bIsWall = true
  platform[1].mapRadius = 1024

  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(-platform[1].radius,0,platform[1].height+256+116))
  platform[2].radius = 128
  platform[2].height = 32
  platform[2].unitsOnPlatform = {}
  platform[2].canDropThrough = false
  platform[2].bIsWall = true
  RotatePlatform(platform[2],40)

  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(platform[1].radius,0,platform[1].height+256+116))
  platform[3].radius = 128
  platform[3].height = 32
  platform[3].unitsOnPlatform = {}
  platform[3].canDropThrough = false
  platform[3].bIsWall = true
  RotatePlatform(platform[3],-40)
--[[
  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(-platform[1].radius+32,0,platform[1].height+384))
  platform[4].radius = 32 * 1.5
  platform[4].height = 128
  platform[4].unitsOnPlatform = {}
  platform[4].canDropThrough = false
  platform[4].bIsWall = true
  

  platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[5]:SetAbsOrigin(Vector(platform[1].radius-32,0,platform[1].height+384))
  platform[5].radius = 32 * 1.5
  platform[5].height = 128
  platform[5].unitsOnPlatform = {}
  platform[5].canDropThrough = false
  platform[5].bIsWall = true]]


end

function MapSmallDestructable()
  for i=0,8 do
    
    platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[i]:SetAbsOrigin(Vector(-1024+i*256,0,500))
    platform[i].colliderName = tostring(i)
    platform[i].radius = 128
    platform[i].height = 64
    platform[i].isDestructable = true
    platform[i].IsPlatform = true
    platform[i].IsPassable = true
    platform[i].mapRadius = 800
    platform[i].unitsOnPlatform = {}
    platform[i].velocity = Vec(0,0)
    Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")
  end
  platform[1].mapRadius = 800
end

function MapLargeDestructable()
  for i=0,12 do
    platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
    platform[i]:SetAbsOrigin(Vector(-1024+i*256,0,256))
    platform[i].colliderName = tostring(i)
    platform[i].radius = 128
    platform[i].height = 64
    platform[i].isDestructable = true
    platform[i].IsPlatform = true
    platform[i].IsPassable = true
    platform[i].mapRadius = 800
    platform[i].unitsOnPlatform = {}
    Physics2D:CreateObject("AABB",platform[i]:GetAbsOrigin(),false,false,platform[i],platform[i].radius*2,platform[i].height,"Platform")
  end
  platform[1].mapRadius = 800
end

function MapFerrisWheel()
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,100))
  platform[1]:SetModelScale(1)
  platform[1].radius = 512
  platform[1].height = 32
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
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

  platform[10] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[10]:SetAbsOrigin(Vector(0,0,900))
  platform[10]:SetModelScale(1)
  platform[10].radius = 128
  platform[10].height = 32
  platform[10].isDestructable = true
  platform[10].canDropThrough = true
  platform[10].mapRadius = 1000
  platform[10].unitsOnPlatform = {}

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
  platform[1].canDropThrough = false
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
    platform[2].canDropThrough = false
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


function MapSmallFunnel()
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/round_platform_1024_1024_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,400))
  platform[1]:SetModelScale(1)
  platform[1].radius = 512
  platform[1].height = 32
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  platform[1].isDestructable = false
  platform[1].mapRadius = 1024 + 512 - 64

  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(512+170,0,700))
  platform[2]:SetModelScale(1)
  platform[2].radius = 256
  platform[2].height = 32
  platform[2].isDestructable = true
  platform[2].canDropThrough = false
  platform[2].unitsOnPlatform = {}
  RotatePlatform(platform[2],-30)

  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(-512-170,0,700))
  platform[3]:SetModelScale(1)
  platform[3].radius = 256
  platform[3].height = 32
  platform[3].isDestructable = true
  platform[3].canDropThrough = false
  platform[3].unitsOnPlatform = {}
  RotatePlatform(platform[3],30)

  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(700+200,0,1300))
  platform[4]:SetModelScale(1)
  platform[4].radius = 256
  platform[4].height = 32
  platform[4].isDestructable = true
  platform[4].canDropThrough = true
  platform[4].unitsOnPlatform = {}
  RotatePlatform(platform[4],-40)

  platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[5]:SetAbsOrigin(Vector(0,0,950))
  platform[5]:SetModelScale(1)
  platform[5].radius = 256
  platform[5].height = 32
  platform[5].isDestructable = true
  platform[5].canDropThrough = true
  platform[5].unitsOnPlatform = {}  

  platform[6] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[6]:SetAbsOrigin(Vector(-700-200,0,1300))
  platform[6]:SetModelScale(1)
  platform[6].radius = 256
  platform[6].height = 32
  platform[6].isDestructable = true
  platform[6].canDropThrough = true
  platform[6].unitsOnPlatform = {}
  RotatePlatform(platform[6],40)
 
--[[
  platform[9] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[9]:SetAbsOrigin(Vector(0,0,1200))
  platform[9]:SetModelScale(1)
  platform[9].radius = 256
  platform[9].height = 32
  platform[9].isDestructable = true
  platform[9].canDropThrough = true
  platform[9].unitsOnPlatform = {}  

   
  platform[7] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[7]:SetAbsOrigin(Vector(-platform[1].radius+12,0,platform[1].height+320))
  platform[7].radius = 32 * 1.5
  platform[7].height = 160
  --platform[7].unitsOnPlatform = {}
  platform[7].canDropThrough = false
  platform[7].bIsWall = true

  platform[8] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/wall64_128_256.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[8]:SetAbsOrigin(Vector(platform[1].radius-12,0,platform[1].height+320))
  platform[8].radius = 32 * 1.5
  platform[8].height = 160
  --platform[8].unitsOnPlatform = {}
  platform[8].canDropThrough = false
  platform[8].bIsWall = true]]
end

function MapPyramidSmall()
  local nPlatforms = 6
  for i=0,nPlatforms do
    --if math.fmod(i, 2) == 0 then
      platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i]:SetAbsOrigin(Vector(-600+i*200,0,400))
      platform[i]:SetModelScale(1)
      platform[i].radius = 128
      platform[i].height = 32
      platform[i].isDestructable = true
      platform[i].canDropThrough = true
      platform[i].mapRadius = 600
      platform[i].unitsOnPlatform = {}
      --if i == 0 then
      --  platform[1] = platform[0]
      --end
    --end
  end
  local nPlatforms = 5
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+8] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+8]:SetAbsOrigin(Vector(-400+i*200,0,800))
      platform[i+8]:SetModelScale(1)
      platform[i+8].radius = 128
      platform[i+8].height = 32
      platform[i+8].isDestructable = true
      platform[i+8].canDropThrough = true
      platform[i+8].mapRadius = 600
      platform[i+8].unitsOnPlatform = {}
    end
  end
  local nPlatforms = 3
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+13] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+13]:SetAbsOrigin(Vector(-200+i*200,0,1200))
      platform[i+13]:SetModelScale(1)
      platform[i+13].radius = 128
      platform[i+13].height = 32
      platform[i+13].isDestructable = true
      platform[i+13].canDropThrough = true
      platform[i+13].mapRadius = 600
      platform[i+13].unitsOnPlatform = {}
    end
  end
  local nPlatforms = 1
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+14] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+14]:SetAbsOrigin(Vector(-0+i*200,0,1600))
      platform[i+14]:SetModelScale(1)
      platform[i+14].radius = 128
      platform[i+14].height = 32
      platform[i+14].isDestructable = true
      platform[i+14].canDropThrough = true
      platform[i+14].mapRadius = 600
      platform[i+14].unitsOnPlatform = {}
    end
  end
end

function MapPyramidLarge()
  local nPlatforms = 8
  for i=0,nPlatforms do
    --if math.fmod(i, 2) == 0 then
      platform[i] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i]:SetAbsOrigin(Vector(-800+i*200,0,300))
      platform[i]:SetModelScale(1)
      platform[i].radius = 128
      platform[i].height = 32
      platform[i].isDestructable = true
      platform[i].canDropThrough = false
      platform[i].mapRadius = 800
      platform[i].unitsOnPlatform = {}
      --if i == 0 then
      --  platform[1] = platform[0]
      --end
    --end
  end
  local nPlatforms = 7
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+10] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+10]:SetAbsOrigin(Vector(-600+i*200,0,700))
      platform[i+10]:SetModelScale(1)
      platform[i+10].radius = 128
      platform[i+10].height = 32
      platform[i+10].isDestructable = true
      platform[i+10].canDropThrough = true
      platform[i+10].mapRadius = 800
      platform[i+10].unitsOnPlatform = {}
    end
  end
  local nPlatforms = 5
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+17] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+17]:SetAbsOrigin(Vector(-400+i*200,0,1100))
      platform[i+17]:SetModelScale(1)
      platform[i+17].radius = 128
      platform[i+17].height = 32
      platform[i+17].isDestructable = true
      platform[i+17].canDropThrough = true
      platform[i+17].mapRadius = 800
      platform[i+17].unitsOnPlatform = {}
    end
  end
  local nPlatforms = 3
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+20] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+20]:SetAbsOrigin(Vector(-200+i*200,0,1500))
      platform[i+20]:SetModelScale(1)
      platform[i+20].radius = 128
      platform[i+20].height = 32
      platform[i+20].isDestructable = true
      platform[i+20].canDropThrough = true
      platform[i+20].mapRadius = 800
      platform[i+20].unitsOnPlatform = {}
    end
  end
  local nPlatforms = 1
  for i=0,nPlatforms do
    if math.fmod(i, 2) == 0 then
      platform[i+23] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
      platform[i+23]:SetAbsOrigin(Vector(-0+i*200,0,1900))
      platform[i+23]:SetModelScale(1)
      platform[i+23].radius = 128
      platform[i+23].height = 32
      platform[i+23].isDestructable = true
      platform[i+23].canDropThrough = true
      platform[i+23].mapRadius = 800
      platform[i+23].unitsOnPlatform = {}
    end
  end
end

function MapTruck()

  -- Transport
  -- R = 490

  -- In the front there is a platform from -490 to 410
  -- The window goes from -410, -7 to -364,100
  -- Next platform -364 to -250 @ 100
  -- Final platform at 171 till 490


  local baseVector = Vector(0,0,160)
  --Numbers are meaningless, will be arranged on from highest to lowest
  platform[1] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/transport_viechle.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[1]:SetAbsOrigin(Vector(0,0,160))
  platform[1]:SetForwardVector(Vector(0,1,0))
  platform[1]:SetModelScale(45)
  platform[1].radius = 200
  platform[1].height = 0
  platform[1].unitsOnPlatform = {}
  platform[1].canDropThrough = false
  platform[1].mapRadius = 330
  --MovePlatform(platform[1],50,"right",6)

  platform[1].bIsWall = false

  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(baseVector+Vector(-125,0,0))
  platform[2].radius = 370
  platform[2].height = 170
  platform[2].unitsOnPlatform = {}
  platform[2].canDropThrough = false
  platform[2].mapRadius = 330
  platform[2].bIsWall = true
  --MovePlatform(platform[2],50,"right",6)

  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(baseVector+Vector(290,0,0))
  platform[3].radius = 57
  platform[3].height = 100
  platform[3].unitsOnPlatform = {}
  platform[3].canDropThrough = false
  platform[3].mapRadius = 330
  platform[3].bIsWall = true
  --MovePlatform(platform[3],50,"right",6)

  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(baseVector+Vector(380,0,-30))
  platform[4].radius = 90
  platform[4].height = 100
  platform[4].unitsOnPlatform = {}
  platform[4].canDropThrough = false
  platform[4].mapRadius = 330
  platform[4].bIsWall = true
  RotatePlatform(platform[4],50)
  --MovePlatform(platform[4],50,"right",6)

  platform[5] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/development/invisiblebox.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[5]:SetAbsOrigin(baseVector+Vector(450,0,-110))
  platform[5].radius = 40
  platform[5].height = 100
  platform[5].unitsOnPlatform = {}
  platform[5].canDropThrough = false
  platform[5].mapRadius = 330
  platform[5].bIsWall = true
  --MovePlatform(platform[5],50,"right",6)

end

