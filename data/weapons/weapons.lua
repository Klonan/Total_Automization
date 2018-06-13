names = require("shared").weapon_names
local require = function(string) return require("data/weapons/"..string) end
require("grenade_launcher/grenade_launcher")
require("stickybomb_launcher/stickybomb_launcher")
require("flamethrower/flamethrower")
require("flare_gun/flare_gun")