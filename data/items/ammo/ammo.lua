local require = function(string) return require("data/items/ammo/"..string) end

require("machine_gun/explosive_magazine")
require("machine_gun/standard_magazine")
require("machine_gun/piercing_magazine")
require("machine_gun/extended_magazine")
require("machine_gun/smart_magazine")

require("shotgun/standard_shells")
require("shotgun/incendiary_shells")
require("shotgun/slug_shells")

require("pistol/pistol_magazine")
require("pistol/revolver_rounds")
