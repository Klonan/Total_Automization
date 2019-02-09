error("Not used, don't use me.")
local name = names.entities.logistic_beacon

local data =
{
  beacons = {}
}

local beacon_built = function(entity)
  local chest = entity.surface.create_entity{name = name.." Chest", position = entity.position, force = entity.force}
  entity.minable = false
  entity.destructible = false
  data.beacons[chest.unit_number] = entity
end

local on_built = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.name == name then
    beacon_built(entity)
  end
end

local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local unit_number = entity.unit_number
  if not unit_number then return end
  local beacon = data.beacons[unit_number]
  if not (beacon and beacon.valid) then return end
  beacon.destroy()
end

local events =
{
  [defines.events.on_built_entity] = on_built,
  [defines.events.on_robot_built_entity] = on_built,
  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
}

local lib = {}

lib.get_events = function() return events end

lib.on_event = handler(events)

lib.get_events = function() return events end

lib.on_init = function()
  global.logistic_beacon = global.logistic_beacon or data
end

lib.on_load = function()
  data = global.logistic_beacon or data
end

return lib
