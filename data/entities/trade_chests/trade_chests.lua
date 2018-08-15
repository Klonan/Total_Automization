local path = util.path("data/entities/trade_chests/")
local buy_name = require("shared").entities.buy_chest

local buy_chest = util.copy(data.raw["logistic-container"]["logistic-chest-buffer"])
buy_chest.name = buy_name
buy_chest.localised_name = buy_name
buy_chest.render_not_in_network_icon = false
buy_chest.minable = {result = buy_name, mining_time = 1}
buy_chest.picture =
{
  layers =
  {
    buy_chest.picture,
    {
      filename = path.."trade_chest_dollar.png",
      height = 200,
      width = 200,
      flags = {},
      scale = (buy_chest.picture.width * (buy_chest.picture.scale or 1)) / 200,
      tint = {g = 1}
    }
  }
}
buy_chest.filter_count = 5

local buy_item = util.copy(data.raw.item["logistic-chest-buffer"])
buy_item.name = buy_name
buy_item.localised_name = buy_name
buy_item.place_result = buy_name
buy_item.icons =
{
  {
    icon = buy_item.icon,
    icon_size = buy_item.icon_size
  },
  {
    icon = path.."trade_chest_dollar.png",
    icon_size = 200,
    tint = {g = 1}
  }
}
buy_item.icon = nil

local buy_recipe = util.copy(data.raw.recipe["logistic-chest-buffer"])
buy_recipe.name = buy_name
buy_recipe.localised = buy_name
buy_recipe.result = buy_name
buy_recipe.enabled = true
buy_recipe.ingredients =
{
  {"steel-chest", 1}
}
buy_recipe.order = "z-a"

data:extend{buy_chest, buy_item, buy_recipe}

local sell_name = require("shared").entities.sell_chest

local sell_chest = util.copy(data.raw["logistic-container"]["logistic-chest-passive-provider"])
sell_chest.name = sell_name
sell_chest.localised_name = sell_name
sell_chest.render_not_in_network_icon = false
sell_chest.minable = {result = sell_name, mining_time = 1}
sell_chest.picture =
{
  layers =
  {
    sell_chest.picture,
    {
      filename = path.."trade_chest_dollar.png",
      height = 200,
      width = 200,
      flags = {},
      scale = (sell_chest.picture.width * (sell_chest.picture.scale or 1)) / 200,
      tint = {r = 1}
    }
  }
}

local sell_item = util.copy(data.raw.item["logistic-chest-passive-provider"])
sell_item.name = sell_name
sell_item.localised_name = sell_name
sell_item.place_result = sell_name
sell_item.icons =
{
  {
    icon = sell_item.icon,
    icon_size = sell_item.icon_size
  },
  {
    icon = path.."trade_chest_dollar.png",
    icon_size = 200,
    tint = {r = 1}
  }
}
sell_item.icon = nil

local sell_recipe = util.copy(data.raw.recipe["logistic-chest-passive-provider"])
sell_recipe.name = sell_name
sell_recipe.localised = sell_name
sell_recipe.enabled = true
sell_recipe.result = sell_name
sell_recipe.ingredients =
{
  {"steel-chest", 1}
}
sell_recipe.order = "z-b"

data:extend{sell_chest, sell_item, sell_recipe}

