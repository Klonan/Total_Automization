--Explosions looks horrible, that is a quote from posila, so if you are reading this, this Lua file is his fault.

for k, explosion in pairs (data.raw.explosion) do
  util.recursive_hack_tint(explosion, {r = 1, g = 1, b = 1, a = 0.5})
  explosion.created_effect = nil
end

--Make all projectiles trigger at the collision position:

for k, projectile in pairs (data.raw.projectile) do
  projectile.hit_at_collision_position = true
end

local explosion = data.raw.explosion["explosion-hit"]
local animation = explosion.animations[1]
animation.tint = nil
animation.blend_mode = "additive-soft"
local animations = {}
local make_animation = function(scale, speed)
  local new = util.copy(animation)
  new.scale = scale
  new.speed = speed
  table.insert(animations, new)
end

for scale = 0.5, 1.5, 0.1 do
  for speed = 1.5, 0.5, -0.1 do
    make_animation(scale, speed)
  end
end

explosion.animations = animations
