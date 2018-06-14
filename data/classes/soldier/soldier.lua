path = util.path("data/classes/soldier/")
local soldier = util.base_player()
soldier.name = names.soldier
soldier.running_speed = util.speed(0.8)
soldier.max_health = 200
local scale = 1.3
util.recursive_hack_scale(soldier, scale)
util.scale_boxes(soldier, scale)



data:extend
{
  soldier
}





