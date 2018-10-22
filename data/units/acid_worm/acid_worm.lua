local path = util.path("data/units/acid_worm/")
local name = names.units.acid_worm

local base = util.copy(data.raw.turret["big-worm-turret"])
--for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
--  layer.frame_count = 1
--end

local hack_layer = function(layer)
  layer.animation_speed = 0.0000000000000000001
  for k, flag in pairs (layer.flags or {}) do
    if flag == "mask" then
      layer.apply_runtime_tint = true
      break
    end
  end
end

for k, layer in pairs (base.ending_attack_animation.layers) do
  hack_layer(layer)
end

local bot =
{
  type = "unit",
  name = name,
  localised_name = name,
  icon = base.icon,
  icon_size = base.icon_size,
  flags = {"player-creation"},
  map_color = {b = 0.5, g = 1},
  enemy_map_color = {r = 1},
  max_health = 200, 
  healing_per_tick = SD(4/60),
  radar_range = 2,
  order="b-b-b",
  subgroup="enemies",
  resistances = nil,
  collision_box = {{-1, -1}, {1, 1}},
  collision_mask = {"not-colliding-with-itself", "player-layer"},
  max_pursue_distance = 64,
  min_persue_time = SU(60 * 15),
  selection_box = {{-1.6, -2.5}, {1.6, 1.2}},
  collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
  sticker_box = {{-0.8, -2}, {0.8, 0.2}},
  distraction_cooldown = SU(15),
  move_while_shooting = false,
  can_open_gates = true,
  minable = {result = name, mining_time = 2},
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(90),
    cooldown_deviation = 0.5,
    range = 40,
    min_attack_distance = 32,
    projectile_creation_distance = 1.5,
    sound = base.starting_attack_sound,
    ammo_type =
    {
      category = "bullet",
      target_type = "entity",
      action =
      {
        type = "direct",
        action_delivery =
        {
          {
          type = "stream",
          stream = name.." Stream",
          }
        }
      }
    },
    animation = base.ending_attack_animation
  },
  vision_distance = 40,
  has_belt_immunity = true,
  movement_speed = SD(0.15),
  distance_per_frame = 0.15,
  pollution_to_join_attack = 1000,
  destroy_when_commands_fail = false,
  --corpse = name.." Corpse",
  dying_explosion = base.dying_explosion,
  dying_sound = base.dying_sound,
  run_animation = base.ending_attack_animation
}

local scale = 1.5
util.recursive_hack_make_hr(bot)
--util.recursive_hack_scale(bot, scale)
--util.scale_boxes(bot, scale)
local particle_gfx = util.copy(data.raw.projectile["acid-projectile-purple"])

local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
stream.name = name.." Stream"
stream.action =
{
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-entity",
          entity_name = name.." Splash"
        }
      }
    }
  },
  {
    type = "area",
    collision_mode = "distance-from-center",
    radius = 1.5,
    force = "not-same",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "damage",
          damage = { amount = 3, type = "acid" }
        }
      }
    }
  }
}
stream.particle = particle_gfx.animation
stream.particle.scale = 1.5
stream.particle_buffer_size = 100
stream.particle_spawn_interval = SU(2)
stream.particle_spawn_timeout = SU(30)
stream.particle_vertical_acceleration = SA(0.981 / 60)
stream.particle_horizontal_speed = SD(0.35)
stream.particle_horizontal_speed_deviation = SD(0.03)
stream.particle_start_alpha = 1
stream.particle_end_alpha = 1
stream.particle_start_scale = 1
stream.particle_loop_frame_count = 10
stream.particle_fade_out_threshold = 1
stream.particle_loop_exit_threshold = 1
--stream.particle.tint = {r = 0.5, g = 0, b = 1}
stream.spine_animation = nil
stream.smoke_sources = nil
stream.target_position_deviation = 3

local splash = 
{
  type = "explosion",
  name = name.." Splash",
  height = 1,
  flags = {"not-on-map"},
  animations =
  {
    {
      filename = path.."acid_worm_splash.png",
      priority = "extra-high",
      width = 92,
      height = 66,
      frame_count = 15,
      line_length = 5,
      shift = {-0.437, 0.5},
      animation_speed = SD(0.35),
      scale = 1.5
    }
  }
}

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = bot.icon,
  icon_size = bot.icon_size,
  flags = {},
  subgroup = "bio-units",
  order = "e-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = names.deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {names.items.biological_structure, 125},
    {type = "fluid", name = "sulfuric-acid", amount = 600}
  },
  energy_required = 75,
  result = name
}

data:extend
{
  bot,
  stream,
  splash,
  --item,
  --recipe
}