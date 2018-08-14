local buy_name = require("shared").entities.buy_chest

local buy_chest = util.copy(data.raw["logistic-container"]["logistic-chest-buffer"])
buy_chest.name = buy_name
buy_chest.localised_name = buy_name
buy_chest.render_not_in_network_icon = false
buy_chest.minable = {result = buy_name, mining_time = 1}

local buy_item = util.copy(data.raw.item["logistic-chest-buffer"])
buy_item.name = buy_name
buy_item.localised_name = buy_name
buy_item.place_result = buy_name

data:extend{buy_chest, buy_item}

local sell_name = require("shared").entities.sell_chest

local sell_chest = util.copy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
sell_chest.name = sell_name
sell_chest.localised_name = sell_name
sell_chest.render_not_in_network_icon = false
sell_chest.minable = {result = sell_name, mining_time = 1}

local sell_item = util.copy(data.raw.item["logistic-chest-passive-provider"])
sell_item.name = sell_name
sell_item.localised_name = sell_name
sell_item.place_result = sell_name

data:extend{sell_chest, sell_item}

