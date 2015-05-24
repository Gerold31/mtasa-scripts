-- Inventories[element][key]:
--   * ´listeners´ saves the clients which has open the inventory


function addInventory(element, key, volume)
	volume = volume or 0
	if (Inventories[element] == nil) then
		Inventories[element] = {}
	end
	if (Inventories[element][key] ~= nil) then
		outputDebugString("Inventory already exists: " .. tostring(element) .. ":" .. tostring(key), 2)
	else
		Inventories[element][key] = {
			["owner"] = element,
			["key"] = key,
			["volume"] = volume,
			["listeners"] = {},
			["items"] = {}
		}
	end
	return setmetatable({["element"] = element, ["key"] = key}, Inventory)
end

function removeInventory(element, key)
	if (key == nil) then
		key = element.key
		element = element.element
	end

	local inventory = getInventory(element, key)
	local inv = getInv(inventory)
	if (inv == nil) then return false end

	triggerClientEvent(inv.listeners, "clientInventoryClose", element, key)
	for _, client in pairs(inv.listeners) do
		triggerEvent("onInventoryClose", element, client, inventory)
	end

	Inventories[element][key] = nil
	if (next(Inventories[element]) == nil) then
		Inventories[element] = nil
	end

	return true
end

function setInventoryItems(inventory, items)
	local inv = getInv(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	if (not setItems(inventory, items)) then
		return false
	end

	local listeners = inv.listeners
	triggerEvent("onInventorySetItems", inventory.element)
	triggerClientEvent(listeners, "clientInventorySetItems", inventory.element, inventory.key, items)

	return true
end

function setInventoryItemAmount(inventory, itemdef, amount)
	local inv = getInv(inventory)
	if (checkInvalidInventory(inv)) then return nil end

	if (not setItemAmount(inventory, itemdef, amount)) then
		return false
	end

	local listeners = inv.listeners
	triggerEvent("onInventorySetItemAmount", inventory.element, inventory, itemdef, amount)
	triggerClientEvent(listeners, "clientInventorySetItemAmount", inventory.element, inventory.key, getItemDefinitionId(itemdef), amount)

	return true
end

function addInventoryItem(inventory, itemdef, amount)
	amount = amount or 1
	if (amount < 0) then return false end
	amount = getInventoryItemAmount(inventory, itemdef) + amount

	return setInventoryItemAmount(inventory, itemdef, amount)
end

function removeInventoryItem(inventory, itemdef, amount)
	amount = amount or 1
	if (amount < 0) then return false end
	amount = getInventoryItemAmount(inventory, itemdef) - amount

	return setInventoryItemAmount(inventory, itemdef, amount)
end

function moveInventoryItem(from, to, itemdef, amount)
	amount = amount or 1
	if (canInventoryItemMove(from, to, itemdef, amount)) then
		assert(removeInventoryItem(from, itemdef, amount))
		assert(addInventoryItem(to, itemdef, amount))
		return true
	else
		return false
	end
end


if (Inventory == nil) then Inventory = {} end
Inventory.remove = removeInventory
Inventory.setItems = setInventoryItems
Inventory.setItemAmount = setInventoryItemAmount
Inventory.addItem = addInventoryItem
Inventory.removeItem = removeInventoryItem
Inventory.moveItem = moveInventoryItem


-- source: inventory.element
-- onInventoryOpen(client, inventory)
addEvent("onInventoryOpen")
-- source: inventory.element
-- onInventoryClose(client, inventory)
addEvent("onInventoryClose")
-- source: inventory.element
-- onInventorySetItemAmount(inventory, itemdef, amount)
addEvent("onInventorySetItemAmount")
-- source: inventory.element
-- onInventorySetItems(inventory)
addEvent("onInventorySetItems")
-- source: inventory.element
-- onInventoryMoveItem(client, from, to, itemdef, amount, userdata)
addEvent("onInventoryMoveItem")
-- source: root
-- onInventoryStartup()
addEvent("onInventoryStartup")
-- source: root
-- onInventoryShutdown()
addEvent("onInventoryShutdown")

-- source: inventory.element
-- serverInventoryOpen(key)
addEvent("serverInventoryOpen", true)
-- source: inventory.element
-- serverInventoryClose(key)
addEvent("serverInventoryClose", true)
-- source: from.element
-- serverInventoryMoveItem(from.key, to.element, to.key, definitionId, amount)
addEvent("serverInventoryMoveItem", true)


function serverInventoryOpen(key)
	local inventory = getInventory(source, key)
	local inv = getInv(inventory)

	if (inv == nil) then
		triggerClientEvent(client, "clientInventoryClose", source, key)
		return
	end

	triggerEvent("onInventoryOpen", source, client, inventory)
	if (wasEventCancelled()) then
		triggerClientEvent(client, "clientInventoryClose", source, key)
	else
		inv.listeners[client] = client
		triggerClientEvent(client, "clientInventoryOpen", source, key, {
			["volume"] = inv.volume,
			["items"] = getInventoryItems(inventory)
		})
	end
end
addEventHandler("serverInventoryOpen", root, serverInventoryOpen)

function serverInventoryClose(key)
	local inventory = getInventory(source, key)
	local inv = getInv(inventory)
	if (inv == nil) then return end
	if (inv.listeners[client] == nil) then return end
	triggerEvent("onInventoryClose", source, client, inventory)
	inv.listeners[client] = nil
end
addEventHandler("serverInventoryClose", root, serverInventoryClose)

function serverInventoryMoveItem(from_key, to_element, to_key, definitionId, amount, userdata)
	local from = getInventory(source, from_key)
	local to = getInventory(to_element, to_key)
	local itemdef = getItemDefinition(definitionId)

	local accept = canInventoryItemMove(from, to, itemdef, amount)
	if (getInventoryFreeVolume(to) < amount * getItemDefinitionVolume(itemdef)) then
		accept = false
	end
	if (getInv(from).listeners[client] == nil or getInv(to).listeners[client] == nil) then
		accept = false
	end
	if (accept) then
		accept = triggerEvent("onInventoryMoveItem", root, client, from, to, itemdef, amount, userdata)
	end

	if (accept) then
		assert(removeInventoryItem(from, itemdef, amount))
		assert(addInventoryItem(to, itemdef, amount))
		-- TODO inform client about success
	else
		-- TODO inform client about cancel
	end
end
addEventHandler("serverInventoryMoveItem", root, serverInventoryMoveItem)

function onElementDestroy()
	if (Inventories[source] == nil) then return end
	for key, inv in pairs(Inventories[source]) do
		for _, client in pairs(inv.listeners) do
			local inventory = assert(getInventory(source, key))
			triggerEvent("onInventoryClose", source, client, inventory)
		end
	end
	Inventories[source] = nil
end
addEventHandler("onElementDestroy", root, onElementDestroy, true, "low-100")


addEventHandler("onResourceStart", resourceRoot,
	function()
		triggerEvent("onInventoryStartup", root)
	end, false
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		triggerEvent("onInventoryShutdown", root)
	end, false
)
