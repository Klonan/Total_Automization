local name = names.units.scout_car

local sprite_base = util.copy(data.raw.car.car)
local turret_base = util.copy(data.raw.car.tank.turret_animation)

util.recursive_hack_make_hr(sprite_base)

for k, layer in pairs (sprite_base.animation.layers) do
  layer.frame_count = 1
  layer.max_advance = nil
  layer.line_length = nil
  if layer.stripes then
    for k, strip in pairs (layer.stripes) do
      strip.width_in_frames = 1
    end
    if layer.apply_runtime_tint or layer.draw_as_shadow then
      local new_stripes = {}
      for k, stripe in pairs (layer.stripes) do
        if k % 2 ~= 0 then
          table.insert(new_stripes, stripe)
        end
      end
      layer.stripes = new_stripes
      --error(serpent.block(layer))
    end
  end
end

util.recursive_hack_make_hr(turret_base)
util.recursive_hack_scale(turret_base, 0.75)

local turret_shift = {0.1, 0}

for k, layer in pairs (turret_base.layers) do
  layer.shift = layer.shift or {0,0}
  layer.shift[1] = layer.shift[1] + turret_shift[1]
  layer.shift[2] = layer.shift[2] + turret_shift[2]
  table.insert(sprite_base.animation.layers, layer)
end
local path = util.path("data/units/scout_car/")


local unit =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = sprite_base.icon,
  icon_size = sprite_base.icon_size,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 155,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-1, -1}, {1, 1}},
  selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  --sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = SU(30),
  move_while_shooting = true,
  can_open_gates = true,
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(100),
    cooldown_deviation = 0.1,
    range = 30,
    min_attack_distance = 25,
    projectile_creation_distance = 1.5,
    sound =
    {
      {
        filename = "__base__/sound/fight/tank-cannon.ogg",
        volume = 1.0
      }
    },
    ammo_type =
    {
      category = "bullet",
      target_type = "direction",
      action =
      {
        {
          type = "direct",
          repeat_count = 2,
          action_delivery =
          {
            {
              type = "projectile",
              projectile = name.." Projectile",
              starting_speed = SD(1),
              starting_speed_deviation = SD(0.05),
              direction_deviation = 0.1,
              --range_deviation = 0.05,
              --starting_frame_deviation = 5,
              max_range = 30
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
    },
    animation = sprite_base.animation
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.35),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    sound =
    {
      filename = "__base__/sound/car-engine.ogg",
      volume = 0.6
    }
  },
  dying_sound =
  {
    {
      filename = "__base__/sound/fight/small-explosion-1.ogg",
      volume = 0.5
    },
    {
      filename = "__base__/sound/fight/small-explosion-2.ogg",
      volume = 0.5
    }
  },
  run_animation = sprite_base.animation
}

local projectile = util.copy(data.raw.projectile["shotgun-pellet"])
projectile.name = name.." Projectile"
projectile.collision_box = {{-0.1, -0.1},{0.1, 0.1}}
projectile.force_condition = "not-same"
projectile.height = 1
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
        entity_name = "explosion"
      },
      {
        type = "damage",
        damage = {amount = 12 , type = util.damage_type("scout_car")}
      }
    }
  }
}
projectile.acceleration = 0
projectile.final_action = nil
projectile.animation.blend_mode = "additive"
util.recursive_hack_scale(projectile, 2)


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = "c-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = names.deployers.iron_unit,
  enabled = true,
  ingredients =
  {
    {"engine-unit", 8},
    {"iron-gear-wheel", 5},
    {"solid-fuel", 15}
  },
  energy_required = 20,
  result = name
}


data:extend{unit, projectile, item, recipe}
