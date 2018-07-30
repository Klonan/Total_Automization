local teleporter_name = require"shared".entities.teleporter


local data =
{
  networks = {},
  frames = {},
  button_actions = {}
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
  cancel_button = function(param)
    close_frame(param.frame)
  end,
  confirm_rename_button = function(param)
    local flying_text = param.flying_text
    if flying_text and flying_text.valid then
      param.flying_text.text = param.textfield.text
    end
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
  network[entity.unit_number] = {teleporter = entity, flying_text = text}


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
  local network = data.networks[force.name]
  if not network then return end
  local param = network[entity.unit_number]
  if not param then return end
  param.flying_text.destroy()
  network[entity.unit_number] = nil
end

local teleporter_triggered = function(entity)
  if not (entity and entity.valid and entity.name == teleporter_name) then return end
  local force = entity.force
  local network = data.networks[force.name]
  if not network then return end
  local param = network[entity.unit_number]
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
  gui_click_actions[action.name](action)
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
