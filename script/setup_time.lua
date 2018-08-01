local names = require("shared").entities
--Don't scale the setup time here, we do it in the function body to preserve real seconds
local setupable =
{
  [names.gun_turret] = 30 * 60
}

local data =
{
  entities = {},
  map = {}
}

local on_tick = function(event)
  local tick = event.tick
  local entities = data.entities[tick]
  if not entities then return end
  for k, param in pairs (entities) do
    local done = (tick >= param.setup_tick)
    local entity = param.entity
    if done and entity and entity.valid then
      entity.active = true
    end
    local text = param.text
    if text and text.valid then
      if done then
        text.destroy()
      else
        local value = math.ceil(SD(param.setup_tick - tick) / 60 )
        text.text = value
        if value <= 5 then
          text.color = {r = 1, g = 0.5, b = 0.5}
        end
      end
    end
  end
  data.entities[tick] = nil
end

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  local setup_time = setupable[entity.name]
  if not setup_time then return end
  entity.active = false
  local setup_tick = event.tick + math.ceil(SU(setup_time))
  local text = entity.surface.create_entity{name = "tutorial-flying-text", position = entity.position, text = math.floor(setup_time / 60)}
  text.active = false
  local param = {entity = entity, text = text, setup_tick = setup_tick}
  data.map[entity.unit_number] = param
  local insert = table.insert
  local entities = data.entities
  local interval = SU(60)
  for k = 1, setup_tick, interval do
    local tick = math.floor(k + 0.5)
    entities[tick] = entities[tick] or {}
    insert(entities[tick], param)
  end
  
  entities[setup_tick] = entities[setup_tick] or {}
  insert(entities[setup_tick], param)
end

local check_setup = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  local map = data.map
  local param = map[entity.unit_number]
  if not param then return end
  local text = param.text
  if text and text.valid then
    text.destroy()
  end
  map[entity.unit_number] = nil
end

local events =
{
  [defines.events.on_tick] = on_tick,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_entity_died] = check_setup,
  [defines.events.on_player_mined_entity] = check_setup,
  [defines.events.on_robot_mined_entity] = check_setup,
}

local on_event = handler(events)

local setup_time = {}

setup_time.on_event = on_event

setup_time.on_load = function()
  data = global.setup_time
end

setup_time.on_init = function()
  global.setup_time = data
end

return setup_time



