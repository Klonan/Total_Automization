local path = util.path("data/units/scatter_spitter/")
local name = names.units.scatter_spitter

local unit = util.copy(data.raw.unit["big-spitter"])
unit.name = name
unit.localised_name = name
unit.collision_mask = {"not-colliding-with-itself", "player-layer"}
unit.can_open_gates = true
unit.destroy_when_commands_fail = false
unit.radar_range = 2
unit.movement_speed = SD(0.2)
unit.max_pursue_distance = 64
unit.min_persue_time = 8 * 60
unit.map_color = {b = 0.5, g = 1}
unit.enemy_map_color = {r = 1}
unit.max_health = 100
unit.collision_box = {{-1, -1},{1, 1}}
unit.selection_box = {{-1.2, -1.2},{1.2, 1.2}}
unit.sticker_box = {{-1, -1},{1, 1}}
unit.dying_explosion = nil
unit.corpse = nil
unit.has_belt_immunity = true
unit.minable = {result = name, mining_time = 2}
unit.healing_per_tick = SD(1/60)
local animation = util.copy(unit.attack_parameters.animation)
for k, layer in pairs (animation.layers) do
  layer.animation_speed = SD(layer.animation_speed or 1)
end
local sound = util.copy(unit.attack_parameters.sound)
animation.layers[2].apply_runtime_tint = true
unit.run_animation.layers[2].apply_runtime_tint = true
unit.attack_parameters = 
{
  animation = animation,
  sound = sound,
  type = "projectile",
  ammo_category = "rocket",
  cooldown = SU(60),
  cooldown_deviation = 0.2,
  range = 20,
  min_attack_distance = 16,
  projectile_creation_distance = 1.9,
  warmup = SU(30),
  ammo_type =
  {
    category = "biological",
    target_type = "entity",
    action = 
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
              target_entities = false,
              trigger_from_target = false,
              repeat_count = 15,
              radius = 3,
              action_delivery =
              {
                type = "projectile",
                projectile = name.." Projectile",
                starting_speed = 1,
                starting_speed_deviation = 0.2,
              }
            }
          }
        }
      }
    }
  },
}

local projectile = util.copy(data.raw.projectile["acid-projectile-purple"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.direction_only = true
projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
projectile.acceleration = SA(-0.02)
projectile.rotatable = true
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
      {
        type = "damage",
        damage = {amount = 3, type = "acid"}
      },
      {
        type = "create-sticker",
        sticker = name.." Sticker"
      }
    }
  }
}

projectile.animation =
{
  {
    filename = path.."scatter_spitter_projectile.png",
    line_length = 4,
    width = 46,
    height = 82,
    frame_count = 16,
    priority = "high",
    scale = 0.25,
    animation_speed = 0.8
  },
  {
    filename = path.."scatter_spitter_projectile.png",
    line_length = 4,
    width = 46,
    height = 82,
    frame_count = 16,
    priority = "high",
    scale = 0.3,
    animation_speed = 1
  },
  {
    filename = path.."scatter_spitter_projectile.png",
    line_length = 4,
    width = 46,
    height = 82,
    frame_count = 16,
    priority = "high",
    scale = 0.2,
    animation_speed = 1.1
  },
  {
    filename = path.."scatter_spitter_projectile.png",
    line_length = 4,
    width = 46,
    height = 82,
    frame_count = 16,
    priority = "high",
    scale = 0.15,
    animation_speed = 1.2
  },
}
projectile.shadow =
{
  {
    filename = path.."scatter_spitter_projectile_shadow.png",
    line_length = 4,
    width = 94,
    height = 170,
    frame_count = 16,
    priority = "high",
    shift = {-0.09, 0.395},
    draw_as_shadow = true,
    scale = 0.25,
    animation_speed = 0.8
  },
  {
    filename = path.."scatter_spitter_projectile_shadow.png",
    line_length = 4,
    width = 94,
    height = 170,
    frame_count = 16,
    priority = "high",
    shift = {-0.09, 0.395},
    draw_as_shadow = true,
    scale = 0.3,
    animation_speed = 1
  },
  {
    filename = path.."scatter_spitter_projectile_shadow.png",
    line_length = 4,
    width = 94,
    height = 170,
    frame_count = 16,
    priority = "high",
    shift = {-0.09, 0.395},
    draw_as_shadow = true,
    scale = 0.2,
    animation_speed = 1.1
  },
  {
    filename = path.."scatter_spitter_projectile_shadow.png",
    line_length = 4,
    width = 94,
    height = 170,
    frame_count = 16,
    priority = "high",
    shift = {-0.09, 0.395},
    draw_as_shadow = true,
    scale = 0.15,
    animation_speed = 1.2
  },
}

local sticker = util.copy(data.raw.sticker["slowdown-sticker"])
sticker.name = name.." Sticker"

sticker.duration_in_ticks = SU(1 * 60)
sticker.target_movement_modifier = 1
sticker.damage_per_tick = {type = "acid", amount = SD(1)}
sticker.stickers_per_square_meter = 15
sticker.animation = 
{
  filename = path.."scatter_spitter_splash.png",
  priority = "extra-high",
  width = 92,
  height = 66,
  frame_count = 5,
  line_length = 5,
  shift = {-0.437, 0.5},
  animation_speed = SD(0.35),
  run_mode = "forward-then-backward",
  scale = 1
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
      filename = path.."scatter_spitter_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.2),
      scale = 1.4
    },
    {
      filename = path.."scatter_spitter_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.3),
      scale = 1.2
    },
    {
      filename = path.."scatter_spitter_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.35),
      scale = 1
    },
    {
      filename = path.."scatter_spitter_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.4),
      scale = 0.8
    },
    {
      filename = path.."scatter_spitter_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.5),
      scale = 0.6
    },
  }
}

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "bio-units",
  order = "c-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = names.deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {names.items.biological_structure, 40},
    {"sulfur", 40},
    {type = "fluid", name = "water", amount = 600}
  },
  energy_required = 35,
  result = name
}

data:extend{unit, projectile, sticker, splash, item, recipe}


