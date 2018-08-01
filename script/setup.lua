local setup_force = function(force)
  if not (force and force.valid) then return end
  force.disable_research()
  force.inserter_stack_size_bonus = 1
end

local on_force_created = function(event)
  setup_force(event.force)
end

local events =
{
  [defines.events.on_force_created] = on_force_created
}

local on_event = handler(events)

local setup = {}

setup.on_init = function()
  for k, force in pairs (game.forces) do
    setup_force(force)
  end
end

return setup

