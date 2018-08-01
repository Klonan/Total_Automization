--Make gate recipe just 1 wall

local recipes = data.raw.recipe
local gate =  recipes["gate"]
if gate then 
  gate.ingredients = {{"stone-wall", 1}}
end