local max = math.huge
local insert = table.insert
local name = names.entities.construction_drone

local max_checks_per_tick = 6

local drone_pathfind_flags =
{
  allow_destroy_friendly_entities = false,
  cache = true,
  low_priority = false
}

local drone_orders =
{
  construct = 1,
  deconstruct = 2,
  repair = 3,
  upgrade = 4,
  request_proxy = 5
}


local data =
{
  ghosts_to_be_checked = {},
  ghosts_to_be_checked_again = {},
  deconstructs_to_be_checked = {},
  deconstructs_to_be_checked_again = {},
  repair_to_be_checked = {},
  repair_to_be_checked_again = {},
  upgrade_to_be_checked = {},
  upgrade_to_be_checked_again = {},
  idle_drones = {},
  drone_commands = {},
  targets = {},
  debug = false
}

local get_drone_radius = function()
  return 1
end

local print = function(string)
  if not data.debug then return end
  log(string)
  game.print(string)
end

local dist = function(cell_a, cell_b)
  local position1 = cell_a.owner.position
  local position2 = cell_b.owner.position
  return ((position2.x - position1.x) * (position2.x - position1.x)) + ((position2.y - position1.y) * (position2.y - position1.y))
end

local get_radius = function(entity)
  if entity.type == "entity-ghost" then
    return game.entity_prototypes[entity.ghost_name].radius
  else
    return entity.get_radius()
  end
end

local in_range = function(entity_1, entity_2, extra)

  local position1 = entity_1.position
  local position2 = entity_2.position
  local distance =  (((position2.x - position1.x) * (position2.x - position1.x)) + ((position2.y - position1.y) * (position2.y - position1.y))) ^ 0.5
  return distance <= (get_radius(entity_1) + (get_radius(entity_2))) + (extra or 2)

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
  set_debug = function(bool)
    data.debug = bool
  end
})

local get_drone_capacity = function(force)
  return 4
end

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
  --TODO, make this support multiple surfaces properly...
  data.idle_drones[force.name] = drones
  return drones
end

local remove_drone_sticker

local get_or_find_network = function(drone_data)
  local network = drone_data.network
  if network and network.valid then return network end

  local drone = drone_data.entity
  local surface = drone.surface
  local force = drone.force
  local position = drone.position
  local networks = force.logistic_networks[surface.name]
  local owners = {}
  for k, network in pairs (networks) do
    local cell = network.find_cell_closest_to(position)
    if cell then table.insert(owners, cell.owner) end
  end
  local closest = surface.get_closest(position, owners)
  if closest then
    network = closest.logistic_cell.logistic_network
  end
  drone_data.network = network
  return network
end

local normalise = function(vector)
  local x = vector.x
  local y = vector.y
  local v = (((x * x) + (y * y)) ^ 0.5)
  --error(serpent.block{x, y, v})
  return {x = x/v, y = y/v}
end

local get_target_position = function(unit, target)
  local radius = get_radius(target)
  --radius = math.max(radius, 1)
  --radius = radius + unit.get_radius()

  local origin = unit.position
  local position = target.position
  local direction =
  {
    x = origin.x - position.x,
    y = origin.y - position.y
  }
  local offset = normalise(direction)
  local target_position = {position.x + (radius * offset.x), position.y + (radius * offset.y)}
  --error(serpent.block{unit = origin, target = position, offset = offset, radius = radius, final_position = target_position})
  target_position = unit.surface.find_non_colliding_position(unit.name, target_position, 0, 0.1) or target_position
  return target_position

end

