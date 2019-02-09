local tf_require = function(string) return tf_require("data/items/weapons/"..string) end

tf_require("machine_gun/machine_gun")
tf_require("machine_gun/submachine_gun")
tf_require("shotgun/shotgun")
tf_require("pistol/pistol")
tf_require("pistol/revolver")
tf_require("sniper_rifle/sniper_rifle")
tf_require("rocket_launcher/rocket_launcher")