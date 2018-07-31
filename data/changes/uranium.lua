--We don't want uranium

local remove = util.prototype.remove_entity_prototype

remove(data.raw["assembling-machine"]["centrifuge"])
remove(data.raw.resource.uranium)
