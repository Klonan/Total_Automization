local classes = require "script/classes/classes"
local teleporters = require "script/teleporters"

on_player_created = function(event)
  local player = game.players[event.player_index]
  if player.character then player.character.destroy() end
  classes.set_class(player, "pyro")
  local count = 5
  for name, v in pairs(classes.class_list) do
    player.surface.create_entity{name = name, position = {player.position.x + count, player.position.y}, force = player.force}
    count = count + 5
  end
  player.surface.create_entity{position = {0, -10}, name = "entry", force = "enemy"}
end

local events = 
{
  [defines.events.on_player_created] = on_player_created
}

on_event = function(event)
  local action = events[event.name] or function() end
  action(event)
  classes.on_event(event)
  teleporters.on_event(event)
end

script.on_event(defines.events, on_event)
script.on_init(function()
  game.speed = settings.startup["game-speed"].value
  for k, surface in pairs (game.surfaces) do
    surface.always_day = true
  end
end)
--todo control points