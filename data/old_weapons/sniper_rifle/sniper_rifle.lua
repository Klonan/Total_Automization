local path = util.path("data/weapons/sniper_rifle/")
local gun = util.base_gun(names.sniper_rifle)
gun.icon = path.."sniper_rifle.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("sniper-ammo"),
  cooldown = SU(1.5 * 60),
  movement_slow_down_factor = 0.73,
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

local ammo = util.base_ammo(names.sniper_rifle)
ammo.icon = path.."sniper_rifle_ammo.png"
ammo.icon_size = 512
ammo.stack_size = 25
ammo.magazine_size = 1
ammo.ammo_type =
{
  category = util.ammo_category("sniper-ammo"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    type = "line",
    range = 55,
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
        damage = { amount = 100, type= util.damage_type("sniper-gun")}
      }
    }
  }
}

data:extend{gun, ammo}
