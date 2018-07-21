local p_util = util.prototype
--Oh boy, here we go
local list = {
  "boiler",
  "generator",
  "solar-panel",
  "accumulator",
  "electric-pole",
  "power-switch",
  "arithmetic-combinator",
  "power-switch",
  "constant-combinator",
  "decider-combinator",
  "programmable-speaker",
  "reactor",
  "heat-pipe" 
}

for k, type in pairs (list) do
  for j, ent in pairs (data.raw[type]) do
    p_util.remove_entity_prototype(ent)
  end
end

for k, type in pairs (data.raw) do
  for j, ent in pairs (type) do
    if ent.energy_source then
      ent.energy_source.type = "void"
    end
  end
end

data.raw.recipe["red-wire"] = nil
util.prototype.remove_recipe_from_technologies("red-wire")
data.raw.recipe["green-wire"] = nil
util.prototype.remove_recipe_from_technologies("green-wire")

