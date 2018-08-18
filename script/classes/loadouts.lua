local names = require("shared")

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
    [names.primary_weapons.sniper_rifle] =
    {
      names.primary_ammo.sniper_round
    },
    [names.primary_weapons.beam_rifle] =
    {
      names.primary_ammo.beam_cell
    }
  },

  secondary_weapons =
  {
    [names.secondary_weapons.smg] =
    {
      names.secondary_ammo.smg_rounds,
      names.secondary_ammo.smg_rounds,
    }
  },
  pistol_weapons =
  {
    [names.pistol_weapons.pistol] =
    {
      names.pistol_ammo.pistol_rounds
    },
    [names.pistol_weapons.revolver] =
    {
      names.pistol_ammo.magnum_rounds
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
    [names.primary_weapons.sniper_rifle] =
    {
      names.primary_ammo.sniper_round
    },
    [names.primary_weapons.rocket_launcher] =
    {
      names.primary_ammo.rockets
    }
  },

  secondary_weapons =
  {
    [names.secondary_weapons.smg] =
    {
      names.secondary_ammo.smg_rounds,
      names.secondary_ammo.smg_rounds,
    }
  },
  pistol_weapons =
  {
    [names.pistol_weapons.pistol] =
    {
      names.pistol_ammo.pistol_rounds
    },
    [names.pistol_weapons.revolver] =
    {
      names.pistol_ammo.magnum_rounds
    }
  }
}

return loadouts