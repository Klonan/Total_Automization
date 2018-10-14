local name = names.units.shell_tank

local sprite_base = util.copy(data.raw.car.tank)
local path = util.path("data/units/shell_tank/")
util.recursive_hack_make_hr(sprite_base)
util.recursive_hack_scale(sprite_base, 1.5)
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
local cannon_pictures = util.copy(data.raw["artillery-turret"]["artillery-turret"])
util.recursive_hack_make_hr(cannon_pictures)

for k, layer in pairs (cannon_pictures.cannon_base_pictures.layers) do
  local stripes = {}
  for k, path in pairs (layer.filenames) do
    table.insert(stripes, {
      filename = path,
      height_in_frames = 4,
      width_in_frames = 1
    })
  end
  layer.stripes = stripes
  layer.filenames = nil
  layer.frame_count = 1
  if layer.draw_as_shadow then
  else
    layer.shift = {layer.shift.x or 0, (layer.shift.y or 0) - 2.5}
  end
end


for k, layer in pairs (cannon_pictures.cannon_barrel_pictures.layers) do
  local stripes = {}
  for k, path in pairs (layer.filenames) do
    table.insert(stripes, {
      filename = path,
      height_in_frames = 4,
      width_in_frames = 1
    })
  end
  layer.stripes = stripes
  layer.filenames = nil
  layer.frame_count = 1
  if layer.draw_as_shadow then
  else
    layer.shift = {layer.shift.x or 0, (layer.shift.y or 0) - 3}
  end
end


for k, layer in pairs (cannon_pictures.cannon_barrel_pictures.layers) do
  table.insert(sprite_base.animation.layers, layer)
end
for k, layer in pairs (cannon_pictures.cannon_base_pictures.layers) do
  table.insert(sprite_base.animation.layers, layer)
end

local shifts = require(path.."shell_tank_creation_parameters")
for k, shift in pairs (shifts) do
  shift[2][2] = shift[2][2] - 1.35
end

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
  max_health = 225,
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  healing_per_tick = 0,
  minable = {result = name, mining_time = 2},
  collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
  selection_box = {{-2, -2}, {2, 2}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  --sticker_box = {{-0.2, -0.2}, {0.2, 0.2}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    warmup = SU(15),
    cooldown = SU(145),
    range = 40,
    --min_attack_distance = 32,
    --projectile_creation_distance = 1.5,
    --projectile_center = {0, -1.5},
    projectile_creation_distance = 1.6,
    projectile_center = {-0.15625, -1.5},
    --range = 7 * 32,
    --min_range = 1 * 32,
    projectile_creation_parameters = shifts,
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
          action_delivery =
          {
            type = "projectile",
            projectile = name.." Projectile",
            starting_speed = SD(1.5),
            starting_speed_deviation = SD(0.1),
            direction_deviation = 0.05,
            range_deviation = 0.1,
            starting_frame_deviation = 5,
            max_range = 40,
            source_effects =
            {
              type = "create-explosion",
              entity_name = "artillery-cannon-muzzle-flash"
            }
          }
        }
      }
    },
    animation = sprite_base.animation
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.15),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = "explosion",
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  working_sound =
  {
    sound = sprite_base.working_sound.sound
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

local projectile = util.copy(data.raw.projectile["cannon-projectile"])
projectile.name = name.." Projectile"
projectile.animation.scale = 2.5
projectile.blend_mode = "additive-soft"
other_animation =
{
  layers =
  {
    {
      filename = "__base__/graphics/entity/artillery-projectile/hr-shell.png",
      width = 64,
      height = 64,
      shift = {1, 0},
      scale = 1,
      frame_count = 1
    },
    projectile.animation,
  }
}
projectile.collision_box = {{-0.2, -0.2},{0.2, 0.2}}
projectile.force_condition = "not-same"
projectile.height = 0
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
      }
    }
  }
}
projectile.acceleration = SA(0)
projectile.final_action = {
  type = "area",
  radius = 2.5,
  force = "not-same",
  collision_mode = "distance-from-center",
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
        damage = {amount = 15 , type = util.damage_type("shell_tank")}
      }
    }
  }
}
--projectile.animation = require("data/tf_util/tf_fire_util").create_fire_pictures({animation_speed = SD(1), scale = 0.5})


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "iron-units",
  order = "e-"..name,
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
    {"engine-unit", 10},
    {"steel-plate", 20},
    {"explosives", 20},
    {"rocket-fuel", 5}
  },
  energy_required = 45,
  result = name
}


data:extend{unit, projectile, item, recipe}
