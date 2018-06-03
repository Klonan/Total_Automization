local path = util.path("data/sniper/")
local sniper = util.base_player()
sniper.name = "sniper"
sniper.running_speed = util.speed(1)
sniper.max_health = 125
local scale = 1.2
util.recursive_hack_scale(sniper, scale)
util.scale_boxes(sniper, scale)

sniper_gun = util.copy(data.raw.gun.railgun)
sniper_gun.name = "sniper-gun"
sniper_gun.icon = path.."sniper-gun.png"
sniper_gun.icon_size = 80
sniper_gun.attack_parameters =
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
      filename = path.."sniper-gun.ogg",
      volume = 1
    }
  }
}
sniper_gun.stack_size = 1

sniper_ammo = util.copy(data.raw.ammo["railgun-dart"])
sniper_ammo.name = "sniper-ammo"
sniper_ammo.ammo_type =
{
  category = util.ammo_category("sniper-ammo"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    type = "line",
    range = 55,
    width = 0.5,
    force = "enemy",
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

--local sniper_smg_gun = util.copy(data.raw["sub-machine-gun"])
--sniper_smg_gun.name = "sniper-smg"

data:extend
{
  sniper,
  sniper_gun,
  sniper_ammo,
  --sniper_smg_gun
}