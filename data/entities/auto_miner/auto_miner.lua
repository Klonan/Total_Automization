local name = require("shared").entities.auto_miner
local path = util.path("data/entities/auto_miner")

local miner = util.copy(data.raw["mining-drill"]["electric-mining-drill"])
miner.name = name
miner.localised_name = name

util.recursive_hack_make_hr(miner)
util.recursive_hack_scale(miner, 2)
util.scale_boxes(miner, 2)
--util.recursive_hack_tint{r = 1}

miner.energy_source = {type = "void", emissions = 0.2}

miner.mining_speed = 2
miner.mining_power = 4
miner.resource_searching_radius = 3
miner.vector_to_place_result = {0.5, -1.75 * 2}
miner.order = "noob"
miner.input_fluid_box.pipe_connections = {
    { position = {-3, 0} },
    { position = {3, 0} },
    { position = {0, 3} }
}
--for k, connection in pairs (miner.input_fluid_box.pipe_connections) do
--  miner.input_fluid_box.pipe_connections[k].position = {connection.position[1] * 2, connection.position[2] * 2}
--end
--miner.input_fluid_box =
--{
--  production_type = "input-output",
--  pipe_picture = assembler2pipepictures(),
--  pipe_covers = pipecoverspictures(),
--  base_area = 1,
--   height = 2,
--  base_level = -1,
--  pipe_connections =
--  {
--    { position = {-4, 0} },
--    { position = {4, 0} },
--    { position = {0, 4} }
--  }
--}

--error(serpent.block(miner.input_fluid_box))

data:extend{miner}

