local data = 
{
  machines = {},
  tick_check = {}
}

defines.events["on_unit_deployed"] = script.generate_event_name()

local names = require("shared").deployers
local units = require("shared").units
local map = {}
for k, deployer in pairs (names) do
  map[deployer] = true
end

local direction_enum = {
  [defines.direction.north] = {0, -0.6},
  [defines.direction.south] = {0, 0.6},
  [defines.direction.east] = {0.6, 0},
  [defines.direction.west] = {-0.6, 0}
}

local deploy_unit = function(source, name, count)
  local offset = direction_enum[source.direction]
  local bounding_box = source.bounding_box
  local offset_x = offset[1] * (bounding_box.right_bottom.x - bounding_box.left_top.x)
  local offset_y = offset[2] * (bounding_box.right_bottom.y - bounding_box.left_top.y)
  local position = {source.position.x + offset_x, source.position.y + offset_y}
  local surface = source.surface
  local force = source.force
  local deployed = 0
  for k = 1, count do
    local deploy_position = surface.find_non_colliding_position(name, position, 8, 1)
    if deploy_position then
      local unit = surface.create_entity{name = name, position = deploy_position, force = force}
      script.raise_event(defines.events.on_unit_deployed,{unit = unit, source = source})
      deployed = deployed + 1
    else
      break
    end
  end
  return deployed
end

local no_recipe_check_again = 300
local check_deployer = function(entity)
  if not (entity and entity.valid) then return end
  --game.print("Checking entity: "..entity.name)
  local recipe = entity.get_recipe()
  if not recipe then
    --No recipe, so lets check this guy again in some ticks
    local check_tick = game.tick + no_recipe_check_again
    data.tick_check[check_tick] = data.tick_check[check_tick] or {}
    data.tick_check[check_tick][entity.unit_number] = entity
    return
  end
  local progress = entity.crafting_progress
  local prototype = game.entity_prototypes[entity.name]
  local speed = prototype.crafting_speed --How much energy per second
  local remaining_ticks = 1 + math.ceil(((recipe.energy * (1 - progress)) / speed) * 60)
  local check_tick = game.tick + remaining_ticks
  data.tick_check[check_tick] = data.tick_check[check_tick] or {}
  data.tick_check[check_tick][entity.unit_number] = entity

  local inventory = entity.get_inventory(defines.inventory.assembling_machine_output)
  local contents = inventory.get_contents()
  local entities = game.entity_prototypes
  for name, count in pairs (contents) do
    --Simplified way for now, maybe map item to entity later...
    if entities[name] then
      deployed_count = deploy_unit(entity, name, count)
      if deployed_count > 0 then
        entity.remove_item{name = name, count = deployed_count}
      end
    end
  end

end

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if not (map[entity.name]) then return end
  data.machines[entity.unit_number] = entity
  check_deployer(entity)
end

local on_tick = function(event)
  local entities = data.tick_check[event.tick]
  if not entities then return end
  for unit_number, entity in pairs (entities) do
    check_deployer(entity)
  end
  data.tick_check[event.tick] = nil
end

local on_entity_settings_pasted = function(event)
  local source = event.source
  local destination = event.destination
  if not (source and source.valid and destination and destination.valid) then return end
  if not map[source.name] then return end
  if not map[destination.name] then return end
end

local events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick
}

local unit_deployment = {}

unit_deployment.on_event = handler(events)

unit_deployment.on_init = function()
  global.unit_deployment = global.unit_deployment or data
end

unit_deployment.on_load = function()
  data = global.unit_deployment
end

return unit_deployment