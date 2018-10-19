local data =
{
  killcams = {}
}

local make_killcam = function(player, cause)
  local gui = player.gui.center
  gui.clear()
  local name = cause.name
  if cause.type == "player" and cause.player then
    name = cause.player.name
  else
    name = game.entity_prototypes[name].localised_name
  end
  local frame = gui.add{type = "frame", caption = {"", "You were killed by ", name}}
  local camera = frame.add{type = "camera", position = cause.position, zoom = 1}
  camera.style.width = player.display_resolution.width * 0.8
  camera.style.height = player.display_resolution.height * 0.8
  local cams = data.killcams
  cams[player.index] = {gui = camera, cause = cause, frame = frame}
end

local on_player_died = function(event)
  local cause = event.cause
  if not cause then return end
  local player = game.players[event.player_index]
  make_killcam(player, cause)
end

local on_tick = function(event)
  local cams = data.killcams
  for k, cam in pairs (cams) do
    local player = game.players[k]
    if player.character then
      cam.frame.destroy()
      cams[k] = nil
    elseif cam.cause.valid then
      cam.gui.position = cam.cause.position
    end
  end
end

local events = 
{
  [defines.events.on_player_died] = on_player_died,
  [defines.events.on_tick] = on_tick
}

local killcam = {}

killcam.on_init = function()
  global.killcam = data
  killcam.on_event = handler(events)
end

killcam.on_load = function()
  data = global.killcam or data
  killcam.on_event = handler(events)
end

return killcam
