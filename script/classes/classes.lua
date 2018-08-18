defines.events.on_pre_player_changed_class = script.generate_event_name()

local util = require("script/script_util")
hotkeys = require("shared").hotkeys
local names = require("shared")
local loadouts = require("script/classes/loadouts")

classes =
{
}

local data =
{
  elements = {},
  selected_loadouts = {}
}


local set_class = function(player, name, primary, secondary)
  script.raise_event(defines.events.on_pre_player_changed_class, {player_index = player.index})
  if player.character then player.character.destroy() end
  player.create_character(name)
  local character = player.character
  if primary then
    character.insert(primary)
    character.insert(primary.." Ammo")
  end
  if secondary then
    character.insert(secondary)
    character.insert(secondary.." Ammo")
  end
end

local stats = 
{
  max_health = "Health",
  running_speed = "Movement Speed",
  --etc.
}
local choose_class_gui_init
local gui_functions = 
{
  class_button_action = function(event, param)
    local element = event.element
    local data = param.data
    local name = data.name
    local player = game.players[event.player_index]
    local flow = param.class_flow
    flow.clear()
    local inner = flow.add{type = "flow", direction = "horizontal"}
    inner.style.vertically_squashable = true
    --local sprite = inner.add{type = "sprite", sprite = data.name}
    local character = game.entity_prototypes[data.name]
    local inner_more = inner.add{type = "flow", direction = "vertical"}
    local info = inner_more.add{type = "frame", caption = data.name}
    local stat_table = info.add{type = "table", column_count = 2}
    for stat, name in pairs (stats) do
      stat_table.add{type = "label", caption = name..": "}
      local value = character[stat]
      if value < 1 then
        stat_table.add{type = "label", caption = value * 100}
      else
        stat_table.add{type = "label", caption = value}
      end
    end
    local loadout = inner_more.add{type = "frame", caption = "Loadout"}
    local loadout_table = loadout.add{type = "table", column_count = 2}
    loadout_table.add{type = "label", caption = "Primary: "}
    local primaries = loadout_table.add{type = "drop-down"}
    local set = false
    for k, name in pairs (data.primary_weapons) do
      primaries.add_item(name)
      if player.get_item_count(name) > 0 then
        primaries.selected_index = k
        set = true
      end
    end
    if not set then
      primaries.selected_index = 1
    end

    loadout_table.add{type = "label", caption = "Secondary: "}
    local secondaries = loadout_table.add{type = "drop-down"}
    set = false
    for k, name in pairs (data.secondary_weapons) do
      secondaries.add_item(name)
      if player.get_item_count(name) > 0 then
        secondaries.selected_index = k
        set = true
      end
    end
    if not set then
      secondaries.selected_index = 1
    end

    local confirm_button = inner_more.add{type = "button", caption = "GO GO GO"}
    data.elements[confirm_button.index] = {name = "confirm_button_action", param = {data = data, primaries = primaries, secondaries = secondaries, top_frame = param.top_frame}}
  end,
  confirm_button_action = function(event, param)
    local element = event.element
    local player = game.players[event.player_index]
    local data = param.data
    set_class(player, data.name, data.primary_weapons[param.primaries.selected_index], data.secondary_weapons[param.secondaries.selected_index])
    util.deregister_gui(param.top_frame, data.elements)
    param.top_frame.destroy()
  end,
  close_gui = function(event, param)
    util.deregister_gui(param.gui, data.elements)
    param.gui.destroy()
  end,
  change_selected_class = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].name = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
  change_selected_primary_weapon = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].primary_weapon = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
  change_selected_primary_ammo = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].primary_ammo = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
}

