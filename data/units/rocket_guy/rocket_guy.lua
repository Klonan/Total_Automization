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
  only_shoot_healthy = true,
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(90),
    cooldown_deviation = 0.25,
    range = 32,
    min_attack_distance = 26,
    projectile_creation_distance = 0.5,
    sound = {
      variations = {
        {filename = path.."rocket_guy_shoot.ogg", volume = 1},
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
        type = "damage",
        damage = {amount = 25 , type = util.damage_type("rocket_guy")}
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

data:extend{bot, projectile, item, recipe}