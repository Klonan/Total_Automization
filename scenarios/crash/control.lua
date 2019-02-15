script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)


  for k = 1, 1000 do
    player.surface.request_path
    {
      bounding_box = {{-0.1,-0.1},{0.1,0.1}},
      collision_mask = {},
      start = {k, k},
      goal = {-k, -k},
      radius = 1,
      force = player.force
    }
  end

end)