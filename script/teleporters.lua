-- TODO 
-- In teleporters and out teleporters
-- hash map of positions
-- check in and out
-- landmine event
-- sends all nearby players
-- trigger effect could spawn next teleporter with a timeout
-- maybe the mine just doesnt die
-- check the event entity on a hash map for partners

-- On built, array of player index + hashmap of entity number pointing to player index data
-- I had it working, but actually have a better idea - waiting on some merge
local teleporters = {
  data = {
    players = {},
    owners = {},
    positions = {}
  },
}

local try_to_link = function(data)
  if not (data.entry and data.exit) then return end
  if not (data.entry.valid and data.exit.valid) then return end
  data.entry.active = true
  data.exit.active = true
end

local entry_died = function(entity)
  local data = teleporters.data.owners[entity.unit_number]
  teleporters.owners[entity.unit_number] = nil
  data.entry = nil  
end

local entry_built = function(entry, index)
  entry.active = false
  entry.force = "enemy"
  teleporters.data.players[index] = teleporters.data.players[index] or {}
  local data = teleporters.data.players[index]
  if data.entry and data.entry.valid then
    entry_died(data.entry)
    data.entry.destroy()
  end
  data.entry = entry
  local map = teleporters.data.owners
  map[entry.unit_number] = data
  local positions = teleporters.data.positions
  positions[entry.position.x] = positions[entry.position.x] or {}
  positions[entry.position.x][entry.position.y] = data
  try_to_link(data)
end

local exit_built = function(exit, index)
  exit.active = false
  exit.force = "enemy"
  teleporters.data.players[index] = teleporters.data.players[index] or {}
  local data = teleporters.data.players[index]
  if data.exit and data.exit.valid then
    exit_removed(data.entry)
    data.exit.destroy()
  end
  data.exit = exit
  try_to_link(data)
end

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.name == "entry" then
    return entry_built(entity, event.player_index)
  end
  if entity.name == "exit" then
    return exit_built(entity, event.player_index)
  end
end

local on_entity_died = function(event)
  local entity = event.entity
  game.print(event.entity == event.cause)
  if not (entity and entity.valid) then return end

  if entity.name == "entry" then
    return entry_died(entity)
  end
  if entity.name == "exit" then
    return exit_died(entity)
  end
end

local on_trigger_created_entity = function(event)
  local entity = event.entity
  if not (entity and entity.valid and entity.name == "entry") then
    return
  end
  teleporters.data.positions[entity.position.x][entity.position.y].entry = entity
  teleporters.data.owners[entity.unit_number] = data
end

local events = {
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_entity_died] = on_entity_died
}

teleporters.on_event = function(event)
  if not (event and event.name) then return end
  local action = events[event.name] or function() return end
  return action(event)
end

teleporters.on_init = function()
  global.teleporters = global.teleporters or teleporters.data
end

teleporters.on_load = function()
  teleporters.data = global.teleporters
end

return teleporters