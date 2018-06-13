local path = util.path("data/stickers/")
sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = "Healing Sticker"

sticker.duration_in_ticks = SU(1 * 60)
sticker.target_movement_modifier = 1
sticker.damage_per_tick = nil
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation = 
{
  filename = path.."healing.png",
  height = 825,
  width = 825,
  frame_count = 1,
  scale = 0.03
}
sticker.stickers_per_square_meter = 1

data:extend{sticker}