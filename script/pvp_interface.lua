--Interfaces with the base game PvP scenario.

local on_round_start = function(event)
  for k, force in pairs (game.forces) do
    force.disable_research()
    force.inserter_stack_size_bonus = 1
    force.worker_robots_storage_bonus = 5
    force.worker_robots_speed_modifier = 3
    force.character_logistic_slot_count = 18
    force.character_trash_slot_count = 12
    force.quickbar_count = 2
    force.ghost_time_to_live = 999999999
    force.character_build_distance_bonus = 2
    force.character_item_drop_distance_bonus = 2
    force.character_reach_distance_bonus = 2
    force.character_resource_reach_distance_bonus = 2
    force.character_inventory_slots_bonus = 20
    force.auto_character_trash_slots = true
  end
end

local events = {}

local register_pvp_events = function()
  local pvp_events = remote.call("pvp", "get_events")
  --events[pvp_events.on_round_start] = on_round_start
end

local names = names

local pvp_interface = {}

pvp_interface.on_init = function()
  if not remote.interfaces["pvp"] then return end
  local config = remote.call("pvp", "get_config")
  local prototypes = config.prototypes
  --prototypes.turret = names.entities.small_gun_turret
  --prototypes.wall = names.entities.stone_wall
  --prototypes.gate = names.entities.stone_gate
  --prototypes.silo = names.entities.command_center
  --prototypes.artillery = names.entities.tesla_turret
  prototypes.chest = "logistic-chest-storage"
  --config.silo_offset = {0, 0}
  --config.team_config.defcon_mode = nil
  --config.team_config.defcon_timer = nil
  --config.team_config.unlock_combat_research = nil
  --config.team_config.friendly_fire = nil
  --config.team_config.starting_equipment = nil
  --config.team_config.research_level = nil
  --config.team_config.technology_price_multiplier = nil
  --config.game_config.protect_empty_teams = nil
  --config.game_config.enemy_building_restriction = nil
  --config.game_config.neutral_chests = nil
  --config.game_config.turret_ammunition = nil
  --config.game_config.no_rush_time = nil
  --config.game_config.base_exclusion_time = nil
  --config.victory.space_race = nil
  --config.victory.required_satellites_sent = nil
  remote.call("pvp", "set_config", config)
  register_pvp_events()
  pvp_interface.on_event = handler(events)
end

pvp_interface.on_load = function()
  if not remote.interfaces["pvp"] then return end
  register_pvp_events()
  pvp_interface.on_event = handler(events)
end

pvp_interface.get_events = function() return events end

return pvp_interface
