local name = names.entities.damage_indicator_text
local damage_indicator_text =
{
  type = "flying-text",
  name = name,
  localised_name = name,
  flags = {"not-on-map", "placeable-off-grid"},
  time_to_live = SU(30),
  speed = SD(0.06),
  text_alignment = "center"
}

data:extend{damage_indicator_text}