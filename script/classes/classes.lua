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
  confirm_loadout = function(event, param)
    local element = event.element
    local player = game.players[event.player_index]
    util.deregister_gui(param.gui, data.elements)
    param.gui.destroy()
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
  change_selected_secondary_weapon = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].secondary_weapon = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
  change_selected_secondary_ammo = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].secondary_ammo = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
  change_selected_pistol_weapon = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].pistol_weapon = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
  change_selected_pistol_ammo = function(event, param)
    local listbox = event.element
    if not (listbox and listbox.valid) then return end
    local player = game.players[event.player_index]
    data.selected_loadouts[player.name].pistol_ammo = listbox.get_item(listbox.selected_index)
    choose_class_gui_init(player)
  end,
}

choose_class_gui_init = function(player)

  local gui = player.gui.center
  util.deregister_gui(gui, data.elements)
  gui.clear()
  local frame = gui.add{type = "frame", direction = "vertical", caption = "CHOOSE YOUR LOADOUT"}
  frame.style = "image_frame"
  frame.style.width = player.display_resolution.width
  frame.style.height = player.display_resolution.height
  frame.style.top_padding = 16
  frame.style.bottom_padding = 16
  frame.style.left_padding = 16
  frame.style.right_padding = 16
  frame.style.align = "center"
  frame.style.vertical_align = "top"
  local mid_flow = frame.add{type = "flow", direction = "horizontal"}
  
  local loadout_frame = mid_flow.add{type = "frame", caption = "Choose your class", direction = "vertical"}
  loadout_frame.style.vertically_stretchable = false
  local loadout_listbox = loadout_frame.add{type = "list-box"}
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

  local info_table = loadout_frame.add{type = "table", column_count = 5, style = "slot_table"}
  local equipments = game.equipment_prototypes
  for name, count in pairs (loadouts[selected_loadout.name].equipment) do
    local equipment = equipments[name]
    if equipment then
      info_table.add{type = "sprite-button", sprite = "equipment/"..name, number = count, style = "technology_slot_button"}    
    end
  end
  
  local primary_gun_frame = mid_flow.add{type = "frame", caption = "Choose your Primary weapon", direction = "vertical"}
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

  primary_gun_frame.add{type = "label", caption = "Choose Primary Ammo", style = "description_label"}
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
  
  local secondary_gun_frame = mid_flow.add{type = "frame", caption = "Choose your Secondary weapon", direction = "vertical"}
  secondary_gun_frame.style.vertically_stretchable = false
  local secondary_gun_list = secondary_gun_frame.add{type = "list-box"}
  data.elements[secondary_gun_list.index] = {name = "change_selected_secondary_weapon"}
  local count = 1
  local index = 1
  local selected_secondary = util.first_key(selected_specification.secondary_weapons)
  for name, ammos in pairs (selected_specification.secondary_weapons) do
    secondary_gun_list.add_item(name)
    if name == selected_loadout.secondary_weapon then
      index = count
      selected_secondary = name
    end
    count = count + 1
  end
  secondary_gun_list.selected_index = index
  secondary_gun_list.style.vertically_squashable = true
  secondary_gun_list.style.horizontally_stretchable = true

  secondary_gun_frame.add{type = "label", caption = "Choose Secondary Ammo", style = "description_label"}
  local secondary_ammo_list = secondary_gun_frame.add{type = "list-box"}
  data.elements[secondary_ammo_list.index] = {name = "change_selected_secondary_ammo"}
  secondary_ammo_list.style.horizontally_stretchable = true
  local index = 1
  for k, ammo in pairs (selected_specification.secondary_weapons[selected_secondary]) do
    secondary_ammo_list.add_item(ammo)
    if ammo == selected_loadout.secondary_ammo then
      index = k
    end
    count = count + 1
  end
  secondary_ammo_list.selected_index = index
  secondary_ammo_list.style.vertically_squashable = true
  secondary_ammo_list.style.horizontally_stretchable = true

    
  local pistol_gun_frame = mid_flow.add{type = "frame", caption = "Choose your pistol", direction = "vertical"}
  pistol_gun_frame.style.vertically_stretchable = false
  local pistol_gun_list = pistol_gun_frame.add{type = "list-box"}
  data.elements[pistol_gun_list.index] = {name = "change_selected_pistol_weapon"}
  local count = 1
  local index = 1
  local selected_pistol = util.first_key(selected_specification.pistol_weapons)
  for name, ammos in pairs (selected_specification.pistol_weapons) do
    pistol_gun_list.add_item(name)
    if name == selected_loadout.pistol_weapon then
      index = count
      selected_pistol = name
    end
    count = count + 1
  end
  pistol_gun_list.selected_index = index
  pistol_gun_list.style.vertically_squashable = true
  pistol_gun_list.style.horizontally_stretchable = true

  pistol_gun_frame.add{type = "label", caption = "Choose Pistol Ammo", style = "description_label"}
  local pistol_ammo_list = pistol_gun_frame.add{type = "list-box"}
  data.elements[pistol_ammo_list.index] = {name = "change_selected_pistol_ammo"}
  local index = 1
  for k, ammo in pairs (selected_specification.pistol_weapons[selected_pistol]) do
    pistol_ammo_list.add_item(ammo)
    if ammo == selected_loadout.pistol_ammo then
      index = k
    end
    count = count + 1
  end
  pistol_ammo_list.selected_index = index
  pistol_ammo_list.style.vertically_squashable = true
  pistol_ammo_list.style.horizontally_stretchable = true

  local final_button_flow = frame.add{type = "flow"}
  final_button_flow.style.horizontally_stretchable = true
  final_button_flow.style.vertically_stretchable = true
  --final_button_flow.style.align = "right"
  final_button_flow.style.vertical_align = "bottom"

  if player.character then
    player.opened = frame
    data.elements[frame.index] = {name = "close_gui", gui = frame}
    local back_button = final_button_flow.add{type = "button", style = "back_button", caption = "Cancel"}
    data.elements[back_button.index] = {name = "close_gui", gui = frame}
  end

  local push = final_button_flow.add{type = "flow"}
  push.style.horizontally_stretchable = true
  local go_button = final_button_flow.add{type = "button", style = "confirm_button", caption = "Confirm loadout selection"}
  data.elements[go_button.index] = {name = "confirm_loadout", gui = frame}

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
    gui_functions[action.name](event, action)
  end
end

local on_gui_closed = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  --I need to think about this, might be hassle or good system...
  local action = data.elements[gui.index]
  if action then
    gui_functions[action.name](event, action)
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