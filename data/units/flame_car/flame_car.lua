local name = require("shared").units.flame_car

local sprite_base = util.copy(data.raw.car.car)
local path = util.path("data/units/flame_car/")

local fire = require("data/tf_util/tf_fire_util")
local sprites = fire.create_fire_pictures({animation_speed = SD(0.5), scale = 0.5})
local index = 0
local sprite = function()
  index = index + 1
  return sprites[index]
end
local base = data.raw.projectile["shotgun-pellet"]
local make_fire = function(name, n)
  pyro_fire_projectile = util.copy(base)
  pyro_fire_projectile.name = name
  pyro_fire_projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
  pyro_fire_projectile.force_condition = "not-same"
  pyro_fire_projectile.height = 0
  pyro_fire_projectile.action = 
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = {amount = 0.1 , type = util.damage_type("fire")}
        },
        {
          type = "create-sticker",
          sticker = "Afterburn Sticker"
        }
      }
    }
  }
  pyro_fire_projectile.final_action = nil
  pyro_fire_projectile.animation = sprite()
  data:extend({pyro_fire_projectile})
  return
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = name,
      starting_speed = SD(0.4) + (0.1 / n),
      direction_deviation = 0.1 * n,
      range_deviation = 0.2 * n,
      starting_frame_deviation = 5,
      max_range = 25 - (n * 2)
    }
  }

end


local unit =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = "__base__/graphics/icons/car.png",
  icon_size = 32,
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
  collision_box = {{-1, -1}, {1, 1}},
  selection_box = {{-1, -1}, {1, 1}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = 60 * 15,
  --sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = 120,
  move_while_shooting = true,
  can_open_gates = true,
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(2.64),
    range = 15,
    min_attack_distance = 15,
    projectile_creation_distance = 0.5,
    cyclic_sound =
    {
      begin_sound =
      {
        {
          filename = path.."flamethrower_shoot_start.ogg",
          volume = 0.5
        }
      },
      middle_sound =
      {
        {
          filename = path.."flamethrower_shoot_mid.ogg",
          volume = 0.5
        }
      },
      end_sound =
      {
        {
          filename = path.."flamethrower_shoot_end.ogg",
          volume = 0.5
        }
      }
    },
    ammo_type =
    {
      category = "bullet",
      target_type = "direction",
      action =
      {
        {
          type = "direct",
          action_delivery =
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
        },
        make_fire("pyro-fire-projectile-1", 1),
        make_fire("pyro-fire-projectile-2", 1.5),
        make_fire("pyro-fire-projectile-3", 2)
      }
    },
    animation = sprite_base.animation
  },
  vision_distance = 16,
  has_belt_immunity = true,
  movement_speed = SD(0.25),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/car-engine.ogg",
      volume = 0.6
    }
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
  run_animation = sprite_base.animation
}

data:extend{unit}
