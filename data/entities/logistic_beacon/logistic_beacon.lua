local name = names.entities.logistic_beacon
local path = util.path("data/entities/logistic_beacon/")

local beacon = util.copy(data.raw["roboport"]["roboport"])
beacon.name = name
beacon.localised_name = name
beacon.energy_source =
{
  type = "void",
  usage_priority = "secondary-input",
  input_flow_limit = "1J",
  buffer_capacity = "1J"
}
beacon.recharge_minimum = "0J"
beacon.energy_usage = "0J"
beacon.charging_energy = "1MW"
beacon.logistics_radius = 3
beacon.logistics_connection_distance = 16
beacon.construction_radius = 16
beacon.charge_approach_distance = 0
beacon.robot_slots_count = 0
beacon.material_slots_count = 0
beacon.stationing_offset = {0, 0}
beacon.charging_offsets = {{0, -1}}
beacon.order = name
beacon.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
beacon.selection_box = {{-1, -1}, {1, 1}}
beacon.base_animation = 
{
  layers =
  {
    {
      filename = path.."logistic_beacon.png",
      priority = "low",
      width = 1104/8,
      height = 159,
      line_length = 8,
      frame_count = 8,
      shift = util.by_pixel(1, -16),
      animation_speed = 0.5,
      scale = 0.5
    }
  }
}
beacon.base = util.empty_sprite()
beacon.base_patch = util.empty_sprite()
beacon.door_animation_up = util.empty_sprite()
beacon.door_animation_down = util.empty_sprite()
beacon.minable.name = name
--beacon.recharging_animation = util.empty_sprite()


local chest = util.copy(data.raw["logistic-container"]["logistic-chest-storage"])
chest.name = name.." Chest"
chest.localised_name = name.." Chest"
chest.collision_box = {{-0.8, -0.8}, {0.8, 0.8}}
chest.selection_box = {{-1, -1}, {1, 1}}
chest.collision_mask = {"doodad-layer"}
chest.order = "noob"
chest.inventory_size = 99
chest.picture = util.empty_sprite()
chest.minable = nil
chest.max_health = 1
chest.flags = {"hide-alt-info", "not-deconstructable"}


local item = util.copy(data.raw.item.roboport)
item.name = name
item.localised_name = name
item.place_result = name
item.icon = path.."logistic_beacon_icon.png"
item.icon_size = 150

data:extend(
  {
    beacon,
    item,
    chest
  }
)




