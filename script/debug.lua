local debug = {}
local names = require("shared")

local get_position = function(n)
  local root = n^0.5
  local nearest_root = math.floor(root+0.5)
  local upper_root = math.ceil(root)
  local root_difference = math.abs(nearest_root^2 - n)
  if nearest_root == upper_root then
    x = upper_root - root_difference
    y = nearest_root
  else
    x = upper_root
    y = root_difference
  end
  --game.print(x.." - "..y)
  return {x, y}
end

local on_player_created = function(event)
  local player = game.players[event.player_index]
  if player.character then player.character.destroy() end
  --debug.libs.classes.set_class(player, "Pyro")
  local count = 5
  for name, class in pairs(debug.libs.classes.class_list) do
    --player.surface.create_entity{name = class.name, position = {player.position.x + count, player.position.y}, force = player.force}
    count = count + 5
  end
  local team1 = {
    blaster_bot = 20,
    plasma_bot = 10
  }
  local pos = {x = 0, y = 0}
  for name, count in pairs (team1) do
    for x = 1, count do
      local vec = get_position(math.random(300))
      player.surface.create_entity{name = names.units[name], position = {pos.x + vec[1], pos.y + vec[2]}, force = "player"}
    end 
  end
  team2 = {
    smg_guy = 40,
    flame_car = 10
  }
  local pos = {x = 50, y = 0}
  for name, count in pairs (team2) do
    for x = 1, count do
      local vec = get_position(math.random(300))
      player.surface.create_entity{name = names.units[name], position = {pos.x + vec[1], pos.y + vec[2]}, force = "enemy"}
    end 
  end
  player.get_quickbar().insert(names.unit_tools.unit_selection_tool)
  player.get_quickbar().insert(names.unit_tools.deployer_selection_tool)
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

remote.add_interface("debug", {dump = function() log(serpent.block(global)) end})

return debug