local set_drone_idle = function(drone)
  if not (drone and drone.valid) then return end
  print("Setting drone idle")
  local drone_data = data.drone_commands[drone.unit_number]
  data.drone_commands[drone.unit_number] = nil
  data.idle_drones[drone.force.name][drone.unit_number] = drone

  drone.speed = math.random() * drone.speed

  if not drone_data then return end

  remove_drone_sticker(drone_data)
  local network = get_or_find_network(drone_data)
  if network then
    local destination_cell = network.find_cell_closest_to(drone.position)
    drone.set_command{
      type = defines.command.go_to_location,
      destination = get_target_position(drone, destination_cell.owner),
      radius = math.max(destination_cell.logistic_radius, get_drone_radius() + destination_cell.owner.get_radius())
    }
  end

end

local process_drone_command

local check_ghost = function(entity)
  if not (entity and entity.valid) then return true end
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

  local drone_data =
  {
    entity = drone,
    order = drone_orders.construct,
    pickup = {chest = chest, stack = item},
    network = network,
    target = entity
  }

  data.drone_commands[drone.unit_number] = drone_data
  data.idle_drones[force.name][drone.unit_number] = nil
  data.targets[entity.unit_number] = drone_data
  process_drone_command(drone_data)
  return true
end

local ghost_type = "entity-ghost"

local on_built_entity = function(event)
  local entity = event.created_entity or event.ghost
  if not (entity and entity.valid) then return end
  if entity.type == ghost_type then
    data.ghosts_to_be_checked[entity.unit_number] = entity
    return
  end
  if entity.name == name then
    local force = entity.force.name
    print("Adding idle drone")
    data.idle_drones[force] = data.idle_drones[force] or {}
    data.idle_drones[force][entity.unit_number] = entity
  end
end

local check_ghost_lists = function()
  local ghosts = data.ghosts_to_be_checked
  local ghosts_again = data.ghosts_to_be_checked_again
  local remaining_checks = max_checks_per_tick
  for k = 1, remaining_checks do
    local key, ghost = next(ghosts)
    if key then
      remaining_checks = remaining_checks - 1
      ghosts[key] = nil
      if not check_ghost(ghost) then
        ghosts_again[key] = ghost
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
      if check_ghost(ghost) then
        ghosts_again[key] = nil
      end
    else
      break
    end
  end
  data.ghost_check_index = index

end

local check_upgrade = function(upgrade_data)
  local entity = upgrade_data.entity
  if not (entity and entity.valid) then return true end
  if not entity.to_be_upgraded() then return true end

  local target_prototype = upgrade_data.target
  if not target_prototype then
    print("Maybe some migration?")
    return true
  end

  local surface = entity.surface
  local force = entity.force

  local networks = surface.find_logistic_networks_by_construction_area(entity.position, force)
  local point, item = get_point(target_prototype.items_to_place_this, networks)
  if not point then return end

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

  local drone_data =
  {
    entity = drone,
    order = drone_orders.upgrade,
    pickup = {chest = chest, stack = item},
    network = network,
    target = entity,
    target_prototype = target_prototype
  }

  data.drone_commands[drone.unit_number] = drone_data
  data.idle_drones[force.name][drone.unit_number] = nil
  data.targets[entity.unit_number] = drone_data
  process_drone_command(drone_data)
  return true
end

local check_upgrade_lists = function()
  local upgrade = data.upgrade_to_be_checked
  local upgrade_again = data.upgrade_to_be_checked_again
  local remaining_checks = max_checks_per_tick
  for k = 1, remaining_checks do
    local key, upgrade_data = next(upgrade)
    if key then
      remaining_checks = remaining_checks - 1
      upgrade[key] = nil
      if not check_upgrade(upgrade_data) then
        upgrade_again[key] = upgrade_data
      end
    else
      break
    end
  end

  if remaining_checks == 0 then return end
  --print("Checking normal ghosts again")
  local index = data.upgrade_check_index
  for k = 1, remaining_checks do
    local key, upgrade_data = next(upgrade_again, index)
    index = key
    if key then
      remaining_checks = remaining_checks - 1
      if check_upgrade(upgrade_data) then
        upgrade_again[key] = nil
      end
    else
      break
    end
  end
  data.upgrade_check_index = index

end

