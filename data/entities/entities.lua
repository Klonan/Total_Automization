local tf_require = function(name) return tf_require("data/entities/"..name) end

tf_require("command_center/command_center")
tf_require("deploy_machine/deploy_machine")
tf_require("logistic_beacon/logistic_beacon")

--tf_require("teleporters/teleporters")
--tf_require("turrets/turrets")
--tf_require("setup_time/setup_time")
--tf_require("walls/walls")
--tf_require("damage_indicator")
--tf_require ("trade_chests/trade_chests")