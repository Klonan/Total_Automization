local path = util.path("data/units/smg_guy")
local name = require("shared").units.smg_guy

local base = util.copy(data.raw.player.player)
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = "__base__/graphics/icons/player.png",
  icon_size = 32,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  max_health = 80,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  can_open_gates = true,
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  sticker_box = {{-0.3, -1}, {0.2, 0.3}},
  distraction_cooldown = SU(15),
  move_while_shooting = true,
  can_open_gates = true,
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(15),
    cooldown_deviation = 0.5,
    range = 24,
    min_attack_distance = 18,
    projectile_creation_distance = 0.5,
    sound = make_light_gunshot_sounds(),
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
          starting_speed = SD(1),
          starting_speed_deviation = SD(0.05),
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = 24
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
    animation = base.animations[1].idle_with_gun
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.2),
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
  run_animation = base.animations[1].running
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.animation.blend_mode = "additive"
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
        damage = {amount = 2.5 , type = util.damage_type("smg_guy")}
      }
    }
  }
}
projectile.final_action = 
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
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
  order = "b-"..name,
  stack_size= 1
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = require("shared").deployers.iron_unit,
  enabled = true,
  ingredients =
  {
    {"light-armor", 1},
    {"submachine-gun", 1},
    {"firearm-magazine", 10}
  },
  energy_required = 15,
  result = name
}

data:extend{bot, projectile, item, recipe}