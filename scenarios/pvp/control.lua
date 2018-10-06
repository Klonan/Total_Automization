local pvp = require("pvp")

pvp.add_remote_interface()

script.on_init(function()
  pvp.on_init()
end)

script.on_load(function()
  pvp.on_load()
end)

script.on_configuration_changed(function()
  pvp.on_configuration_changed()
end)

script.on_event(defines.events, function(event)
  pvp.on_event(event)
end)

script.on_nth_tick(60, function(event)
  pvp.on_nth_tick[60](event)
end)

script.on_nth_tick(300, function(event)
  pvp.on_nth_tick[300](event)
end)
