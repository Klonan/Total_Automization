local path = util.path("data/medic/")

local medic = util.base_player()
medic.name = "medic"
medic.running_speed = util.speed(1.07)

local medic_gun = util.copy(data.raw.gun["submachine-gun"])
medic_gun.name = "medic-gun"
medic_gun.icon = path.."medic-gun.png"
medic_gun.icon_size = 328
medic_gun.stack_size = 1
medic_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "medic-ammo",
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

medic_beam_catagory = 
{
  type = "damage-type",
  name = "medic-beam"
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
          force = "ally",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = { amount = -0.15, type = "medic-beam"}
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
medic_ammo.magazine_size = 999999
medic_ammo.ammo_type =
{
  category = "medic-ammo",
  target_type = "position",
  clamp_position = true,
  action =
  {
    force = "ally",
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

local medic_needle_category = 
{
  type = "ammo-category",
  name = "medic-needle-category"
}

local medic_needle_gun = util.copy(data.raw.gun["submachine-gun"])
medic_needle_gun.name = "medic-needle-gun"
medic_needle_gun.icon = path.."medic-needle-gun.png"
medic_needle_gun.icon_size = 65
medic_needle_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "medic-needle-category",
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
medic_needle_ammo.ammo_type =
{
  category = "medic-needle-category",
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
        starting_speed = SD(1),
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
    force = "enemy",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = { amount = 6, type = "physical"}
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
  medic_ammo_category,
  medic_beam,
  medic_beam_catagory,
  medic_needle_gun,
  medic_needle_category,
  medic_needle_ammo,
  medic_needle_projectile
}

