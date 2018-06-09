local path = util.path("data/medic/")

local medic = util.base_player()
medic.name = "medic"
medic.running_speed = util.speed(1.07)

local medic_gun = util.copy(data.raw.gun["submachine-gun"])
medic_gun.name = "medic-gun"
medic_gun.icon = path.."medic-gun.png"
medic_gun.icon_size = 512
medic_gun.stack_size = 1
medic_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("medic-ammo"),
  cooldown = SU(1),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 20,
  --sound = make_light_gunshot_sounds(),
  cyclic_sound =
  {
    begin_sound =
    {
      {
        filename = path.."medic-gun.ogg",
        volume = 0.7
      }
    },
    middle_sound =
    {
      util.empty_sound()
    },
    end_sound =
    {
      util.empty_sound()
    }
  }
}

local medic_beam = util.copy(data.raw.beam["electric-beam"])
util.recursive_hack_tint(medic_beam, {g = 1})
medic_beam.name = "medic-beam"
medic_beam.damage_interval = SU(1)
medic_beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "nested-result",
        affects_target = true,
        action =
        {
          type = "area",
          radius = 4,
          force = "same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = { amount = -0.8, type = util.damage_type("medic-beam")}
              }
            }
          }
        },
      },
    }
  }
}

local medic_ammo_category = 
{
  type = "ammo-category",
  name = "medic-ammo",
}

local medic_ammo = util.copy(data.raw.ammo["firearm-magazine"])
medic_ammo.name = "medic-ammo"
medic_ammo.icon = path.."medic-ammo.png"
medic_ammo.icon_size = 825
medic_ammo.stack_size = 1
medic_ammo.magazine_size = 1
medic_ammo.ammo_type =
{
  category = util.ammo_category("medic-ammo"),
  consumption_modifier = 0, --This means, it doesn't use any ammo
  target_type = "position",
  clamp_position = true,
  action =
  {
    force = "same",
    type = "direct",
    action_delivery =
    {
      type = "beam",
      beam = "medic-beam",
      add_to_shooter = false,
      max_length = 30,
      duration = SU(2),
      source_offset = {0, -1},
    }
  }
}

local medic_needle_gun = util.copy(data.raw.gun["submachine-gun"])
medic_needle_gun.name = "medic-needle-gun"
medic_needle_gun.icon = path.."medic-needle-gun.png"
medic_needle_gun.icon_size = 512
medic_needle_gun.stack_size = 1
medic_needle_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("medic-needle-gun"),
  cooldown = SU(6),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  --projectile_center = {0, -1},
  range = 25,
  sound =
  {
    {
      filename = path.."medic-needle-gunl.ogg",
      volume = 1
    }
  }
}

medic_needle_ammo = util.copy(data.raw.ammo["firearm-magazine"])
medic_needle_ammo.name = "medic-needle-ammo"
medic_needle_ammo.icon = path.."medic-needle-ammo.png"
medic_needle_ammo.icon_size = 90
medic_needle_ammo.magazine_size = 40
medic_needle_ammo.stack_size = 160 / 40
medic_needle_ammo.reload_time = SU(96 - 6)
medic_needle_ammo.ammo_type =
{
  category = util.ammo_category("medic-needle-gun"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = "medic-needle-projectile",
        starting_speed = SD(0.31),
        direction_deviation = 0.02,
        range_deviation = 0.02,
        max_range = 25
      }
    }
  }
}

medic_needle_projectile = util.copy(data.raw.projectile["shotgun-pellet"])
medic_needle_projectile.name = "medic-needle-projectile"
medic_needle_projectile.action = nil
--medic_needle_projectile.height = 0 -- Not merged
medic_needle_projectile.final_action =
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
          damage = { amount = 10, type = util.damage_type("medic-needle-gun")}
        }
      }
    }
  }
}
medic_needle_projectile.animation =
{
  filename = path.."medic-projectile.png",
  frame_count = 1,
  width = 17,
  height = 119,
  scale = 0.4,
  priority = "high"
}

data:extend{
  medic,
  medic_gun,
  medic_ammo,
  medic_beam,
  medic_needle_gun,
  medic_needle_ammo,
  medic_needle_projectile
}

