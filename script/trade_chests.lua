local production_score = require("production-score")

local data = 
{
  sell_chests = {},
  buy_chests = {},
  prices = {},
  funds = {}
}

local update_interval = 64

local buy_name = require("shared").entities.buy_chest
local sell_name = require("shared").entities.sell_chest

local buy_chest_built = function(entity)
  local unit_number = entity.unit_number
  local index = unit_number % update_interval
  data.buy_chests[index] = data.buy_chests[index] or {}
  data.buy_chests[index][unit_number] = entity
end

local sell_chest_built = function(entity)
  local unit_number = entity.unit_number
  local index = unit_number % update_interval
  data.sell_chests[index] = data.sell_chests[index] or {}
  data.sell_chests[index][unit_number] = entity
end

local on_built_entity = function(event)
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.name == buy_name then
    return buy_chest_built(entity)
  end
  if entity.name == sell_name then
    return sell_chest_built(entity)
  end
end

local sell_from_chest = function(chest)
  local prices = data.prices
  local force = chest.force
  local total = 0
  local contents = chest.get_inventory(defines.inventory.chest).get_contents()
  for name, count in pairs (contents) do
    local price = prices[name]
    if price then
      total = total + (price * count)
    end
  end
  chest.clear_items_inside()
  data.funds[force.name] = (data.funds[force.name] or 0) + total
end

local update_sell_chests = function(chests)
  for unit_number, chest in pairs (chests) do
    if chest.valid then
      sell_from_chest(chest)
    else
      chests[unit_number] = nil
    end
  end
end

local buy_for_chest = function(chest)
  local prices = data.prices
  local force = chest.force
  local funds = data.funds[force.name]
  if not funds then return end
  local contents = chest.get_inventory(defines.inventory.chest).get_contents()
  for k = 1, chest.prototype.filter_count do
    local stack = chest.get_request_slot(k)
    if stack then
      local stack_name = stack.name
      local stack_count = stack.count
      local already = contents[stack_name] or 0
      if already < stack_count then
        local buy_count = stack_count - already
        local price = prices[stack_name]
        if price then
          local cost = price * buy_count
          if cost <= funds then
            funds = funds - cost
            chest.insert({name = stack_name, count = stack_count})
          end
        end
      end
    end
  end
end

local update_buy_chests = function(chests)
  for unit_number, chest in pairs (chests) do
    if chest.valid then
      buy_for_chest(chest)
    else
      chests[unit_number] = nil
    end
  end
end

local on_tick = function(event)
  local tick = event.tick
  local index = tick % update_interval

  local sell_chests = data.sell_chests[index]
  if sell_chests then
    update_sell_chests(sell_chests)
  end

  local buy_chests = data.buy_chests[index]
  if buy_chests then
    update_buy_chests(buy_chests)
  end

end

local events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick
}

local trade_chests = {}

trade_chests.on_event = handler(events)

trade_chests.on_init = function()
  global.trade_chests = global.trade_chests or data
  data.prices = production_score.generate_price_list()
end

trade_chests.on_load = function()
  data = global.trade_chests or data
end

return trade_chests