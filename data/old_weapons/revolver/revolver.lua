local path = util.path("data/weapons/revolver/")
local gun = util.base_gun(names.revolver)
gun.icon = path.."revolver.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("revolver"),
  cooldown = SU(34.8),
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

local ammo = util.base_ammo(names.revolver)
ammo.icon = path.."revolver_ammo.png"
ammo.icon_size = 256
ammo.magazine_size = 6
ammo.stack_size = 4
ammo.reload_time = SU((60 * 1.16) - 34.8)
ammo.ammo_type =
{
  category = util.ammo_category("revolver"),
  target_type = "direction",
  action =
  {
    type = "line",
    range = 40,
    width = 0.5,
    force = "not-same",
    source_effects =
    {
      type = "create-explosion",
      entity_name = "railgun-beam"
    },
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        type = "damage",
        damage = { amount = 40, type= util.damage_type("revolver")}
      }
    }
  }
}

data:extend{gun, ammo}



