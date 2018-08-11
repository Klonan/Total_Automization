local require = function(str) return require("data/entities/turrets/"..str) end

require("small_gun_turret")
require("big_gun_turret")
require("laser_turret")
require("blaster_turret")
require("tesla_turret/tesla_turret")
require("rocket_turret/rocket_turret")

util.prototype.remove_entity_prototype(data.raw["ammo-turret"]["gun-turret"])
util.prototype.remove_entity_prototype(data.raw["electric-turret"]["laser-turret"])
util.prototype.remove_entity_prototype(data.raw["fluid-turret"]["flamethrower-turret"])
util.prototype.remove_entity_prototype(data.raw["artillery-turret"]["artillery-turret"])
