-- TODO:
--   * care about isItemDefinitionDivisible(itemdef)
-- Inventories[element][key]:
--   * ´owner´ saves the element where the inventory is attched to
--   * ´key´ saves the key of the inventory
--   * ´volume´ saves the amount of space in the inventory
--   * ´items´ saves the items in the inventory
--   * the keys of ´items´ are the ids of the item-definition
--   * the values in ´items´ are tables like {type=itemdef, amount=n}


Inventories = {}

function getInventory(element, key)
	if (getInv(element, key) == nil) then
		return nil
	end
	return setmetatable({["element"] = element, ["key"] = key}, Inventory)
end

function getInventories(element)
	local result = {}
	for key, _ in ipairs(Inventories[element]) do
		result[key] = setmetatable({["element"] = element, ["key"] = key}, Inventory)
	end
	return result
end

function isInventoryReady(inventory)
	local inv = getInv(inventory)
	if (inv ~= nil and inv.items ~= nil) then
		return true
	else
		return false
	end
end

function getInventoryVolume(inventory)
	local inv = getInv(inventory)
	if (inv == nil) then
		return nil
	else
		return inv.volume
	end
end

function getInventoryUsedVolume(inventory)
	local inv = getInv(inventory)
	if (inv == nil) then return nil end
	local volume = 0
	for _, stack in pairs(inv.items) do
		volume = volume + stack.amount * getItemDefinitionVolume(stack.type)
	end
	return volume
end

function getInventoryFreeVolume(inventory)
	local inv = getInv(inventory)
	if (inv == nil) then return nil end
	return getInventoryVolume(inventory) - getInventoryUsedVolume(inventory)
end

function getInventoryMass(inventory)
	local inv = Inventories[inventory.element][inventory.key]
	if (inv == nil) then return nil end
	local mass = 0
	for _, stack in pairs(inv.items) do
		mass = mass + stack.amount * getItemDefinitionWeight(stack.type)
	end
	return mass
end

function getInventoryItems(inventory)
	local inv = getInv(inventory)
	if (inv == nil) then return nil end

	local items = {}
	for definitionId, stack in pairs(inv.items) do
		table.insert(items, {
			["type"] = definitionId,
			["amount"] = stack.amount
		})
	end
	return items
end

function getInventoryItemAmount(inventory, itemdef)
	local definitionId = getItemDefinitionId(itemdef)
	local inv = getInv(inventory)
	if (inv == nil) then return nil end
	if (inv.items[definitionId] == nil) then return 0 end
	return inv.items[definitionId].amount
end

function getInventoryIterator(inventory)
	local inv = getInv(inventory)
	if (inv == nil) then
		return inventoryIterator, {}, nil
	else
		return inventoryIterator, inv.items, nil
	end
end

function canInventoryItemMove(from, to, itemdef, amount)
	if (not from or not to or not itemdef or not amount or amount < 0) then
		return false
	end
	if (getInventoryItemAmount(from) < amount) then
		return false
	end
	return true
end

function doInventoryNewIndex(table, key, value)
	outputDebugString("Undefined key on inventory: [" .. tostring(key) .. "]=" .. tostring(value), 1)
end

function doInventoryToString(inventory)
	return "{Inventory:" .. tostring(inventory.element) .. ":" .. tostring(inventory.key) .. "}"
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


function getInv(element, key)
	if (element == nil) then return nil end
	if (key == nil) then
		key = element.key
		element = element.element
	end

	if (Inventories[element] == nil) then
		return nil
	else
		return Inventories[element][key]
	end
end

function setItems(inventory, items)
	if (items == nil) then return false end
	local inv = getInv(inventory)
	if (inv == nil) then return false end

	inv.items = {}
	for _, stack in pairs(items) do
		local itemdef = getItemDefinition(stack.type)
		if (itemdef == nil) then
			-- TODO warning
		else
			inv.items[stack.type] = {
				["type"] = itemdef,
				["amount"] = stack.amount
			}
		end
	end

	return true
end

function setItemAmount(inventory, itemdef, amount)
	local inv = getInv(inventory)
	local definitionId = getItemDefinitionId(itemdef)
	if (inv == nil) then return false end
	if (amount < 0) then return false end

	if (amount > 0 and inv.items[definitionId] == nil) then
		inv.items[definitionId] = {
			["type"] = itemdef,
			["amount"] = amount
		}
		return true
	end
	if (amount > 0 and inv.items[definitionId] ~= nil) then
		inv.items[definitionId].amount = amount
		return true
	end
	if (amount == 0 and inv.items[definitionId] ~= nil) then
		inv.items[definitionId] = nil
		return true
	end
end

function addItem(inventory, itemdef, amount)
	amount = amount or 1
	amount = getInventoryItemAmount(inventory, itemdef) + amount
	return setItemAmount(inventory, itemdef, amount)
end

function removeItem(inventory, itemdef, amount)
	amount = amount or 1
	amount = getInventoryItemAmount(inventory, itemdef) - amount
	return setItemAmount(inventory, itemdef, amount)
end

function inventoryIterator(items, last)
	local lastKey = nil
	if (last ~= nil) then
		lastKey = getItemDefinitionId(last.type)
	end
	key = next(items, lastKey)
	if (key ~= nil) then
		return shallowcopy(items[key])
	end
end

function shallowcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
