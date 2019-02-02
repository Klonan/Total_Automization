local path = util.path("data/units/smg_guy")
local name = names.units.blaster_bot

local base = util.copy(data.raw["combat-robot"]["defender"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end
table.insert(base.idle.layers, base.shadow_idle)
table.insert(base.in_motion.layers, base.shadow_in_motion)
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
  max_health = 60,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
  collision_mask = util.flying_unit_collision_mask(),
  render_layer = "air-object",
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
  sticker_box = {{-0.3, -0.3}, {0.3, 0.3}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  ai_settings =
  {
    do_separation = true
  },
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(45),
    cooldown_deviation = 0.5,
    range = 24,
    min_attack_distance = 18,
    projectile_creation_distance = 1,
    projectile_center = {0, 1.2},
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
          starting_speed = SD(1.5),
          direction_deviation = 0.05,
          range_deviation = 0.05,
          max_range = 28
          }
        }
      }
    },
    animation = base.idle
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.22),
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
  run_animation = base.in_motion
}
util.recursive_hack_make_hr(bot)
util.recursive_hack_scale(bot, 2)

local projectile = util.copy(data.raw.projectile["laser"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
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
        type = "create-entity",
        entity_name = "laser-bubble"
      },
      {
        type = "damage",
        damage = {amount = 8 , type = util.damage_type(name)}
      }
    }
  }
}
projectile.final_action = nil

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "circuit-units",
  order = "b-"..name,
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
    {"electronic-circuit", 8},
    {"copper-cable", 15},
    {"copper-plate", 5}
  },
  energy_required = 20,
  result = name
}

data:extend{bot, projectile, item, recipe}