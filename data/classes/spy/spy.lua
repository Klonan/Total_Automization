path = util.path("data/classes/spy/")
local spy = util.base_player()
spy.name = names.spy
spy.running_speed = util.speed(1.07)
spy.max_health = 125
local scale = 1
util.recursive_hack_scale(spy, scale)
util.scale_boxes(spy, scale)

sprite =
{
  type = "sprite",
  name = names.spy,
  filename = path.."spy.png",
  width = 340,
  height = 863
}

data:extend
{
  spy, sprite
}





