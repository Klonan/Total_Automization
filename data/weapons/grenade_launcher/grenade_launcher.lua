local path = util.path("data/weapons/grenade_launcher/")
local gun = util.base_gun(names.grenade_launcher)
gun.icon = path.."grenade_launcher.png"
gun.icon_size = 512
gun.stack_size = 1

gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("demoman-grenade"),
  movement_slow_down_factor = 0.3,
  cooldown = SU(36),
  projectile_creation_distance = 0.6,
  range = 35,
  --projectile_center = {-0.17, 0},
  gun_center_shift = { 0, -1 },
  sound =
  {
    {
      filename = path.."grenade_launcher_1.ogg",
      volume = 1
    },
    {
      filename = path.."grenade_launcher_2.ogg",
      volume = 1
    },
  }
}

local ammo = util.base_ammo(names.grenade_launcher.." Ammo")
ammo.icon = path.."grenade_launcher_ammo.png"
ammo.icon_size = 514
ammo.magazine_size = 4
ammo.stack_size = 16 / 4
ammo.reload_time = SU(182 - 36)
ammo.ammo_type = 
{
  source_type = "default",
  category = util.ammo_category("demoman-grenade"),
  target_type = "position",
  clamp_position = true,

  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = names.grenade_launcher.." Stream",
      max_length = 50,
      duration = 160,
      source_offset = {0, -1},
    }
  }
}

local stream = 
{
  type = "stream",
  name = names.grenade_launcher.." Stream",
  flags = {},--"not-on-map"},

  smoke_sources = nil,
  --{
  --  {
  --    name = "soft-fire-smoke",
  --    frequency = 0, --0.25,
  --    position = {0.0, 0}, -- -0.8},
  --    starting_frame_deviation = 60
  --  }
  --},

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
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    },
    {
      type = "area",
      force = "not-same",
      radius = 3,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 60, type = util.damage_type("demoman-grenade") }
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
      force = "not-same",
      radius = 1.5,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 40, type = util.damage_type("demoman-grenade") }
          }
        }
      }
    }
  },

  spine_animation =
  {
    filename = path.."grenade_launcher_stream.png",
    --tint = {r=1, g=1, b=1, a=1},
    line_length = 1,
    width = 32,
    height = 30,
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
  gun, ammo, stream
}

