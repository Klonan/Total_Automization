--So, we just want to hand assign guns to characters, no crafting of guns or using them really...
--The item itself might be used somewhere? so we just remove the recipes

for k, gun in pairs (data.raw.gun) do
  util.prototype.remove_item_from_recipes(gun.name)
end

--Same for ammo...

for k, ammo in pairs (data.raw.ammo) do
  util.prototype.remove_item_from_recipes(ammo.name)
end

--okie, no landmines either... 

util.prototype.remove_item_from_recipes("land-mine")

--No equipment...

for k, equipment in pairs (data.raw.item) do
  if equipment.placed_as_equipment_result then
    util.prototype.remove_item_from_recipes(equipment.name)
  end
end

--No armor...

for k, armor in pairs (data.raw.armor) do
  util.prototype.remove_item_from_recipes(armor.name)
end