local rip_inventory = function(inventory, list)
  if inventory.is_empty() then return end
  for name, count in pairs (inventory.get_contents()) do
    list[name] = (list[name] or 0) + count
  end
end

local contents = function(entity)
  local contents = {}
  for k = 1, 10 do
    local inventory = entity.get_inventory(k)
    if inventory then
      rip_inventory(inventory, contents)
    end
  end
  print("Contents are safe!")
  return contents
end

local check_deconstruction = function(deconstruct)
  local entity = deconstruct.entity
  local force = deconstruct.force

  if not (entity and entity.valid) then return true end
  --entity.surface.create_entity{name = "flying-text", position = entity.position, text = "!"}
  if not (force and force.valid) then return true end

  if not entity.to_be_deconstructed(force) then return true end

  local surface = entity.surface

  local mineable_properties = entity.prototype.mineable_properties
  if not mineable_properties.minable then
    print("Why are you marked for deconstruction if I cant mine you?")
    return
  end
  local product = mineable_properties.products[1] --Ehhhhh, well... fuck it...

  local key, network = next(surface.find_logistic_networks_by_construction_area(entity.position, force))
  if not key then
    print("He is outside of any of our construction areas...")
    return
  end

  --local drop_point = network.select_drop_point({product})
  --if not drop_point then
  --  print("No where to drop what we would deconstruct, so don't deconstruct him yet... figure it out later")
  --end

  local capacity = get_drone_capacity(force)
  local total_contents = contents(entity)
  local sum = 0
  for name, count in pairs (total_contents) do
    sum = sum + count
  end
  sum = math.ceil(sum / capacity)
  local send = math.min(sum, 10)
  send = math.max(send, 1)

  for k = 1, send do
    local drone = surface.get_closest(entity.position, get_idle_drones(surface, force))
    if not drone then
      return
    end

    local drone_data =
    {
      order = drone_orders.deconstruct,
      network = network,
      entity = drone,
      target = entity
    }

    data.drone_commands[drone.unit_number] = drone_data
    data.idle_drones[drone.force.name][drone.unit_number] = nil
    process_drone_command(drone_data)
  end
  if send >= sum then
    return true --If we send a drone, return true
  end
end

local check_deconstruction_lists = function()

  local decs = data.deconstructs_to_be_checked
  local decs_again = data.deconstructs_to_be_checked_again
  local remaining_checks = max_checks_per_tick
  for k = 1, remaining_checks do
    local key, deconstruct = next(decs)
    if key then
      remaining_checks = remaining_checks - 1
      decs[key] = nil
      if deconstruct.entity.valid then
        if not check_deconstruction(deconstruct) then
          insert(data.deconstructs_to_be_checked_again, deconstruct)
        end
      end
    else
      break
    end
  end

  if remaining_checks == 0 then return end
  --print("checking things to deconstruct")
  local index = data.deconstruction_check_index
  for k = 1, remaining_checks do
    local key, deconstruct = next(decs_again, index)
    index = key
    if key then
      remaining_checks = remaining_checks - 1
      if deconstruct.entity.valid then
        if check_deconstruction(deconstruct) then
          decs_again[key] = nil
        end
      else
        decs_again[key] = nil
      end
    else
      break
    end
  end
  data.deconstruction_check_index = index

end

