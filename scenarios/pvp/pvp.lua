local mod_gui = require("mod-gui")
local util = require("util")
local balance = require("balance")
local config = require("config")
local production_score = require("production-score")

local script_data =
{
  gui_actions = {},
  team_players = {},
  elements =
  {
    config = {},
    balance = {},
    import = {},
    admin = {},
    admin_button = {},
    spectate_button = {},
    join = {},
    progress_bar = {},
    team_frame = {},
    team_list_button = {},
    production_score_frame = {},
    production_score_inner_frame = {},
    recipe_frame = {},
    recipe_button = {}
  },
  timers = {},
  setup_finished = false,
  ready_players = {},
  config = {},
  round_number = 0,
  selected_recipe = {}
}

local statistics_period = 150 -- Seconds

local events =
{
  on_round_end = script.generate_event_name(),
  on_round_start = script.generate_event_name(),
  on_team_lost = script.generate_event_name(),
  on_team_won = script.generate_event_name()
}

local starting_area_chunk_radius =
{
  ["none"] = 3,
  ["very-low"] = 3,
  ["low"] = 4,
  ["normal"] = 5,
  ["high"] = 6,
  ["very-high"] = 7
}

get_starting_area_radius = function(as_tiles)
  local surface = game.surfaces[1]
  local size = surface.map_gen_settings.starting_area
  local radius = starting_area_chunk_radius[size]
  if as_tiles then
    return radius * 32
  end
  return radius
end

function create_spawn_positions()
  local settings = game.surfaces[1].map_gen_settings
  local width = settings.width
  local height = settings.height
  local displacement = math.max(script_data.config.team_config.average_team_displacement, 64)
  local horizontal_offset = (width / displacement) * 10
  local vertical_offset = (height / displacement) * 10
  script_data.spawn_offset = {x = math.floor(0.5 + math.random(-horizontal_offset, horizontal_offset) / 32) * 32, y = math.floor(0.5 + math.random(-vertical_offset, vertical_offset) / 32) * 32}
  local height_scale = height / width
  local radius = get_starting_area_radius()
  local count = #script_data.config.teams
  local max_distance = get_starting_area_radius(true) * 2 + displacement
  local min_distance = get_starting_area_radius(true) + (32 * (count - 1))
  local edge_addition = (radius + 2) * 32
  local elevator_set = false
  if height_scale == 1 then
    if max_distance > width then
      displacement = width - edge_addition
    end
  end
  if height_scale < 1 then
    if #script_data.config.teams == 2 then
      if max_distance > width then
        displacement = width - edge_addition
      end
      max_distance = 0
    end
    if max_distance > height then
      displacement = height - edge_addition
    end
  end
  if height_scale > 1 then
    if #script_data.config.teams == 2 then
      if max_distance > height then
        displacement = height - edge_addition
      end
      elevator_set = true
      max_distance = 0
    end
    if max_distance > width then
      displacement = width - edge_addition
    end
  end
  local distance = 0.5*displacement
  if distance < min_distance then
    game.print({"map-size-below-minimum"})
  end
  local positions = {}
  if count == 1 then
    positions[1] = {x = 0, y = 0}
  else
    for k = 1, count do
      local rotation = (k*2*math.pi)/count
      local X = 32*(math.floor((math.cos(rotation)*distance+0.5)/32))
      local Y = 32*(math.floor((math.sin(rotation)*distance+0.5)/32))
      if elevator_set then
        --[[Swap X and Y for elevators]]
        Y = 32*(math.floor((math.cos(rotation)*distance+0.5)/32))
        X = 32*(math.floor((math.sin(rotation)*distance+0.5)/32))
      end
      positions[k] = {x = X, y = Y}
    end
  end
  if #positions == 2 and height_scale == 1 then
    --If there are 2 teams in a square map, we adjust positions so they are in the corners of the map
    for k, position in pairs (positions) do
      if position.x == 0 then position.x = position.y end
      if position.y == 0 then position.y = -position.x end
    end
  end
  if #positions == 4 then
    --If there are 4 teams we adjust positions so they are in the corners of the map
    height_scale = math.min(height_scale, 2)
    height_scale = math.max(height_scale, 0.5)
    for k, position in pairs (positions) do
      if position.x == 0 then position.x = position.y end
      if position.y == 0 then position.y = -position.x end
      if height_scale > 1 then
        position.y = position.y * height_scale
      else
        position.x = position.x * (1/height_scale)
      end
    end
    if height_scale < 1 then
      --If the map is wider than tall, swap 1 and 3 so two allied teams will be together
      positions[1], positions[3] = positions[3], positions[1]
    end
  end
  for k, position in pairs (positions) do
    position.x = position.x + script_data.spawn_offset.x
    position.y = position.y + script_data.spawn_offset.y
  end
  script_data.spawn_positions = positions
  --error(serpent.block(positions))
  return positions
end

function create_next_surface()
  local name = "battle_surface_1"
  if game.surfaces[name] ~= nil then
    name = "battle_surface_2"
  end
  script_data.round_number = script_data.round_number + 1
  local settings = game.surfaces[1].map_gen_settings
  settings.starting_points = create_spawn_positions()
  script_data.surface = game.create_surface(name, settings)
  script_data.surface.always_day = script_data.config.team_config.always_day
end

function destroy_player_gui(player)
  local elements = script_data.elements
  local index = player.index
  for name, guis in pairs (elements) do
    local frame = guis[index]
    if frame and frame.valid then
      deregister_gui(frame)
      frame.destroy()
    end
    guis[index] = nil
  end

  for k, timer in pairs (script_data.timers) do
    if timer.valid then
      timer.destroy()
    end
  end
  script_data.timers = {}

end

function check_balance_frame_size(event)
  local player = game.players[event.player_index]
  if not player then return end
  local frame = player.gui.center.balance_options_frame
  if not frame then return end
  toggle_balance_options_gui(player)
  toggle_balance_options_gui(player)
end

function deregister_gui(gui)
  local player_gui_actions = script_data.gui_actions[gui.player_index]
  if not player_gui_actions then return end
  player_gui_actions[gui.index] = nil
  for k, child in pairs (gui.children) do
    deregister_gui(child)
  end
end

function register_gui_action(gui, param)
  local gui_actions = script_data.gui_actions
  local player_gui_actions = gui_actions[gui.player_index]
  if not player_gui_actions then
    gui_actions[gui.player_index] = {}
    player_gui_actions = gui_actions[gui.player_index]
  end
  player_gui_actions[gui.index] = param
end

function add_team_to_new_flow(team, flow, current_team, admin)
  local frame = flow.add{type = "frame", direction = "vertical"}
  frame.style.horizontally_stretchable = true
  local title_flow = frame.add{type = "flow", direction = "horizontal"}
  local show_flow = title_flow.add{type = "flow", style = "slot_table_spacing_horizontal_flow"}
  local label = show_flow.add{type = "label", caption = team.name, style = "large_caption_label"}
  local pusher = show_flow.add{type = "flow"}
  pusher.style.horizontally_stretchable = true
  label.style.font_color = get_color(team, true)
  if admin then
    local edit_button = show_flow.add{type = "sprite-button", style = "slot_button", sprite = "utility/rename_icon_small"}
    edit_button.style.height = 20
    edit_button.style.width = 20
    local edit_flow = title_flow.add{type = "flow", style = "slot_table_spacing_horizontal_flow", visible = false}
    edit_flow.style.horizontally_squashable = true
    local textfield = edit_flow.add{type = "textfield", text = team.name}
    textfield.style.width = 100
    local color_drop = edit_flow.add{type = "drop-down"}
    local index = 1
    for k, color in pairs (script_data.config.colors) do
      color_drop.add_item({"color."..color.name})
      if color.name == team.color then
        index = k
      end
    end
    color_drop.selected_index = index
    local pusher = edit_flow.add{type = "flow"}
    pusher.style.horizontally_stretchable = true
    local textfield_confirm = edit_flow.add{type = "sprite-button", style = "green_slot_button", sprite = "utility/confirm_slot"}
    local textfield_cancel = edit_flow.add{type = "sprite-button", style = "not_available_slot_button", sprite = "utility/reset"}
    register_gui_action(textfield_cancel, {type = "cancel_rename", edit_flow = edit_flow, show_flow = show_flow})
    register_gui_action(edit_button, {type = "rename_team", edit_flow = edit_flow, show_flow = show_flow})
    local delete_button = show_flow.add{type = "sprite-button", style = "not_available_slot_button", sprite = "utility/trash"}
    delete_button.style.height = 20
    delete_button.style.width = 20
    register_gui_action(delete_button, {type = "remove_team", team = team, frame = frame})
    register_gui_action(textfield_confirm, {type = "confirm_rename", textfield = textfield, team = team, dropdown = color_drop})
  end
  local team_number = frame.add{type = "flow", direction = "horizontal"}
  team_number.add{type = "label", caption = {"", {"team"}, {"colon"}}, style = "description_label"}
  if admin then
    local button = team_number.add{type = "button", caption = team.team, style = "small_slot_button"}
    register_gui_action(button, {type = "team_button_press", team = team})
  else
    team_number.add{type = "label", caption = team.team}
  end
  local ready = ""
  local first_ready = true
  local ready_data = script_data.ready_players
  local red = function(str)
    return "[color=1,0.2,0.2]"..str.."[/color]"
  end
  local green = function(str)
    return "[color=0.2,1,0.2]"..str.."[/color]"
  end
  for k, member in pairs (team.members or {}) do
    if first_ready then
      first_ready = false
    else
      ready = ready..", "
    end
    if ready_data[k] then
      ready = ready .. green(member.name)
    else
      ready = ready .. red(member.name)
    end
  end
  if first_ready then
    ready = {"none"}
  end
  local label = frame.add{type = "label", caption = {"members", ready}, style = "description_label"}
  label.style.single_line = false
  label.style.maximal_width = 400
  if not current_team or current_team ~= team then
    local join_team = frame.add{type = "button", caption = {"join-team"}}
    join_team.style.font = "default"
    join_team.style.height = 24
    join_team.style.top_padding = 0
    join_team.style.bottom_padding = 0
    register_gui_action(join_team, {type = "join_team", team = team})
  end

end

refresh_config = function(excluded_player_index)
  for k, player in pairs (game.players) do
    if k ~= excluded_player_index then
      create_config_gui(player)
    end
  end
end

refresh_balance = function(excluded_player_index)
  for k, player in pairs (game.players) do
    if k ~= excluded_player_index then
      toggle_balance_options_gui(player)
      toggle_balance_options_gui(player)
    end
  end
end

local name_allowed = function(name, team)
  if name == "" then return false end
  for k, other_team in pairs (script_data.config.teams) do
    if other_team.name == name then
      if other_team ~= team then
        return false
      end
    end
  end
  return true
end

local is_text_valid = function(text)
  if text == "" then return false end
  local number = tonumber(text)
  if not number then return false end
  if number < 0 then return false end
  if number > 4294967295 then return false end
  return true
end

local check_all_ready = function()
  local all_ready = true
  for k, player in pairs (game.players) do
    if player.connected then
      if not script_data.ready_players[k] then
        all_ready = false
        break
      end
    end
  end
  if all_ready then
    start_all_ready_preparations()
  elseif script_data.ready_start_tick then
    script_data.ready_start_tick = nil
    game.print({"ready-cancelled"})
  end
end

