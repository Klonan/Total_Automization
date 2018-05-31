local medic = util.base_player()
medic.name = "medic"
medic.running_speed = SD(0.15)

local medic_gun = util.copy(data.raw.gun["submachine-gun"])
medic_gun.name = "medic-gun"
medic_gun.icon = "__Team_Factory__/data/medic/medic-gun.png"
medic_gun.icon_size = 328
medic_gun.stack_size = 1
medic_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "medic-ammo",
  cooldown = SU(6),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 20,
  --sound = make_light_gunshot_sounds(),
}

local medic_beam = util.copy(data.raw.beam["electric-beam"])
util.recursive_hack_tint(medic_beam, {g = 1})
medic_beam.name = "medic-beam"
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
                damage = { amount = -6, type = "physical"}
              },
              --{
              --  type = "create-sticker",
              --  sticker = "stun-sticker"
              --}
            }
          }
        },
      },
    }
  }
}

local medic_ammo = util.copy(data.raw.ammo["firearm-magazine"])
medic_ammo.name = "medic-ammo"
medic_ammo.icon = "__Team_Factory__/data/medic/medic-ammo.png"
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
      duration = SU(12),
      source_offset = {0.15, -0.5},
    }
  }
}


data:extend{
  {
    type = "ammo-category",
    name = "medic-ammo",
  },
  medic,
  medic_beam,
  medic_gun,
  medic_ammo
}

