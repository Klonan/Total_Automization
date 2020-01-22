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
util.recursive_hack_scale(turret_base, 0.66)

local turret_shift = {0.18, 0}

for k, layer in pairs (turret_base.layers) do
  layer.shift = layer.shift or {0,0}
  layer.shift[1] = layer.shift[1] + turret_shift[1]
  layer.shift[2] = layer.shift[2] + turret_shift[2]
  table.insert(sprite_base.animation.layers, layer)
end
local path = util.path("data/units/scout_car/")

local attack_range = 21
local unit =
{
  type = "unit",
  name = name,
  localised_name = {name},
  icon = sprite_base.icon,
  icon_size = sprite_base.icon_size,
  flags = util.unit_flags(),
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 315,
  radar_range = 2,
  order="i-c",
  subgroup = "iron-units",
  resistances = nil,
  healing_per_tick = 0,
  collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
  selection_box = {{-1.2, -1.2}, {1.2, 1.2}},
  collision_mask = util.ground_unit_collision_mask(),
  max_pursue_distance = 64,
  min_persue_time = (60 * 15),
  --sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = (30),
  move_while_shooting = false,
  can_open_gates = true,
  resistances = nil,
  old_resistances =
  {
    {
      type = "acid",
      decrease = 8,
      percent = 60
    }
  },
  ai_settings =
  {
    do_separation = true
  },
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    warmup = 10,
    cooldown = 100,
    cooldown_deviation = 0.1,
    range = attack_range,
    lead_target_for_projectile_speed = 1,
    min_attack_distance = attack_range - 3,
    projectile_creation_distance = 1.5,
    sound =
    {
      variations =
      {
        {
          filename = "__base__/sound/fight/heavy-gunshot-1.ogg",
          volume = 0.45
        },
        {
          filename = "__base__/sound/fight/heavy-gunshot-2.ogg",
          volume = 0.45
        },
        {
          filename = "__base__/sound/fight/heavy-gunshot-3.ogg",
          volume = 0.45
        },
        {
          filename = "__base__/sound/fight/heavy-gunshot-4.ogg",
          volume = 0.45
        }
      },
      aggregation =
      {
        max_count = 2,
        remove = true,
        count_already_playing = true
      }
    },
    ammo_type =
    {
      category = util.ammo_category("iron-units"),
      target_type = "direction",
      action =
      {
        {
          type = "direct",
          repeat_count = 1,
          action_delivery =
          {
            {
              type = "projectile",
              projectile = name.." Projectile",
              starting_speed = 0.6,
              starting_speed_deviation = 0.05,
              direction_deviation = 0.1,
              --range_deviation = 0.05,
              --starting_frame_deviation = 5,
              max_range = attack_range + 3
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
  movement_speed = 0.35,
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
projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
projectile.force_condition = "not-same"
projectile.height = 1
projectile.hit_at_collision_position = true
projectile.hit_collision_mask = util.projectile_collision_mask()
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
        entity_name = name.." Explosion"
      },
      {
        type = "damage",
        damage = {amount = 10 , type = util.damage_type("physical")}
      }
    }
  }
}
projectile.animation.height = 1
projectile.animation.width = 1
projectile.acceleration = 0
projectile.final_action = nil
projectile.animation.blend_mode = "additive"
util.recursive_hack_scale(projectile, 1.5)


local make_smoke_source = function(position)
  return
  {
    name = name.."-smoke",
    deviation = {0.1, 0.1},
    frequency = 1,
    position = position,
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  }
end
projectile.smoke = {}

for k = 0.1, 0.6, 0.1 do
  table.insert( projectile.smoke,
  {
    name = name.."-smoke",
    deviation = {0.05, 0.05},
    frequency = 2,
    position = {-0.2, -k},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  })
  table.insert( projectile.smoke,
  {
    name = name.."-smoke",
    deviation = {0.05, 0.05},
    frequency = 2,
    position = {0.2, -k},
    slow_down_factor = 1,
    --starting_frame = 1,
    --starting_frame_deviation = 0,
    --starting_frame_speed = 0,
    --starting_frame_speed_deviation = 0
  })
end


fast ={
  name = "smoke-fast",
  deviation = {0.05, 0.05},
  frequency = 2,
  position = {-0.05, 4/6},
  slow_down_factor = 1,
  --starting_frame = 1,
  --starting_frame_deviation = 0,
  --starting_frame_speed = 0,
  --starting_frame_speed_deviation = 0
}
local smoke = {
  type = "trivial-smoke",
  name = name.."-smoke",
  flags = {"not-on-map"},
  animation =
  {
    filename = "__base__/graphics/entity/flamethrower-fire-stream/flamethrower-explosion.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    frame_count = 8,
    line_length = 8,
    scale = 0.15,
    animation_speed = 1,
    blend_mode = "additive"
  },
  movement_slow_down_factor = 0.95,
  duration = 8,
  fade_away_duration = 8,
  show_when_smoke_off = true
}

local explosion = util.copy(data.raw.explosion.explosion)
util.recursive_hack_scale(explosion, 0.5)
explosion.name = name.." Explosion"


local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = "c-"..name,
  stack_size = 10,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = {name},
  category = names.deployers.iron_unit,
  enabled = false,
  ingredients =
  {
    {"engine-unit", 8},
    {"iron-gear-wheel", 5},
    {"solid-fuel", 15}
  },
  energy_required = 20,
  result = name
}


data:extend{unit, projectile, item, recipe, explosion, smoke}
