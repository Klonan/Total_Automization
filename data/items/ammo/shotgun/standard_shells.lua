local name = names.ammo.standard_shells
local ammo = util.copy(data.raw.ammo["shotgun-shell"])
ammo.name = name
ammo.localised_name = name
--ammo.icon = path.."shotgun_ammo.png"
--ammo.icon_size = 256
ammo.reload_time = SU(210 - 37.5)
ammo.magazine_size = 6
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
      repeat_count = 15,
      action_delivery =
      {
        type = "projectile",
        projectile = name,
        starting_speed = SD(1),
        starting_speed_deviation = SD(0.2),
        direction_deviation = 0.4,
        range_deviation = 0.1,
        max_range = 35
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name
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
        type = "damage",
        damage = {amount = 8 , type = util.damage_type("shotgun")}
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