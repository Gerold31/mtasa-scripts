-- TODO:
--   * care about isItemDefinitionDivisible(itemdef)


function getInventory(element, key)
	if (getInv0(element, key) == nil) then
		return nil
	end
	return setmetatable({["element"] = element, ["key"] = key}, Inventory)
end

function getInventories(element)
	local result = {}
	for key, _ in pairs(Inventories[element] or {}) do
		result[key] = setmetatable({["element"] = element, ["key"] = key}, Inventory)
	end
	return result
end

function isInventoryReady(inventory)
	local inv = getInv0(inventory)
	return isReady0(inv)
end

function getInventoryVolume(inventory)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	return inv.volume
end

function getInventoryUsedVolume(inventory)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	local volume = 0
	for _, stack in pairs(inv.items) do
		volume = volume + stack.amount * getItemDefinitionVolume(stack.type)
	end
	return volume
end

function getInventoryFreeVolume(inventory)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end
	return getInventoryVolume(inventory) - getInventoryUsedVolume(inventory)
end

function getInventoryMass(inventory)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	local mass = 0
	for _, stack in pairs(inv.items) do
		mass = mass + stack.amount * getItemDefinitionMass(stack.type)
	end
	return mass
end

function getInventoryItems(inventory)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	return getItems0(inv)
end

function getInventoryItemAmount(inventory, itemdef)
	local inv = getInv0(inventory)
	if (checkInvalidInventory(inv)) then return nil end
	return getItemAmount0(inv, itemdef)
end

function getInventoryIterator(inventory)
	local inv = getInv0(inventory)
	if (inv == nil) then
		return inventoryIterator, {}, nil
	else
		return inventoryIterator, inv.items, nil
	end
end

function canInventoryItemMove(from, to, itemdef, amount)
	local invFrom = getInv0(from)
	local invTo = getInv0(to)
	if (checkInvalidInventory(invFrom)) then return false end
	if (checkInvalidInventory(invTo)) then return false end

	if (getInventoryFreeVolume(to) < amount * getItemDefinitionVolume(itemdef)) then return false end
	return canItemsMove0(invFrom, invTo, itemdef, amount)
end

function doInventoryNewIndex(table, key, value)
	outputDebugString("Undefined key on inventory: [" .. tostring(key) .. "]=" .. tostring(value), 1)
end

function doInventoryToString(inventory)
	return "{Inventory:" .. tostring(inventory.element) .. ":" .. tostring(inventory.key) .. "}"
end

function checkInvalidInventory(inv)
	if (inv == nil) then
		invalid_call("Invalid inventory.", 1)
		return true
	end
	if (not isReady0(inv)) then
		invalid_call("Inventory not ready.", 1)
		return true
	end
	return false
end


if (Inventory == nil) then Inventory = {} end
Inventory.isReady = isInventoryReady
Inventory.getVolume = getInventoryVolume
Inventory.getUsedVolume = getInventoryUsedVolume
Inventory.getFreeVolume = getInventoryFreeVolume
Inventory.getMass = getInventoryMass
Inventory.getItems = getInventoryItems
Inventory.getItemAmount = getInventoryItemAmount
Inventory.getIterator = getInventoryIterator
Inventory.canItemMove = canInventoryItemMove
Inventory.__newindex = doInventoryNewIndex
Inventory.__tostring = doInventoryToString
Inventory.__metatable = false
Inventory.__index = Inventory


function inventoryIterator(items, last)
	local lastKey = nil
	if (last ~= nil) then
		lastKey = getItemDefinitionId(last.type)
	end
	key = next(items, lastKey)
	if (key ~= nil) then
		return deepcopy(items[key])
	end
end
