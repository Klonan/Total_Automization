local tf_require = function(string) return tf_require("data/items/ammo/"..string) end

tf_require("pistol/pistol_magazine")
tf_require("machine_gun/piercing_magazine")
tf_require("machine_gun/uranium_magazine")

if true then return end
tf_require("machine_gun/standard_magazine")
tf_require("machine_gun/explosive_magazine")
tf_require("machine_gun/extended_magazine")
tf_require("machine_gun/smart_magazine")

tf_require("shotgun/standard_shells")
tf_require("shotgun/incendiary_shells")
tf_require("shotgun/slug_shells")

tf_require("pistol/revolver_rounds")


tf_require("sniper_rifle/sniper_rounds")

tf_require("rocket_launcher/rocket")
tf_require("rocket_launcher/cluster_rocket")
