local util = require "util"
local mod_gui = require "mod-gui"
local map_gen_settings = require "wave_defense_map_gen_settings"
local increment = util.increment
local format_number = util.format_number
local format_time = util.formattime
local insert = table.insert

local script_data =
{
  wave_number = 0,
  wave_tick = 21250,
  force_bounty_modifier = 0.5,
  bounty_bonus = 1,
  skipped_multiplier = 0.1,
  round_button_visible = true,
  money = 0,
  send_satellite_round = false,
  spawn_time = 2500,
  wave_time = 10000,
  team_upgrades = {},
  gui_elements =
  {
    preview_frame = {},
    wave_frame = {},
    upgrade_frame = {},
    upgrade_table = {},
    money_label = {},
    time_label = {},
    round_label = {},
    next_round_button = {},
    wave_frame_button = {},
    upgrade_frame_button = {},
  },
  gui_actions = {}
}

local max_seed = 2^32 - 2
local initial_seed = 314159265 -- Something nice

local players = function(index)
  --deliberately not local, micro-optimization?
  player_list = player_list or game.players
  if not index then return player_list end
  return player_list[index]
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

function init_forces()
  for k, force in pairs (game.forces) do
    set_research(force)
    set_recipes(force)
    --force.set_spawn_position(script_data.silo.position, game.surfaces[1])
    force.friendly_fire = false
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
  script_data.in_round = true
  script_data.wave_tick = game.tick + 5 * 60 * 60
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
  surface.request_to_generate_chunks({0,0}, math.ceil(size / 32))
  surface.force_generate_chunk_requests()
  game.forces.player.chart(surface, {{-size, -size},{size, size}})
  script_data.surface = surface
  create_silo()
  for k, player in pairs (players()) do
    refresh_preview_gui(player)
  end
end

function create_silo()
  local force = game.forces.player
  local surface = script_data.surface
  local origin = force.get_spawn_position(surface)
  local offset = {0,0}
  local silo_position = {x = origin.x + (offset.x or offset[1]), y = origin.y + (offset.y or offset[2])}
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

function init_globals()
  init_unit_settings()
  for name, upgrade in pairs (get_upgrades()) do
    script_data.team_upgrades[name] = 0
  end
end

function init_unit_settings()
  game.map_settings.unit_group.max_group_slowdown_factor = 1
  game.map_settings.unit_group.max_member_speedup_when_behind = 2
  game.map_settings.unit_group.max_member_slowdown_when_ahead = 0.8
  game.map_settings.unit_group.member_disown_distance = 25
  game.map_settings.unit_group.min_group_radius = 8.0
  game.map_settings.path_finder.use_path_cache = true
  game.map_settings.path_finder.max_steps_worked_per_tick = 300
  game.map_settings.path_finder.short_cache_size = 50
  game.map_settings.path_finder.long_cache_size = 50
end

function check_next_wave(tick)
  if not script_data.wave_tick then return end
  if script_data.wave_tick ~= tick then return end
  game.print({"next-wave"})
  next_wave()
end