local check_repair = function(entity)
  if not (entity and entity.valid) then return true end
  print("Checking repair of an entity: "..entity.name)
  local health = entity.get_health_ratio()
  if not (health and health < 1) then return true end
  local surface = entity.surface
  local force = entity.force
  local networks = surface.find_logistic_networks_by_construction_area(entity.position, force)
  local repair_items = {}
  local repair_item
  for name, item in pairs (game.item_prototypes) do
    if item.type == "repair-tool" then
      repair_items[name] = item
    end
  end
  local pickup_target
  for k, network in pairs (networks) do
    for name, item in pairs (repair_items) do
      if network.get_item_count(name) > 0 then
        pickup_target = network.select_pickup_point({name = name})
        if pickup_target then
          repair_item = item
          break
        end
      end
    end
    if pickup_target then break end
  end
  if not pickup_target then
    print("No pickup target for any repair pack.")
    return
  end

  local chest = pickup_target.owner
  local drones = get_idle_drones(surface, force)
  print(serpent.line(drones))
  local drone = surface.get_closest(chest.position, drones)

  if not drone then
    print("No drone for repair.")
    return
  end

  data.idle_drones[drone.force.name][drone.unit_number] = nil


  local drone_data =
  {
    order = drone_orders.repair,
    pickup = {chest = chest, stack = {name = repair_item.name, count = 1}},
    network = pickup_target.logistic_network,
    target = entity,
    entity = drone
  }
  data.drone_commands[drone.unit_number] = drone_data

  process_drone_command(drone_data)
  return true
end

local check_repair_lists = function()

  local repair = data.repair_to_be_checked
  local repair_again = data.repair_to_be_checked_again
  local remaining_checks = max_checks_per_tick
  for k = 1, remaining_checks do
    local key, entity = next(repair)
    if key then
      remaining_checks = remaining_checks - 1
      repair[key] = nil
      if not check_repair(entity) then
        insert(repair_again, entity)
      end
    else
      break
    end
  end

  if remaining_checks == 0 then return end
  --print("checking things to deconstruct")
  local index = data.repair_check_index
  for k = 1, remaining_checks do
    local key, entity = next(repair_again, index)
    index = key
    if key then
      remaining_checks = remaining_checks - 1
      if check_repair(entity) then
        repair_again[key] = nil
      end
    else
      break
    end
  end
  data.repair_check_index = index

end

local on_tick = function(event)
  check_ghost_lists()
  check_deconstruction_lists()
  check_repair_lists()
  check_upgrade_lists()
end

local cancel_drone_order = function(drone_data, on_removed)
  local drone = drone_data.entity
  if not (drone and drone.valid) then return end
  local unit_number = drone.unit_number

  print("Drone command cancelled "..unit_number.." - "..game.tick)

  local target = drone_data.target
  if target and target.valid then
    if target.unit_number then
      data.targets[target.unit_number] = nil
    end
    if target.type == "entity-ghost" then
      data.ghosts_to_be_checked_again[target.unit_number] = target
    end
    if drone_data.order == drone_orders.repair then
      insert(data.repair_to_be_checked_again, target)
    end
  end

  local stack = drone_data.held_stack
  if stack then
    drone_data.dropoff = {stack = stack}
    return process_drone_command(drone_data)
  end

  data.drone_commands[unit_number] = nil

  if not on_removed then
    set_drone_idle(drone)
  end

end

local stack_from_product = function(product)
  return
  {
    name = product.name,
    count = product.amount or (math.random() * (product.amount_max - product.amount_min) + product.amount_min)
  }
end

local move_to_logistic_target = function(drone_data, target)
  local network = get_or_find_network(drone_data)
  if not network then return end
  local cell = target.logistic_cell or network.find_cell_closest_to(target.position)
  local drone = drone_data.entity
  if cell.is_in_construction_range(drone.position) then
    drone.set_command({
      type = defines.command.go_to_location,
      destination = get_target_position(drone, target),
      radius = get_drone_radius() * 2,
      pathfind_flags = drone_pathfind_flags
    })
    return
  end

  drone_data.path = get_drone_path(drone, network, target)
  return process_drone_command(drone_data)
end

remove_drone_sticker = function(drone_data)
  local sticker = drone_data.sticker
  if sticker and sticker.valid then
    sticker.destroy()
  end
end

local add_drone_sticker = function(drone_data, item_name)
  remove_drone_sticker(drone_data)
  local sticker_name = item_name.." Drone Sticker"
  if not game.entity_prototypes[sticker_name] then
    print("No sticker with name sticker_name")
    return
  end
  local drone = drone_data.entity

  drone_data.sticker = drone.surface.create_entity
  {
    name = sticker_name,
    position = drone.position,
    target = drone,
    force = drone.force
  }

