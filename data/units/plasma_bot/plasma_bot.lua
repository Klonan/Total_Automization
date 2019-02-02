local path = util.path("data/units/plasma_bot/")
local name = names.units.plasma_bot

local base = util.copy(data.raw["logistic-robot"]["logistic-robot"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
--table.insert(base.idle.layers, base.shadow_idle)
--table.insert(base.in_motion.layers, base.shadow_in_motion)}
local idle_mask = util.copy(base.idle_with_cargo.hr_version)
idle_mask.apply_runtime_tint = true
local in_motion_mask = util.copy(base.in_motion.hr_version)
in_motion_mask.apply_runtime_tint = true
local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = base.icon,
  icon_size = base.icon_size,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 180,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
  collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
  sticker_box = {{-1.5, -1.5}, {1.5, 1.5}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  ai_settings =
  {
    do_separation = true
  },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(150),
    cooldown_deviation = 0.2,
    range = 56,
    min_attack_distance = 46,
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
      category = util.ammo_category(name),
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "projectile",
          projectile = name.." Projectile",
          starting_speed = SD(-0.2),
          direction_deviation = 0.05,
          range_deviation = 0.05,
          max_range = 60
          }
        }
      }
    },
    animation = {layers = {base.idle_with_cargo, base.shadow_idle_with_cargo, idle_mask}}
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.15),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,

  minable = {result = name, mining_time = 2},
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
  working_sound = {
    sound =
    {
      { filename = "__base__/sound/flying-robot-1.ogg", volume = 0 }
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
  run_animation = {layers = {base.in_motion, base.shadow_in_motion, in_motion_mask}}
}
util.recursive_hack_make_hr(bot)
util.recursive_hack_scale(bot, 3)

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
projectile.direction_only = true
projectile.height = 0.5
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
          type = "create-entity",
          entity_name = name.." Splash"
        }
      }
    }
  },
  {
    type = "area",
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 100,
    radius = 1,
    action_delivery =
    {
      type = "projectile",
      projectile = name.." Small Projectile",
      starting_speed = SD(0.35),
      starting_speed_deviation = SD(0.35),
    }
  }
}
projectile.final_action = nil
--[[{
  type = "area",
  radius = 2.5,
  force = "not-same",
  collision_mode = "distance-from-center",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = name.." Splash"
      },
      {
        type = "damage",
        damage = {amount = 30 , type = util.damage_type("plasma_bot")}
      },
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/creatures/projectile-acid-burn-1.ogg",
            volume = 0.8
          },
          {
            filename = "__base__/sound/creatures/projectile-acid-burn-2.ogg",
            volume = 0.8
          },
          {
            filename = "__base__/sound/creatures/projectile-acid-burn-long-1.ogg",
            volume = 0.8
          },
          {
            filename = "__base__/sound/creatures/projectile-acid-burn-long-2.ogg",
            volume = 0.8
          }
        }
      },
    }
  }
}]]
projectile.animation =
{
  filename = path.."plasma_bot_projectile.png",
  line_length = 5,
  frame_count = 33,
  width = 16,
  height = 18,
  animation_speed = 3,
  scale = 2,
  blend_mode = "additive-soft"

}
--projectile.animation.filename = path.."plasma_bot_projectile.png"
--projectile.animation.blend_mode =
--projectile.animation.animation_speed = 3
--projectile.animation.scale = 2
projectile.acceleration = 0.02


local small_projectile = util.copy(projectile)
small_projectile.name = name.." Small Projectile"
small_projectile.force_condition = "not-same"
--small_projectile.collision_box = {{-0.15, -0.15}, {0.15, 0.15}}
small_projectile.collision_box = nil
small_projectile.direction_only = true
small_projectile.height = 0
small_projectile.max_speed = 1
small_projectile.acceleration = -0.02
small_projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = name.." Small Splash"
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 1,
          ignore_collision_condition = true,
          --collision_mode = "distance-from-center",
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 1 , type = util.damage_type(name)}
              }
            }
          }
        }
      }
    }
  }
}
small_projectile.final_action = nil
util.recursive_hack_scale(small_projectile, 0.5)

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

small_projectile.animation =
{
  make_animation(0.8),
  make_animation(0.85),
  make_animation(0.9),
  make_animation(0.95),
  make_animation(1.0),
  make_animation(1.05),
  make_animation(1.10),
  make_animation(1.15),
  make_animation(1.2)
}
small_projectile.shadow =
{
  make_shadow(0.8),
  make_shadow(0.85),
  make_shadow(0.9),
  make_shadow(0.95),
  make_shadow(1.0),
  make_shadow(1.05),
  make_shadow(1.10),
  make_shadow(1.15),
  make_shadow(1.2)
}


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
      animation_speed = SD(0.35),
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
  animation_speed = SD(0.25),
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
  localised_name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "e-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
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

data:extend{bot, projectile, splash, item, recipe, small_projectile, small_splash}