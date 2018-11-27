local grid_name = "tiny-equipment-grid"
for k, armor in pairs (data.raw.armor) do
  armor.equipment_grid = armor.equipment_grid or name  
end

local grid =
{
  type = "equipment-grid",
  name = name,
  localised_name = name,
  width = 1,
  height = 1,
  equipment_categories = {"drone"}
}

local equipment_name = names.equipment.drone_port

local equipment =
{
  type = "roboport-equipment",
  name = equipment_name,
  localised_name = equipment_name,
  take_result = equipment_name,
  sprite =
  {
    filename = "__base__/graphics/equipment/personal-roboport-equipment.png",
    width = 64,
    height = 64,
    priority = "medium"
  },
  shape =
  {
    width = 1,
    height = 1,
    type = "full"
  },
  energy_source =
  {
    type = "electric",
    buffer_capacity = "35MJ",
    input_flow_limit = "3500KW",
    usage_priority = "secondary-input"
  },
  charging_energy = "1000kW",

  robot_limit = 0,
  construction_radius = 50,
  spawn_and_station_height = 0,
  charge_approach_distance = 0,

  recharging_animation =
  {
    filename = "__base__/graphics/entity/roboport/roboport-recharging.png",
    priority = "high",
    width = 37,
    height = 35,
    frame_count = 16,
    scale = 1.5,
    animation_speed = 0.5
  },
  recharging_light = {intensity = 0.4, size = 5},
  stationing_offset = {0, -0.6},
  charging_station_shift = {0, 0},
  charging_station_count = 0,
  charging_distance = 0,
  charging_threshold_distance = 0,
  categories = {"drone"}
},