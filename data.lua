util = require "data/tf_util/tf_util"
names = require("shared")
require "data/units/units"
require "data/entities/entities"
require "data/variety_explosions"

data.raw.player.player.collision_mask = util.ground_unit_collision_mask()

-- The base game acid splashes are OP.
-- Just turn off the damage and sticker on ground effect.

for k, fire in pairs (data.raw.fire) do
  if fire.name:find("acid%-splash%-fire") then
    fire.on_damage_tick_effect = nil
  end
end
