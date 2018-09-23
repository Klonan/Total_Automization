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
  {type = "fluid", name = "crude-oil", amount = 150}
}

--Don't need rocket silos or any of that junk

util.prototype.remove_entity_prototype(data.raw["rocket-silo"]["rocket-silo"])
util.prototype.remove_item_prototype(data.raw.item["satellite"])
util.prototype.remove_item_prototype(data.raw.item["rocket-escape-pod"])

for k, type in pairs (data.raw) do
  for k, entity in pairs (type) do
    entity.next_upgrade = nil
  end
end

for k, spawner in pairs (data.raw["unit-spawner"]) do
  table.insert(spawner.flags or {}, "placeable-off-grid")
end