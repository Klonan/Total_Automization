local require = function(name) return require("data/entities/"..name) end

require("command_center/command_center")
require("deploy_machine/deploy_machine")
require("logistic_beacon/logistic_beacon")

--require("teleporters/teleporters")
--require("turrets/turrets")
--require("setup_time/setup_time")
--require("walls/walls")
--require("damage_indicator")
--require ("trade_chests/trade_chests")