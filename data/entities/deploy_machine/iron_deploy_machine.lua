local machine = util.copy(data.raw["assembling-machine"]["assembling-machine-3"])
local name = names.deployers.iron_unit
machine.name = name
machine.localised_name = name
local scale = 2
util.recursive_hack_make_hr(machine)
util.recursive_hack_scale(machine, scale)
machine.collision_box = {{-2.7, -2.7},{2.7, 2.7}}
machine.selection_box = {{-2.9, -2.9},{2.9, 2.9}}
machine.crafting_categories = {name}
machine.crafting_speed = SD(1)
machine.ingredient_count = nil
machine.module_specification = nil
machine.minable = {result = name, mining_time = 2}
machine.flags = {"placeable-neutral", "player-creation"}
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
machine.minable.result = name

local item = {
  type = "item",
  name = name,
  icon = machine.icon,  
  icon_size = machine.icon_size,
  flags = {},
  subgroup = "iron-units",
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
  name = "iron-units",
  group = "combat",
  order = "y"
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  enabled = false,
  ingredients =
  {
    {"iron-plate", 50},
    {"iron-gear-wheel", 80},
    {"iron-stick", 50},
  },
  energy_required = 100,
  result = name
}

local technology_name = names.technologies.iron_units

local technology_1 = {
  type = "technology",
  name = technology_name,
  localised_name = technology_name,
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
      recipe = names.units.smg_guy
    }
  },
  unit =
  {
    count = 100,
    ingredients = {
      {"science-pack-1", 1},
      {"science-pack-2", 1},
    },
    time = 30
  },
  prerequisites = {"automation"},
  order = "y-a"
}

local technology_2 = {
  type = "technology",
  name = technology_name.."-2",
  localised_name = technology_name.." 2",
  icon_size = machine.icon_size,
  icon = machine.icon,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = names.units.rocket_guy
    },
    {
      type = "unlock-recipe",
      recipe = names.units.scout_car
    }
  },
  unit =
  {
    count = 200,
    ingredients = {
      {"science-pack-1", 1},
      {"science-pack-2", 1},
      {"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {technology_name},
  order = "y-b",
  upgrade = true
}

local technology_3 = {
  type = "technology",
  name = technology_name.."-3",
  localised_name = technology_name.." 3",
  icon_size = machine.icon_size,
  icon = machine.icon,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = names.units.shell_tank
    }
  },
  unit =
  {
    count = 500,
    ingredients = {
      {"science-pack-1", 1},
      {"science-pack-2", 1},
      {"science-pack-3", 1},
      {"military-science-pack", 1},
    },
    time = 30
  },
  prerequisites = {technology_name.."-2"},
  order = "y-c",
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
  technology_3
}