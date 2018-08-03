local name = require("shared").entities.laser_turret
local turret = util.copy(data.raw["electric-turret"]["laser-turret"])

turret.energy_source = {type = "void"}
turret.name = name
turret.type = "turret"
turret.localised_name = name
turret.prepare_range = 40
turret.attack_parameters =
{
  type = "beam",
  ammo_category = "electric",
  cooldown = SU(1),
  range = 36,
  projectile_center = {-0.09375, -0.2},
  projectile_creation_distance = 1.4,
  source_direction_count = 64,
  source_offset = {0, -3.423489 / 4},
  damage_modifier = 4,
  ammo_type =
  {
    category = "laser-turret",
    energy_consumption = "800kJ",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "beam",
        beam = name.." Beam",
        max_length = 40,
        duration = SU(2),
        source_offset = {0.15, -0.5},
      }
    }
  }
}
turret.max_health = 600
turret.minable.result = name


local beam = util.copy(data.raw.beam["laser-beam"])
beam.name = name.." Beam"
beam.damage_interval = SU(1)
beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = 1.0, type = "electric"}
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
  stack_size = 1,
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
    {"stone-brick", 4}
  },
  energy_required = 5,
  result = name
}

data:extend{turret, beam, item, recipe}

