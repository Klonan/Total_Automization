--WIP
local names = require("shared").unit_names
local path = util.path("data/unit_control/")

local unit_selection_tool = 
{
  type = "selection-tool",
  name = names.unit_selection_tool,
  localised_name = names.unit_selection_tool,
  selection_mode = {"friend", "any-entity"},
  alt_selection_mode = {"friend", "any-entity"},
  entity_type_filters = {"unit"},
  alt_entity_type_filters = {"unit"},
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "pair",
  icon = path.."unit_select.png",
  icon_size = 128,
  stack_size = 1,
  flags = {"goes-to-quickbar"},
  show_in_library = true,
  selection_color = {g = 1},
  alt_selection_color = {r = 1},
}

--/c biter1 = game.surfaces[1].create_entity{name = "small-biter", position = {-20, -10}, force = "enemy"}
--biter2 = game.surfaces[1].create_entity{name = "small-biter", position = {20, -10}, force = "player"}
--group = game.surfaces[1].create_unit_group{position = biter2.position, force = biter2.force}
--biter2.set_command{
--  type = defines.command.group,
--  group = group,
--}
--group.set_command
--{
--  type = defines.command.stop
--}
--
local unit_move_tool =
{
  type = "selection-tool",
  name = names.unit_move_tool,
  localised_name = names.unit_move_tool,
  selection_mode = {"friend", "enemy"},
  alt_selection_mode = {"enemy", "friend"},
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_move_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {},
  selection_color = {a = 0},
  alt_selection_color = {a = 0},
}

local move_confirm_sound =
{
  name = names.unit_move_sound,
  type = "sound",
  filename = "__core__/sound/armor-insert.ogg",
  volume = 2
}

local unit_attack_move_tool =
{
  type = "selection-tool",
  name = names.unit_attack_move_tool,
  localised_name = names.unit_attack_move_tool,
  selection_mode = {"friend", "enemy"},
  alt_selection_mode = {"enemy", "friend"},
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_attack_move_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {},
  selection_color = {a = 0},
  alt_selection_color = {a = 0},
}

local unit_attack_tool =
{
  type = "selection-tool",
  name = names.unit_attack_tool,
  localised_name = names.unit_attack_tool,
  selection_mode = {"enemy", "any-entity"},
  entity_type_filters = {"unit"},
  alt_selection_mode = {"enemy", "friend"},
  selection_cursor_box_type = "not-allowed",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_attack_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {},
  selection_color = {r = 1},
  alt_selection_color = {a = 0},
}

data:extend{
  unit_selection_tool,
  move_confirm_sound,
  unit_move_tool,
  unit_attack_move_tool,
  unit_attack_tool
}

