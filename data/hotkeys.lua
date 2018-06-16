local hotkey_names = require("shared").hotkey_names
local change_class =
{
  type = "custom-input",
  name = hotkey_names.change_class,
  localised_names = hotkey_names.change_class,
  key_sequence = "N",
  consuming = "none"
}
data:extend{change_class}