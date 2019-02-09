local util = tf_require("script/script_util")
hotkeys = names.hotkeys
local names = names
local loadouts = tf_require("script/classes/loadouts")

local data =
{
  elements = {},
  selected_loadouts = {},
  current_loadouts = {}
}

local class_events =
{
  on_pre_player_changed_class = script.generate_event_name()
}

local spawn_player = function(player)
  script.raise_event(class_events.on_pre_player_changed_class, {player_index = player.index})
  local loadout = data.current_loadouts[player.name]
  if not loadout then return error("NO CURRENT LOADOUT FOR PLAYER "..player.name) end
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
      gun_inventory.set_filter(k, nil)
      gun_inventory.set_filter(k, gun_name)
      gun_stack.set_stack{name = gun_name}
      ammo_inventory.set_filter(k, nil)
      ammo_inventory.set_filter(k, ammo_name)
      ammo_stack.set_stack(ammo_name)
    end
  end
  if not player.character then
    player.character = character
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
    local loadout = data.selected_loadouts[player.name]
    data.current_loadouts[player.name] = util.copy(loadout)
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
  --range = {name = "Range"},
  min_range = {name = "Min Range", default = 0},
  cooldown = {name = "Cooldown"},
  damage_modifier = {name = "Damage modifier", default = 1},
  ammo_consumption_modifier = {name = "Ammo Consumption Modifier", default = 1}
}

