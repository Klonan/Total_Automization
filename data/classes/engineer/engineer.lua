local path = util.path("data/classes/engineer/")
local engineer = util.base_player()
engineer.name = names.engineer
engineer.running_speed = util.speed(1)
engineer.max_health = 125
local scale = 1
util.recursive_hack_scale(engineer, scale)
util.scale_boxes(engineer, scale)

sprite =
{
  type = "sprite",
  name = names.engineer,
  filename = path.."engineer.png",
  width = 750,
  height = 786
}

data:extend
{
  engineer, sprite
}
