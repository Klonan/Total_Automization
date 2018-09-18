local name = names.ammo.incendiary_shells
local ammo = util.copy(data.raw.ammo["piercing-shotgun-shell"])
ammo.name = name
ammo.localised_name = name
--ammo.icon = path.."shotgun_ammo.png"
--ammo.icon_size = 256
ammo.reload_time = SU(210 - 37.5)
ammo.magazine_size = 6
ammo.stack_size = 10
ammo.ammo_type =
{
  category = util.ammo_category("shotgun"),
  target_type = "direction",
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    {
      type = "direct",
      repeat_count = 10,
      action_delivery =
      {
        type = "projectile",
        projectile = name,
        starting_speed = SD(1),
        starting_speed_deviation = SD(0.2),
        direction_deviation = 0.4,
        range_deviation = 0.1,
        max_range = 35
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name
projectile.force_condition = "not-same"
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 5 , type = util.damage_type("shotgun")}
      },
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      },
      {
        type = "create-sticker",
        sticker = name.." Sticker"
      },
      {
        type = "create-fire",
        entity_name = name.." Fire"
      }
    }
  }
}
projectile.acceleration = 0


local sticker = util.copy(data.raw.sticker["fire-sticker"])
local total = 25
sticker.name = name.." Sticker"
sticker.duration_in_ticks = SU(3 * 60)
sticker.target_movement_modifier = 1
sticker.damage_per_tick = { amount = total / sticker.duration_in_ticks, type = util.damage_type("shotgun") }
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = nil
sticker.fire_spread_radius = nil
sticker.animation.scale = 0.5
sticker.stickers_per_square_meter = 15

local fire = util.copy(data.raw.fire["fire-flame"])
fire.name = name.." Fire"
fire.damage_per_tick = { amount = 1 / 60, type = util.damage_type("shotgun") }
fire.maximum_damage_multiplier = 1
fire.spread_delay = SU(180)
fire.spread_delay_deviation = SU(180)
fire.emissions_per_tick = SD(0.005)
fire.maximum_lifetime = SU(1800)
fire.initial_lifetime = SU(300)
fire.lifetime_increase_by = SU(150)
fire.delay_between_initial_flames = SU(10)
fire.lifetime_increase_cooldown = SU(4)

data:extend{ammo, projectile, sticker, fire}