local heavy = util.base_player()
heavy.name = "heavy"
heavy.running_speed = SD(0.15)
local scale = 1.8
util.recursive_hack_scale(heavy, scale)
util.scale_boxes(heavy, scale)


heavy_gun = util.copy(data.raw.gun["submachine-gun"])
heavy_gun.name = "heavy-gun"
heavy_gun.stack_size = 1

heavy_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "bullet",
  cooldown = SU(4),
  movement_slow_down_factor = 0.6,
  shell_particle =
  {
    name = "shell-particle",
    direction_deviation = 0.1,
    speed = SD(0.1),
    speed_deviation = SD(0.03),
    center = {0, 0.1},
    creation_distance = -0.5,
    starting_frame_speed = 0.4,
    starting_frame_speed_deviation = 0.1
  },
  projectile_creation_distance = 1.125,
  range = 40,
  sound = make_light_gunshot_sounds(),
}

heavy_ammo = util.copy(data.raw.ammo["firearm-magazine"])
heavy_ammo.name = "heavy-ammo"

--TODO better bullet spread/feel
heavy_ammo.ammo_type =
{
  category = "bullet",
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
      action_delivery =
      {
        type = "projectile",
        projectile = "heavy-projectile",
        starting_speed = SD(1),
        direction_deviation = 0.05,
        range_deviation = 0.05,
        max_range = 40
      }
    }
  }
}
heavy_ammo.magazine_size = 200

heavy_projectile = util.copy(data.raw.projectile["cannon-projectile"])
heavy_projectile.name = "heavy-projectile"
heavy_projectile.piercing_damage = 10
heavy_projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 20 , type = "physical"}
      },
      {
        type = "create-explosion",
        entity_name = "explosion-gunshot"
      },
    }
  }
}
heavy_projectile.final_action = nil


data:extend
{
  heavy,
  heavy_ammo,
  heavy_gun,
  heavy_projectile
}
