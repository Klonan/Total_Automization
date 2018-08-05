local path = util.path("data/units/tazer_bot/")
local name = require("shared").units.tazer_bot
local base = util.copy(data.raw["combat-robot"]["distractor"])
table.insert(base.idle.layers, base.shadow_idle)
table.insert(base.in_motion.layers, base.shadow_in_motion)
local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = "__base__/graphics/icons/distractor.png",
  icon_size = 32,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  max_health = 120,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = 8 * 60,
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  sticker_box = {{-0.5, -0.5}, {0.5, 0.5}},
  distraction_cooldown = SU(15),
  move_while_shooting = true,
  can_open_gates = true,
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "beam",
    ammo_category = "bullet",
    cooldown = SU(150),
    cooldown_deviation = 0.15,
    range = 20,
    min_attack_distance = 16,
    ammo_type =
    {
      category = "bullet",
      action =
      {
        force = "not-same",
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = name.." Beam",
          add_to_shooter = false,
          max_length = 30,
          duration = SU(45),
          source_offset = {0, 0.5},
        }
      }
    },
    animation = base.idle
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.22),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  corpse = name.." Corpse",
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
    probability = SU(1 / (3 * 60)) -- average pause between the sound is 3 seconds
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
util.recursive_hack_make_hr(bot)
util.recursive_hack_scale(bot, 2)
util.scale_boxes(bot, 2)

local corpse =
{
  type = "corpse",
  name = name.." Corpse",
  icon = "__base__/graphics/icons/medium-biter-corpse.png",
  icon_size = 32,
  selectable_in_game = false,
  selection_box = {{-1, -1}, {1, 1}},
  flags = {"placeable-neutral", "placeable-off-grid", "building-direction-8-way", "not-on-map"},
  subgroup="corpses",
  order = "c[corpse]-a[biter]-b[medium]",
  dying_speed = 0.04,
  time_before_removed = 2 * 60 * 60,
  final_render_layer = "corpse",
  animation = {
    layers =
    {
      {
        filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
        width = 1,
        height = 1,
        frame_count = 16,
        direction_count = 16,
        --shift = {scale * 0.546875, scale * 0.21875},
        priority = "very-low",
        --scale = scale,
        
      }
    }
  }
}

local beam = util.copy(data.raw.beam["electric-beam"])

beam.name = name.." Beam"
beam.localised_name = name.." Beam"
beam.damage_interval = SU(15)
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
        damage = { amount = 10, type = "electric"}
      },
      {
        type = "nested-result",
        affects_target = true,
        action =
        {
          type = "area",
          radius = 2,
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-sticker",
                sticker = name.." Sticker"
              }
            }
          }
        }
      }
    }
  }
}

local sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = name.." Sticker"

sticker.duration_in_ticks = SU(2 * 60)
sticker.target_movement_modifier = 0.66
sticker.damage_per_tick = {type = "electric", amount = SD(0.25)}
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation = 
{
  filename = path.."tazer_bot_sticker.png",
  width = 37,
  height = 35,
  frame_count = 16,
  animation_speed = SD(1)
}
sticker.stickers_per_square_meter = 15

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "c-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = require("shared").deployers.circuit_unit,
  enabled = true,
  ingredients =
  {
    {"battery", 8},
    {"copper-cable", 20}
  },
  energy_required = 25,
  result = name
}

data:extend{
  bot,
  beam,
  sticker,
  corpse,
  item,
  recipe
}