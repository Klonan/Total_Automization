local setup_force = function(force)
  if not (force and force.valid) then return end
  --game.print("Running force setup: "..force.name)
  force.disable_research()
  force.inserter_stack_size_bonus = 1
  force.worker_robots_storage_bonus = 5
  --force.worker_robots_speed_modifier = 3
  force.character_logistic_slot_count = 18
  force.character_trash_slot_count = 12
  force.quickbar_count = 3
  force.ghost_time_to_live = 999999999
  force.character_build_distance_bonus = 2
  force.character_item_drop_distance_bonus = 2
  force.character_reach_distance_bonus = 2
  force.character_resource_reach_distance_bonus = 2
  force.character_inventory_slots_bonus = 20
  force.auto_character_trash_slots = true
end

local on_force_created = function(event)
  setup_force(event.force)
end

local events =
{
  [defines.events.on_force_created] = on_force_created
}


local setup = {}

setup.on_init = function()
  for k, force in pairs (game.forces) do
    setup_force(force)
  end
end

setup.on_event = handler(events)

return setup

