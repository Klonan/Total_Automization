

afterburn = util.copy(data.raw.sticker["fire-sticker"])
afterburn.name = "Afterburn Sticker"

afterburn.duration_in_ticks = SU(6 * 60)
afterburn.target_movement_modifier = 1
afterburn.damage_per_tick = { amount = SD(10 / 60), type = util.damage_type("afterburn") }
afterburn.spread_fire_entity = "fire-flame-on-tree"
afterburn.fire_spread_cooldown = SU(30)
afterburn.fire_spread_radius = 0.75
afterburn.animation.scale = 0.5
afterburn.animation.animation_speed = SD(afterburn.animation.animation_speed)

data:extend{afterburn}