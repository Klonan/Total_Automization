local path = util.path("data/changes/enemies/")

local make_worm_attack = function(name, range, damage, duration, cooldown)

  local particle_gfx = util.copy(data.raw.projectile["acid-projectile-purple"])

  local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
  stream.name = name.." Stream"
  stream.action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "create-entity",
            entity_name = name.." Splash"
          }
        }
      }
    },
    {
      type = "area",
      --collision_mode = "distance-from-center",
      radius = 1.5,
      force = "enemy",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = damage, type = util.damage_type(name) }
          }
        }
      }
    }
  }
  stream.particle = particle_gfx.animation
  stream.particle.scale = 1.5
  stream.particle_buffer_size = 100
  stream.particle_spawn_interval = 0.5
  stream.particle_spawn_timeout = duration or 30
  stream.particle_vertical_acceleration = 0.981 / 60
  stream.particle_horizontal_speed = 0.6
  stream.particle_horizontal_speed_deviation = 0.03
  stream.particle_start_alpha = 1
  stream.particle_end_alpha = 1
  stream.particle_start_scale = 1
  stream.particle_loop_frame_count = 10
  stream.particle_fade_out_threshold = 1
  stream.particle_loop_exit_threshold = 1
  --stream.particle.tint = {r = 0.5, g = 0, b = 1}
  stream.spine_animation = nil
  stream.smoke_sources = nil
  stream.target_position_deviation = 4

  local splash =
  {
    type = "explosion",
    name = name.." Splash",
    height = 1,
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = path.."worm_splash.png",
        priority = "extra-high",
        width = 92,
        height = 66,
        frame_count = 15,
        line_length = 5,
        shift = {-0.437, 0.5},
        animation_speed = 0.35,
        scale = 1.5
      },
      {
        filename = path.."worm_splash.png",
        priority = "extra-high",
        width = 92,
        height = 66,
        frame_count = 15,
        line_length = 5,
        shift = {-0.437, 0.5},
        animation_speed = 0.3,
        scale = 1.6
      },
      {
        filename = path.."worm_splash.png",
        priority = "extra-high",
        width = 92,
        height = 66,
        frame_count = 15,
        line_length = 5,
        shift = {-0.437, 0.5},
        animation_speed = 0.4,
        scale = 1.2
      },
    }
  }

  data:extend({
    stream, splash
  })


  local attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = cooldown or 90,
    range = range or 30,
    projectile_creation_distance = 1.8,
    --damage_modifier = 2.5,
    ammo_type =
    {
      category = util.ammo_category(name.." Attack"),
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "stream",
          stream = name.." Stream",
          }
        }
      }
    }
  }
  return attack_parameters
end

local small_worm = data.raw.turret["small-worm-turret"]
local small_worm_range = 50
small_worm.attack_parameters = make_worm_attack(small_worm.name, small_worm_range, 6, 30, 60)
small_worm.range = small_worm_range
small_worm.prepare_range = small_worm_range * 1.1

local medium_worm = data.raw.turret["medium-worm-turret"]
local medium_worm_range = 55
medium_worm.attack_parameters = make_worm_attack(medium_worm.name, medium_worm_range, 8, 30, 70)
medium_worm.range = medium_worm_range
medium_worm.prepare_range = medium_worm_range * 1.1

local big_worm = data.raw.turret["big-worm-turret"]
local big_worm_range = 60
big_worm.attack_parameters = make_worm_attack(big_worm.name, big_worm_range, 10, 30, 80)
big_worm.range = big_worm_range
big_worm.prepare_range = big_worm_range * 1.1

--Spitters

