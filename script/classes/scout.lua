local class = {}
class.name = "scout"
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("scout-gun")
  character.insert("scout-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})