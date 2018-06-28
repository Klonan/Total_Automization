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

util.center = function(area)
  return {x = (area.left_top.x + area.right_bottom.x) / 2, y = (area.left_top.y + area.right_bottom.y) / 2}
end

util.radius = function(area)
  return math.max(math.abs(area.left_top.x + area.right_bottom.x) / 2, math.abs(area.left_top.y + area.right_bottom.y) / 2)
end

util.clear_item = function(entity, item_name)
  if not (entity and entity.valid and item_name) then return end
  entity.remove_item{name = item_name, count = entity.get_item_count(item_name)}
end


return util
