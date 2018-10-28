local name = names.entities.logistic_beacon

local beacon_built = function(entity)
  game.print("helo")
end

local on_built = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.name == name then
    beacon_built(entity)
  end
end

local events =
{
  [defines.events.on_built_entity] = on_built
}

local lib = {}

lib.on_event = handler(events)

return lib
