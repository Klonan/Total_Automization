local names = require("shared").unit_names

local unit_control = {}

local data =
{
  button_action_index = {},
  selected_groups = {},
  open_frames = {},
  unit_owners = {},
  stack_event_check = {}
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
    if not data.selected_groups[event.player_index] then return end
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
    local group = data.selected_groups[event.player_index]
    if not (group and group.valid) then
      data.selected_groups[event.player_index] = nil
      return
    end
    group.set_command
    {
      type = defines.command.stop
    }
  end,
}

local make_unit_gui = function(frame, group)
  frame.clear()
  local map = {}
  local entities = group.members
  if #entities == 0 then
    util.deregister_gui(frame, data.button_action_index)
    frame.destroy()
    group.destroy()
    return
  end
  for k, ent in pairs (group.members) do
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

local deregister_unit = function(entity, new_group)
  if not (entity and entity.valid) then return end
  if not (entity.type == "unit") then return end

  if new_group and new_group.valid then
    entity.set_command
    {
    type = defines.command.group,
    distraction = defines.distraction.none,
    group = new_group
    }
  else
    entity.set_command{type = defines.command.stop}
  end

  local player_index = data.unit_owners[entity.unit_number]
  if not player_index then return end

  local frame = data.open_frames[player_index]
  local group = data.selected_groups[player_index]
  
  if not (frame and frame.valid) then
    data.selected_groups[player_index] = nil
    return
  end

  if not (group and group.valid) then
    util.deregister_gui(frame, button_action_index)
    frame.destroy()
    return
  end
  make_unit_gui(frame, group)
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
  local group = data.selected_groups[player.index]
  if not (append and group and group.valid) then
    game.print("Making new unit group")
    group = surface.create_unit_group{position = center, force = player.force}
  end
  data.selected_groups[player.index] = group
  local index = player.index
  game.print(#entities)
  for k, ent in pairs (entities) do
    data.unit_owners[ent.unit_number] = index
    if ent.unit_group and ent.unit_group ~= group then
      deregister_unit(ent, group)
    end
    group.add_member(ent)
    ent.set_command{
      type = defines.command.group,
      distraction = defines.distraction.none,
      group = group
    }
  end
  game.print(#group.members)
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
  local group = data.selected_groups[event.player_index]
  if not (group and group.valid) then
    data.selected_groups[event.player_index] = nil
    return
  end
  local position = util.center(event.area)
  group.set_command
  {
    type = defines.command.go_to_location,
    destination = position,
    distraction = defines.distraction.none
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local attack_move_units = function(event)
  local group = data.selected_groups[event.player_index]
  if not (group and group.valid) then
    data.selected_groups[event.player_index] = nil
    return
  end
  local position = util.center(event.area)
  group.set_command
  {
    type = defines.command.go_to_location,
    destination = position,
    distraction = defines.distraction.by_anything
  }
  game.players[event.player_index].play_sound({path = names.unit_move_sound})
end

local attack_units = function(event)
  local entities = event.entities
  if #entities == 0 then return end
  local group = data.selected_groups[event.player_index]
  if not (group and group.valid) then
    data.selected_groups[event.player_index] = nil
    return
  end
  if #entities == 1 and entities[1].valid then
    group.set_command
    {
      type = defines.command.attack,
      distraction = defines.distraction.none,
      target = entities[1]
    }
  end
  local position = util.center(event.area)
  local first = entities[1]
  local last = entities[#entities]
  local center = {x = (first.position.x + last.position.x) / 2, y = (first.position.y + last.position.y) / 2}
  local radius = util.distance(center, first.position)
  group.set_command
  {
    type = defines.command.attack_area,
    destination = center,
    radius = radius,
    distaction = defines.distraction.none
  }
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

local events =
{
  [defines.events.on_player_selected_area] = on_player_selected_area,
  [defines.events.on_player_alt_selected_area] = on_player_alt_selected_area,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
  --[defines.event.on_player_created] = on_player_created
  [defines.events[require("shared").hotkeys.unit_move]] = gui_actions.move_button
}

unit_control.on_event = handler(events)

unit_control.on_init = function()
  global.unit_control = data
  game.map_settings.path_finder.max_steps_worked_per_tick = 100000
  game.map_settings.path_finder.start_to_goal_cost_multiplier_to_terminate_path_find = 100000
  game.map_settings.path_finder.short_request_max_steps = 5000
end

unit_control.on_load = function()
  data = global.unit_control or data
end

return unit_control