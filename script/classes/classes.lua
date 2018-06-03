local classes = {}
local class_list = 
{
  pyro = require("script/classes/pyro"),
  heavy = require("script/classes/heavy"),
  sniper = require("script/classes/sniper"),
  medic = require("script/classes/medic"),
  soldier = require("script/classes/soldier"),
  demoman = require("script/classes/demoman"),
  scout = require("script/classes/scout")
}

classes.set_class = function(player, name)
  local class = class_list[name]
  if class then
    class(player)
  end
end

classes.on_event = function(event)
  for class, data in pairs (class_list) do
    if data.on_event then
      data.on_event(event)
      --error("I work")
    end
  end
end

classes.on_init = function()
  for class, data in pairs (class_list) do
    if data.on_init then
      data.on_init()
      --error("I work")
    end
  end
end
classes.on_load = function()
  for class, data in pairs (class_list) do
    if data.on_load then
      data.on_load()
      --error("I work")
    end
  end
end

classes.class_list = class_list

return classes