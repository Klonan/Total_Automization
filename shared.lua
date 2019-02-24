--Shared data interface between data and script, notably prototype names.

local data = {}

data.hotkeys =
{
  shoo = "shoo"
}

data.units =
{
  tazer_bot = "tazer-bot",
  blaster_bot = "blaster-bot",
  laser_bot = "laser-bot",
  plasma_bot = "plasma-bot",
  smg_guy = "smg-guy",
  rocket_guy = "rocket-guy",
  scout_car = "scout-car",
  shell_tank = "shell-tank",
}

data.technologies =
{
  iron_units = "iron-units",
  circuit_units = "circuit-units",
}

data.deployers =
{
  iron_unit = "iron-unit-deployer",
  circuit_unit = "circuit-unit-deployer"
}

return data
