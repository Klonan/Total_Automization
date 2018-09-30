--TODO, would need to be fixed for player specific GUI indices if we wanted to use this.

local production_score = require("production-score")

local data = 
{
  sell_chests = {},
  buy_chests = {},
  prices = {},
  funds = {},
  button_actions = {},
  frames = {},
  selected = {}
}

local update_interval = 64
local buy_tariff = 1.1 --10% tax
local sell_tariff = 1 / 1.1 --10% tax

local buy_name = names.entities.buy_chest
local sell_name = names.entities.sell_chest

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
  local force_name = chest.force.name
  local total = 0
  local contents = chest.get_inventory(defines.inventory.chest).get_contents()
  for name, count in pairs (contents) do
    local price = prices[name]
    if price then
      total = total + ((price * count) * sell_tariff)
    end
  end
  chest.clear_items_inside()
  data.funds[force_name] = (data.funds[force_name] or 0) + total
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
  local force_name = chest.force.name
  local funds = data.funds[force_name]
  if not funds then return end
  local contents = chest.get_inventory(defines.inventory.chest).get_contents()
  --I know it should be "chest.prototype.filter_count", but it hurts performance, and i know that it is 5
  for k = 1, 5 do
    local stack = chest.get_request_slot(k)
    if stack then
      local stack_name = stack.name
      local price = prices[stack_name]
      if price then
        local buy_count = stack.count - (contents[stack_name] or 0)
        if buy_count > 0 then
          local cost = (price * buy_count) * buy_tariff
          if cost <= funds then
            data.funds[force_name] = funds - cost
            chest.insert({name = stack_name, count = buy_count})
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

local sort_groups = function(groups)
  local new = {}
  for name, group in pairs (groups) do
    local order = group.order
    local put = false
    for k, other in pairs (new) do
      if order <= other.order then
        table.insert(new, k, group)
        put = true
        break
      end
    end
    if not put then
      table.insert(new, group)
    end
  end
  return new
end

local get_all_groups = function()
  local groups = {}
  local subgroups = {}
  for k, prot in pairs ({game.item_prototypes, game.fluid_prototypes}) do
    for name, item in pairs (prot) do
      if not groups[item.group.name] then
        groups[item.group.name] = item.group
      end
      if not subgroups[item.subgroup.name] then
        subgroups[item.subgroup.name] = {}
      end
      local subgroup = subgroups[item.subgroup.name]
      local order = item.order
      local put = false
      for k, other in pairs (subgroup) do
        if order <= other.order then
          table.insert(subgroup, k, item)
          put = true
          break
        end
      end
      if not put then
        table.insert(subgroup, item)
      end
    end
  end
  return sort_groups(groups), subgroups
end

local create_trade_menu = function(player)
  local gui = player.gui.left
  local old_frame = data.frames[player.index]
  if (old_frame and old_frame.valid) then
    util.deregister_gui(old_frame, data.button_actions)
    old_frame.destroy()
  end
  local frame = gui.add{type = "frame", caption = "Trade Price Menu", direction = "vertical"}
  data.frames[player.index] = frame
  local groups, subgroups = get_all_groups()
  local flow = frame.add{type = "table", column_count = 6, style = "slot_table"}
  data.selected[player.index] = data.selected[player.index] or 1
  local selected = data.selected[player.index]
  for k = 1, #groups do
    local group = groups[k]
    local slot = flow.add{type = "sprite-button", sprite = "item-group/"..group.name, style = "image_tab_slot", tooltip = group.localised_name}
    data.button_actions[slot.index] = {type = "switch_group", index = k}
    if k == selected then
      slot.style = "image_tab_selected_slot"
    end
  end
  local prices = data.prices
  local fluids = game.fluid_prototypes
  local sub_group_holder = frame.add{type = "table", column_count = 1, style = "slot_table"}
  local selected_group = groups[selected]
  for k, subgroup in pairs (selected_group.subgroups) do
    local subgroup_table = sub_group_holder.add{type = "table", column_count = 10, style = "slot_table"}
    local items = subgroups[subgroup.name]
    for k, item in pairs (items or {}) do
      local price = prices[item.name]
      if price then
        if fluids[item.name] then
          local slot = subgroup_table.add{type = "sprite-button", sprite = "fluid/"..item.name, tooltip = item.localised_name, style = "red_slot_button", number = price}
        elseif not item.has_flag("hidden") then
            local slot = subgroup_table.add{type = "sprite-button", sprite = "item/"..item.name, tooltip = item.localised_name, style = "recipe_slot_button", number = price}
        end
      end
    end
    if #subgroup_table.children == 0 then
      subgroup_table.destroy()
    end
  end
  if #sub_group_holder.children == 0 then
    sub_group_holder.destroy()
    frame.add{type = "label", caption = "No items to show for this group."}
  end



end

local button_functions =
{
  toggle_trade_menu = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.index) then return end
    local old_frame = data.frames[player.index]
    if (old_frame and old_frame.valid) then
      util.deregister_gui(old_frame, data.button_actions)
      old_frame.destroy()
      return
    end
    create_trade_menu(player)
  end,
  switch_group = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.index) then return end
    data.selected[player.index] = param.index
    create_trade_menu(player)
  end
}

local on_player_created = function(event)
  local player = game.players[event.player_index]
  local button = player.gui.top.add{type = "button", caption = "Trade Price Menu"}
  data.button_actions[button.index] = {type = "toggle_trade_menu"}
end

local on_gui_click = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local action = data.button_actions[gui.index]
  if action then
    button_functions[action.type](event, action)
  end
end

local events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_gui_click] = on_gui_click,

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