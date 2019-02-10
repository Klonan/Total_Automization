local util = require "util"
local mod_gui = require "mod-gui"
local config = require "wave_defense_config"
local increment = util.increment
local format_number = util.format_number
local format_time = util.formattime
local insert = table.insert
local floor = math.floor
local ceil = math.ceil

local game_state =
{
  in_round = 1,
  in_preview = 2,
  defeat = 3,
  victory = 4
}

local script_data =
{
  config = config,
  difficulty = config.difficulties.normal,
  wave_number = 0,
  spawn_interval = {300, 500},
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


local get_starting_point = function()
  return {x = 0, y = 0}
end

local set_daytime_settings = function()
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  local settings = script_data.difficulty.day_settings
  for name, value in pairs (settings) do
    surface[name] = value
  end
end

local max_seed = 2^32 - 2
local initial_seed = 1383170748 -- Something nice?

local players = function(index)
  return (index and game.get_player(index)) or game.players
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

local set_up_player = function(player)
  if not player.connected then return end
  gui_init(player)

  if player.ticks_to_respawn then player.ticks_to_respawn = nil end

  if script_data.state == game_state.in_preview then
    if player.character then
      player.character.destroy()
    end
    player.spectator = true
    player.teleport({0,0}, game.surfaces.nauvis)
    return
  end

  if script_data.state == game_state.in_round or script_data.state == game_state.victory then
    local surface = script_data.surface
    if player.surface == surface then return end
    if player.character then
      player.character.destroy()
    end
    local force = game.forces.player
    local spawn = force.get_spawn_position(surface)
    player.teleport(spawn, surface)
    player.character = surface.create_entity{name = "player", position = surface.find_non_colliding_position("player", spawn, 0, 1), force = force}
    give_respawn_equipment(player)
    return
  end

  if script_data.state == game_state.defeat then
    if player.character then
      player.character.destroy()
    end
    local surface = script_data.surface
    local force = game.forces.player
    local position = script_data.silo and script_data.silo.valid and script_data.silo.position or force.get_spawn_position(surface)
    player.set_controller({type = defines.controllers.spectator})
    player.teleport(position, surface)
    return
  end

end

function set_up_players()
  for k, player in pairs (players()) do
    set_up_player(player)
  end
end

function start_round()
  local surface = script_data.surface
  surface.daytime = surface.dawn
  surface.always_day = false
  script_data.state = game_state.in_round
  local tick = game.tick
  script_data.money = 0
  script_data.wave_number = 0
  --How often waves are sent
  script_data.wave_time = surface.ticks_per_day
  --How long waves last
  script_data.spawn_time = floor(surface.ticks_per_day * (surface.morning - surface.evening))
  --First spawn
  script_data.wave_tick = tick + ceil(surface.ticks_per_day * surface.evening) + ceil((1 - surface.dawn) * surface.ticks_per_day)
  set_up_players()
  game.print({"start-round-message"})
end

function restart_round()
  script_data.game_state = game_state.in_preview
  set_up_players()
  local seed = script_data.surface.map_gen_settings.seed
  create_battle_surface(seed)
  start_round()
end

local get_random_seed = function()
  return (32452867 * game.tick) % max_seed
end

local get_starting_area_radius = function()
  return script_data.difficulty.starting_area_size
end

function create_battle_surface(seed)
  local index = 1
  local name = "Surface "
  while game.surfaces[name..index] do
    index = index + 1
  end
  name = name..index
  for k, surface in pairs (game.surfaces) do
    if surface.name ~= "nauvis" then
      game.delete_surface(surface.name)
    end
  end

  local settings = script_data.config.map_gen_settings
  local seed = seed or get_random_seed()
  script_data.random = game.create_random_generator(seed)
  settings.seed = seed
  settings.starting_area = get_starting_area_radius()
  local starting_point = get_starting_point()
  settings.starting_points = {starting_point}
  local surface = game.create_surface(name, settings)
  local size = surface.get_starting_area_radius()
  script_data.surface = surface
  set_daytime_settings()
  surface.request_to_generate_chunks(starting_point, ceil(size / 32))
  surface.force_generate_chunk_requests()
  game.forces.player.chart(surface, {{starting_point.x - size, starting_point.y - size},{starting_point.x + size, starting_point.y + size}})
  create_silo(starting_point)
  create_wall(starting_point)
  create_turrets(starting_point)
  create_starting_chest(starting_point)
  for k, player in pairs (players()) do
    refresh_preview_gui(player)
  end
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
  rendering.draw_light
  {
    sprite = "utility/light_medium",
    target = silo,
    surface = silo.surface,
    scale = 4
  }
  silo.minable = false
  if silo.supports_backer_name() then
    silo.backer_name = ""
  end
  script_data.silo = silo
  --force.set_spawn_position(silo.position, surface)

  local tile_name = "concrete"
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end

  local tiles_2 = {}
  local box = silo.bounding_box
  local x1, x2, y1, y2 =
    floor(box.left_top.x) - 1,
    floor(box.right_bottom.x) + 1,
    floor(box.left_top.y) - 1,
    floor(box.right_bottom.y) + 1
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
  return (32 * (floor(((script_data.surface.get_starting_area_radius() / 32) - 1) / (2^0.5))))
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
  local ammo_name = "firearm-magazine"
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
  local direction_offset =
  {
    [direction.north] = {0, -13},
    [direction.east] = {13, 0},
    [direction.south] = {0, 13},
    [direction.west] = {-13, 0},
  }
  local find_entities_filtered = surface.find_entities_filtered
  local neutral = game.forces.neutral
  local destroy_params = {do_cliff_correction = true}
  local floor = floor
  local create_entity = surface.create_entity
  local can_place_entity = surface.can_place_entity
  for k, position in pairs (positions) do
    if is_in_map(width, height, position) and can_place_entity{name = turret_name, position = position, force = force, build_check_type = defines.build_check_type.ghost_place, forced = true} then
      local turret = create_entity{name = turret_name, position = position, force = force, direction = position.direction, create_build_effect_smoke = false}
      poop = --rendering.draw_light
      {
        sprite = "utility/light_cone",
        target = turret,
        surface = turret.surface,
        scale = 4,
        orientation = turret.orientation,
        target_offset = direction_offset[position.direction],
        minimum_darkness = 0.3
      }
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

local root_2 = 2 ^ 0.5

function get_chest_offset(n)
  local offset_x = 0
  n = n / 2
  if n % 1 == 0.5 then
    offset_x = -1
    n = n + 0.5
  end
  local root = n ^ 0.5
  local nearest_root = math.floor(root + 0.5)
  local upper_root = math.ceil(root)
  local root_difference = math.abs(nearest_root ^ 2 - n)
  if nearest_root == upper_root then
    x = upper_root - root_difference
    y = nearest_root
  else
    x = upper_root
    y = root_difference
  end
  local orientation = 2 * math.pi * (45/360)
  x = x * root_2
  y = y * root_2
  local rotated_x = math.floor(0.5 + x * math.cos(orientation) - y * math.sin(orientation))
  local rotated_y = math.floor(0.5 + x * math.sin(orientation) + y * math.cos(orientation))
  return {x = rotated_x + offset_x, y = rotated_y}
end

function create_starting_chest(starting_point)
  local force = game.forces.player
  local inventory = script_data.difficulty.starting_chest_items
  if not (table_size(inventory) > 0) then return end
  local surface = script_data.surface
  local chest_name = "iron-chest"
  local prototype = game.entity_prototypes[chest_name]
  if not prototype then
    log("Starting chest "..chest_name.." is not a valid entity prototype, picking a new container from prototype list")
    for name, chest in pairs (game.entity_prototypes) do
      if chest.type == "container" then
        chest_name = name
        prototype = chest
        break
      end
    end
  end
  local size = math.ceil(prototype.radius * 2)
  local origin = {x = starting_point.x, y = starting_point.y - 10}
  local index = 1
  local position = {x = origin.x + get_chest_offset(index).x * size, y = origin.y + get_chest_offset(index).y * size}
  local chest = surface.create_entity{name = chest_name, position = position, force = force, create_build_effect_smoke = false}
  for k, v in pairs (surface.find_entities_filtered{force = "neutral", area = chest.bounding_box}) do
    v.destroy()
  end
  local tiles = {}
  local grass = {}
  local tile_name = "refined-concrete"
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  insert(tiles, {name = tile_name, position = {x = position.x, y = position.y}})
  chest.destructible = false
  local items = game.item_prototypes
  for name, count in pairs (inventory) do
    if items[name] then
      local count_to_insert = math.ceil(count)
      local difference = count_to_insert - chest.insert{name = name, count = count_to_insert}
      while difference > 0 do
        index = index + 1
        position = {x = origin.x + get_chest_offset(index).x * size, y = origin.y + get_chest_offset(index).y * size}
        chest = surface.create_entity{name = chest_name, position = position, force = force, create_build_effect_smoke = false}
        for k, v in pairs (surface.find_entities_filtered{force = "neutral", area = chest.bounding_box}) do
          v.destroy()
        end
        insert(tiles, {name = tile_name, position = {x = position.x, y = position.y}})
        chest.destructible = false
        difference = difference - chest.insert{name = name, count = difference}
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
  spawn_units()
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

local get_wave_power = function()
  return script_data.difficulty.wave_power_function(script_data.wave_number)
end

function get_wave_units()
  local wave = script_data.wave_number
  local units = {}
  for name, first_wave in pairs (script_data.difficulty.unit_first_waves) do
    if wave >= first_wave then
      insert(units, {name = name, amount = floor(((wave - first_wave) + 1) ^ 1.25)})
    end
  end
  return units
end

local get_speed_multiplier = function()
  local level = script_data.wave_number
  if level == 0 then return 0.8 end
  return script_data.difficulty.speed_multiplier_function(level)
end

function spawn_units()
  local rand = script_data.random
  local surface = script_data.surface
  local silo = script_data.silo
  if not (silo and silo.valid) then return end
  local command =
  {
    type = defines.command.compound,
    structure_type = defines.compound_command.return_last,
    distraction = defines.distraction.by_anything,
    commands =
    {
      {
        type = defines.command.go_to_location,
        destination_entity = silo,
        distraction = defines.distraction.by_anything,
        radius = 20,
        pathfind_flags = path_find_flags
      },
      {
        type = defines.command.attack,
        target = silo,
        distraction = defines.distraction.by_anything
      },
    }
  }
  local power = get_wave_power()
  local spawns = get_spawn_chunks()
  local spawns_count = #spawns
  if spawns_count == 0 then return end
  local units = get_wave_units()
  local units_length = #units
  local unit_count = 0
  local random = script_data.random
  local random_chunk_position = function(spawns)
    local position = spawns[random(#spawns)]
    local x = (position[1] or position.x) + random(-8, 8)
    local y = (position[2] or position.y) + random(-8, 8)
    return {x, y}
  end
  local some_spawns = {}
  for k = 1, floor((1 + script_data.wave_number) ^ 0.5) do
    insert(some_spawns, spawns[random(spawns_count)])
  end
  local prices = script_data.difficulty.bounties
  while units_length > 0 do
    local k = rand(units_length)
    local unit = units[k]
    local cost = prices[unit.name]
    for j = 1, unit.amount do
      if cost > power then
        table.remove(units, k)
        units_length = units_length - 1
        break
      else
        local position = surface.find_non_colliding_position(unit.name, random_chunk_position(some_spawns), 16, 1.5)
        if not position then return end
        local entity = surface.create_entity{name = unit.name, position = position}
        --rendering.draw_light
        --{
        --  sprite = "utility/light_small",
        --  target = unit,
        --  surface = unit.surface,
        --  scale = 1,
        --  intensity = 0.5,
        --  color = {g = 1}
        --}
        local ai_settings = entity.ai_settings
        ai_settings.allow_try_return_to_spawner = false
        ai_settings.path_resolution_modifier = -2

        entity.set_command(command)
        entity.speed = entity.speed * get_speed_multiplier()
        power = power - cost
        unit_count = unit_count + 1
      end
    end

  end
end

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
  set_up_players()
  game.print({"you-lose"})

end

local insert_items = util.insert_safe

give_respawn_equipment = function(player)
  local equipment = script_data.difficulty.respawn_items
  local items = game.item_prototypes
  local list = {items = {}, armor, equipment = {}}
  for name, count in pairs (equipment) do
    local item = items[name]
    if item then
      if item.type == "armor" then
        local count = count
        if not list.armor then
          list.armor = item
        end
        count = count - 1
        if count > 0 then
          list.items[item] = (list.items[item] or 0) + count
        end
      elseif item.place_as_equipment_result then
        list.equipment[item] = (list.equipment[item] or 0) + count
      else
        list.items[item] = (list.items[item] or 0) + count
      end
    else
      equipment[name] = nil
    end
  end
  local put_equipment = false
  if list.armor then
    local stack = player.get_inventory(defines.inventory.player_armor)[1]
    stack.set_stack{name = list.armor.name}
    local grid = stack.grid
    if grid then
      put_equipment = true
      for prototype, count in pairs (list.equipment) do
        local equipment = prototype.place_as_equipment_result
        for k = 1, count do
          local equipment = grid.put{name = equipment.name}
          if equipment then
            equipment.energy = equipment.max_energy
          else
            player.insert{name = prototype.name}
          end
        end
      end
    end
  end

  if not put_equipment then
    for prototype, count in pairs (list.equipment) do
      player.insert{name = prototype.name, count = count}
    end
  end

  for prototype, count in pairs (list.items) do
    player.insert{name = prototype.name, count = count}
  end
end

function refresh_preview_gui(player)
  local frame = script_data.gui_elements.preview_frame[player.index]
  if not (frame and frame.valid) then return end
  deregister_gui(frame)
  frame.clear()


  local admin = player.admin
  local inner = frame.add{type = "frame", style = "inside_deep_frame", direction = "vertical"}.add{type = "flow", direction = "vertical"}
  inner.style.vertical_spacing = 0
  local subheader = inner.add{type = "frame", style = "subheader_frame"}
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  subheader.style.horizontally_stretchable = true
  --subheader.style.vertical_align = "center"
  subheader.style.bottom_padding = 1
  local label = subheader.add{type = "label", caption = {"gui-map-generator.difficulty"}, style = "caption_label"}
  label.style.vertically_stretchable = true
  label.style.vertical_align = "center"
  label.style.right_padding = 3
  if admin then
    local config = subheader.add{type = "drop-down"}
    local count = 1
    local index
    for name, difficulty in pairs (script_data.config.difficulties) do
      config.add_item{name}
      if difficulty == script_data.difficulty then
        index = count
      end
      count = count + 1
    end
    config.selected_index = index
    register_gui_action(config, {type = "difficulty_changed"})
  else
    local key
    for k, value in pairs (script_data.config.difficulties) do
      if value == script_data.difficulty then key = k break end
    end
    subheader.add{type = "label", caption = {key}, style = "caption_label"}
  end
  local pusher = subheader.add{type = "flow"}
  pusher.style.horizontally_stretchable = true
  local seed_flow = subheader.add{type = "flow", direction = "horizontal", style = "player_input_horizontal_flow"}
  seed_flow.add{type = "label", style = "caption_label", caption = {"gui-map-generator.map-seed"}}
  if admin then
    local seed_input = seed_flow.add{type = "textfield", text = surface.map_gen_settings.seed, style = "long_number_textfield"}
    register_gui_action(seed_input, {type = "check_seed_input"})
    local shuffle_button = seed_flow.add{type = "sprite-button", sprite = "utility/shuffle", style = "tool_button"}
    register_gui_action(shuffle_button, {type = "shuffle_button"})
    local refresh_button = seed_flow.add{type = "sprite-button", sprite = "utility/refresh", style = "tool_button"}
    register_gui_action(refresh_button, {type = "refresh_button", textfield = seed_input})
  else
    seed_flow.add{type = "label", style = "caption_label", caption = surface.map_gen_settings.seed}
  end
  local max = (math.min(player.display_resolution.width, player.display_resolution.height) / player.display_scale) * 0.75
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
  minimap.style.natural_width = max
  minimap.style.natural_height = max
  --minimap.style.top_margin = 0

  --minimap.style.vertically_stretchable = true
  --minimap.style.horizontally_stretchable = true

  local button_flow = frame.add{type = "flow"}
  button_flow.style.horizontal_align = "right"
  button_flow.style.horizontally_stretchable = true
  local start_round = button_flow.add{type = "button", caption = {"start-round"}, style = "confirm_button", enabled = admin}
  register_gui_action(start_round, {type = "start_round"})
end

function make_preview_gui(player)
  local gui = player.gui.center
  local frame = script_data.gui_elements.preview_frame[player.index]
  if not (frame and frame.valid) then
    frame = gui.add{type = "frame", caption = {"setup-frame"}, direction = "vertical"}
    frame.style.horizontal_align = "right"
    script_data.gui_elements.preview_frame[player.index] = frame
  end
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
  caption = {"admin"},
  tooltip = {"upgrade-button-tooltip"},
  style = mod_gui.button_style
}

local add_admin_buttons = function(player)

  if not player.admin then return end

  local button_flow = mod_gui.get_button_flow(player)
  local admin_button = button_flow.add(admin_button_param)
  script_data.gui_elements.admin_frame_button[player.index] = admin_button
  register_gui_action(admin_button, {type = "admin_button"})
end

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

  add_admin_buttons(player)
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

  if script_data.state == game_state.defeat or script_data.state == game_state.victor then
    add_admin_buttons(player)
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
    flow.style.horizontally_stretchable = true
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
      upgrade.price = function(x) return floor((1 + x)) * price end
      upgrade.sprite = "technology/"..append
      upgrade.caption = {"technology-name."..name}
      upgrade.effect = {}
      for k, effect in pairs (base.effects) do
        local type = effect.type
        if type == "ammo-damage" then
          local cat = effect.ammo_category
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_ammo_damage_modifier(cat, force.get_ammo_damage_modifier(cat) + mod)
          end
        elseif type == "turret-attack" then
          local id = effect.turret_id
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_turret_attack_modifier(id, force.get_turret_attack_modifier(id) + mod)
          end
        elseif type == "gun-speed" then
          local cat = effect.ammo_category
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            force.set_gun_speed_modifier(cat, force.get_gun_speed_modifier(cat) + mod)
          end
        elseif type == "maximum-following-robots-count" then
          upgrade.modifier = "+"..tostring(mod)
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            increment(force, "maximum_following_robot_count", mod)
          end
        elseif type == "mining-drill-productivity-bonus" then
          upgrade.effect[k] = function(event)
            local force = players(event.player_index).force
            increment(force, "mining_drill_productivity_bonus", mod)
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
  bonus.price = function(x) return floor((1 + x)) * 2500 end
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
  caption = {"admin"},
  direction = "vertical"
}

local admin_buttons =
{
  {
    param = {type = "button", caption = {"end-round"}},
    action = {type = "end_round"}
  },
  {
    param = {type = "button", caption = {"restart-round"}},
    action = {type = "restart_round"}
  },
  {
    param = {type = "button", caption = "Dev only: Send wave"},
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
    butt.style.horizontally_stretchable = true
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

local init_map_settings = function()
  local settings = game.map_settings
  settings.pollution.enabled = false
  settings.enemy_expansion.enabled = false
  settings.path_finder.use_path_cache = false
  settings.path_finder.max_steps_worked_per_tick = 500
  settings.path_finder.max_clients_to_accept_any_new_request = 100

  settings.steering.moving.force_unit_fuzzy_goto_behavior = true
  settings.steering.moving.radius = 6
  settings.steering.moving.separation_force = 0.01
  settings.steering.moving.separation_factor = 8

  settings.steering.default.force_unit_fuzzy_goto_behavior = true
  settings.steering.default.radius = 1
  settings.steering.default.separation_force = 0.02
  settings.steering.default.separation_factor  = 1
end

local on_init = function()
  init_map_settings()
  init_force(game.forces.player)
end

local round_won = function()
  game.print({"you-win"})
end

local spawner_died = function(event)
  local spawner = event.entity
  if not (spawner and spawner.valid) then return end
  script_data.spawners[spawner.unit_number] = nil

  --If there are still spawners in this list, they haven't won
  if next(script_data.spawners) then return end

  --All spawners are dead, player wins!
  round_won()

end

local bounty_color = {r = 0.2, g = 0.8, b = 0.2, a = 0.2}
local on_entity_died = function(event)
  local died = event.entity
  if not (died and died.valid) then return end

  local bounty = script_data.difficulty.bounties[died.name]
  if bounty and (event.force and event.force.name == "player") then
    local cash = floor(bounty * script_data.bounty_bonus)
    increment(script_data, "money", cash)
    died.surface.create_entity{name = "flying-text", position = died.position, text = "+"..cash, color = bounty_color}
    update_label_list(script_data.gui_labels.money_label, get_money())
  end

  if died.type == "rocket-silo" then
    return rocket_died(event)
  end

  if died.type == "unit-spawner" then
    return spawner_died(event)
  end
end

local on_rocket_launched = function(event)
  round_won()
end

local on_player_joined_game = function(event)
  local player = players(event.player_index)
  if not (script_data.surface and script_data.surface.valid) then
    create_battle_surface(initial_seed)
  end
  set_up_player(player)
end

local on_player_respawned = function(event)
  local player = players(event.player_index)
  give_respawn_equipment(player)
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
  set_up_players()
end

local gui_functions =
{
  send_next_wave = function(event)
    local element = event.element
    if not (element and element.valid and element.enabled) then return end
    if script_data.end_spawn_tick then return end
    local player = players(event.player_index)
    local skipped = floor(script_data.skipped_multiplier * (script_data.wave_tick - event.tick) * (1.15 ^ script_data.wave_number))
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
    if script_data.money < price then
      player.print({"not-enough-money"})
      return
    end

    increment(script_data, "money", -price)
    for k, effect in pairs (list[name].effect) do
      effect(event)
    end
    increment(script_data.team_upgrades, name)
    game.print({"purchased-team-upgrade", player.name, list[name].caption, upgrades[name]})
    update_connected_players()
    for k, player in pairs (game.connected_players) do
      update_upgrade_listing(player)
    end
    update_label_list(script_data.gui_labels.money_label, get_money())

  end,
  shuffle_button = function(event, param)
    create_battle_surface()
  end,
  refresh_button = function(event, param)
    local input = param.textfield
    if not (input and input.valid) then return end
    local seed = input.text
    if is_reasonable_seed(seed) then
      create_battle_surface(seed)
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
  end,
  restart_round = function(event, param)
    restart_round()
  end,
  difficulty_changed = function(event, param)
    local gui = event.element
    if not (gui and gui.valid) then return end
    if not (event.name == defines.events.on_gui_selection_state_changed) then return end
    local selected = gui.selected_index
    local index = 1
    for name, difficulty in pairs (script_data.config.difficulties) do
      if index == selected then
        script_data.difficulty = difficulty
        break
      end
      index = index + 1
    end
    create_battle_surface(script_data.surface.map_gen_settings.seed)
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
end

local chart_base_area = function(tick)
  if tick % 12 ~= 0 then return end
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  local force = game.forces.player
  local origin = force.get_spawn_position(surface)
  local size = get_base_radius()
  force.chart(surface,
  {
    {
      origin.x - (size + 32),
      origin.y - (size + 32)
    },
    {
      origin.x + size,
      origin.y + size
    }
  })
end


local on_tick = function(event)
  local tick = event.tick

  if script_data.state == game_state.in_round then
    check_next_wave(tick)
    check_spawn_units(tick)
    update_connected_players(tick)
    chart_base_area(tick)
    return
  end

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
    rendering.draw_light
    {
      sprite = "utility/light_medium",
      target = spawner,
      surface = surface,
      scale = 2,
      intensity = 1,
      color = {r = 0.5, a = 1}
    }
  end
end

local refresh_player_gui_event = function(event)
  return gui_init(players(event.player_index))
end

local is_valid_map = function(map)
  for string, number in pairs (map) do
    if type(string) ~= "string" then return end
    if type(number) ~= "number" then return end
  end
  return true
end

local add_remote_interface = function()
  if remote.interfaces["wave-defense"] then return end
  remote.add("wave_defense",
  {
    set_config = function(data)
      if type(data) ~= "table" then
        error("Data type for 'set_config' must be a table")
      end
      script_data.config = data
    end,
    get_config = function()
      return script_data.config
    end
  }
  )
end

local events =
{
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_player_respawned] = on_player_respawned,
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_rocket_launched] = on_rocket_launched,
  [defines.events.on_gui_text_changed] = generic_gui_event,
  [defines.events.on_gui_click] = generic_gui_event,
  [defines.events.on_gui_selection_state_changed] = generic_gui_event,
  [defines.events.on_player_died] = on_player_died,
  [defines.events.on_chunk_generated] = on_chunk_generated,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_player_promoted] = refresh_player_gui_event,
  [defines.events.on_player_display_resolution_changed] = refresh_player_gui_event,
  [defines.events.on_player_display_scale_changed] = refresh_player_gui_event,
  [defines.events.on_player_demoted] = refresh_player_gui_event,

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

lib.get_events = function()
  return events
end

return lib
