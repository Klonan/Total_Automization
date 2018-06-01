local heavy = util.base_player()
heavy.name = "heavy"
heavy.running_speed = SD(0.15)
local scale = 1.8
util.recursive_hack_scale(heavy, scale)
util.scale_boxes(heavy, scale)


heavy_gun = util.copy(data.raw.gun["submachine-gun"])
heavy_gun.name = "heavy-gun"
heavy_gun.stack_size = 1
heavy_gun.icon = "__Team_Factory__/data/heavy/heavy-gun.png"
heavy_gun.icon_size = 72
heavy_gun.attack_parameters =
{
  type = "projectile",
  ammo_category = "bullet",
  cooldown = SU(4),
  movement_slow_down_factor = 0.66,
  movement_slow_down_cooldown = SU(60 * 3),
  shell_particle =
  {
    name = "heavy-shell-particle",
    direction_deviation = 1,
    speed = SD(0.2),
    speed_deviation = SD(0.05),
    center = {0, 0.1},
    creation_distance = -0.5,
    starting_frame_speed = 0.4,
    starting_frame_speed_deviation = 0.1
  },
  projectile_creation_distance = 1.125,
  range = 40,
  cyclic_sound =
  {
    begin_sound =
    {
      {
        filename = "__Team_Factory__/data/empty-sound.ogg",
        volume = 0.7
      }
    },
    middle_sound =
    {
      {
        filename = "__Team_Factory__/data/heavy/heavy-gun-mid.ogg",
        volume = 0.7
      }
    },
    end_sound =
    {
      {
        filename = "__Team_Factory__/data/heavy/heavy-gun-end.ogg",
        volume = 0.7
      }
    }
  }
}

heavy_shell = util.copy(data.raw.particle["shell-particle"])
heavy_shell.name = "heavy-shell-particle"
util.recursive_hack_scale(heavy_shell, 2)

heavy_ammo = util.copy(data.raw.ammo["firearm-magazine"])
heavy_ammo.name = "heavy-ammo"

local make_bullet = function(speed, spread, range)
  return
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "heavy-projectile",
      starting_speed = SD(speed),
      direction_deviation = spread,
      range_deviation = range,
      max_range = 40
    }
  }
end

heavy_ammo.ammo_type =
{
  category = "bullet",
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
    make_bullet(1, 0.05, 0.05),
    make_bullet(1.1, 0.05, 0.05),
    make_bullet(1.2, 0.05, 0.05),

  }
}
heavy_ammo.magazine_size = 200

heavy_projectile = util.copy(data.raw.projectile["cannon-projectile"])
heavy_projectile.name = "heavy-projectile"
heavy_projectile.piercing_damage = 10
heavy_projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 20 , type = "physical"}
      },
      {
        type = "create-explosion",
        entity_name = "explosion-gunshot"
      },
    }
  }
}
heavy_projectile.final_action = nil


data:extend
{
  heavy,
  heavy_ammo,
  heavy_gun,
  heavy_projectile,
  heavy_shell
}