end

local process_pickup_command = function(drone_data)
  print("Procesing pickup command")

  local chest = drone_data.pickup.chest
  if not (chest and chest.valid) then
    print("Chest for pickup was not valid")
    cancel_drone_order(drone_data)
    return
  end

  if not in_range(chest, drone_data.entity, 3) then
    print("Not in range: "..drone_data.entity.unit_number.." - "..game.tick)
    return move_to_logistic_target(drone_data, chest)
  end

  print("Pickup chest in range, picking up item")
  local stack = drone_data.pickup.stack
  local inventory
  local type = chest.type

  --Hmm, I think in the future, things like furnace and stuff for deconstructing etc.
  if type == "logistic-container" or type == "container" then
    inventory = chest.get_inventory(defines.inventory.chest)
  elseif type == "roboport" then
    inventory = chest.get_inventory(defines.inventory.robot_repair)
  end

  local chest_stack = inventory.find_item_stack(stack.name)
  if not chest_stack then
    print("The chest didn't have the item we want... jog on...")
    drone_data.pickup.chest = nil
    return process_drone_command(drone_data)
  end
  local new_stack =
  {
    name = stack.name,
    count = stack.count,
    durability = chest_stack.durability
  }
  chest.remove_item(stack)
  drone_data.held_stack = new_stack

  add_drone_sticker(drone_data, new_stack.name)

  drone_data.pickup = nil

  return process_drone_command(drone_data)
end

local process_dropoff_command = function(drone_data)
  print("Procesing dropoff command")

  local drone = drone_data.entity

  local chest = drone_data.dropoff.chest

  if not (chest and chest.valid) then
    local network = get_or_find_network(drone_data)
    if not network then return end
    local point = network.select_drop_point{stack = drone_data.dropoff.stack}
    if not point then
      print("really is nowhere to put it... so just sit and wait...")
      drone.set_command{
        type = defines.command.stop,
        ticks_to_wait = math.random(600, 1200)
      }
      return
    end
    chest = point.owner
    drone_data.dropoff.chest = chest
  end

  if not in_range(drone, chest) then
    return move_to_logistic_target(drone_data, chest)
  end

  print("Dropoff chest in range, picking up item")
  local stack = drone_data.dropoff.stack
  if not stack then
    print("We didn't have a stack anyway, why are we dropping it off??")
    return
  end
  local count = stack.count
  stack.count = stack.count - chest.insert(stack)
  if stack.count > 0 then
    drone_data.dropoff.chest = nil
    return process_drone_command(drone_data)
  end
  if drone_data.extra_inventory then
    local key, product = next(drone_data.extra_inventory)
    if not key then drone_data.extra_inventory = nil end
    if product then
      local stack = stack_from_product(product)
      drone_data.held_stack = stack
      drone_data.dropoff = {stack = stack}
      add_drone_sticker(drone_data, stack.name)
      return process_drone_command(drone_data)
    end
  end

  set_drone_idle(drone)
end

local unit_move_away = function(unit, target, multiplier)
  local multiplier = multiplier or 1
  local radius = get_radius(target)
  local r = (radius + unit.get_radius()) * (1 + (math.random() * 4))
  r = r * multiplier
  local position = {}
  if unit.position.x > target.position.x then
    position.x = unit.position.x + r
  else
    position.x = unit.position.x - r
  end
  if unit.position.y > target.position.y then
    position.y = unit.position.y + r
  else
    position.y = unit.position.y - r
  end
  unit.set_command
  {
    type = defines.command.go_to_location,
    destination = position,
    radius = 1
  }
  unit.speed = unit.prototype.speed
end

