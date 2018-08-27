local name = require("shared").entities.damage_indicator_text
local on_entity_damaged = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local damage = math.floor(event.final_damage_amount * 100) / 100
  local box = entity.selection_box
  local position = {math.random(box.left_top.x * 20, box.right_bottom.x * 20) / 20, math.random(box.left_top.y * 20, box.right_bottom.y * 20) / 20}
  entity.surface.create_entity{name = name, text = "-"..damage, color = {r = 1, g = 0.5, b = 0.5}, position = position}
end

local events =
{
  [defines.events.on_entity_damaged] = on_entity_damaged
}
local damage_indicator = {}

damage_indicator.on_event = handler(events)

return damage_indicator
