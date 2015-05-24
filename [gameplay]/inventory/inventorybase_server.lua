-- Inventories[element][key]:
--   * ´listeners´ saves the clients which has open the inventory


local d = {
	changes = {}
}

function addInventory1(element, key, volume)
	volume = volume or 0
	if (Inventories[element] == nil) then
		Inventories[element] = {}
	end
	if (Inventories[element][key] ~= nil) then
		invalid_call("Inventory already exists: {" .. tostring(element) .. ":" .. tostring(key) .. "}")
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

function removeInventory1(inventory)
	local inv = getInv0(inventory)
	if (inv == nil) then return false end
	local element = inventory.element
	local key = inventory.key

	listener_send(inventory, "clientInventoryClose")
	for _, client in pairs(inv.listeners) do
		triggerEvent("onInventoryClose", element, client, inventory)
	end

	Inventories[element][key] = nil
	if (next(Inventories[element]) == nil) then
		Inventories[element] = nil
	end

	return true
end

function setItems1(inventory, items)
	local inv = getInv0(inventory)
	if (not setItems0(inv, items)) then
		return false
	end

	triggerEvent("onInventorySetItems", inventory.element)
	listener_send(inventory, "clientInventorySetItems", items)

	return true
end

function setItemAmount1(inventory, itemdef, amount)
	local inv = getInv0(inventory)
	if (not setItemAmount0(inv, itemdef, amount)) then
		return false
	end

	triggerEvent("onInventorySetItemAmount", inventory.element, inventory, itemdef, amount)
	listener_send(inventory, "clientInventorySetItemAmount", getItemDefinitionId(itemdef), amount)

	return true
end


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
	local inv = getInv0(inventory)

	if (not isReady0(inv)) then
		inventory = {element = source, key = key}
		listener_send(client, inventory, "clientInventoryClose")
		return
	end
	if (inv.listeners[client] ~= nil) then
		outputDebugString("Client request inventory but it is already open.")
		return
	end

	triggerEvent("onInventoryOpen", source, client, inventory)
	if (wasEventCancelled()) then
		listener_send(client, inventory, "clientInventoryClose")
	else
		inv.listeners[client] = client
		listener_send(client, inventory, "clientInventoryOpen", {
			["volume"] = inv.volume,
			["items"] = getItems0(inv)
		})
	end
end
addEventHandler("serverInventoryOpen", root, serverInventoryOpen)

function serverInventoryClose(key)
	local inventory = getInventory(source, key)
	local inv = getInv0(inventory)
	if (not isReady0(inv)) then
		outputDebugString("Client closes inventory which does not exist.")
		return
	end
	if (inv.listeners[client] == nil) then
		outputDebugString("Client closes inventory which was not open.")
		return
	end
	inv.listeners[client] = nil
	triggerEvent("onInventoryClose", source, client, inventory)
end
addEventHandler("serverInventoryClose", root, serverInventoryClose)

function serverInventoryMoveItem(from_key, to_element, to_key, definitionId, amount, userdata)
	local from = getInventory(source, from_key)
	local to = getInventory(to_element, to_key)
	local itemdef = getItemDefinition(definitionId)

	local accept = canInventoryItemMove(from, to, itemdef, amount)
	if (getInv0(from).listeners[client] == nil or getInv0(to).listeners[client] == nil) then
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
	d.changes[source] = nil
end
addEventHandler("onElementDestroy", root, onElementDestroy, true, "low-100")


addEventHandler("onResourceStart", resourceRoot,
	function ()
		triggerEvent("onInventoryStartup", root)
	end, false
)

addEventHandler("onResourceStop", resourceRoot,
	function ()
		triggerEvent("onInventoryShutdown", root)
	end, false
)

addEventHandler("onPlayerQuit", root,
	function ()
		-- TODO make it faster ?
		for element, elementInventories in pairs(Inventories) do
			for key, inv in pairs(elementInventories) do
				if (inv.listeners[source] ~= nil) then
					triggerEvent("onInventoryClose", element, source, assert(getInventory(element, key)))
					inv.listeners[source] = nil
				end
			end
		end
	end
)


function onTick()
	for client, data in pairs(d.changes) do
		triggerClientEvent(client, "clientInventoryApplay", root, data)
	end
	d.changes = {}
end
setTimer(onTick, 50, 0)

--       listener_send(inventory, event, ...)
--       listener_send(client, inventory, event, ...)
function listener_send(arg1, arg2, arg3, ...)
	local clients = nil
	local inventory = nil
	local event = nil
	local data = nil
	if (arg1.element and arg1.key) then
		clients = getInv0(arg1).listeners
		inventory = arg1
		event = arg2
		data = {arg3, ...}
	else
		clients = {arg1}
		inventory = arg2
		event = arg3
		data = {...}
	end

	local inv = getInv0(inventory)
	for _, listener in pairs(clients) do
		if (d.changes[listener] == nil) then
			d.changes[listener] = {}
		end
		table.insert(d.changes[listener], {
			i = assert(inventory),
			e = assert(event),
			d = assert(data)
		})
	end
end
