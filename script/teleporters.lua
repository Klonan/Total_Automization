-- TODO 
-- In teleporters and out teleporters
-- hash map of positions
-- check in and out
-- landmine event
-- sends all nearby players
-- trigger effect could spawn next teleporter with a timeout
-- maybe the mine just doesnt die
-- check the event entity on a hash map for partners

local teleporters = {}

on_trigger_created_entity = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  game.print(entity.name)
  if entity.name == "entry" then
    for k, p in pairs (entity.surface.find_entities_filtered{type = "player", area = {{entity.position.x - 1, entity.position.y - 1},{entity.position.x + 1, entity.position.y + 1}}}) do
      p.teleport({entity.position.x, entity.position.y - 10})
    end
  end
end

local events = {
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity
}

teleporters.on_event = function(event)
  if not (event and event.name) then return end
  local action = events[event.name] or function() return end
  return action(event)
end

return teleporters