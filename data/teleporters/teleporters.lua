--TODO
-- landmine to trigger event
-- Use roboport door open and closed as graphics

local entry = util.copy(data.raw["land-mine"]["land-mine"])

entry.name = "entry"
entry.trigger_radius = 1
entry.timeout = SU(5 * 60)
entry.max_health = 200
entry.shooting_cursor_size = 0
entry.dying_explosion = "big-explosion"
entry.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    source_effects =
    {
      {
        type = "create-entity",
        entity_name = "explosion"
      }
    }
  }
}
entry.force_die_on_attack = true
entry.order = "entry"
entry.picture_safe =
{
  filename = "__Team_Factory__/data/teleporters/teleporter-closed.png",
  priority = "medium",
  width = 97,
  height = 77,
  scale = 1
}
entry.picture_set = 
{
  filename = "__Team_Factory__/data/teleporters/teleporter-open.png",
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
exit.action =
{
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
}
exit.force_die_on_attack = false

local entry_item = util.copy(data.raw.item["land-mine"])
entry_item.name = "entry-item"
entry_item.place_result = "entry"
entry_item.icon = "__Team_Factory__/data/teleporters/teleporter-icon.png"
entry_item.icon_size = 97

local exit_item = util.copy(entry_item)
exit_item.name = "exit-item"
entry_item.place_result = "exit"

data:extend
{
  entry,
  entry_item,
  exit,
  exit_item
}
