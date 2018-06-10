local path = util.path("data/classes/sniper/")
local sniper = util.base_player()
sniper.name = names.sniper
sniper.running_speed = util.speed(1)
sniper.max_health = 125
local scale = 1.2
util.recursive_hack_scale(sniper, scale)
util.scale_boxes(sniper, scale)

local sniper_gun = util.copy(data.raw.gun.railgun)
sniper_gun.name = "sniper-gun"
sniper_gun.icon = path.."sniper-gun.png"
sniper_gun.icon_size = 512
sniper_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("sniper-ammo"),
  cooldown = SU(1.5 * 60),
  movement_slow_down_factor = 0.73,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."sniper-gun.ogg",
      volume = 1
    }
  }
}
sniper_gun.stack_size = 1

local sniper_ammo = util.copy(data.raw.ammo["railgun-dart"])
sniper_ammo.name = "sniper-ammo"
sniper_ammo.stack_size = 25
sniper_ammo.magazine_size = 1
sniper_ammo.ammo_type =
{
  category = util.ammo_category("sniper-ammo"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    type = "line",
    range = 55,
    width = 0.5,
    force = "not-same",
    source_effects =
    {
      type = "create-explosion",
      entity_name = "railgun-beam"
    },
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        type = "damage",
        damage = { amount = 100, type= util.damage_type("sniper-gun")}
      }
    }
  }
}

local sniper_smg_gun = util.copy(sniper_gun)
sniper_smg_gun.name = "sniper-smg"
sniper_smg_gun.icon = path.."sniper-smg.png"
sniper_smg_gun.icon_size = 512
sniper_smg_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("sniper-smg"),
  cooldown = SU(6),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 0.6,
  range = 40,
  sound =
  {
    {
      filename = path.."sniper-smg.ogg",
      volume = 1
    }
  }
}
sniper_smg_gun.stack_size = 1

local sniper_smg_ammo = util.copy(sniper_ammo)
sniper_smg_ammo.name = "sniper-smg-ammo"
sniper_smg_ammo.magazine_size = 25
sniper_smg_ammo.stack_size = 75 / 25
sniper_smg_ammo.reload_time = SU(60)
sniper_smg_ammo.ammo_type =
{
  category = util.ammo_category("sniper-smg"),
  target_type = "direction",
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    {
      type = "direct",
      action_delivery =
      {
        type = "projectile",
        projectile = "sniper-smg-projectile",
        starting_speed = SD(1),
        direction_deviation = 0.01,
        range_deviation = 0.01,
        max_range = 40
      }
    }
  }
}

local sniper_smg_projectile = util.copy(data.raw.projectile["cannon-projectile"])
sniper_smg_projectile.name = "sniper-smg-projectile"
sniper_smg_projectile.piercing_damage = 0
sniper_smg_projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-explosion",
        entity_name = "explosion-hit"
      }
    }
  }
}
sniper_smg_projectile.final_action = 
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
        damage = {amount = 8 , type = util.damage_type("sniper-smg")}
      }
    }
  }
}



data:extend
{
  sniper,
  sniper_gun,
  sniper_ammo,
  sniper_smg_gun,
  sniper_smg_ammo,
  sniper_smg_projectile
}