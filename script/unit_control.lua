local tool_names = names.unit_tools

local data =
{
  button_actions = {},
  groups = {},
  selected_units = {},
  open_frames = {},
  units = {},
  indicators = {},
}

local checked_tables = {}

local next_command_type =
{
  move = 1,
  patrol = 2,
  scout = 3,
  idle = 4,
  attack = 5,
}

local set_scout_command = function(unit_data, failure, delay)
  local unit = unit_data.entity
  if unit.type ~= "unit" then return end
  unit.speed = unit.prototype.speed
  if delay and delay > 0 then
    unit.set_command
    {
      type = defines.command.stop,
      ticks_to_wait = delay
    }
    return
  end
  --log(game.tick..": Issueing scout command for "..unit.name.." "..unit.unit_number)
  --unit.surface.create_entity{name = "explosion", position = unit.position}
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
  local visible_chunks = {}
  local non_visible_chunks = {}
  local uncharted_chunks = {}
  local checked = {}
  local force = unit.force
  local is_charted = force.is_chunk_charted
  local is_visible = force.is_chunk_visible
  for X = -scout_range, scout_range do
    for Y = -scout_range, scout_range do
      local chunk_position = {x = chunk_x + X, y = chunk_y + Y}
      if in_map(chunk_position) then
        if (not is_charted(surface, chunk_position)) then
          insert(uncharted_chunks, chunk_position)
        elseif (not is_visible(surface, chunk_position)) then
          insert(non_visible_chunks, chunk_position)
        else
          insert(visible_chunks, chunk_position)
        end
      end
    end
  end
  local chunk
  local tile_destination
  local remove = table.remove
  local random = math.random
  local find_non_colliding_position = surface.find_non_colliding_position
  local name = unit.name
  repeat
    if not failure and #uncharted_chunks > 0 then
      index = random(#uncharted_chunks)
      chunk = uncharted_chunks[index]
      remove(uncharted_chunks, index)
      tile_destination = find_non_colliding_position(name, {(chunk.x * 32) + random(32), (chunk.y * 32) + random(32)}, 32, 4)
    elseif not failure and #non_visible_chunks > 0 then
      index = random(#non_visible_chunks)
      chunk = non_visible_chunks[index]
      remove(non_visible_chunks, index)
      tile_destination = find_non_colliding_position(name, {(chunk.x * 32) + random(32), (chunk.y * 32) + random(32)}, 32, 4)
    elseif #visible_chunks > 0 then
      index = random(#visible_chunks)
      chunk = visible_chunks[index]
      remove(visible_chunks, index)
      tile_destination = find_non_colliding_position(name, {(chunk.x * 32) + random(32), (chunk.y * 32) + random(32)}, 32, 4)
    else
      tile_destination = find_non_colliding_position(name, force.get_spawn_position(surface), 32, 4)
    end
  until tile_destination
  unit.set_command
  {
    type = defines.command.go_to_location,
    distraction = defines.distraction.by_enemy,
    destination = tile_destination,
    radius = 1,
    pathfind_flags =
    {
      allow_destroy_friendly_entities = true,
      cache = true,
      low_priority = true
    }
  }
  unit_data.destination = tile_destination
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

local clear_indicators = function(unit_data)
  if not unit_data.indicators then return end
  for k, indicator in pairs (unit_data.indicators) do
    if indicator and indicator.valid then
      indicator.destroy()
    end
  end
  unit_data.indicators = nil
end

local deselect_units = function(unit_data)
  clear_indicators(unit_data)
  unit_data.player = nil
end


local shift_box = function(box, shift)
  local x = shift[1] or shift.x
  local y = shift[2] or shift.y
  local new =
  {
    left_top = {},
    right_bottom = {}
  }
  new.left_top.x = box.left_top.x + x
  new.left_top.y = box.left_top.y + y
  new.right_bottom.x = box.right_bottom.x + x
  new.right_bottom.y = box.right_bottom.y + y
  return new
end

local add_unit_indicators = function(unit_data)
  clear_indicators(unit_data)
  local player
  if unit_data.player then
    player = game.players[unit_data.player]
  end
  if not (player and player.valid and player.connected) then return end
  local indicators = {}
  local unit = unit_data.entity
  local surface = unit.surface
  local create_entity = surface.create_entity
  local render_index = player.index
  local insert = table.insert
  local position = unit.position
  local name = "highlight-box"

  insert(indicators,
  create_entity
  {
    name = name, box_type = "entity",
    target = unit, render_player_index = render_index,
    position = unit.position,
    blink_interval = 0
  })

  local box = unit.prototype.collision_box

  if unit_data.destination then
    insert(indicators,
    create_entity
    {
      name = name, box_type = "copy",
      render_player_index = render_index,
      position = unit_data.destination,
      bounding_box = shift_box(box, unit_data.destination),
      blink_interval = 0
    })
  end

  if unit_data.target and unit_data.target.valid then
    insert(indicators,
    create_entity
    {
      name = name, box_type = "not-allowed",
      render_player_index = render_index,
      target = unit_data.target,
      position = unit_data.target.position,
      blink_interval = 20
    })
  end

  for k, command in pairs (unit_data.command_queue) do
    if command.command_type == next_command_type.move then
      insert(indicators,
      create_entity
      {
        name = name, box_type = "copy",
        render_player_index = render_index,
        position = position,
        bounding_box = shift_box(box, command.destination),
        blink_interval = 0
      })
    end
    if command.command_type == next_command_type.patrol then
      for k, destination in pairs (command.destinations) do
        if k ~= 1 or command.destination_index ~= "initial" then
          insert(indicators,
          create_entity
          {
            name = name, box_type = "electricity",
            render_player_index = render_index,
            position = position,
            bounding_box = shift_box(box, destination),
            blink_interval = 0
          })
        end
      end
    end
  end

  unit_data.indicators = indicators
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
      local unit_data = data.units[unit_number]
      unit_data.command_queue = {}
      unit_data.idle = true
      unit_data.destination = nil
      unit_data.target = nil
      add_unit_indicators(unit_data)
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
        set_scout_command(data, false, unit_number % 120)
        data.command_queue = {{command_type = next_command_type.scout}}
        data.idle = false
        add_unit_indicators(data)
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
          deselect_units(units[unit_number])
          group[unit_number] = nil
          if right then break end
        end
      end
    else
      for unit_number, entity in pairs (group) do
        if entity.name ~= unit_name then
          deselect_units(units[unit_number])
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
  util.deregister_gui(frame, data.button_actions)
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
    util.register_gui(data.button_actions, unit_button, {type = "selected_units_button", unit = name})
  end
  local butts = frame.add{type = "table", column_count = 1}
  for name, action in pairs (button_map) do
    local button = butts.add{type = "button", caption = name}
    util.register_gui(data.button_actions, button, {type = action})
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

  clear_indicators(unit)

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
      deselect_units(units[unit_number])
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
    add_unit_indicators(units[unit_index])
  end
  data.selected_units[index] = group
  local gui = player.gui.left
  local old_frame = data.open_frames[player.index]
  if (old_frame and old_frame.valid) then
    util.deregister_gui(old_frame, data.button_actions)
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
    local name = entity.name
    if not map[name] then
      map[name] = entity.prototype
    end
  end
  local rad = util.radius
  local speed = math.huge
  local max = math.max
  local min = math.min
  for name, prototype in pairs (map) do
    small = max(small, rad(prototype.selection_box) * 2)
    if prototype.type == "unit" then
      speed = min(speed, prototype.speed)
    end
  end
  if speed == math.huge then speed = nil end
  return small, math.ceil((small * (table_size(entities) -1) ^ 0.5)), speed
end

local get_min_speed = function(entities)
  local map = {}
  local speed = math.huge
  for k, entity in pairs (entities) do
    local name = entity.name
    if not map[name] then
      map[name] = entity.prototype
    end
  end
  local min = math.min
  for name, prototype in pairs (map) do
    speed = min(speed, prototype.speed)
  end
  return speed
end

local make_move_command = function(param)
  local position = param.position
  local distraction = param.distraction or defines.distraction.by_enemy
  local group = param.group
  local player = param.player
  local surface = player.surface
  local force = player.force
  local append = param.append
  local type = defines.command.go_to_location
  local find = surface.find_non_colliding_position
  local index
  local offset, radius, speed = get_offset(group)
  local insert = table.insert
  for x = -radius / 2, radius / 2, offset do
    for y = -radius / 2, radius / 2, offset do
      local entity
      index, entity = next(group, index)
      if entity then
        local destination = {position.x + x, position.y + y}
        --log(entity.unit_number.." = "..serpent.line(destination))
        local unit = (entity.type == "unit")
        local destination = find(entity.name, destination, 16, 1) or entity.position
        local command = {
          command_type = next_command_type.move,
          type = type, distraction = distraction,
          radius = 0.2,
          destination = destination,
          speed = speed,
          pathfind_flags =
          {
            allow_destroy_friendly_entities = false,
            cache = false
          }
        }
        local unit_data = data.units[entity.unit_number]
        if append then
          if unit_data.idle and unit then
            entity.set_command(command)
            entity.speed = speed
            unit_data.destination = destination
          end
          insert(unit_data.command_queue, command)
        else
          unit_data.command_queue = {command}
          if unit then
            entity.set_command(command)
            entity.speed = speed
            unit_data.command_queue = {}
            unit_data.destination = destination
          else
            unit_data.command_queue = {command}
          end
        end
        unit_data.idle = false
        add_unit_indicators(unit_data)
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
    append = event.name == defines.events.on_player_alt_selected_area,
    player = player
  }
  player.play_sound({path = tool_names.unit_move_sound})
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
    append = event.name == defines.events.on_player_alt_selected_area,
    player = player
  }
  player.play_sound({path = tool_names.unit_move_sound})
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
  local group = param.group
  local player = param.player
  local surface = player.surface
  local force = player.force
  local append = param.append
  local type = defines.command.go_to_location
  local find = surface.find_non_colliding_position
  local index
  local offset, radius, speed = get_offset(group)
  local insert = table.insert
  for x = -radius / 2, radius / 2, offset do
    for y = -radius / 2, radius / 2, offset do
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
            destination_index = "initial",
            speed = speed
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
        add_unit_indicators(unit_data)
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
    append = event.name == defines.events.on_player_alt_selected_area,
    player = player
  }
  player.play_sound({path = tool_names.unit_move_sound})
