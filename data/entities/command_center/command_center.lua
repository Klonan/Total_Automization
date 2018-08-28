--Its a roboport
local name = names.entities.command_center
local path = util.path("data/entities/command_center/")

local command_center_picture = {
  layers =
  {
    {
      filename = path.."command_center_base_2.png",
      width = 221,
      height = 225,
      shift = {0.068, -0.465},
      direction_count = 1
    },
    {
      filename = path.."command_center_base_2_shadow.png",
      width = 277,
      height = 149,
      shift = {1.7, 1},
      direction_count = 1,
      draw_as_shadow = true
    }
  }
}

local radar = util.copy(data.raw.radar.radar)
radar.name = name
radar.localised_name = name
radar.collision_box = {{-2.9, -2.9},{2.9, 2.9}}
radar.selection_box = {{-3, -3},{3, 3}}
radar.pictures = command_center_picture
radar.max_health = 2000
radar.corpse = "big-remnants"
radar.order = "noob"
radar.energy_source = {type = "void"}
radar.selection_priority = 1
radar.minable = nil
radar.max_distance_of_nearby_sector_revealed = 6
radar.max_distance_of_sector_revealed = 0
radar.energy_per_sector = tostring(100 * 60 * 15).."W"
radar.energy_usage = tostring(100).."W"
radar.energy_per_nearby_scan = "0J"
radar.flags = {"not-repairable", "not-deconstructable"}
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
roboport.flags = {"no-automated-item-removal", "no-automated-item-insertion", "not-repairable", "not-deconstructable"}
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
roboport.logistics_radius = 150
roboport.construction_radius = 200
--roboport.draw_logistic_radius_visualization

roboport.charge_approach_distance = 7
roboport.robot_slots_count = 7
roboport.material_slots_count = 7
roboport.stationing_offset = {0, -0.25}
roboport.spawn_and_station_height = -0.4
roboport.order = "noob"
roboport.charging_station_count = 8
roboport.charging_distance = 2
roboport.charging_station_shift = {0, -1}
roboport.base = command_center_picture
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
robot.minable = nil
util.recursive_hack_make_hr(robot)
util.recursive_hack_scale(robot, 0.75)
util.recursive_hack_tint(robot, {r = 0.5, g = 0.5, b = 0.5})

local robot_item = util.copy(data.raw.item["construction-robot"])
robot_item.name = name.." Robot"
robot_item.localised_name = name.." Robot"
robot_item.place_result = name.." Robot"
robot_item.flags = {"hidden"}

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
chest.picture = command_center_picture
chest.minable = nil
chest.max_health = 1
chest.flags = {"hide-alt-info", "not-deconstructable"}


data:extend{radar, roboport, robot, robot_item, chest}


