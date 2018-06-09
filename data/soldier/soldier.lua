path = util.path("data/soldier/")
local soldier = util.base_player()
soldier.name = "soldier"
soldier.running_speed = util.speed(0.8)
soldier.max_health = 200
local scale = 1.3
util.recursive_hack_scale(soldier, scale)
util.scale_boxes(soldier, scale)

local soldier_gun = util.copy(data.raw.gun["rocket-launcher"])
soldier_gun.name = "soldier-gun"
soldier_gun.icon = path.."soldier-gun.png"
soldier_gun.icon_size = 66
soldier_gun.stack_size = 1
soldier_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("soldier-rocket"),
  movement_slow_down_factor = 0.3,
  cooldown = SU(48),
  projectile_creation_distance = 0.6,
  range = 45,
  projectile_center = {-0.17, 0},
  sound =
  {
    {
      filename = path.."soldier-gun.ogg",
      volume = 0.7
    }
  }
}

local soldier_ammo = util.copy(data.raw.ammo.rocket)
soldier_ammo.name = "soldier-ammo"
soldier_ammo.magazine_size = 4
soldier_ammo.stack_size = 20 / 4
soldier_ammo.reload_time = SU(200 - 48)
soldier_ammo.ammo_type =
{
  category = util.ammo_category("soldier-rocket"),
  target_type = "position",
  clamp_position = true,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "soldier-rocket",
      starting_speed = SD(0.35),
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local soldier_rocket = util.copy(data.raw.projectile.rocket)
soldier_rocket.name = "soldier-rocket"
soldier_rocket.acceleration = SD(0)
soldier_rocket.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
soldier_rocket.action =
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
        type = "nested-result",
        action =
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
                damage = {amount = 45, type = util.damage_type("solider-rocket-hit")}
              }
            }
          }
        }
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 3,
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 45, type = util.damage_type("soldier-rocket-explosion")}
              },
              {
                type = "create-entity",
                entity_name = "explosion"
              }
            }
          }
        }
      }
    }
  }
}



data:extend
{
  soldier,
  soldier_ammo,
  soldier_gun,
  soldier_rocket
}





