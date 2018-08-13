local name = require("shared").entities.small_gun_turret
local turret = util.copy(data.raw["ammo-turret"]["gun-turret"])

turret.name = name
turret.localised_name = name
turret.type = "turret"
turret.energy_source = {type = "void"}
turret.preparing_speed = SD(0.05)
turret.order = "noob"
turret.prepare_range = 42
turret.max_health = 800
turret.minable.result = name
turret.attack_parameters =
{
  type = "projectile",
  ammo_category = "bullet",
  cooldown = SU(5),
  cooldown_deviation = 0.5,
  range = 38,
  projectile_creation_distance = 1.39375,
  projectile_center = {0, -0.0875},
  sound = {
    variations = make_heavy_gunshot_sounds(),
    aggregation =
    {
      max_count = 3,
      remove = true
    }
  },
  ammo_type =
  {
    category = "bullet",
    target_type = "direction",
    action =
    {
      type = "direct",
      action_delivery =
      {
        {
        type = "projectile",
        projectile = name.." Projectile",
        starting_speed = SD(1),
        starting_speed_deviation = SD(0.1),
        direction_deviation = 0.25,
        range_deviation = 0.05,
        max_range = 42
        },
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
      }
    }
  }
}


local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.animation.blend_mode = "additive"
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
        damage = {amount = 4 , type = util.damage_type(name)}
      }
    }
  }
}
projectile.final_action = 
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
      }
    }
  }
}


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = turret.icon,
  icon_size = turret.icon_size,
  flags = {},
  order = "a-"..name,
  stack_size= 10,
  place_result = name,
  subgroup = "defensive-structure",
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  enabled = true,
  ingredients =
  {
    {"stone-brick", 100},
    {"iron-gear-wheel", 10},
    {"copper-plate", 10}
  },
  energy_required = 10,
  result = name
}

data:extend{turret, projectile, item, recipe}
