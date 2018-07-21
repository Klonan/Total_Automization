local machine = util.copy(data.raw["assembling-machine"]["assembling-machine-2"])
local name = require("shared").deployers.iron_unit
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

local item = {
  type = "item",
  name = name,
  icon = machine.icon,  
  icon_size = machine.icon_size,
  flags = {},
  subgroup = "circuit-network",
  order = name,
  place_result = name,
  stack_size = 50
}

local category = {
  type = "recipe-category",
  name = name
}

data:extend{machine, item, category}