local path = util.path("data/items/ammo/pistol/")
local name = names.ammo.revolver_rounds
local ammo = util.base_ammo(name)
ammo.icon = path.."revolver_ammo.png"
ammo.icon_size = 256
ammo.magazine_size = 6
ammo.stack_size = 12
ammo.reload_time = SU(75)
ammo.ammo_type =
{
  category = util.ammo_category("revolver"),
  target_type = "direction",
  action =
  {
    type = "line",
    range = 35,
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
        damage = { amount = 20, type= util.damage_type("revolver")}
      }
    }
  }
}

data:extend{ammo}
