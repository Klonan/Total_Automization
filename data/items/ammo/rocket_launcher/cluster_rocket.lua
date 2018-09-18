local name = names.ammo.cluster_rocket
local ammo = util.copy(data.raw.ammo["rocket"])
ammo.name = name
ammo.localised_name = name
ammo.magazine_size = 2
ammo.stack_size = 20 / 4
ammo.reload_time = SU(150)
ammo.ammo_type =
{
  category = util.ammo_category("rocket_launcher"),
  target_type = "position",
  clamp_position = true,
  action =
  {
    type = "direct",
    repeat_count = 6,
    action_delivery =
    {
      type = "projectile",
      projectile = name,
      starting_speed = SD(0.1),
      starting_speed_deviation = 0.1,
      direction_deviation = 0.3,
      range_deviation = 0.3,
      max_range = 45,
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile.rocket)
projectile.name = name
projectile.acceleration = SA(0.01)
projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
projectile.force_condition = "not-same"
projectile.direction_only = true
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 1.5,
          collision_mode = "distance-from-center",
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 15, type = util.damage_type("rocket")}
              },
              {
                type = "create-entity",
                entity_name = "explosion"
              }
            }
          }
        }
      }
    }
  }
}

data:extend{ammo, projectile}