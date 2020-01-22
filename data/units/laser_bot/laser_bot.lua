local path = util.path("data/units/smg_guy")
local name = names.units.laser_bot

local base = util.copy(data.raw["combat-robot"]["destroyer"])
util.recursive_hack_make_hr(base)
util.recursive_hack_scale(base, 2)
table.insert(base.idle.layers, base.shadow_idle)
table.insert(base.in_motion.layers, base.shadow_in_motion)

local sprite_shift = {0, 1}
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

local attack_range = 18
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
  max_health = 160,
  radar_range = 2,
  order= "c-c",
  subgroup = "circuit-units",
  resistances = nil,
  healing_per_tick = 0,
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = (60 * 15),
  selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
  collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
  sticker_box = {{-0.8, -0.8}, {0.8, 0.8}},
  distraction_cooldown = (15),
  move_while_shooting = false,
  can_open_gates = false,
  ai_settings =
  {
    do_separation = true
  },
  minable = {result = name, mining_time = 2},

  attack_parameters =
  {
    type = "beam",
    cooldown = (100),
    cooldown_deviation = 0.15,
    range = attack_range,
    min_attack_distance = attack_range - 3,
    --projectile_center = {-0.09375, -0.2},
    projectile_creation_distance = 1.4,
    source_direction_count = 8,
    --source_offset = {0, -0.1},
    ammo_type =
    {
      category = util.ammo_category("circuit-units"),
      energy_consumption = "800kJ",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = name.." Beam",
          max_length = attack_range + 3,
          duration = (40),
          --source_offset = {0.15, -0.5},
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
  destroy_when_commands_fail = false,
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
  dying_sound =
  {
    {
      filename = "__base__/sound/fight/small-explosion-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/small-explosion-2.ogg",
      volume = 0.5
    }
  },
  run_animation = base.in_motion
}

local beam = util.copy(data.raw.beam["laser-beam"])
beam.name = name.." Beam"
beam.damage_interval = (20)
beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = 12, type = util.damage_type("laser")}
      }
    }
  }
}

local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "d-"..name,
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
    {"advanced-circuit", 8},
    {"copper-plate", 20},
    {"copper-cable", 20}
  },
  energy_required = 35,
  result = name
}

data:extend{bot, beam, item, recipe}