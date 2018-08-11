local require = function(str) return require("data/entities/deploy_machine/"..str) end

local group =
{
  type = "item-group",
  name = "units",
  order = "zzz",
  icon = "__base__/graphics/icons/big-spitter.png",
  icon_size = 32
}

--data:extend{group}


require("iron_deploy_machine")
require("bio_deploy_machine")
require("circuit_deploy_machine")
