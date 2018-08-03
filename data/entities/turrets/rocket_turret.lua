--Oh yea boi

local path = util.path("data/entities/turrets/")
local name = require("shared").entities.rocket_turret

local up_door_sprite = util.copy(data.raw.roboport.roboport).door_animation_up.hr_version
up_door_sprite.shift = {0.100625, -0.890}
up_door_sprite.direction_count = 1
local down_door_sprite = util.copy(data.raw.roboport.roboport).door_animation_down.hr_version
down_door_sprite.shift = {0.100625, -0.234375}
down_door_sprite.direction_count = 1
local base = util.copy(data.raw["ammo-turret"]["gun-turret"]).base_picture
util.recursive_hack_make_hr(base)
util.recursive_hack_scale(base, 1.5)
local sprite = function(param)
  local up = util.copy(up_door_sprite)
  local down = util.copy(down_door_sprite)
  for k, v in pairs (param) do
    up[k] = v
    down[k] = v
  end
  return {layers = {up, down}}
end
local turret =
{
  type = "turret",
  name = name,
  localised_name = name,
  icon = "__base__/graphics/icons/computer.png",
  icon_size = 32,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.5, result = name},
  max_health = 600,
  corpse = "medium-remnants",
  collision_box = {{-1.4, -1.4 }, {1.4, 1.4}},
  selection_box = {{-1.5, -1.5 }, {1.5, 1.5}},
  rotation_speed = 0.04,
  preparing_speed = 0.04,
  folding_speed = 0.04,
  dying_explosion = "medium-explosion",
  attacking_speed = 0.5,
  folded_animation = sprite{frame_count = 1, direction_count = 1},
  preparing_animation = sprite{},
  prepared_animation = sprite{frame_count = 1, x = up_door_sprite.width * (up_door_sprite.frame_count - 1)},
  attacking_animation = sprite{frame_count = 1, x = up_door_sprite.width * (up_door_sprite.frame_count - 1)},
  folding_animation = sprite{run_mode = "backward"},
  base_picture = base,
  vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "bullet",
    cooldown = SU(90),
    cooldown_deviation = 0.5,
    range = 40,
    min_attack_distance = 32,
    projectile_creation_distance = 0.5,
    sound = { filename = "__base__/sound/fight/rocket-launcher.ogg", volume = 0.6 },
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
    }
  },
  call_for_help_radius = 40 
}

local particle_gfx = util.copy(data.raw.projectile["shotgun-pellet"])

local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
stream.name = name.." Stream"
stream.action =
{
  --{
  --  type = "direct",
  --  action_delivery =
  --  {
  --    type = "instant",
  --    target_effects =
  --    {
  --      {
  --        type = "create-entity",
  --        entity_name = name.." Splash"
  --      }
  --    }
  --  }
  --},
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

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = turret.icon,
  icon_size = turret.icon_size,
  flags = {},
  subgroup = "defensive-structure",
  order = "f-"..name,
  stack_size = 1,
  place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = require("shared").deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 4}
  },
  energy_required = 5,
  result = name
}

data:extend{turret, stream, item, recipe}