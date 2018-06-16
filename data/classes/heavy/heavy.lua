local path = util.path("data/classes/heavy/")
local heavy = util.base_player()
heavy.name = names.heavy
heavy.running_speed = util.speed(0.77)
heavy.max_health = 300
local scale = 1.8
util.recursive_hack_scale(heavy, scale)
util.scale_boxes(heavy, scale)

sprite =
{
  type = "sprite",
  name = names.heavy,
  filename = path.."heavy.png",
  width = 750,
  height = 786
}

data:extend
{
  heavy, sprite
}