end

local quick_dist = function(p1, p2)
  return (((p1.x - p2.x) * (p1.x - p2.x)) + ((p1.y - p2.y) * (p1.y - p2.y)))
end

local attack_closest = function(unit_data, entities)
  local unit = unit_data.entity
  local position = unit.position
  local entities = entities
  local force = unit.force
  local surface = unit.surface
  if not checked_tables[entities] then
    for k, ent in pairs (entities) do
      if not ent.valid then
        entities[k] = nil
      end
    end
    checked_tables[entities] = true
  end
  unit.speed = unit.prototype.speed
  local closest = unit.surface.get_closest(unit.position, entities)

  if closest and closest.valid then
    unit.set_command
    {
      type = defines.command.attack,
      distraction = defines.distraction.none,
      target = closest
    }
    unit_data.target = closest
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
        attack_closest(unit_data, entities)
      end
      table.insert(unit_data.command_queue, next_command)
    else
      if commandable then
        attack_closest(unit_data, entities)
      end
      unit_data.command_queue = {next_command}
    end
    add_unit_indicators(unit_data)
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
    util.deregister_gui(frame, data.button_actions)
    frame.destroy()
    data.open_frames[event.player_index] = nil
  end
end

local on_gui_click = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data.button_actions[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
    gui_actions[action.type](event, action)
    return true
  end
end
local on_entity_removed = function(event)
  checked_tables = {}
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
  unit_data.destination = nil
  unit_data.target = nil

  if not (next_command) then
    entity.set_command(idle_command)
    if entity.type == "unit" then
      entity.speed = entity.prototype.speed
    end
    unit_data.idle = true
    --game.print("No next command??")
    return
  end

  if entity.type == "unit" then
    entity.speed = next_command.speed or entity.prototype.speed
  end

  local type = next_command.command_type

  if type == next_command_type.move then
    entity.set_command(next_command)
    unit_data.destination = next_command.destination
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
    if not attack_closest(unit_data, next_command.targets) then
      table.remove(command_queue, 1)
      process_command_queue(unit_data)
      --game.print"No targets found, removing attack command"
    end
    return
  end

  if type == next_command_type.idle then
    entity.set_command(idle_command)
    unit_data.idle = true
    unit_data.destination = nil
    return
  end

  if type == next_command_type.scout then
    set_scout_command(unit_data, result == defines.behavior_result.fail)
    return
  end

end

local on_ai_command_completed = function(event)
  local unit = data.units[event.unit_number]
  if unit then
    process_command_queue(unit, event.result)
    add_unit_indicators(unit)
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
  checked_tables = {}
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
  for k, command in pairs (data.units[unit.unit_number].command_queue) do
    if command.command_type == next_command_type.move then
      command.destination = {x = command.destination.x + math.random(-6, 6), y = command.destination.y + math.random(-6, 6)}
    end
    if command.command_type == next_command_type.patrol then
      for k, destination in pairs (command.destinations) do
        destination = {x = destination.x + math.random(-6, 6), y = destination.y + math.random(-6, 6)}
      end
    end
  end
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
  if (frame and frame.valid) then
    util.deregister_gui(frame, data.button_actions)
    frame.destroy()
  end
  data.open_frames[event.player_index] = nil
  local group = get_selected_units(event.player_index)
  local units = data.units
  if group then
    for unit_number, ent in pairs (group) do
      deselect_units(units[unit_number])
    end
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
  --[defines.events[names.hotkeys.unit_move]] = gui_actions.move_button,
  [defines.events[names.hotkeys.suicide]] = suicide,
  [defines.events.on_player_died] = on_player_removed,
  [defines.events.on_player_left_game] = on_player_removed,
  [defines.events.on_player_changed_force] = on_player_removed,
  [defines.events.on_player_changed_surface] = on_player_removed
}

local register_events = function()
  if remote.interfaces["unit_deployment"] then
    local unit_deployment_events = remote.call("unit_deployment", "get_events")
    events[unit_deployment_events.on_unit_deployed] = on_unit_deployed
  end
end

local unit_control = {}

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
  game.map_settings.steering.moving.radius = 0
  game.map_settings.steering.moving.default = 0
  game.map_settings.max_failed_behavior_count = 2
  register_events()
  unit_control.on_event = handler(events)
end

unit_control.on_load = function()
  data = global.unit_control
  register_events()
  unit_control.on_event = handler(events)
end

return unit_control
