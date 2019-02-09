local name = names.items.biological_structure
local path = util.path("data/items/biological_structure/")
local item =
{
  type = "item",
  name = name,
  localised_name = name,
  stack_size = 50,
  icon = path.."biological_structure.png",
  icon_size = 32,
  order = "z-"..name,
  subgroup = "raw-material",
  flags = {}
}

local recipe =
{
  type = "recipe",
  name = name,
  localised_name = name,
  ingredients = {
    --{type = "fluid", name = "water", amount = 200},
    {type = "item", name = "coal", amount = 5}
  },
  energy_required = 5,
  result = name,
  result_count = 2,
  order = "z-"..name,
  category = "smelting",
  enabled = true,
  flags = {}
}

data:extend{item, recipe}