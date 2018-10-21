--Remove stack inserters

util.prototype.remove_entity_prototype(data.raw.inserter["stack-inserter"])
util.prototype.remove_entity_prototype(data.raw.inserter["stack-filter-inserter"])

--Burner is pointless

local inserter = data.raw.recipe.inserter
local burner_inserter = data.raw.recipe["burner-inserter"]

inserter.ingredients = util.copy(burner_inserter.ingredients)

util.prototype.remove_entity_prototype(data.raw.inserter["burner-inserter"])


--Just scale their inserting speeds...

for k, inserter in pairs (data.raw.inserter) do
  inserter.extension_speed = SD(inserter.extension_speed)
  inserter.rotation_speed = SD(inserter.rotation_speed)
  inserter.override_stack_size = 2
end

