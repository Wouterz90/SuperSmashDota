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
-- Thanks to TidesofDark ?
function isPointInsidePolygon(point, polygon)
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
