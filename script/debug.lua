local debug = {}
local names = require("shared")

local on_player_created = function(event)
  local player = game.players[event.player_index]
  if player.character then player.character.destroy() end
  --debug.libs.classes.set_class(player, "Pyro")
  local count = 5
  for name, class in pairs(debug.libs.classes.class_list) do
    player.surface.create_entity{name = class.name, position = {player.position.x + count, player.position.y}, force = player.force}
    count = count + 5
  end
  local pos = {0, -10}
  for name, ent in pairs (game.entity_prototypes) do
    if ent.type == "unit" then
      for k = 1, 10 do
        local position = player.surface.find_non_colliding_position(ent.name, pos, 150, 1) 
        if position then
          player.surface.create_entity{name = ent.name, position = position, force = "player"}
        else
          break
        end
      end
    end
  end
  player.get_quickbar().insert(names.unit_names.unit_selection_tool)
  --player.surface.create_entity{name = "Tazer Bot", position = {-10, -10}, force = "enemy"}
  --player.surface.create_entity{name = "Tazer Bot", position = {10, -10}, force = "player"}
  player.insert("entry-item")
  player.insert("exit-item")
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