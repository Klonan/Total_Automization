local names = require("shared").entities
local setupable =
{
  [names.gun_turret] = SU(15 * 60)
}

local data =
{
  entities = {},
  map = {}
}

local on_tick = function(event)
  local tick = event.tick
  local entities = data.entities[tick]
  if not entities then return end
  for k, param in pairs (entities) do
    local entity = param.entity
    if entity and entity.valid then
      entity.active = true
    end
    local animation = param.animation
    if animation and animation.valid then
      animation.destroy()
    end
  end
  data.entities[tick] = nil
end

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  local setup_time = setupable[entity.name]
  if not setup_time then return end
  entity.active = false
  local setup_tick = event.tick + setup_time
  local entities = data.entities
  entities[setup_tick] = entities[setup_tick] or {}
  local animation = entity.surface.create_entity{name = names.setup_time_animation, position = entity.position, force = entity.force}
  animation.destructible = false
  local param = {entity = entity, animation = animation}
  data.map[entity.unit_number] = param
  table.insert(entities[setup_tick], param)
end

local events =
{
  [defines.events.on_tick] = on_tick,
  [defines.events.on_built_entity] = on_built_entity
}

local on_event = handler(events)

local setup_time = {}

setup_time.on_event = on_event

setup_time.on_load = function()
  data = global.setup_time
end

setup_time.on_init = function()
  global.setup_time = data
end

return setup_time



