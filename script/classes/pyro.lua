local class =
{
  name = class_names.pyro
}
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("heavy-armor")
  character.insert("pyro-gun")
  character.insert("pyro-ammo")
  character.insert("pyro-flare-gun")
  character.insert("pyro-flare-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})