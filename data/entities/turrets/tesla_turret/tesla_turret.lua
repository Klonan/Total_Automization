local path = util.path("data/entities/turrets/tesla_turret/")
local name = require("shared").entities.tesla_turret
local turret = util.copy(data.raw["turret"]["small-worm-turret"])
turret.name = name
turret.localised_name = name
turret.type = "turret"
turret.max_health = 10000 
turret.collision_box = {{-1.8, -1.8},{1.8, 1.8}}
turret.selection_box = {{-2, -2},{2, 2}}
--turret.minable = nil
--turret.flags = {"not-deconstructable"}
local picture = {layers = {
  {
    filename = path.."tesla_turret.png",
    width = 330,
    height = 261,
    frame_count = 1,
    direction_count = 1,
    shift = {3, -1.8}
  },
  {
    filename = path.."tesla_turret_mask.png",
    flags = { "mask" },
    line_length = 1,
    width = 122,
    height = 102,
    axially_symmetrical = false,
    direction_count = 1,
    frame_count = 1,
    shift = util.by_pixel(-4, -1),
    apply_runtime_tint = true
  }
}}
local turret =
{
  type = "turret",
  name = name,
  localised_name = name,
  icon = path.."tesla_turret_icon.png",
  icon_size = 261,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 5, result = name},
  order="b-b-d",
  max_health = 1500,
  healing_per_tick = 0.01,
  collision_box = {{-1.8, -1.8},{1.8, 1.8}},
  selection_box = {{-2, -2},{2, 2}},
  shooting_cursor_size = 3,
  corpse = "big-remnants",
  dying_explosion = "massive-explosion",
  preparing_animation = picture,
  prepared_animation = picture,
  folded_animation = picture,
  starting_attack_animation = picture,
  starting_attack_sound = 
  {
    filename = path.."tesla_turret_beam.ogg",
    volume = 2
  },
  ending_attack_animation = picture,
  folding_animation = picture,
  attack_parameters =
  {
    type = "beam",
    ammo_category = "combat-robot-beam",
    cooldown = SU(120),
    source_offset = {0.4, -4.3},
    source_direction_count = 1,
    range = 35,
    ammo_type =
    {
      category = "combat-robot-beam",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "beam",
          beam = name.." Beam",
          max_length = 40,
          duration = SU(23),
        }
      }
    }
  },
  call_for_help_radius = 40
}

local beam = util.copy(data.raw.beam["electric-beam"])
util.recursive_hack_scale(beam, 2)
util.recursive_hack_tint{r = 0, g = 1, b = 0}

beam.name = name.." Beam"
beam.localised_name = name.." Beam"
beam.damage_interval = SU(23)
beam.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = { amount = 35, type = "electric"}
      },
      {
        type = "nested-result",
        affects_target = false,
        action =
        {
          type = "area",
          radius = 4,
          force = "enemy",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "create-sticker",
                sticker = name.." Sticker"
              }
            }
          }
        },
      },
    }
  }
}
beam.working_sound = nil


local sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = name.." Sticker"

sticker.duration_in_ticks = SU(1 * 60)
sticker.target_movement_modifier = 0.75
sticker.damage_per_tick = {type = "electric", amount = 1}
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation = 
{
  filename = path.."tesla_turret_sticker.png",
  width = 37,
  height = 35,
  frame_count = 16,
}
sticker.stickers_per_square_meter = 15


local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = turret.icon,
  icon_size = turret.icon_size,
  flags = {},
  order = "d-"..name,
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

data:extend{turret, beam, sticker, item, recipe}