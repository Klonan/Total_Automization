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

data.hotkey_names =
{
  change_class = "Change class"
}

data.unit_names =
{
  unit_selection_tool = "Select units",
  unit_move_tool = "Move to position",
  unit_move_sound = "Unit move sound",
  unit_attack_move_tool = "Attack move to position",
  unit_attack_tool = "Attack targets",
}

return data
