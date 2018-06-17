
local path = util.path("data/classes/demoman/")
local demoman = util.base_player()
demoman.name = names.demoman
demoman.running_speed = util.speed(0.93)
local scale = 1.6
util.recursive_hack_scale(demoman, scale)
util.scale_boxes(demoman, scale)


sprite =
{
  type = "sprite",
  name = names.demoman,
  filename = path.."demoman.png",
  width = 955,
  height = 955,
  --flags = {}
}

data:extend
{
  demoman, sprite
}





