local name = names.entities.logistic_beacon

local data =
{
  chests = {}
}

local beacon_built = function(entity)
  game.print("helo")
  local chest = entity.surface.create_entity{name = name.." Chest", position = entity.position, force = entity.force}
  chest.minable = false
  chest.destructible = false
  data.chests[entity.unit_number] = chest
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
  local chest = data.chests[unit_number]
  if not (chest and chest.valid) then return end
  chest.destroy()
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

lib.on_event = handler(events)

lib.on_init = function()
  global.logistic_beacon = global.logistic_beacon or data
end

lib.on_load = function()
  data = global.logistic_beacon or data
end

return lib
