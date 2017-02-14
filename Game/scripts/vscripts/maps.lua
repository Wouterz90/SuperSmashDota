function MapSmallSimple()
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

  --platform[1].obstructionObjects = CreateSimpleObstruction(platform[1].radius, platform[1].height,platform[1]:GetAbsOrigin())

  wall[1] = platform[1]
  
  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(-1024,0,900))
  platform[2]:SetModelScale(1)
  platform[2].radius = 256
  platform[2].height = 32

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
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[3].unitsOnPlatform = {}
  MovePlatform(platform[3],6,"up",3)
  --wall[3] = platform[3]
end

function MapSmallMedium()
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

  --platform[1].obstructionObjects = CreateSimpleObstruction(platform[1].radius, platform[1].height,platform[1]:GetAbsOrigin())

  wall[1] = platform[1]
  
  platform[2] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[2]:SetAbsOrigin(Vector(1000,0,1300))
  platform[2]:SetModelScale(1)
  platform[2].radius = 128
  platform[2].height = 32
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[2].unitsOnPlatform = {}
  MovePlatform(platform[2],6,"down",3)
  

  
  
  platform[3] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform512_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[3]:SetAbsOrigin(Vector(0,0,1000))
  platform[3]:SetModelScale(1)
  platform[3].radius = 256
  platform[3].height = 32
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[3].unitsOnPlatform = {}
  --MovePlatform(platform[3],6,"up",3)
  
  platform[4] = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/platform256_128_64.vmdl", DefaultAnim=animation, targetname=DoUniqueString("prop_dynamic")})
  platform[4]:SetAbsOrigin(Vector(-1000,0,1300))
  platform[4]:SetModelScale(1)
  platform[4].radius = 128
  platform[4].height = 32
  --platform[3].obstructionObjects = CreateSimpleObstruction(platform[3].radius, platform[3].height,platform[3]:GetAbsOrigin())
  
  platform[4].unitsOnPlatform = {}
  MovePlatform(platform[4],6,"down",3)
end