local add_gun_info = function(frame, gun)
  local gun_prototype = game.item_prototypes[gun]
  if not gun_prototype then return end
  local info_flow = frame.add{type = "flow", direction = "horizontal"}
  info_flow.style.horizontally_stretchable = true
  local sprite = info_flow.add{type = "sprite-button", sprite = "item/"..gun_prototype.name, tooltip = gun_prototype.localised_name, style = "technology_slot_button"}
  local more_info_flow = info_flow.add{type = "scroll-pane", direction = "vertical"}
  more_info_flow.style.vertically_stretchable = true
  more_info_flow.style.horizontally_squashable = true
  for key, info in pairs (gun_info) do
    local value = gun_prototype.attack_parameters[key]
    if value and (not info.default or info.default ~= value) then
      local label = more_info_flow.add{type = "label", caption = info.name..": ".. math.floor(value*100)/100}
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
  if trigger.type == "line" then
    local label = gui.add{type = "label", caption = {"", indent, "Damages entities in a straight line."}}
    label.style.horizontally_stretchable = true
  end
  if trigger.repeat_count and trigger.repeat_count > 1 then
    local label = gui.add{type = "label", caption = {"", indent, "Repeat count: ", trigger.repeat_count}}
    label.style.horizontally_stretchable = true
  end

  if trigger.radius then
    local label = gui.add{type = "label", caption = {"", indent, "Effect area Radius: ", trigger.radius}}
    label.style.horizontally_stretchable = true
  end

  local action = trigger.action_delivery or {}
  indent = indent.."      "
  for k, delivery in pairs (action) do

    if delivery.target_effects then
      for k, effect in pairs (delivery.target_effects) do
        if effect.damage then
          local label = gui.add{type = "label", caption = {"", indent, "Damage: ", effect.damage.amount}}
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
      --local label = gui.add{type = "label", caption = {"", indent, "Shoots a ", prototype.name}}
      --label.style.horizontally_stretchable = true

      local label = gui.add{type = "label", caption = {"", indent, "Projectile Starting Speed: ", math.floor(delivery.starting_speed * 100) / 100}}
      label.style.horizontally_stretchable = true
      local label = gui.add{type = "label", caption = {"", indent, "Projectile Range: ", math.floor(delivery.max_range * 100) / 100}}
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
  if not ammo_prototype then error(ammo.." not real?") return end
  local info_flow = frame.add{type = "flow", direction = "horizontal"}
  info_flow.style.vertically_stretchable = true
  local sprite = info_flow.add{type = "sprite-button", sprite = "item/"..ammo_prototype.name, tooltip = ammo_prototype.localised_name, style = "technology_slot_button"}
  local more_info_flow = info_flow.add{type = "scroll-pane", direction = "vertical", style = "tab_scroll_pane"}
  more_info_flow.style.vertically_squashable = true
  more_info_flow.style.vertically_stretchable = true
  if ammo_prototype.magazine_size > 1 then
    local label = more_info_flow.add{type = "label", caption = "Magazine size: "..ammo_prototype.magazine_size}
    label.style.horizontally_stretchable = true
  end
  if ammo_prototype.reload_time > 0 then
    local label = more_info_flow.add{type = "label", caption = "Reload time: "..ammo_prototype.reload_time}
    label.style.horizontally_stretchable = true
  end
  local trigger_effects = ammo_prototype.get_ammo_type().action
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
  local align_table = frame.add{type = "table", column_count = 4}
  align_table.style.column_alignments[1] = "top-left"
  align_table.style.column_alignments[2] = "top-left"
  align_table.style.column_alignments[3] = "top-left"
  align_table.style.column_alignments[4] = "top-left"
  align_table.style.vertically_stretchable = true
  align_table.style.horizontally_stretchable = true

  local loadout_frame = align_table.add{type = "frame", caption = "Choose your class", direction = "vertical"}
  loadout_frame.style.vertically_stretchable = true
  loadout_frame.style.horizontally_stretchable = true
  local loadout_listbox = loadout_frame.add{type = "list-box"}
  loadout_listbox.style.horizontally_stretchable = true
  util.register_gui(data.elements, loadout_listbox, {type = "change_selected_class"})
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
  if selected_specification.description then
    local description = loadout_frame.add{type = "label", caption = selected_specification.description, style = "bold_label"}
    description.style.single_line = false
    description.style.horizontally_stretchable = true
  end
  local equipments = game.equipment_prototypes
  for name, count in pairs (selected_specification.equipment) do
    local equipment = equipments[name]
    if equipment then
      local flow = loadout_frame.add{type = "flow"}
      flow.style.vertical_align = "center"
      local sprite = flow.add{type = "sprite-button", sprite = "equipment/"..equipment.name, style = "technology_slot_button"}
      flow.add{type = "label", caption = {"", count, " x ", equipment.localised_name}, style = "bold_label"}
    end
  end

  local primary_gun_frame = align_table.add{type = "frame", caption = "Choose your Primary weapon", direction = "vertical"}
  primary_gun_frame.style.vertically_stretchable = true
  local primary_gun_list = primary_gun_frame.add{type = "list-box"}
  util.register_gui(data.elements, primary_gun_list, {type = "change_selected_primary_weapon"})
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
  selected_loadout.primary_weapon = selected_primary
  primary_gun_list.selected_index = index
  primary_gun_list.style.vertically_squashable = true
  primary_gun_list.style.horizontally_stretchable = true
  add_gun_info(primary_gun_frame, selected_primary)


  local secondary_gun_frame = align_table.add{type = "frame", caption = "Choose your secondary weapon", direction = "vertical"}
  secondary_gun_frame.style.vertically_stretchable = true
  local secondary_gun_list = secondary_gun_frame.add{type = "list-box"}
  util.register_gui(data.elements, secondary_gun_list, {type = "change_selected_secondary_weapon"})
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
  selected_loadout.secondary_weapon = selected_secondary
  secondary_gun_list.selected_index = index
  secondary_gun_list.style.vertically_squashable = true
  secondary_gun_list.style.horizontally_stretchable = true
  add_gun_info(secondary_gun_frame, selected_secondary)

  local pistol_gun_frame = align_table.add{type = "frame", caption = "Choose your pistol weapon", direction = "vertical"}
  pistol_gun_frame.style.vertically_stretchable = true
  local pistol_gun_list = pistol_gun_frame.add{type = "list-box"}
  util.register_gui(data.elements, pistol_gun_list, {type = "change_selected_pistol_weapon"})
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
  selected_loadout.pistol_weapon = selected_pistol
  pistol_gun_list.selected_index = index
  pistol_gun_list.style.vertically_squashable = true
  pistol_gun_list.style.horizontally_stretchable = true
  add_gun_info(pistol_gun_frame, selected_pistol)

  local spacer = align_table.add{type = "flow"}
  spacer.style.vertically_stretchable = true

  local primary_ammo_frame = align_table.add{type = "frame", caption = "Choose Primary Weapon Ammo", direction = "vertical"}
  primary_ammo_frame.style.vertically_stretchable = true
  primary_ammo_frame.style.vertically_squashable = true
  local primary_ammo_list = primary_ammo_frame.add{type = "list-box"}
  util.register_gui(data.elements, primary_ammo_list, {type = "change_selected_primary_ammo"})
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
  selected_loadout.primary_ammo = selected_ammo
  primary_ammo_list.selected_index = index
  primary_ammo_list.style.vertically_squashable = true
  primary_ammo_list.style.horizontally_stretchable = true
  add_ammo_info(primary_ammo_frame, selected_ammo)


  local secondary_ammo_frame = align_table.add{type = "frame", caption = "Choose Secondary Weapon Ammo", direction = "vertical"}
  secondary_ammo_frame.style.vertically_stretchable = true
  secondary_ammo_frame.style.vertically_squashable = true
  local secondary_ammo_list = secondary_ammo_frame.add{type = "list-box"}
  util.register_gui(data.elements, secondary_ammo_list, {type = "change_selected_secondary_ammo"})
  secondary_ammo_list.style.horizontally_stretchable = true
  local index = 1
  local selected_ammo = util.first_value(selected_specification.secondary_weapons[selected_secondary])
  for k, ammo in pairs (selected_specification.secondary_weapons[selected_secondary]) do
    secondary_ammo_list.add_item(ammo)
    if ammo == selected_loadout.secondary_ammo then
      selected_ammo = ammo
      index = k
    end
    count = count + 1
  end
  selected_loadout.secondary_ammo = selected_ammo
  secondary_ammo_list.selected_index = index
  secondary_ammo_list.style.vertically_squashable = true
  secondary_ammo_list.style.horizontally_stretchable = true
  add_ammo_info(secondary_ammo_frame, selected_ammo)

  local pistol_ammo_frame = align_table.add{type = "frame", caption = "Choose Pistol Ammo", direction = "vertical"}
  pistol_ammo_frame.style.vertically_stretchable = true
  pistol_ammo_frame.style.vertically_squashable = true
  local pistol_ammo_list = pistol_ammo_frame.add{type = "list-box"}
  util.register_gui(data.elements, pistol_ammo_list, {type = "change_selected_pistol_ammo"})
  pistol_ammo_list.style.horizontally_stretchable = true
  local index = 1
  local selected_ammo = util.first_value(selected_specification.pistol_weapons[selected_pistol])
  for k, ammo in pairs (selected_specification.pistol_weapons[selected_pistol]) do
    pistol_ammo_list.add_item(ammo)
    if ammo == selected_loadout.pistol_ammo then
      selected_ammo = ammo
      index = k
    end
    count = count + 1
  end
  selected_loadout.pistol_ammo = selected_ammo
  pistol_ammo_list.selected_index = index
  pistol_ammo_list.style.vertically_squashable = true
  pistol_ammo_list.style.horizontally_stretchable = true
  add_ammo_info(pistol_ammo_frame, selected_ammo)

  local final_button_flow = frame.add{type = "flow"}
  final_button_flow.style.horizontally_stretchable = true
  final_button_flow.style.vertical_align = "bottom"

  if player.character then
    player.opened = frame
    util.register_gui(data.elements, frame, {type = "close_gui", gui = frame})
    local back_button = final_button_flow.add{type = "button", style = "back_button", caption = "Cancel"}
    util.register_gui(data.elements, back_button, {type = "close_gui", gui = frame})
  end

  local push = final_button_flow.add{type = "flow"}
  push.style.horizontally_stretchable = true
  local go_button = final_button_flow.add{type = "button", style = "confirm_button", caption = "Confirm loadout selection"}
  util.register_gui(data.elements, go_button, {type = "confirm_loadout", gui = frame})

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
  local x = player.position.x
  local y = player.position.y
  if not (player.surface.count_entities_filtered{area = {{x - 32, y - 32},{x + 32, y + 32}}, name = names.entities.command_center} > 0) then
    player.print("You can only change your class when near a command center")
    return
  end
  choose_class_gui_init(player)
