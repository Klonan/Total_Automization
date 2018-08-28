local hotkeys = names.hotkeys
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

local become_an_hero =
{
  type = "custom-input",
  name = hotkeys.suicide,
  localised_names = hotkeys.suicide,
  key_sequence = "DELETE",
  consuming = "game-only"
}
data:extend{change_class, move_unit, become_an_hero}