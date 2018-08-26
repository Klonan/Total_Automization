local name = require("shared").weapons.submachine_gun
local path = util.path("data/items/weapons/machine_gun/")
local gun = util.copy(data.raw.gun["submachine-gun"])
gun.name = name
gun.localised_name = name
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("machine_gun"),
  cooldown = SU(5),
  cooldown_deviation = 0.15,
  movement_slow_down_factor = 0,
  movement_slow_down_cooldown = SU(30),
  projectile_creation_distance = 0.6,
  damage_modifier = 0.8,
  range = 30,
  sound =
  {
    {
      filename = path.."machine_gun_shoot.ogg",
      volume = 1
    }
  }
}
gun.stack_size = 1

data:extend{gun}