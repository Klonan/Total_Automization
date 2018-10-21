local belts = data.raw["transport-belt"]

local slow_belt = belts["transport-belt"]
slow_belt.speed = SD(slow_belt.speed * 2)

local fast_belt = belts["fast-transport-belt"]
--fast_belt.speed = SD(fast_belt.speed * 2)
util.prototype.remove_entity_prototype(fast_belt)

local express_belt = belts["express-transport-belt"]
util.prototype.remove_entity_prototype(express_belt)

local splitters = data.raw["splitter"]
local slow_splitter = splitters["splitter"]
slow_splitter.speed = slow_belt.speed

local fast_splitter = splitters["fast-splitter"]
--fast_splitter.speed = fast_belt.speed
util.prototype.remove_entity_prototype(fast_splitter)

local express_splitter = splitters["express-splitter"]
util.prototype.remove_entity_prototype(express_splitter)

local grundys = data.raw["underground-belt"]
local slow_grundy = grundys["underground-belt"]
slow_grundy.speed = slow_belt.speed

local fast_grundy = grundys["fast-underground-belt"]
--fast_grundy.speed = fast_belt.speed
util.prototype.remove_entity_prototype(fast_grundy)

local express_grundy = grundys["express-underground-belt"]
util.prototype.remove_entity_prototype(express_grundy)

local loaders = data.raw["loader"]
local slow_loader = loaders["loader"]
slow_loader.speed = slow_belt.speed

local fast_loader = loaders["fast-loader"]
--fast_loader.speed = fast_belt.speed
util.prototype.remove_entity_prototype(fast_loader)

local express_loader = loaders["express-loader"]
util.prototype.remove_entity_prototype(express_loader)