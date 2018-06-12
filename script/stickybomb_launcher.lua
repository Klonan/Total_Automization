local lib = {}
local data = {}

local mine_limit =
{
  ["Stickybomb Launcher Mine"] = 8
}

local on_trigger_created_entity = function(event)
  local mine = event.entity
  if not (mine and mine.valid) then return end
  local source = event.source
  if not (source and source.valid) then return end
  local limit = mine_limit[mine.name]
  if not limit then return end
  data[source.unit_number] = data[source.unit_number] or {}
  local entities = data[source.unit_number]
  for k = #entities, 1, -1 do
    if not entities[k].valid then
      table.remove(entities, k)
    end
  end
  if #entities >= limit then
    entities[1].die()
    table.remove(entities, 1)
  end
  table.insert(entities, mine)
end

local kill_player_mines = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local character = player.character
  if not (character and character.valid) then return end
  local entities = data[character.unit_number]
  if not entities then return end
  for k, entity in pairs (entities) do
    if entity.valid then
      entity.die()
    end
  end
  data[character.unit_number] = nil
end

local events =
{
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity,
  [defines.events.on_pre_player_died] = kill_player_mines,
  [defines.events.on_pre_player_left_game] = kill_player_mines
}

lib.on_event = handler(events)

lib.on_init = function()
  global.stickybomb_launcher = data
end

lib.on_load = function()
  data = global.stickybomb_launcher or data
end

return lib
