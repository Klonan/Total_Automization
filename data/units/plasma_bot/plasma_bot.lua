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
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  selection_box = {{-2.0, -2.0}, {2.0, 2.0}},
  collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
  sticker_box = {{-1.5, -1.5}, {1.5, 1.5}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(150),
    cooldown_deviation = 0.2,
    range = 40,
    min_attack_distance = 32,
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
      category = "bullet",
      target_type = "direction",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "projectile",
          projectile = name.." Projectile",
          starting_speed = SD(0),
          direction_deviation = 0.05,
          range_deviation = 0.05,
          max_range = 40
          }
        }
      }
    },
    animation = {layers = {base.idle_with_cargo, base.shadow_idle_with_cargo, idle_mask}}
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.22),
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

local projectile = util.copy(data.raw.projectile["acid-projectile-purple"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.collision_box = {{-0.25, -0.25}, {0.25, 0.25}}
projectile.direction_only = true
projectile.height = 0.5
projectile.action =
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
}
projectile.final_action = 
{
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
}
projectile.animation.filename = path.."plasma_bot_projectile.png"
projectile.animation.blend_mode = "additive-soft"
projectile.animation.animation_speed = SD(3)
projectile.acceleration = SA(0.02)
util.recursive_hack_scale(projectile, 2)

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
  enabled = true,
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

data:extend{bot, projectile, splash, item, recipe}