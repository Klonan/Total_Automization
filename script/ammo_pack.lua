local ammo_pack = names.items.ammo_pack

local get_empty_ammo_name = function(inventory)
  for k = 1, #inventory do
    local stack = inventory[k]
    local ammo_name = inventory.get_filter(k)
    if ammo_name and not stack.valid_for_read then
      return stack, ammo_name
    end
  end
end

local on_player_ammo_inventory_changed = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local character = player.character
  if not (character and character.valid) then return end
  if character.get_item_count(ammo_pack) == 0 then return end
  local ammo_inventory = character.get_inventory(defines.inventory.player_ammo)
  local stack, name = get_empty_ammo_name(ammo_inventory)
  if not stack then return end
  local item = game.item_prototypes[name]
  if not name then return end
  if not stack.set_stack{name = item.name, count = item.stack_size} then return end
  character.remove_item{name = ammo_pack, count = 1}
  --player.play_sound{path = "utility/wire_connect_pole"}
  player.create_local_flying_text
  {
    text = "Used Ammo Pack",
    color = {r = 0.3, g = 1, b = 0.3},
    position = player.position
  }
end

local on_trigger_created_entity = function(event)
  
end

local events =
{
  [defines.events.on_player_ammo_inventory_changed] = on_player_ammo_inventory_changed,
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity
}

local ammo_pack = {}

ammo_pack.on_event = handler(events)

return ammo_pack
