local path = util.path("data/items/ammo_pack/")
local name = names.items.ammo_pack

local item =
{
  type = "item",
  name = name,
  localised_name = name,
  stack_size = 1,
  order = name,
  icon = path.."ammo_pack.png",
  icon_size = 586,
  flags = {},
  place_result = name
}

local set_sprite =
{
  filename = path.."ammo_pack.png",
  height = 586,
  width = 586,
  scale = 1 / 10,
}

local landmine =
{
  type = "land-mine",
  name = name,
  localised_name = name,
  selection_box = {{-1, -1},{1, 1}},
  picture_safe = util.empty_sprite(),
  picture_set = set_sprite,
  picture_set_enemy = set_sprite,
  trigger_radius = 1,
  trigger_force = "all",
  timeout = 0,
  action =
  {
    type = "direct",
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        {
          type = "insert-item",
          item = name,
          count = 1
        },
        {
          type = "play-sound",
          sound =
          {
            filename = path.."ammo_pack.ogg"
          }
        }
      }
    }
  },
  create_ghost_on_death = false
}

local sound =
{
  type = "sound",
  name = names.sounds.ammo_pack_sound,
  filename = path.."ammo_pack.ogg"
}

data:extend{item, landmine, sound}