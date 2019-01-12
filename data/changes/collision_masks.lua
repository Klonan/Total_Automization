local mask = {"player-layer", "train-layer", "not-colliding-with-itself"}
local mask = {"player-layer", "train-layer"}

for k, unit in pairs (data.raw.unit) do
  unit.collision_mask = mask
  unit.radar_range = unit.radar_range or 2
  unit.affected_by_tiles = true
end


for k, player in pairs (data.raw.player) do
    player.collision_mask = mask
end