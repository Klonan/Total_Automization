local name = require("shared").weapons.shotgun
local path = util.path("data/items/weapons/shotgun/")

local gun = util.copy(data.raw.gun["combat-shotgun"])
gun.name = name
gun.localised_name = name
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("shotgun"),
  cooldown = SU(37.5),
  cooldown_deviation = 0.1,
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 35,
  sound =
  {
    {
      filename = path.."shotgun_shoot.ogg"
    }
  }
}

data:extend{gun}

local name = require("shared").weapons.double_barreled_shotgun
local path = util.path("data/items/weapons/shotgun/")

local gun = util.copy(data.raw.gun["shotgun"])
gun.name = name
gun.localised_name = name
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("shotgun"),
  cooldown = SU(30),
  cooldown_deviation = 0.1,
  movement_slow_down_factor = 0.2,
  movement_slow_down_cooldown = SU(60),
  projectile_creation_distance = 1.125,
  damage_modifier = 2,
  ammo_consumption_modifier = 2,
  range = 35,
  sound =
  {
    {
      filename = path.."shotgun_shoot.ogg"
    }
  }
}

data:extend{gun}

