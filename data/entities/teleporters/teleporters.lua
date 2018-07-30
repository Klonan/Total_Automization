local path = util.path("data/entities/teleporters/")
local teleporter = util.copy(data.raw["land-mine"]["land-mine"])
local name = require"shared".entities.teleporter

teleporter.name = name
teleporter.localised_name = name
teleporter.trigger_radius = 2
teleporter.timeout = SU(5 * 60)
teleporter.max_health = 200
--teleporter.shooting_cursor_size = 0
teleporter.dying_explosion = nil
teleporter.action = nil
teleporter.force_die_on_attack = true
teleporter.trigger_force = "friend"
teleporter.order = name
teleporter.picture_safe =
{
  filename = path.."teleporter-closed.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1
}
teleporter.picture_set = 
{
  filename = path.."teleporter-open.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1
}
teleporter.picture_set_enemy = 
{
  filename = path.."teleporter-open.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1,
  tint = {r = 1}
}
teleporter.minable = {result = name, mining_time = 3}
util.scale_boxes(teleporter, 2)
util.remove_flag(teleporter, "placeable-off-grid")

local teleporter_item = util.copy(data.raw.item["land-mine"])
teleporter_item.name = name
teleporter_item.localised_name = name
teleporter_item.place_result = name
teleporter_item.icon = path.."teleporter-icon.png"
teleporter_item.icon_size = 97


local fire = require("data/tf_util/tf_fire_util")

local teleporter_explosion = util.copy(data.raw.explosion.explosion)
teleporter_explosion.name = "teleporter-explosion"
teleporter_explosion.animations = fire.create_fire_pictures({tint = {b = 1, g = 1}, shift = {0, 1}, scale = 2, animation_speed = SD(0.5)})
teleporter_explosion.sound =
{
  filename = path.."teleporter-explosion.ogg",
  volume = 1
}

data:extend
{
  teleporter,
  teleporter_item,
  teleporter_explosion
}
