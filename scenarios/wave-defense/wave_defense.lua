local util = require "util"
local mod_gui = require "mod-gui"
local map_gen_settings = require "wave_defense_map_gen_settings"
local increment = util.increment
local format_number = util.format_number
local format_time = util.formattime
local insert = table.insert

local game_state =
{
  in_round = 1,
  in_preview = 2,
  defeat = 3,
  victory = 4
}

local script_data =
{
  wave_number = 0,
  spawn_interval = {300, 500},
  force_bounty_modifier = 0.5,
  bounty_bonus = 1,
  skipped_multiplier = 0.1,
  money = 0,
  team_upgrades = {},
  gui_elements =
  {
    preview_frame = {},
    wave_frame_button = {},
    wave_frame = {},
    upgrade_frame_button = {},
    upgrade_frame = {},
    upgrade_table = {},
    admin_frame_button = {},
    admin_frame = {},
  },
  gui_labels =
  {
    money_label = {},
    time_label = {},
    round_label = {}
  },
  gui_actions = {},
  spawners = {},
  state = game_state.in_preview,
  random = nil,
  wave_tick = nil,
  spawn_time = nil,
  wave_time = nil,
}

local max_seed = 2^32 - 2
local initial_seed = 314159265 -- Something nice?

local players = function(index)
  local player_list = game.players
  return index and player_list[index] or player_list
end

function deregister_gui(gui)
  local player_gui_actions = script_data.gui_actions[gui.player_index]
  if not player_gui_actions then return end
  player_gui_actions[gui.index] = nil
  for k, child in pairs (gui.children) do
    deregister_gui(child)
  end
end

function register_gui_action(gui, param)
  local gui_actions = script_data.gui_actions
  local player_gui_actions = gui_actions[gui.player_index]
  if not player_gui_actions then
    gui_actions[gui.player_index] = {}
    player_gui_actions = gui_actions[gui.player_index]
  end
  player_gui_actions[gui.index] = param
end

function init_force(force)

  set_research(force)
  set_recipes(force)
  --force.friendly_fire = false

  for name, upgrade in pairs (get_upgrades()) do
    script_data.team_upgrades[name] = 0
  end

end

function get_walkable_tile()
  for name, tile in pairs (game.tile_prototypes) do
    if tile.collision_mask["player-layer"] == nil and not tile.items_to_place_this then
      return name
    end
  end
  error("No walkable tile in prototype list")
end

function set_tiles_safe(surface, tiles)
  local grass = get_walkable_tile()
  local grass_tiles = {}
  for k, tile in pairs (tiles) do
    grass_tiles[k] = {position = {x = (tile.position.x or tile.position[1]), y = (tile.position.y or tile.position[2])}, name = grass}
  end
  surface.set_tiles(grass_tiles, false)
  surface.set_tiles(tiles)
end

function set_up_players()
  local surface = script_data.surface
  local force = game.forces.player
  local spawn = force.get_spawn_position(surface)
  local find = surface.find_non_colliding_position
  local create = surface.create_entity

  for k, player in pairs (players()) do
    player.teleport(spawn, surface)
    player.character = create{name = "player", position = find("player", spawn, 0, 1), force = force}
    give_starting_equipment(player)
    give_spawn_equipment(player)
    gui_init(player)
  end

end

function start_round()
  local surface = script_data.surface
  surface.daytime = 0
  surface.always_day = false
  script_data.state = game_state.in_round
  local tick = game.tick
  script_data.money = 0
  script_data.wave_number = 0
  script_data.wave_time = surface.ticks_per_day
  script_data.spawn_time = math.floor(surface.ticks_per_day * (surface.morning - surface.evening))
  script_data.wave_tick = tick + math.ceil(surface.ticks_per_day * surface.evening)
  set_up_players()
end

local get_random_seed = function()
  --Some random prime...
  return (32452867 * game.tick) % max_seed
end

function get_map_gen_settings()
  return map_gen_settings
end

local get_map_size = function()
  return script_data.map_size or 160
end

function create_battle_surface(seed)
  local name = "battle_surface"
  for k, surface in pairs (game.surfaces) do
    if surface.name ~= "nauvis" then
      game.delete_surface(surface.name)
    end
    name = name..k
  end
  local settings = get_map_gen_settings()
  settings.seed = seed or get_random_seed()
  local surface = game.create_surface(name, settings)
  local size = surface.get_starting_area_radius()
  script_data.surface = surface
  for k, starting_point in pairs (settings.starting_points) do
    surface.request_to_generate_chunks(starting_point, math.ceil(size / 32))
    surface.force_generate_chunk_requests()
    game.forces.player.chart(surface, {{starting_point.x - size, starting_point.y - size},{starting_point.x + size, starting_point.y + size}})
    create_silo(starting_point)
    create_wall(starting_point)
    create_turrets(starting_point)
  end
  for k, player in pairs (players()) do
    refresh_preview_gui(player)
  end
  script_data.random = game.create_random_generator(settings.seed)
end

