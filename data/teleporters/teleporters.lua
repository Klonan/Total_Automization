--TODO
-- landmine to trigger event
-- Use roboport door open and closed as graphics

local entry = util.copy(data.raw["land-mine"]["land-mine"])

entry.name = "entry"
entry.trigger_radius = 1
entry.timeout = 5 * 60
entry.max_health = 200
entry.shooting_cursor_size = 0
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
        entity_name = "entry",
        trigger_created_entity = true
      },
      {
        type = "create-entity",
        entity_name = "explosion"
      },
      {
        type = "damage",
        damage = { amount = 1000, type = "explosion"}
      }
    }
  }
}
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

local entry_item = util.copy(data.raw.item["land-mine"])
entry_item.name = "entry-item"
entry_item.place_result = "entry"
entry_item.icon = "__Team_Factory__/data/teleporters/teleporter-icon.png"
entry_item.icon_size = 97
entry_item.minable = nil

data:extend
{
  entry,
  entry_item,
  exit
}
