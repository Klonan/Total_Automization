local debug = {}
local names = names
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
  --player.insert(names.entities.buy_chest)
  --player.insert(names.entities.sell_chest)

  --if true then return end

  --if true then return {} end
  local team1 = {
    --beetle = 80,
    --plasma_bot = 1,
    --laser_bot = 20,
    --tazer_bot = 20,
    --blaster_bot = 50
    shell_tank = 1,
    --plasma_bot = 20,
    --acid_worm = 20,
    --piercing_biter = 50
    --scatter_spitter = 20
    --smg_guy = 50
  }
  local pos = {x = -40, y = 0}
    for name, count in pairs (team1) do
      for x = 1, count do
        local vec = get_position(math.random(400))
        player.surface.create_entity{name = names.units[name], position = {pos.x + vec[1], pos.y + vec[2]}, force = "player"}
      end 
    end



  if player.character then player.character.destroy() end

  team2 = {
    --beetle = 50,
    --plasma_bot = 5,
    --rocket_guy = 20,
    --smg_guy = 50,
    --flame_car = 20,
    --rocket_guy = 20,
    --shell_tank = 80
    --scatter_spitter = 20,
    --piercing_biter = 20,
    --rocket_guy = 30,
    --laser_bot = 20
    --acid_worm = 10
  }
  local pos = {x = 20, y = 0}
  for name, count in pairs (team2) do
    for x = 1, count do
      local vec = get_position(math.random(400))
      player.surface.create_entity{name = names.units[name], position = {pos.x + vec[1], pos.y + vec[2]}, force = "enemy"}
    end 
  end
  player.get_quickbar().insert(names.unit_tools.unit_selection_tool)
  player.get_quickbar().insert(names.unit_tools.deployer_selection_tool)
  --player.surface.create_entity{name = "Tazer Bot", position = {-10, -10}, force = "enemy"}
  --player.surface.create_entity{name = "Tazer Bot", position = {10, -10}, force = "player"}
  player.insert(names.entities.teleporter)
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