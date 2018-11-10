local max = math.huge

local name = names.entities.construction_drone

local max_checks_per_tick = 6

local drone_pathfind_flags =
{
  allow_destroy_friendly_entities = false,
  cache = false,
  low_priority = false
}

local debug = false
local print = function(string)
  if not debug then return end
  game.print(string)
end

local data =
{
  ghosts_to_be_checked = {},
  ghosts_to_be_checked_again = {},
  idle_drones = {},
  cells = {},
  drone_commands = {}
}

local dist = function(cell_a, cell_b)
  local position1 = cell_a.owner.position
  local position2 = cell_b.owner.position
  return ((position2.x - position1.x) * (position2.x - position1.x)) + ((position2.y - position1.y) * (position2.y - position1.y))
end

local in_range = function(entity_1, entity_2)

  local position1 = entity_1.position
  local position2 = entity_2.position
  local distance =  (((position2.x - position1.x) * (position2.x - position1.x)) + ((position2.y - position1.y) * (position2.y - position1.y))) ^ 0.5
  return distance <= (entity_1.get_radius() + entity_2.get_radius()) + 1

end

local lowest_f_score = function(set, f_score)
  local lowest = max
  local bestcell
  for k, cell in pairs(set) do
    local score = f_score[cell.owner.unit_number]
    if score <= lowest then
      lowest = score
      bestcell = cell
    end
  end
  return bestcell
end

local insert = table.insert
local unwind_path
unwind_path = function(flat_path, map, current_cell)
  local index = current_cell.owner.unit_number
  if map[index] then
    insert(flat_path, 1, map[index])
    return unwind_path(flat_path, map, map[index])
  else
    return flat_path
  end
end

local get_path = function(start, goal, cells)

  local closed_set = {}
  local open_set = {}
  local came_from = {}

  local g_score = {}
  local f_score = {}
  local start_index = start.owner.unit_number
  open_set[start_index] = start
  g_score[start_index] = 0
  f_score[start_index] = dist(start, goal)

  local insert = table.insert
  while table_size(open_set) > 0 do

    local current = lowest_f_score(open_set, f_score)

    if current == goal then
      local path = unwind_path({}, came_from, goal)
      insert(path, goal)
      return path
    end

    local current_index = current.owner.unit_number
    open_set[current_index] = nil
    closed_set[current_index] = current

    for k, neighbor in pairs(current.neighbours) do
      local neighbor_index = neighbor.owner.unit_number
      if not closed_set[neighbor_index] then
        local tentative_g_score = g_score[current_index] + dist(current, neighbor)
        local new_node = not open_set[neighbor_index]
        if new_node then
          open_set[neighbor.owner.unit_number] = neighbor
          f_score[neighbor.owner.unit_number] = max
        end
        if new_node or tentative_g_score < g_score[neighbor_index] then
          came_from[neighbor_index] = current
          g_score[neighbor_index] = tentative_g_score
          f_score[neighbor_index] = g_score[neighbor_index] + dist(neighbor, goal)
        end
      end
    end

  end
  return nil -- no valid path
end

local get_nodes = function(unit)
  local networks = unit.force.logistic_networks[unit.surface.name]
  if not networks then return end
  local nodes = {}
  for k, network in pairs (networks) do
    local cells = network.cells
    for k, cell in pairs (cells) do
      if not cell.mobile then
        table.insert(nodes, cell)
      end
    end
  end
  --game.print(serpent.block(nodes))
  return nodes
end

local get_drone_path = function(unit, logistic_network, target)
  if not (unit and unit.valid) then return end

  local origin_cell = logistic_network.find_cell_closest_to(unit.position)
  local destination_cell = logistic_network.find_cell_closest_to(target.position)
  if not destination_cell and origin_cell then return end

  local cells = logistic_network.cells
  if not origin_cell then return end

  return get_path(origin_cell, destination_cell, cells)

end

remote.add_interface("construction_drone",
{
  set_drone_command = function(unit, end_position)
    set_drone_command(unit, end_position)
  end
})

local get_point = function(items, networks)
  for k, network in pairs (networks) do
    local select = network.select_pickup_point
    for k, item in pairs(items) do
      point = select({name = item.name, position = position})
      if point then
        return point, item
      end
    end
  end
end

local validate = function(entities)
  for k, entity in pairs (entities) do
    if not entity.valid then
      entities[k] = nil
    end
  end
end

local get_idle_drones = function(surface, force)
  local drones = data.idle_drones[force.name]
  if drones then
    validate(drones)
    --print("Returning cached drone list: "..game.tick)
    return drones
  end

  local drones = {}
  print("making drone table again? "..game.tick)
  for k, entity in pairs (surface.find_entities_filtered{name = name, force = force}) do
    drones[entity.unit_number] = entity
  end

  data.idle_drones[force.name] = drones
  return drones
end


local drone_orders =
{
  pickup = 1,
  construct = 2
}