local gui_functions =
{
  new_team = function(event, param)
    local name
    repeat name = game.backer_names[math.random(#game.backer_names)]
    until name_allowed(name)
    local team =
    {
      name = name,
      color = script_data.config.colors[math.random(#script_data.config.colors)].name,
      members = {},
      team = "-"
    }
    table.insert(script_data.config.teams, team)
    refresh_config()
  end,
  remove_team = function(event, param)
    if #script_data.config.teams == 1 then
      game.players[event.player_index].print("Can't remove last team")
      return
    end
    for k, team in pairs (script_data.config.teams) do
      if team == param.team then
        table.remove(script_data.config.teams, k)
        for k, members in pairs (team.members) do
          script_data.ready_players[k] = nil
          script_data.team_players[k] = nil
        end
        break
      end
    end
    refresh_config()
  end,
  rename_team = function(event, param)
    param.edit_flow.visible = true
    param.show_flow.visible = false
  end,
  cancel_rename = function(event, param)
    param.edit_flow.visible = false
    param.show_flow.visible = true
  end,
  confirm_rename = function(event, param)
    local name = param.textfield.text
    if not name_allowed(name, param.team) then
      game.players[event.player_index].print("Name not allowed") --[[TODO locale]]
      return
    end
    param.team.name = name
    param.team.color = script_data.config.colors[param.dropdown.selected_index].name
    refresh_config()
  end,
  join_team = function(event, param)
    local player = game.players[event.player_index]
    local current_team = script_data.team_players[player.index]
    if current_team then
      current_team.members[player.index] = nil
    end
    param.team.members[player.index] = player
    script_data.team_players[player.index] = param.team
    refresh_config()
  end,
  team_button_press = function(event, param)
    local gui = event.element
    if not (gui and gui.valid) then return end
    local left_click = (event.button == defines.mouse_button_type.left)
    local index = gui.caption
    if index == "-" then
      if left_click then
        index = 1
      else
        index = "?"
      end
    elseif index == "?" then
      if left_click then
        index = "-"
      else
        index = #script_data.config.teams
      end
    elseif index == tostring(#script_data.config.teams) then
      if left_click then
        index = "?"
      else
        index = index -1
      end
    else
      if left_click then
        index = tonumber(index) + 1
      elseif index == tostring(1) then
        index = "-"
      else
        index = index -1
      end
    end
    gui.caption = index
    param.team.team = index
    refresh_config(event.player_index)
  end,
  config_text_value_changed = function(event, param)
    if event.name ~= defines.events.on_gui_text_changed then return end
    local textfield = event.element
    if not (textfield and textfield.valid) then return end
    local text = textfield.text
    local valid = is_text_valid(text)
    if not valid then
      textfield.style = "invalid_value_textfield"
      return
    end
    textfield.style = "textbox"
    param.config[param.key] = tonumber(text)
    refresh_config(event.player_index)
  end,
  config_dropdown_value_changed = function(event, param)
    if event.name ~= defines.events.on_gui_selection_state_changed then return end
    local dropdown = event.element
    if not (dropdown and dropdown.valid) then return end
    param.value.selected = param.value.options[dropdown.selected_index]
    refresh_config(event.player_index)
  end,
  config_boolean_changed = function(event, param)
    if event.name ~= defines.events.on_gui_checked_state_changed then return end
    local check = event.element
    if not (check and check.valid) then return end
    param.config[param.key] = check.state
    refresh_config(event.player_index)
  end,
  start_round = function(event, param)
    start_round()
  end,
  ready_up = function(event, param)
    if event.name ~= defines.events.on_gui_checked_state_changed then return end
    local checkbox = event.element
    if not (checkbox and checkbox.valid) then return end
    local player = game.players[event.player_index]
    local current_team = script_data.team_players[event.player_index]
    if not current_team then 
      player.print({"cant-ready"})
      checkbox.state = false
      return
    end
    if checkbox.state then
      script_data.ready_players[event.player_index] = true
      game.print({"player-is-ready", player.name})
    else
      script_data.ready_players[event.player_index] = nil
      game.print({"player-is-not-ready", player.name})
    end
    refresh_config()
    check_all_ready()
  end,
  toggle_balance_options = function(event, param)
    toggle_balance_options_gui(game.players[event.player_index])
  end,
  reset_balance_options = function(event, param)
    for name, modifiers in pairs (script_data.config.modifier_list) do
      for key, value in pairs (modifiers) do
        modifiers[key] = 0
      end
    end
    refresh_balance()
  end,
  balance_textfield_changed = function(event, param)
    if event.name ~= defines.events.on_gui_text_changed then return end
    local textfield = event.element
    if not (textfield and textfield.valid) then return end
    local text = textfield.text
    local valid = is_text_valid(text)
    if not valid then
      textfield.style = "invalid_value_textfield"
      return
    end
    textfield.style = "textbox"
    local value = (text - 100) / 100
    script_data.config.modifier_list[param.modifier][param.key] = value
    refresh_balance(event.player_index)
  end,
  balance_options_confirm = function(event, param)
    local player = game.players[event.player_index]
  end,
  pvp_import = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local config = script_data.elements.config[player.index]
    if (config and config.valid) then
      config.visible = false
    end
    local gui = player.gui.center
    local frame = gui.add{type = "frame", caption = {"gui-blueprint-library.import-string"}, direction = "vertical"}
    script_data.elements.import[player.index] = frame
    local textfield = frame.add{type = "text-box"}
    textfield.word_wrap = true
    textfield.style.height = player.display_resolution.height * 0.6
    textfield.style.width = player.display_resolution.width * 0.6
    local flow = frame.add{type = "flow", direction = "horizontal"}
    register_gui_action
    (
      flow.add{type = "button", caption = {"gui.close"}, style = "dialog_button"},
      {type = "import_export_close", frame = frame}
    )
    local pusher = flow.add{type = "flow"}
    pusher.style.horizontally_stretchable = true
    register_gui_action
    (
      flow.add{type = "button", caption = {"gui-blueprint-library.import"}, style = "dialog_button"},
      {type = "import_confirm", frame = frame, textfield = textfield}
    )
  end,
  import_confirm = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local gui = player.gui.center
    local frame = param.frame
    if not (frame and frame.valid) then return end
    local textfield = param.textfield
    if not (textfield and textfield.valid) then return end
    local text = textfield.text
    if text == "" then player.print({"import-failed"}) return end
    local new_config = game.json_to_table(util.decode(text))
    if not new_config then
      player.print({"import-failed"})
      return
    end
    for k, v in pairs (new_config) do
      script_data.config[k] = v
    end
    local config = script_data.elements.config[player.index]
    if (config and config.valid) then
      config.visible = true
    end
    refresh_config()
    deregister_gui(frame)
    frame.destroy()
    script_data.elements.import[player.index] = nil
    player.print({"import-success"})
    log("Pvp config import success")
  end,
  pvp_export = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local config = script_data.elements.config[player.index]
    if (config and config.valid) then
      config.visible = false
    end
    local gui = player.gui.center
    local frame = gui.add{type = "frame", caption = {"gui.export-to-string"}, direction = "vertical"}
    script_data.elements.import[player.index] = frame
    local textfield = frame.add{type = "text-box"}
    textfield.word_wrap = true
    textfield.read_only = true
    textfield.style.height = player.display_resolution.height * 0.6
    textfield.style.width = player.display_resolution.width * 0.6
    local config = script_data.config
    local data =
    {
      game_config = config.game_config,
      team_config = config.team_config,
      modifier_list = config.modifier_list,
      teams = config.teams,
      disabled_items = config.disabled_items
    }
    textfield.text = util.encode(game.table_to_json(data))
    register_gui_action
    (
      frame.add{type = "button", caption = {"gui.close"}, style = "dialog_button"},
      {type = "import_export_close", frame = frame}
    )
  end,
  import_export_close = function(event, param)
    local frame = param.frame
    if not (frame and frame.valid) then return end
    deregister_gui(frame)
    frame.destroy()
    script_data.elements.import[event.player_index] = nil
    local config = script_data.elements.config[event.player_index]
    if (config and config.valid) then
      config.visible = true
    end
  end,
  disable_elem_changed = function(event, param)
    if event.name ~= defines.events.on_gui_elem_changed then return end
    
    local gui = event.element
    local player = game.players[event.player_index]
    if not (player and player.valid and gui and gui.valid) then return end
    local parent = gui.parent
    if not script_data.config.disabled_items then
      script_data.config.disabled_items = {}
    end
    local items = script_data.config.disabled_items
    local value = gui.elem_value
    if not value then
      local map = {}
      for k, child in pairs (parent.children) do
        if child.elem_value then
          map[child.elem_value] = true
        end
      end
      for item, bool in pairs (items) do
        if not map[item] then
          items[item] = nil
        end
      end
      deregister_gui(gui)
      gui.destroy()
      return
    end

    if items[value] then
      if items[value] ~= gui.index then
        gui.elem_value = nil
        player.print({"duplicate-disable"})
      end
    else
      items[value] = gui.index
      register_gui_action(parent.add{type = "choose-elem-button", elem_type = "item"}, {type = "disable_elem_changed"})
    end
    script_data.config.disabled_items = items
    refresh_config(event.player_index)
  end,
  join_spectator = function(event, param)
    local frame = param.frame
    if (frame and frame.valid) then
      deregister_gui(frame)
      frame.destroy()
    end
    spectator_join(game.players[event.player_index])
  end,
  admin_button = function(event, param)
    local gui = event.element
    local player = game.players[event.player_index]
    local frame = script_data.elements.admin[event.player_index]
    if (frame and frame.valid) then
      frame.visible = not frame.visible
      return
    end
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow.add{type = "frame", caption = {"admin"}, direction = "vertical"}
    script_data.elements.admin[player.index] = frame
    frame.visible = true
    register_gui_action(frame.add{type = "button", caption = {"end-round"}, tooltip = {"end-round-tooltip"}, style = "dialog_button"}, {type = "admin_end_round"})
    register_gui_action(frame.add{type = "button", caption = {"reroll-round"}, tooltip = {"reroll-round-tooltip"}, style = "dialog_button"}, {type = "admin_reroll_round"})
    register_gui_action(frame.add{type = "button", caption = {"admin-change-team"}, tooltip = {"admin-change-team-tooltip"}, style = "dialog_button"}, {type = "spectator_join_team_button"})
  end,
  admin_end_round = function(event, param)
    destroy_config_for_all()
    end_round(game.players[event.player_index])
  end,
  admin_reroll_round = function(event, param)
    end_round()
    prepare_next_round()
    return
  end,
  spectator_join_team_button = function(event, param)
    choose_joining_gui(game.players[event.player_index])
  end,
  pick_team = function(event, param)
    local gui = event.element
    local player = game.players[event.player_index]
    if not (gui and gui.valid and player and player.valid) then return end
    local team = param.team
    if not team then return end
    set_player(player, team)
  
    for k, player in pairs (game.forces.player.players) do
      choose_joining_gui(player)
      choose_joining_gui(player)
    end
  
    for k, player in pairs (game.connected_players) do
      update_team_list_frame(player)
    end
  
  end,
  list_teams_button = function(event, param)
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local frame = script_data.elements.team_frame[player.index]
    if frame and frame.valid then
      frame.destroy()
      script_data.elements.team_frame[player.index] = nil
      return
    end
    local flow = mod_gui.get_frame_flow(player)
    frame = flow.add{type = "frame", caption = {"teams"}, direction = "vertical"}
    script_data.elements.team_frame[player.index] = frame
    update_team_list_frame(player)
  end,
  production_score_button = function(event, param)
    local gui = event.element
    local player = game.players[event.player_index]
    local frame = script_data.elements.production_score_frame[player.index]
    if frame and frame.valid then
      deregister_gui(frame)
      script_data.elements.production_score_frame[player.index] = nil
      frame.destroy()
      return
    end
    local flow = mod_gui.get_frame_flow(player)
    frame = flow.add{type = "frame", caption = {"production_score"}, direction = "vertical"}
    script_data.elements.production_score_frame[player.index] = frame
    frame.style.title_bottom_padding = 8
    if script_data.config.victory.required_production_score > 0 then
      frame.add{type = "label", caption = {"", {"required_production_score"}, {"colon"}, " ", util.format_number(script_data.config.victory.required_production_score)}}
    end
    if script_data.config.game_config.time_limit > 0 then
      table.insert(script_data.timers, frame.add{type = "label", caption = {"time_left", get_time_left()}})
    end
    local inner_frame = frame.add{type = "frame", style = "image_frame", direction = "vertical"}
    script_data.elements.production_score_inner_frame[player.index] = inner_frame
    inner_frame.style.left_padding = 8
    inner_frame.style.top_padding = 8
    inner_frame.style.right_padding = 8
    inner_frame.style.bottom_padding = 8
    local flow = frame.add{type = "flow", direction = "horizontal"}
    flow.add{type = "label", caption = {"", {"recipe-calculator"}, {"colon"}}}
    local recipe_button = flow.add{type = "choose-elem-button", elem_type = "recipe"}
    register_gui_action(recipe_button, {type = "recipe_picker_elem_changed", frame = frame})
    script_data.elements.recipe_button[player.index] = recipe_button
    flow.style.vertical_align = "center"
    update_production_score_frame(player)
    recipe_picker_elem_update(player)
  end,
  recipe_picker_elem_changed = function(event, param)
    if event.name ~= defines.events.on_gui_elem_changed then return end
    local elem_button = event.element
    if not (elem_button and elem_button.valid) then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    script_data.selected_recipe[player.index] = elem_button.elem_value
    recipe_picker_elem_update(player)
  end,
  calculator_button_press = function(event, param)
    on_calculator_button_press(event, param)
  end,
  space_race_button = function(event, param)
    space_race_button_press(event)
  end
}

function start_all_ready_preparations()
  local seconds = 10
  game.print({"everybody-ready", seconds})
  script_data.ready_start_tick = game.tick + (seconds * 60)
end

function add_new_config_gui(config_data, flow, admin)
  local bool_flow = flow.add{type = "flow", direction = "vertical"}
  local other_flow = flow.add{type = "table", column_count = 2}
  other_flow.style.column_alignments[1] = "right"
  local items = game.item_prototypes
  for name, value in pairs (config_data) do
    if type(value) == "boolean" then
      local check = bool_flow.add{type = "checkbox", state = value, caption = config.localised_names[name] or {name}, ignored_by_interaction = not admin, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      register_gui_action(check, {type = "config_boolean_changed", config = config_data, key = name})
    end
    if tonumber(value) then
      other_flow.add{type = "label", caption = config.localised_names[name] or {name}, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      if admin then
        text = other_flow.add{type = "textfield", text = value}
        text.style.maximal_width = 80
        register_gui_action(text, {type = "config_text_value_changed", config = config_data, key = name})
      else
        other_flow.add{type = "label", caption = value}
      end
    end
    if type(value) == "table" then
      other_flow.add{type = "label", caption = config.localised_names[name] or {name}, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      if admin then
        local menu = other_flow.add{type = "drop-down", enabled = admin}
        register_gui_action(menu, {type = "config_dropdown_value_changed", value = value})
        local index
        for j, option in pairs (value.options) do
          if items[option] then
            menu.add_item(items[option].localised_name)
          else
            menu.add_item({option})
          end
          if option == value.selected then index = j end
        end
        menu.selected_index = index or 1
      else
        other_flow.add{type = "label", caption = (items[value.selected] and items[value.selected].localised_name) or {value.selected}}
      end
    end
  end
end

function add_victory_gui(config_data, flow, admin)
  local flow = flow.add{type = "table", column_count = 2}
  flow.style.column_alignments[1] = "right"
  local items = game.item_prototypes
  for name, value in pairs (config_data) do
    if type(value) == "boolean" then
      local check = flow.add{type = "checkbox", state = value, caption = config.localised_names[name] or {name}, ignored_by_interaction = not admin, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      check.style.horizontally_stretchable = true
      register_gui_action(check, {type = "config_boolean_changed", config = config_data, key = name})
      local spacer = flow.add{type = "flow"}
    end
    if tonumber(value) then
      flow.add{type = "label", caption = config.localised_names[name] or {name}, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      if admin then
        text = flow.add{type = "textfield", text = value}
        text.style.maximal_width = 80
        register_gui_action(text, {type = "config_text_value_changed", config = config_data, key = name})
      else
        flow.add{type = "label", caption = value}
      end
    end
    if type(value) == "table" then
      flow.add{type = "label", caption = config.localised_names[name] or {name}, tooltip = config.localised_tooltips[name] or {name.."_tooltip"}}
      if admin then
        local menu = flow.add{type = "drop-down", enabled = admin}
        register_gui_action(menu, {type = "config_dropdown_value_changed", value = value})
        local index
        for j, option in pairs (value.options) do
          if items[option] then
            menu.add_item(items[option].localised_name)
          else
            menu.add_item({option})
          end
          if option == value.selected then index = j end
        end
        menu.selected_index = index or 1
      else
        flow.add{type = "label", caption = {value.selected}}
      end
    end
  end
end

function create_config_gui(player)
  local old = script_data.elements.config[player.index]
  local visible = true
  if (old and old.valid) then
    visible = old.visible
    deregister_gui(old)
    old.destroy()
  end
  local admin = player.admin
  local gui = player.gui.center
  local flow = gui.add{type = "flow", direction = "horizontal", visible = visible}
  script_data.elements.config[player.index] = flow
  flow.style.vertical_align = "top"
  flow.style.minimal_width = player.display_resolution.width * 0.8
  flow.style.minimal_height = player.display_resolution.height * 0.8
  flow.style.maximal_width = player.display_resolution.width
  flow.style.maximal_height = player.display_resolution.height
  local upper_frame = flow.add{type = "frame", caption = "PvP configuration", direction = "vertical"}
  upper_frame.style.vertically_stretchable = false
  upper_frame.style.maximal_height = player.display_resolution.height
  local holding_table = upper_frame.add{type = "flow", direction = "horizontal"}
  local team_lobby = holding_table.add{type = "frame", caption = "Teams", direction = "vertical", style = "inside_deep_frame"}
  if admin then
    local button = team_lobby.add{type = "button", caption = {"add-team"}, enabled = #script_data.config.teams < 24, style = "dialog_button"}
    register_gui_action(button, {type = "new_team", frame = flow})
  end
  local scroll = team_lobby.add{type = "scroll-pane", direction = "vertical"}
  local current_team = script_data.team_players[player.index]
  for k, team in pairs (script_data.config.teams) do
    add_team_to_new_flow(team, scroll, current_team, admin)
  end
  local str = ""
  local first = true
  for k, player in pairs (game.players) do
    if not script_data.team_players[k] then
      if first then
        first = false
      else
        str = str.. ", "
      end
      str = str .. player.name
    end
  end
  if first then str = {"none"} end
  team_lobby.add{type = "label", caption = {"unassigned-players",  str}}

  local team_settings = holding_table.add{type = "frame", caption = {"team-settings"}, direction = "vertical", style = "inside_deep_frame"}
  team_settings.style.horizontally_stretchable = false
  add_new_config_gui(script_data.config.team_config, team_settings.add{type = "scroll-pane"}, admin)

  local game_settings = holding_table.add{type = "frame", caption = {"game-settings"}, direction = "vertical", style = "inside_deep_frame"}
  game_settings.style.horizontally_stretchable = false
  add_new_config_gui(script_data.config.game_config, game_settings.add{type = "scroll-pane"}, admin)
  local other_flow = holding_table.add{type = "flow", direction = "vertical"}
  other_flow.style.horizontally_stretchable = false
  local victory = other_flow.add{type = "frame", caption = {"victory-conditions"}, direction = "vertical", style = "inside_deep_frame"}
  add_victory_gui(script_data.config.victory, victory.add{type = "scroll-pane"}, admin)
  local disable_items = other_flow.add{type = "frame", caption = {"disabled-items"}, style = "inside_deep_frame"}
  create_disable_frame(disable_items)
  local button_flow = upper_frame.add{type = "flow"}
  button_flow.style.vertical_align = "center"
  register_gui_action(
    button_flow.add
    {
      type = "button",
      caption = {"balance-options"},
      style = "dialog_button"
    },
    {
      type = "toggle_balance_options"
    }
  )
  register_gui_action(button_flow.add{type = "sprite-button", sprite = "utility/export_slot", tooltip = {"gui.export-to-string"}, style = "slot_button"}, {type = "pvp_export"})
  register_gui_action(button_flow.add{type = "sprite-button", sprite = "utility/import_slot", tooltip = {"gui-blueprint-library.import-string"}, style = "slot_button"}, {type = "pvp_import"})
  local pusher = button_flow.add{type = "flow"}
  pusher.style.horizontally_stretchable = true
  local ready = script_data.ready_players[player.index] or false
  local ready_up = button_flow.add{type = "checkbox", caption = {"ready"}, state = ready}
  register_gui_action(ready_up, {type = "ready_up"})
  local start_button = button_flow.add{type = "button", style = "confirm_button", caption = {"start-round"}, enabled = admin}
  register_gui_action(start_button, {type = "start_round"})
end


function end_round(admin)
  for k, player in pairs (game.players) do
    player.force = game.forces.player
    player.tag = ""
    destroy_player_gui(player)
    if player.connected then
      if player.ticks_to_respawn then
        player.ticks_to_respawn = nil
      end
      local character = player.character
      player.character = nil
      if character then character.destroy() end
      player.set_controller{type = defines.controllers.spectator}
      player.teleport({0,1000}, game.surfaces.Lobby)
      create_config_gui(player)
    end
  end
  if script_data.surface and script_data.surface.valid then
    game.delete_surface(script_data.surface)
  end
  if admin then
    game.print({"admin-ended-round", admin.name})
  end
  script_data.setup_finished = false
  script_data.check_starting_area_generation = false
  script_data.average_score = nil
  script_data.scores = nil
  script_data.exclusion_map = nil
  script_data.protected_teams = nil
  script_data.check_base_exclusion = nil
  script_data.oil_harvest_scores = nil
  script_data.production_scores = nil
  script_data.space_race_scores = nil
  script_data.last_defcon_tick = nil
  script_data.next_defcon_tech = nil
  script_data.silos = nil
  script.raise_event(events.on_round_end, {})
end

function prepare_next_round()
  script_data.setup_finished = false
  script_data.team_won = false
  create_next_surface()
  setup_teams()
  chart_starting_area_for_force_spawns()
  set_evolution_factor()
  set_difficulty()
end

game_mode_buttons = {
  ["production_score"] = {type = "button", caption = {"production_score"}, action = "production_score_button", style = mod_gui.button_style},
  ["oil_harvest"] = {type = "button", caption = {"oil_harvest"}, action = "oil_harvest_button", style = mod_gui.button_style},
  ["space_race"] = {type = "button", caption = {"space_race"}, action = "space_race_button", style = mod_gui.button_style}
}

function init_player_gui(player)
  destroy_player_gui(player)

  if script_data.progress then
    update_progress_bar()
    return
  end

  if not script_data.setup_finished then
    create_config_gui(player)
    return
  end

  if player.force.name == "player" then
    choose_joining_gui(player)
    return
  end

  local button_flow = mod_gui.get_button_flow(player)

  local list_teams_button = button_flow.add{type = "button", caption = {"teams"}, style = mod_gui.button_style}
  register_gui_action(list_teams_button, {type = "list_teams_button"})
  script_data.elements.team_list_button[player.index] = list_teams_button

  for name, button in pairs (game_mode_buttons) do
    if not script_data.elements[name] then
      script_data.elements[name] = {}
    end
    if script_data.config.victory[name] then
      local element = button_flow.add(button)
      register_gui_action(element, {type = button.action})
      script_data.elements[name][player.index] = element
    end
  end

  if player.admin then
    local admin_button = button_flow.add{type = "button", caption = {"admin"}, style = mod_gui.button_style}
    register_gui_action(admin_button, {type = "admin_button"})
    script_data.elements.admin_button[player.index] = admin_button
  end

  if player.force.name == "spectator" then
    local spectate_button = button_flow.add{type = "button", caption = {"join-team"}, style = mod_gui.button_style}
    register_gui_action(spectate_button, {type = "spectator_join_team_button"})
    script_data.elements.spectate_button[player.index] = spectate_button
  end

end

function get_color(team, lighten)
  local c = script_data.config.colors[script_data.config.color_map[team.color]].color
  if lighten then
    return {r = 1 - (1 - c.r) * 0.5, g = 1 - (1 - c.g) * 0.5, b = 1 - (1 - c.b) * 0.5, a = 1}
  end
  return c
end

function add_player_list_gui(force, gui)
  if not (force and force.valid) then return end
  if #force.players == 0 then
    gui.add{type = "label", caption = {"none"}}
    return
  end
  local scroll = gui.add{type = "scroll-pane"}
  scroll.style.maximal_height = 120
  local name_table = scroll.add{type = "table", column_count = 1}
  name_table.style.vertical_spacing = 0
  local added = {}
  local first = true
  if #force.connected_players > 0 then
    local online_names = ""
    for k, player in pairs (force.connected_players) do
      if not first then
        online_names = online_names..", "
      end
      first = false
      online_names = online_names..player.name
      added[player.name] = true
    end
    local online_label = name_table.add{type = "label", caption = {"online", online_names}}
    online_label.style.single_line = false
    online_label.style.maximal_width = 180
  end
  first = true
  if #force.players > #force.connected_players then
    local offline_names = ""
    for k, player in pairs (force.players) do
      if not added[player.name] then
      if not first then
        offline_names = offline_names..", "
      end
      first = false
      offline_names = offline_names..player.name
      added[player.name] = true
      end
    end
    local offline_label = name_table.add{type = "label", caption = {"offline", offline_names}}
    offline_label.style.single_line = false
    offline_label.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
    offline_label.style.maximal_width = 180
  end
end

function set_player(player, team, mute)
  local force = game.forces[team.name]
  local surface = script_data.surface
  if not surface.valid then return end
  local position = surface.find_non_colliding_position("player", force.get_spawn_position(surface), 320, 1)
  if position then
    player.teleport(position, surface)
  else
    player.print({"cant-find-position"})
    choose_joining_gui(player)
    return
  end
  if player.character then
    player.character.destroy()
  end
  player.force = force
  player.color = get_color(team)
  player.chat_color = get_color(team, true)
  player.tag = "["..force.name.."]"
  player.set_controller
  {
    type = defines.controllers.character,
    character = surface.create_entity{name = "player", position = position, force = force}
  }
  player.spectator = false
  init_player_gui(player)
  for k, other_player in pairs (game.connected_players) do
    update_team_list_frame(player)
  end
  local artillery_remote = script_data.config.prototypes.artillery_remote
  if script_data.config.game_config.team_artillery and script_data.config.game_config.give_artillery_remote and game.item_prototypes[artillery_remote] then
    player.insert(artillery_remote)
  end
  config.give_equipment(player)

  balance.apply_character_modifiers(player)
  check_force_protection(force)
  if not mute then
    game.print({"joined", player.name, player.force.name})
  end
end

function choose_joining_gui(player)
  local teams = get_eligible_teams(player)
  if not teams then return end
  local frame = script_data.elements.join[player.index]
  if (frame and frame.valid) then
    deregister_gui(frame)
    frame.destroy()
    return
  end
  local gui = player.gui.center
  local frame = gui.add{type = "frame", caption = {"pick-join"}, direction = "vertical"}
  script_data.elements.join[player.index] = frame
  local inner_frame = frame.add{type = "frame", style = "image_frame", direction = "vertical"}
  inner_frame.style.left_padding = 8
  inner_frame.style.top_padding = 8
  inner_frame.style.right_padding = 8
  inner_frame.style.bottom_padding = 8
  local pick_join_table = inner_frame.add{type = "table", column_count = 4}
  pick_join_table.style.horizontal_spacing = 16
  pick_join_table.style.vertical_spacing = 8
  pick_join_table.draw_horizontal_lines = true
  pick_join_table.draw_vertical_lines = true
  pick_join_table.style.column_alignments[3] = "right"
  pick_join_table.add{type = "label", caption = {"team-name"}}.style.font = "default-semibold"
  pick_join_table.add{type = "label", caption = {"players"}}.style.font = "default-semibold"
  pick_join_table.add{type = "label", caption = {"team-number"}}.style.font = "default-semibold"
  pick_join_table.add{type = "label"}
  for k, team in pairs (teams) do
    local force = game.forces[team.name]
    if force then
      local name = pick_join_table.add{type = "label", caption = force.name}
      name.style.font = "default-semibold"
      name.style.font_color = get_color(team, true)
      add_player_list_gui(force, pick_join_table)
      local caption
      if tonumber(team.team) then
        caption = team.team
      elseif team.team:find("?") then
        caption = team.team:gsub("?", "")
      else
        caption = team.team
      end
      pick_join_table.add{type = "label", caption = caption}
      local join_button = pick_join_table.add{type = "button", caption = {"join"}, style = "dialog_button"}
      register_gui_action(join_button, {type = "pick_team", team = team})
    end
  end
  register_gui_action(frame.add{type = "button", caption = {"join-spectator"}, style = "dialog_button"}, {type = "join_spectator", frame = frame})
end

function toggle_balance_options_gui(player)
  if not (player and player.valid) then return end
  local gui = player.gui.center
  local frame = script_data.elements.balance[player.index]
  local config = script_data.elements.config[player.index]
  if frame then
    deregister_gui(frame)
    frame.destroy()
    script_data.elements.balance[player.index] = nil
    if config then
      config.visible = true
    end
    return
  end
  if (config and config.valid) then
    config.visible = false
  end
  frame = gui.add{type = "frame", direction = "vertical", caption = {"balance-options"}}
  script_data.elements.balance[player.index] = frame
  frame.style.maximal_height = player.display_resolution.height * 0.95
  frame.style.maximal_width = player.display_resolution.width * 0.95
  local scrollpane = frame.add{type = "scroll-pane"}
  local big_table = scrollpane.add{type = "table", column_count = 4, direction = "horizontal"}
  big_table.style.horizontal_spacing = 32
  big_table.draw_vertical_lines = true
  local entities = game.entity_prototypes
  local ammos = game.ammo_category_prototypes
  local admin = player.admin
  for modifier_name, array in pairs (script_data.config.modifier_list) do
    local flow = big_table.add{type = "frame", caption = {modifier_name}, style = "inner_frame"}
    local table = flow.add{type = "table", column_count = 3}
    table.style.column_alignments[1] = "right"
    table.style.column_alignments[2] = "right"
    for name, modifier in pairs (array) do
      if modifier_name == "ammo_damage_modifier" then
        local string = "ammo-category-name."..name
        table.add{type = "label", caption = {"", ammos[name].localised_name, {"colon"}}}
      elseif modifier_name == "gun_speed_modifier" then
        table.add{type = "label", caption = {"", ammos[name].localised_name, {"colon"}}}
      elseif modifier_name == "turret_attack_modifier" then
        table.add{type = "label", caption = {"", entities[name].localised_name, {"colon"}}}
      elseif modifier_name == "character_modifiers" then
        table.add{type = "label", caption = {"", {name}, {"colon"}}}
      end
      if admin then
        local input = table.add{type = "textfield"}
        register_gui_action(input, {type = "balance_textfield_changed", modifier = modifier_name, key = name})
        input.text = tostring((modifier * 100) + 100)
        input.style.maximal_width = 60
      else
        table.add{type = "label", caption = tostring((modifier * 100) + 100)}  
      end
      table.add{type = "label", caption = "%"}
    end
  end
  local flow = frame.add{type = "flow", direction = "horizontal"}
  flow.style.horizontally_stretchable = true
  flow.style.align = "right"
  register_gui_action(flow.add{type = "button", caption = {"gui.close"}, style = "dialog_button"}, {type = "toggle_balance_options"})
  if admin then
    add_pusher(flow)
    register_gui_action(flow.add{type = "button", caption = {"gui.reset"}, style = "dialog_button"}, {type = "reset_balance_options"})
  end
end

function create_disable_frame(gui)
  local disable_table = gui.add{type = "table", column_count = 6}
  disable_table.style.horizontal_spacing = 2
  disable_table.style.vertical_spacing = 2
  local items = game.item_prototypes
  local player = game.players[gui.player_index]
  local admin = player.admin
  if script_data.config.disabled_items then
    for item, bool in pairs (script_data.config.disabled_items) do
      local prototype = items[item]
      if prototype then
        if admin then
          local choose = disable_table.add{type = "choose-elem-button", elem_type = "item"}
          choose.elem_value = item
          register_gui_action(choose, {type = "disable_elem_changed"})
        else
          local icon = disable_table.add{type = "sprite", sprite = "item/"..item, tooltip = prototype.localised_name}
          icon.style.width = 32
          icon.style.height = 32
        end
      end
    end
  end
  if admin then
    local choose = disable_table.add{type = "choose-elem-button", elem_type = "item"}
    register_gui_action(choose, {type = "disable_elem_changed"})
  end
end

function start_round()
  destroy_config_for_all()
  prepare_next_round()
end

function get_eligible_teams(player)
  local limit = script_data.config.team_config.max_players
  local teams = {}
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    if force then
      if limit <= 0 or #force.connected_players < limit or player.admin then
        table.insert(teams, team)
      end
    end
  end
  if #teams == 0 then
    spectator_join(player)
    player.print({"no-space-available"})
    return
  end
  return teams
end


function destroy_config_for_all()

  for name, frames in pairs (script_data.elements) do
    for k, frame in pairs (frames) do
      if (frame and frame.valid) then
        deregister_gui(frame)
        frame.destroy()
      end
    end
    script_data.elements[name] = {}
  end
  script_data.ready_players = {}
end

function set_evolution_factor()
  local n = script_data.config.team_config.evolution_factor
  if n >= 1 then
    n = 1
  end
  if n <= 0 then
    n = 0
  end
  for k, force in pairs (game.forces) do
    force.evolution_factor = n
  end
  script_data.config.team_config.evolution_factor = n
end

function set_difficulty()
  game.difficulty_settings.technology_price_multiplier = script_data.config.team_config.technology_price_multiplier or 1
end

function spectator_join(player)
  if player.character then player.character.destroy() end
  player.set_controller{type = defines.controllers.spectator}
  player.force = "spectator"
  player.teleport(script_data.spawn_offset, script_data.surface)
  player.tag = ""
  player.chat_color = {r = 1, g = 1, b = 1, a = 1}
  player.spectator = true
  init_player_gui(player)
  game.print({"joined-spectator", player.name})
end

function update_team_list_frame(player)
  if not (player and player.valid) then return end
  local frame = script_data.elements.team_frame[player.index]
  if not (frame and frame.valid) then return end
  frame.clear()
  local inner = frame.add{type = "frame", style = "image_frame"}
  inner.style.left_padding = 8
  inner.style.right_padding = 8
  inner.style.top_padding = 8
  inner.style.bottom_padding = 8
  local scroll = inner.add{type = "scroll-pane"}
  scroll.style.maximal_height = player.display_resolution.height * 0.8
  local team_table = scroll.add{type = "table", column_count = 2}
  team_table.style.vertical_spacing = 8
  team_table.style.horizontal_spacing = 16
  team_table.draw_horizontal_lines = true
  team_table.draw_vertical_lines = true
  team_table.add{type = "label", caption = {"team-name"}, style = "bold_label"}
  team_table.add{type = "label", caption = {"players"}, style = "bold_label"}
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    if force then
      local label = team_table.add{type = "label", caption = team.name, style = "description_label"}
      label.style.font_color = get_color(team, true)
      add_player_list_gui(force, team_table)
    end
  end
end

function admin_button_press(event)
end

function admin_frame_button_press(event)
  local gui = event.element
  if not gui.valid then return end
  if not gui.parent then return end
  if not gui.parent.valid then return end
  if gui.parent.name ~= "admin_frame" then return end
  local player = game.players[event.player_index]
  if not player.admin then
    player.print({"only-admins"})
    init_player_gui(player)
    return
  end
end

function format_time(ticks)
  local hours = math.floor(ticks / (60 * 60 * 60))
  ticks = ticks - hours * (60 * 60 * 60)
  local minutes = math.floor(ticks / (60 * 60))
  ticks = ticks - minutes * (60 * 60)
  local seconds = math.floor(ticks / 60)
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, seconds)
  else
    return string.format("%d:%02d", minutes, seconds)
  end
end

function get_time_left()
  if not script_data.round_start_tick then return "Invalid" end
  if not script_data.config.game_config.time_limit then return "Invalid" end
  return format_time((math.max(script_data.round_start_tick + (script_data.config.game_config.time_limit * 60 * 60) - game.tick, 0)))
end

function update_production_score_frame(player)
  local frame = script_data.elements.production_score_inner_frame[player.index]
  if not (frame and frame.valid) then return end
  frame.clear()
  local information_table = frame.add{type = "table", column_count = 4}
  information_table.draw_horizontal_line_after_headers = true
  information_table.draw_vertical_lines = true
  information_table.style.horizontal_spacing = 16
  information_table.style.vertical_spacing = 8
  information_table.style.column_alignments[3] = "right"
  information_table.style.column_alignments[4] = "right"

  for k, caption in pairs ({"", "team-name", "score", "score_per_minute"}) do
    local label = information_table.add{type = "label", caption = {caption}, tooltip = {caption.."_tooltip"}}
    label.style.font = "default-bold"
  end
  local team_map = {}
  for k, team in pairs (script_data.config.teams) do
    team_map[team.name] = team
  end
  local average_score = script_data.average_score
  if not average_score then return end
  local rank = 1
  for name, score in spairs (script_data.production_scores, function(t, a, b) return t[b] < t[a] end) do
    if not average_score[name] then
      average_score = nil
      return
    end
    if team_map[name] then
      local position = information_table.add{type = "label", caption = "#"..rank}
      if name == player.force.name then
        position.style.font = "default-semibold"
        position.style.font_color = {r = 1, g = 1}
      end
      local label = information_table.add{type = "label", caption = name}
      label.style.font = "default-semibold"
      label.style.font_color = get_color(team_map[name], true)
      information_table.add{type = "label", caption = util.format_number(score)}
      local delta_score = (score - (average_score[name] / statistics_period)) * (60 / statistics_period) * 2
      local delta_label = information_table.add{type = "label", caption = util.format_number(math.floor(delta_score))}
      if delta_score < 0 then
        delta_label.style.font_color = {r = 1, g = 0.2, b = 0.2}
      end
      rank = rank + 1
    end
  end
end

function oil_harvest_button_press(event)
  local gui = event.element
  if not gui.valid then return end
  if gui.name ~= "oil_harvest_button" then return end
  local player = game.players[event.player_index]
  local flow = mod_gui.get_frame_flow(player)
  local frame = flow.oil_harvest_frame
  if frame then
    frame.destroy()
    return
  end
  frame = flow.add{type = "frame", name = "oil_harvest_frame", caption = {"oil_harvest"}, direction = "vertical"}
  frame.style.title_bottom_padding = 8
  
  if script_data.config.game_config.time_limit > 0 then
    table.insert(script_data.timers, frame.add{type = "label", caption = {"time_left", get_time_left()}})
  end

  if script_data.config.victory.required_oil > 0 then
    frame.add{type = "label", caption = {"", {"required_oil"}, {"colon"}, " ", util.format_number(script_data.config.victory.required_oil)}}
  end

  local inner_frame = frame.add{type = "frame", style = "image_frame", name = "oil_harvest_inner_frame", direction = "vertical"}
  inner_frame.style.left_padding = 8
  inner_frame.style.top_padding = 8
  inner_frame.style.right_padding = 8
  inner_frame.style.bottom_padding = 8
  update_oil_harvest_frame(player)
end

function update_oil_harvest_frame(player)
  local gui = mod_gui.get_frame_flow(player)
  local frame = gui.oil_harvest_frame
  if not frame then return end
  inner_frame = frame.oil_harvest_inner_frame
  if not inner_frame then return end
  inner_frame.clear()
  local information_table = inner_frame.add{type = "table", column_count = 3}
  information_table.draw_horizontal_line_after_headers = true
  information_table.draw_vertical_lines = true
  information_table.style.horizontal_spacing = 16
  information_table.style.vertical_spacing = 8
  information_table.style.column_alignments[3] = "right"

  for k, caption in pairs ({"", "team-name", "oil_harvest"}) do
    local label = information_table.add{type = "label", caption = {caption}}
    label.style.font = "default-bold"
  end
  local team_map = {}
  for k, team in pairs (script_data.config.teams) do
    team_map[team.name] = team
  end
  if not script_data.oil_harvest_scores then
    script_data.oil_harvest_scores = {}
  end
  local rank = 1
  for name, score in spairs (script_data.oil_harvest_scores, function(t, a, b) return t[b] < t[a] end) do
    if team_map[name] then
      local position = information_table.add{type = "label", caption = "#"..rank}
      if name == player.force.name then
        position.style.font = "default-semibold"
        position.style.font_color = {r = 1, g = 1}
      end
      local label = information_table.add{type = "label", caption = name}
      label.style.font = "default-semibold"
      label.style.font_color = get_color(team_map[name], true)
      information_table.add{type = "label", caption = util.format_number(math.floor(score))}
      rank = rank + 1
    end
  end
end

function space_race_button_press(event)
  local gui = event.element
  if not gui.valid then return end
  local player = game.players[event.player_index]
  local flow = mod_gui.get_frame_flow(player)
  local frame = flow.space_race_frame
  if frame then
    frame.destroy()
    return
  end
  frame = flow.add{type = "frame", name = "space_race_frame", caption = {"space_race"}, direction = "vertical"}
  frame.style.title_bottom_padding = 8
  if script_data.config.victory.required_satellites_sent > 0 then
    frame.add{type = "label", caption = {"", {"required_satellites_sent"}, {"colon"}, " ", util.format_number(script_data.config.victory.required_satellites_sent)}}
  end
  local inner_frame = frame.add{type = "frame", style = "image_frame", name = "space_race_inner_frame", direction = "vertical"}
  inner_frame.style.left_padding = 8
  inner_frame.style.top_padding = 8
  inner_frame.style.right_padding = 8
  inner_frame.style.bottom_padding = 8
  update_space_race_frame(player)
end

function update_space_race_frame(player)
  local gui = mod_gui.get_frame_flow(player)
  local frame = gui.space_race_frame
  if not frame then return end
  inner_frame = frame.space_race_inner_frame
  if not inner_frame then return end
  inner_frame.clear()
  local information_table = inner_frame.add{type = "table", column_count = 4}
  information_table.draw_horizontal_line_after_headers = true
  information_table.draw_vertical_lines = true
  information_table.style.horizontal_spacing = 16
  information_table.style.vertical_spacing = 8
  information_table.style.column_alignments[4] = "right"

  for k, caption in pairs ({"", "team-name", "rocket_parts", "satellites_sent"}) do
    local label = information_table.add{type = "label", caption = {caption}}
    label.style.font = "default-bold"
  end
  local colors = {}
  for k, team in pairs (script_data.config.teams) do
    colors[team.name] = get_color(team, true)
  end
  local rank = 1

  for name, score in spairs (script_data.space_race_scores, function(t, a, b) return t[b] < t[a] end) do
    local position = information_table.add{type = "label", caption = "#"..rank}
    if name == player.force.name then
      position.style.font = "default-semibold"
      position.style.font_color = {r = 1, g = 1}
    end
    local label = information_table.add{type = "label", caption = name}
    label.style.font = "default-semibold"
    label.style.font_color = colors[name]
    local progress = information_table.add{type = "progressbar", value = 1}
    progress.style.width = 0
    progress.style.horizontally_squashable = true
    progress.style.horizontally_stretchable = true
    progress.style.color = colors[name]
    local silo = script_data.silos[name]
    if silo and silo.valid then
      if silo.get_inventory(defines.inventory.rocket_silo_rocket) then
        progress.value = 1
      else
        progress.value = silo.rocket_parts / silo.prototype.rocket_parts_required
      end
    else
      progress.visible = false
    end
    information_table.add{type = "label", caption = util.format_number(score)}
    rank = rank + 1
  end
end

function give_inventory(player)
  if not script_data.config.inventory_list then return end
  if not script_data.config.inventory_list[script_data.config.team_config.starting_inventory.selected] then return end
  local list = script_data.config.inventory_list[script_data.config.team_config.starting_inventory.selected]
  util.insert_safe(player, list)
end

function setup_teams()

  local spectator = game.forces["spectator"]
  if not (spectator and spectator.valid) then
    spectator = game.create_force("spectator")
  end
  local names = {}
  for k, team in pairs (script_data.config.teams) do
    names[team.name] = true
  end

  for name, force in pairs (game.forces) do
    if not (is_ignored_force(name) or names[name]) then
      game.merge_forces(name, "player")
    end
  end

  for k, team in pairs (script_data.config.teams) do
    local new_team
    if game.forces[team.name] then
      new_team = game.forces[team.name]
    else
      new_team = game.create_force(team.name)
    end
    new_team.reset()
    new_team.set_spawn_position(script_data.spawn_positions[k], script_data.surface)
    set_random_team(team)
  end
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    force.set_friend(spectator, true)
    spectator.set_friend(force, true)
    set_diplomacy(team)
    setup_research(force)
    balance.disable_combat_technologies(force)
    force.reset_technology_effects()
    balance.apply_combat_modifiers(force)
  end
  disable_items_for_all()
end

function disable_items_for_all()
  if not script_data.config.disabled_items then return end
  local items = game.item_prototypes
  local recipes = game.recipe_prototypes
  local product_map = {}
  for k, recipe in pairs (recipes) do
    for k, product in pairs (recipe.products) do
      if not product_map[product.name] then
        product_map[product.name] = {}
      end
      table.insert(product_map[product.name], recipe)
    end
  end

  local recipes_to_disable = {}
  for name, k in pairs (script_data.config.disabled_items) do
    local mapping = product_map[name]
    if mapping then
      for k, recipe in pairs (mapping) do
        recipes_to_disable[recipe.name] = true
      end
    end
  end
  for k, force in pairs (game.forces) do
    for name, bool in pairs (recipes_to_disable) do
      force.recipes[name].enabled = false
    end
  end
end

function check_technology_for_disabled_items(event)
  if not script_data.config.disabled_items then return end
  local disabled_items = script_data.config.disabled_items
  local technology = event.research
  local recipes = technology.force.recipes
  for k, effect in pairs (technology.effects) do
    if effect.type == "unlock-recipe" then
      for k, product in pairs (recipes[effect.recipe].products) do
        if disabled_items[product.name] then
          recipes[effect.recipe].enabled = false
        end
      end
    end
  end
end

function set_random_team(team)
  if tonumber(team.team) then return end
  if team.team == "-" then return end
  team.team = "?"..math.random(#script_data.config.teams)
end

function set_diplomacy(team)
  local force = game.forces[team.name]
  if not force or not force.valid then return end
  local team_number
  if tonumber(team.team) then
    team_number = team.team
  elseif team.team:find("?") then
    team_number = team.team:gsub("?", "")
    team_number = tonumber(team_number)
  else
    team_number = "Don't match me"
  end
  for k, other_team in pairs (script_data.config.teams) do
    if game.forces[other_team.name] then
      local other_number
      if tonumber(other_team.team) then
        other_number = other_team.team
      elseif other_team.team:find("?") then
        other_number = other_team.team:gsub("?", "")
        other_number = tonumber(other_number)
      else
        other_number = "Okay i won't match"
      end
      if other_number == team_number then
        force.set_cease_fire(other_team.name, true)
        force.set_friend(other_team.name, true)
      else
        force.set_cease_fire(other_team.name, false)
        force.set_friend(other_team.name, false)
      end
    end
  end
end

function set_team_together_spawns(surface)
  local grouping = {}
  for k, team in pairs (script_data.config.teams) do
    local team_number
    if tonumber(team.team) then
      team_number = team.team
    elseif team.team:find("?") then
      team_number = team.team:gsub("?", "")
      team_number = tonumber(team_number)
    else
      team_number = "-"
    end
    if tonumber(team_number) then
      if not grouping[team_number] then
        grouping[team_number] = {}
      end
      table.insert(grouping[team_number], team.name)
    else
      if not grouping.no_group then
        grouping.no_group = {}
      end
      table.insert(grouping.no_group, team.name)
    end
  end
  local count = 1
  for k, group in pairs (grouping) do
    for j, team_name in pairs (group) do
      local force = game.forces[team_name]
      if force then
        local position = script_data.spawn_positions[count]
        if position then
          force.set_spawn_position(position, surface)
          count = count + 1
        end
      end
    end
  end
end

function chart_starting_area_for_force_spawns()
  --Delay by 1 tick so the GUI can update
  script_data.chart_chunks = 1 + game.tick + (#script_data.config.teams)
  script_data.progress = 0
  update_progress_bar()
end

function check_starting_area_chunks_are_generated()
  if not script_data.chart_chunks then return end
  local index = script_data.chart_chunks - game.tick
  local surface = script_data.surface
  if index == 0 then
    script_data.progress = 0.99
    script_data.chart_chunks = nil
    script_data.finish_setup = game.tick + (#script_data.config.teams)
    update_progress_bar()
    return
  end
  local team = script_data.config.teams[index]
  if not team then return end
  local name = team.name
  local force = game.forces[name]
  if not force then return end
  script_data.progress = (#script_data.config.teams - index) / #script_data.config.teams
  update_progress_bar()
  local surface = script_data.surface
  local radius = get_starting_area_radius()
  local size = radius * 32
  local origin = force.get_spawn_position(surface)
  local area = {{origin.x - size, origin.y - size},{origin.x + (size - 32), origin.y + (size - 32)}}
  surface.request_to_generate_chunks(origin, radius)
  force.chart(surface, area)
  surface.force_generate_chunk_requests()
end

function check_player_color()
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    if force then
      local color = get_color(team)
      for k, player in pairs (force.connected_players) do
        local player_color = player.color
        for c, v in pairs (color) do
          if math.abs(player_color[c] - v) > 0.1 then
            game.print({"player-color-changed-back", player.name})
            player.color = color
            player.chat_color = get_color(team, true)
            break
          end
        end
      end
    end
  end
end

function check_no_rush()
  if not script_data.end_no_rush then return end
  if game.tick > script_data.end_no_rush then
    if script_data.config.game_config.no_rush_time > 0 then
      game.print({"no-rush-ends"})
    end
    script_data.end_no_rush = nil
    script_data.surface.peaceful_mode = script_data.peaceful_mode
    game.forces.enemy.kill_all_units()
    return
  end
end

function check_player_no_rush(player)
  if not script_data.end_no_rush then return end
  local force = player.force
  if not is_ignored_force(force.name) then
    local origin = force.get_spawn_position(player.surface)
    local Xo = origin.x
    local Yo = origin.y
    local position = player.position
    local radius = get_starting_area_radius(true)
    local Xp = position.x
    local Yp = position.y
    if Xp > (Xo + radius) then
      Xp = Xo + radius
    elseif Xp < (Xo - radius) then
      Xp = Xo - radius
    end
    if Yp > (Yo + radius) then
      Yp = Yo + radius
    elseif Yp < (Yo - radius) then
      Yp = Yo - radius
    end
    if position.x ~= Xp or position.y ~= Yp then
      local new_position = {x = Xp, y = Yp}
      local vehicle = player.vehicle
      if vehicle then
        if not vehicle.teleport(new_position) then
          player.driving = false
        end
        vehicle.orientation = vehicle.orientation + 0.5
      else
        player.teleport(new_position)
      end
      local time_left = math.ceil((script_data.end_no_rush-game.tick) / 3600)
      player.print({"no-rush-teleport", time_left})
    end
  end
end

function check_update_production_score()
  if not script_data.config.victory.production_score then return end
  local tick = game.tick
  if script_data.team_won then return end
  local new_scores = production_score.get_production_scores(script_data.price_list)
  local scale = statistics_period / 60
  local index = tick % (60 * statistics_period)

  if not (script_data.scores and script_data.average_score) then
    local average_score = {}
    local scores = {}
    for name, score in pairs (new_scores) do
      scores[name] = {}
      average_score[name] = score * statistics_period
      for k = 0, statistics_period do
        scores[name][k * 60] = score
      end
    end
    script_data.scores = scores
    script_data.average_score = average_score
  end

  local scores = script_data.scores
  local average_score = script_data.average_score
  for name, score in pairs (new_scores) do
    local old_amount = scores[name][index]
    if not old_amount then
      --Something went wrong, reinitialize it next update
      script_data.scores = nil
      script_data.average_score = nil
      return
    end
    average_score[name] = (average_score[name] + score) - old_amount
    scores[name][index] = score
  end

  script_data.production_scores = new_scores

  for k, player in pairs (game.connected_players) do
    update_production_score_frame(player)
  end
  local required = script_data.config.victory.required_production_score
  if required > 0 then
    for team_name, score in pairs (script_data.production_scores) do
      if score >= required then
        team_won(team_name)
      end
    end
  end
  if script_data.config.game_config.time_limit > 0 and tick > script_data.round_start_tick + (script_data.config.game_config.time_limit * 60 * 60) then
    local winner = {"none"}
    local winning_score = 0
    for team_name, score in pairs (script_data.production_scores) do
      if score > winning_score then
        winner = team_name
        winning_score = score
      end
    end
    team_won(winner)
  end
end

function check_update_oil_harvest_score()
  if script_data.team_won then return end
  if not script_data.config.victory.oil_harvest then return end
  local fluid_to_check = script_data.config.prototypes.oil or ""
  if not game.fluid_prototypes[fluid_to_check] then
    log("Disabling oil harvest check as "..fluid_to_check.." is not a valid fluid")
    script_data.config.victory.oil_harvest = false
    return
  end
  local scores = {}
  for force_name, force in pairs (game.forces) do
    local statistics = force.fluid_production_statistics
    local input = statistics.get_input_count(fluid_to_check)
    local output = statistics.get_output_count(fluid_to_check)
    scores[force_name] = input - output
  end
  script_data.oil_harvest_scores = scores
  for k, player in pairs (game.connected_players) do
    update_oil_harvest_frame(player)
  end
  local required = script_data.config.victory.required_oil
  if required > 0 then
    for team_name, score in pairs (script_data.oil_harvest_scores) do
      if score >= required then
        team_won(team_name)
      end
    end
  end
  if script_data.config.game_config.time_limit > 0 and game.tick > (script_data.round_start_tick + (script_data.config.game_config.time_limit * 60 * 60)) then
    local winner = {"none"}
    local winning_score = 0
    for team_name, score in pairs (script_data.oil_harvest_scores) do
      if score > winning_score then
        winner = team_name
        winning_score = score
      end
    end
    team_won(winner)
  end
end

function check_update_space_race_score()
  if script_data.team_won then return end
  if not script_data.config.victory.space_race then return end
  local item_to_check = script_data.config.prototypes.satellite or ""
  if not game.item_prototypes[item_to_check] then
    log("Disabling space race as "..item_to_check.." is not a valiud item")
    script_data.config.victory.space_race = false
    return
  end
  local scores = {}
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    if force then
      scores[team.name] = force.get_item_launched(item_to_check)
    end
  end
  script_data.space_race_scores = scores
  for k, player in pairs (game.connected_players) do
    update_space_race_frame(player)
  end
  local required = script_data.config.victory.required_satellites_sent
  if required > 0 then
    for team_name, score in pairs (script_data.space_race_scores) do
      if score >= required then
        team_won(team_name)
      end
    end
  end
end

function finish_setup()
  if not script_data.finish_setup then return end
  local index = script_data.finish_setup - game.tick
  local surface = script_data.surface
  if index == 0 then
    final_setup_step()
    return
  end
  local name = script_data.config.teams[index].name
  if not name then return end
  local force = game.forces[name]
  if not force then return end
  create_silo_for_force(force)
  local radius = get_starting_area_radius(true) --[[radius in tiles]]
  if script_data.config.game_config.reveal_team_positions then
    for name, other_force in pairs (game.forces) do
      if not is_ignored_force(name) then
        force.chart(surface, get_force_area(other_force))
      end
    end
  end
  create_wall_for_force(force)
  create_starting_chest(force)
  create_starting_turrets(force)
  create_starting_artillery(force)
  protect_force_area(force)
  force.friendly_fire = script_data.config.team_config.friendly_fire
  force.share_chart = true
end

function final_setup_step()
  script_data.progress = 1
  update_progress_bar()
  script_data.progress = nil
  local surface = script_data.surface
  duplicate_starting_area_entities()
  script_data.finish_setup = nil
  game.print({"map-ready"})
  script_data.setup_finished = true
  script_data.round_start_tick = game.tick
  for k, player in pairs (game.connected_players) do
    destroy_player_gui(player)
    player.teleport({0, 1000}, "Lobby")
    local team = script_data.team_players[player.index]
    if team then
      set_player(player, team, true)
    else
      choose_joining_gui(player)
    end
  end
  if script_data.config.game_config.no_rush_time then
    script_data.end_no_rush = game.tick + (script_data.config.game_config.no_rush_time * 60 * 60)
    if script_data.config.game_config.no_rush_time > 0 then
      script_data.peaceful_mode = script_data.surface.peaceful_mode
      script_data.surface.peaceful_mode = true
      game.forces.enemy.kill_all_units()
      game.print({"no-rush-begins", script_data.config.game_config.no_rush_time})
    end
  end
  if script_data.config.game_config.base_exclusion_time then
    if script_data.config.game_config.base_exclusion_time > 0 then
      script_data.check_base_exclusion = true
      game.print({"base-exclusion-begins", script_data.config.game_config.base_exclusion_time})
    end
  end
  create_exclusion_map()
  if script_data.config.game_config.reveal_map_center then
    local radius = script_data.config.team_config.average_team_displacement / 2
    local origin = script_data.spawn_offset
    local area = {{origin.x - radius, origin.y - radius}, {origin.x + (radius - 32), origin.y + (radius - 32)}}
    for k, force in pairs (game.forces) do
      force.chart(surface, area)
    end
  end
  script_data.space_race_scores = {}
  script_data.oil_harvest_scores = {}
  script_data.production_scores = {}
  if script_data.config.victory.production_score then
    script_data.price_list = script_data.price_list or production_score.generate_price_list()
  end
  if script_data.config.team_config.defcon_mode then
    defcon_research()
  end

  script.raise_event(events.on_round_start, {})
end

function check_force_protection(force)
  if not script_data.config.game_config.protect_empty_teams then return end
  if not (force and force.valid) then return end
  if is_ignored_force(force.name) then return end
  if not script_data.protected_teams then script_data.protected_teams = {} end
  local protected = script_data.protected_teams[force.name] ~= nil
  local should_protect = #force.connected_players == 0
  if protected and should_protect then return end
  if (not protected) and (not should_protect) then return end
  if protected and (not should_protect) then
    unprotect_force_area(force)
    return
  end
  if (not protected) and should_protect then
    protect_force_area(force)
    check_base_exclusion()
    return
  end
end

function protect_force_area(force)
  if not script_data.config.game_config.protect_empty_teams then return end
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  local non_destructible = {}
  for k, entity in pairs (surface.find_entities_filtered{force = force, area = get_force_area(force)}) do
    if entity.destructible == false and entity.unit_number then
      non_destructible[entity.unit_number] = true
    end
    entity.destructible = false
  end
  if not script_data.protected_teams then
    script_data.protected_teams = {}
  end
  script_data.protected_teams[force.name] = non_destructible
end

function unprotect_force_area(force)
  if not script_data.config.game_config.protect_empty_teams then return end
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  if not script_data.protected_teams then
    script_data.protected_teams = {}
  end
  local entities = script_data.protected_teams[force.name] or {}
  for k, entity in pairs (surface.find_entities_filtered{force = force, area = get_force_area(force)}) do
    if (not entity.unit_number) or (not entities[entity.unit_number]) then
      entity.destructible = true
    end
  end
  script_data.protected_teams[force.name] = nil
end

function get_force_area(force)
  if not (force and force.valid) then return end
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  local radius = get_starting_area_radius(true)
  local origin = force.get_spawn_position(surface)
  return {{origin.x - radius, origin.y - radius}, {origin.x + (radius - 1), origin.y + (radius - 1)}}
end

function update_progress_bar()
  if not script_data.progress then return end
  local percent = script_data.progress
  local finished = (percent >=1)
  function update_bar_gui(player)
    local frame = script_data.elements.progress_bar[player.index]
    if frame and frame.valid then
      script_data.elements.progress_bar[player.index] = nil
      frame.destroy()
    end
    if finished then return end
    local frame = player.gui.center.add{type = "frame", caption = {"progress-bar"}}
    script_data.elements.progress_bar[player.index] = frame
    frame.add{type = "progressbar", size = 100, value = percent}
  end
  for k, player in pairs (game.players) do
    update_bar_gui(player)
  end
  if finished then
    script_data.progress = nil
    script_data.setup_duration = nil
    script_data.finish_tick = nil
  end
end

function create_silo_for_force(force)
  if not script_data.config.victory.last_silo_standing then return end
  if not (force and force.valid) then return end
  local surface = script_data.surface
  local origin = force.get_spawn_position(surface)
  local offset = script_data.config.silo_offset
  local silo_position = {x = origin.x + (offset.x or offset[1]), y = origin.y + (offset.y or offset[2])}
  local silo_name = script_data.config.prototypes.silo
  if not game.entity_prototypes[silo_name] then log("Silo not created as "..silo_name.." is not a valid entity prototype") return end
  local silo = surface.create_entity{name = silo_name, position = silo_position, force = force, raise_built = true}

  --Event is sent, so some mod could kill the silo
  if not (silo and silo.valid) then return end

  silo.minable = false
  if silo.supports_backer_name() then
    silo.backer_name = force.name
  end
  if not script_data.silos then script_data.silos = {} end
  script_data.silos[force.name] = silo

  local tile_name = script_data.config.prototypes.tile_2
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end

  local tiles_2 = {}
  local box = silo.bounding_box
  local x1, x2, y1, y2 =
    math.floor(box.left_top.x) - 1,
    math.floor(box.right_bottom.x) + 1,
    math.floor(box.left_top.y) - 1,
    math.floor(box.right_bottom.y) + 1
  for X = x1, x2 do
    for Y = y1, y2 do
      table.insert(tiles_2, {name = tile_name, position = {X, Y}})
    end
  end

  for i, entity in pairs(surface.find_entities_filtered({area = {{x1 - 1, y1 - 1},{x2 + 1, y2 + 1}}, force = "neutral"})) do
    entity.destroy()
  end

  set_tiles_safe(surface, tiles_2)
end

function setup_research(force)
  if not script_data.config.team_config.research_level then return end
  if not (force and force.valid) then return end
  local tier = script_data.config.team_config.research_level.selected
  local index
  local set = (tier ~= "none")
  for k, name in pairs (script_data.config.team_config.research_level.options) do
    if script_data.config.research_ingredient_list[name] ~= nil then
      script_data.config.research_ingredient_list[name] = set
    end
    if name == tier then set = false end
  end
  --[[Unlocks all research, and then unenables them based on a blacklist]]
  force.research_all_technologies()
  for k, technology in pairs (force.technologies) do
    for j, ingredient in pairs (technology.research_unit_ingredients) do
      if not script_data.config.research_ingredient_list[ingredient.name] then
        technology.researched = false
        break
      end
    end
  end
end

function create_starting_turrets(force)
  if not script_data.config.game_config.team_turrets then return end
  if not (force and force.valid) then return end
  local turret_name = script_data.config.prototypes.turret
  if not game.entity_prototypes[turret_name] then return end

  local ammo_name
  if script_data.config.game_config.turret_ammunition then
    ammo_name = script_data.config.game_config.turret_ammunition.selected
  end
  
  local surface = script_data.surface
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local origin = force.get_spawn_position(surface)
  local radius = get_starting_area_radius(true) - 18 --[[radius in tiles]]
  local limit = math.min(width - math.abs(origin.x), height - math.abs(origin.y)) - 6
  radius = math.min(radius, limit)
  local positions = {}
  local Xo = origin.x
  local Yo = origin.y
  for X = -radius, radius do
    local Xt = X + Xo
    if X == -radius then
      for Y = -radius, radius do
        local Yt = Y + Yo
        if (Yt + 16) % 32 ~= 0 and Yt % 8 == 0 then
          table.insert(positions, {x = Xo - radius, y = Yt, direction = defines.direction.west})
          table.insert(positions, {x = Xo + radius, y = Yt, direction = defines.direction.east})
        end
      end
    elseif (Xt + 16) % 32 ~= 0 and Xt % 8 == 0 then
      table.insert(positions, {x = Xt, y = Yo - radius, direction = defines.direction.north})
      table.insert(positions, {x = Xt, y = Yo + radius, direction = defines.direction.south})
    end
  end
  local tiles = {}
  local tile_name = script_data.config.prototypes.tile_2
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  local stack
  if ammo_name and game.item_prototypes[ammo_name] then
    stack = {name = ammo_name, count = 20}
  end
  local floor = math.floor
  for k, position in pairs (positions) do
    local turret = surface.create_entity{name = turret_name, position = position, force = force, direction = position.direction}
    local box = turret.bounding_box
    for k, entity in pairs (surface.find_entities_filtered{area = turret.bounding_box, force = "neutral"}) do
      entity.destroy({do_cliff_correction = true})
    end
    if stack then
      turret.insert(stack)
    end
    for x = floor(box.left_top.x), floor(box.right_bottom.x) do
      for y = floor(box.left_top.y), floor(box.right_bottom.y) do
        table.insert(tiles, {name = tile_name, position = {x, y}})
      end
    end
  end
  set_tiles_safe(surface, tiles)
end

function create_starting_artillery(force)
  if not script_data.config.game_config.team_artillery then return end
  if not (force and force.valid) then return end
  local turret_name = script_data.config.prototypes.artillery
  if not (turret_name and game.entity_prototypes[turret_name]) then return end
  local ammo_name = script_data.config.prototypes.artillery_ammo
  if not (ammo_name and game.item_prototypes[ammo_name]) then return end
  local surface = script_data.surface
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local origin = force.get_spawn_position(surface)
  local radius = get_starting_area_radius() - 1 --[[radius in chunks]]
  if radius < 1 then return end
  local positions = {}
  local tile_positions = {}
  for x = -radius, 0 do
    if x == -radius then
      for y = -radius, 0 do
        table.insert(positions, {x = 1 + origin.x + 32*x, y = 1 + origin.y + 32*y})
      end
    else
      table.insert(positions, {x = 1 + origin.x + 32*x, y = 1 + origin.y - radius*32})
    end
  end
  for x = 1, radius do
    if x == radius then
      for y = -radius, -1 do
        table.insert(positions, {x = -2 + origin.x + 32*x, y = 1 + origin.y + 32*y})
      end
    else
      table.insert(positions, {x = -2 + origin.x + 32*x, y = 1 + origin.y - radius*32})
    end
  end
  for x = -radius, -1 do
    if x == -radius then
      for y = 1, radius do
        table.insert(positions, {x = 1 + origin.x + 32*x, y = -2 + origin.y + 32*y})
      end
    else
      table.insert(positions, {x = 1 + origin.x + 32*x, y = -2 + origin.y + radius*32})
    end
  end
  for x = 0, radius do
    if x == radius then
      for y = 0, radius do
        table.insert(positions, {x = -2 + origin.x + 32*x, y = -2 + origin.y + 32*y})
      end
    else
      table.insert(positions, {x = -2 + origin.x + 32*x, y = -2 + origin.y + radius*32})
    end
  end
  local stack = {name = ammo_name, count = 20}
  local tiles = {}
  local tile_name = script_data.config.prototypes.tile_2
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  local floor = math.floor
  for k, position in pairs (positions) do
    local turret = surface.create_entity{name = turret_name, position = position, force = force, direction = position.direction}
    local box = turret.bounding_box
    for k, entity in pairs (surface.find_entities_filtered{area = turret.bounding_box, force = "neutral"}) do
      entity.destroy({do_cliff_correction = true})
    end
    turret.insert(stack)
    for x = floor(box.left_top.x), floor(box.right_bottom.x) do
      for y = floor(box.left_top.y), floor(box.right_bottom.y) do
        table.insert(tiles, {name = tile_name, position = {x, y}})
      end
    end
  end
  set_tiles_safe(surface, tiles)
end

function create_wall_for_force(force)
  if not script_data.config.game_config.team_walls then return end
  if not force.valid then return end
  local surface = script_data.surface
  local height = surface.map_gen_settings.height / 2
  local width = surface.map_gen_settings.width / 2
  local origin = force.get_spawn_position(surface)
  local radius = get_starting_area_radius(true) - 11 --[[radius in tiles]]
  local limit = math.min(width - math.abs(origin.x), height - math.abs(origin.y)) - 1
  radius = math.min(radius, limit)
  if radius < 2 then return end
  local perimeter_top = {}
  local perimeter_bottom = {}
  local perimeter_left = {}
  local perimeter_right = {}
  local tiles = {}
  local insert = table.insert
  for X = -radius, radius - 1 do
    insert(perimeter_top, {x = origin.x + X, y = origin.y - radius})
    insert(perimeter_bottom, {x = origin.x + X, y = origin.y + (radius-1)})
  end
  for Y = -radius, radius - 1 do
    insert(perimeter_left, {x = origin.x - radius, y = origin.y + Y})
    insert(perimeter_right, {x = origin.x + (radius-1), y = origin.y + Y})
  end
  local tile_name = script_data.config.prototypes.tile_1
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  local areas = {
    {{perimeter_top[1].x, perimeter_top[1].y - 1}, {perimeter_top[#perimeter_top].x, perimeter_top[1].y + 3}},
    {{perimeter_bottom[1].x, perimeter_bottom[1].y - 3}, {perimeter_bottom[#perimeter_bottom].x, perimeter_bottom[1].y + 1}},
    {{perimeter_left[1].x - 1, perimeter_left[1].y}, {perimeter_left[1].x + 3, perimeter_left[#perimeter_left].y}},
    {{perimeter_right[1].x - 3, perimeter_right[1].y}, {perimeter_right[1].x + 1, perimeter_right[#perimeter_right].y}},
  }
  for k, area in pairs (areas) do
    for i, entity in pairs(surface.find_entities_filtered({area = area})) do
      entity.destroy({do_cliff_correction = true})
    end
  end
  local wall_name = script_data.config.prototypes.wall
  local gate_name = script_data.config.prototypes.gate
  if not game.entity_prototypes[wall_name] then
    log("Setting walls cancelled as "..wall_name.." is not a valid entity prototype")
    return
  end
  if not game.entity_prototypes[gate_name] then
    log("Setting walls cancelled as "..gate_name.." is not a valid entity prototype")
    return
  end
  local should_gate = {
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true
  }
  for k, position in pairs (perimeter_left) do
    if (k ~= 1) and (k ~= #perimeter_left) then
      insert(tiles, {name = tile_name, position = {position.x + 2, position.y}})
      insert(tiles, {name = tile_name, position = {position.x + 1, position.y}})
    end
    if should_gate[position.y % 32] then
      surface.create_entity{name = gate_name, position = position, direction = 0, force = force}
    else
      surface.create_entity{name = wall_name, position = position, force = force}
    end
  end
  for k, position in pairs (perimeter_right) do
    if (k ~= 1) and (k ~= #perimeter_right) then
      insert(tiles, {name = tile_name, position = {position.x - 2, position.y}})
      insert(tiles, {name = tile_name, position = {position.x - 1, position.y}})
    end
    if should_gate[position.y % 32] then
      surface.create_entity{name = gate_name, position = position, direction = 0, force = force}
    else
      surface.create_entity{name = wall_name, position = position, force = force}
    end
  end
  for k, position in pairs (perimeter_top) do
    if (k ~= 1) and (k ~= #perimeter_top) then
      insert(tiles, {name = tile_name, position = {position.x, position.y + 2}})
      insert(tiles, {name = tile_name, position = {position.x, position.y + 1}})
    end
    if should_gate[position.x % 32] then
      surface.create_entity{name = gate_name, position = position, direction = 2, force = force}
    else
      surface.create_entity{name = wall_name, position = position, force = force}
    end
  end
  for k, position in pairs (perimeter_bottom) do
    if (k ~= 1) and (k ~= #perimeter_bottom) then
      insert(tiles, {name = tile_name, position = {position.x, position.y - 2}})
      insert(tiles, {name = tile_name, position = {position.x, position.y - 1}})
    end
    if should_gate[position.x % 32] then
      surface.create_entity{name = gate_name, position = position, direction = 2, force = force}
    else
      surface.create_entity{name = wall_name, position = position, force = force}
    end
  end
  set_tiles_safe(surface, tiles)
end

function spairs(t, order)
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  if order then
    table.sort(keys, function(a, b) return order(t, a, b) end)
  else
    table.sort(keys)
  end
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

button_press_functions =
{
  admin_button = admin_button_press,
  oil_harvest_button = oil_harvest_button_press,
  space_race_button = space_race_button_press,
  production_score_button = production_score_button_press,
}

function duplicate_starting_area_entities()
  if not script_data.config.team_config.duplicate_starting_area_entities then return end
  local copy_team = script_data.config.teams[1]
  if not copy_team then return end
  local force = game.forces[copy_team.name]
  if not force then return end
  local surface = script_data.surface
  local origin_spawn = force.get_spawn_position(surface)
  local radius = get_starting_area_radius(true) --[[radius in tiles]]
  local area = {{origin_spawn.x - radius, origin_spawn.y - radius}, {origin_spawn.x + radius, origin_spawn.y + radius}}
  local entities = surface.find_entities_filtered{area = area, force = "neutral"}
  local insert = table.insert
  local tiles = {}
  local counts = {}
  local ignore_counts = {
    ["refined-concrete"] = true,
    ["water"] = true,
    ["deepwater"] = true,
    ["refined-hazard-concrete-left"] = true
  }
  local tile_map = {}
  for name, tile in pairs (game.tile_prototypes) do
    tile_map[name] = tile.collision_mask["resource-layer"] ~= nil
    counts[name] = surface.count_tiles_filtered{name = name, area = area}
  end
  local tile_name = get_walkable_tile()
  local top_count = 0
  for name, count in pairs (counts) do
    if not ignore_counts[name] then
      if count > top_count then
        top_count = count
        tile_name = name
      end
    end
  end

  for name, bool in pairs (tile_map) do
    if bool and counts[name] > 0 then
      for k, tile in pairs (surface.find_tiles_filtered{area = area, name = name}) do
        insert(tiles, tile)
      end
    end
  end

  for k, team in pairs (script_data.config.teams) do
    if team.name ~= copy_team.name then
      local force = game.forces[team.name]
      if force then
        local spawn = force.get_spawn_position(surface)
        local area = {{spawn.x - radius, spawn.y - radius}, {spawn.x + radius, spawn.y + radius}}
        for k, entity in pairs (surface.find_entities_filtered{area = area, force = "neutral"}) do
          entity.destroy()
        end
        local set_tiles = {}
        for name, bool in pairs (tile_map) do
          if bool then
            for k, tile in pairs (surface.find_tiles_filtered{area = area, name = name}) do
              insert(set_tiles, {name = tile_name, position = {x = tile.position.x, y = tile.position.y}})
            end
          end
        end
        for k, tile in pairs (tiles) do
          local position = {x = (tile.position.x - origin_spawn.x) + spawn.x, y = (tile.position.y - origin_spawn.y) + spawn.y}
          insert(set_tiles, {name = tile.name, position = position})
        end
        surface.set_tiles(set_tiles)
        for k, entity in pairs (entities) do
          if entity.valid then
            local position = {x = (entity.position.x - origin_spawn.x) + spawn.x, y = (entity.position.y - origin_spawn.y) + spawn.y}
            local type = entity.type
            local amount = (type == "resource" and entity.amount) or nil
            local cliff_orientation = (type == "cliff" and entity.cliff_orientation) or nil
            surface.create_entity{name = entity.name, position = position, force = "neutral", amount = amount, cliff_orientation = cliff_orientation}
          end
        end
      end
    end
  end
end

function create_starting_chest(force)
  if not (force and force.valid) then return end
  local value = script_data.config.team_config.starting_chest.selected
  if value == "none" then return end
  local multiplier = script_data.config.team_config.starting_chest_multiplier
  if not (multiplier > 0) then return end
  local inventory = script_data.config.inventory_list[value]
  if not inventory then return end
  local surface = script_data.surface
  local chest_name = script_data.config.prototypes.chest
  local prototype = game.entity_prototypes[chest_name]
  if not prototype then
    log("Starting chest "..chest_name.." is not a valid entity prototype, picking a new container from prototype list")
    for name, chest in pairs (game.entity_prototypes) do
      if chest.type == "container" then
        chest_name = name
        prototype = chest
        break
      end
    end
  end
  local bounding_box = prototype.collision_box
  local size = math.ceil(math.max(bounding_box.right_bottom.x - bounding_box.left_top.x, bounding_box.right_bottom.y - bounding_box.left_top.y))
  local origin = force.get_spawn_position(surface)
  origin.y = origin.y + 8
  local index = 1
  local position = {x = origin.x + get_chest_offset(index).x * size, y = origin.y + get_chest_offset(index).y * size}
  local chest = surface.create_entity{name = chest_name, position = position, force = force}
  for k, v in pairs (surface.find_entities_filtered{force = "neutral", area = chest.bounding_box}) do
    v.destroy()
  end
  local tiles = {}
  local grass = {}
  local tile_name = script_data.config.prototypes.tile_1
  if not game.tile_prototypes[tile_name] then tile_name = get_walkable_tile() end
  table.insert(tiles, {name = tile_name, position = {x = position.x, y = position.y}})
  chest.destructible = false
  local items = game.item_prototypes
  for name, count in pairs (inventory) do
    if items[name] then
      local count_to_insert = math.ceil(count * multiplier)
      local difference = count_to_insert - chest.insert{name = name, count = count_to_insert}
      while difference > 0 do
        index = index + 1
        position = {x = origin.x + get_chest_offset(index).x * size, y = origin.y + get_chest_offset(index).y * size}
        chest = surface.create_entity{name = chest_name, position = position, force = force}
        for k, v in pairs (surface.find_entities_filtered{force = "neutral", area = chest.bounding_box}) do
          v.destroy()
        end
        table.insert(tiles, {name = tile_name, position = {x = position.x, y = position.y}})
        chest.destructible = false
        difference = difference - chest.insert{name = name, count = difference}
      end
    end
  end
  set_tiles_safe(surface, tiles)
end

function get_chest_offset(n)
  local offset_x = 0
  n = n / 2
  if n % 1 == 0.5 then
    offset_x = -1
    n = n + 0.5
  end
  local root = n ^ 0.5
  local nearest_root = math.floor(root + 0.5)
  local upper_root = math.ceil(root)
  local root_difference = math.abs(nearest_root ^ 2 - n)
  if nearest_root == upper_root then
    x = upper_root - root_difference
    y = nearest_root
  else
    x = upper_root
    y = root_difference
  end
  local orientation = 2 * math.pi * (45/360)
  x = x * (2^0.5)
  y = y * (2^0.5)
  local rotated_x = math.floor(0.5 + x * math.cos(orientation) - y * math.sin(orientation))
  local rotated_y = math.floor(0.5 + x * math.sin(orientation) + y * math.cos(orientation))
  return {x = rotated_x + offset_x, y = rotated_y}
end

function get_walkable_tile()
  for name, tile in pairs (game.tile_prototypes) do
    if tile.collision_mask["player-layer"] == nil and not tile.items_to_place_this then
      return name
    end
  end
  error("No walkable tile in prototype list")
end

function set_tiles_safe(surface, tiles)
  local grass = get_walkable_tile()
  local grass_tiles = {}
  for k, tile in pairs (tiles) do
    grass_tiles[k] = {position = {x = (tile.position.x or tile.position[1]), y = (tile.position.y or tile.position[2])}, name = grass}
  end
  surface.set_tiles(grass_tiles, false)
  surface.set_tiles(tiles)
end

function create_exclusion_map()
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  local exclusion_map = {}
  local radius = get_starting_area_radius() --[[radius in chunks]]
  for k, team in pairs (script_data.config.teams) do
    local name = team.name
    local force = game.forces[name]
    if force then
      local origin = force.get_spawn_position(surface)
      local Xo = math.floor(origin.x / 32)
      local Yo = math.floor(origin.y / 32)
      for X = -radius, radius - 1 do
        Xb = X + Xo
        if not exclusion_map[Xb] then exclusion_map[Xb] = {} end
        for Y = -radius, radius - 1 do
          local Yb = Y + Yo
          exclusion_map[Xb][Yb] = name
        end
      end
    end
  end
  script_data.exclusion_map = exclusion_map
end

function check_base_exclusion()
  if not (script_data.check_base_exclusion or script_data.protected_teams) then return end

  if script_data.check_base_exclusion and game.tick > (script_data.round_start_tick + (script_data.config.game_config.base_exclusion_time * 60 * 60)) then
    script_data.check_base_exclusion = nil
    game.print({"base-exclusion-ends"})
  end

end

function check_player_base_exclusion(player)
  if not (script_data.check_base_exclusion or script_data.protected_teams) then return end

  if not is_ignored_force(player.force.name) then
    check_player_exclusion(player, get_chunk_map_position(player.position))
  end
end

function get_chunk_map_position(position)
  local map = script_data.exclusion_map
  local chunk_x = math.floor(position.x / 32)
  local chunk_y = math.floor(position.y / 32)
  if map[chunk_x] then
    return map[chunk_x][chunk_y]
  end
end


local disallow =
{
  ["player"] = true,
  ["enemy"] = true,
  ["neutral"] = true,
  ["spectator"] = true
}

function is_ignored_force(name)
  return disallow[name]
end

function check_player_exclusion(player, force_name)
  if not force_name then return end
  local force = game.forces[force_name]
  if not (force and force.valid and player and player.valid) then return end
  if force == player.force or force.get_friend(player.force) then return end
  if not (script_data.check_base_exclusion or (script_data.protected_teams and script_data.protected_teams[force_name])) then return end
  local surface = script_data.surface
  local origin = force.get_spawn_position(surface)
  local radius = get_starting_area_radius(true) --[[radius in tiles]]
  local position = {x = player.position.x, y = player.position.y}
  local vector = {x = 0, y = 0}

  if position.x < origin.x then
    vector.x = (origin.x - radius) - position.x
  elseif position.x > origin.x then
    vector.x = (origin.x + radius) - position.x
  end

  if position.y < origin.y then
    vector.y = (origin.y - radius) - position.y
  elseif position.y > origin.y then
    vector.y = (origin.y + radius) - position.y
  end

  if math.abs(vector.x) < math.abs(vector.y) then
    vector.y = 0
  else
    vector.x = 0
  end

  local new_position = {x = position.x + vector.x, y = position.y + vector.y}
  local vehicle = player.vehicle
  if vehicle then
    if not vehicle.teleport(new_position) then
      player.driving = false
    end
    vehicle.orientation = vehicle.orientation + 0.5
  else
    player.teleport(new_position)
  end

  if script_data.check_base_exclusion then
    local time_left = math.ceil((script_data.round_start_tick + (script_data.config.game_config.base_exclusion_time * 60 * 60) - game.tick) / 3600)
    player.print({"base-exclusion-teleport", time_left})
  else
    player.print({"protected-base-area"})
  end

end

function set_button_style(button)
  if not button.valid then return end
  button.style.font = "default"
  button.style.top_padding = 0
  button.style.bottom_padding = 0
end

local should_start = function()
  if script_data.ready_start_tick and script_data.ready_start_tick <= game.tick then
    script_data.ready_start_tick = nil
    return true
  end

  if not script_data.team_won then return false end
  local time = script_data.config.game_config.auto_new_round_time
  if not (time > 0) then return false end
  if game.tick < (script_data.config.game_config.auto_new_round_time * 60 * 60) + script_data.team_won then return false end
  return true
end

function check_restart_round()
  if not should_start() then return end
  end_round()
  destroy_config_for_all()
  prepare_next_round()
end

function team_won(name)
  script_data.team_won = game.tick
  if script_data.config.game_config.auto_new_round_time > 0 then
    game.print({"team-won-auto", name, script_data.config.game_config.auto_new_round_time})
  else
    game.print({"team-won", name})
  end
  script.raise_event(events.on_team_won, {name = name})
end


function offset_respawn_position(player)
  --This is to help the spawn camping situations.
  if not (player and player.valid and player.character) then return end
  local surface = player.surface
  local origin = player.force.get_spawn_position(surface)
  local radius = get_starting_area_radius(true) - 32
  if not (radius > 0) then return end
  local random_position = {origin.x + math.random(-radius, radius), origin.y + math.random(-radius, radius)}
  local position = surface.find_non_colliding_position(player.character.name, random_position, 32, 1)
  if not position then return end
  player.teleport(position)
end

recursive_data_check = function(new_data, old_data)
  for k, data in pairs (new_data) do
    if not old_data[k] then
      old_data[k] = data
    elseif type(data) == "table" then
      recursive_data_check(new_data[k], old_data[k])
    end
  end
end

check_cursor_for_disabled_items = function(event)
  if not script_data.config.disabled_items then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local stack = player.cursor_stack
  if (stack and stack.valid_for_read) then
    if script_data.config.disabled_items[stack.name] then
      stack.clear()
    end
  end
end

function recipe_picker_elem_update(player)
  if not (player and player.valid) then return end
  local production_score_frame = script_data.elements.production_score_frame[player.index]
  if not (production_score_frame and production_score_frame.valid) then return end

  local recipe_frame = script_data.elements.recipe_frame[player.index]
  if recipe_frame and recipe_frame.valid then
    deregister_gui(recipe_frame)
    recipe_frame.destroy()
    script_data.elements.recipe_frame[player.index] = nil
  end

  local elem_value = script_data.selected_recipe[player.index]
  local elem_button = script_data.elements.recipe_button[player.index]
  if (elem_button and elem_button.valid) then
    elem_button.elem_value = elem_value
  end

  if not elem_value then return end
  
  local recipe = player.force.recipes[elem_value]
  local recipe_frame = production_score_frame.add{type = "frame", direction = "vertical", style = "image_frame"}
  script_data.elements.recipe_frame[player.index] = recipe_frame
  local title_flow = recipe_frame.add{type = "flow"}
  title_flow.style.align = "center"
  title_flow.style.horizontally_stretchable = true
  title_flow.add{type = "label", caption = recipe.localised_name, style = "frame_caption_label"}
  local table = recipe_frame.add{type = "table", column_count = 2}
  table.draw_horizontal_line_after_headers = true
  table.draw_vertical_lines = true
  table.style.horizontal_spacing = 16
  table.style.vertical_spacing = 2
  table.style.left_padding = 4
  table.style.right_padding = 4
  table.style.top_padding = 4
  table.style.bottom_padding = 4
  table.style.column_alignments[1] = "center"
  table.style.column_alignments[2] = "center"
  table.add{type = "label", caption = {"ingredients"}, style = "bold_label"}
  table.add{type = "label", caption = {"products"}, style = "bold_label"}
  local ingredients = recipe.ingredients
  local products = recipe.products
  local prices = script_data.price_list
  local cost = 0
  local gain = 0
  local prototypes = {
    fluid = game.fluid_prototypes,
    item = game.item_prototypes
  }
  for k = 1, math.max(#ingredients, #products) do
    local ingredient = ingredients[k]
    local flow = table.add{type = "flow", direction = "horizontal"}
    if k == 1 then
      flow.style.top_padding = 8
    end
    flow.style.vertical_align = "center"
    if ingredient then
      local ingredient_price = prices[ingredient.name] or 0
      local calculator_button = flow.add
      {
        type = "sprite-button",
        sprite = ingredient.type.."/"..ingredient.name,
        number = ingredient.amount,
        style = "slot_button",
        tooltip = {"", "1 ", prototypes[ingredient.type][ingredient.name].localised_name, " = ", util.format_number(math.floor(ingredient_price * 100) / 100)},
      }
      register_gui_action(calculator_button, {type = "calculator_button_press", elem_type = ingredient.type, elem_name = ingredient.name})
      local price = ingredient.amount * ingredient_price or 0
      add_pusher(flow)
      flow.add{type = "label", caption = util.format_number(math.floor(price * 100) / 100)}
      cost = cost + price
    end
    local product = products[k]
    flow = table.add{type = "flow", direction = "horizontal"}
    if k == 1 then
      flow.style.top_padding = 8
    end
    flow.style.vertical_align = "center"
    if product then
      local amount = product.amount or product.probability * (product.amount_max + product.amount_min) / 2 or 0
      local product_price = prices[product.name] or 0
      local calculator_button = flow.add
      {
        type = "sprite-button",
        sprite = product.type.."/"..product.name,
        number = amount,
        style = "slot_button",
        tooltip = {"", "1 ", prototypes[product.type][product.name].localised_name, " = ", util.format_number(math.floor(product_price * 100) / 100)},
        show_percent_for_small_numbers = true
      }
      register_gui_action(calculator_button, {type = "calculator_button_press", elem_type = product.type, elem_name = product.name})
      add_pusher(flow)
      local price = amount * product_price or 0
      flow.add{type = "label", caption = util.format_number(math.floor(price * 100) / 100)}
      gain = gain + price
    end
  end
  local line = table.add{type = "table", column_count = 1}
  line.draw_horizontal_lines = true
  add_pusher(line)
  add_pusher(line)
  line.style.top_padding = 8
  line.style.bottom_padding = 4
  local line = table.add{type = "table", column_count = 1}
  line.draw_horizontal_lines = true
  add_pusher(line)
  add_pusher(line)
  line.style.top_padding = 8
  line.style.bottom_padding = 4
  local cost_flow = table.add{type = "flow"}
  cost_flow.add{type = "label", caption = {"", {"cost"}, {"colon"}}}
  add_pusher(cost_flow)
  cost_flow.add{type = "label", caption = util.format_number(math.floor(cost * 100) / 100)}
  local gain_flow = table.add{type = "flow"}
  gain_flow.add{type = "label", caption = {"", {"gain"}, {"colon"}}}
  add_pusher(gain_flow)
  gain_flow.add{type = "label", caption = util.format_number(math.floor(gain * 100) / 100)}
  table.add{type = "flow"}
  local total_flow = table.add{type = "flow"}
  total_flow.add{type = "label", caption = {"", {"total"}, {"colon"}}, style = "bold_label"}
  add_pusher(total_flow)
  local total = total_flow.add{type = "label", caption = util.format_number(math.floor((gain-cost) * 100) / 100), style = "bold_label"}
  if cost > gain then
    total.style.font_color = {r = 1, g = 0.3, b = 0.3}
  end

end

function add_pusher(gui)
  local pusher = gui.add{type = "flow"}
  pusher.style.horizontally_stretchable = true
end

function check_on_built_protection(event)
  if not script_data.config.game_config.enemy_building_restriction then return end
  local entity = event.created_entity
  local player = game.players[event.player_index]
  if not (entity and entity.valid and player and player.valid) then return end
  local force = entity.force
  local name = get_chunk_map_position(entity.position)
  if not name then return end
  if force.name == name then return end
  local other_force = game.forces[name]
  if not other_force then return end
  if other_force.get_friend(force) then return end
  if not player.mine_entity(entity, true) then
    entity.destroy()
  end
  player.print({"enemy-building-restriction"})
end

function check_defcon()
  if not script_data.config.team_config.defcon_mode then return end
  local defcon_tick = script_data.last_defcon_tick
  if not defcon_tick then
    script_data.last_defcon_tick = game.tick
    return
  end
  local duration = math.max(60, (script_data.config.team_config.defcon_timer * 60 * 60))
  local tick_of_defcon = defcon_tick + duration
  local current_tick = game.tick
  local progress = math.max(0, math.min(1, 1 - (tick_of_defcon - current_tick) / duration))
  local tech = script_data.next_defcon_tech
  if tech and tech.valid then
    for k, team in pairs (script_data.config.teams) do
      local force = game.forces[team.name]
      if force then
        if force.current_research ~= tech.name then
          force.current_research = tech.name
        end
        force.research_progress = progress
      end
    end
  end
  if current_tick >= tick_of_defcon then
    defcon_research()
    script_data.last_defcon_tick = current_tick
  end
end

recursive_technology_prerequisite = function(tech)
  for name, prerequisite in pairs (tech.prerequisites) do
    if not prerequisite.researched then
      return recursive_technology_prerequisite(prerequisite)
    end
  end
  return tech
end

function defcon_research()

  local tech = script_data.next_defcon_tech
  if tech and tech.valid then
    for k, team in pairs (script_data.config.teams) do
      local force = game.forces[team.name]
      if force then
        local tech = force.technologies[tech.name]
        if tech then
          tech.researched = true
        end
      end
    end
    local sound = "utility/research_completed"
    if game.is_valid_sound_path(sound) then
      game.play_sound({path = sound})
    end
    game.print({"defcon-unlock", tech.localised_name}, {r = 1, g = 0.5, b = 0.5})
  end

  local force
  for k, team in pairs (script_data.config.teams) do
    force = game.forces[team.name]
    if force and force.valid then
      break
    end
  end
  if not force then return end
  local available_techs = {}
  for name, tech in pairs (force.technologies) do
    if tech.enabled and tech.researched == false then
      table.insert(available_techs, tech)
    end
  end
  if #available_techs == 0 then return end
  local random_tech = available_techs[math.random(#available_techs)]
  if not random_tech then return end
  random_tech = recursive_technology_prerequisite(random_tech)
  script_data.next_defcon_tech = game.technology_prototypes[random_tech.name]
  for k, team in pairs (script_data.config.teams) do
    local force = game.forces[team.name]
    if force then
      force.current_research = random_tech.name
    end
  end
end

function check_neutral_chests(event)
  if not script_data.config.game_config.neutral_chests then return end
  local entity = event.created_entity
  if not (entity and entity.valid) then return end
  if entity.type == "container" then
    entity.force = "neutral"
  end
end

function on_calculator_button_press(event, param)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  local type = param.elem_type
  local elem_name = param.elem_name
  local items = game.item_prototypes
  local fluids = game.fluid_prototypes
  local recipes = game.recipe_prototypes
  if type == "item" then
    if not items[elem_name] then return end
  elseif type == "fluid" then
    if not fluids[elem_name] then return end
  else
    return
  end
  local selected = script_data.selected_recipe[player.index]
  local candidates = {}
  for name, recipe in pairs (recipes) do
    for k, product in pairs (recipe.products) do
      if product.type == type and product.name == elem_name then
        table.insert(candidates, name)
      end
    end
  end
  if #candidates == 0 then return end
  local index = 0
  for k, name in pairs (candidates) do
    if name == selected then
      index = k
      break
    end
  end
  local recipe_name = candidates[index + 1] or candidates[1]
  if not recipe_name then return end
  script_data.selected_recipe[player.index] = recipe_name
  recipe_picker_elem_update(player)
end

function generic_gui_event(event)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local player_gui_actions = script_data.gui_actions[gui.player_index]
  if not player_gui_actions then return end
  local action = player_gui_actions[gui.index]
  if action then
    gui_functions[action.type](event, action)
    return true
  end
end

function update_timers()
  if true then return end
  for k, timer in (script_data.timers) do
    if timer.valid then
      timer.caption = {"time_left", get_time_left()}
    end
  end
end

local on_rocket_launched = function(event)
  production_score.on_rocket_launched(event)

  if not script_data.config.victory.space_race then return end

  local item = game.item_prototypes[script_data.config.prototypes.satellite or ""]
  if not item then log("Failed to check space race victory, invalid item: "..script_data.config.prototypes.satellite) return end

  local force = event.rocket.force
  if event.rocket.get_item_count(item.name) == 0 then
    force.print({"rocket-launched-without-satellite"})
    return
  end

  if not script_data.team_won then
    team_won(force.name)
  end
end

local on_entity_died = function(event)
  if not script_data.config.victory.last_silo_standing then return end
  local silo = event.entity
  if not (silo and silo.valid and silo.name == (script_data.config.prototypes.silo or "") ) then
    return
  end
  local killing_force = event.force
  local force = silo.force
  if not script_data.silos then return end
  script_data.silos[force.name] = nil
  if killing_force then
    game.print({"silo-destroyed", force.name, killing_force.name})
  else
    game.print({"silo-destroyed", force.name, {"neutral"}})
  end
  script.raise_event(events.on_team_lost, {name = force.name})
  for k, player in pairs (force.players) do
    player.force = "neutral"
    player.set_controller{type = defines.controllers.spectator}
  end
  game.merge_forces(force, "neutral")
  if not script_data.team_won then
    local index = 0
    local winner_name = {"none"}
    for name, listed_silo in pairs (script_data.silos) do
      if listed_silo ~= nil then
        index = index + 1
        winner_name = name
      end
    end
    if index == 1  then
      team_won(winner_name)
    end
  end
end

local on_player_joined_game = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  init_player_gui(player)
  if player.force.name ~= "player" then
    --If they are not on the player force, they have already picked a team this round.
    check_force_protection(player.force)
    for k, player in pairs (game.connected_players) do
      update_team_list_frame(player)
    end
    return
  end
  local character = player.character
  player.character = nil
  if character then character.destroy() end
  player.set_controller{type = defines.controllers.spectator}
  player.teleport({0, 1000}, game.surfaces.Lobby)
end

local on_gui_selection_state_changed = function(event)
  local gui = event.element
  local player = game.players[event.player_index]
  if generic_gui_event(event) then return end
end

local on_gui_text_changed = function(event)
  if generic_gui_event(event) then return end
end

local on_gui_checked_state_changed = function(event)
  if generic_gui_event(event) then return end
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
end

local on_player_left_game = function(event)
  for k, player in pairs (game.players) do
    local gui = player.gui.center
    if gui.pick_join_frame then
      choose_joining_gui(player)
      choose_joining_gui(player)
    end
    if player.connected then
      update_team_list_frame(player)
    end
  end
  if script_data.config.game_config.protect_empty_teams then
    local player = game.players[event.player_index]
    local force = player.force
    check_force_protection(force)
  end
end

local on_gui_elem_changed = function(event)
  if generic_gui_event(event) then return end
end

local on_gui_click = function(event)
  local gui = event.element
  local player = game.players[event.player_index]

  if not (player and player.valid and gui and gui.valid) then return end
  if generic_gui_event(event) then return end

  if gui.name then
    local button_function = button_press_functions[gui.name]
    if button_function then
      button_function(event)
      return
    end
  end
  admin_frame_button_press(event)
end

local on_gui_closed = function(event)
end

local on_tick = function(event)
  if script_data.setup_finished == false then
    check_starting_area_chunks_are_generated()
    finish_setup()
  end
end

local on_player_respawned = function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then return end
  if script_data.setup_finished == true then
    config.give_equipment(player)
    offset_respawn_position(player)
    balance.apply_character_modifiers(player)
  else
    if player.character then
      player.character.destroy()
    end
  end
end

local on_player_display_resolution_changed = function(event)
  local player = game.players[event.player_index]
  init_player_gui(player)
end

local on_research_finished = function(event)
  check_technology_for_disabled_items(event)
end

local on_player_cursor_stack_changed = function(event)
  check_cursor_for_disabled_items(event)
end

local on_built_entity = function(event)
  check_on_built_protection(event)
  check_neutral_chests(event)
end

local on_robot_built_entity = function(event)
  check_neutral_chests(event)
end

local on_research_started = function(event)
  if script_data.config.team_config.defcon_mode then
    local tech = script_data.next_defcon_tech
    if tech and tech.valid and event.research.name ~= tech.name then
      event.research.force.current_research = nil
    end
  end
end

local on_player_promoted = function(event)
  local player = game.players[event.player_index]
  init_player_gui(player)
end

local on_player_demoted = function(event)
  local player = game.players[event.player_index]
  init_player_gui(player)
end

local on_forces_merged = function (event)
  create_exclusion_map()
end

local on_player_changed_position = function(event)
  local player = game.players[event.player_index]
  check_player_base_exclusion(player)
  check_player_no_rush(player)
end

local check_spectator_chart = function()
  local force = game.forces.spectator
  if not (force and force.valid) then return end
  local surface = script_data.surface
  if not (surface and surface.valid) then return end
  force.chart_all(script_data.surface)
end

local pvp = {}

pvp.add_remote_interface = function()
  remote.add_interface("pvp",
  {
    get_event_name = function(name)
      return events[name]
    end,
    get_events = function()
      return events
    end,
    get_teams = function()
      return script_data.config.teams
    end,
    get_config = function()
      return script_data.config
    end,
    set_config = function(array)
      log("pvp global config set by remote call - Can expect script errors after this point.")
      for k, v in pairs (array) do
        script_data.config[k] = v
      end
    end
  })
end

pvp.on_nth_tick = {
  [60] = function(event)
    if script_data.setup_finished == true then
      check_no_rush()
      check_update_production_score()
      check_update_oil_harvest_score()
      check_update_space_race_score()
      check_base_exclusion()
      check_defcon()
      update_timers()
    end
    check_restart_round()
  end,
  [300] = function(event)
    if script_data.setup_finished == true then
      check_player_color()
      check_spectator_chart()
    end
  end
}

pvp.on_init = function()
  script_data.config = config.get_config()
  global.pvp = script_data
  balance.script_data = script_data
  config.script_data = script_data
  balance.init()
  local surface = game.create_surface("Lobby",{width = 1, height = 1})
  surface.set_tiles({{name = "out-of-map",position = {1,1}}})
  for k, force in pairs (game.forces) do
    force.disable_all_prototypes()
    force.disable_research()
  end
end

pvp.on_load = function()
  script_data = global.pvp or script_data
  balance.script_data = script_data
  config.script_data = script_data
end

pvp.on_configuration_changed = function(event)
  recursive_data_check(config.get_config(), script_data.config)
end


local script_events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_chunk_generated] = on_chunk_generated,
  [defines.events.on_entity_died] = on_entity_died,
  [defines.events.on_forces_merged] = on_forces_merged,
  [defines.events.on_gui_checked_state_changed] = on_gui_checked_state_changed,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_gui_closed] = on_gui_closed,
  [defines.events.on_gui_elem_changed] = on_gui_elem_changed,
  [defines.events.on_gui_selection_state_changed] = on_gui_selection_state_changed,
  [defines.events.on_player_changed_position] = on_player_changed_position,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
  [defines.events.on_player_display_resolution_changed] = on_player_display_resolution_changed,
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_player_left_game] = on_player_left_game,
  [defines.events.on_player_promoted] = on_player_promoted,
  [defines.events.on_player_demoted] = on_player_demoted,
  [defines.events.on_player_respawned] = on_player_respawned,
  [defines.events.on_research_finished] = on_research_finished,
  [defines.events.on_research_started] = on_research_started,
  [defines.events.on_robot_built_entity] = on_robot_built_entity,
  [defines.events.on_rocket_launched] = on_rocket_launched,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_gui_text_changed] = on_gui_text_changed,
}

pvp.on_event = function(event)
  local action = script_events[event.name]
  if not action then return end
  return action(event)
end

pvp.get_event_handler = function(name)
  return script_events[name]
end

return pvp
