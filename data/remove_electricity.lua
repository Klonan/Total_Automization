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

local technologies = data.raw.technology
local recipes = data.raw.recipe
local items = data.raw.item


local remove_from_recipe = function(recipe, name)
  --log(name)
  if recipe.normal then
    --Screw this half-assed system
    for k, v in pairs (recipe.normal) do
      recipe[k] = v
    end
    recipe.normal = nil
    recipe.expensive = nil
  end

  local result = recipe.result
  if result == name then
    return
  
  end
  local ingredients = recipe.ingredients
  if ingredients then
    for i = #ingredients, 1, -1 do
      if (ingredients[i].name or ingredients[i][1]) == name then
        table.remove(ingredients, i)
      end
    end
    if #ingredients == 0 then
      return
    end
  end
  
  local products = recipe.products or recipe.products
  if products then
    for i = #products, 1, -1 do
      if (products[i].name or products[i][1]) == name then
        table.remove(products, i)
      end
    end
    if #products == 0 then
      return
    end
  end

  if recipe.main_product and recipe.main_product == name then
    recipe.main_product = nil
  end

  return recipe
end

local remove_technology = function(name)
  for k, tech in pairs (technologies) do
    local req = tech.prerequisites
    if req then
      for i = #req, 1, -1 do
        if req[i] == name then
          table.remove(req, i)
        end
      end
      if #req == 0 then
        tech.prerequisites = nil
      end
    end
  end
  technologies[name] = nil
end

local remove_item_from_technology = function(name)
  for k, tech in pairs (technologies) do
    local packs = tech.unit.ingredients
    for i = #packs, 1, -1 do
      if (packs[i].name or packs[i][1]) == name then
        table.remove(packs, i)
      end
    end
    if #packs == 0 then
      remove_technology(tech.name)
    end
  end
end

local remove_recipe_from_technologies = function(name)
  log("Removing recipe from technologies: "..name)
  for k, technology in pairs (data.raw.technology) do
    local effects = technology.effects
    if effects then
      log(technology.name.." = "..#effects)
      for i = #effects, 1, -1 do
        --log((effects[i].recipe or "nil").. " == "..name)
        if (effects[i].recipe == name) then
          log("Removed from: "..k)
          table.remove(effects, i)
        end
      end
      if #effects == 0 then
        remove_technology(technology.name)
      end
    end
  end
end

local remove_from_recipes = function(name)
  log("Removing item from recipes: "..name)
  for k, recipe in pairs (recipes) do
    local result = remove_from_recipe(recipe, name)
    if not result then
      remove_recipe_from_technologies(recipe.name)
      recipes[k] = nil
    end
  end
end

local remove_from_items = function(name)
  for k, item in pairs (items) do
    if item.place_result == name then
      remove_from_recipes(item.name)
      items[k] = nil
      return
    end
    if item.rocket_launch_product == name then
      item.rocket_launch_product = nil
    end
    if item.rocket_launch_products then
      util.remove_from_list(item.rocket_launch_products, name)
    end
  end
end

local find_mention
find_mention = function(table, name)
  for k, v in pairs (table) do
    if type(v) == "table" then
      find_mention(v, name)
    elseif k == name or ((type(v) == "string") and (v == name)) then
      return true
    end
  end
end
local remove_from_achievements = function(name)
  for type_name, type in pairs (data.raw) do
    if string.find(type_name, "achievement") then
      for k, achievement in pairs (type) do
        if find_mention(achievement, name) then
          type[k] = nil
        end
      end
    end
  end
end

for k, type in pairs (list) do
  for j, ent in pairs (data.raw[type]) do
    log(ent.name)
    remove_from_items(ent.name)
    remove_from_achievements(ent.name)
    ent.minable = nil
    ent.order = "Z-DELETED"
    --data.raw[type][ent.name] = nil
  end
end

for k, type in pairs (data.raw) do
  for j, ent in pairs (type) do
    if ent.energy_source then
      ent.energy_source.type = "void"
    end
  end
end

