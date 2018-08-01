--Sorry pal, achievers need not apply

for k, prot in pairs (data.raw) do
  if string.find(k, "achievement") then
    data.raw[k] = nil
  end
end