--Interfaces with the base game PvP scenario.
if not remote.interfaces["pvp"] then return {} end

local pvp_interface = {}

local on_round_start = function()
  for k, force in pairs (game.forces) do
    force.disable_research()
    force.inserter_stack_size_bonus = 1
    force.worker_robots_storage_bonus = 5
    force.worker_robots_speed_modifier = 3
    force.character_logistic_slot_count = 18
    force.character_trash_slot_count = 12
    force.quickbar_count = 3
    force.ghost_time_to_live = 999999999
    force.character_build_distance_bonus = 2
    force.character_item_drop_distance_bonus = 2
    force.character_reach_distance_bonus = 2
    force.character_resource_reach_distance_bonus = 2
    force.character_inventory_slots_bonus = 20
    force.auto_character_trash_slots = true
  end
end

local names = require("shared")
local events = {}
local register_events = function()
  local pvp_events = remote.call("pvp", "get_events")
  for name, id in pairs (pvp_events) do
    defines.events[name] = id
  end
  --script.on_event(defines.events, control.on_event())
  events = 
  {
    [defines.events.on_round_start] = on_round_start,
  }
  pvp_interface.on_event = handler(events)
  
end

local on_init = function()
  register_events()
  local config = remote.call("pvp", "get_config")
  config.prototypes.turret = names.entities.small_gun_turret
  config.prototypes.wall = names.entities.stone_wall
  config.prototypes.gate = names.entities.stone_gate
  config.prototypes.silo = names.entities.command_center
  config.prototypes.artillery = names.entities.tesla_turret
  config.prototypes.chest = "logistic-chest-storage"
  config.silo_offset = {0,0}
  config.inventory_list.medium[names.entities.small_miner] = 50
  config.inventory_list.medium[names.entities.big_miner] = 25
  remote.call("pvp", "set_config", config)
end

local on_load = function()
  register_events()
end

pvp_interface.on_init = on_init
pvp_interface.on_load = on_load
return pvp_interface