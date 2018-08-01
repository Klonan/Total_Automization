--Remove cars

for k, entity in pairs (data.raw.car) do
  util.prototype.remove_entity_prototype(entity)
end

--Make locomotives run for free

for k, entity in pairs (data.raw.locomotive) do
  entity.energy_source = {type = "void"}
end