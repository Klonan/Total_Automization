local class = {}
class.name = "demoman"
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("heavy-armor")
  character.insert("demoman-gun")
  character.insert("demoman-ammo")
  character.insert("demoman-sticky-gun")
  character.insert("demoman-sticky-ammo")
end
return setmetatable(class, {__call = function(self, ...) create(...) end})