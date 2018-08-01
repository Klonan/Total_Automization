local path = util.path("data/entities/setup_time/")
local name = require("shared").entities.setup_time_animation
local setup_animation = util.copy(data.raw["simple-entity-with-owner"]["simple-entity-with-owner"])
setup_animation.name = name
setup_animation.localised_name = name
setup_animation.force_visibility = "all"
setup_animation.pictures = nil
setup_animation.picture = nil
setup_animation.selectable_in_game = false
setup_animation.collision_box = {{0,0},{0,0}}
setup_animation.render_layer = "object"
setup_animation.animations = {
{
  width = 624,
  height = 440,
  line_length = 3,
  frame_count = 12,
  axially_symmetrical = false,
  direction_count = 1,
  priority = "high",
  animation_speed = SD(0.25),
  scale = 0.1,
  filename = path.."setup_time_animation.png"
}}

data:extend{setup_animation}