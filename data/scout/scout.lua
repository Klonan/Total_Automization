local scout = util.base_player()
scout.name = "scout"
local scale = 0.8
util.recursive_hack_scale(scout, scale)
util.scale_boxes(scout, scale)
scout.running_speed = util.speed(1.33)

local scout_gun = util.copy(data.raw.gun.shotgun)
scout_gun.name = "scout-gun"
scout_gun.icon = "__Team_Factory__/data/scout/scout-gun.png"
scout_gun.icon_size = 512
scout_gun.stack_size = 1
scout_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "shotgun-shell",
  cooldown = SU(37.5),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 35,
  min_range = 1,
  sound =
  {
    {
      filename = "__base__/sound/pump-shotgun.ogg",
      volume = 0.5
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
      projectile = "scout-projectile",
      starting_speed = SD(speed),
      direction_deviation = direction,
      range_deviation = range,
      max_range = 35
    }
  }
end

local scout_ammo = util.copy(data.raw.ammo["shotgun-shell"])
scout_ammo.name = "scout-ammo"
scout_ammo.reload_time = SU(213.6 - 37.5) --TODO make it POP POP
scout_ammo.magazine_size = 6
scout_ammo.ammo_type =
{
  category = "shotgun-shell",
  target_type = "direction",
  clamp_position = true,
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
    make_shotgun_blast(1.00, 0.20, 0.30, 1),
    make_shotgun_blast(1.05, 0.15, 0.25, 1),
    make_shotgun_blast(1.10, 0.10, 0.20, 1),
    make_shotgun_blast(1.15, 0.05, 0.15, 1),
    make_shotgun_blast(1.20, 0.00, 0.10, 1)
  }
}

local scout_projectile = util.copy(data.raw.projectile["shotgun-pellet"])
scout_projectile.name = "scout-projectile"
scout_projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 6 , type = util.damage_type("scout-shotgun")}
      },
      {
        type = "create-explosion",
        entity_name = "explosion-hit"
      },
    }
  }
}
scout_projectile.acceleration = 0 --0.001


data:extend
{
  scout,
  scout_ammo,
  scout_gun,
  scout_projectile
}





