local tf_require = function(str) return tf_require("data/entities/deploy_machine/"..str) end

local group =
{
  type = "item-group",
  name = "units",
  order = "zzz",
  icon = "__base__/graphics/icons/big-spitter.png",
  icon_size = 32
}

--data:extend{group}


tf_require("iron_deploy_machine")
--tf_require("bio_deploy_machine")
tf_require("circuit_deploy_machine")
