local name = names.ammo.rocket
local ammo = util.copy(data.raw.ammo["rocket"])
ammo.name = name
ammo.localised_name = name
ammo.magazine_size = 4
ammo.stack_size = 20 / 4
ammo.reload_time = SU(150)
ammo.ammo_type =
{
  category = util.ammo_category("rocket_launcher"),
  target_type = "position",
  clamp_position = true,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = name,
      starting_speed = SD(0.2),
      max_range = 45,
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local projectile = util.copy(data.raw.projectile.rocket)
projectile.name = name
projectile.acceleration = SA(0.01)
projectile.collision_box = {{-0.05, -0.25}, {0.05, 0.25}}
projectile.force_condition = "not-same"
projectile.direction_only = true
projectile.max_speed = SD(0.5)
projectile.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "nested-result",
        action =
        {
          {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = 2 * math.pi * 1.5 * 1.5,
            radius = 1.5,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "create-entity",
                  entity_name = name.." Explosion"
                }
              }
            }
          },
          {
            type = "area",
            target_entities = false,
            trigger_from_target = true,
            repeat_count = math.pi * 4 * 4,
            radius = 4,
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "create-entity",
                  entity_name = name.." Explosion"
                }
              }
            }
          },
          {
            type = "area",
            radius = 4,
            force = "not-same",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "damage",
                  damage = {amount = 10, type = util.damage_type("rocket")}
                }
              }
            }
          },
          {
            type = "area",
            radius = 1.5,
            force = "not-same",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "damage",
                  damage = {amount = 25, type = util.damage_type("rocket")}
                },
              }
            }
          }
        }
      }
    }
  }
}

local explosion = util.copy(data.raw.explosion.explosion)
explosion.name = name.." Explosion"

local sprites = explosion.animations
local new_animations = {}
local add_sprites = function(scale, speed)
  for k, sprite in pairs (sprites) do
    local new = util.copy(sprite)
    new.animation_speed = (new.animation_speed or 1) * speed
    new.scale = (new.scale or 1) * scale
    new.blend_mode = "additive"
    table.insert(new_animations, new)
  end
end

add_sprites(1, 0.5)
add_sprites(0.95, 0.6)
add_sprites(0.9, 0.7)
add_sprites(0.85, 0.8)
add_sprites(0.8, 0.9)
add_sprites(0.75, 1)
add_sprites(0.6, 1.1)
add_sprites(0.5, 1.2)

explosion.animations = new_animations
explosion.light = nil
explosion.smoke = nil
explosion.smoke_count = 0

data:extend{ammo, projectile, explosion}
