local path = util.path("data/classes/medic/")
local medic = util.base_player()
medic.name = names.medic
medic.running_speed = util.speed(1.07)

sprite =
{
  type = "sprite",
  name = names.medic,
  filename = path.."medic.png",
  width = 750,
  height = 786
}

data:extend{medic, sprite}

