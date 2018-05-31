--TODO
-- landmine to trigger event
-- Use roboport door open and closed as graphics

local entry = util.copy(data.raw["land-mine"]["land-mine"])

entry.name = "entry"
entry.trigger_radius = 1
entry.timeout = 5 * 60
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
data:extend{entry}