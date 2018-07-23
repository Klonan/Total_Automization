local path = util.path("data/units/scatter_spitter")
local name = require("shared").units.scatter_spitter

local unit = util.copy(data.raw.unit["medium-spitter"])
unit.name = name
unit.localised_name = name
unit.collision_mask = {"not-colliding-with-itself", "player-layer", "object-layer"}
unit.destroy_when_commands_fail = false
unit.radar_range = 2
unit.movement_speed = SD(0.2)
unit.max_pursue_distance = 64
unit.min_persue_time = 8 * 60

local animation = util.copy(unit.attack_parameters.animation)
local sound = util.copy(unit.attack_parameters.sound)
local make_spitter_blast = function(speed, direction, range, count)
  return
  {
    type = "direct",
    repeat_count = count or 1,
    action_delivery =
    {
      type = "projectile",
      projectile = name.." Projectile",
      starting_speed = SD(speed),
      direction_deviation = direction,
      range_deviation = range,
      max_range = 30
    }
  }
end
animation.layers[2].apply_runtime_tint = true
unit.run_animation.layers[2].apply_runtime_tint = true
unit.attack_parameters = 
{
  animation = animation,
  sound = sound,
  type = "projectile",
  ammo_category = "rocket",
  cooldown = SU(60),
  range = 18,
  min_attack_distance = 16,
  projectile_creation_distance = 1.9,
  warmup = 30,
  ammo_type =
  {
    category = "biological",
    target_type = "position",
    clamp_position = true,
    action =
    {
      make_spitter_blast(0.80, 0.40, 0.10, 1),
      make_spitter_blast(0.85, 0.35, 0.15, 1),
      make_spitter_blast(0.90, 0.30, 0.20, 1),
      make_spitter_blast(0.95, 0.25, 0.25, 1),
      make_spitter_blast(1.00, 0.20, 0.30, 2),
    }
  },
}

local projectile = util.copy(data.raw.projectile["acid-projectile-purple"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.direction_only = true
projectile.collision_box = {{-0.1, -0.1},{0.1, 0.1}}
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
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
      }
    }
  }
}

local item = {
  type = "item",
  name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "bio-units",
  order = name,
  stack_size= 1
}

local recipe = {
  type = "recipe",
  name = name,
  category = require("shared").deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 4},
    {type = "fluid", name = "water", amount = 1}
  },
  energy_required = 5,
  result = name
}
data:extend{unit, projectile, item, recipe}


