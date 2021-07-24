

local script_data =
{
  machines = {},
  tick_check = {}
}

local names = names.deployers
local units = names.units

local deployer_map

local get_deployer_map = function()
  if deployer_map then
    return deployer_map
  end
  deployer_map = {}
  for name, prototype in pairs (game.item_prototypes["select-units"].entity_filters) do
    if prototype.type ~= "unit" then
      deployer_map[name] = true
    end
  end
  return deployer_map
end

local unit_spawned_event

local direction_enum = {
  [defines.direction.north] = {0, -1},
  [defines.direction.south] = {0, 1},
  [defines.direction.east] = {1, 0},
  [defines.direction.west] = {-1, 0}
}

local deploy_unit = function(source, prototype, count)
  if not (source and source.valid) then return end
  local direction = source.direction
  local offset = direction_enum[direction]
  local name = prototype.name
  local deploy_bounding_box = prototype.collision_box
  local bounding_box = source.bounding_box
  local offset_x = offset[1] * ((bounding_box.right_bottom.x - bounding_box.left_top.x) / 2) + ((deploy_bounding_box.right_bottom.x - deploy_bounding_box.left_top.x) / 2)
  local offset_y = offset[2] * ((bounding_box.right_bottom.y - bounding_box.left_top.y) / 2) + ((deploy_bounding_box.right_bottom.y - deploy_bounding_box.left_top.y) / 2)
  local position = {source.position.x + offset_x, source.position.y + offset_y}
  local surface = source.surface
  local force = source.force
  local deployed = 0
  local can_place_entity = surface.can_place_entity
  local find_non_colliding_position = surface.find_non_colliding_position
  local create_entity = surface.create_entity
  for k = 1, count do
    if not surface.valid then break end
    if not source.valid then break end
    local deploy_position = can_place_entity{name = name, position = position, direction = direction, force = force, build_check_type = defines.build_check_type.manual} and position or find_non_colliding_position(name, position, 0, 1)
    local unit = create_entity{name = name, position = deploy_position, force = force, direction = direction, raise_built = true}
    if unit and unit.valid then
      script.raise_event(unit_spawned_event, {entity = unit, spawner = source})
    end
    deployed = deployed + 1
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
    script_data.tick_check[check_tick] = script_data.tick_check[check_tick] or {}
    script_data.tick_check[check_tick][entity.unit_number] = entity
    return
  end
  local progress = entity.crafting_progress
  local speed = entity.crafting_speed --How much energy per second
  local remaining_ticks = 1 + math.ceil(((recipe.energy * (1 - progress)) / speed) * 60)
  local check_tick = game.tick + remaining_ticks
  script_data.tick_check[check_tick] = script_data.tick_check[check_tick] or {}
  script_data.tick_check[check_tick][entity.unit_number] = entity

  local inventory = entity.get_inventory(defines.inventory.assembling_machine_output)
  local contents = inventory.get_contents()
  local entities = game.entity_prototypes
  for name, count in pairs (contents) do
    --Simplified way for now, maybe map item to entity later...
    local prototype = entities[name]
    if prototype then
      deployed_count = deploy_unit(entity, prototype, count)
      if deployed_count > 0 and entity.valid then
        entity.remove_item{name = name, count = deployed_count}
      end
    end
  end

end

local on_built_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if not (get_deployer_map()[entity.name]) then return end
  script_data.machines[entity.unit_number] = entity
  check_deployer(entity)
end

local on_tick = function(event)
  local entities = script_data.tick_check[event.tick]
  if not entities then return end
  for unit_number, entity in pairs (entities) do
    if entity.valid then
      check_deployer(entity)
    else
      entities[unit_number] = nil
    end
  end
  script_data.tick_check[event.tick] = nil
end

local unit_deployment = {}

unit_deployment.events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.script_raised_built] = on_built_entity,
  [defines.events.script_raised_revive] = on_built_entity,
  [defines.events.on_entity_cloned] = on_built_entity,
  [defines.events.on_tick] = on_tick
}

unit_deployment.on_init = function()
  global.unit_deployment = global.unit_deployment or script_data
end

unit_deployment.on_load = function()
  script_data = global.unit_deployment
  local control_events = remote.call("unit_control", "get_events")
  unit_spawned_event = control_events.on_unit_spawned
end

return unit_deployment