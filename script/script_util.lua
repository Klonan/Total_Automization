local util = require("util")

local deregister_gui
deregister_gui = function(gui_element, data)
--  if data[gui_element.index] then
--    game.print("Deregistered gui of index "..gui_element.index)
--  end
  data[gui_element.index] = nil
  for k, child in pairs (gui_element.children) do
    deregister_gui(child, data)
  end
end
util.deregister_gui = deregister_gui

return util
