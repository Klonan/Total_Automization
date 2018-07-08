local names = require("shared").unit_names

local unit_control = {}

local data =
{
  button_action_index = {},
  groups = {},
  selected_units = {},
  open_frames = {},
  units = {},
  stack_event_check = {},
}

--[[on_player_selected_area

Called after a player selects an area with a selection-tool item.

Contains
player_index :: uint: The player doing the selection.
area :: BoundingBox: The area selected.
item :: string: The item used to select the area.
entities :: array of LuaEntity: The entities selected.
tiles :: array of LuaTile: The tiles selected.]]

local clean = function(player)
  player.clean_cursor()
  local item = data.stack_event_check[player.index]
  if not item then return end
  local count = player.get_item_count(item.item)
  if not (count > 0) then return end
  player.remove_item{name = item.item, count = count}
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
    if not (group and group.valid) then
      data.selected_units[event.player_index] = nil
      return
    end
    group.set_command
    {
      type = defines.command.stop
    }
  end,
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
  --local butts = frame.add{type = "flow", direction = "horizontal", style = "table_spacing_flow"}
  local butts = frame.add{type = "table", column_count = 2}
  local move = butts.add{type = "sprite-button", sprite = "item/"..names.unit_move_tool, tooltip = names.unit_move_tool, style = "image_tab_slot", caption = {"unit_move_button"}}
  data.button_action_index[move.index] = {name = "move_button"}
  move.style.font = "default"
  local attack_move = butts.add{type = "sprite-button", sprite = "item/"..names.unit_attack_move_tool, tooltip = names.unit_attack_move_tool, style = "image_tab_slot"}
  data.button_action_index[attack_move.index] = {name = "attack_move_button"}
  local attack = butts.add{type = "sprite-button", sprite = "item/"..names.unit_attack_tool, tooltip = names.unit_attack_tool, style = "image_tab_slot"}
  data.button_action_index[attack.index] = {name = "attack_button"}
  local stop = butts.add{type = "sprite-button", sprite = "utility/set_bar_slot", tooltip = "Issue stop command", style = "image_tab_slot"}
  data.button_action_index[stop.index] = {name = "stop_button"}
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
      player = index,
      group = group,
      command = {}
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

local move_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local position = util.center(event.area)
  local offset = 1.5
  local radius = math.ceil((offset * table_size(group) ^ 0.5)/2)
  local index = 1
  local destinations = {}
  for x = -radius, radius, offset do
    for y = -radius, radius, offset do
      destinations[index] = {position.x + x, position.y + y}
      index = index + 1
    end
  end


  local command = function(i) return
    {
      type = defines.command.go_to_location,
      destination = destinations[i],
      distraction = defines.distraction.none
    }
  end

  index = 1
  for unit_number, entity in pairs (group) do
    entity.set_command(command(index))
    index = index + 1
  end
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local attack_move_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local position = util.center(event.area)
  local offset = 1.5
  local radius = math.ceil((offset * table_size(group) ^ 0.5)/2)
  local index = 1
  local destinations = {}
  for x = -radius, radius, offset do
    for y = -radius, radius, offset do
      destinations[index] = {position.x + x, position.y + y}
      index = index + 1
    end
  end


  local command = function(i) return
    {
      type = defines.command.go_to_location,
      destination = destinations[i],
      distraction = defines.distraction.by_anything
    }
  end

  index = 1
  for unit_number, entity in pairs (group) do
    entity.set_command(command(index))
    index = index + 1
  end
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local attack_units = function(event)
  local group = get_selected_units(event.player_index)
  if not group then
    data.selected_units[event.player_index] = nil
    return
  end
  local entities = event.entities
  if #entities == 0 then return end
  local positions = {}
  for k, ent in pairs (entities) do
    positions[ent.position] = ent
  end
  local dist = util.distance
  local attack_closest = function(unit)
    local closest
    local min = 5000000
    local position = unit.position
    for other_position, ent in pairs (positions) do
      local sep = dist(position, other_position)
      if sep < min then
        min = sep
        closest = ent
      end
    end
    unit.set_command
    {
      type = defines.command.attack,
      distraction = defines.distraction.none,
      target = closest
    }
  end
  for unit_number, unit in pairs (group) do
    attack_closest(unit)
  end
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local selected_area_actions = 
{
  [names.unit_selection_tool] = unit_selection,
  [names.unit_move_tool] = move_units,
  [names.unit_attack_move_tool] = attack_move_units,
  [names.unit_attack_tool] = attack_units
}

local alt_selected_area_actions = 
{
  [names.unit_selection_tool] = unit_selection,
  [names.unit_attack_tool] = attack_units
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

local on_ai_command_completed = function(event)
  --game.print("Command complete")
  local unit = data.units[event.unit_number]
  if unit then
    --game.print("A matey of our finished a command")
    local entity = unit.entity
    if (entity and entity.valid) then
      entity.set_command{type = defines.command.stop}
      --game.print("And he has stopped.")
    end
  end
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
  --[defines.event.on_player_created] = on_player_created
  [defines.events[require("shared").hotkeys.unit_move]] = gui_actions.move_button
}

unit_control.on_event = handler(events)

unit_control.on_init = function()
  global.unit_control = data
  game.map_settings.path_finder.max_steps_worked_per_tick = 1000000
  game.map_settings.path_finder.start_to_goal_cost_multiplier_to_terminate_path_find = 100000
  game.map_settings.path_finder.short_request_max_steps = 5000
  game.map_settings.path_finder.min_steps_to_check_path_find_termination = 50000
  game.map_settings.path_finder.max_clients_to_accept_any_new_request = 50000
  game.map_settings.steering.moving.force_unit_fuzzy_goto_behavior = true
  
end

unit_control.on_load = function()
  data = global.unit_control or data
end

return unit_control