local class = {}
class.name = "soldier"
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("heavy-armor")
  character.insert("soldier-gun")
  character.insert("soldier-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})