choose_class_gui_init = function(player)

  local gui = player.gui.center
  util.deregister_gui(gui, data.elements)
  gui.clear()
  local frame = gui.add{type = "frame", direction = "horizontal", caption = "CHOOSE YOUR LOADOUT"}
  player.opened = frame
  data.elements[frame.index] = {name = "close_gui", param = {gui = frame}}
  frame.style = "image_frame"
  frame.style.width = player.display_resolution.width
  frame.style.height = player.display_resolution.height
  frame.style.top_padding = 32
  frame.style.bottom_padding = 32
  frame.style.left_padding = 32
  frame.style.right_padding = 32
  frame.style.align = "center"
  frame.style.vertical_align = "top"
  local class_frame = frame.add{type = "frame", caption = "Choose your class", direction = "vertical"}
  class_frame.style.vertically_stretchable = false
  local loadout_listbox = class_frame.add{type = "list-box"}
  loadout_listbox.style.horizontally_stretchable = true
  data.elements[loadout_listbox.index] = {name = "change_selected_class"}

  local selected_loadout = data.selected_loadouts[player.name]
  local selected_specification = loadouts[selected_loadout.name]
  local count = 1
  local index = 1
  for name, loadout in pairs (loadouts) do
    loadout_listbox.add_item(name)
    if name == selected_loadout.name then
      index = count
    end
    count = count + 1
  end
  loadout_listbox.selected_index = index

  local info_table = class_frame.add{type = "table", column_count = 5, style = "slot_table"}
  local equipments = game.equipment_prototypes
  for name, count in pairs (loadouts[selected_loadout.name].equipment) do
    local equipment = equipments[name]
    if equipment then
      info_table.add{type = "sprite-button", sprite = "equipment/"..name, number = count, style = "technology_slot_button"}    
    end
  end
  
  local primary_gun_frame = frame.add{type = "frame", caption = "Choose your Primary weapon", direction = "vertical"}
  primary_gun_frame.style.vertically_stretchable = false
  local primary_gun_list = primary_gun_frame.add{type = "list-box"}
  data.elements[primary_gun_list.index] = {name = "change_selected_primary_weapon"}
  local count = 1
  local index = 1
  local selected_primary = util.first_key(selected_specification.primary_weapons)
  for name, ammos in pairs (selected_specification.primary_weapons) do
    primary_gun_list.add_item(name)
    if name == selected_loadout.primary_weapon then
      index = count
      selected_primary = name
    end
    count = count + 1
  end
  primary_gun_list.selected_index = index
  primary_gun_list.style.vertically_squashable = true
  primary_gun_list.style.horizontally_stretchable = true

  primary_gun_frame.add{type = "label", caption = "Primary Ammo"}
  local primary_ammo_list = primary_gun_frame.add{type = "list-box"}
  data.elements[primary_ammo_list.index] = {name = "change_selected_primary_ammo"}
  primary_ammo_list.style.horizontally_stretchable = true
  local index = 1
  for k, ammo in pairs (selected_specification.primary_weapons[selected_primary]) do
    primary_ammo_list.add_item(ammo)
    if ammo == selected_loadout.primary_ammo then
      index = k
    end
    count = count + 1
  end
  primary_ammo_list.selected_index = index
  primary_ammo_list.style.vertically_squashable = true
  primary_ammo_list.style.horizontally_stretchable = true

end

local on_player_joined_game = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  game.print(player.name or "Nameless player")
  choose_class_gui_init(player)
end

local change_class_hotkey_pressed = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  game.print(player.name or "Nameless player")
  choose_class_gui_init(player)
end

local on_gui_interaction = function(event)
  local element = event.element
  if not (element and element.valid) then return end

  local action = data.elements[element.index]
  if action then
    gui_functions[action.name](event, action.param)
  end
end

local on_gui_closed = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  --I need to think about this, might be hassle or good system...
  local action = data.elements[gui.index]
  if action then
    gui_functions[action.name](event, action.param)
  end
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  local loadout_name, loadout = next(loadouts)
  local player_loadout = {name = loadout_name}

  local primary_name, primary_ammos = next(loadout.primary_weapons)
  local primary_ammo_name = primary_ammos[1]
  player_loadout.primary_weapon = primary_name
  player_loadout.primary_ammo = primary_ammo_name

  local secondary_name, secondary_ammos = next(loadout.secondary_weapons)
  local secondary_ammo_name = secondary_ammos[1]
  player_loadout.secondary_weapon = secondary_name
  player_loadout.secondary_ammo = secondary_ammo_name

  local pistol_name, pistol_ammos = next(loadout.pistol_weapons)
  local pistol_ammo_name = pistol_ammos[1]
  player_loadout.pistol_weapon = pistol_name
  player_loadout.pistol_ammo = pistol_ammo_name

  data.selected_loadouts[player.name] = player_loadout
  --error(serpent.block(player_loadout))
end

local events =
{
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_gui_click] = on_gui_interaction,
  [defines.events.on_gui_closed] = on_gui_interaction,
  [defines.events.on_gui_selection_state_changed] = on_gui_interaction,
  [defines.events[hotkeys.change_class]] = change_class_hotkey_pressed
}

--error(serpent.block(events))

classes.set_class = set_class

classes.on_event = handler(events)

classes.on_init = function()
  global.classes = global.classes or data
end

classes.on_load = function()
  data = global.classes or data
  classes.class_list = global.class_list or classes.class_list
  for class, data in pairs (class_list) do
    if data.on_load then
      data.on_load()
    end
  end
end

classes.class_list = class_list

return classes