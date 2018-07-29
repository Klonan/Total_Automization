local path = util.path("data/units/scatter_spitter")
local name = require("shared").units.piercing_biter

local unit = util.copy(data.raw.unit["big-biter"])
unit.name = name
unit.localised_name = name
unit.collision_mask = {"not-colliding-with-itself", "player-layer"}
unit.can_open_gates = true
unit.destroy_when_commands_fail = false
unit.only_attack_healthy = true
--unit.move_while_shooting = true
unit.radar_range = 2
unit.movement_speed = SD(0.25)
unit.max_pursue_distance = 64
unit.min_persue_time = SU(8 * 60)
unit.map_color = {b = 0.5, g = 1}
unit.collision_box = {{-1, -1},{1, 1}}
unit.selection_box = {{-1, -1},{1, 1}}
unit.sticker_box = {{-1, -1},{1, 1}}
unit.max_health = 220
unit.dying_explosion = nil
unit.corpse = nil
unit.healing_per_tick = SD(3/60)

local animation = util.copy(unit.attack_parameters.animation)
for k, layer in pairs (animation.layers) do
  layer.animation_speed = SD(layer.animation_speed or 1)
end
local sound = util.copy(unit.attack_parameters.sound)
animation.layers[2].apply_runtime_tint = true
unit.run_animation.layers[2].apply_runtime_tint = true
unit.attack_parameters = 
{
  type = "projectile",
  range = 2,
  cooldown = SU(60),
  cooldown_deviation = 0.2,
  ammo_category = "melee",
  ammo_type =
  {
    category = "melee",
    target_type = "entity",
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          damage = { amount = 30, type = util.damage_type("piercing_biter")}
        }
      }
    }
  },
  sound = sound,
  animation = animation
}
--util.recursive_hack_scale(unit, 0.2)

local item = {
  type = "item",
  name = name,
  localised_name = name,
  icon = unit.icon,
  icon_size = unit.icon_size,
  flags = {},
  subgroup = "bio-units",
  order = name,
  stack_size= 1
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = name,
  category = require("shared").deployers.bio_unit,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 4},
    {type = "fluid", name = "water", amount = 1}
  },
  energy_required = 5,
  result = name
}

data:extend{unit, item, recipe}


