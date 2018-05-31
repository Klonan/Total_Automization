local scout = util.base_player()
scout.name = "scout"
local scale = 0.8
util.recursive_hack_scale(scout, scale)
util.scale_boxes(scout, scale)
scout.running_speed = SD(0.3)

local scout_gun = util.copy(data.raw.gun.shotgun)
scout_gun.name = "scout-gun"
scout_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "shotgun-shell",
  cooldown = SU(35),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 35,
  min_range = 1,
  sound =
  {
    {
      filename = "__base__/sound/pump-shotgun.ogg",
      volume = 0.5
    }
  }
}

local scout_ammo = util.copy(data.raw.ammo["shotgun-shell"])
scout_ammo.name = "scout-ammo"
scout_ammo.ammo_type =
{
  category = "shotgun-shell",
  target_type = "direction",
  clamp_position = true,
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
      repeat_count = 15,
      action_delivery =
      {
        type = "projectile",
        projectile = "shotgun-pellet",
        starting_speed = SD(1),
        direction_deviation = 0.1,
        range_deviation = 0.3,
        max_range = 35
      }
    },
    {
      type = "direct",
      repeat_count = 15,
      action_delivery =
      {
        type = "projectile",
        projectile = "shotgun-pellet",
        starting_speed = SD(1),
        direction_deviation = 0.4,
        range_deviation = 0.3,
        max_range = 35
      }
    }
  }
}

local scout_projectile = util.copy(data.raw.projectile["shotgun-pellet"])
scout_projectile.name = "scout-projectile"



data:extend
{
  scout,
  scout_ammo,
  scout_gun,
  scout_rocket
}