function next_wave()
  increment(script_data, "wave_number")
  make_next_wave_tick()
  make_next_spawn_tick()
  local exponent = math.min(#game.connected_players, 8)
  script_data.force_bounty_modifier = (0.5 * (1.15 / (1.15 ^ exponent)))
  update_round_number()
  script_data.wave_power = calculate_wave_power(script_data.wave_number)
  next_round_button_visible(false)
  local value = math.floor(100*((script_data.wave_number - 1) % 20 + 1) / 20)
  if (script_data.silo and script_data.silo.valid) then
    script_data.silo.rocket_parts = value
  end
  script_data.send_satellite_round = (value == 100)
  command_straglers()
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
  next_round_button_visible(true)
  game.print({"wave-over"})
  spawn_units()
  script_data.spawn_tick = nil
end

function make_next_spawn_tick()
  script_data.spawn_tick = game.tick + math.random(200, 300)
end

function check_spawn_units(tick)
  if not script_data.spawn_tick then return end

  if script_data.send_satellite_round then
    script_data.end_spawn_tick = tick + 1
    script_data.wave_tick = tick + script_data.wave_time
    if tick % 250 == 0 then
      if not (script_data.silo and script_data.silo.valid) then return end
      if not script_data.silo.get_inventory(defines.inventory.rocket_silo_rocket) then
        script_data.silo.rocket_parts = 100
      end
    end
  end

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

function spawn_units()

  local rand = math.random
  local surface = game.surfaces[1]
  if surface.count_entities_filtered{type = "unit"} > 500 then return end
  local power = script_data.wave_power
  local spawns = script_data.spawns
  local spawns_count = #spawns
  local units = get_wave_units(script_data.wave_number)
  local units_length = #units
  local groups = {}
  local group_count = 1
  local new_group = true
  local spawn
  local unit_count
  local group

  while units_length > 0 do
    if new_group == true then
      spawn = spawns[rand(spawns_count)]
      group = surface.create_unit_group{position = spawn}
      groups[group_count] = group; group_count = group_count + 1
      new_group = false
      unit_count = 0
    end
    local k = rand(units_length)
    local biter = units[k]
    local cost = biter.cost
    if cost > power then
      table.remove(units, k)
      units_length = units_length - 1
    else
      local position = surface.find_non_colliding_position(biter.name, spawn, 32, 2)
      if position then
        if unit_count <= 500 then
          group.add_member(surface.create_entity{name = biter.name, position = position})
          power = power - cost
          unit_count = unit_count + 1
        else
          new_group = true
        end
      else
        break
      end
    end
  end
  set_command(groups)
end

function randomize_ore()
  local surface = game.surfaces[1]
  local rand = math.random
  for k, ore in pairs (surface.find_entities_filtered{type = "resource"}) do
    ore.amount = ore.amount + rand(-5, 5)
  end
end

function set_command(groups)
  if not (script_data.silo and script_data.silo.valid) then return end
  local waypoints = script_data.waypoints
  local num_waypoints = #waypoints
  local rand = math.random
  local def = defines
  local compound = def.command.compound
  local structure = def.compound_command.return_last
  local go_to = def.command.go_to_location
  local attack = def.command.attack
  local target = script_data.silo
  for k, group in pairs (groups) do
    group.set_command
    {
      type = compound,
      structure_type = structure,
      commands =
      {
        {type = go_to, destination = waypoints[rand(num_waypoints)]},
        {type = attack, target = target}
      }
    }
  end
end

function command_straglers()
  if not (script_data.silo and script_data.silo.valid) then return end
  local command = {type = defines.command.attack, target = script_data.silo}
  for k, unit in pairs (game.surfaces[1].find_entities_filtered({type = "unit"})) do
    if not unit.unit_group then
      unit.set_command(command)
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
  script_data.wave_tick  = script_data.end_spawn_tick + script_data.wave_time
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
  if silo == script_data.silo then
    game.set_game_state{game_finished = true, player_won = false, can_continue = false}
    script_data.silo = nil
  end
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

function next_round_button_visible(bool)
  script_data.round_button_visible = bool
  for k, button in pairs (script_data.gui_elements.next_round_button) do
    button.visible = bool
    button.enabled = not bool
  end
end

function delete_preview_gui(player)

  local frame = script_data.gui_elements.preview_frame[player.index]
  if frame and frame.valid then frame.destroy() end
  script_data.gui_elements.preview_frame[player.index] = nil

end

function refresh_preview_gui(player)

  local frame = script_data.gui_elements.preview_frame[player.index]
  if not (frame and frame.valid) then return end
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
  local minimap = inner.add{type = "minimap", surface_index = surface.index, zoom = max / (surface.get_starting_area_radius() * 2), force = player.force.name, position = player.force.get_spawn_position(surface)}
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
    frame.destroy()
  end
  frame = gui.add{type = "frame", caption = "Start round or something", direction = "vertical"}
  frame.style.horizontal_align = "right"
  script_data.gui_elements.preview_frame[player.index] = frame
  refresh_preview_gui(player)
end

function gui_init(player)

  if not script_data.in_round then
    make_preview_gui(player)
    return
  end

  delete_preview_gui(player)
  create_wave_frame(player)

  local button_flow = mod_gui.get_button_flow(player)
  local button = script_data.gui_elements.wave_frame_button[player.index]
  if not button then
    button = button_flow.add
    {
      type = "sprite-button",
      style = mod_gui.button_style,
      sprite = "entity/behemoth-spitter",
      tooltip = {"visibility-button-tooltip"}
    }
    script_data.gui_elements.wave_frame_button[player.index] = button
    register_gui_action(button, {type = "wave_defense_visibility_button"})
  end

  local upgrade_button = script_data.gui_elements.upgrade_frame_button[player.index]
  if not upgrade_button then
    upgrade_button = button_flow.add
    {
      type = "sprite-button",
      caption = {"upgrade-button"},
      tooltip = {"upgrade-button-tooltip"},
      style = mod_gui.button_style
    }
    script_data.gui_elements.upgrade_frame_button[player.index] = upgrade_button
    register_gui_action(upgrade_button, {type = "upgrade_button"})
  end

  local upgrade_frame = script_data.gui_elements.upgrade_frame[player.index]
  if upgrade_frame and upgrade_frame.valid then
    upgrade_frame.destroy()
  end
  script_data.gui_elements.upgrade_frame[player.index] = nil

end

local cash_font_color = {r = 0.8, b = 0.5, g = 0.8}
local wave_frame =
{
  type = "frame",
  caption = {"wave-frame"},
  direction = "vertical"
}

function create_wave_frame(player)

  local frame = script_data.gui_elements.wave_frame[player.index]

  if not (frame and frame.valid) then
    frame = mod_gui.get_frame_flow(player).add(wave_frame)
    script_data.gui_elements.wave_frame[player.index] = frame
  end

  frame.clear()
  frame.visible = true

  local round = frame.add{type = "label", caption = {"current-wave", script_data.wave_number}}
  insert(script_data.gui_elements.round_label, round)

  local time = frame.add{type = "label", caption = {"time-to-next-wave", time_to_next_wave()}}
  insert(script_data.gui_elements.time_label, time)

  local money_table = frame.add{type = "table", column_count = 2}
  money_table.add{type = "label", name = "force_money_label", caption = {"force-money"}}
  local cash = money_table.add{type = "label", caption = get_money()}
  insert(script_data.gui_elements.money_label, cash)
  cash.style.font_color = cash_font_color
  local button = frame.add
  {
    type = "button",
    caption = {"send-next-wave"},
    tooltip = {"send-next-wave-tooltip"},
    style = "play_tutorial_button"
  }
  insert(script_data.gui_elements.next_round_button, button)
  register_gui_action(button, {type = "send_next_wave"})
  button.style.font = "default"
  button.visible = script_data.round_button_visible
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
  insert(script_data.gui_elements.money_label, cash)
  cash.style.font_color = {r = 0.8, b = 0.5, g = 0.8}
  local scroll = frame.add{type = "scroll-pane"}
  scroll.style.maximal_height = 450
  local upgrade_table = scroll.add{type = "table", column_count = 2}
  upgrade_table.style.horizontal_spacing = 0
  upgrade_table.style.vertical_spacing = 0
  script_data.gui_elements.upgrade_table[player.index] = upgrade_table
  update_upgrade_listing(player)
end

local on_gui_closed = function(event)
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
    register_gui_action(sprite, {type = "purchase_button", name = name})
    local flow = gui.add{type = "frame", name = name.."_flow", direction = "vertical"}
    flow.style.maximal_height = 75
    local another_table = flow.add{type = "table", name = name.."_label_table", column_count = 1}
    another_table.style.vertical_spacing = 2
    local label = another_table.add{type = "label", name = name.."_name", caption = {"", upgrade.caption, " "..upgrade.modifier}}
    label.style.font = "default-bold"
    another_table.add{type = "label", name = name.."_price", caption = {"upgrade-price", format_number(upgrade.price(level))}}
    if not upgrade.hide_level then
      local level = another_table.add{type = "label", name = name.."_level", caption = {"upgrade-level", level}}
    end
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
  local sat = {}
  sat.modifier = ""
  sat.sprite = "technology/rocket-silo"
  sat.price = function(x) return 500000 end
  sat.hide_level = true
  sat.effect = {}
  sat.effect[1] = function(event)
    if not (script_data.silo and script_data.silo.valid) then return end
    local inventory = script_data.silo.get_inventory(defines.inventory.rocket_silo_rocket)
    if inventory then
      local contents = script_data.silo.get_inventory(defines.inventory.rocket_silo_rocket).get_contents()
      if #contents == 0 then
        inventory.insert("satellite")
        game.print({"satellite-purchase", players(event.player_index).name})
        return false
      end
    end
    increment(script_data, "money", 500000)
    players(event.player_index).print({"satellite-refund"})
    return false
  end
  sat.caption = {"buy-satellite"}
  list["buy-satellite"] = sat
  return list
end

function get_money()
  return format_number(script_data.money)
end

local update_label_list = function (list, caption)
  local list = script_data.gui_elements.time_label
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

  update_label_list(script_data.gui_elements.money_label, get_money())

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
  if script_data.send_satellite_round then
    caption = {"send-satellite"}
  end

  update_label_list(script_data.gui_elements.time_label, caption)
end

function update_round_number()
  update_label_list(script_data.gui_elements.round_label, {"current-wave", script_data.wave_number})
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

function set_player(player)
  give_spawn_equipment(player)
  give_starting_equipment(player)
end

local on_player_created = function(event)
  local player = players(event.player_index)
  if player.character then
    player.character.destroy()
  end
end

local on_init = function()
  init_globals()
  --setup_waypoints()
  --init_forces()
  --game.map_settings.pollution.enabled = false
  --randomize_ore()
  create_battle_surface(initial_seed)
end

local on_entity_died = function(event)
  local entity_type = event.entity.type
  if entity_type == "unit" then
    unit_died(event)
    return
  end
  if entity_type == "rocket-silo" then
    rocket_died(event)
    return
  end
end

local on_rocket_launched = function(event)
  local rocket = event.rocket
  if rocket.get_item_count("satellite") > 0 then
    game.set_game_state{game_finished = true, player_won = true, can_continue = true}
    script_data.send_satellite_round = false
    wave_end()
    update_connected_players()
  else
    game.print({"no-satellite"})
  end
end


local on_player_joined_game = function(event)
  local player = players(event.player_index)
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

local gui_functions =
{
  send_next_wave = function(event)
    local element = event.element
    if not (element and element.valid and element.enabled) then return end
    if script_data.end_spawn_tick then return end
    local player = players(event.player_index)
    local skipped = math.floor(script_data.skipped_multiplier * (script_data.wave_tick - event.tick) * (1.15 ^ script_data.wave_number))
    increment(script_data, "money", skipped)
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
  wave_defense_visibility_button = function(event)
    local frame = script_data.gui_elements.wave_frame[event.player_index]
    frame.visible = not frame.visible
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
      if sucess and (#players() > 1) then
        game.print({"purchased-team-upgrade", player.name, list[name].caption,upgrades[name]})
      end
      update_connected_players()
      for k, player in pairs (game.connected_players) do
        update_upgrade_listing(player)
      end
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



--(game_finished, boolean)
--(player_won, boolean)
--(next_level, string)
--(can_continue, boolean)
--(victorious_force, ForceSpecification)

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
