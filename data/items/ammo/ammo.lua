local require = function(string) return require("data/items/ammo/"..string) end

require("machine_gun/explosive_magazine")
require("machine_gun/standard_magazine")
require("machine_gun/piercing_magazine")
require("machine_gun/extended_magazine")