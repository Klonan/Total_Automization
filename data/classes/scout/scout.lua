local path = util.path("data/classes/scout/")
local scout = util.base_player()
scout.name = names.scout
local scale = 0.8
util.recursive_hack_scale(scout, scale)
util.scale_boxes(scout, scale)
scout.running_speed = util.speed(1.33)

sprite =
{
  type = "sprite",
  name = names.scout,
  filename = path.."scout.png",
  width = 750,
  height = 786
}

data:extend
{
  scout, sprite
}