function create_silo(starting_point)
  local force = game.forces.player
  local surface = script_data.surface
  local silo_position = {starting_point.x * 1.1, starting_point.y * 1.1}
  --todo offset out of the way from the starting patches a bit
  local silo_name = "rocket-silo"
  if not game.entity_prototypes[silo_name] then log("Silo not created as "..silo_name.." is not a valid entity prototype") return end
  local silo = surface.create_entity{name = silo_name, position = silo_position, force = force, raise_built = true, create_build_effect_smoke = false}

  if not (silo and silo.valid) then return end

  silo.minable = false
  if silo.supports_backer_name() then
    silo.backer_name = ""
  end
  script_data.silo = silo

  local tile_name = "concrete"
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end

  local tiles_2 = {}
  local box = silo.bounding_box
  local x1, x2, y1, y2 =
    math.floor(box.left_top.x) - 1,
    math.floor(box.right_bottom.x) + 1,
    math.floor(box.left_top.y) - 1,
    math.floor(box.right_bottom.y) + 1
  for X = x1, x2 do
    for Y = y1, y2 do
      insert(tiles_2, {name = tile_name, position = {X, Y}})
    end
  end

  for i, entity in pairs(surface.find_entities_filtered({area = {{x1 - 1, y1 - 1},{x2 + 1, y2 + 1}}, force = "neutral"})) do
    entity.destroy()
  end

  set_tiles_safe(surface, tiles_2)
end

local get_base_radius = function()
  return (32 * (math.floor(((script_data.surface.get_starting_area_radius() / 32) - 0) / (2^0.5))))
end

local is_in_map = function(width, height, position)
  return position.x >= -width
    and position.x < width
    and position.y >= -height
    and position.y < height
end

