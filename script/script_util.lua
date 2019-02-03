local util = require("util")

local deregister_gui_internal
deregister_gui_internal = function(gui_element, data)
  data[gui_element.index] = nil
  for k, child in pairs (gui_element.children) do
    deregister_gui_internal(child, data)
  end
end

util.deregister_gui = function(gui_element, data)
  local player_data = data[gui_element.player_index]
  if not player_data then return end
  deregister_gui_internal(gui_element, player_data)
end

util.register_gui = function(data, gui_element, param)
  local player_data = data[gui_element.player_index]
  if not player_data then
    data[gui_element.player_index] = {}
    player_data = data[gui_element.player_index]
  end
  player_data[gui_element.index] = param
end

util.gui_action_handler = function(event, data, functions)
  error("don't actually use me")
  if not data then error("Gui action handler data is nil") end
  if not functions then error("Gui action handler functions is nil") end
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
    functions[action.type](event, action)
    return true
  end
end

util.center = function(area)
  return {x = (area.left_top.x + area.right_bottom.x) / 2, y = (area.left_top.y + area.right_bottom.y) / 2}
end

util.distance = function(p1, p2)
  return (((p1.x - p2.x) ^ 2) + ((p1.y - p2.y) ^ 2)) ^ 0.5
end

util.radius = function(area)
  return util.distance(area.right_bottom, area.left_top) / 2
end

util.clear_item = function(entity, item_name)
  if not (entity and entity.valid and item_name) then return end
  entity.remove_item{name = item_name, count = entity.get_item_count(item_name)}
end

util.copy = util.table.deepcopy

util.first_key = function(map)
  local k, v = next(map)
  return k
end

util.first_value = function(map)
  local k, v = next(map)
  return v
end

return util
