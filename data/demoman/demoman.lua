local demoman = util.base_player()
demoman.name = "demoman"
demoman.running_speed = SD(0.16)
local scale = 1.6
util.recursive_hack_scale(demoman, scale)
util.scale_boxes(demoman, scale)

local demoman_gun = util.copy(data.raw.gun["rocket-launcher"])
demoman_gun.name = "demoman-gun"
demoman_gun.icon = "__Team_Factory__/data/demoman/demoman-gun.png"
demoman_gun.icon_size = 83
demoman_gun.stack_size = 1

demoman_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "demoman-grenade",
  movement_slow_down_factor = 0.3,
  cooldown = SU(35),
  projectile_creation_distance = 0.6,
  range = 35,
  projectile_center = {-0.17, 0},
  gun_center_shift = { 0, -1 },
  sound =
  {
    {
      filename = "__Team_Factory__/data/demoman/demoman-gun-1.ogg",
      volume = 1
    },
    {
      filename = "__Team_Factory__/data/demoman/demoman-gun-2.ogg",
      volume = 1
    },
  }
}

local demoman_grenade_category = 
{
  type = "ammo-category",
  name = "demoman-grenade",
}

local demoman_ammo = util.copy(data.raw.ammo.rocket)
demoman_ammo.name = "demoman-ammo"
demoman_ammo.icon = "__Team_Factory__/data/demoman/demoman-bomb.png"
demoman_ammo.icon_size = 414
demoman_ammo.ammo_type = 
{
  source_type = "default",
  category = "demoman-grenade",
  target_type = "position",
  clamp_position = true,

  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "stream",
      stream = "demoman-stream",
      max_length = 50,
      duration = 160,
    }
  }
}


local demoman_sticky_category = 
{
  type = "ammo-category",
  name = "demoman-sticky",
}

local demoman_sticky_gun = util.copy(demoman_gun)
demoman_sticky_gun.name = "demoman-sticky-gun"
demoman_sticky_gun.icon = "__Team_Factory__/data/demoman/demoman-sticky-gun.png"
demoman_sticky_gun.icon_size = 65
demoman_sticky_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "demoman-sticky",
  movement_slow_down_factor = 0.3,
  cooldown = SU(35),
  projectile_creation_distance = 0.6,
  range = 35,
  projectile_center = {-0.17, 0},
  gun_center_shift = { 0, -1 },
  sound =
  {
    {
      filename = "__Team_Factory__/data/demoman/demoman-gun-1.ogg",
      volume = 1
    },
    {
      filename = "__Team_Factory__/data/demoman/demoman-gun-2.ogg",
      volume = 1
    },
  }
}


local demoman_sticky_ammo = util.copy(demoman_ammo)
demoman_sticky_ammo.name = "demoman-sticky-ammo"
demoman_sticky_ammo.icon = "__Team_Factory__/data/demoman/demoman-stream-2.png"
demoman_sticky_ammo.icon_size = 32
demoman_sticky_ammo.ammo_type = 
{
  source_type = "default",
  category = "demoman-sticky",
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
      direction_deviation = 0.3,
      range_deviation = 0.3,
    }
  }
}


demoman_stream = 
{
  type = "stream",
  name = "demoman-stream",
  flags = {"not-on-map"},

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
      radius = 5,
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 40, type = "explosion" }
          },
          {
            type = "create-entity",
            entity_name = "explosion"
          }
        }
      }
    }
  },

  spine_animation =
  {
    filename = "__Team_Factory__/data/demoman/demoman-bomb-2.png",
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

local demoman_sticky_stream = util.copy(demoman_stream)
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
  filename = "__Team_Factory__/data/demoman/demoman-stream-2.png",
  --tint = {r=1, g=1, b=1, a=1},
  line_length = 1,
  width = 32,
  height = 32,
  frame_count = 1,
  scale = 1
}

local demoman_sticky_bomb = util.copy(data.raw["land-mine"]["land-mine"])
demoman_sticky_bomb.name = "demoman-sticky-bomb"
demoman_sticky_bomb.picture_set =
{
  filename = "__Team_Factory__/data/demoman/demoman-sticky-bomb.png",
  priority = "medium",
  width = 483,
  height = 479,
  scale = 0.06
}
demoman_sticky_bomb.picture_set_enemy = demoman_sticky_bomb.picture_set
demoman_sticky_bomb.timeout = 0
demoman_sticky_bomb.order = "demoman"
demoman_sticky_bomb.corpse = nil
demoman_sticky_bomb.trigger_radius = 2.5
demoman_sticky_bomb.ammo_category = "landmine"
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
          type = "area",
          radius = 4,
          force = "enemy",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = { amount = 30, type = "explosion"}
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
  demoman_sticky_category,
  demoman_grenade_category,
  demoman_sticky_ammo,
  demoman_sticky_gun,
  demoman_sticky_stream,
  demoman_sticky_bomb
}





