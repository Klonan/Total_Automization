local class =
{
  name = class_names.demoman,
  data = {}
}
local create = function(player)
  player.create_character(class.name)
  local character = player.character
  character.insert("heavy-armor")
  character.insert("demoman-gun")
  character.insert("demoman-ammo")
  character.insert("demoman-sticky-gun")
  character.insert("demoman-sticky-ammo")
end

local demoman_mine_expiry =
{
  ["demoman-sticky-bomb"] = SU(60 * 15)
}

local on_land_mine_armed = function(event)
  local mine = event.mine
  if not (mine and mine.valid) then return end
  local expire = demoman_mine_expiry[mine.name]
  if not expire then return end
  local data = class.data
  local tick_to_expire = event.tick + expire
  data[tick_to_expire] = data[tick_to_expire] or {}
  table.insert(data[tick_to_expire], mine)
end

local on_tick = function(event)
  local entities = class.data[event.tick]
  if not entities then return end
  for k, entity in pairs (entities) do
    if entity.valid then
      entity.die()
    end
  end
  class.data[event.tick] = nil
end

class.events =
{
  [defines.events.on_land_mine_armed] = on_land_mine_armed,
  [defines.events.on_tick] = on_tick
}

class.on_event = handler(class.events)
class.on_init = function()
  global.demoman_destroy_on_tick = global.demoman_destroy_on_tick or class.data
end
class.on_load = function()
  class.data = global.demoman_destroy_on_tick or class.data
end
return setmetatable(class, {__call = function(self, ...) create(...) end})