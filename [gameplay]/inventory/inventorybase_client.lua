-- Inventories[element][key]:
--   * ´items´ and ´volume´ are nil until server sends the data
--   * ´openCount´ saves how often the inventory was opend


function openInventory1(element, key)
	if (Inventories[element] == nil) then
		Inventories[element] = {}
		addEventHandler("onClientElementDestroy", element, onClientElementDestroy, false, "high+100")
	end

	if (Inventories[element][key] == nil) then
		Inventories[element][key] = {
			["owner"] = element,
			["key"] = key,
			["openCount"] = 0
		}
	end
	triggerServerEvent("serverInventoryOpen", element, key)

	return setmetatable({["element"] = element, ["key"] = key}, Inventory)
end

function closeInventory1(inventory, nosync)
	local element = inventory.element
	local key = inventory.key
	local inv = getInv0(inventory)
	if (inv == nil) then return end

	if (not nosync) then
		triggerServerEvent("serverInventoryClose", element, key)
	end
	inv.openCount = 0
	triggerEvent("onClientInventoryClose", element, inventory)

	if (inv.openCount == 0) then
		Inventories[element][key] = nil
		if (next(Inventories[element]) == nil) then
			Inventories[element] = nil
			removeEventHandler("onClientElementDestroy", element, onClientElementDestroy)
		end
	else
		inv.items = nil
		inv.volume = nil
	end
end

function moveItem1(from, to, itemdef, amount, userdata)
	triggerServerEvent("serverInventoryMoveItem", from.element, from.key, to.element, to.key, getItemDefinitionId(itemdef), amount, userdata)
end


-- source: root
-- clientInventoryApplay(changes)
addEvent("clientInventoryApplay", true)

function clientInventoryApplay(changes)
	for _, update in pairs(changes) do
		local inventory = assert(update.i)
		local event = assert(update.e)
		local data = assert(update.d)
		triggerEvent(event, inventory.element, inventory.key, unpack(data))
	end
end
addEventHandler("clientInventoryApplay", root, clientInventoryApplay)


-- source: inventory.element
-- clientInventoryOpen(key, inventory_data) [data with items]
addEvent("clientInventoryOpen", true)
-- source: inventory.element
-- clientInventoryClose(key)
addEvent("clientInventoryClose", true)
-- source: inventory.element
-- clientInventoryUpdate(key, inventory_data) [data without items]
addEvent("clientInventoryUpdate", true)
-- source: inventory.element
-- clientInventorySetItemAmount(key, items)
addEvent("clientInventorySetItemAmount", true)
-- source: inventory.element
-- clientInventorySetItemAmount(key, items)
addEvent("clientInventorySetItems", true)


function clientInventoryOpen(key, inventory_data)
	local inventory = getInventory(source, key)
	local inv = getInv0(inventory)
	if (inv == nil) then
		outputDebugString("Server sends inventory initialisation but inventory does not exist: {" .. tostring(source) .. ":" .. tostring(key) .. "}", 3)
		return
	end
	assert(not isReady0(inv))

	inv.volume = inventory_data.volume
	inv.items = {}
	setItems0(inv, inventory_data.items)
	triggerEvent("onClientInventoryOpen", source, inventory)
end
addEventHandler("clientInventoryOpen", root, clientInventoryOpen)

function clientInventoryClose(key)
	local inv = getInv0(source, key)
	if (inv == nil) then return end
	local inventory = getInventory(source, key)
	closeInventory1(inventory, true)
end
addEventHandler("clientInventoryClose", root, clientInventoryClose)

function clientInventoryUpdate(key, inventory_data)
	local inv = getInv0(source, key)
	if (isReady0(inv)) then
		inv.volume = inventory_data.volume
		triggerEvent("onClientInventoryUpdate", source, assert(getInventory(source, key)))
	end
end
addEventHandler("clientInventoryUpdate", root, clientInventoryUpdate)

function clientInventorySetItemAmount(key, definitionId, amount)
	local itemdef = getItemDefinition(definitionId)
	local inv = getInv0(source, key)
	if (isReady0(inv)) then
		assert(setItemAmount0(inv, itemdef, amount))
		triggerEvent("onClientInventorySetItemAmount", source, inventory, itemdef, amount)
	end
end
addEventHandler("clientInventorySetItemAmount", root, clientInventorySetItemAmount)

function clientInventorySetItems(key, items)
	local inv = getInv0(source, key)
	if (isReady0(inv)) then
		assert(setItems0(inv, items))
		triggerEvent("onClientInventorySetItems", source, inventory)
	end
end
addEventHandler("clientInventorySetItems", root, clientInventorySetItems)

function onClientElementDestroy()
	for key, _ in pairs(Inventories[source]) do
		triggerEvent("onClientInventoryClose", source, assert(getInventory(source, key)))
	end
	Inventories[source] = nil
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerEvent("onClientInventoryStartup", root)
	end, false
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		triggerEvent("onClientInventoryShutdown", root)
		-- TODO trigger onClientInventoryClose
	end, false
)
