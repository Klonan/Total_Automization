local class =
{
  name = class_names.demoman
}
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("Stickybomb Launcher")
  character.insert("Stickybomb Launcher Ammo")
end

return setmetatable(class, {__call = function(self, ...) create(...) end})