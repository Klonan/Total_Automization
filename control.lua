tf_require = function(path)
  local new = path:gsub("/", ".")
  return require(new)
end

SU = function(v)
  return v  -- * settings.startup["game-speed"].value
end

SD = function(v)
  return v -- / settings.startup["game-speed"].value
end


handler = tf_require("script/event_handler")
names = tf_require("shared")
util = tf_require("script/script_util")

--error(serpent.block(defines.events))

local libs = {
  debug = tf_require "script/debug",
  unit_deployment = tf_require("script/unit_deployment"),
  unit_control = tf_require "script/unit_control",
  command_center = tf_require("script/command_center"),
  killcam = tf_require("script/killcam"),
  pvp_interface = tf_require("script/pvp_interface"),
  auto_request = tf_require("script/auto_request"),
  construction_done = tf_require("script/construction_drone"),
  freeplay_interface = tf_require("script/freeplay_interface"),
  --logistic_beacon = tf_require("script/logistic_beacon"),
  --teleporters = tf_require "script/teleporters",
  --setup = tf_require("script/setup"),
  --classes = tf_require "script/classes/classes",
  --stickybomb_launcher = tf_require "script/stickybomb_launcher",
  --setup_time = tf_require("script/setup_time"),
  --ammo_pack = tf_require("script/ammo_pack"),
  --damage_indicator = tf_require("script/damage_indicator"),
  --trade_chests = tf_require("script/trade_chests")
}


remote.add_interface("tf", {get = function(func) func(libs) end})
remote.add_interface("debug", {dump = function() log(serpent.block(global)) end})

libs.debug.libs = libs

local on_event = function(event)
  --local tick = game.tick
  --log(tick.. " | Control on_event triggered")
  for name, lib in pairs (libs) do
    if lib.on_event then
      --log(tick.. " | Running on_Event for lib "..name)
      lib.on_event(event)
    end
  end
end

local register_all_events = function()
  --hack(?)
  local last_event = script.generate_event_name()
  --log("LAST: "..last_event)
  local all_events = {}
  for k = 0, last_event do
    all_events[k] = k
  end
  script.on_event(all_events, on_event)

  local hotkeys = names.hotkeys
  for k, name in pairs (hotkeys) do
    script.on_event(name, function(event) event.name = name on_event(event) end)
  end

end

local on_init = function()
  --game.speed = settings.startup["game-speed"].value
  for name, lib in pairs (libs) do
    if lib.on_init then
      lib.on_init()
    end
  end
  register_all_events()
end

local on_load = function()
  for name, lib in pairs (libs) do
    if lib.on_load then
      lib.on_load()
    end
  end
  register_all_events()
end

local on_configuration_changed = function(data)
  for name, lib in pairs (libs) do
    if lib.on_configuration_changed then
      lib.on_configuration_changed(data)
    end
  end
end

script.on_init(on_init)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)
