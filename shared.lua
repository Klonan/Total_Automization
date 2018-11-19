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

data.weapons =
{
  machine_gun = "Machine Gun",
  submachine_gun = "Submachine Gun",
  shotgun = "Shotgun",
  double_barreled_shotgun = "Double-barreled Shotgun",
  pistol = "Pistol",
  revolver = "Revolver",
  sniper_rifle = "Sniper Rifle",
  rocket_launcher = "Rocket Launcher",



  beam_rifle = "Beam Rifle",
  grenade_launcher = "Grenade Launcher",
  mine_layer ="Mine layer",
  plasma_launcher = "Plasma launcher",
  smg = "SMG",
  laser_rifle = "Laser Rifle",
  tazer = "Tazer",
  flare_gun = "Flare Gun"
}

data.ammo =
{
  standard_magazine = "Standard Magazine",
  explosive_magazine = "Explosive Magazine",
  piercing_magazine = "Piercing Magazine",
  extended_magazine = "Extended Magazine",
  smart_magazine = "Smart Magazine",

  standard_shells = "Standard Shells",
  incendiary_shells = "Incendiary Shells",
  slug_shells = "Slug Shells",

  pistol_magazine = "Pistol Magazine",
  revolver_rounds = "Revolver Rounds",

  sniper_rounds = "Sniper Rounds",
  rocket = "Rocket",
  cluster_rocket = "Cluster Rocket",




  rockets = "Rockets",
  sniper_round = "Sniper Round",
  grenade = "Grenade",
  mine = "Mine",
  beam_cell = "Beam Cell",
  sticky_plasma = "Sticky Plasma",
  smg_rounds = "SMG Rounds",
  shotgun_shells = "Shotgun Shells",
  pulse_laser_cell = "Pulse laser cell",
  pistol_rounds = "Pistol Rounds",
  magnum_rounds = "Magnum Rounds",
  tazer_charge = "Tazer Charge",
  incendiary_flare = "Incendiary Flare"
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
  spy = "Spy",
  light = "Light"
}

data.hotkeys =
{
  change_class = "Change class",
  --unit_move = "Move unit",
  suicide = "Suicide",
  shoo = "Shoo!"
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
  unit_selection_sticker = "Unit Selection Sticker",
  deployer_selection_sticker = "Deployer Selection Sticker",
  enemy_selection_sticker = "Enemy Selection Sticker"
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
  shell_tank = "Shell Tank"
}

data.technologies =
{
  iron_units = "Iron Units",
  circuit_units = "Circuit Units",
  construction_drone_system = "Construction Drone System"
}

data.entities =
{
  recon_outpost = "Recon Outpost",
  command_center = "Command Center",
  big_miner = "Big Mining Drill",
  small_miner = "Small Mining Drill",
  teleporter = "Teleporter",
  small_gun_turret = "Small Gun Turret",
  big_gun_turret = "Big Gun Turret",
  laser_turret = "Laser Turret",
  blaster_turret = "Blaster Turret",
  tazer_turret = "Tazer Turret",
  rocket_turret = "Rocket Turret",
  setup_time_animation = "Setup Animation",
  stone_wall = "Stone Wall",
  stone_gate = "Stone Gate",
  concrete_wall = "Concrete Wall",
  concrete_gate = "Concrete Gate",
  sell_chest = "Trade Chest Sell",
  buy_chest = "Trade Chest Buy",
  damage_indicator_text = "Damage Indicator Text",
  logistic_beacon = "Logistic Beacon",
  construction_drone = "Construction Drone",
  simple_storage_chest = "Simple Storage Chest",
  simple_provider_chest = "Simple Provider Chest"
}

data.deployers =
{
  iron_unit = "Iron Unit Deployer",
  --bio_unit = "Bio Unit Deployer",
  circuit_unit = "Circuit Unit Deployer"
}

data.items =
{
  biological_structure = "Biological Structure",
  ammo_pack = "Ammo pack"
}

data.sounds =
{
  ammo_pack_sound = "Ammo Pack Sound"
}

return data
