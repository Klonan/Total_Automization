local sniper = util.base_player()
sniper.name = "sniper"
sniper.running_speed = SD(0.2)
local scale = 1.2
util.recursive_hack_scale(sniper, scale)
util.scale_boxes(sniper, scale)

sniper_gun = util.copy(data.raw.gun.railgun)
sniper_gun.name = "sniper-gun"
sniper_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "railgun",
  cooldown = SU(1.5 * 60),
  movement_slow_down_factor = 0.33,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = "__base__/sound/railgun.ogg",
      volume = 0.8
    }
  }
}
sniper_gun.stack_size = 1

sniper_ammo = util.copy(data.raw.ammo["railgun-dart"])
sniper_ammo.name = "sniper-ammo"
sniper_ammo.ammo_type =
{
  category = "railgun",
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
        damage = { amount = 150, type="physical"}
      }
    }
  }
}

data:extend
{
  sniper,
  sniper_gun,
  sniper_ammo
}