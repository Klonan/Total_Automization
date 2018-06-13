local path = util.path("data/weapons/flamethrower/")
gun = util.base_gun(names.flamethrower)
gun.icon = path.."flamethrower.png"
gun.icon_size = 512
gun.stack_size = 1
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("pyro-fire"),
  cooldown = SU(2.64),
  movement_slow_down_factor = 0,
  projectile_creation_distance = 1.125,
  range = 40, 
  cyclic_sound =
  {
    begin_sound =
    {
      {
        filename = path.."flamethrower_shoot_start.ogg",
        volume = 1
      }
    },
    middle_sound =
    {
      {
        filename = path.."flamethrower_shoot_mid.ogg",
        volume = 1
      }
    },
    end_sound =
    {
      {
        filename = path.."flamethrower_shoot_end.ogg",
        volume = 1
      }
    }
  }
}

ammo = util.base_ammo(names.flamethrower)
ammo.icon = path.."flamethrower_ammo.png"
ammo.icon_size = 540
ammo.magazine_size = 1
ammo.stack_size = 200

local fire = require("data/tf_util/tf_fire_util")
local sprites = fire.create_fire_pictures({animation_speed = SD(0.5), scale = 0.8})
local index = 0
local sprite = function()
  index = index + 1
  return sprites[index]
end
local base = data.raw.projectile["shotgun-pellet"]
local make_fire = function(name, n)
  pyro_fire_projectile = util.copy(base)
  pyro_fire_projectile.name = name
  pyro_fire_projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
  pyro_fire_projectile.action = nil
  pyro_fire_projectile.final_action = 
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
            damage = {amount = 2 , type = util.damage_type("pyro-fire")}
          },
          {
            type = "create-sticker",
            sticker = "Afterburn Sticker"
          }
        }
      }
    }
  }
  pyro_fire_projectile.animation = sprite()
  data:extend({pyro_fire_projectile})
  return
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = name,
      starting_speed = SD(0.4) + (0.1 / n),
      direction_deviation = 0.1 * n,
      range_deviation = 0.2 * n,
      starting_frame_deviation = 5,
      max_range = 25 - (n * 2)
    }
  }

end

ammo.ammo_type =
{
  category = util.ammo_category("pyro-fire"),
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
    make_fire("pyro-fire-projectile-1", 1),
    make_fire("pyro-fire-projectile-2", 1.5),
    make_fire("pyro-fire-projectile-3", 2),
    make_fire("pyro-fire-projectile-4", 2.5),
    make_fire("pyro-fire-projectile-5", 3),
    make_fire("pyro-fire-projectile-6", 3.5)
  }
}

data:extend
{
  gun, ammo
}