--Its a roboport
local name = require("shared").entities.command_center
local path = util.path("data/entities/command_center/")

local radar = util.copy(data.raw.radar.radar)
radar.name = name
radar.localised_name = name
radar.collision_box = {{-2.9, -2.9},{2.9, 2.9}}
radar.selection_box = {{-3, -3},{3, 3}}
radar.pictures = {
  layers =
  {
    {
      filename = path.."command_center_base.png",
      width = 293,
      height = 229,
      shift = {1.2, -0.25},
      direction_count = 1
    }
  }
}
radar.max_health = 2000
radar.order = "noob"
radar.energy_source = {type = "void"}
radar.selection_priority = 1
radar.minable = nil
radar.max_distance_of_nearby_sector_revealed = 6
radar.max_distance_of_sector_revealed = 0
radar.energy_per_sector = tostring(100 * 60 * 15).."W"
radar.energy_usage = tostring(100).."W"
radar.energy_per_nearby_scan = "0J"
radar.working_sound =
{
  sound =
  {
    {
      filename = path.."command_center.ogg",
      volume = 2
    }
  }
}

local roboport = util.copy(data.raw.roboport.roboport)
roboport.flags = {"no-automated-item-removal", "no-automated-item-insertion"}
roboport.name = name.." Roboport"
roboport.localised_name = name.." Roboport"
--roboport.collision_box = {{-2.9, -2.9},{2.9, 2.9}}
roboport.selection_box = {{-1.2, -2.5},{1.2, -0.5}}
roboport.drawing_box = {{-3, -3},{3, 3}}
roboport.selectable_in_game = true
roboport.selection_priority = 10
roboport.energy_source =
{
  type = "void"
}
roboport.minable = nil
roboport.max_health = 1
roboport.recharge_minimum = "40MJ"
roboport.energy_usage = "50kW"
-- per one charge slot
roboport.charging_energy = "2000kW"
roboport.logistics_radius = 0
roboport.construction_radius = 100
roboport.charge_approach_distance = 7
roboport.robot_slots_count = 7
roboport.material_slots_count = 7
roboport.stationing_offset = {0, -0.25}
roboport.spawn_and_station_height = -0.4
roboport.order = "noob"
roboport.charging_station_count = 8
roboport.charging_distance = 2
roboport.robot_limit = 20
roboport.charging_station_shift = {0, -1}
roboport.base =
{
  layers =
  {
    {
      filename = path.."command_center_base.png",
      width = 293,
      height = 229,
      shift = {1.2, -0.25}
    }
  }
}
roboport.base_patch =
{
  filename = path.."command_center_patch.png",
  width = 120,
  height = 67,
  shift = util.by_pixel(3, -7)
}
roboport.working_sound = nil
roboport.base_animation = util.empty_sprite()
roboport.door_animation_up =
{
  filename = "__base__/graphics/entity/roboport/hr-roboport-door-up.png",
  priority = "medium",
  width = 97,
  height = 38,
  frame_count = 16,
  shift = util.by_pixel(-0.25, -65),
  scale = 1
}
roboport.door_animation_down =
{
  filename = "__base__/graphics/entity/roboport/hr-roboport-door-down.png",
  priority = "medium",
  width = 97,
  height = 41,
  frame_count = 16,
  shift = util.by_pixel(-0.25,-26),
  scale = 1
}
roboport.recharging_animation =
{
  filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
  priority = "high",
  width = 37,
  height = 35,
  frame_count = 16,
  scale = 1.5,
  animation_speed = 0.5
}

local robot = util.copy(data.raw["construction-robot"]["construction-robot"])
robot.max_energy = nil
robot.energy_per_move = nil
robot.energy_per_tick = nil
robot.name = name.." Robot"
robot.localised_name = name.." Robot"
robot.order = "noob"
util.recursive_hack_make_hr(robot)
util.recursive_hack_scale(robot, 0.75)
util.recursive_hack_tint(robot, {r = 0.5, g = 0.5, b = 0.5})

local robot_item = util.copy(data.raw.item["construction-robot"])
robot_item.name = name.." Robot"
robot_item.localised_name = name.." Robot"
robot_item.place_result = name.." Robot"
robot_item.flags = {"hidden"}

local turret_name = require("shared").entities.command_center_turret
local turret = util.copy(data.raw["electric-turret"]["laser-turret"])
turret.name = turret_name
turret.type = "turret"
turret.localised_name = turret_name
turret.max_health = 10000 
turret.collision_box = {{-1.8, -1.8},{1.8, 1.8}}
turret.selection_box = {{-2, -2},{2, 2}}
turret.minable = nil
local picture =
{
  filename = path.."command_center_turret.png",
  width = 330,
  height = 261,
  frame_count = 1,
  direction_count = 1,
  shift = {3, -1.8}
}

turret.energy_source =
{
  type = "void",
  --buffer_capacity = "801kJ",
  --input_flow_limit = "9600kW",
  --drain = "24kW",
  --usage_priority = "primary-input"
}
turret.folded_animation = picture
turret.preparing_animation = picture
turret.prepared_animation = picture
turret.folding_animation = picture
turret.base_picture = util.empty_sprite()
turret.order = "noob"
turret.corpse = "big-remnants"
turret.starting_attack_sound = 
{
  filename = path.."command_center_turret_beam.ogg",
  volume = 2
}
turret.attack_parameters =
{
  type = "beam",
  ammo_category = "combat-robot-beam",
  cooldown = SU(120),
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
        beam = turret_name.." Beam",
        max_length = 35,
        duration = SU(23),
        source_offset = {0.4, -5.3}
      }
    }
  }
}

local beam = util.copy(data.raw.beam["electric-beam"])
util.recursive_hack_scale(beam, 2)
util.recursive_hack_tint{r = 0, g = 1, b = 0}

beam.name = turret_name.." Beam"
beam.localised_name = turret_name.." Beam"
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
        damage = { amount = 90, type = "electric"}
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
                sticker = turret_name.." Sticker"
              }
            }
          }
        },
      },
    }
  }
}
beam.working_sound =
{
  {
    filename = path.."command_center_turret_beam.ogg",
    volume = 0
  }
}


local sticker = util.copy(data.raw.sticker["fire-sticker"])
sticker.name = turret_name.." Sticker"

sticker.duration_in_ticks = SU(1 * 60)
sticker.target_movement_modifier = 0.75
sticker.damage_per_tick = {type = "electric", amount = 1}
sticker.spread_fire_entity = nil
sticker.fire_spread_cooldown = 0
sticker.fire_spread_radius = 0
sticker.animation = 
{
  filename = path.."command_center_turret_stick.png",
  width = 37,
  height = 35,
  frame_count = 16
}
sticker.stickers_per_square_meter = 15

local chest = util.copy(data.raw["logistic-container"]["logistic-chest-storage"])
chest.name = name.." Chest"
chest.localised_name = name.." Chest"
chest.collision_box = {{-2.8, -2.8},{2.8, 2.8}}
chest.drawing_box = {{-3, -3},{3, 3}}
chest.selection_box = {{-1.2, 0.5},{1.2, 2.5}}
chest.collision_mask = {"doodad-layer"}
chest.order = "noob"
chest.inventory_size = 99
--util.recursive_hack_scale(chest, 6)
chest.picture =
{
  filename = path.."command_center_base.png",
  width = 293,
  height = 229,
  shift = {1.2, -0.25}
}
chest.minable = nil
chest.max_health = 1


data:extend{radar, roboport, robot, robot_item, turret, beam, sticker,
chest
}


