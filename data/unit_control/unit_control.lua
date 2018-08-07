local names = require("shared").unit_tools
local path = util.path("data/unit_control/")

local unit_selection_tool = 
{
  type = "selection-tool",
  name = names.unit_selection_tool,
  localised_name = names.unit_selection_tool,
  selection_mode = {"friend", "entity-with-health"},
  alt_selection_mode = {"friend", "entity-with-health"},
  entity_type_filters = {"unit"},
  alt_entity_type_filters = {"unit"},
  selection_cursor_box_type = "copy",
  alt_selection_cursor_box_type = "pair",
  icon = path.."unit_select.png",
  icon_size = 128,
  stack_size = 1,
  flags = {"goes-to-quickbar"},
  show_in_library = true,
  selection_color = {g = 1},
  alt_selection_color = {g = 1, b = 1},
  draw_label_for_cursor_render = true,
}

local deploy_filter = {}
for k, name in pairs (require("shared").deployers) do
  table.insert(deploy_filter, name)
end

local deployer_selection_tool = 
{
  type = "selection-tool",
  name = names.deployer_selection_tool,
  localised_name = names.deployer_selection_tool,
  selection_mode = {"friend", "entity-with-health"},
  alt_selection_mode = {"friend", "entity-with-health"},
  entity_filters = deploy_filter,
  alt_entity_filters = deploy_filter,
  selection_cursor_box_type = "copy",
  alt_selection_cursor_box_type = "pair",
  icon = path.."deployer_select.png",
  icon_size = 128,
  stack_size = 1,
  flags = {"goes-to-quickbar"},
  show_in_library = true,
  selection_color = {g = 1},
  alt_selection_color = {g = 1, b = 1},
  draw_label_for_cursor_render = true,
}

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
  flags = {"only-in-cursor"},
  selection_color = {a = 0},
  alt_selection_color = {a = 0},
}

local unit_patrol_tool =
{
  type = "selection-tool",
  name = names.unit_patrol_tool,
  localised_name = names.unit_patrol_tool,
  selection_mode = {"friend", "enemy"},
  alt_selection_mode = {"enemy", "friend"},
  selection_cursor_box_type = "entity",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_move_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {"only-in-cursor"},
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
  flags = {"only-in-cursor"},
  selection_color = {a = 0},
  alt_selection_color = {a = 0},
}

local unit_attack_tool =
{
  type = "selection-tool",
  name = names.unit_attack_tool,
  localised_name = names.unit_attack_tool,
  selection_mode = {"enemy", "entity-with-force"},
  alt_selection_mode = {"enemy", "entity-with-force"},
  selection_cursor_box_type = "not-allowed",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_attack_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {"only-in-cursor"},
  selection_color = {r = 1},
  alt_selection_color = {r = 1},
}

local unit_force_attack_tool =
{
  type = "selection-tool",
  name = names.unit_force_attack_tool,
  localised_name = names.unit_force_attack_tool,
  selection_mode = {"not-same-force", "entity-with-health"},
  alt_selection_mode = {"not-same-force", "entity-with-health"},
  selection_cursor_box_type = "not-allowed",
  alt_selection_cursor_box_type = "not-allowed",
  icon = path.."unit_attack_tool.png",
  icon_size = 258,
  stack_size = 1,
  flags = {"only-in-cursor"},
  selection_color = {r = 1},
  alt_selection_color = {r = 1},
}

local move_indicator = util.copy(data.raw["simple-entity-with-owner"]["simple-entity-with-owner"])
move_indicator.flags = {"placeable-off-grid"}
move_indicator.name = names.move_indicator
move_indicator.localised_name = names.move_indicator
move_indicator.force_visibility = "same"
move_indicator.pictures = nil
move_indicator.picture = nil
move_indicator.selectable_in_game = false
move_indicator.collision_box = {{0,0},{0,0}}
move_indicator.render_layer = "lower-object"
move_indicator.animations = {
{
  width = 624,
  height = 440,
  line_length = 3,
  frame_count = 12,
  axially_symmetrical = false,
  direction_count = 1,
  priority = "high",
  animation_speed = SD(0.25),
  scale = 0.5,
  filename = path.."move_indicator.png",
}}

local attack_move_indicator = util.copy(move_indicator)
attack_move_indicator.name = names.attack_move_indicator
attack_move_indicator.localised_name = names.attack_move_indicator
attack_move_indicator.animations[1].filename = path.."attack_move_indicator.png"



local selection_sticker = util.copy(data.raw.sticker["fire-sticker"])
selection_sticker.name = names.unit_selection_sticker
selection_sticker.localised_name = names.unit_selection_sticker
selection_sticker.duration_in_ticks = 2 ^ 31
selection_sticker.target_movement_modifier = 1
selection_sticker.damage_per_tick = nil
selection_sticker.spread_fire_entity = nil
selection_sticker.fire_spread_cooldown = 0
selection_sticker.fire_spread_radius = 0
selection_sticker.animation = nil
selection_sticker.selection_box_type = "entity"
selection_sticker.stickers_per_square_meter = 0
selection_sticker.force_visibility = "same"

local enemy_target_sticker = util.copy(selection_sticker)
enemy_target_sticker.name = names.enemy_selection_sticker
enemy_target_sticker.localised_name = names.enemy_selection_sticker
enemy_target_sticker.duration_in_ticks = SU(60 * 4)
enemy_target_sticker.selection_box_type = "not-allowed"


local deployer_selection_sticker = util.copy(data.raw["simple-entity-with-owner"]["simple-entity-with-owner"])
deployer_selection_sticker.flags = {"placeable-off-grid"}
deployer_selection_sticker.name = names.deployer_selection_sticker
deployer_selection_sticker.localised_name = names.deployer_selection_sticker
deployer_selection_sticker.force_visibility = "same"
deployer_selection_sticker.pictures = nil
deployer_selection_sticker.picture = nil
deployer_selection_sticker.selectable_in_game = false
deployer_selection_sticker.collision_box = {{0,0},{0,0}}
deployer_selection_sticker.render_layer = "selection-box"
deployer_selection_sticker.animations = {
{
  width = 128,
  height = 128,
  line_length = 1,
  frame_count = 1,
  axially_symmetrical = false,
  direction_count = 1,
  priority = "high",
  animation_speed = 1,
  scale = 1.4,
  filename = path.."deployer_select.png",
}}

data:extend{
  unit_selection_tool,
  deployer_selection_tool,
  move_confirm_sound,
  unit_move_tool,
  unit_patrol_tool,
  unit_attack_move_tool,
  unit_force_attack_tool,
  unit_attack_tool,
  move_indicator,
  attack_move_indicator,
  selection_sticker,
  --enemy_target_sticker,
  deployer_selection_sticker
}

