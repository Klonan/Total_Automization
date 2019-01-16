--Fix shotguns

local shotgun = data.raw.gun.shotgun
shotgun.attack_parameters =
{
  type = "projectile",
  ammo_category = "shotgun-shell",
  cooldown = 30,
  movement_slow_down_factor = 0.1,
  projectile_creation_distance = 1.125,
  range = 40,
  min_range = 1,
  sound =
  {
    {
      filename = "__base__/sound/pump-shotgun.ogg",
      volume = 0.5
    }
  }
}


local pellet = data.raw.projectile["shotgun-pellet"]
pellet.force_condition = "not-same"
pellet.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 10, type = "physical"}
      },
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local animation = pellet.animation
animation.tint = nil
animation.blend_mode = "additive"
local animations = {}
local make_animation = function(scale)
  local new = util.copy(animation)
  new.scale = scale
  table.insert(animations, new)
end

for scale = 0.5, 1.5, 0.05 do
  make_animation(scale)
end

pellet.animation = animations

local piercing_pellet = data.raw.projectile["piercing-shotgun-pellet"]
piercing_pellet.force_condition = "not-same"
piercing_pellet.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 20, type = "physical"}
      },
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local animation = piercing_pellet.animation
animation.tint = nil
animation.blend_mode = "additive"
local animations = {}
local make_animation = function(scale)
  local new = util.copy(animation)
  new.scale = scale
  table.insert(animations, new)
end

for scale = 0.5, 1.5, 0.05 do
  make_animation(scale)
end

piercing_pellet.animation = animations

local shotgun_ammo = data.raw.ammo["shotgun-shell"]
shotgun_ammo.reload_time = 60
shotgun_ammo.ammo_type =
{
  category = "shotgun-shell",
  target_type = "direction",
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    {
      type = "direct",
      repeat_count = 12,
      action_delivery =
      {
        type = "projectile",
        projectile = "shotgun-pellet",
        starting_speed = 1,
        starting_speed_deviation = 0.1,
        direction_deviation = 0.2,
        range_deviation = 0.2,
        max_range = 25
      }
    }
  }
}

local piercing_shotgun_ammo = data.raw.ammo["piercing-shotgun-shell"]
piercing_shotgun_ammo.reload_time = 60
piercing_shotgun_ammo.ammo_type =
{
  category = "shotgun-shell",
  target_type = "direction",
  action =
  {
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        source_effects =
        {
          {
            type = "create-explosion",
            entity_name = "explosion-gunshot"
          }
        }
      }
    },
    {
      type = "direct",
      repeat_count = 16,
      action_delivery =
      {
        type = "projectile",
        projectile = "piercing-shotgun-pellet",
        starting_speed = 1,
        starting_speed_deviation = 0.1,
        direction_deviation = 0.2,
        range_deviation = 0.2,
        max_range = 25
      }
    }
  }
}


--Make rockets fun

local rocket = data.raw.projectile.rocket
rocket.direction_only = true
rocket.force_condition = "not-same"
rocket.collision_box = {{-0.1, -0.1},{0.1, 0.1}}
rocket.acceleration = 0.01
rocket.max_speed = 0.5
rocket.action =
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = "explosion"
      },
      {
        type = "nested-result",
        action =
        {
          type = "area",
          radius = 1,
          force = "not-same",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage = {amount = 40, type = "explosion"}
              },
            }
          }
        }
      }
    }
  }
}



local explosive_rocket = data.raw.projectile["explosive-rocket"]
explosive_rocket.direction_only = true
explosive_rocket.force_condition = "not-same"
explosive_rocket.collision_box = {{-0.1, -0.1},{0.1, 0.1}}
explosive_rocket.acceleration = 0.01
explosive_rocket.max_speed = 0.5
explosive_rocket.action =
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
                  entity_name = explosive_rocket.name.." Explosion"
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
                  entity_name = explosive_rocket.name.." Explosion"
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
explosion.name = explosive_rocket.name.." Explosion"

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

data:extend{explosion}

local rocket_ammo = data.raw.ammo.rocket
rocket_ammo.magazine_size = 5
rocket_ammo.reload_time = 100
rocket_ammo.ammo_type =
{
  category = "rocket",
  target_type = "direction",
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "rocket",
      starting_speed = 0.1,
      max_range = 40,
      range_deviation = 0.1,
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local explosive_rocket_ammo = data.raw.ammo["explosive-rocket"]
explosive_rocket_ammo.magazine_size = 5
explosive_rocket_ammo.reload_time = 100
explosive_rocket_ammo.ammo_type =
{
  category = "rocket",
  target_type = "direction",
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "projectile",
      projectile = "explosive-rocket",
      starting_speed = 0.1,
      max_range = 40,
      range_deviation = 0.1,
      source_effects =
      {
        type = "create-entity",
        entity_name = "explosion-hit"
      }
    }
  }
}

