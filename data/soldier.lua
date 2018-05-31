local soldier = util.base_player()
soldier.name = "soldier"
soldier.running_speed = SD(0.2)
local scale = 1.3
util.recursive_hack_scale(soldier, scale)
util.scale_boxes(soldier, scale)

local soldier_gun = util.copy(data.raw.gun["rocket-launcher"])
soldier_gun.name = "soldier-gun"
soldier_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "rocket",
  movement_slow_down_factor = 0.3,
  cooldown = SU(35),
  projectile_creation_distance = 0.6,
  range = 35,
  projectile_center = {-0.17, 0},
  sound =
  {
    {
      filename = "__base__/sound/fight/rocket-launcher.ogg",
      volume = 0.7
    }
  }
}

local soldier_ammo = util.copy(data.raw.ammo.rocket)
soldier_ammo.name = "soldier-ammo"
soldier_ammo.ammo_type =
{
  category = "rocket",
  target_type = "direction",
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "soldier-rocket",
      starting_speed = SD(0.6),
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
  soldier,
  soldier_ammo,
  soldier_gun,
  soldier_rocket
}





