local path = util.path("data/weapons/rocket_launcher/")
local gun = util.base_gun(names.rocket_launcher)
gun.icon = path.."rocket_launcher.png"
gun.icon_size = 512
gun.stack_size = 1
gun.attack_parameters =
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
      filename = path.."rocket_launcher_shoot.ogg"
    }
  }
}

local ammo = util.base_ammo(names.rocket_launcher)
ammo.magazine_size = 4
ammo.stack_size = 20 / 4
ammo.reload_time = SU(200 - 48)
ammo.icon = path.."rocket_launcher_ammo.png"
ammo.icon_size = 1106
ammo.ammo_type =
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
      projectile = names.rocket_launcher.." Projectile",
      starting_speed = SD(0.35),
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile.rocket)
projectile.name = names.rocket_launcher.." Projectile"
projectile.acceleration = SD(0)
projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
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
        type = "create-entity",
        entity_name = "big-explosion"
      },
      {
        type = "damage",
        damage = {amount = 45, type = util.damage_type("solider-rocket-hit")}
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

data:extend{gun, ammo, projectile}
