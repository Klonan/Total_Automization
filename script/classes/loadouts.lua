local weapons = require("shared").weapons
local ammo = require("shared").ammo

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
      ammo.machine_gun_ammo
    },
    ["shotgun"] =
    {
      "shotgun-shell",
      "piercing-shotgun-shell"
    },
    [weapons.shotgun] =
    {
      weapons.shotgun.." Ammo"
    },
    [weapons.sniper_rifle] =
    {
      ammo.sniper_round
    },
    [weapons.beam_rifle] =
    {
      ammo.beam_cell
    }
  },

  secondary_weapons =
  {
    [weapons.smg] =
    {
      ammo.smg_rounds,
      ammo.smg_rounds,
    }
  },

  pistol_weapons =
  {
    ["Pistol"] =
    {
      "firearm-magazine"
    },
    [weapons.revolver] =
    {
      ammo.magnum_rounds
    }
  }
}

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