local speed = settings.startup["game-speed"].value
SU = function(v)
  return v * speed
end
SD = function(v)
  return v / speed
end
SA = function(v)
  return v / (speed ^ 2)
end
util = require "data/tf_util/tf_util"
names = require("shared")
require "data/entities/entities"
--require "data/health_pickup"
require "data/stickers/afterburn"
require "data/stickers/healing"
require "data/hotkeys"
require "data/unit_control/unit_control"
require "data/units/units"
require "data/items/items"
--require "data/soundtrack/soundtrack"
--require "data/changes/changes"

--for name, font in pairs (data.raw.font) do
--  font.size = font.size * 1.33
--end
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