local process_contruct_command = function(drone_data)
  print("Processing construct command")
  local target = drone_data.target
  if not (target and target.valid) then
    cancel_drone_order(drone_data)
    return
  end
  local drone = drone_data.entity
  if not (drone and drone.valid) then
    print("oh the entity isnt valid, oh well")
    return
  end
  if not in_range(target, drone) then
    return move_to_logistic_target(drone_data, target)
  end

  if not target.revive() then
    unit_move_away(drone, target)
    print("Some idiot might be in the way too ("..drone.unit_number.." - "..game.tick..")")
      local radius = get_radius(target) * 2
      local area = {{target.position.x - radius, target.position.y - radius},{target.position.x + radius, target.position.y + radius}}
      for k, unit in pairs (target.surface.find_entities_filtered{type = "unit", area = area}) do

        print("Telling idiot to MOVE IT ("..drone.unit_number.." - "..game.tick..")")
        unit_move_away(unit, target)
      end
    return
  end

  set_drone_idle(drone)
end

local drone_follow_path = function(drone_data)
  print("I am following path")
  local path = drone_data.path
  local drone = drone_data.entity
  local current_cell = path[1]
  if current_cell and current_cell.valid then
    if current_cell.is_in_construction_range(drone.position) then
      table.remove(path, 1)
    else
      drone.set_command({
        type = defines.command.go_to_location,
        destination_entity = current_cell.owner,
        radius = math.max(current_cell.construction_radius, current_cell.logistic_radius),
        pathfind_flags = drone_pathfind_flags
      })
      return
    end
  end
  local next_cell = path[1]
  if next_cell and next_cell.valid then
    local last = path[2]
    local current = current_cell.owner.position
    local origin = drone.position
    local next = next_cell.owner.position
    local dx = current.x - origin.x
    local dy = current.y - origin.y
    local r = math.max(current_cell.construction_radius, current_cell.logistic_radius) / 2
    if dx < -r then dx = -r end
    if dx > r then dx = r end
    if dy < -r then dy = -r end
    if dy > r then dy = r end
    local new_position = drone.surface.find_non_colliding_position(drone.name, {x = next.x - dx, y = next.y - dy}, 0, 2)
    drone.set_command({
      type = defines.command.go_to_location,
      destination = new_position,
      radius = last and r or math.max(current_cell.construction_radius, current_cell.logistic_radius),
      pathfind_flags = drone_pathfind_flags
    })
    return
  end
  drone_data.path = nil
  return process_drone_command(drone_data)
end

local random = math.random
local randish = function(value, variance)
  return value + ((random() - 0.5) * variance * 2)
end

local process_failed_command = function(drone_data)
    local drone = drone_data.entity
    if not drone and drone.valid then return end
    --Something is really fucky!
    if game.tick % 137 == 0 then
      local position = drone.surface.find_non_colliding_position(drone.name, {randish(drone.position.x, 0.5), randish(drone.position.y, 0.5)} , 0, 1)
      drone.teleport(position)
      drone.surface.create_entity{name = "flying-text", position = drone.position, text = "Oof"}
    end

    --[[local r = 3
    drone.set_command({
      type = defines.command.go_to_location,
      destination = {randish(drone.position.x, r), randish(drone.position.y, r)},
      radius = get_drone_radius(),
      pathfind_flags = drone_pathfind_flags
    })
    return]]
end

local process_deconstruct_command = function(drone_data)
  print("Processing deconstruct command")
  local target = drone_data.target
  if not (target and target.valid) then
    cancel_drone_order(drone_data)
    return
  end

  local drone = drone_data.entity

  if not in_range(drone, target) then
    return move_to_logistic_target(drone_data, target)
  end

  local remaining_contents = contents(target)
  local stack
  local name, count = next(remaining_contents)
  if name then
    print("Target has contents, lets just pick up them for now")
    count = math.min(count, get_drone_capacity(drone.force))
    stack = {name = name, count = count}
    target.remove_item(stack)
  else
    print("Target says he has no contents")
    local products = target.prototype.mineable_properties.products
    local product = products[1]
    stack = stack_from_product(product)
    target.destroy()
    drone_data.order = nil
    table.remove(products, 1)
    if next(products) then
      drone_data.extra_inventory = products
    end
  end

  drone_data.dropoff =
  {
    stack = stack
  }
  drone_data.held_stack = stack

  add_drone_sticker(drone_data, stack.name)
  return process_drone_command(drone_data)
