-- sigh... another mini mod to waste my time on
local get_burners = function()
  if burners then return burners end
  --deliberately not local
  burners = {}
  for name, entity in pairs (game.entity_prototypes) do
    if entity.burner_prototype then
      burners[name] = true
    end
  end
  return burners
end

local is_burner = function(name)
  return get_burners()[name]
end

on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if is_burner(entity.name) then
    return entity.surface.create_entity
    {
      name = "item-request-proxy",
      position = entity.position,
      force = entity.force,
      target = entity,
      modules = {coal = 5}
    }
  end

  if entity.type == "entity-ghost" then
    if is_burner(entity.ghost_name) then
      entity.item_requests = {coal = 5}
      return
    end
  end
end

local events =
{
  [defines.events.on_built_entity] = on_built_entity
}


local lib = {}
lib.on_event = handler(events)

return lib
