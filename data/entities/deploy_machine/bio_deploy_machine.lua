local machine = util.copy(data.raw["assembling-machine"]["assembling-machine-2"])
local graphics = util.copy(data.raw["unit-spawner"]["biter-spawner"])
local name = require("shared").deployers.bio_unit
machine.name = name
machine.localised_name = name
machine.icon = graphics.icon
machine.icon_size = graphics.icon_size
local scale = 2
util.recursive_hack_make_hr(machine)
util.recursive_hack_scale(machine, scale)
machine.collision_box = {{-2.2, -2.2},{2.2, 2.2}}
machine.selection_box = {{-2.4, -2.4},{2.4, 2.4}}
machine.crafting_categories = {name}
machine.crafting_speed = SD(1)
machine.ingredient_count = 100
machine.module_specification = nil
machine.minable = {result = name, mining_time = 5}
machine.flags = {"placeable-neutral", "player-creation"}
machine.animation = 
{
north = graphics.animations[1],
east = graphics.animations[2],
south = graphics.animations[3],
west = graphics.animations[4],
}
machine.working_sound = graphics.working_sound
machine.fluid_boxes =
{
  {
    production_type = "output",
    pipe_picture = nil,
    pipe_covers = nil,
    base_area = 1,
    base_level = 1,
    pipe_connections = {{ type= "output", position = {0, -3} }},
  },
  {
    production_type = "input",
    pipe_picture = nil,
    pipe_covers = nil,
    base_area = 5,
    height = 2,
    base_level = -1,
    pipe_connections = {{ type = "input", position = {0, 3} }},
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
  subgroup = "bio-units",
  order = "aa-"..name,
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
  name = "bio-units",
  group = "combat",
  order = "b"
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  enabled = true,
  ingredients =
  {
    {"coal", 250},
  },
  energy_required = 100,
  result = name
}

data:extend{machine, item, category, subgroup, recipe}