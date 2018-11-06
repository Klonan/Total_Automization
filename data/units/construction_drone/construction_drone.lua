local path = util.path("data/units/construction_drone/")
local name = names.entities.construction_drone

local animation =
{
  layers =
  {
    walk =
    {
      width = 78,
      height = 104,
      frame_count = 2,
      axially_symmetrical = false,
      direction_count = 32,
      shift = util.by_pixel(0.0, -14),
      scale = 0.5,
      stripes =
      {
        {
          filename = path.."drone_walk_1.png",
          width_in_frames = 2,
          height_in_frames = 16
        },
        {
          filename = path.."drone_walk_2.png",
          width_in_frames = 2,
          height_in_frames = 16
        }
      }
    },
    walk_shadow =
    {
      width = 142,
      height = 56,
      frame_count = 2,
      axially_symmetrical = false,
      direction_count = 32,
      shift = util.by_pixel(15.5, -0.5),
      draw_as_shadow = true,
      scale = 0.5,
      stripes = util.multiplystripes(2,
      {
        {
          filename = path.."drone_shadow.png",
          width_in_frames = 1,
          height_in_frames = 32
        }
      })
    }
  }
}

local unit = {
  type = "unit",
  name = name,
  localised_name = name,
  icon = path.."construction_drone_icon.png",
  icon_size = 64,
  flags = {"placeable-player", "placeable-enemy", "placeable-off-grid"},
  map_color = {r = 0, g = 0.365, b = 0.58, a = 1},
  max_health = 15,
  order = "b-b-a",
  subgroup="enemies",
  has_belt_immunity = true,
  can_open_gates = true,
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  selection_box = {{-0.4, -0.7}, {0.7, 0.4}},
  attack_parameters =
  {
    type = "projectile",
    range = 1.5,
    min_attack_distance = 0.5,
    cooldown = SU(35),
    cooldown_deviation = 0.2,
    ammo_category = "melee",
    ammo_type =
    {
      category = "melee",
      target_type = "entity",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          target_effects =
          {
            type = "damage",
            damage = { amount = 1, type = util.damage_type(name)}
          }
        }
      }
    },
    sound = nil,
    animation = animation
  },
  vision_distance = 5,
  movement_speed = 0.12,
  distance_per_frame = 0.1,
  pollution_to_join_attack = 20000000,
  distraction_cooldown = 30000000,
  min_pursue_time = 10 * 60,
  max_pursue_distance = 50,
  corpse = nil,
  dying_explosion = "explosion",
  --dying_sound =  make_biter_dying_sounds(0.4),
  working_sound =
  {
    sound = {
      {filename = path.."construction_drone_1.ogg"},
      {filename = path.."construction_drone_2.ogg"},
      {filename = path.."construction_drone_3.ogg"},
      {filename = path.."construction_drone_4.ogg"},
      {filename = path.."construction_drone_5.ogg"},
      {filename = path.."construction_drone_6.ogg"},
      {filename = path.."construction_drone_7.ogg"},
      {filename = path.."construction_drone_8.ogg"},
      {filename = path.."construction_drone_9.ogg"},
      {filename = path.."construction_drone_10.ogg"},
      {filename = path.."construction_drone_11.ogg"},
      {filename = path.."construction_drone_12.ogg"},
      {filename = path.."construction_drone_13.ogg"}
    },
    probability = 1 / (5 * 60),
    max_sounds_per_type = 3
  },
  run_animation = animation,
  destroy_when_commands_fail = false
}


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = data.raw.item["construction-robot"].subgroup,
  order = "a-"..name,
  stack_size= 10,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = data.raw.recipe["construction-robot"].category,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 1},
  },
  energy_required = 1,
  result = name
}

data:extend
{
  unit,
  item,
  recipe
}