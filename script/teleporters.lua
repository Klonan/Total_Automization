local teleporter_name = require"shared".entities.teleporter


local data =
{
  networks = {},
  frames = {},
  button_actions = {},
  map = {}
}

local create_flash = function(surface, position)
  return surface.create_entity{name = "teleporter-explosion", position = position}
end

local close_frame = function(frame)
  if not (frame and frame.valid) then return end
  data.frames[frame.index] = nil
  util.deregister_gui(frame, data.button_actions)
  frame.destroy()
end

local gui_click_actions =
{
  cancel_button = function(event, param)
    close_frame(param.frame)
  end,
  confirm_rename_button = function(event, param)
    local flying_text = param.flying_text
    if not (flying_text and flying_text.valid) then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local key = flying_text.text
    local network = data.networks[player.force.name]
    local info = network[key]
    local new_key = param.textfield.text
    if network[new_key] and network[new_key] ~= info then
      player.print("Name already taken")
      return
    end
    network[new_key] = info
    network[key] = nil
    param.flying_text.text = new_key
    close_frame(param.frame)
  end,
  teleport_button = function(event, param)
    local teleport_param = param.param
    if not teleport_param then return end
    local destination = teleport_param.teleporter
    if not (destination and destination.valid) then return end
    destination.timeout = SU(300)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    player.teleport(destination.position)
    close_frame(param.frame)
  end
}

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.name ~= teleporter_name then return end
  local player = game.players[event.player_index]
  local surface = entity.surface
  local force = entity.force
  local caption = teleporter_name.." "..entity.unit_number
  local text = surface.create_entity{name = "tutorial-flying-text", text = caption, position = {entity.position.x, entity.position.y - 2}, force = entity.force, color = player.chat_color}
  text.active = false

  data.networks[force.name] = data.networks[force.name] or {}
  local network = data.networks[force.name]
  network[caption] = {teleporter = entity, flying_text = text}
  data.map[entity.unit_number] = network[caption]

  local gui = player.gui.center
  util.deregister_gui(gui, data.frames)
  util.deregister_gui(gui, data.button_actions)
  gui.clear()
  local frame = gui.add{type = "frame", caption = "Name teleporter", direction = "horizontal"}
  player.opened = frame
  data.frames[frame.index] = frame

  local textfield = frame.add{type = "textfield", text = caption}
  textfield.style.horizontally_stretchable = true
  local confirm = frame.add{type = "sprite-button", sprite = "utility/confirm_slot", style = "slot_button"}
  data.button_actions[confirm.index] = {name = "confirm_rename_button", frame = frame, textfield = textfield, flying_text = text}

  local cancel = frame.add{type = "sprite-button", sprite = "utility/set_bar_slot", style = "slot_button"}
  data.button_actions[cancel.index] = {name = "cancel_button", frame = frame}

end

local on_teleporter_removed = function(entity)
  if not (entity and entity.valid) then return end
  if entity.name ~= teleporter_name then return end
  local force = entity.force
  local param = data.map[entity.unit_number]
  if not param then return end
  param.flying_text.destroy()
  data.map[entity.unit_number] = nil
end

local create_teleport_gui = function(player, force)
  local network = data.networks[force.name]
  if not (table_size(network) > 1) then return end
  local gui = player.gui.center
  util.deregister_gui(gui, data.frames)
  util.deregister_gui(gui, data.button_actions)
  gui.clear()
  local frame = gui.add{type = "frame", direction = "vertical", caption = "Teleporter Network"}
  data.frames[frame.index] = frame
  for name, param in pairs (network) do
    local button = frame.add{type = "button", caption = name}
    data.button_actions[button.index] = {name = "teleport_button", param = param, frame = frame}
  end

end



local teleporter_triggered = function(entity)
  if not (entity and entity.valid and entity.name == teleporter_name) then return end
  local force = entity.force
  local surface = entity.surface
  local position = entity.position
  local param = data.map[entity.unit_number]
  local new_teleporter = surface.create_entity{name = teleporter_name, position = position, force = force}
  new_teleporter.active = false
  param.teleporter = new_teleporter
  data.map[new_teleporter.unit_number] = param
  data.map[entity.unit_number] = nil
  local player = surface.find_entities_filtered{type = "player", area = {{position.x - 1, position.y - 1}, {position.x + 1, position.y + 1}}, force = force}[1]
  if not player then return end
  create_teleport_gui(player, force)
end

local on_entity_died = function(event)
  local cause = event.cause
  local entity = event.entity
  if cause and cause.valid and entity and entity.valid and entity.name == teleporter_name and cause == entity then
    return teleporter_triggered(entity)
  end
  on_teleporter_removed(event.entity)
end

local on_player_mined_entity = function(event)
  on_teleporter_removed(event.entity)
end

local on_robot_mined_entity = function(event)
  on_teleporter_removed(event.entity)
end

local on_gui_click = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local action = data.button_actions[element.index]
  if not action then return end
  gui_click_actions[action.name](event, action)
end

local on_gui_closed = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local frame = data.frames[element.index]
  if not (frame and frame.valid) then return end
  data.frames[element.index] = nil
  frame.destroy()
end

local events = {
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_player_mined_entity] = on_player_mined_entity,
  [defines.events.on_robot_mined_entity] = on_robot_mined_entity,
  [defines.events.on_gui_closed] = on_gui_closed,
}

local teleporters = {}

teleporters.on_event = function(event)
  if not (event and event.name) then return end
  local action = events[event.name] or function() return end
  return action(event)
end

teleporters.on_init = function()
  global.teleporters = global.teleporters or data
end

teleporters.on_load = function()
  data = global.teleporters
end

return teleporters
