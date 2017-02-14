function GameMode:FilterExecuteOrder(filterTable)
  local units = filterTable["units"]
  local issuer = filterTable["issuer_player_id_const"]
  local order_type = filterTable["order_type"]
  local abilityIndex = filterTable["entindex_ability"]
  local ability = EntIndexToHScript(abilityIndex)
  local targetIndex = filterTable["entindex_target"]
  local target = EntIndexToHScript(targetIndex)
  return true
  --[[ if issuer == -1 then 
    return true
  else
    return false
  end
    
  if order_type ~= DOTA_UNIT_ORDER_CAST_NO_TARGET then
    return false
  else
    return true
  end]]
  

end