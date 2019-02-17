local require = function(str) return require("data/entities/deploy_machine/"..str) end

require("iron_deploy_machine")
require("circuit_deploy_machine")
