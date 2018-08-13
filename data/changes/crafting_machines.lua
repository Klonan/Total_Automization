--Don't want no stinking assembling machine 3
util.prototype.remove_entity_prototype(data.raw["assembling-machine"]["assembling-machine-3"])

--Scale the crafting speed of the others

for k, machine in pairs (data.raw.furnace) do
  machine.crafting_speed = SD(machine.crafting_speed * 2)
end
for k, machine in pairs (data.raw["assembling-machine"]) do
  machine.crafting_speed = SD(machine.crafting_speed * 2)
end

--Make electric furnaces more powerful! (Counter the more expense and the fact electricity and modules are gone)
local furnace = data.raw.furnace["electric-furnace"]
if furnace then
  furnace.crafting_speed = furnace.crafting_speed * 2
end