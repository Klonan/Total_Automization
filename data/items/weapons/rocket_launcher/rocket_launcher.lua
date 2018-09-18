local path = util.path("data/items/weapons/rocket_launcher/")
local name = names.weapons.rocket_launcher
local gun = util.copy(data.raw.gun["rocket-launcher"])
--gun.icon = path.."rocket_launcher.png"
--gun.icon_size = 512
gun.name = name
gun.localised_name = name
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("rocket_launcher"),
  movement_slow_down_factor = 0.3,
  cooldown = SU(48),
  projectile_creation_distance = 0.6,
  range = 45,
  projectile_center = {-0.17, 0},
  sound =
  {
    {
      filename = path.."rocket_launcher_shoot.ogg"
    }
  }
}

data:extend{gun}
