local require = function(str) return require("data/entities/turrets/"..str) end

require("small_gun_turret")
require("big_gun_turret")
require("laser_turret")

util.prototype.remove_entity_prototype(data.raw["ammo-turret"]["gun-turret"])
util.prototype.remove_entity_prototype(data.raw["electric-turret"]["laser-turret"])
