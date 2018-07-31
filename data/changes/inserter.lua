--Remove stack inserters

util.prototype.remove_entity_prototype(data.raw.inserter["stack-inserter"])
util.prototype.remove_entity_prototype(data.raw.inserter["filter-stack-inserter"])

--Just scale their inserting speeds...

for k, inserter in pairs (data.raw.inserter) do
  inserter.extension_speed = SD(inserter.extension_speed)
  inserter.rotation_speed = SD(inserter.rotation_speed)
end

