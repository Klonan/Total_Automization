local path = util.path("data/items/ammo/sniper_rifle/")
local name = names.ammo.sniper_rounds

local ammo = util.base_ammo(name)
ammo.icon = path.."sniper_rounds.png"
ammo.icon_size = 512
ammo.stack_size = 25
ammo.magazine_size = 1
ammo.ammo_type =
{
  category = util.ammo_category("sniper"),
  target_type = "direction",
  clamp_position = true,
  action =
  {
    type = "line",
    range = 55,
    width = 0.5,
    force = "not-same",
    source_effects =
    {
      type = "create-explosion",
      entity_name = "railgun-beam"
    },
    action_delivery =
    {
      type = "instant",
      target_effects =
      {
        type = "damage",
        damage = { amount = 100, type= util.damage_type("sniper")}
      }
    }
  }
}

data:extend{ammo}
