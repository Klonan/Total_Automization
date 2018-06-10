class_names = require("shared").class_names
local classes =
{
  data =
  {
    buttons = {}
  }
}
local class_list = 
{
  pyro = require("script/classes/pyro"),
  heavy = require("script/classes/heavy"),
  sniper = require("script/classes/sniper"),
  medic = require("script/classes/medic"),
  soldier = require("script/classes/soldier"),
  demoman = require("script/classes/demoman"),
  scout = require("script/classes/scout")
}


classes.set_class = function(player, name)
  local class = class_list[name]
  if class then
    class(player)
  end
end

local join_class_button = function(data)
  return function(event)
    local player = game.players[event.player_index]
    if not (player and player.index) then return end
    if player.character then player.character.destroy() end
    return data(player)
  end
end

local choose_class_gui_init = function(player)

  local gui = player.gui.left

  local frame = gui.add{type = "frame", direction = "vertical"}
  local table = frame.add{type = "table", column_count = 1}
  for name, data in pairs (class_list) do
    local button = table.add{type = "button", caption = "Be a "..name}
    classes.data.buttons[button.index] = join_class_button(data)
  end

end

local on_player_joined_game = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  game.print(player.name or "Nameless player")
  choose_class_gui_init(player)
end

local on_gui_click = function(event)
  local button = event.element
  if not (button and button.valid) then return end

  --I need to think about this, might be hassle or good system...
  local action = classes.data.buttons[button.index] or function() return end
  return action(event)
end

local events =
{
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_gui_click] = on_gui_click
}

local action = handler(events)

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
  for class, data in pairs (class_list) do
    if data.on_init then
      data.on_init()
    end
  end
end
classes.on_load = function()
  classes.data = global.classes or classes.data
  for class, data in pairs (class_list) do
    if data.on_load then
      data.on_load()
    end
  end
end

classes.class_list = class_list

return classes