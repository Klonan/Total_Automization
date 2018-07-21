--Remove technologies we don't care about

local types =
{
  ["mining-drill-productivity-bonus"] = true,
  ["ammo-damage"] = true,
  ["gun-speed"] = true,
  ["turret-attack"] = true,
  ["artillery-range"] = true,
  ["deconstruction-time-to-live"] = true,
  ["worker-robot-speed"] = true,
  ["worker-robot-storage"] = true,
  ["laboratory-speed"] = true,
  ["inserter-stack-size-bonus"] = true,
  ["stack-inserter-capacity-bonus"] = true,
  ["ghost-time-to-live"] = true,
  ["train-braking-force-bonus"] = true,
  ["laboratory-productivity"] = true,
  ["maximum-following-robots-count"] = true,
  ["quick-bar-count"] = true,
  ["auto-character-logistic-trash-slots"] = true,
  ["character-logistic-trash-slots"] = true,
  ["character-logistic-slots"] = true
}

util.prototype.remove_technology_effect_type(types)

