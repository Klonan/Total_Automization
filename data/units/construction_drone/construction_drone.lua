local path = util.path("data/units/construction_drone/")
local name = names.entities.construction_drone

local scale = 2/3

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
      shift = util.by_pixel(0.0 * scale, -14 * scale),
      scale = 0.5 * scale,
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
      shift = util.by_pixel(15.5 * scale, -0.5 * scale),
      draw_as_shadow = true,
      scale = 0.5 * scale,
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
  map_color = {r = 0, g = 1, b = 1, a = 1},
  max_health = 15,
  order = "b-b-a",
  subgroup="enemies",
  has_belt_immunity = true,
  can_open_gates = true,
  path_resolution_modifier = 4,
  affected_by_tiles = true, --not merged
  collision_box = {{-0.025, -0.00 }, {0.0, 0.025}},
  selection_box = {{-0.6 * scale, -1.0 * scale}, {0.6 * scale, 0.4 * scale}},
  attack_parameters =
  {
    type = "projectile",
    range = 1.5,
    min_attack_distance = 0.5,
    cooldown = SU(60),
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
            damage = { amount = 10, type = util.damage_type(name)}
          }
        }
      }
    },
    sound = nil,
    animation = animation
  },
  vision_distance = 10,
  movement_speed = 0.16,
  distance_per_frame = 0.1,
  pollution_to_join_attack = 20000000,
  distraction_cooldown = 30000000,
  min_pursue_time = 0,
  max_pursue_distance = 0,
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
    probability = 1 / (3 * 60)
  },
  run_animation = animation,
  minable = {name = name, mining_time = 1},
  ai_settings =
  {
    destroy_when_commands_fail = false,
    allow_try_return_to_spawner = false,
    do_separation = false
  }
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
  enabled = false,
  ingredients =
  {
    {"iron-plate", 1},
  },
  energy_required = 1,
  result = name
}

local shoo =
{
  type = "sound",
  name = "shoo",
  filename = path.."shoo.ogg"
}

--Sticker time!

local background = "__core__/graphics/entity-info-dark-background.png"

local shift = {0, -0.3}

local item_types =
{
  "item",
  "rail-planner",
  "item-with-entity-data",
  "blueprint-item",
  "upgrade-item",
  "deconstruction-item",
  "ammo",
  "gun",
  "tool",
  "repair-tool",
  "copy-paste-tool",
  "module",
  "armor",
  "item-with-inventory",
  "item-with-label",
  "item-with-tags"
}

for k, item_type in pairs(item_types) do
  for name, prototype in pairs (data.raw[item_type] or {}) do
    if prototype.icon then
      local sticker =
      {
        type = "sticker",
        name = prototype.name.." Drone Sticker",
        flags = {},
        animation =
        {
          layers =
          {
            {
              filename = background,
              width = 53,
              height = 53,
              scale = 0.5,
              frame_count = 1,
              shift = shift
            },
            {
              filename = prototype.icon,
              priority = "extra-high",
              width = prototype.icon_size,
              height = prototype.icon_size,
              scale = (32 / prototype.icon_size) / 2,
              frame_count = 1,
              animation_speed = 1,
              shift = shift
            }
          }
        },
        duration_in_ticks = 2 ^ 31,
        target_movement_modifier = 1,
        force_visibility = "same",
        single_particle = true
      }
      data:extend{sticker}
    end
  end
end

local simple_storage_chest_name = names.entities.simple_storage_chest
local simple_storage_chest = util.copy(data.raw["logistic-container"]["logistic-chest-storage"])
simple_storage_chest.name =simple_storage_chest_name
simple_storage_chest.localised_name = simple_storage_chest_name
simple_storage_chest.inventory_size = 19
simple_storage_chest.picture =
{
  filename = path.."simple-storage-chest.png",
  priority = "extra-high",
  width = 48,
  height = 34,
  shift = {0.1875, 0}
}

local simple_storage_chest_item = {
  type = "item",
  name = simple_storage_chest_name,
  localised_name = simple_storage_chest_name,
  icon = path.."simple-storage-chest.png",
  icon_size = 32,
  flags = {},
  subgroup = data.raw.item["logistic-chest-storage"].subgroup,
  order = "c-"..simple_storage_chest_name,
  stack_size= 50,
  place_result = simple_storage_chest_name
}

local simple_storage_chest_recipe = {
  type = "recipe",
  name = simple_storage_chest_name,
  localised_name = simple_storage_chest_name,
  category = data.raw.recipe["logistic-chest-storage"].category,
  enabled = false,
  ingredients =
  {
    {"iron-chest", 1},
    {"electronic-circuit", 5},
  },
  energy_required = 0.5,
  result = simple_storage_chest_name
}

local simple_provider_chest_name = names.entities.simple_provider_chest
local simple_provider_chest = util.copy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
simple_provider_chest.name = simple_provider_chest_name
simple_provider_chest.localised_name = simple_provider_chest_name
simple_provider_chest.inventory_size = 19
simple_provider_chest.picture =
{
  filename = path.."simple-provider-chest.png",
  priority = "extra-high",
  width = 48,
  height = 34,
  shift = {0.1875, 0}
}

local simple_provider_chest_item = {
  type = "item",
  name = simple_provider_chest_name,
  localised_name = simple_provider_chest_name,
  icon = path.."simple-provider-chest.png",
  icon_size = 32,
  flags = {},
  subgroup = data.raw.item["logistic-chest-passive-provider"].subgroup,
  order = "d-"..simple_provider_chest_name,
  stack_size= 50,
  place_result = simple_provider_chest_name
}

local simple_provider_chest_recipe = {
  type = "recipe",
  name = simple_provider_chest_name,
  localised_name = simple_provider_chest_name,
  category = data.raw.recipe["logistic-chest-passive-provider"].category,
  enabled = false,
  ingredients =
  {
    {"iron-chest", 1},
    {"electronic-circuit", 5},
  },
  energy_required = 0.5,
  result = simple_provider_chest_name
}


local technology_name = names.technologies.construction_drone_system
local technology = {
  type = "technology",
  name = technology_name,
  localised_name = technology_name,
  icon = path.."construction_drone_technology.png",
  icon_size = 150,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = name
    },
    {
      type = "unlock-recipe",
      recipe = names.entities.logistic_beacon
    },
    {
      type = "unlock-recipe",
      recipe = simple_storage_chest_name
    },
    {
      type = "unlock-recipe",
      recipe = simple_provider_chest_name
    },
  },
  unit =
  {
    count = 200,
    ingredients = {
      {"science-pack-1", 1},
      {"science-pack-2", 1},
    },
    time = 30
  },
  prerequisites = {"automation"},
  order = "y-a"
}



data:extend
{
  unit,
  item,
  recipe,
  shoo,
  technology,
  simple_provider_chest,
  simple_provider_chest_item,
  simple_provider_chest_recipe,
  simple_storage_chest,
  simple_storage_chest_item,
  simple_storage_chest_recipe
}