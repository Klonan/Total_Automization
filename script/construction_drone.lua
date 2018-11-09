local max = math.huge

local name = names.entities.construction_drone

local max_checks_per_tick = 6

local debug = true
local print = function(string)
  if not debug then return end
  game.print(string)
end

local data =
{
  ghosts_to_be_checked = {},
  ghosts_to_be_checked_again = {},
  idle_drones = {},
  active_drones = {},
  cells = {}
}

local dist = function(cell_a, cell_b)
  local position1 = cell_a.owner.position
  local position2 = cell_b.owner.position
  return ((position2.x - position1.x) * (position2.x - position1.x)) + ((position2.y - position1.y) * (position2.y - position1.y))
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

local get_drone_command = function(unit, destination_entity, origin_position, destination_cell)
  if not (unit and unit.valid) then return end
  local position = origin_position or unit.position
  if not destination_cell then return end
  local destination_network = destination_cell.logistic_network
  local cells = destination_network.cells
  local starting_cell = destination_network.find_cell_closest_to(position)
  if not starting_cell then return end

  local path = get_path(starting_cell, destination_cell, cells)

  if not path then print("No path for drone command") end

  --local biter = unit.surface.create_entity{name = names, force = unit.force, position = {unit.position.x + 3, unit.position.y}}
  local commands = {}
  local command_type = defines.command.go_to_location
  local radius = unit.get_radius()
  for k, cell in pairs (path) do
    local command =
    {
      type = command_type,
      destination_entity = cell.owner,
      radius = math.max(cell.construction_radius, cell.logistic_radius)+ radius
    }
    table.insert(commands, command)
  end
  table.insert(commands,
  {
    type = command_type,
    destination_entity = destination_entity,
    radius = destination_entity.get_radius() + radius
  })

  return commands

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
        return point
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
  data.active_drones[force.name] = {}
  return drones
end

local check_ghost = function(entity)
  if not (entity and entity.valid) then return end
  local force = entity.force
  local surface = entity.surface
  local position = entity.position

  local networks = surface.find_logistic_networks_by_construction_area(position, force)
  local prototype = game.entity_prototypes[entity.ghost_name]
  local point = get_point(prototype.items_to_place_this, networks)
    
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

  local origin_cell = point.logistic_network.find_cell_closest_to(point.owner.position)
  local destination_cell = point.logistic_network.find_cell_closest_to(entity.position)

  local commands_1 = get_drone_command(drone, chest, drone.position, origin_cell)
  local commands_2 = get_drone_command(drone, entity, chest.position, destination_cell)
  local commands = {}
  for k, command in pairs (commands_1) do
    table.insert(commands, command)
  end
  for k, command in pairs (commands_2) do
    table.insert(commands, command)
  end
  drone.set_command{
    type = defines.command.compound,
    commands = commands,
    structure_type = defines.compound_command.return_last
  }
  data.idle_drones[force.name][drone.unit_number] = nil
  data.active_drones[force.name][drone.unit_number] = drone
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
    data.drones[entity.force.name][entity.unit_number] = entity
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
  for k = 1, remaining_checks do
    local key, ghost = next(ghosts_again)
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

end

local lib = {}

local events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick
}

lib.on_event = handler(events)
lib.on_load = function()
  data = global.construction_drone or data
end

return lib
