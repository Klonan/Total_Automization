--We removed Steam generation, so this recipe is worthless
--But i am lazy, lets use this to make crude oil
local recipe = data.raw.recipe["coal-liquefaction"]
--error(serpent.block(recipe))
recipe.ingredients =
{
  {type = "fluid", name = "water", amount = 100},
  {type = "item", name = "coal", amount = 25}
}
recipe.main_product = "crude-oil"
recipe.results =
{
  {type = "fluid", name = "crude-oil", amount = 15}
}
