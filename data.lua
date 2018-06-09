SU = function(v)
  return v * settings.startup["game-speed"].value
end
SD = function(v)
  return v / settings.startup["game-speed"].value
end
util = require "data/tf_util"
require "data/classes"
require "data/health_pickup"
require "data/teleporters/teleporters"

for name, font in pairs (data.raw.font) do
  font.size = font.size * 1.33
end