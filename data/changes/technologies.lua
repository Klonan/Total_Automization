--Remove technologies we don't care about

local types =
{
  ["mining-drill-productivity-bonus"] = true,
  ["ammo-damage"] = true,
  ["gun-speed"] = true,
  ["turret-attack"] = true,
  ["artillery-range"] = true,
  ["deconstruction-time-to-live"] = true,
  ["worker-robot-speed"] = true,
  ["worker-robot-storage"] = true,
  ["laboratory-speed"] = true,
  ["inserter-stack-size-bonus"] = true,
  ["stack-inserter-capacity-bonus"] = true,
  ["ghost-time-to-live"] = true,
  ["train-braking-force-bonus"] = true,
  ["laboratory-productivity"] = true,
  ["maximum-following-robots-count"] = true,
  ["quick-bar-count"] = true,
  ["auto-character-logistic-trash-slots"] = true,
  ["character-logistic-trash-slots"] = true,
  ["character-logistic-slots"] = true,
}

util.prototype.remove_technology_effect_type(types)

--Unlock all recipes that normall unlock with tech

local recipes = data.raw.recipe
local unlock_recipe = function(name)
  local recipe = data.raw.recipe[name]
  if recipe then 
    recipe.enabled = true
  end
end


local packs = {}

for name, tech in pairs (data.raw.technology) do
  for k = #(tech.effects or {}), 1, -1 do
    if tech.unit then
      if tech.unit.ingredients then
        for k, ingredient in pairs (tech.unit.ingredients) do
          packs[ingredient[1]] = true
        end
      end
    end
    local effect = tech.effects[k]
    if effect and effect.type == "unlock-recipe" then
      unlock_recipe(effect.recipe)
      table.remove(tech.effects, k)
    end
  end
  if not tech.effects then
    util.prototype.remove_technology(name)
  elseif not tech.effects[1] then
    util.prototype.remove_technology(name)
  end
end

--Remove science packs

local items = data.raw.tool
for name, bool in pairs (packs) do
  if items[name] then
    util.prototype.remove_item_prototype(items[name])
  end
end

--Remove the labs

for k, lab in pairs (data.raw.lab) do
  util.prototype.remove_entity_prototype(lab)
end


