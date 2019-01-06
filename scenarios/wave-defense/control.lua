local wave_defense = require("wave_defense")

script.on_event(defines.events, function(event)
  wave_defense.on_event(event)
end)

script.on_init(function()
  wave_defense.on_init()
end)

script.on_load(function()
  wave_defense.on_load()
end)