local rocket_launcher = data.raw.gun["rocket-launcher"]
rocket_launcher.attack_parameters =
{
  type = "projectile",
  ammo_category = "rocket",
  movement_slow_down_factor = 0.3,
  cooldown = 35,
  projectile_creation_distance = 0.6,
  range = 40,
  projectile_center = {-0.17, 0},
  sound =
  {
    {
      filename = "__base__/sound/fight/rocket-launcher.ogg",
      volume = 0.7
    }
  }
}

--Grenades...

local capsule = data.raw.capsule.grenade


capsule.capsule_action =
{
  type = "throw",
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "grenade",
    cooldown = 40,
    projectile_creation_distance = 0.6,
    range = 35,
    ammo_type =
    {
      category = "grenade",
      target_type = "position",
      action =
      {
        {
          type = "direct",
          action_delivery =
          {
            type = "stream",
            stream = capsule.name.." Stream",
            source_offset = {0, -1}
          }
        }
      }
    }
  }
}

local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
stream.name = capsule.name.." Stream"
stream.oriented_particle = true
stream.action =
{
  {
    type = "area",
    radius = 6.5,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
        type = "damage",
        damage = {amount = 35, type = "explosion"}
        },
        {
        type = "create-entity",
        entity_name = "explosion"
        }
      }
    }
  },
  {
    type = "area",
    target_entities = false,
    trigger_from_target = true,
    repeat_count = 60,
    radius = 6.5,
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "create-entity",
          entity_name = stream.name.." Explosion"
        }
      }
    }
  }
}

local explosion = util.copy(data.raw.explosion.explosion)
explosion.name = stream.name.." Explosion"

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


local grenade = data.raw.projectile.grenade

stream.particle = grenade.animation
stream.shadow = grenade.shadow
stream.particle.scale = 1
stream.particle_buffer_size = 1
stream.particle_spawn_interval = 100
stream.particle_spawn_timeout = 0
stream.particle_vertical_acceleration = 1.981 / 90
stream.particle_horizontal_speed = 0.4
stream.particle_horizontal_speed_deviation = 0.1
stream.particle_start_alpha = 1
stream.particle_end_alpha = 1
stream.particle_start_scale = 1
stream.particle_loop_frame_count = 1
stream.particle_fade_out_threshold = 1
stream.particle_loop_exit_threshold = 1
stream.spine_animation = nil
stream.smoke_sources = nil
local old_smoke = {
  {
    name = "soft-fire-smoke",
    frequency = 2, --0.25,
    position = {0.0, 0}, -- -0.8},
    starting_frame_deviation = 60
  }
}
stream.progress_to_create_smoke = 0
stream.target_position_deviation = 1

data:extend({stream, explosion})

local cluster_capsule = data.raw.capsule["cluster-grenade"]

cluster_capsule.capsule_action =
{
  type = "throw",
  attack_parameters =
  {
    type = "projectile",
    ammo_category = "grenade",
    cooldown = 20,
    projectile_creation_distance = 0.6,
    range = 40,
    ammo_type =
    {
      category = "grenade",
      target_type = "position",
      action =
      {
        type = "direct",
        action_delivery =
        {
          type = "stream",
          stream = cluster_capsule.name.." Stream",
          source_offset = {0, -1}
        }
      }
    }
  }
}

local stream = util.copy(data.raw.stream["flamethrower-fire-stream"])
stream.name = cluster_capsule.name.." Stream"
stream.oriented_particle = true
stream.action =
{
  {
    type = "cluster",
    cluster_count = 7,
    distance = 4,
    distance_deviation = 3,
    action_delivery =
    {
      type = "stream",
      stream = capsule.name.." Stream",
      source_offset = {0, -1}
    }
  }
}

local grenade = data.raw.projectile["cluster-grenade"]

stream.particle = grenade.animation
stream.shadow = grenade.shadow
stream.particle.scale = 1
stream.particle_buffer_size = 1
stream.particle_spawn_interval = 100
stream.particle_spawn_timeout = 0
stream.particle_vertical_acceleration = 1.981 / 90
stream.particle_horizontal_speed = 0.4
stream.particle_horizontal_speed_deviation = 0.1
stream.particle_start_alpha = 1
stream.particle_end_alpha = 1
stream.particle_start_scale = 1
stream.particle_loop_frame_count = 1
stream.particle_fade_out_threshold = 1
stream.particle_loop_exit_threshold = 1
stream.spine_animation = nil
stream.smoke_sources = nil
local old_smoke = {
  {
    name = "soft-fire-smoke",
    frequency = 2, --0.25,
    position = {0.0, 0}, -- -0.8},
    starting_frame_deviation = 60
  }
}
stream.progress_to_create_smoke = 0
stream.target_position_deviation = 1

data:extend({stream})