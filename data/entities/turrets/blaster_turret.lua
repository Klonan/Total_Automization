local name = require("shared").entities.blaster_turret
local turret = util.copy(data.raw["electric-turret"]["laser-turret"])
--local base = util.copy(data.raw["ammo-turret"]["gun-turret"])
--util.recursive_hack_make_hr(base)
--util.recursive_hack_scale(base, 0.5)

turret.energy_source = {type = "void"}
turret.name = name
turret.type = "turret"
turret.localised_name = name
turret.prepare_range = 40
turret.rotation_speed = 0.025
--turret.collision_box = {{-0.8, -0.8},{0.8, 0.8}}
--turret.selection_box = {{-1, -1},{1, 1}}
--turret.base_picture = base.base_picture
turret.attack_parameters =
{
  type = "projectile",
  ammo_category = "bullet",
  cooldown = SU(6),
  cooldown_deviation = 0.5,
  range = 35,
  projectile_creation_distance = 1,
  projectile_center = {0, -0.8},
  sound = 
  {
    {
      filename = "__base__/sound/fight/laser-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/laser-2.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/laser-3.ogg",
      volume = 0.5
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
        starting_speed = SD(1.5),
        direction_deviation = 0.025,
        range_deviation = 0.05,
        max_range = 40
        }
      }
    }
  }
}
turret.max_health = 400
turret.minable.result = name

util.recursive_hack_make_hr(turret)



local projectile = util.copy(data.raw.projectile["laser"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
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
        type = "damage",
        damage = {amount = 12, type = util.damage_type(name)}
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
        entity_name = "laser-bubble"
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
  order = "b-"..name,
  stack_size = 10,
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
    {"copper-plate", 15},
    {"electronic-circuit", 15},
    {"copper-cable", 10}
  },
  energy_required = 15,
  result = name
}

data:extend{turret, projectile, item, recipe}

