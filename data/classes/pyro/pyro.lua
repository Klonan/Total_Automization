local path = util.path("data/classes/pyro/")
local pyro = util.base_player()
pyro.name = names.pyro
pyro.max_health = 175
pyro.running_speed = util.speed(1)
pyro.resistances =
{
  {
    type = util.damage_type("pyro-fire"),
    percent = 60
  },
}
util.add_flag(pyro, "not-flammable")
--util.recursive_hack_scale(pyro, 1)
--class_util.recursive_hack_animation_speed(pyro, 0.8)

data:extend
{
  pyro
}
