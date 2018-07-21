local path = util.path("data/entities/auto_miner")
local items = data.raw.item
local recipes = data.raw.recipe
local rename_recipe = function(old, new)
  for k, recipe in pairs (recipes) do
    if recipe.normal then
      for k, v in pairs(recipe.normal) do
        recipe[k] = v
      end
      recipe.normal = nil
      recipe.expensive = nil
    end
    for k, ingredient in pairs (recipe.ingredients) do
      if ingredient.name and ingredient.name == old then
        ingredient.name = new
      end
      if ingredient[1] and ingredient[1] == old then
        ingredient[1] = new
      end
    end
    if recipe.result and recipe.result == old then
      recipe.result = new
    end
    for k, product in pairs (recipe.products or {}) do
      if product.name and product.name == old then
        product.name = new
      end
      if product[1] and product[1] == old then
        product[1] = new
      end
    end
  end
end

local rename_item = function(old, new)
  for k, item in pairs (items) do
    if item.place_result and item.place_result == old then
      item.place_result = new
    end
    if item.name == old then
      item.name = new
      items[new] = item
      items[old] = nil
      rename_recipe(old, new)
    end
  end
end

local old_name = "electric-mining-drill"
local big_miner = data.raw["mining-drill"][old_name]
local big_miner_name = require("shared").entities.big_miner
big_miner.minable.result = big_miner_name
big_miner.name = big_miner_name
data.raw["mining-drill"][big_miner_name] = big_miner
data.raw["mining-drill"][old_name] = nil
big_miner.localised_name = big_miner_name
rename_item(old_name, big_miner_name)

local scale = 5 / 3
util.recursive_hack_make_hr(big_miner)
util.recursive_hack_scale(big_miner, scale)
util.scale_boxes(big_miner, scale)
--util.recursive_hack_tint{r = 1}

big_miner.energy_source = {type = "void", emissions = 0.2}
big_miner.mining_power = 4.9
big_miner.mining_speed = 13.333 / 4
big_miner.localised_description = "Each big miner outputs 1 half of a transport belt."
big_miner.resource_searching_radius = 4.49
--miner.minable = {mining_time = 2, result = name}
big_miner.vector_to_place_result = {0, -1.75 * scale}
big_miner.order = "noob"
big_miner.input_fluid_box.pipe_connections =
{
  { position = {-2.5, 0} },
  { position = {2.5, 0} },
  { position = {0, 2.5} }
}
big_miner.radius_visualisation_picture.scale = 1

local original_name = "burner-mining-drill"
local small_miner_name = require("shared").entities.small_miner
local small_miner = data.raw["mining-drill"][original_name]
data.raw["mining-drill"][small_miner_name] = small_miner
data.raw["mining-drill"][original_name] = nil
rename_item(original_name, small_miner_name)
small_miner.name = small_miner_name
small_miner.localised_name = small_miner_name
small_miner.minable.result = small_miner_name



local scale = 4 / 2
util.recursive_hack_make_hr(small_miner)
util.recursive_hack_scale(small_miner, scale)
util.scale_boxes(small_miner, scale)
--util.recursive_hack_tint{r = 1}

small_miner.energy_source = {type = "void", emissions = 0.2}
small_miner.mining_power = 4.9
small_miner.mining_speed = 13.333 / 8
small_miner.localised_description = "Each small miner outputs 1 quater of a transport belt."
small_miner.resource_searching_radius = 4.49
--miner.minable = {mining_time = 2, result = name}
small_miner.vector_to_place_result = {-1, -2}
--miner.radius_visualisation_picture.scale = 1

--data:extend{miner, item, recipe}

