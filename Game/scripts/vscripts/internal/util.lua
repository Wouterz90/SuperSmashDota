function DebugPrint(nDebugValue,debugString)
  local spew = Convars:GetInt('barebones_spew') or 0
  if spew == 0 and LUA_DEBUG_SPEW then
    spew = LUA_DEBUG_SPEW
  end
  
  if spew >= nDebugValue then
    print(debugString)
  end
end

function DebugPrintTable(nDebugValue,debugTable)
  local spew = Convars:GetInt('barebones_spew') or 0
  if spew == 0 and LUA_DEBUG_SPEW then
    spew = LUA_DEBUG_SPEW
  end

  if spew >= nDebugValue then
    PrintTable(nDebugValue)
  end
end

function PrintTable(t, indent, done)
  --print ( string.format ('PrintTable type %s', type(keys)) )
  if type(t) ~= "table" then return end

  done = done or {}
  done[t] = true
  indent = indent or 0

  local l = {}
  for k, v in pairs(t) do
    table.insert(l, k)
  end

  table.sort(l)
  for k, v in ipairs(l) do
    -- Ignore FDesc
    if v ~= 'FDesc' then
      local value = t[v]

      if type(value) == "table" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..":")
        PrintTable (value, indent + 2, done)
      elseif type(value) == "userdata" and not done[value] then
        done [value] = true
        print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
      else
        if t.FDesc and t.FDesc[v] then
          print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
        else
          print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
        end
      end
    end
  end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end




--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables( unit )
  unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            print(model:GetModelName())
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables( unit )
  for i,v in pairs(unit.hiddenWearables) do
    v:RemoveEffects(EF_NODRAW)
  end
end


function isPointInsidePolygon(point, polygon) -- This is used for the x,y coordiantes from the screen
  local oddNodes = false
  local j = #polygon
  for i = 1, #polygon do
      if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
          if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
              oddNodes = not oddNodes
          end
      end
      j = i
  end
  return oddNodes
end

function IsPointInsidePolygon(point, polygon) -- Could be used to detect collision
  local oddNodes = false
  local j = #polygon
  for i = 1, #polygon do
      if (polygon[i].z < point.z and polygon[j].z >= point.z or polygon[j].z < point.z and polygon[i].z >= point.z) then
          if (polygon[i].x + ( point.z - polygon[i].z ) / (polygon[j].z - polygon[i].z) * (polygon[j].x - polygon[i].x) < point.x) then
              oddNodes = not oddNodes
          end
      end
      j = i
  end
  return oddNodes
end

