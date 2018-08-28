local path = util.path("data/weapons/pistol/")
local gun = util.base_gun(names.pistol)
gun.icon = path.."pistol.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("pistol"),
  cooldown = SU(10.2),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 0.6,
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

local ammo = util.base_ammo(names.pistol)
ammo.icon = path.."pistol_ammo.png"
ammo.icon_size = 256
ammo.magazine_size = 12
ammo.stack_size = 10
ammo.reload_time = SU((60 * 1.25) - 10.2)
ammo.ammo_type =
{
  category = util.ammo_category("pistol"),
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
        projectile = names.pistol.." Projectile",
        starting_speed = SD(1),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 40
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["cannon-projectile"])
projectile.name = names.pistol.." Projectile"
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
        damage = {amount = 15 , type = util.damage_type("pistol")}
      }
    }
  }
}
projectile.final_action = nil

data:extend{gun, ammo, projectile}



