if true then return end

local path = util.path("data/classes/demoman/")
local demoman = util.base_player()
demoman.name = names.demoman
demoman.running_speed = util.speed(0.93)
local scale = 1.6
util.recursive_hack_scale(demoman, scale)
util.scale_boxes(demoman, scale)


local demoman_sticky_gun = util.base_gun("deom")
demoman_sticky_gun.name = "demoman-sticky-gun"
demoman_sticky_gun.icon = path.."demoman-sticky-gun.png"
demoman_sticky_gun.icon_size = 512
demoman_sticky_gun.attack_parameters =
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
      filename = path.."demoman-gun-1.ogg",
      volume = 1
    },
    {
      filename = path.."demoman-gun-2.ogg",
      volume = 1
    },
  }
}


local demoman_sticky_ammo = util.base_ammo("hon")
demoman_sticky_ammo.name = "demoman-sticky-ammo"
demoman_sticky_ammo.icon = path.."demoman-stream-2.png"
demoman_sticky_ammo.icon_size = 32
demoman_sticky_ammo.magazine_size = 8
demoman_sticky_ammo.stack_size = 24 / 8
demoman_sticky_ammo.reload_time = SU(346 - 36)

demoman_sticky_ammo.ammo_type = 
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
      stream = "demoman-sticky-stream",
      max_length = 50,
      duration = 160,
      source_offset = {0, -1},
      direction_deviation = 0.3,
      range_deviation = 0.3,
    }
  }
}

local demoman_sticky_stream = util.copy()
demoman_sticky_stream.name = "demoman-sticky-stream"
demoman_sticky_stream.action =
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
          entity_name = "demoman-sticky-bomb"
        }
      }
    }
  }
}
demoman_sticky_stream.spine_animation =
{
  filename = path.."demoman-stream-2.png",
  --tint = {r=1, g=1, b=1, a=1},
  line_length = 1,
  width = 32,
  height = 32,
  frame_count = 1,
  scale = 1
}

local demoman_sticky_bomb = util.copy(data.raw["land-mine"]["land-mine"])
demoman_sticky_bomb.name = "demoman-sticky-bomb"
util.add_flag(demoman, "not-deconstructable")
util.add_flag(demoman, "not-blueprintable")
util.add_flag(demoman, "not-repairable")
demoman_sticky_bomb.dying_explosion = "explosion"
demoman_sticky_bomb.picture_set =
{
  filename = path.."demoman-sticky-bomb.png",
  priority = "medium",
  width = 483,
  height = 479,
  scale = 0.06
}
demoman_sticky_bomb.picture_set_enemy = demoman_sticky_bomb.picture_set
demoman_sticky_bomb.picture_safe = demoman_sticky_bomb.picture_set
demoman_sticky_bomb.timeout = SU(1 * 60)
demoman_sticky_bomb.alert_when_damaged = false
demoman_sticky_bomb.order = "demoman"
demoman_sticky_bomb.corpse = nil
demoman_sticky_bomb.trigger_radius = 2.5
demoman_sticky_bomb.ammo_category = util.ammo_category("demoman-sticky-bomb-mine")
demoman_sticky_bomb.action =
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





local demoman_rocket = util.copy(data.raw.projectile.rocket)
demoman_rocket.name = "demoman-rocket"
demoman_rocket.acceleration = 0
demoman_rocket.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
demoman_rocket.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = "big-explosion"
      },
      {
        type = "damage",
        damage = {amount = 100, type = "explosion"}
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 3.5,
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 20, type = "explosion"}
              },
              {
                type = "create-entity",
                entity_name = "explosion"
              }
            }
          }
        },
      }
    }
  }
},



data:extend
{
  demoman,
  demoman_ammo,
  demoman_gun,
  demoman_rocket,
  demoman_stream,
  demoman_sticky_ammo,
  demoman_sticky_gun,
  demoman_sticky_stream,
  demoman_sticky_bomb
}





