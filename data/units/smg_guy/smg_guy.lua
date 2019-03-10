local path = util.path("data/units/smg_guy/")
local name = names.units.smg_guy

local base = util.copy(data.raw.player.player)
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
local attack_range = 16
local bot =
{
  type = "unit",
  name = name,
  localised_name = {name},
  icon = "__base__/graphics/icons/player.png",
  icon_size = 32,
  flags = {"player-creation", "placeable-off-grid"},
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 80,
  radar_range = 1,
  order="b-b-b",
  subgroup="enemies",
  can_open_gates = true,
  resistances = nil,
  healing_per_tick = 0,
  minable = {result = name, mining_time = 2},
  collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
  collision_mask = util.ground_unit_collision_mask(),
  max_pursue_distance = 64,
  resistances =
  {
    {
      type = "acid",
      decrease = 2,
      percent = 40
    }
  },
  min_persue_time = 60 * 15,
  selection_box = {{-0.5, -1.6}, {0.5, 0.3}},
  sticker_box = {{-0.3, -1}, {0.2, 0.3}},
  distraction_cooldown = (15),
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
    cooldown = 15,
    cooldown_deviation = 0.5,
    range = attack_range,
    min_attack_distance = attack_range - 2,
    projectile_creation_distance = 0.5,
    lead_target_for_projectile_speed = 1,
    sound =
    {
      variations =
      {
        {
          filename = "__base__/sound/fight/light-gunshot-1.ogg"
        },
        {
          filename = "__base__/sound/fight/light-gunshot-2.ogg"
        },
        {
          filename = "__base__/sound/fight/light-gunshot-3.ogg"
        }
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
          starting_speed = 1,
          starting_speed_deviation = 0.05,
          direction_deviation = 0.1,
          range_deviation = 0.1,
          max_range = attack_range + 2,
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
  movement_speed = 0.2,
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
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
projectile.hit_at_collision_position = true
projectile.hit_collision_mask = util.projectile_collision_mask()
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
        damage = {amount = 2.5 , type = util.damage_type(name)}
      },
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}
projectile.final_action = nil

local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = "b-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = {name},
  category = names.deployers.iron_unit,
  enabled = false,
  ingredients =
  {
    {"iron-plate", 15},
    {"iron-gear-wheel", 10},
    {"iron-stick", 10}
  },
  energy_required = 15,
  result = name
}

data:extend{bot, projectile, item, recipe}