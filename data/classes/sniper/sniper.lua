local path = util.path("data/classes/sniper/")
local sniper = util.base_player()
sniper.name = names.sniper
sniper.running_speed = util.speed(1)
sniper.max_health = 125
local scale = 1.2
util.recursive_hack_scale(sniper, scale)
util.scale_boxes(sniper, scale)


data:extend
{
  sniper
}