local debug = {}

local on_player_created = function(event)
  local player = game.players[event.player_index]
  if player.character then player.character.destroy() end
  debug.libs.classes.set_class(player, "pyro")
  local count = 5
  for name, v in pairs(debug.libs.classes.class_list) do
    player.surface.create_entity{name = name, position = {player.position.x + count, player.position.y}, force = player.force}
    count = count + 5
  end
  player.surface.create_entity{position = {0, -10}, name = "entry", force = "enemy"}
  player.insert("entry-item")
end

local events = 
{
  [defines.events.on_player_created] = on_player_created
}

debug.on_event = handler(events)

debug.on_init = function()
  for k, surface in pairs (game.surfaces) do
    surface.always_day = true
  end
end

return debug