end

local process_repair_command = function(drone_data)
  print("Processing repair command")
  local target = drone_data.target
  if not (target and target.valid) then
    cancel_drone_order(drone_data)
    return
  end

  if target.get_health_ratio() == 1 then
    print("Target is fine... give up on healing him")
    drone_data.target = nil
    if drone_data.held_stack then
      drone_data.dropoff = {stack = drone_data.held_stack}
      return process_drone_command(drone_data)
    end
    return cancel_drone_order(drone_data)
  end

  local drone = drone_data.entity

  if not in_range(drone, target) then
    return move_to_logistic_target(drone_data, target)
  end

  local stack = drone_data.held_stack
  if stack.durability <= 0 then
    error("NO, CHECK DURABILITY WHEN YOU DRAIN IT LAZY BOI")
  end

  local health = target.health
  local repair_speed = game.item_prototypes[stack.name].speed
  if not repair_speed then
    print("WTF, maybe some migration?")
    drone_data.dropoff = {stack = stack}
    return process_drone_command(drone_data)
  end

  target.health = target.health + repair_speed
  stack.durability = stack.durability - repair_speed
  if stack.durability <= 0 then
    print("Stack expired, going to pikcup a new one")
    stack.durability = nil
    drone_data.pickup = {stack = stack}
    drone_data.held_stack = nil
    remove_drone_sticker(drone_data)
    return process_drone_command(drone_data)
  end

  if target.get_health_ratio() == 1 then
    print("Job done, matey is all repaired")
    drone_data.dropoff = {stack = stack}
    drone_data.target = nil
    return process_drone_command(drone_data)
  end

  --oof, this might be a bit heavy... maybe we can do is every n ticks? maybe later...
  drone.set_command{
    type = defines.command.stop,
    ticks_to_wait = 1,
    distraction = defines.distraction.by_damage
  }

end

local process_upgrade_command = function(drone_data)
  print("Processing upgrade command")

  local target = drone_data.target
  if not (target and target.valid and target.to_be_upgraded()) then
    cancel_drone_order(drone_data)
    return
  end

  local drone = drone_data.entity

  if not in_range(target, drone) then
    return move_to_logistic_target(drone_data, target)
  end

  local surface = drone.surface
  local prototype = drone_data.target_prototype
  local original_name = target.name
  local upgraded = surface.create_entity
  {
    name = prototype.name,
    position = target.position,
    direction = target.direction,
    fast_replace = true,
    force = target.force,
    spill = false
  }
  if not upgraded then error("Shouldn't happen, upgrade failed when creating entity... let me know!") return end
  local products = game.entity_prototypes[original_name].mineable_properties.products
  local product = products[1]
  if product then
    local stack = stack_from_product(product)
    drone_data.held_stack = stack
    drone_data.dropoff = {stack = stack}
    drone_data.order = nil
    add_drone_sticker(drone_data, stack.name)
    return process_drone_command(drone_data)
  end
end


