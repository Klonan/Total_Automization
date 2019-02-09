tf_require = function(path)
  local new = path:gsub("/", ".")
  return require(new)
end
--local speed = settings.startup["game-speed"].value
SU = function(v)
  return v --* speed
end
SD = function(v)
  return v --/ speed
end
SA = function(v)
  return v --/ (speed ^ 2)
end
util = tf_require "data/tf_util/tf_util"
names = tf_require("shared")
tf_require "data/entities/entities"
--tf_require "data/health_pickup"
tf_require "data/stickers/afterburn"
tf_require "data/stickers/healing"
tf_require "data/hotkeys"
tf_require "data/unit_control/unit_control"
tf_require "data/units/units"
tf_require "data/items/items"
--tf_require "data/soundtrack/soundtrack"
--tf_require "data/changes/changes"

--for name, font in pairs (data.raw.font) do
--  font.size = font.size * 1.33
--end
--[[
local slot = data.raw["gui-style"].default.slot_button
slot.width = 64
slot.height = 64
]]
if true then return end
local style = data.raw["gui-style"].default
style.working_weapon_button.height = 96 + 4
style.working_weapon_button.width = 96 + 4
style.not_working_weapon_button.height = 96 + 4
style.not_working_weapon_button.width = 96 + 4
