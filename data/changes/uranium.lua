--We don't want uranium

local remove = util.prototype.remove_entity_prototype

remove(data.raw["assembling-machine"]["centrifuge"])
remove(data.raw.resource["uranium-ore"])
data.raw.resource["uranium-ore"] = nil
--data.raw["autoplace-control"]["uranium-ore"] = nil
