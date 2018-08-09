--Make all normal chests into logistic passive providers
local new = {}
for k, chest in pairs (data.raw.container) do
  local new_chest = util.copy(chest)
  new_chest.type = "logistic-container"
  new_chest.logistic_mode = "passive-provider"
  new_chest.render_not_in_network_icon = false
  table.insert(new, new_chest)
  chest.name = chest.name.."-old"
  chest.order = "old"
  chest.flags = {}
  table.insert(new, chest)
  data.raw.container[k] = nil
end
data:extend(new)


