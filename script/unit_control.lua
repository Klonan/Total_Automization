local names = require("shared").units

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

local clean = function(player)
  player.clean_cursor()
  local item = data.stack_event_check[player.index]
  if not item then return end
  local count = player.get_item_count(item.item)
  if not (count > 0) then return end
  player.remove_item{name = item.item, count = count}
end

local set_scout_command = function(unit)
  if unit.type ~= "unit" then return end
  local position = unit.position
  local surface = unit.surface
  local chunk_x = math.floor(position.x / 32)
  local chunk_y = math.floor(position.y / 32)
  --unit.surface.request_to_generate_chunks(position, scout_range)
  local eligible_chunks = {}
  local checked = {}
  local scout_range = 4
  local any = false
  while not any do
    for X = -scout_range, scout_range do
      checked[X] = checked[X] or {}
      for Y = -scout_range, scout_range do
        if (not (X == 0 and Y == 0)) and not checked[X][Y] then
          local chunk_position = {x = chunk_x + X, y = chunk_y + Y}
          if not unit.force.is_chunk_charted(surface, chunk_position) then
            any = true
            table.insert(eligible_chunks, chunk_position)
          end
          checked[X][Y] = true
        end
      end
    end
    scout_range = scout_range + 1
  end
  local chunk = eligible_chunks[math.random(#eligible_chunks)]
  local tile_destination = surface.find_non_colliding_position(unit.name, {(chunk.x * 32) + math.random(32), (chunk.y * 32) + math.random(32)}, 16, 4)
  if tile_destination then
    unit.set_command{type = defines.command.go_to_location, distraction = defines.distraction.by_enemy, destination = tile_destination}
    return true
  end
  return false
end

local gui_actions =
{
  move_button = function(event)
    if not data.selected_units[event.player_index] then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    clean(player)
    player.cursor_stack.set_stack{name = names.unit_move_tool}
    player.cursor_stack.label = "Issue move command"
    data.stack_event_check[player.index] = {item = names.unit_move_tool, ignore_tick = game.tick}
  end,
  attack_move_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    clean(player)
    player.cursor_stack.set_stack{name = names.unit_attack_move_tool}
    player.cursor_stack.label = "Issue attack move command"
    data.stack_event_check[player.index] = {item = names.unit_attack_move_tool, ignore_tick = game.tick}
  end,
  attack_button = function(event)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    clean(player)
    player.cursor_stack.set_stack{name = names.unit_attack_tool}
    player.cursor_stack.label = "Issue attack command"
    data.stack_event_check[player.index] = {item = names.unit_attack_tool, ignore_tick = game.tick}
  end,
  stop_button = function(event)
    local group = data.selected_units[event.player_index]
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
  end,
  scout_button = function(event)
    local group = data.selected_units[event.player_index]
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
  end,
}

local button_map = 
{
  [names.unit_move_tool] = "move_button",
  [names.unit_attack_move_tool] = "attack_move_button",
  [names.unit_attack_tool] = "attack_button",
  ["Stop"] = "stop_button",
  ["Scout"] = "scout_button"
}

local make_unit_gui = function(frame, group)
  if not group then return end
  frame.clear()
  local map = {}
  if table_size(group) == 0 then
    util.deregister_gui(frame, data.button_action_index)
    frame.destroy()
    return
  end
  for unit_number, ent in pairs (group) do
    map[ent.name] = (map[ent.name] or 0) + 1
  end
  local tab = frame.add{type = "table", column_count = 6}
  local pro = game.entity_prototypes
  for name, count in pairs (map) do
    local ent = pro[name]
    tab.add{type = "sprite-button", sprite = "entity/"..name, tooltip = ent.localised_name, number = count, style = "slot_button"}
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

  make_unit_gui(frame, group)
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
  local group = get_selected_units(index)
  if not append then
    game.print("New selected units")
    group = {}
  end
  data.selected_units[index] = group
  game.print(#entities)
  for k, ent in pairs (entities) do
    deregister_unit(ent)
    group[ent.unit_number] = ent
    data.units[ent.unit_number] = 
    {
      entity = ent,
      --player = index,
      --group = group,
      command_queue = {},
      idle = true
    }
  end
  local gui = player.gui.left
  local old_frame = data.open_frames[player.index]
  if (old_frame and old_frame.valid) then
    util.deregister_gui(old_frame, data.button_action_index)
    old_frame.destroy()
  end
  local frame = gui.add{type = "frame", caption = "units", direction = "vertical"}
  data.open_frames[player.index] = frame
  --player.opened = frame
  make_unit_gui(frame, group)
  player.clean_cursor()
end

local make_move_command = function(param)
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
    type = next_command_type.move,
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
    type = next_command_type.move,
    indicator = names.attack_move_indicator
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local patrol_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  make_move_command{
    position = util.center(event.area),
    distraction = defines.distraction.by_enemy,
    group = group,
    surface = game.players[event.player_index].surface,
    spacing = 1.5,
    append = event.name == defines.events.on_player_alt_selected_area,
    type = next_command_type.move
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
    if ent.valid and ent.health and visible(surface, {ent.position.x / 32, ent.position.y / 32}) then
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
  [names.unit_attack_move_tool] = attack_move_units,
  [names.unit_attack_tool] = attack_units
}

local alt_selected_area_actions = 
{
  [names.unit_selection_tool] = unit_selection,
  [names.deployer_selection_tool] = unit_selection,
  [names.unit_attack_tool] = attack_units,
  [names.unit_attack_move_tool] = attack_move_units,
  [names.unit_move_tool] = move_units
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
  return gui_actions[action.name](event, action.param)
end

local on_entity_died = function(event)
  deregister_unit(event.entity)
end

local on_player_cursor_stack_changed = function(event)
  local item = data.stack_event_check[event.player_index]
  if not item then return end
  if event.tick == item.ignore_tick then return end
  local player = game.players[event.player_index]
  local count = player.get_item_count(item.item)
  if count > 0 then
    player.remove_item{name = item.item, count = count}
  end
  data.stack_event_check[player.index] = nil
end

local idle_command = {type = defines.command.wander, radius = 0.1}


local process_command_queue
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
    entity.set_command(next_command)
    table.remove(command_queue, 1)
    table.insert(command_queue, next_command)
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

local events =
{
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_player_alt_selected_area] = on_player_alt_selected_area,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
  [defines.events.on_ai_command_completed] = on_ai_command_completed,
  [defines.events.on_tick] = on_tick,
  --[defines.event.on_player_created] = on_player_created
  [defines.events[require("shared").hotkeys.unit_move]] = gui_actions.move_button,
  [defines.events.on_unit_deployed] = on_unit_deployed
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