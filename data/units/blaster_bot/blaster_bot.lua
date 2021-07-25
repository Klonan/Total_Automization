local path = util.path("data/units/smg_guy")
local name = names.units.blaster_bot


local base = util.copy(data.raw["combat-robot"]["defender"])
util.recursive_hack_make_hr(base)
util.recursive_hack_scale(base, 1.5)
table.insert(base.idle.layers, base.shadow_idle)
table.insert(base.in_motion.layers, base.shadow_in_motion)

local sprite_shift = {0, 0}
for k, layer in pairs (base.idle.layers) do
  util.shift_layer(layer, sprite_shift)
end
for k, layer in pairs (base.in_motion.layers) do
  util.shift_layer(layer, sprite_shift)
end

local shadow_shift = {2, 4}
util.shift_layer(base.shadow_in_motion, shadow_shift)
base.shadow_in_motion.scale = (base.shadow_in_motion.scale or 1) * 0.8
util.shift_layer(base.shadow_idle, shadow_shift)
base.shadow_idle.scale = (base.shadow_idle.scale or 1) * 0.8

local attack_range = 14
local bot =
{
  type = "unit",
  name = name,
  localised_name = {name},
  icon = base.icon,
  icon_size = base.icon_size,
  flags = util.unit_flags(),
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 85,
  radar_range = 1,
  order="c-a",
  subgroup = "circuit-units",
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  sticker_box = {{-0.3, -0.3}, {0.3, 0.3}},
  distraction_cooldown = 15,
  move_while_shooting = true,
  can_open_gates = false,
  ai_settings =
  {
    do_separation = true
  },
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = 45,
    cooldown_deviation = 0.5,
    range = attack_range,
    min_attack_distance = attack_range - 2,
    projectile_creation_distance = 1,
    --lead_target_for_projectile_speed = 0.8,
    projectile_center = {0, 1.2},
    sound =
    {
      {
        filename = "__base__/sound/fight/laser-1.ogg",
        volume = 0.5
      },
      {
        filename = "__base__/sound/fight/laser-2.ogg",
        volume = 0.5
      },
      {
        filename = "__base__/sound/fight/laser-3.ogg",
        volume = 0.5
      }
    },
    ammo_type =
    {
      category = util.ammo_category("circuit-units"),
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "projectile",
          projectile = name.." Projectile",
          starting_speed = 0.4,
          --direction_deviation = 0.05,
          --range_deviation = 0.05,
          max_range = attack_range + 4
          }
        }
      }
    },
    animation = base.idle
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = 0.15,
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
  working_sound = {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0 }
    },
    max_sounds_per_type = 3,
    probability = (1 / (3 * 60)) -- average pause between the sound is 3 seconds
  },
  run_animation = base.in_motion
}

local projectile = util.copy(data.raw.projectile["laser"])
projectile.name = name.." Projectile"
projectile.collision_box = nil
projectile.direction_only = false
projectile.acceleration = 0
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
        damage = {amount = 8 , type = util.damage_type("laser")}
      }
    }
  }
}
projectile.animation = util.empty_sprite()
projectile.final_action = nil
projectile.smoke =
{
  {
    name = name.." smoke",
    frequency = 2,
    position = {0, 0},
    slow_down_factor = 1
  },
  {
    name = name.." smoke",
    frequency = 2,
    position = {0, 0.05},
    slow_down_factor = 1
  },
  {
    name = name.." smoke",
    frequency = 2,
    position = {0, 0.15},
    slow_down_factor = 1
  },
  {
    name = name.." smoke",
    frequency = 2,
    position = {0, 0.25},
    slow_down_factor = 1
  },
  {
    name = name.." smoke",
    frequency = 2,
    position = {0, 0.35},
    slow_down_factor = 1
  }
}

local blaster_smoke = {
  type = "trivial-smoke",
  name = name.." smoke",
  flags = {"not-on-map"},
  animation =
  {
    filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    frame_count = 32,
    line_length = 8,
    scale = 0.1,
    animation_speed = 32 / 100,
    blend_mode = "additive",
    tint = {b = 1, g = 1}
  },
  movement_slow_down_factor = 0.95,
  duration = 12,
  fade_away_duration = 12,
  affected_by_wind = false,
  show_when_smoke_off = true
}


local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "b-"..name,
  stack_size = 10,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = {name},
  category = names.deployers.circuit_unit,
  enabled = false,
  ingredients =
  {
    {"electronic-circuit", 8},
    {"copper-cable", 15},
    {"copper-plate", 5}
  },
  energy_required = 20,
  result = name
}

data:extend
{
  bot,
  projectile,
  blaster_smoke,
  item,
  recipe
}