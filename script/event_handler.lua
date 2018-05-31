return function(events)
  return function(event)
    local events = events or {}
    local action = events[event.name] or function() return end
    return action(event)
  end
end