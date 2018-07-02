defines.events.on_pre_player_changed_class = script.generate_event_name()

local util = require("script/script_util")
class_names = require("shared").class_names
weapon_names = require("shared").weapon_names
hotkeys = require("shared").hotkeys

classes =
{
  data =
  {
    elements = {}
  }
}

local class_list = 
{
  scout = require("script/classes/scout"),
  soldier = require("script/classes/soldier"),
  pyro = require("script/classes/pyro"),
  demoman = require("script/classes/demoman"),
  heavy = require("script/classes/heavy"),
  engineer = require("script/classes/engineer"),
  medic = require("script/classes/medic"),
  sniper = require("script/classes/sniper"),
  spy = require("script/classes/spy")
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
    local sprite = inner.add{type = "sprite", sprite = data.name}
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
    classes.data.elements[confirm_button.index] = {name = "confirm_button_action", param = {data = data, primaries = primaries, secondaries = secondaries, top_frame = param.top_frame}}
  end,
  confirm_button_action = function(event, param)
    local element = event.element
    local player = game.players[event.player_index]
    local data = param.data
    set_class(player, data.name, data.primary_weapons[param.primaries.selected_index], data.secondary_weapons[param.secondaries.selected_index])
    util.deregister_gui(param.top_frame, classes.data.elements)
    param.top_frame.destroy()
  end,
  close_gui = function(event, param)
    util.deregister_gui(param.gui, classes.data.elements)
    param.gui.destroy()
  end
}

local choose_class_gui_init = function(player)

  local gui = player.gui.center
  util.deregister_gui(gui, classes.data.elements)
  gui.clear()
  local frame = gui.add{type = "frame", direction = "vertical"}
  player.opened = frame
  classes.data.elements[frame.index] = {name = "close_gui", param = {gui = frame}}
  frame.style = "image_frame"
  frame.style.width = player.display_resolution.width
  frame.style.height = player.display_resolution.height
  frame.style.top_padding = 32
  frame.style.bottom_padding = 32
  frame.style.left_padding = 32
  frame.style.right_padding = 32
  frame.style.align = "center"
  frame.style.vertical_align = "top"
  local inner = frame.add{type = "flow", direction = "horizontal"}
  inner.style.horizontally_stretchable = true
  inner.style.align = "center"
  local class_flow = frame.add{type = "flow"}
  class_flow.style.horizontally_stretchable = true
  class_flow.style.align = "center"

  local offense = inner.add{type = "frame", caption = "Offense", direction = "horizontal"}
  for k, name in pairs ({"scout", "soldier", "pyro"}) do
    local data = class_list[name]
    local button = offense.add{type = "sprite-button", sprite = data.name, style = "slot_button"}
    button.style.width = player.display_resolution.width / (table_size(class_list) * 1.5)
    button.style.height = player.display_resolution.width / (table_size(class_list) * 1.5)
    classes.data.elements[button.index] = {name = "class_button_action", param = {data = data, class_flow = class_flow, top_frame = frame}}
  end
  
  local defense = inner.add{type = "frame", caption = "Defence", direction = "horizontal"}
  for k, name in pairs ({"demoman", "heavy", "engineer"}) do
    local data = class_list[name]
    local button = defense.add{type = "sprite-button", sprite = data.name, style = "slot_button"}
    button.style.width = player.display_resolution.width / (table_size(class_list) * 1.5)
    button.style.height = player.display_resolution.width / (table_size(class_list) * 1.5)
    classes.data.elements[button.index] = {name = "class_button_action", param = {data = data, class_flow = class_flow, top_frame = frame}}
  end
  
  local support = inner.add{type = "frame", caption = "Support", direction = "horizontal"}
  for k, name in pairs ({"medic", "sniper", "spy"}) do
    local data = class_list[name]
    local button = support.add{type = "sprite-button", sprite = data.name, style = "slot_button"}
    button.style.width = player.display_resolution.width / (table_size(class_list) * 1.5)
    button.style.height = player.display_resolution.width / (table_size(class_list) * 1.5)
    classes.data.elements[button.index] = {name = "class_button_action", param = {data = data, class_flow = class_flow, top_frame = frame}}
  end

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

local on_gui_click = function(event)
  local button = event.element
  if not (button and button.valid) then return end

  --I need to think about this, might be hassle or good system...
  local action = classes.data.elements[button.index]
  if action then
    gui_functions[action.name](event, action.param)
  end
end

local on_gui_closed = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  --I need to think about this, might be hassle or good system...
  local action = classes.data.elements[gui.index]
  if action then
    gui_functions[action.name](event, action.param)
  end
end

local events =
{
  --[defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events[hotkeys.change_class]] = change_class_hotkey_pressed
}

--error(serpent.block(events))

local action = handler(events)

classes.set_class = set_class

classes.on_event = function(event)
  action(event)
  for class, data in pairs (class_list) do
    if data.on_event then
      data.on_event(event)
    end
  end
end

classes.on_init = function()
  global.classes = global.classes or classes.data
  global.class_list = global.class_list or classes.class_list
  for class, data in pairs (class_list) do
    if data.on_init then
      data.on_init()
    end
  end
end

classes.on_load = function()
  classes.data = global.classes or classes.data
  classes.class_list = global.class_list or classes.class_list
  for class, data in pairs (class_list) do
    if data.on_load then
      data.on_load()
    end
  end
end

classes.class_list = class_list

return classes