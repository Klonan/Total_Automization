local util = require("util")

local variety = function(explosion)

  if not explosion then return end
  local sprite = explosion.animations[1]
  if not sprite then return end

  local new = {}

  for scale = 0.7, 1.3, 0.1 do
    for speed = 0.7, 1.3, 0.1 do
      local fresh = util.copy(sprite)
      fresh.scale = (fresh.scale or 1) * scale
      fresh.animation_speed = (fresh.animation_speed or 1) * scale
      table.insert(new, fresh)
    end
  end

  explosion.animations = new
end

variety(data.raw.explosion["explosion-hit"])
variety(data.raw.explosion["explosion-gunshot"])
