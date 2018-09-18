--Explosions looks horrible, that is a quote from posila, so if you are reading this, this Lua file is his fault.

for k, explosion in pairs (data.raw.explosion) do
  util.recursive_hack_tint(explosion, {r = 1, g = 1, b = 1, a = 0.5})
  explosion.created_effect = nil
end