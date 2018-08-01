--Shared data interface between data and script, notably prototype names.

local data = {}

data.weapon_names =
{
  scattergun = "Scattergun",
  pistol = "Pistol",
  bat = "Bat",
  rocket_launcher = "Rocket Launcher",
  shotgun = "Shotgun",
  shovel = "Shovel",
  flamethrower = "Flame Thrower",
  flare_gun = "Flare Gun",
  fire_axe = "Fire Axe",
  grenade_launcher = "Grenade Launcher",
  stickybomb_launcher = "Stickybomb Launcher",
  bottle = "Bottle",
  minigun = "Minigun",
  fists = "Fists",
  wrench = "Wrench",
  syringe_gun = "Syringe Gun",
  medi_gun = "Medi Gun",
  bonesaw = "Bonesaw",
  sniper_rifle = "Sniper Rifle",
  submachine_gun = "Submachine Gun",
  kukri = "Kukri",
  revolver = "Revolver",
  knife = "Knife"
}

data.class_names =
{
  scout = "Scout",
  soldier = "Soldier",
  pyro = "Pyro",
  demoman = "Demoman",
  heavy = "Heavy",
  engineer = "Engineer",
  medic = "Medic",
  sniper = "Sniper",
  spy = "Spy"
}

data.hotkeys =
{
  change_class = "Change class",
  unit_move = "Move unit",
  suicide = "Suicide"
}

data.unit_tools =
{
  unit_selection_tool = "Select units",
  deployer_selection_tool = "Select deployers",
  unit_move_tool = "Move to position",
  unit_patrol_tool = "Add patrol waypoint",
  unit_move_sound = "Unit move sound",
  unit_attack_move_tool = "Attack move to position",
  unit_attack_tool = "Attack targets",
  unit_force_attack_tool = "Force attack targets",
  move_indicator = "Move Indicator",
  attack_move_indicator = "Attack Move Indicator",
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
  flame_car = "Flame Car",
  acid_worm = "Acid Worm",
  beetle = "Beetle",
  piercing_biter = "Piercing Biter",
  shell_tank = "Shell Tank"
}

data.entities =
{
  recon_outpost = "Recon Outpost",
  command_center = "Command Center",
  command_center_turret = "Command Center Turret",
  big_miner = "Big Mining Drill",
  small_miner = "Small Mining Drill",
  teleporter = "Teleporter",
  gun_turret = "Gun Turret"
}

data.deployers =
{
  iron_unit = "Iron Unit Deployer",
  bio_unit = "Bio Unit Deployer",
  circuit_unit = "Circuit Unit Deployer"
}

return data
