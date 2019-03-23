local path = util.path("data/units/plasma_bot/")
local name = names.units.plasma_bot

local base = util.copy(data.raw["logistic-robot"]["logistic-robot"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
--table.insert(base.idle.layers, base.shadow_idle)
--table.insert(base.in_motion.layers, base.shadow_in_motion)}
util.recursive_hack_make_hr(base)
util.recursive_hack_scale(base, 3)
local idle_mask = util.copy(base.idle_with_cargo)
idle_mask.apply_runtime_tint = true
local in_motion_mask = util.copy(base.in_motion)
in_motion_mask.apply_runtime_tint = true

local shadow_shift = {2, 4}
util.shift_layer(base.shadow_idle_with_cargo, shadow_shift)
base.shadow_idle_with_cargo.scale = (base.shadow_idle_with_cargo.scale or 1) * 0.8
util.shift_layer(base.shadow_in_motion, shadow_shift)
base.shadow_in_motion.scale = (base.shadow_in_motion.scale or 1) * 0.8

local attack_range = 32
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
  max_health = 320,
  radar_range = 3,
  order="c-d",
  subgroup = "circuit-units",
  resistances = nil,
  healing_per_tick = 0,
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
  collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
  sticker_box = {{-1.5, -1.5}, {1.5, 1.5}},
  distraction_cooldown = 15,
  move_while_shooting = true,
  can_open_gates = false,
  ai_settings =
  {
    do_separation = true
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    projectile_center = {0, 2},
    cooldown = 150,
    cooldown_deviation = 0.2,
    --lead_target_for_projectile_speed = 0.5,--tricky...
    range = attack_range,
    min_attack_distance = attack_range - 4,
    projectile_creation_distance = 0.5,
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
      category = util.ammo_category("combat-robot-beam"),
      target_type = "entity",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "projectile",
          projectile = name.." Projectile",
          starting_speed = 0.5,
          direction_deviation = 0.05,
          range_deviation = 0.05,
          max_range = attack_range + 4
          }
        }
      }
    },
    animation = {layers = {base.idle_with_cargo, base.shadow_idle_with_cargo, idle_mask}}
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = 0.15,
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,

  minable = {result = name, mining_time = 2},
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
  run_animation = {layers = {base.in_motion, base.shadow_in_motion, in_motion_mask}}
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.collision_box = nil --{{-0.25, -0.25}, {0.25, 0.25}}
projectile.direction_only = false
projectile.height = 2
projectile.max_speed = 0.75
projectile.hit_at_collision_position = true
projectile.hit_collision_mask = util.projectile_collision_mask()
projectile.action =
{
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-particle",
          entity_name = name.." Small Projectile",
          initial_height = projectile.height,
          --speed_from_center = 1
          type = "create-particle",
          repeat_count = 100,
          --entity_name = "explosion-remnants-particle",
          --initial_height = 0.5,
          speed_from_center = 0.4,
          speed_from_center_deviation = 0.2,
          initial_vertical_speed = -0.2,
          initial_vertical_speed_deviation = 0.05,
          offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
        },
        {
          type = "create-trivial-smoke",
          smoke_name = name.." smoke",
          offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
          repeat_count = 4,
          offsets =
          {
            {0, -projectile.height}
          }
        }
      }
    }
  },
  {
    type = "area",
    target_entities = true,
    trigger_from_target = false,
    repeat_count = 1,
    radius = 4,
    force = "not-same",
    ignore_collision_condition = true,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = {amount = 20 , type = util.damage_type("electric")}
        }
      }
    }
  }
}
projectile.final_action = nil
projectile.animation = util.empty_sprite()
old = {
  filename = path.."plasma_bot_projectile.png",
  line_length = 5,
  frame_count = 33,
  width = 16,
  height = 18,
  animation_speed = 3,
  scale = 2,
  blend_mode = "additive-soft"

}
projectile.acceleration = 0



projectile.smoke =
{
  {
    name = name.." big smoke",
    deviation = {0.1, 0.1},
    frequency = 2,
    position = {-0.05, 2/6},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  },
  {
    name = name.." big smoke",
    deviation = {0.2, 0.2},
    frequency = 2,
    position = {-0.1, 3/6},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  },
}

local projectile_smoke = {
  type = "trivial-smoke",
  name = name.." big smoke",
  flags = {"not-on-map"},
  animation =
  {
    filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    frame_count = 32,
    line_length = 8,
    scale = 0.8,
    animation_speed = 32 / 100,
    blend_mode = "additive",
    tint = {g = 1, b = 1}
  },
  movement_slow_down_factor = 0.95,
  duration = 16,
  fade_away_duration = 8,
  show_when_smoke_off = true
}




