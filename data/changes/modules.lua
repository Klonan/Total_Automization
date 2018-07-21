--Remove modules.

local modules = data.raw.module

for k, item in pairs (modules) do
  util.prototype.remove_item_prototype(item)
end

--And so, we don't need beacons

local beacons = data.raw.beacon

for k, ent in pairs (beacons) do
  util.prototype.remove_entity_prototype(ent)
end