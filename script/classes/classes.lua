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

local spawn_player = function(player)
  local loadout = data.selected_loadouts[player.name]
  if not loadout then return error("NO LOADOUT FOR PLAYER "..player.name) end
  local spec = loadouts[loadout.name]
  local force = player.force
  local surface = player.surface
  local character = player.character
  if not character then
    local origin = force.get_spawn_position(surface)
    local position = surface.find_non_colliding_position("player", origin, 100, 1)
    character = surface.create_entity{name = "player", position = position, force = force}
  end
  local armor_inventory = character.get_inventory(defines.inventory.player_armor)
  armor_inventory.clear()
  local armor_stack = armor_inventory[1]
  armor_stack.set_stack{name = "power-armor-mk2"}
  local grid = armor_stack.grid
  for name, count in pairs (spec.equipment) do
    for k = 1, count do
      grid.put{name = name}
    end
  end

  local gun_inventory = character.get_inventory(defines.inventory.player_guns)
  local ammo_inventory = character.get_inventory(defines.inventory.player_ammo)
  ammo_inventory.clear()
  gun_inventory.clear()
  local items = game.item_prototypes
  for k, name in pairs ({"primary", "secondary", "pistol"}) do
    local gun_stack = gun_inventory[k]
    local ammo_stack = ammo_inventory[k]
    local gun_name = loadout[name.."_weapon"]
    local ammo_name = loadout[name.."_ammo"]
    if items[gun_name] and items[ammo_name] then
      gun_stack.set_stack{name = gun_name}
      ammo_stack.set_stack{name = ammo_name}
    end
  end


end

local choose_class_gui_init
local gui_functions = 
{
  confirm_loadout = function(event, param)
    local element = event.element
    local player = game.players[event.player_index]
    util.deregister_gui(param.gui, data.elements)
    param.gui.destroy()
    spawn_player(player)
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

local gun_info =
{
  range = "Range",
  min_range = "Min Range",
  cooldown = "Cooldown",
  damage_modifier = "Damage modifier",
}

local add_gun_info = function(frame, gun)
  local gun_prototype = game.item_prototypes[gun]
  if not gun_prototype then return end
  local info_flow = frame.add{type = "flow", direction = "horizontal"}
  info_flow.style.horizontally_stretchable = true
  local sprite = info_flow.add{type = "sprite-button", sprite = "item/"..gun_prototype.name, tooltip = gun_prototype.localised_name, style = "technology_slot_button"}
  local more_info_flow = info_flow.add{type = "flow", direction = "vertical"}
  more_info_flow.style.horizontally_squashable = true
  for key, name in pairs (gun_info) do
    local value = gun_prototype.attack_parameters[key]
    if value then
      local label = more_info_flow.add{type = "label", caption = {"", name, {"colon"}, " ", math.floor(value*100)/100}}
      label.style.horizontally_stretchable = true
    end
  end
end

local trigger_info =
{
  damage = "Damage",

}

local add_trigger_info
add_trigger_info = function(gui, trigger, indent)
  if not trigger then return end
  
  if trigger.repeat_count and trigger.repeat_count > 1 then    
    local label = gui.add{type = "label", caption = {"", indent, "Repeat count", {"colon"}, " ", trigger.repeat_count}}
    label.style.horizontally_stretchable = true
  end

  if trigger.radius then    
    local label = gui.add{type = "label", caption = {"", indent, "Effect area Radius", {"colon"}, " ", trigger.radius}}
    label.style.horizontally_stretchable = true
  end

  local action = trigger.action_delivery or {}
  indent = indent.."      "
  for k, delivery in pairs (action) do

    if delivery.target_effects then
      for k, effect in pairs (delivery.target_effects) do
        if effect.damage then
          local label = gui.add{type = "label", caption = {"", indent, "Damage", {"colon"}, " ", effect.damage.amount}}
          label.style.horizontally_stretchable = true
        end
        if effect.action then
          for k, trigger in pairs (effect.action) do
            add_trigger_info(gui, trigger, indent)
          end
        end
      end
    end
    if delivery.projectile then
      local prototype = game.entity_prototypes[delivery.projectile]
      local label = gui.add{type = "label", caption = {"", indent, "Create entity", {"colon"}, " ", prototype.localised_name}}
      label.style.horizontally_stretchable = true
      for k, trigger in pairs (prototype.attack_result or {}) do
        add_trigger_info(gui, trigger, indent)
      end
      for k, trigger in pairs (prototype.final_attack_result or {}) do
        add_trigger_info(gui, trigger, indent)
      end
    end
  end
end


local add_ammo_info = function(frame, ammo)
  local ammo_prototype = game.item_prototypes[ammo]
  if not ammo_prototype then return end
  local info_flow = frame.add{type = "flow", direction = "horizontal"}
  local sprite = info_flow.add{type = "sprite-button", sprite = "item/"..ammo_prototype.name, tooltip = ammo_prototype.localised_name, style = "technology_slot_button"}
  local more_info_flow = info_flow.add{type = "flow", direction = "vertical"}
  if ammo_prototype.magazine_size > 1 then
    local label = more_info_flow.add{type = "label", caption = {"", "Magazine size", {"colon"}, " ", ammo_prototype.magazine_size}}
    label.style.horizontally_stretchable = true
  end
  local trigger_effects = ammo_prototype.get_ammo_result()
  for k, trigger in pairs (trigger_effects) do
    add_trigger_info(more_info_flow, trigger, "")
  end
end



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
  local items = game.item_prototypes

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
  add_gun_info(primary_gun_frame, selected_primary)

  primary_gun_frame.add{type = "label", caption = "Choose Primary Ammo", style = "description_label"}
  local primary_ammo_list = primary_gun_frame.add{type = "list-box"}
  data.elements[primary_ammo_list.index] = {name = "change_selected_primary_ammo"}
  primary_ammo_list.style.horizontally_stretchable = true
  local index = 1
  local selected_ammo = util.first_value(selected_specification.primary_weapons[selected_primary])
  for k, ammo in pairs (selected_specification.primary_weapons[selected_primary]) do
    primary_ammo_list.add_item(ammo)
    if ammo == selected_loadout.primary_ammo then
      selected_ammo = ammo
      index = k
    end
    count = count + 1
  end
  primary_ammo_list.selected_index = index
  primary_ammo_list.style.vertically_squashable = true
  primary_ammo_list.style.horizontally_stretchable = true

  add_ammo_info(primary_gun_frame, selected_ammo)
  ammo_prototype = items[selected_ammo]
  if gun_prototype then
    local info_flow = primary_gun_frame.add{type = "flow", direction = "horizontal"}
    local sprite = info_flow.add{type = "sprite-button", sprite = "item/"..gun_prototype.name, tooltip = gun_prototype.localised_name, style = "technology_slot_button"}
    local more_info_flow = info_flow.add{type = "flow", direction = "vertical"}
    for key, name in pairs (gun_info) do
      local value = gun_prototype.attack_parameters[key]
      if value then
        more_info_flow.add{type = "label", caption = {"", name, {"colon"}, " ", value}}
      end
    end
  end
  
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