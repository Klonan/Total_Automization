local name = names.ammo.slug_shells
local ammo = util.copy(data.raw.ammo["piercing-shotgun-shell"])
ammo.name = name
ammo.localised_name = name
--ammo.icon = path.."shotgun_ammo.png"
--ammo.icon_size = 256
ammo.reload_time = SU(210 - 37.5)
ammo.magazine_size = 4
ammo.stack_size = 10
ammo.ammo_type =
{
  category = util.ammo_category("shotgun"),
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
      repeat_count = 1,
      action_delivery =
      {
        type = "projectile",
        projectile = name,
        starting_speed = SD(1),
        starting_speed_deviation = SD(0.1),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 40
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.animation.scale = 2
projectile.name = name
projectile.force_condition = "not-same"
projectile.piercing_damage = 200
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
        damage = {amount = 100 , type = util.damage_type("shotgun")}
      },
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      },
    }
  }
}
projectile.acceleration = 0

data:extend{ammo, projectile}