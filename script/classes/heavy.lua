local class =
{
  name = class_names.heavy
}
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("heavy-armor")
  character.insert("heavy-gun")
  character.insert("heavy-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})