local check_ghost = function(entity)
  if not (entity and entity.valid) then return end
  local force = entity.force
  local surface = entity.surface
  local position = entity.position

  local networks = surface.find_logistic_networks_by_construction_area(position, force)
  local prototype = game.entity_prototypes[entity.ghost_name]
  local point, item = get_point(prototype.items_to_place_this, networks)

  if not point then
    print("no point with item?")
    return
  end

  local chest = point.owner
  local drones = get_idle_drones(surface, force)

  local drone = surface.get_closest(chest.position, drones)

  if not drone then
    print("No drones for pickup")
    return
  end

  local network = point.logistic_network

  local path = get_drone_path(drone, network, chest)

  local cell = path[1]
  if cell then
    table.remove(path, 1)
    drone.set_command({
      type = defines.command.go_to_location,
      destination_entity = cell.owner,
      radius = cell.construction_radius,
      pathfind_flags = drone_pathfind_flags
    })
  else
    path = nil
  end

  local drone_data =
  {
    path = path,
    entity = drone,
    order = drone_orders.pickup,
    pickup = {chest = chest, stack = item},
    network = network,
    target = entity
  }
  data.drone_commands[drone.unit_number] = drone_data
  data.idle_drones[force.name][drone.unit_number] = nil
  data.ghosts_to_be_checked[entity.unit_number] = nil
  data.ghosts_to_be_checked_again[entity.unit_number] = nil

end

local ghost_type = "entity-ghost"

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.type == ghost_type then
    data.ghosts_to_be_checked[entity.unit_number] = entity
    return
  end
  if entity.name == name then
    local force = entity.force.name
    data.idle_drones[force] = data.idle_drones[force] or {}
    data.idle_drones[entity.force.name][entity.unit_number] = entity
  end
end

local on_tick = function(event)
  local ghosts = data.ghosts_to_be_checked
  local ghosts_again = data.ghosts_to_be_checked_again
  local remaining_checks = max_checks_per_tick
  for k = 1, remaining_checks do
    local key, ghost = next(ghosts)
    if key then
      remaining_checks = remaining_checks - 1
      ghosts[key] = nil
      if ghost.valid then
        ghosts_again[key] = ghost
        check_ghost(ghost)
      end
    else
      break
    end
  end

  if remaining_checks == 0 then return end
  --print("Checking normal ghosts again")
  local index = data.ghost_check_index
  for k = 1, remaining_checks do
    local key, ghost = next(ghosts_again, index)
    index = key
    if key then
      remaining_checks = remaining_checks - 1
      if ghost.valid then
        check_ghost(ghost)
      else
        ghosts[key] = nil
      end
    else
      break
    end
  end
  data.ghost_check_index = index
end

local process_pickup_command = function(drone_data)
  print("Procesing pickup command")
  local drone = drone_data.entity
  if not (drone and drone.valid) then
    print("Drone not valid on pickup command process")
    return
  end
  local chest = drone_data.pickup.chest
  if not in_range(chest, drone) then
    drone.set_command({
      type = defines.command.go_to_location,
      destination_entity = chest,
      radius = chest.get_radius() + drone.get_radius() + 0.5,
      pathfind_flags = drone_pathfind_flags
    })
    return
  end
  print("Pickip chest in range, picking up item")
  local stack = drone_data.pickup.stack
  if not (chest and chest.valid) then
    print("Chest for pickup was not valid")
    return
  end
  chest.remove_item(stack)
  local network = drone_data.network
  local target = drone_data.target

  local path = get_drone_path(drone, network, target)


  local cell = path[1]
  if cell then
    table.remove(path, 1)
    drone.set_command({
      type = defines.command.go_to_location,
      destination_entity = cell.owner,
      radius = cell.construction_radius,
      pathfind_flags = drone_pathfind_flags
    })
  else
    path = nil
  end

  drone_data.path = path
  drone_data.pickup = nil
  drone_data.order = drone_orders.construct

end

local process_contruct_command = function(drone_data)
  local target = drone_data.target
  if not (target and target.valid) then
    print("Contruction target not valid... oh well")
    return
  end
  local drone = drone_data.entity
  if not (drone and drone.valid) then
    print("oh the entity isnt valiud, oh well")
    return
  end
  if not in_range(target, drone) then
    drone.set_command({
      type = defines.command.go_to_location,
      destination_entity = target,
      radius = target.get_radius() + drone.get_radius(),
      pathfind_flags = drone_pathfind_flags
    })
    return
  end
  target.revive()
  data.idle_drones[drone.force.name][drone.unit_number] = drone
end


local process_drone_command = function(drone_data, result)
  local drone = drone_data.entity
  print("Drone AI command complete, processing queue "..drone.unit_number.." - "..game.tick.." = "..tostring(result ~= defines.behavior_result.fail))

  if (result == defines.behavior_result.fail) then
    --Something is really fucky!
    local r = 3
    drone.set_command({
      type = defines.command.go_to_location,
      destination = {drone.position.x + (math.random(-r, r)), drone.position.y + (math.random(-r, r))},
      radius = drone.get_radius(),
      pathfind_flags = drone_pathfind_flags
    })
    return
  end

  if drone_data.path then
    local cell = drone_data.path[1]
    if cell then
      table.remove(drone_data.path, 1)
      drone.set_command({
        type = defines.command.go_to_location,
        destination_entity = cell.owner,
        radius = cell.construction_radius,
        pathfind_flags = drone_pathfind_flags
      })
      return
    else
      drone_data.path = nil
    end
  end


  if drone_data.order == drone_orders.pickup then
    process_pickup_command(drone_data)
    return
  end

  if drone_data.order == drone_orders.construct then
    process_contruct_command(drone_data)
    return
  end

end

local on_ai_command_completed = function(event)
  drone = data.drone_commands[event.unit_number]
  if drone then process_drone_command(drone, event.result) end
end

local lib = {}

local events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_ai_command_completed] = on_ai_command_completed
}

lib.on_event = handler(events)
lib.on_load = function()
  data = global.construction_drone or data
end

return lib
