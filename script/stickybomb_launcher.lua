local data = {
  mines = {},
  frames = {},
  sources = {}
}

local mine_limit =
{
  ["Stickybomb Launcher Mine"] = 8
}

local validate_entities = function(entities)
  for k = #entities, 1, -1 do
    if not entities[k].valid then
      table.remove(entities, k)
    end
  end
  return entities
end

local update_source_frame = function(source)
  local mines = validate_entities(data.mines[source.unit_number])
  local player = source.player
  if not player then return end
  local frame = data.frames[player.index] or player.gui.left.add{type = "frame"}
  frame.clear()
  local label = frame.add{type = "label", caption = "Mines: "..#mines}
  label.style.font = "default-large-bold"

  data.frames[player.index] = frame
end

local on_trigger_created_entity = function(event)
  local mine = event.entity
  if not (mine and mine.valid) then return end
  local source = event.source
  if not (source and source.valid) then return end
  local limit = mine_limit[mine.name]
  if not limit then return end
  data.sources[mine.unit_number] = source
  data.mines[source.unit_number] = data.mines[source.unit_number] or {}
  local entities = validate_entities(data.mines[source.unit_number])
  local sources = data.sources
  if #entities >= limit then
    sources[entities[1].unit_number] = nil
    entities[1].die()
    table.remove(entities, 1)
  end
  table.insert(entities, mine)
  update_source_frame(source)
end

local kill_player_mines = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local character = player.character
  if not (character and character.valid) then return end
  local entities = data.mines[character.unit_number]
  if not entities then return end
  local sources = data.sources
  for k, entity in pairs (entities) do
    if entity.valid then
      sources[entity.unit_number] = nil
      entity.die()
    end
  end
  data.mines[character.unit_number] = nil
  local frame = data.frames[player.index]
  if frame and frame.valid then
    frame.destroy()
  end
  data.frames[player.index] = nil
end

local on_entity_died = function(event)
  local entity = event.entity
  if not (entity and entity.valid and mine_limit[entity.name]) then return end
  local source = data.sources[entity.unit_number]
  if not source then return end
  local mines = data.mines[source.unit_number]
  if mines then
    for k, mine in pairs (mines) do
      if mine == entity then
        table.remove(mines, k)
        break
      end
    end
  end
  return update_source_frame(source)
end

local events =
{
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity,
  [defines.events.on_pre_player_died] = kill_player_mines,
  [defines.events.on_pre_player_left_game] = kill_player_mines,
  [defines.events.on_entity_died] = on_entity_died
}

local lib = {}

lib.on_event = handler(events)

lib.on_init = function()
  global.stickybomb_launcher = data
end

lib.on_load = function()
  data = global.stickybomb_launcher or data
end

return lib