process_drone_command = function(drone_data, result)
  local drone = drone_data.entity
  drone.speed = (((math.random() / 10) - 0.1) + 1) * drone.prototype.speed
  print("Drone AI command complete, processing queue "..drone.unit_number.." - "..game.tick.." = "..tostring(result ~= defines.behavior_result.fail))

  if not (drone and drone.valid) then
    error("Drone entity not valid when processing its own command!")
  end

  local print = function(string)
    print(string.. "("..drone.unit_number.." - "..game.tick..")")
  end

  if (result == defines.behavior_result.fail) then
    print("Fail")
    process_failed_command(drone_data)
  end

  if drone_data.path then
    print("Path")
    drone_follow_path(drone_data)
    return
  end

  if drone_data.pickup then
    print("Pickup")
    process_pickup_command(drone_data)
    return
  end

  if drone_data.dropoff then
    print("Dropoff")
    process_dropoff_command(drone_data)
    return
  end

  if drone_data.order == drone_orders.construct then
    print("Construct")
    process_contruct_command(drone_data)
    return
  end

  if drone_data.order == drone_orders.deconstruct then
    print("Deconstruct")
    process_deconstruct_command(drone_data)
    return
  end

  if drone_data.order == drone_orders.repair then
    print("Repair")
    process_repair_command(drone_data)
    return
  end

  if drone_data.order == drone_orders.upgrade then
    print("Upgrade")
    process_upgrade_command(drone_data)
    return
  end

  print("Nothin")
  set_drone_idle(drone)
end

local on_ai_command_completed = function(event)
  drone_data = data.drone_commands[event.unit_number]
  if drone_data then process_drone_command(drone_data, event.result) end
end

local on_entity_removed = function(event)
  local entity = event.entity or event.ghost
  print("On removed event fired: "..entity.name.." - "..game.tick)
  if not (entity and entity.valid) then return end
  local unit_number = entity.unit_number
  if not unit_number then return end

  if entity.name == name then
    data.idle_drones[entity.force.name][unit_number] = nil
    local drone_data = data.drone_commands[unit_number]
    if drone_data then
      cancel_drone_order(drone_data, true)
    end
    return
  end

  if entity.name == "entity-ghost" then
    data.ghosts_to_be_checked_again[unit_number] = nil
    data.ghosts_to_be_checked[unit_number] = nil
    local drone_data = data.targets[unit_number]
    data.targets[unit_number] = nil
    if drone_data then
      cancel_drone_order(drone_data)
    end
    return
  end

end
local on_marked_for_deconstruction = function(event)
  local force = event.force or game.players[event.player_index].force
  if not force then return end
  insert(data.deconstructs_to_be_checked, {entity = event.entity, force = force})
end

local on_entity_damaged = function(event)
  local entity = event.entity
  insert(data.repair_to_be_checked, entity)
end

local shoo = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local radius = 16
  local target = player.selected or player.character
  local position = target and target.position or player.position
  local area = {{position.x - radius, position.y - radius},{position.x + radius, position.y + radius}}
  for k, unit in pairs(player.surface.find_entities_filtered{area = area, name = name, force = player.force}) do
    unit_move_away(unit, target, 4)
  end
  player.surface.play_sound{path = "shoo", position = player.position}
end

local on_marked_for_upgrade = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local upgrade_data = {entity = entity, target = event.target}
  data.upgrade_to_be_checked[entity.unit_number] = upgrade_data
end

local lib = {}

local events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_ai_command_completed] = on_ai_command_completed,
  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_marked_for_deconstruction] = on_marked_for_deconstruction,
  [defines.events.on_pre_ghost_deconstructed] = on_entity_removed,
  [defines.events.on_post_entity_died] = on_built_entity,
  [defines.events.on_entity_damaged] = on_entity_damaged,
  [defines.events.on_marked_for_upgrade] = on_marked_for_upgrade,
  [names.hotkeys.shoo]  = shoo
}

lib.on_event = handler(events)
lib.on_load = function()
  data = global.construction_drone or data
  global.construction_drone = data
end

lib.on_init = function()
  global.construction_drone = global.construction_drone or data
  data.ghosts_to_be_checked_again = {}
  for k, surface in pairs (game.surfaces) do
    for k, ghost in pairs (surface.find_entities_filtered{type = "entity-ghost"}) do
      insert(data.ghosts_to_be_checked_again, ghost)
    end
  end
end

return lib
