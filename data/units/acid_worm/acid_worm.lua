local path = util.path("data/units/acid_worm/")
local name = require("shared").units.acid_worm

local base = util.copy(data.raw.turret["big-worm-turret"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end

local hack_layer = function(layer)
  layer.animation_speed = 0.0000000000000000001
  for k, flag in pairs (layer.flags or {}) do
    if flag == "mask" then
      layer.apply_runtime_tint = true
      break
    end
  end
end

for k, layer in pairs (base.ending_attack_animation.layers) do
  hack_layer(layer)
end

local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = base.icon,
  icon_size = base.icon_size,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  max_health = 125,
  radar_range = 2,
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
  collision_box = {{-1, -1}, {1, 1}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-1, -1}, {1, 1}},
  sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = SU(30),
  move_while_shooting = true,
  can_open_gates = true,
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(90),
    cooldown_deviation = 0.5,
    range = 36,
    min_attack_distance = 28,
    projectile_creation_distance = 0.5,
    sound = base.starting_attack_sound,
    ammo_type =
    {
      category = "bullet",
      target_type = "entity",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "stream",
          stream = name.." Stream",
          }
        }
      }
    },
    animation = base.ending_attack_animation
  },
  vision_distance = 16,
  has_belt_immunity = true,
  movement_speed = SD(0.15),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = base.dying_explosion,
  working_sound = {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0 }
    },
    max_sounds_per_type = 3,
    probability = SU(1 / (3 * 60)) -- average pause between the sound is 3 seconds
  },
  dying_sound = base.dying_sound,
  run_animation = base.ending_attack_animation
}

local scale = 1.5
util.recursive_hack_make_hr(bot)
--util.recursive_hack_scale(bot, scale)
--util.scale_boxes(bot, scale)

local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
stream.name = name.." Stream"
stream.action =
{
  {
    type = "area",
    radius = 2.5,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = { amount = 3, type = "acid" }
        }
      }
    }
  }
}
stream.particle.frame_count = 8
stream.particle_buffer_size = 100
stream.particle_spawn_interval = 2
stream.particle_spawn_timeout = SU(30)
stream.particle_vertical_acceleration = 0.981 / 60
stream.particle_horizontal_speed = 0.35
stream.particle_horizontal_speed_deviation = 0.005
stream.particle_start_alpha = 1
stream.particle_end_alpha = 1
stream.particle_start_scale = 1
stream.particle_loop_frame_count = 3
stream.particle_fade_out_threshold = 1
stream.particle_loop_exit_threshold = 1
stream.particle.tint = {r = 0.5, g = 0, b = 1}
stream.spine_animation.tint = {r = 0.5, g = 0, b = 1}
stream.spine_animation = nil
stream.smoke_sources = nil
stream.target_position_deviation = 3 -- not merged


local item = {
  type = "item",
  name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = name,
  stack_size = 1
}

local recipe = {
  type = "recipe",
  name = name,
  category = require("shared").deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 4}
  },
  energy_required = 5,
  result = name
}

data:extend{bot, stream, item, recipe}