local require = function(name) return require("data/entities/"..name) end

require ("teleporters/teleporters")
require ("command_center/command_center")
require ("deploy_machine/deploy_machine")
require ("turrets/turrets")
require ("setup_time/setup_time")
require ("walls/walls")
--require ("trade_chests/trade_chests")