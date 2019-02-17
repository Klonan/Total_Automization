--Shared data interface between data and script, notably prototype names.

local data = {}

data.hotkeys =
{
  shoo = "Shoo!"
}

data.units =
{
  tazer_bot = "Tazer Bot",
  blaster_bot = "Blaster Bot",
  laser_bot = "Laser Bot",
  plasma_bot = "Plasma Bot",
  scatter_spitter = "Scatter Spitter",
  smg_guy = "SMG Guy",
  rocket_guy = "Rocket Guy",
  scout_car = "Scout Car",
  acid_worm = "Acid Worm",
  beetle = "Beetle",
  piercing_biter = "Piercing Biter",
  shell_tank = "Shell Tank",
}

data.technologies =
{
  iron_units = "Iron Units",
  circuit_units = "Circuit Units",
}

data.deployers =
{
  iron_unit = "Iron Unit Deployer",
  circuit_unit = "Circuit Unit Deployer"
}

return data