local small_projectile = util.copy(data.raw.particle["explosion-remnants-particle"])
small_projectile.name = name.." Small Projectile"
--small_projectile.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
small_projectile.collision_box = nil
small_projectile.direction_only = true
small_projectile.height = 0
small_projectile.max_speed = 1
small_projectile.acceleration = -0.02
small_projectile.action = nil
small_projectile.final_action = nil
small_projectile.pictures = util.empty_sprite()
small_projectile.shadows = util.empty_sprite()

small_projectile.regular_trigger_effect =
{
  {
    type = "create-trivial-smoke",
    smoke_name = name.." smoke",
    offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
    speed_from_center = 0.02
  },
  {
    type = "create-trivial-smoke",
    smoke_name = name.." smoke",
    offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
    speed_from_center = 0.02
  },
  {
    type = "create-trivial-smoke",
    smoke_name = name.." smoke",
    offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
    speed_from_center = 0.02
  },
  {
    type = "create-trivial-smoke",
    smoke_name = name.." smoke",
    offset_deviation = {{-0.1, -0.1}, {0.1, 0.1}},
    speed_from_center = 0.02
  }
}
small_projectile.regular_trigger_effect_frequency = 1
small_projectile.ended_in_water_trigger_effect = nil
small_projectile.movement_modifier_when_on_ground = 1
--util.recursive_hack_scale(small_projectile, 0.3)



small_projectile.smoke =
{
  {
    name = name.." smoke",
    deviation = {0.1, 0.1},
    frequency = 2,
    --position = {-0.05, 2/6},
    position = {0,0},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  },
  {
    name = name.." smoke",
    deviation = {0.2, 0.2},
    frequency = 2,
    --position = {-0.1, 3/6},
    position = {0,0},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  },
}

local small_projectile_smoke = {
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
    tint = {g = 1, b = 1}
  },
  movement_slow_down_factor = 0,
  duration = 32,
  fade_away_duration = 12,
  affected_by_wind = false,
  show_when_smoke_off = true,
  start_scale = 1,
  end_scale = 0
}

local animation = util.copy(small_projectile.animation)
local make_animation = function(scale)
  local data = util.copy(animation)
  data.scale = (data.scale or 1) * scale
  return data
end
local shadow = util.copy(small_projectile.shadow)
local make_shadow = function(scale)
  local data = util.copy(animation)
  data.scale = (data.scale or 1) * scale
  return data
end

--small_projectile.animation =
--{
--  make_animation(0.8),
--  make_animation(0.85),
--  make_animation(0.9),
--  make_animation(0.95),
--  make_animation(1.0),
--  make_animation(1.05),
--  make_animation(1.10),
--  make_animation(1.15),
--  make_animation(1.2)
--}
--small_projectile.shadow =
--{
--  make_shadow(0.8),
--  make_shadow(0.85),
--  make_shadow(0.9),
--  make_shadow(0.95),
--  make_shadow(1.0),
--  make_shadow(1.05),
--  make_shadow(1.10),
--  make_shadow(1.15),
--  make_shadow(1.2)
--}
--

local splash =
{
  type = "explosion",
  name = name.." Splash",
  height = 1,
  flags = {"not-on-map"},
  animations =
  {
    {
      filename = path.."plasma_bot_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 10,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = (0.35),
      blend_mode = "additive-soft",
      run_mode = "backward",
      scale = 1.5
    }
  }
}

local animation =
{
  filename = path.."plasma_bot_splash.png",
  priority = "extra-high",
  width = 92,
  height = 66,
  frame_count = 10,
  line_length = 5,
  shift = {-0.437, 0.5},
  animation_speed = (0.25),
  blend_mode = "additive-soft",
  run_mode = "backward",
  scale = 1
}
local make_animation = function(scale, speed)
  local data = util.copy(animation)
  data.scale = (data.scale or 1) * scale
  data.animation_speed = (data.animation_speed or 1) * speed
  return data
end

local small_splash =
{
  type = "explosion",
  name = name.." Small Splash",
  height = 1,
  flags = {"not-on-map"},
  animations =
  {
    make_animation(1, 0.75),
    make_animation(0.9, 0.8),
    make_animation(0.8, 0.85),
    make_animation(0.7, 0.9),
    make_animation(0.6, 0.95),
    make_animation(0.5, 1),
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
  order = "e-"..name,
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
    {"processing-unit", 2},
    {"battery", 20},
    {"copper-cable", 20},
    {"copper-plate", 10}
  },
  energy_required = 75,
  result = name
}

data:extend
{
  bot,
  projectile,
  projectile_smoke,
  splash,
  item,
  recipe,
  small_projectile,
  small_splash,
  small_projectile_smoke
}