local name = require("shared").entities.recon_outpost
local path = util.path("data/entities/recon_outpost/")

local radar = util.copy(data.raw.radar.radar)
radar.name = name
radar.localised_name = name
radar.energy_source = {type = "void"}
radar.rotation_speed = SD(0.04)
radar.pictures =
{
  layers =
  {
    {
      filename = path.."recon_outpost.png",
      priority = "low",
      width = 1104/8,
      height = 159,
      apply_projection = false,
      direction_count = 8,
      line_length = 8,
      shift = util.by_pixel(1, -16)
    }
  }
}
radar.max_distance_of_nearby_sector_revealed = 3
radar.max_distance_of_sector_revealed = 8
radar.energy_per_sector = tostring(100 * 60 * 15).."W"
radar.energy_usage = tostring(100).."W"
radar.energy_per_nearby_scan = "0J"
radar.order = "noob"
radar.tile_width = 32
radar.tile_height = 32
util.scale_boxes(radar, 0.5)
util.recursive_hack_scale(radar, 0.5)
--error(serpent.block(radar))

local item = util.copy(data.raw.item.radar)
item.icon = path.."recon_outpost_icon.png"
item.icon_size = 150
item.name = name
item.localised_name = name
item.place_result = name


data:extend{radar, item}
