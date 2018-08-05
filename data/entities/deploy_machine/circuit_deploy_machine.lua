local machine = util.copy(data.raw["assembling-machine"]["centrifuge"])
local name = require("shared").deployers.circuit_unit
machine.name = name
machine.localised_name = name
local scale = 2
util.recursive_hack_make_hr(machine)
util.recursive_hack_scale(machine, scale)
machine.collision_box = {{-2.7, -2.7},{2.7, 2.7}}
machine.selection_box = {{-2.9, -2.9},{2.9, 2.9}}
machine.crafting_categories = {name}
machine.crafting_speed = SD(1)
machine.ingredient_count = 100
machine.module_specification = nil
machine.animation = machine.idle_animation
machine.idle_animation = nil
machine.minable = {result = name, mining_time = 5}
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
machine.always_draw_idle_animation = false
machine.working_visualisations = nil
machine.minable.result = name

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
  group = "units",
  order = "a"
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  enabled = true,
  ingredients =
  {
    {"electronic-circuit", 50},
    {"copper-cable", 100},
    {"copper-plate", 50}
  },
  energy_required = 100,
  result = name
}

data:extend{machine, item, category, subgroup, recipe}