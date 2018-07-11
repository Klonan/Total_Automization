local path = util.path("data/weapons/syringe_gun/")
local gun = util.base_gun(names.syringe_gun)
gun.icon = path.."syringe_gun.png"
gun.icon_size = 512
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("medic-needle-gun"),
  cooldown = SU(6),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  projectile_center = {0, -0.5},
  range = 25,
  sound =
  {
    {
      filename = path.."syringe_gun_shoot.ogg"
    }
  }
}

ammo = util.base_ammo(names.syringe_gun)
ammo.icon = path.."syringe_gun_ammo.png"
ammo.icon_size = 90
ammo.magazine_size = 40
ammo.stack_size = 160 / 40
ammo.reload_time = SU(96 - 6)
ammo.ammo_type =
{
  category = util.ammo_category("medic-needle-gun"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = names.syringe_gun.." Projectile",
        starting_speed = SD(0.31),
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 25
      }
    }
  }
}

projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = names.syringe_gun.." Projectile"
projectile.height = 0.5
projectile.force_condition = "not-same"
projectile.action = 
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = 10, type = util.damage_type("medic-needle-gun")}
      }
    }
  }
}
projectile.final_action = nil

projectile.animation =
{
  filename = path.."syringe_gun_projectile.png",
  frame_count = 1,
  width = 17,
  height = 119,
  scale = 0.4,
  priority = "high"
}

data:extend{gun, ammo, projectile}