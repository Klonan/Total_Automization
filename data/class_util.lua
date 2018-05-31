local util = require("util")
local recursive_hack_scale
recursive_hack_scale = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if v.width and v.height and v.filename then
        v.scale = scale
        if v.shift then
          --v.shift[1], v.shift[2] = v.shift[1] * scale, v.shift[2] * scale
        end
      end
      recursive_hack_scale(v, scale)
    end
  end
end

local recursive_hack_animation_speed
recursive_hack_animation_speed = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if v.width and v.height and v.filename and v.animation_speed then
        v.animation_speed = v.animation_speed * scale
      end
      recursive_hack_animation_speed(v, scale)
    end
  end
end

local recursive_hack_tint
recursive_hack_tint = function(array, tint)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if v.width and v.height and v.filename then
        v.tint = tint
      end
      recursive_hack_tint(v, tint)
    end
  end
end

util.scale_boxes = function(prototype, scale)
  for k, v in pairs {"collision_box", "selection_box"} do
    local box = prototype[v]
    if box then
      local width = (box[2][1] - box[1][1]) * (scale / 2)
      local height = (box[2][2] - box[1][2]) * (scale / 2)
      local x = (box[1][1] + box[2][1]) / 2
      local y = (box[1][2] + box[2][2]) / 2
      box[1][1], box[2][1] = x - width, x + width
      box[1][2], box[2][2] = y - height, y + height
    end
  end
end

util.base_player = function()
  
  local player = util.table.deepcopy(data.raw.player.player or error("Wat man cmon why"))
  player.ticks_to_keep_gun = SU(600)
  player.ticks_to_keep_aiming_direction = SU(100)
  player.ticks_to_stay_in_combat = SU(600)
  for k, v in pairs (player.flags) do
    if v == "not-flammable" then
      table.remove(player.flags, k)
      break
    end
  end
  return player
end

util.recursive_hack_scale = recursive_hack_scale
util.recursive_hack_animation_speed = recursive_hack_animation_speed
util.recursive_hack_tint = recursive_hack_tint
util.copy = util.table.deepcopy
return util