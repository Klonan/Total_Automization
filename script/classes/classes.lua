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
    if class.on_event then
      class.on_event(event)
    end
  end
end

classes.class_list = class_list

return classes