local names = names.entities
local stone_wall = names.stone_wall
local stone_gate = names.stone_gate
local concrete_wall = names.concrete_wall
local concrete_gate = names.concrete_gate

local wall = util.copy(data.raw.wall["stone-wall"])
local stone_tint = {r = 0.6, g = 0.6, b = 0.6}
wall.name = stone_wall
wall.localised_name = stone_wall
wall.max_health = 500
wall.minable = {result = stone_wall, mining_time = 0.5}
wall.icons = {
  {
    icon = wall.icon,
    icon_size = wall.icon_size,
    tint = stone_tint
  }
}
wall.icon = nil

local item = {
  type = "item",
  name = stone_wall,
  localised_name = stone_wall,
  icons = wall.icons,
  flags = {},
  subgroup = "defensive-structure",
  order = "w-"..stone_wall,
  place_result = stone_wall,
  stack_size= 100
}

local recipe = {
  type = "recipe",
  name = stone_wall,
  localised_name = stone_wall,
  enabled = true,
  ingredients =
  {
    {"stone-brick", 5}
  },
  energy_required = 2,
  result = stone_wall
}
util.recursive_hack_tint(wall, stone_tint)
data:extend{wall, item, recipe}

local gate = util.copy(data.raw.gate["gate"])

gate.name = stone_gate
gate.localised_name = stone_gate
gate.max_health = 500
gate.minable = {result = stone_gate, mining_time = 0.5}
gate.icons = {
  {
    icon = gate.icon,
    icon_size = gate.icon_size,
    tint = stone_tint
  }
}

local item = {
  type = "item",
  name = stone_gate,
  localised_name = stone_gate,
  icons = gate.icons,
  flags = {},
  subgroup = "defensive-structure",
  order = "x-"..stone_gate,
  place_result = stone_gate,
  stack_size= 100
}

local recipe = {
  type = "recipe",
  name = stone_gate,
  localised_name = stone_gate,
  enabled = true,
  ingredients =
  {
    {stone_wall, 1}
  },
  energy_required = 0.2,
  result = stone_gate
}

util.recursive_hack_tint(gate, stone_tint)
data:extend{gate, item, recipe}

local wall = util.copy(data.raw.wall["stone-wall"])

wall.name = concrete_wall
wall.localised_name = concrete_wall
wall.max_health = 800
wall.minable = {result = concrete_wall, mining_time = 0.5}

local item = {
  type = "item",
  name = concrete_wall,
  localised_name = concrete_wall,
  icon = wall.icon,
  icon_size = wall.icon_size,
  flags = {},
  subgroup = "defensive-structure",
  order = "y-"..concrete_wall,
  place_result = concrete_wall,
  stack_size= 100
}

local recipe = {
  type = "recipe",
  name = concrete_wall,
  localised_name = concrete_wall,
  enabled = true,
  ingredients =
  {
    {"concrete", 15}
  },
  energy_required = 2,
  result = concrete_wall
}

data:extend{wall, item, recipe}


local gate = util.copy(data.raw.gate["gate"])

gate.name = concrete_gate
gate.localised_name = concrete_gate
gate.max_health = 800
gate.minable = {result = concrete_gate, mining_time = 0.5}

local item = {
  type = "item",
  name = concrete_gate,
  localised_name = concrete_gate,
  icon = gate.icon,
  icon_size = gate.icon_size,
  flags = {},
  subgroup = "defensive-structure",
  order = "z-"..concrete_gate,
  place_result = concrete_gate,
  stack_size= 100
}

local recipe = {
  type = "recipe",
  name = concrete_gate,
  localised_name = concrete_gate,
  enabled = true,
  ingredients =
  {
    {concrete_wall, 1}
  },
  energy_required = 0.2,
  result = concrete_gate
}

data:extend{gate, item, recipe}

util.prototype.remove_entity_prototype(data.raw.wall["stone-wall"])
util.prototype.remove_entity_prototype(data.raw.gate.gate)

