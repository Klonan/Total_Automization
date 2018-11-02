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
      collision_mode = "distance-from-center",
      radius = 1.5,
      force = "not-same",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 3, type = "acid" }
          }
        }
      }
    }
  }
  stream.particle = particle_gfx.animation
  stream.particle.scale = 1.5
  stream.particle_buffer_size = 100
  stream.particle_spawn_interval = 2
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
  stream.target_position_deviation = 3

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
small_worm.attack_parameters = make_worm_attack(small_worm.name, small_worm_range, 5, 30, 100)
small_worm.range = small_worm_range
small_worm.prepare_range = small_worm_range + 4