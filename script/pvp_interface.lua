--Interfaces with the base game PvP scenario.

local names = require("shared")

local on_init = function()
  if not remote.interfaces["pvp"] then return end
  local config = remote.call("pvp", "get_config")
  config.prototypes.turret = names.entities.big_gun_turret
  config.prototypes.wall = names.entities.concrete_wall
  config.prototypes.gate = names.entities.concrete_gate
  config.prototypes.silo = names.entities.command_center
  config.prototypes.artillery = names.entities.rocket_turret
  config.silo_offset = {0,0}
  remote.call("pvp", "set_config", config)
end

local pvp_interface = {}
pvp_interface.on_init = on_init
return pvp_interface