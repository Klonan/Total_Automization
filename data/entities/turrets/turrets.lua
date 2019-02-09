local tf_require = function(str) return tf_require("data/entities/turrets/"..str) end

tf_require("small_gun_turret")
tf_require("big_gun_turret")
tf_require("laser_turret")
tf_require("blaster_turret")
tf_require("tazer_turret/tazer_turret")
tf_require("rocket_turret/rocket_turret")

util.prototype.remove_entity_prototype(data.raw["ammo-turret"]["gun-turret"])
util.prototype.remove_entity_prototype(data.raw["electric-turret"]["laser-turret"])
util.prototype.remove_entity_prototype(data.raw["fluid-turret"]["flamethrower-turret"])
util.prototype.remove_entity_prototype(data.raw["artillery-turret"]["artillery-turret"])
