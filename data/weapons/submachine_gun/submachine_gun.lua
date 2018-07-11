local path = util.path("data/weapons/submachine_gun/")
local gun = util.base_gun(names.submachine_gun)
gun.icon = path.."submachine_gun.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("sniper-smg"),
  cooldown = SU(6),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."submachine_gun_shoot.ogg",
      volume = 1
    }
  }
}
gun.stack_size = 1

local ammo = util.base_ammo(names.submachine_gun)
ammo.icon = path.."submachine_gun_ammo.png"
ammo.icon_size = 256
ammo.magazine_size = 25
ammo.stack_size = 75 / 25
ammo.reload_time = SU(60)
ammo.ammo_type =
{
  category = util.ammo_category("sniper-smg"),
  target_type = "direction",
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = names.submachine_gun.." Projectile",
        starting_speed = SD(1),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 40
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["cannon-projectile"])
projectile.name = names.submachine_gun.." Projectile"
projectile.piercing_damage = 0
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
        type = "create-explosion",
        entity_name = "explosion-hit"
      },
      {
        type = "damage",
        damage = {amount = 8 , type = util.damage_type("sniper-smg")}
      }
    }
  }
}
projectile.final_action = nil

data:extend{gun, ammo, projectile}



