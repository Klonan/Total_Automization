local path = util.path("data/weapons/medi_gun/")
local gun = util.base_gun(names.medi_gun)
gun.icon = path.."medi_gun.png"
gun.icon_size = 512
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("medic-ammo"),
  cooldown = SU(1),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 20,
  cyclic_sound =
  {
    begin_sound =
    {
      {
        filename = path.."medi_gun_shoot.ogg"
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

local beam = util.copy(data.raw.beam["electric-beam"])
util.recursive_hack_tint(beam, {g = 1})
beam.name = names.medi_gun.." Beam"
beam.localised_name = names.medi_gun.." Beam"
beam.damage_interval = SU(1)
beam.action =
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
              },
              {
                type = "create-sticker",
                sticker = "Healing Sticker"
              }
            }
          }
        },
      },
    }
  }
}

local ammo = util.base_ammo(names.medi_gun)
ammo.icon = path.."medi_gun_ammo.png"
ammo.icon_size = 825
ammo.stack_size = 1
ammo.magazine_size = 1
ammo.ammo_type =
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
      beam = names.medi_gun.." Beam",
      add_to_shooter = false,
      max_length = 30,
      duration = SU(2),
      source_offset = {0, -1},
    }
  }
}

data:extend{gun, ammo, beam}