local path = util.path("data/weapons/minigun/")
gun = util.base_gun(names.minigun)
gun.stack_size = 1
gun.icon = path.."minigun.png"
gun.icon_size = 512
gun.attack_parameters =
{
  type = "projectile",
  ammo_category = util.ammo_category("heavy-gun"),
  cooldown = SU(6),
  movement_slow_down_factor = 0.66,
  movement_slow_down_cooldown = SU(60 * 3),
  projectile_creation_distance = 1.125,
  range = 40,
  cyclic_sound =
  {
    begin_sound =
    {
      util.empty_sound()
    },
    middle_sound =
    {
      {
        filename = path.."minigun_shoot_mid.ogg"
      }
    },
    end_sound =
    {
      {
        filename = path.."minigun_shoot_end.ogg"
      }
    }
  }
}

ammo = util.base_ammo(names.minigun)
ammo.icon = path.."minigun_ammo.png"
ammo.icon_size = 512
ammo.stack_size = 200
ammo.magazine_size = 1

local make_bullet = function(speed, spread, range)
  return
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = names.minigun.." Projectile",
      starting_speed = SD(speed),
      direction_deviation = spread,
      range_deviation = range,
      max_range = 40
    }
  }
end

ammo.ammo_type =
{
  category = util.ammo_category("heavy-gun"),
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
    make_bullet(1.33, 0.05, 0.05),
    --make_bullet(1.1, 0.05, 0.05),
    --make_bullet(1.2, 0.05, 0.05),
  }
}

projectile = util.copy(data.raw.projectile["cannon-projectile"])
projectile.name = names.minigun.." Projectile"
projectile.piercing_damage = 0
projectile.action =
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
projectile.final_action = 
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
        damage = {amount = 9 , type = util.damage_type("heavy-projectile")}
      }
    }
  }
}

data:extend{gun, ammo, projectile}

