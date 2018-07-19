--Fuck it, just make all inserters 'Auto'

for k, inserter in pairs (data.raw.inserter) do
  inserter.energy_source.type = "void"
end