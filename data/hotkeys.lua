local hotkeys = require("shared").hotkeys
local change_class =
{
  type = "custom-input",
  name = hotkeys.change_class,
  localised_names = hotkeys.change_class,
  key_sequence = "N",
  consuming = "none"
}

local move_unit =
{
  type = "custom-input",
  name = hotkeys.unit_move,
  localised_names = hotkeys.unit_move,
  key_sequence = "SHIFT + A",
  consuming = "game-only"
}
data:extend{change_class, move_unit}