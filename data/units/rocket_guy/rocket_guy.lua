local path = util.path("data/units/rocket_guy/")
local name = names.units.rocket_guy

local base = util.copy(data.raw.player.player)
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end

local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = path.."rocket_guy_icon.png",
  icon_size = 107,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 140,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  collision_box = {{-0.6, -0.6}, {0.6, 0.6}},
  selection_box = {{-0.8, -2.2}, {0.8, 0.4}},
  sticker_box = {{-0.3, -1.5}, {0.3, 0.2}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(125),
    cooldown_deviation = 0.25,
    range = 28,
    min_attack_distance = 24,
    projectile_creation_distance = 0.5,
    sound = {
      variations = {
        {
          filename = "__base__/sound/fight/rocket-launcher.ogg",
          volume = 1
        },
      },
      aggregation =
      {
        max_count = 2,
        remove = true,
        count_already_playing = true
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
          starting_speed = SD(0.1),
          starting_speed_deviation = SD(0.05),
          --direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 40
          },
          {
            type = "instant",
            source_effects =
            {
              {
                type = "create-explosion",
                entity_name = "explosion-gunshot"
              }
            }
          }
        }
      }
    },
    animation = base.animations[2].idle_with_gun
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.15),
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
  run_animation = base.animations[2].running
}

util.recursive_hack_make_hr(bot)
util.recursive_hack_scale(bot, 1.5)


local projectile = util.copy(data.raw.projectile.rocket)
projectile.name = name.." Projectile"
projectile.acceleration = SD(0.01)
projectile.max_speed = 0.5
projectile.collision_box = {{-0.1, -0.25}, {0.1, 0.25}}
projectile.force_condition = "not-same"
projectile.direction_only = true
projectile.action =
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
          {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = 2 * math.pi * 1 * 1,
            radius = 1,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "create-entity",
                  entity_name = name.." Explosion"
                }
              }
            }
          },
          {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = math.pi * 2 * 2,
            radius = 2,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "create-entity",
                  entity_name = name.." Explosion"
                }
              }
            }
          },
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
                  type = "damage",
                  damage = {amount = 5, type = util.damage_type("rocket")}
                }
              }
            }
          },
          {
            type = "area",
            radius = 1,
            force = "not-same",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "damage",
                  damage = {amount = 10, type = util.damage_type("rocket")}
                },
              }
            }
          }
        }
      }
    }
  }
}

local explosion = util.copy(data.raw.explosion.explosion)
explosion.name = name.." Explosion"

local sprites = explosion.animations
local new_animations = {}
local add_sprites = function(scale, speed)
  for k, sprite in pairs (sprites) do
    local new = util.copy(sprite)
    new.animation_speed = (new.animation_speed or 1) * speed
    new.scale = (new.scale or 1) * scale
    new.blend_mode = "additive"
    table.insert(new_animations, new)
  end
end

add_sprites(1, 0.5)
add_sprites(0.95, 0.6)
add_sprites(0.9, 0.7)
add_sprites(0.85, 0.8)
add_sprites(0.8, 0.9)
add_sprites(0.75, 1)
add_sprites(0.6, 1.1)
add_sprites(0.5, 1.2)

explosion.animations = new_animations
explosion.light = nil
explosion.smoke = nil
explosion.smoke_count = 0

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = "d-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = names.deployers.iron_unit,
  enabled = true,
  ingredients =
  {
    {"steel-plate", 15},
    {"iron-gear-wheel", 10},
    {"explosives", 15}
  },
  energy_required = 25,
  result = name
}

data:extend{bot, projectile, item, recipe, explosion}