for k, sound in pairs (data.raw["ambient-sound"]) do
  data.raw["ambient-sound"][k] = nil
end
local path = util.path("data/soundtrack/")

local add = function(name)
  data:extend
  {
    {
      type = "ambient-sound",
      name = name,
      track_type = "main-track",
      sound =
      {
        filename = path..name..".ogg"
      }
    }
  }
end

add("Breakdown")
add("Broken Reality")
add("In a Heartbeat")
add("Pulse Rock")
add("Twisted")
