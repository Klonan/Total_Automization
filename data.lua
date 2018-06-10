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
--[[
local slot = data.raw["gui-style"].default.slot_button
slot.width = 64
slot.height = 64
]]

local style = data.raw["gui-style"].default


style.working_weapon_button.height = 96 + 4
style.working_weapon_button.width = 96 + 4
style.not_working_weapon_button.height = 96 + 4
style.not_working_weapon_button.width = 96 + 4