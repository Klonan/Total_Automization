local name = require("shared").entities.auto_miner
local path = util.path("data/entities/auto_miner")

local miner = util.copy(data.raw["mining-drill"]["electric-mining-drill"])
miner.name = name
miner.localised_name = name

local scale = 5 / 3
util.recursive_hack_make_hr(miner)
util.recursive_hack_scale(miner, scale)
util.scale_boxes(miner, scale)
--util.recursive_hack_tint{r = 1}

miner.energy_source = {type = "void", emissions = 0.2}
miner.mining_power = 4.9
miner.mining_speed = 13.333 / 4
miner.localised_description = "Each miner outputs 1 half of a transport belt."
miner.resource_searching_radius = 4.49
miner.minable = {mining_time = 2, result = name}
miner.vector_to_place_result = {0, -1.75 * scale}
miner.order = "noob"
miner.input_fluid_box.pipe_connections =
{
  { position = {-2.5, 0} },
  { position = {2.5, 0} },
  { position = {0, 2.5} }
}
miner.radius_visualisation_picture.scale = 1

local item = util.copy(data.raw.item["electric-mining-drill"])
item.name = name
item.localised_name = name
item.place_result = name

local recipe = util.copy(data.raw.recipe["electric-mining-drill"])
recipe.name = name
recipe.localised_name = name
recipe.normal.result = name
recipe.expensive.result = name

--data:extend{miner, item, recipe}

