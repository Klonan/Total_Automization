global.gui_action_listener = {}

local get_next_index = function(table)
  local max = 0
  for k in table do
    max = k
  end
  return max + 1
end

local add_action_listener = function(gui, param)
  local gui_actions = global.gui_action_listener
  local player_gui_actions = gui_actions[gui.player_index]
  if not player_gui_actions then
    gui_actions[gui.player_index] = {}
    player_gui_actions = gui_actions[gui.player_index]
  end
  local actions = player_gui_actions[gui.index]
  if not actions then
    actions = {}
    player_gui_actions[gui.index] = actions
  end
  local index = get_next_index(actions)
  actions[index] = param
  return index
end


local clear_action_listeners = function(gui)
  local player_gui_actions = global.gui_action_listener[gui.player_index]
  if not player_gui_actions then return end
  player_gui_actions[gui.index] = nil
end

local remove_action_listener = function(gui, index)
  local player_gui_actions = global.gui_action_listener[gui.player_index]
  if not player_gui_actions then return end
  local gui_actions = player_gui_actions[gui.index]
  if not gui_actions then return end
  gui_actions[index] = nil
end

local function recursive_clear_all_listeners(gui)
  local player_gui_actions = global.gui_action_listener[gui.player_index]
  if not player_gui_actions then return end
  player_gui_actions[gui.index] = nil
  for k, child in pairs (gui.children) do
    recursive_clear_all_listeners(child)
  end
end

local generic_gui_event = function(event, functions)
  --oh idk
end

return
{
  add = add_action_listener,
  remove = remove_action_listener,
  clear = clear_action_listeners,
  clear_all = recursive_clear_all_listeners
}
