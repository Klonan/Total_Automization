local path = util.path("data/units/tazer_bot/")
local name = names.units.tazer_bot

local base = util.copy(data.raw["combat-robot"]["distractor"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
util.recursive_hack_make_hr(base)
util.recursive_hack_scale(base, 2)
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
  icon = "__base__/graphics/icons/distractor.png",
  icon_size = 64,
  flags = util.unit_flags(),
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 220,
  radar_range = 2,
  order="b-b-b",
  subgroup = "circuit-units",
  resistances = nil,
  healing_per_tick = 0,
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-0.8, -0.8}, {0.8, 0.8}},
  collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
  sticker_box = {{-0.8, -0.8}, {0.8, 0.8}},
  distraction_cooldown = (15),
  move_while_shooting = true,
  can_open_gates = false,
  minable = {result = name, mining_time = 2},
  ai_settings =
  {
    do_separation = true
  },
  attack_parameters =
  {
    type = "beam",
    warmup = 30,
    cooldown = (40),
    cooldown_deviation = 0.2,
    range = attack_range,
    min_attack_distance = attack_range - 3,
    ammo_type =
    {
      category = util.ammo_category("circuit-units"),
      action =
      {
        force = "not-same",
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = name.." Beam",
          add_to_shooter = false,
          max_length = attack_range  + 3,
          duration = (45),
          source_offset = {0, 0.5},
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
  dying_explosion = "explosion",
  working_sound = {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-2.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-3.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-4.ogg", volume = 0.6 },
      { filename = "__base__/sound/flying-robot-5.ogg", volume = 0.6 }
    },
    max_sounds_per_type = 3,
    probability = (1 / (3 * 60)) -- average pause between the sound is 3 seconds
  },
  run_animation = base.in_motion
}

local beam = util.copy(data.raw.beam["electric-beam"])

beam.name = name.." Beam"
beam.localised_name = name.." Beam"
beam.damage_interval = (45)
--beam.random_target_offset = true
beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 2.5,
          force = "not-same",
          trigger_from_target = true,
          action_delivery =
          {
            type = "beam",
            beam = name.." Small Beam",
            add_to_shooter = false,
            max_length = 30,
            duration = (45),
            source_offset = {0, 0.5},
          }
        }
      },
      {
        type = "damage",
        damage = { amount = 15, type = util.damage_type("electric")}
      },
      {
        type = "create-sticker",
        sticker = name.." Sticker"
      },
    }
  }
}


local small_beam = util.copy(beam)

small_beam.name = name.." Small Beam"
small_beam.localised_name = name.." Small Beam"
small_beam.damage_interval = (45)
small_beam.random_target_offset = true
small_beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = 10, type = util.damage_type("electric")}
      },
      {
        type = "create-sticker",
        sticker = name.." Sticker"
      }
    }
  }
}

local sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = name.." Sticker"

sticker.duration_in_ticks = (2 * 60)
sticker.target_movement_modifier = 0.66
sticker.damage_per_tick = {type = "electric", amount = 0}--(0.25)}
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation =
{
  filename = path.."tazer_bot_sticker.png",
  width = 37,
  height = 35,
  frame_count = 16,
  animation_speed = (1)
}
sticker.stickers_per_square_meter = 8

local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "c-"..name,
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
    {"battery", 10},
    {"electronic-circuit", 10},
    {"copper-cable", 20}
  },
  energy_required = 25,
  result = name
}

data:extend{
  bot,
  beam,
  sticker,
  item,
  recipe,
  small_beam
}