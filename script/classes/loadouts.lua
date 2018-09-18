local weapons = names.weapons
local ammo = names.ammo

local loadouts = {}

loadouts["Light"] =
{
  name = "Light",
  description = "Gotta get places quick, no time for heavy energy shield modules. Quick quick quick quick quick",
  equipment =
  {
    ["fusion-reactor-equipment"] = 1,
    ["personal-roboport-equipment"] = 1,
    ["exoskeleton-equipment"] = 1
  },

  primary_weapons =
  {
    [weapons.machine_gun] =
    {
      ammo.standard_magazine,
      ammo.explosive_magazine,
      ammo.piercing_magazine,
      ammo.smart_magazine,
      ammo.extended_magazine
    },
    [weapons.rocket_launcher] =
    {
      ammo.rocket,
      ammo.cluster_rocket
    },
    [weapons.shotgun] =
    {
      ammo.standard_shells,
      ammo.incendiary_shells,
      ammo.slug_shells,
    },
    [weapons.double_barreled_shotgun] =
    {
      ammo.standard_shells,
      ammo.incendiary_shells,
      ammo.slug_shells,
    },
    [weapons.sniper_rifle] =
    {
      ammo.sniper_rounds
    }
  },

  secondary_weapons =
  {
    [weapons.submachine_gun] =
    {
      ammo.standard_magazine,
      ammo.piercing_magazine,
    }
  },

  pistol_weapons =
  {
    [weapons.pistol] =
    {
      ammo.pistol_magazine
    },
    [weapons.revolver] =
    {
      ammo.revolver_rounds
    }
  }
}
if true then return loadouts end
loadouts["Heavy"] =
{
  name = "Heavy",
  description = "Likes to take his time getting to places.",

  equipment =
  {
    ["fusion-reactor-equipment"] = 1,
    ["personal-roboport-equipment"] = 1,
    ["energy-shield-equipment"] = 1
  },

  primary_weapons =
  {
    [weapons.sniper_rifle] =
    {
      "Sniper Rifle Ammo"
    },
    [weapons.rocket_launcher] =
    {
      weapons.rocket_launcher.." Ammo",
      "rocket",
      "explosive-rocket"
    }
  },

  secondary_weapons =
  {
    [weapons.submachine_gun] =
    {
      weapons.submachine_gun.." Ammo"
    }
  },

  pistol_weapons =
  {
    [weapons.pistol] =
    {
      ammo.pistol_rounds
    },
    [weapons.revolver] =
    {
      weapons.revolver.." Ammo"
    }
  }
}

return loadouts