SU = function(v)
  return v * settings.startup["game-speed"].value
end

SD = function(v)
  return v / settings.startup["game-speed"].value
end

handler = require("script/event_handler")

local hotkeys = require("shared").hotkeys
for k, name in pairs (hotkeys) do
  local event_name = script.generate_event_name()
  defines.events[name] = event_name
  script.on_event(name, function(event) script.raise_event(event_name, event) end)
end

--error(serpent.block(defines.events))

local libs = {
  debug = require "script/debug",
  teleporters = require "script/teleporters",
  classes = require "script/classes/classes",
  stickybomb_launcher = require "script/stickybomb_launcher",
  unit_deployment = require("script/unit_deployment"),
  unit_control = require "script/unit_control",
  command_center = require("script/command_center"),
  --killcam = require("script/killcam"),
  setup = require("script/setup"),
  setup_time = require("script/setup_time")
}


remote.add_interface("tf", {get = function(func) func(libs) end})

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