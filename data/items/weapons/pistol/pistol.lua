local path = util.path("data/items/weapons/pistol/")
local name = names.weapons.pistol
local gun = util.copy(data.raw.gun.pistol)
gun.name = name
gun.localised_name = name
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("pistol"),
  cooldown = SU(10),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 0.6,
  --damage_modifier = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."pistol_shoot.ogg",
      volume = 1
    }
  }
}
gun.stack_size = 1

data:extend{gun}
