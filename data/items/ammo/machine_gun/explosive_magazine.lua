local name = require("shared").ammo.explosive_magazine
local ammo = util.copy(data.raw.ammo["piercing-rounds-magazine"])
ammo.name = name
ammo.localised_name = name
ammo.magazine_size = 15
ammo.stack_size = 8
ammo.reload_time = SU(75)
ammo.ammo_type =
{
  category = util.ammo_category("machine_gun"),
  target_type = "direction",
  cooldown_modifier = 1.2,
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
        projectile = name,
        starting_speed = SD(0.8),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 30
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["cannon-projectile"])
projectile.name = name
projectile.localised_name = name
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
        type = "create-entity",
        entity_name = "explosion"
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 2,
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 5, type = util.damage_type("explosive_machine_gun")}
              },
              {
                type = "create-entity",
                entity_name = "explosion-hit"
              }
            }
          }
        }
      }
    }
  }
}
projectile.final_action = nil

data:extend{ammo, projectile}



