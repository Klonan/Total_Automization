local path = util.path("data/units/scatter_spitter")
local name = names.units.beetle

local unit = util.copy(data.raw.unit["small-biter"])
unit.name = name
unit.localised_name = name
unit.collision_mask = {"not-colliding-with-itself", "player-layer"}
unit.can_open_gates = true
unit.destroy_when_commands_fail = false
unit.only_attack_healthy = true
--unit.move_while_shooting = true
unit.radar_range = 2
unit.movement_speed = SD(0.3)
unit.max_pursue_distance = 64
unit.min_persue_time = SU(8 * 60)
unit.map_color = {b = 0.5, g = 1}
unit.collision_box = {{-0.6, -0.6},{0.6, 0.6}}
unit.selection_box = {{-1.0, -1.0},{1.0, 1.0}}
unit.sticker_box = {{-0.5, -1},{0.5, 0.5}}
unit.max_health = 45
unit.dying_explosion = nil
unit.corpse = nil
unit.healing_per_tick = SD(0.5/60)
unit.has_belt_immunity = true
unit.minable = {result = name, mining_time = 2}

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
  range = 1.5,
  min_attack_distance = 0.5,
  cooldown = SU(35),
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
          damage = { amount = 5, type = util.damage_type("beetle")}
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
  order = "b-"..name,
  stack_size= 1,
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
    {names.items.biological_structure, 20},
    {type = "fluid", name = "water", amount = 600}
  },
  energy_required = 25,
  result = name
}

data:extend{unit, item, recipe}