-- function found (http://stackoverflow.com/questions/15706270/sort-a-table-in-lua)
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function CDOTA_BaseNPC:CanCast(hAbility) -- A check for abilities, ran when the caster starts till it's cast point time is over
  DebugPrint(1,"[SMASH] [UTIL] CanCast")
  --if self:HasModifier("modifier_smash_stun") then return false end
  if string.find(hAbility:GetAbilityName(),"special") and self:HasModifier("modifier_smash_silence") then
    EmitSoundOnClient("General.Cancel",self:GetPlayerOwner())
    return false 
  end
  if string.find(hAbility:GetAbilityName(),"basic") and self:HasModifier("modifier_smash_disarm") then
    EmitSoundOnClient("General.Cancel",self:GetPlayerOwner())
    return false 
  end
  local time = GameRules:GetGameTime()
  Timers:CreateTimer(1/32,function()
    DebugPrint(2,"[SMASH] [TIMER] [UTIL] CanCast",hAbility:GetAbilityName())
    if not IsValidEntity(self) or not IsValidEntity(hAbility) then
      
      return nil  
    end
    -- If the caster interupted the ability manually stop running the timer.
    if not hAbility:IsInAbilityPhase() then 
      
      return nil 
    end

    -- Interupt and stop the timer if it would become illegal while casting
    if (string.find(hAbility:GetAbilityName(),"special") or self:IsChanneling()) and self:HasModifier("modifier_smash_silence") then
      self:Interrupt()
      
      return nil 
    end
    if string.find(hAbility:GetAbilityName(),"basic") and self:HasModifier("modifier_smash_disarm") then
      self:Interrupt()
      
      return nil 
    end

    -- Stop running this after cast point period has expired.
    if (GameRules:GetGameTime() - time) >= hAbility:GetCastPoint() then
      
      return nil
    else
      
      return 1/32
    end
    
    return nil
  end)
  return true
end



function FilterUnitsBasedOnHeight(tableUnits,vOrigin,flRadius)
  local units = {}
  for k,v in pairs (tableUnits) do
    if (vOrigin-v:GetAbsOrigin()):Length() <= flRadius then
      table.insert(units,v)
    end
  end
  return units
end

function StoreSpecialKeyValues(object,ability)
  if not ABILITIES_TXT then
    ABILITIES_TXT = LoadKeyValues("scripts/npc/npc_abilities.txt")
    for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_override.txt")) do ABILITIES_TXT[k] = v end
    for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_custom.txt")) do ABILITIES_TXT[k] = v end
  end

  if not ability then ability = object end

  for k,v in pairs(ABILITIES_TXT[ability:GetName()]["AbilitySpecial"]) do
    for K,V in pairs(v) do
      if K ~= "var_type" and K ~= "LinkedSpecialBonus" then
        local array = StringToArray(V)
        object[tostring(K)] = tonumber(array[ability:GetLevel()]) or tonumber(array[#array])
      end
    end
  end
end

function StringToArray(inputString, seperator)
  if not seperator then seperator = " " end
  local array={}
  local i=1

  for str in string.gmatch(inputString, "([^"..seperator.."]+)") do
    array[i] = str
    i = i + 1
  end
  return array
end

function Reload_AbilityKeyValues()
  print("Reloading Ability files")
  ABILITIES_TXT = LoadKeyValues("scripts/npc/npc_abilities.txt")
  for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_override.txt")) do ABILITIES_TXT[k] = v end
  for k,v in pairs(LoadKeyValues("scripts/npc/npc_abilities_custom.txt")) do ABILITIES_TXT[k] = v end
end

function GetMinMaxValue(tab) -- Returns average of the minimum and the maximum

  local min = math.huge
  local max = -math.huge
  for k,v in pairs (tab) do

    if v < min then min = v end
    if v > max then max = v end
  end
  return (min+max)/2
end

function CDOTA_BaseNPC:HasModifierFromTable(tab)
  for modifier,b in pairs(tab) do
    if b == true and self:HasModifier(modifier) then
      return true
    end
  end
end

-- Util functions
function math.clamp(min,max,number)
  if number > max then return max end
  if number < min then return min end
  return number
end

function IsNaN(value)
  return value ~= value
end

function IsInf(value)
  return value == math.huge or value == -math.huge
end

function CrossProduct(a,b)
  if a.x and b.x then
    return (a.x * b.z - a.z * b.x)
  elseif a.x then
    return Vec(s * a.z,-s*a.x)
  elseif b.x then
    return Vec(-s * a.z,s*a.x)
  end
  print("Error! No Vector argument in CrossProduct!")
end

function RemoveNullFromTable(tab)
  for i=#tab,1,-1 do
    -- Remove weird positioned stuff first
    if tab[i].location and math.abs(tab[i].location.x) > 10000 or math.abs(tab[i].location.z) > 5000 then
      UTIL_Remove(tab[i])
    end
    if tab[i].RemoveProjectile then
      if IsValidEntity(tab[i]) then
        UTIL_Remove(tab[i])
      end
    end
    if tab[i]:IsNull() then
      table.remove(tab, i)
    end
  end
end

function LengthSquared(vVector)
  return math.pow(vVector.x,2) + math.pow(vVector.z,2)
end