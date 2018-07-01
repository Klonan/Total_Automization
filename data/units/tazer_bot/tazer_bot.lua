local path = util.path("data/units/tazer_bot/")
local name = require("shared").unit_names.tazer_bot
local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = "__base__/graphics/icons/defender.png",
  icon_size = 32,
  flags = {},
  max_health = 125,
  radar_range = 1,
  order="b-b-b",
  subgroup="enemies",
  resistances =
  {
    {
      type = "physical",
      decrease = 4,
    }
  },
  healing_per_tick = 0,
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.1, -0.1}, {0.1, 0.1}},
  distraction_cooldown = 300,
  
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(150),
    projectile_center = {0, 1},
    projectile_creation_distance = 0.6,
    range = 12,
    min_attack_distance = 8,
    sound = make_light_gunshot_sounds(),
    ammo_type =
    {
      category = "bullet",
      action =
      {
        force = "enemy",
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = name.." Beam",
          add_to_shooter = false,
          max_length = 30,
          duration = SU(45),
          source_offset = {0, -0.5},
        }
      }
    },
    animation =
    {   
      layers =
      {
        {
          filename = "__base__/graphics/entity/distractor-robot/distractor-robot.png",
          priority = "high",
          line_length = 16,
          width = 38,
          height = 33,
          frame_count = 1,
          direction_count = 16,
          shift = {0, -0.078125},
          hr_version =
          {
            filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot.png",
            priority = "high",
            line_length = 16,
            width = 72,
            height = 62,
            frame_count = 1,
            direction_count = 16,
            shift = util.by_pixel(0, -2.5),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/distractor-robot/distractor-robot-mask.png",
          priority = "high",
          line_length = 16,
          width = 24,
          height = 21,
          frame_count = 1,
          direction_count = 16,
          shift = {0, -0.203125},
          apply_runtime_tint = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-mask.png",
            priority = "high",
            line_length = 16,
            width = 42,
            height = 37,
            frame_count = 1,
            direction_count = 16,
            shift = util.by_pixel(0, -6.25),
            apply_runtime_tint = true,
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/distractor-robot/distractor-robot-shadow.png",
          priority = "high",
          line_length = 16,
          width = 40,
          height = 25,
          frame_count = 1,
          direction_count = 16,
          shift = {0.9375, 0.609375},
          hr_version =
          {
            filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-shadow.png",
            priority = "high",
            line_length = 16,
            width = 97,
            height = 59,
            frame_count = 1,
            direction_count = 16,
            shift = util.by_pixel(32.5, 19.25),
            scale = 0.5
          }
        }
      }
    }
  },
  vision_distance = 25,
  movement_speed = SD(0.2),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
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
  run_animation = 
  {
    layers =
    {
      {
        filename = "__base__/graphics/entity/distractor-robot/distractor-robot.png",
        priority = "high",
        line_length = 16,
        width = 38,
        height = 33,
        frame_count = 1,
        direction_count = 16,
        shift = {0, -0.078125},
        y = 33,
        hr_version =
        {
          filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot.png",
          priority = "high",
          line_length = 16,
          width = 72,
          height = 62,
          frame_count = 1,
          direction_count = 16,
          shift = util.by_pixel(0, -2.5),
          y = 62,
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/distractor-robot/distractor-robot-mask.png",
        priority = "high",
        line_length = 16,
        width = 24,
        height = 21,
        frame_count = 1,
        direction_count = 16,
        shift = {0, -0.203125},
        apply_runtime_tint = true,
        y = 21,
        hr_version =
        {
          filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-mask.png",
          priority = "high",
          line_length = 16,
          width = 42,
          height = 37,
          frame_count = 1,
          direction_count = 16,
          shift = util.by_pixel(0, -6.25),
          apply_runtime_tint = true,
          y = 37,
          scale = 0.5
        }
      },
      {
        filename = "__base__/graphics/entity/distractor-robot/distractor-robot-shadow.png",
        priority = "high",
        line_length = 16,
        width = 40,
        height = 25,
        frame_count = 1,
        direction_count = 16,
        shift = {0.9375, 0.609375},
        hr_version =
        {
          filename = "__base__/graphics/entity/distractor-robot/hr-distractor-robot-shadow.png",
          priority = "high",
          line_length = 16,
          width = 97,
          height = 59,
          frame_count = 1,
          direction_count = 16,
          shift = util.by_pixel(32.5, 19.25),
          scale = 0.5
        }
      }
    }
  }
}
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
        type = "create-sticker",
        sticker = name.." Sticker"
      }
    }
  }
}

local sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = name.." Sticker"

sticker.duration_in_ticks = SU(1 * 60)
sticker.target_movement_modifier = 0.75
sticker.damage_per_tick = {type = "electric", amount = 0.1}
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation = 
{
  filename = path.."tazer_bot_sticker.png",
  width = 37,
  height = 35,
  frame_count = 16
}
sticker.stickers_per_square_meter = 15



data:extend{
  bot,
  beam,
  sticker,
  corpse
}