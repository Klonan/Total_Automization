local mask = {"player-layer", "train-layer", "not-colliding-with-itself"}

for k, unit in pairs (data.raw.unit) do
    unit.collision_mask = mask
    if not unit.radar_range then unit.radar_range = 2 end
end

for k, player in pairs (data.raw.player) do
    player.collision_mask = mask
end