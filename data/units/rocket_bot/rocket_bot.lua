local path = util.path("data/units/rocket_bot/")
local name = require("shared").units.rocket_bot

local base = util.copy(data.raw.player.player)
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end

util.recursive_hack_tint(base.animations[2].idle_with_gun.layers[2], {r = 0.6, g = 0.6, b = 0.6})
util.recursive_hack_tint(base.animations[2].idle_with_gun.layers[4], {r = 0.6, g = 0.6, b = 0.6})
util.recursive_hack_tint(base.animations[2].running.layers[2], {r = 0.6, g = 0.6, b = 0.6})
util.recursive_hack_tint(base.animations[2].running.layers[4], {r = 0.6, g = 0.6, b =0.6})

local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = path.."rocket_bot_icon.png",
  icon_size = 107,
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
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  collision_mask = {"not-colliding-with-itself", "player-layer", "object-layer"},
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = SU(30),
  move_while_shooting = true, --Not merged
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(120),
    cooldown_deviation = 0.5,
    range = 36,
    min_attack_distance = 28,
    projectile_creation_distance = 0.5,
    sound = {
      {filename = path.."rocket_bot_shoot.ogg", volume = 0.5}
    },
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
          type = "projectile",
          projectile = name.." Projectile",
          starting_speed = SD(1),
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 32
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
  vision_distance = 16,
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

local scale = 1.5
util.recursive_hack_make_hr(bot)
util.recursive_hack_scale(bot, scale)
util.scale_boxes(bot, scale)


local projectile = util.copy(data.raw.projectile.rocket)
projectile.name = name.." Projectile"
projectile.acceleration = SD(0)
--projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
--projectile.force_condition = "not-same"
projectile.direction_only = false
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 50 , type = util.damage_type("rocket_bot")}
      },
      {
        type = "create-entity",
        entity_name = "explosion"
      },
    }
  }
}

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
  category = require("shared").deployers.iron_unit,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 4}
  },
  energy_required = 5,
  result = name
}

data:extend{bot, projectile, item, recipe}