local make_spitter_attack = function(name, damage, cooldown, range)

  local projectile = util.copy(data.raw.projectile["acid-projectile-purple"])
  projectile.name = name.." Projectile"
  projectile.force_condition = "enemy"
  projectile.direction_only = false
  projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
  projectile.acceleration = 0
  projectile.rotatable = true
  projectile.range = range * 1.1
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
          entity_name = name.." Splash"
        },
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
          type = "nested-result",
          action =
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
                  damage = { amount = damage, type = util.damage_type(name) }
                },
                {
                  type = "create-sticker",
                  sticker = name.." Sticker"
                }
              }
            }
          }
        }
      }
    }
  }

  local animation =
  {
    filename = path.."spitter_projectile.png",
    line_length = 4,
    width = 46,
    height = 82,
    frame_count = 16,
    priority = "high",
    scale = 0.3,
    animation_speed = 1
  }

  local make_animation = function(scale, speed)
    local data = util.copy(animation)
    data.scale = (data.scale or 1) * scale
    data.animation_speed = (data.animation_speed or 1) * speed
    return data
  end

  local shadow =
  {
    filename = path.."spitter_projectile_shadow.png",
    line_length = 4,
    width = 94,
    height = 170,
    frame_count = 16,
    priority = "high",
    shift = {-0.09, 0.395},
    draw_as_shadow = true,
    scale = 0.3,
    animation_speed = 1
  }
  local make_shadow = function(scale, speed)
    local data = util.copy(shadow)
    data.scale = (data.scale or 1) * scale
    data.animation_speed = (data.animation_speed or 1) * speed
    return data
  end

  projectile.animation =
  {
    make_animation(0.6, 1),
    make_animation(0.65, 0.95),
    make_animation(0.7, 0.9),
    make_animation(0.75, 0.85),
    make_animation(0.8, 0.8),
    make_animation(0.85, 0.75),
    make_animation(0.9, 0.7),
    make_animation(0.95, 0.65),
    make_animation(1, 0.6),
  }
  projectile.shadow =
  {
    make_shadow(0.6, 1),
    make_shadow(0.65, 0.95),
    make_shadow(0.7, 0.9),
    make_shadow(0.75, 0.85),
    make_shadow(0.8, 0.8),
    make_shadow(0.85, 0.75),
    make_shadow(0.9, 0.7),
    make_shadow(0.95, 0.65),
    make_shadow(1, 0.6),
  }

  local sticker = util.copy(data.raw.sticker["slowdown-sticker"])
  sticker.name = name.." Sticker"

  sticker.duration_in_ticks = 60
  sticker.target_movement_modifier = 0.75
  sticker.damage_per_tick = nil --{type = util.damage_type(name), amount = 1}
  sticker.stickers_per_square_meter = 5
  sticker.animation =
  {
    filename = path.."spitter_splash.png",
    priority = "extra-high",
    width = 92,
    height = 66,
    frame_count = 5,
    line_length = 5,
    shift = {-0.437, 0.5},
    animation_speed = SD(0.35),
    run_mode = "forward-then-backward",
    scale = 1
  }

  local animation =
  {
    filename = path.."spitter_splash.png",
    priority = "extra-high",
    width = 92,
    height = 66,
    frame_count = 15,
    line_length = 5,
    shift = {-0.437, 0.5},
    animation_speed = 0.35,
    scale = 1
  }

  local make_animation = function(scale, speed)
    local data = util.copy(animation)
    data.scale = (data.scale or 1) * scale
    data.animation_speed = (data.animation_speed or 1) * speed
    return data
  end

  local splash =
  {
    type = "explosion",
    name = name.." Splash",
    height = 1,
    flags = {"not-on-map"},
    animations =
    {
      make_animation(1.0, 0.75),
      make_animation(0.9, 0.8),
      make_animation(0.8, 0.85),
      make_animation(0.7, 0.9),
      make_animation(0.6, 0.95),
      make_animation(0.5, 1.0),
    }
  }


  local attack_parameters =
  {
    animation = animation,
    sound = sound,
    type = "projectile",
    ammo_category = util.ammo_category(name),
    cooldown = cooldown,
    cooldown_deviation = 0.2,
    range = range,
    min_attack_distance = range * 0.8,
    projectile_creation_distance = 1.9,
    warmup = 30,
    ammo_type =
    {
      category = util.ammo_category(name),
      target_type = "entity",
      action =
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
                type = "area",
                target_entities = false,
                trigger_from_target = false,
                repeat_count = 15,
                radius = 3,
                action_delivery =
                {
                  type = "projectile",
                  projectile = name.." Projectile",
                  starting_speed = 0.8,
                  starting_speed_deviation = 0.2,
                  --max_range = range * 1.05
                  --max_range_deviation = 0.1
                }
              }
            }
          }
        }
      }
    }
  }
  data:extend({
    projectile,
    splash,
    sticker
  })

  return attack_parameters
end

local small_spitter = data.raw.unit["small-spitter"]
local animation = small_spitter.attack_parameters.animation
small_spitter.attack_parameters = make_spitter_attack(small_spitter.name, 2, 60, 18)
small_spitter.attack_parameters.animation = animation


local medium_spitter = data.raw.unit["medium-spitter"]
local animation = medium_spitter.attack_parameters.animation
medium_spitter.attack_parameters = make_spitter_attack(medium_spitter.name, 4, 60, 20)
medium_spitter.attack_parameters.animation = animation


local big_spitter = data.raw.unit["big-spitter"]
local animation = big_spitter.attack_parameters.animation
big_spitter.attack_parameters = make_spitter_attack(big_spitter.name, 8, 60, 22)
big_spitter.attack_parameters.animation = animation