function create_wall(starting_point)
  local force = game.forces.player
  local surface = script_data.surface
  local origin = starting_point or force.get_spawn_position(surface)
  local radius =  get_base_radius() + 5
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local perimeter_top = {}
  local perimeter_bottom = {}
  local perimeter_left = {}
  local perimeter_right = {}
  local tiles = {}
  local insert = insert
  for X = -radius, radius - 1 do
    insert(perimeter_top, {x = origin.x + X, y = origin.y - radius})
    insert(perimeter_bottom, {x = origin.x + X, y = origin.y + (radius-1)})
  end
  for Y = -radius, radius - 1 do
    insert(perimeter_left, {x = origin.x - radius, y = origin.y + Y})
    insert(perimeter_right, {x = origin.x + (radius-1), y = origin.y + Y})
  end
  local tile_name = "refined-concrete"
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  local areas =
  {
    {{perimeter_top[1].x, perimeter_top[1].y - 1}, {perimeter_top[#perimeter_top].x, perimeter_top[1].y + 3}},
    {{perimeter_bottom[1].x, perimeter_bottom[1].y - 3}, {perimeter_bottom[#perimeter_bottom].x, perimeter_bottom[1].y + 1}},
    {{perimeter_left[1].x - 1, perimeter_left[1].y}, {perimeter_left[1].x + 3, perimeter_left[#perimeter_left].y}},
    {{perimeter_right[1].x - 3, perimeter_right[1].y}, {perimeter_right[1].x + 1, perimeter_right[#perimeter_right].y}}
  }
  local find_entities_filtered = surface.find_entities_filtered
  local destroy_param = {do_cliff_correction = true}
  for k, area in pairs (areas) do
    for i, entity in pairs(find_entities_filtered({area = area})) do
      entity.destroy(destroy_param)
    end
  end
  local wall_name = "stone-wall"
  local gate_name = "gate"
  if not game.entity_prototypes[wall_name] then
    log("Setting walls cancelled as "..wall_name.." is not a valid entity prototype")
    return
  end
  if not game.entity_prototypes[gate_name] then
    log("Setting walls cancelled as "..gate_name.." is not a valid entity prototype")
    return
  end
  local should_gate =
  {
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true
  }
  local create_entity = surface.create_entity
  for k, position in pairs (perimeter_left) do
    if is_in_map(width, height, position) then
      if (k ~= 1) and (k ~= #perimeter_left) then
        insert(tiles, {name = tile_name, position = {position.x + 2, position.y}})
        insert(tiles, {name = tile_name, position = {position.x + 1, position.y}})
        insert(tiles, {name = tile_name, position = {position.x, position.y}})
      end
      if should_gate[position.y % 32] then
        create_entity{name = gate_name, position = position, direction = 0, force = force, create_build_effect_smoke = false}
      else
        create_entity{name = wall_name, position = position, force = force, create_build_effect_smoke = false}
      end
    end
  end
  for k, position in pairs (perimeter_right) do
    if is_in_map(width, height, position) then
      if (k ~= 1) and (k ~= #perimeter_right) then
        insert(tiles, {name = tile_name, position = {position.x - 2, position.y}})
        insert(tiles, {name = tile_name, position = {position.x - 1, position.y}})
        insert(tiles, {name = tile_name, position = {position.x, position.y}})
      end
      if should_gate[position.y % 32] then
        create_entity{name = gate_name, position = position, direction = 0, force = force, create_build_effect_smoke = false}
      else
        create_entity{name = wall_name, position = position, force = force, create_build_effect_smoke = false}
      end
    end
  end
  for k, position in pairs (perimeter_top) do
    if is_in_map(width, height, position) then
      if (k ~= 1) and (k ~= #perimeter_top) then
        insert(tiles, {name = tile_name, position = {position.x, position.y + 2}})
        insert(tiles, {name = tile_name, position = {position.x, position.y + 1}})
        insert(tiles, {name = tile_name, position = {position.x, position.y + 0}})
      end
      if should_gate[position.x % 32] then
        create_entity{name = gate_name, position = position, direction = 2, force = force, create_build_effect_smoke = false}
      else
        create_entity{name = wall_name, position = position, force = force, create_build_effect_smoke = false}
      end
    end
  end
  for k, position in pairs (perimeter_bottom) do
    if is_in_map(width, height, position) then
      if (k ~= 1) and (k ~= #perimeter_bottom) then
        insert(tiles, {name = tile_name, position = {position.x, position.y - 2}})
        insert(tiles, {name = tile_name, position = {position.x, position.y - 1}})
        insert(tiles, {name = tile_name, position = {position.x, position.y - 0}})
      end
      if should_gate[position.x % 32] then
        create_entity{name = gate_name, position = position, direction = 2, force = force, create_build_effect_smoke = false}
      else
        create_entity{name = wall_name, position = position, force = force, create_build_effect_smoke = false}
      end
    end
  end
  set_tiles_safe(surface, tiles)
end

function create_turrets(starting_point)
  local force = game.forces.player
  local turret_name = "gun-turret"
  if not game.entity_prototypes[turret_name] then return end
  local surface = script_data.surface
  local ammo_name = "uranium-rounds-magazine"
  local direction = defines.direction
  local surface = script_data.surface
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local origin = starting_point
  local radius = get_base_radius() - 5
  local positions = {}
  local Xo = origin.x
  local Yo = origin.y
  for X = -radius, radius do
    local Xt = X + Xo
    if X == -radius then
      for Y = -radius, radius do
        local Yt = Y + Yo
        if (Yt + 16) % 32 ~= 0 and Yt % 8 == 0 then
          insert(positions, {x = Xo - radius, y = Yt, direction = direction.west})
          insert(positions, {x = Xo + radius, y = Yt, direction = direction.east})
        end
      end
    elseif (Xt + 16) % 32 ~= 0 and Xt % 8 == 0 then
      insert(positions, {x = Xt, y = Yo - radius, direction = direction.north})
      insert(positions, {x = Xt, y = Yo + radius, direction = direction.south})
    end
  end
  local tiles = {}
  local tile_name = "hazard-concrete-left"
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  local stack
  if ammo_name and game.item_prototypes[ammo_name] then
    stack = {name = ammo_name, count = 50}
  end
  local find_entities_filtered = surface.find_entities_filtered
  local neutral = game.forces.neutral
  local destroy_params = {do_cliff_correction = true}
  local floor = math.floor
  local create_entity = surface.create_entity
  local can_place_entity = surface.can_place_entity
  for k, position in pairs (positions) do
    if is_in_map(width, height, position) and can_place_entity{name = turret_name, position = position, force = force, build_check_type = defines.build_check_type.ghost_place, forced = true} then
      local turret = create_entity{name = turret_name, position = position, force = force, direction = position.direction, create_build_effect_smoke = false}
      local box = turret.bounding_box
      for k, entity in pairs (find_entities_filtered{area = turret.bounding_box, force = neutral}) do
        entity.destroy(destroy_params)
      end
      if stack then
        turret.insert(stack)
      end
      for x = floor(box.left_top.x), floor(box.right_bottom.x) do
        for y = floor(box.left_top.y), floor(box.right_bottom.y) do
          insert(tiles, {name = tile_name, position = {x, y}})
        end
      end
    end
  end
  set_tiles_safe(surface, tiles)
end

function check_next_wave(tick)
  if not script_data.wave_tick then return end
  if script_data.wave_tick ~= tick then return end
  game.print({"next-wave"})
  next_wave()
end

function next_wave()
  increment(script_data, "wave_number")
  update_label_list(script_data.gui_labels.round_label, {"current-wave", script_data.wave_number})
  make_next_wave_tick()
  make_next_spawn_tick()
  local exponent = math.min(#game.connected_players, 8)
  script_data.force_bounty_modifier = (0.5 * (1.15 / (1.15 ^ exponent)))
  script_data.wave_power = calculate_wave_power(script_data.wave_number)
  spawn_units()
end

function calculate_wave_power(x)
  local c = 1.65
  local p = math.min(#game.connected_players, 8)
  if x % 4 == 0 then
    return math.floor((1.15 ^ p) * (x ^ c) * 60)
  elseif x % 2 == 0 then
    return math.floor((1.15 ^ p) * (x ^ c) * 50)
  else
    return math.floor((1.15 ^ p) * (x ^ c) * 40)
  end
end

function wave_end()
  game.print({"wave-over"})
  spawn_units()
  script_data.spawn_tick = nil
  script_data.end_spawn_tick = nil
end

function make_next_spawn_tick()
  script_data.spawn_tick = game.tick + script_data.random(script_data.spawn_interval[1], script_data.spawn_interval[2])
end

function check_spawn_units(tick)
  if not script_data.spawn_tick then return end

  if script_data.end_spawn_tick <= tick then
    wave_end()
    return
  end

  if script_data.spawn_tick == tick then
    spawn_units()
    make_next_spawn_tick()
  end

end

function get_wave_units(x)
  local units = {}
  local k = 1
  for unit_name, unit in pairs (unit_config) do
    if unit.in_wave(x) then
      units[k] = {name = unit_name, cost = unit.cost}
      k = k + 1
    end
  end
  return units
end

local get_all_spawn_chunks = function()
  local surface = script_data.surface
  local force = game.forces.player
  local check = force.is_chunk_charted
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local positions = {}
  for chunk in surface.get_chunks() do
    local position = {x = (chunk.x * 32), y = (chunk.y * 32)}
    if is_in_map(width, height, position) and not check(surface, chunk) then
      insert(positions, position)
    end
  end

  if #positions > 0 then
    return positions
  end

  check = force.is_chunk_visible
  for chunk in surface.get_chunks() do
    local position = {x = (chunk.x * 32), y = (chunk.y * 32)}
    if is_in_map(width, height, position) and not check(surface, chunk) then
      insert(positions, position)
    end
  end

  return positions
end

function get_spawn_chunks()
  local spawners = script_data.spawners
  local positions = {}
  for k, spawner in pairs (spawners) do
    if not spawner.valid then
      spawners[k] = nil
    else
      insert(positions, spawner.position)
    end
  end
  return positions
end



function spawn_units()

  local rand = script_data.random
  local surface = script_data.surface
  local silo = script_data.silo
  if not (silo and silo.valid) then return end
  --if surface.count_entities_filtered{type = "unit"} > 1000 then return end
  local command =
  {
    type = defines.command.compound,
    structure_type = defines.compound_command.return_last,
    distraction = defines.distraction.by_enemy,
    commands =
    {
      {
        type = defines.command.go_to_location,
        destination_entity = silo,
        distraction = defines.distraction.by_enemy,
        radius = 20,
        pathfind_flags = path_find_flags
      },
      {
        type = defines.command.attack,
        target = silo,
        distraction = defines.distraction.by_enemy
      },
    }
  }
  local power = 10000 or script_data.wave_power
  local spawns = get_spawn_chunks()
  local spawns_count = #spawns
  if spawns_count == 0 then return end
  local units = get_wave_units(script_data.wave_number)
  local units_length = #units
  local unit_count = 0
  local random = script_data.random
  local random_chunk_position = function(position)
    local x = (position[1] or position.x) + random(-8, 8)
    local y = (position[2] or position.y) + random(-8, 8)
    return {x, y}
  end
  local spawn = spawns[random(spawns_count)]
  while units_length > 0 do
    local k = rand(units_length)
    local biter = units[k]
    local cost = biter.cost

    if unit_count > 20 then
      spawn = spawns[random(spawns_count)]
      unit_count = 0
    end

    if cost > power then
      table.remove(units, k)
      units_length = units_length - 1
    else
      local position = surface.find_non_colliding_position(biter.name, random_chunk_position(spawn), 0, 4)
      local unit = surface.create_entity{name = biter.name, position = position}
      local ai_settings = unit.ai_settings
      ai_settings.allow_try_return_to_spawner = false
      ai_settings.path_resolution_modifier = -3

      unit.set_command(command)
      power = power - cost
      unit_count = unit_count + 1
    end

  end
end

unit_config =
  {
    ["small-biter"] =      {bounty = 20, cost = 10, in_wave = function(x) return (x<=5) end},
    ["small-spitter"] =    {bounty = 30, cost = 20, in_wave = function(x) return ((x>=3) and (x<=8)) end},
    ["medium-biter"] =     {bounty = 120, cost = 80 , in_wave = function(x) return ((x>=5) and (x<=10)) end},
    ["medium-spitter"] =   {bounty = 50, cost = 120, in_wave = function(x) return ((x>=7) and (x<=12)) end},
    ["big-biter"] =        {bounty = 400, cost = 300, in_wave = function(x) return (x>=11) and (x<=19) end},
    ["big-spitter"] =      {bounty = 200, cost = 400, in_wave = function(x) return (x>=13) and (x<=21) end},
    ["behemoth-biter"] =   {bounty = 1200, cost = 800, in_wave = function(x) return (x>=15) end},
    ["behemoth-spitter"] = {bounty = 500, cost = 650, in_wave = function(x) return (x>=17) end}
  }

function make_next_wave_tick()
  script_data.end_spawn_tick = game.tick + script_data.spawn_time
  script_data.wave_tick  = game.tick + script_data.wave_time
end

function time_to_next_wave()
  if not script_data.wave_tick then return end
  return format_time(script_data.wave_tick - game.tick)
end

function time_to_wave_end()
  if not script_data.end_spawn_tick then return end
  return format_time(script_data.end_spawn_tick - game.tick)
end

function rocket_died(event)
  if not (script_data.silo and script_data.silo.valid) then return end
  local silo = event.entity
  if not silo == script_data.silo then
    return
  end
  script_data.state = game_state.defeat
  script_data.silo = nil
  for k, player in pairs (players()) do
    player.set_controller({type = defines.controllers.spectator})
    player.teleport(silo.position)
  end
  game.print("GAME OVER, tell admin to start a new round or soemthing.")

end

local color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2}
function unit_died(event)
  local force = event.force
  if not force then return end
  if not force.valid then return end
  local died = event.entity
  local surface = died.surface
  local cash = math.floor(get_bounty_price(died.name) * script_data.force_bounty_modifier * script_data.bounty_bonus)
  increment(script_data, "money", cash)
  surface.create_entity{name = "flying-text", position = died.position, text = "+"..cash, color = color}
  update_label_list(script_data.gui_labels.money_label, get_money())
end

function get_bounty_price(name)
  if not unit_config[name] then game.print(name.." not in config") return 0 end
  if not unit_config[name].bounty then game.print(name.." not in bounty list") return 0 end
  return unit_config[name].bounty
end

function setup_waypoints()
  local surface = game.surfaces[1]
  local w = surface.map_gen_settings.width
  local threshold = -((5*w)/8)
  local spawns = {}
  local waypoints = {}
  for k, entity in pairs (surface.find_entities_filtered{name = "big-worm-turret"}) do
    local position = entity.position
    local X = position.x
    local Y = position.y
    local I = Y-X
    if I > threshold then
      table.insert(waypoints, position)
    else
      table.insert(spawns, position)
    end
    entity.destroy()
  end
  script_data.waypoints = waypoints
  script_data.spawns = spawns
end

function insert_items(entity, array)
  for name, count in pairs (array) do
    entity.insert({name = name, count = count})
  end
end

function give_starting_equipment(player)
  local items =
  {
    ["iron-plate"] = 200,
    ["pipe"] = 200,
    ["pipe-to-ground"] = 50,
    ["copper-plate"] = 200,
    ["steel-plate"] = 200,
    ["iron-gear-wheel"] = 250,
    ["transport-belt"] = 600,
    ["underground-belt"] = 40,
    ["splitter"] = 40,
    ["gun-turret"] = 8,
    ["stone-wall"] = 50,
    ["repair-pack"] = 20,
    ["inserter"] = 100,
    ["burner-inserter"] = 50,
    ["small-electric-pole"] = 50,
    ["medium-electric-pole"] = 50,
    ["big-electric-pole"] = 15,
    ["burner-mining-drill"] = 50,
    ["electric-mining-drill"] = 50,
    ["stone-furnace"] = 35,
    ["steel-furnace"] = 20,
    ["electric-furnace"] = 8,
    ["assembling-machine-1"] = 50,
    ["assembling-machine-2"] = 20,
    ["assembling-machine-3"] = 8,
    ["electronic-circuit"] = 200,
    ["fast-inserter"] = 100,
    ["long-handed-inserter"] = 100,
    ["substation"] = 10,
    ["boiler"] = 10,
    ["offshore-pump"] = 1,
    ["steam-engine"] = 20,
    ["chemical-plant"] = 20,
    ["oil-refinery"] = 5,
    ["pumpjack"] = 10,
    ["small-lamp"] = 20
  }
  insert_items(player, items)
end

function give_spawn_equipment(player)
  local items =
    {
      ["submachine-gun"] = 1,
      ["firearm-magazine"] = 40,
      ["shotgun"] = 1,
      ["shotgun-shell"] = 20,
      ["power-armor"] = 1,
      ["construction-robot"] = 20,
      ["blueprint"] = 3,
      ["deconstruction-planner"] = 1
    }
  insert_items(player, items)
  local equipment =
    {
      "fusion-reactor-equipment",
      "exoskeleton-equipment",
      "personal-roboport-equipment",
      "personal-roboport-equipment"
    }
  local armor = player.get_inventory(5)[1].grid
  for k, name in pairs (equipment) do
    armor.put({name = name})
  end
  for k, equipment in pairs (armor.equipment) do
    equipment.energy = equipment.max_energy
  end
end

function refresh_preview_gui(player)

  local frame = script_data.gui_elements.preview_frame[player.index]
  if not (frame and frame.valid) then return end
  deregister_gui(frame)
  frame.clear()

  local inner = frame.add{type = "frame", style = "inside_deep_frame", direction = "vertical"}
  local subheader = inner.add{type = "frame", style = "subheader_frame"}
  subheader.style.horizontally_stretchable = true
  subheader.style.horizontal_align = "right"
  subheader.style.bottom_padding = 1
  local pusher = subheader.add{type = "flow"}
  pusher.style.horizontally_stretchable = true
  local seed_flow = subheader.add{type = "flow", direction = "horizontal", style = "player_input_horizontal_flow"}
  seed_flow.add{type = "label", style = "caption_label", caption = "Seed"}
  local seed_input = seed_flow.add{type = "textfield", text = "", style = "long_number_textfield"}
  register_gui_action(seed_input, {type = "check_seed_input"})
  local shuffle_button = seed_flow.add{type = "sprite-button", sprite = "utility/shuffle", style = "tool_button"}
  register_gui_action(shuffle_button, {type = "shuffle_button"})
  local refresh_button = seed_flow.add{type = "sprite-button", sprite = "utility/refresh", style = "tool_button"}
  register_gui_action(refresh_button, {type = "refresh_button", textfield = seed_input})
  local max = math.min(player.display_resolution.width, player.display_resolution.height) * 0.6

  local surface = script_data.surface
  seed_input.text = surface.map_gen_settings.seed
  local size = surface.get_starting_area_radius()
  local position = player.force.get_spawn_position(surface)
  local minimap = inner.add
  {
    type = "minimap",
    surface_index = surface.index,
    zoom = max / (size * 2),
    force = player.force.name,
    position = position
  }
  minimap.style.width = max
  minimap.style.height = max

  --minimap.style.vertically_stretchable = true
  --minimap.style.horizontally_stretchable = true

  local button_flow = frame.add{type = "flow"}
  button_flow.style.horizontal_align = "right"
  button_flow.style.horizontally_stretchable = true
  local start_round = button_flow.add{type = "button", caption = "Looks good, lets go!", style = "confirm_button"}
  register_gui_action(start_round, {type = "start_round"})
end

function make_preview_gui(player)
  local gui = player.gui.center
  local frame = script_data.gui_elements.preview_frame[player.index]
  if frame and frame.valid then
    return refresh_preview_gui(player)
  end
  frame = gui.add{type = "frame", caption = "Start round or something", direction = "vertical"}
  frame.style.horizontal_align = "right"
  script_data.gui_elements.preview_frame[player.index] = frame
  refresh_preview_gui(player)
end

local wave_button_param =
{
  type = "sprite-button",
  style = mod_gui.button_style,
  sprite = "entity/behemoth-spitter",
  tooltip = {"visibility-button-tooltip"}
}

local upgrade_button_param =
{
  type = "button",
  caption = {"upgrade-button"},
  tooltip = {"upgrade-button-tooltip"},
  style = mod_gui.button_style
}

local admin_button_param =
{
  type = "button",
  caption = "ADMIN",
  tooltip = {"upgrade-button-tooltip"},
  style = mod_gui.button_style
}

local add_gui_buttons= function(player)
  local button_flow = mod_gui.get_button_flow(player)

  local wave_button = script_data.gui_elements.wave_frame_button[player.index]
  if not wave_button then
    wave_button = button_flow.add(wave_button_param)
    script_data.gui_elements.wave_frame_button[player.index] = wave_button
    register_gui_action(wave_button, {type = "wave_frame_button"})
  end

  local upgrade_button = script_data.gui_elements.upgrade_frame_button[player.index]
  if not upgrade_button then
    upgrade_button = button_flow.add(upgrade_button_param)
    script_data.gui_elements.upgrade_frame_button[player.index] = upgrade_button
    register_gui_action(upgrade_button, {type = "upgrade_button"})
  end

  if player.admin then
    local admin_button = button_flow.add(admin_button_param)
    script_data.gui_elements.admin_frame_button[player.index] = admin_button
    register_gui_action(admin_button, {type = "admin_button"})
  end
end

local delete_game_gui = function(player)
  local index = player.index
  for k, gui_list in pairs(script_data.gui_elements) do
    local element = gui_list[index]
    if (element and element.valid) then
      deregister_gui(element)
      element.destroy()
    end
    gui_list[index] = nil
  end
end

function gui_init(player)

  delete_game_gui(player)

  if script_data.state == game_state.in_preview then
    make_preview_gui(player)
    return
  end

  if script_data.state == game_state.in_round then
    add_gui_buttons(player)
    toggle_wave_frame(player)
    return
  end

end

local cash_font_color = {r = 0.8, b = 0.5, g = 0.8}
local wave_frame =
{
  type = "frame",
  caption = {"wave-frame"},
  direction = "vertical"
}

function toggle_wave_frame(player)

  local frame = script_data.gui_elements.wave_frame[player.index]

  if (frame and frame.valid) then
    deregister_gui(frame)
    script_data.gui_elements.wave_frame[player.index] = nil
    frame.destroy()
    return
  end

  frame = mod_gui.get_frame_flow(player).add(wave_frame)
  script_data.gui_elements.wave_frame[player.index] = frame

  frame.style.vertically_stretchable = false

  local round = frame.add{type = "label", caption = {"current-wave", script_data.wave_number}}
  insert(script_data.gui_labels.round_label, round)

  local time = frame.add{type = "label", caption = {"time-to-next-wave", time_to_next_wave()}}
  insert(script_data.gui_labels.time_label, time)

  local money_table = frame.add{type = "table", column_count = 2}
  money_table.add{type = "label", name = "force_money_label", caption = {"force-money"}}
  local cash = money_table.add{type = "label", caption = get_money()}
  insert(script_data.gui_labels.money_label, cash)
  cash.style.font_color = cash_font_color
end


local upgrade_frame = {type = "frame", caption = {"buy-upgrades"}, direction = "vertical"}
function toggle_upgrade_frame(player)

  local frame = script_data.gui_elements.upgrade_frame[player.index]
  if frame and frame.valid then
    frame.destroy()
    script_data.gui_elements.upgrade_frame[player.index] = nil
    return
  end

  frame = mod_gui.get_frame_flow(player).add(upgrade_frame)
  script_data.gui_elements.upgrade_frame[player.index] = frame

  frame.visible = true
  local money_table = frame.add{type = "table", name = "money_table", column_count = 2}
  money_table.style.column_alignments[2] = "right"
  local label = money_table.add{type = "label", caption = {"force-money"}}
  label.style.font = "default-semibold"
  local cash = money_table.add{type = "label", caption = get_money()}
  insert(script_data.gui_labels.money_label, cash)
  cash.style.font_color = {r = 0.8, b = 0.5, g = 0.8}
  local scroll = frame.add{type = "scroll-pane"}
  scroll.style.maximal_height = 450
  local upgrade_table = scroll.add{type = "table", column_count = 2}
  upgrade_table.style.horizontal_spacing = 0
  upgrade_table.style.vertical_spacing = 0
  script_data.gui_elements.upgrade_table[player.index] = upgrade_table
  update_upgrade_listing(player)
end

function update_upgrade_listing(player)
  local gui = script_data.gui_elements.upgrade_table[player.index]
  if not (gui and gui.valid) then return end
  local upgrades = script_data.team_upgrades
  local array = get_upgrades()
  gui.clear()
  for name, upgrade in pairs (array) do
    local level = upgrades[name]
    local sprite = gui.add{type = "sprite-button", name = name, sprite = upgrade.sprite, tooltip = {"purchase"}, style = "play_tutorial_button"}
    sprite.style.minimal_height = 75
    sprite.style.minimal_width = 75
    sprite.number = upgrade.price(level)
    register_gui_action(sprite, {type = "purchase_button", name = name})
    local flow = gui.add{type = "frame", name = name.."_flow", direction = "vertical"}
    flow.style.maximal_height = 75
    local another_table = flow.add{type = "table", name = name.."_label_table", column_count = 1}
    another_table.style.vertical_spacing = 2
    local label = another_table.add{type = "label", name = name.."_name", caption = {"", upgrade.caption, " "..upgrade.modifier}}
    label.style.font = "default-bold"
    local level = another_table.add{type = "label", name = name.."_level", caption = {"upgrade-level", level}}
  end
end

upgrade_research =
{
  ["physical-projectile-damage"] = 2000,
  ["stronger-explosives"] = 2000,
  ["refined-flammables"] = 2000,
  ["energy-weapons-damage"] = 2000,
  ["weapon-shooting-speed"] = 2000,
  ["laser-turret-speed"] = 2000,
  ["follower-robot-count"] = 500,
  ["mining-productivity"] = 750
}

function get_upgrades()
  local list = {}
  local tech = game.forces["player"].technologies
  for name, price in pairs (upgrade_research) do
    local append = name.."-1"
    if tech[append] then
      local base = tech[append]
      local upgrade = {}
      local mod = base.effects[1].modifier
      upgrade.modifier = "+"..tostring(mod * 100).."%"
      upgrade.price = function(x) return math.floor((1 + x)) * price end
      upgrade.sprite = "technology/"..append
      upgrade.caption = {"technology-name."..name}
      upgrade.effect = {}
      for k, effect in pairs (base.effects) do
        local type = effect.type
        if type == "ammo-damage" then
          local cat = effect.ammo_category
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_ammo_damage_modifier(cat, force.get_ammo_damage_modifier(cat)+mod)
            increment(script_data.team_upgrades, name)
            return true
          end
        elseif type == "turret-attack" then
          local id = effect.turret_id
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_turret_attack_modifier(id, force.get_turret_attack_modifier(id)+mod)
            increment(script_data.team_upgrades, name)
            return true
          end
        elseif type == "gun-speed" then
          local cat = effect.ammo_category
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_gun_speed_modifier(cat, force.get_gun_speed_modifier(cat)+mod)
            increment(script_data.team_upgrades, name)
            return true
          end
        elseif type == "maximum-following-robots-count" then
          upgrade.modifier = "+"..tostring(mod)
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            increment(force, "maximum_following_robot_count", mod)
            increment(script_data.team_upgrades, name)
            return true
          end
        elseif type == "mining-drill-productivity-bonus" then
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            increment(force, "mining_drill_productivity_bonus", mod)
            increment(script_data.team_upgrades, name)
            return true
          end
        else error(name.." - This tech has no relevant upgrade effect") end
      end
      list[name] = upgrade
    else
      error(name.." is not a valid technology.")
    end
  end
  local bonus = {}
  bonus.modifier = "+10%"
  bonus.sprite = "technology/energy-shield-equipment"
  bonus.price = function(x) return math.floor((1 + x)) * 2500 end
  bonus.effect = {}
  bonus.effect[1] =  function (event)
    increment(script_data, "bounty_bonus", 0.1)
    increment(script_data.team_upgrades, "bounty_bonus")
    return true
  end
  bonus.caption = {"bounty-bonus"}
  list["bounty_bonus"] = bonus
  return list
end

function get_money()
  return format_number(script_data.money)
end

function update_label_list(list, caption)
  for k, label in pairs (list) do
    if label.valid then
      label.caption = caption
    else
      list[k] = nil
    end
  end
end

function update_connected_players(tick)

  if tick and tick % 60 ~= 0 then return end

  local time_left
  if script_data.spawn_tick then
    time_left = time_to_wave_end()
  elseif script_data.wave_tick then
    time_left = time_to_next_wave()
  else
    time_left = "Somethings gone wrong here... ?"
  end

  local caption
  if script_data.spawn_tick then
    caption = {"time-to-wave-end", time_left}
  elseif script_data.wave_tick then
    caption = {"time-to-next-wave", time_left}
  end

  update_label_list(script_data.gui_labels.time_label, caption)
end

local admin_frame_param =
{
  type = "frame",
  caption = "Admin stuff",
  direction = "vertical"
}

local admin_buttons =
{
  {
    param = {type = "button", caption = "End round"},
    action = {type = "end_round"}
  },
  {
    param = {type = "button", caption = "Send wave"},
    action = {type = "send_wave"}
  },

}

local toggle_admin_frame = function(player)
  if not (player and player.valid) then return end
  local frame = script_data.gui_elements.admin_frame[player.index]
  if (frame and frame.valid) then
    deregister_gui(frame)
    frame.destroy()
    script_data.gui_elements.admin_frame[player.index] = nil
    return
  end
  local gui = mod_gui.get_frame_flow(player)
  frame = gui.add(admin_frame_param)
  script_data.gui_elements.admin_frame[player.index] = frame
  for k, button in pairs (admin_buttons) do
    local butt = frame.add(button.param)
    register_gui_action(butt, button.action)
  end

end

function set_research(force)
  force.research_all_technologies()
  local tech = force.technologies
  for name in pairs (upgrade_research) do
    for i = 1, 20 do
      local full_name = name.."-"..i
      if tech[full_name] then
        tech[full_name].researched = false
      end
    end
  end
  force.reset_technology_effects()
  force.disable_research()
end

function set_recipes(force)
  local recipes = force.recipes
  local disable =
  {
    "automation-science-pack",
    "logistic-science-pack",
    "chemical-science-pack",
    "military-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "lab"
  }

  for k, name in pairs (disable) do
    if recipes[name] then
      recipes[name].enabled = false
    else
      error(name.." is not a valid recipe")
    end
  end
end

local on_player_created = function(event)
  local player = players(event.player_index)
  if player.character then
    player.character.destroy()
  end
end

local init_map_settings = function()
  local settings = game.map_settings
  settings.pollution.enabled = false
  settings.enemy_expansion.enabled = false
  settings.path_finder.use_path_cache = false
  settings.path_finder.max_steps_worked_per_tick = 300
  settings.path_finder.max_clients_to_accept_any_new_request = 1000

  settings.steering.moving.force_unit_fuzzy_goto_behavior = true
  settings.steering.moving.radius = 8
  settings.steering.moving.separation_force = 0.01
  settings.steering.moving.separation_factor = 8
  
  settings.steering.default.force_unit_fuzzy_goto_behavior = true
  settings.steering.default.radius = 4
  settings.steering.default.separation_force = 0.02
  settings.steering.default.separation_factor  = 1
  settings.path_finder.max_steps_worked_per_tick = 10000
end

local on_init = function()
  init_map_settings()
  init_force(game.forces.player)

end

local on_entity_died = function(event)
  local entity_type = event.entity.type
  if entity_type == "unit" then
    return unit_died(event)
  end
  if entity_type == "rocket-silo" then
    return rocket_died(event)
  end
end

local on_rocket_launched = function(event)
  local rocket = event.rocket
  game.print("WOOP DE DOO YOU WIN")
end

local on_player_joined_game = function(event)
  local player = players(event.player_index)
  if not (script_data.surface and script_data.surface.valid) then
    create_battle_surface(initial_seed)
  end
  gui_init(player)
end

local on_player_respawned = function(event)
  local player = players(event.player_index)
  give_spawn_equipment(player)
end

local is_reasonable_seed = function(string)
  local number = tonumber(string)
  if not number then return end
  if number < 0 or number > max_seed then
    return
  end
  return true
end

local end_round = function(player)
  script_data.state = game_state.in_preview
  script_data.wave_tick = nil
  script_data.spawn_tick = nil
  local seed = script_data.surface.map_gen_settings.seed
  game.delete_surface(script_data.surface)
  create_battle_surface(script_data.surface.map_gen_settings.seed)
  for k, player in pairs (players()) do
    if player.character then player.character.destroy() end
    player.teleport({0,0}, game.surfaces[1])
    gui_init(player)
  end
end

local gui_functions =
{
  send_next_wave = function(event)
    local element = event.element
    if not (element and element.valid and element.enabled) then return end
    if script_data.end_spawn_tick then return end
    local player = players(event.player_index)
    local skipped = math.floor(script_data.skipped_multiplier * (script_data.wave_tick - event.tick) * (1.15 ^ script_data.wave_number))
    increment(script_data, "money", skipped)
    update_label_list(script_data.gui_labels.money_label, get_money())
    next_wave()
    if player.name == "" then
      game.print({"next-wave"})
    else
      game.print({"sent-next-wave", player.name})
    end
    update_connected_players()
  end,
  upgrade_button = function(event)
    toggle_upgrade_frame(players(event.player_index))
  end,
  wave_frame_button = function(event)
    toggle_wave_frame(players(event.player_index))
  end,
  admin_button = function(event)
    toggle_admin_frame(players(event.player_index))
  end,
  purchase_button = function(event, param)
    local name = param.name
    local list = get_upgrades()
    local upgrades = script_data.team_upgrades
    local player = players(event.player_index)
    local price = list[name].price(upgrades[name])
    if script_data.money >= price then
      increment(script_data, "money", -price)
      local sucess = false
      for k, effect in pairs (list[name].effect) do
        sucess = effect(event)
      end
      if sucess and game.is_multiplayer() then
        game.print({"purchased-team-upgrade", player.name, list[name].caption,upgrades[name]})
      end
      update_connected_players()
      for k, player in pairs (game.connected_players) do
        update_upgrade_listing(player)
      end
      update_label_list(script_data.gui_labels.money_label, get_money())
    else
      player.print({"not-enough-money"})
    end
  end,
  shuffle_button = function(event, param)
    create_battle_surface()
  end,
  refresh_button = function(event, param)
    local input = param.textfield
    if not (input and input.valid) then return end
    local seed = input.text
    if is_reasonable_seed(seed) then
      create_battle_surface(tonumber(seed))
    end
  end,
  check_seed_input = function(event, param)
    local gui = event.element
    if not (gui and gui.valid) then return end
    if is_reasonable_seed(gui.text) then
      gui.style = "long_number_textfield"
    else
      gui.style = "invalid_value_textfield"
    end
  end,
  start_round = function(event, param)
    start_round()
  end,
  send_wave = function(event, param)
    spawn_units()
  end,
  end_round = function(event, param)
    end_round()
  end
}

function generic_gui_event(event)
  local gui = event.element
  if not (gui and gui.valid) then return end

  local player_gui_actions = script_data.gui_actions[gui.player_index]
  if not player_gui_actions then return end

  local action = player_gui_actions[gui.index]
  if not action then return end

  gui_functions[action.type](event, action)
  return true
end

local on_gui_click = function(event)
  if generic_gui_event(event) then return end
end

local on_tick = function(event)
  local tick = event.tick
  check_next_wave(tick)
  check_spawn_units(tick)
  update_connected_players(tick)
  --local print = {tick = game.tick, seed = get_random_seed()}
  --log(serpent.block(print))
end

local oh_no_you_dont = {game_finished = false}
local on_player_died = function(event)
  if game.is_multiplayer() then return end
  local player = players(event.player_index)
  if not player then return end
  game.set_game_state(oh_no_you_dont)
end

local on_chunk_generated = function(event)
  local area = event.area
  local surface = event.surface
  if not (surface and surface.valid and surface == script_data.surface) then return end
  for k, spawner in pairs (surface.find_entities_filtered{area = area, type = "unit-spawner"}) do
    script_data.spawners[spawner.unit_number] = spawner
  end
end

local events =
{
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_player_respawned] = on_player_respawned,
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_rocket_launched] = on_rocket_launched,
  [defines.events.on_gui_text_changed] = generic_gui_event,
  [defines.events.on_gui_click] = generic_gui_event,
  [defines.events.on_player_died] = on_player_died,
  [defines.events.on_chunk_generated] = on_chunk_generated,
  [defines.events.on_gui_closed] = on_gui_closed
}

local lib = {}

lib.on_event = function(event)
  local action = events[event.name]
  if not action then return end
  return action(event)
end

lib.on_load = function()
  script_data = global.wave_defense or script_data
end

lib.on_init = function()
  global.wave_defense = global.wave_defense or script_data
  on_init()
end

return lib
