local tool_names = names.unit_tools

local unit_control = {}

local data =
{
  button_action_index = {},
  groups = {},
  selected_units = {},
  open_frames = {},
  units = {},
  stack_event_check = {},
  indicators = {}
}

local next_command_type =
{
  move = 1,
  patrol = 2,
  scout = 3,
  idle = 4,
  attack = 5,
}

local set_scout_command = function(unit, failure)
  if unit.type ~= "unit" then return end
  --log(game.tick..": Issueing scout command for "..unit.name.." "..unit.unit_number)
  unit.surface.create_entity{name = "explosion", position = unit.position}
  local position = unit.position
  local surface = unit.surface
  local chunk_x = math.floor(position.x / 32)
  local chunk_y = math.floor(position.y / 32)
  --unit.surface.request_to_generate_chunks(position, scout_range)
  local map_chunk_width = surface.map_gen_settings.width / 64
  local map_chunk_height = surface.map_gen_settings.height / 64
  local in_map = function(chunk_position)
    if map_chunk_width > 0 and (chunk_position.x > map_chunk_width or chunk_position.x < -map_chunk_width) then
      return false
    end
    if map_chunk_height > 0 and (chunk_position.y > map_chunk_height or chunk_position.y < -map_chunk_height) then
      return false
    end
    return true
  end
  local insert = table.insert
  local scout_range = 6
  if failure then scout_range = 8 end
  local visible_chunks = {}
  local non_visible_chunks = {}
  local uncharted_chunks = {}
  local checked = {}
  for X = -scout_range, scout_range do
    for Y = -scout_range, scout_range do
      local chunk_position = {x = chunk_x + X, y = chunk_y + Y}
      if in_map(chunk_position) then
        if (not unit.force.is_chunk_charted(surface, chunk_position)) then
          insert(uncharted_chunks, chunk_position)
        elseif (not unit.force.is_chunk_visible(surface, chunk_position)) then
          insert(non_visible_chunks, chunk_position)
        else
          insert(visible_chunks, chunk_position)
        end
      end
    end
  end
  local chunk
  local tile_destination
  repeat
    if #uncharted_chunks > 0 and not failure then
      index = math.random(#uncharted_chunks)
      chunk = uncharted_chunks[index]
      table.remove(uncharted_chunks, index)
      tile_destination = surface.find_non_colliding_position(unit.name, {(chunk.x * 32) + math.random(32), (chunk.y * 32) + math.random(32)}, 32, 4)
    elseif #non_visible_chunks > 0 and not failure then
      index = math.random(#non_visible_chunks)
      chunk = non_visible_chunks[index]
      table.remove(non_visible_chunks, index)
      tile_destination = surface.find_non_colliding_position(unit.name, {(chunk.x * 32) + math.random(32), (chunk.y * 32) + math.random(32)}, 32, 4)
    else
      index = math.random(#visible_chunks)
      chunk = visible_chunks[index]
      table.remove(visible_chunks, index)
      tile_destination = surface.find_non_colliding_position(unit.name, {(chunk.x * 32) + math.random(32), (chunk.y * 32) + math.random(32)}, 32, 4)
    end
  until tile_destination
  unit.set_command{type = defines.command.go_to_location, distraction = defines.distraction.by_enemy, destination = tile_destination, radius = 8}
end

local get_selected_units = function(player_index)
  local data = data.selected_units
  local selected = data[player_index] or {}
  for unit_number, entity in pairs (selected) do
    if not entity.valid then
      selected[unit_number] = nil
    end
  end
  data[player_index] = selected
  return selected
end

local make_unit_gui
local deselect_unit = function(param)
  if not param then return end
  local sticker = param.sticker
  if (sticker and sticker.valid) then
    sticker.destroy()
  end
  param.sticker = nil
end

local gui_actions =
{
  move_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.clean_cursor()
    player.cursor_stack.set_stack{name = tool_names.unit_move_tool}
    player.cursor_stack.label = "Issue move command"
  end,
  patrol_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.clean_cursor()
    player.cursor_stack.set_stack{name = tool_names.unit_patrol_tool}
    player.cursor_stack.label = "Add patrol waypoint"
  end,
  attack_move_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.clean_cursor()
    player.cursor_stack.set_stack{name = tool_names.unit_attack_move_tool}
    player.cursor_stack.label = "Issue attack move command"
  end,
  attack_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.clean_cursor()
    player.cursor_stack.set_stack{name = tool_names.unit_attack_tool}
    player.cursor_stack.label = "Issue attack command"
  end,
  force_attack_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.clean_cursor()
    player.cursor_stack.set_stack{name = tool_names.unit_force_attack_tool}
    player.cursor_stack.label = "Issue force attack command"
  end,
  stop_button = function(event)
    local group = get_selected_units(event.player_index)
    if not group then
      return
    end
    for unit_number, unit in pairs (group) do
      if unit.type == "unit" then
        unit.set_command{type = defines.command.wander, radius = 0.1}
      end
      data.units[unit_number].command_queue = {}
      data.units[unit_number].idle = true
    end
    game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
  end,
  scout_button = function(event)
    local group = get_selected_units(event.player_index)
    if not group then
      return
    end
    local append = event.shift
    for unit_number, unit in pairs (group) do
      local data = data.units[unit_number]
      if append and not data.idle then
        table.insert(data.command_queue, {command_type = next_command_type.scout})
      else
        set_scout_command(unit)
        data.command_queue = {{command_type = next_command_type.scout}}
        data.idle = false
      end
    end
    game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
  end,
  selected_units_button = function(event, action)
    local unit_name = action.unit
    local group = get_selected_units(event.player_index)
    if not group then return end
    local right = (event.button == defines.mouse_button_type.right)
    local units = data.units
    if event.control or right then
      for unit_number, entity in pairs (group) do
        if entity.name == unit_name then
          deselect_unit(units[unit_number])
          group[unit_number] = nil
          if right then break end
        end
      end
    else
      for unit_number, entity in pairs (group) do
        if entity.name ~= unit_name then
          deselect_unit(units[unit_number])
          group[unit_number] = nil
        end
      end
    end
    local frame = data.open_frames[event.player_index]
    if not (frame and frame.valid) then
      data.open_frames[event.player_index] = nil
      return
    end
    make_unit_gui(frame)
  end
}

local button_map = 
{
  [tool_names.unit_move_tool] = "move_button",
  [tool_names.unit_patrol_tool] = "patrol_button",
  [tool_names.unit_attack_move_tool] = "attack_move_button",
  [tool_names.unit_attack_tool] = "attack_button",
  [tool_names.unit_force_attack_tool] = "force_attack_button",
  ["Stop"] = "stop_button",
  ["Scout"] = "scout_button"
}

make_unit_gui = function(frame)
  local index = frame.player_index
  local group = get_selected_units(index)
  if not group then return end
  util.deregister_gui(frame, data.button_action_index)
  if table_size(group) == 0 then
    frame.destroy()
    return
  end
  frame.clear()
  local map = {}
  for unit_number, ent in pairs (group) do
    map[ent.name] = (map[ent.name] or 0) + 1
  end
  local tab = frame.add{type = "table", column_count = 6}
  local pro = game.entity_prototypes
  for name, count in pairs (map) do
    local ent = pro[name]
    local unit_button = tab.add{type = "sprite-button", sprite = "entity/"..name, tooltip = ent.localised_name, number = count, style = "slot_button"}
    data.button_action_index[unit_button.index] = {name = "selected_units_button", unit = name}
  end
  local butts = frame.add{type = "table", column_count = 1}
  for name, action in pairs (button_map) do
    local button = butts.add{type = "button", caption = name}
    data.button_action_index[button.index] = {name = action}
    button.style.font = "default"
    button.style.horizontally_stretchable = true
  end
  butts.style.align = "center"
end

deregister_unit = function(entity)
  if not (entity and entity.valid) then return end
  local unit_number = entity.unit_number
  if not unit_number then return end
  local unit = data.units[unit_number]
  if not unit then return end
  data.units[unit_number] = nil

  local sticker = unit.sticker
  if sticker and sticker.valid then
    sticker.destroy()
  end
  unit.sticker = nil

  local group = unit.group
  if group then
    --game.print("Deregistered unit from group")
    group[unit_number] = nil
    --if table_size(group) == 0 then 
  end
  local player_index = unit.player
  if not player_index then
    --game.print("No player index attached to unit info")
    return
  end

  local frame = data.open_frames[player_index]
  
  if not (frame and frame.valid) then
    data.selected_units[player_index] = nil
    return
  end

  make_unit_gui(frame)
end

local unit_selection = function(event)
  local entities = event.entities
  if not entities then return end
  local append = (event.name == defines.events.on_player_alt_selected_area)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local surface = player.surface
  local force = player.force
  local area = event.area
  local center = util.center(area)
  local index = player.index
  local units = data.units
  local group = get_selected_units(index)
  if not append then
    for unit_number, ent in pairs (group) do
      deselect_unit(units[unit_number])
    end
    group = {}
  end
  for k, ent in pairs (entities) do
    local unit_index = ent.unit_number
    local unit_data = units[unit_index]
    deregister_unit(ent)
    group[unit_index] = ent
    units[unit_index] = unit_data or
    {
      entity = ent,
      command_queue = {},
      idle = true
    }
    units[unit_index].group = group
    units[unit_index].player = index
    units[unit_index].sticker = surface.create_entity
    {
      name = "highlight-box",
      position = ent.position,
      source = ent,
      render_player_index = index, --Not merged
      box_type = "entity"
    }
    --[[
    if ent.type == "unit" then
      units[unit_index].sticker = surface.create_entity{name = tool_names.unit_selection_sticker, position = ent.position, force = force, target = ent}
    else
      units[unit_index].sticker = surface.create_entity{name = tool_names.deployer_selection_sticker, position = ent.position, force = force}
    end]]
  end
  data.selected_units[index] = group
  local gui = player.gui.left
  local old_frame = data.open_frames[player.index]
  if (old_frame and old_frame.valid) then
    util.deregister_gui(old_frame, data.button_action_index)
    old_frame.destroy()
  end
  local frame = gui.add{type = "frame", caption = "Unit control", direction = "vertical"}
  data.open_frames[player.index] = frame
  --player.opened = frame
  make_unit_gui(frame)
end

local get_offset = function(entities)
  local map = {}
  local small = 1
  for k, entity in pairs (entities) do
    if not map[entity.name] then
      map[entity.name] = entity.prototype
    end
  end
  local rad = util.radius
  local max = math.max
  for name, prototype in pairs (map) do
    small = max(small, rad(prototype.selection_box) * 2)
  end
  return small
end

local make_move_command = function(param)
  local position = param.position
  local distraction = param.distraction or defines.distraction.by_enemy
  local offset = param.spacing or 1
  local group = param.group
  offset = get_offset(group)
  local surface = param.surface
  local append = param.append
  local indicator = surface.create_entity{name = param.indicator or tool_names.move_indicator, position = position, force = param.force}
  local tick_to_die = game.tick + SU(300)
  data.indicators[tick_to_die] = data.indicators[tick_to_die] or {}
  table.insert(data.indicators[tick_to_die], indicator)
  local type = defines.command.go_to_location
  local radius = math.ceil((offset * table_size(group) ^ 0.5)/2)
  local find = surface.find_non_colliding_position
  local index
  local insert = table.insert
  for x = -radius, radius, offset do
    for y = -radius, radius, offset do
      local entity
      index, entity = next(group, index)
      if entity then
        local destination = {position.x + x, position.y + y}
        --log(entity.unit_number.." = "..serpent.line(destination))
        local unit = (entity.type == "unit")
        local command = {
          command_type = next_command_type.move,
          type = type, distraction = distraction,
          radius = 0.2,
          destination = find(entity.name, destination, 16, 1) or entity.position,
        }
        local unit_data = data.units[entity.unit_number]
        if append then
          if unit_data.idle and unit then
            entity.set_command(command)
          end
          insert(unit_data.command_queue, command)
        else
          if unit then
            entity.set_command(command)
            unit_data.command_queue = {}
          else
            unit_data.command_queue = {command}
          end
        end
        unit_data.idle = false
      else
        return
      end
    end
  end
end



local move_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local player = game.players[event.player_index]
  make_move_command{
    position = util.center(event.area),
    distraction = defines.distraction.none,
    group = group,
    surface = player.surface,
    force = player.force,
    spacing = 1.5,
    append = event.name == defines.events.on_player_alt_selected_area,
    indicator = tool_names.move_indicator
  }
  game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
end

local attack_move_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local player = game.players[event.player_index]
  make_move_command{
    position = util.center(event.area),
    distraction = defines.distraction.by_enemy,
    group = group,
    surface = player.surface,
    force = player.force,
    spacing = 1.5,
    append = event.name == defines.events.on_player_alt_selected_area,
    indicator = tool_names.attack_move_indicator
  }
  game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
end

local find_patrol_comand = function(queue)
  if not queue then return end
  for k, command in pairs (queue) do
    if command.command_type == next_command_type.patrol then
      return command
    end
  end
end


local process_command_queue

local make_patrol_command = function(param)
  local position = param.position
  local distraction = param.distraction or defines.distraction.by_enemy
  local offset = param.spacing or 1
  local group = param.group
  local surface = param.surface
  local append = param.append
  local indicator = surface.create_entity{name = param.indicator or tool_names.move_indicator, position = position, force = param.force}
  local tick_to_die = game.tick + 300
  data.indicators[tick_to_die] = data.indicators[tick_to_die] or {}
  table.insert(data.indicators[tick_to_die], indicator)
  local type = defines.command.go_to_location
  local radius = math.ceil((offset * table_size(group) ^ 0.5)/2)
  local find = surface.find_non_colliding_position
  local index
  local insert = table.insert
  for x = -radius, radius, offset do
    for y = -radius, radius, offset do
      index, entity = next(group, index)
      if entity then
        local unit = (entity.type == "unit")
        local unit_data = data.units[entity.unit_number]
        local next_destination = find(entity.name, {position.x + x, position.y + y}, 16, 4) or entity.position
        local patrol_command = find_patrol_comand(unit_data.command_queue)
        if patrol_command and append then
          table.insert(patrol_command.destinations, next_destination)
        else
          command = 
          {
            command_type = next_command_type.patrol,
            destinations = {entity.position, next_destination},
            destination_index = "initial"
          }
        end
        if not append then
          unit_data.command_queue = {command}
          unit_data.idle = false
          if unit then
            process_command_queue(unit_data)
          end
        end
        if append and not patrol_command then
          table.insert(unit_data.command_queue, command)
          if unit_data.idle and unit then
            process_command_queue(unit_data)
          end
        end
      else
        return
      end
    end
  end
end

local patrol_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local player = game.players[event.player_index]
  make_patrol_command{
    position = util.center(event.area),
    distraction = defines.distraction.by_enemy,
    group = group,
    surface = player.surface,
    force = player.force,
    spacing = 1.5,
    append = event.name == defines.events.on_player_alt_selected_area,
    indicator = tool_names.move_indicator
  }
  game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
end

local quick_dist = function(p1, p2)
  return (((p1.x - p2.x) * (p1.x - p2.x)) + ((p1.y - p2.y) * (p1.y - p2.y)))
end

local attack_closest = function(unit, entities)
  local closest
  local min = 5000000000000000000000000
  local position = unit.position
  local entities = entities
  local force = unit.force
  local surface = unit.surface
  local visible = force.is_chunk_visible
  local quick_dist = quick_dist
  for k, ent in pairs (entities) do
    if ent.valid and visible(surface, {ent.position.x / 32, ent.position.y / 32}) then
      local sep = quick_dist(ent.position, position)
      if sep < min then
        min = sep
        closest = ent
      end
    else
      entities[k] = nil
    end
  end

  if closest then
    unit.set_command
    {
      type = defines.command.attack,
      distraction = defines.distraction.none,
      target = closest
    }
    --surface.create_entity{name = "highlight-box", position = closest.position, source = closest, box_type = "not-allowed"}
    --Still a 'maybe'
    return true
  else
    return false
  end
end

local make_attack_command = function(group, entities, append)
  local entities = entities
  if #entities == 0 then return end
  local data = data.units
  for unit_number, unit in pairs (group) do
    local commandable = (unit.type == "unit")
    local next_command = 
    {
      command_type = next_command_type.attack,
      targets = entities
    }
    local unit_data = data[unit_number]
    if append then
      if unit_data.idle and commandable then
        attack_closest(unit, entities)
      end
      table.insert(unit_data.command_queue, next_command)
    else
      if commandable then
        attack_closest(unit, entities)
      end
      unit_data.command_queue = {next_command}
    end
    unit_data.idle = false
  end
end

local attack_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local append = event.name == defines.events.on_player_alt_selected_area
  make_attack_command(group, event.entities, append)
  game.players[event.player_index].play_sound({path = tool_names.unit_move_sound})
end

local selected_area_actions = 
{
  [tool_names.unit_selection_tool] = unit_selection,
  [tool_names.deployer_selection_tool] = unit_selection,
  [tool_names.unit_move_tool] = move_units,
  [tool_names.unit_patrol_tool] = patrol_units,
  [tool_names.unit_attack_move_tool] = attack_move_units,
  [tool_names.unit_attack_tool] = attack_units,
  [tool_names.unit_force_attack_tool] = attack_units,
}

local alt_selected_area_actions = 
{
  [tool_names.unit_selection_tool] = unit_selection,
  [tool_names.deployer_selection_tool] = unit_selection,
  [tool_names.unit_attack_tool] = attack_units,
  [tool_names.unit_force_attack_tool] = attack_units,
  [tool_names.unit_attack_move_tool] = attack_move_units,
  [tool_names.unit_move_tool] = move_units,
  [tool_names.unit_patrol_tool] = patrol_units,
}

local on_player_selected_area = function(event)
  local action = selected_area_actions[event.item]
  if not action then return end
  return action(event)
end

local on_player_alt_selected_area = function(event)
  local action = alt_selected_area_actions[event.item]
  if not action then return end
  return action(event)
end

local on_gui_closed = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local frame = data.open_frames[event.player_index]
  if frame then
    util.deregister_gui(frame, data.button_action_index)
    frame.destroy()
    data.open_frames[event.player_index] = nil
  end
end

local on_gui_click = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local action = data.button_action_index[gui.index]
  if not action then return end
  return gui_actions[action.name](event, action)
end

local on_entity_removed = function(event)
  deregister_unit(event.entity)
end

local idle_command = {type = defines.command.stop, radius = 1}

process_command_queue = function(unit_data, result)
  local entity = unit_data.entity
  if not (entity and entity.valid) then
    game.print("Entity is nil??")
    return 
  end
  local command_queue = unit_data.command_queue
  local next_command = command_queue[1]

  if not (next_command) then
    entity.set_command(idle_command)
    unit_data.idle = true
    --game.print("No next command??")
    return
  end

  local type = next_command.command_type

  if type == next_command_type.move then
    entity.set_command(next_command)
    table.remove(command_queue, 1)
    return
  end

  if type == next_command_type.patrol then
    if next_command.destination_index == "initial" then
      next_command.destinations[1] = entity.position
      next_command.destination_index = 2
    else
      next_command.destination_index = next_command.destination_index + 1
    end
    local next_destination = next_command.destinations[next_command.destination_index]
    if not next_destination then
      next_command.destination_index = 1
      next_destination = next_command.destinations[next_command.destination_index]
    end
    entity.set_command
    {
      type = defines.command.go_to_location,
      destination = entity.surface.find_non_colliding_position(entity.name, next_destination, 16, 4) or entity.position,
      radius = 0.2
    }
    return
  end

  if type == next_command_type.attack then
    --game.print"Issuing attack command"
    if not attack_closest(entity, next_command.targets) then
      table.remove(command_queue, 1)
      process_command_queue(unit_data)
      --game.print"No targets found, removing attack command"
    end
    return
  end

  if type == next_command_type.idle then
    entity.set_command(idle_command)
    unit_data.idle = true
    return
  end

  if type == next_command_type.scout then
    set_scout_command(entity, result == defines.behavior_result.fail)
    return
  end

end

local on_ai_command_completed = function(event)
  local unit = data.units[event.unit_number]
  if unit then
    process_command_queue(unit, event.result)
  end
end

local check_indicators = function(tick)
  local indicators = data.indicators[tick]
  if not indicators then return end
  for k, ent in pairs (indicators) do
    if ent.valid then
      ent.destroy()
    end
  end
end

local on_tick = function(event)
  check_indicators(event.tick)
end

local on_unit_deployed = function(event)
  local unit = event.unit
  local source = event.source
  if not (source and source.valid and unit and unit.valid) then return end

  local source_data = data.units[source.unit_number]
  if not source_data then return end
  local queue = source_data.command_queue
  data.units[unit.unit_number] = 
  {
    entity = unit,
    command_queue = util.copy(queue),
    idle = true
  }
  process_command_queue(data.units[unit.unit_number])
end

local suicide = function(event)
  local group = get_selected_units(event.player_index)
  if not group then return end
  local unit_number, entity = next(group)
  if entity then entity.die() end
end

local on_entity_settings_pasted = function(event)
  --Copy pasting deployers recipe.
  local source = event.source
  local destination = event.destination
  if not (source and source.valid and destination and destination.valid) then return end
  local unit_data = data.units[source.unit_number]
  if not unit_data then return end
  data.units[destination.unit_number] = util.copy(unit_data)
end

local on_player_removed = function(event)
  local frame = data.open_frames[event.player_index]
  if frame then
    util.deregister_gui(frame, data.button_action_index)
    frame.destroy()
    data.open_frames[event.player_index] = nil
  end
end

local events =
{
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_entity_settings_pasted] = on_entity_settings_pasted,
  [defines.events.on_player_alt_selected_area] = on_player_alt_selected_area,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_ai_command_completed] = on_ai_command_completed,
  [defines.events.on_tick] = on_tick,
  --[defines.event.on_player_created] = on_player_created
  [defines.events[names.hotkeys.unit_move]] = gui_actions.move_button,
  [defines.events.on_unit_deployed] = on_unit_deployed,
  [defines.events[hotkeys.suicide]] = suicide,
  [defines.events.on_player_died] = on_player_removed,
  [defines.events.on_player_left_game] = on_player_removed,
  [defines.events.on_player_changed_force] = on_player_removed,
  [defines.events.on_player_changed_surface] = on_player_removed
}

unit_control.on_event = handler(events)

unit_control.on_init = function()
  global.unit_control = data
  game.map_settings.path_finder.max_steps_worked_per_tick = 10000
  game.map_settings.path_finder.start_to_goal_cost_multiplier_to_terminate_path_find = 1000
  game.map_settings.path_finder.short_request_max_steps = 200
  game.map_settings.path_finder.min_steps_to_check_path_find_termination = 500
  game.map_settings.path_finder.max_clients_to_accept_any_new_request = 1000
  game.map_settings.path_finder.short_cache_size = 50
  game.map_settings.path_finder.long_cache_size = 250
  game.map_settings.steering.moving.force_unit_fuzzy_goto_behavior = true
  game.map_settings.steering.moving.radius = 2
  game.map_settings.steering.moving.default = 2
  game.map_settings.max_failed_behavior_count = 2
  
end

unit_control.on_load = function()
  data = global.unit_control
end

return unit_control