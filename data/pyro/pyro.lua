local path = util.path("data/pyro/")
local pyro = util.base_player()
pyro.name = "pyro"
pyro.max_health = 175
pyro.running_speed = util.speed(1)
pyro.resistances =
{
  {
    type = util.damage_type("pyro-fire"),
    percent = 60
  },
}
util.add_flag(pyro, "not-flammable")
--util.recursive_hack_scale(pyro, 1)
--class_util.recursive_hack_animation_speed(pyro, 0.8)


pyro_gun = util.copy(data.raw.gun.flamethrower)
pyro_gun.name = "pyro-gun"
pyro_gun.icon = path.."pyro-gun.png"
pyro_gun.icon_size = 81
pyro_gun.attack_parameters.movement_slow_down_factor = 0
pyro_gun.attack_parameters.range = 25
pyro_gun.attack_parameters.cooldown = math.ceil(SU(1))
pyro_gun.stack_size = 1
pyro_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("pyro-fire"),
  cooldown = SU(2.64),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 40, 
  cyclic_sound =
  {
    begin_sound =
    {
      {
        filename = path.."pyro-gun-start.ogg",
        volume = 1
      }
    },
    middle_sound =
    {
      {
        filename = path.."pyro-gun-mid.ogg",
        volume = 1
      }
    },
    end_sound =
    {
      {
        filename = path.."pyro-gun-end.ogg",
        volume = 1
      }
    }
  }
}

pyro_ammo = util.copy(data.raw.ammo["flamethrower-ammo"])
pyro_ammo.name = "pyro-ammo"
pyro_ammo.icon = path.."pyro-ammo.png"
pyro_ammo.icon_size = 540
pyro_ammo.magazine_size = 5000
pyro_ammo.stack_size = 1

local fire = require("data/tf_fire_util")
local sprites = fire.create_fire_pictures({animation_speed = SD(0.5), scale = 0.8})
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
  pyro_fire_projectile.action = nil
  pyro_fire_projectile.final_action = 
  {
    {
      type = "area",
      radius = 0.1,
      collision_mode = "distance-from-center",
      force = "not-same",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = {amount = 2 , type = util.damage_type("pyro-fire")}
          },
          {
            type = "create-sticker",
            sticker = "pyro-fire-sticker"
          }
        }
      }
    }
  }
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

pyro_ammo.ammo_type =
{
  category = util.ammo_category("pyro-fire"),
  target_type = "direction",
  clamp_position = true,
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
    make_fire("pyro-fire-projectile-3", 2),
    make_fire("pyro-fire-projectile-4", 2.5),
    make_fire("pyro-fire-projectile-5", 3),
    make_fire("pyro-fire-projectile-6", 3.5)
  }
}

pyro_flare_gun = util.copy(pyro_gun)
pyro_flare_gun.name = "pyro-flare-gun"
pyro_flare_gun.icon = path.."pyro-flare-gun.png"
pyro_flare_gun.icon_size = 56
pyro_flare_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("pyro-flare"),
  movement_slow_down_factor = 0.3,
  cooldown = SU(100),
  projectile_creation_distance = 0.6,
  range = 45,
  projectile_center = {-0.17, -1},
  gun_center_shift = { 0, -1 },
  sound =
  {
    {
      filename = path.."pyro-flare-gun.ogg",
      volume = 1
    }
  }
}

pyro_flare_ammo = util.copy(pyro_ammo)
pyro_flare_ammo.name = "pyro-flare-ammo"
pyro_flare_ammo.icon = path.."pyro-flare-ammo.png"
pyro_flare_ammo.icon_size = 120
pyro_flare_ammo.ammo_type = 
{
  source_type = "default",
  category = util.ammo_category("pyro-flare"),
  target_type = "position",
  clamp_position = true,

  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = "pyro-flare-stream",
      max_length = 45,
      duration = SU(160),
    }
  }
}

