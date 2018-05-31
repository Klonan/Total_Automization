handler = require("script/event_handler")

local libs = {
  debug = require "script/debug",
  teleporters = require "script/teleporters",
  classes = require "script/classes/classes",
}

libs.debug.libs = libs

script.on_event(defines.events, function(event)
  for name, lib in pairs (libs) do
    if lib.on_event then
      lib.on_event(event)
    end
  end
end)

script.on_init(function()
  game.speed = settings.startup["game-speed"].value
  for name, lib in pairs (libs) do
    if lib.on_init then
      lib.on_init()
    end
  end
end)

script.on_load(function()
  for name, lib in pairs (libs) do
    if lib.on_load then
      lib.on_load()
    end
  end
end)

script.on_configuration_changed(function(data)
  for name, lib in pairs (libs) do
    if lib.on_configuration_changed then
      lib.on_configuration_changed(data)
    end
  end
end)

--todo control points