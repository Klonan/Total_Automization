local path = util.path("data/weapons/stickybomb_launcher/")
local gun = util.base_gun(names.stickybomb_launcher)
gun.icon = path.."stickybomb_launcher.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("demoman-sticky-bomb"),
  movement_slow_down_factor = 0.3,
  cooldown = SU(36),
  projectile_creation_distance = 0.6,
  range = 35,
  projectile_center = {-0.17, 0},
  gun_center_shift = { 0, -1 },
  sound =
  {
    {
      filename = path.."stickybomb_launcher_shoot.ogg",
      volume = 1
    }
  }
}


local ammo = util.base_ammo(names.stickybomb_launcher)
ammo.icon = path.."stickybomb_launcher_ammo.png"
ammo.icon_size = 512
ammo.magazine_size = 8
ammo.stack_size = 24 / 8
ammo.reload_time = SU(346 - 36)

ammo.ammo_type = 
{
  source_type = "default",
  category = util.ammo_category("demoman-sticky-bomb"),
  target_type = "position",
  clamp_position = true,

  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = names.stickybomb_launcher.." Stream",
      max_length = 50,
      duration = SU(160),
      source_offset = {0, -1},
      direction_deviation = 0.3,
      range_deviation = 0.3,
    }
  }
}

local stream = 
{
  type = "stream",
  name = names.stickybomb_launcher.." Stream",
  flags = {},--"not-on-map"},

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
            entity_name = names.stickybomb_launcher .. " Mine",
            trigger_created_entity = true
          }
        }
      }
    }
  },

  spine_animation =
  {
    filename = path.."stickybomb_launcher_stream.png",
    --tint = {r=1, g=1, b=1, a=1},
    line_length = 1,
    width = 32,
    height = 32,
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

local mine = util.copy(data.raw["land-mine"]["land-mine"])
mine.name = names.stickybomb_launcher .. " Mine"
util.add_flag(mine, "not-deconstructable")
util.add_flag(mine, "not-blueprintable")
util.add_flag(mine, "not-repairable")
mine.dying_explosion = "explosion"
mine.picture_set =
{
  filename = path.."stickybomb_launcher_ammo.png",
  priority = "medium",
  width = 512,
  height = 512,
  scale = 0.06
}
mine.picture_set_enemy = mine.picture_set
mine.picture_safe = mine.picture_set
mine.timeout = SU(0.7 * 60)
mine.alert_when_damaged = false
mine.order = "mine"
mine.corpse = nil
mine.trigger_radius = 2.5
mine.ammo_category = util.ammo_category("demoman-sticky-bomb-mine")
mine.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    source_effects =
    {
      {
        type = "nested-result",
        affects_target = true,
        action =
        {
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
                  damage = { amount = 40, type = util.damage_type("demoman-sticky") }
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
                  damage = { amount = 80, type = util.damage_type("demoman-sticky") }
                }
              }
            }
          }
        },
      },
      {
        type = "create-entity",
        entity_name = "explosion"
      }
    }
  }
}

data:extend
{
  gun,
  ammo,
  stream,
  mine
}
