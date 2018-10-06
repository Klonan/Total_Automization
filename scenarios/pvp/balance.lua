local combat_technologies =
{
  "follower-robot-count",
  "combat-robot-damage",
  "laser-turret-damage",
  "laser-turret-speed",
  "bullet-damage",
  "bullet-speed",
  "shotgun-shell-damage",
  "shotgun-shell-speed",
  "gun-turret-damage",
  "rocket-damage",
  "rocket-speed",
  "grenade-damage",
  "flamethrower-damage",
  "cannon-shell-damage",
  "cannon-shell-speed",
  "artillery-shell-range",
  "artillery-shell-speed"
}

local balance = {script_data = {}}

balance.disable_combat_technologies = function(force)
  if balance.script_data.config.team_config.unlock_combat_research then return end --If true, then we want them to stay unlocked
  local tech = force.technologies
  for k, name in pairs (combat_technologies) do
    local i = 1
    repeat
      local full_name = name.."-"..i
      if tech[full_name] then
        tech[full_name].researched = false
      end
      i = i + 1
    until not tech[full_name]
  end
end

balance.apply_character_modifiers = function(player)
  local apply = function(player, name, modifier)
    player[name] = modifier
  end
  --Because some things want greater than 0, others wants greater than -1.
  --Better to just catch the error than making some complicated code.
  for name, modifier in pairs (balance.script_data.config.modifier_list.character_modifiers) do
    local status, error = pcall(apply, player, name, modifier)
    if not status then
      log(name)
      log(error)
      balance.script_data.config.modifier_list.character_modifiers[name] = 0
    end
  end
end

balance.init = function()
  local modifier_list =
  {
    character_modifiers =
      {
        character_running_speed_modifier = 0,
        character_health_bonus = 0,
        character_crafting_speed_modifier = 0,
        character_mining_speed_modifier = 0,
        character_build_distance_bonus = 0,
        character_reach_distance_bonus = 0,
      },
    turret_attack_modifier = {},
    ammo_damage_modifier ={},
    gun_speed_modifier = {}
  }
  local entities = game.entity_prototypes
  local turret_types = {
    ["ammo-turret"] = true,
    ["electric-turret"] = true,
    ["fluid-turret"] = true,
    ["artillery-turret"] = true,
    ["turret"] = true
  }
  for name, entity in pairs (entities) do
    if turret_types[entity.type] then
      modifier_list.turret_attack_modifier[name] = 0
    end
  end
  for name, ammo in pairs (game.ammo_category_prototypes) do
    modifier_list.ammo_damage_modifier[name] = 0
    modifier_list.gun_speed_modifier[name] = 0
  end
  balance.script_data.config.modifier_list = modifier_list
end

balance.apply_combat_modifiers = function(force)

  local entities = game.entity_prototypes

  for name, modifier in pairs (balance.script_data.config.modifier_list.turret_attack_modifier) do
    if entities[name] then
      force.set_turret_attack_modifier(name, force.get_turret_attack_modifier(name) + modifier)
    else
      log(name.." removed from turret attack modifiers, as it is not a valid turret prototype")
      balance.script_data.config.modifier_list.turret_attack_modifier[name] = nil
    end
  end

  local ammo = game.ammo_category_prototypes

  for name, modifier in pairs (balance.script_data.config.modifier_list.ammo_damage_modifier) do
    if ammo[name] then
      force.set_ammo_damage_modifier(name, force.get_ammo_damage_modifier(name) + modifier)
    else
      log(name.." removed from ammo damage modifiers, as it is not a valid turret prototype")
      balance.script_data.config.modifier_list.ammo_damage_modifier[name] = nil
    end
  end

  for name, modifier in pairs (balance.script_data.config.modifier_list.gun_speed_modifier) do
    if ammo[name] then
      force.set_gun_speed_modifier(name, force.get_gun_speed_modifier(name) + modifier)
    else
      balance.script_data.config.modifier_list.gun_speed_modifier[name] = nil
    end
  end

end

return balance