local behemoth_spitter = data.raw.unit["behemoth-spitter"]
local animation = behemoth_spitter.attack_parameters.animation
behemoth_spitter.attack_parameters = make_spitter_attack(behemoth_spitter.name, 15, 60, 24)
behemoth_spitter.attack_parameters.animation = animation

local make_biter_attack = function(name, damage, cooldown)



  local sticker = util.copy(data.raw.sticker["fire-sticker"])
  sticker.name = name.." Sticker"
  sticker.duration_in_ticks = 2 * 60
  sticker.target_movement_modifier = 0.5
  sticker.damage_per_tick = nil
  sticker.spread_fire_entity = nil
  sticker.fire_spread_cooldown = 0
  sticker.fire_spread_radius = 0
  sticker.animation = util.empty_sprite()
  sticker.stickers_per_square_meter = 1
  data:extend{sticker}

  local ammo_type =
  {
    category = util.ammo_category(name),
    target_type = "entity",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-sticker",
            sticker = name.." Sticker"
          },
          {
            type = "damage",
            damage = {amount = damage, type = util.damage_type(name)}
          },
          {
            type = "nested-result",
            action =
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
                    damage = {amount = damage, type = util.damage_type(name)}
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  local attack_parameters =
  {
    type = "projectile",
    range = 0.5,
    cooldown = cooldown,
    cooldown_deviation = 0.2,
    ammo_category = util.ammo_category(name),
    ammo_type = ammo_type
  }
  return attack_parameters

end

local small_biter = data.raw.unit["small-biter"]
local sound = small_biter.attack_parameters.sound
local animation = small_biter.attack_parameters.animation
small_biter.attack_parameters = make_biter_attack(small_biter.name, 7, 35)
small_biter.attack_parameters.sound = sound
small_biter.attack_parameters.animation = animation
small_biter.movement_speed = small_biter.movement_speed * 1.5

local medium_biter = data.raw.unit["medium-biter"]
local sound = medium_biter.attack_parameters.sound
local animation = medium_biter.attack_parameters.animation
medium_biter.attack_parameters = make_biter_attack(medium_biter.name, 15, 35)
medium_biter.attack_parameters.sound = sound
medium_biter.attack_parameters.animation = animation
medium_biter.movement_speed = medium_biter.movement_speed * 1.5

local big_biter = data.raw.unit["big-biter"]
local sound = big_biter.attack_parameters.sound
local animation = big_biter.attack_parameters.animation
big_biter.attack_parameters = make_biter_attack(big_biter.name, 30, 35)
big_biter.attack_parameters.sound = sound
big_biter.attack_parameters.animation = animation
big_biter.movement_speed = big_biter.movement_speed * 1.5

local behemoth_biter = data.raw.unit["behemoth-biter"]
local sound = behemoth_biter.attack_parameters.sound
local animation = behemoth_biter.attack_parameters.animation
behemoth_biter.attack_parameters = make_biter_attack(behemoth_biter.name, 90, 35)
behemoth_biter.attack_parameters.sound = sound
behemoth_biter.attack_parameters.animation = animation
behemoth_biter.movement_speed = behemoth_biter.movement_speed * 1.5

local biter_spawner = data.raw["unit-spawner"]["biter-spawner"]
biter_spawner.max_count_of_owned_units = biter_spawner.max_count_of_owned_units * 8
biter_spawner.max_friends_around_to_spawn = biter_spawner.max_friends_around_to_spawn * 8
biter_spawner.collision_box = util.scale_box(biter_spawner.collision_box, 0.8)
table.insert(biter_spawner.flags, "placeable-off-grid")
biter_spawner.max_health = biter_spawner.max_health * 1.5
biter_spawner.spawning_cooldown[1] = biter_spawner.spawning_cooldown[1] * 4
biter_spawner.spawning_cooldown[2] = biter_spawner.spawning_cooldown[2] * 4

local spitter_spawner = data.raw["unit-spawner"]["spitter-spawner"]
spitter_spawner.max_count_of_owned_units = spitter_spawner.max_count_of_owned_units * 8
spitter_spawner.max_friends_around_to_spawn = spitter_spawner.max_friends_around_to_spawn * 8
spitter_spawner.collision_box = util.scale_box(spitter_spawner.collision_box, 1)
table.insert(spitter_spawner.flags, "placeable-off-grid")
spitter_spawner.max_health = spitter_spawner.max_health * 1.5
spitter_spawner.spawning_cooldown[1] = spitter_spawner.spawning_cooldown[1] * 4
spitter_spawner.spawning_cooldown[2] = spitter_spawner.spawning_cooldown[2] * 4