end

local on_gui_interaction = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data.elements[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
    gui_functions[action.type](event, action)
    return true
  end
end

local default_loadout = function()
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
  return player_loadout
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  data.selected_loadouts[player.name] = default_loadout()
end

local on_player_respawned = function(event)
  spawn_player(game.players[event.player_index])
end

local check_guns = function(player)
  local character = player.character
  if not (character and character.valid) then return end

  local loadout = data.current_loadouts[player.name]
  if not loadout then return end
  local gun_inventory = character.get_inventory(defines.inventory.player_guns)

  local remove_opened = function(player, name)
    player.opened.remove_item{name = name, count = 100}
  end

  local changed = false
  local items = game.item_prototypes
  for k, name in pairs ({"primary", "secondary", "pistol"}) do
    local gun_stack = gun_inventory[k]
    local gun_name = loadout[name.."_weapon"]
    if items[gun_name] and (not gun_stack.valid_for_read or (gun_stack.valid_for_read and gun_stack.name ~= gun_name)) then
      pcall(remove_opened, player, gun_name)
      character.remove_item{name = gun_name, count = 100}
      gun_inventory.set_filter(k, nil)
      gun_inventory.set_filter(k, gun_name)
      gun_stack.set_stack{name = gun_name}
      changed = true
    end
  end

  return changed
end

local on_player_gun_inventory_changed = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  if check_guns(player) then
    player.print("Guns can only be changed through loadout selection.")
  end
end

local on_player_joined_team = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  if player.character then player.character.destroy() end
  choose_class_gui_init(player)
end

local events =
{
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_player_respawned] = on_player_respawned,
  [defines.events.on_gui_click] = on_gui_interaction,
  [defines.events.on_gui_closed] = on_gui_interaction,
  [defines.events.on_player_gun_inventory_changed] = on_player_gun_inventory_changed,
  [defines.events.on_gui_selection_state_changed] = on_gui_interaction,
  [defines.events[hotkeys.change_class]] = change_class_hotkey_pressed
}

local register_events = function()
  if remote.interfaces["pvp"] then
    local pvp_events = remote.call("pvp", "get_events")
    events[pvp_events.on_player_joined_team] = on_player_joined_team
  end
end

remote.add_interface("classes",
{
  get_events = function() return util.copy(class_events) end
})

local classes = {}

classes.on_init = function()
  global.classes = global.classes or data
  for k, player in pairs (game.players) do
    data.selected_loadouts[player.name] = default_loadout()
  end
  register_events()
  classes.on_event = handler(events)
end

classes.on_load = function()
  data = global.classes or data
  register_events()
  classes.on_event = handler(events)
end

return classes
