local machine = util.copy(data.raw["assembling-machine"]["centrifuge"])
local name = names.deployers.circuit_unit
machine.name = name
machine.localised_name = {name}
local scale = 2
util.recursive_hack_make_hr(machine)
util.recursive_hack_scale(machine, scale)
machine.collision_box = {{-2.7, -2.7},{2.7, 2.7}}
machine.selection_box = {{-2.9, -2.9},{2.9, 2.9}}
machine.crafting_categories = {name}
machine.crafting_speed = (1)
machine.ingredient_count = 100
machine.module_specification =
{
  module_slots = 2
}
machine.animation = machine.idle_animation
machine.idle_animation = nil
machine.minable = {result = name, mining_time = 1}
machine.flags = {"placeable-neutral", "player-creation", "no-automated-item-removal"}
machine.fluid_boxes =
{
  {
    production_type = "output",
    pipe_picture = nil,
    pipe_covers = nil,
    base_area = 1,
    base_level = 1,
    pipe_connections = {{ type="output", position = {0, -3} }},
  },
  off_when_no_fluid_recipe = false
}
machine.scale_entity_info_icon = true
machine.always_draw_idle_animation = false
machine.working_visualisations = nil
machine.is_deployer = true
machine.energy_usage = "400kW"
machine.energy_source =
{
  type = "electric",
  usage_priority = "secondary-input",
  emissions_per_second_per_watt = 1 / 180000
}

local item = {
  type = "item",
  name = name,
  icon = machine.icon,
  icon_size = machine.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "aa"..name,
  place_result = name,
  stack_size = 50
}

local category = {
  type = "recipe-category",
  name = name
}

local subgroup =
{
  type = "item-subgroup",
  name = "circuit-units",
  group = "combat",
  order = "z"
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = {name},
  enabled = false,
  ingredients =
  {
    {"electronic-circuit", 50},
    {"copper-cable", 50},
    {"copper-plate", 50}
  },
  energy_required = 100,
  result = name
}

local technology_name = names.technologies.circuit_units

local technology_1 = {
  type = "technology",
  name = technology_name,
  localised_name = {technology_name},
  localised_description = "",
  icon_size = machine.icon_size,
  icon = machine.icon,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = name
    },
    {
      type = "unlock-recipe",
      recipe = names.units.blaster_bot
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      --{"logistic-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {"automation"},
  order = "z-a"
}

local technology_2 = {
  type = "technology",
  name = technology_name.."-2",
  localised_name = technology_name.." 2",
  localised_description = "",
  icon_size = machine.icon_size,
  icon = machine.icon,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = names.units.tazer_bot
    },
    {
      type = "unlock-recipe",
      recipe = names.units.laser_bot
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      --{"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {technology_name},
  order = "z-b",
  upgrade = true
}

local technology_3 = {
  type = "technology",
  name = technology_name.."-3",
  localised_name = technology_name.." 3",
  localised_description = "",
  icon_size = machine.icon_size,
  icon = machine.icon,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = names.units.plasma_bot
    }
  },
  unit =
  {
    count = 500,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      --{"chemical-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {technology_name.."-2"},
  order = "z-c",
  upgrade = true
}


local damage_technology_name = names.technologies.circuit_units_damage

local damage_icon =
{
  icon = "__base__/graphics/technology/physical-projectile-damage-2.png",
  icon_size = 128,
  scale = 0.8 * (32 / 128)
}

local damage_technology_icon =
{
  {
    icon = machine.icon,
    icon_size = machine.icon_size
  },
  damage_icon
}


local circuit_unit_damage_1 =
{
  type = "technology",
  name = damage_technology_name.."-1",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      --{"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {technology_name},
  order = "y-d",
  upgrade = false
}

local circuit_unit_damage_2 =
{
  type = "technology",
  name = damage_technology_name.."-2",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {circuit_unit_damage_1.name},
  order = "y-e",
  upgrade = true
}

local circuit_unit_damage_3 =
{
  type = "technology",
  name = damage_technology_name.."-3",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {circuit_unit_damage_2.name},
  order = "y-f",
  upgrade = true
}

local circuit_unit_damage_4 =
{
  type = "technology",
  name = damage_technology_name.."-4",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {circuit_unit_damage_3.name},
  order = "y-g",
  upgrade = true
}

local circuit_unit_damage_5 =
{
  type = "technology",
  name = damage_technology_name.."-5",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"utility-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {circuit_unit_damage_4.name},
  order = "y-h",
  upgrade = true
}

local circuit_unit_damage_6 =
{
  type = "technology",
  name = damage_technology_name.."-6",
  localised_name = {damage_technology_name},
  localised_description = "",
  icons = damage_technology_icon,
  effects =
  {
    {
      type = "ammo-damage",
      ammo_category = "circuit-units",
      modifier = 0.2
    }
  },
  unit =
  {
    count_formula = "2^(L-5)*250",
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"military-science-pack", 1},
      {"chemical-science-pack", 1},
      {"utility-science-pack", 1},
    },
    time = 30
  },
  max_level = "infinite",
  upgrade = true,
  prerequisites = {circuit_unit_damage_5.name},
  order = "y-h",
  upgrade = true
}

data:extend
{
  machine,
  item,
  category,
  subgroup,
  recipe,
  technology_1,
  technology_2,
  technology_3,
  circuit_unit_damage_1,
  circuit_unit_damage_2,
  circuit_unit_damage_3,
  circuit_unit_damage_4,
  circuit_unit_damage_5,
  circuit_unit_damage_6
}