pyro_fire = util.copy(data.raw.fire["fire-flame"])
pyro_fire.name = "pyro-fire"
pyro_fire.damage_per_tick = {amount = SD(3/60), type = "fire"}
pyro_fire.maximum_damage_multiplier = 1
pyro_fire.damage_multiplier_increase_per_added_fuel = 0
pyro_fire.damage_multiplier_decrease_per_tick = 0
pyro_fire.spawn_entity = "fire-flame-on-tree"
pyro_fire.spread_delay = SU(300)
pyro_fire.spread_delay_deviation = SU(180)
pyro_fire.maximum_spread_count = 100
pyro_fire.flame_alpha = 0.35
pyro_fire.flame_alpha_deviation = 0.05
pyro_fire.emissions_per_tick = SD(0.005)
pyro_fire.add_fuel_cooldown = SU(10)
pyro_fire.fade_in_duration = SU(30)
pyro_fire.fade_out_duration = SU(30)
pyro_fire.initial_lifetime = SU(300)
pyro_fire.lifetime_increase_by = SU(150)
pyro_fire.lifetime_increase_cooldown = SU(4)
pyro_fire.maximum_lifetime = SU(1800)
pyro_fire.delay_between_initial_flames = SU(10)
pyro_fire.initial_flame_count = 1
pyro_fire.burnt_patch_lifetime = SU(1800)

pyro_fire_sticker = util.copy(data.raw.sticker["fire-sticker"])
pyro_fire_sticker.name = "pyro-fire-sticker"

pyro_fire_sticker.duration_in_ticks = SU(6 * 60)
pyro_fire_sticker.target_movement_modifier = 1
pyro_fire_sticker.damage_per_tick = { amount = SD(10 / 60), type = util.damage_type("pyro-afterburn") }
pyro_fire_sticker.spread_fire_entity = "fire-flame-on-tree"
pyro_fire_sticker.fire_spread_cooldown = SU(30)
pyro_fire_sticker.fire_spread_radius = 0.75
pyro_fire_sticker.animation.scale = 0.5

pyro_flare_stream = 
{
  type = "stream",
  name = "pyro-flare-stream",
  flags = {"not-on-map"},

  smoke_sources = 
  {
    {
      name = "soft-fire-smoke",
      frequency = SD(1), --0.25,
      position = {0.0, 0}, -- -0.8},
      starting_frame_deviation = 60
    }
  },

  stream_light = {intensity = 0, size = 4 * 0.8},
  ground_light = {intensity = 0, size = 4 * 0.8},

  particle_buffer_size = 1,
  particle_spawn_interval = SU(1000),
  particle_spawn_timeout = SU(1000),
  particle_vertical_acceleration = SD(0.005 * 2),
  particle_horizontal_speed = SD(0.65),
  particle_horizontal_speed_deviation = 0.0035,
  particle_start_alpha = 0,
  particle_end_alpha = 1,
  particle_start_scale = 1,
  particle_loop_frame_count = SD(100),
  particle_fade_out_threshold = 0,
  particle_loop_exit_threshold = 0,
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-fire",
            entity_name = "pyro-fire",
            initial_ground_flame_count = 6
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    {
      type = "area",
      radius = 2,
      collision_mode = "distance-from-center",
      force = "not-same",
      action_delivery =
      {
        force = "enemy",
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 30, type = util.damage_type("pyro-flare") },
            apply_damage_to_trees = false
          },
          {
            type = "create-sticker",
            sticker = "pyro-fire-sticker"
          },
          {
            type = "create-fire",
            entity_name = "pyro-fire",
            initial_ground_flame_count = 3,
          }
        }
      }
    },
  },

  spine_animation =
  {
    filename = "__Team_Factory__/data/demoman/demoman-grenade-2.png",
    --tint = {r=1, g=1, b=1, a=1},
    line_length = 1,
    width = 32,
    height = 14,
    frame_count = 1,
    scale = 1
  },

  shadow =
  {
    filename = "__base__/graphics/entity/acid-projectile-purple/acid-projectile-purple-shadow.png",
    line_length = 5,
    width = 28,
    height = 16,
    frame_count = 33,
    priority = "high",
    scale = 0.5,
    shift = {-0.09 * 0.5, 0.395 * 0.5}
  }
}



data:extend
{
  pyro,
  pyro_ammo,
  pyro_fire_projectile,
  pyro_fire_sticker,
  pyro_fire,
  pyro_flare_ammo,
  pyro_flare_gun,
  pyro_flare_stream,
  pyro_gun,
  pyro_stream
}
