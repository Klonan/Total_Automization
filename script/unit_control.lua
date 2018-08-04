local names = require("shared").unit_tools

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

--[[on_player_selected_area

Called after a player selects an area with a selection-tool item.

Contains
player_index :: uint: The player doing the selection.
area :: BoundingBox: The area selected.
item :: string: The item used to select the area.
entities :: array of LuaEntity: The entities selected.
tiles :: array of LuaTile: The tiles selected.]]

local next_command_type =
{
  move = 1,
  patrol = 2,
  scout = 3,
  idle = 4,
  attack = 5,
}

local set_scout_command = function(unit)
  if unit.type ~= "unit" then return end
  local position = unit.position
  local surface = unit.surface
  local chunk_x = math.floor(position.x / 32)
  local chunk_y = math.floor(position.y / 32)
  --unit.surface.request_to_generate_chunks(position, scout_range)
  local scout_range = 4
  local max = 16
  local any = false
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
  local eligible_chunks = {}
  local checked = {}
  while (not any) and (scout_range < max) do
    for X = -scout_range, scout_range do
      checked[X] = checked[X] or {}
      for Y = -scout_range, scout_range do
        if (not (X == 0 and Y == 0)) and not checked[X][Y] then
          local chunk_position = {x = chunk_x + X, y = chunk_y + Y}
          if in_map(chunk_position) and (not unit.force.is_chunk_charted(surface, chunk_position))then
            any = true
            table.insert(eligible_chunks, chunk_position)
          end
          checked[X][Y] = true
        end
      end
    end
    scout_range = scout_range + 1
  end
  if #eligible_chunks == 0 then
    scout_range = 4 
    checked = {}
    while (not any) and (scout_range < max) do
      for X = -scout_range, scout_range do
        checked[X] = checked[X] or {}
        for Y = -scout_range, scout_range do
          if (not (X == 0 and Y == 0)) and not checked[X][Y] then
            local chunk_position = {x = chunk_x + X, y = chunk_y + Y}
            if in_map(chunk_position) and (not unit.force.is_chunk_visible(surface, chunk_position))then
              any = true
              table.insert(eligible_chunks, chunk_position)
            end
            checked[X][Y] = true
          end
        end
      end
      scout_range = scout_range + 1
    end
  end
  if #eligible_chunks == 0 then return false end
  local chunk = eligible_chunks[math.random(#eligible_chunks)]
  local tile_destination = surface.find_non_colliding_position(unit.name, {(chunk.x * 32) + math.random(32), (chunk.y * 32) + math.random(32)}, 16, 4)
  if not tile_destination then return false end
  
  unit.set_command{type = defines.command.go_to_location, distraction = defines.distraction.by_enemy, destination = tile_destination}
  return true
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

local gui_actions =
{
  move_button = function(event)
    if not data.selected_units[event.player_index] then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.cursor_stack.set_stack{name = names.unit_move_tool}
    player.cursor_stack.label = "Issue move command"
  end,
  patrol_button = function(event)
    if not data.selected_units[event.player_index] then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.cursor_stack.set_stack{name = names.unit_patrol_tool}
    player.cursor_stack.label = "Add patrol waypoint"
  end,
  attack_move_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.cursor_stack.set_stack{name = names.unit_attack_move_tool}
    player.cursor_stack.label = "Issue attack move command"
  end,
  attack_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.cursor_stack.set_stack{name = names.unit_attack_tool}
    player.cursor_stack.label = "Issue attack command"
  end,
  force_attack_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.cursor_stack.set_stack{name = names.unit_force_attack_tool}
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
    game.players[event.player_index].play_sound({path = names.unit_move_sound})
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
    game.players[event.player_index].play_sound({path = names.unit_move_sound})
  end,
  selected_units_button = function(event, action)
    local unit_name = action.unit
    local group = get_selected_units(event.player_index)
    if not group then return end
    local right = (event.button == defines.mouse_button_type.right)
    if event.control or right then
      for unit_number, entity in pairs (group) do
        if entity.name == unit_name then
          group[unit_number] = nil
          if right then break end
        end
      end
    else
      for unit_number, entity in pairs (group) do
        if entity.name ~= unit_name then
          group[unit_number] = nil
        end
      end
    end
    local frame = data.open_frames[event.player_index]
    if not frame then return end
    make_unit_gui(frame)
  end
}

local button_map = 
{
  [names.unit_move_tool] = "move_button",
  [names.unit_patrol_tool] = "patrol_button",
  [names.unit_attack_move_tool] = "attack_move_button",
  [names.unit_attack_tool] = "attack_button",
  [names.unit_force_attack_tool] = "force_attack_button",
  ["Stop"] = "stop_button",
  ["Scout"] = "scout_button"
}

make_unit_gui = function(frame)
  local index = frame.player_index
  local group = get_selected_units(index)
  if not group then return end
  frame.clear()
  if table_size(group) == 0 then
    util.deregister_gui(frame, data.button_action_index)
    frame.destroy()
    return
  end
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

local deregister_unit = function(entity)
  if not (entity and entity.valid) then return end
  if not (entity.type == "unit") then return end
  local unit_number = entity.unit_number
  local unit = data.units[unit_number]
  if not unit then
    --game.print("No unit to deregister")
    return
  end
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
  if #entities == 0 then return end
  local append = (event.name == defines.events.on_player_alt_selected_area)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local surface = player.surface
  local area = event.area
  local center = util.center(area)
  local index = player.index
  local group
  if append then
    group = get_selected_units(index)
  else
    group = {}
  end
  local units = data.units
  for k, ent in pairs (entities) do
    deregister_unit(ent)
    local unit_index = ent.unit_number
    group[unit_index] = ent
    units[unit_index] = units[unit_index] or
    {
      entity = ent,
      command_queue = {},
      idle = true
    }
    units[unit_index].group = group
    units[unit_index].player = index
  end
  data.selected_units[index] = group
  local gui = player.gui.left
  local old_frame = data.open_frames[player.index]
  if (old_frame and old_frame.valid) then
    util.deregister_gui(old_frame, data.button_action_index)
    old_frame.destroy()
  end
  local frame = gui.add{type = "frame", caption = "units", direction = "vertical"}
  data.open_frames[player.index] = frame
  --player.opened = frame
  make_unit_gui(frame)
end

local make_move_command = function(param)
  local position = param.position
  local distraction = param.distraction or defines.distraction.by_enemy
  local offset = param.spacing or 1
  local group = param.group
  local surface = param.surface
  local append = param.append
  local indicator = surface.create_entity{name = param.indicator or names.move_indicator, position = position, force = param.force}
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
      index, entity = next(group, index)
      if entity then
        local unit = (entity.type == "unit")
        local command = {
          command_type = next_command_type.move,
          type = type, distraction = distraction,
          destination = find(entity.name, {position.x + x, position.y + y}, 16, 4) or entity.position,
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
    indicator = names.move_indicator
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
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
    indicator = names.attack_move_indicator
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
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
  local indicator = surface.create_entity{name = param.indicator or names.move_indicator, position = position, force = param.force}
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
    indicator = names.move_indicator
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
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
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local selected_area_actions = 
{
  [names.unit_selection_tool] = unit_selection,
  [names.deployer_selection_tool] = unit_selection,
  [names.unit_move_tool] = move_units,
  [names.unit_patrol_tool] = patrol_units,
  [names.unit_attack_move_tool] = attack_move_units,
  [names.unit_attack_tool] = attack_units,
  [names.unit_force_attack_tool] = attack_units,
}

local alt_selected_area_actions = 
{
  [names.unit_selection_tool] = unit_selection,
  [names.deployer_selection_tool] = unit_selection,
  [names.unit_attack_tool] = attack_units,
  [names.unit_force_attack_tool] = attack_units,
  [names.unit_attack_move_tool] = attack_move_units,
  [names.unit_move_tool] = move_units,
  [names.unit_patrol_tool] = patrol_units,
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

local on_entity_died = function(event)
  deregister_unit(event.entity)
end

local idle_command = {type = defines.command.wander, radius = 1}

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
    if next_destination then
      entity.set_command{type = defines.command.go_to_location, destination = next_destination}
    else
      next_command.destination_index = 1
      next_destination = next_command.destinations[next_command.destination_index]
      if next_destination then
        entity.set_command{type = defines.command.go_to_location, destination = next_destination}
      else
        error("Something really fucked with this command here mate: "..serpent.block(unit_data))
      end
    end
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
    if result == defines.behavior_result.fail or (not  set_scout_command(entity)) then
      entity.set_command(idle_command)
      unit_data.idle = true
      unit_data.command_queue = {}
    end
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

local events =
{
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_player_alt_selected_area] = on_player_alt_selected_area,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_ai_command_completed] = on_ai_command_completed,
  [defines.events.on_tick] = on_tick,
  --[defines.event.on_player_created] = on_player_created
  [defines.events[require("shared").hotkeys.unit_move]] = gui_actions.move_button,
  [defines.events.on_unit_deployed] = on_unit_deployed,
  [defines.events[hotkeys.suicide]] = suicide
}

unit_control.on_event = handler(events)

unit_control.on_init = function()
  global.unit_control = data
  game.map_settings.path_finder.max_steps_worked_per_tick = 1000000
  game.map_settings.path_finder.start_to_goal_cost_multiplier_to_terminate_path_find = 1000000000
  game.map_settings.path_finder.short_request_max_steps = 5000
  game.map_settings.path_finder.min_steps_to_check_path_find_termination = 50000
  game.map_settings.path_finder.max_clients_to_accept_any_new_request = 50000
  game.map_settings.steering.moving.force_unit_fuzzy_goto_behavior = true
  game.map_settings.steering.moving.radius = 0
  game.map_settings.steering.moving.default = 0
  game.map_settings.max_failed_behavior_count = 50
  
end

unit_control.on_load = function()
  data = global.unit_control or data
end

return unit_control