local path = util.path("data/pyro/")
local pyro = util.base_player()
pyro.name = "pyro"
pyro.max_health = 200
pyro.running_speed = SD(0.2)
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
  cooldown = SU(1),
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
local make_fire = function(name, n)
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

--pyro_ammo.ammo_type = 
--{
--  source_type = "default",
--  category = "flamethrower",
--  target_type = "position",
--  clamp_position = true,
--
--  action =
--  {
--    type = "direct",
--    action_delivery =
--    {
--      type = "stream",
--      stream = "pyro-fire-stream",
--      max_length = 25,
--      duration = SU(160),
--    }
--  }
--}

local make_projectile = function(name, animation)
  pyro_fire_projectile = util.copy(data.raw.projectile["shotgun-pellet"])
  pyro_fire_projectile.name = name
  pyro_fire_projectile.action = nil
  pyro_fire_projectile.final_action = 
  {
    {
      type = "area",
      radius = 0.1,
      collision_mode = "distance-from-center",
      force = "enemy",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-sticker",
          sticker = "pyro-fire-sticker"
        }
      }
    }
    },
    {
      type = "area",
      radius = 0.1,
      collision_mode = "distance-from-center",
      --force = "enemy",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = {amount = 2 , type = util.damage_type("pyro-fire")}
  }
        }
      }
    }
  }
  pyro_fire_projectile.animation = animation
  data:extend({pyro_fire_projectile})
end

make_projectile("pyro-fire-projectile-1",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-13.png",
  line_length = 8,
  width = 60,
  height = 118,
  frame_count = 25,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 }, --{ r = 1, g = 1, b = 1, a = 0.35 },
})

make_projectile("pyro-fire-projectile-2",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
  line_length = 8,
  width = 67,
  height = 130,
  frame_count = 32,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 },
})

make_projectile("pyro-fire-projectile-3",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-09.png",
  line_length = 8,
  width = 64,
  height = 101,
  frame_count = 25,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 },
}
)

make_projectile("pyro-fire-projectile-4",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-08.png",
  line_length = 8,
  width = 50,
  height = 98,
  frame_count = 32,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 },
}
)

make_projectile("pyro-fire-projectile-5",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-04.png",
  line_length = 8,
  width = 67,
  height = 130,
  frame_count = 32,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 },
}
)

make_projectile("pyro-fire-projectile-6",
{
  filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
  line_length = 8,
  width = 66,
  height = 119,
  frame_count = 32,
  axially_symmetrical = false,
  direction_count = 1,
  blend_mode = "normal",
  animation_speed = SD(1),
  scale = 0.5,
  tint = { r = 0.5, g = 0.5, b = 0.5, a = 0.18 },
}
)

pyro_stream = util.copy(data.raw.stream["handheld-flamethrower-fire-stream"])
pyro_stream.name = "pyro-fire-stream"
pyro_stream.particle_vertical_acceleration = SD(0.005 * 0.2)
pyro_stream.particle_horizontal_speed = SD(0.45)
pyro_stream.particle_horizontal_speed_deviation = SD(0.0035)
pyro_stream.action =
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
          initial_ground_flame_count = 2,
        },
      }
    }
  },
  {
    type = "area",
    radius = 2.5,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-sticker",
          sticker = "pyro-fire-sticker"
        },
        {
          type = "damage",
          damage = { amount = 2, type = util.damage_type("pyro-fire") },
          apply_damage_to_trees = false
        },
        {
          type = "create-fire",
          entity_name = "pyro-fire",
          initial_ground_flame_count = 1,
        }
      }
    }
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
  range = 35,
  projectile_center = {-0.17, 0},
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
      max_length = 25,
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
  particle_horizontal_speed = SD(0.45),
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
            initial_ground_flame_count = 2
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
      radius = 4,
      action_delivery =
      {
        force = "enemy",
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 15, type = util.damage_type("pyro-flare") },
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
    {
      type = "area",
      radius = 0.5,
      action_delivery =
      {
        force = "enemy",
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 40, type = util.damage_type("pyro-flare") }
          }
        }
      }
    }
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
