local name = require("shared").ammo.extended_magazine
local ammo = util.copy(data.raw.ammo["firearm-magazine"])
ammo.name = name
ammo.localised_name = name
ammo.magazine_size = 55
ammo.stack_size = 5
ammo.reload_time = SU(150)
ammo.ammo_type =
{
  category = util.ammo_category("machine_gun"),
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
      action_delivery =
      {
        type = "projectile",
        projectile = name,
        starting_speed = SD(1),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 40
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
        entity_name = "explosion-hit"
      },
      {
        type = "damage",
        damage = {amount = 8 , type = util.damage_type("machine_gun")}
      }
    }
  }
}
projectile.final_action = nil

data:extend{ammo, projectile}



