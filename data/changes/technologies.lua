--Remove technologies we don't care about

local types =
{
  "mining-drill-productivity-bonus",
  "ammo-damage",
  "gun-speed",
  "turret-attack",
  "artillery-range",
  "deconstruction-time-to-live",
  "worker-robot-speed",
  "worker-robot-storage",
  "laboratory-speed",
  "inserter-stack-size-bonus",
  "stack-inserter-capacity-bonus",
  "ghost-time-to-live",
  "train-braking-force-bonus",
  "laboratory-productivity",
  "maximum-following-robots-count",
  "quick-bar-count"
}
for k, type in pairs(types) do
  util.prototype.remove_technology_effect_type(type)
end

