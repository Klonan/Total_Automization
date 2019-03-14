util = require "data/tf_util/tf_util"
names = require("shared")
require "data/units/units"
require "data/entities/entities"
require "data/variety_explosions"

data.raw.player.player.collision_mask = util.ground_unit_collision_mask()
