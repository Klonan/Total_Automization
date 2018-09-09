local path = util.path("data/items/weapons/pistol/")
local name = names.weapons.revolver
local gun = util.base_gun(name)
gun.icon = path.."revolver.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("revolver"),
  cooldown = SU(35),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."revolver_shoot.ogg",
      volume = 1
    }
  }
}
gun.stack_size = 1

data:extend{gun}
