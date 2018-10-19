local data = {}
local names = names.entities

local command_center_events =
{
  on_command_center_killed = script.generate_event_name()
}

local on_entity_died = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name == names.command_center then
    script.raise_event(command_center_events.on_command_center_killed, event)
  end
end

local on_command_center_killed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local related = data[entity.unit_number]
  if not related then return end
  for k, ent in pairs (related) do
    ent.destroy()
  end
end

local script_raised_built = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if not (entity.name == names.command_center) then return end
  local position = entity.position
  local surface = entity.surface
  local force = entity.force
  local components = {}
  local roboport = surface.create_entity{name = names.command_center.." Roboport", position = position, force = force}
  roboport.operable = false
  roboport.destructible = false
  --roboport.insert({name = names.command_center.." Robot", count = 50})
  roboport.insert({name = "construction-robot", count = 150})
  roboport.insert({name = "logistic-robot", count = 150})
  table.insert(components, roboport)
  local chest = surface.create_entity{name = names.command_center.." Chest", position = position, force = force}
  chest.destructible = false
  table.insert(components, chest)
  data[entity.unit_number] = components

end

local create = function(surface, position, force)
  local force = force or "player"
  local offsets = {
    {-12,-12},
    {-12, 12},
    {12, 12},
    {12, -12} 
  }
  local command_center = surface.create_entity{name = names.command_center, position = position, force = force}
  local components = {}
  local roboport = surface.create_entity{name = names.command_center.." Roboport", position = position, force = force}
  roboport.operable = false
  roboport.destructible = false
  roboport.insert({name = names.command_center.." Robot", count = 50})
  table.insert(components, roboport)
  local chest = surface.create_entity{name = names.command_center.." Chest", position = position, force = force}
  chest.destructible = false
  table.insert(components, chest)
  data[command_center.unit_number] = components

end

remote.add_interface("command_center",
{
  create = function(surface, position, force) create(surface, position, force) end,
  get_events = function() return util.copy(command_center_events) end
})

local events =
{
  [defines.events.script_raised_built] = script_raised_built,
  [defines.events.on_entity_died] = on_entity_died
}

local register_command_center_events = function()
  if not remote.interfaces["command_center"] then return end
  local remote_events = remote.call("command_center", "get_events")
  events[remote_events.on_command_center_killed] = on_command_center_killed
end


local command_center = {}

command_center.on_init = function()
  global.command_center = data
  register_command_center_events()
  command_center.on_event = handler(events)
end

command_center.on_load = function()
  data = global.command_center or data
  register_command_center_events()
  command_center.on_event = handler(events)
end

return command_center