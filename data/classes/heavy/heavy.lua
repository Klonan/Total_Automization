local path = util.path("data/classes/heavy/")
local heavy = util.base_player()
heavy.name = names.heavy
heavy.running_speed = util.speed(0.77)
heavy.max_health = 300
local scale = 1.8
util.recursive_hack_scale(heavy, scale)
util.scale_boxes(heavy, scale)

data:extend
{
  heavy
}
