local path = util.path("data/items/weapons/sniper_rifle/")
local name = names.weapons.sniper_rifle
local gun = util.base_gun(name)
gun.icon = path.."sniper_rifle.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("sniper"),
  cooldown = SU(90),
  movement_slow_down_factor = 0.75,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."sniper_rifle_shoot.ogg"
    }
  }
}
gun.stack_size = 1

data:extend{gun}
