local class = {}
class.name = "medic"
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  --character.insert("heavy-armor")
  character.insert("medic-gun")
  character.insert("medic-ammo")
  character.insert("medic-needle-gun")
  character.insert("medic-needle-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})