local machine = util.copy(data.raw["assembling-machine"]["centrifuge"])
local name = require("shared").deployers.circuit_unit
machine.name = name
machine.localised_name = name
local scale = 2
util.recursive_hack_make_hr(machine)
util.recursive_hack_scale(machine, scale)
util.scale_boxes(machine, scale)
machine.fluid_boxes = nil
machine.crafting_categories = {name}
machine.crafting_speed = SD(1)
machine.ingredient_count = 100
machine.module_specification = nil
machine.animation = machine.idle_animation
machine.idle_animation = nil
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
  order = name,
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

data:extend{machine, item, category, subgroup}