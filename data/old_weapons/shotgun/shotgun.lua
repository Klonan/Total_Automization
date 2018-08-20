
local path = util.path("data/weapons/shotgun/")
local gun = util.base_gun(names.shotgun)
gun.icon = path.."shotgun.png"
gun.icon_size = 512
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "shotgun-shell",
  cooldown = SU(37.5),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 35,
  sound =
  {
    {
      filename = path.."shotgun_shoot.ogg"
    }
  }
}

local make_shotgun_blast = function(speed, direction, range, count)
  return
  {
    type = "direct",
    repeat_count = count or 1,
    action_delivery =
    {
      type = "projectile",
      projectile = names.shotgun.." Projectile",
      starting_speed = SD(speed),
      direction_deviation = direction,
      range_deviation = range,
      max_range = 35
    }
  }
end

local ammo = util.base_ammo(names.shotgun)
ammo.icon = path.."shotgun_ammo.png"
ammo.icon_size = 256
ammo.reload_time = SU(210 - 37.5)
ammo.magazine_size = 6
ammo.stack_size = 32 / 6
ammo.ammo_type =
{
  category = "shotgun-shell",
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
    make_shotgun_blast(0.80, 0.40, 0.10, 1),
    make_shotgun_blast(0.85, 0.35, 0.15, 1),
    make_shotgun_blast(0.90, 0.30, 0.20, 1),
    make_shotgun_blast(0.95, 0.25, 0.25, 1),
    make_shotgun_blast(1.00, 0.20, 0.30, 2),
    make_shotgun_blast(1.05, 0.15, 0.25, 1),
    make_shotgun_blast(1.10, 0.10, 0.20, 1),
    make_shotgun_blast(1.15, 0.05, 0.15, 1),
    make_shotgun_blast(1.20, 0.00, 0.10, 1)
  }
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = names.shotgun.." Projectile"
projectile.force_condition = "not-same"
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 6 , type = util.damage_type("shotgun")}
      },
      {
        type = "create-explosion",
        entity_name = "explosion-hit"
      },
    }
  }
}
projectile.acceleration = 0 --0.001

data:extend{gun, ammo, projectile}
