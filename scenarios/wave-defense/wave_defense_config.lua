--This is serialised on init.
local config = {}

local default_unit_first_waves = function()
return
  {
    ["small-biter"] =      0,
    ["medium-biter"] =     6,
    ["big-biter"] =        12,
    ["behemoth-biter"] =   18,

    ["small-spitter"] =    3,
    ["medium-spitter"] =   9,
    ["big-spitter"] =      15,
    ["behemoth-spitter"] = 20
  }
end

local default_bounties = function()
  return
  {
    ["small-biter"] = 25,
    ["medium-biter"] = 125,
    ["big-biter"] = 350,
    ["behemoth-biter"] = 800,

    ["small-spitter"] = 35,
    ["medium-spitter"] = 140,
    ["big-spitter"] = 400,
    ["behemoth-spitter"] = 1000,

    ["small-worm-turret"] = 50,
    ["medium-worm-turret"] = 150,
    ["big-worm-turret"] = 450,

    ["biter-spawner"] = 1000,
    ["spitter-spawner"] = 1500
  }
end

local default_starting_items = function()
  return
  {
    ["iron-plate"] = 200,
    ["pipe"] = 200,
    ["pipe-to-ground"] = 50,
    ["copper-plate"] = 200,
    ["steel-plate"] = 200,
    ["iron-gear-wheel"] = 250,
    ["transport-belt"] = 600,
    ["underground-belt"] = 40,
    ["splitter"] = 40,
    ["gun-turret"] = 8,
    ["stone-wall"] = 50,
    ["repair-pack"] = 20,
    ["inserter"] = 100,
    ["burner-inserter"] = 50,
    ["small-electric-pole"] = 50,
    ["medium-electric-pole"] = 50,
    ["big-electric-pole"] = 15,
    ["burner-mining-drill"] = 50,
    ["electric-mining-drill"] = 50,
    ["stone-furnace"] = 35,
    ["steel-furnace"] = 20,
    ["electric-furnace"] = 8,
    ["assembling-machine-1"] = 50,
    ["assembling-machine-2"] = 20,
    ["assembling-machine-3"] = 8,
    ["electronic-circuit"] = 200,
    ["fast-inserter"] = 100,
    ["long-handed-inserter"] = 100,
    ["substation"] = 10,
    ["boiler"] = 10,
    ["offshore-pump"] = 1,
    ["steam-engine"] = 20,
    ["chemical-plant"] = 20,
    ["oil-refinery"] = 5,
    ["pumpjack"] = 10,
    ["small-lamp"] = 20
  }
end

local default_respawn_items = function()
  return
  {
    ["submachine-gun"] = 1,
    ["firearm-magazine"] = 40,
    ["shotgun"] = 1,
    ["shotgun-shell"] = 20,
    ["construction-robot"] = 10,
    ["modular-armor"] = 1,
    ["exoskeleton-equipment"] = 1,
    ["personal-roboport-equipment"] = 1,
    ["battery-equipment"] = 1,
    ["solar-panel-equipment"] = 11,

  }
end

local default_wave_power_function = function()
  return function(level)
    return (level ^ 1.15) * 400
  end
end

local default_speed_multiplier_function = function()
  return function(level)
    return (level ^ 0.1) - 0.2
  end
end

config.difficulties =
{

  easy = {
    starting_area_size = 1.8,
    day_settings =
    {
      ticks_per_day = 27500,
      dusk = 0.25,
      evening = 0.45,
      morning = 0.50,
      dawn = 0.70
    },
    starting_chest_items = default_starting_items(),
    respawn_items = default_respawn_items(),
    bounties = default_bounties(),
    unit_first_waves = default_unit_first_waves(),
    wave_power_function = default_wave_power_function(),
    speed_multiplier_function = default_speed_multiplier_function()
  },

  normal = {
    starting_area_size = 1.6,
    day_settings =
    {
      ticks_per_day = 25000,
      dusk = 0.25,
      evening = 0.45,
      morning = 0.6,
      dawn = 0.75
    },
    starting_chest_items = default_starting_items(),
    respawn_items = default_respawn_items(),
    bounties = default_bounties(),
    unit_first_waves = default_unit_first_waves(),
    wave_power_function = default_wave_power_function(),
    speed_multiplier_function = default_speed_multiplier_function()
  },

  hard = {
    starting_area_size = 1.4,
    day_settings =
    {
      ticks_per_day = 22500,
      dusk = 0.2,
      evening = 0.40,
      morning = 0.6,
      dawn = 0.75
    },
    starting_chest_items = default_starting_items(),
    respawn_items = default_respawn_items(),
    bounties = default_bounties(),
    unit_first_waves = default_unit_first_waves(),
    wave_power_function = default_wave_power_function(),
    speed_multiplier_function = default_speed_multiplier_function()
  }

}

config.map_gen_settings =
{
  autoplace_controls =
  {
    coal =
    {
      frequency = 1,
      richness = 2,
      size = 2
    },
    ["copper-ore"] =
    {
      frequency = 1,
      richness = 2,
      size = 2
    },
    ["crude-oil"] =
    {
      frequency = 10,
      richness = 2,
      size = 2
    },
    desert =
    {
      frequency = 6,
      richness = 1,
      size = 0
    },
    dirt =
    {
      frequency = 6,
      richness = 1,
      size = 0
    },
    ["enemy-base"] =
    {
      frequency = 10,
      richness = 1,
      size = 1
    },
    grass =
    {
      frequency = 6,
      richness = 1,
      size = 6
    },
    ["iron-ore"] =
    {
      frequency = 1,
      richness = 2,
      size = 2
    },
    sand =
    {
      frequency = 6,
      richness = 1,
      size = 0
    },
    stone =
    {
      frequency = 1,
      richness = 2,
      size = 2
    },
    trees =
    {
      frequency = 4,
      richness = 1,
      size = 0.15
    },
    ["uranium-ore"] =
    {
      frequency = 3,
      richness = 2,
      size = 0.5
    }
  },
  autoplace_settings = {},
  cliff_settings =
  {
    cliff_elevation_0 = 20,
    cliff_elevation_interval = 2,
    name = "cliff"
  },
  height = 1024,
  property_expression_names =
  {},
  research_queue_from_the_start = "after-victory",
  starting_area = 1.2,
  starting_points =
  {
    {
      x = 0, --(1024 / 2) - 64,
      y = 0
    },
  },
  terrain_segmentation = 2,
  water = 1.3,
  width = 1024
}

return config
