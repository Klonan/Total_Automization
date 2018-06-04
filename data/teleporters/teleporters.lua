local path = util.path("data/teleporters/")
local entry = util.copy(data.raw["land-mine"]["land-mine"])

entry.name = "entry"
entry.trigger_radius = 1
entry.timeout = SU(5 * 60)
entry.max_health = 200
entry.shooting_cursor_size = 0
entry.dying_explosion = nil
entry.action = nil
entry.force_die_on_attack = true
entry.order = "entry"
entry.picture_safe =
{
  filename = path.."teleporter-closed.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1
}
entry.picture_set = 
{
  filename = path.."teleporter-open.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1
}
entry.picture_set_enemy = entry.picture_set
entry.minable = nil
util.scale_boxes(entry, 2)
util.remove_flag(entry, "placeable-off-grid")

exit = util.copy(entry)
exit.name = "exit"
--pushback!
exit.trigger_radius = 0
exit.action = nil
--[[{
  {
    type = "area",
    radius = 2.5,
    force = "enemy",
    action_delivery =
    {
     {
       type = "instant",
       target_effects =
       {
        {
          type = "push-back",
          distance = 1.5,
        }
       }
     }
    }
  }
}]]
exit.force_die_on_attack = false

local entry_item = util.copy(data.raw.item["land-mine"])
entry_item.name = "entry-item"
entry_item.place_result = "entry"
entry_item.icon = path.."teleporter-icon.png"
entry_item.icon_size = 97

local exit_item = util.copy(entry_item)
exit_item.name = "exit-item"
entry_item.place_result = "exit"

local fire = require("data/tf_fire_util")

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
  entry,
  entry_item,
  exit,
  exit_item,
  teleporter_explosion
}
