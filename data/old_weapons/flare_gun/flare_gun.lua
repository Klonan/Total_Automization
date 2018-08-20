local path = util.path("data/weapons/flare_gun/")

gun = util.base_gun(names.flare_gun)
gun.icon = path.."flare_gun.png"
gun.icon_size = 512
gun.attack_parameters =
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
      filename = path.."flare_gun_shoot.ogg",
      volume = 1
    }
  }
}

ammo = util.base_ammo(names.flare_gun)
ammo.icon = path.."flare_gun_ammo.png"
ammo.icon_size = 512
ammo.stack_size = 16
ammo.ammo_type = 
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
      stream = names.flare_gun.." Stream",
      max_length = 45,
      duration = SU(160),
    }
  }
}

fire = util.copy(data.raw.fire["fire-flame"])
fire.name = names.flare_gun.." Flame"
fire.localised_name = names.flare_gun.." Flame"
fire.damage_per_tick = {amount = SD(3/60), type = "fire"}
fire.maximum_damage_multiplier = 1
fire.damage_multiplier_increase_per_added_fuel = 0
fire.damage_multiplier_decrease_per_tick = 0
fire.spawn_entity = "fire-flame-on-tree"
fire.spread_delay = SU(300)
fire.spread_delay_deviation = SU(180)
fire.maximum_spread_count = 100
fire.flame_alpha = 0.35
fire.flame_alpha_deviation = 0.05
fire.emissions_per_tick = SD(0.005)
fire.add_fuel_cooldown = SU(10)
fire.fade_in_duration = SU(30)
fire.fade_out_duration = SU(30)
fire.initial_lifetime = SU(300)
fire.lifetime_increase_by = SU(150)
fire.lifetime_increase_cooldown = SU(4)
fire.maximum_lifetime = SU(1800)
fire.delay_between_initial_flames = SU(10)
fire.initial_flame_count = 1
fire.burnt_patch_lifetime = SU(1800)

stream = 
{
  type = "stream",
  name = names.flare_gun.." Stream",
  localised_name = names.flare_gun.." Stream",
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
            entity_name = names.flare_gun.." Flame",
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
            sticker = "Afterburn Sticker"
          },
          {
            type = "create-fire",
            entity_name = names.flare_gun.." Flame",
            initial_ground_flame_count = 3,
          }
        }
      }
    },
  },

  spine_animation =
  {
    filename = path.."flare_gun_stream.png",
    --tint = {r=1, g=1, b=1, a=1},
    line_length = 1,
    width = 32,
    height = 13,
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
  gun, ammo, fire, stream
}