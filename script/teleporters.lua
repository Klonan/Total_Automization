--[[
  Players can only have a single pair each
  So when a teleporter is built, it destroys any that are assigned to that player ID,
  and stores the data to the new one

  Also the unit_number is put into a map,
  so when the entity dies, we can cheaply lookup which player it belongs to

  If a entry died with itself as a cause, it should teleport people
]]

local teleporters = {
  data = {
    players = {},
    owners = {}
  },
}

local try_to_link = function(data)
  if not (data.entry and data.exit) then return end
  if not (data.entry.valid and data.exit.valid) then return end
  data.entry.active = true
  data.exit.active = true
end

local entry_died = function(entity, cause)
  local owners = teleporters.data.owners
  local data = owners[entity.unit_number]
  owners[entity.unit_number] = nil
  local exit = data.exit
  if not exit and exit.valid then return end
  if entity == cause then
    local surface = entity.surface
    local origin = entity.position
    if (exit and exit.valid) then
      local destination = exit.position
      local destination_surface = exit.surface
      for k, character in pairs (surface.find_entities_filtered{type = "player", area = {{origin.x - 2, origin.y - 2},{origin.x + 2, origin.y + 2}}}) do
        local position = destination_surface.find_non_colliding_position(character.name, destination, 4, 0.5) or destination
        if character.player then
          character.player.teleport(position, destination_surface.index)
        end
      end
    end
    local new = surface.create_entity{name = entity.name, force = entity.force, position = entity.position}
    data.entry = new
    owners[new.unit_number] = data
  else
    exit.active = false
  end
end

local exit_died = function(entity)
  local owners = teleporters.data.owners
  local data = owners[entity.unit_number]
  owners[entity.unit_number] = nil
  if data.entry then
    data.entry.active = false
  end
end

local entry_built = function(entry, index)
  entry.active = false
  entry.force = "enemy"
  teleporters.data.players[index] = teleporters.data.players[index] or {}
  local data = teleporters.data.players[index]
  if data.entry and data.entry.valid then
    data.entry.die()
  end
  data.entry = entry
  teleporters.data.owners[entry.unit_number] = data
  try_to_link(data)
end

local exit_built = function(exit, index)
  exit.active = false
  exit.force = "enemy"
  teleporters.data.players[index] = teleporters.data.players[index] or {}
  local data = teleporters.data.players[index]
  if data.exit and data.exit.valid then
    data.exit.die()
  end
  data.exit = exit
  teleporters.data.owners[exit.unit_number] = data
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
  if not (entity and entity.valid) then return end
  if entity.name == "entry" then
    return entry_died(entity, event.cause)
  end
  if entity.name == "exit" then
    return exit_died(entity)
  end
end

local events = {
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