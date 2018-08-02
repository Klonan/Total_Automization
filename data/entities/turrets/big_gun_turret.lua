local name = require("shared").entities.big_gun_turret
local turret = util.copy(data.raw["ammo-turret"]["gun-turret"])

util.recursive_hack_make_hr(turret)
util.recursive_hack_scale(turret, 2)

for k, layer in pairs (turret.base_picture.layers) do
  layer.shift = {0, 0.5}
end
local recursive_fix_these_turret_shawdows
recursive_fix_these_turret_shawdows = function(table)
  for k, v in pairs (table) do
    if type(v) == "table" then
      if v.draw_as_shadow then
        v.shift = v.shift or {0,0}
        v.shift[1] = v.shift[1] + 0.5
        v.shift[2] = v.shift[2] + 0.5
      end
      recursive_fix_these_turret_shawdows(v)
    end
  end
end
recursive_fix_these_turret_shawdows(turret)
turret.name = name
turret.localised_name = name
turret.type = "electric-turret"
turret.energy_source = {type = "void"}
turret.preparing_speed = SD(0.05)
turret.order = "noob"
turret.prepare_range = 45
turret.max_health = 3000
turret.selection_box = {{-2, -2},{2 , 2}}
turret.collision_box = {{-1.8, -1.8},{1.8 , 1.8}}
turret.minable.result = name
turret.attack_parameters =
{
  type = "projectile",
  ammo_category = "bullet",
  cooldown = SU(4),
  cooldown_deviation = 0.5,
  range = 40,
  projectile_creation_distance = 1.39375 * 2,
  projectile_center = {0, -0.0875 * 2},
  sound = {
    variations = make_heavy_gunshot_sounds(),
    aggregation =
    {
      max_count = 3,
      remove = true
    }
  },
  ammo_type =
  {
    category = "bullet",
    target_type = "direction",
    action =
    {
      type = "direct",
      action_delivery =
      {
        {
        type = "projectile",
        projectile = name.." Projectile",
        starting_speed = SD(1),
        starting_speed_deviation = SD(0.1),
        direction_deviation = 0.05,
        range_deviation = 0.05,
        max_range = 42
        },
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
      }
    }
  }
}


local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.force_condition = "not-same"
projectile.animation.blend_mode = "additive"
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
        damage = {amount = 8 , type = util.damage_type(name)}
      }
    }
  }
}
projectile.final_action = 
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}
util.recursive_hack_scale(projectile, 1.5)


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = turret.icon,
  icon_size = turret.icon_size,
  flags = {},
  order = "a-"..name,
  stack_size= 1,
  place_result = name,
  subgroup = "defensive-structure",
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  enabled = true,
  ingredients =
  {
    {"stone-brick", 4}
  },
  energy_required = 5,
  result = name
}

data:extend{turret, projectile, item, recipe}
