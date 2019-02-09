local libraries =
{
  wave_defense = require("wave_defense")
}

local register_events = function(libraries)

  local all_events = {}

  for lib_name, lib in pairs (libraries) do
    if lib.get_events then
      local lib_events = lib.get_events()
      for k, handler in pairs (lib_events) do
        all_events[k] = all_events[k] or {}
        all_events[k][lib_name] = handler
      end
    end
  end

  for event, handlers in pairs (all_events) do
    local action
    action = function(event)
      for k, handler in pairs (handlers) do
        handler(event)
      end
    end
    script.on_event(event, action)
  end

end

script.on_init(function()
  for k, lib in pairs (libraries) do
    if lib.on_init then
      lib.on_init()
    end
  end
  register_events(libraries)
end)

script.on_load(function()
  for k, lib in pairs (libraries) do
    if lib.on_load then
      lib.on_load()
    end
  end
  register_events(libraries)
end)
