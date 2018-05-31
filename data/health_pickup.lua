local util = require "util"

local health_pack = util.table.deepcopy(data.raw["land-mine"]["land-mine"])
health_pack.name = "health-pack"
health_pack.trigger_radius = 5
--health_pack.ammo_category = "landmine"
health_pack.action =
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
        type = "damage",
        damage = { amount = -100, type = "explosion"}
      }
    }
  }
}
for k, rock in pairs (data.raw["simple-entity"]) do
  if rock.autoplace then
    health_pack.autoplace = util.table.deepcopy(rock.autoplace)
  end
end
health_pack.autoplace.force = "enemy"
health_pack.picture_set_enemy = health_pack.picture_set
health_pack.order = "zzz"
data:extend{health_pack}

