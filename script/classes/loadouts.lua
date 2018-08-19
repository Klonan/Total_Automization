local weapons = require("shared").weapons
local ammo = require("shared").ammo

local loadouts = {}

loadouts["Light"] =
{
  name = "Light",

  equipment =
  {
    ["fusion-reactor-equipment"] = 1,
    ["personal-roboport-equipment"] = 1,
    ["exoskeleton-equipment"] = 1
  },

  primary_weapons =
  {
    ["Pistol"] =
    {
      "Pistol Ammo"
    },
    ["shotgun"] =
    {
      "shotgun-shell",
      "piercing-shotgun-shell"
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
    [weapons.smg] =
    {
      ammo.smg_rounds,
      ammo.smg_rounds,
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
      ammo.magnum_rounds
    }
  }
}

return loadouts